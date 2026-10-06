<!-- Resposta do Gemini 3.8 Flash à geração (iteração 0), rodada FASE3-E2E-FS-03_playlistFlow, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome).
     Conversa: https://gemini.google.com/app/53b3739a2f20ac9e -->

```dart
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

  /// Aguarda a aparição de um widget com polling periódico, evitando
  /// timeouts e lidando com operações assíncronas de rede/Firestore.
  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('Elemento não encontrado no tempo limite: $finder');
  }

  testWidgets(
      'Criar playlist: autentica, navega até CriarPlaylistScreen, seleciona músicas e salva no Firestore',
      (tester) async {
    // 1. Inicializa o aplicativo na tela inicial (boas-vindas)
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 2. Acessa a tela de Login a partir da HomeScreen
    final botaoLoginHome = find.widgetWithText(ElevatedButton, 'Login');
    await esperar(tester, botaoLoginHome);
    await tester.tap(botaoLoginHome);
    await esperar(tester, find.byType(LoginScreen));

    // 3. Preenche as credenciais do usuário de teste pré-populado
    final camposTextoLogin = find.byType(TextFormField);
    await tester.enterText(camposTextoLogin.at(0), 'tester@sintonize.test');
    await tester.enterText(camposTextoLogin.at(1), 'senha123');

    // 4. Executa o login e aguarda o redirecionamento para TelaInicialScreen
    final botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
    await tester.tap(botaoEntrar);
    await esperar(tester, find.byType(TelaInicialScreen));

    // 5. Navega até a UsuarioScreen através do item "Minha Conta" na barra inferior
    final abaMinhaConta = find.text('Minha Conta');
    await esperar(tester, abaMinhaConta);
    await tester.tap(abaMinhaConta);
    await esperar(tester, find.byType(UsuarioScreen));

    // 6. Clica na opção "Criar Playlist" dentro de UsuarioScreen
    final menuCriarPlaylist = find.text('Criar Playlist');
    await esperar(tester, menuCriarPlaylist);
    await tester.tap(menuCriarPlaylist);
    await esperar(tester, find.byType(CriarPlaylistScreen));

    // 7. Aguarda o carregamento das músicas do Firestore no ListView
    // A tela busca 'musica' e exibe formatado com 'Track Name - Artist Name'
    final primeiraMusica = find.textContaining('Bohemian Rhapsody');
    await esperar(tester, primeiraMusica);

    // 8. Digita o nome da nova playlist
    final campoNomePlaylist = find.widgetWithText(TextField, 'Nome da Playlist');
    await tester.enterText(campoNomePlaylist, 'Minhas Favoritas');
    await tester.pump();

    // 9. Marca checkboxes para incluir músicas na playlist
    // Seleciona as caixas de seleção da primeira e da segunda música da lista
    final checkboxesDesmarcados = find.byIcon(Icons.check_box_outline_blank);
    expect(checkboxesDesmarcados, findsWidgets);

    await tester.tap(checkboxesDesmarcados.first);
    await tester.pumpAndSettle();

    // Marca mais uma música
    await tester.tap(find.byIcon(Icons.check_box_outline_blank).first);
    await tester.pumpAndSettle();

    // Valida se os checkboxes marcados agora estão visíveis na tela
    expect(find.byIcon(Icons.check_box), findsNWidgets(2));

    // 10. Toca em "Salvar Playlist" para persistir no Firestore
    final botaoSalvarPlaylist =
        find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    await tester.tap(botaoSalvarPlaylist);

    // 11. Verifica retorno à UsuarioScreen e exibição da playlist criada na lista
    await esperar(tester, find.byType(UsuarioScreen));
    await esperar(tester, find.text('Minhas Favoritas'));

    // Valida se o card da playlist salva reflete a quantidade correta de músicas
    expect(find.text('2 músicas'), findsOneWidget);
  });
}

```