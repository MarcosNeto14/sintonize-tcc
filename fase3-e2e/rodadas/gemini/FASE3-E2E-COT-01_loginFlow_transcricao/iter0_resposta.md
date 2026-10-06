<!-- Resposta do Gemini 3.8 Flash à geração (iteração 0), rodada FASE3-E2E-COT-01_loginFlow, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome).
     Conversa: https://gemini.google.com/app/60b70378ac678107 -->

### 1. Análise do Fluxo

O fluxo se inicia na tela de boas-vindas (`HomeScreen`), onde o usuário aciona o botão "Login" para transitar até a `LoginScreen`. Nessa tela, insere e-mail e senha e clica em "Entrar". O primeiro ponto de decisão ocorre na validação do formulário síncrono local (campos preenchidos e formato de e-mail / tamanho de senha); em caso de invalidação, mensagens de erro inline são exibidas sem acionar a rede. O segundo ponto de decisão reside na chamada assíncrona ao Firebase Auth: em caso de credenciais corretas, o app substitui a rota atual navegando para a `TelaInicialScreen`; em caso de erro da API (credencial incorreta ou usuário inexistente), permanece na `LoginScreen` e dispara um `SnackBar` vermelho contendo a mensagem de erro correspondente.

---

### 2. Identificação das Dependências

* **Serviços Acionados por Tela:**
* `HomeScreen`: Nenhum serviço externo.
* `LoginScreen`: `FirebaseAuth.instance.signInWithEmailAndPassword(email, password)`.
* `TelaInicialScreen`:
* `FirebaseAuth.instance.currentUser` (leitura do usuário autenticado).
* `FirebaseFirestore.instance.collection('usuarios').doc(uid).get()` (leitura do nome, histórico e gêneros favoritos).
* `FirebaseFirestore.instance.collection('musica').get()` (leitura das músicas para recomendação).
* `FirebaseFirestore.instance.collection('usuarios').doc(uid).update(...)` (gravação do histórico e recomendação diária).




* **Dados Pré-existentes nos Emuladores:**
* **Firebase Auth:** Usuário com e-mail `tester@sintonize.test` e senha `senha123`.
* **Firestore (`usuarios/{uid}`):** Documento do usuário de teste com `nome: 'tester sintonize'` e `generos_favoritos: ['rock', 'pop']`.
* **Firestore (`musica`):** 5 documentos pré-cadastrados (`bohemian rhapsody`, `billie jean`, `take five`, `the thrill is gone`, `one love`).



---

### 3. Caminho de Navegação e Sincronização

1. **Partida (`HomeScreen`):**
* Inicialização com `await tester.pumpWidget(const MyApp());`.
* Liquidação de animações da tela inicial (`AnimatedOpacity` de 2s e delay de 500ms) usando `await tester.pumpAndSettle();`.


2. **Transição para `LoginScreen`:**
* Localizar o botão "Login" (`find.widgetWithText(ElevatedButton, 'Login')`) e executar `await tester.tap(...)`.
* Aguardar o término do `SlideTransition` via `await tester.pumpAndSettle();`.


3. **Interação na `LoginScreen`:**
* Identificar os campos de texto: primeiro `TextFormField` (índice 0) para E-mail e segundo (índice 1) para Senha.
* Inserir dados com `await tester.enterText(...)`.
* Tocar no botão "Entrar" (`find.widgetWithText(ElevatedButton, 'Entrar')`).


4. **Sincronização com Emuladores:**
* **Fluxo de Sucesso:** `await tester.pumpAndSettle();` aguarda a resposta assíncrona do Auth emulator, a transição de rota (`Navigator.pushReplacement`) e a resolução dos `FutureBuilder` da `TelaInicialScreen`.
* **Fluxo de Erro:** `await tester.pumpAndSettle();` aguarda o retorno da exceção `FirebaseAuthException` e a renderização completa da animação de entrada do `SnackBar`.



---

### 4. Cenários de Teste

1. **Sucesso Ponta a Ponta:** Preenchimento com credenciais válidas (`tester@sintonize.test` / `senha123`) $\rightarrow$ navegação confirmada pela presença de widgets da `TelaInicialScreen` (ex.: "essa é a nossa recomendação de música para você!").
2. **Validação de Campos Vazios:** Tocar em "Entrar" sem preencher nada $\rightarrow$ exibição dos erros inline `'Por favor, insira seu e-mail'` e `'Por favor, insira sua senha'` sem chamada ao Firebase.
3. **Validação de Formato e Tamanho:** E-mail sem formato válido (`emailinvalido`) e senha curta (`123`) $\rightarrow$ exibição das mensagens `'Por favor, insira um e-mail válido'` e `'A senha deve ter pelo menos 6 caracteres'`.
4. **Erro do Firebase (Senha Incorreta / Credenciais Inválidas):** E-mail existente com senha errada $\rightarrow$ exibição do `SnackBar` com mensagem correspondente aos códigos `wrong-password` ou `invalid-credential`.
5. **Erro do Firebase (Usuário Inexistente / Credenciais Inválidas):** E-mail não cadastrado (`naoexiste@sintonize.test`) $\rightarrow$ exibição do `SnackBar` com mensagem correspondente a `user-not-found` ou `invalid-credential`.

---

### 5. Código dos Testes End-to-End

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

```