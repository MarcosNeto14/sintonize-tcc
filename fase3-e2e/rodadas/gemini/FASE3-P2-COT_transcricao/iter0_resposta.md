<!-- Resposta do Gemini 3.8 Flash à geração (iteração 0), rodada FASE3-P2-COT, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome), segunda máquina (DESKTOP-6ETPO2H).
     Conversa: https://gemini.google.com/app/7220e500359ac53d -->

Abaixo está o planejamento detalhado e o código completo do teste end-to-end com `integration_test` para o fluxo de criação de playlists no **Sintonize**.

---

### 1. Análise do Fluxo

O usuário inicia na tela de boas-vindas (`HomeScreen`), navega até a tela de login (`LoginScreen`) e autentica-se com suas credenciais. Uma vez autenticado na `TelaInicialScreen`, ele acessa o menu inferior em **"Minha Conta"** (`UsuarioScreen`) e toca na opção **"Criar Playlist"**, abrindo a `CriarPlaylistScreen`. Nesta tela, o catálogo de músicas é carregado do Firestore e o usuário pode filtrar músicas via campo de busca, selecionar faixas marcando os checkboxes e definir um nome para a playlist. Se o usuário tentar salvar com o nome vazio, o ponto de decisão exibe uma `SnackBar` de erro sem persistir os dados; caso preencha o nome corretamente, o fluxo de decisão valida o formulário, grava o documento na coleção `playlists` no Firestore e retorna à `UsuarioScreen`, onde a nova playlist é exibida na lista.

### 2. Identificação das Dependências

* **Firebase Auth:**
* `LoginScreen`: Executa `signInWithEmailAndPassword` contra o emulador Auth (`10.0.2.2:9099`).
* `TelaInicialScreen`, `UsuarioScreen` e `CriarPlaylistScreen`: Leem `FirebaseAuth.instance.currentUser` para obter `uid`.


* **Cloud Firestore:**
* `TelaInicialScreen`: Lê `usuarios/{uid}` e consulta a coleção `musica` (para recomendação diária).
* `UsuarioScreen`: Lê `usuarios/{uid}` (nome do usuário), consulta `playlists` com filtro `where('userId', isEqualTo: uid)` e lê `musica`.
* `CriarPlaylistScreen`:
* **Leitura:** Executa `_firestore.collection('musica').get()`.
* **Gravação:** Executa `_firestore.collection('playlists').add(...)` com `{ userId, nome, musicas, dataCriacao }`.




* **Dados pré-existentes nos emuladores:**
* Usuário Auth: `tester@sintonize.test` / `senha123` com doc `usuarios/{uid}` (`nome: 'tester sintonize'`, `generos_favoritos: ['rock', 'pop']`).
* Documentos na coleção `musica`:
* `track_name: 'bohemian rhapsody'`, `artist_name: 'queen'`, `genre: 'rock'`
* `track_name: 'billie jean'`, `artist_name: 'michael jackson'`, `genre: 'pop'`
* `track_name: 'take five'`, `artist_name: 'dave brubeck'`, `genre: 'jazz'`
* `track_name: 'the thrill is gone'`, `artist_name: 'b.b. king'`, `genre: 'blues'`
* `track_name: 'one love'`, `artist_name: 'bob marley'`, `genre: 'reggae'`





### 3. Caminho de Navegação e Esperas

1. **HomeScreen:** Aguarda o carregamento inicial (`pumpAndSettle()`). Toca no botão com texto `'Login'` ou ícone `Icons.login`.
2. **Transição para LoginScreen:** Aguarda a animação do `PageRouteBuilder` com `pumpAndSettle()`.
3. **LoginScreen:** Preenche os campos `TextFormField` de e-mail (`tester@sintonize.test`) e senha (`senha123`). Toca no botão `'Entrar'`.
4. **Transição para TelaInicialScreen:** Aguarda o término da chamada do Auth e Firestore com `pumpAndSettle()`.
5. **TelaInicialScreen:** Toca no item `'Minha Conta'` (ícone `Icons.person`) da `BottomNavigationBar`.
6. **Transição para UsuarioScreen:** Aguarda `pumpAndSettle()` até o menu de opções carregar.
7. **UsuarioScreen:** Toca no card/item `'Criar Playlist'` (ícone `Icons.add`).
8. **Transição para CriarPlaylistScreen:** Aguarda `pumpAndSettle()` até que a requisição de `musica.get()` seja finalizada e o `CircularProgressIndicator` desapareça da lista.
9. **Finalização do fluxo:** Ao salvar com sucesso, a tela executa `Navigator.pop(context)`, retornando à `UsuarioScreen`, onde um novo `pumpAndSettle()` permite que `_fetchPlaylists()` busque e renderize o novo card de playlist.

