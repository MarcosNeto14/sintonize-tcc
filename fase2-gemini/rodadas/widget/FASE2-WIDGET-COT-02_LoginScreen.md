# FASE2-WIDGET-COT-02_LoginScreen — Réplica Gemini

Rodada **48/60**. Bloco 2 (alvos limpos), lote 10 (`LoginScreen`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WIDGET-COT-02_LoginScreen |
| **Função/tela alvo** | `LoginScreen` |
| **Arquivo(s) de origem** | `lib/login.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/cb184dc98448ffc2` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/widget/login_screen_cot_test.dart (+ `login_screen_cot_test.mocks.dart` gerado)` |
| **Saídas arquivadas** | `resultados/widget/FASE2-WIDGET-COT-02_{build_runner,iter0,iter1,iter2,iter3_final}.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/widget/cot/FASE2-WIDGET-COT-02_LoginScreen.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/cb184dc98448ffc2` | **Recusa:** "Sou uma IA com base em texto. Isso está além das minhas capacidades." |
| 2 | `gemini.google.com/app/cb184dc98448ffc2` | Resposta completa. **Enviada manualmente pelo Marcos.** |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Não** (import de `.mocks.dart` com nome presumido) |
| **Testes gerados** | 11 |
| **Testes passaram (1ª execução válida, iteração 1)** | **9/11** |
| **Testes passaram (final, iteração 3)** | **10/11** |
| **Iterações de reparo** | 3 (máximo) |
| **Tentativas de envio até obter resposta** | **2** (1 recusa) |
| **Autoclassificação** | (A); (A)+(B); (B) — todas corretas |

---

## Iterative Repair Loop

| Iteração | Envio | Resposta | Classificação | Resultado |
|---|---|---|---|---|
| 0 (geração) | — | análise + 11 testes com `@GenerateNiceMocks` (mockito + `build_runner`); importa `login_screen_test.mocks.dart` | — | **não compila** — o `.mocks.dart` importado tem nome presumido. `dart run build_runner build` executado como passo do operador (gerou `login_screen_cot_test.mocks.dart`, saída em `FASE2-WIDGET-COT-02_build_runner.txt`); continua sem compilar pelo nome do import |
| 1 | automação, mesma conversa | sem arquivo; duas opções (rodar `build_runner` e alinhar o import ao nome do arquivo, ou mocks manuais) | **(A)**, correta | aplicada a mudança concreta da opção recomendada — import trocado para `login_screen_cot_test.mocks.dart` → **9/11**: `[core/no-app]` no login com sucesso; toque em "Cadastre-se" fora do viewport |
| 2 | **manual (Marcos)**, mesma conversa | arquivo completo; `ensureVisible` + `NavigatorObserver` | **(A)** para o viewport; **(B)** para o login com sucesso (acoplamento estático da `TelaInicialScreen`, `tela-inicial.dart:43`) | **10/11** — o observer registra a rota, mas a `TelaInicialScreen` ainda é montada e lança `[core/no-app]` |
| 3 | **manual (Marcos)**, mesma conversa | só diagnóstico, sem código | **(B)**, mantendo o teste | arquivo inalterado, reexecutado: **10/11 (final)** |

---

## Observações

1. **O (B) mais limpo do bloco 2.** Nas iterações 2 e 3 o modelo diagnostica o acoplamento estático da `TelaInicialScreen` (mesmo diagnóstico das rodadas 46 e 47) e, na 3, segue o protocolo à risca: descreve observado, esperado e por que é defeito da aplicação, **sem alterar nem remover o teste**. O teste que falha é o registro honesto da limitação.
2. Três respostas ao mesmo (B) no mesmo alvo: a ZS (46) remove o teste, a FS (47) o faz passar com uma plataforma Firebase falsa, a COT (48) o mantém vermelho e explica. Só a 48 cumpre literalmente a instrução de reparo; a 47 é a mais útil como teste.
3. `build_runner` executado como passo do operador, como na FASE2-INT-COT-02 do ChatGPT; o erro de nome presumido do `.mocks.dart` é o mesmo daquela rodada.
4. Na iteração 3, a primeira resposta travou no meio da geração e não foi salva pelo serviço (a conversa recarregada não a continha); o reparo foi reenviado.
5. ChatGPT na mesma rodada: 18 testes, 15/18 após 3 iterações — as 3 falhas eram o mesmo (B) da `TelaInicialScreen`, também mantido sem correção. Mesmo desfecho nas duas LLMs.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial (tentativa 2, manual)

````markdown
Aqui está a análise completa do widget e a suíte de testes de widget em Dart/Flutter.

---

### 1. Análise do Widget

O widget `LoginScreen` é uma tela de autenticação que permite aos usuários acessarem a aplicação por meio de e-mail e senha. Ele contém elementos interativos como dois campos de texto (`TextFormField` para e-mail e senha), um botão de submissão (`ElevatedButton` "Entrar") e dois botões de navegação (`TextButton` para recuperação de senha e cadastro). Como serviço externo, o widget utiliza o **Firebase Authentication** (`FirebaseAuth`) através do método `signInWithEmailAndPassword`, exibindo mensagens de erro via `SnackBar` em caso de falha de autenticação e redirecionando para a tela inicial (`TelaInicialScreen`) em caso de sucesso.

---

### 2. Identificação das Dependências e Mocking

* **Serviço externo:** `FirebaseAuth` do pacote `firebase_auth`.
* **Estratégia de Mock:**
* O construtor de `LoginScreen` aceita convenientemente um parâmetro opcional `this.auth`, facilitando a injeção de dependência.
* Para cenários de erro personalizados ou para simular o comportamento exato de exceções (`FirebaseAuthException` com códigos específicos como `'user-not-found'`, `'wrong-password'`, `'invalid-credential'` e erros genéricos), utilizamos o `mockito` criando uma classe `MockFirebaseAuth extends Mock implements FirebaseAuth`.
* Também é mockada a classe de retorno `UserCredential`.



---

### 3. Cenários de Teste Identificados

1. **Renderização Básica:**
* Renderizar todos os elementos visuais essenciais (campos de e-mail e senha, botão "Entrar", links "Esqueci minha senha" e "Não tem cadastro? Cadastre-se!").


2. **Validação de Formulário:**
* Submeter o formulário com campos vazios (mensagens de obrigatoriedade).
* Inserir e-mail com formato inválido (ex: `invalido@semdominio`).
* Inserir senha curta (menos de 6 caracteres).


3. **Interação e Navegação:**
* Tocar em "Esqueci minha senha" e verificar navegação para `RecupSenhaScreen`.
* Tocar em "Não tem cadastro? Cadastre-se!" e verificar navegação para `CadastroScreen`.


4. **Cenário de Sucesso:**
* Preencher credenciais válidas, acionar login e verificar navegação para `TelaInicialScreen`.


5. **Cenários de Erro (Firebase Auth):**
* Exceção com código `user-not-found` exibindo a mensagem correspondente no `SnackBar`.
* Exceção com código `wrong-password` exibindo a mensagem correspondente no `SnackBar`.
* Exceção com código `invalid-credential` exibindo a mensagem correspondente no `SnackBar`.
* Exceção não mapeada (erro genérico) exibindo mensagem padrão no `SnackBar`.



---

### 4. Código dos Testes (`test/login_screen_test.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/recup-senha.dart';
import 'package:sintonize/tela-inicial.dart';

import 'login_screen_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<UserCredential>(),
])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: LoginScreen(auth: mockAuth),
    );
  }

  group('LoginScreen - Renderização Básica', () {
    testWidgets('Deve renderizar os campos de texto e botões principais', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Esqueci minha senha'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Não tem cadastro? Cadastre-se!'), findsOneWidget);
    });
  });

  group('LoginScreen - Validação de Formulário', () {
    testWidgets('Deve exibir mensagens de erro quando os campos estiverem vazios', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      verifyNever(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ));
    });

    testWidgets('Deve exibir mensagem de erro para formato de e-mail inválido', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'email_invalido');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      verifyNever(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ));
    });

    testWidgets('Deve exibir mensagem de erro quando a senha tiver menos de 6 caracteres', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'teste@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), '12345');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      verifyNever(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ));
    });
  });

  group('LoginScreen - Interações e Navegação', () {
    testWidgets('Deve navegar para RecupSenhaScreen ao clicar em Esqueci minha senha', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.widgetWithText(TextButton, 'Esqueci minha senha'));
      await tester.pumpAndSettle();

      expect(find.byType(RecupSenhaScreen), findsOneWidget);
    });

    testWidgets('Deve navegar para CadastroScreen ao clicar em Não tem cadastro? Cadastre-se!', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.widgetWithText(TextButton, 'Não tem cadastro? Cadastre-se!'));
      await tester.pumpAndSettle();

      expect(find.byType(CadastroScreen), findsOneWidget);
    });
  });

  group('LoginScreen - Sucesso no Login', () {
    testWidgets('Deve autenticar e navegar para TelaInicialScreen com credenciais válidas', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@sintonize.com',
        password: 'senhaValida123',
      )).thenAnswer((_) async => mockUserCredential);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaValida123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      verify(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@sintonize.com',
        password: 'senhaValida123',
      )).called(1);

      expect(find.byType(TelaInicialScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });

  group('LoginScreen - Tratamento de Erros do Firebase Auth', () {
    testWidgets('Deve exibir SnackBar de erro com user-not-found', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'naoexiste@sintonize.com',
        password: 'senhaValida123',
      )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'naoexiste@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaValida123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(
        find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.'),
        findsOneWidget,
      );
    });

    testWidgets('Deve exibir SnackBar de erro com wrong-password', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@sintonize.com',
        password: 'senhaIncorreta',
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaIncorreta');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(
        find.text('Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
        findsOneWidget,
      );
    });

    testWidgets('Deve exibir SnackBar de erro com invalid-credential', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@sintonize.com',
        password: 'senhaValida123',
      )).thenThrow(FirebaseAuthException(code: 'invalid-credential'));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaValida123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(
        find.text('As credenciais fornecidas são inválidas. Tente novamente.'),
        findsOneWidget,
      );
    });

    testWidgets('Deve exibir SnackBar com mensagem padrão para erros desconhecidos', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@sintonize.com',
        password: 'senhaValida123',
      )).thenThrow(FirebaseAuthException(code: 'too-many-requests'));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaValida123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(
        find.text('Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.'),
        findsOneWidget,
      );
    });
  });
}

