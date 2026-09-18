# FASE2-WIDGET-COT-02_LoginScreen — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WIDGET-COT-02 |
| **Tela testada** | `LoginScreen` — `lib/login.dart` (alvo limpo, bug W-SILENT do piloto já revertido em `fase2-prep`, sem reversão adicional necessária nesta branch) |
| **Arquivo de origem** | `lib/login.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das demais rodadas da Fase 2) |
| **Data de acesso** | 2026-09-18 |
| **Conversa nova?** | Sim — `https://chatgpt.com/uc/6aad50f5-56a0-83ea-91a1-afc69ff2dbba` |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/widget/login_screen_cot_test.dart` |
| **Execução** | **Retomada da automação de navegador (Claude in Chrome)** — as rodadas 31–32 haviam sido conduzidas manualmente pelo autor após falhas de ambiente; esta rodada voltou à automação e ela funcionou. Ver nota abaixo. |
| **Iterações de reparo** | 3 (o máximo permitido) |
| **Resultado final** | **15/18** — as 3 falhas remanescentes são o achado **(B)**, mantido sem correção por protocolo |

**Nota sobre a retomada da automação:** as rodadas `FASE2-WIDGET-ZS-02` e
`FASE2-WIDGET-FS-02` foram conduzidas manualmente pelo autor porque a
automação de navegador havia esbarrado em três falhas: UI do ChatGPT em
layout mobile degradado, timeouts de captura de tela via CDP e bloqueio da
extração de texto por filtro de conteúdo. Nesta rodada a automação foi
retomada e **funcionou**, com duas diferenças de técnica que contornaram as
falhas anteriores:

1. A extração da resposta passou a ser feita pelo **botão de cópia da
   própria resposta do ChatGPT** + leitura do clipboard via PowerShell, em
   vez de leitura do DOM via JavaScript — isso elimina completamente o
   filtro de conteúdo que inviabilizou a rodada 31.
2. O scroll da página precisa ser feito com o cursor **fora** do bloco de
   código (que captura o evento de scroll); com o cursor sobre o código, a
   página não rola.

Dois timeouts de captura de tela via CDP (30 s) ocorreram durante a rodada,
ambos resolvidos com uma simples repetição da chamada — não foram
bloqueantes. A sessão sem login **não perdeu a conversa** em nenhum momento
do ciclo de reparo, ao contrário do que ocorreu na rodada 31.

