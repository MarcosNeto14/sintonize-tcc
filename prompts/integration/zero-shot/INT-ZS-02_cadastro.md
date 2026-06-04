# INT-ZS-02

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | INT-ZS-02 |
| **Fluxo testado** | Cadastro (CadastroScreen → GenerosCadastroScreen) |
| **Arquivos de origem** | `lib/cadastro.dart`, `lib/generos-cadastro.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.5 |
| **Data de acesso** | 2026-05-22 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | Flutter 3.41.6 / Dart 3.11.4 |

---

## Prompt Enviado

```
Gere um teste de integração em Dart usando flutter_test para o seguinte fluxo do aplicativo Flutter "Sintonize":

O usuário preenche o formulário de cadastro na CadastroScreen e, após registro bem-sucedido no Firebase (Auth + Firestore), é redirecionado para a GenerosCadastroScreen onde seleciona gêneros musicais favoritos. Há também o caminho secundário: o botão "Já tem uma conta? Faça login" navega para a LoginScreen.

Código das telas envolvidas:
[código completo de lib/cadastro.dart e lib/generos-cadastro.dart]

Dependências disponíveis para mocking:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito

Requisitos:
- Use testWidgets() do flutter_test
- Monte todas as telas do fluxo dentro de um MaterialApp com rotas configuradas
- Configure os mocks de Firebase necessários
- Teste o fluxo completo ponta a ponta: interações na primeira tela → navegação → estado da tela destino
- Teste também cenários de erro (campos inválidos, Firebase retorna erro ao criar usuário)
- Os testes devem ser executáveis com `flutter test test/integration/`
- Use `import 'package:sintonize/...'` para os imports do projeto
```

---

## Resposta do LLM

O LLM identificou que as telas usam `FirebaseAuth.instance` e `FirebaseFirestore.instance` estáticos e propôs **modificar o código de produção** para suportar injeção de dependência (parâmetros opcionais `auth` e `firestore` nos construtores de `CadastroScreen` e `GenerosCadastroScreen`). O teste gerado depende dessas modificações.

Testes gerados (5):
1. `deve preencher formulário e navegar para GenerosCadastroScreen`
2. `deve navegar para LoginScreen ao clicar em Faça login`
3. `deve mostrar erros de validação quando formulário inválido`
4. `deve mostrar snackbar quando Firebase retorna erro`
5. `deve selecionar gênero musical e confirmar`

**Arquivo gerado:** `test/integration/cadastro_flow_zs_test.dart`
_(código salvo em arquivo — ver test/integration/cadastro_flow_zs_test.dart)_

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Não |
| **Testes gerados** | 7 |
| **Testes passaram (1ª execução)** | 0 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | 1 |
| **Testes falharam (pós-repair)** | 6 |

### Saída do terminal

```
00:00 +0 -1: loading cadastro_flow_zs_test.dart [E]
  Failed to load "cadastro_flow_zs_test.dart":
  Compilation failed:
  test/integration/cadastro_flow_zs_test.dart:60:9: Error: No named parameter with the name 'auth'.
          auth: auth,
          ^^^^
  lib/cadastro.dart:11:9: Context: Found this candidate, but the arguments don't match.
    const CadastroScreen({super.key});
  test/integration/cadastro_flow_zs_test.dart:65:15: Error: No named parameter with the name 'auth'.
                auth: auth,
                ^^^^
  lib/generos-cadastro.dart:7:9: Context: Found this candidate, but the arguments don't match.
    const GenerosCadastroScreen({super.key});
  test/integration/cadastro_flow_zs_test.dart:339:13: Error: No named parameter with the name 'auth'.
              auth: signedAuth,
              ^^^^
  lib/generos-cadastro.dart:7:9: Context: Found this candidate, but the arguments don't match.
    const GenerosCadastroScreen({super.key});
00:00 +0 -1: Some tests failed.
```

**Diagnóstico:** o LLM gerou um teste que pressupõe injeção de dependência nos construtores das telas. Os construtores de produção não possuem os parâmetros `auth` e `firestore` — o LLM sugeriu modificar as telas, o que foge do escopo do experimento. O prompt de reparo vai solicitar que o teste seja reescrito **sem modificar o código de produção**.

---

## Iterative Repair Loop

### Iteração 1

**Prompt de reparo enviado:**
```
O teste de integração falhou com o seguinte erro de compilação:

test/integration/cadastro_flow_zs_test.dart:60:9: Error: No named parameter with the name 'auth'.
lib/cadastro.dart:11:9: Context: Found this candidate, but the arguments don't match.
  const CadastroScreen({super.key});
