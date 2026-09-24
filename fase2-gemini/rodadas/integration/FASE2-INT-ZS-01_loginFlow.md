# FASE2-INT-ZS-01_loginFlow — Réplica Gemini

Rodada **52/60**. Bloco 3 (integração), lote 12 (`loginFlow`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-INT-ZS-01_loginFlow |
| **Função/tela alvo** | fluxo de login — `LoginScreen` → `TelaInicialScreen` |
| **Arquivo(s) de origem** | `lib/login.dart`, `lib/tela-inicial.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Pílula do seletor conferida a cada envio: `Flash` (não `Flash-Lite`). |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/b03412f4c5e9524c` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos`, alvo limpo. **W-SILENT verificado revertido** antes da rodada: `lib/login.dart:41-42` associa `user-not-found` a "Usuário não encontrado" (mensagens não trocadas) |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 · DevTools 2.54.2 |
| **Arquivo de teste** | `test/fase2-gemini/integration/login_flow_zs_test.dart` (+ `login_flow_zs_test.mocks.dart`, gerado por `build_runner` e usado até o fim, com prefixo) |
| **Saídas arquivadas** | `resultados/integration/FASE2-INT-ZS-01_{build_runner,iter0,iter1,iter2,iter3_final}.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/integration/zero-shot/FASE2-INT-ZS-01_loginFlow.md`, sem alteração |

---

## Tentativas de envio

| Envio | Canal | Resultado |
|---|---|---|
| Geração | automação | Aceito no primeiro envio. |
| Reparo 1 | automação | Aceito no primeiro envio. |
| Reparo 2 | automação | Aceito no primeiro envio. |
| Reparo 3 | automação | Aceito no primeiro envio. |

**Tentativas de envio até obter resposta: 1 em todos os envios. Nenhuma recusa nesta rodada** — a primeira rodada automatizada do bloco sem nenhuma. Ver observação 4.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Não** (import de `.mocks.dart` com nome presumido) |
| **Testes gerados** | 7 |
| **Testes passaram (1ª execução válida, iteração 2)** | **6/7** |
| **Testes passaram (final, iteração 3)** | **6/7** |
| **Iterações de reparo** | 3 (máximo) |
| **Tentativas de envio até obter resposta** | 1 (nenhuma recusa) |
| **Autoclassificação** | (A); (A); (A) — todas corretas |

---

## Iterative Repair Loop

| Iteração | Envio | Resposta | Classificação | Resultado |
|---|---|---|---|---|
| 0 (geração) | automação | arquivo completo, 7 `testWidgets`, `@GenerateMocks([FirebaseAuth])` + `firebase_auth_mocks`; importa `login_flow_test.mocks.dart` | — | **não compila** — `.mocks.dart` com nome presumido. `dart run build_runner build` executado como passo do operador (gerou `login_flow_zs_test.mocks.dart`, saída em `FASE2-INT-ZS-01_build_runner.txt`); continua sem compilar pelo nome do import |
| 1 | automação, mesma conversa | sem arquivo; duas opções (rodar `build_runner`, ou alinhar o import ao nome do arquivo) | **(A)**, correta | aplicada a mudança concreta da opção 2 — import trocado para `login_flow_zs_test.mocks.dart` → **não compila**: `MockFirebaseAuth` vem tanto do arquivo gerado quanto de `package:firebase_auth_mocks`, colisão de identificador |
| 2 | automação, mesma conversa | **arquivo completo**; importa os dois com prefixo (`as fam`, `as mockito_mocks`) | **(A)**, correta | **compila pela primeira vez** — 7 testes, **6/7**. Falha: `RangeError (index)` no `enterText`, finder `.at(1)` sobre `widgetWithText(TextFormField, '')` que resolve para 1 elemento |
| 3 | automação, mesma conversa | **arquivo completo**; troca os finders posicionais por finders estáveis | **(A)**, correta | **6/7 (final)** — a falha muda de natureza: agora é `[core/no-app]`, ver abaixo. Limite de 3 iterações atingido |

### A falha que sobrou

```
[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
  #3  _TelaInicialScreenState.fetchLastRecommendedMusic (package:sintonize/tela-inicial.dart:43:31)
```

`TelaInicialScreen` chama `FirebaseAuth.instance` direto no `initState`, sem injeção de dependência — ao contrário de `LoginScreen`, que aceita `FirebaseAuth? auth`. Assim que a navegação acontece, a tela destino toca o singleton real e o teste morre. É **exatamente o achado (B) das rodadas 46/47/48 (bloco widget) e da mesma rodada no ChatGPT**, onde foi classificado como *limitação de testabilidade*, não bug funcional.

---

## Observações

1. **O modelo nunca chegou a classificar o (B).** As três iterações foram gastas em problemas do próprio teste (nome do `.mocks.dart`, colisão de identificador, finder posicional), todos legitimamente (A). O `[core/no-app]` só apareceu na execução da **última** iteração, sem reparo restante para classificá-lo. O achado está no repositório porque o operador o registra, não porque o modelo o reconheceu.
2. **Comparação direta com o ChatGPT na mesma rodada:** ChatGPT gerou 8 testes e fechou em **7/8**, alcançando o (B) na iteração 3 e documentando-o sem enfraquecer a asserção. Gemini gerou 7 e fechou em **6/7**, sem chegar ao (B). Mesmo alvo, mesmo prompt, mesmo limite de iterações — mesma parede (`TelaInicialScreen`), alcançada com uma iteração de atraso.
3. **O nome presumido do `.mocks.dart` queimou a iteração 0 pela quarta vez seguida** (rodadas 48, 51 e agora 52; e a `FASE2-INT-COT-02` do ChatGPT). É um custo fixo do protocolo, não uma característica de um modelo: o nome do arquivo de teste é decidido pelo operador **depois** da geração, e nenhum dos dois modelos tem como adivinhá-lo.
4. **Nenhuma recusa nesta rodada, toda ela automatizada.** É contraexemplo direto à leitura de que a automação, por si só, causa a recusa — reforçando que o fator é intermitente e ainda não isolado. Ver a nota sobre o assunto na rodada 51 e a seção "Recusas não determinísticas" do `fase2-gemini/README.md`, ainda não revisada.
5. **`build_runner` como passo do operador tem efeito colateral fora da rodada.** A execução regenerou/apagou arquivos `.mocks.dart` de rodadas já fechadas (`criar_playlist_screen_cot_test.mocks.dart` foi apagado, porque o arquivo final da rodada 51 não usa mais `@GenerateNiceMocks`). Foram restaurados com `git checkout --` antes de seguir, e a árvore ficou idêntica ao commit da rodada 51. **Conferir `git status` depois de todo `build_runner`.**

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
Aqui está o arquivo completo de testes de integração em Dart utilizando `flutter_test`, com simulações via `firebase_auth_mocks`, `mockito` e `fake_cloud_firestore`.

Salve o código no arquivo: `test/integration/login_flow_test.dart`.

```dart
// test/integration/login_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

// Gera o mock para FirebaseAuth nos cenários que exigem lançar FirebaseAuthException
@GenerateMocks([FirebaseAuth])
import 'login_flow_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Helper para empacotar a LoginScreen em um MaterialApp
  Widget createTestWidget({FirebaseAuth? auth}) {
    return MaterialApp(
      home: LoginScreen(auth: auth),
    );
  }

  // Constantes de teste
  const validEmail = 'usuario@exemplo.com';
  const validPassword = 'senhaValida123';

  group('Fluxo de Integração - Login (Sucesso e Navegação)', () {
    testWidgets('Deve autenticar com sucesso e navegar para TelaInicialScreen',
        (WidgetTester tester) async {
      // 1. Configura mock de autenticação com usuário existente
      final mockUser = MockUser(
        uid: 'user-uid-123',
        email: validEmail,
        displayName: 'Carlos',
      );
      final mockAuth = MockFirebaseAuth(mockUser: mockUser);

      // 2. Renderiza a LoginScreen
      await tester.pumpWidget(createTestWidget(auth: mockAuth));
      await tester.pumpAndSettle();

      // 3. Localiza os campos de e-mail e senha
      final emailField = find.widgetWithText(TextFormField, '');
      // Há dois TextFormFields no formulário: primeiro é e-mail, segundo é senha
      expect(emailField, findsNWidgets(2));

      await tester.enterText(emailField.at(0), validEmail);
      await tester.enterText(emailField.at(1), validPassword);
      await tester.pump();

      // 4. Clica no botão "Entrar"
      final enterButton = find.widgetWithText(ElevatedButton, 'Entrar');
      expect(enterButton, findsOneWidget);

      await tester.tap(enterButton);
      // Aguarda processamento assíncrono do login e animação de transição da tela
      await tester.pumpAndSettle();

      // 5. Verifica que a LoginScreen foi substituída e estamos na TelaInicialScreen
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);
    });
  });

  group('Validações de Formulário Local (Campos vazios / inválidos)', () {
    testWidgets(
        'Exibe mensagens de validação quando campos estão vazios e bloqueia chamada ao Firebase',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(createTestWidget(auth: mockAuth));
      await tester.pumpAndSettle();

      // Toca em 'Entrar' sem preencher nada
      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      // Verifica exibição dos erros do validator
      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);

      // Permanece na LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets(
        'Exibe erro quando e-mail é malformatado ou senha tem menos de 6 caracteres',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(createTestWidget(auth: mockAuth));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'email_invalido_sem_arroba');
      await tester.enterText(textFields.at(1), '123'); // < 6 dígitos
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });

  group('Cenários de Erro no Firebase (SnackBars de Falha)', () {
    late MockFirebaseAuth mockFirebaseAuthMockito;

    setUp(() {
      mockFirebaseAuthMockito = MockFirebaseAuth();
    });

    Future<void> executarTesteDeErro(
      WidgetTester tester, {
      required String errorCode,
      required String expectedMessage,
    }) async {
      // Configura o mockito para disparar o FirebaseAuthException desejado
      when(mockFirebaseAuthMockito.signInWithEmailAndPassword(
        email: validEmail,
        password: validPassword,
      )).thenThrow(
        FirebaseAuthException(code: errorCode),
      );

      await tester.pumpWidget(createTestWidget(auth: mockFirebaseAuthMockito));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), validEmail);
      await tester.enterText(textFields.at(1), validPassword);
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      // Verifica que a SnackBar foi exibida com a mensagem e cor vermelha
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(expectedMessage), findsOneWidget);

      final snackBarWidget = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBarWidget.backgroundColor, Colors.red);

      // Garante que o usuário permanece na LoginScreen
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    }

    testWidgets('Exibe mensagem adequada quando código é "user-not-found"',
        (WidgetTester tester) async {
      await executarTesteDeErro(
        tester,
        errorCode: 'user-not-found',
        expectedMessage:
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
      );
    });

    testWidgets('Exibe mensagem adequada quando código é "wrong-password"',
        (WidgetTester tester) async {
      await executarTesteDeErro(
        tester,
        errorCode: 'wrong-password',
        expectedMessage:
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
      );
    });

    testWidgets('Exibe mensagem adequada quando código é "invalid-credential"',
        (WidgetTester tester) async {
      await executarTesteDeErro(
        tester,
        errorCode: 'invalid-credential',
        expectedMessage:
            'As credenciais fornecidas são inválidas. Tente novamente.',
      );
    });

    testWidgets(
        'Exibe mensagem genérica quando código for desconhecido/inesperado',
        (WidgetTester tester) async {
      await executarTesteDeErro(
        tester,
        errorCode: 'too-many-requests',
        expectedMessage:
            'Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.',
      );
    });
  });
}

