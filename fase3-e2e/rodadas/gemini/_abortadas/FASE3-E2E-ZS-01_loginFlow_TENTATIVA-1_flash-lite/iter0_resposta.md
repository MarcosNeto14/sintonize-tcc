<!-- Resposta do Gemini 3.8 Flash à geração (iteração 0), como devolvida pelo autor
     em 2026-10-05: preâmbulo, bloco de código e texto final, nesta ordem, sem
     edição. A indentação irregular das primeiras linhas do código veio assim na
     colagem. -->

I will now generate the end-to-end integration test file for the Sintonize application, covering successful login navigation as well as error validation cases.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
IntegrationTestWidgetsFlutterBinding.ensureInitialized();

setUpAll(() async {
await setupFirebaseEmulators();
});

group('Sintonize App - Fluxo de Login E2E', () {
testWidgets('Deve exibir erro no SnackBar ao tentar logar com credenciais inválidas', (WidgetTester tester) async {
// 1. Inicia o aplicativo na tela inicial (HomeScreen)
await tester.pumpWidget(const MyApp());
await tester.pumpAndSettle();

  // Verifica se estamos na tela de boas-vindas
  expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);

  // 2. Toca no botão "Login" para navegar para a LoginScreen
  final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Login');
  expect(loginButtonFinder, findsOneWidget);
  await tester.tap(loginButtonFinder);
  await tester.pumpAndSettle();

  // 3. Preenche e-mail e senha incorretos
  final emailFieldFinder = find.byType(TextFormField).first;
  final passwordFieldFinder = find.byType(TextFormField).last;

  expect(emailFieldFinder, findsOneWidget);
  expect(passwordFieldFinder, findsOneWidget);

  await tester.enterText(emailFieldFinder, 'usuario_inexistente@sintonize.test');
  await tester.enterText(passwordFieldFinder, 'senhaerrada123');
  await tester.pump();

  // 4. Toca no botão "Entrar"
  final entrarButtonFinder = find.widgetWithText(ElevatedButton, 'Entrar');
  expect(entrarButtonFinder, findsOneWidget);
  await tester.tap(entrarButtonFinder);
  
  // Aguarda a resposta assíncrona do Firebase Auth
  await tester.pumpAndSettle(const Duration(seconds: 3));

  // 5. Valida se o SnackBar vermelho com a mensagem de erro foi exibido
  expect(find.byType(SnackBar), findsOneWidget);
  
  // Como o emulador retorna erro de usuário não encontrado ou credencial inválida:
  final snackBarFinder = find.byType(SnackBar);
  final SnackBar snackBar = tester.widget(snackBarFinder);
  expect(snackBar.backgroundColor, Colors.red);
});

testWidgets('Deve realizar login com sucesso e navegar para a TelaInicialScreen usando o usuário de teste', (WidgetTester tester) async {
  // 1. Inicia o aplicativo
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();

  // 2. Navega para a LoginScreen
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();

  // 3. Preenche com as credenciais válidas pré-populadas no emulador
  final emailFieldFinder = find.byType(TextFormField).first;
  final passwordFieldFinder = find.byType(TextFormField).last;

  await tester.enterText(emailFieldFinder, 'tester@sintonize.test');
  await tester.enterText(passwordFieldFinder, 'senha123');
  await tester.pump();

  // 4. Toca em "Entrar"
  await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
  
  // Aguarda a conclusão da autenticação e a navegação por substituição
  await tester.pumpAndSettle(const Duration(seconds: 4));

  // 5. Valida se navegou com sucesso para a TelaInicialScreen (verificando elementos da barra ou saudação)
  expect(find.text('Pesquisa Direta'), findsOneWidget);
  expect(find.text('Sintonizados'), findsOneWidget);
  expect(find.text('Mapa'), findsOneWidget);
  expect(find.text('Minha Conta'), findsOneWidget);
});


});
}
```

I have successfully generated the end-to-end integration test file integration_test/fase3/login_flow_test.dart. It covers launching the real app, invoking the Firebase emulator configuration in setUpAll(), testing negative error handling scenarios via the red SnackBar, and executing a successful login flow leading to the TelaInicialScreen.

You can execute it using the specified command:

Bash
flutter test integration_test/fase3/login_flow_test.dart -d emulator-5554
