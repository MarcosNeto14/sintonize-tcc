import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailEdit', () {
    
    // ✅ Sucesso
    test('Deve retornar null para e-mail válido simples', () {
      final result = Validators.validateEmailEdit('test@example.com');
      expect(result, isNull);
    });

    test('Deve retornar null para e-mail com subdomínio', () {
      final result = Validators.validateEmailEdit('user@mail.example.com');
      expect(result, isNull);
    });

    test('Deve retornar null para e-mail com caracteres especiais válidos', () {
      final result = Validators.validateEmailEdit('user.name+tag@example.co');
      expect(result, isNull);
    });

    // ❌ Falha
    test('Deve retornar erro para e-mail sem @', () {
      final result = Validators.validateEmailEdit('testexample.com');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve retornar erro para e-mail sem domínio', () {
      final result = Validators.validateEmailEdit('test@');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve retornar erro para domínio inválido', () {
      final result = Validators.validateEmailEdit('test@.com');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve retornar erro para TLD muito curto', () {
      final result = Validators.validateEmailEdit('test@example.c');
      expect(result, 'Formato de e-mail inválido');
    });

    // ⚠️ Borda
    test('Deve retornar null para valor null', () {
      final result = Validators.validateEmailEdit(null);
      expect(result, isNull);
    });

    test('Deve retornar null para string vazia', () {
      final result = Validators.validateEmailEdit('');
      expect(result, isNull);
    });

    test('Deve retornar erro para string com espaços', () {
      final result = Validators.validateEmailEdit('   ');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve retornar erro para e-mail com espaços internos', () {
      final result = Validators.validateEmailEdit('test@exa mple.com');
      expect(result, 'Formato de e-mail inválido');
    });
  });
}