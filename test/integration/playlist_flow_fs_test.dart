import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/criar_playlist.dart';
import 'package:sintonize/adicionar-musica.dart';

void main() {
  group('Fluxo de Playlist', () {
    testWidgets(
      'deve renderizar CriarPlaylistScreen com campos e spinner',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CriarPlaylistScreen(editPlaylist: {}),
          ),
        );

        // Aguarda tentativa de fetch do Firebase
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Criando Playlist'), findsOneWidget);
        expect(find.text('Nome da Playlist'), findsOneWidget);
        expect(find.text('Pesquisar MÃºsica ou Artista'), findsOneWidget);
        expect(find.text('Salvar Playlist'), findsOneWidget);

        // Como Firebase falha, lista permanece vazia e spinner aparece
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Dois TextFields: nome + pesquisa
        expect(find.byType(TextField), findsNWidgets(2));
      },
    );

    testWidgets(
      'deve permitir digitar nome da playlist e pesquisa',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CriarPlaylistScreen(editPlaylist: {}),
          ),
        );

        await tester.pump(const Duration(seconds: 1));

        await tester.enterText(
          find.byType(TextField).at(0),
          'Minha Playlist',
        );

        await tester.enterText(
          find.byType(TextField).at(1),
          'Rock',
        );

        await tester.pump();

        expect(find.text('Minha Playlist'), findsOneWidget);
        expect(find.text('Rock'), findsOneWidget);
      },
    );

    testWidgets(
      'deve mostrar SnackBar ao tentar salvar playlist sem nome',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CriarPlaylistScreen(editPlaylist: {}),
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
      'botÃ£o voltar deve fechar CriarPlaylistScreen',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CriarPlaylistScreen(editPlaylist: {}),
                      ),
                    );
                  },
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Abrir'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(CriarPlaylistScreen), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(CriarPlaylistScreen), findsNothing);
        expect(find.text('Abrir'), findsOneWidget);
      },
    );

    testWidgets(
      'deve renderizar AdicionarMusicaScreen com spinner',
      (tester) async {
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
        expect(find.text('Pesquisar MÃºsica ou Artista'), findsOneWidget);
        expect(find.text('Concluir'), findsOneWidget);

        // Firebase falha -> spinner permanece
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        expect(find.byType(TextField), findsOneWidget);
      },
    );

    testWidgets(
      'deve permitir pesquisar mÃºsica em AdicionarMusicaScreen',
      (tester) async {
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
          'Metallica',
        );

        await tester.pump();

        expect(find.text('Metallica'), findsOneWidget);
      },
    );

    testWidgets(
      'botÃ£o concluir sem mÃºsicas selecionadas deve voltar para tela anterior',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
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
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Abrir'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(AdicionarMusicaScreen), findsOneWidget);

        // Sem mÃºsicas selecionadas, apenas Navigator.pop(context)
        await tester.tap(find.text('Concluir'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(AdicionarMusicaScreen), findsNothing);
        expect(find.text('Abrir'), findsOneWidget);
      },
    );

    testWidgets(
      'botÃ£o voltar deve fechar AdicionarMusicaScreen',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
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
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Abrir'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(AdicionarMusicaScreen), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(AdicionarMusicaScreen), findsNothing);
        expect(find.text('Abrir'), findsOneWidget);
      },
    );
  });
}
