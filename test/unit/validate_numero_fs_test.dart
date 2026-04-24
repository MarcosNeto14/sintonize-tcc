import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateNumero', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateNumero(null), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateNumero(''), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor não é numérico', () {
      expect(Validators.validateNumero('abc'), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor contém caracteres mistos', () {
      expect(Validators.validateNumero('123abc'), isNotNull);
    });

    test('deve retornar null quando valor é numérico válido', () {
      expect(Validators.validateNumero('123'), isNull);
    });

    test('deve aceitar números negativos', () {
      expect(Validators.validateNumero('-123'), isNull);
    });
  });
}