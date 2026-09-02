import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateSenha', () {
    group('falhas', () {
      test('deve rejeitar senha nula', () {
        expect(
          Validators.validateSenha(null),
          equals('Por favor, insira sua senha'),
        );
      });

      test('deve rejeitar senha vazia', () {
        expect(
          Validators.validateSenha(''),
          equals('Por favor, insira sua senha'),
        );
      });

      test('deve rejeitar senha com 1 caractere', () {
        expect(
          Validators.validateSenha('a'),
          equals('A senha deve ter pelo menos 6 caracteres'),
        );
      });

      test('deve rejeitar senha com 5 caracteres', () {
        expect(
          Validators.validateSenha('abcde'),
          equals('A senha deve ter pelo menos 6 caracteres'),
        );
      });

      test('deve rejeitar senha com 6 caracteres', () {
        expect(
          Validators.validateSenha('abcdef'),
          equals('A senha deve ter pelo menos 6 caracteres'),
        );
      });
    });

    group('sucesso', () {
      test('deve aceitar senha com 7 caracteres', () {
        expect(
          Validators.validateSenha('abcdefg'),
          isNull,
        );
      });

      test('deve aceitar senha com mais de 7 caracteres', () {
        expect(
          Validators.validateSenha('senha123'),
          isNull,
        );
      });

      test('deve aceitar senha contendo espaços', () {
        expect(
          Validators.validateSenha('abc def'),
          isNull,
        );
      });

      test('deve aceitar senha contendo caracteres especiais', () {
        expect(
          Validators.validateSenha('a@#1234'),
          isNull,
        );
      });
    });

    group('casos de borda', () {
      test('deve considerar exatamente 6 caracteres como inválida', () {
        const senha = '123456';

        expect(senha.length, equals(6));
        expect(
          Validators.validateSenha(senha),
          equals('A senha deve ter pelo menos 6 caracteres'),
        );
      });

      test('deve considerar exatamente 7 caracteres como válida', () {
        const senha = '1234567';

        expect(senha.length, equals(7));
        expect(
          Validators.validateSenha(senha),
          isNull,
        );
      });

      test('deve aceitar senha com caracteres Unicode', () {
        expect(
          Validators.validateSenha('áéíóúçã123'),
          isNull,
        );
      });
    });
  });
}
