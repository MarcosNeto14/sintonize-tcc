import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.capitalize', () {
    group('cenários de sucesso', () {
      test('deve retornar uma string vazia quando a entrada for vazia', () {
        expect(Validators.capitalize(''), '');
      });

      test('deve capitalizar uma única palavra em minúsculas', () {
        expect(Validators.capitalize('maria'), 'Maria');
      });

      test('deve normalizar uma palavra em maiúsculas', () {
        expect(Validators.capitalize('MARIA'), 'Maria');
      });

      test('deve normalizar uma palavra com capitalização misturada', () {
        expect(Validators.capitalize('maRIA'), 'Maria');
      });

      test('deve capitalizar todas as palavras de um nome', () {
        expect(
          Validators.capitalize('maRIA silva'),
          'Maria Silva',
        );
      });

      test('deve normalizar um nome completamente em maiúsculas', () {
        expect(
          Validators.capitalize('MARIA SILVA'),
          'Maria Silva',
        );
      });

      test('deve preservar e normalizar caracteres acentuados', () {
        expect(
          Validators.capitalize('joÃO da silva'),
          'João Da Silva',
        );
      });

      test('deve capitalizar uma palavra com apenas um caractere', () {
        expect(Validators.capitalize('a'), 'A');
      });

      test('deve preservar números e caracteres especiais', () {
        expect(
          Validators.capitalize('123 abc @TESTE'),
          '123 Abc @teste',
        );
      });
    });

    group('cenários de falha e entradas inesperadas', () {
      test('deve lançar RangeError quando houver espaços consecutivos', () {
        expect(
          () => Validators.capitalize('maria  silva'),
          throwsRangeError,
        );
      });

      test('deve lançar RangeError quando houver espaço no início', () {
        expect(
          () => Validators.capitalize(' maria'),
          throwsRangeError,
        );
      });

      test('deve lançar RangeError quando houver espaço no final', () {
        expect(
          () => Validators.capitalize('maria '),
          throwsRangeError,
        );
      });
    });
  });
}
