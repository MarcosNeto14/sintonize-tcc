# AUDITORIA DE CONSISTÊNCIA DOCUMENTAL

**Data:** 2026-05-20
**Arquivos auditados:** 39 (30 unit + 9 widget)
**Referências:** `prompts/Template_Documentacao_Rodada.md` e `prompts/README.md`

## Legenda

- **✓** campo/seção presente e preenchido com valor real
- **✗** campo ausente, vazio, com placeholder `_preencher_`, ou em prosa em vez de conteúdo literal
- **~** presente mas com desvio de terminologia ou valor discutível (anotado em Observações)

---

## Parte 1 — Tabela geral (39 linhas)

### Critérios de avaliação

| Coluna | O que verifica |
|--------|---------------|
| Título H1 | Existe e bate com o ID declarado |
| Metadados | Seção presente com tabela de campos |
| Todos campos | 11 campos obrigatórios preenchidos (sem `_preencher_`) |
| Prompt Enviado | Texto literal do prompt (não descrição em prosa) |
| Resposta LLM | Resposta literal colada (não esqueleto/comentário) |
| Resultado+Tabela | Seção presente com tabela de métricas preenchida |
| Repair Loop | Seção presente com iterações documentadas |

### Unit — Zero-shot

| ID | Título H1 | Metadados | Todos campos | Prompt Enviado | Resposta LLM | Resultado+Tabela | Repair Loop | Observações |
|----|:---------:|:---------:|:------------:|:--------------:|:------------:|:----------------:|:-----------:|-------------|
| UNIT-ZS-01 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados da Rodada" (único que segue o template). Flutter 3.41.7. |
| UNIT-ZS-02 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados" (sem "da Rodada"). Flutter 3.41.7. |
| UNIT-ZS-03 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". Iteração 1 documentada com prompt e resposta literais. |
| UNIT-ZS-04 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". Todos os campos preenchidos. |
| UNIT-ZS-05 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-ZS-06 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-ZS-07 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-ZS-08 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". Iteração 1 documentada. |
| UNIT-ZS-09 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-ZS-10 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |

### Unit — Few-shot

| ID | Título H1 | Metadados | Todos campos | Prompt Enviado | Resposta LLM | Resultado+Tabela | Repair Loop | Observações |
|----|:---------:|:---------:|:------------:|:--------------:|:------------:|:----------------:|:-----------:|-------------|
| UNIT-FS-01 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". Prompt literal com exemplos few-shot + função. |
| UNIT-FS-02 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-FS-03 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-FS-04 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-FS-05 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-FS-06 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-FS-07 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-FS-08 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". Iteração 1 documentada. |
| UNIT-FS-09 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-FS-10 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |

### Unit — Chain-of-Thought

| ID | Título H1 | Metadados | Todos campos | Prompt Enviado | Resposta LLM | Resultado+Tabela | Repair Loop | Observações |
|----|:---------:|:---------:|:------------:|:--------------:|:------------:|:----------------:|:-----------:|-------------|
| UNIT-COT-01 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-COT-02 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-COT-03 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". Iteração 1 documentada. |
| UNIT-COT-04 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-COT-05 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-COT-06 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-COT-07 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-COT-08 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". 2 iterações documentadas com prompts e respostas literais. |
| UNIT-COT-09 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |
| UNIT-COT-10 | ✓ | ~ | ~ | ✓ | ✓ | ✓ | ✓ | Seção "Metadados". |

### Widget — Zero-shot

| ID | Título H1 | Metadados | Todos campos | Prompt Enviado | Resposta LLM | Resultado+Tabela | Repair Loop | Observações |
|----|:---------:|:---------:|:------------:|:--------------:|:------------:|:----------------:|:-----------:|-------------|
| WIDGET-ZS-01 | ✓ | ~ | ~ | ✓ | ~ | ~ | ~ | Único ZS com prompt literal completo. Resposta: código transcrito. Repair Loop it.1: "Não executada" (conversa perdida por refresh). Ver §4.5. |
| WIDGET-ZS-02 | ✓ | ~ | ~ | **✗** | **✗** | ~ | ✓ | **PROMPT EM PROSA.** Resposta: esqueleto com comentário, código não transcrito. Ver §2 e §4.4. |
| WIDGET-ZS-03 | ✓ | ~ | ~ | **✗** | **✗** | ~ | ✓ | **PROMPT EM PROSA.** Resposta: esqueleto com 11 testWidgets implícitos, código não transcrito. |

### Widget — Few-shot

