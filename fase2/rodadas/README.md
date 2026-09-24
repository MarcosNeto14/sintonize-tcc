# Rodadas da Fase 2 — Notas Gerais

Documentação individual de cada rodada em `unit/`, `widget/` e
`integration/`, seguindo `fase2/Template_Documentacao_Rodada_Fase2.md`.

## Desvio de protocolo — sessão sem login

Por decisão do autor do TCC, todas as 18 rodadas da Fase 2 são
executadas em sessão do ChatGPT **sem login** (deslogada, sem conta),
em vez da conta paga usada na Fase 1 (documentada como GPT-5.5). Não há
seletor de modelo visível sem login, então a versão real não é
verificável de forma independente. Perguntado diretamente, o modelo se
autodeclarou "GPT-5.6 Luna" — nome que não corresponde a nenhuma
nomenclatura pública conhecida da OpenAI, então deve ser tratado como
autodeclaração não confiável (modelos frequentemente confabulam a
própria identidade quando perguntados), não como confirmação
verificada.

Esse desvio se aplica a todas as rodadas da Fase 2 e é análogo (mas não
idêntico) ao desvio já documentado em WIDGET-COT-03 (GPT-4o) na Fase 1.
Deve ser considerado na análise comparativa entre Fase 1 e Fase 2.

## Rodadas isoladas — reparo enriquecido pelo operador

Em 2026-09-24, 15 rodadas de bug plantado (`WCRASH-{FS,COT}`,
`WSILENT-{ZS,FS,COT}`, `WSILENT-FS_REEXEC`, `ICRASH-{ZS,FS,COT}` e os três
`_REEXEC`, `ISILENT-{ZS,FS,COT}`) foram movidas sem alteração para
`fase2/_execucao-assistida/`. Nelas o prompt de reparo levou informação do operador
além do template fixo, e por isso ficam fora da comparação entre modelos. As 7
rodadas de bug plantado sem reparo enriquecido continuam aqui. Detalhes em
`fase2/_execucao-assistida/README.md`.

> Correção (2026-09-24): a autodeclaração "GPT-5.6 Luna" corresponde ao nome oficial do modelo do tier gratuito/deslogado (OpenAI Help Center, https://help.openai.com/en/articles/20001354-gpt-56-and-gpt-6-pro-in-chatgpt, consultado em 2026-09-24); a fonte externa da época que indicava "Sol" descrevia o plano pago.
