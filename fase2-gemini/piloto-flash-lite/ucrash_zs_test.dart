import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart'; // Ajuste o import conforme a estrutura real do seu projeto

void main() {
  group('Validators.capitalize', () {
    group('Cenários de Sucesso', () {
      test('deve capitalizar corretamente um nome simples em letras minúsculas', () {
        final result = Validators.capitalize('maria');
        expect(result, equals('Maria'));
      });

      test('deve corrigir um nome misturado com maiúsculas e minúsculas aleatórias', () {
        final result = Validators.capitalize('maRIA');
        expect(result, equals('Maria'));
      });

      test('deve capitalizar corretamente um nome completo com múltiplos espaços e letras misturadas', () {
        final result = Validators.capitalize('maRIA silva');
        expect(result, equals('Maria Silva'));
      });

      test('deve capitalizar uma frase completa com várias palavras', () {
        final result = Validators.capitalize('joão pedro DE oliveira');
        // Nota: A lógica atual aplica toLowerCase em todo o restante, 
        // então conectores como "de" virarão "De". Se esse for o comportamento esperado:
        expect(result, equals('João Pedro De Oliveira'));
      });
    });

    group('Casos de Borda e Valores Limites', () {
      test('deve retornar uma string vazia quando a entrada for vazia', () {
        final result = Validators.capitalize('');
        expect(result, equals(''));
      });

      test('deve lidar corretamente com uma única letra', () {
        final result = Validators.capitalize('a');
        expect(result, equals('A'));
      });

      test('deve lidar corretamente com uma única letra maiúscula', () {
        final result = Validators.capitalize('Z');
        expect(result, equals('Z'));
      });

      test('deve lidar com espaços extras nas extremidades ou múltiplos espaços', () {
        // Cuidado: split(' ') com espaços múltiplos cria palavras vazias ('') 
        // que podem causar comportamentos indesejados dependendo da implementação.
        // Este teste documenta o comportamento atual da função com espaços.
        expect(() => Validators.capitalize('  '), returnsNormally);
      });
    });

    group('Cenários de Falha / Erros esperados', () {
      test('deve lançar RangeError ao tentar capitalizar uma string contendo apenas um espaço', () {
        // AVISO DE BUG CONHECIDO NA IMPLEMENTAÇÃO:
        // Se a entrada for ' ' (espaço simples), o split gera ['']. 
        // word[0] tenta acessar o índice 0 de uma string vazia, lançando StateError/RangeError.
        expect(
          () => Validators.capitalize(' '),
          throwsA(isA<RangeError>()),
        );
      });

      test('deve lançar RangeError quando houver múltiplos espaços consecutivos gerando vazios internos', () {
        // AVISO DE BUG CONHECIDO NA IMPLEMENTAÇÃO:
        // Espaços duplos como "Ana  Silva" geram strings vazias no split, 
        // disparando RangeError ao tentar pegar word[0].
        expect(
          () => Validators.capitalize('Ana  Silva'),
          throwsA(isA<RangeError>()),
        );
      });
    });
  });
}
