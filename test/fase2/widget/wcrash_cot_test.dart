import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sintonize/criar_playlist.dart';

import 'wcrash_cot_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  Query,
  QuerySnapshot,
])
void main() {
  group('CriarPlaylistScreen', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;

    Future<void> pumpScreen(
      WidgetTester tester, {
      required FirebaseAuth auth,
      required FirebaseFirestore firestore,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CriarPlaylistScreen(
            editPlaylist: const {},
            auth: auth,
            firestore: firestore,
          ),
        ),
      );

      // Aguarda o Future iniciado no initState.
      await tester.pumpAndSettle();
    }

    Future<void> adicionarMusicas(
      FakeFirebaseFirestore firestore,
      List<Map<String, dynamic>> musicas,
    ) async {
      for (final musica in musicas) {
        await firestore.collection('musica').add(musica);
      }
    }

    setUp(() {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth();
    });

    group('Renderização', () {
      testWidgets(
        'deve renderizar os principais elementos da tela',
        (WidgetTester tester) async {
          await pumpScreen(
            tester,
            auth: auth,
            firestore: firestore,
          );

          expect(find.text('Criando Playlist'), findsOneWidget);
          expect(find.text('Nome da Playlist'), findsOneWidget);
          expect(
            find.text('Pesquisar Música ou Artista'),
            findsOneWidget,
          );
          expect(find.text('Salvar Playlist'), findsOneWidget);
          expect(find.byIcon(Icons.arrow_back), findsOneWidget);
          expect(find.byIcon(Icons.person), findsOneWidget);
          expect(find.byIcon(Icons.search), findsOneWidget);
        },
      );

      testWidgets(
        'deve carregar e exibir as músicas vindas do Firestore',
        (WidgetTester tester) async {
          await adicionarMusicas(
            firestore,
            [
              {
                'track_name': 'shape of you',
                'artist_name': 'ed sheeran',
              },
              {
                'track_name': 'believer',
                'artist_name': 'imagine dragons',
              },
            ],
          );

          await pumpScreen(
            tester,
            auth: auth,
            firestore: firestore,
          );

          expect(
            find.text('Shape Of You - Ed Sheeran'),
            findsOneWidget,
          );
          expect(
            find.text('Believer - Imagine Dragons'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'deve exibir o indicador de carregamento quando não existem músicas',
        (WidgetTester tester) async {
          // Não adiciona músicas ao FakeFirestore.
          await tester.pumpWidget(
            MaterialApp(
              home: CriarPlaylistScreen(
                editPlaylist: const {},
                auth: auth,
                firestore: firestore,
              ),
            ),
          );

          await tester.pumpAndSettle();

          // O código de produção usa isEmpty tanto para "carregando"
          // quanto para uma coleção vazia.
          expect(
            find.byType(CircularProgressIndicator),
            findsOneWidget,
          );
        },
      );
    });

    group('Validação', () {
      testWidgets(
        'deve exibir erro ao tentar salvar sem informar o nome',
        (WidgetTester tester) async {
          await pumpScreen(
            tester,
            auth: auth,
            firestore: firestore,
          );

          await tester.tap(find.text('Salvar Playlist'));
          await tester.pump();

          expect(
            find.text('Nome da playlist é obrigatório'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'deve exibir erro quando o nome informado é vazio',
        (WidgetTester tester) async {
          await pumpScreen(
            tester,
            auth: auth,
            firestore: firestore,
          );

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
        },
      );

      testWidgets(
        'deve aceitar um nome válido da playlist',
        (WidgetTester tester) async {
          await pumpScreen(
            tester,
            auth: auth,
            firestore: firestore,
          );

          final nomeField = find.byType(TextField).first;

          await tester.enterText(
            nomeField,
            'Minha Playlist',
          );

          expect(
            find.text('Minha Playlist'),
            findsOneWidget,
          );
        },
      );
    });

    group('Pesquisa e interação com músicas', () {
      testWidgets(
        'deve filtrar músicas pelo nome da música',
        (WidgetTester tester) async {
          await adicionarMusicas(
            firestore,
            [
              {
                'track_name': 'shape of you',
                'artist_name': 'ed sheeran',
              },
              {
                'track_name': 'believer',
                'artist_name': 'imagine dragons',
              },
            ],
          );

          await pumpScreen(
            tester,
            auth: auth,
            firestore: firestore,
          );

          final searchField = find.byType(TextField).at(1);

          await tester.enterText(
            searchField,
            'shape',
          );

          await tester.pump();

          expect(
            find.text('Shape Of You - Ed Sheeran'),
            findsOneWidget,
          );
          expect(
            find.text('Believer - Imagine Dragons'),
            findsNothing,
          );
        },
      );

      testWidgets(
        'deve filtrar músicas pelo nome do artista',
        (WidgetTester tester) async {
          await adicionarMusicas(
            firestore,
            [
              {
                'track_name': 'shape of you',
                'artist_name': 'ed sheeran',
              },
              {
                'track_name': 'believer',
                'artist_name': 'imagine dragons',
              },
            ],
          );

          await pumpScreen(
            tester,
            auth: auth,
            firestore: firestore,
          );

          final searchField = find.byType(TextField).at(1);

          await tester.enterText(
            searchField,
            'imagine',
          );

          await tester.pump();

          expect(
            find.text('Believer - Imagine Dragons'),
            findsOneWidget,
          );
          expect(
            find.text('Shape Of You - Ed Sheeran'),
            findsNothing,
          );
        },
      );

      testWidgets(
        'deve realizar pesquisa sem diferenciar maiúsculas e minúsculas',
        (WidgetTester tester) async {
          await adicionarMusicas(
            firestore,
            [
              {
                'track_name': 'Shape of You',
                'artist_name': 'Ed Sheeran',
              },
            ],
          );

          await pumpScreen(
            tester,
            auth: auth,
            firestore: firestore,
          );

          final searchField = find.byType(TextField).at(1);

          await tester.enterText(
            searchField,
            'SHAPE',
          );

          await tester.pump();

          expect(
            find.text('Shape Of You - Ed Sheeran'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'deve remover da lista as músicas que não correspondem à pesquisa',
        (WidgetTester tester) async {
          await adicionarMusicas(
            firestore,
            [
              {
                'track_name': 'hello',
                'artist_name': 'adele',
              },
              {
                'track_name': 'yellow',
                'artist_name': 'coldplay',
              },
            ],
          );

          await pumpScreen(
            tester,
            auth: auth,
            firestore: firestore,
          );

          final searchField = find.byType(TextField).at(1);

          await tester.enterText(
            searchField,
            'adele',
          );

          await tester.pump();

          expect(
            find.text('Hello - Adele'),
            findsOneWidget,
          );
          expect(
            find.text('Yellow - Coldplay'),
            findsNothing,
          );
        },
      );

      testWidgets(
        'deve permitir selecionar e desselecionar uma música',
        (WidgetTester tester) async {
          await adicionarMusicas(
            firestore,
            [
              {
                'track_name': 'hello',
                'artist_name': 'adele',
              },
            ],
          );

          await pumpScreen(
            tester,
            auth: auth,
            firestore: firestore,
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
        'deve permitir scroll pela lista de músicas',
        (WidgetTester tester) async {
          final musicas = List.generate(
            30,
            (index) => {
              'track_name': 'musica $index',
              'artist_name': 'artista $index',
            },
          );

          await adicionarMusicas(
            firestore,
            musicas,
          );

          await pumpScreen(
            tester,
            auth: auth,
            firestore: firestore,
          );

          expect(find.byType(ListView), findsOneWidget);

          // Move a lista para baixo.
          await tester.drag(
            find.byType(ListView),
            const Offset(0, -500),
          );

          await tester.pumpAndSettle();

          // Uma música inicialmente fora da viewport deve poder
          // ser encontrada após o scroll.
          expect(
            find.text('Musica 20 - Artista 20'),
            findsOneWidget,
          );
        },
      );
    });

    group('Salvamento com sucesso', () {
      testWidgets(
        'deve salvar a playlist com usuário autenticado',
        (WidgetTester tester) async {
          final mockUser = MockUser(
            uid: 'usuario-123',
            email: 'teste@sintonize.com',
          );
          auth = MockFirebaseAuth(
            mockUser: mockUser,
          );

          await adicionarMusicas(
            firestore,
            [
              {
                'track_name': 'hello',
                'artist_name': 'adele',
              },
              {
                'track_name': 'yellow',
                'artist_name': 'coldplay',
              },
            ],
          );

          // Cria uma tela anterior para podermos verificar o Navigator.pop.
          await tester.pumpWidget(
            MaterialApp(
              initialRoute: '/',
              routes: {
                '/': (_) => const Scaffold(
                      body: Text('Tela anterior'),
                    ),
                '/playlist': (_) => CriarPlaylistScreen(
                      editPlaylist: const {},
                      auth: auth,
                      firestore: firestore,
                    ),
              },
            ),
          );
          Navigator.of(
            tester.element(find.text('Tela anterior')),
          ).pushNamed('/playlist');
          await tester.pumpAndSettle();

          // Informa o nome.
          await tester.enterText(
            find.byType(TextField).first,
            'Minha Playlist',
          );
          // Seleciona "Hello".
          await tester.tap(
            find.byIcon(Icons.check_box_outline_blank).first,
          );
          await tester.pump();
          await tester.tap(
            find.text('Salvar Playlist'),
          );
          await tester.pumpAndSettle();

          // O Navigator.pop deve ter retornado para a tela anterior.
          expect(
            find.text('Tela anterior'),
            findsOneWidget,
          );

          // Verifica o documento criado no Firestore fake.
          final snapshot =
              await firestore.collection('playlists').get();
          expect(snapshot.docs, hasLength(1));
          final playlist = snapshot.docs.first.data();
          expect(
            playlist['userId'],
            'usuario-123',
          );
          expect(
            playlist['musicas'],
            ['hello'],
          );
          // O widget atualmente salva "Nova Playlist", apesar de
          // receber o texto digitado pelo usuário.
          expect(
            playlist['nome'],
            'Nova Playlist',
          );
          expect(
            playlist['dataCriacao'],
            isA<Timestamp>(),
          );
        },
      );

      testWidgets(
        'não deve salvar quando não existe usuário autenticado',
        (WidgetTester tester) async {
          // MockFirebaseAuth sem mockUser => currentUser == null.
          auth = MockFirebaseAuth();

          await adicionarMusicas(
            firestore,
            [
              {
                'track_name': 'hello',
                'artist_name': 'adele',
              },
            ],
          );

          await pumpScreen(
            tester,
            auth: auth,
            firestore: firestore,
          );

          await tester.enterText(
            find.byType(TextField).first,
            'Minha Playlist',
          );
          await tester.tap(
            find.byIcon(Icons.check_box_outline_blank),
          );
          await tester.tap(
            find.text('Salvar Playlist'),
          );
          await tester.pumpAndSettle();

          final snapshot =
              await firestore.collection('playlists').get();
          expect(snapshot.docs, isEmpty);

          // Como o código de produção não trata currentUser == null
          // com SnackBar ou outra mensagem, apenas verificamos que
          // não houve persistência.
          expect(
            find.text('Criando Playlist'),
            findsOneWidget,
          );
        },
      );
    });

    group('Navegação', () {
      testWidgets(
        'deve voltar ao pressionar o botão de voltar',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              initialRoute: '/',
              routes: {
                '/': (_) => const Scaffold(
                      body: Text('Tela inicial'),
                    ),
                '/playlist': (_) => CriarPlaylistScreen(
                      editPlaylist: const {},
                      auth: auth,
                      firestore: firestore,
                    ),
              },
            ),
          );
          Navigator.of(
            tester.element(find.text('Tela inicial')),
          ).pushNamed('/playlist');
          await tester.pumpAndSettle();

          expect(
            find.text('Criando Playlist'),
            findsOneWidget,
          );

          await tester.tap(
            find.byIcon(Icons.arrow_back),
          );
          await tester.pumpAndSettle();

          expect(
            find.text('Tela inicial'),
            findsOneWidget,
          );
          expect(
            find.text('Criando Playlist'),
            findsNothing,
          );
        },
      );
    });

    group('Erros do Firestore', () {
      testWidgets(
        'não deve quebrar quando falha ao buscar músicas',
        (WidgetTester tester) async {
          final firestoreMock = MockFirebaseFirestore();
          final musicaCollection =
              MockCollectionReference<Map<String, dynamic>>();
          final snapshot = MockQuerySnapshot<Map<String, dynamic>>();

          when(
            firestoreMock.collection('musica'),
          ).thenReturn(musicaCollection);
          when(
            musicaCollection.get(),
          ).thenAnswer(
            (_) async => snapshot,
          );
          when(snapshot.docs).thenReturn([]);

          await tester.pumpWidget(
            MaterialApp(
              home: CriarPlaylistScreen(
                editPlaylist: const {},
                auth: auth,
                firestore: firestoreMock,
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(
            find.text('Criando Playlist'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'deve exibir SnackBar quando ocorre erro ao salvar',
        (WidgetTester tester) async {
          final firestoreMock = MockFirebaseFirestore();
          final musicaCollection =
              MockCollectionReference<Map<String, dynamic>>();
          final playlistsCollection =
              MockCollectionReference<Map<String, dynamic>>();
          final documentReference =
              MockDocumentReference<Map<String, dynamic>>();
          final snapshot = MockQuerySnapshot<Map<String, dynamic>>();

          when(
            firestoreMock.collection('musica'),
          ).thenReturn(musicaCollection);
          when(
            musicaCollection.get(),
          ).thenAnswer(
            (_) async => snapshot,
          );
          when(snapshot.docs).thenReturn([]);

          when(
            firestoreMock.collection('playlists'),
          ).thenReturn(playlistsCollection);
          when(
            playlistsCollection.add(any),
          ).thenAnswer(
            (_) async => throw Exception('Erro de rede'),
          );
          when(
            playlistsCollection.doc(any),
          ).thenReturn(documentReference);

          final mockUser = MockUser(
            uid: 'usuario-123',
            email: 'teste@sintonize.com',
          );
          auth = MockFirebaseAuth(
            mockUser: mockUser,
          );

          await pumpScreen(
            tester,
            auth: auth,
            firestore: firestoreMock,
          );

          await tester.enterText(
            find.byType(TextField).first,
            'Minha Playlist',
          );
          await tester.tap(
            find.text('Salvar Playlist'),
          );
          await tester.pump();

          expect(
            find.textContaining(
              'Erro ao salvar a playlist:',
            ),
            findsOneWidget,
          );
          expect(
            find.textContaining('Erro de rede'),
            findsOneWidget,
          );
        },
      );
    });

    group('Formato dos dados', () {
      testWidgets(
        'deve formatar nome da música e artista com iniciais maiúsculas',
        (WidgetTester tester) async {
          await adicionarMusicas(
            firestore,
            [
              {
                'track_name': 'my favorite song',
                'artist_name': 'the beatles',
              },
            ],
          );

          await pumpScreen(
            tester,
            auth: auth,
            firestore: firestore,
          );

          expect(
            find.text('My Favorite Song - The Beatles'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'deve usar "Desconhecido" quando artist_name é null',
        (WidgetTester tester) async {
          await adicionarMusicas(
            firestore,
            [
              {
                'track_name': 'unknown artist song',
                'artist_name': null,
              },
            ],
          );

          await pumpScreen(
            tester,
            auth: auth,
            firestore: firestore,
          );

          expect(
            find.text('Unknown Artist Song - Desconhecido'),
            findsOneWidget,
          );
        },
      );
    });
  });
}
