// test/utils/validators_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateSenha', () {
    group('Cenários de falha - Campo vazio ou nulo', () {
      test('deve retornar mensagem de erro quando o valor for nulo', () {
        final result = Validators.validateSenha(null);
        expect(result, 'Por favor, insira sua senha');
      });

      test('deve retornar mensagem de erro quando o valor for uma string vazia', () {
        final result = Validators.validateSenha('');
        expect(result, 'Por favor, insira sua senha');
      });
    });

    group('Cenários de falha - Tamanho menor que o permitido (< 7)', () {
      test('deve retornar mensagem de erro para senha com 1 caractere', () {
        final result = Validators.validateSenha('1');
        expect(result, 'A senha deve ter pelo menos 6 caracteres');
      });

      test('deve retornar mensagem de erro para senha com 5 caracteres', () {
        final result = Validators.validateSenha('12345');
        expect(result, 'A senha deve ter pelo menos 6 caracteres');
      });

      test('deve falhar para 6 caracteres devido à regra atual (length < 7)', () {
        // Caso de borda crítico: se a intenção for aceitar 6 caracteres,
        // a implementação precisará ser ajustada para `value.length < 6`.
        final result = Validators.validateSenha('123456');
        expect(result, 'A senha deve ter pelo menos 6 caracteres');
      });
    });

    group('Cenários de sucesso (>= 7 caracteres)', () {
      test('deve retornar null para o caso de borda com exatamente 7 caracteres', () {
        final result = Validators.validateSenha('1234567');
        expect(result, isNull);
      });

      test('deve retornar null para senhas longas com caracteres especiais e espaços', () {
        final result = Validators.validateSenha('MinhaSenhaForte@2026!');
        expect(result, isNull);
      });
    });
  });
}
