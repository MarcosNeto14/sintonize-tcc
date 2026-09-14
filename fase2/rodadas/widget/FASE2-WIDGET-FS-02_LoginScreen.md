# FASE2-WIDGET-FS-02_LoginScreen — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WIDGET-FS-02 |
| **Tela testada** | `LoginScreen` — `lib/login.dart` (alvo limpo, bug W-SILENT do piloto já revertido em `fase2-prep`, sem reversão adicional necessária nesta branch) |
| **Arquivo de origem** | `lib/login.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das demais rodadas da Fase 2, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-14 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/widget/login_screen_fs_test.dart` |
| **Execução** | **Mesmo desvio de execução da rodada `FASE2-WIDGET-ZS-02_LoginScreen`** — conduzida manualmente pelo autor no teclado (Claude Code forneceu o texto exato de cada prompt original e de reparo, e assumiu a documentação, gravação dos arquivos de teste, execução do `flutter test` e registro da rodada), não por automação de navegador. Ver a nota detalhada nos metadados de `FASE2-WIDGET-ZS-02_LoginScreen.md` para o histórico completo de por que esse desvio foi adotado a partir desta fase das 12 rodadas restantes. |

**Verificação pré-rodada:** `lib/login.dart` não tem bug plantado — única
diferença em relação a `main` é a injeção de dependência opcional de
`auth`. `TelaInicialScreen` mantém a limitação de testabilidade conhecida
(acesso direto a `FirebaseAuth.instance`/`FirebaseFirestore.instance`, sem
injeção), já documentada nas 3 rodadas de integração do fluxo de login
(`FASE2-INT-*-01_loginFlow`) e na rodada `FASE2-WIDGET-ZS-02_LoginScreen`.

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/widget/few-shot/FASE2-WIDGET-FS-02_LoginScreen.md`
— um exemplo de widget test bem escrito (formulário de login genérico com
`firebase_auth_mocks`) seguido do código completo de `LoginScreen` colado
verbatim, pedindo para seguir o mesmo padrão do exemplo.

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Gerou 8 testes em um único `group`, usando `firebase_auth_mocks`
(`MockFirebaseAuth()` "real", não mockito) para todos os cenários,
incluindo um teste de login bem-sucedido que verificava
`find.byType(TelaInicialScreen)` diretamente e um teste de
`user-not-found` que **não configurava a exceção** — usando apenas o
`MockFirebaseAuth()` padrão — com uma observação honesta ao final da
resposta reconhecendo essa limitação e sugerindo mockito para configurar
as exceções explicitamente.

### Iteração 1 (repair) — 3 falhas na execução inicial

- **Motivo da falha:** (1) login bem-sucedido navegava para
  `TelaInicialScreen`, que esbarra no acesso direto a
  `FirebaseAuth.instance` (`[core/no-app]`); (2) o teste de
  `user-not-found` não configurava a exceção (mesma lacuna já reconhecida
  pelo próprio modelo na resposta inicial), então a mensagem de erro nunca
  aparecia; (3) `tap()` no botão de cadastro fora da viewport de
  600px (mesmo padrão já visto em `FASE2-WIDGET-ZS-02_LoginScreen`).
- **Resposta do LLM:** classificou os três padrões como **(A)**. Para (1),
  reconheceu a limitação de testabilidade de `TelaInicialScreen` e propôs
  testar a navegação via `NavigatorObserver` em vez de deixar
  `TelaInicialScreen` montar de verdade. Para (2), propôs usar
  `mockito` com uma classe `MockFirebaseAuthWithMockito extends Mock
  implements FirebaseAuth` — mas **definiu essa classe e nunca a usou**,
  continuando a chamar `when()`/`anyNamed()` sobre o `mockAuth` de
  `firebase_auth_mocks` (que não é um mock do mockito). Para (3), propôs
  `scrollUntilVisible`.
- **Resultado após correção:** não compilou — `anyNamed('email')`/
  `anyNamed('password')` retornam `null` como placeholder (mecanismo do
  mockito), mas como `mockAuth` não é um objeto mockito de verdade, o
  método real foi invocado com `null`, causando `Error: The argument type
  'Null' can't be assigned to the parameter type 'String'` (6 ocorrências)
  além de `Method not found: 'MockUserCredential'` (classe não pública).

### Iteração 2 (repair) — erro de compilação (mistura de dois mecanismos de mock)

