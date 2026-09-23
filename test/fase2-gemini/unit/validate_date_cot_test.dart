import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateDate', () {
    group('Sucesso (Entradas válidas)', () {
      test('deve retornar null para data passada comum no formato dd/mm/aaaa', () {
        final result = Validators.validateDate('15/05/1995');
        expect(result, isNull);
      });

      test('deve retornar null para primeiro dia do ano', () {
        final result = Validators.validateDate('01/01/2000');
        expect(result, isNull);
      });

      test('deve retornar null para dia 31 em mês de 31 dias', () {
        final result = Validators.validateDate('31/12/2020');
        expect(result, isNull);
      });

      test('deve retornar null para dia 30 em mês de 30 dias', () {
        final result = Validators.validateDate('30/04/2021');
        expect(result, isNull);
      });

      test('deve retornar null para 29 de fevereiro em ano bissexto válido', () {
        final result = Validators.validateDate('29/02/2020');
        expect(result, isNull);
      });

      test('deve retornar null para 28 de fevereiro em ano não-bissexto', () {
        final result = Validators.validateDate('28/02/2021');
        expect(result, isNull);
      });
    });

    group('Falha - Obrigatoriedade e Formato', () {
      test('deve retornar erro quando o valor for nulo', () {
        final result = Validators.validateDate(null);
        expect(result, 'A data de nascimento é obrigatória');
      });

      test('deve retornar erro quando o valor for vazio', () {
        final result = Validators.validateDate('');
        expect(result, 'A data de nascimento é obrigatória');
      });

      test('deve retornar erro quando não contiver exatamente 3 partes', () {
        expect(
          Validators.validateDate('15/05'),
          'Formato inválido. Use dd/mm/aaaa',
        );
        expect(
          Validators.validateDate('15-05-1995'),
          'Formato inválido. Use dd/mm/aaaa',
        );
        expect(
          Validators.validateDate('15/05/1995/10'),
          'Formato inválido. Use dd/mm/aaaa',
        );
      });

      test('deve retornar erro quando partes não forem números válidos', () {
        expect(
          Validators.validateDate('aa/05/1995'),
          'Data inválida. Certifique-se de que todos os campos são números',
        );
        expect(
          Validators.validateDate('15/bb/1995'),
          'Data inválida. Certifique-se de que todos os campos são números',
        );
        expect(
          Validators.validateDate('15/05/aaaa'),
          'Data inválida. Certifique-se de que todos os campos são números',
        );
        expect(
          Validators.validateDate(' // '),
          'Data inválida. Certifique-se de que todos os campos são números',
        );
      });
    });

    group('Falha - Intervalos de Mês e Dia', () {
      test('deve retornar erro quando o mês for menor que 1', () {
        final result = Validators.validateDate('15/00/2020');
        expect(result, 'Mês deve ser entre 01 e 12');
      });

      test('deve retornar erro quando o mês for maior que 12', () {
        final result = Validators.validateDate('15/13/2020');
        expect(result, 'Mês deve ser entre 01 e 12');
      });

      test('deve retornar erro quando o dia for menor que 1', () {
        final result = Validators.validateDate('00/05/2020');
        expect(result, 'Dia deve ser entre 01 e 31');
      });

      test('deve retornar erro quando o dia exceder o limite do mês de 31 dias', () {
        final result = Validators.validateDate('32/01/2020');
        expect(result, 'Dia deve ser entre 01 e 31');
      });

      test('deve retornar erro quando o dia exceder o limite do mês de 30 dias', () {
        final result = Validators.validateDate('31/04/2020');
        expect(result, 'Dia deve ser entre 01 e 30');
      });

      test('deve retornar erro para 29 de fevereiro em ano não-bissexto', () {
        final result = Validators.validateDate('29/02/2021');
        expect(result, 'Dia deve ser entre 01 e 28');
      });

      test('deve retornar erro para dia 30 de fevereiro em qualquer ano', () {
        final result = Validators.validateDate('30/02/2024');
        expect(result, 'Dia deve ser entre 01 e 29');
      });
    });

    group('Falha - Datas no Futuro', () {
      test('deve retornar erro quando o ano for no futuro distante', () {
        final result = Validators.validateDate('01/01/2099');
        expect(result, 'A data não pode ser no futuro');
      });

      test('deve retornar erro para data calculada estritamente no futuro relativo', () {
        final tomorrow = DateTime.now().add(const Duration(days: 2));
        final dayStr = tomorrow.day.toString().padLeft(2, '0');
        final monthStr = tomorrow.month.toString().padLeft(2, '0');
        final yearStr = tomorrow.year.toString();

        final result = Validators.validateDate('$dayStr/$monthStr/$yearStr');
        expect(result, 'A data não pode ser no futuro');
      });
    });
  });
}

