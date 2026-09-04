# FASE2-UNIT-FS-01_validateNome — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-FS-01 |
| **Função testada** | `Validators.validateNome` — `lib/utils/validators.dart` |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das demais rodadas da Fase 2, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-04 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/unit/validate_nome_fs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `validateNome` não é alvo de nenhum bug plantado
da Fase 2. Primeira função da estratégia few-shot no escopo revisado de 8
funções.

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/few-shot/FASE2-UNIT-FS-01_validateNome.md`
— dois exemplos de testes bem escritos (`validateCampoObrigatorio`,
`validateTelefone`) seguidos do corpo verbatim de `validateNome`.

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

Gerou 6 testes em um único grupo `validateNome`, seguindo de perto a
estrutura dos dois exemplos fornecidos (obrigatoriedade + regex). Cobriu
null, vazio, nome válido com espaço, nome com acento (`José Antônio`),
nome com números e nome com caractere especial (`@`). Não explorou casos de
borda adicionais (ex.: espaços múltiplos, apenas espaços) além dos
espelhados nos exemplos — consistente com o estilo few-shot, que tende a
ancorar na cobertura dos exemplos em vez de expandir.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 6 |
| **Testes passaram (1ª execução)** | 6 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (repair não foi necessário) |
| **Testes falharam (pós-repair)** | — |

### Saída do terminal (iteração 0 — final, 6/6)

```
00:00 +6: All tests passed!
```

(saída completa em `fase2/resultados/unit/few-shot/FASE2-UNIT-FS-01_validateNome_iter0_final.txt`)

---

## Iterative Repair Loop

Não houve. A suíte passou 6/6 na primeira execução.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | N/A — nenhum comportamento divergente para classificar |
| **★ Classificação humana (auditoria)** | N/A |
| **★ Concordância** | N/A (repair não foi necessário e não há bug a capturar) |
| **★ Observações** | Suíte mais enxuta que a equivalente zero-shot (6 vs. 19 testes em `FASE2-UNIT-ZS-01`), coerente com o padrão few-shot de ancorar na cobertura dos exemplos fornecidos em vez de explorar bordas adicionais. |

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
