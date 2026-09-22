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

    test('deve rejeitar valor que contém letras ou caracteres especiais', () {
      expect(Validators.validateNumero('12a4'), isNotNull);
      expect(Validators.validateNumero('12#4'), isNotNull);
    });

    test('deve rejeitar valor com casas decimais', () {
      expect(Validators.validateNumero('12.5'), isNotNull);
    });

    test('deve retornar null quando valor é um número inteiro válido', () {
      expect(Validators.validateNumero('123'), isNull);
    });

    test('deve retornar null quando valor é zero ou número negativo válido', () {
      expect(Validators.validateNumero('0'), isNull);
      expect(Validators.validateNumero('-10'), isNull);
    });
  });
}

