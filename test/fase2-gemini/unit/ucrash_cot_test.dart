import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.capitalize', () {
    group('Cenários de Sucesso (Entradas Válidas)', () {
      test('deve capitalizar uma palavra simples em minúsculo', () {
        final result = Validators.capitalize('joao');
        expect(result, equals('Joao'));
      });

      test('deve converter palavras com caixa mista para Title Case', () {
        final result = Validators.capitalize('maRIA silva');
        expect(result, equals('Maria Silva'));
      });

      test('deve manter a formatação se o texto já estiver capitalizado', () {
        final result = Validators.capitalize('Flutter Dart');
        expect(result, equals('Flutter Dart'));
      });

      test('deve capitalizar palavra composta por um único caractere', () {
        final result = Validators.capitalize('a');
        expect(result, equals('A'));
      });

      test('deve preservar números e pontuações iniciais em palavras', () {
        final result = Validators.capitalize('123 abc');
        expect(result, equals('123 Abc'));
      });
    });

    group('Casos de Borda', () {
      test('deve retornar string vazia quando a entrada for vazia', () {
        final result = Validators.capitalize('');
        expect(result, equals(''));
      });

      test('deve tratar caracteres acentuados corretamente', () {
        final result = Validators.capitalize('órgão público');
        expect(result, equals('Órgão Público'));
      });
    });

    group('Casos de Falha / Limitações da Implementação Atual', () {
      test(
        'lança RangeError ao receber múltiplos espaços consecutivos',
        () {
          // split(' ') gera strings vazias ("") que quebram em word[0]
          expect(
            () => Validators.capitalize('maria  silva'),
            throwsA(isA<RangeError>()),
          );
        },
      );

      test(
        'lança RangeError ao receber espaços no início ou fim',
        () {
          expect(
            () => Validators.capitalize(' maria '),
            throwsA(isA<RangeError>()),
          );
        },
      );

      test(
        'lança RangeError ao receber apenas espaços em branco',
        () {
          expect(
            () => Validators.capitalize('   '),
            throwsA(isA<RangeError>()),
          );
        },
      );
    });
  });
}
