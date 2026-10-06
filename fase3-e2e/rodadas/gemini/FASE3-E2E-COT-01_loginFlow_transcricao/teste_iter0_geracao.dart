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
    // Garante que nenhum usuário permaneça autenticado entre os testes
    await FirebaseAuth.instance.signOut();
  });

  /// Helper para navegar da HomeScreen até a LoginScreen aguardando as transições.
  Future<void> navigateToLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginButtonFinder, findsOneWidget);

    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  }

  group('Fluxo E2E - Autenticação na LoginScreen', () {
    testWidgets('Login com sucesso deve redirecionar para a TelaInicialScreen',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      final emailField = textFields.at(0);
      final senhaField = textFields.at(1);
      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');

      // Preenche credenciais válidas do usuário pré-populado
      await tester.enterText(emailField, 'tester@sintonize.test');
      await tester.enterText(senhaField, 'senha123');
      await tester.tap(entrarButton);

      // Aguarda resposta do Auth emulator e carregamento da TelaInicialScreen
      await tester.pumpAndSettle();

      expect(find.byType(TelaInicialScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(
        find.textContaining('essa é a nossa recomendação de música para você!'),
        findsOneWidget,
      );
    });

    testWidgets('Submissão com campos vazios deve exibir mensagens de validação síncrona',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarButton);
      await tester.pumpAndSettle();

      // Validação local impede avanço e não aciona Firebase
      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Submissão com e-mail mal formatado e senha curta exibe mensagens de validação',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.at(0);
      final senhaField = textFields.at(1);
      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');

      await tester.enterText(emailField, 'emailinvalido');
      await tester.enterText(senhaField, '123');
      await tester.tap(entrarButton);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Tentativa de login com senha incorreta exibe SnackBar de erro vermelho',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.at(0);
      final senhaField = textFields.at(1);
      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');

      await tester.enterText(emailField, 'tester@sintonize.test');
      await tester.enterText(senhaField, 'senhaErrada123');
      await tester.tap(entrarButton);
      await tester.pumpAndSettle();

      // Valida permanência na tela de login
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);

      // Valida exibição do SnackBar vermelho
      final snackBarFinder = find.byType(SnackBar);
      expect(snackBarFinder, findsOneWidget);

      final snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBarWidget.backgroundColor, Colors.red);

      // Firebase Auth pode retornar 'wrong-password' ou a especificação mais recente 'invalid-credential'
      final hasWrongPasswordMsg = find.text(
        'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
      );
      final hasInvalidCredentialMsg = find.text(
        'As credenciais fornecidas são inválidas. Tente novamente.',
      );

      expect(
        find.byWidgetPredicate((widget) =>
            widget is Text &&
            (widget.data == 'Senha incorreta. Certifique-se de que está digitando a senha corretamente.' ||
             widget.data == 'As credenciais fornecidas são inválidas. Tente novamente.')),
        findsOneWidget,
      );
    });

    testWidgets('Tentativa de login com usuário inexistente exibe SnackBar de erro vermelho',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.at(0);
      final senhaField = textFields.at(1);
      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');

      await tester.enterText(emailField, 'usuario_fantasma@sintonize.test');
      await tester.enterText(senhaField, 'senha123');
      await tester.tap(entrarButton);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);

      final snackBarFinder = find.byType(SnackBar);
      expect(snackBarFinder, findsOneWidget);

      final snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBarWidget.backgroundColor, Colors.red);

      // Trata retorno tanto para 'user-not-found' quanto 'invalid-credential'
      expect(
        find.byWidgetPredicate((widget) =>
            widget is Text &&
            (widget.data == 'Usuário não encontrado. Verifique o e-mail e tente novamente.' ||
             widget.data == 'As credenciais fornecidas são inválidas. Tente novamente.')),
        findsOneWidget,
      );
    });
  });
}

