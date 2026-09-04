import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailLogin', () {
    group('Casos de sucesso', () {
      test('deve retornar null para um e-mail válido', () {
        final result = Validators.validateEmailLogin('usuario@email.com');

        expect(result, isNull);
      });

      test('deve aceitar e-mail com subdomínio', () {
        final result =
            Validators.validateEmailLogin('usuario@mail.example.com');

        expect(result, isNull);
      });

      test('deve aceitar e-mail com números e caracteres comuns', () {
        final result =
            Validators.validateEmailLogin('usuario123+teste@example.com');

        expect(result, isNull);
      });

      test('deve aceitar e-mail com hífen no domínio', () {
        final result =
            Validators.validateEmailLogin('usuario@meu-dominio.com');

        expect(result, isNull);
      });
    });

    group('Casos de falha', () {
      test('deve retornar mensagem de campo obrigatório quando value for null', () {
        final result = Validators.validateEmailLogin(null);

        expect(result, 'Por favor, insira seu e-mail');
      });

      test('deve retornar mensagem de campo obrigatório quando value for vazio', () {
        final result = Validators.validateEmailLogin('');

        expect(result, 'Por favor, insira seu e-mail');
      });

      test('deve retornar mensagem de e-mail inválido quando não houver @', () {
        final result = Validators.validateEmailLogin('usuarioemail.com');

        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar mensagem de e-mail inválido quando não houver domínio', () {
        final result = Validators.validateEmailLogin('usuario@');

        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar mensagem de e-mail inválido quando não houver ponto no domínio', () {
        final result = Validators.validateEmailLogin('usuario@email');

        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar mensagem de e-mail inválido quando houver múltiplos @', () {
        final result = Validators.validateEmailLogin('usuario@@email.com');

        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar mensagem de e-mail inválido quando não houver texto antes do @', () {
        final result = Validators.validateEmailLogin('@email.com');

        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar mensagem de e-mail inválido quando não houver texto entre @ e ponto', () {
        final result = Validators.validateEmailLogin('usuario@.com');

        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar mensagem de e-mail inválido quando não houver texto após o ponto', () {
        final result = Validators.validateEmailLogin('usuario@email.');

        expect(result, 'Por favor, insira um e-mail válido');
      });
    });

    group('Casos de borda', () {
      test('deve aceitar domínio com apenas um caractere após o ponto', () {
        final result = Validators.validateEmailLogin('usuario@email.c');

        expect(result, isNull);
      });

      test('deve aceitar e-mail com múltiplos níveis de domínio', () {
        final result =
            Validators.validateEmailLogin('usuario@sub.exemplo.com');

        expect(result, isNull);
      });

      test('deve retornar mensagem de e-mail inválido para apenas @', () {
        final result = Validators.validateEmailLogin('@');

        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar mensagem de e-mail inválido para apenas texto', () {
        final result = Validators.validateEmailLogin('usuario');

        expect(result, 'Por favor, insira um e-mail válido');
      });
    });
  });
}
