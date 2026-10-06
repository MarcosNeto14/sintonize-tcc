import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const testEmail = 'tester@sintonize.test';
  const testPassword = 'senha123';

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  setUp(() async {
    await FirebaseAuth.instance.signOut();

    final playlists =
        await FirebaseFirestore.instance.collection('playlists').get();
    for (var doc in playlists.docs) {
      await doc.reference.delete();
    }
  });

  Future<void> navegarAteCriarPlaylist(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Tocar em "Login" na HomeScreen
    final loginBtnFinder = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginBtnFinder, findsOneWidget);
    await tester.tap(loginBtnFinder);
    await tester.pumpAndSettle();

    // 2. Preencher formulário de login
    final textFormFields = find.byType(TextFormField);
    expect(textFormFields, findsNWidgets(2));

    await tester.enterText(textFormFields.at(0), testEmail);
    await tester.enterText(textFormFields.at(1), testPassword);
    await tester.pumpAndSettle();

    // 3. Tocar em "Entrar"
    final entrarBtnFinder = find.widgetWithText(ElevatedButton, 'Entrar');
    await tester.ensureVisible(entrarBtnFinder);
    await tester.tap(entrarBtnFinder);
    await tester.pumpAndSettle();

    // 4. Na TelaInicialScreen, acessar "Minha Conta" no BottomNavigationBar
    final minhaContaFinder = find.text('Minha Conta');
    expect(minhaContaFinder, findsOneWidget);
    await tester.tap(minhaContaFinder);
    await tester.pumpAndSettle();

    // 5. Na UsuarioScreen, tocar em "Criar Playlist"
    final criarPlaylistFinder = find.text('Criar Playlist');
    expect(criarPlaylistFinder, findsOneWidget);
    await tester.tap(criarPlaylistFinder);
    await tester.pumpAndSettle();

    // 6. Confirma que a CriarPlaylistScreen está montada
    expect(find.text('Criando Playlist'), findsOneWidget);
  }

  testWidgets(
    'Cenário 1: Estados intermediários visíveis - indicador de carregamento e listagem',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final loginBtnFinder = find.widgetWithText(ElevatedButton, 'Login');
      await tester.tap(loginBtnFinder);
      await tester.pumpAndSettle();

      final textFormFields = find.byType(TextFormField);
      await tester.enterText(textFormFields.at(0), testEmail);
      await tester.enterText(textFormFields.at(1), testPassword);
      await tester.pumpAndSettle();

      final entrarBtnFinder = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(entrarBtnFinder);
      await tester.tap(entrarBtnFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Minha Conta'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Criar Playlist'));
      await tester.pump();

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('Bohemian Rhapsody'), findsOneWidget);
      expect(find.textContaining('Billie Jean'), findsOneWidget);
    },
  );

  testWidgets(
    'Cenário 2: Validação antes de salvar - nome vazio exibe SnackBar e não salva',
    (WidgetTester tester) async {
      await navegarAteCriarPlaylist(tester);

      final salvarBtnFinder =
          find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.ensureVisible(salvarBtnFinder);
      await tester.tap(salvarBtnFinder);
      await tester.pump();

      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Criando Playlist'), findsOneWidget);

      final playlistsSnapshot =
          await FirebaseFirestore.instance.collection('playlists').get();
      expect(playlistsSnapshot.docs.isEmpty, isTrue);
    },
  );

  testWidgets(
    'Cenário 3: Pesquisa e filtragem em tempo real da lista de músicas',
    (WidgetTester tester) async {
      await navegarAteCriarPlaylist(tester);

      final searchFieldFinder =
          find.widgetWithText(TextField, 'Pesquisar Música ou Artista');
      expect(searchFieldFinder, findsOneWidget);

      // 1. Filtra por título de música existente ('Bohemian')
      await tester.enterText(searchFieldFinder, 'bohemian');
      await tester.pumpAndSettle();

      expect(find.textContaining('Bohemian Rhapsody'), findsOneWidget);
      expect(find.textContaining('Billie Jean'), findsNothing);
      expect(find.textContaining('Take Five'), findsNothing);

      // 2. Filtra por nome do artista ('Bob Marley')
      await tester.enterText(searchFieldFinder, 'bob marley');
      await tester.pumpAndSettle();

      expect(find.textContaining('One Love'), findsOneWidget);
      expect(find.textContaining('Bohemian Rhapsody'), findsNothing);

      // 3. Limpa o campo de busca e assegura retorno das demais músicas
      await tester.enterText(searchFieldFinder, '');
      await tester.pumpAndSettle();

      expect(find.textContaining('Bohemian Rhapsody'), findsOneWidget);
      expect(find.textContaining('Billie Jean'), findsOneWidget);
      expect(find.textContaining('Take Five'), findsOneWidget);
    },
  );

  testWidgets(
    'Cenário 4: Fluxo de sucesso ponta a ponta - seleção, salvar e documento persistido',
    (WidgetTester tester) async {
      await navegarAteCriarPlaylist(tester);

      const nomePlaylist = 'Minhas Favoritas Rock e Pop';

      // 1. Digita o nome da playlist
      final nomeFieldFinder =
          find.widgetWithText(TextField, 'Nome da Playlist');
      await tester.enterText(nomeFieldFinder, nomePlaylist);
      await tester.pumpAndSettle();

      // 2. Seleciona a primeira música ('bohemian rhapsody')
      final checkboxBohemian = find.descendant(
        of: find.widgetWithText(ListTile, 'Bohemian Rhapsody - Queen'),
        matching: find.byType(IconButton),
      );
      expect(checkboxBohemian, findsOneWidget);
      await tester.tap(checkboxBohemian);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Bohemian Rhapsody - Queen'),
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      // Seleciona a segunda música ('billie jean')
      final checkboxBillie = find.descendant(
        of: find.widgetWithText(ListTile, 'Billie Jean - Michael Jackson'),
        matching: find.byType(IconButton),
      );
      expect(checkboxBillie, findsOneWidget);
      await tester.tap(checkboxBillie);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Billie Jean - Michael Jackson'),
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      // 3. Toca em "Salvar Playlist"
      final salvarBtnFinder =
          find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.ensureVisible(salvarBtnFinder);
      await tester.tap(salvarBtnFinder);
      await tester.pumpAndSettle();

      // 4. Confirma retorno à UsuarioScreen
      expect(find.text('Criando Playlist'), findsNothing);
      expect(find.text('Criar Playlist'), findsOneWidget);
      expect(find.textContaining('Bem-vindo(a)'), findsOneWidget);

      // 5. Validação direta da persistência no Cloud Firestore
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: currentUserId)
          .get();

      expect(querySnapshot.docs.length, 1);

      final playlistGravada = querySnapshot.docs.first.data();
      expect(playlistGravada['nome'], equals(nomePlaylist));
      expect(playlistGravada['userId'], equals(currentUserId));
      expect(playlistGravada['dataCriacao'], isA<Timestamp>());

      final List<dynamic> musicasGravadas = playlistGravada['musicas'];
      expect(musicasGravadas.length, equals(2));
      expect(musicasGravadas, contains('bohemian rhapsody'));
      expect(musicasGravadas, contains('billie jean'));
    },
  );
}

