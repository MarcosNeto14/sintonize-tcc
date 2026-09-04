# FASE2-INT-COT-01_loginFlow — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-INT-COT-01 |
| **Fluxo testado** | `LoginScreen` → `TelaInicialScreen` (`lib/login.dart`, `lib/tela-inicial.dart`) — alvo limpo, bug W-SILENT do piloto revertido |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login). Usou reasoning ("Pensou por 10s") e citou fontes/documentação do `firebase_auth_mocks`/`fake_cloud_firestore`/`firebase_core_platform_interface` em várias respostas — não verificável de forma independente sem login. |
| **Data de acesso** | 2026-09-04 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable), Dart 3.11.5 |
| **Arquivo de teste** | `test/fase2/integration/login_flow_cot_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** mesma verificação das rodadas ZS/FS — bug W-SILENT
revertido, `TelaInicialScreen` com a mesma limitação de testabilidade
conhecida (acesso direto a `FirebaseAuth.instance`/`FirebaseFirestore.instance`).
Esta é a **última rodada das 30 do escopo limpo da Fase 2** (30/30).

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/integration/cot/FASE2-INT-COT-01_loginFlow.md`
— os 5 passos do CoT (analisar o fluxo, identificar dependências, montar
estrutura de navegação, identificar cenários de teste, escrever os testes),
seguido do código completo de `LoginScreen` e `TelaInicialScreen` colado
verbatim e da instrução de reparo revisada (A/B + autoclassificação).

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Seguiu os 5 passos do CoT explicitamente antes do código:

1. **Análise do fluxo:** descreveu corretamente o caminho feliz e os dois
   ramos de erro (validação de formulário / `FirebaseAuthException`).
2. **Dependências:** montou uma tabela Tela × Serviço × Uso × Estratégia de
   teste, identificando corretamente que `FirebaseAuth.instance` e
   `FirebaseFirestore.instance` em `TelaInicialScreen` **não são injetáveis**
   e que `FakeFirebaseFirestore` não pode ser conectado sem alterar a
   produção — a mesma limitação sistemática já documentada nas rodadas
   piloto (W-SILENT) e nas rodadas ZS/FS desta trinca, detectada aqui
   **espontaneamente, antes de qualquer execução**.
3. **Estrutura de navegação:** optou corretamente por `MaterialApp(home:
   LoginScreen(auth: auth))` em vez de declarar `routes`, já que a navegação
   usa `Navigator.pushReplacement` com `MaterialPageRoute` direto.
4. **Cenários de teste:** listou 10 cenários (sucesso ponta a ponta, 4
   validações de campo, 4 erros de Firebase Auth por código, 1 mantém
   `LoginScreen` em erro) e **justificou explicitamente a ausência** de um
   cenário de loading ("não existe estado visual de loading implementado na
   `LoginScreen` fornecida") e de um cenário de Firestore indisponível
   ("o Firestore usado pela tela é o singleton real, portanto
   `FakeFirebaseFirestore` não consegue simular essa condição sem uma
   alteração arquitetural na produção") — em vez de inventar cenários que a
   aplicação não suporta.
5. **Testes:** gerou 10 `testWidgets()` completos.

Também acrescentou, fora do código, uma observação proativa: recomendou
**não** forçar `fake_cloud_firestore` nos testes do fluxo de login porque
não há ponto de injeção em `TelaInicialScreen`, e sugeriu como alternativa
real (fora de escopo) uma refatoração para DI — mesma conclusão a que a
rodada FS só chegou depois de 2 iterações de reparo e uma regressão.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Não na geração inicial (5 erros de `whenCalling` — método não encontrado); sim a partir da iteração 1 |
| **Testes gerados** | 10 |
| **Testes passaram (1ª execução válida, iteração 2)** | 9 |
| **Testes falharam (1ª execução válida, iteração 2)** | 1 |
| **Testes passaram (pós-repair, iteração 3/3 — final)** | **10** |
| **Testes falharam (pós-repair, iteração 3/3 — final)** | **0** |

**Única rodada das 3 estratégias do fluxo de login a fechar 100%** (ZS: 7/8;
FS: 5/6; COT: **10/10**).

### Saída do terminal (iteração 0 — erro de compilação)

```
test/fase2/integration/login_flow_cot_test.dart:225:9: Error: Method not found: 'whenCalling'.
...
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/integration/cot/FASE2-INT-COT-01_loginFlow_iter0.txt`)

### Saída do terminal (iteração 1 — novo erro, `setUpAll`)

```
00:00 +0: (setUpAll)
00:00 +0 -1: (setUpAll) [E]
  PlatformException(channel-error, Unable to establish connection on channel., null, null)
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/integration/cot/FASE2-INT-COT-01_loginFlow_iter1.txt`)