- **Motivo da falha:** mistura inconsistente entre o `MockFirebaseAuth`
  "fake" de `firebase_auth_mocks` e o mecanismo `when()`/`anyNamed()` do
  mockito, que exige um mock mockito de verdade.
- **Resposta do LLM:** classificou **(A)** — reconheceu explicitamente o
  problema ("a classe `MockFirebaseAuthWithMockito` que eu havia criado
  não estava sendo usada") e reescreveu a solução para separar os papéis:
  renomeou a própria classe mockito local para `MockFirebaseAuth extends
  Mock implements FirebaseAuth` (colidindo intencionalmente com o nome
  importado de `firebase_auth_mocks`, que deixou de ser usado no arquivo)
  e trocou `MockNavigatorObserver`/`anyNamed` por um
  `TestNavigatorObserver` manual e por argumentos literais exatos em vez
  de matchers.
- **Resultado após correção:** compilou (a redefinição de
  `MockFirebaseAuth` não gerou conflito de nomes, pois o import de
  `firebase_auth_mocks` foi removido nesta versão); mas **6 de 11
  falharam** — `type 'Null' is not a subtype of type
  'Future<UserCredential>'` no primeiro teste de Firebase Auth (mock
  mockito sem geração de código/`provideDummy` não sabe produzir um valor
  dummy para o retorno não-nulável `Future<UserCredential>`), erro que
  aparentemente deixou o estado interno do mockito corrompido e quebrou em
  cascata os 4 testes de exceção seguintes (`Bad state: Cannot call
  'when' within a stub response`), mais uma falha independente em
  `scrollUntilVisible` (`Bad state: Too many elements`) no teste de
  navegação para cadastro.

### Iteração 3 (repair, última permitida) — dummy de mockito insuficiente

- **Motivo da falha:** mesmo padrão da iteração 2, causado pela ausência
  de um valor dummy registrado para `Future<UserCredential>` antes do uso
  do mock mockito sem geração de código.
- **Resposta do LLM:** classificou **(A)** para os três padrões de falha.
  Adicionou `provideDummy<Future<UserCredential>>(Future<UserCredential>
  .value(MockUserCredential()))` em um `setUpAll()`, mantendo o restante
  da estrutura da iteração 2. Trocou `scrollUntilVisible` por
  `tester.ensureVisible()` no teste de cadastro, citando explicitamente
  que essa abordagem já havia funcionado em outra rodada do mesmo projeto
  (informação fornecida pelo operador no prompt de reparo).
- **Resultado após correção:** o teste de navegação para cadastro passou
  (`ensureVisible` resolveu o problema, como na rodada ZS). Porém **o
  erro `type 'Null' is not a subtype of type 'Future<UserCredential>'`
  persistiu de forma idêntica** no teste de login bem-sucedido, e os 4
  testes de exceção seguintes voltaram a falhar em cascata pelo mesmo
  motivo da iteração 2 — o `provideDummy` adicionado não resolveu o
  problema. **Limite de 3 iterações de reparo esgotado**: falha final
  documentada sem correção adicional, conforme protocolo do repositório.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim na geração inicial; erro de compilação na iteração 1; sim novamente nas iterações 2 e 3 |
| **Testes gerados** | 8 (geração inicial) → 11 (a partir da iteração 1, com os testes de exceção desmembrados) |
| **Testes passaram (1ª execução)** | 5 |
| **Testes falharam (1ª execução)** | 3 |
| **Testes passaram (pós-repair, iteração 3/3 — final)** | 6 |
| **Testes falharam (pós-repair, iteração 3/3 — final)** | 5 |

### Saída do terminal (iteração 0 — geração inicial)

```
00:02 +4 -1: LoginScreen Widget deve realizar login e navegar para tela inicial [E]
[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()

00:03 +4 -2: LoginScreen Widget deve mostrar mensagem quando usuário não existe [E]
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Usuário não encontrado...": []>

00:03 +5 -3: LoginScreen Widget deve navegar para cadastro [E]
Offset(400.0, 664.0) ... outside the bounds ... Size(800.0, 600.0)
...
00:03 +5 -3: Some tests failed.
```

(saída completa em `fase2/resultados/widget/few-shot/FASE2-WIDGET-FS-02_LoginScreen_iter0.txt`)

### Saída do terminal (iteração 1 — erro de compilação)

```
test/fase2/widget/login_screen_fs_test.dart:115:24: Error: Method not found: 'MockUserCredential'.
test/fase2/widget/login_screen_fs_test.dart:111:20: Error: The argument type 'Null' can't be assigned to the parameter type 'String'.
(mesmo erro de 'Null' em mais 4 pares de linhas)
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/widget/few-shot/FASE2-WIDGET-FS-02_LoginScreen_iter1.txt`)

