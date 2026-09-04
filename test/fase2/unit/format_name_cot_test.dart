import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.formatName', () {
    group('Cenários de sucesso', () {
      test('deve formatar uma única palavra', () {
        expect(
          Validators.formatName('joao'),
          equals('Joao'),
        );
      });

      test('deve formatar um nome com duas palavras', () {
        expect(
          Validators.formatName('joao silva'),
          equals('Joao Silva'),
        );
      });

      test('deve formatar um nome com várias palavras', () {
        expect(
          Validators.formatName('maria da silva'),
          equals('Maria Da Silva'),
        );
      });

      test('deve manter um nome que já está formatado', () {
        expect(
          Validators.formatName('Joao Silva'),
          equals('Joao Silva'),
        );
      });

      test('deve preservar palavras totalmente em maiúsculas', () {
        expect(
          Validators.formatName('JOAO'),
          equals('JOAO'),
        );
      });

      test('deve formatar uma palavra com uma única letra', () {
        expect(
          Validators.formatName('a'),
          equals('A'),
        );
      });

      test('deve preservar caracteres especiais no início da palavra', () {
        expect(
          Validators.formatName('@joao'),
          equals('@joao'),
        );
      });

      test('deve preservar números', () {
        expect(
          Validators.formatName('123'),
          equals('123'),
        );
      });

      test('deve preservar palavras que começam com números', () {
        expect(
          Validators.formatName('123abc'),
          equals('123abc'),
        );
      });

      test('deve formatar caracteres acentuados', () {
        expect(
          Validators.formatName('áurea'),
          equals('Áurea'),
        );
      });
    });

    group('Casos de borda', () {
      test('deve retornar uma string vazia quando a entrada for vazia', () {
        expect(
          Validators.formatName(''),
          equals(''),
        );
      });

      test('deve lançar RangeError quando a entrada contém apenas espaços', () {
        expect(
          () => Validators.formatName('   '),
          throwsRangeError,
        );
      });

      test('deve lançar RangeError quando existem espaços consecutivos', () {
        expect(
          () => Validators.formatName('joao  silva'),
          throwsRangeError,
        );
      });

      test('deve lançar RangeError quando existe espaço no início', () {
        expect(
          () => Validators.formatName(' joao'),
          throwsRangeError,
        );
      });

      test('deve lançar RangeError quando existe espaço no final', () {
        expect(
          () => Validators.formatName('joao '),
          throwsRangeError,
        );
      });
    });
  });
}
