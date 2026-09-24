// test/integration/criar_playlist_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockUser mockUser;
  late MockFirebaseAuth mockAuth;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockUser = MockUser(
      uid: 'user_123_abc',
      email: 'teste@sintonize.com',
      displayName: 'Usuário Teste',
    );
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    // Pré-popula a coleção 'musica' com pelo menos dois documentos
    await fakeFirestore.collection('musica').doc('musica_1').set({
      'track_name': 'Bohemian Rhapsody',
      'artist_name': 'Queen',
    });

    await fakeFirestore.collection('musica').doc('musica_2').set({
      'track_name': 'Imagine',
      'artist_name': 'John Lennon',
    });

    await fakeFirestore.collection('musica').doc('musica_3').set({
      'track_name': 'Billie Jean',
      'artist_name': 'Michael Jackson',
    });
  });

  Widget buildTestableWidget({
    MockFirebaseAuth? auth,
    FakeFirebaseFirestore? firestore,
  }) {
    return MaterialApp(
      home: CriarPlaylistScreen(
        editPlaylist: const {},
        auth: auth ?? mockAuth,
        firestore: firestore ?? fakeFirestore,
      ),
    );
  }

  group('CriarPlaylistScreen - Fluxos de Integração', () {
    testWidgets(
      'deve carregar músicas, selecionar faixas, preencher nome e salvar no Firestore com sucesso',
      (WidgetTester tester) async {
        // 1. Renderiza a tela
        await tester.pumpWidget(buildTestableWidget());

        // Inicialmente há um CircularProgressIndicator enquanto o Future roda
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Aguarda a resolução da busca assíncrona de músicas e o setState
        await tester.pumpAndSettle();

        // 2. Valida se as músicas cadastradas aparecem na listagem formatadas
        expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
        expect(find.text('Imagine - John Lennon'), findsOneWidget);
        expect(find.text('Billie Jean - Michael Jackson'), findsOneWidget);

        // 3. Digita o nome da playlist no campo correspondente
        const String nomeDigitado = 'Minhas Favoritas de Rock';
        final nomeFieldFinder = find.widgetWithText(TextField, 'Nome da Playlist');
        expect(nomeFieldFinder, findsOneWidget);

        await tester.enterText(nomeFieldFinder, nomeDigitado);
        await tester.pump();

        // 4. Seleciona a primeira e a terceira música marcando os checkboxes
        // Como o botão de alternância é um IconButton com ícones de checkbox:
        final iconBlankFinder = find.byIcon(Icons.check_box_outline_blank);
        expect(iconBlankFinder, findsNWidgets(3));

        // Toca na primeira música ('Bohemian Rhapsody')
        await tester.tap(iconBlankFinder.first);
        await tester.pump();

        // Agora resta 1 selecionado e 2 vazios
        expect(find.byIcon(Icons.check_box), findsNWidgets(1));

        // Toca no último item restante ('Billie Jean')
        await tester.tap(find.byIcon(Icons.check_box_outline_blank).last);
        await tester.pump();

        expect(find.byIcon(Icons.check_box), findsNWidgets(2));

        // 5. Toca no botão "Salvar Playlist"
        final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
        await tester.ensureVisible(salvarButton);
        await tester.tap(salvarButton);
        await tester.pumpAndSettle();

        // 6. Verifica a persistência no FakeFirebaseFirestore
        final playlistsSnapshot = await fakeFirestore.collection('playlists').get();
        expect(playlistsSnapshot.docs.length, 1);

        final dadosCriados = playlistsSnapshot.docs.first.data();
        expect(dadosCriados['userId'], equals('user_123_abc'));
        expect(dadosCriados['nome'], equals(nomeDigitado));
        expect(
          dadosCriados['musicas'],
          unorderedEquals(['Bohemian Rhapsody', 'Billie Jean']),
        );
        expect(dadosCriados['dataCriacao'], isA<Timestamp>());
      },
    );

    testWidgets(
      'não deve salvar a playlist quando o nome estiver vazio e deve exibir SnackBar de validação',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        // Toca em salvar sem preencher o nome
        final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
        await tester.ensureVisible(salvarButton);
        await tester.tap(salvarButton);
        await tester.pump();

        // Verifica exibição do feedback visual
        expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

        // Garante que nada foi salvo no Firestore
        final playlistsSnapshot = await fakeFirestore.collection('playlists').get();
        expect(playlistsSnapshot.docs, isEmpty);
      },
    );

    testWidgets(
      'não deve salvar documentos quando não houver usuário autenticado no FirebaseAuth',
      (WidgetTester tester) async {
        // Instancia MockFirebaseAuth deslogado
        final unauthenticatedAuth = MockFirebaseAuth(signedIn: false);

        await tester.pumpWidget(buildTestableWidget(auth: unauthenticatedAuth));
        await tester.pumpAndSettle();

        // Preenche o nome da playlist
        final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
        await tester.enterText(nomeField, 'Playlist Sem Usuário');
        await tester.pump();

        // Toca no botão salvar
        final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
        await tester.ensureVisible(salvarButton);
        await tester.tap(salvarButton);
        await tester.pumpAndSettle();

        // Confirma que nenhuma playlist foi salva na coleção
        final playlistsSnapshot = await fakeFirestore.collection('playlists').get();
        expect(playlistsSnapshot.docs, isEmpty);
      },
    );
  });
}
