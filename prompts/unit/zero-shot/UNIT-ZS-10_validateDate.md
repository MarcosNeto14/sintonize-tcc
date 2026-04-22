# UNIT-ZS-10

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-ZS-10 |
| **Função testada** | validateDate |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de cadastro.dart — _validateDate) |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.6 |
| **Data de acesso** | _preencher_ |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 |

---

## Prompt Enviado
Gere testes unitários em Dart usando o pacote flutter_test para a seguinte função:

\```dart
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'A data de nascimento é obrigatória';
    }
    final parts = value.split('/');
    if (parts.length != 3) {
      return 'Formato inválido. Use dd/mm/aaaa';
    }
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return 'Data inválida. Certifique-se de que todos os campos são números';
    }
    if (month < 1 || month > 12) {
      return 'Mês deve ser entre 01 e 12';
    }
    final maxDay = DateTime(year, month + 1, 0).day;
    if (day < 1 || day > maxDay) {
      return 'Dia deve ser entre 01 e $maxDay';
    }
    final date = DateTime(year, month, day);
    if (date.isAfter(DateTime.now())) {
      return 'A data não pode ser no futuro';
    }
    return null;
  } 
\```

A função faz parte de uma classe chamada Validators no arquivo lib/utils/validators.dart de um projeto Flutter chamado "sintonize".

Requisitos:
- Use a estrutura group() e test() do flutter_test
- Cubra cenários de sucesso e de falha
- Inclua casos de borda
- Os testes devem ser executáveis com `flutter test`

---

## Resposta do LLM
Aqui está um conjunto completo de testes unitários usando o pacote flutter_test, cobrindo cenários de sucesso, falha e casos de borda para a função validateDate.

Crie um arquivo, por exemplo:
test/utils/validators_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateDate', () {
    group('Casos válidos', () {
      test('Deve retornar null para uma data válida', () {
        final result = Validators.validateDate('15/08/1995');
        expect(result, isNull);
      });

      test('Deve aceitar ano bissexto (29/02/2020)', () {
        final result = Validators.validateDate('29/02/2020');
        expect(result, isNull);
      });

      test('Deve aceitar último dia do mês corretamente', () {
        final result = Validators.validateDate('31/01/2023');
        expect(result, isNull);
      });
    });

    group('Campos obrigatórios', () {
      test('Deve retornar erro quando valor é null', () {
        final result = Validators.validateDate(null);
        expect(result, 'A data de nascimento é obrigatória');
      });

      test('Deve retornar erro quando valor é vazio', () {
        final result = Validators.validateDate('');
        expect(result, 'A data de nascimento é obrigatória');
      });
    });

    group('Formato inválido', () {
      test('Deve retornar erro quando formato não tem 3 partes', () {
        final result = Validators.validateDate('12/2020');
        expect(result, 'Formato inválido. Use dd/mm/aaaa');
      });

      test('Deve retornar erro quando separador é incorreto', () {
        final result = Validators.validateDate('12-12-2020');
        expect(result, 'Formato inválido. Use dd/mm/aaaa');
      });
    });

    group('Valores não numéricos', () {
      test('Deve retornar erro quando dia não é número', () {
        final result = Validators.validateDate('aa/12/2020');
        expect(
          result,
          'Data inválida. Certifique-se de que todos os campos são números',
        );
      });

      test('Deve retornar erro quando mês não é número', () {
        final result = Validators.validateDate('10/bb/2020');
        expect(
          result,
          'Data inválida. Certifique-se de que todos os campos são números',
        );
      });

      test('Deve retornar erro quando ano não é número', () {
        final result = Validators.validateDate('10/10/cccc');
        expect(
          result,
          'Data inválida. Certifique-se de que todos os campos são números',
        );
      });
    });

    group('Validação de mês', () {
      test('Deve falhar para mês menor que 1', () {
        final result = Validators.validateDate('10/00/2020');
        expect(result, 'Mês deve ser entre 01 e 12');
      });

      test('Deve falhar para mês maior que 12', () {
        final result = Validators.validateDate('10/13/2020');
        expect(result, 'Mês deve ser entre 01 e 12');
      });
    });

    group('Validação de dia', () {
      test('Deve falhar para dia menor que 1', () {
        final result = Validators.validateDate('00/01/2020');
        expect(result, 'Dia deve ser entre 01 e 31');
      });

      test('Deve falhar para dia maior que o permitido no mês', () {
        final result = Validators.validateDate('31/04/2023'); // Abril tem 30
        expect(result, 'Dia deve ser entre 01 e 30');
      });

      test('Deve falhar para 29/02 em ano não bissexto', () {
        final result = Validators.validateDate('29/02/2021');
        expect(result, 'Dia deve ser entre 01 e 28');
      });
    });

    group('Datas futuras', () {
      test('Deve falhar para data no futuro', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        final formatted =
            '${futureDate.day.toString().padLeft(2, '0')}/'
            '${futureDate.month.toString().padLeft(2, '0')}/'
            '${futureDate.year}';

        final result = Validators.validateDate(formatted);

        expect(result, 'A data não pode ser no futuro');
      });
    });

    group('Casos de borda', () {
      test('Deve aceitar data de hoje', () {
        final now = DateTime.now();
        final formatted =
            '${now.day.toString().padLeft(2, '0')}/'
            '${now.month.toString().padLeft(2, '0')}/'
            '${now.year}';

        final result = Validators.validateDate(formatted);

        expect(result, isNull);
      });

      test('Deve aceitar dia 1 e mês 1', () {
        final result = Validators.validateDate('01/01/2000');
        expect(result, isNull);
      });

      test('Deve aceitar 31/12', () {
        final result = Validators.validateDate('31/12/1999');
        expect(result, isNull);
      });
    });
  });
}

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 19 |
| **Testes passaram** | 19 |
| **Testes falharam** | 0 |


### Saída do terminal
00:01 +19: All tests passed!

---

## Iterative Repair Loop

### Iteração 1
- **Necessária?** _preencher (Sim/Não)_
- **Motivo da falha:** _preencher_
- **Prompt de correção:**
preencher
- **Resposta do LLM:**
preencher
- **Resultado:** _preencher (Passou/Falhou)_

### Iteração 2
- **Necessária?** _preencher (Sim/Não)_
- _(preencher se necessário)_

### Iteração 3
- **Necessária?** _preencher (Sim/Não)_
- _(preencher se necessário)_
