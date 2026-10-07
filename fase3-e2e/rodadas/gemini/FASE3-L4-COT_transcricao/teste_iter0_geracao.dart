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
    // Garante que não haja sessão de usuário residual entre execuções
    await FirebaseAuth.instance.signOut();
  });

  /// Helper para navegar da HomeScreen inicial até a LoginScreen
  Future<void> navigateToLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final loginNavButton = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginNavButton, findsOneWidget);

    await tester.tap(loginNavButton);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  }

  group('Fluxo E2E - Autenticação na LoginScreen', () {
    testWidgets(
      'Cenário 1: Sucesso ponta a ponta - Credenciais válidas navegam para a TelaInicialScreen',
      (WidgetTester tester) async {
        await navigateToLoginScreen(tester);

        final textFields = find.byType(TextFormField);
        expect(textFields, findsNWidgets(2));

        final emailField = textFields.at(0);
        final senhaField = textFields.at(1);
        final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');

        await tester.enterText(emailField, 'tester@sintonize.test');
        await tester.enterText(senhaField, 'senha123');
        await tester.pumpAndSettle();

        await tester.tap(entrarButton);
        await tester.pumpAndSettle();

        // Confirma que a LoginScreen foi substituída pela TelaInicialScreen
        expect(find.byType(LoginScreen), findsNothing);
        expect(find.byType(TelaInicialScreen), findsOneWidget);

        // Verifica elementos populados a partir do Firestore/Auth do emulador
        expect(
          find.textContaining('Tester Sintonize, essa é a nossa recomendação'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Cenário 2: Validação - Erro ao submeter formulário com campos vazios',
      (WidgetTester tester) async {
        await navigateToLoginScreen(tester);

        final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');
        await tester.tap(entrarButton);
        await tester.pumpAndSettle();

        expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
        expect(find.text('Por favor, insira sua senha'), findsOneWidget);
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );

    testWidgets(
      'Cenário 3: Validação - Erro ao inserir formato inválido de e-mail',
      (WidgetTester tester) async {
        await navigateToLoginScreen(tester);

        final textFields = find.byType(TextFormField);
        final emailField = textFields.at(0);
        final senhaField = textFields.at(1);
        final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');

        await tester.enterText(emailField, 'email_sem_formato_valido');
        await tester.enterText(senhaField, 'senha123');
        await tester.pumpAndSettle();

        await tester.tap(entrarButton);
        await tester.pumpAndSettle();

        expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );

    testWidgets(
      'Cenário 4: Validação - Erro ao inserir senha com menos de 6 caracteres',
      (WidgetTester tester) async {
        await navigateToLoginScreen(tester);

        final textFields = find.byType(TextFormField);
        final emailField = textFields.at(0);
        final senhaField = textFields.at(1);
        final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');

        await tester.enterText(emailField, 'tester@sintonize.test');
        await tester.enterText(senhaField, '12345');
        await tester.pumpAndSettle();

        await tester.tap(entrarButton);
        await tester.pumpAndSettle();

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );

    testWidgets(
      'Cenário 5: Erro do Firebase - Senha incorreta exibe SnackBar vermelho',
      (WidgetTester tester) async {
        await navigateToLoginScreen(tester);

        final textFields = find.byType(TextFormField);
        final emailField = textFields.at(0);
        final senhaField = textFields.at(1);
        final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');

        await tester.enterText(emailField, 'tester@sintonize.test');
        await tester.enterText(senhaField, 'senhaIncorreta123');
        await tester.pumpAndSettle();

        await tester.tap(entrarButton);
        await tester.pumpAndSettle();

        // O Firebase Emulator pode retornar invalid-credential ou wrong-password dependendo da configuração
        final snackBarFinder = find.byType(SnackBar);
        expect(snackBarFinder, findsOneWidget);

        final SnackBar snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
        expect(snackBarWidget.backgroundColor, Colors.red);

        final mensagemErroPossivel = find.text(
          'As credenciais fornecidas são inválidas. Tente novamente.',
        );
        final mensagemSenhaIncorreta = find.text(
          'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
        );

        expect(
          find.byWidgetPredicate((widget) =>
              widget is Text &&
              (widget.data ==
                      'As credenciais fornecidas são inválidas. Tente novamente.' ||
                  widget.data ==
                      'Senha incorreta. Certifique-se de que está digitando a senha corretamente.')),
          findsOneWidget,
        );
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );

    testWidgets(
      'Cenário 6: Erro do Firebase - Usuário inexistente exibe SnackBar vermelho',
      (WidgetTester tester) async {
        await navigateToLoginScreen(tester);

        final textFields = find.byType(TextFormField);
        final emailField = textFields.at(0);
        final senhaField = textFields.at(1);
        final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');

        await tester.enterText(emailField, 'usuario_fantasma@sintonize.test');
        await tester.enterText(senhaField, 'qualquersenha123');
        await tester.pumpAndSettle();

        await tester.tap(entrarButton);
        await tester.pumpAndSettle();

        final snackBarFinder = find.byType(SnackBar);
        expect(snackBarFinder, findsOneWidget);

        final SnackBar snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
        expect(snackBarWidget.backgroundColor, Colors.red);

        expect(
          find.byWidgetPredicate((widget) =>
              widget is Text &&
              (widget.data ==
                      'Usuário não encontrado. Verifique o e-mail e tente novamente.' ||
                  widget.data ==
                      'As credenciais fornecidas são inválidas. Tente novamente.')),
          findsOneWidget,
        );
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );
  });
}

