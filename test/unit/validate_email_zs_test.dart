import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmail', () {
    // 🔴 Casos de falha

    test('retorna erro quando valor é null', () {
      final result = Validators.validateEmail(null);
      expect(result, 'O e-mail é obrigatório');
    });

    test('retorna erro quando valor é vazio', () {
      final result = Validators.validateEmail('');
      expect(result, 'O e-mail é obrigatório');
    });

    test('retorna erro quando não possui @', () {
      final result = Validators.validateEmail('emailinvalido.com');
      expect(result, 'E-mail inválido');
    });

    test('retorna erro quando não possui domínio', () {
      final result = Validators.validateEmail('teste@');
      expect(result, 'E-mail inválido');
    });

    test('retorna erro quando domínio não tem TLD', () {
      final result = Validators.validateEmail('teste@dominio');
      expect(result, 'E-mail inválido');
    });

    test('retorna erro com caracteres inválidos', () {
      final result = Validators.validateEmail('teste@dominio!.com');
      expect(result, 'E-mail inválido');
    });

    // 🟢 Casos de sucesso

    test('retorna null para e-mail válido simples', () {
      final result = Validators.validateEmail('teste@email.com');
      expect(result, isNull);
    });

    test('retorna null para e-mail com subdomínio', () {
      final result = Validators.validateEmail('user@mail.server.com');
      expect(result, isNull);
    });

    test('retorna null para e-mail com caracteres especiais válidos', () {
      final result = Validators.validateEmail('user.name+tag@domain.co');
      expect(result, isNull);
    });

    // ⚠️ Casos de borda

    test('retorna erro para e-mail com espaço', () {
      final result = Validators.validateEmail('teste @email.com');
      expect(result, 'E-mail inválido');
    });

    test('retorna erro para e-mail com TLD de 1 caractere', () {
      final result = Validators.validateEmail('teste@email.c');
      expect(result, 'E-mail inválido');
    });

    test('retorna null para e-mail com TLD longo', () {
      final result = Validators.validateEmail('teste@email.technology');
      expect(result, isNull);
    });

    test('retorna erro para múltiplos @', () {
      final result = Validators.validateEmail('teste@@email.com');
      expect(result, 'E-mail inválido');
    });

    test('retorna erro para string com apenas espaços', () {
      final result = Validators.validateEmail('   ');
      expect(result, 'E-mail inválido');
    });
  });
}