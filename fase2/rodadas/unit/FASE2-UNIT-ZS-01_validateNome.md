# FASE2-UNIT-ZS-01_validateNome — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-ZS-01 |
| **Função testada** | `Validators.validateNome` |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das 18 rodadas do piloto e das 4 reexecuções, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-03 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable) |
| **Arquivo de teste** | `test/fase2/unit/validate_nome_zs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT, mesmo padrão das 18 rodadas do piloto e das 4 reexecuções — não pelo autor manualmente no teclado |

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/zero-shot/FASE2-UNIT-ZS-01_validateNome.md`: código isolado da função `validateNome` (sem docstring), template zero-shot idêntico ao usado na Fase 1 (`prompts/PROMPT_TEMPLATE_UNIT.md`).

```dart
  static String? validateNome(String? value) {
    if (value == null || value.isEmpty) {
      return 'O nome é obrigatório';
    }
    final hasInvalidCharacters = RegExp(r'[^a-zA-ZÀ-ÿ\s]').hasMatch(value);
    if (hasInvalidCharacters) {
      return 'O nome não pode conter números ou caracteres especiais';
    }
    return null;
  }
```

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

O modelo gerou 19 testes em 3 grupos (`Casos de sucesso`, `Casos de falha`, `Casos de borda`), incluindo dois testes de borda que assumiam — incorretamente — que a regex da função rejeitaria tabulação (`\t`) e quebra de linha (`\n`) como "caracteres especiais". O modelo já alertou espontaneamente, ao final da resposta, que `"apenas espaços"` retorna `null` pela implementação atual (`value.isEmpty` sem `trim()`), e registrou esse comportamento no teste correspondente em vez de presumir que deveria ser inválido.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 19 |
| **Testes passaram (1ª execução)** | 17 |
| **Testes falharam (1ª execução)** | 2 |
| **Testes passaram (pós-repair)** | 19 |
| **Testes falharam (pós-repair)** | 0 |

### Saída do terminal (iteração 0 — 17/19)

```
00:00 +14: Validators.validateNome Casos de borda deve rejeitar nome contendo tabulação
00:00 +14 -1: Validators.validateNome Casos de borda deve rejeitar nome contendo tabulação [E]
  Expected: 'O nome não pode conter números ou caracteres especiais'
    Actual: <null>
     Which: not an <Instance of 'String'>
...
00:00 +14 -2: Validators.validateNome Casos de borda deve rejeitar nome contendo quebra de linha [E]
  Expected: 'O nome não pode conter números ou caracteres especiais'
    Actual: <null>
     Which: not an <Instance of 'String'>
...
00:00 +17 -2: Some tests failed.
```

(saída completa em `fase2/resultados/unit/zero-shot/FASE2-UNIT-ZS-01_validateNome_iter0.txt`)

### Saída do terminal (iteração 1 — final, 19/19)

```
00:00 +19: All tests passed!
```

(saída completa em `fase2/resultados/unit/zero-shot/FASE2-UNIT-ZS-01_validateNome_iter1_final.txt`)

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** os dois testes de borda `'deve rejeitar nome contendo tabulação'` e `'deve rejeitar nome contendo quebra de linha'` esperavam mensagem de erro, mas `RegExp(r'[^a-zA-ZÀ-ÿ\s]')` usa `\s`, que casa qualquer espaço em branco (inclui `\t` e `\n`) — logo a função retorna `null` (válido) para essas entradas, e o teste presumia uma regra mais restritiva do que a implementação realmente especifica.
- **Prompt de reparo enviado:** saída de erro completa colada, seguindo o template padrão de reparo (verbatim, conforme `fase2/prompts_prontos/unit/zero-shot/FASE2-UNIT-ZS-01_validateNome.md`).
- **Resposta do LLM:** classificou **(A)** — "o teste presume um comportamento que não é o especificado pela implementação fornecida"; explicou corretamente que `\s` inclui tabulação e quebra de linha; moveu os dois testes de `Casos de borda` para `Casos de sucesso`, invertendo a expectativa para `isNull`; manteve intacto o teste de `" "` (apenas espaços) já classificado corretamente na resposta inicial.
- **Resultado após correção:** 19/19 passaram.

### Iteração 2

- **Necessária?** Não (repair concluído na iteração 1).

### Iteração 3

- **Necessária?** Não.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) na iteração 1 — correta: os dois testes presumiam que `\s` na regex excluiria tabulação/quebra de linha, quando na verdade `\s` as inclui por definição |
| **★ Classificação humana (auditoria)** | Erro de teste (iteração 1 — expectativa incorreta sobre o comportamento de `\s` em `RegExp`) |
| **★ Concordância** | Sim |
| **★ Observações** | Rodada sem incidentes de infraestrutura (sem Firebase, sem widget, sem viewport) — a única falha foi uma presunção equivocada sobre semântica de regex, corrigida em 1 iteração. O modelo já havia sinalizado corretamente, na resposta inicial, o comportamento de `" "` (apenas espaços) sem que isso gerasse falha — não se qualifica como categoria (C), pois não há bug injetado nesta função; é apenas documentação correta de um comportamento legítimo e não-óbvio da implementação. |

**Referência de categorias (classificação humana — mesmas da Fase 1, + (C) da Fase 2):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
| Bug capturado sem necessidade de reparo (C) | O modelo já identificou e se ajustou ao bug real na geração inicial, sem falha nem ciclo de reparo |
