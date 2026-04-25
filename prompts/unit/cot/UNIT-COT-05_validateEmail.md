# UNIT-COT-05

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-COT-05 |
| **Função testada** | validateEmail |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de cadastro.dart — _validateEmail) |
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
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O e-mail é obrigatório';
    }
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  } 
\```

A função faz parte da classe Validators em lib/utils/validators.dart de um projeto Flutter chamado "sintonize".
Use `import 'package:sintonize/utils/validators.dart';` nos testes.

---

## Resposta do LLM
1. Análise da função

A função validateEmail valida uma string de e-mail. Ela verifica se o valor é nulo ou vazio, retornando uma mensagem de erro obrigatória, e depois usa uma expressão regular para validar o formato do e-mail. Se o formato for válido, retorna null; caso contrário, retorna uma mensagem de erro indicando e-mail inválido.

2. Cenários de teste
✅ Cenários de sucesso (entradas válidas)
E-mail válido simples (test@example.com)
E-mail com subdomínio (user@mail.example.com)
E-mail com caracteres permitidos (user.name+tag@example.co)
❌ Cenários de falha (entradas inválidas)
Valor null
String vazia ""
E-mail sem @ (testexample.com)
E-mail sem domínio (test@)
E-mail com domínio inválido (test@.com)
E-mail com TLD inválido (test@example.c)
⚠️ Casos de borda
E-mail com espaços (" test@example.com " – dependendo da regra, deve falhar)
E-mail com caracteres inválidos (test@exa mple.com)
E-mail muito longo (para verificar comportamento, mesmo que regex aceite)
3. Testes unitários em Dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmail', () {
    
    // ----------------------
    // Cenários de sucesso
    // ----------------------
    test('Retorna null para e-mail válido simples', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
    });

    test('Retorna null para e-mail com subdomínio', () {
      expect(Validators.validateEmail('user@mail.example.com'), isNull);
    });

    test('Retorna null para e-mail com caracteres especiais válidos', () {
      expect(Validators.validateEmail('user.name+tag@example.co'), isNull);
    });

    // ----------------------
    // Cenários de falha
    // ----------------------
    test('Retorna erro quando valor é null', () {
      expect(Validators.validateEmail(null), 'O e-mail é obrigatório');
    });

    test('Retorna erro quando valor é vazio', () {
      expect(Validators.validateEmail(''), 'O e-mail é obrigatório');
    });

    test('Retorna erro para e-mail sem @', () {
      expect(Validators.validateEmail('testexample.com'), 'E-mail inválido');
    });

    test('Retorna erro para e-mail sem domínio', () {
      expect(Validators.validateEmail('test@'), 'E-mail inválido');
    });

    test('Retorna erro para domínio inválido', () {
      expect(Validators.validateEmail('test@.com'), 'E-mail inválido');
    });

    test('Retorna erro para TLD inválido', () {
      expect(Validators.validateEmail('test@example.c'), 'E-mail inválido');
    });

    // ----------------------
    // Casos de borda
    // ----------------------
    test('Retorna erro para e-mail com espaços', () {
      expect(Validators.validateEmail(' test@example.com '), 'E-mail inválido');
    });

    test('Retorna erro para e-mail com espaço no meio', () {
      expect(Validators.validateEmail('test@exa mple.com'), 'E-mail inválido');
    });

    test('Valida e-mail muito longo', () {
      final longEmail = 'a' * 64 + '@example.com';
      expect(Validators.validateEmail(longEmail), isNull);
    });
  });
}

Se quiser, posso adaptar os testes para usar setUp, tearDown ou até gerar mocks e integração com CI.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 12 |
| **Testes passaram** | 12 |
| **Testes falharam** | 0 |

### Saída do terminal
00:01 +12: All tests passed!

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
