import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/criar_playlist.dart';
import 'package:sintonize/main.dart';
import 'package:sintonize/usuario.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> esperar(
    WidgetTester tester,
    Finder finder, {
    int tentativas = 40,
  }) async {
    for (var i = 0; i < tentativas; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu: $finder');
  }

  Future<void> esperarTelaInicial(WidgetTester tester) async {
    await esperar(
      tester,
      find.byType(TelaInicialScreen),
    );
  }

  Future<void> fazerLogin(WidgetTester tester) async {
    // Tela inicial.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);

    // Abre LoginScreen.
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Preenche e-mail.
    final campos = find.byType(TextFormField);
    expect(campos, findsNWidgets(2));

    await tester.enterText(
      campos.at(0),
      'tester@sintonize.test',
    );

    // Preenche senha.
    await tester.enterText(
      campos.at(1),
      'senha123',
    );

    // Executa login.
    await tester.tap(find.text('Entrar'));

    await esperarTelaInicial(tester);
  }

  testWidgets(
    'criar playlist: seleciona músicas e persiste playlist no Firestore',
    (tester) async {
      await fazerLogin(tester);

      // Abre "Minha Conta".
      await tester.tap(find.text('Minha Conta'));

      await esperar(
        tester,
        find.byType(UsuarioScreen),
      );

      // Aguarda a tela de usuário terminar de carregar.
      await esperar(
        tester,
        find.text('Criar Playlist'),
      );

      // Abre Criar Playlist.
      await tester.tap(find.text('Criar Playlist'));

      await esperar(
        tester,
        find.byType(CriarPlaylistScreen),
      );

      // A CriarPlaylistScreen busca as músicas no Firestore durante o initState.
      // Aguarda duas músicas conhecidas aparecerem na lista.
      await esperar(
        tester,
        find.text('Bohemian Rhapsody - Queen'),
      );

      await esperar(
        tester,
        find.text('Billie Jean - Michael Jackson'),
      );

      // Confirma que a lista realmente veio do Firestore.
      expect(
        find.text('Take Five - Dave Brubeck'),
        findsOneWidget,
      );

      expect(
        find.text('The Thrill Is Gone - B.B. King'),
        findsOneWidget,
      );

      expect(
        find.text('One Love - Bob Marley'),
        findsOneWidget,
      );

      // Digita o nome da playlist.
      final campoNome = find.widgetWithText(
        TextField,
        'Nome da Playlist',
      );

      expect(campoNome, findsOneWidget);

      await tester.enterText(
        campoNome,
        'Playlist E2E Sintonize',
      );

      // Seleciona Bohemian Rhapsody.
      //
      // O checkbox é implementado como IconButton no trailing do ListTile.
      // Encontramos o ListTile pelo texto da música e acionamos seu
      // IconButton, evitando depender da posição da lista.
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

      await tester.pumpAndSettle();

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

      await tester.pumpAndSettle();

      // Confirma visualmente que os dois itens foram marcados.
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

      // O _salvarPlaylist faz um add() no Firestore e, depois,
      // Navigator.pop(context).
      await esperar(
        tester,
        find.byType(UsuarioScreen),
      );

      // Aguarda o retorno da tela de usuário e a atualização da consulta
      // de playlists.
      await esperar(
        tester,
        find.text('Playlist E2E Sintonize'),
      );

      // A UI também deve indicar que existem duas músicas na playlist.
      expect(
        find.text('2 músicas'),
        findsOneWidget,
      );

      // ---------------------------------------------------------------
      // Verificação E2E da persistência no Firestore.
      // ---------------------------------------------------------------

      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);

      final playlistSnapshot = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: user!.uid)
          .where('nome', isEqualTo: 'Playlist E2E Sintonize')
          .get();

      expect(
        playlistSnapshot.docs,
        hasLength(1),
      );

      final playlistData = playlistSnapshot.docs.single.data();

      expect(
        playlistData['userId'],
        user.uid,
      );

      expect(
        playlistData['nome'],
        'Playlist E2E Sintonize',
      );

      expect(
        playlistData['musicas'],
        containsAll(<String>[
          'bohemian rhapsody',
          'billie jean',
        ]),
      );

      expect(
        (playlistData['musicas'] as List).length,
        2,
      );

      expect(
        playlistData['dataCriacao'],
        isA<Timestamp>(),
      );
    },
  );
}
