# Alinhamento com o texto final (tcc/main.tex)

| Afirmação nos textos de análise | Versão final |
|---|---|
| "o prompt traz sempre o código limpo" | Vale só para a Fase 3 (E2E). Na Fase 2 o prompt trazia o código com o defeito (regime de defeito visível); na Fase 3, código limpo e execução contra worktree com defeito (regime oculto). Ver `tcc/main.tex` §4.4 e Ct7. |
| "14 canonizações" | 7 (2 ChatGPT, 5 Gemini) nos defeitos plantados, mais R5 em alvo limpo. |
| "FS tem a pior aprovação nos dois" | Pior no ChatGPT (88,0%); no Gemini a pior é COT (88,2%). |
| Coluna "Viu o defeito" por estratégia | ChatGPT 6/8, 6/9, 4/8; Gemini 5/9, 6/9, 4/9. |
| "P2 5/5", "C3 1/8" | P2 4/5 (4/4 das que chegaram à lista), C3 1/5. |
| "I-CRASH 0/6 exercitado" | 0/6 capturado; canonizado nas duas COT. |
| R5 "canonizado" | Na mesma rodada (UNIT-COT-06), capturado por um teste e canonizado por outro. |
| Estado do código com os defeitos | Fase 2: os seis defeitos ativos juntos no commit `295fa34` (limpo `03c9bac`); Fase 3: um worktree por defeito (`eb14334`, `20edaaa`, `60cbaff`; limpo `ccae44a`). Co-atividade verificada sem efeito nas rodadas limpas. |
| Prompts de reparo da Fase 3 | 86 prompts de reparo arquivados na Fase 3 = 85 iterações com resposta + 1 reparo da C3-COT do ChatGPT sem resposta. |
| W-CRASH-FS do Gemini registrado como `3/2 n.c.` | O arquivo final compila e executa (`fase2-gemini/resultados/widget/FASE2-WCRASH-FS_iter3_final.txt`: 3 passaram, 2 falharam); o rótulo n.c. era indevido. A taxa de 91,8% de Widget/Gemini com defeito já incluía essa rodada. |
| Tabela por estratégia com coluna agregada "Viu o defeito" | Desmembrada em Capturou / Caracterizou / Viu sem asserção / Canonizou / Não viu (ChatGPT ZS 1·4·1·0·2, FS 3·3·0·0·3, COT 1·3·0·2·2; Gemini ZS 2·2·1·1·3, FS 3·1·2·1·2, COT 2·2·0·3·2). |
| `FASE2-UNIT-COT-06_validateEmailLogin` (ChatGPT): o doc da rodada registra 18 testes gerados e 17/1 no estado final | 19 testes e 18/1: `fase2/resultados/unit/cot/FASE2-UNIT-COT-06_validateEmailLogin_iter1_final.txt` termina em `+18 -1`, e `test/fase2/unit/validate_email_login_cot_test.dart` tem 19 `test()`. A Pirâmide já traz 19 e 18/1. O doc da rodada não foi alterado (registro de 2026-11-25, conferência do pacote de replicação). |
| `FASE2-UNIT-ZS-10_validateDate` (ChatGPT): o doc da rodada registra 34 testes gerados e 34/34 | 33 e 33/33: `fase2/resultados/unit/zero-shot/FASE2-UNIT-ZS-10_validateDate_iter0_final.txt` termina em `+33: All tests passed!`, e `test/fase2/unit/validate_date_zs_test.dart` tem 33 `test()`. A Pirâmide já traz 33/33. O doc da rodada não foi alterado. |
| `FASE3-E2E-ZS-02_cadastroFlow` (Gemini): a aba Rodadas de `Piramide_Unificada_ChatGPT_x_Gemini.xlsx` registrava 5 testes gerados (com 4 passando e 0 falhando) | 4: a resposta da iteração 0 (`fase3-e2e/rodadas/gemini/FASE3-E2E-ZS-02_cadastroFlow_transcricao/iter0_resposta.md`) tem 4 `testWidgets()`, a saída da iteração 0 termina em `+2 -2` e a final em `+4: All tests passed!`; o doc da rodada já dizia 4. Célula I155 da aba Rodadas corrigida de 5 para 4 em commit próprio; totais do Gemini passam a 28 gerados no E2E e 404 no agregado dos alvos limpos. |

Em caso de divergência, prevalece tcc/main.tex.
