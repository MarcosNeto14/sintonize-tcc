// ===== integration_test/fase3/l4_zs_test.dart =====
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
    await FirebaseAuth.instance.signOut();
  });

  tearDown(() async {
    await FirebaseAuth.instance.signOut();
  });

  /// Helper para aguardar a aparição de um widget com timeout explícito.
  Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (finder.evaluate().isNotEmpty) {
        await tester.pumpAndSettle();
        return;
      }
    }
    await tester.pumpAndSettle();
  }

  /// Helper para navegar da HomeScreen inicial até a LoginScreen.
  Future<void> navigateToLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginButtonFinder, findsOneWidget);

    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  }

  group('Fluxo E2E - Autenticação / LoginScreen', () {
    testWidgets(
        'Validação de formulário: exibe mensagens de erro com campos vazios',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(entrarBtn);
      await tester.pumpAndSettle();

      await tester.tap(entrarBtn);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets(
        'Validação de formato: e-mail inválido e senha curta (< 6 caracteres)',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.at(0);
      final senhaField = textFields.at(1);

      await tester.enterText(emailField, 'emailinvalido');
      await tester.enterText(senhaField, '123');
      await tester.pumpAndSettle();

      final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(entrarBtn);
      await tester.pumpAndSettle();

      await tester.tap(entrarBtn);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets(
        'Falha de login: usuário não cadastrado exibe SnackBar vermelho',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.at(0);
      final senhaField = textFields.at(1);

      await tester.enterText(emailField, 'inexistente@sintonize.test');
      await tester.enterText(senhaField, 'senha123456');
      await tester.pumpAndSettle();

      // Esconde o teclado virtual e rola até o botão
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(entrarBtn);
      await tester.pumpAndSettle();

      await tester.tap(entrarBtn);

      await waitForWidget(tester, find.byType(SnackBar));

      expect(
        find.byWidgetPredicate((widget) {
          if (widget is Text) {
            return widget.data ==
                    'Usuário não encontrado. Verifique o e-mail e tente novamente.' ||
                widget.data ==
                    'As credenciais fornecidas são inválidas. Tente novamente.';
          }
          return false;
        }),
        findsOneWidget,
      );

      final snackBarWidget = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBarWidget.backgroundColor, Colors.red);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets(
        'Falha de login: senha incorreta para usuário existente exibe SnackBar vermelho',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.at(0);
      final senhaField = textFields.at(1);

      await tester.enterText(emailField, 'tester@sintonize.test');
      await tester.enterText(senhaField, 'senha_errada_123');
      await tester.pumpAndSettle();

      // Esconde o teclado virtual e rola até o botão
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(entrarBtn);
      await tester.pumpAndSettle();

      await tester.tap(entrarBtn);

      await waitForWidget(tester, find.byType(SnackBar));

      expect(
        find.byWidgetPredicate((widget) {
          if (widget is Text) {
            return widget.data ==
                    'Senha incorreta. Certifique-se de que está digitando a senha corretamente.' ||
                widget.data ==
                    'As credenciais fornecidas são inválidas. Tente novamente.';
          }
          return false;
        }),
        findsOneWidget,
      );

      final snackBarWidget = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBarWidget.backgroundColor, Colors.red);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets(
        'Sucesso no login: navega para TelaInicialScreen com usuário carregado',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.at(0);
      final senhaField = textFields.at(1);

      await tester.enterText(emailField, 'tester@sintonize.test');
      await tester.enterText(senhaField, 'senha123');
      await tester.pumpAndSettle();

      // Esconde o teclado virtual e rola para garantir visibilidade do botão
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(entrarBtn);
      await tester.pumpAndSettle();

      await tester.tap(entrarBtn);

      // Aguarda a resolução do login e a transição para TelaInicialScreen
      await waitForWidget(tester, find.byType(TelaInicialScreen));

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);

      // Aguarda a resolução dos dados do usuário vindo do Firestore
      final recomendacaoFinder = find.textContaining(
        'Tester Sintonize, essa é a nossa recomendação de música para você!',
      );
      await waitForWidget(tester, recomendacaoFinder);

      expect(recomendacaoFinder, findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsOneWidget);
      expect(find.text('Sintonizados'), findsOneWidget);
      expect(find.text('Minha Conta'), findsOneWidget);
    });
  });
}
