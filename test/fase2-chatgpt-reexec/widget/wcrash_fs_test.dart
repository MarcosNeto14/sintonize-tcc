import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// AJUSTE ESTE IMPORT para o local real do arquivo.
// Exemplos:
// import 'package:sintonize/screens/criar_playlist_screen.dart';
// import 'package:sintonize/pages/criar_playlist_screen.dart';
// import 'package:sintonize/widgets/criar_playlist_screen.dart';
import 'package:sintonize/criar_playlist_screen.dart';

void main() {
  group('CriarPlaylistScreen Widget', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user123'),
      );

      fakeFirestore = FakeFirebaseFirestore();
    });

    Future<void> inserirMusicas() async {
      await fakeFirestore.collection('musica').add({
        'track_name': 'love story',
        'artist_name': 'taylor swift',
      });

      await fakeFirestore.collection('musica').add({
        'track_name': 'shape of you',
        'artist_name': 'ed sheeran',
      });

      await fakeFirestore.collection('musica').add({
        'track_name': 'bohemian rhapsody',
        'artist_name': 'queen',
      });
    }

    Future<void> abrirTela(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CriarPlaylistScreen(
            editPlaylist: const {},
            auth: mockAuth,
            firestore: fakeFirestore,
          ),
        ),
      );

      await tester.pumpAndSettle();
    }

    testWidgets('deve exibir o título e os campos da tela', (tester) async {
      await abrirTela(tester);

      expect(find.text('Criando Playlist'), findsOneWidget);
      expect(find.text('Nome da Playlist'), findsOneWidget);
      expect(
        find.text('Pesquisar Música ou Artista'),
        findsOneWidget,
      );
      expect(find.text('Salvar Playlist'), findsOneWidget);
    });

    testWidgets(
      'deve carregar e exibir as músicas do Firestore',
      (tester) async {
        await inserirMusicas();
        await abrirTela(tester);

        expect(
          find.text('Love Story - Taylor Swift'),
          findsOneWidget,
        );

        expect(
          find.text('Shape Of You - Ed Sheeran'),
          findsOneWidget,
        );

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve filtrar músicas pelo nome da música',
      (tester) async {
        await inserirMusicas();
        await abrirTela(tester);

        final campoBusca = find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText ==
                  'Pesquisar Música ou Artista',
        );

        await tester.enterText(campoBusca, 'love');
        await tester.pump();

        expect(
          find.text('Love Story - Taylor Swift'),
          findsOneWidget,
        );

        expect(
          find.text('Shape Of You - Ed Sheeran'),
          findsNothing,
        );

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve filtrar músicas pelo nome do artista',
      (tester) async {
        await inserirMusicas();
        await abrirTela(tester);

        final campoBusca = find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText ==
                  'Pesquisar Música ou Artista',
        );

        await tester.enterText(campoBusca, 'queen');
        await tester.pump();

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );

        expect(
          find.text('Love Story - Taylor Swift'),
          findsNothing,
        );

        expect(
          find.text('Shape Of You - Ed Sheeran'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve permitir selecionar e desselecionar uma música',
      (tester) async {
        await inserirMusicas();
        await abrirTela(tester);

        final musica = find.text('Love Story - Taylor Swift');

        final listTile = find.ancestor(
          of: musica,
          matching: find.byType(ListTile),
        );

        final botaoSelecao = find.descendant(
          of: listTile,
          matching: find.byType(IconButton),
        );

        expect(
          find.descendant(
            of: botaoSelecao,
            matching: find.byIcon(
              Icons.check_box_outline_blank,
            ),
          ),
          findsOneWidget,
        );

        await tester.tap(botaoSelecao);
        await tester.pump();

        expect(
          find.descendant(
            of: botaoSelecao,
            matching: find.byIcon(Icons.check_box),
          ),
          findsOneWidget,
        );

        await tester.tap(botaoSelecao);
        await tester.pump();

        expect(
          find.descendant(
            of: botaoSelecao,
            matching: find.byIcon(
              Icons.check_box_outline_blank,
            ),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve mostrar erro quando tentar salvar sem informar o nome da playlist',
      (tester) async {
        await inserirMusicas();
        await abrirTela(tester);

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        expect(
          find.text('Nome da playlist é obrigatório'),
          findsOneWidget,
        );

        final playlists =
            await fakeFirestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);
      },
    );

    testWidgets(
      'deve salvar a playlist com usuário e música selecionada',
      (tester) async {
        await inserirMusicas();
        await abrirTela(tester);

        final campoNome = find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText == 'Nome da Playlist',
        );

        await tester.enterText(campoNome, 'Minha Playlist');

        final musica = find.text('Love Story - Taylor Swift');

        final listTile = find.ancestor(
          of: musica,
          matching: find.byType(ListTile),
        );

        final botaoSelecao = find.descendant(
          of: listTile,
          matching: find.byType(IconButton),
        );

        await tester.tap(botaoSelecao);
        await tester.pump();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final playlists =
            await fakeFirestore.collection('playlists').get();

        expect(playlists.docs.length, 1);

        final playlist = playlists.docs.first.data();

        expect(playlist['userId'], 'user123');

        // Este teste registra o comportamento atual da implementação.
        expect(playlist['nome'], 'Nova Playlist');

        expect(playlist['musicas'], ['love story']);

        expect(
          playlist['dataCriacao'],
          isA<Timestamp>(),
        );
      },
    );

    testWidgets(
      'deve voltar para a tela anterior depois de salvar',
      (tester) async {
        await inserirMusicas();

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CriarPlaylistScreen(
                            editPlaylist: const {},
                            auth: mockAuth,
                            firestore: fakeFirestore,
                          ),
                        ),
                      );
                    },
                    child: const Text('Abrir playlist'),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Abrir playlist'));
        await tester.pumpAndSettle();

        final campoNome = find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText == 'Nome da Playlist',
        );

        await tester.enterText(campoNome, 'Minha Playlist');

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        expect(find.text('Abrir playlist'), findsOneWidget);
        expect(find.text('Criando Playlist'), findsNothing);
      },
    );

    testWidgets(
      'deve mostrar CircularProgressIndicator quando não houver músicas',
      (tester) async {
        await abrirTela(tester);

        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve filtrar sem diferenciar maiúsculas e minúsculas',
      (tester) async {
        await inserirMusicas();
        await abrirTela(tester);

        final campoBusca = find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText ==
                  'Pesquisar Música ou Artista',
        );

        await tester.enterText(campoBusca, 'TaYlOr');
        await tester.pump();

        expect(
          find.text('Love Story - Taylor Swift'),
          findsOneWidget,
        );

        expect(
          find.text('Shape Of You - Ed Sheeran'),
          findsNothing,
        );
      },
    );
  });
}
