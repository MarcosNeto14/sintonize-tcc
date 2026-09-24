# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is a **TCC (undergraduate thesis) experiment**, not a product. The Flutter app "Sintonize" is the *artifact under test*; the actual research output is the controlled comparison of three LLM prompting strategies (Zero-shot, Few-shot, Chain-of-Thought) for generating automated tests for the pyramid (unit / widget / integration).

The experiment is **fully manual and documented**: each "round" (one function × one strategy) has a markdown doc capturing the exact prompt sent, the exact LLM response, the test file produced, the `flutter test` output, and any repair iterations (max 3). The whole point is reproducibility and traceability — do not "improve" outputs after the fact.

The work is organized in **four stages**, each with its own artifact tree. See "Experiment structure and progress" at the bottom for the full picture, and read that section before assuming anything about counts, branches, or which model was used.

| Stage | Rounds | Model | Artifacts | Branch | Status |
|---|---|---|---|---|---|
| **Fase 1** — pilot study | 48 | ChatGPT | `prompts/`, `results/`, `analise/` | `main` | complete |
| **Fase 2** — main study | 60 = 42 clean + 18 planted-bug (+4 `_REEXEC`) | ChatGPT | `fase2/`; 15 operator-assisted bug rounds isolated in `fase2/_execucao-assistida/` | `fase2-prep` / `fase2-alvos-limpos` | complete |
| **Fase 2 – Gemini** — replication | 60 (+4 `_REEXEC`) | Gemini 3.8 Flash | `fase2-gemini/` | bug rounds: `fase2-gemini-piloto`; clean: `fase2-gemini-alvos-limpos` | complete |
| **Fase 2 – ChatGPT re-run** — the 22 bug rounds, fixed repair template | 18 (+4 `_REEXEC`) | ChatGPT | `fase2-chatgpt-reexec/`, `test/fase2-chatgpt-reexec/` | `fase2-gemini-piloto` | infrastructure only, 0/22 |

## Commands

```bash
flutter pub get                          # install deps
flutter test test/unit/                  # run all unit tests
flutter test test/unit/validate_nome_zs_test.dart   # run a single test file
flutter test test/widget/                # run widget tests
flutter test test/fase2/unit/            # Fase 2 tests (also widget/, integration/)
flutter analyze                          # lint (uses flutter_lints)
flutter --version                        # required when filling out round metadata
git branch --show-current                # ALWAYS check before running a Fase 2 round
```

Dart SDK constraint: `>=2.17.0 <4.0.0` (per `pubspec.yaml`).

## Architecture

**`lib/utils/validators.dart`** is the single source of truth for the functions under test. It is **deliberately not idiomatic**: the file collects 10 validation/formatting functions copy-pasted from various screens (`cadastro.dart`, `login.dart`, `alterar-dados.dart`, `mapa.dart`, `adicionar-musica.dart`) **preserving the original inconsistencies between them** — three different email validators with diverging regexes and required/optional behavior, two different name-capitalization functions with different casing rules, etc. These inconsistencies are *data* for the thesis. **Never refactor them.** The docstrings explicitly flag each inconsistency.

The 10 target functions, in fixed experimental order:

| # | Function | Origin |
|---|---|---|
| 01 | `validateNome` | cadastro.dart |
| 02 | `validateSenha` | login.dart |
| 03 | `validateNumero` | cadastro.dart |
| 04 | `validateCEP` | cadastro.dart |
| 05 | `validateEmail` | cadastro.dart (strict regex, required) |
| 06 | `validateEmailLogin` | login.dart (permissive regex, required) |
| 07 | `validateEmailEdit` | alterar-dados.dart (strict regex, optional) |
| 08 | `formatName` | adicionar-musica.dart (preserves rest-of-word casing) |
| 09 | `capitalize` | mapa.dart (lowercases rest of word) |
| 10 | `validateDate` | cadastro.dart |

## Experimental conventions

**Round IDs:** `LEVEL-STRATEGY-NUMBER` — e.g. `UNIT-COT-03` = unit / chain-of-thought / `validateNumero`. See `prompts/README.md` for the full traceability table.

- Levels: `UNIT`, `WIDGET`, `INT`
- Strategies: `ZS` (zero-shot), `FS` (few-shot), `COT` (chain-of-thought); `MS` and `CE` reserved for integration

**File naming follows the ID one-to-one:**

