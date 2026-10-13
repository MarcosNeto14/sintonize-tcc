import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.capitalize', () {
    group('Cenários de Sucesso', () {
      test('deve capitalizar uma única palavra em minúsculo', () {
        final result = Validators.capitalize('teste');
        expect(result, equals('Teste'));
      });

      test('deve capitalizar uma palavra com caracteres mistos (maiúsculos e minúsculos)', () {
        final result = Validators.capitalize('mArIa');
        expect(result, equals('Maria'));
      });

      test('deve converter palavras em caixa alta mantendo apenas a inicial maiúscula', () {
        final result = Validators.capitalize('MARIA SILVA');
        expect(result, equals('Maria Silva'));
      });

      test('deve capitalizar corretamente múltiplas palavras separadas por espaço simples', () {
        final result = Validators.capitalize('joão da silva');
        expect(result, equals('João Da Silva'));
      });

      test('deve manter caracteres acentuados ao capitalizar', () {
        final result = Validators.capitalize('álvaro érico');
        expect(result, equals('Álvaro Érico'));
      });
    });

    group('Casos de Borda Válidos', () {
      test('deve retornar a própria string quando for vazia', () {
        final result = Validators.capitalize('');
        expect(result, equals(''));
      });

      test('deve processar palavras de apenas uma letra', () {
        final result = Validators.capitalize('a b c');
        expect(result, equals('A B C'));
      });

      test('não deve alterar palavras que já começam com números ou símbolos', () {
        final result = Validators.capitalize('123 teste #flutter');
        expect(result, equals('123 Teste #flutter'));
      });
    });

    group('Casos de Falha / Limitações da Implementação Atual', () {
      test('deve lançar RangeError quando houver múltiplos espaços consecutivos', () {
        // split(' ') gera strings vazias "", e word[0] falha com RangeError
        expect(
          () => Validators.capitalize('maria  silva'),
          throwsA(isA<RangeError>()),
        );
      });

      test('deve lançar RangeError se a string contiver apenas espaços', () {
        expect(
          () => Validators.capitalize('   '),
          throwsA(isA<RangeError>()),
        );
      });

      test('deve lançar RangeError se houver espaços no início ou no fim', () {
        expect(
          () => Validators.capitalize(' maria silva '),
          throwsA(isA<RangeError>()),
        );
      });
    });
  });
}
