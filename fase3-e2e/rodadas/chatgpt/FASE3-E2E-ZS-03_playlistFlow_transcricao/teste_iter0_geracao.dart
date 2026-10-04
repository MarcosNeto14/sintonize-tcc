import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> login(
    WidgetTester tester, {
    String email = 'tester@sintonize.test',
    String senha = 'senha123',
  }) async {
    // Tela inicial
    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget);

    final campos = find.byType(TextFormField);
    expect(campos, findsNWidgets(2));

    await tester.enterText(campos.at(0), email);
    await tester.enterText(campos.at(1), senha);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('essa é a nossa recomendação'), findsOneWidget);
  }

  Future<void> navegarParaCriarPlaylist(WidgetTester tester) async {
    // TelaInicialScreen -> UsuarioScreen.
    await tester.tap(find.text('Minha Conta'));
    await tester.pumpAndSettle();

    expect(find.text('Criar Playlist'), findsOneWidget);

    await tester.tap(find.text('Criar Playlist'));
    await tester.pumpAndSettle();

    expect(find.text('Criando Playlist'), findsOneWidget);
  }

  testWidgets(
    'E2E - cria playlist com músicas e persiste no Firestore',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await login(tester);
      await navegarParaCriarPlaylist(tester);

      // A CriarPlaylistScreen busca as músicas no Firestore durante o initState.
      // Esperamos que os dados reais dos emuladores apareçam na tela.
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

      // O nome é deliberadamente dinâmico para garantir que o valor digitado
      // pelo usuário é exatamente o valor persistido.
      const nomePlaylist = 'Playlist E2E - Rock e Pop';

      final campos = find.byType(TextField);
      expect(campos, findsNWidgets(2));

      // Primeiro TextField: Nome da Playlist.
      await tester.enterText(campos.at(0), nomePlaylist);

      // Seleciona duas músicas pelos respectivos ListTiles.
      //
      // O IconButton não possui Key; portanto usamos o ListTile que contém
      // o texto da música e encontramos o IconButton dentro dele.
      final bohemianTile = find.ancestor(
        of: find.text('Bohemian Rhapsody - Queen'),
        matching: find.byType(ListTile),
      );

      final billieJeanTile = find.ancestor(
        of: find.text('Billie Jean - Michael Jackson'),
        matching: find.byType(ListTile),
      );

      expect(bohemianTile, findsOneWidget);
      expect(billieJeanTile, findsOneWidget);

      await tester.tap(
        find.descendant(
          of: bohemianTile,
          matching: find.byType(IconButton),
        ),
      );

      await tester.tap(
        find.descendant(
          of: billieJeanTile,
          matching: find.byType(IconButton),
        ),
      );

      await tester.pumpAndSettle();

      // Confirma visualmente que os checkboxes foram marcados.
      expect(
        find.descendant(
          of: bohemianTile,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      expect(
        find.descendant(
          of: billieJeanTile,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      // Captura o UID do usuário autenticado para validar a associação
      // correta da playlist no Firestore.
      final user = FirebaseAuth.instance.currentUser;
      expect(user, isNotNull);

      final uid = user!.uid;

      // Garante que não havia uma playlist com o mesmo nome antes do save.
      final antes = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: uid)
          .where('nome', isEqualTo: nomePlaylist)
          .get();

      expect(antes.docs, isEmpty);

      // Salva pela interface.
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      // A tela deve fechar após o Navigator.pop().
      expect(find.text('Criando Playlist'), findsNothing);

      // Validação diretamente no Firestore emulator:
      // a playlist precisa ter sido realmente persistida.
      final resultado = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: uid)
          .where('nome', isEqualTo: nomePlaylist)
          .get();

      expect(resultado.docs, hasLength(1));

      final playlist = resultado.docs.single.data();

      expect(playlist['userId'], equals(uid));
      expect(playlist['nome'], equals(nomePlaylist));
      expect(
        playlist['musicas'],
        containsAll(<String>[
          'bohemian rhapsody',
          'billie jean',
        ]),
      );
      expect(playlist['musicas'], hasLength(2));
      expect(playlist['dataCriacao'], isA<Timestamp>());
    },
  );

  testWidgets(
    'E2E - nome vazio não salva playlist',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await login(tester);
      await navegarParaCriarPlaylist(tester);

      // Aguarda as músicas reais carregarem.
      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsOneWidget,
      );

      final user = FirebaseAuth.instance.currentUser;
      expect(user, isNotNull);

      final uid = user!.uid;

      // O nome permanece vazio.
      final nomeVazio = find.byType(TextField).at(0);
      await tester.tap(nomeVazio);
      await tester.enterText(nomeVazio, '');

      // Selecionar uma música não deve permitir o save sem nome.
      final bohemianTile = find.ancestor(
        of: find.text('Bohemian Rhapsody - Queen'),
        matching: find.byType(ListTile),
      );

      await tester.tap(
        find.descendant(
          of: bohemianTile,
          matching: find.byType(IconButton),
        ),
      );

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      // A validação ocorre antes de _salvarPlaylist().
      expect(
        find.text('Nome da playlist é obrigatório'),
        findsOneWidget,
      );

      // Continua na CriarPlaylistScreen.
      expect(find.text('Criando Playlist'), findsOneWidget);

      // Verifica no Firestore que nenhuma playlist vazia foi criada.
      final resultado = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: uid)
          .where('nome', isEqualTo: '')
          .get();

      expect(resultado.docs, isEmpty);
    },
  );
}