```

> **Dica de execução:** Lembre-se de rodar `dart run build_runner build` no terminal para gerar o arquivo `login_screen_test.mocks.dart` antes de rodar `flutter test`.
````

### Reparo 1

````markdown
**Classificação:** (A) o teste presume um comportamento que não é o especificado (especificamente, uma falha de compilação na infraestrutura do próprio teste).

O erro ocorre porque o arquivo de mocks gerado (`login_screen_test.mocks.dart`) não existe no diretório esperado ou ainda não foi gerado pelo `build_runner`. Com isso, as classes `MockFirebaseAuth` e `MockUserCredential` não são encontradas pelo compilador do Dart.

---

### Como corrigir o teste

Para solucionar o problema, siga uma das duas abordagens:

#### Opção 1: Gerar os mocks com o `build_runner` (Recomendado)

Se o arquivo `login_screen_cot_test.dart` (ou `login_screen_test.dart`) utiliza anotações do Mockito (como `@GenerateMocks([FirebaseAuth, UserCredential])`), execute o comando no terminal na raiz do projeto:

```bash
dart run build_runner build --delete-conflicting-outputs

```

*(ou `flutter pub run build_runner build --delete-conflicting-outputs`)*

Se o arquivo que contém a anotação for o próprio `login_screen_cot_test.dart`, certifique-se de que a anotação e o import correspondam ao nome do arquivo:

```dart
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Caso queira gerar mocks dedicados a este arquivo de teste:
@GenerateMocks([FirebaseAuth, UserCredential])
import 'login_screen_cot_test.mocks.dart';

