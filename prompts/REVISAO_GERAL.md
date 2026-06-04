# Revisão Geral do Repositório Sintonize

**Data da revisão inicial:** 2026-06-03  
**Data da atualização:** 2026-06-03 (auditoria encerrada — repositório limpo)  
**Revisor:** Claude Code (auditoria automatizada)  
**Escopo:** `prompts/`, `test/`, `results/`, `e2e-manual/`, `analise/`

> **Legenda de status:**
> - [OK] — conforme, nenhuma ação necessária
> - [CORRIGIDO] — problema identificado e corrigido nesta sessão
> - [ATENÇÃO] — anomalia de baixo impacto, pendente ou documentada
> - [PROBLEMA] — erro de dado ou estrutura que exige correção

---

## 1. Consistência Estrutural dos Docs de Rodada

### 1.1 Template canônico

O arquivo `prompts/Template_Documentacao_Rodada.md` define as seções esperadas:
- `## Metadados` (tabela com 11 campos)
- `## Prompt Enviado`
- `## Resposta do LLM`
- `## Resultado da Execução` (tabela — atualizada para 6 linhas)
- `### Saída do terminal`
- `## Iterative Repair Loop` com `### Iteração 1/2/3`

[CORRIGIDO] A tabela de `## Resultado da Execução` no template foi atualizada de 4 para 6 linhas, alinhando-se à prática adotada em todos os 48 docs reais.

### 1.2 Seções nas 30 rodadas unitárias

[OK] Todos os 30 docs de nível unitário possuem todas as 6 seções obrigatórias e usam a tabela de 6 linhas.

### 1.3 Seções nas 9 rodadas de widget

[OK] Todos os 9 docs de widget possuem todas as seções obrigatórias.

[CORRIGIDO] `WIDGET-COT-01_login.md` e `WIDGET-COT-02_criarPlaylist.md` usavam `### Saída do terminal (iteração 3 — resultado final)` — renomeado para o padrão `### Saída do terminal` em ambos.

[ATENÇÃO] `WIDGET-COT-03_cadastro.md` possui 3 campos extras na tabela de Resultado (`Setup correto de mocks?`, `MaterialApp wrapper?`, `Tratou assets?`). Não fazem parte do template canônico, mas foram mantidos como dados históricos relevantes.

### 1.4 Seções nas 9 rodadas de integração

[OK] Todos os 9 docs de integração possuem todas as seções obrigatórias.

[CORRIGIDO] `INT-ZS-01_login.md` tinha 3 ocorrências do placeholder `_Resposta completa do ChatGPT — colar aqui._` nas seções `## Resposta do LLM`, `### Iteração 1` e `### Iteração 2`. Substituídas por nota indicando que o texto não foi capturado durante a rodada.

---

## 2. Consistência dos Metadados

### 2.1 Versão do Flutter

[ATENÇÃO] Há duas versões distintas registradas:
- **Unitário (30 docs) e Widget (9 docs):** `3.41.7`
- **Integration (9 docs):** `Flutter 3.41.6 • Dart 3.11.4`

Isso reflete execuções em momentos diferentes do experimento — não é um erro de dado, mas uma inconsistência real. Uma nota explicativa foi adicionada em `analise/dados_consolidados.md` (seção 6. Notas Metodológicas).

### 2.2 Versão do modelo — desvio em WIDGET-COT-03

[CORRIGIDO] `WIDGET-COT-03_cadastro.md` registrava `GPT-4o (2026-05-20)` sem nota metodológica. Uma nota foi adicionada ao doc e ao `analise/dados_consolidados.md` explicando o desvio de protocolo.

### 2.3 Campo "Versão do Flutter" com valor errado em INT-ZS-01

[CORRIGIDO] O campo continha `GPT-5.5` (valor de outro campo copiado erroneamente). Corrigido para `Flutter 3.41.6 • Dart 3.11.4`.

### 2.4 Inconsistência no nome do campo de arquivos de origem

[ATENÇÃO] O campo correspondente a "arquivos do código testado" aparece com nomes diferentes:
- Docs unitários/widget: `Arquivo de origem`
- Docs integração (alguns): `Arquivos de origem` ou `Arquivos envolvidos`

Nenhum coincide exatamente com o template. Uma nota foi adicionada ao `Template_Documentacao_Rodada.md` orientando o uso de `Arquivo(s) de origem` e indicando o plural para rodadas multi-arquivo. Os 48 docs existentes não foram modificados (alteração retroativa de baixo valor).

