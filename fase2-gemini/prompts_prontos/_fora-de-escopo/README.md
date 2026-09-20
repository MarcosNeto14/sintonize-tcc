# Prompts fora do escopo das 30 rodadas limpas

Os 6 prompts nesta pasta foram gerados quando o escopo das rodadas limpas da
Fase 2 era **10 funções unitárias × 3 estratégias**. Em **2026-09-03** o autor
do TCC revisou o escopo de volta ao desenho original:

> **8 funções unitárias + CadastroScreen (widget) + fluxo de login (integração)**,
> × 3 estratégias = 30 rodadas.

O motivo é metodológico: a Fase 1 cobriu os três níveis da pirâmide
(unitário, widget, integração) de forma equilibrada, e a Fase 2 precisa da
mesma distribuição para permitir a comparação final entre as duas fases nos
três níveis — não apenas no unitário.

Com isso, `validateSenha` e `capitalize` saíram do grupo limpo. As duas já
têm dado próprio no experimento:

| Função | Bug do piloto | Rodadas do piloto |
|---|---|---|
| `validateSenha` | U-SILENT | `FASE2-USILENT-{ZS,FS,COT}` |
| `capitalize` | U-CRASH | `FASE2-UCRASH-{ZS,FS,COT}` |

E, no caso de `validateSenha`, também dois artefatos extras de controle limpo:

- `fase2/rodadas/unit/FASE2-VALIDATESENHA-ZS-FORA-DE-ESCOPO.md` — rodada
  executada contra o código já revertido (8/8, sem reparo).
- `fase2/rodadas/unit/FASE2-VALIDATESENHA-ZS-ACHADO-EXTRA-BUG-ATIVO.md` —
  rodada executada por engano contra o código com o bug ainda ativo
  (10/10, categoria (C)).

Juntos, os dois formam um par controlado: mesma função, mesmo prompt, mesma
estratégia, com e sem o bug.

**Estes arquivos são preservados, não descartados** — o conteúdo segue válido
e reflete o código real pós-reversão dos bugs. Estão aqui apenas para deixar
claro que não fazem parte da execução das 30 rodadas limpas.

Os prompts ativos das rodadas limpas estão em
`fase2/prompts_prontos/unit/{zero-shot,few-shot,cot}/` (24 = 8 funções × 3)
mais os prompts de widget e integração.
