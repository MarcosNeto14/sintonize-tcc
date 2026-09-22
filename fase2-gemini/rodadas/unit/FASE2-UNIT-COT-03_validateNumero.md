# FASE2-UNIT-COT-03_validateNumero — Réplica Gemini

Rodada **24/60**. Bloco 2 (alvos limpos), lote 2 (`validateNumero`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-COT-03_validateNumero |
| **Função/tela alvo** | `Validators.validateNumero` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim — `gemini.google.com/app/0285e3ba1d530f9a` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/validate_numero_cot_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-COT-03_iter{0,1}.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/cot/FASE2-UNIT-COT-03_validateNumero.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/0285e3ba1d530f9a` | Resposta completa |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 13 |
| **Testes passaram (1ª execução)** | 12/13 |
| **Iterações de reparo** | 1 |
| **Testes passaram (pós-repair)** | **13/13** |
| **Tentativas de envio até obter resposta** | **1** |

---

## Iterative Repair Loop

### Iteração 1

- **Motivo:** `deve retornar erro se houver espaços ao redor do número` — `Actual: <null>` para `' 10 '`. Mesma premissa falsa da rodada 22.
- **★ Autoclassificação:** **(A)**, correta, citando a documentação de `int.tryParse` ("surrounded by optional whitespace").
- **Correção entregue:** só o teste afetado, renomeado e com `isNull`. **Aplicado:** substituição desse teste no arquivo.
- **Resultado:** **13/13.**
- Saída: `FASE2-UNIT-COT-03_iter1.txt`

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) |
| **★ Classificação humana (auditoria)** | Erro de teste |
| **★ Concordância** | Sim |

---

## Observações

1. Mesma premissa falsa da rodada 22 sobre espaços, em conversa independente — é um viés estável do modelo sobre `int.tryParse`, não acaso.
2. ChatGPT na mesma rodada: 17 testes (19 após o reparo).

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
### 1. Análise da Função

A função `validateNumero` valida se uma string de entrada representa um valor numérico inteiro obrigatório. Ela verifica primeiro se o valor é nulo ou vazio, retornando uma mensagem de obrigatoriedade caso positivo. Em seguida, tenta converter o texto para um inteiro via `int.tryParse()`, retornando uma mensagem de erro caso o conteúdo não seja estritamente numérico ou `null` quando o valor é válido.

---

### 2. Cenários de Teste

* **Cenários de Sucesso (entradas válidas):**
* Número inteiro positivo simples (ex: `'42'`).
* Número zero (`'0'`).
* Número inteiro negativo (ex: `'-10'`), pois `int.tryParse` aceita sinais.


* **Cenários de Falha (entradas inválidas):**
* Valor nulo (`null`).
* String vazia (`''`).
* Letras ou caracteres alfabéticos (ex: `'abc'`).
* Textos alfanuméricos mistos (ex: `'123a'`).
* Caracteres especiais ou símbolos (ex: `'@#!'`).


* **Casos de Borda e Entradas Inesperadas:**
* String contendo apenas espaços em branco (ex: `'   '`) — `isEmpty` é falso, mas `int.tryParse` falha e retorna o erro numérico.
* Números decimais ou com ponto flutuante (ex: `'10.5'`, `'10,5'`) — `int.tryParse` falha para casas decimais.
* Número inteiro muito grande dentro dos limites do tipo de dados de 64 bits (ex: `'9223372036854775807'`).
* Valor com espaços antes ou depois do número (ex: `' 123 '`), testando se há trim implícito (não há, deve falhar).



---

### 3. Testes Unitários

Arquivo: `test/utils/validators_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateNumero', () {
    group('Cenários de Sucesso', () {
      test('deve retornar null para um número inteiro positivo comum', () {
        final result = Validators.validateNumero('42');
        expect(result, isNull);
      });

      test('deve retornar null para o valor zero', () {
        final result = Validators.validateNumero('0');
        expect(result, isNull);
      });

      test('deve retornar null para um número inteiro negativo', () {
        final result = Validators.validateNumero('-15');
        expect(result, isNull);
      });
    });

    group('Cenários de Falha - Obrigatoriedade', () {
      test('deve retornar mensagem de obrigatoriedade quando o valor for nulo', () {
        final result = Validators.validateNumero(null);
        expect(result, 'O número é obrigatório');
      });

      test('deve retornar mensagem de obrigatoriedade quando a string for vazia', () {
        final result = Validators.validateNumero('');
        expect(result, 'O número é obrigatório');
      });
    });

    group('Cenários de Falha - Formato Numérico', () {
      test('deve retornar mensagem de erro quando contiver apenas letras', () {
        final result = Validators.validateNumero('abc');
        expect(result, 'O número deve ser numérico');
      });

      test('deve retornar mensagem de erro quando contiver caracteres alfanuméricos mistos', () {
        final result = Validators.validateNumero('123a');
        expect(result, 'O número deve ser numérico');
      });

      test('deve retornar mensagem de erro quando contiver caracteres especiais', () {
        final result = Validators.validateNumero('!@#\$%');
        expect(result, 'O número deve ser numérico');
      });
    });

    group('Casos de Borda e Entradas Inesperadas', () {
      test('deve retornar erro de formato quando contiver apenas espaços em branco', () {
        final result = Validators.validateNumero('   ');
        expect(result, 'O número deve ser numérico');
      });

      test('deve retornar erro de formato para número com casas decimais (ponto)', () {
        final result = Validators.validateNumero('10.5');
        expect(result, 'O número deve ser numérico');
      });

      test('deve retornar erro de formato para número com casas decimais (vírgula)', () {
        final result = Validators.validateNumero('10,5');
        expect(result, 'O número deve ser numérico');
      });

      test('deve retornar erro se houver espaços ao redor do número', () {
        final result = Validators.validateNumero(' 10 ');
        expect(result, 'O número deve ser numérico');
      });

      test('deve retornar null para um número inteiro longo no limite de 64 bits', () {
        final result = Validators.validateNumero('9223372036854775807');
        expect(result, isNull);
      });
    });
  });
}

