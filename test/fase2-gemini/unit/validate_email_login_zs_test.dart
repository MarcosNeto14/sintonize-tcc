// test/utils/validators_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailLogin', () {
    group('Falha - Campo vazio ou nulo', () {
      test('deve retornar mensagem de erro obrigatório quando o valor for null', () {
        final result = Validators.validateEmailLogin(null);
        expect(result, 'Por favor, insira seu e-mail');
      });

      test('deve retornar mensagem de erro obrigatório quando a string for vazia', () {
        final result = Validators.validateEmailLogin('');
        expect(result, 'Por favor, insira seu e-mail');
      });
    });

    group('Falha - Formato inválido e casos de borda', () {
      test('deve retornar erro para e-mail sem @', () {
        final result = Validators.validateEmailLogin('usuarioexemplo.com');
        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar erro para e-mail sem domínio/extensão', () {
        final result = Validators.validateEmailLogin('usuario@');
        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar erro para e-mail sem o ponto no domínio', () {
        final result = Validators.validateEmailLogin('usuario@dominio');
        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar erro para e-mail que começa diretamente com @', () {
        final result = Validators.validateEmailLogin('@dominio.com');
        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar erro se o ponto estiver colado ao @', () {
        final result = Validators.validateEmailLogin('usuario@.com');
        expect(result, 'Por favor, insira um e-mail válido');
      });

      test('deve retornar erro quando contiver apenas espaços em branco', () {
        // Como o regex exige r'^[^@]+@[^@]+\.[^@]+', apenas espaços falham no regex
        final result = Validators.validateEmailLogin('   ');
        expect(result, 'Por favor, insira um e-mail válido');
      });
    });

    group('Sucesso - Formatos válidos', () {
      test('deve retornar null para um e-mail padrão simples', () {
        final result = Validators.validateEmailLogin('teste@dominio.com');
        expect(result, isNull);
      });

      test('deve retornar null para e-mail com múltiplos subdomínios', () {
        final result = Validators.validateEmailLogin('usuario@sub.empresa.com.br');
        expect(result, isNull);
      });

      test('deve retornar null para e-mail contendo números e caracteres comuns', () {
        final result = Validators.validateEmailLogin('usuario.123_abc@dominio.org');
        expect(result, isNull);
      });
    });
  });
}

