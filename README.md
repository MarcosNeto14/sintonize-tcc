# Uso de Modelos de Linguagem de Grande Escala na Implementação da Pirâmide de Testes: Um Estudo de Caso em uma Aplicação Móvel

Pacote de replicação do TCC.

- **Autor:** Marcos Leite Bezerra Neto
- **Orientador:** Prof. Cleyton Magalhães
- **Instituição:** Bacharelado em Sistemas de Informação, Universidade Federal Rural de Pernambuco (UFRPE)
- **Texto:** [[PDF]]
- **Licença:** MIT (`LICENSE`)

Este README é só o mapa do pacote. Cada assunto é tratado no README da
pasta correspondente.

## Branches

**`fase3-e2e` é a branch do pacote** e reúne os artefatos de todas as fases.
Ela tem o `lib/` limpo (`git diff ccae44a -- lib/` vazio). As demais branches
são históricas e não devem receber commits:

| Branch / tag | Papel |
|---|---|
| `main` | Fase 1 |
| `fase2-prep`, `fase2-alvos-limpos`, `fase2-gemini-alvos-limpos` | Fase 2 e réplica, já contidas na `fase3-e2e` |
| `fase2-gemini-piloto` → tag `fase2-gemini-piloto-final` (`6c7e0d2`) | estado com os 6 bugs da Fase 2 ativos; artefatos copiados em `519799d` |
| `fase2-chatgpt-reexec` → tag `fase2-chatgpt-reexec-final` (`4c0a3ef`) | reexecução ChatGPT; artefatos copiados em `6986444` e `eba31fa` |

Para rodar um teste de bug plantado, faça o checkout do estado de `lib/` em
que ele foi gerado: a tag `fase2-gemini-piloto-final` para a Fase 2, e
`eb14334` (L4), `20edaaa` (C3) ou `60cbaff` (P2) para a Fase 3. Use um worktree
separado. Ver o mapa de branches em `CLAUDE.md`.

## Pastas

| Pasta | Conteúdo |
|---|---|
| `lib/` | App Sintonize (Flutter + Firebase), o artefato sob teste. `lib/utils/validators.dart` reúne as 10 funções-alvo, com as inconsistências originais preservadas |
| `prompts/`, `results/`, `analise/`, `e2e-manual/` | Fase 1 (piloto, 48 rodadas, ChatGPT): docs de rodada com prompt e resposta, saídas do `flutter test`, consolidação e roteiros E2E manuais |
| `fase2/` | Fase 2 (estudo principal, ChatGPT): prompts, docs, resultados, análises e planilhas. As 15 rodadas com reparo enriquecido pelo operador estão isoladas em `fase2/_execucao-assistida/` |
| `fase2-gemini/` | Réplica da Fase 2 no Gemini (60 rodadas + 4 `_REEXEC`), com os prompts byte-idênticos aos da Fase 2 |
| `fase2-chatgpt-reexec/` | Reexecução no ChatGPT das 15 rodadas assistidas, com o template de reparo puro |
| `fase3-e2e/` | Fase 3, E2E no AVD + Firebase Emulator Suite (36 rodadas, ChatGPT e Gemini) |
| `test/` | Testes finais arquivados: Fase 1 (`unit/`, `widget/`, `integration/`), `fase2/`, `fase2-gemini/`, `fase2-chatgpt-reexec/` |
| `integration_test/` | Fase 3: testes gerados (`fase3/<modelo>/`), seed e helper do emulador, e as implementações de referência (`_referencia/`, fora do protocolo) |
| `scripts/` | Scripts de coleta de cobertura de 2026-10-07 (`scripts/cobertura/`) |
| `docs/` | `README_anterior.md`, o README da raiz antes deste pacote |
| `tcc/` | Texto do TCC em LaTeX (template SBC, v7): `main.tex`, bibliografia, estilo e figuras. Como compilar em `tcc/README.md` |
| `CLAUDE.md` | Instruções operacionais usadas pelo Claude Code: fases, branches e regras do protocolo |

## Como ler uma rodada

Cada rodada tem quatro artefatos: o doc, a transcrição, as saídas do
`flutter test` (uma por iteração, a última com `_final`) e o teste final.