**Verificação pré-rodada:** `lib/login.dart` não tem bug plantado — a única
diferença em relação a `main` é a injeção de dependência opcional de `auth`.
`TelaInicialScreen` mantém a limitação de testabilidade conhecida (acesso
direto a `FirebaseAuth.instance`/`FirebaseFirestore.instance`, sem injeção).

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/widget/cot/FASE2-WIDGET-COT-02_LoginScreen.md`
— roteiro em 4 passos (analisar o widget → identificar dependências a mockar
→ enumerar cenários → escrever os testes) seguido do código completo de
`LoginScreen` colado verbatim. Texto exato arquivado; prompts de reparo em
`FASE2-WIDGET-COT-02_transcricao/repair{1,2,3}_cot02.txt`.

---

## Resposta do LLM

Transcrições exatas em `FASE2-WIDGET-COT-02_transcricao/`.

### Mensagem inicial (geração dos testes)

Seguiu a estrutura CoT pedida, com as 4 seções numeradas explícitas. Gerou
18 testes distribuídos em 4 `group`s (renderização, validação, interação,
login com sucesso, erros do Firebase Auth).

**Observação relevante:** ao final da própria resposta inicial, o modelo
**reconheceu espontaneamente** que estava misturando duas estratégias de
mocking incompatíveis (`MockFirebaseAuth` de `firebase_auth_mocks` — que é um
fake real — com `when()/anyNamed()` do mockito, que exige um mock do mockito)
e avisou que o arquivo "precisará ser adaptado para a API específica dessa
versão". Gerou o código problemático mesmo assim.

### Iteração 1 (repair) — a suíte não compila

- **Motivo da falha:** `Method not found: 'MockUserCredential'` e 18
  ocorrências de `The argument type 'Null' can't be assigned to the parameter
  type 'String'` — `anyNamed()` retorna `null` como placeholder do mockito,
  mas `mockAuth` não é um mock do mockito, então o método real foi invocado
  com `null`. **Exatamente a mesma falha da rodada `FASE2-WIDGET-FS-02`.**
- **Resposta do LLM:** classificou **(A)** explicitamente. Diagnóstico
  correto e mais direto que o da rodada FS: em vez de tentar conciliar os
  dois mecanismos, eliminou o mockito por completo e passou a usar a API
  `whenCalling(...).on(auth).thenThrow(...)` do `mock_exceptions`.
- **Resultado após correção:** ainda não compila.

### Iteração 2 (repair) — erro de compilação (import faltando)

- **Motivo da falha:** 5× `Method not found: 'whenCalling'` — o modelo usou a
  API do `mock_exceptions` **sem importar o pacote**. Este é um erro
  recorrente já registrado em 2 das 3 rodadas de widget anteriores.
- **Resposta do LLM:** classificou **(A)**, adicionou
  `import 'package:mock_exceptions/mock_exceptions.dart';` e sugeriu declarar
  `mock_exceptions: ^0.8.2` em `dev_dependencies`. **A sugestão de alterar o
  `pubspec.yaml` não foi aplicada** — o pacote já é dependência transitiva de
  `firebase_auth_mocks` e o import funciona sem declaração, e o protocolo não
  permite adicionar dependências durante uma rodada.
- **Resultado após correção:** **a suíte passa a compilar — 14/18**. Falhas:
  1 por viewport (`tap()` em `Offset(400, 664)`, fora de `800×600`) e 3 por
  `[core/no-app]` ao montar `TelaInicialScreen`.

### Iteração 3 (repair, última permitida) — classificação dupla (A) + (B)

- **Resposta do LLM:** **classificou as duas causas separadamente**, o
  comportamento mais correto observado até aqui nas rodadas de widget:
  - **CadastroScreen → (A):** leu o `Offset(400.0, 664.0)` do próprio log,
    concluiu que o botão está abaixo da viewport por causa do
    `SingleChildScrollView` e propôs `ensureVisible()` antes do `tap()`.
    Entregou o patch como **substituição de um único teste** ("Substitua
    somente este teste"), não como reescrita do arquivo.
  - **Login bem-sucedido → (B):** identificou que `TelaInicialScreen` acessa
    `FirebaseAuth.instance` diretamente em `initState`, e declarou
    explicitamente: *"Não vou enfraquecer a asserção de sucesso nem remover a
    verificação da navegação para fazer o teste passar."* Encerrou pedindo o
    conteúdo de `tela-inicial.dart` para aprofundar o diagnóstico —
    **informação não fornecida**, por estar fora do escopo do prompt da
    rodada (forneceria uma dica que as demais estratégias não receberam).
- **Correção aplicada:** apenas o patch cirúrgico do caso (A). Os 3 testes do
  caso (B) foram mantidos **exatamente como estavam**, conforme o protocolo.

---

## Resultado Final

**15/18** (`00:04 +15 -3`).

| Grupo | Resultado |
|---|---|
| renderização (2) | 2/2 |
| validação (5) | 5/5 |
| interação (3) | 3/3 |
| login com sucesso (3) | **0/3 — achado (B)** |
| erros do Firebase Auth (5) | 5/5 |

As 3 falhas são idênticas entre si: `[core/no-app] No Firebase App '[DEFAULT]'
has been created`, com a pilha apontando para
`_TelaInicialScreenState.fetchLastRecommendedMusic (lib/tela-inicial.dart:43)`
chamado a partir de `initState`.

---

## Achados

### (B) — limitação de testabilidade de `TelaInicialScreen` (6ª confirmação independente)

`TelaInicialScreen` acessa `FirebaseAuth.instance` e
`FirebaseFirestore.instance` diretamente em `initState`, sem injeção de
dependência. Qualquer teste que exercite o caminho de sucesso de
`LoginScreen` até o fim monta `TelaInicialScreen` e falha com `[core/no-app]`.

Esta é a **sexta confirmação independente** do mesmo achado, agora cobrindo as
três estratégias em dois níveis da pirâmide:

| Rodada | Nível | Estratégia | Confirmou |
|---|---|---|---|
| FASE2-INT-ZS-01 | Integração | Zero-shot | sim |
| FASE2-INT-FS-01 | Integração | Few-shot | sim |
| FASE2-INT-COT-01 | Integração | CoT | sim |
| FASE2-WIDGET-ZS-02 | Widget | Zero-shot | sim |
| FASE2-WIDGET-FS-02 | Widget | Few-shot | sim |
| **FASE2-WIDGET-COT-02** | **Widget** | **CoT** | **sim** |

Nenhuma alteração foi feita em `lib/tela-inicial.dart` ou `lib/login.dart` —
refatorar a aplicação sob teste está fora do escopo do protocolo.

### Notas qualitativas para a análise comparativa

- **Única rodada de widget da Fase 2 em que o modelo emitiu classificação
  dupla numa mesma iteração** — (A) para uma falha e (B) para outra, no mesmo
  ciclo de reparo. Nas rodadas anteriores a classificação foi sempre única
  para o conjunto de falhas.
- **Única rodada de widget em que a última iteração de reparo entregou um
  patch cirúrgico em vez de uma reescrita completa do arquivo.** A lição
  registrada após `FASE2-WIDGET-COT-01` (onde uma reescrita completa na
  iteração 3 trocou "compila com 22 falhas" por "não compila") se confirma
  pelo contraste: aqui não houve regressão nenhuma entre iterações, e o
  resultado subiu monotonicamente 0 → 0 → 14 → 15.
- **Nenhum achado de risco nesta rodada** — ao contrário das 3 rodadas de
  widget anteriores, em que uma correção do modelo por rodada causou
  travamento do `flutter test` (FS-01), não-compilação (COT-01) ou regressão.
- O modelo **antecipou o próprio erro** na resposta inicial (avisou que a
  mistura `firebase_auth_mocks` + mockito poderia não funcionar) mas gerou o
  código problemático mesmo assim — padrão de "aviso sem ação" que vale
  registrar na análise.
- Comparação das três estratégias no mesmo alvo (`LoginScreen`), lida dos
  arquivos de resultado finais:

  | Estratégia | Rodada | Resultado final | Iterações de reparo |
  |---|---|---|---|
  | Zero-shot | FASE2-WIDGET-ZS-02 | 11/12 | 2 |
  | Few-shot | FASE2-WIDGET-FS-02 | 6/11 | 3 |
  | **Chain-of-Thought** | **FASE2-WIDGET-COT-02** | **15/18** | **3** |

  A CoT produziu a suíte mais ampla (18 testes contra 12 e 11) e a maior taxa
  de aprovação em termos absolutos. Em proporção, ZS lidera (91,7%), seguida
  de CoT (83,3%) e FS (54,5%) — mas as 3 falhas da CoT são **todas** o achado
  (B) mantido deliberadamente, o que significa que ela não tem nenhuma falha
  atribuível a erro de geração no estado final, diferente de FS.
