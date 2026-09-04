# FASE2-INT-ZS-01_loginFlow — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-INT-ZS-01 |
| **Fluxo testado** | `LoginScreen` → `TelaInicialScreen` (`lib/login.dart`, `lib/tela-inicial.dart`) — alvo limpo, bug W-SILENT do piloto revertido |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login). Usou reasoning ("Pensou por Ns") em pelo menos uma resposta e citou fontes/documentação do `firebase_auth_mocks` (indicador "Dart packages" na interface) — não verificável de forma independente sem login. |
| **Data de acesso** | 2026-09-04 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/integration/login_flow_zs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** bug **W-SILENT** (mensagens de `user-not-found`
e `wrong-password` trocadas) estava ativo em `lib/login.dart` e foi
**revertido** antes desta rodada. Nenhum bug plantado no fluxo.
**Limitação de testabilidade conhecida e documentada no prompt antes da
execução:** `TelaInicialScreen` acessa `FirebaseAuth.instance` e
`FirebaseFirestore.instance` diretamente, sem injeção de dependência
(diferente de `LoginScreen`, que recebe `auth` injetável) — já havia
inviabilizado o teste do fluxo de sucesso nas 3 rodadas W-SILENT do piloto.

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/integration/zero-shot/FASE2-INT-ZS-01_loginFlow.md`
— pede um teste de integração cobrindo o fluxo completo (login → navegação
→ estado da tela destino) e cenários de erro, com o código completo de
`LoginScreen` e `TelaInicialScreen`.

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Gerou 8 testes: 1 de fluxo de sucesso completo (login → navegação →
conteúdo da `TelaInicialScreen`), 4 de erro do Firebase Auth
(`user-not-found`, `wrong-password`, `invalid-credential`, código
desconhecido → mensagem genérica) e 3 de validação de formulário (campos
vazios, e-mail inválido, senha curta). Identificou **proativamente e sem
que fosse necessário nenhuma falha** a limitação estrutural de
`TelaInicialScreen` não receber Firebase por injeção, e recomendou (na
prosa da resposta, fora do arquivo de teste) uma refatoração de
`lib/tela-inicial.dart` para aceitar `auth`/`firestore` opcionais — **não
aplicada**, por estar fora do escopo permitido (o protocolo do experimento
não permite alterar o código sob teste).

### Iteração 1 (repair) — 6 erros de compilação (APIs inexistentes em `firebase_auth_mocks` 0.14.2)

- **Motivo da falha:** usou `mockSignInWithEmailAndPassword` (parâmetro
  inexistente no construtor de `MockFirebaseAuth`) e `MockUserCredential`
  (classe/construtor não exportado dessa forma) — mesma classe de erro
  já vista nas rodadas de widget (o modelo presume uma API de
  `firebase_auth_mocks` mais recente/diferente da instalada).
- **Resposta do LLM:** classificou **(A)** — "o teste presume uma
  API/comportamento que não é o especificado pela versão instalada da
  biblioteca". Substituiu por `whenCalling(...).on(...).thenThrow(...)`
  (API real do pacote `mock_exceptions`, citando a documentação do pacote
  como fonte) e removeu o uso de `MockUserCredential`.
- **Resultado após correção:** Não compilou (nova classe de erro).

### Iteração 2 (repair) — 3 erros de compilação (tipo de exceção incompatível)

- **Motivo da falha:** `whenCalling(...).thenThrow(StateError(...))` —
  `thenThrow` do `mock_exceptions` exige um `Exception`, e `StateError`
  implementa `Error`, não `Exception`, em Dart.
- **Resposta do LLM:** classificou **(A)** — "o teste presume um tipo de
  exceção incompatível com a API utilizada... isso é um problema
  exclusivamente no teste, não um comportamento observado da aplicação".
  Trocou `StateError(...)` por `Exception(...)` nos 3 testes de validação
  (usados apenas como guarda para garantir que a autenticação não seria
  chamada indevidamente — a mensagem da exceção não é parte da asserção
  do teste).
- **Resultado após correção:** Compilou. **7/8 passaram, 1 falhou** — o
  teste de fluxo de sucesso completo, com `[core/no-app] No Firebase App
  '[DEFAULT]' has been created`.

### Iteração 3 (repair, última permitida) — falha do fluxo de sucesso (limitação de testabilidade pré-documentada)

- **Motivo da falha:** `TelaInicialScreen.initState()` chama
  `fetchLastRecommendedMusic()`, que acessa `FirebaseAuth.instance`
  diretamente — não há `FirebaseApp` inicializado no ambiente de teste
  (nenhuma chamada real ao Firebase, por design do teste), e o
  `MockFirebaseAuth` injetado em `LoginScreen` não é visível para
  `TelaInicialScreen`, que não recebe nada por injeção.
- **Resposta do LLM:** classificou **(B)** — "o teste capturou um
  comportamento potencialmente incorreto da aplicação". Descreveu a causa
  passo a passo (login usa DI corretamente → autenticação mockada conclui
  → navega → `TelaInicialScreen` é criada → `initState` chama
  `FirebaseAuth.instance.currentUser` → não há Firebase App `[DEFAULT]` →
  exceção) e concluiu: "isso é diferente de simplesmente faltar uma
  configuração do teste. O código da aplicação mistura injeção de
  dependência na tela de login com acesso direto aos singletons do
  Firebase na tela seguinte." Declarou explicitamente que **não
  enfraqueceria o teste** removendo a asserção da tela destino nem
  inicializando um Firebase real "apenas para esconder esse problema", e
  propôs como correção **modificar `lib/tela-inicial.dart`** para aceitar
  `auth`/`firestore` opcionais (mesmo padrão de injeção já usado em
  `CadastroScreen`/`LoginScreen`).
- **Ação do operador:** a proposta de alterar `lib/tela-inicial.dart` **não
  foi aplicada** — está fora do escopo permitido pelo protocolo do
  experimento (não se altera o código sob teste para fazer um teste
  passar; a inconsistência de design é o próprio objeto de estudo, não um
  defeito a corrigir durante a rodada). O teste de fluxo de sucesso
  permanece com a asserção original, documentado como falha residual.
- **Resultado final (limite de reparo esgotado):** 7/8 passaram, 1 falhou
  — falha mantida e documentada como achado, sem alteração do teste nem
  da aplicação, conforme protocolo para classificação (B).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Não na geração inicial nem na iteração 1 (2 classes de erro de compilação); sim a partir da iteração 2 |
| **Testes gerados** | 8 |
| **Testes passaram (1ª execução válida, iteração 2)** | 7 |
| **Testes falharam (1ª execução válida, iteração 2)** | 1 |
| **Testes passaram (pós-repair, iteração 3/3 — final)** | 7 (sem alteração — achado (B) documentado, não corrigido) |
| **Testes falharam (pós-repair, iteração 3/3 — final)** | 1 |

### Saída do terminal (iteração 0 — erro de compilação)

```
test/fase2/integration/login_flow_zs_test.dart:113:11: Error: No named parameter with the name 'mockSignInWithEmailAndPassword'.
test/fase2/integration/login_flow_zs_test.dart:257:20: Error: Method not found: 'MockUserCredential'.
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/integration/zero-shot/FASE2-INT-ZS-01_loginFlow_iter0.txt`)

### Saída do terminal (iteração 1 — erro de compilação)

```
test/fase2/integration/login_flow_zs_test.dart:316:15: Error: The argument type 'StateError' can't be assigned to the parameter type 'Exception'.
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/integration/zero-shot/FASE2-INT-ZS-01_loginFlow_iter1.txt`)

### Saída do terminal (iteração 2 — final, 7/8)

```
[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
...
00:06 +7 -1: Some tests failed.
```

(saída completa em `fase2/resultados/integration/zero-shot/FASE2-INT-ZS-01_loginFlow_iter2_final.txt`)

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** `mockSignInWithEmailAndPassword` e
  `MockUserCredential` não existem em `firebase_auth_mocks` 0.14.2.
- **Resposta do LLM:** classificação **(A)**; corrigiu usando
  `whenCalling(...).on(...).thenThrow(...)` de `mock_exceptions`.
- **Resultado após correção:** Não compilou (nova classe de erro).

### Iteração 2

- **Motivo da falha:** `StateError` passado onde `Exception` é exigido
  pela assinatura de `thenThrow`.
- **Resposta do LLM:** classificação **(A)**; trocou por `Exception`.
- **Resultado após correção:** Compilou; 7/8 passaram, 1 falhou (Firebase
  App não inicializado ao alcançar `TelaInicialScreen`).

### Iteração 3 (máximo)

- **Motivo da falha:** `TelaInicialScreen` acessa `FirebaseAuth.instance`
  diretamente, sem receber a instância mockada por injeção — limitação
  estrutural pré-documentada, não uma presunção do teste.
- **Resposta do LLM:** classificação **(B)**; recusou-se a enfraquecer a
  asserção e propôs uma correção na aplicação (fora de escopo).
- **Resultado após a rodada:** **falha mantida sem alteração**, conforme
  protocolo para (B) — 7/8 passaram, 1 falhou.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) nas iterações 1 e 2; (B) na iteração 3 |
| **★ Classificação humana (auditoria)** | Iterações 1 e 2: concordo — causas raiz corretamente diagnosticadas (APIs inexistentes na versão instalada). Iteração 3: concordo com a classificação **(B)**, mas reclassifico a categoria humana como **Limitação de testabilidade** em vez de "Bug real exposto" — não é um bug funcional (a aplicação funciona normalmente em produção, onde `Firebase.initializeApp()` já foi chamado antes de qualquer tela ser exibida), mas sim uma inconsistência de design (mistura de injeção de dependência com acesso direto a singletons) que **impede a validação automatizada do fluxo completo** sem alterar o código de produção — exatamente a mesma limitação já registrada nas 3 rodadas W-SILENT do piloto, agora confirmada de forma independente por uma quarta rodada (zero-shot, alvo limpo) sem qualquer dica do operador. |
| **★ Concordância** | Sim — a classificação (B) do modelo e a recusa em enfraquecer a asserção estão corretas; a única nuance é de categoria (Limitação de testabilidade vs. Bug real exposto), não de mérito |
| **★ Observações** | Esta é a **primeira rodada da Fase 2** em que o próprio modelo — sem qualquer dica do operador — identificou de forma autônoma e correta a limitação de testabilidade de `TelaInicialScreen`, seguiu rigorosamente o protocolo de reparo (B) (não enfraqueceu a asserção, descreveu comportamento observado vs. esperado, apontou a causa na aplicação) e ainda assim propôs, de forma útil mas fora de escopo, a correção real (injeção de dependência em `lib/tela-inicial.dart`, seguindo o mesmo padrão já usado em `CadastroScreen`/`LoginScreen`). A proposta não foi aplicada porque alterar `lib/tela-inicial.dart` está fora do protocolo do experimento, mas fica registrada aqui como validação externa e independente do achado do piloto: a limitação não é um acaso de uma rodada específica, é sistemática ao design da tela `TelaInicialScreen` e se manifesta em qualquer estratégia de prompt que gere um teste de integração ponta a ponta genuíno para este fluxo. |

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
