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

    test('deve aceitar CEP no formato válido XXXXX-XXX', () {
      expect(Validators.validateCEP('50740-540'), isNull);
    });

    test('deve rejeitar CEP sem hífen', () {
      expect(Validators.validateCEP('50740540'), isNotNull);
    });

    test('deve rejeitar CEP com letras', () {
      expect(Validators.validateCEP('50A40-540'), isNotNull);
    });

    test('deve rejeitar CEP com tamanho incorreto', () {
      expect(Validators.validateCEP('50740-54'), isNotNull);
    });

    test('deve rejeitar CEP com formato incorreto', () {
      expect(Validators.validateCEP('5074-0540'), isNotNull);
    });
  });
}