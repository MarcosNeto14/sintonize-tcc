import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateDate', () {
    test('deve retornar erro quando valor é null', () {
      expect(Validators.validateDate(null), isNotNull);
    });

    test('deve retornar erro quando valor é vazio', () {
      expect(Validators.validateDate(''), isNotNull);
    });

    test('deve retornar erro quando formato é inválido', () {
      expect(Validators.validateDate('2020-01-01'), isNotNull);
    });

    test('deve retornar erro quando contém valores não numéricos', () {
      expect(Validators.validateDate('aa/bb/cccc'), isNotNull);
    });

    test('deve retornar erro quando mês é menor que 1', () {
      expect(Validators.validateDate('10/00/2020'), isNotNull);
    });

    test('deve retornar erro quando mês é maior que 12', () {
      expect(Validators.validateDate('10/13/2020'), isNotNull);
    });

    test('deve retornar erro quando dia é inválido para o mês', () {
      expect(Validators.validateDate('31/02/2023'), isNotNull);
    });

    test('deve retornar erro quando dia é menor que 1', () {
      expect(Validators.validateDate('00/12/2020'), isNotNull);
    });

    test('deve retornar erro quando data está no futuro', () {
      final futureDate = DateTime.now().add(const Duration(days: 1));
      final formatted =
          '${futureDate.day.toString().padLeft(2, '0')}/'
          '${futureDate.month.toString().padLeft(2, '0')}/'
          '${futureDate.year}';

      expect(Validators.validateDate(formatted), isNotNull);
    });

    test('deve aceitar data válida', () {
      expect(Validators.validateDate('15/08/1995'), isNull);
    });

    test('deve aceitar último dia válido do mês', () {
      expect(Validators.validateDate('30/04/2023'), isNull);
    });

    test('deve aceitar 29 de fevereiro em ano bissexto', () {
      expect(Validators.validateDate('29/02/2024'), isNull);
    });

    test('deve rejeitar 29 de fevereiro em ano não bissexto', () {
      expect(Validators.validateDate('29/02/2023'), isNotNull);
    });
  });
}