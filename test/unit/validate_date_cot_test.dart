import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateDate', () {
    
    // ---------------------------
    // Sucesso
    // ---------------------------
    test('Deve retornar null para data válida', () {
      expect(Validators.validateDate('15/08/1995'), null);
    });

    test('Deve aceitar data no limite do mês', () {
      expect(Validators.validateDate('31/01/2020'), null);
    });

    test('Deve aceitar 29/02 em ano bissexto', () {
      expect(Validators.validateDate('29/02/2020'), null);
    });

    test('Deve aceitar a data de hoje', () {
      final now = DateTime.now();
      final today =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      expect(Validators.validateDate(today), null);
    });

    // ---------------------------
    // Falhas - obrigatoriedade
    // ---------------------------
    test('Deve retornar erro se valor for null', () {
      expect(
        Validators.validateDate(null),
        'A data de nascimento é obrigatória',
      );
    });

    test('Deve retornar erro se valor for vazio', () {
      expect(
        Validators.validateDate(''),
        'A data de nascimento é obrigatória',
      );
    });

    // ---------------------------
    // Falhas - formato
    // ---------------------------
    test('Deve retornar erro para formato inválido', () {
      expect(
        Validators.validateDate('15-08-1995'),
        'Formato inválido. Use dd/mm/aaaa',
      );
    });

    test('Deve retornar erro para formato incompleto', () {
      expect(
        Validators.validateDate('15/08'),
        'Formato inválido. Use dd/mm/aaaa',
      );
    });

    // ---------------------------
    // Falhas - valores não numéricos
    // ---------------------------
    test('Deve retornar erro para valores não numéricos', () {
      expect(
        Validators.validateDate('aa/bb/cccc'),
        'Data inválida. Certifique-se de que todos os campos são números',
      );
    });

    // ---------------------------
    // Falhas - mês inválido
    // ---------------------------
    test('Deve retornar erro para mês menor que 1', () {
      expect(
        Validators.validateDate('10/00/2020'),
        'Mês deve ser entre 01 e 12',
      );
    });

    test('Deve retornar erro para mês maior que 12', () {
      expect(
        Validators.validateDate('10/13/2020'),
        'Mês deve ser entre 01 e 12',
      );
    });

    // ---------------------------
    // Falhas - dia inválido
    // ---------------------------
    test('Deve retornar erro para dia menor que 1', () {
      expect(
        Validators.validateDate('00/01/2020'),
        'Dia deve ser entre 01 e 31',
      );
    });

    test('Deve retornar erro para dia maior que o permitido no mês', () {
      expect(
        Validators.validateDate('31/04/2020'),
        'Dia deve ser entre 01 e 30',
      );
    });

    test('Deve retornar erro para 29/02 em ano não bissexto', () {
      expect(
        Validators.validateDate('29/02/2021'),
        'Dia deve ser entre 01 e 28',
      );
    });

    // ---------------------------
    // Falhas - data futura
    // ---------------------------
    test('Deve retornar erro para data futura', () {
      final future = DateTime.now().add(Duration(days: 1));
      final futureDate =
          '${future.day.toString().padLeft(2, '0')}/${future.month.toString().padLeft(2, '0')}/${future.year}';

      expect(
        Validators.validateDate(futureDate),
        'A data não pode ser no futuro',
      );
    });
  });
}