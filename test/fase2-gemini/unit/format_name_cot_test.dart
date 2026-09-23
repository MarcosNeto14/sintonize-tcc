import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.formatName', () {
    group('Cenários de Sucesso (Entradas Válidas)', () {
      test('deve capitalizar uma única palavra minúscula', () {
        final result = Validators.formatName('joão');
        expect(result, equals('João'));
      });

      test('deve capitalizar todas as palavras de um nome composto com espaço simples', () {
        final result = Validators.formatName('maria da silva');
        expect(result, equals('Maria Da Silva'));
      });

      test('deve manter a formatação se as palavras já estiverem capitalizadas', () {
        final result = Validators.formatName('Carlos Alberto');
        expect(result, equals('Carlos Alberto'));
      });

      test('deve capitalizar palavra de apenas um caractere', () {
        final result = Validators.formatName('a b c');
        expect(result, equals('A B C'));
      });
    });

    group('Casos de Borda', () {
      test('deve retornar string vazia sem erros quando receber string vazia', () {
        final result = Validators.formatName('');
        expect(result, equals(''));
      });

      test('deve manter números e caracteres especiais sem quebrar a execução', () {
        final result = Validators.formatName('123 teste');
        expect(result, equals('123 Teste'));
      });

      test('deve preservar letras maiúsculas internas da palavra', () {
        final result = Validators.formatName('mcDonald iPhone');
        expect(result, equals('McDonald IPhone'));
      });
    });

    group('Cenários de Falha / Comportamentos Inesperados da Implementação Atual', () {
      test('lança RangeError ao receber espaços no início ou fim', () {
        expect(
          () => Validators.formatName(' ana '),
          throwsA(isA<RangeError>()),
        );
      });

      test('lança RangeError ao receber múltiplos espaços consecutivos', () {
        expect(
          () => Validators.formatName('joao  silva'),
          throwsA(isA<RangeError>()),
        );
      });
    });
  });
}

