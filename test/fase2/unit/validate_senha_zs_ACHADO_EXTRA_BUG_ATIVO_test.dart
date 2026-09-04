import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateSenha', () {
    group('Casos de falha', () {
      test('deve retornar mensagem de erro quando a senha for null', () {
        expect(
          Validators.validateSenha(null),
          'Por favor, insira sua senha',
        );
      });

      test('deve retornar mensagem de erro quando a senha for vazia', () {
        expect(
          Validators.validateSenha(''),
          'Por favor, insira sua senha',
        );
      });

      test('deve retornar mensagem de erro para senha com 1 caractere', () {
        expect(
          Validators.validateSenha('a'),
          'A senha deve ter pelo menos 6 caracteres',
        );
      });

      test('deve retornar mensagem de erro para senha com 6 caracteres', () {
        expect(
          Validators.validateSenha('123456'),
          'A senha deve ter pelo menos 6 caracteres',
        );
      });
    });

    group('Casos de sucesso', () {
      test('deve retornar null para senha com 7 caracteres', () {
        expect(
          Validators.validateSenha('1234567'),
          isNull,
        );
      });

      test('deve retornar null para senha com mais de 7 caracteres', () {
        expect(
          Validators.validateSenha('senha123456'),
          isNull,
        );
      });

      test('deve retornar null para senha contendo caracteres especiais', () {
        expect(
          Validators.validateSenha('abc@123'),
          isNull,
        );
      });
    });

    group('Casos de borda', () {
      test('deve rejeitar senha com exatamente 6 caracteres', () {
        expect(
          Validators.validateSenha('abcdef'),
          'A senha deve ter pelo menos 6 caracteres',
        );
      });

      test('deve aceitar senha com exatamente 7 caracteres', () {
        expect(
          Validators.validateSenha('abcdefg'),
          isNull,
        );
      });

      test('deve aceitar senha contendo espaços', () {
        expect(
          Validators.validateSenha('       '),
          isNull,
        );
      });
    });
  });
}