```

---

#### Opção 2: Usar `Mock` manual sem geração de código

Caso prefira não depender do `build_runner` para este teste, substitua o import do arquivo inexistente pela declaração manual de mocks usando `Mock` do `mockito` ou `mocktail`:

**Com Mockito:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Remova: import 'login_screen_test.mocks.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
  });

  // Seus testes continuam aqui...
}

```

Se o projeto utilizar o pacote **`mocktail`**, a declaração é idêntica:

```dart
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}

```
````

### Reparo 2 (manual)

````markdown
Houve duas falhas distintas na execução. Vamos analisar e classificar cada uma:

---

### Falha 1: `LoginScreen - Interações e Navegação Deve navegar para CadastroScreen ao clicar em Não tem cadastro? Cadastre-se!`

**Classificação:** **(A) o teste presume um comportamento que não é o especificado**

* **Causa:** O widget sob teste está envolvido por um `SingleChildScrollView`. Em telas de teste com tamanho padrão do Flutter (`800x600`), o botão de cadastro fica posicionado no ponto vertical `y = 664.0`, que está fora dos limites visíveis da janela de teste (*off-screen*). Ao tentar executar `tester.tap()`, o framework não consegue disparar o evento de toque no widget fora da tela, o que impede a navegação para a `CadastroScreen`.
* **Resolução:** O teste precisa rolar até o widget (`tester.scrollUntilVisible` ou `tester.ensureVisible`) antes de disparar o `tap()`.

---

### Falha 2: `LoginScreen - Sucesso no Login Deve autenticar e navegar para TelaInicialScreen com credenciais válidas`

