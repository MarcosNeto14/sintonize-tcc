import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmail', () {
    group('sucesso', () {
      test('deve retornar null para um e-mail válido', () {
        const email = 'usuario@example.com';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve aceitar e-mail com números', () {
        const email = 'usuario123@example.com';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve aceitar caracteres permitidos antes do @', () {
        const email = 'nome.sobrenome+teste@example.com';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve aceitar domínio com subdomínio', () {
        const email = 'usuario@mail.example.com';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve aceitar domínio com hífen', () {
        const email = 'usuario@meu-dominio.com';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve aceitar domínio com TLD de dois caracteres', () {
        const email = 'usuario@example.br';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });

      test('deve aceitar TLD com mais de dois caracteres', () {
        const email = 'usuario@example.com.br';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });
    });

    group('falha', () {
      test('deve retornar mensagem de obrigatório quando o valor for null', () {
        final result = Validators.validateEmail(null);

        expect(result, 'O e-mail é obrigatório');
      });

      test('deve retornar mensagem de obrigatório quando o valor estiver vazio', () {
        final result = Validators.validateEmail('');

        expect(result, 'O e-mail é obrigatório');
      });

      test('deve rejeitar e-mail sem @', () {
        const email = 'usuarioexample.com';

        final result = Validators.validateEmail(email);

        expect(result, 'E-mail inválido');
      });

      test('deve rejeitar e-mail sem domínio', () {
        const email = 'usuario@';

        final result = Validators.validateEmail(email);

        expect(result, 'E-mail inválido');
      });

      test('deve rejeitar e-mail sem parte local', () {
        const email = '@example.com';

        final result = Validators.validateEmail(email);

        expect(result, 'E-mail inválido');
      });

      test('deve rejeitar e-mail sem extensão', () {
        const email = 'usuario@example';

        final result = Validators.validateEmail(email);

        expect(result, 'E-mail inválido');
      });

      test('deve rejeitar TLD com apenas um caractere', () {
        const email = 'usuario@example.c';

        final result = Validators.validateEmail(email);

        expect(result, 'E-mail inválido');
      });

      test('deve rejeitar e-mail com espaços', () {
        const email = 'usuario @example.com';

        final result = Validators.validateEmail(email);

        expect(result, 'E-mail inválido');
      });

      test('deve rejeitar e-mail com dois @', () {
        const email = 'usuario@@example.com';

        final result = Validators.validateEmail(email);

        expect(result, 'E-mail inválido');
      });

      test('deve rejeitar e-mail que começa com @', () {
        const email = '@usuario.com';

        final result = Validators.validateEmail(email);

        expect(result, 'E-mail inválido');
      });

      test('deve rejeitar e-mail que termina com @', () {
        const email = 'usuario@';

        final result = Validators.validateEmail(email);

        expect(result, 'E-mail inválido');
      });
    });

    group('casos de borda', () {
      test('deve rejeitar e-mail contendo apenas espaços', () {
        const email = '   ';

        final result = Validators.validateEmail(email);

        expect(result, 'E-mail inválido');
      });

      test('deve rejeitar e-mail com espaço no início', () {
        const email = ' usuario@example.com';

        final result = Validators.validateEmail(email);

        expect(result, 'E-mail inválido');
      });

      test('deve rejeitar e-mail com espaço no final', () {
        const email = 'usuario@example.com ';

        final result = Validators.validateEmail(email);

        expect(result, 'E-mail inválido');
      });

      test('deve rejeitar domínio sem TLD válido', () {
        const email = 'usuario@example.c';

        final result = Validators.validateEmail(email);

        expect(result, 'E-mail inválido');
      });

      test('deve rejeitar caracteres não permitidos', () {
        const email = 'usuário@example.com';

        final result = Validators.validateEmail(email);

        expect(result, 'E-mail inválido');
      });

      test('deve rejeitar e-mail com ponto após o @ sem domínio válido', () {
        const email = 'usuario@.com';

        final result = Validators.validateEmail(email);

        expect(result, 'E-mail inválido');
      });

      test('deve aceitar o menor TLD permitido pelo padrão', () {
        const email = 'a@b.co';

        final result = Validators.validateEmail(email);

        expect(result, isNull);
      });
    });
  });
}