```
prompts/unit/{zero-shot,few-shot,cot}/UNIT-{ZS,FS,COT}-NN_<funcName>.md
test/unit/<func_name>_{zs,fs,cot}_test.dart
results/unit/{zero-shot,few-shot,cot}/<output of flutter test>
```

Same pattern for widget tests under `test/widget/` and `prompts/integration/` (note: the `integration/` prompts directory currently holds the *widget* test rounds — `WIDGET-ZS-NN_*.md` etc.).

**Fase 2 IDs** use a `FASE2-` prefix and live in a parallel tree. Planted-bug rounds are named after the bug, clean-target rounds keep the Fase 1 shape:

```
fase2/prompts_prontos/FASE2-{U,W,I}{CRASH,SILENT}-{ZS,FS,COT}.md      # planted bug
fase2/prompts_prontos/unit/{zero-shot,few-shot,cot}/FASE2-UNIT-{ZS,FS,COT}-NN_<func>.md
fase2/rodadas/{unit,widget,integration}/<ID>.md                        # round docs
fase2/resultados/<level>/<strategy>/<ID>_iter<N>[_final].txt
test/fase2/{unit,widget,integration}/<name>_{zs,fs,cot}_test.dart
```

Bug IDs: `UCRASH` (`capitalize`), `USILENT` (`validateSenha`), `WCRASH` (`CriarPlaylistScreen._filterMusicas`), `WSILENT` (`LoginScreen.login()`), `ICRASH` (`GenerosCadastroScreen._salvarGeneros`), `ISILENT` (`CriarPlaylistScreen._salvarPlaylist`).

A `_REEXEC` suffix marks a round re-run with a corrected prompt. It is documented as a **new** round alongside the original, never as a replacement. Four exist in Fase 2 (`WSILENT-FS`, `ICRASH-{ZS,FS,COT}`) and are not counted in the headline 60.

`fase2-gemini/` mirrors this layout exactly, with `prompts_prontos/` byte-identical to Fase 2's.

## Workflow for a new round

**The LLM depends on the stage.** Fase 1, Fase 2 and the Fase 2 – ChatGPT re-run use ChatGPT; the Fase 2 – Gemini replication used Gemini. Check which stage the round belongs to before opening a conversation — using the wrong model silently invalidates the round.

1. **Check out the right branch for the block** (see the branch map below) and verify the code state. Getting this wrong has already contaminated rounds once — see the 2026-09-03 incident note in `fase2/propostas_bugs_fase2.md`.
2. Open the round doc (e.g. `prompts/unit/cot/UNIT-COT-04_validateCEP.md`, or for Fase 2 the ready-made prompt under `fase2/prompts_prontos/`).
3. For Fase 1, copy the prompt template from `prompts/PROMPT_TEMPLATES.md` and substitute the target function's code verbatim from `lib/utils/validators.dart`. Fase 2 prompts are already complete — paste them verbatim, changing nothing.
4. Start a **new** conversation with the stage's LLM (one round = one fresh conversation; cross-contamination invalidates the comparison).
5. **Record the model version** — ask the LLM what version it is and record the answer *literally*, plus an external check of which model is served on that date. See "Model version must be recorded per session" below. This is mandatory for every Fase 2 – Gemini and ChatGPT re-run round.
6. Paste the LLM's generated Dart code into the corresponding test file (`test/unit/<func>_<strategy>_test.dart`, or `test/fase2/<level>/...`).
7. Run `flutter test <that_file>` and save the terminal output under the stage's results directory.
8. Fill in the round doc from the stage's template — `prompts/Template_Documentacao_Rodada.md` (Fase 1), `fase2/Template_Documentacao_Rodada_Fase2.md` (Fase 2), or `fase2-gemini/Template_Documentacao_Rodada_Fase2.md` (Gemini, which adds the two model-version fields).
9. If tests fail: use the repair prompt in the **same** conversation, **max 3 iterations**, documenting each iteration and the model's A/B/C self-classification.

### Model version must be recorded per session

During Fase 2 the model served without login **changed from GPT-5.5 to GPT-5.6 mid-study, with no announcement**, and this was only noticed months later. Every round from now on records two independent fields:

- **Model declared by the LLM** — ask at the start of the session, record the answer verbatim.
- **External version check** — confirm from an outside source which model is served on that date.

They are independent on purpose. A model's self-report is not reliable evidence: asked directly during Fase 2, ChatGPT declared itself "GPT-5.6 Luna", a name matching no public OpenAI nomenclature. **When the two fields disagree, record the disagreement — do not resolve it.**

## What not to do

