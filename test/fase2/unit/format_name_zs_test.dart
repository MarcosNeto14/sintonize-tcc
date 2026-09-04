import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.formatName', () {
    group('Casos de sucesso', () {
      test('deve retornar o nome vazio quando receber uma string vazia', () {
        expect(Validators.formatName(''), '');
      });

      test('deve capitalizar a primeira letra de um nome simples', () {
        expect(Validators.formatName('joao'), 'Joao');
      });

      test('deve capitalizar a primeira letra de cada palavra', () {
        expect(
          Validators.formatName('joao da silva'),
          'Joao Da Silva',
        );
      });

      test('deve preservar o restante das letras da palavra', () {
        expect(
          Validators.formatName('jOaO dA sIlVa'),
          'JOaO DA SIlVa',
        );
      });

      test('deve funcionar com uma única letra', () {
        expect(Validators.formatName('a'), 'A');
      });
    });

    group('Casos de falha', () {
      test('deve lançar RangeError quando houver espaços consecutivos', () {
        expect(
          () => Validators.formatName('joao  silva'),
          throwsRangeError,
        );
      });

      test('deve lançar RangeError quando houver apenas espaços', () {
        expect(
          () => Validators.formatName('   '),
          throwsRangeError,
        );
      });

      test('deve lançar RangeError quando o nome começar com espaço', () {
        expect(
          () => Validators.formatName(' joao'),
          throwsRangeError,
        );
      });

      test('deve lançar RangeError quando o nome terminar com espaço', () {
        expect(
          () => Validators.formatName('joao '),
          throwsRangeError,
        );
      });
    });

    group('Casos de borda', () {
      test('deve preservar espaços simples entre as palavras', () {
        expect(
          Validators.formatName('joao silva'),
          'Joao Silva',
        );
      });

      test('deve aceitar caracteres especiais dentro da palavra', () {
        expect(
          Validators.formatName("d'angelo"),
          "D'angelo",
        );
      });

      test('deve manter números no restante da palavra', () {
        expect(
          Validators.formatName('joao123'),
          'Joao123',
        );
      });

      test('deve manter uma palavra que já começa com letra maiúscula', () {
        expect(
          Validators.formatName('Joao'),
          'Joao',
        );
      });
    });
  });
}