### Saída do terminal (iteração 2 — 5/11)

```
00:02 +4 -1: LoginScreen Widget deve realizar login e navegar para tela inicial [E]
type 'Null' is not a subtype of type 'Future<UserCredential>'

00:02 +4 -2: LoginScreen Widget deve mostrar mensagem quando usuário não existe [E]
Bad state: Cannot call `when` within a stub response
(mesmo erro nos 3 testes de exceção seguintes)

00:03 +5 -6: LoginScreen Widget deve navegar para cadastro [E]
Bad state: Too many elements
...
00:02 +5 -6: Some tests failed.
```

(saída completa em `fase2/resultados/widget/few-shot/FASE2-WIDGET-FS-02_LoginScreen_iter2.txt`)

### Saída do terminal (iteração 3 — final, 6/11)

```
00:02 +4 -1: LoginScreen Widget deve realizar login e navegar para tela inicial [E]
type 'Null' is not a subtype of type 'Future<UserCredential>'
#0      MockFirebaseAuth.signInWithEmailAndPassword (test/fase2/widget/login_screen_fs_test.dart:10:7)

(mesmo erro em cascata nos 4 testes de exceção seguintes — Bad state: Cannot call `when` within a stub response)

00:03 +6 -5: Some tests failed.
```

(saída completa em `fase2/resultados/widget/few-shot/FASE2-WIDGET-FS-02_LoginScreen_iter3_final.txt`)

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** 3 padrões — (1) testabilidade de `TelaInicialScreen`; (2) `user-not-found` sem exceção configurada; (3) `tap()` fora da viewport.
- **Prompt de reparo enviado:** os três erros de execução completos, pedindo classificação separada para cada um, com nota lembrando a observação do próprio modelo na resposta inicial sobre a necessidade de mockito.
- **Resposta do LLM:** **(A)** para os três. Propôs `NavigatorObserver`, mockito (`MockFirebaseAuthWithMockito`, mas não usada) e `scrollUntilVisible`.
- **Resultado após correção:** não compilou — API mockito aplicada sobre objeto que não é um mock mockito (`anyNamed` retornando `null` para parâmetro `String`), mais `MockUserCredential` inexistente.

### Iteração 2

- **Motivo da falha:** erro de compilação por mistura inconsistente entre `firebase_auth_mocks.MockFirebaseAuth` e o mecanismo `when()` do mockito.
- **Prompt de reparo enviado:** erro de compilação completo, com nota explícita apontando a classe `MockFirebaseAuthWithMockito` definida e nunca usada, sugerindo usá-la de fato ou voltar ao mecanismo `whenCalling`/`mock_exceptions` que já havia funcionado na rodada ZS.
- **Resposta do LLM:** classificação **(A)** — reconheceu o problema e reescreveu a solução redefinindo `MockFirebaseAuth` localmente como mock mockito (removendo o import de `firebase_auth_mocks`), com `TestNavigatorObserver` manual e argumentos literais em vez de matchers.
- **Resultado após correção:** compilou; 5/11 passaram, 6 falharam — erro de tipo `Future<UserCredential>` sem dummy, com efeito cascata sobre os testes de exceção seguintes, mais uma falha independente de `scrollUntilVisible`.

### Iteração 3 (máximo)

- **Motivo da falha:** mesmo erro de tipo (ausência de valor dummy do mockito para retorno não-nulável) e sua cascata sobre os testes de exceção; falha independente de `scrollUntilVisible`.
- **Prompt de reparo enviado:** os três padrões de erro com stack traces, citando que `ensureVisible` já havia funcionado em outra rodada do projeto para o mesmo tipo de problema, e sugerindo `provideDummy` ou o mecanismo `whenCalling`/`mock_exceptions` como alternativas caso a abordagem com `Mock` continuasse frágil — deixando a escolha para o modelo.
- **Resposta do LLM:** classificação **(A)** para os três padrões. Adicionou `provideDummy<Future<UserCredential>>(...)` em `setUpAll()` e trocou `scrollUntilVisible` por `ensureVisible`.
- **Resultado após correção:** `ensureVisible` resolveu o problema de cadastro (1 teste a mais passou). **O `provideDummy` não resolveu o erro de tipo** — a mesma exceção `type 'Null' is not a subtype of type 'Future<UserCredential>'` ocorreu de forma idêntica, e os 4 testes de exceção voltaram a falhar em cascata pelo mesmo motivo. **Limite de reparo esgotado (3/3) — falha final documentada sem correção adicional**, conforme protocolo do repositório.