- Don't refactor `lib/utils/validators.dart` to fix the cross-function inconsistencies — they are the subject of analysis.
- Don't edit LLM-generated test files in `test/unit/` or `test/widget/` to make them pass. If a test fails, it fails — record it. The only allowed mutation path is the documented repair loop.
- Don't rewrite round docs to reflect a "cleaner" history. Prompts, responses, and outputs must be the actual artifacts.
- Don't add new dependencies casually; the experiment is anchored to the pinned versions in `pubspec.yaml` and `pubspec.lock`.
- Don't touch completed stages. `prompts/`, `results/`, `analise/` (Fase 1) and `fase2/` (Fase 2) are finished artifact trees and the comparison groups for everything that follows.
- Don't adapt the prompts in `fase2-gemini/prompts_prontos/` for Gemini. They are byte-identical copies of the Fase 2 prompts on purpose — the model is the *only* variable that changes. That includes the "colar no ChatGPT" operator line, which sits above the `---` separator and is not part of what gets sent to the model.

## Experiment structure and progress

### Fase 1 — pilot study (48 rounds, ChatGPT, complete)

**No longer the thesis's main study**, but its artifacts are preserved and must not be altered.

- **Unit (30 rounds):** ZS, FS, COT × 10 functions — `prompts/unit/`, `test/unit/`, `results/unit/`.
- **Widget (9 rounds):** ZS, FS, COT × 3 screens (login, criar_playlist, cadastro) — `prompts/widget/`, `test/widget/`, `results/widget/`.
- **Integration (9 rounds):** ZS, FS, COT × 3 flows (login, cadastro, playlist) — `prompts/integration/`, `test/integration/`, `results/integration/`.
- **E2E manual (4 flows):** roteiros in `e2e-manual/`; all 4 executed and documented (Chrome/Web, 2026-05-25).
- **E2E automated:** not executed (out of scope).
- Analysis in `analise/` covers these 48 rounds only.

### Fase 2 — main study (60 rounds, ChatGPT, complete)

Artifacts in `fase2/`. Repeats the ZS/FS/COT comparison, now against six deliberately planted bugs plus clean targets, using a revised repair prompt that asks the model to self-classify each failure as (A) bad test or (B) real application bug.

| Block | Rounds | Notes |
|---|---|---|
| Planted bug | 18 | 6 bugs × 3 strategies |
| `formatName` | 3 | see the caveat below — not a clean target |
| Clean targets, original | 27 | |
| Clean targets, added later | 12 | to balance widget and integration coverage |
| **Total** | **60** | |

Four `_REEXEC` rounds (corrected prompts for `WSILENT-FS` and `ICRASH-{ZS,FS,COT}`) exist alongside the originals and are not part of the 60.

**Isolated, operator-assisted rounds.** In 15 planted-bug rounds (the 4 `_REEXEC` included), the operator added information to the repair prompt beyond the fixed template: real paths, real API signatures, the real `build()`, and findings from earlier rounds. The Gemini replica used the bare template, so these 15 rounds are excluded from the cross-model comparison. Their artifacts, including their 15 test files, were moved unchanged to `fase2/_execucao-assistida/`, which sits outside `test/`. The clean re-run goes in `fase2-chatgpt-reexec/`. The other 7 planted-bug rounds had no enriched repair and stay in `fase2/`. See `fase2/_execucao-assistida/README.md`.

### Fase 2 – Gemini — replication (60 rounds, complete)

Artifacts in `fase2-gemini/`. It uses the same prompts, targets, planted bugs and protocol as Fase 2 (max 3 repair iterations, A/B/C self-classification, bare repair template). **The model is the only variable that changes.** The prompts are byte-identical copies, verified by `diff -r` and per-file `sha256sum`. The one deviation is the session: it ran logged in, with the model pinned to 3.8 Flash, because logged out Gemini serves only Flash Lite. The reasoning is in `fase2-gemini/README.md`.

All 60 rounds and the 4 `_REEXEC` were executed between 2026-09-22 and 2026-09-24. The docs are split across two branches, and neither branch holds all of them. The 18 bug rounds and 4 `_REEXEC` are on `fase2-gemini-piloto`; the 42 clean-target rounds are on `fase2-gemini-alvos-limpos`.

### Fase 2 – ChatGPT re-run (22 rounds, not started)

`fase2-chatgpt-reexec/` re-runs the 18 planted-bug rounds and the 4 `_REEXEC` on ChatGPT, under the replica's protocol: the repair prompt is the fixed template plus terminal output, and nothing else. Its purpose is to remove the operator-assisted repairs isolated in `fase2/_execucao-assistida/`.

