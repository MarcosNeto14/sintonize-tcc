# WIDGET-COT-01

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | WIDGET-COT-01 |
| **Widget testado** | LoginScreen |
| **Arquivo de origem** | lib/login.dart |
| **Complexidade** | Baixa |
| **Nível da pirâmide** | Integração (Widget Test) |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.5 |
| **Data de acesso** | 2026-05-19 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 |

---

## Prompt Enviado

```
Quero que você gere widget tests em Dart para o widget Flutter abaixo. Antes de escrever os testes, siga estes passos:

1. **Analise o widget:** Descreva em 3-5 frases o que ele faz, quais são seus elementos interativos e quais serviços externos ele usa.
2. **Identifique as dependências que precisam de mock:** Liste quais serviços (Firebase Auth, Firestore, HTTP) são usados e como devem ser mockados.
3. **Identifique os cenários de teste:** Liste todos os cenários relevantes, incluindo:
   - Renderização básica (o widget aparece corretamente?)
   - Validação de formulário (campos vazios, dados inválidos)
   - Interação do usuário (toques, entrada de texto, scroll)
   - Cenários de sucesso (fluxo completo funciona)
   - Cenários de erro (Firebase retorna erro, rede falha)
4. **Escreva os testes:** Para cada cenário, escreva um testWidgets() completo.

IMPORTANTE: Não modifique o código do widget. Apenas gere testes.

Widget a testar:

```dart
[código completo de lib/login.dart — 219 linhas]
```

O widget faz parte do projeto Flutter "sintonize".
Use `import 'package:sintonize/...'` para os imports.

Dependências disponíveis para mocking:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito
```

---

## Resposta do LLM

### 1. Análise do widget

O widget LoginScreen é uma tela de autenticação Flutter que permite ao usuário realizar login utilizando e-mail e senha com integração ao Firebase Authentication. Ele contém dois campos de formulário (TextFormField) com validações locais, um botão principal de login (ElevatedButton) e dois botões secundários (TextButton) para navegação para recuperação de senha e cadastro.

Os elementos interativos principais são: campo de e-mail, campo de senha, botão "Entrar", botão "Esqueci minha senha", botão "Não tem cadastro? Cadastre-se!".

O widget utiliza: FirebaseAuth para autenticação, Navigator para troca de telas, ScaffoldMessenger para exibir mensagens de erro via SnackBar.

### 2. Dependências que precisam de mock

Firebase Authentication — serviço usado: `FirebaseAuth.instance.signInWithEmailAndPassword()`. Como o widget usa diretamente `FirebaseAuth.instance`, o teste precisará sobrescrever a instância padrão do Firebase em ambiente de teste. Utilizar `MockFirebaseAuth` do pacote `firebase_auth_mocks` e `await Firebase.initializeApp()` no `setUpAll`.

### 3. Cenários de teste

- Renderização básica: renderiza logo, campos de e-mail e senha, botão "Entrar", botões de navegação
- Validação de formulário: e-mail vazio, e-mail inválido, senha vazia, senha menor que 6 caracteres
- Interação do usuário: digitar e-mail, digitar senha, tap no botão Entrar, navegação para recuperação de senha, navegação para cadastro, scroll da tela
- Cenários de sucesso: login válido chama FirebaseAuth, navega para TelaInicialScreen
- Cenários de erro: user-not-found, wrong-password, invalid-credential, erro genérico inesperado

### 4. Código gerado (geração inicial)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';
import 'package:sintonize/recup-senha.dart';
import 'package:sintonize/cadastro.dart';

void main() {
  late MockFirebaseAuth mockAuth;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  // [14 testWidgets — renderização, validações, interações, sucesso, erros]
  // Cenários de erro usaram: MockFirebaseAuth(authExceptions: { ... })
}
```

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Não (iteração inicial) → Não (iter 1) → Sim (iter 3) |
| **Testes gerados** | 14 |
| **Testes passaram** | 0 |
| **Testes falharam** | 14 (setUpAll falhou — nenhum executou) |
| **Setup correto de mocks?** | Não — `Firebase.initializeApp()` falha sem `setupFirebaseAuthMocks()` |
| **MaterialApp wrapper?** | Sim |
| **Tratou assets?** | Não |
| **Tipos de teste gerados** | Renderização, Validação de formulário, Interação, Fluxo de sucesso, Cenários de erro (degradados) |

### Saída do terminal (iteração 3 — resultado final)

```
00:00 +0: loading test/widget/login_cot_test.dart
00:00 +0: (setUpAll)
00:00 +0 -1: (setUpAll) [E]
  PlatformException(channel-error, Unable to establish connection on channel., null, null)
  package:firebase_core_platform_interface/src/pigeon/messages.pigeon.dart 210:7  FirebaseCoreHostApi.initializeCore

00:00 +0 -1: (tearDownAll)
00:00 +0 -1: Some tests failed.
```

---

## Iterative Repair Loop

### Iteração 1
- **Necessária?** Sim
- **Motivo da falha:** Parâmetro `authExceptions` não existe em `firebase_auth_mocks 0.14.2` — erro de compilação em 4 ocorrências
- **Prompt de correção:** Informado o erro de compilação e a versão do pacote; solicitado correção dos 4 testes de erro
- **Resposta do LLM:** Substituiu `authExceptions` por `whenCalling(Invocation.method(...)).on(mockAuth).thenThrow(...)`
- **Resultado:** Falhou — `Method not found: 'whenCalling'` (função não existe nessa versão)

### Iteração 2
- **Necessária?** Sim
- **Motivo da falha:** `whenCalling` não é função disponível na versão do projeto; widget usa `FirebaseAuth.instance` diretamente (sem injeção de dependência), impossibilitando interception de erros
- **Prompt de correção:** Informado o erro e a limitação arquitetural; solicitado degradar os 4 testes de erro para apenas verificar que o widget permanece na tela
- **Resposta do LLM:** Substituiu todos os cenários de erro por testes que apenas verificam `expect(find.byType(LoginScreen), findsOneWidget)` após tap no botão
- **Resultado:** Falhou — código compilou mas `setUpAll` lança `PlatformException` em `Firebase.initializeApp()` (canal de plataforma indisponível no ambiente de teste)

### Iteração 3
- **Necessária?** N/A — limite de 3 iterações atingido após iteração 2; resultado final registrado com falha em setUpAll
