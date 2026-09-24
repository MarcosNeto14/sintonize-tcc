# FASE2-INT-COT-01_loginFlow — Réplica Gemini

Rodada **54/60**. Bloco 3 (integração), lote 12 (`loginFlow`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-INT-COT-01_loginFlow |
| **Função/tela alvo** | fluxo de login — `LoginScreen` → `TelaInicialScreen` |
| **Arquivo(s) de origem** | `lib/login.dart`, `lib/tela-inicial.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Pílula do seletor conferida a cada envio: `Flash` (não `Flash-Lite`). |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/29403ff847fce010` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos`, alvo limpo. W-SILENT verificado revertido antes da rodada |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 · DevTools 2.54.2 |
| **Arquivo de teste** | `test/fase2-gemini/integration/login_flow_cot_test.dart` (sem `.mocks.dart` — mocks manuais, `build_runner` não foi necessário) |
| **Saídas arquivadas** | `resultados/integration/FASE2-INT-COT-01_{iter0,iter1,iter2,iter3_final}.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/integration/cot/FASE2-INT-COT-01_loginFlow.md`, sem alteração |

---

## Tentativas de envio

| Envio | Canal | Resultado |
|---|---|---|
| Geração | automação | Aceito no primeiro envio. |
| Reparo 1 | automação | Aceito no primeiro envio. |
| Reparo 2 | automação | Aceito no primeiro envio. |
| Reparo 3 | automação | Aceito no primeiro envio. |

**Tentativas de envio até obter resposta: 1 em todos os envios. Nenhuma recusa.**

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** — única rodada do bloco até agora em que a geração compilou de primeira |
| **Testes gerados** | 8 |
| **Testes passaram (iteração 0, melhor estado da rodada)** | **3/8** |
| **Testes passaram (final, iteração 3)** | **0** — o arquivo **nem carrega** |
| **Iterações de reparo** | 3 (máximo) |
| **Tentativas de envio até obter resposta** | 1 (nenhuma recusa) |
| **Autoclassificação** | (A); (A); (A) — todas corretas |

**O ciclo de reparo piorou a rodada monotonicamente.** Ver observação 1.

---

## Iterative Repair Loop

| Iteração | Envio | Resposta | Classificação | Resultado |
|---|---|---|---|---|
| 0 (geração) | automação | análise do fluxo + 8 `testWidgets`, `firebase_auth_mocks` + mock manual do mockito para os cenários de erro | — | **compila** — **3/8**. 5 falhas: `[core/no-app]` na navegação e erros do mock manual sob null safety |
| 1 | automação, mesma conversa | arquivo completo; introduz `setupFirebaseCoreMocks()` | **(A)**, correta | **não compila** — `Method not found: 'setupFirebaseCoreMocks'` (o símbolo não estava importado) |
| 2 | automação, mesma conversa | arquivo completo; corrige o import do utilitário | **(A)**, correta | compila, mas **0 testes executam** — `setUpAll` estoura `PlatformException(channel-error, Unable to establish connection on channel.)` |
| 3 | automação, mesma conversa | arquivo completo; troca para `setupFirebaseCoreMocks()` de `firebase_core_platform_interface/test.dart` | **(A)**, correta | **o arquivo nem carrega (final)** — `Binding has not yet been initialized`: `setupFirebaseCoreMocks()` é chamado em `main()` **antes** de `TestWidgetsFlutterBinding.ensureInitialized()` |

### Nota de procedimento — por que não houve reversão

A Fase 2 com ChatGPT tem um precedente de **reverter** uma iteração que regride (`FASE2-INT-FS-01`, iteração 2). Lá a reversão se justificou por duas razões que **não valem aqui**: o próprio modelo reconheceu a regressão, e a correção proposta exigia alterar `lib/login.dart`, fora do escopo do protocolo.

Nesta rodada o modelo não reconheceu regressão alguma — a cada iteração declarou ter corrigido o problema — e nenhuma proposta saiu do arquivo de teste. Aplicar as três e registrar o resultado é o que o protocolo manda. **O estado final arquivado é o da iteração 3, que não carrega.** O melhor estado da rodada (3/8, iteração 0) está preservado no `iter0.txt` e no Apêndice.

---

## Observações

1. **Primeira rodada da réplica em que o reparo piora tudo, monotonicamente:** 3/8 → não compila → 0 executados → nem carrega. Cada iteração foi uma tentativa de resolver o `[core/no-app]` mockando o Firebase Core na camada de plataforma, e cada tentativa quebrou o arquivo um nível mais fundo. O modelo persegue a inicialização do Firebase em vez de reconhecer o acoplamento de `TelaInicialScreen` — que é o que o mesmo modelo, no mesmo alvo, diagnosticou com precisão na rodada 53 (few-shot).
2. **Três (A) corretas e mesmo assim o pior resultado do lote.** As classificações não estão erradas: os erros das iterações 1, 2 e 3 eram mesmo do teste, criados pela própria iteração anterior. O que falha não é o diagnóstico, é a estratégia — o modelo corrige o sintoma que acabou de produzir, em vez de reavaliar a abordagem.
3. **A comparação do lote 12 é o achado mais forte até agora.** Mesmo alvo, mesmo protocolo, três estratégias:

   | Estratégia | Rodada | Testes | Final | Chegou ao (B)? |
   |---|---|---|---|---|
   | Zero-shot | 52 | 7 | **6/7** | não — iterações gastas em erros de compilação |
   | Few-shot | 53 | 4 | **0/4** | **sim, na iteração 2**, e manteve o teste vermelho |
   | Chain-of-thought | 54 | 8 | **0** (não carrega) | não — perseguiu o mock da plataforma até quebrar o arquivo |

   A ordenação por "testes passando" (ZS > FS > COT) é o **inverso** da ordenação por qualidade de diagnóstico (FS > ZS > COT). Um ranking por taxa de aprovação classificaria a única rodada que entendeu o problema como a pior.
4. **Comparação com o ChatGPT na mesma rodada:** ChatGPT gerou 10 testes e fechou em **10/10**, com (A) nas 3 iterações. É a maior distância entre os dois modelos registrada na réplica até aqui — e, ao contrário do lote widget, aqui não há leitura alternativa que favoreça o Gemini: a rodada terminou sem nenhum teste executável.
5. **A geração compilou de primeira** — a primeira vez no bloco 3 e uma das poucas na réplica. O modelo não usou `@GenerateMocks`, evitando o problema do nome presumido do `.mocks.dart` que queimou a iteração 0 das rodadas 48, 51 e 52.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
Aqui está a análise completa do fluxo seguida pelos testes de integração em Dart.

---

### 1. Análise do Fluxo

O usuário inicia na `LoginScreen`, insere seu e-mail e senha nos respectivos campos do formulário e aciona o botão "Entrar". O aplicativo submete as credenciais à validação local síncrona do `FormState` (verificando formato de e-mail e comprimento mínimo da senha); caso inválidas, o envio é interrompido exibindo mensagens inline sob os campos. Caso válidas, aciona-se `FirebaseAuth.signInWithEmailAndPassword`: em caso de sucesso, o app executa `Navigator.pushReplacement` renderizando a `TelaInicialScreen`; em caso de erro (`FirebaseAuthException`), o app permanece na tela de login e exibe um `SnackBar` vermelho com texto customizado de acordo com o código da falha (`user-not-found`, `wrong-password`, `invalid-credential` ou genérico).

---

### 2. Identificação de Dependências e Estratégia de Mocks

* **`FirebaseAuth` (na `LoginScreen`):**
* **Uso:** `signInWithEmailAndPassword(email, password)`.
* **Mock:** A `LoginScreen` aceita injeção direta de dependência pelo construtor (`final FirebaseAuth? auth`). Utilizaremos um mock via `mockito` (ou subclasse de mock do `FirebaseAuth`) para poder configurar respostas dinâmicas (`when(...).thenAnswer(...)` ou `thenThrow(FirebaseAuthException(...))`).


* **`FirebaseAuth` e `FirebaseFirestore` (na `TelaInicialScreen`):**
* **Uso:** A `TelaInicialScreen` acessa diretamente os singletons globais `FirebaseAuth.instance.currentUser` e `FirebaseFirestore.instance.collection(...)` no `initState()` e nas chamadas assíncronas.
* **Observação para os testes:** Para garantir que a `TelaInicialScreen` não quebre ao ser montada após o `pushReplacement`, a verificação de transição de tela pode focar na destruição da `LoginScreen` e na presença de componentes específicos da nova tela (como `TelaInicialScreen` ou seu `BottomNavigationBar`), tratando ou contornando chamadas de singletons com mock pré-carregado ou verificando a navegação via observer.



---

### 3. Estrutura de Navegação para os Testes

Como a `LoginScreen` usa `Navigator.pushReplacement` com `MaterialPageRoute(builder: (context) => const TelaInicialScreen())`, basta envolver a `LoginScreen` em um `MaterialApp` padrão com suporte ao `ScaffoldMessenger`:

```dart
Widget createTestWidget({required FirebaseAuth auth}) {
  return MaterialApp(
    home: LoginScreen(auth: auth),
  );
}

```

Como o `MaterialPageRoute` instancia o widget ### 1. Análise do Fluxo

O fluxo se inicia na `LoginScreen`, onde o usuário insere seu e-mail e senha e aciona o botão "Entrar". O primeiro ponto de decisão ocorre localmente via validação de formulário: se os campos estiverem vazios ou em formato inválido, a submissão é abortada exibindo mensagens de erro de validação sob os campos. Caso o formulário seja válido, o app invoca `signInWithEmailAndPassword` no Firebase Auth; em caso de sucesso, ocorre a substituição de rota (`Navigator.pushReplacement`) para a `TelaInicialScreen`, que consome dados do usuário e coleções no Firestore. Em caso de falha no Firebase, uma exceção `FirebaseAuthException` é capturada e a tela permanece na `LoginScreen`, exibindo um `SnackBar` vermelho com texto amigável correspondente ao código do erro retornado.

---

### 2. Identificação das Dependências e Estratégia de Mock

* **`FirebaseAuth` na `LoginScreen`:**
* Injetado diretamente via construtor `LoginScreen(auth: mockAuth)`.
* Utiliza-se a classe `MockFirebaseAuth` do pacote `firebase_auth_mocks` ou subclasses/mocks com `mockito` para simular tanto o login bem-sucedido quanto o disparo controlado de exceções `FirebaseAuthException` com códigos específicos (`user-not-found`, `wrong-password`, `invalid-credential`, `network-request-failed`).


* **`FirebaseAuth.instance` e `FirebaseFirestore.instance` na `TelaInicialScreen`:**
* A `TelaInicialScreen` acessa instâncias globais estáticas (`FirebaseAuth.instance` e `FirebaseFirestore.instance`). Em testes de integração de widgets Flutter, para manter a fidelidade e evitar modificações nas telas de produção, essas instâncias globais devem ser associadas a um Mock Firebase App ou as chamadas de método de canal de plataforma (`MethodChannel`) devem ser interceptadas/configuradas para o ambiente de testes.



---

### 3. Estrutura de Navegação

Como a `LoginScreen` executa `Navigator.pushReplacement` instanciando diretamente `MaterialPageRoute(builder: (context) => const TelaInicialScreen())`, rotas nomeadas não são mandatórias. A inicialização no teste envolve empacotar a tela em um `MaterialApp`:

```dart
Widget createTestWidget({required FirebaseAuth auth}) {
  return MaterialApp(
    home: LoginScreen(auth: auth),
  );
}

```

---

### 4. Cenários de Teste

1. **Validação de Formulário:**
* Submissão com campos vazios (exibe `"Por favor, insira seu e-mail"` e `"Por favor, insira sua senha"` sem chamar o Firebase).
* Submissão com formato de e-mail inválido (exibe `"Por favor, insira um e-mail válido"`).
* Submissão com senha menor que 6 caracteres (exibe `"A senha deve ter pelo menos 6 caracteres"`).


2. **Erros do Firebase (Feedback via SnackBar):**
* Código `user-not-found`: exibe SnackBar vermelho com `"Usuário não encontrado. Verifique o e-mail e tente novamente."`.
* Código `wrong-password`: exibe SnackBar vermelho com `"Senha incorreta. Certifique-se de que está digitando a senha corretamente."`.
* Código `invalid-credential`: exibe SnackBar vermelho com `"As credenciais fornecidas são inválidas. Tente novamente."`.
* Código genérico/outro: exibe SnackBar vermelho com `"Erro inesperado ao fazer login. Por favor, tente novamente mais tarde."`.


3. **Fluxo de Sucesso Ponta a Ponta:**
* Preenchimento com credenciais válidas, acionamento do botão "Entrar", autenticação bem-sucedida e verificação da transição para a `TelaInicialScreen` (destruindo a `LoginScreen` do widget tree).



---

### 5. Código dos Testes de Integração

Crie o arquivo sob `test/integration/login_flow_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

// Gera classe MockFirebaseAuthCustom para cenários de erro controlados
class MockFirebaseAuthCustom extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}

