<!-- Resposta do Gemini 3.8 Flash ao reparo 2, rodada FASE3-P2-FS, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome).
     Conversa: https://gemini.google.com/app/e8261792a79eae6f -->

**Classificação da causa provável da falha:**
**(A) o teste presume um comportamento que não é o especificado**

---

### Diagnóstico

Na implementação de `CriarPlaylistScreen` (`lib/criar_playlist.dart`):

```dart
  @override
  void initState() {
    super.initState();
    _fetchMusicas();
    _searchController.addListener(_filterMusicas);
  }

  void _filterMusicas() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _musicasFiltradas = _musicasDataset.where((musica) {
        String musicaNome = musica['track_name'].toLowerCase();
        String artistName = musica['artist_name']?.toLowerCase() ?? '';
        return musicaNome.contains(query) || artistName.contains(query);
      }).toList();
    });
  }

```

O `_searchController` possui um listener ativo (`_filterMusicas`). No entanto, o campo onde digitamos o nome da playlist foi definido assim:

```dart
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: TextField(
      controller: _nomeController,
      decoration: InputDecoration(
        labelText: 'Nome da Playlist',
...
      onChanged: (value) {
        setState(() {
          _playlistName = value;
        });
      },
    ),
  ),

```

No teste anterior, o comando `await tester.enterText(nomePlaylistField, nomePlaylist);` foi executado **antes** de esperar a coleção de músicas ser completamente carregada do Firestore. Ao digitar no campo de texto e disparar o `setState` ou interagir com os widgets de entrada enquanto a requisição assíncrona `_fetchMusicas()` terminava de popular `_musicasDataset`, o `ListView.builder` iniciou uma reconstrução (build frame) com o `itemCount: _musicasFiltradas.length` desfasado em relação à lista interna durante o ciclo de layout/scroll dos slivers, resultando em:
`RangeError (length): Invalid value: Not in inclusive range 0..4: 5` na linha 167 de `criar_playlist.dart`:

```dart
var musica = _musicasFiltradas[index];

```

Além disso, em testes de interface no Flutter com listas que carregam de serviços assíncronos, deve-se primeiro aguardar a conclusão do carregamento dos itens (esperando a lista renderizar na árvore) para que o estado do widget esteja estabilizado antes de interagir com os campos e listas, e usar métodos seguros para encontrar e rolar até o item (`ensureVisible`), evitando que o builder acesse índices fora de sincronia.

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

    // 1. Tela de Boas-vindas -> Navegar para LoginScreen
    final loginBtnFinder = find.widgetWithText(ElevatedButton, 'Login');
    await esperar(tester, loginBtnFinder);
    await tester.tap(loginBtnFinder);
    await esperar(tester, find.byType(LoginScreen));

    // 2. Preencher credenciais pré-populadas no emulador
    final emailField = find.byType(TextFormField).at(0);
    final senhaField = find.byType(TextFormField).at(1);

    await tester.enterText(emailField, 'tester@sintonize.test');
    await tester.enterText(senhaField, 'senha123');

    final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
    await tester.tap(entrarBtn);

    // 3. Aguardar autenticação e navegação para a TelaInicialScreen
    await esperar(tester, find.byType(TelaInicialScreen));

    // 4. Navegar para a UsuarioScreen ("Minha Conta" no BottomNavigationBar)
    final minhaContaItem = find.text('Minha Conta');
    await esperar(tester, minhaContaItem);
    await tester.tap(minhaContaItem);
    await esperar(tester, find.byType(UsuarioScreen));

    // 5. Acessar a tela CriarPlaylistScreen
    final criarPlaylistBtn = find.text('Criar Playlist');
    await esperar(tester, criarPlaylistBtn);
    await tester.tap(criarPlaylistBtn);
    await esperar(tester, find.byType(CriarPlaylistScreen));

    // 6. Aguardar primeiro o carregamento assíncrono das músicas no Firestore
    // Isso garante que _musicasDataset e _musicasFiltradas estejam povoados
    // e estáveis antes de disparar eventos de digitação e re-renders.
    final musicaItemFinder = find.textContaining('Bohemian Rhapsody');
    await esperar(tester, musicaItemFinder);
    await tester.pumpAndSettle();

    // 7. Preencher o nome da playlist
    const nomePlaylist = 'Minhas Favoritas';
    final nomePlaylistField = find.widgetWithText(TextField, 'Nome da Playlist');
    await esperar(tester, nomePlaylistField);
    await tester.enterText(nomePlaylistField, nomePlaylist);
    await tester.pumpAndSettle();

    // 8. Selecionar o checkbox da música
    final tileDaMusica = find.ancestor(
      of: musicaItemFinder,
      matching: find.byType(ListTile),
    );
    final checkboxIconFinder = find.descendant(
      of: tileDaMusica,
      matching: find.byType(IconButton),
    );

    await tester.ensureVisible(checkboxIconFinder);
    await tester.tap(checkboxIconFinder);
    await tester.pumpAndSettle();

    // Confirmar visualmente a seleção do checkbox
    expect(find.byIcon(Icons.check_box), findsWidgets);

    // 9. Tocar em "Salvar Playlist"
    final salvarBtnFinder = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    await tester.ensureVisible(salvarBtnFinder);
    await tester.tap(salvarBtnFinder);

    // 10. Aguardar o retorno para a UsuarioScreen
    await esperar(tester, find.byType(UsuarioScreen));

    // 11. Validar a nova playlist na tela de usuário
    await esperar(tester, find.text(nomePlaylist));

    // 12. Validar a persistência no banco de dados Firestore
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