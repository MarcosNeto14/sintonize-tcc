# UNIT-ZS-03

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-ZS-03 |
| **Função testada** | validateNumero |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de cadastro.dart — _validateNumero) |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.6 |
| **Data de acesso** | 20/04/2026 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 |

---

## Prompt Enviado
Gere testes unitários em Dart usando o pacote flutter_test para a seguinte função: \
dart
  static String? validateNumero(String? value) {
    if (value == null || value.isEmpty) {
      return 'O número é obrigatório';
    }
    if (int.tryParse(value) == null) {
      return 'O número deve ser numérico';
    }
    return null;
  } 
\
A função faz parte de uma classe chamada Validators no arquivo lib/utils/validators.dart de um projeto Flutter chamado "sintonize". Requisitos: - Use a estrutura group() e test() do flutter_test - Cubra cenários de sucesso e de falha - Inclua casos de borda - Os testes devem ser executáveis com flutter test

---

## Resposta do LLM
Aqui vai um conjunto completo de testes unitários para a função validateNumero, usando o pacote flutter_test. Eles cobrem cenários de sucesso, falha e alguns casos de borda.

Crie o arquivo, por exemplo:
test/utils/validators_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateNumero', () {
    test('deve retornar erro quando valor é null', () {
      final result = Validators.validateNumero(null);

      expect(result, 'O número é obrigatório');
    });

    test('deve retornar erro quando valor é vazio', () {
      final result = Validators.validateNumero('');

      expect(result, 'O número é obrigatório');
    });

    test('deve retornar erro quando valor não é numérico', () {
      final result = Validators.validateNumero('abc');

      expect(result, 'O número deve ser numérico');
    });

    test('deve retornar erro para string com caracteres mistos', () {
      final result = Validators.validateNumero('123abc');

      expect(result, 'O número deve ser numérico');
    });

    test('deve aceitar número inteiro válido', () {
      final result = Validators.validateNumero('123');

      expect(result, isNull);
    });

    test('deve aceitar número negativo', () {
      final result = Validators.validateNumero('-42');

      expect(result, isNull);
    });

    test('deve aceitar zero', () {
      final result = Validators.validateNumero('0');

      expect(result, isNull);
    });

    test('deve rejeitar número com espaço', () {
      final result = Validators.validateNumero(' 123');

      expect(result, 'O número deve ser numérico');
    });

    test('deve rejeitar número decimal', () {
      final result = Validators.validateNumero('12.5');

      expect(result, 'O número deve ser numérico');
    });

    test('deve rejeitar apenas espaços', () {
      final result = Validators.validateNumero('   ');

      expect(result, 'O número deve ser numérico');
    });
  });
}
Observações rápidas
Os testes assumem que a função usa int.tryParse, então:
"12.5" falha (não é inteiro)
" 123" falha (espaços não são tratados)
Se você quiser aceitar espaços ou números decimais, a função precisaria ser ajustada — e os testes também.
Como rodar

Dentro do projeto sintonize:

flutter test

Se quiser, posso também sugerir melhorias na função (por exemplo, trim() ou suporte a double).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 10 |
| **Testes passaram** | 9 |
| **Testes falharam** | 1 |

### Saída do terminal
00:02 +7 -1: Validators.validateNumero deve rejeitar número com espaço [E]
  Expected: 'O número deve ser numérico'
    Actual: <null>
     Which: not an <Instance of 'String'>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test\unit\validate_numero_zs_test.dart 51:7         main.<fn>.<fn> 

---

## Iterative Repair Loop

### Iteração 1
- **Necessária?** Sim

- **Motivo da falha:** O LLM assumiu que int.tryParse(' 123')
  retornaria null (falha), mas em Dart o int.tryParse aceita
  espaços em branco antes/depois do número e retorna 123.
  O teste esperava rejeição, mas a função aceita ' 123' como
  válido.

- **Prompt de correção:**
O teste falhou com o seguinte erro: \
00:02 +7 -1: Validators.validateNumero deve rejeitar número com espaço [E]
  Expected: 'O número deve ser numérico'
    Actual: <null>
     Which: not an <Instance of 'String'>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test\unit\validate_numero_zs_test.dart 51:7         main.<fn>.<fn> 
\
Corrija o teste para que ele compile e passe corretamente.

- **Resposta do LLM:**
O erro não está no teste “quebrado”, e sim na premissa do teste.
O int.tryParse(' 123') retorna 123, ou seja, o Dart aceita espaços à esquerda/direita — então a função retorna null (válido), não erro.

Portanto, o teste precisa ser ajustado para refletir o comportamento real da função.

✅ Correção do teste

Substitua este teste:

test('deve rejeitar número com espaço', () {
  final result = Validators.validateNumero(' 123');

  expect(result, 'O número deve ser numérico');
});

Por este:

test('deve aceitar número com espaço (int.tryParse permite)', () {
  final result = Validators.validateNumero(' 123');

  expect(result, isNull);
});
💡 Alternativa (se a regra de negócio for diferente)

Se a sua intenção era realmente rejeitar espaços, então o problema está na função, não no teste. Aí você deveria mudar a implementação para:

static String? validateNumero(String? value) {
  if (value == null || value.isEmpty) {
    return 'O número é obrigatório';
  }

  if (value.trim() != value) {
    return 'O número deve ser numérico';
  }

  if (int.tryParse(value) == null) {
    return 'O número deve ser numérico';
  }

  return null;
}

Mas com a implementação atual, o comportamento correto é aceitar " 123".

✔️ Resumo
✔ O Dart aceita " 123" como inteiro válido
✔ O teste estava assumindo comportamento incorreto
✔ Ajustar o expect resolve o erro
✔ flutter test deve passar normalmente após a correção

Se quiser, posso te ajudar a fortalecer ainda mais os testes (ex: cobertura de whitespace mais completa ou property-based testing).

- **Resultado:** Passou
00:01 +10: All tests passed!

### Iteração 2
- **Necessária?** _preencher (Sim/Não)_
- _(preencher se necessário)_

### Iteração 3
- **Necessária?** _preencher (Sim/Não)_
- _(preencher se necessário)_
