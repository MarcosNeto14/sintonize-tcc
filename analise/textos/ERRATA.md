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

Em caso de divergência, prevalece tcc/main.tex.
