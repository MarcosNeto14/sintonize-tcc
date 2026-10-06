<!-- Resposta do Gemini 3.8 Flash ao reparo 2, rodada FASE3-L4-FS, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome).
     Conversa: https://gemini.google.com/app/97eb647a54bf7405 -->

**Classificação da causa provável:**
**(A) o teste presume um comportamento que não é o especificado.**

---

### Análise da Falha

Examinando a implementação de `lib/login.dart`:

```dart
Future<void> login(BuildContext context) async {
  if (!formKey.currentState!.validate()) {
    return;
  }

  final email = emailController.text.trim();
  final senha = senhaController.text.trim();
  // ...

```

E os validadores:

```dart
// E-mail:
if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) { ... }

// Senha:
if (value.length < 6) { ... }

```

O problema está na forma como o teste preencheu os campos e interagiu com a tela:

1. `find.byType(TextFormField)`: No Flutter, um `TextFormField` renderiza internamente uma árvore de widgets onde `enterText` pode ter como alvo múltiplos nós ou não propagar o evento de mudança se múltiplos campos responderem ou se o foco não estiver ativo. Além disso, ao usar `camposTexto.at(0)` e `camposTexto.at(1)` sem fechar o teclado do dispositivo (`tester.testTextInput.hide()` ou `FocusManager.instance.primaryFocus?.unfocus()`), o teclado virtual permanece aberto cobrindo o botão ou mantendo o scroll deslocado.
2. Na chamada `await tester.tap(botaoEntrar); await tester.pump();`, o `tester.pump()` avança apenas um frame. Em testes de integração com o emulador Firebase (onde há chamadas de rede assíncronas reais), `Navigator.pushReplacement` cria animações de transição de rota (`PageRouteBuilder` ou `MaterialPageRoute`). Se o loop `esperar` roda apenas com `pump(Duration(milliseconds: 250))` enquanto a transição de rota ainda está pendente ou o Future assíncrono de `signInWithEmailAndPassword` conclui no loop de microtasks, a transição pode travar se o frame não for disparado adequadamente.
3. Mais importante: em `HomeScreen`, o botão que abre a `LoginScreen` é:

```dart
SizedBox(
  width: 250,
  height: 50,
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        PageRouteBuilder(...), // Animação de SlideTransition com duração padrão (300ms)
      );
    },
    child: Row(
      children: [
        Icon(Icons.login),
        Text('Login'),
      ],
    ),
  ),
)

```

E na `LoginScreen`, o botão de submissão é:

```dart
ElevatedButton(
  onPressed: () => login(context),
  child: const Text('Entrar'),
)

```

Se `await tester.tap(find.text('Entrar'))` for chamado enquanto a transição de entrada (`SlideTransition`) ainda não terminou completamente ou o teclado virtual está sobrepondo a viewport móvel do emulador Android (AVD `emulator-5554`), o tap atinge coordenadas fora da tela ou é ignorado. Usar `tester.pumpAndSettle()` logo após o preenchimento, fechar o teclado virtual (`FocusScope.of(context).unfocus()`), e garantir que o formulário foi realmente submetido resolve o problema de forma determinística.

---

### Teste Corrigido

```dart
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

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('Elemento não apareceu a tempo: $finder');
  }

  testWidgets(
    'Login: falha ao autenticar exibe SnackBar vermelho com mensagem de erro',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navega da HomeScreen para a LoginScreen
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);

      // Preenche os campos com credenciais incorretas
      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'usuario_inexistente@sintonize.test');
      await tester.enterText(campos.at(1), 'senhaInvalida123');

      // Fecha o teclado virtual para não cobrir o botão nem afetar o layout
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Rola até o botão "Entrar" e clica
      final botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(botaoEntrar);
      await tester.pumpAndSettle();
      await tester.tap(botaoEntrar);
      await tester.pump();

      // Aguarda o aparecimento do SnackBar na tela
      final snackBarFinder = find.byType(SnackBar);
      await esperar(tester, snackBarFinder);

      final SnackBar snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBarWidget.backgroundColor, Colors.red);

      final mensagemEncontrada = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data ==
                    'Usuário não encontrado. Verifique o e-mail e tente novamente.' ||
                widget.data ==
                    'As credenciais fornecidas são inválidas. Tente novamente.' ||
                widget.data ==
                    'Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
      );
      expect(mensagemEncontrada, findsOneWidget);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    },
  );

  testWidgets(
    'Login: sucesso ao autenticar redireciona para a TelaInicialScreen',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navega da HomeScreen para a LoginScreen
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);

      // Preenche os campos com credenciais válidas do emulador
      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'tester@sintonize.test');
      await tester.enterText(campos.at(1), 'senha123');

      // Fecha o teclado virtual para garantir visão desobstruída
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Rola até o botão "Entrar" e clica
      final botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(botaoEntrar);
      await tester.pumpAndSettle();
      await tester.tap(botaoEntrar);
      await tester.pump();

      // Aguarda a autenticação e transição para TelaInicialScreen
      await esperar(tester, find.byType(TelaInicialScreen));
      await tester.pumpAndSettle();

      // Confirma que a LoginScreen foi substituída pela TelaInicialScreen
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);

      // Valida que a barra inferior está presente
      expect(find.text('Minha Conta'), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsOneWidget);
    },
  );
}

```