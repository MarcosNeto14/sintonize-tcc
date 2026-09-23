import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators - validateEmailEdit', () {
    group('Casos opcionais / borda neutra (devem retornar null)', () {
      test('deve retornar null quando o valor for nulo', () {
        final result = Validators.validateEmailEdit(null);
        expect(result, isNull);
      });

      test('deve retornar null quando a string for vazia', () {
        final result = Validators.validateEmailEdit('');
        expect(result, isNull);
      });
    });

    group('E-mails válidos (devem retornar null)', () {
      test('deve aceitar e-mail em formato padrão simples', () {
        final result = Validators.validateEmailEdit('usuario@exemplo.com');
        expect(result, isNull);
      });

      test('deve aceitar subdomínios', () {
        final result = Validators.validateEmailEdit('usuario@mail.empresa.com.br');
        expect(result, isNull);
      });

      test('deve aceitar caracteres especiais permitidos no local-part (+, _, %, -, .)', () {
        final result = Validators.validateEmailEdit('user.name+tag_123%test-456@dominio.org');
        expect(result, isNull);
      });

      test('deve aceitar TLDs longos com mais de 2 caracteres', () {
        final result = Validators.validateEmailEdit('dev@plataforma.technology');
        expect(result, isNull);
      });

      test('deve aceitar letras maiúsculas e minúsculas', () {
        final result = Validators.validateEmailEdit('User.Name@Domain.COM');
        expect(result, isNull);
      });
    });

    group('E-mails inválidos (devem retornar mensagem de erro)', () {
      const errorMessage = 'Formato de e-mail inválido';

      test('deve rejeitar e-mail sem arroba (@)', () {
        final result = Validators.validateEmailEdit('usuarioexemplo.com');
        expect(result, equals(errorMessage));
      });

      test('deve rejeitar e-mail sem domínio após o @', () {
        final result = Validators.validateEmailEdit('usuario@');
        expect(result, equals(errorMessage));
      });

      test('deve rejeitar e-mail sem parte local antes do @', () {
        final result = Validators.validateEmailEdit('@exemplo.com');
        expect(result, equals(errorMessage));
      });

      test('deve rejeitar e-mail sem TLD / extensão final', () {
        final result = Validators.validateEmailEdit('usuario@dominio');
        expect(result, equals(errorMessage));
      });

      test('deve rejeitar TLD com menos de 2 caracteres', () {
        final result = Validators.validateEmailEdit('usuario@dominio.c');
        expect(result, equals(errorMessage));
      });

      test('deve rejeitar e-mail contendo espaços internos', () {
        final result = Validators.validateEmailEdit('user name@exemplo.com');
        expect(result, equals(errorMessage));
      });

      test('deve rejeitar e-mail com espaços no início ou fim (sem trim prévio)', () {
        final result = Validators.validateEmailEdit(' usuario@exemplo.com ');
        expect(result, equals(errorMessage));
      });

      test('deve rejeitar múltiplos arrobas (@)', () {
        final result = Validators.validateEmailEdit('usuario@@exemplo.com');
        expect(result, equals(errorMessage));
      });

      test('deve rejeitar caracteres especiais proibidos', () {
        final result = Validators.validateEmailEdit('usuario!#\$@dominio.com');
        expect(result, equals(errorMessage));
      });
    });
  });
}

