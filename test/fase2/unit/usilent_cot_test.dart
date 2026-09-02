import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateSenha', () {
    group('Cenários de falha', () {
      test('deve rejeitar senha nula', () {
        expect(
          Validators.validateSenha(null),
          'Por favor, insira sua senha',
        );
      });

      test('deve rejeitar senha vazia', () {
        expect(
          Validators.validateSenha(''),
          'Por favor, insira sua senha',
        );
      });

      test('deve rejeitar senha com 1 caractere', () {
        expect(
          Validators.validateSenha('a'),
          'A senha deve ter pelo menos 6 caracteres',
        );
      });

      test('deve rejeitar senha com 6 caracteres', () {
        expect(
          Validators.validateSenha('123456'),
          'A senha deve ter pelo menos 6 caracteres',
        );
      });
    });

    group('Cenários de sucesso', () {
      test('deve aceitar senha com exatamente 7 caracteres', () {
        expect(
          Validators.validateSenha('1234567'),
          isNull,
        );
      });

      test('deve aceitar senha com mais de 7 caracteres', () {
        expect(
          Validators.validateSenha('senha123456'),
          isNull,
        );
      });

      test('deve aceitar senha contendo letras, números e símbolos', () {
        expect(
          Validators.validateSenha('Abc123!'),
          isNull,
        );
      });

      test('deve aceitar senha com espaços quando possui tamanho suficiente', () {
        expect(
          Validators.validateSenha('senha 1'),
          isNull,
        );
      });

      test('deve aceitar senha composta somente por espaços quando possui '
          '7 caracteres', () {
        expect(
          Validators.validateSenha('       '),
          isNull,
        );
      });

      test('deve aceitar senha com caracteres Unicode quando length '
          'for suficiente', () {
        expect(
          Validators.validateSenha('áéíóúab'),
          isNull,
        );
      });
    });

    group('Casos de borda', () {
      test('deve rejeitar senha no limite de 6 caracteres', () {
        expect(
          Validators.validateSenha('abcdef'),
          'A senha deve ter pelo menos 6 caracteres',
        );
      });

      test('deve aceitar senha no limite de 7 caracteres', () {
        expect(
          Validators.validateSenha('abcdefg'),
          isNull,
        );
      });

      test('deve aceitar senha muito longa', () {
        final senha = 'a' * 1000;

        expect(
          Validators.validateSenha(senha),
          isNull,
        );
      });

      test('deve considerar o comprimento UTF-16 de caracteres Unicode', () {
        final senha = '😀😀😀😀';

        // Cada emoji ocupa 2 unidades de código UTF-16 em String.length.
        // Portanto, o comprimento dessa string é 8 e a senha é aceita.
        expect(senha.length, 8);
        expect(
          Validators.validateSenha(senha),
          isNull,
        );
      });
    });
  });
}
