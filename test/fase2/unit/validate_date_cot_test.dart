import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateDate', () {
    group('Cenários de sucesso', () {
      test('deve retornar null para uma data válida comum', () {
        expect(
          Validators.validateDate('15/05/1990'),
          isNull,
        );
      });

      test('deve retornar null para o primeiro dia do ano', () {
        expect(
          Validators.validateDate('01/01/2000'),
          isNull,
        );
      });

      test('deve retornar null para o último dia de um mês com 31 dias', () {
        expect(
          Validators.validateDate('31/01/2000'),
          isNull,
        );
      });

      test('deve retornar null para o último dia de um mês com 30 dias', () {
        expect(
          Validators.validateDate('30/04/2000'),
          isNull,
        );
      });

      test('deve retornar null para 29 de fevereiro em ano bissexto', () {
        expect(
          Validators.validateDate('29/02/2024'),
          isNull,
        );
      });

      test('deve retornar null para uma data sem zeros à esquerda', () {
        expect(
          Validators.validateDate('1/5/1990'),
          isNull,
        );
      });

      test('deve retornar null para a data de hoje', () {
        final now = DateTime.now();
        final today = '${now.day}/${now.month}/${now.year}';

        expect(
          Validators.validateDate(today),
          isNull,
        );
      });
    });

    group('Cenários de falha - valor obrigatório', () {
      test('deve retornar erro quando o valor for null', () {
        expect(
          Validators.validateDate(null),
          'A data de nascimento é obrigatória',
        );
      });

      test('deve retornar erro quando o valor for vazio', () {
        expect(
          Validators.validateDate(''),
          'A data de nascimento é obrigatória',
        );
      });
    });

    group('Cenários de falha - formato', () {
      test('deve retornar erro quando houver menos de três partes', () {
        expect(
          Validators.validateDate('15/05'),
          'Formato inválido. Use dd/mm/aaaa',
        );
      });

      test('deve retornar erro quando houver mais de três partes', () {
        expect(
          Validators.validateDate('15/05/1990/123'),
          'Formato inválido. Use dd/mm/aaaa',
        );
      });

      test('deve retornar erro quando o separador for inválido', () {
        expect(
          Validators.validateDate('15-05-1990'),
          'Formato inválido. Use dd/mm/aaaa',
        );
      });

      test('deve retornar erro quando houver uma string sem separadores', () {
        expect(
          Validators.validateDate('15051990'),
          'Formato inválido. Use dd/mm/aaaa',
        );
      });
    });

    group('Cenários de falha - campos não numéricos', () {
      test('deve retornar erro quando o dia não for numérico', () {
        expect(
          Validators.validateDate('xx/05/1990'),
          'Data inválida. Certifique-se de que todos os campos são números',
        );
      });

      test('deve retornar erro quando o mês não for numérico', () {
        expect(
          Validators.validateDate('15/xx/1990'),
          'Data inválida. Certifique-se de que todos os campos são números',
        );
      });

      test('deve retornar erro quando o ano não for numérico', () {
        expect(
          Validators.validateDate('15/05/abcd'),
          'Data inválida. Certifique-se de que todos os campos são números',
        );
      });

      test('deve retornar erro quando mais de um campo não for numérico', () {
        expect(
          Validators.validateDate('xx/xx/abcd'),
          'Data inválida. Certifique-se de que todos os campos são números',
        );
      });
    });

    group('Cenários de falha - mês inválido', () {
      test('deve retornar erro para mês 00', () {
        expect(
          Validators.validateDate('15/00/1990'),
          'Mês deve ser entre 01 e 12',
        );
      });

      test('deve retornar erro para mês 13', () {
        expect(
          Validators.validateDate('15/13/1990'),
          'Mês deve ser entre 01 e 12',
        );
      });
    });

    group('Cenários de falha - dia inválido', () {
      test('deve retornar erro para dia 00', () {
        expect(
          Validators.validateDate('00/05/1990'),
          'Dia deve ser entre 01 e 31',
        );
      });

      test('deve retornar erro para dia maior que 31 em janeiro', () {
        expect(
          Validators.validateDate('32/01/1990'),
          'Dia deve ser entre 01 e 31',
        );
      });

      test('deve retornar erro para 31 de abril', () {
        expect(
          Validators.validateDate('31/04/2024'),
          'Dia deve ser entre 01 e 30',
        );
      });

      test('deve retornar erro para 31 de junho', () {
        expect(
          Validators.validateDate('31/06/2024'),
          'Dia deve ser entre 01 e 30',
        );
      });

      test('deve retornar erro para 31 de fevereiro', () {
        expect(
          Validators.validateDate('31/02/2024'),
          'Dia deve ser entre 01 e 29',
        );
      });

      test('deve retornar erro para 29 de fevereiro em ano não bissexto', () {
        expect(
          Validators.validateDate('29/02/2023'),
          'Dia deve ser entre 01 e 28',
        );
      });
    });

    group('Cenários de falha - data futura', () {
      test('deve retornar erro para uma data futura', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));
        final date =
            '${futureDate.day}/${futureDate.month}/${futureDate.year}';

        expect(
          Validators.validateDate(date),
          'A data não pode ser no futuro',
        );
      });

      test('deve retornar erro para uma data muito distante no futuro', () {
        expect(
          Validators.validateDate('31/12/9999'),
          'A data não pode ser no futuro',
        );
      });
    });

    group('Casos de borda', () {
      test('deve aceitar o último dia de fevereiro em ano bissexto', () {
        expect(
          Validators.validateDate('29/02/2024'),
          isNull,
        );
      });

      test('deve aceitar o último dia de fevereiro em ano não bissexto', () {
        expect(
          Validators.validateDate('28/02/2023'),
          isNull,
        );
      });

      test('deve aceitar 31 de dezembro de um ano passado', () {
        expect(
          Validators.validateDate('31/12/2000'),
          isNull,
        );
      });

      test('deve retornar erro para ano 0000', () {
        final result = Validators.validateDate('01/01/0000');

        expect(
          result,
          isNull,
        );
      });

      test('deve aceitar espaços nas extremidades da data', () {
        expect(
          Validators.validateDate(' 15/05/1990 '),
          isNull,
        );
      });
    });
  });
}