| ID | Título H1 | Metadados | Todos campos | Prompt Enviado | Resposta LLM | Resultado+Tabela | Repair Loop | Observações |
|----|:---------:|:---------:|:------------:|:--------------:|:------------:|:----------------:|:-----------:|-------------|
| WIDGET-FS-01 | ✓ | ~ | ~ | **✗** | **✗** | ~ | ✓ | **PROMPT EM PROSA.** Resposta: esqueleto com "código completo em test/widget/login_fs_test.dart". |
| WIDGET-FS-02 | ✓ | ~ | ~ | **✗** | **✗** | ~ | ✓ | **PROMPT EM PROSA.** Resposta: esqueleto com "código completo em test/widget/criar_playlist_fs_test.dart". |
| WIDGET-FS-03 | ✓ | ~ | ~ | **✗** | **✗** | ~ | ✓ | **PROMPT EM PROSA.** Resposta: esqueleto com "código completo em test/widget/cadastro_fs_test.dart". |

### Widget — Chain-of-Thought

| ID | Título H1 | Metadados | Todos campos | Prompt Enviado | Resposta LLM | Resultado+Tabela | Repair Loop | Observações |
|----|:---------:|:---------:|:------------:|:--------------:|:------------:|:----------------:|:-----------:|-------------|
| WIDGET-COT-01 | ✓ | ~ | ~ | ~ | **✗** | ~ | ✓ | Prompt-texto literal, mas código do widget substituído por marcador `[código completo de lib/login.dart — 219 linhas]`. Resposta: análise CoT + esqueleto, código dos 14 tests não transcrito. Flutter **3.41.6** (diverge das demais). |
| WIDGET-COT-02 | ✓ | ~ | ~ | ~ | **✗** | ~ | ✓ | Idem COT-01. Flutter **3.41.6**. |
| WIDGET-COT-03 | ✓ | ~ | ~ | ~ | **✗** | ~ | ✓ | Idem. Flutter **3.41.6**. Modelo **"GPT-4o (2026-05-20)"** — único divergente (demais: "GPT-5.5"). Ver §4.2. |

---

## Parte 2 — Docs com prompt em prosa em vez de literal

Os seguintes arquivos têm "Prompt Enviado" descrevendo a estrutura do prompt em vez de colar o texto exato enviado ao LLM:

| # | Arquivo | Texto encontrado (resumo) |
|---|---------|--------------------------|
| 1 | `WIDGET-ZS-02_criarPlaylist.md` | "Mesmo template zero-shot do PROMPT_TEMPLATE_WIDGET.md, com o código completo de lib/criar_playlist.dart (253 linhas) embutido no marcador [COLAR O CÓDIGO COMPLETO...]. Estrutura do prompt: 1. Instrução [...] 2. Código completo [...]" |
| 2 | `WIDGET-ZS-03_cadastro.md` | "Mesmo template zero-shot do PROMPT_TEMPLATE_WIDGET.md, com o código completo de lib/cadastro.dart (484 linhas — o widget mais complexo...). Estrutura idêntica às rodadas anteriores..." |
| 3 | `WIDGET-FS-01_login.md` | "Template few-shot do PROMPT_TEMPLATE_WIDGET.md. Estrutura: 1. Instrução 'Gere widget tests...' 2. Bloco ```dart``` com exemplo de widget test de um MeuFormulario fictício... 3. 'Agora, gere widget tests para este widget...'" |
| 4 | `WIDGET-FS-02_criarPlaylist.md` | "Template few-shot do PROMPT_TEMPLATE_WIDGET.md (igual ao FS-01: exemplo de MeuFormulario com MockFirebaseAuth...) seguido do código completo de lib/criar_playlist.dart (253 linhas)..." |
| 5 | `WIDGET-FS-03_cadastro.md` | "Template few-shot do PROMPT_TEMPLATE_WIDGET.md (exemplo de MeuFormulario...) seguido do código completo de lib/cadastro.dart (484 linhas — widget mais complexo: Firebase Auth + Firestore + HTTP ViaCEP...)..." |

**Caso limítrofe — COT-01, COT-02, COT-03:** O texto do prompt está literal, mas o código do widget foi substituído por marcador de tamanho (ex.: `[código completo de lib/login.dart — 219 linhas]`). O prompt-instrução é reproduzível; o insumo-código não está embutido no doc.

**Impacto para reprodutibilidade:** Um leitor externo (banca, pesquisador) não consegue reconstruir exatamente o que foi enviado ao LLM nos 5 casos acima sem consultar os arquivos `.dart` separadamente e o `PROMPT_TEMPLATE_WIDGET.md`. Para os 3 casos COT, o código está disponível no repositório, mas não transcrito.

---

## Parte 3 — Divergências de terminologia

### 3.1 Nome da seção de metadados

| Fonte | Texto |
|-------|-------|
| Template oficial | `## Metadados da Rodada` |
| UNIT-ZS-01 | `## Metadados da Rodada` ← único conforme |
| Demais 38 arquivos | `## Metadados` (sem "da Rodada") |

