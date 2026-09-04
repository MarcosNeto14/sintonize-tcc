# FASE2-UNIT-FS-03_validateNumero — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-FS-03 |
| **Função testada** | `Validators.validateNumero` — `lib/utils/validators.dart` |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das demais rodadas da Fase 2, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-04 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/unit/validate_numero_fs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `validateNumero` não é alvo de nenhum bug
plantado da Fase 2.

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/few-shot/FASE2-UNIT-FS-03_validateNumero.md`
— mesmos dois exemplos padrão seguidos do corpo verbatim de `validateNumero`.

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

Gerou 4 testes em um único grupo `validateNumero`: null, vazio, valor não
numérico (`'abc'`) e valor numérico válido (`'123'`). Cobertura mínima e
direta — não explorou casos de borda além dos três ramos explícitos da
função (ex.: números negativos, decimais, ou strings com espaços), embora
esses casos sejam relevantes por não estarem exemplificados nos exemplos
few-shot fornecidos.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 4 |
| **Testes passaram (1ª execução)** | 4 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (repair não foi necessário) |
| **Testes falharam (pós-repair)** | — |

### Saída do terminal (iteração 0 — final, 4/4)

```
00:00 +4: All tests passed!
```

(saída completa em `fase2/resultados/unit/few-shot/FASE2-UNIT-FS-03_validateNumero_iter0_final.txt`)

---

## Iterative Repair Loop

Não houve. A suíte passou 4/4 na primeira execução.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | N/A — nenhum comportamento divergente para classificar |
| **★ Classificação humana (auditoria)** | N/A |
| **★ Concordância** | N/A (repair não foi necessário e não há bug a capturar) |
| **★ Observações** | Suíte mais enxuta da rodada até aqui em few-shot (4 testes) — a função tem só 3 ramos e o modelo não extrapolou além deles (ex.: não testou `'-5'`, `'3.5'` ou `' 5 '`, que também são casos relevantes de `int.tryParse`). |

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
