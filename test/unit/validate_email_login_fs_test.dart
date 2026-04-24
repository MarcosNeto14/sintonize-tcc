import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateEmailLogin', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateEmailLogin(null), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateEmailLogin(''), isNotNull);
    });

    test('deve retornar mensagem de erro para e-mail sem @', () {
      expect(Validators.validateEmailLogin('email.com'), isNotNull);
    });

    test('deve retornar mensagem de erro para e-mail sem domínio', () {
      expect(Validators.validateEmailLogin('email@'), isNotNull);
    });

    test('deve retornar mensagem de erro para e-mail sem ponto no domínio', () {
      expect(Validators.validateEmailLogin('email@dominio'), isNotNull);
    });

    test('deve retornar null para e-mail válido', () {
      expect(Validators.validateEmailLogin('teste@email.com'), isNull);
    });

    test('deve aceitar e-mail com subdomínio válido', () {
      expect(Validators.validateEmailLogin('user@mail.example.com'), isNull);
    });
  });
}