**Nota sobre (C):** não aplicável — a rodada teve falhas reais com ciclo de reparo em todas as três iterações, não um bug identificado espontaneamente na geração inicial sem falha.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) em todas as três iterações, para todos os padrões de falha identificados. |
| **★ Classificação humana (auditoria)** | Iteração 1, padrão 1 (testabilidade de `TelaInicialScreen`): concordo — **Limitação de testabilidade**, não erro de teste em sentido estrito. Padrão 2 (`user-not-found` sem exceção configurada) e padrão 3 (viewport): concordo — **Erro de teste** genuíno. Resultado da correção da iteração 1 (API mockito aplicada sobre objeto não-mockito) e das iterações 2/3 (ausência de dummy para retorno não-nulável do mockito sem geração de código): **Erro de geração** — o modelo produziu, em três tentativas consecutivas, código que depende de uma capacidade do mockito (dummies automáticos para tipos não-nulos complexos) que só existe de fato com `@GenerateMocks`/`build_runner`, ou que exige uma chamada de `provideDummy` com a assinatura exata esperada pela API — a tentativa da iteração 3 usou `provideDummy<Future<UserCredential>>(...)`, mas o erro indica que o mockito precisava do dummy do tipo `UserCredential` (não de `Future<UserCredential>`) ou de um mecanismo adicional não utilizado, e isso não foi diagnosticado corretamente nem na 2ª nem na 3ª tentativa. |
| **★ Concordância** | Parcial — concordância alta na classificação da *causa raiz* imediata de cada falha (o modelo geralmente identificou corretamente "isso é um erro de configuração de mock", "isso é um problema de viewport"), mas **discordância relevante no resultado prático**: a estratégia escolhida pelo modelo para testar exceções do Firebase Auth (mock mockito hand-rolled sem geração de código) se mostrou fundamentalmente frágil e consumiu as 3 iterações de reparo disponíveis sem nunca produzir uma versão funcional — em contraste direto com a rodada `FASE2-WIDGET-ZS-02_LoginScreen` (mesmo alvo, mesma classe de problema), em que a 2ª iteração de reparo, usando o mecanismo real do pacote `firebase_auth_mocks` (`whenCalling`/`mock_exceptions`) em vez de mockito hand-rolled, teve sucesso completo. |
| **★ Observações** | Achado mais relevante desta rodada para a comparação entre estratégias de prompt: a resposta few-shot, guiada pelo exemplo fornecido (que usava apenas `firebase_auth_mocks`, sem mockito), inicialmente evitou mockito — mas ao tentar reparar o teste de `user-not-found`, migrou para uma abordagem mockito hand-rolled que nunca funcionou nas 3 iterações permitidas, mesmo depois de receber a dica explícita (no prompt de reparo da iteração 3) de que o mecanismo `whenCalling`/`mock_exceptions` já havia funcionado no mesmo projeto. O modelo optou por perseverar na abordagem mockito com `provideDummy` em vez de adotar a alternativa sugerida, e essa escolha não se pagou. Isso é um contraste direto e informativo com `FASE2-WIDGET-ZS-02_LoginScreen`: mesmo alvo (`LoginScreen`), mesmo tipo de falha inicial (API de mock incompatível com a versão instalada), mas trajetórias de reparo com desfechos opostos — a rodada ZS chegou a 11/12 (92%) usando o mecanismo nativo do pacote já disponível no projeto; esta rodada FS ficou em 6/11 (55%) insistindo em uma abordagem mockito sem geração de código que o próprio ambiente do projeto não suporta sem configuração adicional (`build_runner`). O teste de "botão de cadastro" (viewport) seguiu o mesmo padrão observado em `FASE2-WIDGET-ZS-02_LoginScreen` e `FASE2-WIDGET-ZS-01_CadastroScreen`: `ensureVisible` resolve de forma confiável, enquanto `scrollUntilVisible` se mostrou mais frágil (produziu `Bad state: Too many elements` nesta rodada). |

---

**Referência de categorias (classificação humana — mesmas da Fase 1, + (C) da Fase 2):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
| Bug capturado sem necessidade de reparo (C) | O modelo já identificou e se ajustou ao bug real na geração inicial, sem falha nem ciclo de reparo |