### Saída do terminal (iteração 2 — 9/10)

```
00:00 +0 -1: LoginScreen - fluxo de autenticação faz login com sucesso e navega para TelaInicialScreen [E]
  Test failed. See exception logs above.
...
00:01 +9 -1: Some tests failed.
```

(saída completa em `fase2/resultados/integration/cot/FASE2-INT-COT-01_loginFlow_iter2.txt`)

### Saída do terminal (iteração 3 — final, 10/10)

```
00:01 +10: (tearDownAll)
00:01 +10: All tests passed!
```

(saída completa em `fase2/resultados/integration/cot/FASE2-INT-COT-01_loginFlow_iter3_final.txt`)

---

## Iterative Repair Loop

### Iteração 1 — 5 erros de compilação (`whenCalling` não encontrado)

- **Motivo da falha:** o teste gerado usa `whenCalling(...).on(auth).thenThrow(...)`
  em 5 blocos, mas a API pertence ao pacote `mock_exceptions` e o teste
  gerado **não a importou**.
- **Resposta do LLM:** classificou **(A)** — "o problema está no teste que
  escrevi, não em um comportamento incorreto da aplicação". Identificou
  exatamente a linha faltante (`import 'package:mock_exceptions/mock_exceptions.dart';`)
  e observou corretamente que `mockito`, sugerido por ele mesmo na análise
  inicial de dependências, **não é necessário** para essa parte.
- **Ação do operador:** adicionado o import ao arquivo de teste (`mock_exceptions`
  já é dependência transitiva resolvível via `pubspec.lock`, sem alteração
  de `pubspec.yaml`).
- **Resultado após correção:** Compilou. **9/10 passaram, 1 falhou** — nova
  falha em `setUpAll`, antes de qualquer teste rodar (ver iteração 2).

### Iteração 2 — `PlatformException(channel-error)` em `setUpAll`

- **Motivo da falha:** `Firebase.initializeApp()` com `FirebaseOptions` falsas,
  sem mockar o Firebase Core, tenta se comunicar com um platform channel
  nativo inexistente no ambiente `flutter_test` — mesma causa raiz já
  confirmada nas 3 rodadas W-SILENT do piloto e na rodada FS desta trinca
  (lá, a tentativa idêntica gerou uma **regressão** de 5/6 para 0/6).
- **Resposta do LLM:** classificou **(A)** — "o teste presume uma
  infraestrutura de Firebase que não existe no ambiente de `flutter test`".
  Identificou que `firebase_core_platform_interface` expõe
  `setupFirebaseCoreMocks()` especificamente para isso, e propôs adicionar
  essa chamada **antes** de `Firebase.initializeApp()` no `setUpAll` — **sem
  alterar `login.dart` nem `tela-inicial.dart`**. Também **previu
  proativamente**, antes de qualquer nova execução, que o teste de sucesso
  poderia falhar por uma segunda causa (`FirebaseAuth.instance`/
  `FirebaseFirestore.instance` como singletons não injetáveis em
  `TelaInicialScreen`), declarando explicitamente que essa seria uma
  "limitação real da arquitetura atual" e que não deveria ser "consertada"
  enfraquecendo a asserção de navegação.
- **Ação do operador:** adicionado `import 'package:firebase_core_platform_interface/test.dart';`
  e a chamada `setupFirebaseCoreMocks()` no início de
  `initializeFirebaseForTest()`, antes de `Firebase.initializeApp(...)`.
- **Resultado após correção:** **9/10 passaram, 1 falhou** — exatamente a
  previsão do modelo: o teste de sucesso ponta a ponta falhou com
  `Expected: exactly one matching candidate / Actual: Found 0 widgets with
  type "TelaInicialScreen"`.

### Iteração 3 (máximo) — teste de sucesso ainda falha após mockar o Firebase Core

- **Motivo da falha:** reportado ao modelo com a nota explícita do operador
  de que esta é a última iteração permitida pelo protocolo.
