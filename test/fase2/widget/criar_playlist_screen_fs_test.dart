import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  group('CriarPlaylistScreen Widget', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
    });

    Future<void> pumpCriarPlaylist(
      WidgetTester tester, {
      bool waitForFirestore = false,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CriarPlaylistScreen(
            editPlaylist: const {},
            auth: mockAuth,
            firestore: fakeFirestore,
          ),
        ),
      );

      if (waitForFirestore) {
        // Executa o Future iniciado no initState sem esperar
        // por animações infinitas do CircularProgressIndicator.
        await tester.pump();
      } else {
        await tester.pump();
      }
    }

    testWidgets(
      'deve mostrar os campos e botão da tela',
      (tester) async {
        await pumpCriarPlaylist(tester);

        expect(
          find.text('Criando Playlist'),
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

        expect(
          find.text('Salvar Playlist'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve mostrar mensagem de erro quando nome da playlist está vazio',
      (tester) async {
        await pumpCriarPlaylist(tester);

        await tester.tap(
          find.text('Salvar Playlist'),
        );

        await tester.pump();

        expect(
          find.text('Nome da playlist é obrigatório'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve carregar músicas do Firestore',
      (tester) async {
        await fakeFirestore.collection('musica').add({
          'track_name': 'my song',
          'artist_name': 'the artist',
        });

        await pumpCriarPlaylist(
          tester,
          waitForFirestore: true,
        );

        expect(
          find.text('My Song - The Artist'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve formatar nome da música e artista',
      (tester) async {
        await fakeFirestore.collection('musica').add({
          'track_name': 'bohemian rhapsody',
          'artist_name': 'queen',
        });

        await pumpCriarPlaylist(
          tester,
          waitForFirestore: true,
        );

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve usar Desconhecido quando artista não existir',
      (tester) async {
        await fakeFirestore.collection('musica').add({
          'track_name': 'minha musica',
        });

        await pumpCriarPlaylist(
          tester,
          waitForFirestore: true,
        );

        // Esta asserção representa o comportamento esperado.
        //
        // Atualmente o widget falha antes de renderizar este texto,
        // porque musica['artist_name'] lança uma exceção quando o
        // campo não existe.
        expect(
          find.text('Minha Musica - Desconhecido'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve filtrar músicas pelo nome da música',
      (tester) async {
        await fakeFirestore.collection('musica').add({
          'track_name': 'yellow',
          'artist_name': 'coldplay',
        });

        await fakeFirestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpCriarPlaylist(
          tester,
          waitForFirestore: true,
        );

        expect(
          find.text('Yellow - Coldplay'),
          findsOneWidget,
        );

        expect(
          find.text('Imagine - John Lennon'),
          findsOneWidget,
        );

        await tester.enterText(
          find.byType(TextField).at(1),
          'yellow',
        );

        await tester.pump();

        expect(
          find.text('Yellow - Coldplay'),
          findsOneWidget,
        );

        expect(
          find.text('Imagine - John Lennon'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve filtrar músicas pelo nome do artista',
      (tester) async {
        await fakeFirestore.collection('musica').add({
          'track_name': 'song one',
          'artist_name': 'the beatles',
        });

        await fakeFirestore.collection('musica').add({
          'track_name': 'song two',
          'artist_name': 'pink floyd',
        });

        await pumpCriarPlaylist(
          tester,
          waitForFirestore: true,
        );

        await tester.enterText(
          find.byType(TextField).at(1),
          'beatles',
        );

        await tester.pump();

        expect(
          find.text('Song One - The Beatles'),
          findsOneWidget,
        );

        expect(
          find.text('Song Two - Pink Floyd'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve filtrar ignorando maiúsculas e minúsculas',
      (tester) async {
        await fakeFirestore.collection('musica').add({
          'track_name': 'beautiful day',
          'artist_name': 'u2',
        });

        await pumpCriarPlaylist(
          tester,
          waitForFirestore: true,
        );

        await tester.enterText(
          find.byType(TextField).at(1),
          'BEAUTIFUL',
        );

        await tester.pump();

        expect(
          find.text('Beautiful Day - U2'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve selecionar uma música',
      (tester) async {
        await fakeFirestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpCriarPlaylist(
          tester,
          waitForFirestore: true,
        );

        expect(
          find.byIcon(Icons.check_box_outline_blank),
          findsOneWidget,
        );

        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank),
        );

        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve desmarcar uma música previamente selecionada',
      (tester) async {
        await fakeFirestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpCriarPlaylist(
          tester,
          waitForFirestore: true,
        );

        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank),
        );

        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsOneWidget,
        );

        await tester.tap(
          find.byIcon(Icons.check_box),
        );

        await tester.pump();

        expect(
          find.byIcon(Icons.check_box_outline_blank),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve salvar playlist para usuário autenticado',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
          signedIn: true,
        );

        await fakeFirestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpCriarPlaylist(
          tester,
          waitForFirestore: true,
        );

        await tester.enterText(
          find.byType(TextField).at(0),
          'Minha Playlist',
        );

        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank),
        );

        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsOneWidget,
        );

        await tester.tap(
          find.text('Salvar Playlist'),
        );

        // Não usamos pumpAndSettle porque a tela pode ter
        // animações/estado assíncrono. Um pump é suficiente para
        // processar o Future de salvamento.
        await tester.pump();
        await tester.pump();

        final playlists =
            await fakeFirestore.collection('playlists').get();

        expect(
          playlists.docs,
          hasLength(1),
        );

        final playlist = playlists.docs.first.data();

        expect(
          playlist['userId'],
          'usuario-123',
        );

        expect(
          playlist['nome'],
          'Minha Playlist',
        );

        expect(
          playlist['musicas'],
          ['imagine'],
        );

        expect(
          playlist['dataCriacao'],
          isA<Timestamp>(),
        );
      },
    );

    testWidgets(
      'não deve salvar playlist quando não existe usuário autenticado',
      (tester) async {
        await fakeFirestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpCriarPlaylist(
          tester,
          waitForFirestore: true,
        );

        await tester.enterText(
          find.byType(TextField).at(0),
          'Minha Playlist',
        );

        await tester.tap(
          find.text('Salvar Playlist'),
        );

        await tester.pump();

        final playlists =
            await fakeFirestore.collection('playlists').get();

        expect(
          playlists.docs,
          isEmpty,
        );
      },
    );

    testWidgets(
      'deve voltar ao tocar no botão de voltar',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CriarPlaylistScreen(
                            editPlaylist: const {},
                            auth: mockAuth,
                            firestore: fakeFirestore,
                          ),
                        ),
                      );
                    },
                    child: const Text('Abrir'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();

        await tester.tap(find.text('Abrir'));

        // Avança a animação da transição da rota sem usar
        // pumpAndSettle(), pois a tela pode conter uma animação
        // indeterminada (CircularProgressIndicator).
        await tester.pump(const Duration(milliseconds: 500));

        expect(
          find.text('Criando Playlist'),
          findsOneWidget,
        );

        await tester.tap(
          find.byIcon(Icons.arrow_back),
        );

        // Avança a animação de retorno.
        await tester.pump(const Duration(milliseconds: 500));

        expect(
          find.text('Abrir'),
          findsOneWidget,
        );
      },
    );
  });
}