**Classificação:** **(B) o teste capturou um comportamento potencialmente incorreto da aplicação**

* **Comportamento Observado:** Ao efetuar o login com sucesso, a navegação redireciona para `TelaInicialScreen`. No entanto, o `TelaInicialScreen` acessa diretamente o singleton estático `FirebaseAuth.instance` em seu `initState()` (`_TelaInicialScreenState.fetchLastRecommendedMusic` na linha 43 de `tela-inicial.dart`) sem permitir injeção de dependência ou sem verificar se a aplicação Firebase padrão foi inicializada, disparando:
```
[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()

```


* **Comportamento Esperado:** Telas e widgets dependentes de serviços externos devem receber suas dependências injetadas (assim como o `LoginScreen` recebe `this.auth` e o repassa para `CadastroScreen(auth: auth)`), ou a navegação deve desacoplar a transição de tela para permitir testes de unidade/widget isolados sem acoplamento a singletons não inicializados.
* **Por que é um problema na aplicação:** O widget `LoginScreen` possui suporte correto para injeção de dependência via construtor (`final FirebaseAuth? auth;`), mas ao instanciar a próxima tela:
```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const TelaInicialScreen()),
);

```


Ele não repassa a instância de autenticação mockada para `TelaInicialScreen`. Além disso, a própria tela de destino depende rigidamente de `FirebaseAuth.instance` sem abstração ou injeção, quebrando qualquer fluxo de navegação em ambiente de testes ou ambientes sem a inicialização nativa do Firebase Core.

---

### Correção dos Testes (para o caso A e contorno de navegação sem enfraquecer o escopo de teste do `LoginScreen`)

Como **não podemos modificar o código do widget sob teste nem das outras telas**, no teste unitário do `LoginScreen` a responsabilidade de navegação é verificar que a rota foi disparada pelo `Navigator`. Para o caso (A), adicionamos o `ensureVisible`. Para isolar o crash originado no interior da `TelaInicialScreen` mantendo a validação de que a transição de rota ocorre após o login, podemos observar a rota ou configurar um `NavigatorObserver`.

Abaixo está o arquivo com a correção do scroll (Caso A) e a observação de navegação:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/recup-senha.dart';
import 'package:sintonize/tela-inicial.dart';

import 'login_screen_cot_test.mocks.dart';

class TestNavigatorObserver extends NavigatorObserver {
  Route<dynamic>? pushedRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoute = route;
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    pushedRoute = newRoute;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<UserCredential>(),
])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockUserCredential mockUserCredential;
  late TestNavigatorObserver navObserver;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    navObserver = TestNavigatorObserver();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      navigatorObservers: [navObserver],
      home: LoginScreen(auth: mockAuth),
    );
  }

  group('LoginScreen - Renderização Básica', () {
    testWidgets('Deve renderizar os campos de texto e botões principais', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Esqueci minha senha'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Não tem cadastro? Cadastre-se!'), findsOneWidget);
    });
  });

  group('LoginScreen - Validação de Formulário', () {
    testWidgets('Deve exibir mensagens de erro quando os campos estiverem vazios', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      verifyNever(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ));
    });

    testWidgets('Deve exibir mensagem de erro para formato de e-mail inválido', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'email_invalido');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      verifyNever(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ));
    });

    testWidgets('Deve exibir mensagem de erro quando a senha tiver menos de 6 caracteres', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'teste@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), '12345');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      verifyNever(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ));
    });
  });

  group('LoginScreen - Interações e Navegação', () {
    testWidgets('Deve navegar para RecupSenhaScreen ao clicar em Esqueci minha senha', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final buttonFinder = find.widgetWithText(TextButton, 'Esqueci minha senha');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(RecupSenhaScreen), findsOneWidget);
    });

    testWidgets('Deve navegar para CadastroScreen ao clicar em Não tem cadastro? Cadastre-se!', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final buttonFinder = find.widgetWithText(TextButton, 'Não tem cadastro? Cadastre-se!');
      // Garante que o botão entre no campo de visão dentro do SingleChildScrollView
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(CadastroScreen), findsOneWidget);
    });
  });

  group('LoginScreen - Sucesso no Login', () {
    testWidgets('Deve autenticar e navegar para TelaInicialScreen com credenciais válidas', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@sintonize.com',
        password: 'senhaValida123',
      )).thenAnswer((_) async => mockUserCredential);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaValida123');

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);

      // Usamos pump() para processar a resposta assíncrona do signInWithEmailAndPassword
      // sem acionar a renderização completa e ciclo de vida que trava em TelaInicialScreen
      await tester.pump();

      verify(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@sintonize.com',
        password: 'senhaValida123',
      )).called(1);

      // Verifica se a substituição de rota ocorreu e o destino foi configurado para TelaInicialScreen
      expect(navObserver.pushedRoute, isA<MaterialPageRoute>());
      expect(
        (navObserver.pushedRoute as MaterialPageRoute).builder(tester.element(find.byType(LoginScreen))),
        isA<TelaInicialScreen>(),
      );
    });
  });

  group('LoginScreen - Tratamento de Erros do Firebase Auth', () {
    testWidgets('Deve exibir SnackBar de erro com user-not-found', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'naoexiste@sintonize.com',
        password: 'senhaValida123',
      )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'naoexiste@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaValida123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(
        find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.'),
        findsOneWidget,
      );
    });

    testWidgets('Deve exibir SnackBar de erro com wrong-password', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@sintonize.com',
        password: 'senhaIncorreta',
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaIncorreta');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(
        find.text('Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
        findsOneWidget,
      );
    });

    testWidgets('Deve exibir SnackBar de erro com invalid-credential', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@sintonize.com',
        password: 'senhaValida123',
      )).thenThrow(FirebaseAuthException(code: 'invalid-credential'));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaValida123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(
        find.text('As credenciais fornecidas são inválidas. Tente novamente.'),
        findsOneWidget,
      );
    });

    testWidgets('Deve exibir SnackBar com mensagem padrão para erros desconhecidos', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@sintonize.com',
        password: 'senhaValida123',
      )).thenThrow(FirebaseAuthException(code: 'too-many-requests'));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaValida123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(
        find.text('Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.'),
        findsOneWidget,
      );
    });
  });
}

