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
    // Configura o usuário autenticado mockado
    mockUser = MockUser(
      isAnonymous: false,
      uid: 'user_123',
      email: 'usuario@sintonize.com',
      displayName: 'Usuário Teste',
    );
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    // Instancia o Fake Cloud Firestore e popula a coleção 'musica'
    fakeFirestore = FakeFirebaseFirestore();
    await fakeFirestore.collection('musica').add({
      'track_name': 'Bohemian Rhapsody',
      'artist_name': 'Queen',
    });
    await fakeFirestore.collection('musica').add({
      'track_name': 'Hotel California',
      'artist_name': 'Eagles',
    });
  });

  Widget createTestableWidget() {
    return MaterialApp(
      home: CriarPlaylistScreen(
        editPlaylist: const {},
        auth: mockAuth,
        firestore: fakeFirestore,
      ),
    );
  }

  testWidgets(
    'Fluxo de sucesso: preencher nome, selecionar músicas e salvar playlist no Firestore',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Verifica se as músicas carregaram
      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
      expect(find.text('Hotel California - Eagles'), findsOneWidget);

      // 1. Digita o nome da playlist
      final nomePlaylistInput = find.widgetWithText(TextField, 'Nome da Playlist');
      await tester.enterText(nomePlaylistInput, 'Rock Clássico');
      await tester.pumpAndSettle();

      // 2. Localiza diretamente o ícone desmarcado e clica nele
      final unselectedCheckbox = find.byIcon(Icons.check_box_outline_blank);
      expect(unselectedCheckbox, findsWidgets);

      await tester.tap(unselectedCheckbox.first);
      await tester.pumpAndSettle();

      // Verifica se agora há 1 checkbox marcado
      expect(find.byIcon(Icons.check_box), findsOneWidget);

      // 3. Clica no botão "Salvar Playlist"
      final salvarBtn = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.tap(salvarBtn);
      await tester.pumpAndSettle();

      // 4. Valida se o documento foi persistido no Fake Firestore
      final playlistsSnapshot = await fakeFirestore.collection('playlists').get();
      expect(playlistsSnapshot.docs.length, equals(1));

      final playlistCriada = playlistsSnapshot.docs.first.data();
      expect(playlistCriada['userId'], equals('user_123'));
      expect(playlistCriada['musicas'], isNotEmpty);
      expect(playlistCriada['dataCriacao'], isNotNull);
    },
  );

  testWidgets(
    'Validação: exibe SnackBar de erro ao tentar salvar sem preencher o nome da playlist',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestableWidget());
      await tester.pumpAndSettle();

      // Tenta submeter sem digitar nome
      final salvarBtn = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.tap(salvarBtn);
      await tester.pump();

      // Verifica exibição do SnackBar
      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

      // Garante que nada foi gravado
      final playlistsSnapshot = await fakeFirestore.collection('playlists').get();
      expect(playlistsSnapshot.docs.isEmpty, isTrue);
    },
  );
}
