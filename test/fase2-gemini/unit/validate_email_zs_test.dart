import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmail', () {
    group('Casos de obrigatoriedade (retorna erro de campo obrigatório)', () {
      test('deve retornar mensagem de erro quando o valor for nulo', () {
        final result = Validators.validateEmail(null);
        expect(result, equals('O e-mail é obrigatório'));
      });

      test('deve retornar mensagem de erro quando o valor for uma string vazia', () {
        final result = Validators.validateEmail('');
        expect(result, equals('O e-mail é obrigatório'));
      });
    });

    group('Casos de sucesso (retorna null)', () {
      final validEmails = [
        'usuario@dominio.com',
        'nome.sobrenome@empresa.com.br',
        'usuario+tag@sub.dominio.org',
        'user_name123@provedor.co',
        'conta%teste-1@exemplo.tech',
        'TESTE@DOMINIO.COM',
      ];

      for (final email in validEmails) {
        test('deve retornar null para o e-mail válido: "$email"', () {
          final result = Validators.validateEmail(email);
          expect(result, isNull);
        });
      }
    });

    group('Casos inválidos e de borda (retorna erro de formato inválido)', () {
      final invalidEmails = [
        // Sem partes obrigatórias da estrutura
        'sem_arroba.com',
        'usuario@',
        '@dominio.com',
        'usuario@dominio',
        'usuario@dominio.',

        // TLD inválido (< 2 caracteres ou com números)
        'usuario@dominio.c',
        'usuario@dominio.1a',

        // Espaços em branco
        '   ',
        'usuario @dominio.com',
        'usuario@ dominio.com',
        'usuario@dominio .com',
        ' usuario@dominio.com',
        'usuario@dominio.com ',

        // Caracteres proibidos na regex
        'usuario#teste@dominio.com',
        'usuario@domínio.com', // Caracteres acentuados
        'usuario@dom!nio.com',

        // Múltiplos arrobas
        'usuario@@dominio.com',
        'usuario@outro@dominio.com',
      ];

      for (final email in invalidEmails) {
        test('deve retornar "E-mail inválido" para: "$email"', () {
          final result = Validators.validateEmail(email);
          expect(result, equals('E-mail inválido'));
        });
      }
    });
  });
}

