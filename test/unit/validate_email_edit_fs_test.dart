import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateEmailEdit', () {
    test('deve retornar null quando valor é null', () {
      expect(Validators.validateEmailEdit(null), isNull);
    });

    test('deve retornar null quando valor é vazio', () {
      expect(Validators.validateEmailEdit(''), isNull);
    });

    test('deve aceitar e-mail válido simples', () {
      expect(Validators.validateEmailEdit('teste@email.com'), isNull);
    });

    test('deve aceitar e-mail com subdomínio', () {
      expect(Validators.validateEmailEdit('user@mail.example.com'), isNull);
    });

    test('deve aceitar e-mail com caracteres especiais válidos', () {
      expect(Validators.validateEmailEdit('user.name+tag@email.co'), isNull);
    });

    test('deve rejeitar e-mail sem @', () {
      expect(Validators.validateEmailEdit('testeemail.com'), isNotNull);
    });

    test('deve rejeitar e-mail sem domínio', () {
      expect(Validators.validateEmailEdit('teste@'), isNotNull);
    });

    test('deve rejeitar e-mail sem TLD', () {
      expect(Validators.validateEmailEdit('teste@email'), isNotNull);
    });

    test('deve rejeitar e-mail com caracteres inválidos', () {
      expect(Validators.validateEmailEdit('teste@ema!l.com'), isNotNull);
    });

    test('deve retornar mensagem de erro para e-mail inválido', () {
      expect(
        Validators.validateEmailEdit('email_invalido'),
        'Formato de e-mail inválido',
      );
    });
  });
}