**38 de 39 arquivos divergem do template** neste ponto. A variação é sistemática e não afeta o conteúdo, mas é inconsistente com o template canônico.

### 3.2 Valor de "Nível da pirâmide" nos widgets

| Fonte | Valor |
|-------|-------|
| Template (exemplo) | `Unitário` |
| README (nível widget) | `Widget` / `Widget test` |
| CLAUDE.md | `WIDGET` (código de nível) |
| Todos os 9 arquivos widget | `Integração (Widget Test)` |

O valor "Integração (Widget Test)" confunde dois níveis distintos da pirâmide. O CLAUDE.md lista `WIDGET` e `INT` como níveis separados. O README usa "Widget Tests" para descrever o nível widget. O valor adotado mistura nomenclaturas e é contrário à distinção explícita na documentação do experimento. **Decisão pendente:** corrigir para `Widget Test` ou justificar explicitamente na análise.

### 3.3 Campo extra "Complexidade" nos docs widget

Todos os 9 arquivos widget adicionam um campo não previsto no template:

| Campo | Valores encontrados |
|-------|---------------------|
| `Complexidade` | `Baixa` (login), `Média` (criarPlaylist), `Alta` (cadastro) |

O campo é uma extensão útil e aplicada uniformemente, mas representa um desvio formal do template. Não é um problema grave.

### 3.4 Campo "Função testada" vs "Widget testado"

| Fonte | Nome do campo |
|-------|--------------|
| Template oficial | `Função testada` |
| Todos os 30 arquivos unit | `Função testada` ← conforme |
| Todos os 9 arquivos widget | `Widget testado` |

A adaptação semântica faz sentido (widget test não testa uma função). Divergência justificável, mas não documentada formalmente.

### 3.5 Nome da seção de repair loop

| Fonte | Texto |
|-------|-------|
| Template oficial | `## Iterative Repair Loop (se necessário)` |
| UNIT-ZS-01 | `## Iterative Repair Loop (se necessário)` ← conforme |
| Demais 38 arquivos | `## Iterative Repair Loop` (sem "(se necessário)") |

Variação menor sem impacto no conteúdo.

### 3.6 Estratégia de prompt: terminologia interna consistente

Todos os 39 arquivos usam os valores exatos `Zero-shot`, `Few-shot`, `Chain-of-Thought` no campo "Estratégia de prompt". O README usa "CoT" como abreviação, mas os docs usam o nome completo. **Sem divergência interna nos docs.**

### 3.7 Tabela de métricas: campos diferentes entre unit e widget

**Unit (campos):** Compilou? / Testes gerados / Testes passaram / Testes falharam / Saída do terminal

**Widget (campos adicionais):** Setup correto de mocks? / MaterialApp wrapper? / Tratou assets? / Tipos de teste gerados / Testes passaram pós-repair / Nota metodológica

A expansão do template nos docs widget é coerente internamente, mas não está prevista no template canônico e não foi documentada formalmente como variante.

---

## Parte 4 — Campos com valores suspeitos

### 4.1 Versão do modelo: "GPT-5.5" em 38 de 39 arquivos

| Escopo | Campo | Valor |
|--------|-------|-------|
| 38 arquivos (todos exceto WIDGET-COT-03) | `Versão do modelo` | `GPT-5.5` |

"GPT-5.5" não corresponde a nenhuma versão publicamente documentada da OpenAI conhecida. As versões públicas disponíveis até meados de 2026 incluem GPT-4o, GPT-4o mini, GPT-4.1, GPT-4.5 (preview), o1, o3, GPT-5 — mas não "GPT-5.5". Hipóteses:

- Apelido informal adotado pelo experimentador
- Erro de digitação (ex.: GPT-4.5 → GPT-5.5)
- Versão de acesso antecipado não documentada publicamente

**Impacto para reprodutibilidade:** A identificação precisa do modelo é requisito para reprodução do experimento e citação acadêmica. O valor como está não é verificável por um leitor externo.

### 4.2 Versão do modelo em WIDGET-COT-03: heterogeneidade

| Arquivo | Valor |
|---------|-------|
| WIDGET-COT-01, WIDGET-COT-02 | `GPT-5.5` |
| **WIDGET-COT-03** | **`GPT-4o (2026-05-20)`** |

A última rodada widget COT usou um modelo diferente dos outros dois da mesma estratégia e célula experimental. Isso introduz uma **variável não controlada** na comparação ZS×FS×COT para o widget CadastroScreen. Deve ser registrado como limitação na análise comparativa.

### 4.3 Versão do Flutter: duas versões no experimento

| Rodadas | Versão Flutter |
|---------|---------------|
| 36 rodadas (todos unit + widget ZS + widget FS) | `3.41.7` |
| 3 rodadas (WIDGET-COT-01, COT-02, COT-03) | `3.41.6` |

