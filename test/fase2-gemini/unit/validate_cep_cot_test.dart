import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateCEP', () {
    const requiredError = 'O CEP é obrigatório';
    const invalidFormatError = 'CEP inválido. Formato correto: XXXXX-XXX';

    group('Sucesso', () {
      test('deve retornar null para um CEP válido no formato padrão', () {
        final result = Validators.validateCEP('50000-000');
        expect(result, isNull);
      });

      test('deve retornar null para CEP válido com números repetidos', () {
        final result = Validators.validateCEP('11111-111');
        expect(result, isNull);
      });
    });

    group('Validações de Obrigatoriedade', () {
      test('deve retornar mensagem de obrigatoriedade quando o valor for nulo', () {
        final result = Validators.validateCEP(null);
        expect(result, equals(requiredError));
      });

      test('deve retornar mensagem de obrigatoriedade quando o valor for vazio', () {
        final result = Validators.validateCEP('');
        expect(result, equals(requiredError));
      });
    });

    group('Formato Inválido', () {
      test('deve retornar erro quando o CEP não possui máscara (apenas 8 dígitos)', () {
        final result = Validators.validateCEP('50000000');
        expect(result, equals(invalidFormatError));
      });

      test('deve retornar erro quando contiver caracteres alfabéticos', () {
        final result = Validators.validateCEP('5000A-000');
        expect(result, equals(invalidFormatError));
      });

      test('deve retornar erro quando a posição do hífen estiver incorreta', () {
        final result = Validators.validateCEP('5000-0000');
        expect(result, equals(invalidFormatError));
      });

      test('deve retornar erro se o separador não for um hífen', () {
        final result = Validators.validateCEP('50000.000');
        expect(result, equals(invalidFormatError));
      });
    });

    group('Casos de Borda e Limites', () {
      test('deve retornar erro de formato quando contiver apenas espaços em branco', () {
        final result = Validators.validateCEP('         ');
        expect(result, equals(invalidFormatError));
      });

      test('deve retornar erro quando houver espaços extras nas extremidades', () {
        final result = Validators.validateCEP(' 50000-000');
        expect(result, equals(invalidFormatError));
      });

      test('deve retornar erro quando o comprimento for menor que 9 caracteres', () {
        final result = Validators.validateCEP('5000-00');
        expect(result, equals(invalidFormatError));
      });

      test('deve retornar erro quando o comprimento for maior que 9 caracteres', () {
        final result = Validators.validateCEP('50000-0000');
        expect(result, equals(invalidFormatError));
      });
    });
  });
}

