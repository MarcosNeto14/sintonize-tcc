import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateNumero', () {
    group('Cenários de Sucesso', () {
      test('deve retornar null para um número inteiro positivo comum', () {
        final result = Validators.validateNumero('42');
        expect(result, isNull);
      });

      test('deve retornar null para o valor zero', () {
        final result = Validators.validateNumero('0');
        expect(result, isNull);
      });

      test('deve retornar null para um número inteiro negativo', () {
        final result = Validators.validateNumero('-15');
        expect(result, isNull);
      });
    });

    group('Cenários de Falha - Obrigatoriedade', () {
      test('deve retornar mensagem de obrigatoriedade quando o valor for nulo', () {
        final result = Validators.validateNumero(null);
        expect(result, 'O número é obrigatório');
      });

      test('deve retornar mensagem de obrigatoriedade quando a string for vazia', () {
        final result = Validators.validateNumero('');
        expect(result, 'O número é obrigatório');
      });
    });

    group('Cenários de Falha - Formato Numérico', () {
      test('deve retornar mensagem de erro quando contiver apenas letras', () {
        final result = Validators.validateNumero('abc');
        expect(result, 'O número deve ser numérico');
      });

      test('deve retornar mensagem de erro quando contiver caracteres alfanuméricos mistos', () {
        final result = Validators.validateNumero('123a');
        expect(result, 'O número deve ser numérico');
      });

      test('deve retornar mensagem de erro quando contiver caracteres especiais', () {
        final result = Validators.validateNumero('!@#\$%');
        expect(result, 'O número deve ser numérico');
      });
    });

    group('Casos de Borda e Entradas Inesperadas', () {
      test('deve retornar erro de formato quando contiver apenas espaços em branco', () {
        final result = Validators.validateNumero('   ');
        expect(result, 'O número deve ser numérico');
      });

      test('deve retornar erro de formato para número com casas decimais (ponto)', () {
        final result = Validators.validateNumero('10.5');
        expect(result, 'O número deve ser numérico');
      });

      test('deve retornar erro de formato para número com casas decimais (vírgula)', () {
        final result = Validators.validateNumero('10,5');
        expect(result, 'O número deve ser numérico');
      });

      test('deve aceitar número com espaços no início ou no fim (comportamento nativo de int.tryParse)', () {
        final result = Validators.validateNumero(' 10 ');
        expect(result, isNull);
      });

      test('deve retornar null para um número inteiro longo no limite de 64 bits', () {
        final result = Validators.validateNumero('9223372036854775807');
        expect(result, isNull);
      });
    });
  });
}

