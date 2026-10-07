# Cobertura de linhas — Fase 2 (rodadas limpas, ChatGPT e Gemini)

Medição de 2026-10-07, sobre o `lib/` limpo (`ccae44a`, idêntico ao de `fase3-e2e`),
com `flutter test --coverage <arquivo>` executado **um arquivo por vez** sobre o
teste final arquivado de cada rodada limpa (`test/fase2/**` para o ChatGPT,
`test/fase2-gemini/**` para o Gemini). Flutter 3.41.6. Nenhum arquivo de teste
ou de `lib/` foi alterado. Dados brutos em `cobertura.csv` (uma linha por
arquivo de `lib/` carregado pelo teste, mais uma linha `TOTAL` por rodada).

**Escopo:** 78 rodadas limpas, 75 medidas. Excluídas as
rodadas de bug plantado (`ucrash`, `usilent`, `wcrash`), as 3 de `formatName`
(não é alvo limpo, defeito real pré-existente) e os dois arquivos
`validate_senha_zs_*` (fora de escopo / bug ativo). Por modelo: 21 unit
(7 funções × 3 estratégias), 9 widget, 9 integration = 39; total 78.

**Como ler `linhas_total`.** O lcov só lista os arquivos de `lib/` que o teste
carregou. Um teste unitário carrega só `validators.dart` (46 linhas
instrumentadas); um teste de widget ou de integração que importa `main.dart`
carrega o app inteiro (1657 linhas). Por isso a soma de `linhas_total` entre
rodadas não é comparável entre níveis, e o resumo traz duas leituras:
a **média do % por rodada** (cada rodada sobre o seu próprio denominador) e a
**união da célula** (linhas cobertas por pelo menos uma rodada da célula,
sobre todas as linhas instrumentadas em qualquer rodada da célula).

## Resumo por nível × estratégia × modelo

| nível | estratégia | modelo | rodadas medidas | média % por rodada | união: linhas cobertas | união: linhas total | união % |
|---|---|---|---|---|---|---|---|
| integration | COT | ChatGPT | 3 | 9.8 | 465 | 1657 | 28.1 |
| integration | COT | Gemini | 2 | 57.4 | 425 | 1657 | 25.6 |
| integration | FS | ChatGPT | 3 | 7.9 | 371 | 1657 | 22.4 |
| integration | FS | Gemini | 3 | 28.9 | 102 | 1657 | 6.2 |
| integration | ZS | ChatGPT | 3 | 9.3 | 440 | 1657 | 26.6 |
| integration | ZS | Gemini | 2 | 43.0 | 92 | 296 | 31.1 |
| unit | COT | ChatGPT | 7 | 9.9 | 32 | 46 | 69.6 |
| unit | COT | Gemini | 7 | 9.9 | 32 | 46 | 69.6 |
| unit | FS | ChatGPT | 7 | 9.9 | 32 | 46 | 69.6 |
| unit | FS | Gemini | 7 | 9.9 | 32 | 46 | 69.6 |
| unit | ZS | ChatGPT | 7 | 9.9 | 32 | 46 | 69.6 |
| unit | ZS | Gemini | 7 | 9.9 | 32 | 46 | 69.6 |
| widget | COT | ChatGPT | 2 | 10.9 | 351 | 1657 | 21.2 |
| widget | COT | Gemini | 3 | 12.7 | 476 | 1657 | 28.7 |
| widget | FS | ChatGPT | 3 | 11.7 | 429 | 1657 | 25.9 |
| widget | FS | Gemini | 3 | 12.3 | 500 | 1657 | 30.2 |
| widget | ZS | ChatGPT | 3 | 12.8 | 481 | 1657 | 29.0 |
| widget | ZS | Gemini | 3 | 11.8 | 436 | 1657 | 26.3 |

## Rodadas em que a cobertura não pôde ser medida (3)

| Arquivo | Modelo | Motivo |
|---|---|---|
| `test/fase2-gemini/integration/cadastro_flow_zs_test.dart` | Gemini | não compila: `Method not found: 'setupFirebaseCoreMocks'` (linha 29) |
| `test/fase2-gemini/integration/login_flow_cot_test.dart` | Gemini | não carrega: `Binding has not yet been initialized` ao carregar o arquivo (reproduzido em 2 execuções); o coletor de cobertura perde o VM service |
| `test/fase2/widget/cadastro_screen_cot_test.dart` | ChatGPT | não compila: `FakeHttpClient` não implementa membros de `HttpClient`; `FakeHttpHeaders.add` com assinatura divergente (linhas 1586, 1705) |

Por isso as células integration×ZS×Gemini, integration×COT×Gemini e
widget×COT×ChatGPT têm 2 rodadas medidas em vez de 3.

## Observações

- Cobertura foi coletada **independentemente de o teste passar**: 56 arquivos
  passaram e 22 tiveram ao menos um teste falhando nesta execução. O resultado
  pass/fail de cada rodada é o do doc da rodada, não o desta medição (outra
  máquina, outra data); aqui ele só indica que o arquivo executou.
- Uma execução (Gemini INT playlist COT) travou na coleta (`Service has
  disappeared`) e foi reexecutada com sucesso; o loop passou a usar timeout
  de 240 s por arquivo.
- Tempo total do loop: 592 s para os 75 arquivos medidos (≈ 8 s por teste
  unitário, 8–21 s por widget/integration), mais ≈ 60 s da reexecução.