```

---

### Passos para Execução:

1. **Configuração de dependências (`pubspec.yaml`):**
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  firebase_auth_mocks: ^0.14.0
  fake_cloud_firestore: ^3.1.0
  mockito: ^5.4.4
  build_runner: ^2.4.9

```


2. **Gerar arquivos de Mock:**
Execute no terminal para gerar o arquivo `test/integration/login_flow_test.mocks.dart`:
```bash
dart run build_runner build --delete-conflicting-outputs

```


3. **Rodar os testes:**
```bash
flutter test test/integration/

```
````

### Reparo 1

````markdown
**Classificação da causa provável:**
**(A) O teste presume um comportamento que não é o especificado.**

*Justificativa:* A falha é um erro de compilação em tempo de build/execução do teste (`Compilation failed`), causado pela ausência de um arquivo gerado por build runner (`login_flow_test.mocks.dart`) ou pela importação incorreta de um arquivo de mocks de outro teste. O teste nem sequer chegou a executar contra a aplicação.

---

### Como corrigir o teste

O arquivo de teste `login_flow_zs_test.dart` está tentando importar `login_flow_test.mocks.dart`, que não existe no diretório. Há duas abordagens para resolver:

#### 1. Gerar os mocks necessários

Se o teste utiliza anotações do Mockito (como `@GenerateMocks([...])`), certifique-se de que a anotação está presente no próprio arquivo `login_flow_zs_test.dart`:

