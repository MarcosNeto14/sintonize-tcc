import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('capitalize', () {
    test('deve retornar string vazia quando o texto de entrada for vazio', () {
      expect(Validators.capitalize(''), equals(''));
    });

    test('deve capitalizar uma única palavra em minúsculas', () {
      expect(Validators.capitalize('joão'), equals('João'));
    });

    test('deve capitalizar uma única palavra em maiúsculas', () {
      expect(Validators.capitalize('MARIA'), equals('Maria'));
    });

    test('deve formatar texto com maiúsculas e minúsculas misturadas', () {
      expect(Validators.capitalize('maRIA silva'), equals('Maria Silva'));
    });

    test('deve formatar frase com múltiplas palavras', () {
      expect(
        Validators.capitalize('recife pernambuco brasil'),
        equals('Recife Pernambuco Brasil'),
      );
    });

    test('deve manter a formatação correta em palavras com apenas 1 caractere', () {
      expect(Validators.capitalize('a'), equals('A'));
      expect(Validators.capitalize('d e f'), equals('D E F'));
    });
  });
}
