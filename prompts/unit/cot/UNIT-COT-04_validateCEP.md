# UNIT-COT-04

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-COT-04 |
| **Função testada** | validateCEP |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de cadastro.dart — _validateCEP) |
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
  static String? validateCEP(String? value) {
    if (value == null || value.isEmpty) {
      return 'O CEP é obrigatório';
    }
    if (value.length != 9 || !RegExp(r'^\d{5}-\d{3}$').hasMatch(value)) {
      return 'CEP inválido. Formato correto: XXXXX-XXX';
    }
    return null;
  } 
\```

A função faz parte da classe Validators em lib/utils/validators.dart de um projeto Flutter chamado "sintonize".
Use `import 'package:sintonize/utils/validators.dart';` nos testes.

---

## Resposta do LLM
1. Análise da função

A função validateCEP verifica se uma string representa um CEP válido no formato brasileiro XXXXX-XXX. Ela retorna uma mensagem de erro quando o valor é nulo, vazio ou não corresponde ao padrão esperado, e retorna null quando o CEP é válido.

2. Cenários de teste

✅ Cenários de sucesso (entradas válidas):

CEP válido no formato correto: "12345-678"

❌ Cenários de falha (entradas inválidas):

Valor null
String vazia ""
CEP sem hífen: "12345678"
CEP com formato incorreto: "1234-567"
CEP com letras: "1234A-678"
CEP com caracteres extras: "12345-6789"

⚠️ Casos de borda:

CEP com tamanho correto (9) mas formato inválido: "123456-78"
CEP com espaços: " 12345-678" ou "12345-678 "
CEP com caracteres especiais: "12345_678"
3. Testes unitários em Dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateCEP', () {
    // ✅ Sucesso
    test('Deve retornar null para CEP válido', () {
      final result = Validators.validateCEP('12345-678');
      expect(result, null);
    });

    // ❌ Falhas - obrigatoriedade
    test('Deve retornar erro quando valor é null', () {
      final result = Validators.validateCEP(null);
      expect(result, 'O CEP é obrigatório');
    });

    test('Deve retornar erro quando valor é vazio', () {
      final result = Validators.validateCEP('');
      expect(result, 'O CEP é obrigatório');
    });

    // ❌ Falhas - formato inválido
    test('Deve retornar erro quando CEP não tem hífen', () {
      final result = Validators.validateCEP('12345678');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    test('Deve retornar erro quando formato está incorreto', () {
      final result = Validators.validateCEP('1234-567');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    test('Deve retornar erro quando contém letras', () {
      final result = Validators.validateCEP('1234A-678');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    test('Deve retornar erro quando possui caracteres extras', () {
      final result = Validators.validateCEP('12345-6789');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    // ⚠️ Casos de borda
    test('Deve retornar erro quando tamanho é 9 mas formato inválido', () {
      final result = Validators.validateCEP('123456-78');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    test('Deve retornar erro quando possui espaço no início', () {
      final result = Validators.validateCEP(' 12345-678');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    test('Deve retornar erro quando possui espaço no final', () {
      final result = Validators.validateCEP('12345-678 ');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    test('Deve retornar erro quando contém caractere especial', () {
      final result = Validators.validateCEP('12345_678');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });
  });
}

Se quiser, posso te ajudar a adaptar esses testes para usar setUp, tearDown ou até integrar com cobertura de testes (flutter test --coverage).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 11 |
| **Testes passaram** | 11 |
| **Testes falharam** | 0 |

### Saída do terminal
00:01 +11: All tests passed!

---

## Iterative Repair Loop

### Iteração 1
- **Necessária?** _preencher (Sim/Não)_
- **Motivo da falha:** _preencher_
- **Prompt de correção:**
preencher
- **Resposta do LLM:**
preencher
- **Resultado:** _preencher (Passou/Falhou)_

### Iteração 2
- **Necessária?** _preencher (Sim/Não)_
- _(preencher se necessário)_

### Iteração 3
- **Necessária?** _preencher (Sim/Não)_
- _(preencher se necessário)_
