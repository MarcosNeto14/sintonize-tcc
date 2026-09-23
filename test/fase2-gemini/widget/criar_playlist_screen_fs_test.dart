import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  group('CriarPlaylistScreen Widget Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      mockUser = MockUser(
        uid: 'user_123',
        email: 'teste@sintonize.com',
        displayName: 'Usuario Teste',
      );
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      // Popula dados mockados no FakeFirestore
      await fakeFirestore.collection('musica').add({
        'track_name': 'blinding lights',
        'artist_name': 'the weeknd',
      });
      await fakeFirestore.collection('musica').add({
        'track_name': 'yellow',
        'artist_name': 'coldplay',
      });
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: CriarPlaylistScreen(
          editPlaylist: const {},
          auth: mockAuth,
          firestore: fakeFirestore,
        ),
      );
    }

    testWidgets('deve exibir os elementos visuais iniciais e carregar lista de músicas',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Antes do Future resolver, exibe indicador de carregamento
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Aguarda o término de _fetchMusicas()
      await tester.pumpAndSettle();

      // Valida textos do cabeçalho e campos
      expect(find.text('Criando Playlist'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Nome da Playlist'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Pesquisar Música ou Artista'), findsOneWidget);
      expect(find.text('Salvar Playlist'), findsOneWidget);

      // Valida exibição formatada das músicas vindas do mock
      expect(find.text('Blinding Lights - The Weeknd'), findsOneWidget);
      expect(find.text('Yellow - Coldplay'), findsOneWidget);
    });

    testWidgets('deve exibir SnackBar de erro ao tentar salvar sem preencher o nome',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Clica no botão "Salvar Playlist" sem digitar o nome
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pump();

      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);
    });

    testWidgets('deve alternar ícone de seleção ao clicar no checkbox da música',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Inicialmente nenhum item está selecionado
      expect(find.byIcon(Icons.check_box_outline_blank), findsNWidgets(2));
      expect(find.byIcon(Icons.check_box), findsNothing);

      // Seleciona a primeira música
      await tester.tap(find.byIcon(Icons.check_box_outline_blank).first);
      await tester.pump();

      expect(find.byIcon(Icons.check_box), findsOneWidget);
      expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);

      // Desmarca a música
      await tester.tap(find.byIcon(Icons.check_box));
      await tester.pump();

      expect(find.byIcon(Icons.check_box), findsNothing);
      expect(find.byIcon(Icons.check_box_outline_blank), findsNWidgets(2));
    });

    testWidgets('deve filtrar músicas corretamente ao pesquisar por nome ou artista',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final searchField = find.widgetWithText(TextField, 'Pesquisar Música ou Artista');

      // Busca por artista
      await tester.enterText(searchField, 'weeknd');
      await tester.pump();

      expect(find.text('Blinding Lights - The Weeknd'), findsOneWidget);
      expect(find.text('Yellow - Coldplay'), findsNothing);

      // Limpa e busca por faixa
      await tester.enterText(searchField, 'yellow');
      await tester.pump();

      expect(find.text('Yellow - Coldplay'), findsOneWidget);
      expect(find.text('Blinding Lights - The Weeknd'), findsNothing);
    });

    testWidgets('deve salvar a playlist com sucesso no Firestore quando o formulário for válido',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Digita o nome da playlist
      final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
      await tester.enterText(nomeField, 'Minhas Favoritas');

      // Seleciona uma música
      await tester.tap(find.byIcon(Icons.check_box_outline_blank).first);
      await tester.pump();

      // Salva a playlist
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      // Verifica se o documento foi persistido no FakeFirestore
      final snapshot = await fakeFirestore.collection('playlists').get();
      expect(snapshot.docs.length, 1);

      final data = snapshot.docs.first.data();
      expect(data['nome'], 'Minhas Favoritas');
      expect(data['userId'], 'user_123');
      expect(data['musicas'], contains('blinding lights'));
    });
  });
}

