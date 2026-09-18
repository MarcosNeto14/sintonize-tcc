import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;

  setUp(() async {
    firestore = FakeFirebaseFirestore();

    final user = MockUser(
      uid: 'usuario-teste-123',
      email: 'teste@sintonize.com',
    );

    auth = MockFirebaseAuth(
      mockUser: user,
      signedIn: true,
    );

    // Pré-popula o Firestore antes do pump do widget.
    await firestore.collection('musica').add({
      'track_name': 'tempo perdido',
      'artist_name': 'legiao urbana',
    });

    await firestore.collection('musica').add({
      'track_name': 'garota de ipanema',
      'artist_name': 'antonio carlos jobim',
    });
  });

  Widget createWidget() {
    return MaterialApp(
      home: CriarPlaylistScreen(
        editPlaylist: const {},
        auth: auth,
        firestore: firestore,
      ),
    );
  }

  testWidgets(
    'exibe as músicas carregadas do Firestore fake',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      // _fetchMusicas() é assíncrono.
      await tester.pumpAndSettle();

      expect(find.text('Tempo Perdido - Legiao Urbana'), findsOneWidget);
      expect(
        find.text('Garota De Ipanema - Antonio Carlos Jobim'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'permite digitar o nome da playlist',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final campoNome = find.byType(TextField).first;

      await tester.enterText(campoNome, 'Minhas Favoritas');
      await tester.pump();

      expect(find.text('Minhas Favoritas'), findsOneWidget);
    },
  );

  testWidgets(
    'filtra músicas pelo nome da música',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final campoPesquisa = find.byType(TextField).at(1);

      await tester.enterText(campoPesquisa, 'tempo');
      await tester.pump();

      expect(find.text('Tempo Perdido - Legiao Urbana'), findsOneWidget);
      expect(
        find.text('Garota De Ipanema - Antonio Carlos Jobim'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'filtra músicas pelo nome do artista',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final campoPesquisa = find.byType(TextField).at(1);

      await tester.enterText(campoPesquisa, 'jobim');
      await tester.pump();

      expect(
        find.text('Garota De Ipanema - Antonio Carlos Jobim'),
        findsOneWidget,
      );
      expect(find.text('Tempo Perdido - Legiao Urbana'), findsNothing);
    },
  );

  testWidgets(
    'permite marcar e desmarcar uma música',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final botaoMusica = find.byIcon(Icons.check_box_outline_blank).first;

      expect(botaoMusica, findsOneWidget);

      await tester.tap(botaoMusica);
      await tester.pump();

      expect(find.byIcon(Icons.check_box), findsOneWidget);

      // O primeiro botão agora deve representar a música selecionada.
      await tester.tap(find.byIcon(Icons.check_box).first);
      await tester.pump();

      expect(find.byIcon(Icons.check_box_outline_blank), findsNWidgets(2));
    },
  );

  testWidgets(
    'mostra erro ao tentar salvar sem informar nome da playlist',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pump();

      expect(
        find.text('Nome da playlist é obrigatório'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'salva a playlist com nome e música selecionada',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Digita o nome da playlist.
      final campoNome = find.byType(TextField).first;
      await tester.enterText(campoNome, 'Playlist Favorita');
      await tester.pump();

      // Seleciona "Tempo Perdido".
      final itemMusica = find.text('Tempo Perdido - Legiao Urbana');
      expect(itemMusica, findsOneWidget);

      final listTile = find.ancestor(
        of: itemMusica,
        matching: find.byType(ListTile),
      );

      final botaoSelecao = find.descendant(
        of: listTile,
        matching: find.byType(IconButton),
      );

      await tester.tap(botaoSelecao);
      await tester.pump();

      expect(find.byIcon(Icons.check_box), findsOneWidget);

      // Salva.
      await tester.tap(find.text('Salvar Playlist'));

      // Aguarda o Future de _salvarPlaylist().
      await tester.pumpAndSettle();

      // O widget deve ter feito Navigator.pop().
      expect(find.byType(CriarPlaylistScreen), findsNothing);

      // Confirma diretamente no Firestore fake que a playlist foi criada.
      final playlists =
          await firestore.collection('playlists').get();

      expect(playlists.docs, hasLength(1));

      final playlist = playlists.docs.first.data();

      expect(playlist['userId'], 'usuario-teste-123');
      expect(playlist['nome'], 'Playlist Favorita');
      expect(playlist['musicas'], ['tempo perdido']);
      expect(playlist['dataCriacao'], isA<Timestamp>());
    },
  );

  testWidgets(
    'permite pesquisar, selecionar uma música e salvar somente a música filtrada',
    (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Nome da playlist.
      await tester.enterText(
        find.byType(TextField).first,
        'Playlist Jobim',
      );
      await tester.pump();

      // Pesquisa pelo artista.
      await tester.enterText(
        find.byType(TextField).at(1),
        'jobim',
      );
      await tester.pump();

      expect(
        find.text('Garota De Ipanema - Antonio Carlos Jobim'),
        findsOneWidget,
      );
      expect(find.text('Tempo Perdido - Legiao Urbana'), findsNothing);

      // Seleciona a música encontrada.
      final itemMusica =
          find.text('Garota De Ipanema - Antonio Carlos Jobim');

      final listTile = find.ancestor(
        of: itemMusica,
        matching: find.byType(ListTile),
      );

      final botaoSelecao = find.descendant(
        of: listTile,
        matching: find.byType(IconButton),
      );

      await tester.tap(botaoSelecao);
      await tester.pump();

      expect(find.byIcon(Icons.check_box), findsOneWidget);

      // Salva a playlist.
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      final playlists =
          await firestore.collection('playlists').get();

      expect(playlists.docs, hasLength(1));

      final playlist = playlists.docs.first.data();

      expect(playlist['userId'], 'usuario-teste-123');
      expect(playlist['nome'], 'Playlist Jobim');
      expect(playlist['musicas'], ['garota de ipanema']);
    },
  );
}