```
````

### Resposta ao reparo 1

````markdown
### Classificação da Causa da Falha

**(A) O teste presume um comportamento que não é o especificado.**

---

### Análise e Justificativa

O teste falhou na asserção do caso com espaços ao redor:

```dart
test('deve retornar erro se houver espaços ao redor do número', () {
  final result = Validators.validateNumero(' 10 ');
  expect(result, 'O número deve ser numérico');
});

```

A premissa do teste assumiu que `int.tryParse(' 10 ')` rejeitaria espaços ao redor. No entanto, de acordo com a documentação oficial da linguagem Dart, o método `int.tryParse(String source)` permite explicitamente espaços em branco no início e no final da cadeia de caracteres (*leading and trailing whitespace*):

> *"The source must be a non-empty sequence of base-radix digits, optionally prefixed by a minus or plus sign ('-' or '+'), and **surrounded by optional whitespace**."*

Portanto, a implementação original:

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

analisa `' 10 '` com sucesso como o inteiro `10` e retorna `null`. O comportamento do código é fiel ao contrato nativo da API que ele utiliza (`int.tryParse`), sem ter sido especificada nenhuma restrição contra espaços extras.

---

### Correção do Teste

O teste deve refletir o contrato real da função e da API `int.tryParse`, validando que strings numéricas contendo espaços no início ou fim são aceitas com sucesso (`isNull`), ou simplesmente ser renomeado e ajustado conforme o comportamento esperado:

```dart
test('deve aceitar número com espaços no início ou no fim (comportamento nativo de int.tryParse)', () {
  final result = Validators.validateNumero(' 10 ');
  expect(result, isNull);
});

```
````

