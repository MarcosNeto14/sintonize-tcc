import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailLogin', () {
    
    // ✅ Sucesso
    test('Retorna null para e-mail válido simples', () {
      final result = Validators.validateEmailLogin('test@example.com');
      expect(result, isNull);
    });

    test('Retorna null para e-mail com subdomínio', () {
      final result = Validators.validateEmailLogin('user@mail.example.com');
      expect(result, isNull);
    });

    test('Retorna null para e-mail com caracteres especiais válidos', () {
      final result = Validators.validateEmailLogin('user.name+tag@example.co.uk');
      expect(result, isNull);
    });

    // ❌ Falhas
    test('Retorna erro quando valor é null', () {
      final result = Validators.validateEmailLogin(null);
      expect(result, 'Por favor, insira seu e-mail');
    });

    test('Retorna erro quando valor é vazio', () {
      final result = Validators.validateEmailLogin('');
      expect(result, 'Por favor, insira seu e-mail');
    });

    test('Retorna erro quando não tem @', () {
      final result = Validators.validateEmailLogin('testexample.com');
      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('Retorna erro quando não tem domínio', () {
      final result = Validators.validateEmailLogin('test@');
      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('Retorna erro quando não tem parte local', () {
      final result = Validators.validateEmailLogin('@example.com');
      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('Retorna erro quando não tem ponto no domínio', () {
      final result = Validators.validateEmailLogin('test@example');
      expect(result, 'Por favor, insira um e-mail válido');
    });

    // ⚠️ Bordas
    test('Retorna erro para string com espaços', () {
      final result = Validators.validateEmailLogin('   ');
      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('Valida e-mail com espaços antes/depois (sem trim)', () {
      final result = Validators.validateEmailLogin(' test@example.com ');
      // Regex ainda considera válido porque não há trim
      expect(result, isNull);
    });

    test('Retorna erro para múltiplos @', () {
      final result = Validators.validateEmailLogin('test@@example.com');
      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('Retorna erro para caracteres inválidos extremos', () {
      final result = Validators.validateEmailLogin('@@@');
      expect(result, 'Por favor, insira um e-mail válido');
    });
  });
}