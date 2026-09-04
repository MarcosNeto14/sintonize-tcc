# FASE2-UNIT-COT-04_validateCEP — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-COT-04 |
| **Função testada** | `Validators.validateCEP` — `lib/utils/validators.dart` |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das demais rodadas da Fase 2, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-04 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/unit/validate_cep_cot_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `validateCEP` não é alvo de nenhum bug plantado
da Fase 2.

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/cot/FASE2-UNIT-COT-04_validateCEP.md`
— prompt estruturado em 3 passos (analisar, identificar cenários, escrever
testes).

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

Análise e lista de cenários exaustiva antes do código: 4 cenários de
sucesso, 12 de falha (subdivididos em "campo obrigatório" e "formato
inválido") e 5 casos de borda. Gerou 23 testes ao todo, incluindo dois
casos sofisticados que passaram corretamente de primeira:

- **Dígitos Unicode fullwidth** (`'１２３４５-６７８'`, caracteres
  U+FF10–FF19): o modelo previu corretamente que `\d` no Dart `RegExp`
  (sem flag Unicode) não reconhece esses caracteres como dígitos, logo o
  CEP é rejeitado — mesmo com `value.length == 9` (fullwidth digits são
  um único code unit UTF-16 cada).
- **Quebra de linha embutida** (`'12345-67\n'`, 9 caracteres): rejeitado
  corretamente, pois os 2 dígitos + `\n` no lugar dos 3 dígitos finais não
  casam com `\d{3}$`.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 23 |
| **Testes passaram (1ª execução)** | 23 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (repair não foi necessário) |
| **Testes falharam (pós-repair)** | — |

### Saída do terminal (iteração 0 — final, 23/23)

```
00:00 +23: All tests passed!
```

(saída completa em `fase2/resultados/unit/cot/FASE2-UNIT-COT-04_validateCEP_iter0_final.txt`)

---

## Iterative Repair Loop

Não houve. A suíte passou 23/23 na primeira execução.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | N/A — nenhum comportamento divergente para classificar |
| **★ Classificação humana (auditoria)** | N/A |
| **★ Concordância** | N/A (repair não foi necessário e não há bug a capturar) |
| **★ Observações** | Rodada mais robusta desta série CoT quanto a raciocínio sobre semântica de regex — acertou de primeira dois casos de borda genuinamente sutis (dígitos Unicode fullwidth fora de `\d` ASCII, e quebra de linha ocupando posição de dígito) que exigem entender como o motor de regex do Dart trata classes de caracteres, sem qualquer tentativa e erro. Contrasta com `FASE2-UNIT-COT-03_validateNumero`, onde o mesmo tipo de raciocínio sobre uma API padrão (`int.tryParse`) levou a uma presunção incorreta — sugerindo que a precisão do CoT sobre comportamento de bibliotecas/regex é inconsistente entre chamadas. |

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
