# FASE2-UNIT-ZS-03_validateNumero — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-ZS-03 |
| **Função testada** | `Validators.validateNumero` |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das 18 rodadas do piloto e das 4 reexecuções, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-03 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable), Dart 3.11.5 |
| **Arquivo de teste** | `test/fase2/unit/validate_numero_zs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT, mesmo padrão das rodadas anteriores — não pelo autor manualmente no teclado |

**Verificação pré-rodada (procedimento adotado após o incidente do U-SILENT):**
`validateNumero` não é alvo de nenhum bug plantado, e o prompt pronto contém o
corpo verbatim da função em `lib/utils/validators.dart`.

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/zero-shot/FASE2-UNIT-ZS-03_validateNumero.md`:
código isolado da função (sem docstring), template zero-shot idêntico ao usado
na Fase 1 (`prompts/PROMPT_TEMPLATE_UNIT.md`).

```dart
  static String? validateNumero(String? value) {
    if (value == null || value.isEmpty) {
      return 'O número é obrigatório';
    }
    if (int.tryParse(value) == null) {
      return 'O número deve ser numérico';
    }
    return null;
  }
```

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

O modelo gerou 14 testes em 4 grupos (`quando o valor é obrigatório`,
`quando o valor não é numérico`, `quando o valor é numérico`, `casos de borda`).
Cobertura ampla, incluindo zero, negativo, `9223372036854775807` (maior inteiro
do Dart), zeros à esquerda e sinal isolado (`'-'`).

Ao final da resposta o modelo destacou espontaneamente uma característica da
implementação:

> Esses testes também verificam um detalhe importante da implementação: decimais como '10.5' são considerados inválidos, porque a função usa int.tryParse(), e não double.tryParse().

Essa observação está correta. Porém o modelo errou uma **outra** propriedade de
`int.tryParse` na mesma resposta — ver iteração 1.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 14 |
| **Testes passaram (1ª execução)** | 13 |
| **Testes falharam (1ª execução)** | 1 |
| **Testes passaram (pós-repair)** | 15 |
| **Testes falharam (pós-repair)** | 0 |

### Saída do terminal (iteração 0 — 13/14)

```
00:00 +5 -1: Validators.validateNumero quando o valor não é numérico deve retornar erro para valor contendo espaços [E]
  Expected: 'O número deve ser numérico'
    Actual: <null>
     Which: not an <Instance of 'String'>
...
00:00 +13 -1: Some tests failed.
```

(saída completa em `fase2/resultados/unit/zero-shot/FASE2-UNIT-ZS-03_validateNumero_iter0.txt`)

### Saída do terminal (iteração 1 — final, 15/15)

```
00:00 +15: All tests passed!
```

(saída completa em `fase2/resultados/unit/zero-shot/FASE2-UNIT-ZS-03_validateNumero_iter1_final.txt`)

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** o teste `'deve retornar erro para valor contendo espaços'`
  esperava mensagem de erro para `'123 '`, mas `int.tryParse` no Dart tolera
  espaços em branco ao redor do número — `int.tryParse('123 ')` devolve `123`,
  logo a função retorna `null` (válido). A expectativa presumia uma regra mais
  restritiva do que a implementação especifica.
- **Prompt de reparo enviado:** saída de erro completa colada, seguindo o
  template padrão de reparo (verbatim, conforme o arquivo do prompt).
- **★ Autoclassificação do modelo:** **(A)** — declarada explicitamente na
  primeira linha da resposta: *"Classificação: (A) — o teste presume um
  comportamento que não é o especificado."* O modelo explicou corretamente que
  `int.tryParse('123 ')` retorna `123`, converteu o teste em um caso de sucesso
  (`'deve retornar null para número com espaço no final'`) e **preservou**
  o teste de `'   '` (apenas espaços), que continua inválido — distinção
  correta entre os dois casos.
- **Resultado após correção:** 15/15 passaram (o total subiu de 14 para 15
  porque o modelo separou o caso de espaços em dois testes distintos).

### Iteração 2

- **Necessária?** Não (repair concluído na iteração 1).

### Iteração 3

- **Necessária?** Não.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) na iteração 1 — correta |
| **★ Classificação humana (auditoria)** | Erro de teste (expectativa incorreta sobre o comportamento de `int.tryParse` com espaços ao redor) |
| **★ Concordância** | Sim |
| **★ Observações** | Ver abaixo. |

### Observações

1. **Padrão que se repete com a rodada 1 (`validateNome`):** nas duas, a única
   falha veio de uma **presunção equivocada sobre a semântica de uma API padrão
   do Dart** — `\s` em `RegExp` incluindo `\t`/`\n` na ZS-01, e `int.tryParse`
   tolerando espaços ao redor nesta. Em ambos os casos a autoclassificação foi
   (A), correta, e o reparo saiu em uma única iteração. É um tipo de erro
   distinto dos erros de API de teste do Flutter observados no bloco W-SILENT
   do piloto: aqui não é desconhecimento da biblioteca de testes, e sim da
   biblioteca padrão da linguagem.

2. **Conhecimento assimétrico sobre a mesma função.** Na mesma resposta inicial
   o modelo acertou uma sutileza de `int.tryParse` (rejeita `'10.5'` porque não
   é `double.tryParse`) e errou outra (aceita espaços ao redor). Sugere
   cobertura irregular do comportamento da API, não ignorância geral sobre ela.

3. **Recusa correta de enfraquecer a asserção.** Ao encerrar a resposta de
   reparo, o modelo delimitou o escopo da correção sem que isso fosse pedido:
   observou que, *se* a regra de negócio do Sintonize proibisse espaços, a
   correção correta seria na aplicação e não no teste — *"não deveríamos
   alterar o teste para esconder o problema"*. É o comportamento que a
   instrução de reparo revisada busca induzir, aqui aplicado espontaneamente a
   um caso classificado como (A).

---

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
