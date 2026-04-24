import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateNome', () {
    // ✅ Sucesso
    test('deve retornar null para nome válido simples', () {
      expect(Validators.validateNome('Joao'), isNull);
    });

    test('deve retornar null para nome com espaço', () {
      expect(Validators.validateNome('Joao Silva'), isNull);
    });

    test('deve retornar null para nome com acentos', () {
      expect(Validators.validateNome('José Álvarez'), isNull);
    });

    test('deve retornar null para nome com caracteres acentuados extremos', () {
      expect(Validators.validateNome('ÀÉÍÓÚ'), isNull);
    });

    test('deve retornar null para string com apenas espaços', () {
      expect(Validators.validateNome('   '), isNull);
    });

    // ❌ Falhas
    test('deve retornar erro quando valor é null', () {
      expect(
        Validators.validateNome(null),
        'O nome é obrigatório',
      );
    });

    test('deve retornar erro quando valor é vazio', () {
      expect(
        Validators.validateNome(''),
        'O nome é obrigatório',
      );
    });

    test('deve retornar erro quando contém números', () {
      expect(
        Validators.validateNome('Joao123'),
        'O nome não pode conter números ou caracteres especiais',
      );
    });

    test('deve retornar erro quando contém caracteres especiais', () {
      expect(
        Validators.validateNome('Joao@'),
        'O nome não pode conter números ou caracteres especiais',
      );
    });

    test('deve retornar erro quando contém mistura de válido e inválido', () {
      expect(
        Validators.validateNome('João#'),
        'O nome não pode conter números ou caracteres especiais',
      );
    });
  });
}