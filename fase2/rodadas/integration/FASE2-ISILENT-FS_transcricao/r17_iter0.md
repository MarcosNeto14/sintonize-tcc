Abaixo está um teste de integração usando flutter_test, firebase_auth_mocks e fake_cloud_firestore. Ele pré-carrega músicas no Firestore fake, abre a CriarPlaylistScreen, preenche o nome, seleciona duas músicas e verifica diretamente o documento salvo.

Há um detalhe importante no código fornecido: apesar de o usuário digitar o nome da playlist, _salvarPlaylist() grava 'Nova Playlist' fixamente em nome. Portanto, o teste abaixo valida o comportamento real do código atual, e não o nome digitado.

Escrita
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/criar_playlist_screen.dart';

void main() {
  group('Fluxo de Criação de Playlist', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() async {
      mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user123'),
      );

      fakeFirestore = FakeFirebaseFirestore();

      // Dados que a CriarPlaylistScreen consulta ao iniciar.
      await fakeFirestore.collection('musica').add({
        'track_name': 'Bohemian Rhapsody',
        'artist_name': 'Queen',
      });

      await fakeFirestore.collection('musica').add({
        'track_name': 'Imagine',
        'artist_name': 'John Lennon',
      });

      await fakeFirestore.collection('musica').add({
        'track_name': 'Billie Jean',
        'artist_name': 'Michael Jackson',
      });
    });

    testWidgets(
      'cria playlist, seleciona músicas e salva no Firestore',
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

        // Aguarda o carregamento das músicas do Firestore fake.
        await tester.pumpAndSettle();

        // Verifica que as músicas foram carregadas.
        expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
        expect(find.text('Imagine - John Lennon'), findsOneWidget);
        expect(
          find.text('Billie Jean - Michael Jackson'),
          findsOneWidget,
        );

        // Digita o nome da playlist.
        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Nome da Playlist',
          ),
          'Minha Playlist',
        );

        // Seleciona "Bohemian Rhapsody".
        final bohemianTile = find.ancestor(
          of: find.text('Bohemian Rhapsody - Queen'),
          matching: find.byType(ListTile),
        );

        await tester.tap(
          find.descendant(
            of: bohemianTile,
            matching: find.byType(IconButton),
          ),
        );

        // Seleciona "Imagine".
        final imagineTile = find.ancestor(
          of: find.text('Imagine - John Lennon'),
          matching: find.byType(ListTile),
        );

        await tester.tap(
          find.descendant(
            of: imagineTile,
            matching: find.byType(IconButton),
          ),
        );

        await tester.pump();

        // Salva a playlist.
        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        // Consulta o Firestore fake para verificar o documento criado.
        final playlists = await fakeFirestore
            .collection('playlists')
            .get();

        expect(playlists.docs.length, 1);

        final playlist = playlists.docs.first;

        expect(playlist['userId'], 'user123');

        // O código atual da tela grava "Nova Playlist", independentemente
        // do texto digitado pelo usuário.
        expect(playlist['nome'], 'Nova Playlist');

        expect(
          playlist['musicas'],
          containsAll(<String>[
            'Bohemian Rhapsody',
            'Imagine',
          ]),
        );

        expect(playlist['musicas'], hasLength(2));

        expect(playlist.data(), contains('dataCriacao'));
        expect(playlist['dataCriacao'], isNotNull);
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

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        expect(
          find.text('Nome da playlist é obrigatório'),
          findsOneWidget,
        );

        // Nenhuma playlist deve ter sido criada.
        final playlists = await fakeFirestore
            .collection('playlists')
            .get();

        expect(playlists.docs, isEmpty);
      },
    );
  });
}

Observação importante

Se a intenção do requisito é que a playlist seja salva com o nome que o usuário digitou, há um bug na implementação. Atualmente existe:

'nome': 'Nova Playlist',


O correto seria usar o valor armazenado em _playlistName:

'nome': _playlistName,


Nesse caso, a asserção do teste deve ser alterada para:

expect(playlist['nome'], 'Minha Playlist');


Assim, o teste passa a verificar exatamente o fluxo descrito: digitar o nome → selecionar músicas → salvar → conferir nome, usuário e músicas no Firestore.