# FASE2-UNIT-ZS-07_validateEmailEdit — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-ZS-07 |
| **Função testada** | `Validators.validateEmailEdit` (variante estrita, opcional — origem `alterar-dados.dart`) |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das 18 rodadas do piloto e das 4 reexecuções, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-03 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable), Dart 3.11.5 |
| **Arquivo de teste** | `test/fase2/unit/validate_email_edit_zs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `validateEmailEdit` não é alvo de nenhum bug
plantado, e o prompt pronto contém o corpo verbatim da função em
`lib/utils/validators.dart`.

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/zero-shot/FASE2-UNIT-ZS-07_validateEmailEdit.md`:
código isolado da função (sem docstring), template zero-shot idêntico ao usado
na Fase 1.

```dart
  static String? validateEmailEdit(String? value) {
    if (value != null && value.isNotEmpty) {
      const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
      if (!RegExp(emailRegex).hasMatch(value)) {
        return 'Formato de e-mail inválido';
      }
    }
    return null;
  }
```

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

O modelo gerou 20 testes em 3 grupos (`sucesso`, `falha`, `casos de borda`) e
identificou corretamente, **já na resposta inicial e sem qualquer prompt de
reparo**, a característica que distingue esta função das outras duas variantes
de e-mail: o campo é **opcional**. Os dois primeiros testes de
`casos de borda` assertam:

```dart
test('deve retornar null para valor null', () {
  expect(Validators.validateEmailEdit(null), isNull);
});

test('deve retornar null para string vazia', () {
  expect(Validators.validateEmailEdit(''), isNull);
});
```

E a resposta encerra com:

> Esses testes cobrem null e string vazia (que, pela implementação atual, são considerados válidos), formatos válidos, formatos inválidos e diversos limites da expressão regular.

O restante da cobertura replica a mesma estrutura de `validateEmail` (ZS-05),
pois a regex é idêntica — subdomínio, hífen, TLD de 2 caracteres, múltiplos
`@`, espaços em várias posições — mais um caso não testado em ZS-05:
`'USUARIO@EXAMPLE.COM'` (letras maiúsculas), corretamente aceito.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 20 |
| **Testes passaram (1ª execução)** | 20 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (repair não foi necessário) |
| **Testes falharam (pós-repair)** | — |

### Saída do terminal (iteração 0 — final, 20/20)

```
00:00 +20: All tests passed!
```

(saída completa em `fase2/resultados/unit/zero-shot/FASE2-UNIT-ZS-07_validateEmailEdit_iter0_final.txt`)

---

## Iterative Repair Loop

### Iteração 1

- **Necessária?** Não. A suíte passou 20/20 na primeira execução; nenhum prompt de reparo foi enviado e nenhuma autoclassificação (A)/(B) foi solicitada ao modelo.

### Iteração 2

- **Necessária?** Não.

### Iteração 3

- **Necessária?** Não.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | Não declarada — não houve falha. Não se aplica (C): a opcionalidade do campo é um comportamento correto e documentado da função, não um bug. |
| **★ Classificação humana (auditoria)** | N/A — nenhuma falha a classificar |
| **★ Concordância** | N/A (repair não foi necessário) |
| **★ Observações** | Ver abaixo. |

### Observações

1. **Fecha o trio de comparação entre os três validadores de e-mail com um
   contraste limpo.** `validateEmail` (ZS-05, estrita+obrigatória, regex
   ancorada) → 25/25 de primeira. `validateEmailLogin` (ZS-06,
   permissiva+obrigatória, **sem** âncora `$`) → falhou nas duas direções.
   `validateEmailEdit` (ZS-07, estrita+opcional, mesma regex ancorada de ZS-05)
   → 20/20 de primeira. A variável que separa sucesso de falha nas 3 rodadas
   continua sendo a **presença da âncora `$`**, não a obrigatoriedade do campo
   — a opcionalidade foi tratada corretamente apesar de introduzir um ramo
   condicional (`if (value != null && value.isNotEmpty)`) que as outras duas
   funções não têm.

2. **Nenhuma contaminação entre os prompts das três rodadas.** Cada uma correu
   em conversa nova, sem histórico compartilhado, e ainda assim ZS-07
   reconheceu a opcionalidade unicamente a partir do `if` da função fornecida
   — não por ter visto ZS-05 ou ZS-06 antes (isso não é possível: conversas
   independentes). Confirma que a leitura do contrato, quando explícita no
   código, é feita de forma consistente entre execuções distintas.

3. **Docstring omitida de propósito, e o modelo não precisou dela.** O prompt
   não inclui a nota que documenta esta função como "variante opcional" nem a
   inconsistência entre as três — a opcionalidade foi inferida unicamente do
   corpo da função (`if (value != null && value.isNotEmpty)` antes de qualquer
   validação de formato), sem qualquer pista textual adicional.

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
