import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockUser = MockUser(
      uid: 'user_test_123',
      email: 'teste@sintonize.com',
      displayName: 'Usuário Teste',
    );
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    // Pré-popula a coleção 'musica' com faixas de teste
    await fakeFirestore.collection('musica').add({
      'track_name': 'bohemian rhapsody',
      'artist_name': 'queen',
    });
    await fakeFirestore.collection('musica').add({
      'track_name': 'imagine',
      'artist_name': 'john lennon',
    });
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: CriarPlaylistScreen(
        editPlaylist: const {},
        auth: mockAuth,
        firestore: fakeFirestore,
      ),
    );
  }

  testWidgets('Deve renderizar os campos e carregar a lista de músicas',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Valida elementos estáticos do layout
    expect(find.text('Criando Playlist'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Nome da Playlist'), findsOneWidget);
    expect(
        find.widgetWithText(TextField, 'Pesquisar Música ou Artista'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Salvar Playlist'), findsOneWidget);

    // Valida as músicas formatadas pelo método _formatName
    expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
    expect(find.text('Imagine - John Lennon'), findsOneWidget);
  });

  testWidgets('Deve filtrar músicas pelo campo de busca',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final searchField =
        find.widgetWithText(TextField, 'Pesquisar Música ou Artista');

    // Filtra pelo nome da faixa
    await tester.enterText(searchField, 'bohemian');
    await tester.pumpAndSettle();

    expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
    expect(find.text('Imagine - John Lennon'), findsNothing);

    // Filtra pelo nome do artista
    await tester.enterText(searchField, 'lennon');
    await tester.pumpAndSettle();

    expect(find.text('Bohemian Rhapsody - Queen'), findsNothing);
    expect(find.text('Imagine - John Lennon'), findsOneWidget);
  });

  testWidgets('Deve alternar a seleção de uma música ao tocar no checkbox',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Inicialmente todos os checkboxes estão desmarcados
    expect(find.byIcon(Icons.check_box_outline_blank), findsNWidgets(2));
    expect(find.byIcon(Icons.check_box), findsNothing);

    // Seleciona a primeira música
    final firstCheckbox = find.byType(IconButton).at(1); // 0 é o back button
    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_box), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);

    // Desmarca a música
    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_box), findsNothing);
    expect(find.byIcon(Icons.check_box_outline_blank), findsNWidgets(2));
  });

  testWidgets('Deve exibir SnackBar de validação se tentar salvar sem nome',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

    // Garante que nada foi gravado no Firestore
    final playlistsSnapshot = await fakeFirestore.collection('playlists').get();
    expect(playlistsSnapshot.docs, isEmpty);
  });

  testWidgets('Deve salvar a playlist no Firestore com as músicas selecionadas',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
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
            ),
          ),
        ),
      ),
    );

    // Navega para a tela
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // Digita o nome da playlist
    final nameField = find.widgetWithText(TextField, 'Nome da Playlist');
    await tester.enterText(nameField, 'Minhas Favoritas');
    await tester.pumpAndSettle();

    // Marca a primeira música ('bohemian rhapsody')
    final firstCheckbox = find.byType(IconButton).at(1);
    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();

    // Clica em Salvar
    final saveButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verifica se a tela fez pop após salvar com sucesso
    expect(find.text('Criando Playlist'), findsNothing);
    expect(find.text('Abrir'), findsOneWidget);

    // Valida o documento gravado no Firestore
    final playlists = await fakeFirestore.collection('playlists').get();
    expect(playlists.docs.length, 1);

    final savedData = playlists.docs.first.data();
    expect(savedData['userId'], mockUser.uid);
    expect(savedData['nome'], 'Minhas Favoritas');
    expect(savedData['musicas'], contains('bohemian rhapsody'));
    expect(savedData['dataCriacao'], isNotNull);
  });
}