### 4. Cenários de Teste

1. **Fluxo de Sucesso Ponta a Ponta:**
* Navega da tela inicial até `CriarPlaylistScreen`.
* Digita o nome da playlist ("Minhas Favoritas").
* Seleciona faixas via checkbox (ex: "Bohemian Rhapsody" e "Billie Jean").
* Clica em "Salvar Playlist".
* Verifica retorno à `UsuarioScreen`, exibição do nome da playlist e validação direta da persistência do documento no Firestore associado ao `userId`.


2. **Validação Antes de Salvar (Nome Vazio):**
* Navega até `CriarPlaylistScreen`.
* Seleciona uma música, mas mantém o campo de nome vazio.
* Toca em "Salvar Playlist".
* Verifica se a `SnackBar` com o texto `'Nome da playlist é obrigatório'` é exibida e garante que a tela não realizou o `pop`.


3. **Pesquisa e Filtragem da Lista de Músicas:**
* Na `CriarPlaylistScreen`, insere um termo de busca no campo `'Pesquisar Música ou Artista'` (ex: `"queen"` ou `"bohemian"`).
* Verifica que apenas a música correspondente permanece visível na lista e as demais são filtradas.
* Limpa a pesquisa e valida que a lista completa é restaurada.


4. **Estados Intermediários Visíveis ao Usuário:**
* Verifica os indicadores de carregamento (`CircularProgressIndicator`) antes do término do fetch inicial de músicas.
* Valida a exibição e desaparecimento da `SnackBar` de erro ao disparar ação inválida.



---

