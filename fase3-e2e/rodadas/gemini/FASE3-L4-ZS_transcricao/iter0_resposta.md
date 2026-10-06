<!-- Resposta do Gemini 3.8 Flash à geração (iteração 0), rodada FASE3-L4-ZS, 2026-10-05,
     como devolvida pelo autor (colagem do texto da resposta), sem edição.
     Prompt: FASE3-E2E-ZS-01_loginFlow.md.
     Conversa: https://gemini.google.com/app/ce109fc0d738e577?hl=pt-BR -->

Aqui está a implementação do teste de integração end-to-end com integration_test para o fluxo de autenticação e login do aplicativo Sintonize.

O arquivo deve ser salvo em integration_test/fase3/login_flow_test.dart.

Dart
// ===== integration_test/fase3/login_flow_test.dart =====
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
    // Garante que qualquer sessão anterior seja encerrada antes de cada teste
    await FirebaseAuth.instance.signOut();
  });

  tearDown(() async {
    await FirebaseAuth.instance.signOut();
  });

  /// Helper para navegar da HomeScreen inicial até a LoginScreen.
  Future<void> navigateToLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Encontra o botão "Login" na HomeScreen e toca nele
    final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginButtonFinder, findsOneWidget);

    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();

    // Assegura que a LoginScreen foi carregada
    expect(find.byType(LoginScreen), findsOneWidget);
  }

  group('Fluxo E2E - Autenticação / LoginScreen', () {
    testWidgets('Validação de formulário: exibe mensagens de erro com campos vazios',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      // Clica em "Entrar" com os campos em branco
      final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarBtn);
      await tester.pumpAndSettle();

      // Verifica os avisos disparados pelos validadores do TextFormField
      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Validação de formato: e-mail inválido e senha curta (< 6 caracteres)',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.at(0);
      final senhaField = textFields.at(1);

      await tester.enterText(emailField, 'emailinvalido');
      await tester.enterText(senhaField, '123');
      await tester.pumpAndSettle();

      final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarBtn);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Falha de login: usuário não cadastrado exibe SnackBar vermelho',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.at(0);
      final senhaField = textFields.at(1);

      // Credenciais inexistentes no Firebase Auth Emulator
      await tester.enterText(emailField, 'inexistente@sintonize.test');
      await tester.enterText(senhaField, 'senha123456');
      await tester.pumpAndSettle();

      final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarBtn);

      // Aguarda resposta do Firebase Emulator e animação do SnackBar
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // No Firebase Auth recente o erro retornado pode ser 'invalid-credential' ou 'user-not-found'
      final userNotFoundFinder = find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.');
      final invalidCredFinder = find.text('As credenciais fornecidas são inválidas. Tente novamente.');

      expect(
        find.byWidgetPredicate((widget) {
          if (widget is Text) {
            return widget.data == 'Usuário não encontrado. Verifique o e-mail e tente novamente.' ||
                   widget.data == 'As credenciais fornecidas são inválidas. Tente novamente.';
          }
          return false;
        }),
        findsOneWidget,
      );

      // Verifica se o SnackBar possui fundo vermelho conforme a regra da tela
      final snackBarWidget = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBarWidget.backgroundColor, Colors.red);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Falha de login: senha incorreta para usuário existente exibe SnackBar vermelho',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.at(0);
      final senhaField = textFields.at(1);

      // Usuário semeado nos emuladores, mas com senha errada
      await tester.enterText(emailField, 'tester@sintonize.test');
      await tester.enterText(senhaField, 'senha_errada_123');
      await tester.pumpAndSettle();

      final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarBtn);

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // No Auth moderno pode cair em 'wrong-password' ou 'invalid-credential'
      expect(
        find.byWidgetPredicate((widget) {
          if (widget is Text) {
            return widget.data == 'Senha incorreta. Certifique-se de que está digitando a senha corretamente.' ||
                   widget.data == 'As credenciais fornecidas são inválidas. Tente novamente.';
          }
          return false;
        }),
        findsOneWidget,
      );

      final snackBarWidget = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBarWidget.backgroundColor, Colors.red);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Sucesso no login: navega para TelaInicialScreen com usuário carregado',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.at(0);
      final senhaField = textFields.at(1);

      // Credenciais válidas populadas previamente no emulador
      await tester.enterText(emailField, 'tester@sintonize.test');
      await tester.enterText(senhaField, 'senha123');
      await tester.pumpAndSettle();

      final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarBtn);

      // Aguarda autenticação, transição de tela e requisições do Firestore na TelaInicialScreen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Valida que estamos na TelaInicialScreen e saímos da LoginScreen
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);

      // O usuário tester possui nome: 'tester sintonize'. A tela aplica formatação: "Tester Sintonize"
      expect(
        find.textContaining('Tester Sintonize, essa é a nossa recomendação de música para você!'),
        findsOneWidget,
      );

      // Confirma que os elementos da barra inferior da TelaInicialScreen estão presentes
      expect(find.text('Pesquisa Direta'), findsOneWidget);
      expect(find.text('Sintonizados'), findsOneWidget);
      expect(find.text('Minha Conta'), findsOneWidget);
    });
  });
}
Como executar
Certifique-se de que o emulador Android (emulator-5554) e os emuladores Firebase (Auth na porta 9099 e Firestore na 8080) estejam em execução e populados. Em seguida, execute:

Bash
flutter test integration_test/fase3/login_flow_test.dart -d emulator-5554
