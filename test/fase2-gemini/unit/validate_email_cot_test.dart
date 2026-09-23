import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmail', () {
    group('Obrigatoriedade e valores vazios/nulos', () {
      test('deve retornar mensagem de obrigatoriedade quando o valor for nulo', () {
        final result = Validators.validateEmail(null);
        expect(result, 'O e-mail é obrigatório');
      });

      test('deve retornar mensagem de obrigatoriedade quando a string for vazia', () {
        final result = Validators.validateEmail('');
        expect(result, 'O e-mail é obrigatório');
      });
    });

    group('Cenários de sucesso (e-mails válidos)', () {
      test('deve retornar null para e-mail padrão simples', () {
        final result = Validators.validateEmail('usuario@dominio.com');
        expect(result, isNull);
      });

      test('deve retornar null para e-mail com subdomínio e múltiplos pontos', () {
        final result = Validators.validateEmail('contato@mail.servidor.com.br');
        expect(result, isNull);
      });

      test('deve retornar null para e-mail com caracteres especiais permitidos (+, ., _, -, %)', () {
        final result = Validators.validateEmail('user.name+tag_100%test-dev@dominio.org');
        expect(result, isNull);
      });

      test('deve retornar null para domínios de primeiro nível (TLD) longos', () {
        final result = Validators.validateEmail('developer@startup.technology');
        expect(result, isNull);
      });

      test('deve retornar null para e-mails contendo números no usuário e no domínio', () {
        final result = Validators.validateEmail('12345@dominio123.co');
        expect(result, isNull);
      });
    });

    group('Cenários de falha (e-mails inválidos)', () {
      test('deve retornar "E-mail inválido" quando não contiver o caractere "@"', () {
        final result = Validators.validateEmail('usuariodominio.com');
        expect(result, 'E-mail inválido');
      });

      test('deve retornar "E-mail inválido" quando não contiver nome de usuário antes do "@"', () {
        final result = Validators.validateEmail('@dominio.com');
        expect(result, 'E-mail inválido');
      });

      test('deve retornar "E-mail inválido" quando não contiver o domínio após o "@"', () {
        final result = Validators.validateEmail('usuario@');
        expect(result, 'E-mail inválido');
      });

      test('deve retornar "E-mail inválido" quando o TLD tiver menos de 2 caracteres', () {
        final result = Validators.validateEmail('usuario@dominio.c');
        expect(result, 'E-mail inválido');
      });

      test('deve retornar "E-mail inválido" quando contiver caracteres inválidos', () {
        final result = Validators.validateEmail('usuario@dominio,com');
        expect(result, 'E-mail inválido');
      });

      test('deve retornar "E-mail inválido" quando houver espaços no corpo do e-mail', () {
        final result = Validators.validateEmail('usuario teste@dominio.com');
        expect(result, 'E-mail inválido');
      });
    });

    group('Casos de borda', () {
      test('deve retornar "E-mail inválido" para strings contendo apenas espaços em branco', () {
        final result = Validators.validateEmail('   ');
        expect(result, 'E-mail inválido');
      });

      test('deve retornar "E-mail inválido" se houver espaços no início ou no fim de um e-mail válido', () {
        final result = Validators.validateEmail(' usuario@dominio.com ');
        expect(result, 'E-mail inválido');
      });
    });
  });
}

