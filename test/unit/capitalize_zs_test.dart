import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.capitalize', () {
    test('deve capitalizar uma única palavra', () {
      final result = Validators.capitalize('hello');
      expect(result, 'Hello');
    });

    test('deve capitalizar múltiplas palavras', () {
      final result = Validators.capitalize('hello world');
      expect(result, 'Hello World');
    });

    test('deve transformar letras maiúsculas em minúsculas (exceto a primeira)', () {
      final result = Validators.capitalize('hELLo wORLD');
      expect(result, 'Hello World');
    });

    test('deve retornar string vazia quando input for vazio', () {
      final result = Validators.capitalize('');
      expect(result, '');
    });

    test('deve lidar com espaços extras entre palavras', () {
      final result = Validators.capitalize('hello   world');
      expect(result, 'Hello   World');
    });

    test('deve lidar com espaços no início e fim', () {
      final result = Validators.capitalize('  hello world  ');
      expect(result, '  Hello World  ');
    });

    test('deve lidar com palavras de um único caractere', () {
      final result = Validators.capitalize('a b c');
      expect(result, 'A B C');
    });

    test('deve manter números e caracteres especiais', () {
      final result = Validators.capitalize('123 abc! @home');
      expect(result, '123 Abc! @home');
    });

    test('deve lidar com palavras vazias entre espaços', () {
      final result = Validators.capitalize('hello  world');
      expect(result, 'Hello  World');
    });

    test('não deve lançar exceção com string contendo apenas espaços', () {
      final result = Validators.capitalize('     ');
      expect(result, '     ');
    });
  });
}