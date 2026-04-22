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

    test('deve aceitar número com espaço (int.tryParse permite)', () {
      final result = Validators.validateNumero(' 123');

      expect(result, isNull);
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