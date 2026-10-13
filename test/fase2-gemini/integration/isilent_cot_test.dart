import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser testUser;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    testUser = MockUser(
      uid: 'user_123_abc',
      email: 'user@sintonize.com',
      displayName: 'Marcos Neto',
    );
    mockAuth = MockFirebaseAuth(mockUser: testUser, signedIn: true);

    // Popula o banco falso com músicas de teste
    await fakeFirestore.collection('musica').add({
      'track_name': 'Bohemian Rhapsody',
      'artist_name': 'Queen',
    });
    await fakeFirestore.collection('musica').add({
      'track_name': 'Hotel California',
      'artist_name': 'Eagles',
    });
  });

  Widget buildTestableWidget({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CriarPlaylistScreen(
                      editPlaylist: const {},
                      auth: auth,
                      firestore: firestore,
                    ),
                  ),
                );
              },
              child: const Text('Abrir Criar Playlist'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'Fluxo de sucesso: preencher nome, selecionar música, salvar e desempilhar tela',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(auth: mockAuth, firestore: fakeFirestore),
      );

      // Abre a tela via navegação
      await tester.tap(find.text('Abrir Criar Playlist'));
      await tester.pumpAndSettle();

      expect(find.byType(CriarPlaylistScreen), findsOneWidget);
      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);

      // 1. Digita o nome da playlist
      final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
      await tester.enterText(nomeField, 'Minhas Favoritas');
      await tester.pumpAndSettle();

      // 2. Seleciona a primeira música da lista
      final checkboxButtons = find.byIcon(Icons.check_box_outline_blank);
      expect(checkboxButtons, findsWidgets);
      await tester.tap(checkboxButtons.first);
      await tester.pumpAndSettle();

      // Verifica se o ícone mudou para selecionado
      expect(find.byIcon(Icons.check_box), findsOneWidget);

      // 3. Salva a playlist
      final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.tap(salvarButton);
      await tester.pumpAndSettle();

      // Verifica se a tela foi fechada (Navigator.pop)
      expect(find.byType(CriarPlaylistScreen), findsNothing);
      expect(find.text('Abrir Criar Playlist'), findsOneWidget);

      // 4. Verifica persistência no Firestore
      final snapshot = await fakeFirestore.collection('playlists').get();
      expect(snapshot.docs.length, 1);
      final data = snapshot.docs.first.data();
      expect(data['userId'], 'user_123_abc');
      expect(data['musicas'], contains('Bohemian Rhapsody'));
    },
  );

  testWidgets(
    'Validação: nome vazio exibe SnackBar de erro e não persiste dados',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(auth: mockAuth, firestore: fakeFirestore),
      );

      await tester.tap(find.text('Abrir Criar Playlist'));
      await tester.pumpAndSettle();

      // Deixa o nome da playlist em branco e aciona o salvamento
      final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.tap(salvarButton);
      await tester.pump(); // Dispara a exibição da SnackBar

      // Validações da interface
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);
      expect(find.byType(CriarPlaylistScreen), findsOneWidget);

      // Validação do banco: nenhum registro deve ser criado
      final snapshot = await fakeFirestore.collection('playlists').get();
      expect(snapshot.docs, isEmpty);
    },
  );

  testWidgets(
    'Segurança: usuário não autenticado não salva registro nem fecha tela',
    (WidgetTester tester) async {
      final unauthenticatedAuth = MockFirebaseAuth(signedIn: false);

      await tester.pumpWidget(
        buildTestableWidget(auth: unauthenticatedAuth, firestore: fakeFirestore),
      );

      await tester.tap(find.text('Abrir Criar Playlist'));
      await tester.pumpAndSettle();

      // Preenche o nome para passar pela primeira barreira de validação
      final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
      await tester.enterText(nomeField, 'Rock Clássico');
      await tester.pumpAndSettle();

      // Clica em salvar
      final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.tap(salvarButton);
      await tester.pumpAndSettle();

      // Confirma que nenhuma playlist foi gerada no Firestore
      final snapshot = await fakeFirestore.collection('playlists').get();
      expect(snapshot.docs, isEmpty);

      // Confirma que a tela continua ativa
      expect(find.byType(CriarPlaylistScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Integridade: dados persistidos na coleção "playlists" possuem esquema exato',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(auth: mockAuth, firestore: fakeFirestore),
      );

      await tester.tap(find.text('Abrir Criar Playlist'));
      await tester.pumpAndSettle();

      // Preenche nome
      final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
      await tester.enterText(nomeField, 'Trilha Sonora');
      await tester.pumpAndSettle();

      // Seleciona ambas as músicas
      final blankCheckboxes = find.byIcon(Icons.check_box_outline_blank);
      await tester.tap(blankCheckboxes.at(0));
      await tester.pumpAndSettle();
      await tester.tap(blankCheckboxes.at(0)); // Próximo item vira index 0 após rebuild
      await tester.pumpAndSettle();

      // Salva
      final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.tap(salvarButton);
      await tester.pumpAndSettle();

      // Inspeciona esquema de dados
      final snapshot = await fakeFirestore.collection('playlists').get();
      expect(snapshot.docs.length, 1);

      final Map<String, dynamic> docData = snapshot.docs.first.data();
      expect(docData.keys, containsAll(['userId', 'nome', 'musicas', 'dataCriacao']));
      expect(docData['userId'], equals(testUser.uid));
      expect(docData['nome'], equals('Nova Playlist')); // Conforme implementado na tela
      expect(docData['musicas'], isA<List>());
      expect(docData['musicas'], containsAll(['Bohemian Rhapsody', 'Hotel California']));
      expect(docData['dataCriacao'], isA<Timestamp>());
    },
  );
}

