<!-- Resposta do Gemini 3.8 Flash ao reparo 2, rodada FASE3-E2E-COT-01_loginFlow, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome).
     Conversa: https://gemini.google.com/app/60b70378ac678107 -->

### Classificação da Causa da Falha

**(A) O teste presume um comportamento que não é o especificado.**

---

### Análise Técnica da Falha

Examinando o log da falha:

```text
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _TextContainingWidgetFinder:<Found 0 widgets with text containing essa é a nossa
recomendação de música para você!: []>
   Which: means none were found but one was expected

```

1. **A navegação ocorreu com sucesso:**
A asserção anterior `expect(find.byType(TelaInicialScreen), findsOneWidget);` passou sem erros. Ou seja, o aplicativo autenticou no Firebase Auth emulator e navegou com sucesso para a `TelaInicialScreen`.
2. **Por que o texto não foi encontrado imediatamente:**
Na `TelaInicialScreen`, o texto `'..., essa é a nossa recomendação de música para você!'` é gerado dentro de um `FutureBuilder`:
```dart
FutureBuilder<String>(
  future: fetchUserName(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Text('Carregando...', ...);
    }
    if (snapshot.hasError) {
      return const Text('Erro ao carregar', ...);
    }
    return Text(
      '${_formatName(snapshot.data!)}, essa é a nossa recomendação de música para você!',
      ...
    );
  },
)

```


O método `fetchUserName()` realiza uma consulta de rede assíncrona ao emulador do Cloud Firestore (`FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get()`).
3. **O equívoco do teste:**
O helper `waitFor(tester, find.byType(TelaInicialScreen))` retornou no milissegundo em que a `TelaInicialScreen` foi inserida na árvore de widgets. Nesse momento inicial, a consulta ao Firestore ainda estava em trânsito pela rede, fazendo com que o `FutureBuilder` renderizasse `'Carregando...'`. O teste assumiu erroneamente que, ao encontrar a `TelaInicialScreen`, todos os `Futures` assíncronos do Firestore já teriam sido resolvidos, chamando a asserção imediatamente sem aguardar a conclusão de `fetchUserName()`.

---

### Correção do Teste

Utilizamos a função de espera `waitFor` também para aguardar a resolução do texto vindo da requisição assíncrona do Firestore antes de fazer o `expect`.

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
    await FirebaseAuth.instance.signOut();
  });

  /// Aguarda até que um Finder seja encontrado na árvore de widgets,
  /// lidando com latência assíncrona real de emuladores e transições de rotas.
  Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) {
        await tester.pumpAndSettle();
        return;
      }
    }
    throw TestFailure('Timeout aguardando por: $finder');
  }

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

      await tester.enterText(emailField, 'tester@sintonize.test');
      await tester.enterText(senhaField, 'senha123');
      await tester.tap(entrarButton);

      // Aguarda a autenticação e transição para a TelaInicialScreen
      await waitFor(tester, find.byType(TelaInicialScreen));

      expect(find.byType(TelaInicialScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);

      // Aguarda o FutureBuilder consultar o Firestore (fetchUserName) e renderizar a saudação
      final recomendacaoFinder =
          find.textContaining('essa é a nossa recomendação de música para você!');
      await waitFor(tester, recomendacaoFinder);

      expect(recomendacaoFinder, findsOneWidget);
    });

    testWidgets('Submissão com campos vazios deve exibir mensagens de validação síncrona',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarButton);
      await tester.pumpAndSettle();

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

      await waitFor(tester, find.byType(SnackBar));

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);

      final snackBarFinder = find.byType(SnackBar);
      expect(snackBarFinder, findsOneWidget);

      final snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBarWidget.backgroundColor, Colors.red);

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

      await waitFor(tester, find.byType(SnackBar));

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);

      final snackBarFinder = find.byType(SnackBar);
      expect(snackBarFinder, findsOneWidget);

      final snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBarWidget.backgroundColor, Colors.red);

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

```