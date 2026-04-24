# UNIT-COT-03

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-COT-03 |
| **Função testada** | validateNumero |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de cadastro.dart — _validateNumero) |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.6 |
| **Data de acesso** | _preencher_ |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 |

---

## Prompt Enviado
Quero que você gere testes unitários em Dart para a função abaixo. Antes de escrever os testes, siga estes passos:

1. **Analise a função:** Descreva em 2-3 frases o que ela faz.
2. **Identifique os cenários:** Liste todos os cenários de teste relevantes, incluindo:
   - Cenários de sucesso (entradas válidas)
   - Cenários de falha (entradas inválidas)
   - Casos de borda (limites, valores extremos, entradas inesperadas)
3. **Escreva os testes:** Para cada cenário identificado, escreva um teste usando flutter_test com group() e test().

Função a testar:

\```dart
  static String? validateNumero(String? value) {
    if (value == null || value.isEmpty) {
      return 'O número é obrigatório';
    }
    if (int.tryParse(value) == null) {
      return 'O número deve ser numérico';
    }
    return null;
  } 
\```

A função faz parte da classe Validators em lib/utils/validators.dart de um projeto Flutter chamado "sintonize".
Use `import 'package:sintonize/utils/validators.dart';` nos testes.

---

## Resposta do LLM
1. Análise da função

A função validateNumero valida uma string que representa um número. Ela verifica se o valor é nulo ou vazio e, em seguida, se pode ser convertido para um inteiro. Caso alguma validação falhe, retorna uma mensagem de erro; caso contrário, retorna null.

2. Cenários de teste
✅ Cenários de sucesso (entradas válidas)
String contendo número inteiro válido ("123")
Número negativo ("-10")
Número zero ("0")
❌ Cenários de falha (entradas inválidas)
Valor null
String vazia ("")
String com letras ("abc")
String alfanumérica ("123abc")
⚠️ Casos de borda
String com espaços (" 123 " → int.tryParse falha)
Número muito grande (ainda válido como int)
String com símbolo decimal ("12.3" → inválido para int)
3. Testes unitários em Dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateNumero', () {
    
    // ✅ Cenários de sucesso
    test('deve retornar null para número inteiro válido', () {
      expect(Validators.validateNumero('123'), null);
    });

    test('deve retornar null para número negativo', () {
      expect(Validators.validateNumero('-10'), null);
    });

    test('deve retornar null para zero', () {
      expect(Validators.validateNumero('0'), null);
    });

    test('deve aceitar número muito grande', () {
      expect(Validators.validateNumero('999999999'), null);
    });

    // ❌ Cenários de falha
    test('deve retornar erro quando valor é null', () {
      expect(Validators.validateNumero(null), 'O número é obrigatório');
    });

    test('deve retornar erro quando valor é vazio', () {
      expect(Validators.validateNumero(''), 'O número é obrigatório');
    });

    test('deve retornar erro quando contém letras', () {
      expect(Validators.validateNumero('abc'), 'O número deve ser numérico');
    });

    test('deve retornar erro para string alfanumérica', () {
      expect(Validators.validateNumero('123abc'), 'O número deve ser numérico');
    });

    // ⚠️ Casos de borda
    test('deve retornar erro para número com espaços', () {
      expect(Validators.validateNumero(' 123 '), 'O número deve ser numérico');
    });

    test('deve retornar erro para número decimal', () {
      expect(Validators.validateNumero('12.3'), 'O número deve ser numérico');
    });
  });
}

Se quiser, posso também sugerir melhorias na função (por exemplo, tratar trim() para aceitar " 123 " como válido).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 10 |
| **Testes passaram** | 10 |
| **Testes falharam** | 01 |

### Saída do terminal
00:02 +8 -1: Validators.validateNumero deve retornar erro para número com espaços [E]                                                                                                                         
  Expected: 'O número deve ser numérico'
    Actual: <null>
     Which: not an <Instance of 'String'>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test\unit\validate_numero_cot_test.dart 43:7        main.<fn>.<fn>
  

To run this test again: C:\Users\marcos.neto\flutter\bin\cache\dart-sdk\bin\dart.exe test C:/Users/marcos.neto/Desktop/sintonize-tcc/test/unit/validate_numero_cot_test.dart -p vm --plain-name "Validators.validateNumero deve retornar erro para número com espaços"
00:02 +9 -1: Some tests failed.                           

---

## Iterative Repair Loop

### Iteração 1
- **Necessária?** Sim
- **Motivo da falha:** _preencher_
- **Prompt de correção:**
O teste falhou com o seguinte erro:

\```
00:02 +8 -1: Validators.validateNumero deve retornar erro para número com espaços [E]                                                                                                                         
  Expected: 'O número deve ser numérico'
    Actual: <null>
     Which: not an <Instance of 'String'>
  
  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test\unit\validate_numero_cot_test.dart 43:7        main.<fn>.<fn>
  

To run this test again: C:\Users\marcos.neto\flutter\bin\cache\dart-sdk\bin\dart.exe test C:/Users/marcos.neto/Desktop/sintonize-tcc/test/unit/validate_numero_cot_test.dart -p vm --plain-name "Validators.validateNumero deve retornar erro para número com espaços"
00:02 +9 -1: Some tests failed.         
\```

Corrija o teste para que ele compile e passe corretamente.

- **Resposta do LLM:**
Boa — esse erro mostra que a suposição do teste estava errada, não a função.

Em Dart, int.tryParse(' 123 ') retorna 123 normalmente, pois o método ignora espaços em branco. Ou seja, " 123 " é considerado válido, então a função retorna null.

✅ Correção necessária

O teste abaixo está incorreto:

test('deve retornar erro para número com espaços', () {
  expect(Validators.validateNumero(' 123 '), 'O número deve ser numérico');
});

Ele deve ser ajustado para refletir o comportamento real da função.

✔️ Teste corrigido
test('deve aceitar número com espaços (int.tryParse ignora espaços)', () {
  expect(Validators.validateNumero(' 123 '), null);
});
💡 Alternativa (se quiser outro caso de borda válido)

Se a sua intenção era testar um input com espaços que realmente falha, use algo como:

test('deve retornar erro para número com espaços internos', () {
  expect(Validators.validateNumero('12 3'), 'O número deve ser numérico');
});

Se quiser, posso te ajudar a deixar a função mais rígida (por exemplo, rejeitar " 123 " usando trim() antes da validação).

- **Resultado:** Passou

### Iteração 2
- **Necessária?** _preencher (Sim/Não)_
- _(preencher se necessário)_

### Iteração 3
- **Necessária?** _preencher (Sim/Não)_
- _(preencher se necessário)_
