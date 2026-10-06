<!-- Resposta do Gemini 3.8 Flash à geração (iteração 0), rodada 9, 2026-10-05,
     como devolvida pelo autor (colagem do texto da resposta), sem edição.
     Conversa: https://gemini.google.com/app/402bbd7ee33b0a3b?hl=pt-BR -->

Aqui está a implementação completa do teste de integração end-to-end com o pacote integration_test, cobrindo o fluxo com sucesso (persistência real no Firestore validada) e o cenário de validação/erro ao tentar salvar sem nome.

O arquivo pode ser salvo em:

integration_test/fase3/criar_playlist_test.dart

Dart
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
    // Garante logout após cada teste para manter isolamento de sessão
    await FirebaseAuth.instance.signOut();
  });

  /// Helper para navegar da tela inicial até a CriarPlaylistScreen realizando login
  Future<void> navegarAteCriarPlaylist(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 1. Toca no botão de Login na tela de boas-vindas
    final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginButtonFinder, findsOneWidget);
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();

    // 2. Preenche e-mail e senha cadastrados nos emuladores
    final emailFieldFinder = find.byType(TextFormField).at(0);
    final senhaFieldFinder = find.byType(TextFormField).at(1);

    await tester.enterText(emailFieldFinder, 'tester@sintonize.test');
    await tester.enterText(senhaFieldFinder, 'senha123');
    await tester.pumpAndSettle();

    // 3. Toca em "Entrar" para logar e aguarda navegação para a TelaInicialScreen
    final entrarButtonFinder = find.widgetWithText(ElevatedButton, 'Entrar');
    await tester.tap(entrarButtonFinder);
    await tester.pumpAndSettle();

    // Aguarda o carregamento dos dados da tela inicial
    expect(find.text('Minha Conta'), findsOneWidget);

    // 4. Toca em "Minha Conta" no BottomNavigationBar para ir para a UsuarioScreen
    await tester.tap(find.text('Minha Conta'));
    await tester.pumpAndSettle();

    // Aguarda carregar dados do usuário na UsuarioScreen
    expect(find.text('Criar Playlist'), findsOneWidget);

    // 5. Toca no item "Criar Playlist"
    await tester.tap(find.text('Criar Playlist'));
    await tester.pumpAndSettle();

    // Confirma que a CriarPlaylistScreen foi aberta
    expect(find.text('Criando Playlist'), findsOneWidget);
  }

  testWidgets(
    'Não deve salvar playlist quando o nome estiver vazio e deve exibir snackbar de erro',
    (WidgetTester tester) async {
      await navegarAteCriarPlaylist(tester);

      // Quantidade de playlists inicial antes da tentativa
      final user = FirebaseAuth.instance.currentUser!;
      final playlistsAntes = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: user.uid)
          .get();

      // Deixa o nome da playlist vazio e seleciona uma música
      // As músicas vêm da coleção 'musica' populada no Firestore
      final primeiroCheckbox = find.byIcon(Icons.check_box_outline_blank).first;
      await tester.tap(primeiroCheckbox);
      await tester.pumpAndSettle();

      // Toca em "Salvar Playlist"
      final salvarBtn = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.ensureVisible(salvarBtn);
      await tester.tap(salvarBtn);
      await tester.pumpAndSettle();

      // Verifica exibição do SnackBar de validação
      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

      // Garante que continuamos na tela de criação (não fechou com pop)
      expect(find.text('Criando Playlist'), findsOneWidget);

      // Confirma que nenhum documento foi criado no Firestore
      final playlistsDepois = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: user.uid)
          .get();

      expect(playlistsDepois.docs.length, equals(playlistsAntes.docs.length));
    },
  );

  testWidgets(
    'Deve buscar músicas, criar playlist com músicas selecionadas e persistir no Firestore associada ao usuário',
    (WidgetTester tester) async {
      await navegarAteCriarPlaylist(tester);

      final user = FirebaseAuth.instance.currentUser!;
      final String nomeDinamicoPlaylist =
          'Playlist Teste ${DateTime.now().millisecondsSinceEpoch}';

      // 1. Digita o nome da playlist no TextField correspondente
      final nomePlaylistInput = find.widgetWithText(TextField, 'Nome da Playlist');
      expect(nomePlaylistInput, findsOneWidget);
      await tester.enterText(nomePlaylistInput, nomeDinamicoPlaylist);
      await tester.pumpAndSettle();

      // 2. Aguarda a lista de músicas do Firestore carregar na UI
      // As músicas populadas têm nomes formatados por _formatName (ex: 'Bohemian Rhapsody')
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ListTile), findsWidgets);

      // 3. Seleciona duas músicas marcando os checkboxes
      final iconesCheckbox = find.byIcon(Icons.check_box_outline_blank);
      expect(iconesCheckbox, findsWidgets);

      // Marca a primeira música
      await tester.tap(iconesCheckbox.at(0));
      await tester.pumpAndSettle();

      // Marca a segunda música
      await tester.tap(iconesCheckbox.at(1));
      await tester.pumpAndSettle();

      // Verifica se os ícones mudaram para checked
      expect(find.byIcon(Icons.check_box), findsNWidgets(2));

      // 4. Rola até o botão "Salvar Playlist" e clica nele
      final salvarBtn = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.ensureVisible(salvarBtn);
      await tester.tap(salvarBtn);
      await tester.pumpAndSettle();

      // 5. Após salvar com sucesso, deve dar pop voltando para a UsuarioScreen
      expect(find.text('Criando Playlist'), findsNothing);
      expect(find.text('Criar Playlist'), findsOneWidget);

      // 6. Validação ponta a ponta direta no Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: user.uid)
          .where('nome', isEqualTo: nomeDinamicoPlaylist)
          .get();

      expect(querySnapshot.docs.length, equals(1),
          reason: 'A playlist deve ter sido persistida com o nome digitado');

      final dadosPlaylist = querySnapshot.docs.first.data();
      expect(dadosPlaylist['userId'], equals(user.uid));
      expect(dadosPlaylist['nome'], equals(nomeDinamicoPlaylist));
      expect(dadosPlaylist['musicas'], isA<List>());

      final List<dynamic> musicasSalvas = dadosPlaylist['musicas'];
      expect(musicasSalvas.length, equals(2),
          reason: 'A playlist deve conter exatamente as duas músicas marcadas');
      expect(dadosPlaylist['dataCriacao'], isA<Timestamp>());

      // 7. Validação visual na lista da UsuarioScreen
      // A UsuarioScreen recarrega as playlists após o pop e exibe o nome salvo
      await tester.pumpAndSettle();
      expect(find.text(nomeDinamicoPlaylist), findsOneWidget);
      expect(find.text('2 músicas'), findsOneWidget);
    },
  );
}
Principais pontos cobertos:
Configuração de Emulador: Usa o setupFirebaseEmulators() no setUpAll() e fecha a sessão do Auth no tearDown().

Navegação Real: Inicia em MyApp() na raiz, transita por HomeScreen → LoginScreen (com login das credenciais do seed) → TelaInicialScreen → UsuarioScreen → CriarPlaylistScreen.

Cenário Negativo: Tenta submeter sem nome, verifica o SnackBar 'Nome da playlist é obrigatório', a permanência na tela e a ausência de mutação no Firestore.

Cenário Positivo & Firestore: Preenche um nome dinâmico com timestamp, seleciona dois checkboxes de músicas reais vindas da coleção musica, salva, valida o retorno para a tela anterior e consulta o documento criado em playlists checando userId, nome, a lista musicas e dataCriacao.
