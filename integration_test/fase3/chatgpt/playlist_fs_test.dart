import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/criar_playlist.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu: $finder');
  }

  testWidgets(
    'criar playlist: usuário seleciona músicas e salva playlist',
    (tester) async {
      // Abre o aplicativo real.
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Login pelo Firebase Auth Emulator.
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'tester@sintonize.test',
      );

      await tester.enterText(
        find.byType(TextFormField).last,
        'senha123',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // O login deve levar à TelaInicialScreen.
      expect(find.text('Pesquisa Direta'), findsOneWidget);
      expect(find.text('Minha Conta'), findsOneWidget);

      // Abre Minha Conta.
      await tester.tap(find.text('Minha Conta'));
      await tester.pumpAndSettle();

      // Abre Criar Playlist.
      await tester.tap(find.text('Criar Playlist'));

      await esperar(
        tester,
        find.byType(CriarPlaylistScreen),
      );

      expect(find.text('Criando Playlist'), findsOneWidget);
      expect(find.text('Nome da Playlist'), findsOneWidget);
      expect(find.text('Pesquisar Música ou Artista'), findsOneWidget);
      expect(find.text('Salvar Playlist'), findsOneWidget);

      // A CriarPlaylistScreen busca as músicas no Firestore ao ser montada.
      // Esperamos uma música conhecida do dataset do teste.
      await esperar(
        tester,
        find.text('Bohemian Rhapsody - Queen'),
      );

      expect(
        find.text('Billie Jean - Michael Jackson'),
        findsOneWidget,
      );

      expect(
        find.text('Take Five - Dave Brubeck'),
        findsOneWidget,
      );

      // Os dois TextFields da CriarPlaylistScreen são:
      // 0 = Nome da Playlist
      // 1 = Pesquisar Música ou Artista
      final textFields = find.byType(TextField);

      expect(textFields, findsNWidgets(2));

      await tester.enterText(
        textFields.at(0),
        'Playlist E2E',
      );

      // Seleciona Bohemian Rhapsody.
      final bohemianTile = find.ancestor(
        of: find.text('Bohemian Rhapsody - Queen'),
        matching: find.byType(ListTile),
      );

      expect(bohemianTile, findsOneWidget);

      await tester.tap(
        find.descendant(
          of: bohemianTile,
          matching: find.byType(IconButton),
        ),
      );

      await tester.pump();

      // Seleciona Billie Jean.
      final billieTile = find.ancestor(
        of: find.text('Billie Jean - Michael Jackson'),
        matching: find.byType(ListTile),
      );

      expect(billieTile, findsOneWidget);

      await tester.tap(
        find.descendant(
          of: billieTile,
          matching: find.byType(IconButton),
        ),
      );

      await tester.pump();

      // Confirma que as duas músicas ficaram selecionadas.
      expect(
        find.descendant(
          of: bohemianTile,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      expect(
        find.descendant(
          of: billieTile,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      // Salva a playlist.
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      // _salvarPlaylist() faz Navigator.pop() depois de persistir.
      expect(
        find.byType(CriarPlaylistScreen),
        findsNothing,
      );

      // Validação diretamente no Firestore Emulator.
      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);
      expect(user!.email, 'tester@sintonize.test');

      final snapshot = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: user.uid)
          .get();

      expect(snapshot.docs, isNotEmpty);

      // Como os emuladores são reiniciados/populados antes da execução,
      // esperamos encontrar a playlist criada pelo teste.
      final playlists = snapshot.docs
          .map((doc) => doc.data())
          .where((playlist) => playlist['nome'] == 'Playlist E2E')
          .toList();

      expect(playlists, hasLength(1));

      final playlist = playlists.single;

      expect(playlist['userId'], user.uid);
      expect(playlist['nome'], 'Playlist E2E');
      expect(playlist['musicas'], isA<List>());
      expect(playlist['musicas'], contains('bohemian rhapsody'));
      expect(playlist['musicas'], contains('billie jean'));
      expect(playlist['musicas'], hasLength(2));
      expect(playlist['dataCriacao'], isA<Timestamp>());
    },
  );
}
