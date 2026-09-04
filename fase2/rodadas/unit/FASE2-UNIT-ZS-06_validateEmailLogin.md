# FASE2-UNIT-ZS-06_validateEmailLogin — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-ZS-06 |
| **Função testada** | `Validators.validateEmailLogin` (variante permissiva, obrigatória — origem `login.dart`) |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das 18 rodadas do piloto e das 4 reexecuções, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-03 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable), Dart 3.11.5 |
| **Arquivo de teste** | `test/fase2/unit/validate_email_login_zs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT, mesmo padrão das rodadas anteriores — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `validateEmailLogin` não é alvo de nenhum bug
plantado, e o prompt pronto contém o corpo verbatim da função em
`lib/utils/validators.dart`.

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/zero-shot/FASE2-UNIT-ZS-06_validateEmailLogin.md`:
código isolado da função (sem docstring, portanto sem qualquer menção às outras
duas variantes de validação de e-mail do projeto), template zero-shot idêntico
ao usado na Fase 1.

```dart
  static String? validateEmailLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu e-mail';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Por favor, insira um e-mail válido';
    }
    return null;
  }
```

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

O modelo gerou 16 testes em 3 grupos (`Casos de sucesso`, `Casos de falha`,
`Casos de borda`) e **percebeu, já na resposta inicial, que esta regex é mais
permissiva** que a de um validador de e-mail convencional — dedicando um grupo
inteiro a documentar essa permissividade e encerrando com:

> Observação importante: os casos em Casos de borda refletem exatamente o comportamento atual da regex, que é relativamente permissiva. Por exemplo, @email.com, usuario@.com e usuario@email. são considerados válidos pela implementação fornecida. [...] Se a intenção for que a validação rejeite esses casos, a própria RegExp precisará ser mais restritiva.

A intuição de que a regex é permissiva estava certa, mas **as três instâncias
citadas estavam erradas**: `[^@]+` exige *um ou mais* caracteres, então
`@email.com`, `usuario@.com` e `usuario@email.` são de fato **rejeitados**.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 16 |
| **Testes passaram (1ª execução)** | 12 |
| **Testes falharam (1ª execução)** | 4 |
| **Testes passaram (pós-repair)** | 17 |
| **Testes falharam (pós-repair)** | 0 |

### Saída do terminal (iteração 0 — 12/16)

```
00:00 +10 -1: ... deve retornar mensagem de e-mail inválido quando houver espaço [E]
  Expected: 'Por favor, insira um e-mail válido'
    Actual: <null>
00:00 +10 -2: ... Casos de borda deve aceitar e-mail com caracteres antes do @ [E]
  Expected: null
    Actual: 'Por favor, insira um e-mail válido'
00:00 +10 -3: ... Casos de borda deve aceitar e-mail com caracteres depois do @ e do ponto [E]
  Expected: null
    Actual: 'Por favor, insira um e-mail válido'
00:00 +10 -4: ... Casos de borda deve aceitar e-mail que termina com ponto [E]
  Expected: null
    Actual: 'Por favor, insira um e-mail válido'
00:00 +12 -4: Some tests failed.
```

(saída completa em `fase2/resultados/unit/zero-shot/FASE2-UNIT-ZS-06_validateEmailLogin_iter0.txt`)

### Saída do terminal (iteração 1 — final, 17/17)

```
00:00 +17: All tests passed!
```

(saída completa em `fase2/resultados/unit/zero-shot/FASE2-UNIT-ZS-06_validateEmailLogin_iter1_final.txt`)

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** 4 falhas, em **duas direções opostas**, todas sobre a
  mesma regex `^[^@]+@[^@]+\.[^@]+`:
  - **Permissivo demais (3 testes):** `'@email.com'`, `'usuario@.com'` e
    `'usuario@email.'` foram assertados como válidos, mas `[^@]+` exige 1+
    caracteres em cada uma das três posições — a função os rejeita.
  - **Restritivo demais (1 teste):** `'usuario @email.com'` foi assertado como
    inválido, mas a regex **não tem âncora `$`**, então basta existir um trecho
    casável a partir do início — a função o aceita.
