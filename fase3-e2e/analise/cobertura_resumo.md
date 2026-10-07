# Cobertura de linhas — Fase 3 (rodadas limpas E2E, ChatGPT e Gemini)

Medição de 2026-10-07, sobre o `lib/` limpo (`ccae44a`), no worktree de build
`Desktop\sintonize-fase3` (`dc88352`, `lib/` idêntico), AVD `tcc_e2e` (API 34) +
Firebase Emulator Suite (Auth 9099, Firestore 8080). Para cada uma das 18
rodadas limpas (`integration_test/fase3/{chatgpt,gemini}/{login,cadastro,playlist}_{zs,fs,cot}_test.dart`,
o arquivo final arquivado de cada rodada): emuladores Firebase derrubados e
subidos vazios, `seed_test` executado e conferido por REST (1 conta / 1
`usuarios` / 5 `musica`, bloqueante), depois
`flutter test --coverage <arquivo> -d emulator-5554`, um arquivo por comando.
O arquivo foi copiado para `integration_test/fase3/` do worktree só durante a
execução (mesma profundidade usada nas rodadas, para o `import
'../firebase_test_helper.dart'`) e apagado em seguida. Flutter 3.41.6.
Nenhum arquivo de teste ou de `lib/` foi alterado. Dados brutos em
`cobertura.csv` (uma linha por arquivo de `lib/` carregado, mais `TOTAL` por
rodada).

**Como ler.** Todos os 18 testes importam `main.dart`, então o denominador é
sempre o app inteiro (1657 linhas instrumentadas) e os totais são
comparáveis entre rodadas. A cobertura é a da **execução desta medição**: um
teste que falha cedo cobre menos do que o mesmo teste quando passa, e o
resultado pass/fail abaixo não substitui o do doc da rodada (outra data; a
regra de não determinismo do README (b) se aplica).

## Resumo por estratégia × modelo (nível único: e2e)

| nível | estratégia | modelo | rodadas medidas | média % por rodada | união: linhas cobertas | união: linhas total | união % |
|---|---|---|---|---|---|---|---|
| e2e | COT | ChatGPT | 3 | 17.8 | 645 | 1657 | 38.9 |
| e2e | COT | Gemini | 3 | 20.3 | 679 | 1657 | 41.0 |
| e2e | FS | ChatGPT | 3 | 11.1 | 405 | 1657 | 24.4 |
| e2e | FS | Gemini | 3 | 18.8 | 668 | 1657 | 40.3 |
| e2e | ZS | ChatGPT | 3 | 10.0 | 350 | 1657 | 21.1 |
| e2e | ZS | Gemini | 3 | 18.7 | 669 | 1657 | 40.4 |

## Por rodada

| Rodada | Modelo | Tempo | Resultado nesta execução |
|---|---|---|---|
| FASE3-E2E-ZS-01_loginFlow | ChatGPT | 106 s | 7 passou / 2 falhou |
| FASE3-E2E-FS-01_loginFlow | ChatGPT | 89 s | 1 passou / 1 falhou |
| FASE3-E2E-COT-01_loginFlow | ChatGPT | 80 s | 5 passou / 3 falhou |
| FASE3-E2E-ZS-02_cadastroFlow | ChatGPT | 78 s | 2 passou / 3 falhou |
| FASE3-E2E-FS-02_cadastroFlow | ChatGPT | 64 s | 0 passou / 1 falhou |
| FASE3-E2E-COT-02_cadastroFlow | ChatGPT | 91 s | 9 passou / 2 falhou |
| FASE3-E2E-ZS-03_playlistFlow | ChatGPT | 51 s | 0 passou / 2 falhou |
| FASE3-E2E-FS-03_playlistFlow | ChatGPT | 55 s | 0 passou / 1 falhou |
| FASE3-E2E-COT-03_playlistFlow | ChatGPT | 68 s | 0 passou / 4 falhou |
| FASE3-E2E-ZS-01_loginFlow | Gemini | 69 s | 4 passou / 1 falhou |
| FASE3-E2E-FS-01_loginFlow | Gemini | 61 s | 2 passou / 0 falhou |
| FASE3-E2E-COT-01_loginFlow | Gemini | 64 s | 4 passou / 1 falhou |
| FASE3-E2E-ZS-02_cadastroFlow | Gemini | 88 s | 4 passou / 0 falhou |
| FASE3-E2E-FS-02_cadastroFlow | Gemini | 66 s | 1 passou / 0 falhou |
| FASE3-E2E-COT-02_cadastroFlow | Gemini | 81 s | 2 passou / 2 falhou |
| FASE3-E2E-ZS-03_playlistFlow | Gemini | 56 s | 1 passou / 1 falhou |
| FASE3-E2E-FS-03_playlistFlow | Gemini | 61 s | 1 passou / 0 falhou |
| FASE3-E2E-COT-03_playlistFlow | Gemini | 68 s | 2 passou / 2 falhou |

