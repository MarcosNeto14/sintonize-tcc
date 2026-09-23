import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateDate', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateDate(null), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateDate(''), isNotNull);
    });

    test('deve rejeitar quando formato não contém três partes separadas por barra', () {
      expect(Validators.validateDate('10-05-1995'), isNotNull);
      expect(Validators.validateDate('10/05'), isNotNull);
    });

    test('deve rejeitar quando contém caracteres não numéricos', () {
      expect(Validators.validateDate('aa/05/1995'), isNotNull);
      expect(Validators.validateDate('10/bb/1995'), isNotNull);
      expect(Validators.validateDate('10/05/aaaa'), isNotNull);
    });

    test('deve rejeitar mês menor que 01 ou maior que 12', () {
      expect(Validators.validateDate('10/00/1995'), isNotNull);
      expect(Validators.validateDate('10/13/1995'), isNotNull);
    });

    test('deve rejeitar dia menor que 01 ou maior que o limite do mês', () {
      expect(Validators.validateDate('00/05/1995'), isNotNull);
      expect(Validators.validateDate('32/01/1995'), isNotNull);
      expect(Validators.validateDate('31/04/1995'), isNotNull); // Abril tem 30 dias
    });

    test('deve respeitar anos bissextos para o mês de fevereiro', () {
      expect(Validators.validateDate('29/02/2024'), isNull); // 2024 é bissexto
      expect(Validators.validateDate('29/02/2023'), isNotNull); // 2023 não é bissexto
    });

    test('deve rejeitar datas no futuro', () {
      final anoFuturo = DateTime.now().year + 5;
      expect(Validators.validateDate('01/01/$anoFuturo'), isNotNull);
    });

    test('deve retornar null quando a data for válida e no passado', () {
      expect(Validators.validateDate('15/08/1998'), isNull);
    });
  });
}

