import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators - validateCEP', () {
    group('Casos de Sucesso', () {
      test('deve retornar null para CEP válido no formato padrão', () {
        final result = Validators.validateCEP('50000-000');
        expect(result, isNull);
      });

      test('deve retornar null para outro CEP válido com dígitos variados', () {
        final result = Validators.validateCEP('01310-200');
        expect(result, isNull);
      });
    });

    group('Validação de Obrigatoriedade (Nulo / Vazio)', () {
      test('deve retornar mensagem de obrigatoriedade quando o valor for null', () {
        final result = Validators.validateCEP(null);
        expect(result, 'O CEP é obrigatório');
      });

      test('deve retornar mensagem de obrigatoriedade quando o valor for vazio', () {
        final result = Validators.validateCEP('');
        expect(result, 'O CEP é obrigatório');
      });
    });

    group('Validação de Formato e Casos de Borda', () {
      const invalidFormatMessage = 'CEP inválido. Formato correto: XXXXX-XXX';

      test('deve falhar para CEP sem hífen (apenas números)', () {
        final result = Validators.validateCEP('50000000');
        expect(result, invalidFormatMessage);
      });

      test('deve falhar para CEP com menos de 9 caracteres', () {
        final result = Validators.validateCEP('1234-567');
        expect(result, invalidFormatMessage);
      });

      test('deve falhar para CEP com mais de 9 caracteres', () {
        final result = Validators.validateCEP('123456-7890');
        expect(result, invalidFormatMessage);
      });

      test('deve falhar para CEP com hífen na posição incorreta', () {
        final result = Validators.validateCEP('1234-5678');
        expect(result, invalidFormatMessage);
      });

      test('deve falhar quando contiver letras', () {
        final result = Validators.validateCEP('5000A-000');
        expect(result, invalidFormatMessage);
      });

      test('deve falhar quando contiver caracteres especiais inválidos', () {
        final result = Validators.validateCEP('50000.000');
        expect(result, invalidFormatMessage);
      });

      test('deve falhar para CEP com espaços internos ou em branco', () {
        expect(Validators.validateCEP('   -   '), invalidFormatMessage);
        expect(Validators.validateCEP('50000 000'), invalidFormatMessage);
      });

      test('deve falhar para CEP válido com espaços extras nas pontas', () {
        // Como a função não aplica .trim(), deve acusar erro de tamanho/formato
        final result = Validators.validateCEP(' 50000-000 ');
        expect(result, invalidFormatMessage);
      });
    });
  });
}

