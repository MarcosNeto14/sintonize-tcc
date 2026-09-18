import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sintonize/criar_playlist.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

void main() {
  group('CriarPlaylistScreen', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;

    Future<void> pumpScreen(
      WidgetTester tester, {
      FirebaseAuth? customAuth,
      FirebaseFirestore? customFirestore,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CriarPlaylistScreen(
            editPlaylist: const {},
            auth: customAuth ?? auth,
            firestore: customFirestore ?? firestore,
          ),
        ),
      );
    }

    setUp(() {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth();
    });

    testWidgets(
      'renderiza os elementos básicos da tela',
      (tester) async {
        await pumpScreen(tester);

        expect(find.text('Criando Playlist'), findsOneWidget);
        expect(find.text('Nome da Playlist'), findsOneWidget);
        expect(
          find.text('Pesquisar Música ou Artista'),
          findsOneWidget,
        );
        expect(find.text('Salvar Playlist'), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      },
    );

    testWidgets(
      'exibe indicador de carregamento antes das músicas serem carregadas',
      (tester) async {
        await pumpScreen(tester);

        // Apenas processa o primeiro frame.
        // Não usar pumpAndSettle(), pois o CircularProgressIndicator
        // possui uma animação contínua.
        await tester.pump();

        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'exibe as músicas depois que o Firestore termina de carregar',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'bohemian rhapsody',
          'artist_name': 'queen',
        });

        await firestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );
        expect(
          find.text('Imagine - John Lennon'),
          findsOneWidget,
        );

        expect(
          find.byIcon(Icons.check_box_outline_blank),
          findsNWidgets(2),
        );
      },
    );

    testWidgets(
      'formata corretamente nomes de músicas e artistas',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'my favorite song',
          'artist_name': 'the beatles',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        expect(
          find.text('My Favorite Song - The Beatles'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'permite digitar o nome da playlist',
      (tester) async {
        await pumpScreen(tester);

        final campoNome = find.byType(TextField).first;

        await tester.enterText(campoNome, 'Minha Playlist');
        await tester.pump();

        expect(
          find.text('Minha Playlist'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'filtra músicas pelo nome da música',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'bohemian rhapsody',
          'artist_name': 'queen',
        });

        await firestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final campoPesquisa = find.byType(TextField).at(1);

        await tester.enterText(campoPesquisa, 'bohemian');
        await tester.pump();

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );

        expect(
          find.text('Imagine - John Lennon'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'filtra músicas pelo nome do artista',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'bohemian rhapsody',
          'artist_name': 'queen',
        });

        await firestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final campoPesquisa = find.byType(TextField).at(1);

        await tester.enterText(campoPesquisa, 'queen');
        await tester.pump();

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );

        expect(
          find.text('Imagine - John Lennon'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'a pesquisa não diferencia maiúsculas de minúsculas',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'Bohemian Rhapsody',
          'artist_name': 'Queen',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final campoPesquisa = find.byType(TextField).at(1);

        await tester.enterText(campoPesquisa, 'QUEEN');
        await tester.pump();

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'marca uma música quando o usuário toca no checkbox',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        expect(
          find.byIcon(Icons.check_box_outline_blank),
          findsOneWidget,
        );

        await tester.tap(find.byIcon(Icons.check_box_outline_blank));
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'desmarca uma música previamente selecionada',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.check_box_outline_blank));
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsOneWidget,
        );

        await tester.tap(find.byIcon(Icons.check_box));
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box_outline_blank),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'exibe erro quando tenta salvar sem informar nome da playlist',
      (tester) async {
        await pumpScreen(tester);

        // Não usar pumpAndSettle(): a tela possui
        // CircularProgressIndicator continuamente animado.
        await tester.pump();

        await tester.tap(find.text('Salvar Playlist'));

        // Processa o rebuild causado pelo SnackBar.
        await tester.pump();

        expect(
          find.text('Nome da playlist é obrigatório'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'salva playlist com usuário autenticado e músicas selecionadas',
      (tester) async {
        final mockUser = MockUser(
          isAnonymous: false,
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        auth = MockFirebaseAuth(
          mockUser: mockUser,
          signedIn: true,
        );

        await firestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await firestore.collection('musica').add({
          'track_name': 'hey jude',
          'artist_name': 'the beatles',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final campoNome = find.byType(TextField).first;

        await tester.enterText(
          campoNome,
          'Minha Playlist',
        );

        final checkboxes =
            find.byIcon(Icons.check_box_outline_blank);

        await tester.tap(checkboxes.at(0));
        await tester.pump();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final playlists =
            await firestore.collection('playlists').get();

        expect(playlists.docs, hasLength(1));

        final playlist = playlists.docs.first.data();

        expect(
          playlist['userId'],
          equals('usuario-123'),
        );

        expect(
          playlist['nome'],
          equals('Minha Playlist'),
        );

        expect(
          playlist['musicas'],
          equals(['imagine']),
        );

        expect(
          playlist['dataCriacao'],
          isA<Timestamp>(),
        );
      },
    );

    testWidgets(
      'não salva playlist quando não existe usuário autenticado',
      (tester) async {
        auth = MockFirebaseAuth(
          signedIn: false,
        );

        await pumpScreen(tester);

        // Processa a construção inicial sem esperar
        // a animação do CircularProgressIndicator terminar.
        await tester.pump();

        await tester.enterText(
          find.byType(TextField).first,
          'Playlist sem usuário',
        );

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        final playlists =
            await firestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);
      },
    );

    testWidgets(
      'não salva playlist quando o nome é uma string vazia',
      (tester) async {
        final mockUser = MockUser(
          isAnonymous: false,
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        auth = MockFirebaseAuth(
          mockUser: mockUser,
          signedIn: true,
        );

        await pumpScreen(tester);
        await tester.pump();

        await tester.enterText(
          find.byType(TextField).first,
          '',
        );

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        expect(
          find.text('Nome da playlist é obrigatório'),
          findsOneWidget,
        );

        final playlists =
            await firestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);
      },
    );

    testWidgets(
      'aceita nome contendo apenas espaços conforme a validação atual',
      (tester) async {
        final mockUser = MockUser(
          isAnonymous: false,
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        auth = MockFirebaseAuth(
          mockUser: mockUser,
          signedIn: true,
        );

        await pumpScreen(tester);
        await tester.pump();

        await tester.enterText(
          find.byType(TextField).first,
          '   ',
        );

        await tester.tap(find.text('Salvar Playlist'));

        // Como o widget usa apenas isNotEmpty, "   " é aceito.
        await tester.pumpAndSettle();

        final playlists =
            await firestore.collection('playlists').get();

        expect(playlists.docs, hasLength(1));
        expect(
          playlists.docs.first.data()['nome'],
          equals('   '),
        );
      },
    );

    testWidgets(
      'volta para a tela anterior ao tocar no botão de voltar',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                          pageBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                          ) {
                            return CriarPlaylistScreen(
                              editPlaylist: const {},
                              auth: auth,
                              firestore: firestore,
                            );
                          },
                        ),
                      );
                    },
                    child: const Text('Abrir'),
                  ),
                );
              },
            ),
          ),
        );

        expect(
          find.text('Abrir'),
          findsOneWidget,
        );

        // Abre CriarPlaylistScreen usando uma rota sem animação.
        await tester.tap(find.text('Abrir'));
        await tester.pump();

        expect(
          find.text('Criando Playlist'),
          findsOneWidget,
        );

        expect(
          find.text('Abrir'),
          findsNothing,
        );

        // Executa o Navigator.pop() existente no widget.
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pump();

        // A tela anterior deve estar novamente visível.
        expect(
          find.text('Abrir'),
          findsOneWidget,
        );

        expect(
          find.text('Criando Playlist'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'exibe indicador quando a coleção de músicas está vazia',
      (tester) async {
        await pumpScreen(tester);

        // O CircularProgressIndicator é uma animação contínua.
        await tester.pump();

        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );

        expect(
          find.byType(ListTile),
          findsNothing,
        );
      },
    );

    testWidgets(
      'permite selecionar várias músicas',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'first song',
          'artist_name': 'artist one',
        });

        await firestore.collection('musica').add({
          'track_name': 'second song',
          'artist_name': 'artist two',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final checkboxes =
            find.byIcon(Icons.check_box_outline_blank);

        expect(checkboxes, findsNWidgets(2));

        await tester.tap(checkboxes.at(0));
        await tester.pump();

        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank),
        );
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsNWidgets(2),
        );
      },
    );

    testWidgets(
      'pesquisa sem resultados não exibe nenhuma música',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField).at(1),
          'xyz-musica-inexistente',
        );

        await tester.pump();

        expect(
          find.text('Imagine - John Lennon'),
          findsNothing,
        );
      },
    );
  });
}
