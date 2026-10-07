<!-- Resposta do Gemini 3.8 Flash ao reparo 1, rodada FASE3-L4-COT, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome), segunda máquina (DESKTOP-6ETPO2H).
     Conversa: https://gemini.google.com/app/eec230273581473b -->

### Classificação da Causa Provável

**(A) O teste presume um comportamento que não é o especificado.**

---

### Análise da Causa

O teste falhou na asserção de transição para a `TelaInicialScreen`:

```text
Expected: exactly one matching candidate
Actual: _TypeWidgetFinder:<Found 0 widgets with type "TelaInicialScreen": []>

```

Observando o método `login` na `LoginScreen`:

```dart
Future<void> login(BuildContext context) async {
  if (!formKey.currentState!.validate()) {
    return;
  }

  final email = emailController.text.trim();
  final senha = senhaController.text.trim();

  try {
    final firebaseAuth = auth ?? FirebaseAuth.instance;
    await firebaseAuth.signInWithEmailAndPassword(email: email, password: senha);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TelaInicialScreen()),
    );
  } on FirebaseAuthException catch (e) {
    ...

```

Em um teste E2E com `integration_test` comunicando-se com o emulador real via rede local (`10.0.2.2:9099`), a chamada assíncrona `signInWithEmailAndPassword` e a consequente transição de rota (`pushReplacement`) ocorrem após o dispatch do evento de toque.

Um único `await tester.pumpAndSettle()` logo após o `tester.tap(entrarButton)` frequentemente se estabiliza **antes** do callback da Future do Firebase retornar, ou seja, enquanto a requisição HTTP/gRPC para o emulador de Auth ainda está em trânsito no event loop nativo/Dart. Como a rota ainda não mudou no exato instante em que o microtask queue esvaziou a primeira animação de clique, a asserção `expect(find.byType(TelaInicialScreen), findsOneWidget)` roda imediatamente e falha porque o app ainda está na `LoginScreen`.

Para aguardar chamadas assíncronas externas (como emuladores de rede/Firebase) sem alterar a aplicação, o teste precisa de uma espera explícita com retentativas/polling até que a rota de destino apareça na árvore (`pumpAndSettle` com timeouts ou `pump` em loop condicional).

Além disso, após o login, a `TelaInicialScreen` executa `fetchUserName()` e `fetchLastRecommendedMusic()` no Firestore (`10.0.2.2:8080`), o que também demanda tempo de resposta de I/O de rede assíncrono antes que o texto final seja exibido.

---

### Correção do Teste

Para resolver a condição de corrida sem enfraquecer o escopo nem alterar a aplicação, implementamos uma função auxiliar de espera por widget (`waitForWidget`) com timeout razoável para operações de rede local.

Substitua o arquivo `integration_test/fase3/login_flow_test.dart` pelo código corrigido abaixo:

```dart
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
    // Garante que não haja sessão residual entre execuções
    await FirebaseAuth.instance.signOut();
  });

  /// Aguarda a aparição de um Finder em chamadas assíncronas com emuladores
  Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
    // Faz o pump final para permitir que o expect lance a mensagem detalhada em caso de timeout
    await tester.pumpAndSettle();
  }

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

        // Aguarda a resposta do Firebase Auth e a transição de rota assíncrona
        final telaInicialFinder = find.byType(TelaInicialScreen);
        await waitForWidget(tester, telaInicialFinder);

        expect(find.byType(LoginScreen), findsNothing);
        expect(telaInicialFinder, findsOneWidget);

        // Aguarda os dados do Firestore carregarem no cabeçalho da TelaInicialScreen
        final recomendacaoTextFinder = find.textContaining(
          'Tester Sintonize, essa é a nossa recomendação',
        );
        await waitForWidget(tester, recomendacaoTextFinder);

        expect(recomendacaoTextFinder, findsOneWidget);
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

        final snackBarFinder = find.byType(SnackBar);
        await waitForWidget(tester, snackBarFinder);

        expect(snackBarFinder, findsOneWidget);

        final SnackBar snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
        expect(snackBarWidget.backgroundColor, Colors.red);

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

        final snackBarFinder = find.byType(SnackBar);
        await waitForWidget(tester, snackBarFinder);

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

```
