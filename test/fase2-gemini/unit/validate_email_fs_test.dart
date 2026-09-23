import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateEmail', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(
        Validators.validateEmail(null),
        equals('O e-mail é obrigatório'),
      );
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(
        Validators.validateEmail(''),
        equals('O e-mail é obrigatório'),
      );
    });

    test('deve rejeitar e-mail sem @', () {
      expect(
        Validators.validateEmail('usuarioemail.com'),
        equals('E-mail inválido'),
      );
    });

    test('deve rejeitar e-mail sem domínio após o @', () {
      expect(
        Validators.validateEmail('usuario@'),
        equals('E-mail inválido'),
      );
    });

    test('deve rejeitar e-mail sem TLD válido', () {
      expect(
        Validators.validateEmail('usuario@dominio'),
        equals('E-mail inválido'),
      );
    });

    test('deve rejeitar e-mail com espaços', () {
      expect(
        Validators.validateEmail('usuario @dominio.com'),
        equals('E-mail inválido'),
      );
    });

    test('deve retornar null para e-mail padrão válido', () {
      expect(
        Validators.validateEmail('usuario@dominio.com'),
        isNull,
      );
    });

    test('deve retornar null para e-mail com subdomínio e caracteres especiais permitidos', () {
      expect(
        Validators.validateEmail('user.name+tag@sub.dominio.com.br'),
        isNull,
      );
    });
  });
}

