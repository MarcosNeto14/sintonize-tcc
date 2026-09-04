import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateNumero', () {
    group('quando o valor é obrigatório', () {
      test('deve retornar erro quando o valor for null', () {
        expect(
          Validators.validateNumero(null),
          'O número é obrigatório',
        );
      });

      test('deve retornar erro quando o valor for vazio', () {
        expect(
          Validators.validateNumero(''),
          'O número é obrigatório',
        );
      });
    });

    group('quando o valor não é numérico', () {
      test('deve retornar erro para texto', () {
        expect(
          Validators.validateNumero('abc'),
          'O número deve ser numérico',
        );
      });

      test('deve retornar erro para caracteres especiais', () {
        expect(
          Validators.validateNumero('@#\$%'),
          'O número deve ser numérico',
        );
      });

      test('deve retornar erro para número decimal', () {
        expect(
          Validators.validateNumero('10.5'),
          'O número deve ser numérico',
        );
      });

      test('deve retornar erro para valor contendo apenas espaços', () {
        expect(
          Validators.validateNumero('   '),
          'O número deve ser numérico',
        );
      });
    });

    group('quando o valor é numérico', () {
      test('deve retornar null para um número inteiro positivo', () {
        expect(
          Validators.validateNumero('123'),
          isNull,
        );
      });

      test('deve retornar null para zero', () {
        expect(
          Validators.validateNumero('0'),
          isNull,
        );
      });

      test('deve retornar null para um número inteiro negativo', () {
        expect(
          Validators.validateNumero('-123'),
          isNull,
        );
      });

      test('deve retornar null para o maior inteiro suportado pelo Dart', () {
        expect(
          Validators.validateNumero('9223372036854775807'),
          isNull,
        );
      });

      test('deve retornar null para número com espaço no final', () {
        expect(
          Validators.validateNumero('123 '),
          isNull,
        );
      });
    });

    group('casos de borda', () {
      test('deve retornar null para uma string contendo um único dígito', () {
        expect(
          Validators.validateNumero('1'),
          isNull,
        );
      });

      test('deve retornar erro para uma string contendo apenas espaços', () {
        expect(
          Validators.validateNumero('   '),
          'O número deve ser numérico',
        );
      });

      test('deve retornar erro para uma string com sinal sem número', () {
        expect(
          Validators.validateNumero('-'),
          'O número deve ser numérico',
        );
      });

      test('deve retornar null para número com zeros à esquerda', () {
        expect(
          Validators.validateNumero('00123'),
          isNull,
        );
      });
    });
  });
}
