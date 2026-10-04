Abaixo está a análise e, em seguida, o arquivo completo `integration_test/fase3/criar_playlist_test.dart`. O desenho usa `integration_test` \+ `testWidgets`, sem mocks, e monta o `MyApp` real diretamente; isso evita inicializar o Firebase duas vezes, já que o `setupFirebaseEmulators()` fornecido pelo projeto já inicializa o app Firebase. Esse padrão é compatível com a forma oficial de carregar o widget principal em testes de integração.  Documentação Flutter+1

 ## 1\. Análise do fluxo

 O fluxo começa na tela de boas-vindas, passa pelo login com o usuário pré-populado e chega à `TelaInicialScreen`; dali o usuário entra em **Minha Conta** e toca em **Criar Playlist**, abrindo a `CriarPlaylistScreen`. Ao ser montada, essa tela consulta `musica` no Firestore, exibe as músicas, permite pesquisar/filtrar e marcar uma ou mais músicas. Ao tocar em **Salvar Playlist**, o app verifica se o nome não está vazio; com nome válido, grava um documento em `playlists` contendo `userId`, `nome`, `musicas` e `dataCriacao`, e retorna para `UsuarioScreen`. Se o nome estiver vazio, nenhum documento é gravado e um `SnackBar` informa que o nome é obrigatório.

 ## 2\. Dependências e estado dos emuladores

 | Tela | Serviço | Leitura/gravação | Dados necessários antes do teste |
| --- | --- | --- | --- |
| `HomeScreen` | Nenhum | Nenhuma | Nenhum |
| `LoginScreen` | Firebase Auth | `signInWithEmailAndPassword` | Usuário `tester@sintonize.test` / `senha123` |
| `TelaInicialScreen` | Auth + Firestore | Lê `usuarios/{uid}`; pode consultar/atualizar histórico de músicas | `usuarios/{uid}` com `nome` e `generos_favoritos` |
| `UsuarioScreen` | Auth + Firestore | Lê `usuarios/{uid}` e `playlists` filtrando por `userId`; também lê `musica` | Usuário autenticado e coleção `musica` |
| `CriarPlaylistScreen` | Auth + Firestore | Lê toda a coleção `musica`; grava em `playlists` | Cinco músicas na coleção `musica` |
| Pós-salvamento | Firestore | O documento recém-criado deve existir em `playlists` | Nenhum documento da playlist é necessário previamente |

Os cinco documentos `musica` fornecidos permitem testar tanto resultados encontrados quanto filtragem. Para o teste de persistência, o documento criado deve ter o UID do usuário autenticado, o nome escolhido e as músicas selecionadas.

 ## 3\. Caminho de navegação e sincronização

 O caminho usado pelos testes é:

 `HomeScreen` → **Login** → `LoginScreen` → preencher e-mail/senha → **Entrar** → `TelaInicialScreen` → **Minha Conta** → `UsuarioScreen` → **Criar Playlist** → `CriarPlaylistScreen`.

 Depois de cada ação de navegação, os testes usam `pumpAndSettle()` para aguardar as animações e reconstruções da UI. Na `CriarPlaylistScreen`, o teste primeiro aguarda até que uma música conhecida apareça; isso é importante porque a tela começa com `_musicasFiltradas` vazia e somente depois da resposta do Firestore ela é preenchida. A documentação do Flutter recomenda `pumpAndSettle()` após ações que provocam mudanças/animções na interface.  Documentação Flutter+1

 Para a persistência, o teste não considera o desaparecimento da tela como evidência suficiente: ele consulta diretamente o Firestore emulator depois do salvamento e valida o documento criado. Isso confirma o comportamento ponta a ponta entre UI e backend.

 ## 4\. Cenários cobertos

 - **Sucesso ponta a ponta:** login → Minha Conta → Criar Playlist → músicas carregadas → selecionar músicas → informar nome → salvar → validar documento no Firestore.
- **Validação antes de salvar:** deixar o nome vazio → tocar em Salvar Playlist → verificar `SnackBar` → verificar que nenhum documento correspondente foi criado.
- **Pesquisa e filtragem:** carregar a lista → pesquisar `queen` → verificar somente `Bohemian Rhapsody - Queen` → limpar → pesquisar `jackson` → verificar `Billie Jean - Michael Jackson`.
- **Estados intermediários:** verificar que a lista inicialmente está em estado de carregamento e que, após a resposta do Firestore, as músicas aparecem; também verificar o `SnackBar` da validação.

 A implementação abaixo não altera nenhuma tela do aplicativo.

 integration\_test/fase3/criar\_playlist\_test.dart

