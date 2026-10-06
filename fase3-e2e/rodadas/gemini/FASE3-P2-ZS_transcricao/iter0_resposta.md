<!-- Resposta do Gemini 3.8 Flash à geração (iteração 0), rodada FASE3-P2-ZS, 2026-10-06,
     copiada pelo botão "Copiar" do Gemini (Markdown), sem edição. Envio e cópia automatizados (Claude in Chrome).
     Prompt: FASE3-E2E-ZS-03_playlistFlow.md.
     Conversa: https://gemini.google.com/app/a3fdf09e9875d979 -->

Aqui está o teste end-to-end implementado com o pacote `integration_test` do Flutter, cobrindo o fluxo completo e os cenários de sucesso e validação de erro.

O arquivo deve ser salvo em:
`integration_test/fase3/criar_playlist_test.dart`

```dart
// ===== integration_test/fase3/criar_playlist_test.dart =====
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

  tearDown(() async {
    // Garante deslogar após cada execução de teste
    await FirebaseAuth.instance.signOut();
  });

  /// Helper para navegar da HomeScreen até a CriarPlaylistScreen
  /// realizando login com as credenciais padrão do ambiente de testes.
  Future<void> navegarAteCriarPlaylist(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Toca no botão de 'Login' na HomeScreen
    final loginHomeBtn = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginHomeBtn, findsOneWidget);
    await tester.tap(loginHomeBtn);
    await tester.pumpAndSettle();

    // 2. Preenche credenciais e toca em 'Entrar'
    final emailField = find.byType(TextFormField).first;
    final senhaField = find.byType(TextFormField).last;

    await tester.enterText(emailField, 'tester@sintonize.test');
    await tester.enterText(senhaField, 'senha123');
    await tester.pumpAndSettle();

    final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
    await tester.tap(entrarBtn);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 3. Acessa "Minha Conta" no BottomNavigationBar (ícone de perfil / índice 3)
    final minhaContaTab = find.byIcon(Icons.person).last;
    await tester.tap(minhaContaTab);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 4. Clica em "Criar Playlist" na UsuarioScreen
    final criarPlaylistMenu = find.text('Criar Playlist');
    expect(criarPlaylistMenu, findsOneWidget);
    await tester.tap(criarPlaylistMenu);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Valida que estamos na CriarPlaylistScreen
    expect(find.text('Criando Playlist'), findsOneWidget);
  }

  testWidgets(
      'Não deve salvar playlist quando o campo nome estiver vazio e exibir SnackBar de erro',
      (WidgetTester tester) async {
    await navegarAteCriarPlaylist(tester);

    // Clica diretamente em "Salvar Playlist" sem digitar o nome
    final salvarBtn = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    expect(salvarBtn, findsOneWidget);
    await tester.tap(salvarBtn);
    await tester.pump();

    // Verifica a mensagem de validação exibida no SnackBar
    expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

    // Aguarda o SnackBar desaparecer
    await tester.pumpAndSettle();

    // Confirma que nenhuma playlist foi persistida
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final playlistsSnapshot = await FirebaseFirestore.instance
        .collection('playlists')
        .where('userId', isEqualTo: uid)
        .get();

    expect(playlistsSnapshot.docs.isEmpty, isTrue);
  });

  testWidgets(
      'Fluxo completo: busca músicas no Firestore, preenche nome, seleciona músicas, salva e valida persistência',
      (WidgetTester tester) async {
    await navegarAteCriarPlaylist(tester);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final String nomeDinamicoPlaylist =
        'Minhas Favoritas ${DateTime.now().millisecondsSinceEpoch}';

    // 1. Digita o nome dinâmico da playlist no primeiro TextField
    final nomePlaylistField = find.widgetWithText(TextField, 'Nome da Playlist');
    expect(nomePlaylistField, findsOneWidget);
    await tester.enterText(nomePlaylistField, nomeDinamicoPlaylist);
    await tester.pumpAndSettle();

    // 2. Aguarda e valida a lista de músicas carregadas da coleção 'musica'
    // Conforme o setup, Bohemian Rhapsody e Billie Jean estão disponíveis
    final musicaQueen = find.textContaining('Bohemian Rhapsody');
    final musicaJackson = find.textContaining('Billie Jean');

    expect(musicaQueen, findsOneWidget);
    expect(musicaJackson, findsOneWidget);

    // 3. Marca os checkboxes das músicas desejadas
    // Na CriarPlaylistScreen, o checkbox é um IconButton no trailing do ListTile
    final queenListTile = find.ancestor(
      of: musicaQueen,
      matching: find.byType(ListTile),
    );
    final queenCheckbox = find.descendant(
      of: queenListTile,
      matching: find.byType(IconButton),
    );
    await tester.tap(queenCheckbox);
    await tester.pumpAndSettle();

    final jacksonListTile = find.ancestor(
      of: musicaJackson,
      matching: find.byType(ListTile),
    );
    final jacksonCheckbox = find.descendant(
      of: jacksonListTile,
      matching: find.byType(IconButton),
    );
    await tester.tap(jacksonCheckbox);
    await tester.pumpAndSettle();

    // 4. Toca em "Salvar Playlist"
    final salvarBtn = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    await tester.ensureVisible(salvarBtn);
    await tester.tap(salvarBtn);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 5. Validação da UI: após salvar, a tela fecha (pop) e retorna para a UsuarioScreen
    expect(find.text('Criando Playlist'), findsNothing);
    expect(find.text('Criar Playlist'), findsOneWidget);
    expect(find.text(nomeDinamicoPlaylist), findsOneWidget);

    // 6. Validação direta no Firestore Emulator
    final snapshot = await FirebaseFirestore.instance
        .collection('playlists')
        .where('userId', isEqualTo: uid)
        .where('nome', isEqualTo: nomeDinamicoPlaylist)
        .get();

    expect(snapshot.docs.length, 1);

    final playlistCriada = snapshot.docs.first.data();
    expect(playlistCriada['userId'], uid);
    expect(playlistCriada['nome'], nomeDinamicoPlaylist);
    expect(playlistCriada['musicas'], isA<List>());

    final List<dynamic> musicasSalvas = playlistCriada['musicas'];
    expect(musicasSalvas, containsAll(['bohemian rhapsody', 'billie jean']));
    expect(playlistCriada['dataCriacao'], isNotNull);
  });
}

```

### Detalhes da Execução

1. **Ciclo de Vida e Emuladores**: O `setUpAll()` roda a rotina `setupFirebaseEmulators()`, ligando a instância ao Firebase Emulator Suite em `10.0.2.2`. Ao término de cada teste, o `tearDown` faz o logoff do usuário para evitar vazamento de estado.
2. **Navegação End-to-End**: A rotina `navegarAteCriarPlaylist` simula o usuário real desde a tela de splash/boas-vindas (`MyApp`), faz o preenchimento do formulário de login e navega pelo `BottomNavigationBar` até o menu `Criar Playlist`.
3. **Asserções de Banco de Dados**: A validação verifica o documento recém-criado em `playlists` associado ao `uid` do usuário autenticado, confirmando que o valor dinâmico (`nomeDinamicoPlaylist`) e as músicas selecionadas (`bohemian rhapsody` e `billie jean`) foram devidamente persistidos.
