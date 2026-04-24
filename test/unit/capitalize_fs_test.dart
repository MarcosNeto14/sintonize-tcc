import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('capitalize', () {
    test('deve retornar string vazia quando texto é vazio', () {
      expect(Validators.capitalize(''), equals(''));
    });

    test('deve capitalizar primeira letra de uma única palavra', () {
      expect(Validators.capitalize('hello'), equals('Hello'));
    });

    test('deve converter resto da palavra para minúsculo', () {
      expect(Validators.capitalize('hELLo'), equals('Hello'));
    });

    test('deve capitalizar múltiplas palavras', () {
      expect(
        Validators.capitalize('hello world'),
        equals('Hello World'),
      );
    });

    test('deve lidar com múltiplos espaços entre palavras', () {
      expect(
        Validators.capitalize('hello   world'),
        equals('Hello   World'),
      );
    });

    test('deve manter espaços no início e fim', () {
      expect(
        Validators.capitalize('  hello world  '),
        equals('  Hello World  '),
      );
    });

    test('deve lidar com palavras já capitalizadas corretamente', () {
      expect(
        Validators.capitalize('Hello World'),
        equals('Hello World'),
      );
    });

    test('deve lidar com mistura de maiúsculas e minúsculas', () {
      expect(
        Validators.capitalize('hELLo WoRLD'),
        equals('Hello World'),
      );
    });
  });
}