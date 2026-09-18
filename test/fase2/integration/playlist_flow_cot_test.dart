import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  group('CriarPlaylistScreen', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;

    Future<void> seedMusicas() async {
      await fakeFirestore.collection('musica').add({
        'track_name': 'imagine',
        'artist_name': 'john lennon',
      });

      await fakeFirestore.collection('musica').add({
        'track_name': 'yellow',
        'artist_name': 'coldplay',
      });
    }

    Widget buildScreen() {
      return MaterialApp(
        home: CriarPlaylistScreen(
          auth: mockAuth,
          firestore: fakeFirestore,
          editPlaylist: {},
        ),
      );
    }

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
    });

    testWidgets(
      'fluxo de sucesso: busca músicas, seleciona músicas, salva e persiste corretamente',
      (WidgetTester tester) async {
        await seedMusicas();

        final user = MockUser(
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
          signedIn: true,
        );

        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        expect(find.text('Imagine - John Lennon'), findsOneWidget);
        expect(find.text('Yellow - Coldplay'), findsOneWidget);

        final nomePlaylist =
            find.widgetWithText(TextField, 'Nome da Playlist');

        expect(nomePlaylist, findsOneWidget);

        await tester.enterText(nomePlaylist, 'Minhas Favoritas');

        expect(find.text('Minhas Favoritas'), findsOneWidget);

        final imagineTile = find.ancestor(
          of: find.text('Imagine - John Lennon'),
          matching: find.byType(ListTile),
        );

        expect(imagineTile, findsOneWidget);

        final imagineCheckbox = find.descendant(
          of: imagineTile,
          matching: find.byIcon(Icons.check_box_outline_blank),
        );

        expect(imagineCheckbox, findsOneWidget);

        await tester.tap(imagineCheckbox);
        await tester.pump();

        expect(
          find.descendant(
            of: imagineTile,
            matching: find.byIcon(Icons.check_box),
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final playlists =
            await fakeFirestore.collection('playlists').get();

        expect(playlists.docs, hasLength(1));

        final playlist = playlists.docs.single.data();

        expect(playlist['userId'], 'usuario-123');
        expect(playlist['nome'], 'Minhas Favoritas');
        expect(playlist['musicas'], ['imagine']);
        expect(playlist['dataCriacao'], isA<Timestamp>());

        expect(find.text('Criando Playlist'), findsNothing);
      },
    );

    testWidgets(
      'mostra indicador de carregamento antes de as músicas serem carregadas',
      (WidgetTester tester) async {
        await seedMusicas();

        await tester.pumpWidget(buildScreen());

        // O initState iniciou _fetchMusicas(), mas ainda não aguardamos
        // a conclusão da operação assíncrona.
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        expect(find.text('Imagine - John Lennon'), findsOneWidget);
        expect(find.text('Yellow - Coldplay'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'nome vazio mostra SnackBar e não cria playlist',
      (WidgetTester tester) async {
        await seedMusicas();

        final user = MockUser(
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
          signedIn: true,
        );

        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        expect(
          find.text('Nome da playlist é obrigatório'),
          findsOneWidget,
        );

        final playlists =
            await fakeFirestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);
      },
    );

    testWidgets(
      'usuário não autenticado não cria playlist',
      (WidgetTester tester) async {
        await seedMusicas();

        mockAuth = MockFirebaseAuth(
          signedIn: false,
        );

        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Nome da Playlist'),
          'Playlist Sem Login',
        );

        final imagineTile = find.ancestor(
          of: find.text('Imagine - John Lennon'),
          matching: find.byType(ListTile),
        );

        await tester.tap(
          find.descendant(
            of: imagineTile,
            matching: find.byIcon(Icons.check_box_outline_blank),
          ),
        );

        await tester.pump();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final playlists =
            await fakeFirestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);

        // Como _salvarPlaylist() simplesmente retorna quando currentUser
        // é null, a tela continua montada.
        expect(find.text('Criando Playlist'), findsOneWidget);
      },
    );

    testWidgets(
      'seleciona e desseleciona uma música corretamente',
      (WidgetTester tester) async {
        await seedMusicas();

        final user = MockUser(
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
          signedIn: true,
        );

        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        final imagineTile = find.ancestor(
          of: find.text('Imagine - John Lennon'),
          matching: find.byType(ListTile),
        );

        final checkbox = find.descendant(
          of: imagineTile,
          matching: find.byIcon(Icons.check_box_outline_blank),
        );

        await tester.tap(checkbox);
        await tester.pump();

        expect(
          find.descendant(
            of: imagineTile,
            matching: find.byIcon(Icons.check_box),
          ),
          findsOneWidget,
        );

        await tester.tap(
          find.descendant(
            of: imagineTile,
            matching: find.byIcon(Icons.check_box),
          ),
        );
        await tester.pump();

        expect(
          find.descendant(
            of: imagineTile,
            matching: find.byIcon(Icons.check_box_outline_blank),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
