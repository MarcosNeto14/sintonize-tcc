import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.formatName', () {
    group('Cenários de Sucesso', () {
      test('deve capitalizar a primeira letra de um nome simples em minúsculo', () {
        final result = Validators.formatName('joao');
        expect(result, equals('Joao'));
      });

      test('deve capitalizar cada palavra de um nome composto', () {
        final result = Validators.formatName('joao da silva');
        expect(result, equals('Joao Da Silva'));
      });

      test('deve manter nomes que já estão com a primeira letra maiúscula', () {
        final result = Validators.formatName('Maria Souza');
        expect(result, equals('Maria Souza'));
      });

      test('deve capitalizar corretamente palavras com apenas um caractere', () {
        final result = Validators.formatName('e');
        expect(result, equals('E'));
      });

      test('deve capitalizar corretamente palavras com acentuação', () {
        final result = Validators.formatName('édipo ângelo');
        expect(result, equals('Édipo Ângelo'));
      });
    });

    group('Casos de Borda (Edge Cases)', () {
      test('deve retornar a própria string se ela for vazia', () {
        final result = Validators.formatName('');
        expect(result, equals(''));
      });

      test('não deve alterar palavras que já estão totalmente em maiúsculas', () {
        // Como a função não aplica .toLowerCase() no resto da string,
        // o comportamento esperado do código atual é manter as demais letras maiúsculas.
        final result = Validators.formatName('SILVA');
        expect(result, equals('SILVA'));
      });
    });

    group('Cenários de Falha / Limitações da Implementação Atual', () {
      test('lança RangeError quando a entrada contém espaços múltiplos consecutivos', () {
        // 'joao  silva'.split(' ') gera elementos vazios (''),
        // fazendo word[0] estourar o índice da string (RangeError).
        expect(
          () => Validators.formatName('joao  silva'),
          throwsA(isA<RangeError>()),
        );
      });

      test('lança RangeError quando a entrada contém espaços no início ou fim', () {
        expect(
          () => Validators.formatName(' joao'),
          throwsA(isA<RangeError>()),
        );
        expect(
          () => Validators.formatName('joao '),
          throwsA(isA<RangeError>()),
        );
      });

      test('lança RangeError quando a string contém apenas espaços em branco', () {
        expect(
          () => Validators.formatName('   '),
          throwsA(isA<RangeError>()),
        );
      });
    });
  });
}

