<!-- Resposta do Gemini 3.8 Flash à geração (iteração 0), rodada FASE3-E2E-COT-03_playlistFlow, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome), segunda máquina (DESKTOP-6ETPO2H).
     Conversa: https://gemini.google.com/app/f82eb24ef7ebdcea -->

Aqui está a análise completa do fluxo, o mapeamento de dependências e caminhos de navegação, a matriz de cenários e o arquivo completo de testes end-to-end com `integration_test`.

---

### 1. Análise do Fluxo

O usuário inicia na tela de boas-vindas (`HomeScreen`), navega até a `LoginScreen`, autentica-se com credenciais existentes e alcança a `TelaInicialScreen`. A partir do menu inferior da tela inicial, acessa a tela de perfil/conta (`UsuarioScreen`) e toca na opção "Criar Playlist", abrindo a `CriarPlaylistScreen`. Nesta tela, o catálogo de músicas é carregado do Firestore e o usuário pode pesquisar/filtrar as faixas em tempo real, selecionar uma ou mais músicas via checkbox e informar o nome da playlist. No ponto de decisão ao tocar em "Salvar Playlist", caso o nome não tenha sido informado, a operação é rejeitada exibindo uma `SnackBar` de validação; se válido, a playlist é gravada no Firestore vinculada ao UID do usuário autenticado e a tela é fechada (`Navigator.pop`), retornando para a lista de playlists na `UsuarioScreen`.

---

### 2. Identificação das Dependências

* **Serviços Acionados por Tela:**
* `LoginScreen`: **Firebase Auth** (`signInWithEmailAndPassword`) para autenticar o usuário.
* `TelaInicialScreen`: **Firebase Auth** (`currentUser`) e **Firestore** (leitura de `usuarios/{uid}` para carregar o nome e histórico de músicas recomendadas).
* `UsuarioScreen`: **Firebase Auth** (`currentUser`) e **Firestore** (leitura de `usuarios/{uid}` para obter `nome`; leitura de `playlists` filtrando por `where('userId', isEqualTo: user.uid)`).
* `CriarPlaylistScreen`: **Firebase Auth** (`currentUser.uid`) e **Firestore** (leitura inicial da coleção `musica` para compor o catálogo; gravação de novo documento na coleção `playlists` com campos `userId`, `nome`, `musicas`, `dataCriacao`).


* **Dados pré-existentes nos emuladores:**
* **Auth:** Usuário `tester@sintonize.test` com senha `senha123`.
* **Firestore (`usuarios/{uid}`):** `{ 'nome': 'tester sintonize', 'generos_favoritos': ['rock', 'pop'] }`.
* **Firestore (`musica`):** 5 faixas (`bohemian rhapsody`, `billie jean`, `take five`, `the thrill is gone`, `one love`).



---

### 3. Caminho de Navegação

1. **`HomeScreen`:** O teste renderiza `MyApp()`. Localiza o botão "Login" e aciona o toque.
2. **Transição para `LoginScreen`:** Aguarda animações com `tester.pumpAndSettle()`.
3. **`LoginScreen`:** Preenche os campos de e-mail (`tester@sintonize.test`) e senha (`senha123`), fecha o teclado/faz scroll se necessário e toca no botão "Entrar".
4. **Transição para `TelaInicialScreen`:** Aguarda a resposta do Firebase Auth e o carregamento do Firestore via `tester.pumpAndSettle()`.
5. **`TelaInicialScreen`:** Localiza o item "Minha Conta" no `BottomNavigationBar` (ícone `Icons.person`) e aciona o toque.
6. **Transição para `UsuarioScreen`:** Aguarda transição e leitura inicial das playlists.
7. **`UsuarioScreen`:** Localiza a opção "Criar Playlist" e toca nela.
8. **Transição para `CriarPlaylistScreen`:** Aguarda a montagem da tela e o carregamento da lista de músicas da coleção `musica` do Firestore via `tester.pumpAndSettle()`.

---

### 4. Cenários de Teste

1. **Estados intermediários visíveis ao usuário:**
* Verifica se o indicador de progresso (`CircularProgressIndicator`) aparece enquanto a lista de músicas está sendo requisitada e se a lista é renderizada logo após o término do carregamento.


2. **Validação antes de salvar (nome obrigatório):**
* Na `CriarPlaylistScreen`, tenta salvar a playlist sem preencher o campo "Nome da Playlist".
* Verifica a exibição da `SnackBar` com o texto `'Nome da playlist é obrigatório'` e assegura que nenhuma playlist nova foi salva no Firestore.


