# analise/ — Documentação de Análise

Esta pasta contém a análise quantitativa do experimento TCC Sintonize.

---

## Arquivo principal: `dados_consolidados.md`

Centraliza os dados numéricos de todas as **48 rodadas** do experimento (30 unitárias + 9 widget + 9 integração), organizados em 6 seções:

| Seção | Conteúdo |
|---|---|
| 1. Testes Unitários | Tabela com 30 linhas (uma por rodada), resumo por estratégia |
| 2. Testes de Widget | Tabela com 9 linhas, resumo por estratégia |
| 3. Testes de Integração | Tabela com 9 linhas, resumo por estratégia |
| 4. Visão Geral | Tabela cruzada nível × estratégia + consolidado global |
| 5. Achados Principais | Interpretação qualitativa dos dados (5 achados) |
| 6. Notas Metodológicas | Desvios de protocolo e convenções de contagem |

---

## Definição das métricas

| Coluna | Definição |
|---|---|
| **Gerados** | Número de casos de teste (`test()` ou `testWidgets()`) no arquivo final entregue pelo LLM após todas as iterações |
| **Pass(1ª)** | Testes que passaram na execução da geração inicial, sem nenhuma iteração de reparo |
| **Fail(1ª)** | Testes que falharam na 1ª execução |
| **Pass(final)** | Testes que passaram após todas as iterações (≤ 3) de reparo |
| **Fail(final)** | Testes que permaneceram falhando após o limite de 3 iterações |
| **Taxa final** | `Pass(final) / Gerados` — percentual de aprovação ao encerrar a rodada |
| **Iterações** | Número de rodadas de repair executadas (0 = passou de primeira; máx. 3) |
| **Compilou(1ª)** | Se o código gerado inicialmente compilou sem erros de sintaxe/tipo |

---

## Composição dos agregados

### Nível unitário (30 rodadas)

| Estratégia | Rodadas |
|---|---|
| ZS | UNIT-ZS-01 a UNIT-ZS-10 (10 funções) |
| FS | UNIT-FS-01 a UNIT-FS-10 (10 funções) |
| COT | UNIT-COT-01 a UNIT-COT-10 (10 funções) |

Funções testadas: `validateNome`, `validateSenha`, `validateNumero`, `validateCEP`, `validateEmail`, `validateEmailLogin`, `validateEmailEdit`, `formatName`, `capitalize`, `validateDate` — todas definidas em `lib/utils/validators.dart`.

### Nível widget (9 rodadas)

| Estratégia | Rodadas |
|---|---|
| ZS | WIDGET-ZS-01 (LoginScreen), WIDGET-ZS-02 (CriarPlaylistScreen), WIDGET-ZS-03 (CadastroScreen) |
| FS | WIDGET-FS-01, WIDGET-FS-02, WIDGET-FS-03 (mesmos widgets) |
| COT | WIDGET-COT-01, WIDGET-COT-02, WIDGET-COT-03 (mesmos widgets) |

Nota: WIDGET-COT-03 foi executado com GPT-4o (desvio de protocolo documentado).

### Nível integração (9 rodadas)

| Estratégia | Rodadas |
|---|---|
| ZS | INT-ZS-01 (Login), INT-ZS-02 (Cadastro), INT-ZS-03 (Playlist) |
| FS | INT-FS-01 (Login), INT-FS-02 (Cadastro), INT-FS-03 (Playlist) |
| COT | INT-COT-01 (Login), INT-COT-02 (Cadastro), INT-COT-03 (Playlist) |

---

## Como verificar os dados

Cada linha do `dados_consolidados.md` pode ser rastreada até:
- **Doc da rodada:** `prompts/{unit,widget,integration}/{zero-shot,few-shot,cot}/ID_nome.md` — contém o prompt exato, resposta do LLM e resultado da execução
- **Arquivo de teste:** `test/{unit,widget,integration}/funcao_{zs,fs,cot}_test.dart`
- **Saída do terminal:** `results/{unit,widget,integration}/{zero-shot,few-shot,cot}/ID.txt`

A tabela de rastreabilidade completa está em `prompts/README.md`.

---

## Convenções de contagem

- **Integração — "Testes gerados (final)":** para ZS e FS com repair loop, o LLM por vezes gerou mais ou menos testes do que na tentativa inicial. A coluna `Gerados` registra a contagem **final** (arquivo de teste entregue ao término da rodada).
- **Widget — iterações overcounted:** a convenção "### Iteração N — Não necessária" não conta como iteração realizada. Os valores de iteração nos docs refletem apenas iterações efetivamente executadas.
- **Unitário:** todos terminaram com 0 falhas finais — a variação entre estratégias está na quantidade de testes gerados e no número de iterações de reparo necessárias.