- **Prompt de reparo enviado:** saída de erro completa colada, seguindo o
  template padrão de reparo (verbatim, conforme o arquivo do prompt).
- **★ Autoclassificação do modelo:** **(A)** — declarada na primeira linha:
  *"Classificação: (A) — o teste presume um comportamento que não é o
  especificado."* O diagnóstico foi correto nas duas direções. Sobre a âncora,
  explicou:

  > Ela possui ^, mas não possui $. Assim, ela verifica se existe um padrão válido começando no início da string, mas não exige que esse padrão consuma a string inteira.

- **Resultado após correção:** 17/17 passaram (o total subiu de 16 para 17).

### Iteração 2

- **Necessária?** Não (repair concluído na iteração 1).

### Iteração 3

- **Necessária?** Não.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) na iteração 1 — correta nas duas direções de erro |
| **★ Classificação humana (auditoria)** | Erro de teste (expectativas incorretas sobre a cardinalidade de `[^@]+` e sobre a ausência de âncora `$`) |
| **★ Concordância** | Sim |
| **★ Observações** | Ver abaixo. |

### Observações

1. **Confirma a hipótese das rodadas 4 e 5, agora pelo lado negativo.** ZS-04 e
   ZS-05 passaram 100% de primeira com regexes **totalmente ancoradas**
   (`^...$`). Esta é a primeira regex da série **sem `$`** — e voltou a falhar.
   O padrão acumulado em 6 rodadas é consistente: o modelo erra quando o
   contrato depende de algo que não está literalmente escrito (a semântica de
   `\s`, o comportamento de `int.tryParse`, a *ausência* de uma âncora).

2. **Errou nas duas direções sobre a mesma regex, na mesma resposta.** Foi
   simultaneamente permissivo demais (sobre `[^@]+` aceitar vazio) e restritivo
   demais (sobre a string inteira precisar casar). Não é um viés sistemático
   numa direção, e sim leitura imprecisa do literal — reforçando a leitura da
   observação 1.

3. **A intuição estava certa, os exemplos errados.** O modelo identificou
   corretamente, sem ser perguntado, que esta regex é permissiva — o que é
   verdade, e é justamente a inconsistência que separa `validateEmailLogin` de
   `validateEmail`. Mas as três instâncias que citou como prova eram todas
   falsas, enquanto o caso que de fato demonstra a permissividade (espaço ao
   final, por falta de `$`) ele classificou como inválido. Diagnóstico certo,
   evidência errada.

4. **Recusa correta de enfraquecer a asserção, mesmo classificando como (A).**
   Ao tratar o caso do espaço, o modelo delimitou o escopo espontaneamente:
   *"não devemos simplesmente mudar a asserção para fazer o teste passar se o
   requisito da aplicação for rejeitar espaços. Nesse caso específico, há um
   possível problema na implementação: se a regra de negócio disser que o valor
   inteiro deve ser um e-mail válido, a regex deveria exigir o fim da string."*
   É um comportamento híbrido A/B — classificou (A) e ajustou o teste, mas
   registrou o possível defeito da aplicação em vez de silenciá-lo. Mesmo
   padrão observado em ZS-03.

5. **Nota de execução (erro do operador, não do modelo):** a primeira tentativa
   de rodar o código da iteração 1 falhou na compilação, mas por um erro de
   **extração** — o texto explicativo que seguia o bloco de código foi copiado
   junto para o arquivo `.dart`. O código entregue pelo modelo estava correto e
   compila. A saída registrada em
   `FASE2-UNIT-ZS-06_validateEmailLogin_iter1_final.txt` é a da execução válida.
   Esse erro **não conta** como iteração de reparo nem como falha da rodada.

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
