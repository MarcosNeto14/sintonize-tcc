import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateNome', () {
    group('Casos de sucesso', () {
      test('deve retornar null para um nome simples', () {
        expect(Validators.validateNome('João'), isNull);
      });

      test('deve retornar null para nome e sobrenome', () {
        expect(Validators.validateNome('João Silva'), isNull);
      });

      test('deve retornar null para nome com múltiplos espaços', () {
        expect(Validators.validateNome('João da Silva'), isNull);
      });

      test('deve retornar null para nome com acentos', () {
        expect(Validators.validateNome('José Antônio'), isNull);
      });

      test('deve retornar null para letras maiúsculas e minúsculas', () {
        expect(Validators.validateNome('JoSÉ da SILVA'), isNull);
      });

      test('deve retornar null para nome contendo apenas espaços', () {
        expect(Validators.validateNome(' '), isNull);
      });

      test('deve retornar null para nome contendo tabulação', () {
        expect(Validators.validateNome('João\tSilva'), isNull);
      });

      test('deve retornar null para nome contendo quebra de linha', () {
        expect(Validators.validateNome('João\nSilva'), isNull);
      });
    });

    group('Casos de falha', () {
      test('deve retornar erro quando o valor for null', () {
        expect(
          Validators.validateNome(null),
          equals('O nome é obrigatório'),
        );
      });

      test('deve retornar erro quando o nome estiver vazio', () {
        expect(
          Validators.validateNome(''),
          equals('O nome é obrigatório'),
        );
      });

      test('deve retornar erro quando o nome contiver números', () {
        expect(
          Validators.validateNome('João123'),
          equals('O nome não pode conter números ou caracteres especiais'),
        );
      });

      test('deve retornar erro quando o nome contiver caracteres especiais', () {
        expect(
          Validators.validateNome('João@Silva'),
          equals('O nome não pode conter números ou caracteres especiais'),
        );
      });

      test('deve retornar erro quando o nome contiver hífen', () {
        expect(
          Validators.validateNome('Maria-José'),
          equals('O nome não pode conter números ou caracteres especiais'),
        );
      });

      test('deve retornar erro quando o nome contiver apóstrofo', () {
        expect(
          Validators.validateNome("D'Angelo"),
          equals('O nome não pode conter números ou caracteres especiais'),
        );
      });
    });

    group('Casos de borda', () {
      test('deve aceitar caracteres acentuados no limite suportado', () {
        expect(Validators.validateNome('Àÿ'), isNull);
      });

      test('deve aceitar espaços no início e no fim', () {
        expect(Validators.validateNome(' João Silva '), isNull);
      });

      test('deve rejeitar emoji', () {
        expect(
          Validators.validateNome('João 😀'),
          equals('O nome não pode conter números ou caracteres especiais'),
        );
      });

      test('deve rejeitar nome contendo apenas números', () {
        expect(
          Validators.validateNome('123456'),
          equals('O nome não pode conter números ou caracteres especiais'),
        );
      });

      test('deve rejeitar nome contendo apenas caracteres especiais', () {
        expect(
          Validators.validateNome('@#\$%'),
          equals('O nome não pode conter números ou caracteres especiais'),
        );
      });
    });
  });
}
