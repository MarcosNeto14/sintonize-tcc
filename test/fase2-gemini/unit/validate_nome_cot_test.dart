import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateNome', () {
    group('Cenários de Sucesso', () {
      test('deve retornar null para nome simples com letras maiúsculas e minúsculas', () {
        final result = Validators.validateNome('Carlos');
        expect(result, isNull);
      });

      test('deve retornar null para nome completo separado por espaços', () {
        final result = Validators.validateNome('Maria Clara Silva');
        expect(result, isNull);
      });

      test('deve retornar null para nomes contendo acentuações e caracteres latinos', () {
        final result = Validators.validateNome('João Lúcio da Conceição');
        expect(result, isNull);
      });
    });

    group('Cenários de Falha - Obrigatoriedade', () {
      test('deve retornar erro de obrigatoriedade quando o valor for null', () {
        final result = Validators.validateNome(null);
        expect(result, 'O nome é obrigatório');
      });

      test('deve retornar erro de obrigatoriedade quando a string for vazia', () {
        final result = Validators.validateNome('');
        expect(result, 'O nome é obrigatório');
      });
    });

    group('Cenários de Falha - Caracteres Inválidos', () {
      test('deve retornar erro quando o nome contiver números', () {
        final resultComNumeroNoFim = Validators.validateNome('Lucas123');
        final resultComNumeroNoMeio = Validators.validateNome('Pedro 2 Silva');

        expect(resultComNumeroNoFim, 'O nome não pode conter números ou caracteres especiais');
        expect(resultComNumeroNoMeio, 'O nome não pode conter números ou caracteres especiais');
      });

      test('deve retornar erro quando o nome contiver símbolos ou pontuação especial', () {
        final resultComArroba = Validators.validateNome('Ana@Silva');
        final resultComUnderline = Validators.validateNome('Marcos_Vinicius');
        final resultComExclamacao = Validators.validateNome('José!');

        expect(resultComArroba, 'O nome não pode conter números ou caracteres especiais');
        expect(resultComUnderline, 'O nome não pode conter números ou caracteres especiais');
        expect(resultComExclamacao, 'O nome não pode conter números ou caracteres especiais');
      });

      test('deve rejeitar hífens e apóstrofos com a implementação atual da regex', () {
        final resultHifen = Validators.validateNome('Jean-Luc');
        final resultApostrofo = Validators.validateNome("D'Ávila");

        expect(resultHifen, 'O nome não pode conter números ou caracteres especiais');
        expect(resultApostrofo, 'O nome não pode conter números ou caracteres especiais');
      });
    });

    group('Casos de Borda', () {
      test('deve aceitar uma única letra válida', () {
        final result = Validators.validateNome('A');
        expect(result, isNull);
      });

      test('deve aceitar string com apenas espaços com a implementação atual (sem trim)', () {
        // value.isEmpty é falso para "   " e \s dá match em espaços
        final result = Validators.validateNome('   ');
        expect(result, isNull);
      });

      test('deve aceitar caracteres de espaçamento como tabulação e quebra de linha', () {
        final result = Validators.validateNome("Carlos\tEduardo\nSouza");
        expect(result, isNull);
      });
    });
  });
}

