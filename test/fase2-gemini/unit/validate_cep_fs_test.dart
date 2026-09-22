import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateCEP', () {
    test('deve retornar erro quando o valor for null', () {
      expect(Validators.validateCEP(null), isNotNull);
    });

    test('deve retornar erro quando o valor for vazio', () {
      expect(Validators.validateCEP(''), isNotNull);
    });

    test('deve aceitar CEP no formato correto XXXXX-XXX', () {
      expect(Validators.validateCEP('50000-000'), isNull);
    });

    test('deve rejeitar CEP com apenas 8 dígitos sem hífen', () {
      expect(Validators.validateCEP('50000000'), isNotNull);
    });

    test('deve rejeitar CEP com hífen na posição errada', () {
      expect(Validators.validateCEP('5000-0000'), isNotNull);
    });

    test('deve rejeitar CEP com caracteres alfabéticos ou especiais', () {
      expect(Validators.validateCEP('5000a-000'), isNotNull);
      expect(Validators.validateCEP('50000-00#'), isNotNull);
    });

    test('deve rejeitar CEP com tamanho menor que 9 caracteres', () {
      expect(Validators.validateCEP('1234-56'), isNotNull);
    });

    test('deve rejeitar CEP com tamanho maior que 9 caracteres', () {
      expect(Validators.validateCEP('50000-0001'), isNotNull);
    });
  });
}

