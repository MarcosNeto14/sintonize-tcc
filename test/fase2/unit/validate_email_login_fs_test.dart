import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateEmailLogin', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(
        Validators.validateEmailLogin(null),
        'Por favor, insira seu e-mail',
      );
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(
        Validators.validateEmailLogin(''),
        'Por favor, insira seu e-mail',
      );
    });

    test('deve retornar null quando e-mail é válido', () {
      expect(
        Validators.validateEmailLogin('usuario@email.com'),
        isNull,
      );
    });

    test('deve retornar mensagem de erro quando e-mail não possui @', () {
      expect(
        Validators.validateEmailLogin('usuarioemail.com'),
        'Por favor, insira um e-mail válido',
      );
    });

    test('deve retornar mensagem de erro quando e-mail não possui domínio', () {
      expect(
        Validators.validateEmailLogin('usuario@'),
        'Por favor, insira um e-mail válido',
      );
    });

    test('deve retornar mensagem de erro quando e-mail não possui extensão', () {
      expect(
        Validators.validateEmailLogin('usuario@email'),
        'Por favor, insira um e-mail válido',
      );
    });
  });
}
