// test/fase2-gemini/integration/playlist_flow_cot_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

// Fake customizado que herda de FakeFirebaseFirestore e simula erro de escrita
class ErrorOnAddFirestore extends FakeFirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    if (collectionPath == 'playlists') {
      return _ErrorCollectionReference(super.collection(collectionPath));
    }
    return super.collection(collectionPath);
  }
}

class _ErrorCollectionReference extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final CollectionReference<Map<String, dynamic>> _delegate;
  _ErrorCollectionReference(this._delegate);

  @override
  Future<DocumentReference<Map<String, dynamic>>> add(Map<String, dynamic> data) {
    throw FirebaseException(plugin: 'firestore', message: 'Permissão negada');
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) {
    return _delegate.get(options);
  }
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  const testUid = 'test_user_789';

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(
        uid: testUid,
        email: 'dev@sintonize.com',
        displayName: 'Tester',
      ),
    );

    // Pré-popula o catálogo de músicas
    await fakeFirestore.collection('musica').add({
      'track_name': 'Bohemian Rhapsody',
      'artist_name': 'Queen',
    });
    await fakeFirestore.collection('musica').add({
      'track_name': 'Imagine',
      'artist_name': 'John Lennon',
    });
  });

  Widget createWidgetUnderTest({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) {
    return MaterialApp(
      home: CriarPlaylistScreen(
        editPlaylist: const {},
        auth: auth ?? mockAuth,
        firestore: firestore ?? fakeFirestore,
      ),
    );
  }

  testWidgets('Deve exibir indicador de carregamento antes de resolver a busca de músicas',
      (WidgetTester tester) async {
    // Renderiza sem pumpAndSettle para capturar o frame de transição
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Conclui os timers assíncronos do initState
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Deve validar nome obrigatório exibindo SnackBar e não salvando no Firestore',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Toca no botão salvar sem digitar nenhum nome
    final btnSalvar = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    await tester.tap(btnSalvar);
    await tester.pump(); // Renderiza o frame da SnackBar

    expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

    // Garante que nada foi criado na coleção
    final playlistsSnapshot = await fakeFirestore.collection('playlists').get();
    expect(playlistsSnapshot.docs.isEmpty, isTrue);
  });

  testWidgets('Deve filtrar as faixas da lista conforme digitação no campo de pesquisa',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Inicialmente ambas as músicas devem estar visíveis
    expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
    expect(find.text('Imagine - John Lennon'), findsOneWidget);

    // Filtra pelo termo 'Queen'
    final searchField = find.widgetWithText(TextField, 'Pesquisar Música ou Artista');
    await tester.enterText(searchField, 'Queen');
    await tester.pumpAndSettle();

    // Somente a música correspondente à busca deve permanecer visível
    expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
    expect(find.text('Imagine - John Lennon'), findsNothing);
  });

  testWidgets('Fluxo ponta a ponta: busca, seleciona música, salva e persiste com sucesso no Firestore',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // 1. Digita o nome da playlist
    final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
    await tester.enterText(nomeField, 'Minhas Favoritas');
    await tester.pumpAndSettle();

    // 2. Marca a primeira música
    final checkboxFirstTrack = find.descendant(
      of: find.widgetWithText(ListTile, 'Bohemian Rhapsody - Queen'),
      matching: find.byType(IconButton),
    );
    await tester.tap(checkboxFirstTrack);
    await tester.pumpAndSettle();

    // Confirma ícone marcado
    expect(find.byIcon(Icons.check_box), findsOneWidget);

    // 3. Submete o formulário
    final btnSalvar = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    await tester.tap(btnSalvar);
    await tester.pumpAndSettle();

    // 4. Validação da persistência
    final querySnapshot = await fakeFirestore.collection('playlists').get();
    expect(querySnapshot.docs.length, 1);

    final savedData = querySnapshot.docs.first.data();
    expect(savedData['nome'], equals('Minhas Favoritas'));
    expect(savedData['userId'], equals(testUid));
    expect(savedData['musicas'], contains('Bohemian Rhapsody'));
    expect(savedData['dataCriacao'], isA<Timestamp>());
  });

  testWidgets('Não deve criar playlist caso o usuário não esteja autenticado',
      (WidgetTester tester) async {
    final unauthMock = MockFirebaseAuth(signedIn: false);

    await tester.pumpWidget(createWidgetUnderTest(auth: unauthMock));
    await tester.pumpAndSettle();

    final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
    await tester.enterText(nomeField, 'Rock Clássico');

    final btnSalvar = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    await tester.tap(btnSalvar);
    await tester.pumpAndSettle();

    final querySnapshot = await fakeFirestore.collection('playlists').get();
    expect(querySnapshot.docs.isEmpty, isTrue);
  });

  testWidgets('Deve exibir SnackBar de erro caso o Firestore lance uma exceção ao salvar',
      (WidgetTester tester) async {
    final errorFirestore = ErrorOnAddFirestore();

    // Adiciona músicas na coleção 'musica' normalmente
    await errorFirestore.collection('musica').add({
      'track_name': 'Bohemian Rhapsody',
      'artist_name': 'Queen',
    });

    await tester.pumpWidget(
      createWidgetUnderTest(firestore: errorFirestore),
    );
    await tester.pumpAndSettle();

    final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
    await tester.enterText(nomeField, 'Playlist com Falha');

    final btnSalvar = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    await tester.tap(btnSalvar);
    await tester.pump(); // Desenha a SnackBar com a mensagem capturada no catch

    expect(find.textContaining('Erro ao salvar a playlist:'), findsOneWidget);
  });
}