```dart
import 'package:mockito/annotations.dart';
// outras importações...

@GenerateMocks([/* classes a serem mockadas */])
import 'login_flow_zs_test.mocks.dart';

```

Em seguida, execute o gerador de código no terminal:

```bash
dart run build_runner build --delete-conflicting-outputs

```

*(Ou `flutter pub run build_runner build --delete-conflicting-outputs` caso use Flutter).*

#### 2. Corrigir o nome da importação

Se o arquivo com a anotação for o próprio `login_flow_zs_test.dart`, ajuste a linha 14:

* **De:**
```dart
import 'login_flow_test.mocks.dart';

```


* **Para:**
```dart
import 'login_flow_zs_test.mocks.dart';

```



Se os mocks foram gerados originalmente em outro local (por exemplo, dentro de `test/fase2-gemini/integration/login_flow_test.dart`), certifique-se de rodar o `build_runner` para que o arquivo `login_flow_test.mocks.dart` seja criado antes de rodar a suíte de testes.
````

### Reparo 2

````markdown
**Classificação da causa provável:**
**(A) o teste presume um comportamento que não é o especificado.**

*Justificativa:* Trata-se novamente de um erro de compilação em tempo de build do teste (colisão de identificadores). Tanto o pacote `firebase_auth_mocks` quanto o arquivo gerado pelo Mockito (`login_flow_zs_test.mocks.dart`) exportam uma classe chamada `MockFirebaseAuth`, gerando conflito no namespace de importações do arquivo de teste. A aplicação sequer chegou a ser executada.

