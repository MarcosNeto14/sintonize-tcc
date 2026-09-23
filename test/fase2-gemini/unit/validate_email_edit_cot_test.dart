import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailEdit', () {
    group('Cenários opcionais e valores vazios (deve retornar null)', () {
      test('deve retornar null quando o valor for nulo', () {
        final result = Validators.validateEmailEdit(null);
        expect(result, isNull);
      });

      test('deve retornar null quando o valor for uma string vazia', () {
        final result = Validators.validateEmailEdit('');
        expect(result, isNull);
      });
    });

    group('Cenários de sucesso com e-mails válidos (deve retornar null)', () {
      test('deve retornar null para um e-mail padrão simples', () {
        final result = Validators.validateEmailEdit('usuario@dominio.com');
        expect(result, isNull);
      });

      test('deve retornar null para e-mail com subdomínio e múltiplos pontos', () {
        final result = Validators.validateEmailEdit('dev@mail.empresa.com.br');
        expect(result, isNull);
      });

      test('deve retornar null para e-mail contendo caracteres permitidos (._%+-) no identificador', () {
        final result = Validators.validateEmailEdit('user.name+tag_test-1@dominio.com');
        expect(result, isNull);
      });

      test('deve retornar null para e-mail com TLD longo/moderno', () {
        final result = Validators.validateEmailEdit('contato@empresa.technology');
        expect(result, isNull);
      });

      test('deve retornar null para TLD no limite mínimo de 2 caracteres', () {
        final result = Validators.validateEmailEdit('teste@dominio.io');
        expect(result, isNull);
      });
    });

    group('Cenários de falha com formatos inválidos (deve retornar mensagem de erro)', () {
      const errorMessage = 'Formato de e-mail inválido';

      test('deve retornar erro quando não contiver @', () {
        final result = Validators.validateEmailEdit('usuariodominio.com');
        expect(result, equals(errorMessage));
      });

      test('deve retornar erro quando faltar o identificador antes do @', () {
        final result = Validators.validateEmailEdit('@dominio.com');
        expect(result, equals(errorMessage));
      });

      test('deve retornar erro quando faltar o domínio após o @', () {
        final result = Validators.validateEmailEdit('usuario@');
        expect(result, equals(errorMessage));
      });

      test('deve retornar erro quando faltar o TLD', () {
        final result = Validators.validateEmailEdit('usuario@dominio');
        expect(result, equals(errorMessage));
      });

      test('deve retornar erro quando o TLD tiver menos de 2 caracteres', () {
        final result = Validators.validateEmailEdit('usuario@dominio.c');
        expect(result, equals(errorMessage));
      });

      test('deve retornar erro quando houver múltiplos @', () {
        final result = Validators.validateEmailEdit('usuario@@dominio.com');
        expect(result, equals(errorMessage));
      });

      test('deve retornar erro quando houver espaços antes, depois ou no meio', () {
        expect(Validators.validateEmailEdit(' usuario@dominio.com'), equals(errorMessage));
        expect(Validators.validateEmailEdit('usuario@dominio.com '), equals(errorMessage));
        expect(Validators.validateEmailEdit('user name@dominio.com'), equals(errorMessage));
      });

      test('deve retornar erro para string contendo apenas espaços em branco', () {
        final result = Validators.validateEmailEdit('   ');
        expect(result, equals(errorMessage));
      });

      test('deve retornar erro quando contiver caracteres especiais inválidos', () {
        final result = Validators.validateEmailEdit('usuário!#@dominio.com');
        expect(result, equals(errorMessage));
      });
    });
  });
}

