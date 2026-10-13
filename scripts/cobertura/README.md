# Scripts de cobertura (medição de 2026-10-07)

Coletam cobertura de linhas (`flutter test --coverage`) dos testes finais
arquivados das rodadas limpas e geram os CSV e resumos de
`fase2/analise/cobertura*` e `fase3-e2e/analise/cobertura*`.

**Origem:** os arquivos originais ficaram no diretório temporário da sessão
(`$TMP/cov/`) e não existem mais. Estes foram **recuperados do registro da
sessão do Claude Code de 2026-10-07**: o conteúdo de cada heredoc de criação
foi extraído, e os patches que efetivamente surtiram efeito foram reaplicados
na mesma ordem (14:18 no `fase2.sh`; 14:30 e 14:31 no `parse.py`; 14:47 no
`fase3.sh`). O resultado é o estado dos scripts no fim da medição, com o
conteúdo literal, sem limpeza nem generalização. Eles **não foram
reexecutados** depois da recuperação, só checados quanto à sintaxe
(`bash -n` e `ast.parse`).

| Arquivo | O que faz |
|---|---|
| `fase2.sh` | Roda `flutter test --coverage` arquivo por arquivo em `test/fase2/` e `test/fase2-gemini/`, excluindo `ucrash`, `usilent`, `wcrash`, `validate_senha_zs` e `format_name`, com timeout de 240 s. Copia cada `coverage/lcov.info` para `$TMP/cov/fase2/<id>.lcov` e registra rc, tempo e pass/fail em `log.txt`. Se for interrompido, retoma de onde parou. |
| `fase3.sh` | Para cada um dos 18 testes limpos de `integration_test/fase3/{chatgpt,gemini}/`: reinicia os emuladores Firebase vazios, roda `seed_test` e confere 1/1/5 por REST (bloqueante). Depois copia o teste para o worktree de build como `cov_<f>_test.dart`, roda `flutter test --coverage -d emulator-5554` (timeout de 600 s) e apaga a cópia. A saída fica em `$TMP/cov/fase3/`. |
| `parse.py` | `parse.py <fase2\|fase3> <dir_lcov> <csv_saida> <resumo_md>`: lê os `.lcov`, grava o CSV (uma linha por arquivo de `lib/` e uma `TOTAL` por rodada) e a tabela do resumo (média do % por rodada e união da célula). |

## Como rodar

Usa Git Bash no Windows. Os caminhos do repositório e do worktree estão
fixos no topo de cada script e devem ser ajustados para a máquina.

```bash
mkdir -p "$TMP/cov/fase2"          # fase2.sh não cria o diretório
bash scripts/cobertura/fase2.sh
python scripts/cobertura/parse.py fase2 "$TMP/cov/fase2" fase2_cobertura.csv fase2_resumo.md

# Fase 3: AVD tcc_e2e ligado (emulator-5554), firebase-tools no PATH, JDK 17,
# worktree de build com o lib/ limpo (ccae44a) em $W
bash scripts/cobertura/fase3.sh
python scripts/cobertura/parse.py fase3 "$TMP/cov/fase3" fase3_cobertura.csv fase3_resumo.md
```

A repetição dos 3 arquivos de playlist do ChatGPT usou uma variante gerada por
`sed`: `OUT` passa a ser `$TMP/cov/fase3_rep`, e o laço fica em
`for m in chatgpt; do for f in playlist_zs playlist_fs playlist_cot; do`.

O texto dos `cobertura_resumo.md` (escopo, rodadas não medidas, observações)
foi escrito à mão em torno da tabela gerada por `parse.py`.

## Cuidados

- **O filtro do `fase2.sh` vale para o repositório de 2026-10-07.** Naquela
  data, `test/fase2-gemini/` ainda não tinha os testes das rodadas de bug do
  Gemini, que vieram de `fase2-gemini-piloto` depois. Rodado hoje, o `find`
  também pegaria `icrash*`, `isilent*` e `wsilent*`. Para reproduzir as 78
  rodadas limpas, inclua esses três padrões no `grep -v`.
- `P=sintonize-fa494` e `Authorization: Bearer owner` só valem para o Firebase
  Emulator Suite: `owner` é o token administrativo do emulador local, não uma
  credencial.
