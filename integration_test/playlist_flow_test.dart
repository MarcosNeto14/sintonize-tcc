import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/criar_playlist.dart';
import 'package:sintonize/main.dart';
import 'package:sintonize/tela-inicial.dart';
import 'package:sintonize/usuario.dart';

import 'firebase_test_helper.dart';
import 'pump_helpers.dart';
import 'seed.dart';

/// Fluxo de criar playlist (E2E-03 do roteiro manual,
/// `e2e-manual/E2E-03_criar_playlist.md`):
/// login com o usuário do seed → TelaInicialScreen → "Minha Conta"
/// (UsuarioScreen) → "Criar Playlist" → CriarPlaylistScreen → E1 (salvar sem
/// nome) → nome, pesquisa, seleção → "Salvar Playlist" → volta à
/// UsuarioScreen com a playlist listada; confere o doc em `playlists`.
///
/// A lista de músicas vem da coleção `musica` do seed (5 docs). O bug P2
/// (`itemCount` + 1) estoura exatamente aqui, no item de índice 5.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Nome único por execução: o emulador acumula uma playlist por run e a
  // UsuarioScreen lista todas as do usuário.
  final nomePlaylist =
      'Minha Playlist ${DateTime.now().millisecondsSinceEpoch}';

  setUpAll(() async {
    await setupFirebaseEmulators();
    await seedEmulators();
  });

  setUp(() async {
    await FirebaseAuth.instance.signOut();
  });

  /// Pré-condição do roteiro: usuário autenticado (E2E-02 antes). Faz o
  /// login pela UI, sem repetir as asserções do login_flow_test.
  Future<void> logarEAbrirCriarPlaylist(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), seedEmail);
    await tester.enterText(find.byType(TextFormField).at(1), seedSenha);
    await fecharTeclado(tester);
    await tester.tap(find.text('Entrar'));
    await pumpAte(tester, find.byType(TelaInicialScreen));

    // Passo 1: "Minha Conta" na barra inferior abre a UsuarioScreen.
    await tester.tap(find.text('Minha Conta'));
    await pumpAte(tester, find.byType(UsuarioScreen));
    await pumpAte(tester, find.text('Bem-vindo(a), $seedNome!'));

    // Passo 2: "Criar Playlist".
    await tester.tap(find.text('Criar Playlist'));
    await pumpAte(tester, find.byType(CriarPlaylistScreen));
    expect(find.text('Criando Playlist'), findsOneWidget);
    expect(find.text('Nome da Playlist'), findsOneWidget);
  }

  /// Passo 3: a lista substitui o CircularProgressIndicator.
  Future<void> esperarLista(WidgetTester tester) async {
    await pumpAte(tester, find.byType(ListTile));
    expect(find.byType(CircularProgressIndicator), findsNothing);
  }

  Finder campoNome() => find.byType(TextField).at(0);
  Finder campoPesquisa() => find.byType(TextField).at(1);

  testWidgets('lista carrega as 5 músicas do seed', (tester) async {
    await logarEAbrirCriarPlaylist(tester);
    await esperarLista(tester);
    expect(find.byType(ListTile), findsNWidgets(seedMusicas.length));
    expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outline_blank),
        findsNWidgets(seedMusicas.length));
    expect(find.byIcon(Icons.check_box), findsNothing);
  });

  testWidgets('E1: salvar sem nome mostra SnackBar e não salva',
      (tester) async {
    await logarEAbrirCriarPlaylist(tester);
    await esperarLista(tester);

    await tocarQuandoAlcancavel(tester, find.text('Salvar Playlist'));
    await pumpAte(tester, find.text('Nome da playlist é obrigatório'));
    expect(find.byType(CriarPlaylistScreen), findsOneWidget);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final salvas = await FirebaseFirestore.instance
        .collection('playlists')
        .where('userId', isEqualTo: uid)
        .get();
    expect(salvas.docs.where((d) => d['nome'] == null || d['nome'] == ''),
        isEmpty);
  });

  testWidgets('pesquisa filtra por música ou artista', (tester) async {
    await logarEAbrirCriarPlaylist(tester);
    await esperarLista(tester);

    // Passo 5: o filtro olha track_name e artist_name (não o gênero).
    await tester.enterText(campoPesquisa(), 'queen');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);

    await tester.enterText(campoPesquisa(), 'take');
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Take Five - Dave Brubeck'), findsOneWidget);

    // Passo 6, primeira parte: limpar a pesquisa devolve a lista inteira.
    // Contar com o teclado fechado: o ListView.builder é preguiçoso e, com o
    // viewport encolhido pelo teclado, só 3 dos 5 cards existem (run 1).
    await tester.enterText(campoPesquisa(), '');
    await fecharTeclado(tester);
    expect(find.byType(ListTile), findsNWidgets(seedMusicas.length));
  });

  testWidgets('criar playlist válida → volta à UsuarioScreen com ela listada',
      (tester) async {
    await logarEAbrirCriarPlaylist(tester);
    await esperarLista(tester);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Passo 4: nome.
    await tester.enterText(campoNome(), nomePlaylist);
    await tester.pumpAndSettle();

    // Passo 6: seleciona "Bohemian Rhapsody" (1º card) pelo ícone.
    await fecharTeclado(tester);
    final primeiroCheck = find.descendant(
      of: find.widgetWithText(ListTile, 'Bohemian Rhapsody - Queen'),
      matching: find.byIcon(Icons.check_box_outline_blank),
    );
    await tester.tap(primeiroCheck);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_box), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outline_blank),
        findsNWidgets(seedMusicas.length - 1));

    // Passo 7: salvar → grava em `playlists` e faz pop.
    // A UsuarioScreen já é encontrada durante a transição do pop (run 1),
    // então a espera é pela saída da CriarPlaylistScreen.
    await tocarQuandoAlcancavel(tester, find.text('Salvar Playlist'));
    await pumpAteSumir(tester, find.byType(CriarPlaylistScreen));
    expect(find.byType(UsuarioScreen), findsOneWidget);

    // Passo 8: a playlist aparece na lista (UsuarioScreen refaz o fetch no
    // retorno). O roteiro manual diz "TelaInicialScreen", mas o pop volta
    // para a UsuarioScreen, que é quem lista as playlists.
    await pumpAte(tester, find.text(nomePlaylist));
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, nomePlaylist),
        matching: find.text('1 músicas'),
      ),
      findsOneWidget,
    );

    // O que ficou no Firestore.
    final salvas = await FirebaseFirestore.instance
        .collection('playlists')
        .where('userId', isEqualTo: uid)
        .where('nome', isEqualTo: nomePlaylist)
        .get();
    expect(salvas.docs.length, 1);
    expect(salvas.docs.first['musicas'], ['bohemian rhapsody']);
    expect(salvas.docs.first['dataCriacao'], isA<Timestamp>());
  });
}
