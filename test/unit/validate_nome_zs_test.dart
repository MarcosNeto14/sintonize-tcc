import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateNome', () {
    // 🔴 Casos de falha

    test('deve retornar erro quando valor é null', () {
      final result = Validators.validateNome(null);
      expect(result, 'O nome é obrigatório');
    });

    test('deve retornar erro quando valor é vazio', () {
      final result = Validators.validateNome('');
      expect(result, 'O nome é obrigatório');
    });

    test('deve retornar erro quando contém números', () {
      final result = Validators.validateNome('João123');
      expect(result, 'O nome não pode conter números ou caracteres especiais');
    });

    test('deve retornar erro quando contém caracteres especiais', () {
      final result = Validators.validateNome('Maria@Silva');
      expect(result, 'O nome não pode conter números ou caracteres especiais');
    });

    test('deve retornar erro quando contém mistura inválida', () {
      final result = Validators.validateNome('Ana#123');
      expect(result, 'O nome não pode conter números ou caracteres especiais');
    });

    // 🟢 Casos de sucesso

    test('deve retornar null para nome válido simples', () {
      final result = Validators.validateNome('João');
      expect(result, isNull);
    });

    test('deve retornar null para nome com espaços', () {
      final result = Validators.validateNome('Maria Silva');
      expect(result, isNull);
    });

    test('deve aceitar caracteres acentuados', () {
      final result = Validators.validateNome('Élson Álvares');
      expect(result, isNull);
    });

    // ⚠️ Casos de borda

    test('deve aceitar apenas espaços (comportamento atual)', () {
      final result = Validators.validateNome('   ');
      expect(result, isNull);
    });

    test('deve aceitar nome com uma única letra', () {
      final result = Validators.validateNome('A');
      expect(result, isNull);
    });

    test('deve rejeitar caracteres como underline', () {
      final result = Validators.validateNome('Joao_Silva');
      expect(result, 'O nome não pode conter números ou caracteres especiais');
    });

    test('deve rejeitar hífen (não permitido pela regex atual)', () {
      final result = Validators.validateNome('João-Silva');
      expect(result, 'O nome não pode conter números ou caracteres especiais');
    });
  });
}