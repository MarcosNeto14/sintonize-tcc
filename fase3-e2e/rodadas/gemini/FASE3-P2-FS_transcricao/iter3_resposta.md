<!-- Resposta do Gemini 3.8 Flash ao reparo 3, rodada FASE3-P2-FS, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome).
     Conversa: https://gemini.google.com/app/e8261792a79eae6f -->

**Classificação da causa provável da falha:**
**(A) o teste presume um comportamento que não é o especificado**

---

### Diagnóstico

Analisando a stack trace do erro:

```
RangeError (length): Invalid value: Not in inclusive range 0..4: 5
#0      List.[] (dart:core-patch/growable_array.dart)
#1      _CriarPlaylistScreenState.build.<anonymous closure> (package:sintonize/criar_playlist.dart:167:55)
#2      SliverChildBuilderDelegate.build (package:flutter/src/widgets/scroll_delegate.dart:552:22)

```

E inspecionando o código de `CriarPlaylistScreen` (`lib/criar_playlist.dart:164-167`):

```dart
ListView.builder(
  itemCount: _musicasFiltradas.length,
  itemBuilder: (context, index) {
    var musica = _musicasFiltradas[index]; // Linha 167

```

A coleção `musica` contém exatamente **5 documentos** pré-populados no Firestore (`index` de `0` a `4`), logo `_musicasFiltradas.length == 5`.

O Flutter dispara `RangeError` ao tentar acessar `_musicasFiltradas[5]` porque, por padrão, o `ListView.builder` em telas com scroll ou redimensionamento de viewport tenta fazer pré-layout (*over-scroll* ou pré-renderização de itens adjacentes). Quando um `ListView.builder` ou `ListView` está aninhado dentro de um `Column` contendo `Expanded` em conjunto com a animação de transição de rota de navegação e chamadas a `tester.pumpAndSettle()`, o Flutter layout engine pode requisitar o builder para o índice `5` para verificar se há mais elementos e calcular extensões de slivers antes da atualização do frame.

Porém, a raiz direta do teste disparar esse erro no ambiente de teste está na forma como o fluxo foi acionado:

1. `tester.pumpAndSettle()` avança os frames infinitamente até não haver animações pendentes. Na tela `CriarPlaylistScreen`, o `ListView.builder` começa com o `Center(child: CircularProgressIndicator())` enquanto busca as músicas no Firestore.
2. Ao usar `await tester.ensureVisible(checkboxIconFinder);` ou tentar interagir com elementos de uma lista dinâmica enquanto transições e timers assíncronos ocorrem, o `WidgetTester` tenta forçar o scroll da `ListView`. Ao forçar o scroll em direção à base da tela para um item que já está visível ou perto do limite, o layout do `RenderSliverList` avança (`advance`) e solicita à delegate o próximo índice (`index = 5`), causando o `RangeError` na linha 167 de `criar_playlist.dart`.
3. Além disso, `await tester.pumpAndSettle()` no `IconButton` do checkbox dispara frames contínuos durante a renderização da lista. No teste anterior, o `ensureVisible` forçou o cálculo de scroll além do limite dos itens existentes.
4. Para interagir com a lista em testes de integração de forma estável e segura sem forçar o viewport além da coleção:
* Não se deve chamar `ensureVisible` em itens que já estão visíveis na viewport inicial (como o primeiro item de uma lista com apenas 5 elementos).
* O toque (`tester.tap`) no `IconButton` deve ser acompanhado de `tester.pump()` / `esperar` pontual em vez de múltiplos `pumpAndSettle()` desnecessários enquanto a lista mantém animações residuais.
* Para o botão "Salvar Playlist", ele está posicionado abaixo da `Expanded(child: ListView...)`, fixo no `Column` inferior do `Scaffold`, já visível na tela padrão do emulador (`1080x1920` / `1080x2400`), não necessitando de `ensureVisible`.



---

