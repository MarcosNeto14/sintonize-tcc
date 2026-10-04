Abaixo está o teste completo para `integration_test/fase3/criar_playlist_test.dart`. Ele percorre o fluxo real desde a tela inicial, faz login no Firebase Auth Emulator, navega até `CriarPlaylistScreen`, espera as músicas carregarem, cria a playlist e, por fim, verifica diretamente no Firestore Emulator que o documento foi persistido para o usuário autenticado.

 Teste E2E — criação de playlist

```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/criar_playlist.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu: $finder');
  }

  testWidgets(
    'criar playlist: usuário seleciona músicas e salva playlist',
    (tester) async {
      // ----------------------------------------------------------------------
      // 1. Abre o aplicativo real.
      // ----------------------------------------------------------------------
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // ----------------------------------------------------------------------
      // 2. Faz login usando o usuário previamente criado no Auth Emulator.
      // ----------------------------------------------------------------------
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'tester@sintonize.test',
      );

      await tester.enterText(
        find.byType(TextFormField).last,
        'senha123',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Confirma que o login levou à tela inicial.
      expect(find.text('Pesquisa Direta'), findsOneWidget);
      expect(find.text('Minha Conta'), findsOneWidget);

      // ----------------------------------------------------------------------
      // 3. Abre "Minha Conta".
      // ----------------------------------------------------------------------
      await tester.tap(find.text('Minha Conta'));
      await tester.pumpAndSettle();

      // ----------------------------------------------------------------------
      // 4. Abre "Criar Playlist".
      // ----------------------------------------------------------------------
      await tester.tap(find.text('Criar Playlist'));
      await esperar(
        tester,
        find.byType(CriarPlaylistScreen),
      );

      expect(find.text('Criando Playlist'), findsOneWidget);
      expect(find.text('Nome da Playlist'), findsOneWidget);
      expect(find.text('Salvar Playlist'), findsOneWidget);

      // ----------------------------------------------------------------------
      // 5. Espera as músicas do Firestore carregarem.
      //
      // O dataset do ambiente contém:
      // - Bohemian Rhapsody - Queen
      // - Billie Jean - Michael Jackson
      // - Take Five - Dave Brubeck
      // - The Thrill Is Gone - B.B. King
      // - One Love - Bob Marley
      //
      // Usamos uma música conhecida como indicador de que a consulta ao
      // Firestore terminou.
      // ----------------------------------------------------------------------
      await esperar(
        tester,
        find.text('Bohemian Rhapsody - Queen'),
      );

      expect(find.text('Billie Jean - Michael Jackson'), findsOneWidget);
      expect(find.text('Take Five - Dave Brubeck'), findsOneWidget);

      // ----------------------------------------------------------------------
      // 6. Preenche o nome da playlist.
      //
      // Os dois TextFields da tela são:
      //   1. Nome da Playlist
      //   2. Pesquisar Música ou Artista
      // ----------------------------------------------------------------------
      final textFields = find.byType(TextField);

      expect(textFields, findsNWidgets(2));

      await tester.enterText(
        textFields.at(0),
        'Playlist E2E',
      );

      // ----------------------------------------------------------------------
      // 7. Seleciona duas músicas.
      //
      // Cada música possui um IconButton no trailing do ListTile.
      // Em vez de depender de posições na tela, encontramos o ListTile pela
      // música e acionamos o IconButton correspondente.
      // ----------------------------------------------------------------------
      final bohemianTile = find.ancestor(
        of: find.text('Bohemian Rhapsody - Queen'),
        matching: find.byType(ListTile),
      );

      expect(bohemianTile, findsOneWidget);

      await tester.tap(
        find.descendant(
          of: bohemianTile,
          matching: find.byType(IconButton),
        ),
      );

      await tester.pump();

      final billieTile = find.ancestor(
        of: find.text('Billie Jean - Michael Jackson'),
        matching: find.byType(ListTile),
      );

      expect(billieTile, findsOneWidget);

      await tester.tap(
        find.descendant(
          of: billieTile,
          matching: find.byType(IconButton),
        ),
      );

      await tester.pump();

      // Confirma visualmente que os checkboxes selecionados estão marcados.
      expect(
        find.descendant(
          of: bohemianTile,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      expect(
        find.descendant(
          of: billieTile,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      // ----------------------------------------------------------------------
      // 8. Salva a playlist.
      // ----------------------------------------------------------------------
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      // _salvarPlaylist() faz Navigator.pop() após o add no Firestore.
      // Portanto, a CriarPlaylistScreen deve ter sido fechada.
      expect(find.byType(CriarPlaylistScreen), findsNothing);

      // ----------------------------------------------------------------------
      // 9. Validação E2E no Firestore Emulator.
      //
      // Não usamos mock nem interceptamos a operação de escrita.
      // Consultamos a coleção real do Firestore Emulator usando o UID do
      // usuário que acabou de fazer login.
      // ----------------------------------------------------------------------
      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);
      expect(user!.email, 'tester@sintonize.test');

      final snapshot = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: user.uid)
          .get();

      expect(snapshot.docs, isNotEmpty);

      final playlist = snapshot.docs.first.data();

      expect(playlist['userId'], user.uid);
      expect(playlist['nome'], 'Playlist E2E');
      expect(playlist['musicas'], contains('bohemian rhapsody'));
      expect(playlist['musicas'], contains('billie jean'));
      expect(playlist['musicas'], hasLength(2));
      expect(playlist['dataCriacao'], isA<Timestamp>());
    },
  );
}
```

 Esse teste valida tanto o comportamento visual/navegacional quanto o efeito real no backend: a escrita em `playlists` só é considerada bem-sucedida se o documento realmente aparecer no Firestore Emulator com o `userId` do usuário autenticado e as duas músicas selecionadas.

 Se quiser, também posso montar uma segunda versão que **não faz login pela interface**, mas cria o usuário exclusivamente pela UI de cadastro e percorre `Cadastro → Gêneros → Tela Inicial → Minha Conta → Criar Playlist`, deixando o teste ainda mais completo.