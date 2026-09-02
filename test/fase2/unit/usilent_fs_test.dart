import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateSenha', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateSenha(null), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateSenha(''), isNotNull);
    });

    test('deve retornar mensagem de erro quando senha tem menos de 6 caracteres', () {
      expect(Validators.validateSenha('12345'), isNotNull);
    });

    test('deve retornar mensagem de erro quando senha tem exatamente 6 caracteres', () {
      expect(Validators.validateSenha('123456'), isNotNull);
    });

    test('deve retornar null quando senha tem 7 caracteres', () {
      expect(Validators.validateSenha('1234567'), isNull);
    });

    test('deve retornar null quando senha tem mais de 7 caracteres', () {
      expect(Validators.validateSenha('12345678'), isNull);
    });
  });
}
