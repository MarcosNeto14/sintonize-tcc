import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.formatName', () {
    test('Deve capitalizar uma única palavra', () {
      expect(Validators.formatName('joao'), 'Joao');
    });

    test('Deve capitalizar múltiplas palavras', () {
      expect(Validators.formatName('joao silva'), 'Joao Silva');
    });

    test('Deve manter palavras já capitalizadas', () {
      expect(Validators.formatName('Joao Silva'), 'Joao Silva');
    });

    test('Deve lidar com mistura de maiúsculas e minúsculas', () {
      expect(Validators.formatName('jOaO sIlVa'), 'JOaO SIlVa');
    });

    test('Deve retornar string vazia quando input for vazio', () {
      expect(Validators.formatName(''), '');
    });

    test('Deve lançar erro com múltiplos espaços entre palavras', () {
      expect(
        () => Validators.formatName('joao   silva'),
        throwsA(isA<RangeError>()),
      );
    });

    test('Deve lançar erro com espaços no início e fim', () {
      expect(
        () => Validators.formatName('  joao silva  '),
        throwsA(isA<RangeError>()),
      );
    });

    test('Deve lançar erro com string contendo apenas espaço', () {
      expect(
        () => Validators.formatName(' '),
        throwsA(isA<RangeError>()),
      );
    });

    test('Deve lidar com nomes com caracteres especiais', () {
      expect(Validators.formatName('joão da silva'), 'João Da Silva');
    });

    test('Deve lidar com nomes com hífen', () {
      expect(Validators.formatName('joao-pedro'), 'Joao-pedro');
    });
  });
}