import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateEmail', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(
        Validators.validateEmail(null),
        'O e-mail é obrigatório',
      );
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(
        Validators.validateEmail(''),
        'O e-mail é obrigatório',
      );
    });

    test('deve retornar null quando e-mail é válido', () {
      expect(
        Validators.validateEmail('usuario@email.com'),
        isNull,
      );
    });

    test('deve aceitar e-mail com números, pontos e caracteres especiais válidos', () {
      expect(
        Validators.validateEmail('usuario.123+teste@email.com'),
        isNull,
      );
    });

    test('deve rejeitar e-mail sem @', () {
      expect(
        Validators.validateEmail('usuarioemail.com'),
        'E-mail inválido',
      );
    });

    test('deve rejeitar e-mail sem domínio', () {
      expect(
        Validators.validateEmail('usuario@'),
        'E-mail inválido',
      );
    });

    test('deve rejeitar e-mail sem extensão do domínio', () {
      expect(
        Validators.validateEmail('usuario@email'),
        'E-mail inválido',
      );
    });

    test('deve rejeitar e-mail com extensão menor que dois caracteres', () {
      expect(
        Validators.validateEmail('usuario@email.c'),
        'E-mail inválido',
      );
    });

    test('deve rejeitar e-mail com caracteres inválidos', () {
      expect(
        Validators.validateEmail('usuario#email.com'),
        'E-mail inválido',
      );
    });
  });
}
