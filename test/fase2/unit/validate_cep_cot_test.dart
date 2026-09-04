import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateCEP', () {
    group('Cenários de sucesso', () {
      test('deve retornar null para um CEP válido', () {
        const cep = '12345-678';

        final result = Validators.validateCEP(cep);

        expect(result, isNull);
      });

      test('deve aceitar CEP começando com zeros', () {
        const cep = '01234-567';

        final result = Validators.validateCEP(cep);

        expect(result, isNull);
      });

      test('deve aceitar CEP com todos os dígitos iguais', () {
        const cep = '11111-111';

        final result = Validators.validateCEP(cep);

        expect(result, isNull);
      });

      test('deve aceitar CEP no limite superior do formato', () {
        const cep = '99999-999';

        final result = Validators.validateCEP(cep);

        expect(result, isNull);
      });
    });

    group('Cenários de falha - campo obrigatório', () {
      test('deve retornar mensagem de obrigatório quando o valor for null', () {
        final result = Validators.validateCEP(null);

        expect(result, 'O CEP é obrigatório');
      });

      test('deve retornar mensagem de obrigatório quando o valor for vazio', () {
        final result = Validators.validateCEP('');

        expect(result, 'O CEP é obrigatório');
      });
    });

    group('Cenários de falha - formato inválido', () {
      test('deve rejeitar CEP sem hífen', () {
        const cep = '12345678';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });

      test('deve rejeitar CEP com hífen na posição errada', () {
        const cep = '1234-5678';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });

      test('deve rejeitar CEP com menos de cinco dígitos antes do hífen', () {
        const cep = '1234-567';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });

      test('deve rejeitar CEP com mais de cinco dígitos antes do hífen', () {
        const cep = '123456-78';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });

      test('deve rejeitar CEP com menos de três dígitos depois do hífen', () {
        const cep = '12345-67';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });

      test('deve rejeitar CEP com mais de três dígitos depois do hífen', () {
        const cep = '12345-6789';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });

      test('deve rejeitar CEP contendo letras', () {
        const cep = '1234A-678';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });

      test('deve rejeitar CEP contendo caracteres especiais', () {
        const cep = '12345-67@';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });

      test('deve rejeitar CEP com espaço no início', () {
        const cep = ' 12345-678';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });

      test('deve rejeitar CEP com espaço no final', () {
        const cep = '12345-678 ';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });

      test('deve rejeitar CEP com espaço no lugar do hífen', () {
        const cep = '12345 678';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });

      test('deve rejeitar CEP com hífen duplicado', () {
        const cep = '12345--678';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });
    });

    group('Casos de borda', () {
      test('deve rejeitar string com exatamente nove caracteres, mas formato inválido', () {
        const cep = '123456789';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });

      test('deve rejeitar string com menos de nove caracteres', () {
        const cep = '12345-67';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });

      test('deve rejeitar string com mais de nove caracteres', () {
        const cep = '12345-6789';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });

      test('deve rejeitar dígitos Unicode que não sejam 0-9 ASCII', () {
        const cep = '１２３４５-６７８';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });

      test('deve rejeitar CEP contendo quebra de linha', () {
        const cep = '12345-67\n';

        final result = Validators.validateCEP(cep);

        expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
      });
    });
  });
}
