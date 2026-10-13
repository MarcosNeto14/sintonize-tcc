import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateSenha', () {
    test('deve retornar erro quando valor é null', () {
      expect(
        Validators.validateSenha(null),
        'Por favor, insira sua senha',
      );
    });

    test('deve retornar erro quando valor é vazio', () {
      expect(
        Validators.validateSenha(''),
        'Por favor, insira sua senha',
      );
    });

    test('deve retornar erro quando senha tem menos de 6 caracteres', () {
      expect(
        Validators.validateSenha('12345'),
        'A senha deve ter pelo menos 6 caracteres',
      );
    });

    test('deve retornar erro quando senha tem exatamente 6 caracteres (comportamento atual com < 7)', () {
      expect(
        Validators.validateSenha('123456'),
        'A senha deve ter pelo menos 6 caracteres',
      );
    });

    test('deve retornar null quando senha tem 7 caracteres ou mais', () {
      expect(Validators.validateSenha('1234567'), isNull);
      expect(Validators.validateSenha('minhasenhasegura123'), isNull);
    });
  });
}
