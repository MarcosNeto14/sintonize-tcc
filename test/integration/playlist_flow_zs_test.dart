import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/criar_playlist.dart';
import 'package:sintonize/adicionar-musica.dart';

void main() {
  group('CriarPlaylistScreen', () {
    testWidgets(
      'deve renderizar campos e botÃ£o',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CriarPlaylistScreen(
              editPlaylist: {},
            ),
          ),
        );

        // AvanÃ§a sem esperar pumpAndSettle infinito
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Criando Playlist'), findsOneWidget);

        expect(find.byType(TextField), findsNWidgets(2));

        expect(find.text('Salvar Playlist'), findsOneWidget);

        // Spinner continua visÃ­vel porque Firebase falha
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'deve permitir digitar nome da playlist',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CriarPlaylistScreen(
              editPlaylist: {},
            ),
          ),
        );

        await tester.pump(const Duration(seconds: 1));

        final nomeField = find.byType(TextField).at(0);

        await tester.enterText(
          nomeField,
          'Minha Playlist',
        );

        await tester.pump();

        expect(find.text('Minha Playlist'), findsOneWidget);
      },
    );

    testWidgets(
      'deve mostrar snackbar ao salvar sem nome',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CriarPlaylistScreen(
              editPlaylist: {},
            ),
          ),
        );

        await tester.pump(const Duration(seconds: 1));

        await tester.tap(find.text('Salvar Playlist'));

        await tester.pump();

        expect(
          find.text('Nome da playlist Ã© obrigatÃ³rio'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'botÃ£o voltar deve fechar a tela',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CriarPlaylistScreen(
                            editPlaylist: {},
                          ),
                        ),
                      );
                    },
                    child: const Text('Abrir'),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Abrir'));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Criando Playlist'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Abrir'), findsOneWidget);
      },
    );
  });

  group('AdicionarMusicaScreen', () {
    testWidgets(
      'deve renderizar tela corretamente',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AdicionarMusicaScreen(
              playlistId: 'playlist_1',
              currentSongs: [],
            ),
          ),
        );

        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Adicionar MÃºsicas'), findsOneWidget);

        expect(find.byType(TextField), findsOneWidget);

        expect(find.text('Concluir'), findsOneWidget);

        // Firebase falha => spinner eterno
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'deve permitir digitar na pesquisa',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: AdicionarMusicaScreen(
              playlistId: 'playlist_1',
              currentSongs: [],
            ),
          ),
        );

        await tester.pump(const Duration(seconds: 1));

        await tester.enterText(
          find.byType(TextField),
          'rock',
        );

        await tester.pump();

        expect(find.text('rock'), findsOneWidget);
      },
    );

    testWidgets(
      'botÃ£o concluir sem seleÃ§Ã£o deve fechar tela',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AdicionarMusicaScreen(
                            playlistId: 'playlist_1',
                            currentSongs: [],
                          ),
                        ),
                      );
                    },
                    child: const Text('Abrir'),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Abrir'));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Adicionar MÃºsicas'), findsOneWidget);

        await tester.tap(find.text('Concluir'));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Abrir'), findsOneWidget);
      },
    );

    testWidgets(
      'botÃ£o voltar deve retornar navegaÃ§Ã£o',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AdicionarMusicaScreen(
                            playlistId: 'playlist_1',
                            currentSongs: [],
                          ),
                        ),
                      );
                    },
                    child: const Text('Abrir'),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Abrir'));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Adicionar MÃºsicas'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Abrir'), findsOneWidget);
      },
    );
  });
}
