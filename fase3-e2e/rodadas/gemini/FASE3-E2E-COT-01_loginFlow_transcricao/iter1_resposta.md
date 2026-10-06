<!-- Resposta do Gemini 3.8 Flash ao reparo 1, rodada FASE3-E2E-COT-01_loginFlow, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome).
     Conversa: https://gemini.google.com/app/60b70378ac678107 -->

### Classificação da Causa da Falha

**(B) O teste capturou um comportamento potencialmente incorreto da aplicação.**

---

### Diagnóstico e Análise do Problema

#### 1. Comportamento Observado

* Durante a execução do primeiro teste (`Login com sucesso deve redirecionar para a TelaInicialScreen`), o teste disparou o clique no botão "Entrar" e executou `await tester.pumpAndSettle()`.
* A asserção `expect(find.byType(TelaInicialScreen), findsOneWidget);` falhou imediatamente com 0 ocorrências encontradas (`Found 0 widgets with type "TelaInicialScreen"`).
* Logo após a conclusão com falha do teste, o Flutter Framework lançou a seguinte exceção de ciclo de vida assíncrono:
```text
Looking up a deactivated widget's ancestor is unsafe.
At this point the state of the widget's element tree is no longer stable.
...
#3 Navigator.of (package:flutter/src/widgets/navigator.dart:2925:32)
#4 Navigator.pushReplacement (package:flutter/src/widgets/navigator.dart:2405:22)
#5 LoginScreen.build.login (package:sintonize/login.dart:34:19)

```



#### 2. Comportamento Esperado

Após a confirmação da autenticação com o Firebase Auth (`signInWithEmailAndPassword`), o aplicativo deveria executar o `Navigator.pushReplacement(...)` utilizando um `BuildContext` válido e ativo na árvore de widgets, realizando a transição da `LoginScreen` para a `TelaInicialScreen`.

#### 3. Por que isso indica um problema na aplicação

Ao analisar a implementação de `lib/login.dart`:

```dart
class LoginScreen extends StatelessWidget {
  ...
  @override
  Widget build(BuildContext context### Classificação da Causa Provável

**(A) O teste presume um comportamento que não é o especificado.**

---

### Análise Técnica da Falha

Examinando a stack trace:
1. `Actual: _TypeWidgetFinder:<Found 0 widgets with type "TelaInicialScreen": []>` na linha de verificação.
2. Logo em seguida, ocorre uma exceção assíncrona após o término do teste:

```

Looking up a deactivated widget's ancestor is unsafe.
...
#3 Navigator.of
#4 Navigator.pushReplacement
#5 LoginScreen.build.login (package:sintonize/login.dart:34:19)

```

**O que aconteceu:**
* A chamada de rede para o emulador do Firebase (`signInWithEmailAndPassword`) é assíncrona e demorou mais do que o ciclo de frames processado por um único `await tester.pumpAndSettle()`.
* O `pumpAndSettle()` encerrou prematuramente porque naquele instante a animação da interface havia parado enquanto aguardava o Future do Firebase Auth resolver.
* O teste imediatamente executou a asserção `expect(find.byType(TelaInicialScreen), findsOneWidget);` antes do término do Future, falhando com 0 widgets encontrados.
* O teste foi finalizado e desmontado; milissegundos depois, o Future da rede completou no emulador e tentou rodar `Navigator.pushReplacement(context, ...)`, mas o `context` da `LoginScreen` já estava desativado/destruído pelo framework de teste, gerando o erro de *deactivated widget's ancestor*.

Para testes E2E reais contra emuladores de rede, é necessário aguardar explicitamente a conclusão da operação assíncrona com `pump` ou polling até que o widget de destino apareça antes de invocar `pumpAndSettle()`.

---

### Correção do Teste

Adicionamos uma função utilitária de espera explícita (`waitFor`) para aguardar a resolução assíncrona da rede no emulador antes de realizar as asserções finais.

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

   // Aguarda a resolução assíncrona do Firebase Auth no emulador e a navegação
   await waitFor(tester, find.byType(TelaInicialScreen));

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