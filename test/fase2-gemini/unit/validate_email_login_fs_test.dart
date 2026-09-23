import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateEmailLogin', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateEmailLogin(null), 'Por favor, insira seu e-mail');
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateEmailLogin(''), 'Por favor, insira seu e-mail');
    });

    test('deve rejeitar e-mail sem arroba (@)', () {
      expect(
        Validators.validateEmailLogin('usuario.dominio.com'),
        'Por favor, insira um e-mail válido',
      );
    });

    test('deve rejeitar e-mail sem domínio ou extensão', () {
      expect(
        Validators.validateEmailLogin('usuario@dominio'),
        'Por favor, insira um e-mail válido',
      );
    });

    test('deve rejeitar e-mail com múltiplos arrobas (@)', () {
      expect(
        Validators.validateEmailLogin('usuario@@dominio.com'),
        'Por favor, insira um e-mail válido',
      );
    });

    test('deve rejeitar e-mail sem nome de usuário antes do arroba', () {
      expect(
        Validators.validateEmailLogin('@dominio.com'),
        'Por favor, insira um e-mail válido',
      );
    });

    test('deve retornar null quando o e-mail é válido', () {
      expect(Validators.validateEmailLogin('usuario@email.com'), isNull);
    });

    test('deve retornar null para e-mails válidos com subdomínios', () {
      expect(Validators.validateEmailLogin('contato@empresa.com.br'), isNull);
    });
  });
}

