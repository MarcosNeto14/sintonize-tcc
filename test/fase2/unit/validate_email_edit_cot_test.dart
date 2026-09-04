import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailEdit', () {
    group('Cenários de sucesso', () {
      test('deve retornar null quando o valor for null', () {
        expect(
          Validators.validateEmailEdit(null),
          isNull,
        );
      });

      test('deve retornar null quando o valor for vazio', () {
        expect(
          Validators.validateEmailEdit(''),
          isNull,
        );
      });

      test('deve aceitar um e-mail simples válido', () {
        expect(
          Validators.validateEmailEdit('usuario@example.com'),
          isNull,
        );
      });

      test('deve aceitar e-mail contendo números', () {
        expect(
          Validators.validateEmailEdit('usuario123@example.com'),
          isNull,
        );
      });

      test('deve aceitar caracteres permitidos no usuário', () {
        expect(
          Validators.validateEmailEdit('usuario.nome_123+teste@example.com'),
          isNull,
        );
      });

      test('deve aceitar percentual no usuário', () {
        expect(
          Validators.validateEmailEdit('usuario%teste@example.com'),
          isNull,
        );
      });

      test('deve aceitar hífen no usuário', () {
        expect(
          Validators.validateEmailEdit('usuario-teste@example.com'),
          isNull,
        );
      });

      test('deve aceitar domínio contendo hífen', () {
        expect(
          Validators.validateEmailEdit('usuario@meu-dominio.com'),
          isNull,
        );
      });

      test('deve aceitar domínio com subdomínio', () {
        expect(
          Validators.validateEmailEdit('usuario@mail.example.com'),
          isNull,
        );
      });

      test('deve aceitar TLD com exatamente 2 caracteres', () {
        expect(
          Validators.validateEmailEdit('usuario@example.br'),
          isNull,
        );
      });

      test('deve aceitar TLD com mais de 2 caracteres', () {
        expect(
          Validators.validateEmailEdit('usuario@example.com.br'),
          isNull,
        );
      });

      test('deve aceitar letras maiúsculas e minúsculas', () {
        expect(
          Validators.validateEmailEdit('Usuario@Example.COM'),
          isNull,
        );
      });
    });

    group('Cenários de falha', () {
      test('deve rejeitar e-mail sem @', () {
        expect(
          Validators.validateEmailEdit('usuarioexample.com'),
          'Formato de e-mail inválido',
        );
      });

      test('deve rejeitar e-mail sem domínio', () {
        expect(
          Validators.validateEmailEdit('usuario@'),
          'Formato de e-mail inválido',
        );
      });

      test('deve rejeitar e-mail sem TLD', () {
        expect(
          Validators.validateEmailEdit('usuario@example'),
          'Formato de e-mail inválido',
        );
      });

      test('deve rejeitar TLD com apenas um caractere', () {
        expect(
          Validators.validateEmailEdit('usuario@example.c'),
          'Formato de e-mail inválido',
        );
      });

      test('deve rejeitar usuário vazio antes do @', () {
        expect(
          Validators.validateEmailEdit('@example.com'),
          'Formato de e-mail inválido',
        );
      });

      test('deve rejeitar domínio vazio', () {
        expect(
          Validators.validateEmailEdit('usuario@.com'),
          'Formato de e-mail inválido',
        );
      });

      test('deve rejeitar e-mail contendo espaços', () {
        expect(
          Validators.validateEmailEdit('usuario teste@example.com'),
          'Formato de e-mail inválido',
        );
      });

      test('deve rejeitar espaço no domínio', () {
        expect(
          Validators.validateEmailEdit('usuario@exam ple.com'),
          'Formato de e-mail inválido',
        );
      });

      test('deve rejeitar e-mail com caracteres não permitidos', () {
        expect(
          Validators.validateEmailEdit('usuário@example.com'),
          'Formato de e-mail inválido',
        );
      });

      test('deve rejeitar e-mail com dois @', () {
        expect(
          Validators.validateEmailEdit('usuario@@example.com'),
          'Formato de e-mail inválido',
        );
      });

      test('deve rejeitar e-mail iniciado com @', () {
        expect(
          Validators.validateEmailEdit('@usuario.com'),
          'Formato de e-mail inválido',
        );
      });

      test('deve rejeitar e-mail terminado com @', () {
        expect(
          Validators.validateEmailEdit('usuario@'),
          'Formato de e-mail inválido',
        );
      });

      test('deve rejeitar e-mail terminado com ponto', () {
        expect(
          Validators.validateEmailEdit('usuario@example.'),
          'Formato de e-mail inválido',
        );
      });

      test('deve rejeitar e-mail contendo espaço entre os componentes', () {
        expect(
          Validators.validateEmailEdit('usuario @example.com'),
          'Formato de e-mail inválido',
        );
      });
    });

    group('Casos de borda', () {
      test('deve aceitar usuário contendo ponto', () {
        expect(
          Validators.validateEmailEdit('nome.sobrenome@example.com'),
          isNull,
        );
      });

      test('deve aceitar usuário contendo underscore', () {
        expect(
          Validators.validateEmailEdit('nome_sobrenome@example.com'),
          isNull,
        );
      });

      test('deve aceitar usuário contendo múltiplos caracteres permitidos', () {
        expect(
          Validators.validateEmailEdit('a.b_c%+d-e@example.com'),
          isNull,
        );
      });

      test('deve aceitar TLD com exatamente dois caracteres', () {
        expect(
          Validators.validateEmailEdit('a@b.co'),
          isNull,
        );
      });

      test('deve rejeitar TLD com um caractere', () {
        expect(
          Validators.validateEmailEdit('a@b.c'),
          'Formato de e-mail inválido',
        );
      });

      test('deve aceitar TLD com muitos caracteres', () {
        expect(
          Validators.validateEmailEdit('usuario@example.technology'),
          isNull,
        );
      });

      test('deve rejeitar uma string contendo apenas espaços', () {
        expect(
          Validators.validateEmailEdit(' '),
          'Formato de e-mail inválido',
        );
      });

      test('deve rejeitar string contendo apenas @', () {
        expect(
          Validators.validateEmailEdit('@'),
          'Formato de e-mail inválido',
        );
      });
    });

    group('Comportamentos específicos da implementação atual', () {
      test('deve aceitar ponto no usuário conforme permitido pela regex', () {
        expect(
          Validators.validateEmailEdit('usuario..teste@example.com'),
          isNull,
        );
      });

      test(
          'deve aceitar hífen no início do domínio conforme permitido pela regex',
          () {
        expect(
          Validators.validateEmailEdit('usuario@-example.com'),
          isNull,
        );
      });

      test(
          'deve aceitar ponto no início do domínio conforme permitido pela regex',
          () {
        expect(
          Validators.validateEmailEdit('usuario@.example.com'),
          isNull,
        );
      });
    });
  });
}
