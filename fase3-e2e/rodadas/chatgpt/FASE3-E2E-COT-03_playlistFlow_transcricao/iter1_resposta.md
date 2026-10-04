## Classificação: **(A)**

 A causa é **(A) — o teste presume algo incorretamente apenas no nível de compilação/importação**, e não há evidência, nesse log, de um comportamento incorreto da aplicação.

 Os erros são todos símbolos Flutter ou telas do próprio projeto que o arquivo de teste utiliza, mas não importou:

 - `TextFormField`, `TextField`, `ListTile`, `IconButton` e `CircularProgressIndicator` pertencem a `package:flutter/material.dart`.
- `TelaInicialScreen` pertence a `package:sintonize/tela-inicial.dart`.
- `UsuarioScreen` pertence a `package:sintonize/usuario.dart`.

 Portanto, **não devemos alterar nenhuma asserção nem reduzir o escopo dos testes**. Basta corrigir os imports do teste.

 Abaixo está o arquivo completo corrigido. Mantive os quatro cenários e a validação diretamente no Firestore Emulator.

 integration\_test/fase3/playlist\_cot\_test.dart

```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';
import 'package:sintonize/tela-inicial.dart';
import 'package:sintonize/usuario.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  tearDown(() async {
    await FirebaseAuth.instance.signOut();
  });

  Future<void> iniciarAplicativo(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
  }

  Future<void> fazerLogin(WidgetTester tester) async {
    await iniciarAplicativo(tester);

    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);

    final emailField = find.byType(TextFormField).first;
    final senhaField = find.byType(TextFormField).last;

    await tester.enterText(emailField, 'tester@sintonize.test');
    await tester.enterText(senhaField, 'senha123');

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.byType(TelaInicialScreen), findsOneWidget);
  }

  Future<void> navegarParaCriarPlaylist(WidgetTester tester) async {
    await fazerLogin(tester);

    expect(find.text('Minha Conta'), findsOneWidget);

    await tester.tap(find.text('Minha Conta'));
    await tester.pumpAndSettle();

    expect(find.byType(UsuarioScreen), findsOneWidget);
    expect(find.text('Criar Playlist'), findsOneWidget);

    await tester.tap(find.text('Criar Playlist'));
    await tester.pump();

    expect(find.text('Criando Playlist'), findsOneWidget);
  }

  Future<void> aguardarMusicasCarregarem(WidgetTester tester) async {
    const timeout = Duration(seconds: 15);
    final inicio = DateTime.now();

    while (find.text('Bohemian Rhapsody - Queen').evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 100));

      if (DateTime.now().difference(inicio) > timeout) {
        fail(
          'Timeout aguardando as músicas do Firestore. '
          'A música "Bohemian Rhapsody - Queen" não apareceu.',
        );
      }
    }

    expect(
      find.text('Bohemian Rhapsody - Queen'),
      findsOneWidget,
    );
  }

  Future<void> selecionarMusica(
    WidgetTester tester,
    String tituloCompleto,
  ) async {
    final textoMusica = find.text(tituloCompleto);

    expect(textoMusica, findsOneWidget);

    final listTile = find.ancestor(
      of: textoMusica,
      matching: find.byType(ListTile),
    );

    expect(listTile, findsOneWidget);

    final botaoCheckbox = find.descendant(
      of: listTile,
      matching: find.byType(IconButton),
    );

    expect(botaoCheckbox, findsOneWidget);

    await tester.tap(botaoCheckbox);
    await tester.pump();
  }

  testWidgets(
    'fluxo E2E: cria playlist, seleciona músicas e persiste no Firestore',
    (tester) async {
      await navegarParaCriarPlaylist(tester);

      await aguardarMusicasCarregarem(tester);

      final firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);

      final userId = user!.uid;
      const nomePlaylist = 'Playlist E2E Sintonize';

      final playlistsAntes = await firestore
          .collection('playlists')
          .where('userId', isEqualTo: userId)
          .get();

      final quantidadeAntes = playlistsAntes.docs.length;

      final nomeField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration.labelText == 'Nome da Playlist',
      );

      expect(nomeField, findsOneWidget);

      await tester.enterText(nomeField, nomePlaylist);

      await selecionarMusica(
        tester,
        'Bohemian Rhapsody - Queen',
      );

      await selecionarMusica(
        tester,
        'Billie Jean - Michael Jackson',
      );

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      expect(find.byType(UsuarioScreen), findsOneWidget);

      final query = await firestore
          .collection('playlists')
          .where('userId', isEqualTo: userId)
          .get();

      expect(query.docs.length, quantidadeAntes + 1);

      final documentos = query.docs
          .where((doc) => doc.data()['nome'] == nomePlaylist)
          .toList();

      expect(documentos, hasLength(1));

      final playlist = documentos.single.data();

      expect(playlist['userId'], userId);
      expect(playlist['nome'], nomePlaylist);
      expect(
        playlist['musicas'],
        contains('bohemian rhapsody'),
      );
      expect(
        playlist['musicas'],
        contains('billie jean'),
      );
      expect(
        (playlist['musicas'] as List).length,
        2,
      );
      expect(
        playlist['dataCriacao'],
        isA<Timestamp>(),
      );
    },
  );

  testWidgets(
    'validação: nome vazio exibe SnackBar e não salva playlist',
    (tester) async {
      await navegarParaCriarPlaylist(tester);

      await aguardarMusicasCarregarem(tester);

      final firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);

      final userId = user!.uid;

      final playlistsAntes = await firestore
          .collection('playlists')
          .where('userId', isEqualTo: userId)
          .get();

      final quantidadeAntes = playlistsAntes.docs.length;

      await selecionarMusica(
        tester,
        'Bohemian Rhapsody - Queen',
      );

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pump();

      expect(
        find.text('Nome da playlist é obrigatório'),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 1));

      expect(
        find.text('Criando Playlist'),
        findsOneWidget,
      );

      final playlistsDepois = await firestore
          .collection('playlists')
          .where('userId', isEqualTo: userId)
          .get();

      expect(
        playlistsDepois.docs.length,
        quantidadeAntes,
        reason:
            'Uma playlist não pode ser criada quando o nome está vazio.',
      );
    },
  );

  testWidgets(
    'pesquisa e filtragem: filtra músicas por nome ou artista',
    (tester) async {
      await navegarParaCriarPlaylist(tester);

      await aguardarMusicasCarregarem(tester);

      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsOneWidget,
      );
      expect(
        find.text('Billie Jean - Michael Jackson'),
        findsOneWidget,
      );
      expect(
        find.text('Take Five - Dave Brubeck'),
        findsOneWidget,
      );
      expect(
        find.text('The Thrill Is Gone - B.b. King'),
        findsOneWidget,
      );
      expect(
        find.text('One Love - Bob Marley'),
        findsOneWidget,
      );

      final searchField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration.labelText ==
                'Pesquisar Música ou Artista',
      );

      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'queen');
      await tester.pump();

      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsOneWidget,
      );

      expect(
        find.text('Billie Jean - Michael Jackson'),
        findsNothing,
      );
      expect(
        find.text('Take Five - Dave Brubeck'),
        findsNothing,
      );
      expect(
        find.text('The Thrill Is Gone - B.b. King'),
        findsNothing,
      );
      expect(
        find.text('One Love - Bob Marley'),
        findsNothing,
      );

      await tester.enterText(searchField, 'billie');
      await tester.pump();

      expect(
        find.text('Billie Jean - Michael Jackson'),
        findsOneWidget,
      );

      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsNothing,
      );

      await tester.enterText(searchField, '');
      await tester.pump();

      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsOneWidget,
      );
      expect(
        find.text('Billie Jean - Michael Jackson'),
        findsOneWidget,
      );
      expect(
        find.text('Take Five - Dave Brubeck'),
        findsOneWidget,
      );
      expect(
        find.text('The Thrill Is Gone - B.b. King'),
        findsOneWidget,
      );
      expect(
        find.text('One Love - Bob Marley'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'estado intermediário: exibe carregamento e depois as músicas do Firestore',
    (tester) async {
      await fazerLogin(tester);

      await tester.tap(find.text('Minha Conta'));
      await tester.pumpAndSettle();

      expect(
        find.byType(UsuarioScreen),
        findsOneWidget,
      );

      await tester.tap(find.text('Criar Playlist'));
      await tester.pump();

      expect(
        find.text('Criando Playlist'),
        findsOneWidget,
      );

      final loadingIndicator = find.byType(
        CircularProgressIndicator,
      );

      // O Firestore Emulator pode responder antes que o primeiro
      // frame seja observado pelo teste. Por isso, caso o indicador
      // ainda esteja presente, validamos explicitamente esse estado.
      if (loadingIndicator.evaluate().isNotEmpty) {
        expect(
          loadingIndicator,
          findsOneWidget,
        );
      }

      await aguardarMusicasCarregarem(tester);

      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsOneWidget,
      );

      expect(
        find.text('Billie Jean - Michael Jackson'),
        findsOneWidget,
      );

      expect(
        find.byType(CircularProgressIndicator),
        findsNothing,
      );

      expect(
        find.text('Salvar Playlist'),
        findsOneWidget,
      );

      expect(
        find.text('Nome da Playlist'),
        findsOneWidget,
      );

      expect(
        find.text('Pesquisar Música ou Artista'),
        findsOneWidget,
      );
    },
  );
}
```

 ### O que foi corrigido

 Os imports que faltavam são estes:

```
import 'package:flutter/material.dart';
import 'package:sintonize/tela-inicial.dart';
import 'package:sintonize/usuario.dart';
```

 Isso resolve especificamente todos os símbolos reportados pelo compilador.

 Não alterei as asserções de negócio. Em particular, o teste continua verificando que:

 - uma playlist válida realmente aparece no Firestore;
- `userId` corresponde ao usuário autenticado;
- `nome` é persistido;
- as duas músicas selecionadas são persistidas;
- `dataCriacao` é um `Timestamp`;
- nome vazio **não cria documento**;
- a pesquisa funciona tanto por música quanto por artista;
- a lista inicialmente carregada contém os cinco documentos esperados;
- o estado de carregamento não é simplesmente ignorado quando estiver observável.

 O comando de execução continua sendo:

```
flutter test integration_test/fase3/playlist_cot_test.dart -d emulator-5554
```

 Se o próximo erro ocorrer **depois da compilação**, aí vale analisar o novo log separando problemas do teste de possíveis comportamentos incorretos da aplicação, sem enfraquecer as asserções.