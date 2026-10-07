<!-- Resposta do Gemini 3.8 Flash à geração (iteração 0), rodada FASE3-L4-COT, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome), segunda máquina (DESKTOP-6ETPO2H).
     Conversa: https://gemini.google.com/app/eec230273581473b -->

### 1. Análise do Fluxo

O fluxo se inicia na tela de boas-vindas (`HomeScreen`), onde o usuário clica no botão "Login" para transicionar à `LoginScreen`. Nessa tela, o usuário insere seu e-mail e senha e aciona o botão "Entrar". O primeiro ponto de decisão ocorre na validação síncrona do formulário local: caso os campos estejam vazios ou fora do formato esperado, mensagens de validação são exibidas e o Firebase não é chamado. O segundo ponto de decisão acontece na chamada assíncrona ao Firebase Auth: caso a autenticação tenha sucesso, o aplicativo redireciona via substituição para a `TelaInicialScreen`; se houver falha, a tela permanece em `LoginScreen` e exibe um `SnackBar` vermelho contendo a mensagem correspondente ao código de erro lançado pelo Firebase.

---

### 2. Identificação das Dependências

* **Firebase Auth:**
* Acionado na `LoginScreen` pelo método `signInWithEmailAndPassword(email, password)`.
* Lido na `TelaInicialScreen` através de `FirebaseAuth.instance.currentUser` para obter o `uid` da sessão ativa.


* **Cloud Firestore:**
* Na `TelaInicialScreen`, realiza leitura em `usuarios/{uid}` para resgatar o campo `nome`, a lista `generos_favoritos` e o mapa `historico_musicas`.
* Realiza leitura (`get`) na coleção `musica` para carregar as músicas compatíveis com os gêneros do usuário.
* Realiza gravação/atualização (`update`) em `usuarios/{uid}` salvando `historico_musicas` e `musica_recomendada`.


* **Massa de Dados Pré-existente nos Emuladores:**
* Usuário pré-cadastrado no Auth: `tester@sintonize.test` com senha `senha123`.
* Documento `usuarios/{uid}` com `nome: 'tester sintonize'` e `generos_favoritos: ['rock', 'pop']`.
* Coleção `musica` com 5 faixas (`bohemian rhapsody`, `billie jean`, `take five`, `the thrill is gone`, `one love`).



---

### 3. Caminho de Navegação e Sincronização

1. **Partida (`MyApp`):** O teste inicializa com `app.main()` ou `tester.pumpWidget(const MyApp())`. A tela inicial exibida é a `HomeScreen`. Aguarda-se a animação do logo com `tester.pumpAndSettle()`.
2. **Navegação para Login:** Localiza-se o botão contendo o texto `'Login'` e executa-se o toque (`tester.tap`). Utiliza-se `tester.pumpAndSettle()` para completar a transição de rota animada (`SlideTransition`).
3. **Interação com a `LoginScreen`:** Preenche-se os campos com `tester.enterText(finder, valor)`. Os `TextFormField` são identificados por sua ordem na árvore de widgets (primeiro e-mail, segundo senha).
4. **Disparo da Ação:** Toca-se no botão `'Entrar'`.
5. **Esperas e Asserções:**
* **Fluxo de Sucesso:** Aguarda-se a resposta do emulador Auth e as queries do Firestore na nova tela com `tester.pumpAndSettle()`. Garante-se que a tela final exibida contenha elementos da `TelaInicialScreen` (ex.: texto de saudação com o nome formatado `"Tester Sintonize,"`).
* **Fluxo com Erro:** Executa-se `tester.pumpAndSettle()` para que o erro do Firebase Auth seja retornado e a animação do `SnackBar` seja renderizada. Verifica-se a mensagem e a cor de fundo do `SnackBar`.



---

### 4. Cenários de Teste

1. **Fluxo de Sucesso Ponta a Ponta:** Preenchimento com `tester@sintonize.test` e `senha123`, toque em "Entrar", resolução do login no emulador, navegação e renderização da `TelaInicialScreen` com saudação `"Tester Sintonize,"`.
2. **Validação de Campos Vazios:** Tocar em "Entrar" sem preencher e-mail e senha. As mensagens `'Por favor, insira seu e-mail'` e `'Por favor, insira sua senha'` devem ser exibidas simultaneamente sem acionar o Firebase.
3. **Validação de Formato de E-mail Inválido:** Preencher um e-mail com formato inadequado (ex.: `email_invalido`) e senha válida. A mensagem `'Por favor, insira um e-mail válido'` deve ser exibida.
4. **Validação de Tamanho Mínimo de Senha:** Preencher um e-mail válido e uma senha com menos de 6 caracteres (ex.: `12345`). A mensagem `'A senha deve ter pelo menos 6 caracteres'` deve ser exibida.
5. **Erro do Firebase - Credencial Incorreta / Senha Inválida:** Preenchimento de `tester@sintonize.test` com uma senha incorreta. O aplicativo deve capturar o erro e exibir um `SnackBar` vermelho com `'As credenciais fornecidas são inválidas. Tente novamente.'` ou `'Senha incorreta. Certifique-se de que está digitando a senha corretamente.'`.
6. **Erro do Firebase - Usuário Inexistente:** Preenchimento com usuário inexistente (ex.: `naoexiste@sintonize.test`). O aplicativo deve exibir o `SnackBar` vermelho com a mensagem correspondente (`'Usuário não encontrado...'` ou `'As credenciais fornecidas são inválidas...'`).

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

```
