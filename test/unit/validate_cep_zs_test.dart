import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateCEP', () {
    // 🔴 Casos de falha - valor nulo ou vazio
    test('deve retornar erro quando valor for null', () {
      final result = Validators.validateCEP(null);
      expect(result, 'O CEP é obrigatório');
    });

    test('deve retornar erro quando valor for vazio', () {
      final result = Validators.validateCEP('');
      expect(result, 'O CEP é obrigatório');
    });

    // 🔴 Casos de falha - formato inválido
    test('deve retornar erro quando CEP não tem hífen', () {
      final result = Validators.validateCEP('12345678');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    test('deve retornar erro quando CEP tem letras', () {
      final result = Validators.validateCEP('1234A-678');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    test('deve retornar erro quando CEP tem menos de 9 caracteres', () {
      final result = Validators.validateCEP('1234-678');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    test('deve retornar erro quando CEP tem mais de 9 caracteres', () {
      final result = Validators.validateCEP('123456-7890');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    test('deve retornar erro quando hífen está na posição errada', () {
      final result = Validators.validateCEP('123-45678');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    // 🟡 Casos de borda
    test('deve falhar com espaços extras', () {
      final result = Validators.validateCEP(' 12345-678 ');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    test('deve falhar com caracteres especiais', () {
      final result = Validators.validateCEP('12345@678');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    // 🟢 Caso de sucesso
    test('deve retornar null para CEP válido', () {
      final result = Validators.validateCEP('12345-678');
      expect(result, isNull);
    });
  });
}