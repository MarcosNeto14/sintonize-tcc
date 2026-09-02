import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('capitalize', () {
    test('deve retornar string vazia quando valor é vazio', () {
      expect(Validators.capitalize(''), '');
    });

    test('deve capitalizar a primeira letra de uma palavra', () {
      expect(Validators.capitalize('maria'), 'Maria');
    });

    test('deve converter o restante da palavra para letras minúsculas', () {
      expect(Validators.capitalize('MARIA'), 'Maria');
    });

    test('deve capitalizar cada palavra de um texto', () {
      expect(Validators.capitalize('maria silva'), 'Maria Silva');
    });

    test('deve corrigir maiúsculas e minúsculas em múltiplas palavras', () {
      expect(Validators.capitalize('maRIA silVA'), 'Maria Silva');
    });

    test('deve preservar espaços internos vazios', () {
      expect(Validators.capitalize('maria  silva'), 'Maria  Silva');
    });
  });
}
