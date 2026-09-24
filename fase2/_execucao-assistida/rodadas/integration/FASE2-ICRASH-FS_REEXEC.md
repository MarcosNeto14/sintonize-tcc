# FASE2-ICRASH-FS_REEXEC — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-ICRASH-FS_REEXEC |
| **Rodada original** | `FASE2-ICRASH-FS` (piloto, `fase2/rodadas/integration/FASE2-ICRASH-FS.md`) — reexecutada porque o `CadastroScreen` do prompt do piloto tinha apenas 4 campos (a tela real tem 10), causa confirmada da falha final (`Expected: exactly 4 / Actual: Found 10 widgets with type "TextFormField"`). O exemplo few-shot do piloto também continha `AuthExceptions` (API inexistente), embora não tenha sido exercitado pelo modelo naquela rodada |
| **Bug ID** | I-CRASH |
| **Função/tela alvo** | Fluxo de cadastro — `GenerosCadastroScreen._salvarGeneros()` |
| **Arquivo(s) de origem** | `lib/cadastro.dart` + `lib/generos-cadastro.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Few-shot (corrigido) |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login) |
| **Data de acesso** | 2026-09-03 |
| **Conversa nova?** | Sim — sessão deslogada, sem histórico prévio |
| **Framework de teste** | flutter_test |
| **Arquivo de teste** | `test/fase2/integration/icrash_fs_reexec_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome), mesmo padrão das 18 rodadas do piloto |

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/FASE2--REEXEC.md`, seção "FASE2-ICRASH-FS — REEXEC": código real e completo de `lib/cadastro.dart` (10 campos + Estado) e `lib/generos-cadastro.dart` (`Switch`), colado verbatim; exemplo few-shot corrigido (login flow usando `whenCalling(...).thenThrow(...)`, sem `AuthExceptions`).

---

## Resposta do LLM

### Mensagem inicial

3 testWidgets: fluxo completo (cadastro → gêneros → Firestore → tela inicial), falha ao salvar gêneros, e não permite confirmar sem gênero. Usou corretamente os 10 campos reais e `Switch`. Não usou `AuthExceptions` em nenhum ponto — o exemplo few-shot corrigido não induziu essa API.

**★ Confirmação do achado da investigação:** nenhuma das 3 iterações apresentou `Expected: exactly 4 / Actual: Found 10 widgets` — a divergência de campos do piloto não se repetiu. `AuthExceptions` também não apareceu em nenhum momento.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou? (1ª tentativa)** | Sim |
| **Testes gerados** | 3 |
| **Iteração 0 (sem reparo)** | **0/3** — dropdown/botão fora do viewport 800×600 (mesmo padrão de `FASE2-ICRASH-ZS_REEXEC`) + SnackBar de erro não encontrado |
| **Iteração 1** | **2/3** — viewport corrigido com `setSurfaceSize(800,1400)` + `find.byWidgetPredicate`; teste de erro do Firestore reformulado (documento inexistente, sem mock manual de `update()`) |
| **Iteração 2 (final)** | **2/3** — última falha classificada (B): limitação de testabilidade sistemática de `TelaInicialScreen`, mantida sem alteração |

### Saída do terminal (iteração 0)

```
fluxo completo: cadastro cria usuário, salva dados e permite salvar gêneros [E]
  Bad state: No element (tap no DropdownButtonFormField fora do viewport 800x600)
falha ao salvar gêneros exibe mensagem de erro [E]
  Expected: exactly one matching candidate
  Actual: Found 0 widgets with text "Erro ao salvar os gêneros!"
não permite confirmar sem selecionar nenhum gênero [E]
  Warning: tap() em "Confirmar" fora do viewport (Offset 400,618 vs Size 800x600)
  Actual: Found 0 widgets with text "Selecione pelo menos um gênero musical!"
