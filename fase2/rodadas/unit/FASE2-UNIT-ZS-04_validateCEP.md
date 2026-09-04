# FASE2-UNIT-ZS-04_validateCEP — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-ZS-04 |
| **Função testada** | `Validators.validateCEP` |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das 18 rodadas do piloto e das 4 reexecuções, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-03 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable), Dart 3.11.5 |
| **Arquivo de teste** | `test/fase2/unit/validate_cep_zs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT, mesmo padrão das rodadas anteriores — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `validateCEP` não é alvo de nenhum bug plantado, e
o prompt pronto contém o corpo verbatim da função em `lib/utils/validators.dart`.

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/zero-shot/FASE2-UNIT-ZS-04_validateCEP.md`:
código isolado da função (sem docstring), template zero-shot idêntico ao usado
na Fase 1 (`prompts/PROMPT_TEMPLATE_UNIT.md`).

```dart
  static String? validateCEP(String? value) {
    if (value == null || value.isEmpty) {
      return 'O CEP é obrigatório';
    }
    if (value.length != 9 || !RegExp(r'^\d{5}-\d{3}$').hasMatch(value)) {
      return 'CEP inválido. Formato correto: XXXXX-XXX';
    }
    return null;
  }
```

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

O modelo gerou 16 testes em 3 grupos (`sucesso`, `falha`, `casos de borda`).
Cobertura da estrutura do formato: ausência de hífen, hífen em posição errada,
hífen duplicado, letra no meio dos dígitos, espaço, um caractere a menos, um a
mais, e quebra de linha ao final.

O modelo comentou ao final da resposta:

> Os casos de borda também verificam explicitamente o limite de 9 caracteres e caracteres que podem parecer válidos, mas não satisfazem a expressão regular.

Um dos testes de borda materializa a checagem de comprimento antes de chamar a
função, assertando `cep.length` diretamente:

```dart
test('deve aceitar exatamente 9 caracteres no formato correto', () {
  const cep = '12345-678';

  expect(cep.length, 9);
  expect(Validators.validateCEP(cep), isNull);
});
```

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 16 |
| **Testes passaram (1ª execução)** | 16 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (repair não foi necessário) |
| **Testes falharam (pós-repair)** | — |

### Saída do terminal (iteração 0 — final, 16/16)

```
00:00 +16: All tests passed!
```

(saída completa em `fase2/resultados/unit/zero-shot/FASE2-UNIT-ZS-04_validateCEP_iter0_final.txt`)

---

## Iterative Repair Loop

### Iteração 1

- **Necessária?** Não. A suíte passou 16/16 na primeira execução; nenhum prompt de reparo foi enviado e nenhuma autoclassificação (A)/(B) foi solicitada ao modelo.

### Iteração 2

- **Necessária?** Não.

### Iteração 3

- **Necessária?** Não.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | Não declarada — não houve falha, portanto não houve ciclo de reparo em que o esquema (A)/(B) fosse solicitado. Não se aplica (C): não há bug nesta função. |
| **★ Classificação humana (auditoria)** | N/A — nenhuma falha a classificar |
| **★ Concordância** | N/A (repair não foi necessário e não havia bug a capturar) |
| **★ Observações** | Ver abaixo. |

### Observações

1. **Segunda rodada consecutiva com 100% sem reparo**, junto de ZS-02
   (`validateSenha`, hoje fora do escopo das 30). A quebra do padrão observado
   em ZS-01 e ZS-03 tem uma explicação plausível: `validateCEP` é a primeira
   função da série em que a **regex é totalmente explícita e ancorada**
   (`^\d{5}-\d{3}$`), sem classes de caractere de semântica ambígua. Não há
   `\s` (que derrubou ZS-01) nem uma função de parsing da biblioteca padrão com
   comportamento não-óbvio (`int.tryParse`, que derrubou ZS-03) — o contrato
   está inteiramente visível no próprio literal da regex.

2. **A dupla checagem da função foi respeitada.** A implementação valida
   `length != 9` **e** a regex, redundância que na prática é inócua (a regex
   ancorada já garante 9 caracteres). O modelo não comentou a redundância, mas
   também não escreveu nenhum teste que dependesse dela para passar.

3. **Um teste asserta uma propriedade do literal, não da função.** Em
   `'deve aceitar exatamente 9 caracteres no formato correto'`, a linha
   `expect(cep.length, 9)` verifica a constante do próprio teste, não o
   comportamento de `validateCEP`. É um assert tautológico — não invalida a
   rodada (o segundo `expect` do mesmo teste exercita a função de verdade), mas
   é um caso de teste que documenta a intenção em vez de testá-la. Vale como
   dado qualitativo sobre a forma dos testes gerados.

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
