import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;

  const editPlaylist = <String, dynamic>{};

  Future<void> seedMusicas(
    FakeFirebaseFirestore firestore,
  ) async {
    await firestore.collection('musica').add({
      'track_name': 'Bohemian Rhapsody',
      'artist_name': 'Queen',
    });

    await firestore.collection('musica').add({
      'track_name': 'Imagine',
      'artist_name': 'John Lennon',
    });

    await firestore.collection('musica').add({
      'track_name': 'Billie Jean',
      'artist_name': 'Michael Jackson',
    });
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    FakeFirebaseFirestore? customFirestore,
    MockFirebaseAuth? customAuth,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CriarPlaylistScreen(
          editPlaylist: editPlaylist,
          auth: customAuth ?? auth,
          firestore: customFirestore ?? firestore,
        ),
      ),
    );

    // Permite que _fetchMusicas termine e o setState seja processado.
    await tester.pump();
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();

    final user = MockUser(
      uid: 'user-test-123',
      email: 'teste@sintonize.com',
      displayName: 'Usuário Teste',
    );

    auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: user,
    );
  });

  group('CriarPlaylistScreen - renderização', () {
    testWidgets(
      'deve renderizar os elementos principais e as músicas carregadas',
      (tester) async {
        await seedMusicas(firestore);

        await pumpScreen(tester);

        expect(find.text('Criando Playlist'), findsOneWidget);
        expect(find.text('Nome da Playlist'), findsOneWidget);
        expect(find.text('Pesquisar Música ou Artista'), findsOneWidget);
        expect(find.text('Salvar Playlist'), findsOneWidget);

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );
        expect(
          find.text('Imagine - John Lennon'),
          findsOneWidget,
        );
        expect(
          find.text('Billie Jean - Michael Jackson'),
          findsOneWidget,
        );

        expect(find.byIcon(Icons.person), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      },
    );

    testWidgets(
      'deve mostrar CircularProgressIndicator quando o Firestore não possui músicas',
      (tester) async {
        await pumpScreen(tester);

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Salvar Playlist'), findsOneWidget);
      },
    );

    testWidgets(
      'deve voltar quando o botão de voltar for pressionado',
      (tester) async {
        await seedMusicas(firestore);

        var returned = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CriarPlaylistScreen(
                          editPlaylist: editPlaylist,
                          auth: auth,
                          firestore: firestore,
                        ),
                      ),
                    );
                  },
                  child: const Text('Abrir playlist'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Abrir playlist'));
        await tester.pump();
        await tester.pump();

        expect(find.text('Criando Playlist'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        returned = find.text('Abrir playlist').evaluate().isNotEmpty;

        expect(returned, isTrue);
      },
    );
  });

  group('CriarPlaylistScreen - validação', () {
    testWidgets(
      'deve exibir erro quando tentar salvar sem informar o nome da playlist',
      (tester) async {
        await seedMusicas(firestore);

        await pumpScreen(tester);

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        expect(
          find.text('Nome da playlist é obrigatório'),
          findsOneWidget,
        );

        // Nenhuma playlist deve ter sido criada.
        final snapshot = await firestore.collection('playlists').get();
        expect(snapshot.docs, isEmpty);
      },
    );

    testWidgets(
      'deve aceitar um nome de playlist preenchido',
      (tester) async {
        await seedMusicas(firestore);

        await pumpScreen(tester);

        final nomeField = find.widgetWithText(
          TextField,
          'Nome da Playlist',
        );

        await tester.enterText(nomeField, 'Minha Playlist');
        await tester.pump();

        expect(find.text('Minha Playlist'), findsOneWidget);
      },
    );
  });

  group('CriarPlaylistScreen - pesquisa', () {
    testWidgets(
      'deve filtrar músicas pelo nome da faixa',
      (tester) async {
        await seedMusicas(firestore);

        await pumpScreen(tester);

        final searchField = find.widgetWithText(
          TextField,
          'Pesquisar Música ou Artista',
        );

        await tester.enterText(searchField, 'bohemian');
        await tester.pump();

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );
        expect(
          find.text('Imagine - John Lennon'),
          findsNothing,
        );
        expect(
          find.text('Billie Jean - Michael Jackson'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve filtrar músicas pelo nome do artista',
      (tester) async {
        await seedMusicas(firestore);

        await pumpScreen(tester);

        final searchField = find.widgetWithText(
          TextField,
          'Pesquisar Música ou Artista',
        );

        await tester.enterText(searchField, 'michael');
        await tester.pump();

        expect(
          find.text('Billie Jean - Michael Jackson'),
          findsOneWidget,
        );
        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsNothing,
        );
        expect(
          find.text('Imagine - John Lennon'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve fazer pesquisa case-insensitive',
      (tester) async {
        await seedMusicas(firestore);

        await pumpScreen(tester);

        final searchField = find.widgetWithText(
          TextField,
          'Pesquisar Música ou Artista',
        );

        await tester.enterText(searchField, 'QUEEN');
        await tester.pump();

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve não mostrar músicas quando a pesquisa não encontrar resultados',
      (tester) async {
        await seedMusicas(firestore);

        await pumpScreen(tester);

        final searchField = find.widgetWithText(
          TextField,
          'Pesquisar Música ou Artista',
        );

        await tester.enterText(searchField, 'artista inexistente');
        await tester.pump();

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsNothing,
        );
        expect(
          find.text('Imagine - John Lennon'),
          findsNothing,
        );
        expect(
          find.text('Billie Jean - Michael Jackson'),
          findsNothing,
        );

        // A implementação usa a lista vazia como condição para
        // CircularProgressIndicator, portanto o estado de "sem resultados"
        // também apresenta o indicador de progresso.
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'deve retornar todas as músicas quando a pesquisa for limpa',
      (tester) async {
        await seedMusicas(firestore);

        await pumpScreen(tester);

        final searchField = find.widgetWithText(
          TextField,
          'Pesquisar Música ou Artista',
        );

        await tester.enterText(searchField, 'queen');
        await tester.pump();

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );
        expect(
          find.text('Imagine - John Lennon'),
          findsNothing,
        );

        await tester.enterText(searchField, '');
        await tester.pump();

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );
        expect(
          find.text('Imagine - John Lennon'),
          findsOneWidget,
        );
        expect(
          find.text('Billie Jean - Michael Jackson'),
          findsOneWidget,
        );
      },
    );
  });

  group('CriarPlaylistScreen - seleção de músicas', () {
    testWidgets(
      'deve selecionar uma música ao tocar no checkbox',
      (tester) async {
        await seedMusicas(firestore);

        await pumpScreen(tester);

        final tile = find.text('Bohemian Rhapsody - Queen');

        final listTile = find.ancestor(
          of: tile,
          matching: find.byType(ListTile),
        );

        final checkboxButton = find.descendant(
          of: listTile,
          matching: find.byIcon(Icons.check_box_outline_blank),
        );

        expect(checkboxButton, findsOneWidget);

        await tester.tap(checkboxButton);
        await tester.pump();

        expect(
          find.descendant(
            of: listTile,
            matching: find.byIcon(Icons.check_box),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve desselecionar uma música quando o checkbox selecionado for pressionado novamente',
      (tester) async {
        await seedMusicas(firestore);

        await pumpScreen(tester);

        final tile = find.text('Bohemian Rhapsody - Queen');

        final listTile = find.ancestor(
          of: tile,
          matching: find.byType(ListTile),
        );

        await tester.tap(
          find.descendant(
            of: listTile,
            matching: find.byIcon(Icons.check_box_outline_blank),
          ),
        );
        await tester.pump();

        expect(
          find.descendant(
            of: listTile,
            matching: find.byIcon(Icons.check_box),
          ),
          findsOneWidget,
        );

        await tester.tap(
          find.descendant(
            of: listTile,
            matching: find.byIcon(Icons.check_box),
          ),
        );
        await tester.pump();

        expect(
          find.descendant(
            of: listTile,
            matching: find.byIcon(Icons.check_box_outline_blank),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve permitir selecionar várias músicas',
      (tester) async {
        await seedMusicas(firestore);

        await pumpScreen(tester);

        final firstTile = find.ancestor(
          of: find.text('Bohemian Rhapsody - Queen'),
          matching: find.byType(ListTile),
        );

        final secondTile = find.ancestor(
          of: find.text('Imagine - John Lennon'),
          matching: find.byType(ListTile),
        );

        await tester.tap(
          find.descendant(
            of: firstTile,
            matching: find.byIcon(Icons.check_box_outline_blank),
          ),
        );

        await tester.tap(
          find.descendant(
            of: secondTile,
            matching: find.byIcon(Icons.check_box_outline_blank),
          ),
        );

        await tester.pump();

        expect(
          find.descendant(
            of: firstTile,
            matching: find.byIcon(Icons.check_box),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: secondTile,
            matching: find.byIcon(Icons.check_box),
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('CriarPlaylistScreen - scroll', () {
    testWidgets(
      'deve permitir rolar a lista de músicas',
      (tester) async {
        for (var i = 0; i < 30; i++) {
          await firestore.collection('musica').add({
            'track_name': 'Musica $i',
            'artist_name': 'Artista $i',
          });
        }

        await pumpScreen(tester);

        final listView = find.byType(ListView);
        expect(listView, findsOneWidget);

        // O item 29 começa fora da viewport.
        expect(
          find.text('Musica 29 - Artista 29'),
          findsNothing,
        );

        await tester.scrollUntilVisible(
          find.text('Musica 29 - Artista 29'),
          300,
          scrollable: listView,
        );

        await tester.pump();

        expect(
          find.text('Musica 29 - Artista 29'),
          findsOneWidget,
        );
      },
    );
  });

  group('CriarPlaylistScreen - salvamento', () {
    testWidgets(
      'deve salvar a playlist com usuário, nome e músicas selecionadas',
      (tester) async {
        await seedMusicas(firestore);

        await pumpScreen(tester);

        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Nome da Playlist',
          ),
          'Minha Playlist',
        );

        final firstTile = find.ancestor(
          of: find.text('Bohemian Rhapsody - Queen'),
          matching: find.byType(ListTile),
        );

        final secondTile = find.ancestor(
          of: find.text('Imagine - John Lennon'),
          matching: find.byType(ListTile),
        );

        await tester.tap(
          find.descendant(
            of: firstTile,
            matching: find.byIcon(Icons.check_box_outline_blank),
          ),
        );

        await tester.tap(
          find.descendant(
            of: secondTile,
            matching: find.byIcon(Icons.check_box_outline_blank),
          ),
        );

        await tester.pump();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final snapshot = await firestore.collection('playlists').get();

        expect(snapshot.docs, hasLength(1));

        final playlist = snapshot.docs.first.data();

        expect(playlist['userId'], 'user-test-123');

        // Observação importante:
        // o widget atualmente grava "Nova Playlist", e não
        // o conteúdo de _playlistName.
        expect(playlist['nome'], 'Nova Playlist');

        expect(
          playlist['musicas'],
          containsAll(<String>[
            'Bohemian Rhapsody',
            'Imagine',
          ]),
        );

        expect(playlist['musicas'], hasLength(2));
        expect(playlist['dataCriacao'], isA<Timestamp>());

        // O Navigator.pop() executado após o add() remove a tela.
        expect(find.text('Criando Playlist'), findsNothing);
      },
    );

    testWidgets(
      'não deve salvar quando não existe usuário autenticado',
      (tester) async {
        await seedMusicas(firestore);

        final authWithoutUser = MockFirebaseAuth(
          signedIn: false,
        );

        await pumpScreen(
          tester,
          customAuth: authWithoutUser,
        );

        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Nome da Playlist',
          ),
          'Playlist sem usuário',
        );

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final snapshot = await firestore.collection('playlists').get();

        expect(snapshot.docs, isEmpty);

        // Como o código não trata explicitamente currentUser == null,
        // também não há SnackBar de erro nesse cenário.
        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets(
      'deve exibir SnackBar quando o Firestore falhar ao salvar',
      (tester) async {
        final failingFirestore = FakeFirebaseFirestore(
          securityRules: '''
          service cloud.firestore {
            match /databases/{database}/documents {
              match /musica/{document} {
                allow read, write: if true;
              }

              match /playlists/{document} {
                allow read: if true;
                allow write: if false;
              }
            }
          }
          ''',
          authObject: auth.authForFakeFirestore,
        );

        await failingFirestore.collection('musica').add({
          'track_name': 'Bohemian Rhapsody',
          'artist_name': 'Queen',
        });

        await pumpScreen(
          tester,
          customFirestore: failingFirestore,
        );

        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Nome da Playlist',
          ),
          'Playlist com erro',
        );

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        expect(
          find.textContaining('Erro ao salvar a playlist'),
          findsOneWidget,
        );

        final snapshot =
            await failingFirestore.collection('playlists').get();

        expect(snapshot.docs, isEmpty);
      },
    );
  });

  group('CriarPlaylistScreen - erros do Firestore', () {
    testWidgets(
      'deve capturar erro ao buscar músicas sem quebrar a tela',
      (tester) async {
        final musicaQuery = firestore.collection('musica');

        whenCalling(
          Invocation.method(#get, null),
        ).on(musicaQuery).thenThrow(
              FirebaseException(
                plugin: 'cloud_firestore',
                code: 'unavailable',
                message: 'Falha de rede',
              ),
            );

        await pumpScreen(tester);

        expect(find.text('Criando Playlist'), findsOneWidget);
        expect(find.text('Nome da Playlist'), findsOneWidget);
        expect(find.text('Salvar Playlist'), findsOneWidget);

        // _fetchMusicas captura a exceção e não altera
        // _musicasFiltradas, que continua vazia.
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );
  });
}
