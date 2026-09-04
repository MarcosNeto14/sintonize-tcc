import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateNumero', () {
    group('Cenários de falha', () {
      test('deve retornar mensagem de obrigatório quando o valor for null', () {
        expect(
          Validators.validateNumero(null),
          'O número é obrigatório',
        );
      });

      test('deve retornar mensagem de obrigatório quando o valor for vazio', () {
        expect(
          Validators.validateNumero(''),
          'O número é obrigatório',
        );
      });

      test('deve retornar mensagem de erro para texto não numérico', () {
        expect(
          Validators.validateNumero('abc'),
          'O número deve ser numérico',
        );
      });

      test('deve retornar mensagem de erro para texto parcialmente numérico', () {
        expect(
          Validators.validateNumero('123abc'),
          'O número deve ser numérico',
        );
      });

      test('deve retornar mensagem de erro para número decimal', () {
        expect(
          Validators.validateNumero('12.5'),
          'O número deve ser numérico',
        );
      });

      test('deve retornar mensagem de erro para string contendo apenas espaços', () {
        expect(
          Validators.validateNumero(' '),
          'O número deve ser numérico',
        );
      });

      test('deve retornar mensagem de erro para sinal positivo isolado', () {
        expect(
          Validators.validateNumero('+'),
          'O número deve ser numérico',
        );
      });

      test('deve retornar mensagem de erro para sinal negativo isolado', () {
        expect(
          Validators.validateNumero('-'),
          'O número deve ser numérico',
        );
      });
    });

    group('Cenários de sucesso', () {
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

      test('deve retornar null para número com zeros à esquerda', () {
        expect(
          Validators.validateNumero('00123'),
          isNull,
        );
      });

      test('deve retornar null para -0', () {
        expect(
          Validators.validateNumero('-0'),
          isNull,
        );
      });

      test('deve retornar null para um inteiro grande dentro do limite da plataforma', () {
        expect(
          Validators.validateNumero('9223372036854775807'),
          isNull,
        );
      });

      test('deve retornar null para número com espaços ao redor', () {
        expect(
          Validators.validateNumero(' 123 '),
          isNull,
        );
      });

      test('deve retornar null para número seguido de quebra de linha', () {
        expect(
          Validators.validateNumero('123\n'),
          isNull,
        );
      });
    });

    group('Casos de borda', () {
      test('deve rejeitar um valor maior que o limite de int de 64 bits', () {
        expect(
          Validators.validateNumero('9223372036854775808'),
          'O número deve ser numérico',
        );
      });

      test('deve rejeitar um valor menor que o limite de int de 64 bits', () {
        expect(
          Validators.validateNumero('-9223372036854775809'),
          'O número deve ser numérico',
        );
      });

      test('deve rejeitar uma string contendo apenas um ponto', () {
        expect(
          Validators.validateNumero('.'),
          'O número deve ser numérico',
        );
      });
    });
  });
}
