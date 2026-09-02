import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.capitalize', () {
    group('Casos de sucesso', () {
      test('deve capitalizar a primeira letra e colocar o restante em minúsculas', () {
        expect(
          Validators.capitalize('maRIA silva'),
          equals('Maria Silva'),
        );
      });

      test('deve capitalizar todas as palavras de um texto', () {
        expect(
          Validators.capitalize('jOÃO DA sILVA'),
          equals('João Da Silva'),
        );
      });

      test('deve preservar uma única palavra corretamente', () {
        expect(
          Validators.capitalize('mARIA'),
          equals('Maria'),
        );
      });

      test('deve retornar o texto vazio quando a entrada for vazia', () {
        expect(
          Validators.capitalize(''),
          equals(''),
        );
      });
    });

    group('Casos de borda', () {
      test('deve aceitar uma palavra com apenas uma letra', () {
        expect(
          Validators.capitalize('a'),
          equals('A'),
        );
      });

      test('deve colocar uma palavra já capitalizada em formato correto', () {
        expect(
          Validators.capitalize('Maria'),
          equals('Maria'),
        );
      });

      test('deve converter uma palavra totalmente em maiúsculas', () {
        expect(
          Validators.capitalize('MARIA'),
          equals('Maria'),
        );
      });

      test('deve tratar corretamente números e caracteres sem letras', () {
        expect(
          Validators.capitalize('123 ABC'),
          equals('123 Abc'),
        );
      });
    });

    group('Casos de falha', () {
      test('deve lançar RangeError quando houver duas palavras separadas por '
          'dois espaços', () {
        expect(
          () => Validators.capitalize('maria  silva'),
          throwsRangeError,
        );
      });

      test('deve lançar RangeError quando houver um espaço no início', () {
        expect(
          () => Validators.capitalize(' maria'),
          throwsRangeError,
        );
      });

      test('deve lançar RangeError quando houver um espaço no final', () {
        expect(
          () => Validators.capitalize('maria '),
          throwsRangeError,
        );
      });

      test('deve lançar RangeError quando houver somente espaços', () {
        expect(
          () => Validators.capitalize('   '),
          throwsRangeError,
        );
      });
    });
  });
}
