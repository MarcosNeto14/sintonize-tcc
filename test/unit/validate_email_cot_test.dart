import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmail', () {
    
    // ----------------------
    // Cenários de sucesso
    // ----------------------
    test('Retorna null para e-mail válido simples', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
    });

    test('Retorna null para e-mail com subdomínio', () {
      expect(Validators.validateEmail('user@mail.example.com'), isNull);
    });

    test('Retorna null para e-mail com caracteres especiais válidos', () {
      expect(Validators.validateEmail('user.name+tag@example.co'), isNull);
    });

    // ----------------------
    // Cenários de falha
    // ----------------------
    test('Retorna erro quando valor é null', () {
      expect(Validators.validateEmail(null), 'O e-mail é obrigatório');
    });

    test('Retorna erro quando valor é vazio', () {
      expect(Validators.validateEmail(''), 'O e-mail é obrigatório');
    });

    test('Retorna erro para e-mail sem @', () {
      expect(Validators.validateEmail('testexample.com'), 'E-mail inválido');
    });

    test('Retorna erro para e-mail sem domínio', () {
      expect(Validators.validateEmail('test@'), 'E-mail inválido');
    });

    test('Retorna erro para domínio inválido', () {
      expect(Validators.validateEmail('test@.com'), 'E-mail inválido');
    });

    test('Retorna erro para TLD inválido', () {
      expect(Validators.validateEmail('test@example.c'), 'E-mail inválido');
    });

    // ----------------------
    // Casos de borda
    // ----------------------
    test('Retorna erro para e-mail com espaços', () {
      expect(Validators.validateEmail(' test@example.com '), 'E-mail inválido');
    });

    test('Retorna erro para e-mail com espaço no meio', () {
      expect(Validators.validateEmail('test@exa mple.com'), 'E-mail inválido');
    });

    test('Valida e-mail muito longo', () {
      final longEmail = 'a' * 64 + '@example.com';
      expect(Validators.validateEmail(longEmail), isNull);
    });
  });
}