import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateEmail', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateEmail(null), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateEmail(''), isNotNull);
    });

    test('deve aceitar e-mail válido simples', () {
      expect(Validators.validateEmail('teste@email.com'), isNull);
    });

    test('deve aceitar e-mail com subdomínio', () {
      expect(Validators.validateEmail('user@mail.example.com'), isNull);
    });

    test('deve aceitar e-mail com caracteres especiais válidos', () {
      expect(Validators.validateEmail('user.name+tag@email.co'), isNull);
    });

    test('deve rejeitar e-mail sem @', () {
      expect(Validators.validateEmail('testeemail.com'), isNotNull);
    });

    test('deve rejeitar e-mail sem domínio', () {
      expect(Validators.validateEmail('teste@'), isNotNull);
    });

    test('deve rejeitar e-mail sem sufixo do domínio', () {
      expect(Validators.validateEmail('teste@email'), isNotNull);
    });

    test('deve rejeitar e-mail com caracteres inválidos', () {
      expect(Validators.validateEmail('teste@ema!l.com'), isNotNull);
    });

    test('deve rejeitar e-mail com espaço', () {
      expect(Validators.validateEmail('teste @email.com'), isNotNull);
    });
  });
}