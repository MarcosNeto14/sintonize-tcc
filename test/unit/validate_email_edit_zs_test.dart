import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailEdit', () {
    // ✅ Cenários de sucesso (retorno null)
    test('Deve retornar null para e-mail válido simples', () {
      final result = Validators.validateEmailEdit('teste@email.com');
      expect(result, isNull);
    });

    test('Deve retornar null para e-mail com subdomínio', () {
      final result = Validators.validateEmailEdit('user@mail.domain.com');
      expect(result, isNull);
    });

    test('Deve retornar null para e-mail com caracteres especiais válidos', () {
      final result = Validators.validateEmailEdit('user.name+tag@domain.co');
      expect(result, isNull);
    });

    test('Deve retornar null quando valor é null', () {
      final result = Validators.validateEmailEdit(null);
      expect(result, isNull);
    });

    test('Deve retornar null quando valor é string vazia', () {
      final result = Validators.validateEmailEdit('');
      expect(result, isNull);
    });

    // ❌ Cenários de falha (retorno com erro)
    test('Deve retornar erro para e-mail sem @', () {
      final result = Validators.validateEmailEdit('emailinvalido.com');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve retornar erro para e-mail sem domínio', () {
      final result = Validators.validateEmailEdit('teste@');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve retornar erro para e-mail sem TLD', () {
      final result = Validators.validateEmailEdit('teste@email');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve retornar erro para e-mail com espaços', () {
      final result = Validators.validateEmailEdit('teste @email.com');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve retornar erro para e-mail com caracteres inválidos', () {
      final result = Validators.validateEmailEdit('teste#email.com');
      expect(result, 'Formato de e-mail inválido');
    });

    // ⚠️ Casos de borda
    test('Deve retornar erro para e-mail com TLD de 1 caractere', () {
      final result = Validators.validateEmailEdit('teste@email.c');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve aceitar TLD com 2 caracteres (mínimo válido)', () {
      final result = Validators.validateEmailEdit('teste@email.co');
      expect(result, isNull);
    });

    test('Deve retornar erro para múltiplos @', () {
      final result = Validators.validateEmailEdit('teste@@email.com');
      expect(result, 'Formato de e-mail inválido');
    });
  });
}