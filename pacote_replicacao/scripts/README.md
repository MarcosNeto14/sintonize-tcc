# Scripts que geram `pacote_replicacao/indice.xlsx`

Três scripts, rodados nesta ordem a partir da raiz do repositório, na branch
`fase3-e2e`. Precisam de Python 3 e `openpyxl` (`pip install openpyxl`).
`<tmp>` é uma pasta de trabalho qualquer fora do repositório.

```bash
python -X utf8 -I pacote_replicacao/scripts/export_piramide.py . <tmp>
python -X utf8 -I pacote_replicacao/scripts/extract.py . <tmp>/extract.json
python -X utf8 -I pacote_replicacao/scripts/build.py <tmp> pacote_replicacao/indice.xlsx
```

- `export_piramide.py` exporta a aba Rodadas de
  `analise/planilhas/Piramide_Unificada_ChatGPT_x_Gemini.xlsx` (valores) para
  `<tmp>/piramide_rodadas.csv`. É a autoridade sobre o que é rodada do desenho.
- `extract.py` lê os 76 prompts pelo conteúdo commitado (`git show HEAD:<caminho>`,
  fim de linha LF) e os 187 documentos de rodada do working tree; calcula hash e
  tamanhos, extrai os campos das tabelas de metadados/resultado e grava
  `<tmp>/extract.json`.
- `build.py` cruza o JSON com o CSV, preenche a codificação de detecção da Fase 2
  a partir de `analise/textos/relatorio_bugs.md` (tabela transcrita no próprio
  script), classifica as diferenças contra a Pirâmide e grava a planilha com as
  abas Leia-me, Prompts e Rodadas.

O `indice.xlsx` commitado foi gerado em 2026-11-25 contra a Pirâmide **antes** da
correção da célula I155 (Gemini, `FASE3-E2E-ZS-02_cadastroFlow`, 5 → 4), feita em
commit próprio logo depois; por isso o Leia-me dele ainda lista essa divergência.
Regenerar com a Pirâmide corrigida remove essa linha e nada mais.

Os scripts só leem o repositório; não alteram nenhum artefato executado.
