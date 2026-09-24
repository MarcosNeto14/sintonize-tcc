import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sintonize/criar_playlist.dart';

// Mocks manuais sem necessidade de code-generation via build_runner
class MockFirestoreInstance extends Mock implements FirebaseFirestore {}

class MockCollectionRef extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// Fake para simular falha no salvamento sem problemas de Null Safety do Mockito
class FakeFailingPlaylistCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  @override
  Future<DocumentReference<Map<String, dynamic>>> add(
      Map<String, dynamic> data) async {
    throw FirebaseException(plugin: 'firestore', message: 'Permissão negada');
  }
}

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(
        uid: 'user_test_123',
        email: 'user@test.com',
      ),
    );
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget buildTestableWidget({
    MockFirebaseAuth? auth,
    FirebaseFirestore? firestore,
    NavigatorObserver? navigatorObserver,
  }) {
    return MaterialApp(
      navigatorObservers:
          navigatorObserver != null ? [navigatorObserver] : const [],
      home: CriarPlaylistScreen(
        editPlaylist: const {},
        auth: auth ?? mockAuth,
        firestore: firestore ?? fakeFirestore,
      ),
    );
  }

  group('Renderização Básica', () {
    testWidgets(
      'Deve exibir CircularProgressIndicator enquanto o dataset de músicas estiver vazio',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

        expect(find.text('Criando Playlist'), findsOneWidget);
        expect(find.text('Nome da Playlist'), findsOneWidget);
        expect(find.text('Pesquisar Música ou Artista'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'Deve exibir lista de músicas formatadas após carregar do Firestore',
      (tester) async {
        await fakeFirestore.collection('musica').add({
          'track_name': 'bohemian rhapsody',
          'artist_name': 'queen',
        });

        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
        expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
      },
    );
  });

  group('Interação do Usuário', () {
    testWidgets('Deve permitir digitar o nome da playlist', (tester) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
      await tester.enterText(nomeField, 'Minhas Favoritas');
      await tester.pump();

      expect(find.text('Minhas Favoritas'), findsOneWidget);
    });

    testWidgets('Deve filtrar músicas por nome e por artista', (tester) async {
      await fakeFirestore.collection('musica').add({
        'track_name': 'yellow',
        'artist_name': 'coldplay',
      });
      await fakeFirestore.collection('musica').add({
        'track_name': 'toxicity',
        'artist_name': 'system of a down',
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      expect(find.text('Yellow - Coldplay'), findsOneWidget);
      expect(find.text('Toxicity - System Of A Down'), findsOneWidget);

      final searchField =
          find.widgetWithText(TextField, 'Pesquisar Música ou Artista');

      // Filtrando pelo artista
      await tester.enterText(searchField, 'coldplay');
      await tester.pumpAndSettle();

      expect(find.text('Yellow - Coldplay'), findsOneWidget);
      expect(find.text('Toxicity - System Of A Down'), findsNothing);

      // Filtrando pelo nome da música
      await tester.enterText(searchField, 'toxic');
      await tester.pumpAndSettle();

      expect(find.text('Yellow - Coldplay'), findsNothing);
      expect(find.text('Toxicity - System Of A Down'), findsOneWidget);
    });

    testWidgets('Deve marcar e desmarcar uma música da seleção', (tester) async {
      await fakeFirestore.collection('musica').add({
        'track_name': 'imagine',
        'artist_name': 'john lennon',
      });

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      final checkboxButton = find.byType(IconButton).last;

      // Inicialmente não selecionado
      expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
      expect(find.byIcon(Icons.check_box), findsNothing);

      // Clicar para marcar
      await tester.tap(checkboxButton);
      await tester.pump();

      expect(find.byIcon(Icons.check_box), findsOneWidget);
      expect(find.byIcon(Icons.check_box_outline_blank), findsNothing);

      // Clicar novamente para desmarcar
      await tester.tap(checkboxButton);
      await tester.pump();

      expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
      expect(find.byIcon(Icons.check_box), findsNothing);
    });
  });

  group('Cenários de Sucesso', () {
    testWidgets(
      'Deve salvar a playlist no Firestore e fechar a tela ao preencher dados corretamente',
      (tester) async {
        await fakeFirestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
        await tester.enterText(nomeField, 'Rock Clássico');

        final checkboxButton = find.byType(IconButton).last;
        await tester.tap(checkboxButton);
        await tester.pump();

        final salvarButton =
            find.widgetWithText(ElevatedButton, 'Salvar Playlist');
        await tester.tap(salvarButton);
        await tester.pumpAndSettle();

        final playlistsSnapshot =
            await fakeFirestore.collection('playlists').get();
        expect(playlistsSnapshot.docs.length, 1);

        final dados = playlistsSnapshot.docs.first.data();
        expect(dados['nome'], 'Rock Clássico');
        expect(dados['userId'], 'user_test_123');
        expect(dados['musicas'], ['imagine']);
        expect(dados['dataCriacao'], isA<Timestamp>());
      },
    );
  });

  group('Cenários de Erro e Validação', () {
    testWidgets(
      'Deve exibir SnackBar de erro ao tentar salvar sem preencher o nome da playlist',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        final salvarButton =
            find.widgetWithText(ElevatedButton, 'Salvar Playlist');
        await tester.tap(salvarButton);
        await tester.pump();

        expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

        final playlistsSnapshot =
            await fakeFirestore.collection('playlists').get();
        expect(playlistsSnapshot.docs.isEmpty, isTrue);
      },
    );

    testWidgets(
      'Não deve salvar playlist caso o usuário não esteja autenticado',
      (tester) async {
        final authDeslogado = MockFirebaseAuth(signedIn: false);

        await tester.pumpWidget(buildTestableWidget(auth: authDeslogado));
        await tester.pumpAndSettle();

        final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
        await tester.enterText(nomeField, 'Playlist Deslogada');
        await tester.pump();

        final salvarButton =
            find.widgetWithText(ElevatedButton, 'Salvar Playlist');
        await tester.tap(salvarButton);
        await tester.pumpAndSettle();

        final playlistsSnapshot =
            await fakeFirestore.collection('playlists').get();
        expect(playlistsSnapshot.docs.isEmpty, isTrue);
      },
    );

    testWidgets(
      'Deve lidar com erro na busca de músicas sem travar a interface',
      (tester) async {
        final mockFirestore = MockFirestoreInstance();
        final mockCollection = MockCollectionRef();

        when(mockFirestore.collection('musica')).thenReturn(mockCollection);
        when(mockCollection.get()).thenThrow(
          FirebaseException(plugin: 'firestore', message: 'Erro de rede'),
        );

        await tester.pumpWidget(buildTestableWidget(firestore: mockFirestore));
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Criando Playlist'), findsOneWidget);
      },
    );

    testWidgets(
      'Deve exibir SnackBar de erro quando falhar ao salvar no Firestore',
      (tester) async {
        final mockFirestore = MockFirestoreInstance();
        final mockMusicaCollection = MockCollectionRef();

        // Carregamento inicial de músicas sem falhar
        when(mockFirestore.collection('musica')).thenReturn(mockMusicaCollection);
        when(mockMusicaCollection.get()).thenAnswer(
          (_) async => FakeFirebaseFirestore().collection('musica').get(),
        );

        // Retorna a coleção fake configurada para lançar exceção no add()
        when(mockFirestore.collection('playlists'))
            .thenReturn(FakeFailingPlaylistCollection());

        await tester.pumpWidget(buildTestableWidget(firestore: mockFirestore));
        await tester.pumpAndSettle();

        final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
        await tester.enterText(nomeField, 'Playlist com Falha');
        await tester.pump();

        final salvarButton =
            find.widgetWithText(ElevatedButton, 'Salvar Playlist');
        await tester.tap(salvarButton);
        await tester.pump();

        expect(
          find.textContaining('Erro ao salvar a playlist:'),
          findsOneWidget,
        );
      },
    );
  });
}

