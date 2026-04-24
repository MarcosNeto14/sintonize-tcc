import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateNumero', () {
    
    // ✅ Cenários de sucesso
    test('deve retornar null para número inteiro válido', () {
      expect(Validators.validateNumero('123'), null);
    });

    test('deve retornar null para número negativo', () {
      expect(Validators.validateNumero('-10'), null);
    });

    test('deve retornar null para zero', () {
      expect(Validators.validateNumero('0'), null);
    });

    test('deve aceitar número muito grande', () {
      expect(Validators.validateNumero('999999999'), null);
    });

    // ❌ Cenários de falha
    test('deve retornar erro quando valor é null', () {
      expect(Validators.validateNumero(null), 'O número é obrigatório');
    });

    test('deve retornar erro quando valor é vazio', () {
      expect(Validators.validateNumero(''), 'O número é obrigatório');
    });

    test('deve retornar erro quando contém letras', () {
      expect(Validators.validateNumero('abc'), 'O número deve ser numérico');
    });

    test('deve retornar erro para string alfanumérica', () {
      expect(Validators.validateNumero('123abc'), 'O número deve ser numérico');
    });

    // ⚠️ Casos de borda
    test('deve aceitar número com espaços (int.tryParse ignora espaços)', () {
      expect(Validators.validateNumero(' 123 '), null);
    });

    test('deve retornar erro para número decimal', () {
      expect(Validators.validateNumero('12.3'), 'O número deve ser numérico');
    });
  });
}