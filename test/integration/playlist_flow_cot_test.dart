// test/integration/playlist_flow_cot_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:sintonize/criar_playlist.dart';
import 'package:sintonize/adicionar-musica.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;

  setUp(() async {
    firestore = FakeFirebaseFirestore();

    auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: '123'),
    );
  });

  group('CriarPlaylistScreen', () {
    testWidgets('deve renderizar loading inicial',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CriarPlaylistScreen(
            editPlaylist: {},
            auth: auth,
            firestore: firestore,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('deve exibir campos e botão principais',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CriarPlaylistScreen(
            editPlaylist: {},
            auth: auth,
            firestore: firestore,
          ),
        ),
      );

      expect(find.text('Criando Playlist'), findsOneWidget);
      expect(find.text('Salvar Playlist'), findsOneWidget);
      expect(find.text('Nome da Playlist'), findsOneWidget);
      expect(find.text('Pesquisar Música ou Artista'), findsOneWidget);
    });

    testWidgets('deve mostrar snackbar ao salvar sem nome',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CriarPlaylistScreen(
            editPlaylist: {},
            auth: auth,
            firestore: firestore,
          ),
        ),
      );

      await tester.tap(find.text('Salvar Playlist'));

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(
        find.text('Nome da playlist é obrigatório'),
        findsOneWidget,
      );
    });

    testWidgets('deve permitir digitar nome da playlist',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CriarPlaylistScreen(
            editPlaylist: {},
            auth: auth,
            firestore: firestore,
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextField).at(0),
        'Minha Playlist',
      );

      await tester.pump();

      expect(find.text('Minha Playlist'), findsOneWidget);
    });

    testWidgets('deve permitir digitar no campo de pesquisa',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CriarPlaylistScreen(
            editPlaylist: {},
            auth: auth,
            firestore: firestore,
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextField).at(1),
        'Rock',
      );

      await tester.pump();

      expect(find.text('Rock'), findsOneWidget);
    });

    testWidgets('deve voltar para tela anterior ao clicar back',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CriarPlaylistScreen(
                        editPlaylist: {},
                        auth: auth,
                        firestore: firestore,
                      ),
                    ),
                  );
                },
                child: const Text('Abrir'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.text('Criando Playlist'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.text('Abrir'), findsOneWidget);
    });
  });

  group('AdicionarMusicaScreen', () {
    testWidgets('deve renderizar loading inicial',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdicionarMusicaScreen(
            playlistId: 'playlist_1',
            currentSongs: [],
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('deve exibir pesquisa e botão concluir',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdicionarMusicaScreen(
            playlistId: 'playlist_1',
            currentSongs: [],
          ),
        ),
      );

      expect(find.text('Adicionar Músicas'), findsOneWidget);
      expect(find.text('Concluir'), findsOneWidget);
      expect(find.text('Pesquisar Música ou Artista'), findsOneWidget);
    });

    testWidgets('deve permitir digitar no campo de pesquisa',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdicionarMusicaScreen(
            playlistId: 'playlist_1',
            currentSongs: [],
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextField),
        'Pop',
      );

      await tester.pump();

      expect(find.text('Pop'), findsOneWidget);
    });

    testWidgets('deve voltar ao clicar no botão back',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdicionarMusicaScreen(
                        playlistId: 'playlist_1',
                        currentSongs: [],
                      ),
                    ),
                  );
                },
                child: const Text('Abrir'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.text('Adicionar Músicas'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.text('Abrir'), findsOneWidget);
    });

    testWidgets('deve fechar tela ao concluir sem músicas selecionadas',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdicionarMusicaScreen(
                        playlistId: 'playlist_1',
                        currentSongs: [],
                      ),
                    ),
                  );
                },
                child: const Text('Abrir'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      await tester.tap(find.text('Concluir'));

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(find.text('Abrir'), findsOneWidget);
    });
  });
}
