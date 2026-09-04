import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateNome', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateNome(null), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateNome(''), isNotNull);
    });

    test('deve retornar null quando nome é preenchido corretamente', () {
      expect(Validators.validateNome('João da Silva'), isNull);
    });

    test('deve aceitar nome com caracteres acentuados', () {
      expect(Validators.validateNome('José Antônio'), isNull);
    });

    test('deve rejeitar nome com números', () {
      expect(Validators.validateNome('João123'), isNotNull);
    });

    test('deve rejeitar nome com caracteres especiais', () {
      expect(Validators.validateNome('João@Silva'), isNotNull);
    });
  });
}
