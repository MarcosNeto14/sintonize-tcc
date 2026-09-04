import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateDate', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(
        Validators.validateDate(null),
        'A data de nascimento é obrigatória',
      );
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(
        Validators.validateDate(''),
        'A data de nascimento é obrigatória',
      );
    });

    test('deve retornar mensagem de erro quando formato não possui três partes', () {
      expect(
        Validators.validateDate('01/01'),
        'Formato inválido. Use dd/mm/aaaa',
      );
    });

    test('deve retornar mensagem de erro quando data não possui números', () {
      expect(
        Validators.validateDate('ab/01/2000'),
        'Data inválida. Certifique-se de que todos os campos são números',
      );
    });

    test('deve retornar mensagem de erro quando mês é menor que 1', () {
      expect(
        Validators.validateDate('10/00/2000'),
        'Mês deve ser entre 01 e 12',
      );
    });

    test('deve retornar mensagem de erro quando mês é maior que 12', () {
      expect(
        Validators.validateDate('10/13/2000'),
        'Mês deve ser entre 01 e 12',
      );
    });

    test('deve retornar mensagem de erro quando dia é menor que 1', () {
      expect(
        Validators.validateDate('00/01/2000'),
        'Dia deve ser entre 01 e 31',
      );
    });

    test('deve retornar mensagem de erro quando dia não existe no mês', () {
      expect(
        Validators.validateDate('31/04/2000'),
        'Dia deve ser entre 01 e 30',
      );
    });

    test('deve aceitar uma data válida', () {
      expect(Validators.validateDate('15/06/2000'), isNull);
    });

    test('deve aceitar o último dia de um mês', () {
      expect(Validators.validateDate('30/04/2000'), isNull);
    });

    test('deve aceitar 29 de fevereiro em ano bissexto', () {
      expect(Validators.validateDate('29/02/2024'), isNull);
    });

    test('deve rejeitar 29 de fevereiro em ano não bissexto', () {
      expect(
        Validators.validateDate('29/02/2023'),
        'Dia deve ser entre 01 e 28',
      );
    });

    test('deve rejeitar data futura', () {
      expect(
        Validators.validateDate('05/09/2026'),
        'A data não pode ser no futuro',
      );
    });

    test('deve aceitar a data de hoje', () {
      final today = DateTime.now();
      final value =
          '${today.day.toString().padLeft(2, '0')}/'
          '${today.month.toString().padLeft(2, '0')}/'
          '${today.year}';

      expect(Validators.validateDate(value), isNull);
    });
  });
}
