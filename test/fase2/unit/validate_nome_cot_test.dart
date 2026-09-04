import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateNome', () {
    group('Cenários de sucesso', () {
      test('deve retornar null para um nome simples', () {
        expect(Validators.validateNome('João'), isNull);
      });

      test('deve retornar null para um nome completo com espaços', () {
        expect(Validators.validateNome('João da Silva'), isNull);
      });

      test('deve retornar null para nome com letras maiúsculas e minúsculas', () {
        expect(Validators.validateNome('JoÃo Silva'), isNull);
      });

      test('deve retornar null para nome com caracteres acentuados', () {
        expect(Validators.validateNome('José Álvaro'), isNull);
      });

      test('deve retornar null para um nome com espaço no início e no fim', () {
        expect(Validators.validateNome(' João Silva '), isNull);
      });
    });

    group('Cenários de falha', () {
      test('deve retornar mensagem de obrigatório quando o valor for null', () {
        expect(
          Validators.validateNome(null),
          equals('O nome é obrigatório'),
        );
      });

      test('deve retornar mensagem de obrigatório quando o valor estiver vazio', () {
        expect(
          Validators.validateNome(''),
          equals('O nome é obrigatório'),
        );
      });

      test('deve rejeitar nome contendo números', () {
        expect(
          Validators.validateNome('João123'),
          equals('O nome não pode conter números ou caracteres especiais'),
        );
      });

      test('deve rejeitar nome contendo caracteres especiais', () {
        expect(
          Validators.validateNome('João!'),
          equals('O nome não pode conter números ou caracteres especiais'),
        );
      });

      test('deve rejeitar nome contendo hífen', () {
        expect(
          Validators.validateNome('João-Silva'),
          equals('O nome não pode conter números ou caracteres especiais'),
        );
      });

      test('deve rejeitar nome contendo ponto', () {
        expect(
          Validators.validateNome('João.Silva'),
          equals('O nome não pode conter números ou caracteres especiais'),
        );
      });

      test('deve rejeitar nome contendo underscore', () {
        expect(
          Validators.validateNome('João_Silva'),
          equals('O nome não pode conter números ou caracteres especiais'),
        );
      });

      test('deve rejeitar nome contendo emoji', () {
        expect(
          Validators.validateNome('João 😀'),
          equals('O nome não pode conter números ou caracteres especiais'),
        );
      });

      test('deve rejeitar nome contendo símbolos', () {
        expect(
          Validators.validateNome('João@Silva#'),
          equals('O nome não pode conter números ou caracteres especiais'),
        );
      });

      test('deve rejeitar nome com caracteres Unicode fora do intervalo permitido', () {
        expect(
          Validators.validateNome('Алексей'),
          equals('O nome não pode conter números ou caracteres especiais'),
        );
      });
    });

    group('Casos de borda', () {
      test('deve considerar uma string contendo apenas espaços como válida', () {
        expect(Validators.validateNome('   '), isNull);
      });

      test('deve considerar tabulação como caractere válido', () {
        expect(Validators.validateNome('\t'), isNull);
      });

      test('deve considerar quebra de linha como caractere válido', () {
        expect(Validators.validateNome('\n'), isNull);
      });

      test('deve aceitar caracteres no intervalo suportado de À a ÿ', () {
        expect(Validators.validateNome('Àÿ'), isNull);
      });

      test('deve rejeitar uma mistura de letras e caracteres inválidos', () {
        expect(
          Validators.validateNome('João 123!'),
          equals('O nome não pode conter números ou caracteres especiais'),
        );
      });

      test('deve aceitar um nome com múltiplos espaços entre as palavras', () {
        expect(Validators.validateNome('João   da   Silva'), isNull);
      });
    });
  });
}
