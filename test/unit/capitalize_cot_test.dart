import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.capitalize', () {
    // ✅ Cenários de sucesso
    test('Deve capitalizar uma única palavra', () {
      expect(Validators.capitalize('hello'), 'Hello');
    });

    test('Deve capitalizar múltiplas palavras', () {
      expect(Validators.capitalize('hello world'), 'Hello World');
    });

    test('Deve manter texto já capitalizado corretamente', () {
      expect(Validators.capitalize('Hello World'), 'Hello World');
    });

    test('Deve corrigir palavras com letras misturadas', () {
      expect(Validators.capitalize('hELLo wORLD'), 'Hello World');
    });

    // ❌ Cenário de falha
    test('Deve retornar string vazia quando input for vazio', () {
      expect(Validators.capitalize(''), '');
    });

    // ⚠️ Casos de borda
    test('Deve preservar múltiplos espaços entre palavras', () {
      expect(
        Validators.capitalize('hello   world'),
        'Hello   World',
      );
    });

    test('Deve preservar espaços no início e no fim', () {
      expect(
        Validators.capitalize('  hello world  '),
        '  Hello World  ',
      );
    });

    test('Deve lidar com palavras vazias (espaços consecutivos)', () {
      expect(
        Validators.capitalize('hello  world'),
        'Hello  World',
      );
    });

    test('Deve lidar com caracteres especiais', () {
      expect(
        Validators.capitalize('hello-world'),
        'Hello-world',
      );
    });

    test('Deve lidar com números no texto', () {
      expect(
        Validators.capitalize('hello 123 world'),
        'Hello 123 World',
      );
    });
  });
}