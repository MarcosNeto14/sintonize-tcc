# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is a **TCC (undergraduate thesis) experiment**, not a product. The Flutter app "Sintonize" is the *artifact under test*; the actual research output is the controlled comparison of three LLM prompting strategies (Zero-shot, Few-shot, Chain-of-Thought) for generating automated tests for the pyramid (unit / widget / integration).

The experiment is **fully manual and documented**: each "round" (one function × one strategy) has a markdown doc capturing the exact prompt sent, the exact LLM response, the test file produced, the `flutter test` output, and any repair iterations (max 3). The whole point is reproducibility and traceability — do not "improve" outputs after the fact.

## Commands

```bash
flutter pub get                          # install deps
flutter test test/unit/                  # run all unit tests
flutter test test/unit/validate_nome_zs_test.dart   # run a single test file
flutter test test/widget/                # run widget tests
flutter analyze                          # lint (uses flutter_lints)
flutter --version                        # required when filling out round metadata
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

## Workflow for a new round

1. Open the round doc (e.g. `prompts/unit/cot/UNIT-COT-04_validateCEP.md`).
2. Copy the prompt template from `prompts/PROMPT_TEMPLATES.md` for the strategy, substitute the target function's code verbatim from `lib/utils/validators.dart`.
3. Start a **new** ChatGPT conversation (one round = one fresh conversation; cross-contamination invalidates the comparison).
4. Paste the LLM's generated Dart code into the corresponding `test/unit/<func>_<strategy>_test.dart` file.
5. Run `flutter test test/unit/<that_file>.dart` and save the terminal output under `results/unit/<strategy>/`.
6. Fill in the round doc using `prompts/Template_Documentacao_Rodada.md` — metadata (model version, date, Flutter version), exact prompt, exact response, metrics.
7. If tests fail: use the repair prompt from `PROMPT_TEMPLATES.md` in the **same** conversation, **max 3 iterations**, document each iteration.

## What not to do

- Don't refactor `lib/utils/validators.dart` to fix the cross-function inconsistencies — they are the subject of analysis.
- Don't edit LLM-generated test files in `test/unit/` or `test/widget/` to make them pass. If a test fails, it fails — record it. The only allowed mutation path is the documented repair loop.
- Don't rewrite round docs to reflect a "cleaner" history. Prompts, responses, and outputs must be the actual artifacts.
- Don't add new dependencies casually; the experiment is anchored to the pinned versions in `pubspec.yaml` and `pubspec.lock`.

## Tracking progress

The unit/COT phase is in progress (see `prompts/unit/cot/`). Each strategy spans 10 functions; the FS and ZS phases for unit are complete. Widget tests cover `login`, `cadastro`, `criar_playlist` across the three strategies. Integration and E2E (`e2e-manual/`) are still TBD.