### 2.5 Campo "Complexidade" em docs de widget

[OK] Verificado: todos os 9 docs de widget possuem o campo `Complexidade` (ZS-01: Baixa, ZS-02: Média, ZS-03: Alta; FS-01: Baixa, FS-02: Média, FS-03: Alta; COT-01: Baixa, COT-02: Média, COT-03: Alta). O campo é consistente entre estratégias para o mesmo widget. Não faz parte do template canônico mas está uniformemente presente; mantido como dado relevante.

### 2.6 Nível da pirâmide

[OK] Todos os 48 docs registram o nível correto: `Unitário` / `Widget` / `Integração`.

### 2.7 Conversa nova?

[OK] Todos os 48 docs registram `Sim`.

---

## 3. Rastreabilidade (docs ↔ testes ↔ resultados)

### 3.1 Nível Unitário

[OK] 30 docs, 30 arquivos `.dart`, 30 `.txt` — traceabilidade 100% completa. Nenhum arquivo órfão.

### 3.2 Nível Widget

[OK] 9 docs e 9 arquivos de teste presentes.

[CORRIGIDO] `results/widget/cot/WIDGET-COT-03_iter3.txt` estava ausente. Criado com nota explicando que o output bruto do terminal não foi capturado durante a rodada.

[ATENÇÃO] Convenção de nomenclatura inconsistente em `results/widget/cot/`: ZS e FS usam um arquivo por rodada (`WIDGET-XX-NN.txt`); COT usa um arquivo por iteração (`WIDGET-COT-NN_iterK.txt`). Diferença documentada em `results/README.md` — renomeação retroativa não realizada (quebraria histórico de git sem benefício).

### 3.3 Nível Integration

[OK] 9 docs, 9 arquivos `.dart`, 9 `.txt` — traceabilidade 100% completa.

### 3.4 Tabela de rastreabilidade no README

[CORRIGIDO] `prompts/README.md` continha 4 links mortos na tabela de Integration (sufixo `_flow` inexistente). Corrigidos para os nomes reais: `INT-ZS-01_login.md`, `INT-ZS-02_cadastro.md`, `INT-ZS-03_playlist.md`, `INT-FS-01_login.md`.

[CORRIGIDO] Tabela de rastreabilidade para o nível Widget estava ausente. Adicionada em `prompts/README.md` com links para os 9 docs, 9 arquivos de teste e pasta de resultados.

---

## 4. Integridade dos Dados Numéricos

### 4.1 WIDGET-COT-03 — tabela pós-repair

[CORRIGIDO] A tabela `## Resultado da Execução` registrava `pós-repair: 3 pass / 10 fail`, mas a narrativa de Iteração 3 documenta `12/13 passando` (1 falha remanescente: FirebaseAuth estático). Corrigido para `12 pass / 1 fail` no doc e em `analise/dados_consolidados.md`.

**Impacto no consolidado (corrigido):**
- Taxa final COT widget: 8% → 33%
- Total widget pass(final): 26 → 35
- Taxa global COT: 82% → 87%
- Total global pass(final): 406 → 415

### 4.2 Contagem de iterações de integração

[CORRIGIDO] Quatro rodadas tinham iterações overcounted no consolidado (a convenção "Iteração 3 = Não necessária" foi contada como iteração realizada):

| Rodada | Era | Correto |
|---|---|---|
| INT-ZS-01 | 3 | 2 |
| INT-ZS-02 | 3 | 2 |
| INT-ZS-03 | 3 | 2 |
| INT-FS-01 | 2 | 1 |

Total integration: 14 → 10. Médias de iteração por estratégia recalculadas no consolidado.

### 4.3 INT-ZS-03 — narrativa vs tabela

[CORRIGIDO] A seção `## Resposta do LLM` de `INT-ZS-03_playlist.md` mencionava "5 testes gerados" (contagem inicial), mas a tabela registra `Testes gerados = 8` (contagem final). Nota metodológica adicionada ao doc explicando que a geração inicial foi de 5 testes e que o total de 8 reflete o estado após o repair loop (Iteração 1 regenerou com 9; Iteração 2 removeu 1 problemático). A tabela de Resultado da Execução registra corretamente a contagem final.

### 4.4 Spot-check unitário

[OK] 5 rodadas verificadas (UNIT-ZS-01, ZS-03, FS-08, COT-08, COT-03) — dados individuais consistentes com o consolidado.

### 4.5 Alteração retroativa de `formatName`