| Fase | Doc da rodada | Transcrição | Saídas do `flutter test` | Teste final |
|---|---|---|---|---|
| 1 | `prompts/unit/cot/UNIT-COT-04_validateCEP.md` | dentro do doc | `results/unit/cot/UNIT-COT-04.txt` | `test/unit/validate_cep_cot_test.dart` |
| 2 (ChatGPT) | `fase2/rodadas/integration/FASE2-INT-FS-02_cadastroFlow.md` | `fase2/rodadas/integration/FASE2-INT-FS-02_transcricao/` | `fase2/resultados/integration/few-shot/FASE2-INT-FS-02_cadastroFlow_iter{0..3}*.txt` | `test/fase2/integration/cadastro_flow_fs_test.dart` |
| 2 (Gemini) | `fase2-gemini/rodadas/integration/FASE2-ICRASH-COT.md` | dentro do doc | `fase2-gemini/resultados/integration/FASE2-ICRASH-COT_iter{0..3}*.txt` | `test/fase2-gemini/integration/icrash_cot_test.dart` |
| 2 (reexec. ChatGPT) | `fase2-chatgpt-reexec/rodadas/integration/FASE2-ICRASH-COT.md` | `fase2-chatgpt-reexec/rodadas/integration/FASE2-ICRASH-COT_transcricao/` | `fase2-chatgpt-reexec/resultados/integration/FASE2-ICRASH-COT_iter{0..3}*.txt` | `test/fase2-chatgpt-reexec/integration/icrash_cot_test.dart` |
| 3 | `fase3-e2e/rodadas/gemini/FASE3-L4-COT.md` | `fase3-e2e/rodadas/gemini/FASE3-L4-COT_transcricao/` | `fase3-e2e/resultados/gemini/FASE3-L4-COT_iter{0..3}*.txt` | `integration_test/fase3/gemini/l4_cot_test.dart` |

Tentativas descartadas ficam em subpastas `_abortadas/`, ao lado das rodadas
válidas.

## Prompts, planilhas e análises

- **Prompts:** os da Fase 1 são gerados a partir de `prompts/PROMPT_TEMPLATE_*.md`.
  Os prompts prontos das demais fases estão em `fase2/prompts_prontos/`,
  `fase2-gemini/prompts_prontos/` (cópia byte-idêntica),
  `fase2-chatgpt-reexec/prompts_prontos/` (cópia dos 18 prompts de bug e
  `FASE2--REEXEC.md`) e `fase3-e2e/prompts_prontos/`.
- **Hashes:** `fase3-e2e/prompts_prontos/_sha256.txt`.
- **Planilhas:**
  - `fase2/planilha/Fase2_Consolidado_60rodadas.xlsx`
  - `fase2/planilha/Fase2_Consolidado_60rodadas_v2.xlsx`
  - `fase2/planilha/Comparacao_ChatGPT_x_Gemini_60rodadas.xlsx`
  - A diferença entre v1 e v2 está em `fase2/planilha/README.md`.
  - `analise/planilhas/`: pirâmide unificada, comparação ChatGPT × Gemini, consolidado Gemini e matriz de rastreabilidade (índice em `analise/planilhas/README.md`).
- **Análises:**
  - `analise/dados_consolidados.md` (Fase 1)
  - `analise/textos/`: textos de análise usados no TCC (pirâmide unificada, comparação e análise Gemini, relatório de bugs, limitações por validade, aplicação de Baltes et al. 2026 e Medeiros 2026)
  - `fase2/analise/` (erro por categoria, auditoria dos (B), cobertura)
  - `fase2-gemini/analise/ajuda_import.md`
  - `fase3-e2e/analise/` (consolidado, custo, cobertura)

## Condições de sessão e versões por bloco

| Bloco | Rodadas | Modelo | Sessão | Fonte |
|---|---|---|---|---|
| Fase 1 | 48 | ChatGPT, GPT-5.5 (WIDGET-COT-03 com GPT-4o, desvio documentado) | conta paga | `prompts/README.md`, `fase2/rodadas/README.md` |
| Fase 2, ChatGPT | 60 + 4 `_REEXEC` (49 válidas fora da execução assistida) | GPT-5.5 → GPT-5.6, troca não anunciada no meio do estudo; autodeclarado "GPT-5.6 Luna" | deslogada | `fase2/rodadas/README.md`, `fase2-gemini/README.md` |
| Fase 2, reexecução ChatGPT | 15 (11 + 4 `_REEXEC`) | GPT-5.6 Luna, autodeclarado e confirmado no OpenAI Help Center (2026-09-24) | deslogada | `fase2-chatgpt-reexec/README.md` |
| Fase 2, Gemini | 60 + 4 `_REEXEC` | 3.8 Flash, fixado no seletor | logada, conta Pro | `fase2-gemini/README.md` |
| Fase 3, ChatGPT | 18 (16 com dado) | GPT-5.6 Luna, autodeclarado e confirmado no Help Center (2026-10-03) | deslogada | `fase3-e2e/README.md`, `fase3-e2e/analise/consolidado_fase3.md` |
| Fase 3, Gemini | 18 | 3.8 Flash | logada, conta Pro | idem |

