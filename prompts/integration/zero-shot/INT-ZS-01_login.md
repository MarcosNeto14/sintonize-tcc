# INT-ZS-01

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | INT-ZS-01 |
| **Fluxo testado** | Login (LoginScreen → TelaInicialScreen) |
| **Arquivos de origem** | `lib/login.dart`, `lib/tela-inicial.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.5 |
| **Data de acesso** | 2026-05-21 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | Flutter 3.41.6 • Dart 3.11.4 |

---

## Prompt Enviado

````
Gere um teste de integração em Dart usando flutter_test para o seguinte fluxo do aplicativo Flutter "Sintonize":

O usuário preenche email e senha na LoginScreen e, após autenticação bem-sucedida, é redirecionado para a TelaInicialScreen, onde vê o conteúdo da tela inicial.

Código das telas envolvidas:

// ============ lib/login.dart ============
[código completo de lib/login.dart colado no prompt]

// ============ lib/tela-inicial.dart ============
[código completo de lib/tela-inicial.dart colado no prompt]

Dependências disponíveis para mocking:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito

Requisitos:
- Use testWidgets() do flutter_test
- Monte todas as telas do fluxo dentro de um MaterialApp com rotas configuradas
- Configure os mocks de Firebase necessários
- Teste o fluxo completo ponta a ponta: interações na primeira tela → navegação → estado da tela destino
- Teste também cenários de erro (credenciais inválidas, campos vazios, Firebase retorna erro)
- Os testes devem ser executáveis com `flutter test test/integration/`
- Use `import 'package:sintonize/...'` para os imports do projeto
````

---

## Resposta do LLM

*(Texto da resposta do LLM não capturado durante a rodada. O código gerado / alterações estão descritos abaixo.)*

**Código gerado (Iteração 1):**

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget createWidgetTest(Widget child) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: child,
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const TelaInicialScreen(),
      },
    );
  }

  group('Fluxo de Login - Sintonize', () {
    testWidgets('Deve realizar login com sucesso e navegar para TelaInicialScreen', ...);
    testWidgets('Deve exibir erro quando email estiver vazio', ...);
    testWidgets('Deve exibir erro quando senha estiver vazia', ...);
    testWidgets('Deve exibir erro para email inválido', ...);
    testWidgets('Deve exibir erro para senha curta', ...);
    testWidgets('Deve exibir SnackBar quando Firebase retornar erro de credenciais', ...);
    testWidgets('Deve renderizar elementos principais da TelaInicialScreen', ...);
  });
}
```

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Não |
| **Testes gerados** | 5 |
| **Testes passaram (1ª execução)** | 0 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | 3 |
| **Testes falharam (pós-repair)** | 2 |

### Saída do terminal

```
test/integration/login_flow_zs_test.dart:215:11: Error: No named parameter with the name 'exception'.
          exception: FirebaseAuthException(
          ^^^^^^^^^
Failed to load: Compilation failed
00:00 +0 -1: Some tests failed.
```

---

## Iterative Repair Loop

### Iteração 1

**Prompt de reparo enviado:**

```
O teste de integração falhou com o seguinte erro:

test/integration/login_flow_zs_test.dart:215:11: Error: No named parameter with the name 'exception'.
          exception: FirebaseAuthException(

Contexto adicional: a versão instalada é firebase_auth_mocks 0.14.2. Nessa versão, o parâmetro correto para simular exceções é authExceptions, não exception. Exemplo:
MockFirebaseAuth(
  authExceptions: AuthExceptions(
    signInWithEmailAndPassword: FirebaseAuthException(code: 'invalid-credential'),
  ),
)

Corrija o teste para que compile e passe corretamente. Não modifique o código das telas, apenas o código do teste.
```

**Resposta do LLM:**

*(Texto da resposta do LLM não capturado durante a rodada. O código gerado / alterações estão descritos abaixo.)*

Introduziu `setupFirebaseAuthMocks()` + `Firebase.initializeApp()` no `setUpAll` e substituiu `exception:` por `authExceptions: AuthExceptions(...)`.

**Resultado:**

**Compilou?** Não
**Erro:** `setupFirebaseAuthMocks` e `AuthExceptions` não existem em `firebase_auth_mocks 0.14.2`; `authExceptions` também não é parâmetro do construtor nessa versão.

```
test/integration/login_flow_zs_test.dart:17:5: Error: Method not found: 'setupFirebaseAuthMocks'.
test/integration/login_flow_zs_test.dart:127:27: Error: Method not found: 'AuthExceptions'.
test/integration/login_flow_zs_test.dart:127:11: Error: No named parameter with the name 'authExceptions'.
Failed to load: Compilation failed
00:00 +0 -1: Some tests failed.
```

---

### Iteração 2

**Prompt de reparo enviado:**

```
O teste de integração falhou novamente com os seguintes erros:

Error: Method not found: 'setupFirebaseAuthMocks'.
Error: Method not found: 'AuthExceptions'.
Error: No named parameter with the name 'authExceptions'.

Contexto real da versão instalada — firebase_auth_mocks 0.14.2:

O construtor de MockFirebaseAuth aceita APENAS estes parâmetros:
  MockFirebaseAuth({
    bool signedIn = false,
    MockUser? mockUser,
    Map<String, List<String>>? signInMethodsForEmail,
    bool verifyEmailAutomatically = true,
  })

Não existe: setupFirebaseAuthMocks(), AuthExceptions, nem authExceptions ou exception.

Para inicializar o Firebase em testes, use apenas:
  TestWidgetsFlutterBinding.ensureInitialized();

Corrija o teste removendo setupFirebaseAuthMocks(), Firebase.initializeApp(), AuthExceptions e authExceptions. O teste de erro de credenciais deve ser simplificado. Não modifique o código das telas.
```

**Resposta do LLM:**

*(Texto da resposta do LLM não capturado durante a rodada. O código gerado / alterações estão descritos abaixo.)*

Removeu `setupFirebaseAuthMocks()`, `Firebase.initializeApp()`, `AuthExceptions`. Simplificou o teste de erro para apenas verificar que `LoginScreen` permanece presente após o tap. Reduziu de 7 para 5 testes.

**Resultado:**

**Compilou?** Sim
**Testes gerados:** 5
**Passaram:** 3
**Falharam:** 2

```
00:00 +0: loading
00:00 +0: Fluxo de Login - Sintonize Deve validar campos vazios
00:01 +1: Fluxo de Login - Sintonize Deve validar email inválido
00:02 +2: Fluxo de Login - Sintonize Deve validar senha curta
00:02 +3: Fluxo de Login - Sintonize Não deve navegar quando login falhar
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞═══════════
FirebaseException: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
  at LoginScreen.build.login (package:sintonize/login.dart:25:28)
  ...
00:03 +3 -2: Fluxo de Login - Sintonize Deve renderizar TelaInicialScreen [E]
00:03 +3 -2: Some tests failed.
```

---

### Iteração 3

Não necessária.
