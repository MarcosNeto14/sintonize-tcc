import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateNome', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateNome(null), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateNome(''), isNotNull);
    });

    test('deve retornar mensagem de erro quando contém números', () {
      expect(Validators.validateNome('Marcos123'), isNotNull);
    });

    test('deve retornar mensagem de erro quando contém caracteres especiais', () {
      expect(Validators.validateNome('Marcos@'), isNotNull);
    });

    test('deve aceitar nome com letras e espaços', () {
      expect(Validators.validateNome('Marcos Neto'), isNull);
    });

    test('deve aceitar nome com acentuação', () {
      expect(Validators.validateNome('José Álvaro'), isNull);
    });
  });
}