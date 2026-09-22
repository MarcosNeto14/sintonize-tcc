import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators - validateNumero', () {
    const errorObrigatorio = 'O número é obrigatório';
    const errorNumerico = 'O número deve ser numérico';

    group('Cenários de Sucesso', () {
      test('deve retornar null para inteiros positivos comuns', () {
        expect(Validators.validateNumero('1'), isNull);
        expect(Validators.validateNumero('42'), isNull);
        expect(Validators.validateNumero('123456789'), isNull);
      });

      test('deve retornar null para o número zero', () {
        expect(Validators.validateNumero('0'), isNull);
      });

      test('deve retornar null para inteiros negativos válidos', () {
        expect(Validators.validateNumero('-1'), isNull);
        expect(Validators.validateNumero('-999'), isNull);
      });

      test('deve retornar null para valores com sinal explícito de positivo', () {
        // int.tryParse('+5') é interpretado como 5
        expect(Validators.validateNumero('+5'), isNull);
      });
    });

    group('Cenários de Falha - Campo obrigatório', () {
      test('deve retornar erro quando o valor for nulo', () {
        final result = Validators.validateNumero(null);
        expect(result, equals(errorObrigatorio));
      });

      test('deve retornar erro quando a string for vazia', () {
        final result = Validators.validateNumero('');
        expect(result, equals(errorObrigatorio));
      });
    });

    group('Cenários de Falha - Formato não numérico', () {
      test('deve retornar erro para letras ou palavras', () {
        expect(Validators.validateNumero('abc'), equals(errorNumerico));
        expect(Validators.validateNumero('dez'), equals(errorNumerico));
      });

      test('deve retornar erro para caracteres especiais e pontuação', () {
        expect(Validators.validateNumero('@#\$%'), equals(errorNumerico));
        expect(Validators.validateNumero('-'), equals(errorNumerico));
        expect(Validators.validateNumero('+'), equals(errorNumerico));
      });

      test('deve retornar erro para combinações alfanuméricas', () {
        expect(Validators.validateNumero('12a'), equals(errorNumerico));
        expect(Validators.validateNumero('b45'), equals(errorNumerico));
      });

      test('deve retornar erro para números com ponto flutuante / decimais', () {
        // int.tryParse rejeita casas decimais
        expect(Validators.validateNumero('10.5'), equals(errorNumerico));
        expect(Validators.validateNumero('10,5'), equals(errorNumerico));
      });
    });

    group('Casos de Borda', () {
      test('deve retornar erro numérico para strings compostas apenas por espaços', () {
        // '   ' não é vazio (length > 0), mas int.tryParse('   ') resulta em null
        expect(Validators.validateNumero('   '), equals(errorNumerico));
      });

      test('deve aceitar espaços nas extremidades e rejeitar espaços internos', () {
        // int.tryParse aceita leading e trailing whitespaces nativamente
        expect(Validators.validateNumero(' 123'), isNull);
        expect(Validators.validateNumero('123 '), isNull);

        // Espaços intercalados invalidam o número
        expect(Validators.validateNumero('12 3'), equals(errorNumerico));
      });

      test('deve validar limites de representação de inteiros de 64 bits', () {
        expect(Validators.validateNumero('9223372036854775807'), isNull);
        expect(Validators.validateNumero('-9223372036854775808'), isNull);

        expect(Validators.validateNumero('9223372036854775808'), equals(errorNumerico));
      });
    });
  });
}