As 3 rodadas COT de widget foram executadas com uma versão de patch diferente. É improvável que isso afete os resultados (patch version), mas representa uma inconsistência no controle experimental. O CLAUDE.md instrui explicitamente a registrar `flutter --version` por rodada para garantir reprodutibilidade.

### 4.4 Resposta do LLM não transcrita em 8 de 9 docs widget

| Arquivo | Situação |
|---------|----------|
| WIDGET-ZS-01 | ✓ Código transcrito literalmente |
| WIDGET-ZS-02 | ✗ Esqueleto com "// 7 testWidgets... (código completo em test/widget/criar_playlist_zs_test.dart)" |
| WIDGET-ZS-03 | ✗ Esqueleto com 11 testWidgets implícitos |
| WIDGET-FS-01 | ✗ Esqueleto com "código completo em test/widget/login_fs_test.dart" |
| WIDGET-FS-02 | ✗ Esqueleto com "código completo em test/widget/criar_playlist_fs_test.dart" |
| WIDGET-FS-03 | ✗ Esqueleto com "código completo em test/widget/cadastro_fs_test.dart" |
| WIDGET-COT-01 | ✗ Análise CoT + esqueleto; 14 testWidgets não transcritos |
| WIDGET-COT-02 | ✗ Análise CoT + esqueleto; 9 testWidgets não transcritos |
| WIDGET-COT-03 | ✗ Análise CoT + esqueleto; 13 testWidgets não transcritos |

O template exige "[COLAR A RESPOSTA COMPLETA DO CHATGPT AQUI — incluindo explicações e código]". Em 8 dos 9 casos o código gerado existe nos arquivos `.dart` em `test/widget/`, mas não está transcrito no documento de rodada. O WIDGET-ZS-01 é o único caso conforme.

### 4.5 Repair Loop: iteração necessária não executada (WIDGET-ZS-01)

| Arquivo | Campo | Situação |
|---------|-------|----------|
| WIDGET-ZS-01 | Iteração 1 → Resposta do LLM | `N/A — conversa perdida por refresh acidental do navegador` |
| WIDGET-ZS-01 | Iteração 1 → Resultado | `Não executada` |

Único caso em que uma iteração marcada como necessária não foi realizada por razão externa ao experimento (perda de contexto). O protocolo não prevê esta situação. Deve ser registrado explicitamente como **limitação metodológica** na análise.

### 4.6 Datas: coerência cronológica (sem valores suspeitos)

| Fase | Datas |
|------|-------|
| Unit ZS | 2026-04-20 a 2026-04-21 |
| Unit FS | 2026-04-24 |
| Unit COT | 2026-04-30 |
| Widget ZS | 2026-05-15 |
| Widget FS | 2026-05-15 |
| Widget COT | 2026-05-19 a 2026-05-20 |

Cronologicamente coerente (unit antes de widget; ZS→FS→COT). Sem valores suspeitos.

---

## Sumário executivo

| Dimensão | Unit (30) | Widget (9) |
|----------|:---------:|:----------:|
| Título H1 correto | ✓ todos | ✓ todos |
| Prompt literal | ✓ todos | ✓ 1 (ZS-01); ~ 3 (COT, com marcador); ✗ 5 (ZS-02/03, FS-01/02/03) |
| Resposta LLM literal | ✓ todos | ✓ 1 (ZS-01); ✗ 8 |
| Versão do modelo | ~ todos ("GPT-5.5" — valor suspeito) | ~ idem; COT-03 usa modelo diferente |
| Versão Flutter | ✓ consistente (3.41.7) | ✗ COT usa 3.41.6, demais 3.41.7 |
| Nível da pirâmide | ✓ todos "Unitário" | ✗ todos "Integração (Widget Test)" |
| Nome da seção Metadados | ~ 29/30 sem "da Rodada" | ~ todos sem "da Rodada" |

**Ação prioritária 1 — Versão do modelo:** Confirmar e corrigir "GPT-5.5" nos 38 arquivos. Se for apelido, documentar o mapeamento para o model ID real.

**Ação prioritária 2 — Nível da pirâmide nos widgets:** Decidir entre `Widget Test` (conforme README/CLAUDE.md) ou `Integração (Widget Test)` (atual) e aplicar uniformemente. Registrar a decisão.

**Ação prioritária 3 — Prompts/respostas em prosa nos widgets ZS/FS:** Colar os prompts e respostas literais ou documentar formalmente que a reprodutibilidade se apoia nos arquivos `.dart` + `PROMPT_TEMPLATE_WIDGET.md` (decisão de design, não falha acidental).

**Ação não urgente:** Corrigir nome da seção "Metadados" → "Metadados da Rodada" nos 38 arquivos divergentes, se a fidelidade ao template for requisito da entrega.
