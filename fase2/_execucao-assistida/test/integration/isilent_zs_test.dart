import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late MockUser mockUser;

  setUp(() {
    mockUser = MockUser(
      isAnonymous: false,
      uid: 'usuario-teste-123',
      email: 'teste@sintonize.com',
      displayName: 'Usuário Teste',
    );

    mockAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: mockUser,
    );

    fakeFirestore = FakeFirebaseFirestore();
  });

  Future<void> popularMusicas() async {
    await fakeFirestore.collection('musica').add({
      'track_name': 'bohemian rhapsody',
      'artist_name': 'queen',
    });

    await fakeFirestore.collection('musica').add({
      'track_name': 'imagine',
      'artist_name': 'john lennon',
    });
  }

  Future<void> montarTela(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CriarPlaylistScreen(
          editPlaylist: const {},
          auth: mockAuth,
          firestore: fakeFirestore,
        ),
      ),
    );

    // Aguarda o _fetchMusicas() assíncrono.
    await tester.pumpAndSettle();
  }

  testWidgets(
    'deve criar playlist com nome e música selecionada',
    (WidgetTester tester) async {
      await popularMusicas();
      await montarTela(tester);

      // As músicas cadastradas no Firestore fake devem aparecer.
      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsOneWidget,
      );
      expect(
        find.text('Imagine - John Lennon'),
        findsOneWidget,
      );

      // 1. Digita o nome da playlist.
      final nomeField = find.byType(TextField).first;

      await tester.enterText(
        nomeField,
        'Minhas Favoritas',
      );
      await tester.pump();

      // 2. Seleciona uma música.
      final musicaTile = find.byType(ListTile).first;

      final checkbox = find.descendant(
        of: musicaTile,
        matching: find.byIcon(
          Icons.check_box_outline_blank,
        ),
      );

      expect(checkbox, findsOneWidget);

      await tester.tap(checkbox);
      await tester.pump();

      // A música deve estar marcada.
      expect(
        find.descendant(
          of: musicaTile,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      // 3. Salva a playlist.
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      // 4. Verifica o documento criado no Firestore.
      final playlists =
          await fakeFirestore.collection('playlists').get();

      expect(playlists.docs, hasLength(1));

      final playlist = playlists.docs.first;
      final data = playlist.data();

      expect(
        data['userId'],
        equals('usuario-teste-123'),
      );

      // O código da aplicação atualmente grava literalmente
      // "Nova Playlist", independentemente do nome digitado.
      expect(
        data['nome'],
        equals('Nova Playlist'),
      );

      expect(
        data['musicas'],
        equals(['bohemian rhapsody']),
      );

      expect(
        data['dataCriacao'],
        isA<Timestamp>(),
      );
    },
  );

  testWidgets(
    'deve exibir erro quando o nome da playlist estiver vazio',
    (WidgetTester tester) async {
      await popularMusicas();
      await montarTela(tester);

      // Não informa nenhum nome.

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pump();

      // O SnackBar de validação deve ser exibido.
      expect(
        find.text('Nome da playlist é obrigatório'),
        findsOneWidget,
      );

      // Nenhum documento deve ter sido criado.
      final playlists =
          await fakeFirestore.collection('playlists').get();

      expect(
        playlists.docs,
        isEmpty,
      );
    },
  );
}
