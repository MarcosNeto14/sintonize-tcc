import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailLogin', () {
    group('Cenários de sucesso', () {
      test('deve retornar null para um e-mail válido', () {
        const value = 'usuario@example.com';

        final result = Validators.validateEmailLogin(value);

        expect(result, isNull);
      });

      test('deve retornar null para e-mail com subdomínio', () {
        const value = 'usuario@mail.example.com';

        final result = Validators.validateEmailLogin(value);

        expect(result, isNull);
      });

      test('deve retornar null para e-mail com ponto antes do @', () {
        const value = 'nome.sobrenome@example.com';

        final result = Validators.validateEmailLogin(value);

        expect(result, isNull);
      });

      test('deve retornar null para e-mail contendo números', () {
        const value = 'usuario123@example.com';

        final result = Validators.validateEmailLogin(value);

        expect(result, isNull);
      });

      test('deve retornar null para e-mail com caracteres especiais', () {
        const value = 'nome+teste@example.com';

        final result = Validators.validateEmailLogin(value);

        expect(result, isNull);
      });
    });

    group('Cenários de falha', () {
      test('deve retornar mensagem de campo obrigatório quando valor for null', () {
        final result = Validators.validateEmailLogin(null);

        expect(result, 'Por favor, insira seu e-mail');
      });

      test('deve retornar mensagem de campo obrigatório quando valor for vazio', () {
        final result = Validators.validateEmailLogin('');

        expect(result, 'Por favor, insira seu e-mail');
      });

      test('deve retornar mensagem de e-mail inválido quando não houver @', () {
        const value = 'usuarioexample.com';

        final result = Validators.validateEmailLogin(value);

        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar mensagem de e-mail inválido quando não houver domínio', () {
        const value = 'usuario@';

        final result = Validators.validateEmailLogin(value);

        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar mensagem de e-mail inválido quando não houver extensão', () {
        const value = 'usuario@example';

        final result = Validators.validateEmailLogin(value);

        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar mensagem de e-mail inválido quando @ estiver no início', () {
        const value = '@example.com';

        final result = Validators.validateEmailLogin(value);

        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar mensagem de e-mail inválido quando não houver conteúdo após o ponto', () {
        const value = 'usuario@example.';

        final result = Validators.validateEmailLogin(value);

        expect(result, 'Por favor, insira um e-mail válido');
      });
    });

    group('Casos de borda', () {
      test('deve rejeitar uma string contendo apenas espaços', () {
        const value = ' ';

        final result = Validators.validateEmailLogin(value);

        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve rejeitar e-mail contendo espaço no domínio', () {
        const value = 'usuario@exam ple.com';

        final result = Validators.validateEmailLogin(value);

        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve rejeitar e-mail com dois @ consecutivos', () {
        const value = 'usuario@@example.com';

        final result = Validators.validateEmailLogin(value);

        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve aceitar ponto imediatamente antes do @ conforme regex atual', () {
        const value = 'usuario.@example.com';

        final result = Validators.validateEmailLogin(value);

        expect(result, isNull);
      });

      test('deve aceitar ponto imediatamente depois do @ conforme regex atual', () {
        const value = 'usuario@.example.com';

        final result = Validators.validateEmailLogin(value);

        expect(result, isNull);
      });

      test('deve aceitar texto após um e-mail válido conforme regex atual', () {
        const value = 'usuario@example.com texto-extra';

        final result = Validators.validateEmailLogin(value);

        expect(result, isNull);
      });

      test('deve aceitar e-mail com domínio contendo múltiplos níveis', () {
        const value = 'usuario@subdominio.exemplo.com.br';

        final result = Validators.validateEmailLogin(value);

        expect(result, isNull);
      });
    });
  });
}
