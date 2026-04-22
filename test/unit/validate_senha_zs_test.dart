import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateSenha', () {
    test('deve retornar erro quando valor for null', () {
      final result = Validators.validateSenha(null);

      expect(result, 'Por favor, insira sua senha');
    });

    test('deve retornar erro quando valor for vazio', () {
      final result = Validators.validateSenha('');

      expect(result, 'Por favor, insira sua senha');
    });

    test('deve retornar erro quando senha tiver menos de 6 caracteres', () {
      final result = Validators.validateSenha('12345');

      expect(result, 'A senha deve ter pelo menos 6 caracteres');
    });

    test('deve aceitar senha com exatamente 6 caracteres (caso de borda)', () {
      final result = Validators.validateSenha('123456');

      expect(result, isNull);
    });

    test('deve aceitar senha com mais de 6 caracteres', () {
      final result = Validators.validateSenha('1234567');

      expect(result, isNull);
    });

    test('deve aceitar senha com caracteres especiais', () {
      final result = Validators.validateSenha('abc@123');

      expect(result, isNull);
    });

    test('deve tratar espaços como caracteres válidos', () {
      final result = Validators.validateSenha('123 56');

      expect(result, isNull);
    });
  });
}