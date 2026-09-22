import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sintonize/criar_playlist.dart';

import 'wcrash_cot_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseFirestore>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(),
])
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;

  final mockUser = MockUser(
    uid: 'user_test_123',
    email: 'dev@sintonize.com',
  );

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    // Popula o catálogo de músicas para os testes
    await fakeFirestore.collection('musica').add({
      'track_name': 'tempo perdido',
      'artist_name': 'legiao urbana',
    });
    await fakeFirestore.collection('musica').add({
      'track_name': 'bohemian rhapsody',
      'artist_name': 'queen',
    });
    await fakeFirestore.collection('musica').add({
      'track_name': 'pais e filhos',
      'artist_name': 'legiao urbana',
    });
  });

  Widget createWidgetUnderTest({
    FirebaseFirestore? customFirestore,
    MockFirebaseAuth? customAuth,
  }) {
    return MaterialApp(
      home: CriarPlaylistScreen(
        editPlaylist: const {},
        firestore: customFirestore ?? fakeFirestore,
        auth: customAuth ?? mockAuth,
      ),
    );
  }

  group('1. Renderização Básica', () {
    testWidgets('Deve renderizar os componentes principais da tela', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Criando Playlist'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Nome da Playlist'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Pesquisar Música ou Artista'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Salvar Playlist'), findsOneWidget);
    });

    testWidgets('Deve exibir CircularProgressIndicator quando a lista de músicas estiver vazia', (WidgetTester tester) async {
      final firestoreVazio = FakeFirebaseFirestore();

      await tester.pumpWidget(createWidgetUnderTest(customFirestore: firestoreVazio));
      // pump inicial sem pumpAndSettle para checar o estado vazio
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Deve renderizar e formatar as músicas carregadas do Firestore', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Checa a formatação em Title Case aplicada pela função _formatName
      expect(find.text('Tempo Perdido - Legiao Urbana'), findsOneWidget);
      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
      expect(find.text('Pais E Filhos - Legiao Urbana'), findsOneWidget);
    });
  });

  group('2. Validação de Formulário', () {
    testWidgets('Deve exibir SnackBar com erro ao tentar salvar sem preencher o nome', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.tap(salvarButton);
      await tester.pump(); // Inicia animação da SnackBar

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);
    });
  });

  group('3. Interação do Usuário', () {
    testWidgets('Deve filtrar as músicas ao digitar no campo de pesquisa', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final searchField = find.widgetWithText(TextField, 'Pesquisar Música ou Artista');

      // Filtra por artista
      await tester.enterText(searchField, 'Queen');
      await tester.pumpAndSettle();

      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
      expect(find.text('Tempo Perdido - Legiao Urbana'), findsNothing);

      // Filtra por faixa
      await tester.enterText(searchField, 'tempo');
      await tester.pumpAndSettle();

      expect(find.text('Tempo Perdido - Legiao Urbana'), findsOneWidget);
      expect(find.text('Bohemian Rhapsody - Queen'), findsNothing);
    });

    testWidgets('Deve alternar o estado de seleção da música ao clicar no checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Inicialmente todos os checkboxes devem estar vazios
      expect(find.byIcon(Icons.check_box_outline_blank), findsNWidgets(3));
      expect(find.byIcon(Icons.check_box), findsNothing);

      // Seleciona a primeira música
      final primeiroCheckbox = find.byType(IconButton).at(1); // 0 é o arrow_back
      await tester.tap(primeiroCheckbox);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_box), findsOneWidget);
      expect(find.byIcon(Icons.check_box_outline_blank), findsNWidgets(2));

      // Desmarca a música
      await tester.tap(primeiroCheckbox);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_box), findsNothing);
      expect(find.byIcon(Icons.check_box_outline_blank), findsNWidgets(3));
    });

    testWidgets('Deve acionar Navigator.pop ao tocar no botão de voltar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CriarPlaylistScreen(
                      editPlaylist: const {},
                      firestore: fakeFirestore,
                      auth: mockAuth,
                    ),
                  ),
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Criando Playlist'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Criando Playlist'), findsNothing);
      expect(find.text('Abrir'), findsOneWidget);
    });
  });

  group('4. Cenários de Sucesso', () {
    testWidgets('Deve salvar a playlist no Firestore com sucesso e fechar a tela', (WidgetTester tester) async {
      bool telaFechada = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onPopPage: (route, result) {
              telaFechada = true;
              return route.didPop(result);
            },
            pages: [
              MaterialPage(
                child: CriarPlaylistScreen(
                  editPlaylist: const {},
                  firestore: fakeFirestore,
                  auth: mockAuth,
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Preenche o nome da playlist
      final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
      await tester.enterText(nomeField, 'Minhas Favoritas');
      await tester.pumpAndSettle();

      // Seleciona a primeira música da lista
      final primeiraMusicaBotao = find.byType(IconButton).at(1);
      await tester.tap(primeiraMusicaBotao);
      await tester.pumpAndSettle();

      // Clica em Salvar
      final salvarBtn = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.tap(salvarBtn);
      await tester.pumpAndSettle();

      // Verifica se gravou no Firestore
      final playlistsSnapshot = await fakeFirestore.collection('playlists').get();
      expect(playlistsSnapshot.docs.length, 1);

      final playlistData = playlistsSnapshot.docs.first.data();
      expect(playlistData['userId'], equals('user_test_123'));
      expect(playlistData['musicas'], contains('tempo perdido'));
      expect(playlistData['dataCriacao'], isNotNull);

      // Verifica navegação de retorno
      expect(telaFechada, isTrue);
    });
  });

  group('5. Cenários de Erro', () {
    testWidgets('Deve exibir SnackBar com mensagem de erro quando falhar a gravação no Firestore', (WidgetTester tester) async {
      final mockFaultyFirestore = MockFirebaseFirestore();
      final mockCollection = MockCollectionReference();

      // Configura falha intencional na collection playlists
      when(mockFaultyFirestore.collection('musica')).thenAnswer((_) => fakeFirestore.collection('musica'));
      when(mockFaultyFirestore.collection('playlists')).thenReturn(mockCollection);
      when(mockCollection.add(any)).thenThrow(Exception('Falha de permissão no Firestore'));

      await tester.pumpWidget(createWidgetUnderTest(customFirestore: mockFaultyFirestore));
      await tester.pumpAndSettle();

      // Preenche o nome da playlist
      final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
      await tester.enterText(nomeField, 'Rock Clássico');
      await tester.pumpAndSettle();

      // Tenta salvar
      final salvarBtn = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.tap(salvarBtn);
      await tester.pump(); // Renderiza a SnackBar

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Erro ao salvar a playlist: Exception: Falha de permissão no Firestore'), findsOneWidget);
    });
  });
}
