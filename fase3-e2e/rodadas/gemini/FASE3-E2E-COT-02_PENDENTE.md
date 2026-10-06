# FASE3-E2E-COT-02_cadastroFlow — Gemini — PENDENTE (rodada 32, interrompida)

Interrompida em 2026-10-06 por decisão do autor (troca de máquina), depois da
iteração 1. Executada na máquina original (`DellT4i51`), worktree
`Desktop\sintonize-fase3` (detached em `dc88352`, `lib/` limpo). Conversa:
`https://gemini.google.com/app/3968b3e7d43db829` (envio automatizado). Seletor
conferido em 3.8 Flash (`evidencias/gemini/FASE3-E2E-COT-02_cadastroFlow_seletor_38flash.png`).
Prompt: `prompts_prontos/cot/FASE3-E2E-COT-02_cadastroFlow.md`, 50.897
caracteres (52.381 no editor). O primeiro clique na seta não enviou; o segundo
enviou (uma única mensagem na conversa).

## Estado

| Passo | Artefato | Resultado |
|---|---|---|
| Geração | `..._transcricao/iter0_resposta.md`, `teste_iter0_geracao.dart` (4 cenários) | iter0 **0/4** — `RangeError (index)` num índice de campo (5 de 5), "E-mail inválido" não encontrado, entre outros (`resultados/gemini/..._iter0.txt`) |
| Reparo 1 | `iter1_resposta.md` — **(A)**, arquivo completo (`teste_iter1.dart`, sha256 `6eeb05be…977b`); o maior dos 4 blocos | iter1 **1/4** — cenário 1: `GenerosCadastroScreen` não encontrada (linha 89); depois do teste, `State.context` após unmount em `cadastro.dart:176` (`_submit`); cenários 3 e 4 também falham (`..._iter1.txt`) |
| Reparo 2 | `prompt_reparo_iter2.txt` **não montado, não enviado** | — |

## Para retomar

1. Montar o reparo 2 com `scripts_automacao/reparo.ps1` a partir de `resultados/gemini/FASE3-E2E-COT-02_cadastroFlow_iter1.txt` e enviá-lo **na mesma conversa** (link acima).
2. Aplicar a resposta (se trouxer teste completo) como `integration_test/fase3/cadastro_cot_test.dart` no worktree limpo; seed conferido 1/1/5; executar → `_iter2.txt`. Seguir até o reparo 3 / `_iter3_final.txt` se precisar.
3. Escrever `FASE3-E2E-COT-02_cadastroFlow.md`, arquivar o teste final em `integration_test/fase3/gemini/cadastro_cot_test.dart` e apagar esta nota.

O arquivo de trabalho foi retirado do worktree; `teste_iter1.dart` é idêntico a ele (conferido por `cmp`).