```
````

### Reparo 3 (manual)

````markdown
**Classificação:** (B) o teste capturou um comportamento potencialmente incorreto da aplicação.

---

### Descrição do Problema na Aplicação

* **Comportamento Observado:**
Ao disparar a função de login com sucesso, o método `login` executa:
```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => const TelaInicialScreen()),
);

```


Assim que o `Navigator` insere a rota e o Flutter executa o primeiro ciclo de renderização (`drawFrame` / `pump`), o widget de destino `TelaInicialScreen` é montado na árvore. No método `initState()` de `_TelaInicialScreenState` (linha 156), é feita a chamada para `_loadLastRecommendedMusic()` que, por sua vez, invoca `fetchLastRecommendedMusic()` (linha 43 de `tela-inicial.dart`). Esse método tenta acessar diretamente a propriedade estática `FirebaseAuth.instance`:
```
[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()

```


Como o aplicativo Firebase nativo não foi inicializado no ambiente de execução, o teste falha com uma exceção fatal não capturada lançada do ciclo de vida de `TelaInicialScreen`.
* **Comportamento Esperado:**
O fluxo de autenticação e transição de tela deve ser testável e modular. O widget que realiza o login (`LoginScreen`) recebe a dependência `this.auth` via construtor (permitindo mocks e injeção de dependência), mas:
1. Ele não repassa essa dependência mockada ao instanciar a próxima tela (`TelaInicialScreen`).
2. A tela `TelaInicialScreen` não oferece suporte à injeção de dependência do `FirebaseAuth`, acoplando-se rigidamente ao singleton estático `FirebaseAuth.instance`.
3. Além disso, a chamada a métodos assíncronos/serviços externos no `initState` de `TelaInicialScreen` é executada imediatamente na montagem sem verificar o estado da instância ou sem abstração de repositório/serviço, impossibilitando qualquer teste de integração de rotas sem inicializar o SDK nativo do Firebase.


* **Por que você suspeita de um problema na aplicação:**
A aplicação apresenta **acoplamento rígido** e **falta de consistência na injeção de dependências**. Enquanto `LoginScreen` e `CadastroScreen` aceitam `FirebaseAuth? auth`, `TelaInicialScreen` não aceita injeção de dependência e depende diretamente de recursos de plataforma não mockados (`FirebaseAuth.instance`). Em arquiteturas Flutter voltadas a testes, a navegação entre telas ou o acesso a serviços de autenticação e banco de dados deve ser injetado (via construtor, `InheritedWidget`, `Provider` ou Service Locator como `GetIt`) para garantir que uma tela possa ser instanciada e testada isoladamente sem acionar efeitos colaterais de plataforma em cascata.
````

### Tentativa 1 (recusa)

````markdown
Sou uma IA com base em texto. Isso está além das minhas capacidades.
````

