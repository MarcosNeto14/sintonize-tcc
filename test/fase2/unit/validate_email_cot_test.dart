import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmail', () {
    group('Cenários de sucesso', () {
      test('deve retornar null para um e-mail simples e válido', () {
        const email = 'usuario@example.com';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve retornar null para e-mail contendo números', () {
        const email = 'usuario123@example.com';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve retornar null para e-mail com caracteres permitidos', () {
        const email = 'user.name+tag_123-test%value@example.com';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve retornar null para domínio contendo hífen', () {
        const email = 'usuario@meu-dominio.com';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve retornar null para domínio contendo múltiplos níveis', () {
        const email = 'usuario@mail.example.com';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve retornar null para TLD com exatamente 2 caracteres', () {
        const email = 'usuario@example.co';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve retornar null para TLD com mais de 2 caracteres', () {
        const email = 'usuario@example.com.br';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve aceitar letras maiúsculas e minúsculas', () {
        const email = 'Usuario@Example.COM';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });
    });

    group('Cenários de falha', () {
      test('deve retornar mensagem de obrigatório quando o valor for null', () {
        final result = Validators.validateEmail(null);

        expect(result, equals('O e-mail é obrigatório'));
      });

      test('deve retornar mensagem de obrigatório quando o valor for vazio', () {
        final result = Validators.validateEmail('');

        expect(result, equals('O e-mail é obrigatório'));
      });

      test('deve retornar e-mail inválido quando não houver @', () {
        const email = 'usuarioexample.com';

        final result = Validators.validateEmail(email);

        expect(result, equals('E-mail inválido'));
      });

      test('deve retornar e-mail inválido quando não houver domínio', () {
        const email = 'usuario@';

        final result = Validators.validateEmail(email);

        expect(result, equals('E-mail inválido'));
      });

      test('deve retornar e-mail inválido quando não houver TLD', () {
        const email = 'usuario@example';

        final result = Validators.validateEmail(email);

        expect(result, equals('E-mail inválido'));
      });

      test('deve retornar e-mail inválido quando o TLD tiver apenas um caractere', () {
        const email = 'usuario@example.c';

        final result = Validators.validateEmail(email);

        expect(result, equals('E-mail inválido'));
      });

      test('deve retornar e-mail inválido quando houver espaços', () {
        const email = 'usuario @example.com';

        final result = Validators.validateEmail(email);

        expect(result, equals('E-mail inválido'));
      });

      test('deve retornar e-mail inválido quando houver caracteres não permitidos', () {
        const email = 'usuário@example.com';

        final result = Validators.validateEmail(email);

        expect(result, equals('E-mail inválido'));
      });

      test('deve retornar e-mail inválido quando houver mais de um @', () {
        const email = 'usuario@@example.com';

        final result = Validators.validateEmail(email);

        expect(result, equals('E-mail inválido'));
      });

      test('deve retornar e-mail inválido para string contendo apenas espaços', () {
        const email = ' ';

        final result = Validators.validateEmail(email);

        expect(result, equals('E-mail inválido'));
      });
    });

    group('Casos de borda', () {
      test('deve aceitar o menor TLD permitido pela expressão regular', () {
        const email = 'a@b.co';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve aceitar TLD longo', () {
        const email = 'usuario@example.technology';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve aceitar vários pontos no domínio', () {
        const email = 'usuario@mail.sub.example.com';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve aceitar caracteres permitidos em posições diferentes do usuário', () {
        const email = 'a.b_c-d+e%f@example.com';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve rejeitar e-mail com espaço no final', () {
        const email = 'usuario@example.com ';

        final result = Validators.validateEmail(email);

        expect(result, equals('E-mail inválido'));
      });

      test('deve rejeitar e-mail com espaço no início', () {
        const email = ' usuario@example.com';

        final result = Validators.validateEmail(email);

        expect(result, equals('E-mail inválido'));
      });
    });
  });
}