## Rodadas em que a cobertura não pôde ser medida

Nenhuma: os 18 arquivos compilaram e geraram `lcov.info`.

## Repetição da medição — playlist × ChatGPT (2026-10-07, mesma tarde)

Os três arquivos de playlist do ChatGPT tiveram 0 testes passando na
medição. Cada um foi medido **uma segunda vez**, nas mesmas condições
(emuladores Firebase reiniciados vazios, seed 1/1/5 conferido por REST, AVD
sem outros processos de build). É repetição de medição, não rodada: nenhum doc
de rodada muda. Regra aplicada: se a repetição passasse, o `cobertura.csv`
usaria a repetição; nenhuma passou, então o CSV mantém a 1ª medição.

| Rodada | 1ª medição: pass/fail | 1ª: linhas cobertas | 2ª medição: pass/fail | 2ª: linhas cobertas | Estado |
|---|---|---|---|---|---|
| FASE3-E2E-ZS-03_playlistFlow (ChatGPT) | 0 / 2 | 107 / 1657 | 1 / 1 | 384 / 1657 | **instável** — pass/fail e cobertura divergem |
| FASE3-E2E-FS-03_playlistFlow (ChatGPT) | 0 / 1 | 106 / 1657 | 0 / 1 | 106 / 1657 | estável |
| FASE3-E2E-COT-03_playlistFlow (ChatGPT) | 0 / 4 | 380 / 1657 | 0 / 4 | 379 / 1657 | estável (−1 linha, mesmo caminho) |

Na ZS-03, o teste que passou na 2ª medição percorreu a tela de playlist
(384 linhas, próximo das 408 da ZS-03 do Gemini); na 1ª os dois testes caíram
antes. Isso confirma o caveat acima: a cobertura desta tabela é a da execução
que a produziu. A média da célula playlist×ZS×ChatGPT e a união da célula
ZS×ChatGPT no resumo seguem calculadas com a 1ª medição (107). A repetição do
FS exigiu dois seeds: o primeiro falhou no emulador Auth
(`[firebase_auth/unknown] unexpected end of stream`, com 0,5 GB livres) e
foi refeito. Tempo da repetição: 615 s + 204 s.

## Observações

- Tempo total: 2300 s para 16 arquivos no loop final + 195 s para os 2
  primeiros (≈ 42 min de medição, 51–106 s por arquivo, incluindo seed e
  reinício dos emuladores; o primeiro inclui o build Gradle). Duas tentativas
  anteriores foram interrompidas por falta de memória da máquina
  (Claude Code encerrou o processo com < 1 GB livre) e uma delas ficou viva
  em paralelo com a retomada, o que fez 2 seeds falharem e 1 coleta perder o
  diretório temporário; essas 3 execuções foram descartadas e refeitas com um
  único loop.
- Os totais por rodada idênticos entre modelos (login ZS 160, login FS 168,
  cadastro COT 391) são coincidência de caminho percorrido, não de arquivo:
  os testes são diferentes.
