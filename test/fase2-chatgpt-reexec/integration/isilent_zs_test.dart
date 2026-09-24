import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  group('CriarPlaylistScreen', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;
    late MockUser user;

    setUp(() async {
      firestore = FakeFirebaseFirestore();

      user = MockUser(
        uid: 'usuario-teste-123',
        email: 'teste@sintonize.com',
      );

      auth = MockFirebaseAuth(
        signedIn: true,
        mockUser: user,
      );

      // Popula a coleção de músicas utilizada pela tela.
      await firestore.collection('musica').add({
        'track_name': 'imagine',
        'artist_name': 'john lennon',
      });

      await firestore.collection('musica').add({
        'track_name': 'hey jude',
        'artist_name': 'the beatles',
      });
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: CriarPlaylistScreen(
          editPlaylist: const {},
          auth: auth,
          firestore: firestore,
        ),
      );
    }

    testWidgets(
      'deve criar uma playlist ao digitar nome, selecionar música e salvar',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        // Aguarda o carregamento assíncrono da coleção "musica".
        await tester.pumpAndSettle();

        expect(find.text('Imagine - John Lennon'), findsOneWidget);
        expect(find.text('Hey Jude - The Beatles'), findsOneWidget);

        // 1. Digita o nome da playlist.
        final nomePlaylistField = find.byType(TextField).first;

        await tester.enterText(
          nomePlaylistField,
          'Minha Playlist',
        );

        expect(find.text('Minha Playlist'), findsOneWidget);

        // 2. Seleciona "Imagine".
        final imagineTile = find.ancestor(
          of: find.text('Imagine - John Lennon'),
          matching: find.byType(ListTile),
        );

        final imagineButton = find.descendant(
          of: imagineTile,
          matching: find.byType(IconButton),
        );

        await tester.tap(imagineButton);
        await tester.pump();

        // O botão deve ter mudado para o estado selecionado.
        final selectedIcon = find.descendant(
          of: imagineTile,
          matching: find.byIcon(Icons.check_box),
        );

        expect(selectedIcon, findsOneWidget);

        // 3. Salva a playlist.
        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        // A tela deve ter sido removida da navegação.
        expect(find.byType(CriarPlaylistScreen), findsNothing);

        // 4. Verifica o documento criado no Firestore fake.
        final playlists = await firestore.collection('playlists').get();

        expect(playlists.docs, hasLength(1));

        final playlist = playlists.docs.single.data();

        expect(playlist['userId'], 'usuario-teste-123');

        // O código atual da tela grava "Nova Playlist", e não
        // o conteúdo digitado no campo.
        expect(playlist['nome'], 'Nova Playlist');

        expect(
          playlist['musicas'],
          contains('imagine'),
        );

        expect(
          playlist['musicas'],
          hasLength(1),
        );

        expect(playlist['dataCriacao'], isNotNull);
      },
    );

    testWidgets(
      'deve exibir SnackBar quando o nome da playlist estiver vazio',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.pumpAndSettle();

        // Não digita nenhum nome.
        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        expect(
          find.text('Nome da playlist é obrigatório'),
          findsOneWidget,
        );

        // Nenhuma playlist deve ter sido criada.
        final playlists = await firestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);
      },
    );
  });
}
