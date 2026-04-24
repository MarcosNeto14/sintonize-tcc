import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('formatName', () {
    test('deve retornar string vazia quando nome for vazio', () {
      expect(Validators.formatName(''), equals(''));
    });

    test('deve capitalizar primeira letra de uma única palavra', () {
      expect(Validators.formatName('joao'), equals('Joao'));
    });

    test('deve capitalizar cada palavra separada por espaço', () {
      expect(Validators.formatName('joao silva'), equals('Joao Silva'));
    });

    test('deve manter palavras já capitalizadas corretamente', () {
      expect(Validators.formatName('Maria Souza'), equals('Maria Souza'));
    });

    test('deve corrigir mistura de maiúsculas e minúsculas', () {
      expect(Validators.formatName('jOaO sIlVa'), equals('JOaO SIlVa'));
    });

    test('deve lançar erro quando houver múltiplos espaços', () {
      expect(
        () => Validators.formatName('joao   silva'),
        throwsA(isA<RangeError>()),
      );
    });

    test('deve funcionar com apenas uma letra', () {
      expect(Validators.formatName('j'), equals('J'));
    });
  });
}