---

### Correção

Para resolver o conflito de nomes, podemos usar um prefixo (`as mockito_mocks`) na importação gerada pelo Mockito ou usar `MockFirebaseAuth` do próprio pacote `firebase_auth_mocks` para simular as exceções (ou esconder o símbolo conflitante via `hide` / `show`).

A forma mais direta e limpa no Flutter é dar um alias ao arquivo gerado pelo Mockito (ou importar com prefixo). Além disso, nos testes de validação local nem é estritamente necessário instanciar `MockFirebaseAuth`, mas mantendo o suporte ao Mockito para lançar exceções, aqui está o arquivo completo corrigido (`test/fase2-gemini/integration/login_flow_zs_test.dart`):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as fam;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

// Gera o mock para FirebaseAuth nos cenários que exigem lançar FirebaseAuthException
@GenerateMocks([FirebaseAuth])
import 'login_flow_zs_test.mocks.dart' as mockito_mocks;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Helper para empacotar a LoginScreen em um MaterialApp
  Widget createTestWidget({FirebaseAuth? auth}) {
    return MaterialApp(
      home: LoginScreen(auth: auth),
    );
  }

  // Constantes de teste
  const validEmail = 'usuario@exemplo.com';
  const validPassword = 'senhaValida123';

  group('Fluxo de Integração - Login (Sucesso e Navegação)', () {
    testWidgets('Deve autenticar com sucesso e navegar para TelaInicialScreen',
        (WidgetTester tester) async {
      // 1. Configura mock de autenticação com usuário existente do firebase_auth_mocks
      final mockUser = fam.MockUser(
        uid: 'user-uid-123',
        email: validEmail,
        displayName: 'Carlos',
      );
      final mockAuth = fam.MockFirebaseAuth(mockUser: mockUser);

      // 2. Renderiza a LoginScreen
      await tester.pumpWidget(createTestWidget(auth: mockAuth));
      await tester.pumpAndSettle();

      // 3. Localiza os campos de e-mail e senha
      final emailField = find.widgetWithText(TextFormField, '');
      expect(emailField, findsNWidgets(2));

      await tester.enterText(emailField.at(0), validEmail);
      await tester.enterText(emailField.at(1), validPassword);
      await tester.pump();

      // 4. Clica no botão "Entrar"
      final enterButton = find.widgetWithText(ElevatedButton, 'Entrar');
      expect(enterButton, findsOneWidget);

      await tester.tap(enterButton);
      await tester.pumpAndSettle();

      // 5. Verifica navegação
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);
    });
  });

  group('Validações de Formulário Local (Campos vazios / inválidos)', () {
    testWidgets(
        'Exibe mensagens de validação quando campos estão vazios e bloqueia chamada ao Firebase',
        (WidgetTester tester) async {
      final mockAuth = fam.MockFirebaseAuth();
      await tester.pumpWidget(createTestWidget(auth: mockAuth));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets(
        'Exibe erro quando e-mail é malformatado ou senha tem menos de 6 caracteres',
        (WidgetTester tester) async {
      final mockAuth = fam.MockFirebaseAuth();
      await tester.pumpWidget(createTestWidget(auth: mockAuth));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'email_invalido_sem_arroba');
      await tester.enterText(textFields.at(1), '123');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });

  group('Cenários de Erro no Firebase (SnackBars de Falha)', () {
    late mockito_mocks.MockFirebaseAuth mockFirebaseAuthMockito;

    setUp(() {
      mockFirebaseAuthMockito = mockito_mocks.MockFirebaseAuth();
    });

    Future<void> executarTesteDeErro(
      WidgetTester tester, {
      required String errorCode,
      required String expectedMessage,
    }) async {
      when(mockFirebaseAuthMockito.signInWithEmailAndPassword(
        email: validEmail,
        password: validPassword,
      )).thenAnswer(
        (_) => throw FirebaseAuthException(code: errorCode),
      );

      await tester.pumpWidget(createTestWidget(auth: mockFirebaseAuthMockito));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), validEmail);
      await tester.enterText(textFields.at(1), validPassword);
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(expectedMessage), findsOneWidget);

      final snackBarWidget = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBarWidget.backgroundColor, Colors.red);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    }

    testWidgets('Exibe mensagem adequada quando código é "user-not-found"',
        (WidgetTester tester) async {
      await executarTesteDeErro(
        tester,
        errorCode: 'user-not-found',
        expectedMessage:
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
      );
    });

    testWidgets('Exibe mensagem adequada quando código é "wrong-password"',
        (WidgetTester tester) async {
      await executarTesteDeErro(
        tester,
        errorCode: 'wrong-password',
        expectedMessage:
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
      );
    });

    testWidgets('Exibe mensagem adequada quando código é "invalid-credential"',
        (WidgetTester tester) async {
      await executarTesteDeErro(
        tester,
        errorCode: 'invalid-credential',
        expectedMessage:
            'As credenciais fornecidas são inválidas. Tente novamente.',
      );
    });

    testWidgets(
        'Exibe mensagem genérica quando código for desconhecido/inesperado',
        (WidgetTester tester) async {
      await executarTesteDeErro(
        tester,
        errorCode: 'too-many-requests',
        expectedMessage:
            'Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.',
      );
    });
  });
}