00:03 +0 -3: Some tests failed.
```

(saída completa em `fase2/resultados/integration/FASE2-ICRASH-FS_REEXEC_iter0.txt`)

### Saída do terminal (iteração 1 — 2/3)

Aplicando `setSurfaceSize(800,1400)` + `addTearDown` em todos os testes,
`find.byWidgetPredicate` para o dropdown, e reformulando o teste de erro
do Firestore para usar um documento inexistente (em vez de tentar mockar
`DocumentReference.update()` diretamente), 2 dos 3 testes passaram. O
teste do fluxo completo falhou com `[core/no-app]` ao navegar para
`TelaInicialScreen`.
(saída completa em `fase2/resultados/integration/FASE2-ICRASH-FS_REEXEC_iter1.txt`)

### Saída do terminal (iteração 2 — final, 2/3, sem alteração de código)

Idêntica à iteração 1 — o modelo classificou a falha remanescente como
(B) e explicitamente recusou-se a alterar o teste (nem trocar
`pumpAndSettle()` por `pump()`, nem remover a asserção final, nem
inicializar Firebase falso).
(saída completa em `fase2/resultados/integration/FASE2-ICRASH-FS_REEXEC_iter2_final.txt`, cópia da iteração 1 porque nenhum código foi alterado)

---

## ⚠️ Achado metodológico importante

### 1. Os dois defeitos confirmados foram eliminados

Nenhuma das 3 iterações usou `AuthExceptions` (exemplo few-shot corrigido)
nem apresentou a divergência de 4 vs. 10 campos do `CadastroScreen`
(código completo fornecido). Ambos os defeitos identificados na
investigação foram corrigidos com sucesso.

### 2. Mesmo padrão de viewport já visto em `FASE2-ICRASH-ZS_REEXEC`

A causa dominante da iteração 0 (dropdown e botão fora do viewport
800×600) é idêntica à observada na reexecução da rodada irmã Zero-shot,
confirmando que essa é uma limitação sistemática do viewport padrão de
teste do Flutter diante deste formulário longo, não um problema
específico da estratégia Few-shot. A correção (`setSurfaceSize` +
`find.byWidgetPredicate`) foi fornecida preventivamente no prompt de
reparo (com base no aprendizado da rodada ZS) e funcionou de primeira.

### 3. `TelaInicialScreen` — limitação de testabilidade, mais uma vez

A única falha remanescente é, novamente, `[core/no-app]` ao navegar para
`TelaInicialScreen` — a mesma limitação sistemática documentada em
`FASE2-WSILENT-ZS`, `FASE2-WSILENT-FS` (piloto e reexecução) e
`FASE2-ICRASH-COT` (piloto). O modelo propôs corretamente a correção de
produção apropriada (propagar `auth`/`firestore` por injeção até
`TelaInicialScreen`), mas — corretamente, por protocolo — não a aplicou
nem contornou o teste.

### 4. Comparação com o piloto

| | Piloto (`FASE2-ICRASH-FS`) | Reexecução |
|---|---|---|
| Causa dominante das falhas | `CadastroScreen` com 4 campos (divergência de prompt) | Resolvida — 0 ocorrências |
| Resultado final | 0/2 | 2/3 (67%) |
| Detecção espontânea do bug I-CRASH | Não | Não (mas o teste de sucesso chega a acionar `_salvarGeneros()` com sucesso; o bug em si não foi exercitado por um cenário de usuário não autenticado nesta rodada, diferente da ZS) |

A correção do material de entrada teve impacto direto e positivo: de 0/2
sem nenhum teste sequer alcançando os cenários de erro, para 2/3 com a
única falha remanescente sendo uma limitação de testabilidade já
documentada e não atribuível ao prompt.

---

## Iterative Repair Loop

### Iteração 1
- **Motivo da falha:** viewport 800×600 insuficiente (dropdown e botão "Confirmar"); mock manual de `update()` não funcionando como esperado.
- **Prompt de reparo:** erros colados + conhecimento acumulado da rodada `FASE2-ICRASH-ZS_REEXEC` (técnica `setSurfaceSize`/`find.byWidgetPredicate`) fornecido preventivamente.
- **Resposta do LLM:** classificou (A) para as 3 falhas; aplicou `setSurfaceSize(800,1400)` em todos os testes; reformulou o teste de erro do Firestore para usar um documento inexistente em vez de mockar `update()` diretamente (abordagem mais robusta, testando o `catch` real da aplicação).
- **Resultado:** 2/3 passaram; 1 falhou com `[core/no-app]` (limitação de `TelaInicialScreen`).

### Iteração 2 (final — encerrada antes do limite de 3, sem novas alterações a propor)
- **Motivo da falha:** limitação de testabilidade sistemática de `TelaInicialScreen`.
- **Prompt de reparo:** erro colado + nota de protocolo com a causa raiz já documentada em rodadas anteriores + confirmação de que `Firebase.initializeApp()` falso já foi tentado sem sucesso.
- **Resposta do LLM:** classificou **(B)**; descreveu o comportamento observado e esperado; propôs a correção de produção apropriada (propagar `auth`/`firestore` até `TelaInicialScreen`) mas não a aplicou; recusou-se explicitamente a trocar `pumpAndSettle()` por `pump()` ou remover a asserção final.
- **Resultado final:** 2/3 (67%). Como o modelo não alterou nenhum código nesta iteração (apenas confirmou a classificação (B) da rodada anterior), o loop foi considerado encerrado sem necessidade de uma 3ª iteração — não haveria nova informação a obter repetindo a mesma pergunta.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) na iteração 1 (viewport e mock, ambas corretas); (B) na iteração 2 (limitação de testabilidade, correta) |
| **★ Classificação humana (auditoria)** | Iteração 1: **Erro de teste** (viewport, mock manual inadequado) — corrigido corretamente. Iteração 2: **Limitação de testabilidade**, consistente com o achado sistemático já registrado em múltiplas rodadas anteriores |
| **★ Concordância** | Concorda integralmente |
| **★ Observações** | Ambos os defeitos confirmados pela investigação (`AuthExceptions` e `CadastroScreen` truncado) foram eliminados com sucesso — nenhuma das 3 iterações os reproduziu. O resultado final (2/3, 67%) é consideravelmente melhor que o piloto (0/2), e a única falha remanescente é uma limitação de testabilidade já conhecida e independente da qualidade do prompt. O compartilhamento de conhecimento entre rodadas irmãs do mesmo bloco (a técnica de viewport aprendida em `FASE2-ICRASH-ZS_REEXEC` aplicada preventivamente aqui) permitiu resolver a causa dominante em uma única iteração. |

**Referência de categorias (classificação humana — mesmas da Fase 1):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
