import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailLogin', () {
    test('retorna erro quando o valor é null', () {
      final result = Validators.validateEmailLogin(null);

      expect(result, 'Por favor, insira seu e-mail');
    });

    test('retorna erro quando o valor é vazio', () {
      final result = Validators.validateEmailLogin('');

      expect(result, 'Por favor, insira seu e-mail');
    });

    test('retorna erro quando o valor contém apenas espaços', () {
      final result = Validators.validateEmailLogin('   ');

      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('retorna erro para e-mail sem @', () {
      final result = Validators.validateEmailLogin('usuarioemail.com');

      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('retorna erro para e-mail sem domínio', () {
      final result = Validators.validateEmailLogin('usuario@');

      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('retorna erro para e-mail sem ponto no domínio', () {
      final result = Validators.validateEmailLogin('usuario@dominio');

      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('retorna erro para formato inválido com múltiplos @', () {
      final result = Validators.validateEmailLogin('user@@dominio.com');

      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('retorna null para e-mail válido simples', () {
      final result = Validators.validateEmailLogin('teste@email.com');

      expect(result, isNull);
    });

    test('retorna null para e-mail com subdomínio', () {
      final result =
          Validators.validateEmailLogin('usuario@mail.dominio.com');

      expect(result, isNull);
    });

    test('retorna null para e-mail com números e caracteres válidos', () {
      final result =
          Validators.validateEmailLogin('user123.teste@dominio.co');

      expect(result, isNull);
    });

    test('retorna null para e-mail com caracteres especiais válidos', () {
      final result =
          Validators.validateEmailLogin('user.name+tag@domain.com');

      expect(result, isNull);
    });
  });
}