Widget buildTestableWidget({required FirebaseAuth auth}) {
  return MaterialApp(
    home: LoginScreen(auth: auth),
  );
}

void main() {
  setUpAll(() {
    // Configura carregador de imagem para assets locais nos testes
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Validações de Formulário (LoginScreen)', () {
    testWidgets('Deve exibir erros quando campos estiverem vazios',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      // Clica em Entrar sem preencher campos
      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pumpAndSettle();

      // Verifica exibição das mensagens de validação
      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir erro para formato de e-mail inválido',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'email_invalido');
      await tester.enterText(textFields.at(1), '123456');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir erro quando a senha tiver menos de 6 caracteres',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'usuario@exemplo.com');
      await tester.enterText(textFields.at(1), '123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pumpAndSettle();

      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });

  group('Tratamento de Exceções do Firebase Auth', () {
    late MockFirebaseAuthCustom mockAuthError;

    setUp(() {
      mockAuthError = MockFirebaseAuthCustom();
    });

    testWidgets(
        'Deve exibir SnackBar vermelho quando usuário não for encontrado',
        (WidgetTester tester) async {
      when(mockAuthError.signInWithEmailAndPassword(
        email: 'naoexiste@exemplo.com',
        password: 'password123',
      )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      await tester.pumpWidget(buildTestableWidget(auth: mockAuthError));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'naoexiste@exemplo.com');
      await tester.enterText(textFields.at(1), 'password123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump(); // Inicia animação do SnackBar

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.'),
        findsOneWidget,
      );

      final SnackBar snackBar = tester.widget(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir SnackBar vermelho quando a senha estiver incorreta',
        (WidgetTester tester) async {
      when(mockAuthError.signInWithEmailAndPassword(
        email: 'usuario@exemplo.com',
        password: 'wrong_password',
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      await tester.pumpWidget(buildTestableWidget(auth: mockAuthError));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'usuario@exemplo.com');
      await tester.enterText(textFields.at(1), 'wrong_password');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
        findsOneWidget,
      );
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir SnackBar vermelho para invalid-credential',
        (WidgetTester tester) async {
      when(mockAuthError.signInWithEmailAndPassword(
        email: 'invalido@exemplo.com',
        password: 'password123',
      )).thenThrow(FirebaseAuthException(code: 'invalid-credential'));

      await tester.pumpWidget(buildTestableWidget(auth: mockAuthError));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'invalido@exemplo.com');
      await tester.enterText(textFields.at(1), 'password123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('As credenciais fornecidas são inválidas. Tente novamente.'),
        findsOneWidget,
      );
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir erro inesperado para outros códigos do Firebase',
        (WidgetTester tester) async {
      when(mockAuthError.signInWithEmailAndPassword(
        email: 'erro@exemplo.com',
        password: 'password123',
      )).thenThrow(FirebaseAuthException(code: 'network-request-failed'));

      await tester.pumpWidget(buildTestableWidget(auth: mockAuthError));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'erro@exemplo.com');
      await tester.enterText(textFields.at(1), 'password123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.'),
        findsOneWidget,
      );
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });

  group('Fluxo de Sucesso Ponta a Ponta', () {
    testWidgets('Login com sucesso deve navegar para TelaInicialScreen',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth(
        mockUser: MockUser(
          isAnonymous: false,
          uid: 'user_123',
          email: 'sucesso@exemplo.com',
          displayName: 'Marcos',
        ),
      );

      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'sucesso@exemplo.com');
      await tester.enterText(textFields.at(1), 'senhaSegura123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);

      // Transição de navegação
      await tester.pumpAndSettle();

      // Verifica substituição da tela
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);
    });
  });
}

```
````

### Reparo 1

````markdown
### Classificação da Causa Provável

**Classificação: (A) O teste presume um comportamento que não é o especificado (falhas na implementação/configuração do próprio teste).**

---

### Diagnóstico Técnico das Falhas

1. **Erros nos testes de exceção do Firebase Auth:**
* **Causa:** `MockFirebaseAuthCustom extends Mock implements FirebaseAuth {}` foi instanciado sem geração de código pelo `build_runner` (Mockito com Null Safety não permite mock manual cru sem stubs explícitos ou anotação `@GenerateMocks`). Com isso, ao invocar `when(...)`, o método `signInWithEmailAndPassword` retorna `null`, gerando `type 'Null' is not a subtype of type 'Future<UserCredential>'` e deixando o Mockito em estado corrompido (`Bad state: Cannot call when within a stub response`) para os testes subsequentes.
* **Solução:** Em vez de usar Mockito sem código gerado, podemos estender `Fake` ou criar uma classe concreta leve (`FakeFirebaseAuthException` / mock stub) ou usar uma subclasse direta de `Fake implements FirebaseAuth` com override de `signInWithEmailAndPassword`, sem qualquer complexidade de mock generators.


2. **Erro no fluxo de sucesso (`[core/no-app] No Firebase App '[DEFAULT]' has been created`):**
* **Causa:** Na transição de tela, o `Navigator.pushReplacement` monta a `TelaInicialScreen`. A `TelaInicialScreen` acessa diretamente os singletons estáticos `FirebaseAuth.instance` e `FirebaseFirestore.instance` no seu `initState()` (`_loadLastRecommendedMusic()` -> `fetchLastRecommendedMusic()`), os quais requerem inicialização do Firebase Core no ambiente de testes.
* **Solução:** Configurar a inicialização do mock do Firebase Core no `setUpAll` utilizando os canais de plataforma de teste (`TestDefaultBinaryMessenger` ou configuração do `firebase_core_platform_interface`), permitindo que `TelaInicialScreen` encontre o app padrão mockado sem lançar exceção no teste.



---

### Código dos Testes Corrigido

Substitua o arquivo de teste pelo código abaixo:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

// Fake customizado que não depende de código gerado pelo mockito
// e lança FirebaseAuthException de forma controlada e tipada
class FakeFirebaseAuthWithException extends Fake implements FirebaseAuth {
  final FirebaseAuthException exceptionToThrow;

  FakeFirebaseAuthWithException(this.exceptionToThrow);

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw exceptionToThrow;
  }
}

// Configuração do ambiente mock de Firebase Core para evitar erro [core/no-app]
void setupFirebaseAuthAndFirestoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock do Core Platform Interface
  setupFirebaseCoreMocks();
}

Widget buildTestableWidget({required FirebaseAuth auth}) {
  return MaterialApp(
    home: LoginScreen(auth: auth),
  );
}

void main() {
  setupFirebaseAuthAndFirestoreMocks();

  setUpAll(() async {
    // Inicializa o app Firebase padrão em memória para o ambiente de teste
    await Firebase.initializeApp();
  });

  group('Validações de Formulário (LoginScreen)', () {
    testWidgets('Deve exibir erros quando campos estiverem vazios',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir erro para formato de e-mail inválido',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'email_invalido');
      await tester.enterText(textFields.at(1), '123456');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir erro quando a senha tiver menos de 6 caracteres',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'usuario@exemplo.com');
      await tester.enterText(textFields.at(1), '123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pumpAndSettle();

      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });

  group('Tratamento de Exceções do Firebase Auth', () {
    testWidgets(
        'Deve exibir SnackBar vermelho quando usuário não for encontrado',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'user-not-found'),
      );

      await tester.pumpWidget(buildTestableWidget(auth: fakeAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'naoexiste@exemplo.com');
      await tester.enterText(textFields.at(1), 'password123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump(); // Inicia renderização do SnackBar

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.'),
        findsOneWidget,
      );

      final SnackBar snackBar = tester.widget(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir SnackBar vermelho quando a senha estiver incorreta',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'wrong-password'),
      );

      await tester.pumpWidget(buildTestableWidget(auth: fakeAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'usuario@exemplo.com');
      await tester.enterText(textFields.at(1), 'wrong_password');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
        findsOneWidget,
      );
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir SnackBar vermelho para invalid-credential',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'invalid-credential'),
      );

      await tester.pumpWidget(buildTestableWidget(auth: fakeAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'invalido@exemplo.com');
      await tester.enterText(textFields.at(1), 'password123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('As credenciais fornecidas são inválidas. Tente novamente.'),
        findsOneWidget,
      );
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir erro inesperado para outros códigos do Firebase',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'network-request-failed'),
      );

      await tester.pumpWidget(buildTestableWidget(auth: fakeAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'erro@exemplo.com');
      await tester.enterText(textFields.at(1), 'password123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.'),
        findsOneWidget,
      );
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });

  group('Fluxo de Sucesso Ponta a Ponta', () {
    testWidgets('Login com sucesso deve navegar para TelaInicialScreen',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth(
        mockUser: MockUser(
          isAnonymous: false,
          uid: 'user_123',
          email: 'sucesso@exemplo.com',
          displayName: 'Marcos',
        ),
      );

      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'sucesso@exemplo.com');
      await tester.enterText(textFields.at(1), 'senhaSegura123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);

      // Avança a animação de rota sem aguardar o timer/streams internos da TelaInicial
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verifica que saiu da LoginScreen e montou a TelaInicialScreen
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);
    });
  });
}

```
````

### Reparo 2

````markdown
### Classificação da Causa Provável

**Classificação: (A) O teste presume um comportamento que não é o especificado (falha de compilação/implementação do próprio teste).**

---

### Diagnóstico Técnico da Falha

O método `setupFirebaseCoreMocks()` é utilitário de teste interno do pacote `firebase_core_platform_interface` (ou `firebase_auth_mocks`), mas não é exposto como função global diretamente no escopo público do `firebase_core_platform_interface.dart` nas versões atuais, gerando o erro de compilação `Method not found: 'setupFirebaseCoreMocks'`.

Além disso, note que você possui `fake_cloud_firestore` e `firebase_auth_mocks` disponíveis no projeto. A forma padrão e limpa no Flutter sem depender de funções privadas ou não exportadas do platform interface é:

1. Simular o canal de plataforma do `firebase_core` via `TestDefaultBinaryMessengerBinding` ou registrar o mock platform interface; ou
2. Utilizar a implementação do próprio mock ou criar um mock fake minimalista para o canal `plugins.flutter.io/firebase_core`.

Dessa forma, o Firebase inicializa sem exceções e a `TelaInicialScreen` pode ser montada na transição de telas sem lançar `[core/no-app]`.

---

### Código dos Testes Corrigido

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

// Fake customizado para simular lançamentos de FirebaseAuthException sem Mockito
class FakeFirebaseAuthWithException extends Fake implements FirebaseAuth {
  final FirebaseAuthException exceptionToThrow;

  FakeFirebaseAuthWithException(this.exceptionToThrow);

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw exceptionToThrow;
  }
}

// Configura o canal do Firebase Core para testes locais sem plataforma nativa
void setupFirebaseCoreMockChannels() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_core'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'Firebase#initializeCore') {
        return [
          {
            'name': defaultFirebaseAppName,
            'options': {
              'apiKey': 'fake-api-key',
              'appId': 'fake-app-id',
              'messagingSenderId': 'fake-sender-id',
              'projectId': 'fake-project-id',
            },
            'pluginConstants': {},
          }
        ];
      }
      if (methodCall.method == 'Firebase#initializeApp') {
        return {
          'name': methodCall.arguments['appName'],
          'options': methodCall.arguments['options'],
          'pluginConstants': {},
        };
      }
      return null;
    },
  );
}

