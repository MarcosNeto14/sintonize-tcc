import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/criar_playlist_screen.dart';

void main() {
  group('Fluxo de criação de playlist', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() async {
      mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user123'),
      );

      fakeFirestore = FakeFirebaseFirestore();

      // Dados que a CriarPlaylistScreen busca da coleção "musica".
      await fakeFirestore.collection('musica').add({
        'track_name': 'Imagine',
        'artist_name': 'John Lennon',
      });

      await fakeFirestore.collection('musica').add({
        'track_name': 'Billie Jean',
        'artist_name': 'Michael Jackson',
      });

      await fakeFirestore.collection('musica').add({
        'track_name': 'Bohemian Rhapsody',
        'artist_name': 'Queen',
      });
    });

    testWidgets(
      'cria playlist com as músicas selecionadas e salva no Firestore',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CriarPlaylistScreen(
              editPlaylist: const {},
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        );

        // Aguarda o carregamento da coleção "musica".
        await tester.pumpAndSettle();

        // Preenche o nome da playlist.
        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Nome da Playlist',
          ),
          'Minha Playlist',
        );

        // Seleciona "Imagine".
        final imagineTile = find.text('Imagine - John Lennon');
        expect(imagineTile, findsOneWidget);

        final imagineListTile = find.ancestor(
          of: imagineTile,
          matching: find.byType(ListTile),
        );

        await tester.tap(
          find.descendant(
            of: imagineListTile,
            matching: find.byType(IconButton),
          ),
        );

        // Seleciona "Billie Jean".
        final billieTile = find.text('Billie Jean - Michael Jackson');
        expect(billieTile, findsOneWidget);

        final billieListTile = find.ancestor(
          of: billieTile,
          matching: find.byType(ListTile),
        );

        await tester.tap(
          find.descendant(
            of: billieListTile,
            matching: find.byType(IconButton),
          ),
        );

        // Salva a playlist.
        await tester.tap(find.text('Salvar Playlist'));

        // Como o código chama Navigator.pop(), a tela é fechada.
        await tester.pumpAndSettle();

        // Verifica o documento criado no Firestore fake.
        final playlists =
            await fakeFirestore.collection('playlists').get();

        expect(playlists.docs.length, 1);

        final playlist = playlists.docs.first.data();

        expect(playlist['userId'], 'user123');

        // O código atual da tela grava "Nova Playlist",
        // independentemente do texto digitado.
        expect(playlist['nome'], 'Nova Playlist');

        expect(
          playlist['musicas'],
          containsAll(<String>[
            'Imagine',
            'Billie Jean',
          ]),
        );

        expect(
          (playlist['musicas'] as List).length,
          2,
        );

        expect(
          playlist['dataCriacao'],
          isA<Timestamp>(),
        );
      },
    );

    testWidgets(
      'exibe erro quando tenta salvar sem informar o nome',
      (tester) async {
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

        // Não informa o nome e tenta salvar.
        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        expect(
          find.text('Nome da playlist é obrigatório'),
          findsOneWidget,
        );

        // Nenhuma playlist deve ter sido criada.
        final playlists =
            await fakeFirestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);
      },
    );
  });
}
