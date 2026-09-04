import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateNumero', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(
        Validators.validateNumero(null),
        'O número é obrigatório',
      );
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(
        Validators.validateNumero(''),
        'O número é obrigatório',
      );
    });

    test('deve retornar mensagem de erro quando valor não é numérico', () {
      expect(
        Validators.validateNumero('abc'),
        'O número deve ser numérico',
      );
    });

    test('deve retornar null quando valor é numérico', () {
      expect(
        Validators.validateNumero('123'),
        isNull,
      );
    });
  });
}