Tabela "Condições de sessão nos dois modelos", copiada de `fase2-chatgpt-reexec/README.md`:

| | ChatGPT (64 rodadas) | Gemini (64 rodadas) |
|---|---|---|
| **Sessão** | deslogada | logada, conta Pro |
| **Modelo** | GPT-5.6 Luna (tier gratuito; "fastest and lowest-cost" da família, segundo a OpenAI) — autodeclarado e confirmado pela fonte do item d | 3.8 Flash fixado no seletor, print por sessão |
| **Posição na linha do fornecedor** | modelo do tier gratuito | 3.8 Flash, padrão do produto, com 3.5 Flash Lite abaixo e 3.1 Pro acima |
| **Por quê** | condição original da Fase 2, mantida | deslogado era inviável — ver motivos |

## Uso de LLM

Os LLMs tiveram três papéis distintos no trabalho:

1. **Modelos sob estudo** (ChatGPT e Gemini): geraram e repararam os testes. Só as respostas deles são dado experimental.
2. **Claude Code, uso operacional:** rodou o `flutter test`, arquivou saídas, preencheu docs a partir dos artefatos, fez verificações de branch e contagens e escreveu os scripts de cobertura e de automação. As regras que ele seguiu estão em `CLAUDE.md`. O código de teste sob estudo ele só transcreveu das respostas dos modelos, sem escrever nem corrigir nada; os reparos passaram pelo ciclo documentado. As implementações de referência em `integration_test/_referencia/` foram escritas com ajuda dele, fora do protocolo, e nunca entraram em prompt.
3. **Claude in Chrome, envio:** em parte das rodadas, nos dois modelos, colou o prompt no navegador e copiou a resposta. O meio de envio de cada rodada está registrado no doc dela. Os scripts de apoio estão em `fase3-e2e/scripts_automacao/`.

## Como reproduzir

**Pré-requisitos:**
- Flutter 3.41.6 (Dart 3.11.4)
- Para E2E:
  - JDK 17
  - Android SDK com o AVD `tcc_e2e` (Pixel 6, API 34, `google_apis;x86_64`)
  - Node (v22 ou v24)
  - firebase-tools 15.31.0 (`npm i -g firebase-tools@15.31.0`)

O passo a passo para montar o ambiente E2E está em `fase3-e2e/README.md`,
seção "Montar o ambiente numa máquina nova".

```bash
flutter pub get

# unit, widget e integração (VM, sem dispositivo)
flutter test test/fase2/unit/validate_cep_cot_test.dart
flutter test test/fase2/widget/login_screen_zs_test.dart
flutter test test/fase2/integration/login_flow_zs_test.dart

# E2E: emuladores Firebase e AVD
firebase emulators:start --only auth,firestore --project sintonize-fa494   # em outro terminal
flutter emulators --launch tcc_e2e
flutter test integration_test/seed_test.dart -d emulator-5554   # 1 conta, 1 usuarios, 5 musica
# os testes arquivados importam '../firebase_test_helper.dart': rode-os de integration_test/fase3/
cp integration_test/fase3/gemini/login_fs_test.dart integration_test/fase3/tmp_login_fs_test.dart
flutter test integration_test/fase3/tmp_login_fs_test.dart -d emulator-5554
rm integration_test/fase3/tmp_login_fs_test.dart
```

Antes de cada teste E2E, os emuladores devem ser reiniciados vazios e o seed
rodado de novo (`fase3-e2e/template_rodada.md`). O resultado de uma execução
nova pode divergir do registrado no doc (regra (b) de `fase3-e2e/README.md`).

## Limitações do pacote

- As conversas deslogadas do ChatGPT não podem ser recuperadas. O registro
  delas é o que está nos docs e nas transcrições, além dos prints em
  `evidencias/`.
- A cobertura é a da medição de 2026-10-07 (`*/analise/cobertura_resumo.md`).
  Os scripts em `scripts/cobertura/` foram recuperados do registro da sessão e
  não foram reexecutados.
- Na Fase 3, duas células do ChatGPT ficaram sem dado: P2-ZS e C3-COT, por
  limitação do serviço (`fase3-e2e/README.md`, "Limitações e desvios (d)").
  Na réplica Gemini, `FASE2-ICRASH-ZS_REEXEC` não foi executada (duas recusas).
