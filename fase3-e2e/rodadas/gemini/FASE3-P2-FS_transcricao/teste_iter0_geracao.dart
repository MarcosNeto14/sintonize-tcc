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

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 4```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/criar_playlist.dart';
import 'package:sintonize/login.dart';
import 'package:sintonize/main.dart';
import 'package:sintonize/tela-inicial.dart';
import 'package:sintonize/usuario.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('não apareceu: $finder');
  }

  testWidgets(
      'criar playlist: autentica, seleciona músicas, salva e valida persistência no Firestore',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Tela de Boas-vindas -> Navegar para LoginScreen
    final loginBtnFinder = find.widgetWithText(ElevatedButton, 'Login');
    await esperar(tester, loginBtnFinder);
    await tester.tap(loginBtnFinder);
    await esperar(tester, find.byType(LoginScreen));

    // 2. Preencher credenciais pré-populadas no emulador
    final emailField = find.byType(TextFormField).at(0);
    final senhaField = find.byType(TextFormField).at(1);

    await tester.enterText(emailField, 'tester@sintonize.test');
    await tester.enterText(senhaField, 'senha123');

    // Tocar no botão 'Entrar'
    final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
    await tester.tap(entrarBtn);

    // 3. Aguardar autenticação e navegação para a TelaInicialScreen
    await esperar(tester, find.byType(TelaInicialScreen));

    // 4. Navegar para a UsuarioScreen ("Minha Conta" no BottomNavigationBar)
    final minhaContaItem = find.text('Minha Conta');
    await esperar(tester, minhaContaItem);
    await tester.tap(minhaContaItem);
    await esperar(tester, find.byType(UsuarioScreen));

    // 5. Acessar a tela CriarPlaylistScreen
    final criarPlaylistBtn = find.text('Criar Playlist');
    await esperar(tester, criarPlaylistBtn);
    await tester.tap(criarPlaylistBtn);
    await esperar(tester, find.byType(CriarPlaylistScreen));

    // 6. Preencher o nome da playlist
    const nomePlaylist = 'Minhas Favoritas';
    final nomePlaylistField = find.widgetWithText(TextField, 'Nome da Playlist');
    await esperar(tester, nomePlaylistField);
    await tester.enterText(nomePlaylistField, nomePlaylist);

    // 7. Aguardar carregamento das músicas da coleção 'musica'
    // 'bohemian rhapsody' é formatada na interface como 'Bohemian Rhapsody'
    final musicaItemFinder = find.textContaining('Bohemian Rhapsody');
    await esperar(tester, musicaItemFinder);

    // Selecionar o checkbox da música encontrada
    final checkboxIconFinder = find.descendant(
      of: find.ancestor(of: musicaItemFinder, matching: find.byType(ListTile)),
      matching: find.byType(IconButton),
    );
    await tester.tap(checkboxIconFinder);
    await tester.pumpAndSettle();

    // Confirmar que o checkbox foi marcado
    expect(find.byIcon(Icons.check_box), findsWidgets);

    // 8. Tocar em "Salvar Playlist"
    final salvarBtnFinder = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    await tester.tap(salvarBtnFinder);

    // 9. Aguardar o retorno para a UsuarioScreen
    await esperar(tester, find.byType(UsuarioScreen));

    // 10. Validar na interface e diretamente no Firestore
    await esperar(tester, find.text(nomePlaylist));

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    expect(currentUid, isNotNull);

    final playlistQuery = await FirebaseFirestore.instance
        .collection('playlists')
        .where('userId', isEqualTo: currentUid)
        .where('nome', isEqualTo: nomePlaylist)
        .get();

    expect(playlistQuery.docs.isNotEmpty, isTrue);
    final playlistSalva = playlistQuery.docs.first.data();
    expect(playlistSalva['nome'], equals(nomePlaylist));
    expect(playlistSalva['musicas'], contains('bohemian rhapsody'));
  });
}
