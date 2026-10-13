import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  group('CriarPlaylistScreen - fluxo de integração', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;

    Future<void> adicionarMusicasDeTeste() async {
      await firestore.collection('musica').add({
        'track_name': 'primeira musica',
        'artist_name': 'primeiro artista',
      });

      await firestore.collection('musica').add({
        'track_name': 'segunda musica',
        'artist_name': 'segundo artista',
      });

      await firestore.collection('musica').add({
        'track_name': 'terceira musica',
        'artist_name': 'terceiro artista',
      });
    }

    Widget buildApp() {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
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
              );
            },
          ),
        ),
      );
    }

    setUp(() {
      firestore = FakeFirebaseFirestore();

      auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
          uid: 'usuario-teste-123',
          email: 'teste@sintonize.com',
        ),
      );
    });

    testWidgets(
      'fluxo de sucesso: digita nome, seleciona músicas, salva e '
      'persiste os dados no Firestore',
      (tester) async {
        await adicionarMusicasDeTeste();

        await tester.pumpWidget(buildApp());

        await tester.tap(find.text('Abrir Criar Playlist'));
        await tester.pumpAndSettle();

        expect(find.text('Nome da Playlist'), findsOneWidget);
        expect(find.text('Pesquisar Música ou Artista'), findsOneWidget);

        final nomeField = find.byType(TextField).first;

        await tester.enterText(
          nomeField,
          'Minha Playlist',
        );

        expect(find.text('Minha Playlist'), findsOneWidget);

        expect(
          find.text('Primeira Musica - Primeiro Artista'),
          findsOneWidget,
        );
        expect(
          find.text('Segunda Musica - Segundo Artista'),
          findsOneWidget,
        );
        expect(
          find.text('Terceira Musica - Terceiro Artista'),
          findsOneWidget,
        );

        // Seleciona a primeira música.
        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank).at(0),
        );
        await tester.pump();

        // Seleciona a segunda música.
        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank).at(0),
        );
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsNWidgets(2),
        );

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        // O salvamento bem-sucedido chama Navigator.pop().
        expect(
          find.text('Abrir Criar Playlist'),
          findsOneWidget,
        );

        final playlistsSnapshot =
            await firestore.collection('playlists').get();

        expect(playlistsSnapshot.docs, hasLength(1));

        final data = playlistsSnapshot.docs.single.data();

        expect(data.keys, containsAll([
          'userId',
          'nome',
          'musicas',
          'dataCriacao',
        ]));

        expect(data.keys, hasLength(4));

        expect(
          data['userId'],
          equals('usuario-teste-123'),
        );

        // Importante: a implementação atual não usa o nome digitado.
        expect(
          data['nome'],
          equals('Nova Playlist'),
        );

        expect(
          data['musicas'],
          equals([
            'primeira musica',
            'segunda musica',
          ]),
        );

        expect(
          data['dataCriacao'],
          isA<Timestamp>(),
        );
      },
    );

    testWidgets(
      'nome de playlist vazio exibe SnackBar e não salva no Firestore',
      (tester) async {
        await adicionarMusicasDeTeste();

        await tester.pumpWidget(buildApp());

        await tester.tap(find.text('Abrir Criar Playlist'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        expect(
          find.text('Nome da playlist é obrigatório'),
          findsOneWidget,
        );

        final playlistsSnapshot =
            await firestore.collection('playlists').get();

        expect(
          playlistsSnapshot.docs,
          isEmpty,
        );

        // A tela continua aberta porque o código não chama Navigator.pop().
        expect(
          find.text('Salvar Playlist'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'usuário não autenticado não salva a playlist nem fecha a tela',
      (tester) async {
        auth = MockFirebaseAuth(
          signedIn: false,
        );

        await adicionarMusicasDeTeste();

        await tester.pumpWidget(buildApp());

        await tester.tap(find.text('Abrir Criar Playlist'));
        await tester.pumpAndSettle();

        final nomeField = find.byType(TextField).first;

        await tester.enterText(
          nomeField,
          'Playlist Sem Usuario',
        );

        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank).first,
        );
        await tester.pump();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final playlistsSnapshot =
            await firestore.collection('playlists').get();

        expect(
          playlistsSnapshot.docs,
          isEmpty,
        );

        // Como currentUser é null, _salvarPlaylist() não chama pop().
        expect(
          find.text('Salvar Playlist'),
          findsOneWidget,
        );

        expect(
          find.text('Playlist Sem Usuario'),
          findsOneWidget,
        );

        expect(
          find.text('Primeira Musica - Primeiro Artista'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'verifica exatamente os dados persistidos na coleção playlists',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'rock nacional',
          'artist_name': 'banda exemplo',
        });

        await firestore.collection('musica').add({
          'track_name': 'pop brasileiro',
          'artist_name': 'artista exemplo',
        });

        await tester.pumpWidget(buildApp());

        await tester.tap(find.text('Abrir Criar Playlist'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField).first,
          'Playlist de Teste',
        );

        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank).first,
        );
        await tester.pump();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final snapshot =
            await firestore.collection('playlists').get();

        expect(snapshot.docs, hasLength(1));

        final document = snapshot.docs.single;

        expect(
          document.data().keys.toSet(),
          equals({
            'userId',
            'nome',
            'musicas',
            'dataCriacao',
          }),
        );

        expect(
          document['userId'],
          equals('usuario-teste-123'),
        );

        expect(
          document['nome'],
          equals('Nova Playlist'),
        );

        expect(
          document['musicas'],
          equals([
            'rock nacional',
          ]),
        );

        expect(
          document['dataCriacao'],
          isA<Timestamp>(),
        );

        // Garante que o nome digitado não foi usado como nome persistido.
        expect(
          document['nome'],
          isNot(equals('Playlist de Teste')),
        );
      },
    );
  });
}
