# FASE2-UNIT-ZS-05_validateEmail — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-ZS-05 |
| **Função testada** | `Validators.validateEmail` (variante estrita, obrigatória — origem `cadastro.dart`) |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das 18 rodadas do piloto e das 4 reexecuções, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-03 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable), Dart 3.11.5 |
| **Arquivo de teste** | `test/fase2/unit/validate_email_zs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT, mesmo padrão das rodadas anteriores — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `validateEmail` não é alvo de nenhum bug plantado, e
o prompt pronto contém o corpo verbatim da função em `lib/utils/validators.dart`.

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/zero-shot/FASE2-UNIT-ZS-05_validateEmail.md`:
código isolado da função (sem docstring — em particular, **sem** o parágrafo que
sinaliza a inconsistência entre os três validadores de e-mail do projeto),
template zero-shot idêntico ao usado na Fase 1.

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

### Mensagem inicial (geração dos testes)

O modelo gerou 25 testes em 3 grupos (`sucesso`, `falha`, `casos de borda`) — a
maior suíte produzida até aqui nas rodadas limpas. Adotou espontaneamente o
padrão **arrange/act/assert** com variável intermediária (`const email = ...;
final result = Validators.validateEmail(email); expect(result, ...)`), formato
que não havia usado em nenhuma rodada anterior desta série.

Cobertura entregue, alinhada aos elementos da regex:

- **Parte local:** dígitos, `.`, `+` (`nome.sobrenome+teste@example.com`).
- **Domínio:** subdomínio, hífen, TLD de 2 caracteres, TLD composto (`.com.br`).
- **Rejeições:** sem `@`, sem domínio, sem parte local, sem extensão, TLD de 1
  caractere, espaço interno/inicial/final, `@` duplicado, `usuario@.com`.
- **Acentuação:** `usuário@example.com` rejeitado — o modelo identificou que a
  classe `[a-zA-Z0-9._%+-]` não cobre caracteres acentuados.
- **Limite inferior:** `a@b.co` aceito, descrito como "o menor TLD permitido
  pelo padrão".

Encerrou observando:

> Esses testes verificam tanto o valor retornado quanto a mensagem específica de erro, além de exercitarem os principais limites definidos pela expressão regular.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 25 |
| **Testes passaram (1ª execução)** | 25 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (repair não foi necessário) |
| **Testes falharam (pós-repair)** | — |

### Saída do terminal (iteração 0 — final, 25/25)

```
00:00 +25: All tests passed!
```

(saída completa em `fase2/resultados/unit/zero-shot/FASE2-UNIT-ZS-05_validateEmail_iter0_final.txt`)

---

## Iterative Repair Loop

### Iteração 1

- **Necessária?** Não. A suíte passou 25/25 na primeira execução; nenhum prompt de reparo foi enviado e nenhuma autoclassificação (A)/(B) foi solicitada ao modelo.

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

1. **Reforça a hipótese levantada em ZS-04.** Segunda rodada consecutiva com
   100% sem reparo, e novamente sobre uma função cujo **contrato está
   inteiramente contido numa regex ancorada e explícita**. As duas rodadas que
   falharam (ZS-01, ZS-03) dependiam de semântica implícita de API padrão
   (`\s`; `int.tryParse`); as duas que passaram de primeira (ZS-04, ZS-05) têm
   o contrato visível no literal. A regex daqui é substancialmente mais
   complexa que a de `validateCEP` — e ainda assim não houve falha, o que
   sugere que o fator determinante é a **explicitude do contrato**, não o
   tamanho ou a complexidade da função.

2. **Nenhum teste "otimista" de e-mail.** Um erro comum ao gerar testes de
   validador de e-mail é assumir conformidade com RFC 5322 em vez da regex
   fornecida. O modelo não caiu nisso: rejeitou corretamente `usuário@...`
   (acentuação fora da classe de caracteres) e aceitou `a@b.co`, que uma
   heurística de "e-mail realista" provavelmente rejeitaria. As asserções
   seguiram a regex, não a noção geral de e-mail válido.

3. **Mudança de estilo não solicitada.** Esta foi a primeira rodada da série em
   que o modelo usou variável intermediária e separação arrange/act/assert, em
   vez de `expect(Validators.f(x), y)` em uma linha. Nada no prompt pediu isso
   — o template zero-shot é idêntico ao das rodadas anteriores. Variação de
   forma sem variação de instrução; vale como dado sobre a estabilidade do
   formato de saída entre conversas independentes.

4. **A inconsistência entre os três validadores de e-mail não foi comentada** —
   como esperado, já que o prompt isola a função e omite a docstring que a
   sinaliza. O ponto de comparação relevante virá da rodada ZS-06
   (`validateEmailLogin`, regex permissiva) e ZS-07 (`validateEmailEdit`,
   mesma regex estrita mas campo opcional).

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
