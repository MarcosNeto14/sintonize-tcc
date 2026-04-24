import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateSenha', () {
    
    // ❌ Cenários de falha
    test('deve retornar erro quando senha for null', () {
      final result = Validators.validateSenha(null);
      expect(result, 'Por favor, insira sua senha');
    });

    test('deve retornar erro quando senha for vazia', () {
      final result = Validators.validateSenha('');
      expect(result, 'Por favor, insira sua senha');
    });

    test('deve retornar erro quando senha tiver menos de 6 caracteres', () {
      final result = Validators.validateSenha('12345');
      expect(result, 'A senha deve ter pelo menos 6 caracteres');
    });

    test('deve retornar erro para senha com 1 caractere', () {
      final result = Validators.validateSenha('1');
      expect(result, 'A senha deve ter pelo menos 6 caracteres');
    });

    // ⚠️ Casos de borda
    test('deve aceitar senha com exatamente 6 caracteres', () {
      final result = Validators.validateSenha('123456');
      expect(result, null);
    });

    test('deve rejeitar senha com 5 caracteres (limite inferior inválido)', () {
      final result = Validators.validateSenha('12345');
      expect(result, 'A senha deve ter pelo menos 6 caracteres');
    });

    test('deve aceitar senha com 6 espaços (regra atual permite)', () {
      final result = Validators.validateSenha('      ');
      expect(result, null);
    });

    // ✅ Cenários de sucesso
    test('deve aceitar senha com mais de 6 caracteres', () {
      final result = Validators.validateSenha('1234567');
      expect(result, null);
    });

    test('deve aceitar senha longa', () {
      final result = Validators.validateSenha('minhaSenhaSuperSegura123');
      expect(result, null);
    });
  });
}