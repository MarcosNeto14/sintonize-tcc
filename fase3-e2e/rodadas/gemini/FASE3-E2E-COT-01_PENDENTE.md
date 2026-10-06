# FASE3-E2E-COT-01_loginFlow — Gemini — PENDENTE (rodada 31, interrompida)

Interrompida em 2026-10-06 por decisão do autor, depois de a iteração 2 travar
duas vezes por falta de memória na máquina original (`DellT4i51`, 7,8 GB; 0,5–1,0
GB livres com AVD, emuladores, Chrome e outros apps abertos). Conversa:
`https://gemini.google.com/app/60b70378ac678107` (envio automatizado). Seletor
conferido em 3.8 Flash (`evidencias/gemini/FASE3-E2E-COT-01_loginFlow_seletor_38flash.jpg`).
Prompt: `prompts_prontos/cot/FASE3-E2E-COT-01_loginFlow.md` (sha256 do blob
`199c50d6…bfdf`, igual ao de `_sha256.txt`), 34.484 caracteres.

## Estado

| Passo | Artefato | Resultado |
|---|---|---|
| Geração | `..._transcricao/iter0_resposta.md`, `teste_iter0_geracao.dart` | iter0 **4/5** — teste de sucesso: `TelaInicialScreen` não encontrada logo após o login (`resultados/gemini/..._iter0.txt`) |
| Reparo 1 | `iter1_resposta.md` — **(B)**, mas com arquivo completo (`teste_iter1.dart`), aplicado | iter1 **4/5** — agora falha na saudação ("essa é a nossa recomendação…") |
| Reparo 2 | `iter2_resposta.md` — **(A)**, arquivo completo (`teste_iter2.dart`) | iter2 **não executada** |

## Ocorrências

1. **Iteração 2 travou no seed**, duas vezes: a primeira, o `flutter test` do `seed_test` ficou parado depois de instalar o APK (mais de 10 min, sem nenhum teste executado) e foi encerrado; a segunda tentativa foi interrompida pelo autor durante o build. A saída parcial ficou em `resultados/gemini/..._iter2_interrompida.txt` (só o build); não é resultado. O print vazio foi apagado.
2. **Reparo 1 com cerca solta:** o Markdown copiado tem um ```` ``` ```` de fechamento sem abertura (linha 58); o teste é o bloco ```` ```dart ```` das linhas 74–258, que bate com os 3 blocos renderizados na página. O extrator passou a abrir bloco só em ```` ```dart ```` e fechar na próxima linha ```` ``` ````.

## Para retomar

1. Liberar memória antes (fechar apps; os emuladores e o AVD sobem de novo).
2. Executar `teste_iter2.dart` inalterado como `integration_test/fase3/login_cot_test.dart` no worktree `Desktop\sintonize-fase3` (seed conferido 1/1/5) → `_iter2.txt`.
3. Se falhar: reparo 3 na mesma conversa (template + saída literal), aplicar, `_iter3_final.txt`. Se passar: `_iter2` é o final.
4. Escrever `FASE3-E2E-COT-01_loginFlow.md`, arquivar o teste em `integration_test/fase3/gemini/login_cot_test.dart` e apagar esta nota.

O arquivo de trabalho foi retirado do worktree; `teste_iter2.dart` é idêntico a ele (conferido por `cmp`).