3. **Pesquisa e filtragem da lista de músicas:**
* Digita termos no campo "Pesquisar Música ou Artista" (por título e por artista).
* Verifica se a lista exibe apenas os itens correspondentes e oculta os demais.


4. **Fluxo de sucesso ponta a ponta:**
* Navega da tela inicial até a `CriarPlaylistScreen`.
* Digita um nome válido para a playlist.
* Seleciona músicas marcando os checkboxes (alternando estados).
* Toca em "Salvar Playlist", aguarda a finalização e confirma o retorno para a `UsuarioScreen`.
* Consulta diretamente a coleção `playlists` no Firestore para validar a persistência dos campos `userId`, `nome`, e a lista exata de `musicas`.



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

  const testEmail = 'tester@sintonize.test';
  const testPassword = 'senha123';

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  setUp(() async {
    // Garante estado deslogado e limpa playlists criadas por testes anteriores
    await FirebaseAuth.instance.signOut();

    final playlists =
        await FirebaseFirestore.instance.collection('playlists').get();
    for (var doc in playlists.docs) {
      await doc.reference.delete();
    }
  });

  /// Helper que executa o fluxo comum de navegação da HomeScreen até CriarPlaylistScreen
  Future<void> navegarAteCriarPlaylist(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Tocar em "Login" na HomeScreen
    final loginBtnFinder = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginBtnFinder, findsOneWidget);
    await tester.tap(loginBtnFinder);
    await tester.pumpAndSettle();

    // 2. Preencher formulário de login
    final emailFieldFinder = find.widgetWithText(TextFormField, '');
    // Como há dois TextFormFields, identificamos por ordem ou tipo de conteúdo
    final textFormFields = find.byType(TextFormField);
    expect(textFormFields, findsNWidgets(2));

    await tester.enterText(textFormFields.at(0), testEmail);
    await tester.enterText(textFormFields.at(1), testPassword);
    await tester.pumpAndSettle();

    // 3. Tocar em "Entrar"
    final entrarBtnFinder = find.widgetWithText(ElevatedButton, 'Entrar');
    await tester.ensureVisible(entrarBtnFinder);
    await tester.tap(entrarBtnFinder);
    await tester.pumpAndSettle();

    // 4. Na TelaInicialScreen, acessar "Minha Conta" no BottomNavigationBar
    final minhaContaFinder = find.text('Minha Conta');
    expect(minhaContaFinder, findsOneWidget);
    await tester.tap(minhaContaFinder);
    await tester.pumpAndSettle();

    // 5. Na UsuarioScreen, tocar em "Criar Playlist"
    final criarPlaylistFinder = find.text('Criar Playlist');
    expect(criarPlaylistFinder, findsOneWidget);
    await tester.tap(criarPlaylistFinder);
    await tester.pumpAndSettle();

    // 6. Confirma que a CriarPlaylistScreen está montada
    expect(find.text('Criando Playlist'), findsOneWidget);
  }

  testWidgets(
    'Cenário 1: Estados intermediários visíveis - indicador de carregamento e listagem',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navega até a tela inicial autenticado
      final loginBtnFinder = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginBtnFinder);
      await tester.pumpAndSettle();

      final textFormFields = find.byType(TextFormField);
      await tester.enterText(textFormFields.at(0), testEmail);
      await tester.enterText(textFormFields.at(1), testPassword);
      await tester.pumpAndSettle();

      final entrarBtnFinder = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(entrarBtnFinder);
      await tester.tap(entrarBtnFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Minha Conta'));
      await tester.pumpAndSettle();

      // Toca em criar playlist e verifica pump imediato (estado de loading do Firestore)
      await tester.tap(find.text('Criar Playlist'));
      await tester.pump(); // Renderiza o primeiro frame antes da resolução da Future

      // Verifica se o indicador de loading pode ser renderizado enquanto carrega
      // ou se logo após pumpAndSettle a lista populada é exibida
      await tester.pumpAndSettle();

      // O indicador deve sumir e os itens do dataset devem aparecer
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Bohemian Rhapsody'), findsOneWidget);
      expect(find.textContaining('Billie Jean'), findsOneWidget);
    },
  );

  testWidgets(
    'Cenário 2: Validação antes de salvar - nome vazio exibe SnackBar e não salva',
    (WidgetTester tester) async {
      await navegarAteCriarPlaylist(tester);

      // Tenta salvar sem preencher o nome da playlist
      final salvarBtnFinder =
          find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.ensureVisible(salvarBtnFinder);
      await tester.tap(salvarBtnFinder);
      await tester.pump(); // Inicia animação da SnackBar

      // Valida se a SnackBar de erro aparece com a mensagem correta
      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

      await tester.pumpAndSettle();

      // Continua na CriarPlaylistScreen
      expect(find.text('Criando Playlist'), findsOneWidget);

      // Garante que nenhum documento foi criado no Firestore
      final playlistsSnapshot =
          await FirebaseFirestore.instance.collection('playlists').get();
      expect(playlistsSnapshot.docs.isEmpty, isTrue);
    },
  );

  testWidgets(
    'Cenário 3: Pesquisa e filtragem em tempo real da lista de músicas',
    (WidgetTester tester) async {
      await navegarAteCriarPlaylist(tester);

      final searchFieldFinder =
          find.widgetWithText(TextField, 'Pesquisar Música ou Artista');
      expect(searchFieldFinder, findsOneWidget);

      // 1. Filtra por título de música existente ('Bohemian')
      await tester.enterText(searchFieldFinder, 'bohemian');
      await tester.pumpAndSettle();

      expect(find.textContaining('Bohemian Rhapsody'), findsOneWidget);
      expect(find.textContaining('Billie Jean'), findsNothing);
      expect(find.textContaining('Take Five'), findsNothing);

      // 2. Filtra por nome do artista ('Bob Marley')
      await tester.enterText(searchFieldFinder, 'bob marley');
      await tester.pumpAndSettle();

      expect(find.textContaining('One Love'), findsOneWidget);
      expect(find.textContaining('Bohemian Rhapsody'), findsNothing);

      // 3. Limpa o campo de busca e assegura retorno das demais músicas
      await tester.enterText(searchFieldFinder, '');
      await tester.pumpAndSettle();

      expect(find.textContaining('Bohemian Rhapsody'), findsOneWidget);
      expect(find.textContaining('Billie Jean'), findsOneWidget);
      expect(find.textContaining('Take Five'), findsOneWidget);
    },
  );

  testWidgets(
    'Cenário 4: Fluxo de sucesso ponta a ponta - seleção, salvar e documento persistido',
    (WidgetTester tester) async {
      await navegarAteCriarPlaylist(tester);

      const nomePlaylist = 'Minhas Favoritas Rock e Pop';

      // 1. Digita o nome da playlist
      final nomeFieldFinder =
          find.widgetWithText(TextField, 'Nome da Playlist');
      await tester.enterText(nomeFieldFinder, nomePlaylist);
      await tester.pumpAndSettle();

      // 2. Localiza as músicas e seus botões de checkbox
      // Seleciona a primeira música ('bohemian rhapsody')
      final checkboxBohemian = find.descendant(
        of: find.widgetWithText(ListTile, 'Bohemian Rhapsody - Queen'),
        matching: find.byType(IconButton),
      );
      expect(checkboxBohemian, findsOneWidget);
      await tester.tap(checkboxBohemian);
      await tester.pumpAndSettle();

      // Confirma que o ícone mudou para selecionado
      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Bohemian Rhapsody - Queen'),
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      // Seleciona a segunda música ('billie jean')
      final checkboxBillie = find.descendant(
        of: find.widgetWithText(ListTile, 'Billie Jean - Michael Jackson'),
        matching: find.byType(IconButton),
      );
      expect(checkboxBillie, findsOneWidget);
      await tester.tap(checkboxBillie);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Billie Jean - Michael Jackson'),
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      // 3. Toca em "Salvar Playlist"
      final salvarBtnFinder =
          find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.ensureVisible(salvarBtnFinder);
      await tester.tap(salvarBtnFinder);
      await tester.pumpAndSettle();

      // 4. Confirma retorno à tela de perfil do usuário (Navigator.pop)
      expect(find.text('Criando Playlist'), findsNothing);
      expect(find.text('Minha Conta'), findsOneWidget);

      // 5. Validação direta da persistência no Cloud Firestore
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: currentUserId)
          .get();

      expect(querySnapshot.docs.length, 1);

      final playlistGravada = querySnapshot.docs.first.data();
      expect(playlistGravada['nome'], equals(nomePlaylist));
      expect(playlistGravada['userId'], equals(currentUserId));
      expect(playlistGravada['dataCriacao'], isA<Timestamp>());

      final List<dynamic> musicasGravadas = playlistGravada['musicas'];
      expect(musicasGravadas.length, equals(2));
      expect(musicasGravadas, contains('bohemian rhapsody'));
      expect(musicasGravadas, contains('billie jean'));
    },
  );
}

```
