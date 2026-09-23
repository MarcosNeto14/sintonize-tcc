import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('formatName', () {
    test('deve retornar string vazia quando o valor de entrada é vazio', () {
      expect(Validators.formatName(''), equals(''));
    });

    test('deve capitalizar a primeira letra de uma palavra única em minúsculo', () {
      expect(Validators.formatName('marcos'), equals('Marcos'));
    });

    test('deve manter a palavra capitalizada quando já inicia com maiúscula', () {
      expect(Validators.formatName('Marcos'), equals('Marcos'));
    });

    test('deve capitalizar a primeira letra de cada palavra em um nome composto', () {
      expect(Validators.formatName('joao silva'), equals('Joao Silva'));
    });

    test('deve funcionar corretamente com palavras de apenas uma letra', () {
      expect(Validators.formatName('a b c'), equals('A B C'));
    });
  });
}

