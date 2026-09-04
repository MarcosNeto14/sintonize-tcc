import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateCEP', () {
    group('sucesso', () {
      test('deve retornar null para um CEP válido', () {
        expect(Validators.validateCEP('12345-678'), isNull);
      });

      test('deve aceitar CEP válido com zeros', () {
        expect(Validators.validateCEP('00000-000'), isNull);
      });

      test('deve aceitar CEP válido com dígitos variados', () {
        expect(Validators.validateCEP('98765-432'), isNull);
      });
    });

    group('falha', () {
      test('deve retornar erro quando o valor for null', () {
        expect(
          Validators.validateCEP(null),
          'O CEP é obrigatório',
        );
      });

      test('deve retornar erro quando o valor estiver vazio', () {
        expect(
          Validators.validateCEP(''),
          'O CEP é obrigatório',
        );
      });

      test('deve retornar erro quando o CEP não tiver hífen', () {
        expect(
          Validators.validateCEP('12345678'),
          'CEP inválido. Formato correto: XXXXX-XXX',
        );
      });

      test('deve retornar erro quando o CEP tiver quantidade incorreta de dígitos', () {
        expect(
          Validators.validateCEP('1234-5678'),
          'CEP inválido. Formato correto: XXXXX-XXX',
        );
      });

      test('deve retornar erro quando houver letras no CEP', () {
        expect(
          Validators.validateCEP('1234A-678'),
          'CEP inválido. Formato correto: XXXXX-XXX',
        );
      });

      test('deve retornar erro quando o hífen estiver na posição incorreta', () {
        expect(
          Validators.validateCEP('1234-56789'),
          'CEP inválido. Formato correto: XXXXX-XXX',
        );
      });

      test('deve retornar erro quando houver espaços', () {
        expect(
          Validators.validateCEP('12345 -678'),
          'CEP inválido. Formato correto: XXXXX-XXX',
        );
      });

      test('deve retornar erro quando houver caracteres extras', () {
        expect(
          Validators.validateCEP('12345-6780'),
          'CEP inválido. Formato correto: XXXXX-XXX',
        );
      });

      test('deve retornar erro para CEP com hífen duplicado', () {
        expect(
          Validators.validateCEP('12345--678'),
          'CEP inválido. Formato correto: XXXXX-XXX',
        );
      });
    });

    group('casos de borda', () {
      test('deve aceitar exatamente 9 caracteres no formato correto', () {
        const cep = '12345-678';

        expect(cep.length, 9);
        expect(Validators.validateCEP(cep), isNull);
      });

      test('deve rejeitar CEP com um caractere a menos', () {
        expect(
          Validators.validateCEP('12345-67'),
          'CEP inválido. Formato correto: XXXXX-XXX',
        );
      });

      test('deve rejeitar CEP com um caractere a mais', () {
        expect(
          Validators.validateCEP('12345-6789'),
          'CEP inválido. Formato correto: XXXXX-XXX',
        );
      });

      test('deve rejeitar CEP contendo quebra de linha', () {
        expect(
          Validators.validateCEP('12345-678\n'),
          'CEP inválido. Formato correto: XXXXX-XXX',
        );
      });
    });
  });
}
