import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailEdit', () {
    group('sucesso', () {
      test('deve retornar null para um e-mail válido', () {
        expect(
          Validators.validateEmailEdit('usuario@example.com'),
          isNull,
        );
      });

      test('deve aceitar e-mail com números', () {
        expect(
          Validators.validateEmailEdit('usuario123@example.com'),
          isNull,
        );
      });

      test('deve aceitar caracteres permitidos antes do @', () {
        expect(
          Validators.validateEmailEdit('nome.sobrenome+teste@example.com'),
          isNull,
        );
      });

      test('deve aceitar subdomínio', () {
        expect(
          Validators.validateEmailEdit('usuario@mail.example.com'),
          isNull,
        );
      });

      test('deve aceitar domínio com hífen', () {
        expect(
          Validators.validateEmailEdit('usuario@meu-dominio.com'),
          isNull,
        );
      });

      test('deve aceitar domínio com múltiplos níveis', () {
        expect(
          Validators.validateEmailEdit('usuario@mail.exemplo.com.br'),
          isNull,
        );
      });
    });

    group('falha', () {
      test('deve retornar mensagem de erro quando não houver @', () {
        expect(
          Validators.validateEmailEdit('usuarioexample.com'),
          'Formato de e-mail inválido',
        );
      });

      test('deve retornar mensagem de erro quando não houver domínio', () {
        expect(
          Validators.validateEmailEdit('usuario@'),
          'Formato de e-mail inválido',
        );
      });

      test('deve retornar mensagem de erro quando não houver extensão', () {
        expect(
          Validators.validateEmailEdit('usuario@example'),
          'Formato de e-mail inválido',
        );
      });

      test('deve retornar mensagem de erro para e-mail com espaços', () {
        expect(
          Validators.validateEmailEdit('usuario @example.com'),
          'Formato de e-mail inválido',
        );
      });

      test('deve retornar mensagem de erro para e-mail com extensão menor que dois caracteres', () {
        expect(
          Validators.validateEmailEdit('usuario@example.c'),
          'Formato de e-mail inválido',
        );
      });

      test('deve retornar mensagem de erro para e-mail com ponto antes da extensão ausente', () {
        expect(
          Validators.validateEmailEdit('usuario@example.'),
          'Formato de e-mail inválido',
        );
      });

      test('deve retornar mensagem de erro quando houver múltiplos @', () {
        expect(
          Validators.validateEmailEdit('usuario@@example.com'),
          'Formato de e-mail inválido',
        );
      });
    });

    group('casos de borda', () {
      test('deve retornar null para valor null', () {
        expect(
          Validators.validateEmailEdit(null),
          isNull,
        );
      });

      test('deve retornar null para string vazia', () {
        expect(
          Validators.validateEmailEdit(''),
          isNull,
        );
      });

      test('deve rejeitar e-mail contendo apenas espaços', () {
        expect(
          Validators.validateEmailEdit('   '),
          'Formato de e-mail inválido',
        );
      });

      test('deve rejeitar e-mail com espaço no início', () {
        expect(
          Validators.validateEmailEdit(' usuario@example.com'),
          'Formato de e-mail inválido',
        );
      });

      test('deve rejeitar e-mail com espaço no final', () {
        expect(
          Validators.validateEmailEdit('usuario@example.com '),
          'Formato de e-mail inválido',
        );
      });

      test('deve aceitar letras maiúsculas', () {
        expect(
          Validators.validateEmailEdit('USUARIO@EXAMPLE.COM'),
          isNull,
        );
      });

      test('deve rejeitar domínio sem ponto', () {
        expect(
          Validators.validateEmailEdit('usuario@localhost'),
          'Formato de e-mail inválido',
        );
      });
    });
  });
}
