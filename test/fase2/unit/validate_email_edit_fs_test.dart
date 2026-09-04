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
      expect(Validators.validateEmailEdit('usuario@email.com'), isNull);
    });

    test('deve aceitar e-mail com caracteres permitidos', () {
      expect(
        Validators.validateEmailEdit('usuario.nome+teste@email.com.br'),
        isNull,
      );
    });

    test('deve retornar mensagem de erro quando e-mail não possui @', () {
      expect(
        Validators.validateEmailEdit('usuarioemail.com'),
        'Formato de e-mail inválido',
      );
    });

    test('deve retornar mensagem de erro quando e-mail não possui domínio', () {
      expect(
        Validators.validateEmailEdit('usuario@'),
        'Formato de e-mail inválido',
      );
    });

    test('deve retornar mensagem de erro quando e-mail não possui extensão', () {
      expect(
        Validators.validateEmailEdit('usuario@email'),
        'Formato de e-mail inválido',
      );
    });

    test('deve retornar mensagem de erro quando e-mail contém espaços', () {
      expect(
        Validators.validateEmailEdit('usuario @email.com'),
        'Formato de e-mail inválido',
      );
    });
  });
}
