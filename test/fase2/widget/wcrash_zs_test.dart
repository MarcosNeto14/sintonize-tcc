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
      uid: 'user-test-123',
      email: 'teste@sintonize.com',
    );

    auth = MockFirebaseAuth(
      mockUser: user,
      signedIn: true,
    );

    await firestore.collection('musica').add({
      'track_name': 'shape of you',
      'artist_name': 'ed sheeran',
    });

    await firestore.collection('musica').add({
      'track_name': 'blinding lights',
      'artist_name': 'the weeknd',
    });

    await firestore.collection('musica').add({
      'track_name': 'tempo perdido',
      'artist_name': 'legiao urbana',
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

  group('CriarPlaylistScreen - renderização', () {
    testWidgets('deve renderizar os principais elementos da tela',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Criando Playlist'), findsOneWidget);
      expect(find.text('Nome da Playlist'), findsOneWidget);
      expect(find.text('Pesquisar Música ou Artista'), findsOneWidget);
      expect(find.text('Salvar Playlist'), findsOneWidget);
    });

    testWidgets('deve carregar as músicas do Firestore',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Shape Of You - Ed Sheeran'),
        findsOneWidget,
      );

      expect(
        find.text('Blinding Lights - The Weeknd'),
        findsOneWidget,
      );

      expect(
        find.text('Tempo Perdido - Legiao Urbana'),
        findsOneWidget,
      );
    });
  });

  group('CriarPlaylistScreen - validação', () {
    testWidgets(
      'deve mostrar mensagem quando tentar salvar sem nome',
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
      'não deve salvar playlist quando o nome estiver vazio',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        final playlistsAntes =
            await firestore.collection('playlists').get();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        final playlistsDepois =
            await firestore.collection('playlists').get();

        expect(
          playlistsDepois.docs.length,
          playlistsAntes.docs.length,
        );
      },
    );

    testWidgets(
      'deve aceitar nome de playlist válido',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Nome da Playlist'),
          'Minha Playlist',
        );

        expect(find.text('Minha Playlist'), findsOneWidget);
      },
    );
  });

  group('CriarPlaylistScreen - pesquisa', () {
    testWidgets(
      'deve filtrar músicas pelo nome da música',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Pesquisar Música ou Artista',
          ),
          'shape',
        );

        await tester.pump();

        expect(
          find.text('Shape Of You - Ed Sheeran'),
          findsOneWidget,
        );

        expect(
          find.text('Blinding Lights - The Weeknd'),
          findsNothing,
        );

        expect(
          find.text('Tempo Perdido - Legiao Urbana'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve filtrar músicas pelo nome do artista',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Pesquisar Música ou Artista',
          ),
          'weeknd',
        );

        await tester.pump();

        expect(
          find.text('Blinding Lights - The Weeknd'),
          findsOneWidget,
        );

        expect(
          find.text('Shape Of You - Ed Sheeran'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'a pesquisa deve ignorar maiúsculas e minúsculas',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Pesquisar Música ou Artista',
          ),
          'ED SHEERAN',
        );

        await tester.pump();

        expect(
          find.text('Shape Of You - Ed Sheeran'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir indicador de carregamento quando não houver resultados',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Pesquisar Música ou Artista',
          ),
          'musica-que-nao-existe',
        );

        await tester.pump();

        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );
      },
    );
  });

  group('CriarPlaylistScreen - seleção de músicas', () {
    testWidgets(
      'deve selecionar uma música ao tocar no checkbox',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        final checkbox =
            find.byIcon(Icons.check_box_outline_blank).first;

        expect(checkbox, findsOneWidget);

        await tester.tap(checkbox);
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsAtLeastNWidgets(1),
        );
      },
    );

    testWidgets(
      'deve permitir desmarcar uma música selecionada',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        final checkbox =
            find.byIcon(Icons.check_box_outline_blank).first;

        await tester.tap(checkbox);
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsAtLeastNWidgets(1),
        );

        final selectedCheckbox = find.byIcon(Icons.check_box).first;

        await tester.tap(selectedCheckbox);
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box_outline_blank),
          findsAtLeastNWidgets(1),
        );
      },
    );
  });

  group('CriarPlaylistScreen - salvar playlist', () {
    testWidgets(
      'deve salvar playlist com usuário autenticado',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Nome da Playlist'),
          'Playlist de Teste',
        );

        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank).first,
        );
        await tester.pump();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final snapshot =
            await firestore.collection('playlists').get();

        expect(snapshot.docs.length, 1);

        final playlist = snapshot.docs.first.data();

        expect(playlist['userId'], 'user-test-123');
        expect(playlist['nome'], 'Nova Playlist');

        final musicas = playlist['musicas'] as List<dynamic>;

        expect(musicas.length, 1);
        expect(musicas.first, 'shape of you');
      },
    );

    testWidgets(
      'deve voltar para a tela anterior após salvar',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CriarPlaylistScreen(
                            editPlaylist: const {},
                            auth: auth,
                            firestore: firestore,
                          ),
                        ),
                      );
                    },
                    child: const Text('Abrir playlist'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Abrir playlist'));
        await tester.pumpAndSettle();

        expect(find.text('Criando Playlist'), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextField, 'Nome da Playlist'),
          'Playlist de Teste',
        );

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        expect(find.text('Abrir playlist'), findsOneWidget);
        expect(find.text('Criando Playlist'), findsNothing);
      },
    );
  });

  group('CriarPlaylistScreen - navegação', () {
    testWidgets(
      'deve voltar ao tocar no botão de voltar',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CriarPlaylistScreen(
                            editPlaylist: const {},
                            auth: auth,
                            firestore: firestore,
                          ),
                        ),
                      );
                    },
                    child: const Text('Abrir playlist'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Abrir playlist'));
        await tester.pumpAndSettle();

        expect(find.text('Criando Playlist'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.text('Abrir playlist'), findsOneWidget);
        expect(find.text('Criando Playlist'), findsNothing);
      },
    );
  });
}
