import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateDate', () {
    group('quando a data é obrigatória', () {
      test('deve retornar erro quando o valor for null', () {
        expect(
          Validators.validateDate(null),
          'A data de nascimento é obrigatória',
        );
      });

      test('deve retornar erro quando o valor estiver vazio', () {
        expect(
          Validators.validateDate(''),
          'A data de nascimento é obrigatória',
        );
      });
    });

    group('quando o formato é inválido', () {
      test('deve retornar erro quando não houver três partes', () {
        expect(
          Validators.validateDate('01/01'),
          'Formato inválido. Use dd/mm/aaaa',
        );
      });

      test('deve retornar erro quando houver mais de três partes', () {
        expect(
          Validators.validateDate('01/01/2000/extra'),
          'Formato inválido. Use dd/mm/aaaa',
        );
      });

      test('deve retornar erro quando não houver separador "/"', () {
        expect(
          Validators.validateDate('01012000'),
          'Formato inválido. Use dd/mm/aaaa',
        );
      });

      test('deve retornar erro quando houver separadores incorretos', () {
        expect(
          Validators.validateDate('01-01-2000'),
          'Formato inválido. Use dd/mm/aaaa',
        );
      });
    });

    group('quando os campos não são numéricos', () {
      test('deve retornar erro quando o dia não for numérico', () {
        expect(
          Validators.validateDate('aa/01/2000'),
          'Data inválida. Certifique-se de que todos os campos são números',
        );
      });

      test('deve retornar erro quando o mês não for numérico', () {
        expect(
          Validators.validateDate('01/aa/2000'),
          'Data inválida. Certifique-se de que todos os campos são números',
        );
      });

      test('deve retornar erro quando o ano não for numérico', () {
        expect(
          Validators.validateDate('01/01/aaaa'),
          'Data inválida. Certifique-se de que todos os campos são números',
        );
      });

      test('deve retornar erro quando todos os campos não forem numéricos', () {
        expect(
          Validators.validateDate('dd/mm/aaaa'),
          'Data inválida. Certifique-se de que todos os campos são números',
        );
      });
    });

    group('quando o mês é inválido', () {
      test('deve rejeitar mês 00', () {
        expect(
          Validators.validateDate('01/00/2000'),
          'Mês deve ser entre 01 e 12',
        );
      });

      test('deve rejeitar mês 13', () {
        expect(
          Validators.validateDate('01/13/2000'),
          'Mês deve ser entre 01 e 12',
        );
      });

      test('deve rejeitar mês negativo', () {
        expect(
          Validators.validateDate('01/-1/2000'),
          'Mês deve ser entre 01 e 12',
        );
      });
    });

    group('quando o dia é inválido', () {
      test('deve rejeitar dia 00', () {
        expect(
          Validators.validateDate('00/01/2000'),
          'Dia deve ser entre 01 e 31',
        );
      });

      test('deve rejeitar dia 32 em um mês de 31 dias', () {
        expect(
          Validators.validateDate('32/01/2000'),
          'Dia deve ser entre 01 e 31',
        );
      });

      test('deve rejeitar dia 31 em abril', () {
        expect(
          Validators.validateDate('31/04/2000'),
          'Dia deve ser entre 01 e 30',
        );
      });

      test('deve rejeitar dia 30 em fevereiro', () {
        expect(
          Validators.validateDate('30/02/2020'),
          'Dia deve ser entre 01 e 29',
        );
      });

      test('deve rejeitar dia 29 em fevereiro de um ano não bissexto', () {
        expect(
          Validators.validateDate('29/02/2021'),
          'Dia deve ser entre 01 e 28',
        );
      });
    });

    group('quando a data é válida', () {
      test('deve aceitar uma data comum', () {
        expect(
          Validators.validateDate('15/06/1990'),
          isNull,
        );
      });

      test('deve aceitar o primeiro dia do ano', () {
        expect(
          Validators.validateDate('01/01/2000'),
          isNull,
        );
      });

      test('deve aceitar o último dia de janeiro', () {
        expect(
          Validators.validateDate('31/01/2000'),
          isNull,
        );
      });

      test('deve aceitar o último dia de abril', () {
        expect(
          Validators.validateDate('30/04/2000'),
          isNull,
        );
      });

      test('deve aceitar 28 de fevereiro em ano não bissexto', () {
        expect(
          Validators.validateDate('28/02/2021'),
          isNull,
        );
      });

      test('deve aceitar 29 de fevereiro em ano bissexto', () {
        expect(
          Validators.validateDate('29/02/2020'),
          isNull,
        );
      });

      test('deve aceitar 29 de fevereiro em ano bissexto divisível por 400', () {
        expect(
          Validators.validateDate('29/02/2000'),
          isNull,
        );
      });

      test('deve rejeitar 29 de fevereiro em ano divisível por 100 mas não por 400',
          () {
        expect(
          Validators.validateDate('29/02/1900'),
          'Dia deve ser entre 01 e 28',
        );
      });

      test('deve aceitar o último dia de dezembro', () {
        expect(
          Validators.validateDate('31/12/2000'),
          isNull,
        );
      });
    });

    group('quando a data está no futuro', () {
      test('deve rejeitar uma data futura', () {
        final futureDate = DateTime.now().add(const Duration(days: 1));

        final value =
            '${futureDate.day.toString().padLeft(2, '0')}/'
            '${futureDate.month.toString().padLeft(2, '0')}/'
            '${futureDate.year}';

        expect(
          Validators.validateDate(value),
          'A data não pode ser no futuro',
        );
      });

      test('deve aceitar a data de hoje', () {
        final today = DateTime.now();

        final value =
            '${today.day.toString().padLeft(2, '0')}/'
            '${today.month.toString().padLeft(2, '0')}/'
            '${today.year}';

        expect(
          Validators.validateDate(value),
          isNull,
        );
      });
    });

    group('casos de borda', () {
      test('deve aceitar valores sem zero à esquerda', () {
        expect(
          Validators.validateDate('1/1/2000'),
          isNull,
        );
      });

      test('deve aceitar ano com um único dígito quando interpretado pelo DateTime',
          () {
        expect(
          Validators.validateDate('01/01/1'),
          isNull,
        );
      });

      test('deve aceitar o ano 0', () {
        expect(
          Validators.validateDate('01/01/0'),
          isNull,
        );
      });

      test('deve aceitar espaços apenas se int.tryParse conseguir interpretá-los',
          () {
        expect(
          Validators.validateDate('01/01/2000'),
          isNull,
        );
      });
    });
  });
}
