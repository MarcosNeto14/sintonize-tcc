import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateDate', () {
    group('Casos de sucesso', () {
      test('deve retornar null para uma data válida no passado', () {
        final result = Validators.validateDate('15/05/1998');
        expect(result, isNull);
      });

      test('deve retornar null para o último dia de um mês com 31 dias', () {
        final result = Validators.validateDate('31/12/2000');
        expect(result, isNull);
      });

      test('deve retornar null para o último dia de um mês com 30 dias', () {
        final result = Validators.validateDate('30/04/2010');
        expect(result, isNull);
      });

      test('deve retornar null para 29 de fevereiro em ano bissexto válido', () {
        final result = Validators.validateDate('29/02/2024');
        expect(result, isNull);
      });

      test('deve retornar null para a data atual (hoje)', () {
        final now = DateTime.now();
        final day = now.day.toString().padLeft(2, '0');
        final month = now.month.toString().padLeft(2, '0');
        final year = now.year.toString();

        final result = Validators.validateDate('$day/$month/$year');
        expect(result, isNull);
      });
    });

    group('Campos obrigatórios e nulos/vazios', () {
      test('deve retornar mensagem de obrigatoriedade quando o valor for nulo', () {
        final result = Validators.validateDate(null);
        expect(result, equals('A data de nascimento é obrigatória'));
      });

      test('deve retornar mensagem de obrigatoriedade quando a string for vazia', () {
        final result = Validators.validateDate('');
        expect(result, equals('A data de nascimento é obrigatória'));
      });
    });

    group('Formato inválido (divisão por barras)', () {
      test('deve rejeitar formatos sem barras', () {
        final result = Validators.validateDate('15051998');
        expect(result, equals('Formato inválido. Use dd/mm/aaaa'));
      });

      test('deve rejeitar separadores diferentes de barra', () {
        final result = Validators.validateDate('15-05-1998');
        expect(result, equals('Formato inválido. Use dd/mm/aaaa'));
      });

      test('deve rejeitar quando houver menos ou mais de três partes', () {
        expect(
          Validators.validateDate('15/05'),
          equals('Formato inválido. Use dd/mm/aaaa'),
        );
        expect(
          Validators.validateDate('15/05/1998/01'),
          equals('Formato inválido. Use dd/mm/aaaa'),
        );
      });
    });

    group('Valores não numéricos', () {
      test('deve rejeitar quando o dia não for numérico', () {
        final result = Validators.validateDate('aa/05/1998');
        expect(
          result,
          equals('Data inválida. Certifique-se de que todos os campos são números'),
        );
      });

      test('deve rejeitar quando o mês não for numérico', () {
        final result = Validators.validateDate('15/bb/1998');
        expect(
          result,
          equals('Data inválida. Certifique-se de que todos os campos são números'),
        );
      });

      test('deve rejeitar quando o ano não for numérico', () {
        final result = Validators.validateDate('15/05/cccc');
        expect(
          result,
          equals('Data inválida. Certifique-se de que todos os campos são números'),
        );
      });

      test('deve rejeitar partes em branco entre as barras', () {
        final result = Validators.validateDate('15//1998');
        expect(
          result,
          equals('Data inválida. Certifique-se de que todos os campos são números'),
        );
      });
    });

    group('Validação do mês', () {
      test('deve rejeitar mês menor que 1', () {
        final result = Validators.validateDate('15/00/1998');
        expect(result, equals('Mês deve ser entre 01 e 12'));
      });

      test('deve rejeitar mês maior que 12', () {
        final result = Validators.validateDate('15/13/1998');
        expect(result, equals('Mês deve ser entre 01 e 12'));
      });
    });

    group('Validação do dia e limites mensais', () {
      test('deve rejeitar dia menor que 1', () {
        final result = Validators.validateDate('00/05/1998');
        expect(result, equals('Dia deve ser entre 01 e 31'));
      });

      test('deve rejeitar dia maior que 31 em mês de 31 dias', () {
        final result = Validators.validateDate('32/01/1998');
        expect(result, equals('Dia deve ser entre 01 e 31'));
      });

      test('deve rejeitar dia 31 em mês de 30 dias', () {
        final result = Validators.validateDate('31/04/1998');
        expect(result, equals('Dia deve ser entre 01 e 30'));
      });

      test('deve rejeitar 29 de fevereiro em ano não bissexto', () {
        final result = Validators.validateDate('29/02/2023');
        expect(result, equals('Dia deve ser entre 01 e 28'));
      });

      test('deve rejeitar dia 30 de fevereiro mesmo em ano bissexto', () {
        final result = Validators.validateDate('30/02/2024');
        expect(result, equals('Dia deve ser entre 01 e 29'));
      });
    });

    group('Validação de datas futuras', () {
      test('deve rejeitar datas com ano à frente do ano atual', () {
        final futureYear = DateTime.now().year + 5;
        final result = Validators.validateDate('01/01/$futureYear');
        expect(result, equals('A data não pode ser no futuro'));
      });

      test('deve rejeitar o dia seguinte à data atual', () {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final day = tomorrow.day.toString().padLeft(2, '0');
        final month = tomorrow.month.toString().padLeft(2, '0');
        final year = tomorrow.year.toString();

        final result = Validators.validateDate('$day/$month/$year');
        expect(result, equals('A data não pode ser no futuro'));
      });
    });
  });
}

