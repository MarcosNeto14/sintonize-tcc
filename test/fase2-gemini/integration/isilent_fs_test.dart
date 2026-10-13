import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Substitua pelo import real do seu projeto:
// import 'package:sintonize_tcc/...';
// OU mantenha a declaração da tela abaixo caso esteja isolando o componente:

void main() {
  group('Fluxo de Criar Playlist - CriarPlaylistScreen', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;
    const testUserId = 'user_sintonize_123';

    setUp(() async {
      mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: testUserId, email: 'usuario@sintonize.com'),
      );
      fakeFirestore = FakeFirebaseFirestore();

      // Popula dados iniciais para a listagem
      await fakeFirestore.collection('musica').add({
        'track_name': 'Bohemian Rhapsody',
        'artist_name': 'Queen',
      });
      await fakeFirestore.collection('musica').add({
        'track_name': 'Hotel California',
        'artist_name': 'Eagles',
      });
    });

    testWidgets(
      'deve preencher o nome, selecionar músicas e salvar a playlist no Firestore',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CriarPlaylistScreen(
              editPlaylist: const {},
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verifica renderização dos itens vindos do mock
        expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
        expect(find.text('Hotel California - Eagles'), findsOneWidget);

        // Digita o nome da playlist
        final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
        await tester.enterText(nomeField, 'Minhas Favoritas');
        await tester.pump();

        // Seleciona a primeira música
        final iconButtons = find.byType(IconButton);
        await tester.tap(iconButtons.first);
        await tester.pump();

        // Salva a playlist
        final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
        await tester.tap(salvarButton);
        await tester.pumpAndSettle();

        // Verifica persistência no Firestore
        final playlistsSnapshot = await fakeFirestore.collection('playlists').get();
        expect(playlistsSnapshot.docs.length, 1);

        final playlistCriada = playlistsSnapshot.docs.first.data();
        expect(playlistCriada['userId'], testUserId);
        expect(playlistCriada['musicas'], contains('Bohemian Rhapsody'));
        expect(playlistCriada['musicas'], isNot(contains('Hotel California')));
        expect(playlistCriada['dataCriacao'], isNotNull);
      },
    );

    testWidgets(
      'deve exibir SnackBar de erro caso o nome da playlist não seja informado',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CriarPlaylistScreen(
              editPlaylist: const {},
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tenta submeter sem nome
        final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
        await tester.tap(salvarButton);
        await tester.pump();

        expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

        final playlistsSnapshot = await fakeFirestore.collection('playlists').get();
        expect(playlistsSnapshot.docs.isEmpty, isTrue);
      },
    );
  });
}

