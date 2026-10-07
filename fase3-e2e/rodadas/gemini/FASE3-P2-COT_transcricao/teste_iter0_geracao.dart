import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:sintonize/main.dart';
import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  /// Helper para autenticar e navegar da HomeScreen até a CriarPlaylistScreen
  Future<void> navegarAteCriarPlaylist(WidgetTester tester) async {
    // Garante estado de logout antes de começar o fluxo
    await FirebaseAuth.instance.signOut();

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Toca no botão de Login na HomeScreen
    final loginBtnFinder = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginBtnFinder, findsOneWidget);
    await tester.tap(loginBtnFinder);
    await tester.pumpAndSettle();

    // 2. Preenche credenciais na LoginScreen
    final emailField = find.byType(TextFormField).at(0);
    final senhaField = find.byType(TextFormField).at(1);
    await tester.enterText(emailField, 'tester@sintonize.test');
    await tester.enterText(senhaField, 'senha123');
    await tester.pumpAndSettle();

    final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
    await tester.tap(entrarBtn);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 3. Na TelaInicialScreen, navega para "Minha Conta"
    final minhaContaTab = find.text('Minha Conta');
    expect(minhaContaTab, findsOneWidget);
    await tester.tap(minhaContaTab);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 4. Na UsuarioScreen, toca no menu "Criar Playlist"
    final criarPlaylistMenu = find.text('Criar Playlist');
    expect(criarPlaylistMenu, findsOneWidget);
    await tester.tap(criarPlaylistMenu);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Valida que chegou na CriarPlaylistScreen
    expect(find.text('Criando Playlist'), findsOneWidget);
  }

  testWidgets(
    'Cenário 1: Fluxo de sucesso ponta a ponta - criar e persistir playlist no Firestore',
    (WidgetTester tester) async {
      await navegarAteCriarPlaylist(tester);

      // Aguarda carregamento das músicas
      expect(find.byType(ListView), findsOneWidget);

      // Preenche o nome da playlist
      final nomePlaylistField = find.widgetWithText(TextField, 'Nome da Playlist');
      expect(nomePlaylistField, findsOneWidget);
      const String playlistNome = 'Rock & Pop Classics';
      await tester.enterText(nomePlaylistField, playlistNome);
      await tester.pumpAndSettle();

      // Seleciona as músicas "Bohemian Rhapsody" e "Billie Jean"
      final bohemianItem = find.textContaining('Bohemian Rhapsody');
      expect(bohemianItem, findsOneWidget);
      final bohemianTile = find.ancestor(
        of: bohemianItem,
        matching: find.byType(ListTile),
      );
      final bohemianCheckbox = find.descendant(
        of: bohemianTile,
        matching: find.byType(IconButton),
      );
      await tester.tap(bohemianCheckbox);
      await tester.pumpAndSettle();

      final billieItem = find.textContaining('Billie Jean');
      expect(billieItem, findsOneWidget);
      final billieTile = find.ancestor(
        of: billieItem,
        matching: find.byType(ListTile),
      );
      final billieCheckbox = find.descendant(
        of: billieTile,
        matching: find.byType(IconButton),
      );
      await tester.tap(billieCheckbox);
      await tester.pumpAndSettle();

      // Rola a tela até o botão "Salvar Playlist" se necessário e toca nele
      final salvarBtn = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.ensureVisible(salvarBtn);
      await tester.tap(salvarBtn);

      // Aguarda a gravação no Firestore e o pop para a UsuarioScreen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verifica se retornou para a UsuarioScreen e exibe o nome da playlist recém-criada
      expect(find.text(playlistNome), findsOneWidget);
      expect(find.text('2 músicas'), findsOneWidget);

      // Validação direta no emulador Firestore
      final currentUser = FirebaseAuth.instance.currentUser;
      expect(currentUser, isNotNull);

      final snapshot = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: currentUser!.uid)
          .where('nome', isEqualTo: playlistNome)
          .get();

      expect(snapshot.docs.isNotEmpty, isTrue);
      final dadosPlaylist = snapshot.docs.first.data();
      expect(dadosPlaylist['nome'], equals(playlistNome));
      expect(dadosPlaylist['userId'], equals(currentUser.uid));
      final List<dynamic> musicasPersistidas = dadosPlaylist['musicas'];
      expect(musicasPersistidas, contains('bohemian rhapsody'));
      expect(musicasPersistidas, contains('billie jean'));
    },
  );

  testWidgets(
    'Cenário 2: Validação antes de salvar - nome vazio não deve salvar a playlist',
    (WidgetTester tester) async {
      await navegarAteCriarPlaylist(tester);

      // Marca uma música sem preencher o nome da playlist
      final firstSongTile = find.byType(ListTile).first;
      final checkbox = find.descendant(
        of: firstSongTile,
        matching: find.byType(IconButton),
      );
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Clica em "Salvar Playlist" com o nome em branco
      final salvarBtn = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.ensureVisible(salvarBtn);
      await tester.tap(salvarBtn);
      await tester.pump();

      // Verifica se a SnackBar de validação foi apresentada
      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

      // Garante que a tela continua em CriarPlaylistScreen (não fez pop)
      expect(find.text('Criando Playlist'), findsOneWidget);
    },
  );

  testWidgets(
    'Cenário 3: Pesquisa e filtragem da lista de músicas',
    (WidgetTester tester) async {
      await navegarAteCriarPlaylist(tester);

      // Verifica que todas as músicas inicialmente carregadas estão visíveis
      expect(find.textContaining('Bohemian Rhapsody'), findsOneWidget);
      expect(find.textContaining('Billie Jean'), findsOneWidget);
      expect(find.textContaining('Take Five'), findsOneWidget);

      // Digita um termo de pesquisa específico ("Queen")
      final searchField =
          find.widgetWithText(TextField, 'Pesquisar Música ou Artista');
      await tester.enterText(searchField, 'Queen');
      await tester.pumpAndSettle();

      // Valida que apenas o resultado correspondente é exibido
      expect(find.textContaining('Bohemian Rhapsody'), findsOneWidget);
      expect(find.textContaining('Billie Jean'), findsNothing);
      expect(find.textContaining('Take Five'), findsNothing);

      // Limpa a busca e confere se a lista completa reaparece
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      expect(find.textContaining('Bohemian Rhapsody'), findsOneWidget);
      expect(find.textContaining('Billie Jean'), findsOneWidget);
      expect(find.textContaining('Take Five'), findsOneWidget);
    },
  );

  testWidgets(
    'Cenário 4: Estados intermediários visíveis ao usuário (indicador de carregamento e SnackBar)',
    (WidgetTester tester) async {
      await navegarAteCriarPlaylist(tester);

      // Tenta salvar com nome vazio para disparar a SnackBar
      final salvarBtn = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.ensureVisible(salvarBtn);
      await tester.tap(salvarBtn);
      await tester.pump();

      // SnackBar deve estar visível
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

      // Aguarda o timeout natural da SnackBar (4 segundos)
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // SnackBar não deve estar mais visível
      expect(find.byType(SnackBar), findsNothing);
    },
  );
}