test/integration/cadastro_flow_zs_test.dart:65:15: Error: No named parameter with the name 'auth'.
lib/generos-cadastro.dart:7:9: Context: Found this candidate, but the arguments don't match.
  const GenerosCadastroScreen({super.key});

Restrição importante: não é permitido modificar o código das telas. Corrija o teste para que compile
sem modificar o código de produção. Use apenas os mecanismos disponíveis no firebase_auth_mocks e
fake_cloud_firestore para contornar o acoplamento estático (por exemplo, setupFirebaseAuthMocks(),
Firebase.initializeApp(), ou qualquer outra abordagem compatível com os construtores originais).
```

**Resposta do LLM:**
O LLM removeu a injeção de dependência e propôs usar `setupFirebaseAuthMocks()` + `Firebase.initializeApp()` + mock manual do `MethodChannel` do Firestore. Gerou 7 testes focados apenas em UI/validação (sem testar o submit completo).

**Resultado:**
```
00:00 +0 -1: loading cadastro_flow_zs_test.dart [E]
  Failed to load "cadastro_flow_zs_test.dart":
  Compilation failed:
  test/integration/cadastro_flow_zs_test.dart:40:5: Error: Method not found: 'setupFirebaseAuthMocks'.
      setupFirebaseAuthMocks();
      ^^^^^^^^^^^^^^^^^^^^^^
00:00 +0 -1: Some tests failed.
```

**Diagnóstico:** `setupFirebaseAuthMocks()` não existe na versão instalada (`firebase_auth_mocks: 0.14.2`). O pacote só exporta `MockFirebaseAuth` e `MockUser`. O teste nunca chama Firebase realmente (todos os 7 cenários testam validação/UI), logo `setupFirebaseAuthMocks()` e `Firebase.initializeApp()` são desnecessários.

---

### Iteração 2

**Prompt de reparo enviado:**
```
O teste ainda falhou com um novo erro de compilação:

test/integration/cadastro_flow_zs_test.dart:40:5: Error: Method not found: 'setupFirebaseAuthMocks'.

A versão instalada é firebase_auth_mocks: 0.14.2. Essa versão NÃO exporta setupFirebaseAuthMocks() —
o pacote só exporta MockFirebaseAuth e MockUser.

Além disso, analisando os 7 testes gerados, NENHUM deles chega a executar o submit do formulário nem
chamar Firebase realmente. Portanto, setupFirebaseAuthMocks(), Firebase.initializeApp() e o mock manual
de MethodChannel são completamente desnecessários.

Corrija o teste removendo todo o código de inicialização do Firebase (setUpAll, Firebase.initializeApp,
setupFirebaseAuthMocks, MethodChannel mock) e também removendo os imports de firebase_core e
flutter/services.dart. Mantenha os 7 testes de UI/validação exatamente como estão.
```

**Resposta do LLM:**
O LLM removeu corretamente toda a infraestrutura de Firebase (setUpAll, setupFirebaseAuthMocks, Firebase.initializeApp, MethodChannel mock, imports de firebase_core e flutter/services.dart). Manteve os 7 testes e a variável `fakeFirestore` declarada (mas nunca usada). Arquivo compilou.

**Resultado:**
```
00:07 +0 -5: CadastroScreen Integration deve validar campos obrigatórios [E]
  Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "O nome é obrigatório": []>
  (botão "Cadastrar" está off-screen — Offset(400,870) fora dos limites 800x600)

00:07 +0 -5: CadastroScreen Integration deve validar email inválido [E]
  (mesmo problema — botão off-screen)

00:07 +0 -5: CadastroScreen Integration deve validar senha diferente [E]
  (mesmo problema)

00:07 +0 -5: CadastroScreen Integration deve preencher formulário corretamente [E]
  (campos off-screen, interações não alcançam os widgets)

00:07 +0 -5: CadastroScreen Integration deve navegar para login [E]
  Expected: no matching candidates
  Actual: Found 1 widget with type "CadastroScreen"
  (CadastroScreen ainda visível: Navigator.push empilha a tela, não substitui;
   e o LoginScreen usa MaterialPageRoute direto, não a rota nomeada '/login')

00:08 +1 -5: CadastroScreen Integration GenerosCadastroScreen deve selecionar gênero [PASS]

00:08 +1 -6: CadastroScreen Integration GenerosCadastroScreen deve exigir ao menos um gênero [E]
  Expected: exactly one matching candidate
  Actual: Found 0 widgets with text "Selecione pelo menos um gênero musical!"
  (botão "Confirmar" off-screen — Offset(400,618) fora dos limites)

00:08 +1 -6: Some tests failed.
```

---

### Iteração 3

Não necessária.
