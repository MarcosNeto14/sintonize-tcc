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

    test('deve retornar null quando e-mail é válido', () {
      expect(Validators.validateEmailEdit('usuario@exemplo.com'), isNull);
    });

    test('deve rejeitar e-mail sem arroba', () {
      expect(
        Validators.validateEmailEdit('usuarioexemplo.com'),
        equals('Formato de e-mail inválido'),
      );
    });

    test('deve rejeitar e-mail sem domínio', () {
      expect(
        Validators.validateEmailEdit('usuario@'),
        equals('Formato de e-mail inválido'),
      );
    });

    test('deve rejeitar e-mail sem extensão de domínio válida', () {
      expect(
        Validators.validateEmailEdit('usuario@dominio.c'),
        equals('Formato de e-mail inválido'),
      );
    });

    test('deve rejeitar e-mail contendo espaços', () {
      expect(
        Validators.validateEmailEdit('usuario @exemplo.com'),
        equals('Formato de e-mail inválido'),
      );
    });
  });
}

