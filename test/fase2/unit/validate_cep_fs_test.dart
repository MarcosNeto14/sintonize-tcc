import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateCEP', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateCEP(null), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateCEP(''), isNotNull);
    });

    test('deve aceitar CEP no formato XXXXX-XXX', () {
      expect(Validators.validateCEP('12345-678'), isNull);
    });

    test('deve rejeitar CEP sem hífen', () {
      expect(Validators.validateCEP('12345678'), isNotNull);
    });

    test('deve rejeitar CEP com poucos dígitos', () {
      expect(Validators.validateCEP('1234-567'), isNotNull);
    });

    test('deve rejeitar CEP com muitos dígitos', () {
      expect(Validators.validateCEP('123456-789'), isNotNull);
    });

    test('deve rejeitar CEP contendo letras', () {
      expect(Validators.validateCEP('1234A-678'), isNotNull);
    });
  });
}