```
````

### Reparo 3

````markdown
**Classificação da causa provável:**
**(A) o teste presume um comportamento que não é o especificado.**

*Justificativa:* Os *Finders* do Flutter (`Finder`) são avaliados de maneira dinâmica/preguiçosa (*lazy*). No primeiro teste, foi utilizado:

```dart
final emailField = find.widgetWithText(TextFormField, '');
await tester.enterText(emailField.at(0), validEmail);
await tester.enterText(emailField.at(1), validPassword);

```

Assim que o primeiro campo recebe o texto `validEmail`, ele deixa de ter texto vazio (`''`). Quando o teste tenta avaliar `emailField.at(1)`, o finder refaz a busca e encontra apenas 1 elemento (o campo de senha restante), disparando `RangeError: Index out of range: index should be less than 1: 1`. Nos demais testes do arquivo, onde foi usado `find.byType(TextFormField)`, o teste passou normalmente. Trata-se, portanto, exclusivamente de um bug na forma como o seletor do teste foi definido.

---

### Correção

Basta substituir a busca por `find.byType(TextFormField)` no primeiro teste (alinhando com a estratégia bem-sucedida dos outros cenários).

Segue o arquivo corrigido:

```dart
// test/fase2-gemini/integration/login_flow_zs_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as fam;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

