import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateNome', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateNome(null), 'O nome é obrigatório');
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateNome(''), 'O nome é obrigatório');
    });

    test('deve rejeitar nome contendo números', () {
      expect(
        Validators.validateNome('Marcos 123'),
        'O nome não pode conter números ou caracteres especiais',
      );
    });

    test('deve rejeitar nome contendo caracteres especiais e símbolos', () {
      expect(
        Validators.validateNome('João @ Silva'),
        'O nome não pode conter números ou caracteres especiais',
      );
    });

    test('deve aceitar nome simples válido', () {
      expect(Validators.validateNome('Marcos'), isNull);
    });

    test('deve aceitar nome composto com espaços', () {
      expect(Validators.validateNome('Ana Clara Silva'), isNull);
    });

    test('deve aceitar nomes com acentuação e cedilha', () {
      expect(Validators.validateNome('Ágatha José Lourenço Müller'), isNull);
    });
  });
}

