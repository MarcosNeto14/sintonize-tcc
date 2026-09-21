import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'test_user_123', email: 'test@sintonize.com'),
    );

    // Popula o Firestore falso com dados iniciais para a coleção 'musica'
    await firestore.collection('musica').add({
      'track_name': 'bohemian rhapsody',
      'artist_name': 'queen',
    });
    await firestore.collection('musica').add({
      'track_name': 'hotel california',
      'artist_name': 'eagles',
    });
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: CriarPlaylistScreen(
        editPlaylist: const {},
        auth: auth,
        firestore: firestore,
      ),
    );
  }

  testWidgets('Deve renderizar os campos básicos e buscar as músicas com sucesso',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());

    // Processa a requisição assíncrona do initState (_fetchMusicas)
    await tester.pumpAndSettle();

    expect(find.text('Criando Playlist'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Nome da Playlist'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Pesquisar Música ou Artista'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Salvar Playlist'), findsOneWidget);

    // Verifica se os itens foram formatados e renderizados na lista
    expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
    expect(find.text('Hotel California - Eagles'), findsOneWidget);
  });

  testWidgets('Deve exibir SnackBar de erro ao tentar salvar sem preencher o nome',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    final salvarBtn = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    await tester.tap(salvarBtn);
    await tester.pump(); // Atualiza a UI para iniciar a exibição da SnackBar

    expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);
  });

  testWidgets('Deve filtrar a lista de músicas ao digitar no campo de busca',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    final searchField = find.widgetWithText(TextField, 'Pesquisar Música ou Artista');

    // Filtra pelo artista 'Queen'
    await tester.enterText(searchField, 'queen');
    await tester.pumpAndSettle();

    expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
    expect(find.text('Hotel California - Eagles'), findsNothing);

    // Limpa a busca
    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();

    expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
    expect(find.text('Hotel California - Eagles'), findsOneWidget);
  });

  testWidgets('Deve alternar o ícone de seleção ao clicar no checkbox de uma música',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Encontra o botão de seleção do primeiro item
    final checkboxIconInitial = find.widgetWithIcon(IconButton, Icons.check_box_outline_blank).first;
    expect(checkboxIconInitial, findsOneWidget);

    // Clica para selecionar
    await tester.tap(checkboxIconInitial);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_box), findsOneWidget);

    // Clica novamente para desmarcar
    await tester.tap(find.widgetWithIcon(IconButton, Icons.check_box));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_box), findsNothing);
    expect(find.byIcon(Icons.check_box_outline_blank), findsNWidgets(2));
  });

  testWidgets('Deve salvar a playlist no Firestore quando o formulário for válido',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Preenche o nome da playlist
    final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
    await tester.enterText(nomeField, 'Minhas Favoritas');
    await tester.pumpAndSettle();

    // Seleciona a primeira música da lista
    final checkboxBtn = find.widgetWithIcon(IconButton, Icons.check_box_outline_blank).first;
    await tester.tap(checkboxBtn);
    await tester.pumpAndSettle();

    // Clica em salvar
    final salvarBtn = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    await tester.tap(salvarBtn);
    await tester.pumpAndSettle();

    // Valida se o documento foi persistido no FakeFirebaseFirestore
    final snapshot = await firestore.collection('playlists').get();
    expect(snapshot.docs.length, 1);

    final playlistData = snapshot.docs.first.data();
    expect(playlistData['userId'], 'test_user_123');
    expect(playlistData['musicas'], contains('bohemian rhapsody'));
  });
}
