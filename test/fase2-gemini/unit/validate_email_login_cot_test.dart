import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailLogin', () {
    group('Cenários de Sucesso', () {
      test('deve retornar null quando o e-mail for simples e válido', () {
        final result = Validators.validateEmailLogin('usuario@dominio.com');
        expect(result, isNull);
      });

      test('deve retornar null para e-mails com subdomínio e múltiplos pontos', () {
        final result = Validators.validateEmailLogin('nome.sobrenome@empresa.com.br');
        expect(result, isNull);
      });

      test('deve retornar null para e-mails com caracteres como +, - e _ no nome', () {
        final result = Validators.validateEmailLogin('user+tag-test_01@provedor.org');
        expect(result, isNull);
      });
    });

    group('Cenários de Falha - Campo Obrigatório', () {
      test('deve retornar mensagem de campo obrigatório quando for null', () {
        final result = Validators.validateEmailLogin(null);
        expect(result, equals('Por favor, insira seu e-mail'));
      });

      test('deve retornar mensagem de campo obrigatório quando for string vazia', () {
        final result = Validators.validateEmailLogin('');
        expect(result, equals('Por favor, insira seu e-mail'));
      });
    });

    group('Cenários de Falha - Formato Inválido', () {
      test('deve retornar mensagem de e-mail inválido quando não contiver @', () {
        final result = Validators.validateEmailLogin('usuariodominio.com');
        expect(result, equals('Por favor, insira um e-mail válido'));
      });

      test('deve retornar mensagem de e-mail inválido quando faltar o ponto no domínio', () {
        final result = Validators.validateEmailLogin('usuario@dominio');
        expect(result, equals('Por favor, insira um e-mail válido'));
      });

      test('deve retornar mensagem de e-mail inválido quando faltar o usuário antes do @', () {
        final result = Validators.validateEmailLogin('@dominio.com');
        expect(result, equals('Por favor, insira um e-mail válido'));
      });

      test('deve retornar mensagem de e-mail inválido quando houver arrobas duplicados', () {
        final result = Validators.validateEmailLogin('usuario@@dominio.com');
        expect(result, equals('Por favor, insira um e-mail válido'));
      });
    });

    group('Casos de Borda', () {
      test('deve retornar erro de formato quando contiver apenas espaços em branco', () {
        final result = Validators.validateEmailLogin('   ');
        expect(result, equals('Por favor, insira um e-mail válido'));
      });

      test('deve validar comportamento com múltiplos arrobas separados', () {
        final result = Validators.validateEmailLogin('user@extra@domain.com');
        expect(result, equals('Por favor, insira um e-mail válido'));
      });
    });
  });
}

