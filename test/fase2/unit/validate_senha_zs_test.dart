import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateSenha', () {
    group('Falhas de validação', () {
      test('deve retornar mensagem de erro quando a senha for null', () {
        expect(
          Validators.validateSenha(null),
          'Por favor, insira sua senha',
        );
      });

      test('deve retornar mensagem de erro quando a senha estiver vazia', () {
        expect(
          Validators.validateSenha(''),
          'Por favor, insira sua senha',
        );
      });

      test('deve retornar mensagem de erro quando a senha tiver menos de 6 caracteres', () {
        expect(
          Validators.validateSenha('12345'),
          'A senha deve ter pelo menos 6 caracteres',
        );
      });

      test('deve retornar mensagem de erro para uma senha com apenas 1 caractere', () {
        expect(
          Validators.validateSenha('a'),
          'A senha deve ter pelo menos 6 caracteres',
        );
      });
    });

    group('Sucesso de validação', () {
      test('deve retornar null quando a senha tiver exatamente 6 caracteres', () {
        expect(
          Validators.validateSenha('123456'),
          isNull,
        );
      });

      test('deve retornar null quando a senha tiver mais de 6 caracteres', () {
        expect(
          Validators.validateSenha('1234567'),
          isNull,
        );
      });

      test('deve retornar null quando a senha contiver letras, números e símbolos', () {
        expect(
          Validators.validateSenha('Abc@123'),
          isNull,
        );
      });

      test('deve retornar null quando a senha contiver espaços', () {
        expect(
          Validators.validateSenha('abc 12'),
          isNull,
        );
      });
    });
  });
}