[CORRIGIDO] Notas metodológicas adicionadas em `UNIT-ZS-08_formatName.md` e `UNIT-FS-08_formatName.md` explicando que `lib/utils/validators.dart` foi modificado durante UNIT-COT-08 e que os arquivos de teste foram retroativamente atualizados. Nota complementar adicionada em `analise/dados_consolidados.md`.

---

## 5. Arquivos Órfãos, Duplicados ou Temporários

### 5.1 Arquivos .gitkeep em pastas com conteúdo real

[CORRIGIDO] 16 `.gitkeep` removidos via `git rm` de: `prompts/unit/{zero-shot,few-shot,cot}/`, `prompts/integration/{zero-shot,few-shot,cot}/`, `results/unit/{zero-shot,few-shot,cot}/`, `results/widget/{zero-shot,few-shot,cot}/`, `results/integration/{zero-shot,few-shot,cot}/`, `test/integration/`. Mantidos os `.gitkeep` de 4 diretórios realmente vazios: `prompts/e2e/`, `prompts/integration/context-enrichment/`, `prompts/integration/multi-step/`, `results/e2e/`.

### 5.2 Diretórios vazios (estratégias não executadas)

[ATENÇÃO] As pastas `prompts/integration/multi-step/` e `prompts/integration/context-enrichment/` existem apenas com `.gitkeep`. A estrutura de pastas do `prompts/README.md` foi atualizada para indicar explicitamente "reservado (estratégia não executada)".

### 5.3 Arquivo de resultado ausente

[CORRIGIDO] `results/widget/cot/WIDGET-COT-03_iter3.txt` criado. Contém nota sobre ausência do output bruto e resumo documentado da Iteração 3.

### 5.4 Placeholders não preenchidos

[CORRIGIDO] INT-ZS-01: 3 placeholders substituídos por nota de não-captura.

### 5.5 Arquivos temporários ou duplicados

[OK] Nenhum arquivo com padrão `AUDITORIA*`, `TEMP*`, `RASCUNHO*` ou `.md` duplicado encontrado.

---

## 6. Documentação de Apoio

### 6.1 prompts/README.md

[CORRIGIDO] 4 links mortos na tabela de Integration — corrigidos.
[CORRIGIDO] Referência a `PROMPT_TEMPLATE_INT.md` (inexistente) → `PROMPT_TEMPLATE_INTEGRATION.md`.
[CORRIGIDO] Tabela de rastreabilidade Widget adicionada.
[CORRIGIDO] Árvore de pastas atualizada para refletir estado real (integration concluído, pastas de test/integration e results/integration incluídas).

### 6.2 CLAUDE.md

[CORRIGIDO] Seção "Tracking progress" reescrita. Antes descrevia o experimento como incompleto ("COT in progress", "Integration and E2E still TBD"). Agora reflete o estado real: todas as 48 rodadas concluídas, E2E manual executado.

### 6.3 PROMPT_TEMPLATE_UNIT.md

[OK] Coerente com as 30 rodadas executadas.

### 6.4 PROMPT_TEMPLATE_WIDGET.md

[CORRIGIDO] Cabeçalho `**Nível:** Integração (Widget Tests)` corrigido para `**Nível:** Widget Tests`.

### 6.5 PROMPT_TEMPLATE_INTEGRATION.md

[OK] Coerente com as 9 rodadas executadas.

### 6.6 Template_Documentacao_Rodada.md

[CORRIGIDO] Tabela de `## Resultado da Execução` atualizada de 4 para 6 linhas (adicionados `passaram/falharam 1ª execução` e `passaram/falharam pós-repair`).
[CORRIGIDO] Campo `Arquivo de origem` renomeado para `Arquivo(s) de origem` com orientação sobre uso do plural.

### 6.7 results/README.md

[CORRIGIDO] Arquivo expandido para cobrir os 3 níveis (unit, widget, integration). Incluídas convenções de nomenclatura e nota sobre o desvio de convenção nos arquivos COT de widget. Referências às notas metodológicas de WIDGET-COT-03 e formatName.

### 6.8 analise/dados_consolidados.md

[CORRIGIDO] Dados numéricos de WIDGET-COT-03 e contagens de iterações de integration corrigidos. Notas metodológicas adicionadas sobre desvio de modelo (WIDGET-COT-03), alteração retroativa de formatName e inconsistência de versão Flutter.

### 6.9 analise/README.md