Widget buildTestableWidget({required FirebaseAuth auth}) {
  return MaterialApp(
    home: LoginScreen(auth: auth),
  );
}

void main() {
  setupFirebaseCoreMockChannels();

  setUpAll(() async {
    // Inicializa o Firebase padrão mockado em memória
    await Firebase.initializeApp();
  });

  group('Validações de Formulário (LoginScreen)', () {
    testWidgets('Deve exibir erros quando campos estiverem vazios',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir erro para formato de e-mail inválido',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'email_invalido');
      await tester.enterText(textFields.at(1), '123456');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir erro quando a senha tiver menos de 6 caracteres',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'usuario@exemplo.com');
      await tester.enterText(textFields.at(1), '123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pumpAndSettle();

      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });

  group('Tratamento de Exceções do Firebase Auth', () {
    testWidgets(
        'Deve exibir SnackBar vermelho quando usuário não for encontrado',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'user-not-found'),
      );

      await tester.pumpWidget(buildTestableWidget(auth: fakeAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'naoexiste@exemplo.com');
      await tester.enterText(textFields.at(1), 'password123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.'),
        findsOneWidget,
      );

      final SnackBar snackBar = tester.widget(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir SnackBar vermelho quando a senha estiver incorreta',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'wrong-password'),
      );

      await tester.pumpWidget(buildTestableWidget(auth: fakeAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'usuario@exemplo.com');
      await tester.enterText(textFields.at(1), 'wrong_password');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
        findsOneWidget,
      );
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir SnackBar vermelho para invalid-credential',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'invalid-credential'),
      );

      await tester.pumpWidget(buildTestableWidget(auth: fakeAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'invalido@exemplo.com');
      await tester.enterText(textFields.at(1), 'password123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('As credenciais fornecidas são inválidas. Tente novamente.'),
        findsOneWidget,
      );
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir erro inesperado para outros códigos do Firebase',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'network-request-failed'),
      );

      await tester.pumpWidget(buildTestableWidget(auth: fakeAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'erro@exemplo.com');
      await tester.enterText(textFields.at(1), 'password123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.'),
        findsOneWidget,
      );
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });

  group('Fluxo de Sucesso Ponta a Ponta', () {
    testWidgets('Login com sucesso deve navegar para TelaInicialScreen',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth(
        mockUser: MockUser(
          isAnonymous: false,
          uid: 'user_123',
          email: 'sucesso@exemplo.com',
          displayName: 'Marcos',
        ),
      );

      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'sucesso@exemplo.com');
      await tester.enterText(textFields.at(1), 'senhaSegura123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);

      // Transiciona a rota
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verifica transição de tela
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);
    });
  });
}

