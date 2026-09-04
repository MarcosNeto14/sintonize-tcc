# FASE2-UNIT-FS-05_validateEmail — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-FS-05 |
| **Função testada** | `Validators.validateEmail` (regex estrita, obrigatório — origem `cadastro.dart`) |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das demais rodadas da Fase 2, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-04 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/unit/validate_email_fs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `validateEmail` não é alvo de nenhum bug
plantado da Fase 2.

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/few-shot/FASE2-UNIT-FS-05_validateEmail.md`
— mesmos dois exemplos padrão seguidos do corpo verbatim de `validateEmail`.

```dart
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O e-mail é obrigatório';
    }
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }
```

---

## Resposta do LLM

Gerou 9 testes em um único grupo `validateEmail`: null, vazio, e-mail
válido, e-mail com caracteres especiais permitidos (`.`, `+`) no usuário,
e cinco variações de rejeição (sem `@`, sem domínio, sem extensão, extensão
de um único caractere, caractere `#` inválido). Boa cobertura dos limites
da regex, incluindo o caso de fronteira `{2,}` (extensão de 1 caractere
rejeitada) sem que isso tenha sido pedido explicitamente.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 9 |
| **Testes passaram (1ª execução)** | 9 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (repair não foi necessário) |
| **Testes falharam (pós-repair)** | — |

### Saída do terminal (iteração 0 — final, 9/9)

```
00:00 +9: All tests passed!
```

(saída completa em `fase2/resultados/unit/few-shot/FASE2-UNIT-FS-05_validateEmail_iter0_final.txt`)

---

## Iterative Repair Loop

Não houve. A suíte passou 9/9 na primeira execução.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | N/A — nenhum comportamento divergente para classificar |
| **★ Classificação humana (auditoria)** | N/A |
| **★ Concordância** | N/A (repair não foi necessário e não há bug a capturar) |
| **★ Observações** | Maior suíte few-shot até aqui nesta rodada de estratégia (9 testes) — a regex de `validateEmail` tem mais ramos exploráveis que as funções anteriores. |

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
