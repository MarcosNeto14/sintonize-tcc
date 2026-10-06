<!-- Resposta do Gemini 3.8 Flash ao reparo 2, rodada FASE3-L4-ZS, 2026-10-05,
     como devolvida pelo autor (colagem do texto da resposta), sem edição.
     Conversa: https://gemini.google.com/app/ce109fc0d738e577?hl=pt-BR -->

Classificação da Causa Provável
(A) O teste presume um comportamento que não é o especificado.

Análise da Falha
No código da LoginScreen:

Dart
return Scaffold(
  backgroundColor: Colors.white,
  body: SingleChildScrollView(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 50),
              Image.asset('assets/logo-sintoniza.png', ...), // 200px
              const SizedBox(height: 10),
              Card(
                child: Container(
                  child: Column(
                    children: [
                      // E-mail (label + campo + espaçamento)
                      // Senha (label + campo + espaçamento)
                      // Botão Entrar (50px)
                      // Botão Esqueci minha senha
                      // Botão Não tem cadastro?
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
O botão "Entrar" está fora da viewport visível no emulador Android:
A árvore da tela está dentro de um SingleChildScrollView. Com a logo de 200px, espaçamentos e campos de texto, a altura total ultrapassa a viewport visível do emulador (emulator-5554), especialmente quando o teclado de software esteve ativo.

tester.tap() não rola automaticamente:
O método tester.tap(find.widgetWithText(ElevatedButton, 'Entrar')) tenta despachar o evento de toque no centro das coordenadas do widget. Como o botão "Entrar" está fora da área visível na tela (abaixo do viewport da SingleChildScrollView), o toque atinge uma coordenada não interativa ou é ignorado pelo framework, fazendo com que o callback onPressed nunca seja disparado.

Por que os testes anteriores de validação e erro funcionaram?
Nos testes de validação com campos vazios ou formatos inválidos, a tela não tinha sofrido tanta interação e os campos estavam no topo. No teste com o usuário de sucesso, após digitar o e-mail e a senha, o scroll offset permaneceu onde o foco estava, deixando o botão "Entrar" fora do visor.

Solução padrão no Flutter Widget/Integration Test:
Sempre que um elemento estiver contido em uma lista com scroll (SingleChildScrollView, ListView), deve-se usar await tester.ensureVisible(finder) ou await tester.scrollUntilVisible(...) antes de interagir com ele com tester.tap().

Correção do Teste
Adicionamos await tester.ensureVisible(entrarBtn); antes de cada tester.tap(entrarBtn);, garantindo que o botão esteja visível na tela e receba o evento de clique.

Dart
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
