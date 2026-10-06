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

    // 1. Navegar da HomeScreen para LoginScreen
    final loginBtnFinder = find.widgetWithText(ElevatedButton, 'Login');
    await esperar(tester, loginBtnFinder);
    await tester.tap(loginBtnFinder);
    await esperar(tester, find.byType(LoginScreen));

    // 2. Realizar login com as credenciais pré-populadas
    final emailField = find.byType(TextFormField).at(0);
    final senhaField = find.byType(TextFormField).at(1);

    await tester.enterText(emailField, 'tester@sintonize.test');
    await tester.enterText(senhaField, 'senha123');

    final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
    await tester.tap(entrarBtn);

    // 3. Aguardar autenticação e navegação para a TelaInicialScreen
    await esperar(tester, find.byType(TelaInicialScreen));

    // 4. Navegar para a UsuarioScreen via "Minha Conta"
    final minhaContaItem = find.text('Minha Conta');
    await esperar(tester, minhaContaItem);
    await tester.tap(minhaContaItem);
    await esperar(tester, find.byType(UsuarioScreen));

    // 5. Clicar em "Criar Playlist"
    final criarPlaylistBtn = find.text('Criar Playlist');
    await esperar(tester, criarPlaylistBtn);
    await tester.tap(criarPlaylistBtn);
    await esperar(tester, find.byType(CriarPlaylistScreen));

    // 6. Preencher o nome da playlist
    const nomePlaylist = 'Minhas Favoritas';
    final nomePlaylistField = find.widgetWithText(TextField, 'Nome da Playlist');
    await esperar(tester, nomePlaylistField);
    await tester.enterText(nomePlaylistField, nomePlaylist);
    await tester.pump(const Duration(milliseconds: 300));

    // 7. Aguardar o carregamento e renderização das músicas do Firestore
    final musicaItemFinder = find.textContaining('Bohemian Rhapsody');
    await esperar(tester, musicaItemFinder);

    // Encontrar o botão de checkbox correspondente à música dentro do seu ListTile
    final tileDaMusica = find.ancestor(
      of: musicaItemFinder,
      matching: find.byType(ListTile),
    );
    final checkboxIconFinder = find.descendant(
      of: tileDaMusica,
      matching: find.byType(IconButton),
    );

    // Tocar no checkbox para selecionar a música
    await tester.tap(checkboxIconFinder);
    await tester.pump(const Duration(milliseconds: 300));

    // Validar visualmente que o ícone de selecionado foi exibido
    expect(find.byIcon(Icons.check_box), findsWidgets);

    // 8. Tocar no botão "Salvar Playlist"
    final salvarBtnFinder = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    await esperar(tester, salvarBtnFinder);
    await tester.tap(salvarBtnFinder);

    // 9. Aguardar o retorno para UsuarioScreen
    await esperar(tester, find.byType(UsuarioScreen));

    // 10. Validar que a playlist criada aparece na lista da UsuarioScreen
    await esperar(tester, find.text(nomePlaylist));

    // 11. Validar diretamente na coleção 'playlists' do Firestore
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

