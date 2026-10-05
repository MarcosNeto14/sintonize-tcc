<!-- Resposta do Gemini 3.8 Flash à geração (iteração 0), tentativa 2 de 2026-10-05,
     como devolvida pelo autor (colagem do texto da resposta), sem edição. -->

Aqui está o arquivo de teste de integração end-to-end implementando todo o fluxo da LoginScreen, cobrindo validações de formulário, erros retornados pelo Firebase Auth (com validação do SnackBar vermelho e sua mensagem) e o caminho feliz com transição completa para a TelaInicialScreen.

Salve o arquivo em integration_test/fase3/login_test.dart:

Dart
// ===== integration_test/fase3/login_test.dart =====
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sintonize/main.dart';
import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';
import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  setUp(() async {
    // Garante que nenhum usuário permaneça logado entre os testes
    await FirebaseAuth.instance.signOut();
  });

  /// Helper para navegar da tela inicial (HomeScreen) até a LoginScreen.
  Future<void> navigateToLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // Aguarda animação de fade do logo na HomeScreen
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginButtonFinder, findsOneWidget);

    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  }

  group('Fluxo E2E - LoginScreen', () {
    testWidgets('Exibe mensagens de validação ao tentar submeter com campos vazios',
        (tester) async {
      await navigateToLoginScreen(tester);

      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarButton);
      await tester.pumpAndSettle();

      // Validações do FormState
      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
    });

    testWidgets('Exibe erro de validação ao inserir formato de e-mail inválido',
        (tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.first;
      final senhaField = textFields.last;

      await tester.enterText(emailField, 'email_invalido');
      await tester.enterText(senhaField, 'senha123');

      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarButton);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
    });

    testWidgets('Exibe SnackBar vermelho ao tentar login com usuário inexistente',
        (tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.first;
      final senhaField = textFields.last;

      await tester.enterText(emailField, 'inexistente@sintonize.test');
      await tester.enterText(senhaField, 'senha123');

      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarButton);
      // Aguarda resposta da rede/emulador e exibição do SnackBar
      await tester.pumpAndSettle();

      // No Firebase Auth moderno, e-mails inexistentes retornam 'user-not-found'
      // ou 'invalid-credential' para proteção contra enumeração de usuários
      final snackBarFinder = find.byType(SnackBar);
      expect(snackBarFinder, findsOneWidget);

      final snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBarWidget.backgroundColor, Colors.red);

      final userNotFoundMsg = find.text(
        'Usuário não encontrado. Verifique o e-mail e tente novamente.',
      );
      final invalidCredentialMsg = find.text(
        'As credenciais fornecidas são inválidas. Tente novamente.',
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              userNotFoundMsg.matches(widget) ||
              invalidCredentialMsg.matches(widget),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Exibe SnackBar vermelho ao errar a senha de um usuário cadastrado',
        (tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.first;
      final senhaField = textFields.last;

      // Usuário existente no emulador, com senha incorreta
      await tester.enterText(emailField, 'tester@sintonize.test');
      await tester.enterText(senhaField, 'senha_errada_123');

      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarButton);
      await tester.pumpAndSettle();

      final snackBarFinder = find.byType(SnackBar);
      expect(snackBarFinder, findsOneWidget);

      final snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBarWidget.backgroundColor, Colors.red);

      final wrongPasswordMsg = find.text(
        'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
      );
      final invalidCredentialMsg = find.text(
        'As credenciais fornecidas são inválidas. Tente novamente.',
      );

      // Compatível com 'wrong-password' e 'invalid-credential'
      expect(
        find.byWidgetPredicate(
          (widget) =>
              wrongPasswordMsg.matches(widget) ||
              invalidCredentialMsg.matches(widget),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Login com sucesso: navega para TelaInicialScreen e carrega dados',
        (tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.first;
      final senhaField = textFields.last;

      // Credenciais válidas existentes no emulador
      await tester.enterText(emailField, 'tester@sintonize.test');
      await tester.enterText(senhaField, 'senha123');

      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarButton);

      // Aguarda navegação e término das consultas assíncronas no Firestore (fetchUserName e recomendações)
      await tester.pumpAndSettle();

      // Confirma que a TelaInicialScreen foi carregada
      expect(find.byType(TelaInicialScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      // Verifica se o nome retornado do Firestore é exibido formatado
      expect(
        find.textContaining('Tester Sintonize, essa é a nossa recomendação'),
        findsOneWidget,
      );

      // Verifica elementos da barra de navegação inferior da TelaInicialScreen
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Minha Conta'), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsOneWidget);
    });
  });
}
Detalhes da Implementação
Configuração dos Emuladores: setupFirebaseEmulators() é invocado em setUpAll(), garantindo que todas as chamadas de rede no fluxo usem as portas locais 9099 e 8080.

Ciclo de Autenticação Limpo: O setUp() executa FirebaseAuth.instance.signOut() para evitar contaminação de sessão entre os testes.

Tratamento de Códigos Firebase: Considera que o Firebase Auth pode responder com invalid-credential, user-not-found ou wrong-password dependendo das políticas ativas do emulador.

Verificação de Estilos e Estados: Além de validar a presença das mensagens de erro e da tela destino, inspeciona se SnackBar.backgroundColor == Colors.red e se os dados obtidos da coleção usuarios são formatados e renderizados corretamente.
