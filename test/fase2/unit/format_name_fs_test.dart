import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('formatName', () {
    test('deve retornar string vazia quando nome é vazio', () {
      expect(Validators.formatName(''), '');
    });

    test('deve colocar a primeira letra do nome em maiúscula', () {
      expect(Validators.formatName('joao'), 'Joao');
    });

    test('deve colocar a primeira letra de cada palavra em maiúscula', () {
      expect(Validators.formatName('joao da silva'), 'Joao Da Silva');
    });

    test('deve manter o restante das letras como estão', () {
      expect(Validators.formatName('jOAO dA sIlVa'), 'JOAO DA SIlVa');
    });
  });
}