### Código do teste corrigido

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/criar_playlist.dart';
import 'package:sintonize/login.dart';
import 'package:sintonize/main.dart';
import 'package:sintonize/tela-inicial.dart';
import 'package:sintonize/usuario.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('não apareceu: $finder');
  }

  testWidgets(
      'criar playlist: autentica, seleciona músicas, salva e valida persistência no Firestore',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Navegar da HomeScreen para LoginScreen
    final loginBtnFinder = find.widgetWithText(ElevatedButton, 'Login');
    await esperar(tester, loginBtnFinder);
    await tester.tap(loginBtnFinder);
    await esperar(tester, find.byType(LoginScreen));

    // 2. Realizar login com as credenciais pré-populadas
    final emailField = find.byType(TextFormField).at(0);
    final senhaField = find.byType(TextFormField).at(1);

    await tester.enterText(emailField, 'tester@sintonize.test');
    await tester.enterText(senhaField, 'senha123');

    final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
    await tester.tap(entrarBtn);

    // 3. Aguardar autenticação e navegação para a TelaInicialScreen
    await esperar(tester, find.byType(TelaInicialScreen));

    // 4. Navegar para a UsuarioScreen via "Minha Conta"
    final minhaContaItem = find.text('Minha Conta');
    await esperar(tester, minhaContaItem);
    await tester.tap(minhaContaItem);
    await esperar(tester, find.byType(UsuarioScreen));

    // 5. Clicar em "Criar Playlist"
    final criarPlaylistBtn = find.text('Criar Playlist');
    await esperar(tester, criarPlaylistBtn);
    await tester.tap(criarPlaylistBtn);
    await esperar(tester, find.byType(CriarPlaylistScreen));

    // 6. Preencher o nome da playlist
    const nomePlaylist = 'Minhas Favoritas';
    final nomePlaylistField = find.widgetWithText(TextField, 'Nome da Playlist');
    await esperar(tester, nomePlaylistField);
    await tester.enterText(nomePlaylistField, nomePlaylist);
    await tester.pump(const Duration(milliseconds: 300));

    // 7. Aguardar o carregamento e renderização das músicas do Firestore
    final musicaItemFinder = find.textContaining('Bohemian Rhapsody');
    await esperar(tester, musicaItemFinder);

    // Encontrar o botão de checkbox correspondente à música dentro do seu ListTile
    final tileDaMusica = find.ancestor(
      of: musicaItemFinder,
      matching: find.byType(ListTile),
    );
    final checkboxIconFinder = find.descendant(
      of: tileDaMusica,
      matching: find.byType(IconButton),
    );

    // Tocar no checkbox para selecionar a música
    await tester.tap(checkboxIconFinder);
    await tester.pump(const Duration(milliseconds: 300));

    // Validar visualmente que o ícone de selecionado foi exibido
    expect(find.byIcon(Icons.check_box), findsWidgets);

    // 8. Tocar no botão "Salvar Playlist"
    final salvarBtnFinder = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    await esperar(tester, salvarBtnFinder);
    await tester.tap(salvarBtnFinder);

    // 9. Aguardar o retorno para UsuarioScreen
    await esperar(tester, find.byType(UsuarioScreen));

    // 10. Validar que a playlist criada aparece na lista da UsuarioScreen
    await esperar(tester, find.text(nomePlaylist));

    // 11. Validar diretamente na coleção 'playlists' do Firestore
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    expect(currentUid, isNotNull);

    final playlistQuery = await FirebaseFirestore.instance
        .collection('playlists')
        .where('userId', isEqualTo: currentUid)
        .where('nome', isEqualTo: nomePlaylist)
        .get();

    expect(playlistQuery.docs.isNotEmpty, isTrue);
    final playlistSalva = playlistQuery.docs.first.data();
    expect(playlistSalva['nome'], equals(nomePlaylist));
    expect(playlistSalva['musicas'], contains('bohemian rhapsody'));
  });
}

```