- Rounds run on `fase2-gemini-piloto`.
- Generated tests go to `test/fase2-chatgpt-reexec/`.
- The prompts are byte-identical copies of the 18 bug prompts and `FASE2--REEXEC.md`.
- Read `fase2-chatgpt-reexec/README.md` before starting a round.

**Session condition: logged out**, the same as the 49 ChatGPT rounds that are already valid. Changing it mid-set would create a new variable inside ChatGPT, where the comparison between strategies is the study's primary one.

Per-session control:
- **(a)** Ask the model its version before the prompt, and record the answer literally as a self-report. It is not reliable on its own.
- **(b)** Record an external source on which model is served without login on that date, with URL and access date. Repeat (b) every day of execution: this is the check that was missing in Fase 2 and let the GPT-5.5→5.6 switch go unnoticed.
- **(c)** Save one screenshot per work session in `evidencias/`.

**Exit criterion:** if the external source shows the logged-out tier now serves a model clearly inferior to the paid default, the condition no longer means "default model". The re-run then moves to logged in, with the justification written before the next round.

**Session conditions across the two models.** ChatGPT runs logged out, as the original Fase 2 did. Gemini ran logged in on a Pro account, pinned to 3.8 Flash, because logged out was not viable: the selector locks to Flash Lite, the weakest tier. The author also reports that logged-out sessions blocked the repair loop, but no versioned artifact supports that report yet. Details, evidence and the pending item (d) are in `fase2-chatgpt-reexec/README.md`, section "Condições de sessão nos dois modelos".

Of the 22, the 7 rounds that had no enriched repair (U-CRASH ×3, U-SILENT ×3, W-CRASH-ZS) also remain valid in `fase2/`.

### Branch ↔ round-block map

This is the easiest thing to get wrong, and getting it wrong silently invalidates a round.

| Branch | Code state | Use for |
|---|---|---|
| `fase2-gemini-piloto` | all 6 planted bugs active (created from `295fa34`) | the 18 planted-bug rounds (+4 `_REEXEC`) — Gemini replica and ChatGPT re-run |
| `fase2-alvos-limpos` | all 6 bugs reverted | all clean-target rounds, including the 3 `formatName` ones |
| `fase2-gemini-alvos-limpos` | same code as `fase2-alvos-limpos` | the Gemini replica's 42 clean-target docs; also carries `fase2/_execucao-assistida/` and `fase2-chatgpt-reexec/` |
| `fase2-prep` | **intermediate — only 3 of 6 bugs active** | nothing; see below |

**Do not treat `fase2-prep` as "the branch with the bugs".** U-CRASH and U-SILENT were reverted on it in `8d08ff2`, and W-SILENT in `b9cd1e1`; only W-CRASH, I-CRASH and I-SILENT remain. That false premise is exactly what this note exists to prevent. The only commit with all six simultaneously active is `295fa34`, which is why `fase2-gemini-piloto` branches from it.

Verify the pilot state before running anything — all six must match:

```bash
grep -n "value.length < 7"                    lib/utils/validators.dart   # U-SILENT
grep -c "word.isEmpty"                        lib/utils/validators.dart   # U-CRASH: must be 0
grep -n "musica\['artist_name'\].toLowerCase" lib/criar_playlist.dart     # W-CRASH
grep -n "'nome': 'Nova Playlist'"             lib/criar_playlist.dart     # I-SILENT
grep -n "currentUser!.uid"                    lib/generos-cadastro.dart   # I-CRASH
grep -n -A1 "e.code == 'user-not-found'"      lib/login.dart              # W-SILENT
```

For clean-target blocks, `git diff main -- lib/utils/validators.dart` must be empty.

### Caveat — `formatName` is not a clean target

`formatName` carries a **pre-existing real defect**: it never had the `if (word.isEmpty)` guard and throws `RangeError` on multiple spaces. This is not a planted bug and was never reverted — it is **identical on `main`, `fase2-prep` and `fase2-alvos-limpos`**, so it is not branch contamination.

Its three rounds run on `fase2-alvos-limpos` alongside the rest of the unit block, but **must not be counted as clean targets** in the analysis. The methodology note recording this reclassification is commit `54aeeb5`, which exists **only on `fase2-prep`** — reading `fase2/propostas_bugs_fase2.md` from `fase2-alvos-limpos` will not show it.