- **Resposta do LLM:** classificou **(A)** novamente — mas com um diagnóstico
  **diferente** do previsto por ele mesmo na iteração 2: não atribuiu a
  falha ao singleton não injetável, e sim a um problema de *timing* do
  teste — um único `await tester.pump()` após o `tap()` não é suficiente
  para que toda a cadeia assíncrona (`signInWithEmailAndPassword` →
  `Navigator.pushReplacement` → construção de `TelaInicialScreen` → Futures
  do `initState`) termine antes da asserção. Propôs trocar `pump()` por
  `pumpAndSettle()` **apenas nesse teste**, sem alterar nenhuma asserção,
  argumentando explicitamente por que isso não enfraquece o teste ("não
  estamos aumentando o timeout, removendo a verificação da navegação ou
  aceitando um estado intermediário"). Declarou também, sem que fosse
  pedido, que não faria nova alteração sem antes ver o resultado desta.
- **Ação do operador:** substituído `await tester.pump();` por
  `await tester.pumpAndSettle();` no teste de sucesso, mantendo as mesmas
  duas asserções (`TelaInicialScreen` presente, `LoginScreen` ausente).
- **Resultado final (limite de reparo esgotado):** **10/10 passaram — suíte
  100% verde.**

**Por que `pumpAndSettle()` resolveu sem exigir DI:** `TelaInicialScreen`
depende de `FirebaseAuth.instance.currentUser`, mas como o `MockFirebaseAuth`
passado para `LoginScreen` nunca populou o singleton real, `currentUser` é
`null` dentro de `TelaInicialScreen`. Todos os métodos assíncronos da tela
(`fetchUserName`, `fetchLastRecommendedMusic`, `fetchNewMusic`) **tratam
esse caso explicitamente** (`if (user == null) return {...}`/`return
'Usuário'`) em vez de lançar exceção — nenhum deles toca
`FirebaseFirestore.instance` quando `user == null`. Por isso a tela
constrói e renderiza normalmente mesmo sem os dados reais, e como o teste
só verifica a árvore de widgets (navegação), não o conteúdo carregado, a
asserção passa. **Isso não invalida a limitação de DI identificada nas
rodadas anteriores** (ela é real e seria um problema para um teste que
quisesse verificar o nome/música exibidos) — apenas mostra que, para o
recorte específico "navegação ocorreu", o *fallback* defensivo já existente
em `tela-inicial.dart` é suficiente para não expor a limitação.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) nas 3 iterações |
| **★ Classificação humana (auditoria)** | Iteração 1: concordo — erro de geração simples (import ausente), diagnóstico e correção corretos de primeira. Iteração 2: concordo — causa raiz corretamente diagnosticada (ambiente de teste sem platform channel nativo) e corrigida com a API certa (`setupFirebaseCoreMocks()`), sem tentar inicializar Firebase real como a rodada FS fez (evitando a regressão que ocorreu lá). Iteração 3: concordo com a classificação (A) e com a correção — o diagnóstico de timing (`pump()` único vs. `pumpAndSettle()`) estava correto e specific, e resultou em 10/10 sem enfraquecer nenhuma asserção. Reclassifico como **Erro de teste** (não limitação de testabilidade) as 3 iterações, já que todas as 3 causas eram efetivamente falhas no teste (import faltante, mock de infraestrutura ausente, sincronização assíncrona insuficiente) e não bugs da aplicação nem limitações reais de arquitetura que impedissem o teste. |
| **★ Concordância** | Total — concordo com a classificação (A) e com a eficácia de todas as 3 correções propostas nas 3 iterações |
| **★ Observações** | **Única rodada das 3 estratégias do fluxo de login (ZS 7/8, FS 5/6, COT 10/10) a fechar 100% dos testes.** Diferença qualitativa: nas rodadas ZS/FS, o modelo eventualmente concluiu (explícita ou implicitamente) que a falha do teste de sucesso era uma limitação de testabilidade real e documentou-a sem correção (ZS: (B) direto; FS: (A) nominal mas admitindo não haver correção possível sem alterar `login.dart`). Nesta rodada COT, o modelo perseverou em 2 hipóteses de causa (iteração 2: singleton não injetável — não confirmada; iteração 3: timing assíncrono — confirmada) e a segunda hipótese, mais simples, era suficiente porque o comportamento defensivo já existente em `tela-inicial.dart` (fallback para `user == null`) absorveu a limitação de DI sem que o teste precisasse contorná-la. Isso mostra que **o resultado da rodada de integração do fluxo de login não depende só da limitação estrutural de DI, mas também de como o teste sincroniza com o pipeline assíncrono** — um fator ortogonal à estratégia de prompting que nenhuma das 3 rodadas (ZS/FS/COT) havia isolado explicitamente até aqui. A previsão da iteração 2 (que a causa seria o singleton) não se confirmou, mas o modelo não insistiu nela quando o novo erro (`Found 0 widgets`) não correspondia à mensagem de erro esperada para esse caso — sinal de raciocínio adaptativo, não de aplicação mecânica da hipótese anterior. Fecha as 30 rodadas limpas da Fase 2 (30/30). |

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