```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart' as app;

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> iniciarAplicativo(WidgetTester tester) async {
    // O helper já inicializa o Firebase. Por isso carregamos o MyApp
    // diretamente em vez de chamar app.main(), que tentaria inicializar
    // o Firebase novamente.
    await tester.pumpWidget(const app.MyApp());
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> garantirLogout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> fazerLogin(WidgetTester tester) async {
    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget);

    final camposTexto = find.byType(TextFormField);
    expect(camposTexto, findsNWidgets(2));

    await tester.enterText(
      camposTexto.at(0),
      'tester@sintonize.test',
    );
    await tester.enterText(
      camposTexto.at(1),
      'senha123',
    );

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.byType(app.TelaInicialScreen), findsOneWidget);
  }

  Future<void> navegarAteCriarPlaylist(WidgetTester tester) async {
    await fazerLogin(tester);

    // TelaInicialScreen -> UsuarioScreen.
    final minhaConta = find.text('Minha Conta');
    expect(minhaConta, findsOneWidget);

    await tester.tap(minhaConta);
    await tester.pumpAndSettle();

    expect(find.textContaining('Bem-vindo(a),'), findsOneWidget);
    expect(find.text('Criar Playlist'), findsOneWidget);

    // UsuarioScreen -> CriarPlaylistScreen.
    await tester.tap(find.text('Criar Playlist'));
    await tester.pump();

    // A tela começa com _musicasFiltradas vazia e mostra
    // CircularProgressIndicator enquanto a consulta ao Firestore
    // ainda não terminou.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Criando Playlist'), findsOneWidget);
  }

  Future<void> esperarMusicasCarregadas(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      if (find.text('Bohemian Rhapsody - Queen').evaluate().isNotEmpty ||
          find.text('Billie Jean - Michael Jackson').evaluate().isNotEmpty ||
          find.text('Take Five - Dave Brubeck').evaluate().isNotEmpty) {
        return;
      }

      await tester.pump(const Duration(milliseconds: 100));
    }

    fail('As músicas não foram carregadas dentro do tempo esperado.');
  }

  Future<QuerySnapshot<Map<String, dynamic>>> buscarPlaylistsDoUsuario(
    String uid,
  ) {
    return FirebaseFirestore.instance
        .collection('playlists')
        .where('userId', isEqualTo: uid)
        .get();
  }

  testWidgets(
    'Fluxo E2E: criar playlist, selecionar músicas e persistir no Firestore',
    (tester) async {
      await garantirLogout();
      await iniciarAplicativo(tester);

      await navegarAteCriarPlaylist(tester);
      await esperarMusicasCarregadas(tester);

      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
      expect(find.text('Billie Jean - Michael Jackson'), findsOneWidget);
      expect(find.text('Take Five - Dave Brubeck'), findsOneWidget);
      expect(find.text('The Thrill Is Gone - B.B. King'), findsOneWidget);
      expect(find.text('One Love - Bob Marley'), findsOneWidget);

      final nomePlaylist = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Nome da Playlist',
      );

      final pesquisa = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Pesquisar Música ou Artista',
      );

      expect(nomePlaylist, findsOneWidget);
      expect(pesquisa, findsOneWidget);

      await tester.enterText(nomePlaylist, 'Playlist E2E Sintonize');
      await tester.pump();

      // Seleciona duas músicas pelos checkboxes da própria ListTile.
      final bohemian = find.ancestor(
        of: find.text('Bohemian Rhapsody - Queen'),
        matching: find.byType(ListTile),
      );
      expect(bohemian, findsOneWidget);

      final billieJean = find.ancestor(
        of: find.text('Billie Jean - Michael Jackson'),
        matching: find.byType(ListTile),
      );
      expect(billieJean, findsOneWidget);

      await tester.tap(
        find.descendant(
          of: bohemian,
          matching: find.byIcon(Icons.check_box_outline_blank),
        ),
      );
      await tester.pump();

      await tester.tap(
        find.descendant(
          of: billieJean,
          matching: find.byIcon(Icons.check_box_outline_blank),
        ),
      );
      await tester.pump();

      // Confirma que ambas ficaram selecionadas.
      expect(
        find.descendant(
          of: bohemian,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: billieJean,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      final uid = FirebaseAuth.instance.currentUser!.uid;

      final antes = await buscarPlaylistsDoUsuario(uid);
      final quantidadeAntes = antes.docs.length;

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      // O sucesso do salvamento provoca Navigator.pop().
      expect(find.text('Criando Playlist'), findsNothing);
      expect(find.text('Criar Playlist'), findsOneWidget);

      // Verifica a persistência real no Firestore Emulator.
      final depois = await buscarPlaylistsDoUsuario(uid);

      expect(depois.docs.length, quantidadeAntes + 1);

      final novasPlaylists = depois.docs.where((doc) {
        final data = doc.data();
        return data['nome'] == 'Playlist E2E Sintonize';
      }).toList();

      expect(novasPlaylists, hasLength(1));

      final playlist = novasPlaylists.single.data();

      expect(playlist['userId'], uid);
      expect(playlist['nome'], 'Playlist E2E Sintonize');
      expect(
        List<String>.from(playlist['musicas'] as List),
        containsAll(<String>[
          'bohemian rhapsody',
          'billie jean',
        ]),
      );
      expect(playlist['dataCriacao'], isA<Timestamp>());
    },
  );

  testWidgets(
    'Validação: nome vazio exibe SnackBar e não salva playlist',
    (tester) async {
      await garantirLogout();
      await iniciarAplicativo(tester);

      await navegarAteCriarPlaylist(tester);
      await esperarMusicasCarregadas(tester);

      final uid = FirebaseAuth.instance.currentUser!.uid;

      final antes = await buscarPlaylistsDoUsuario(uid);
      final quantidadeAntes = antes.docs.length;

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pump();

      expect(
        find.text('Nome da playlist é obrigatório'),
        findsOneWidget,
      );

      // Dá tempo para o SnackBar permanecer visível e para qualquer
      // frame assíncrono decorrente do tap ser processado.
      await tester.pump(const Duration(milliseconds: 300));

      final depois = await buscarPlaylistsDoUsuario(uid);

      expect(depois.docs.length, quantidadeAntes);

      // A tela continua aberta porque a validação impede _salvarPlaylist().
      expect(find.text('Criando Playlist'), findsOneWidget);
    },
  );

  testWidgets(
    'Pesquisa: filtra músicas pelo nome e pelo artista',
    (tester) async {
      await garantirLogout();
      await iniciarAplicativo(tester);

      await navegarAteCriarPlaylist(tester);
      await esperarMusicasCarregadas(tester);

      final pesquisa = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Pesquisar Música ou Artista',
      );

      expect(pesquisa, findsOneWidget);

      // Filtragem pelo nome do artista.
      await tester.enterText(pesquisa, 'queen');
      await tester.pump();

      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
      expect(find.text('Billie Jean - Michael Jackson'), findsNothing);
      expect(find.text('Take Five - Dave Brubeck'), findsNothing);
      expect(find.text('The Thrill Is Gone - B.B. King'), findsNothing);
      expect(find.text('One Love - Bob Marley'), findsNothing);

      // Limpa a pesquisa.
      await tester.enterText(pesquisa, '');
      await tester.pump();

      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
      expect(find.text('Billie Jean - Michael Jackson'), findsOneWidget);

      // Filtragem pelo nome da música.
      await tester.enterText(pesquisa, 'billie');
      await tester.pump();

      expect(find.text('Billie Jean - Michael Jackson'), findsOneWidget);
      expect(find.text('Bohemian Rhapsody - Queen'), findsNothing);
      expect(find.text('Take Five - Dave Brubeck'), findsNothing);
    },
  );

  testWidgets(
    'Estado intermediário: carregamento das músicas e SnackBar de validação',
    (tester) async {
      await garantirLogout();
      await iniciarAplicativo(tester);

      await fazerLogin(tester);

      await tester.tap(find.text('Minha Conta'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Criar Playlist'));
      await tester.pump();

      // A consulta ao Firestore começa no initState.
      // O estado inicial da tela deve mostrar o indicador.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Espera a resposta real do Firestore Emulator.
      await esperarMusicasCarregadas(tester);

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);

      // Agora exercita outro estado visível da tela: erro de validação.
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pump();

      expect(
        find.text('Nome da playlist é obrigatório'),
        findsOneWidget,
      );

      // O formulário continua na tela.
      expect(find.text('Criando Playlist'), findsOneWidget);
    },
  );
}
```

 ### Observações importantes

 - O teste usa `package:sintonize/main.dart` e instancia `const app.MyApp()`, em vez de chamar `app.main()`. Isso é intencional: o helper fornecido já executa `Firebase.initializeApp()`. Chamar `main()` depois tentaria inicializar o Firebase novamente.
- Nenhum mock é usado. As consultas a Auth e Firestore são feitas pelas próprias telas e a validação final consulta o Firestore Emulator diretamente.
- O teste de pesquisa valida tanto **artista** (`queen`) quanto **música** (`billie`).
- O teste de carregamento observa o `CircularProgressIndicator` antes da resposta do Firestore e depois confirma que ele desapareceu.
- O teste de sucesso verifica a persistência real, inclusive `userId`, `nome`, `musicas` e `dataCriacao`.
- Como os emuladores são reinicializados/populados antes da execução do arquivo, os testes não dependem de playlists previamente existentes. Dentro da mesma execução, o código compara a quantidade de documentos antes e depois para evitar assumir que a coleção esteja vazia.

 Para executar exatamente no ambiente informado:

```
flutter test integration_test/fase3/criar_playlist_test.dart -d emulator-5554
```

 Esse uso de `flutter test` para `integration_test` em Android e a interação via `WidgetTester` seguem o fluxo documentado pelo Flutter.  Documentação Flutter+1