// Gera o mock para FirebaseAuth nos cenários que exigem lançar FirebaseAuthException
@GenerateMocks([FirebaseAuth])
import 'login_flow_zs_test.mocks.dart' as mockito_mocks;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Helper para empacotar a LoginScreen em um MaterialApp
  Widget createTestWidget({FirebaseAuth? auth}) {
    return MaterialApp(
      home: LoginScreen(auth: auth),
    );
  }

  // Constantes de teste
  const validEmail = 'usuario@exemplo.com';
  const validPassword = 'senhaValida123';

  group('Fluxo de Integração - Login (Sucesso e Navegação)', () {
    testWidgets('Deve autenticar com sucesso e navegar para TelaInicialScreen',
        (WidgetTester tester) async {
      // 1. Configura mock de autenticação com usuário existente do firebase_auth_mocks
      final mockUser = fam.MockUser(
        uid: 'user-uid-123',
        email: validEmail,
        displayName: 'Carlos',
      );
      final mockAuth = fam.MockFirebaseAuth(mockUser: mockUser);

      // 2. Renderiza a LoginScreen
      await tester.pumpWidget(createTestWidget(auth: mockAuth));
      await tester.pumpAndSettle();

      // 3. Localiza os campos de e-mail e senha por tipo
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      await tester.enterText(textFields.at(0), validEmail);
      await tester.enterText(textFields.at(1), validPassword);
      await tester.pump();

      // 4. Clica no botão "Entrar"
      final enterButton = find.widgetWithText(ElevatedButton, 'Entrar');
      expect(enterButton, findsOneWidget);

      await tester.tap(enterButton);
      await tester.pumpAndSettle();

      // 5. Verifica navegação
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);
    });
  });

  group('Validações de Formulário Local (Campos vazios / inválidos)', () {
    testWidgets(
        'Exibe mensagens de validação quando campos estão vazios e bloqueia chamada ao Firebase',
        (WidgetTester tester) async {
      final mockAuth = fam.MockFirebaseAuth();
      await tester.pumpWidget(createTestWidget(auth: mockAuth));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets(
        'Exibe erro quando e-mail é malformatado ou senha tem menos de 6 caracteres',
        (WidgetTester tester) async {
      final mockAuth = fam.MockFirebaseAuth();
      await tester.pumpWidget(createTestWidget(auth: mockAuth));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'email_invalido_sem_arroba');
      await tester.enterText(textFields.at(1), '123');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });

  group('Cenários de Erro no Firebase (SnackBars de Falha)', () {
    late mockito_mocks.MockFirebaseAuth mockFirebaseAuthMockito;

    setUp(() {
      mockFirebaseAuthMockito = mockito_mocks.MockFirebaseAuth();
    });

    Future<void> executarTesteDeErro(
      WidgetTester tester, {
      required String errorCode,
      required String expectedMessage,
    }) async {
      when(mockFirebaseAuthMockito.signInWithEmailAndPassword(
        email: validEmail,
        password: validPassword,
      )).thenAnswer(
        (_) => throw FirebaseAuthException(code: errorCode),
      );

      await tester.pumpWidget(createTestWidget(auth: mockFirebaseAuthMockito));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), validEmail);
      await tester.enterText(textFields.at(1), validPassword);
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(expectedMessage), findsOneWidget);

      final snackBarWidget = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBarWidget.backgroundColor, Colors.red);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    }

    testWidgets('Exibe mensagem adequada quando código é "user-not-found"',
        (WidgetTester tester) async {
      await executarTesteDeErro(
        tester,
        errorCode: 'user-not-found',
        expectedMessage:
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
      );
    });

    testWidgets('Exibe mensagem adequada quando código é "wrong-password"',
        (WidgetTester tester) async {
      await executarTesteDeErro(
        tester,
        errorCode: 'wrong-password',
        expectedMessage:
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
      );
    });

    testWidgets('Exibe mensagem adequada quando código é "invalid-credential"',
        (WidgetTester tester) async {
      await executarTesteDeErro(
        tester,
        errorCode: 'invalid-credential',
        expectedMessage:
            'As credenciais fornecidas são inválidas. Tente novamente.',
      );
    });

    testWidgets(
        'Exibe mensagem genérica quando código for desconhecido/inesperado',
        (WidgetTester tester) async {
      await executarTesteDeErro(
        tester,
        errorCode: 'too-many-requests',
        expectedMessage:
            'Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.',
      );
    });
  });
}

```
````
