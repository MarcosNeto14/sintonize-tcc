// File: test/widget/criar_playlist_zs_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// IMPORT CORRIGIDO
// Ajuste conforme a estrutura REAL do seu projeto.
// Exemplo comum:
import 'package:sintonize/view/criar_playlist_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore firestore;

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  setUp(() async {
    firestore = FakeFirebaseFirestore();

    // Mock de músicas
    await firestore.collection('musica').add({
      'track_name': 'Shape of You',
      'artist_name': 'Ed Sheeran',
    });

    await firestore.collection('musica').add({
      'track_name': 'Blinding Lights',
      'artist_name': 'The Weeknd',
    });
  });

  Widget createWidget() {
    return const MaterialApp(
      home: CriarPlaylistScreen(
        editPlaylist: {},
      ),
    );
  }

  group('CriarPlaylistScreen', () {
    testWidgets(
      'deve renderizar componentes principais',
      (tester) async {
        await tester.pumpWidget(createWidget());

        expect(find.text('Criando Playlist'), findsOneWidget);

        expect(find.text('Salvar Playlist'), findsOneWidget);

        expect(find.byType(TextField), findsNWidgets(2));
      },
    );

    testWidgets(
      'deve permitir digitar nome da playlist',
      (tester) async {
        await tester.pumpWidget(createWidget());

        final nomeField = find.byType(TextField).first;

        await tester.enterText(
          nomeField,
          'Minha Playlist',
        );

        await tester.pump();

        expect(find.text('Minha Playlist'), findsOneWidget);
      },
    );

    testWidgets(
      'deve exibir snackbar ao salvar sem nome',
      (tester) async {
        await tester.pumpWidget(createWidget());

        await tester.tap(
          find.text('Salvar Playlist'),
        );

        await tester.pump();

        expect(
          find.text('Nome da playlist é obrigatório'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve permitir pesquisar músicas',
      (tester) async {
        await tester.pumpWidget(createWidget());

        // Aguarda FutureBuilder/Firestore
        await tester.pumpAndSettle();

        final searchField = find.byType(TextField).at(1);

        await tester.enterText(
          searchField,
          'shape',
        );

        await tester.pumpAndSettle();

        // Como _formatName capitaliza palavras:
        expect(
          find.textContaining('Shape Of You'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve selecionar música',
      (tester) async {
        await tester.pumpWidget(createWidget());

        await tester.pumpAndSettle();

        final checkBox =
            find.byIcon(Icons.check_box_outline_blank).first;

        await tester.tap(checkBox);

        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'deve voltar tela ao clicar no botão voltar',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CriarPlaylistScreen(
                              editPlaylist: {},
                            ),
                          ),
                        );
                      },
                      child: const Text('Abrir'),
                    ),
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Abrir'));

        await tester.pumpAndSettle();

        expect(
          find.text('Criando Playlist'),
          findsOneWidget,
        );

        await tester.tap(
          find.byIcon(Icons.arrow_back),
        );

        await tester.pumpAndSettle();

        expect(find.text('Abrir'), findsOneWidget);
      },
    );
  });
}
