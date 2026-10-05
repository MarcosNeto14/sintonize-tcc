// ===== integration_test/fase3/login_zs_test.dart =====
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

  Future<void> navigateToLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginButtonFinder, findsOneWidget);

    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  }

  /// Aguarda até que um Finder encontre ao menos um widget ou atinja o timeout.
  Future<void> waitForFinder(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 15),
    Duration step = const Duration(milliseconds: 200),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(step);
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    // Último pump para deixar a falha explícita na linha da asserção se não encontrar
    await tester.pump();
  }

  group('Fluxo E2E - LoginScreen', () {
    testWidgets('Exibe mensagens de validação ao tentar submeter com campos vazios',
        (tester) async {
      await navigateToLoginScreen(tester);

      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarButton);
      await tester.pumpAndSettle();

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

      final snackBarFinder = find.byType(SnackBar);
      await waitForFinder(tester, snackBarFinder);

      expect(snackBarFinder, findsOneWidget);

      final snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBarWidget.backgroundColor, Colors.red);

      const userNotFoundMsg =
          'Usuário não encontrado. Verifique o e-mail e tente novamente.';
      const invalidCredentialMsg =
          'As credenciais fornecidas são inválidas. Tente novamente.';

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              (widget.data == userNotFoundMsg ||
                  widget.data == invalidCredentialMsg),
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

      await tester.enterText(emailField, 'tester@sintonize.test');
      await tester.enterText(senhaField, 'senha_errada_123');

      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarButton);

      final snackBarFinder = find.byType(SnackBar);
      await waitForFinder(tester, snackBarFinder);

      expect(snackBarFinder, findsOneWidget);

      final snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBarWidget.backgroundColor, Colors.red);

      const wrongPasswordMsg =
          'Senha incorreta. Certifique-se de que está digitando a senha corretamente.';
      const invalidCredentialMsg =
          'As credenciais fornecidas são inválidas. Tente novamente.';

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              (widget.data == wrongPasswordMsg ||
                  widget.data == invalidCredentialMsg),
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

      await tester.enterText(emailField, 'tester@sintonize.test');
      await tester.enterText(senhaField, 'senha123');

      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarButton);

      // Aguarda a transição para a TelaInicialScreen após a autenticação assíncrona
      final telaInicialFinder = find.byType(TelaInicialScreen);
      await waitForFinder(tester, telaInicialFinder);

      expect(telaInicialFinder, findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      // Aguarda as consultas do Firestore completarem e renderizarem o nome
      final recomendacaoFinder = find.textContaining(
        'Tester Sintonize, essa é a nossa recomendação',
      );
      await waitForFinder(tester, recomendacaoFinder);

      expect(recomendacaoFinder, findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Minha Conta'), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsOneWidget);
    });
  });
}
