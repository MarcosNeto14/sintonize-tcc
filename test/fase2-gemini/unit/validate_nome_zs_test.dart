import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateNome', () {
    group('Cenários de Sucesso (nomes válidos)', () {
      test('deve retornar null para nome simples sem acento', () {
        final result = Validators.validateNome('João');
        expect(result, isNull);
      });

      test('deve retornar null para nome completo composto com espaços', () {
        final result = Validators.validateNome('Maria Silva Sauro');
        expect(result, isNull);
      });

      test('deve retornar null para nomes contendo caracteres acentuados comuns (á, é, í, ó, ú, ç, ã)', () {
        final result = Validators.validateNome('Érika Conceição Ângelo');
        expect(result, isNull);
      });

      test('deve aceitar letras maiúsculas e minúsculas misturadas', () {
        final result = Validators.validateNome('mArIa eDuArDa');
        expect(result, isNull);
      });
    });

    group('Cenários de Falha - Campo obrigatório', () {
      test('deve retornar mensagem de obrigatoriedade quando o valor for null', () {
        final result = Validators.validateNome(null);
        expect(result, equals('O nome é obrigatório'));
      });

      test('deve retornar mensagem de obrigatoriedade quando o valor for string vazia', () {
        final result = Validators.validateNome('');
        expect(result, equals('O nome é obrigatório'));
      });
    });

    group('Cenários de Falha - Caracteres inválidos', () {
      test('deve rejeitar nomes contendo números', () {
        final result = Validators.validateNome('João 123');
        expect(result, equals('O nome não pode conter números ou caracteres especiais'));
      });

      test('deve rejeitar caracteres especiais comuns (@, #, \$, %)', () {
        final result = Validators.validateNome('Lucas@Dev');
        expect(result, equals('O nome não pode conter números ou caracteres especiais'));
      });

      test('deve rejeitar pontuações como pontos, vírgulas e hífens', () {
        // Observação: hífens e apóstrofos (como em D'Ávila ou Jean-Luc)
        // não estão incluídos na regex atual [^a-zA-ZÀ-ÿ\s]
        final resultComPonto = Validators.validateNome('Dr. Silva');
        final resultComHifen = Validators.validateNome('Jean-Paul');
        final resultComApostrofo = Validators.validateNome("D'Ávila");

        expect(resultComPonto, equals('O nome não pode conter números ou caracteres especiais'));
        expect(resultComHifen, equals('O nome não pode conter números ou caracteres especiais'));
        expect(resultComApostrofo, equals('O nome não pode conter números ou caracteres especiais'));
      });

      test('deve rejeitar emojis', () {
        final result = Validators.validateNome('Carlos 🚀');
        expect(result, equals('O nome não pode conter números ou caracteres especiais'));
      });
    });

    group('Casos de borda', () {
      test('deve aceitar uma única letra válida', () {
        final result = Validators.validateNome('A');
        expect(result, isNull);
      });

      test('comportamento com apenas espaços em branco', () {
        // Como o regex permite whitespace (\s) e não há trim() antes de isEmpty,
        // uma string com apenas espaços passa na validação atual
        final result = Validators.validateNome('   ');
        expect(result, isNull);
      });

      test('deve aceitar múltiplos espaços e tabulações internas', () {
        final result = Validators.validateNome("Ana   Beatriz\tLima");
        expect(result, isNull);
      });
    });
  });
}

