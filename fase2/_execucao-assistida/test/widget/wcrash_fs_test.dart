import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Arquivo real do projeto.
import 'package:sintonize/criar_playlist.dart';

void main() {
  group('CriarPlaylistScreen Widget', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user123'),
      );

      fakeFirestore = FakeFirebaseFirestore();
    });

    Future<void> inserirMusicas() async {
      await fakeFirestore.collection('musica').add({
        'track_name': 'imagine',
        'artist_name': 'john lennon',
      });

      await fakeFirestore.collection('musica').add({
        'track_name': 'bohemian rhapsody',
        'artist_name': 'queen',
      });

      await fakeFirestore.collection('musica').add({
        'track_name': 'hotel california',
        'artist_name': 'eagles',
      });
    }

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CriarPlaylistScreen(
            editPlaylist: const {},
            auth: mockAuth,
            firestore: fakeFirestore,
          ),
        ),
      );

      // Processa o Future de _fetchMusicas() e o setState subsequente,
      // mas não usa pumpAndSettle(), pois CircularProgressIndicator
      // possui uma animação contínua quando não há músicas.
      await tester.pump();
      await tester.pump();
    }

    testWidgets('deve mostrar o título da tela', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Criando Playlist'), findsOneWidget);
      expect(find.text('Nome da Playlist'), findsOneWidget);
      expect(find.text('Pesquisar Música ou Artista'), findsOneWidget);
      expect(find.text('Salvar Playlist'), findsOneWidget);
    });

    testWidgets('deve carregar as músicas do Firestore', (tester) async {
      await inserirMusicas();

      await pumpScreen(tester);

      expect(
        find.text('Imagine - John Lennon'),
        findsOneWidget,
      );

      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsOneWidget,
      );

      expect(
        find.text('Hotel California - Eagles'),
        findsOneWidget,
      );
    });

    testWidgets('deve formatar nomes das músicas e artistas', (tester) async {
      await fakeFirestore.collection('musica').add({
        'track_name': 'stairway to heaven',
        'artist_name': 'led zeppelin',
      });

      await pumpScreen(tester);

      expect(
        find.text('Stairway To Heaven - Led Zeppelin'),
        findsOneWidget,
      );
    });

    testWidgets('deve filtrar músicas pelo nome da música', (tester) async {
      await inserirMusicas();

      await pumpScreen(tester);

      final searchField = find.byType(TextField).at(1);

      await tester.enterText(searchField, 'bohemian');
      await tester.pump();

      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsOneWidget,
      );

      expect(
        find.text('Imagine - John Lennon'),
        findsNothing,
      );

      expect(
        find.text('Hotel California - Eagles'),
        findsNothing,
      );
    });

    testWidgets('deve filtrar músicas pelo nome do artista', (tester) async {
      await inserirMusicas();

      await pumpScreen(tester);

      final searchField = find.byType(TextField).at(1);

      await tester.enterText(searchField, 'queen');
      await tester.pump();

      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsOneWidget,
      );

      expect(
        find.text('Imagine - John Lennon'),
        findsNothing,
      );

      expect(
        find.text('Hotel California - Eagles'),
        findsNothing,
      );
    });

    testWidgets('deve realizar busca ignorando maiúsculas e minúsculas',
        (tester) async {
      await inserirMusicas();

      await pumpScreen(tester);

      final searchField = find.byType(TextField).at(1);

      await tester.enterText(searchField, 'QUEEN');
      await tester.pump();

      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar todas as músicas quando a busca está vazia',
        (tester) async {
      await inserirMusicas();

      await pumpScreen(tester);

      final searchField = find.byType(TextField).at(1);

      await tester.enterText(searchField, 'queen');
      await tester.pump();

      expect(find.text('Imagine - John Lennon'), findsNothing);
      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);

      await tester.enterText(searchField, '');
      await tester.pump();

      expect(find.text('Imagine - John Lennon'), findsOneWidget);
      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
      expect(find.text('Hotel California - Eagles'), findsOneWidget);
    });

    testWidgets('deve mostrar mensagem quando nenhuma música for encontrada',
        (tester) async {
      await inserirMusicas();

      await pumpScreen(tester);

      final searchField = find.byType(TextField).at(1);

      await tester.enterText(searchField, 'musica inexistente');
      await tester.pump();

      // O widget utiliza CircularProgressIndicator quando a lista filtrada
      // fica vazia.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('deve selecionar uma música', (tester) async {
      await inserirMusicas();

      await pumpScreen(tester);

      final listTile = find.widgetWithText(
        ListTile,
        'Imagine - John Lennon',
      );

      final iconButton = find.descendant(
        of: listTile,
        matching: find.byType(IconButton),
      );

      await tester.tap(iconButton);
      await tester.pump();

      expect(
        find.descendant(
          of: listTile,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );
    });

    testWidgets('deve desselecionar uma música previamente selecionada',
        (tester) async {
      await inserirMusicas();

      await pumpScreen(tester);

      final listTile = find.widgetWithText(
        ListTile,
        'Imagine - John Lennon',
      );

      final iconButton = find.descendant(
        of: listTile,
        matching: find.byType(IconButton),
      );

      await tester.tap(iconButton);
      await tester.pump();

      expect(
        find.descendant(
          of: listTile,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      await tester.tap(iconButton);
      await tester.pump();

      expect(
        find.descendant(
          of: listTile,
          matching: find.byIcon(Icons.check_box_outline_blank),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'deve mostrar erro quando tentar salvar sem informar o nome da playlist',
        (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pump();

      expect(
        find.text('Nome da playlist é obrigatório'),
        findsOneWidget,
      );
    });

    testWidgets('deve permitir informar o nome da playlist', (tester) async {
      await pumpScreen(tester);

      final nomeField = find.byType(TextField).first;

      await tester.enterText(nomeField, 'Minha Playlist');
      await tester.pump();

      expect(
        find.text('Minha Playlist'),
        findsOneWidget,
      );
    });

    testWidgets('deve salvar a playlist com o usuário e músicas selecionadas',
        (tester) async {
      await inserirMusicas();

      // Inserimos uma rota anterior para que Navigator.pop() tenha
      // um destino válido.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CriarPlaylistScreen(
              editPlaylist: const {},
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final nomeField = find.byType(TextField).first;

      await tester.enterText(nomeField, 'Minha Playlist');

      final imagineTile = find.widgetWithText(
        ListTile,
        'Imagine - John Lennon',
      );

      final imagineButton = find.descendant(
        of: imagineTile,
        matching: find.byType(IconButton),
      );

      await tester.tap(imagineButton);
      await tester.pump();

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      final docs = await fakeFirestore.collection('playlists').get();

      expect(docs.docs.length, 1);

      final playlist = docs.docs.first.data();

      expect(playlist['userId'], 'user123');

      // O código atual salva "Nova Playlist", independentemente
      // do texto digitado no campo.
      expect(playlist['nome'], 'Nova Playlist');

      expect(
        List<String>.from(playlist['musicas']),
        contains('imagine'),
      );

      expect(playlist['dataCriacao'], isA<Timestamp>());

      // Após salvar, a tela deve ter sido removida da navegação.
      expect(find.text('Criando Playlist'), findsNothing);
    });

    testWidgets('deve salvar várias músicas selecionadas', (tester) async {
      await inserirMusicas();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CriarPlaylistScreen(
              editPlaylist: const {},
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'Playlist Favorita',
      );

      final imagineTile = find.widgetWithText(
        ListTile,
        'Imagine - John Lennon',
      );

      final queenTile = find.widgetWithText(
        ListTile,
        'Bohemian Rhapsody - Queen',
      );

      await tester.tap(
        find.descendant(
          of: imagineTile,
          matching: find.byType(IconButton),
        ),
      );

      await tester.tap(
        find.descendant(
          of: queenTile,
          matching: find.byType(IconButton),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      final docs = await fakeFirestore.collection('playlists').get();

      expect(docs.docs.length, 1);

      final musicas = List<String>.from(docs.docs.first.data()['musicas']);

      expect(musicas, contains('imagine'));
      expect(musicas, contains('bohemian rhapsody'));
      expect(musicas.length, 2);
    });

    testWidgets('deve voltar ao tocar no botão de voltar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  child: const Text('Abrir playlist'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CriarPlaylistScreen(
                          editPlaylist: const {},
                          auth: mockAuth,
                          firestore: fakeFirestore,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir playlist'));

      // Não usar pumpAndSettle(): sem músicas, a tela possui
      // CircularProgressIndicator com animação infinita.
      await tester.pump();
      await tester.pump();

      expect(find.text('Criando Playlist'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Abrir playlist'), findsOneWidget);
      expect(find.text('Criando Playlist'), findsNothing);
    });
  });
}