```
````

### Reparo 3

````markdown
### Classificação da Causa Provável

**Classificação: (A) O teste presume um comportamento que não é o especificado (falha de configuração/mocking no ambiente de execução do próprio teste).**

---

### Diagnóstico Técnico da Falha

1. **Por que a falha ocorreu:**
* O erro `PlatformException(channel-error, Unable to establish connection on channel.)` disparado em `FirebaseCoreHostApi.initializeCore` ocorreu porque as versões modernas do `firebase_core` utilizam comunicação via **Pigeon** (`dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.*`) em vez do canal genérico legada `MethodChannel('plugins.flutter.io/firebase_core')`.
* Por isso, a tentativa manual de registrar o `MethodChannel` foi ignorada pelo SDK, deixando a chamada `Firebase.initializeApp()` sem resposta nativa.


2. **Como corrigir:**
* O utilitário padrão `setupFirebaseCoreMocks()` reside no arquivo de teste da biblioteca da plataforma: `import 'package:firebase_core_platform_interface/test.dart'`. Ele registra automaticamente o `TestFirebaseCoreHostApi` que atende às mensagens Pigeon do `Firebase.initializeApp()`.



---

### Código dos Testes Corrigido

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

// Fake customizado para simular lançamentos de FirebaseAuthException sem depender de stubs do Mockito
class FakeFirebaseAuthWithException extends Fake implements FirebaseAuth {
  final FirebaseAuthException exceptionToThrow;

  FakeFirebaseAuthWithException(this.exceptionToThrow);

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw exceptionToThrow;
  }
}

Widget buildTestableWidget({required FirebaseAuth auth}) {
  return MaterialApp(
    home: LoginScreen(auth: auth),
  );
}

void main() {
  // Inicializa o binding e registra os mocks Pigeon oficiais do Firebase Core
  setupFirebaseCoreMocks();

  setUpAll(() async {
    // Inicializa o app Firebase mockado para o ambiente de testes
    await Firebase.initializeApp();
  });

  group('Validações de Formulário (LoginScreen)', () {
    testWidgets('Deve exibir erros quando campos estiverem vazios',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir erro para formato de e-mail inválido',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'email_invalido');
      await tester.enterText(textFields.at(1), '123456');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir erro quando a senha tiver menos de 6 caracteres',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'usuario@exemplo.com');
      await tester.enterText(textFields.at(1), '123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pumpAndSettle();

      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });

  group('Tratamento de Exceções do Firebase Auth', () {
    testWidgets(
        'Deve exibir SnackBar vermelho quando usuário não for encontrado',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'user-not-found'),
      );

      await tester.pumpWidget(buildTestableWidget(auth: fakeAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'naoexiste@exemplo.com');
      await tester.enterText(textFields.at(1), 'password123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.'),
        findsOneWidget,
      );

      final SnackBar snackBar = tester.widget(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir SnackBar vermelho quando a senha estiver incorreta',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'wrong-password'),
      );

      await tester.pumpWidget(buildTestableWidget(auth: fakeAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'usuario@exemplo.com');
      await tester.enterText(textFields.at(1), 'wrong_password');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
        findsOneWidget,
      );
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir SnackBar vermelho para invalid-credential',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'invalid-credential'),
      );

      await tester.pumpWidget(buildTestableWidget(auth: fakeAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'invalido@exemplo.com');
      await tester.enterText(textFields.at(1), 'password123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('As credenciais fornecidas são inválidas. Tente novamente.'),
        findsOneWidget,
      );
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir erro inesperado para outros códigos do Firebase',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'network-request-failed'),
      );

      await tester.pumpWidget(buildTestableWidget(auth: fakeAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'erro@exemplo.com');
      await tester.enterText(textFields.at(1), 'password123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.'),
        findsOneWidget,
      );
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });

  group('Fluxo de Sucesso Ponta a Ponta', () {
    testWidgets('Login com sucesso deve navegar para TelaInicialScreen',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth(
        mockUser: MockUser(
          isAnonymous: false,
          uid: 'user_123',
          email: 'sucesso@exemplo.com',
          displayName: 'Marcos',
        ),
      );

      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'sucesso@exemplo.com');
      await tester.enterText(textFields.at(1), 'senhaSegura123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);

      // Aguarda o pushReplacement resolver
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Assegura que navegou para a TelaInicialScreen e saiu da LoginScreen
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);
    });
  });
}

```
````