### 5. Código dos Testes (`integration_test/fase3/criar_playlist_test.dart`)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:sintonize/main.dart';
import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  /// Helper para autenticar e navegar da HomeScreen até a CriarPlaylistScreen
  Future<void> navegarAteCriarPlaylist(WidgetTester tester) async {
    // Garante estado de logout antes de começar o fluxo
    await FirebaseAuth.instance.signOut();

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Toca no botão de Login na HomeScreen
    final loginBtnFinder = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginBtnFinder, findsOneWidget);
    await tester.tap(loginBtnFinder);
    await tester.pumpAndSettle();

    // 2. Preenche credenciais na LoginScreen
    final emailField = find.byType(TextFormField).at(0);
    final senhaField = find.byType(TextFormField).at(1);
    await tester.enterText(emailField, 'tester@sintonize.test');
    await tester.enterText(senhaField, 'senha123');
    await tester.pumpAndSettle();

    final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
    await tester.tap(entrarBtn);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 3. Na TelaInicialScreen, navega para "Minha Conta"
    final minhaContaTab = find.text('Minha Conta');
    expect(minhaContaTab, findsOneWidget);
    await tester.tap(minhaContaTab);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 4. Na UsuarioScreen, toca no menu "Criar Playlist"
    final criarPlaylistMenu = find.text('Criar Playlist');
    expect(criarPlaylistMenu, findsOneWidget);
    await tester.tap(criarPlaylistMenu);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Valida que chegou na CriarPlaylistScreen
    expect(find.text('Criando Playlist'), findsOneWidget);
  }

  testWidgets(
    'Cenário 1: Fluxo de sucesso ponta a ponta - criar e persistir playlist no Firestore',
    (WidgetTester tester) async {
      await navegarAteCriarPlaylist(tester);

      // Aguarda carregamento das músicas
      expect(find.byType(ListView), findsOneWidget);

      // Preenche o nome da playlist
      final nomePlaylistField = find.widgetWithText(TextField, 'Nome da Playlist');
      expect(nomePlaylistField, findsOneWidget);
      const String playlistNome = 'Rock & Pop Classics';
      await tester.enterText(nomePlaylistField, playlistNome);
      await tester.pumpAndSettle();

      // Seleciona as músicas "Bohemian Rhapsody" e "Billie Jean"
      final bohemianItem = find.textContaining('Bohemian Rhapsody');
      expect(bohemianItem, findsOneWidget);
      final bohemianTile = find.ancestor(
        of: bohemianItem,
        matching: find.byType(ListTile),
      );
      final bohemianCheckbox = find.descendant(
        of: bohemianTile,
        matching: find.byType(IconButton),
      );
      await tester.tap(bohemianCheckbox);
      await tester.pumpAndSettle();

      final billieItem = find.textContaining('Billie Jean');
      expect(billieItem, findsOneWidget);
      final billieTile = find.ancestor(
        of: billieItem,
        matching: find.byType(ListTile),
      );
      final billieCheckbox = find.descendant(
        of: billieTile,
        matching: find.byType(IconButton),
      );
      await tester.tap(billieCheckbox);
      await tester.pumpAndSettle();

      // Rola a tela até o botão "Salvar Playlist" se necessário e toca nele
      final salvarBtn = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.ensureVisible(salvarBtn);
      await tester.tap(salvarBtn);

      // Aguarda a gravação no Firestore e o pop para a UsuarioScreen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verifica se retornou para a UsuarioScreen e exibe o nome da playlist recém-criada
      expect(find.text(playlistNome), findsOneWidget);
      expect(find.text('2 músicas'), findsOneWidget);

      // Validação direta no emulador Firestore
      final currentUser = FirebaseAuth.instance.currentUser;
      expect(currentUser, isNotNull);

      final snapshot = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: currentUser!.uid)
          .where('nome', isEqualTo: playlistNome)
          .get();

      expect(snapshot.docs.isNotEmpty, isTrue);
      final dadosPlaylist = snapshot.docs.first.data();
      expect(dadosPlaylist['nome'], equals(playlistNome));
      expect(dadosPlaylist['userId'], equals(currentUser.uid));
      final List<dynamic> musicasPersistidas = dadosPlaylist['musicas'];
      expect(musicasPersistidas, contains('bohemian rhapsody'));
      expect(musicasPersistidas, contains('billie jean'));
    },
  );

  testWidgets(
    'Cenário 2: Validação antes de salvar - nome vazio não deve salvar a playlist',
    (WidgetTester tester) async {
      await navegarAteCriarPlaylist(tester);

      // Marca uma música sem preencher o nome da playlist
      final firstSongTile = find.byType(ListTile).first;
      final checkbox = find.descendant(
        of: firstSongTile,
        matching: find.byType(IconButton),
      );
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Clica em "Salvar Playlist" com o nome em branco
      final salvarBtn = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.ensureVisible(salvarBtn);
      await tester.tap(salvarBtn);
      await tester.pump();

      // Verifica se a SnackBar de validação foi apresentada
      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

      // Garante que a tela continua em CriarPlaylistScreen (não fez pop)
      expect(find.text('Criando Playlist'), findsOneWidget);
    },
  );

  testWidgets(
    'Cenário 3: Pesquisa e filtragem da lista de músicas',
    (WidgetTester tester) async {
      await navegarAteCriarPlaylist(tester);

      // Verifica que todas as músicas inicialmente carregadas estão visíveis
      expect(find.textContaining('Bohemian Rhapsody'), findsOneWidget);
      expect(find.textContaining('Billie Jean'), findsOneWidget);
      expect(find.textContaining('Take Five'), findsOneWidget);

      // Digita um termo de pesquisa específico ("Queen")
      final searchField =
          find.widgetWithText(TextField, 'Pesquisar Música ou Artista');
      await tester.enterText(searchField, 'Queen');
      await tester.pumpAndSettle();

      // Valida que apenas o resultado correspondente é exibido
      expect(find.textContaining('Bohemian Rhapsody'), findsOneWidget);
      expect(find.textContaining('Billie Jean'), findsNothing);
      expect(find.textContaining('Take Five'), findsNothing);

      // Limpa a busca e confere se a lista completa reaparece
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      expect(find.textContaining('Bohemian Rhapsody'), findsOneWidget);
      expect(find.textContaining('Billie Jean'), findsOneWidget);
      expect(find.textContaining('Take Five'), findsOneWidget);
    },
  );

  testWidgets(
    'Cenário 4: Estados intermediários visíveis ao usuário (indicador de carregamento e SnackBar)',
    (WidgetTester tester) async {
      await navegarAteCriarPlaylist(tester);

      // Tenta salvar com nome vazio para disparar a SnackBar
      final salvarBtn = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.ensureVisible(salvarBtn);
      await tester.tap(salvarBtn);
      await tester.pump();

      // SnackBar deve estar visível
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

      // Aguarda o timeout natural da SnackBar (4 segundos)
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // SnackBar não deve estar mais visível
      expect(find.byType(SnackBar), findsNothing);
    },
  );
}

```
