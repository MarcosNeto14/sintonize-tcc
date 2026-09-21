import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateSenha', () {
    group('Cenários de Falha - Entrada nula ou vazia', () {
      test('deve retornar mensagem de obrigatoriedade quando o valor for nulo', () {
        final resultado = Validators.validateSenha(null);

        expect(resultado, 'Por favor, insira sua senha');
      });

      test('deve retornar mensagem de obrigatoriedade quando o valor for vazio', () {
        final resultado = Validators.validateSenha('');

        expect(resultado, 'Por favor, insira sua senha');
      });
    });

    group('Cenários de Falha - Comprimento insuficiente', () {
      test('deve retornar erro para senhas curtas (ex: 3 caracteres)', () {
        final resultado = Validators.validateSenha('123');

        expect(resultado, 'A senha deve ter pelo menos 6 caracteres');
      });

      test('deve retornar erro para senha com 5 caracteres', () {
        final resultado = Validators.validateSenha('12345');

        expect(resultado, 'A senha deve ter pelo menos 6 caracteres');
      });

      test('deve retornar erro para senha com 6 caracteres devido à regra < 7', () {
        final resultado = Validators.validateSenha('123456');

        expect(resultado, 'A senha deve ter pelo menos 6 caracteres');
      });
    });

    group('Cenários de Sucesso e Casos de Borda Válidos', () {
      test('deve retornar null para o limite mínimo aceito pelo código (7 caracteres)', () {
        final resultado = Validators.validateSenha('1234567');

        expect(resultado, isNull);
      });

      test('deve retornar null para senhas comuns com mais de 7 caracteres', () {
        final resultado = Validators.validateSenha('senhaForte123');

        expect(resultado, isNull);
      });

      test('deve retornar null para senhas longas com símbolos e espaços', () {
        final resultado = Validators.validateSenha('P@ssw0rd! Segura #2026');

        expect(resultado, isNull);
      });
    });
  });
}
