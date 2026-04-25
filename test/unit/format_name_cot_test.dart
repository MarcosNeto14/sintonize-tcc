import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.formatName', () {
    test('Deve capitalizar apenas a primeira letra de cada palavra', () {
      expect(
        Validators.formatName('jOaO sIlVa'),
        'Joao Silva',
      );
    });

    test('Deve funcionar com uma única palavra', () {
      expect(
        Validators.formatName('maria'),
        'Maria',
      );
    });

    test('Deve lidar com string contendo apenas espaços', () {
      expect(
        Validators.formatName('   '),
        '',
      );
    });

    test('Deve lidar com múltiplos espaços entre palavras', () {
      expect(
        Validators.formatName('joao   silva'),
        'Joao Silva',
      );
    });

    test('Deve lidar com espaço no início', () {
      expect(
        Validators.formatName(' joao'),
        'Joao',
      );
    });

    test('Deve lidar com espaço no final', () {
      expect(
        Validators.formatName('joao '),
        'Joao',
      );
    });

    test('Deve lidar com espaços mistos (início, meio e fim)', () {
      expect(
        Validators.formatName('   joao   silva   '),
        'Joao Silva',
      );
    });

    test('Deve manter string vazia como vazia', () {
      expect(
        Validators.formatName(''),
        '',
      );
    });
  });
}