[CORRIGIDO] Arquivo criado. Contém: descrição das 6 seções do `dados_consolidados.md`, definição de cada coluna/métrica (Gerados, Pass(1ª), Pass(final), Taxa final, Iterações, Compilou(1ª)), composição dos agregados por nível e estratégia, instruções de rastreabilidade doc→teste→resultado, e convenções de contagem (int "gerados final", widget iterações, unitário).

---

## 7. Sugestões de Melhoria Organizacional

[CORRIGIDO] Todos os itens desta seção foram executados:

- **`analise/README.md` criado** — explica as 6 seções do consolidado, define cada coluna/métrica, lista composição dos agregados e instruções de rastreabilidade.

- **16 `.gitkeep` removidos** via `git rm` de todas as pastas com conteúdo real. Mantidos os 4 em pastas realmente vazias.

- **`prompts/INDICE.md` criado** — tabela única com todas as 48 rodadas (ID, estratégia, alvo, gerados, pass(final), taxa), com links para os docs. Inclui notas sobre desvios (formatName retroativo, GPT-4o no WIDGET-COT-03) e totais por nível.

- **Nota adicionada em INT-ZS-03** — `## Resposta do LLM` agora esclarece que a geração inicial foi de 5 testes e que o total de 8 na tabela reflete o estado após repair loop.

- **Campo `Complexidade` verificado** — todos os 9 docs de widget já possuíam o campo; nenhuma edição necessária.

---

## Resumo Executivo — Estado final (repositório limpo)

**Data de encerramento da auditoria:** 2026-06-03

### Todos os itens corrigidos (22 itens)

| Item | Arquivo(s) |
|---|---|
| WIDGET-COT-03 tabela pós-repair (3/10 → 12/1) | `WIDGET-COT-03_cadastro.md` + `dados_consolidados.md` |
| WIDGET-COT-03 nota sobre GPT-4o | `WIDGET-COT-03_cadastro.md` + `dados_consolidados.md` |
| INT-ZS-01 campo Flutter (era "GPT-5.5") | `INT-ZS-01_login.md` |
| INT-ZS-01 placeholders de resposta (3x) | `INT-ZS-01_login.md` |
| Contagem iterações INT no consolidado (14 → 10) | `dados_consolidados.md` |
| Propagação numérica ao consolidado (taxas recalculadas) | `dados_consolidados.md` |
| Notas metodológicas no consolidado (3 novas) | `dados_consolidados.md` |
| Nota formatName retroativo em UNIT-ZS-08 e FS-08 | 2 docs unitários |
| 4 links mortos no README | `prompts/README.md` |
| Referência `PROMPT_TEMPLATE_INT.md` → correto | `prompts/README.md` |
| Tabela de rastreabilidade Widget adicionada | `prompts/README.md` |
| Árvore de pastas atualizada | `prompts/README.md` |
| CLAUDE.md Tracking progress atualizado | `CLAUDE.md` |
| Cabeçalho PROMPT_TEMPLATE_WIDGET.md | `PROMPT_TEMPLATE_WIDGET.md` |
| Template resultado 4 → 6 linhas | `Template_Documentacao_Rodada.md` |
| results/README.md expandido (3 níveis) | `results/README.md` |
| WIDGET-COT-03_iter3.txt criado | `results/widget/cot/` |
| WIDGET-COT-01/02 nome de seção padronizado | 2 docs de widget |
| INT-ZS-03 nota sobre discrepância narrativa vs tabela (5 vs 8) | `INT-ZS-03_playlist.md` |
| analise/README.md criado | `analise/README.md` |
| 16 `.gitkeep` removidos de pastas com conteúdo | 16 arquivos |
| prompts/INDICE.md criado (índice das 48 rodadas) | `prompts/INDICE.md` |

### Itens sem ação necessária

| Item | Motivo |
|---|---|
| Padronizar `Complexidade` nos docs widget | Todos os 9 docs já possuíam o campo — verificado |
| Inconsistência versão Flutter (3.41.7 vs 3.41.6) | Reflete execuções em momentos distintos — dado real, não erro |
| Inconsistência nomes campo "Arquivo(s) de origem" | 48 docs não modificados; template atualizado com orientação |
| `.gitkeep` em 4 dirs realmente vazios | Mantidos intencionalmente (dirs reservados para fases não executadas) |

### Nenhum item pendente

O repositório está auditado e limpo. Todos os PROBLEMAS foram corrigidos; todas as ATENÇÕES foram resolvidas ou documentadas como decisões conscientes.
