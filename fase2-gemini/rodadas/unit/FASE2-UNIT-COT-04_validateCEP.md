# FASE2-UNIT-COT-04_validateCEP — Réplica Gemini

Rodada **27/60**. Bloco 2 (alvos limpos), lote 3 (`validateCEP`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-COT-04_validateCEP |
| **Função/tela alvo** | `Validators.validateCEP` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim — tentativa 2 em `gemini.google.com/app/71a498cba6848d66` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/validate_cep_cot_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-COT-04_iter0.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/cot/FASE2-UNIT-COT-04_validateCEP.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/895e36cf2c7aaccf` | **Erro do serviço:** aviso "Algo deu errado (1096)"; nenhuma resposta gerada, prompt devolvido ao campo. Não é recusa. |
| 2 | nova — `gemini.google.com/app/71a498cba6848d66` | Resposta completa |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 12 |
| **Testes passaram (1ª execução)** | **12/12** |
| **Iterações de reparo** | 0 |
| **Tentativas de envio até obter resposta** | **2** (1 erro de serviço) |

---

## Observações

1. Primeira falha de serviço (erro 1096) registrada na réplica, distinta das recusas: o Gemini não respondeu nada e devolveu o texto ao campo. Tratada como tentativa perdida, com reenvio em conversa nova.
2. ChatGPT na mesma rodada: 23 testes.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Tentativa 1 (erro de serviço)

````markdown
(sem resposta do modelo — o Gemini exibiu o aviso "Algo deu errado (1096)", não gerou resposta e devolveu o prompt ao campo de texto)
````

### Resposta da geração inicial (tentativa 2)

````markdown
### 1. Análise da Função

A função `validateCEP` valida se uma string fornecida representa um Código de Endereçamento Postal (CEP) brasileiro no formato com máscara (`XXXXX-XXX`). Ela verifica primeiro se o valor é nulo ou vazio, retornando uma mensagem de obrigatoriedade caso seja. Em seguida, valida se a entrada possui exatamente 9 caracteres e se obedece à expressão regular de 5 dígitos, hífen e 3 dígitos, retornando `null` quando o CEP é estritamente válido.

---

### 2. Identificação dos Cenários de Teste

* **Cenários de Sucesso (Entradas Válidas):**
* CEP com formato exato e dígitos válidos (ex.: `'50000-000'`).
* CEP válido com dígitos repetidos (ex.: `'11111-111'`).


* **Cenários de Falha (Entradas Inválidas):**
* Entrada nula (`null`).
* Entrada vazia (`''`).
* CEP sem máscara/apenas dígitos (8 caracteres, ex.: `'50000000'`).
* CEP contendo letras ou caracteres especiais no lugar de números (ex.: `'5000A-000'`, `'5000@-000'`).
* Máscara em posição incorreta (ex.: `'5000-0000'`).


* **Casos de Borda e Entradas Inesperadas:**
* String contendo apenas espaços em branco (ex.: `'   '`).
* CEP com espaços adicionais no início ou no fim (ex.: `' 50000-000'`).
* CEP com menos de 9 caracteres mas com formato truncado (ex.: `'5000-00'`).
* CEP com mais de 9 caracteres (ex.: `'50000-0001'`).
* Uso de separador diferente de hífen (ex.: `'50000.000'`, `'50000/000'`).



---

### 3. Testes Unitários

Arquivo: `test/utils/validators_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateCEP', () {
    const requiredError = 'O CEP é obrigatório';
    const invalidFormatError = 'CEP inválido. Formato correto: XXXXX-XXX';

    group('Sucesso', () {
      test('deve retornar null para um CEP válido no formato padrão', () {
        final result = Validators.validateCEP('50000-000');
        expect(result, isNull);
      });

      test('deve retornar null para CEP válido com números repetidos', () {
        final result = Validators.validateCEP('11111-111');
        expect(result, isNull);
      });
    });

    group('Validações de Obrigatoriedade', () {
      test('deve retornar mensagem de obrigatoriedade quando o valor for nulo', () {
        final result = Validators.validateCEP(null);
        expect(result, equals(requiredError));
      });

      test('deve retornar mensagem de obrigatoriedade quando o valor for vazio', () {
        final result = Validators.validateCEP('');
        expect(result, equals(requiredError));
      });
    });

    group('Formato Inválido', () {
      test('deve retornar erro quando o CEP não possui máscara (apenas 8 dígitos)', () {
        final result = Validators.validateCEP('50000000');
        expect(result, equals(invalidFormatError));
      });

      test('deve retornar erro quando contiver caracteres alfabéticos', () {
        final result = Validators.validateCEP('5000A-000');
        expect(result, equals(invalidFormatError));
      });

      test('deve retornar erro quando a posição do hífen estiver incorreta', () {
        final result = Validators.validateCEP('5000-0000');
        expect(result, equals(invalidFormatError));
      });

      test('deve retornar erro se o separador não for um hífen', () {
        final result = Validators.validateCEP('50000.000');
        expect(result, equals(invalidFormatError));
      });
    });

    group('Casos de Borda e Limites', () {
      test('deve retornar erro de formato quando contiver apenas espaços em branco', () {
        final result = Validators.validateCEP('         ');
        expect(result, equals(invalidFormatError));
      });

      test('deve retornar erro quando houver espaços extras nas extremidades', () {
        final result = Validators.validateCEP(' 50000-000');
        expect(result, equals(invalidFormatError));
      });

      test('deve retornar erro quando o comprimento for menor que 9 caracteres', () {
        final result = Validators.validateCEP('5000-00');
        expect(result, equals(invalidFormatError));
      });

      test('deve retornar erro quando o comprimento for maior que 9 caracteres', () {
        final result = Validators.validateCEP('50000-0000');
        expect(result, equals(invalidFormatError));
      });
    });
  });
}

```
````

