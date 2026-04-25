# UNIT-COT-07

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-COT-07 |
| **Função testada** | validateEmailEdit |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de alterar-dados.dart — _validateEmail) |
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
  static String? validateEmailEdit(String? value) {
    if (value != null && value.isNotEmpty) {
      const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
      if (!RegExp(emailRegex).hasMatch(value)) {
        return 'Formato de e-mail inválido';
      }
    }
    return null;
  } 
\```

A função faz parte da classe Validators em lib/utils/validators.dart de um projeto Flutter chamado "sintonize".
Use `import 'package:sintonize/utils/validators.dart';` nos testes.

---

## Resposta do LLM
1. Análise da função

A função validateEmailEdit valida uma string opcional que representa um e-mail. Se o valor não for nulo nem vazio, ela verifica se o formato corresponde a uma expressão regular de e-mail válida. Caso não corresponda, retorna uma mensagem de erro; caso contrário (ou se for vazio/nulo), retorna null.

2. Cenários de teste
✅ Cenários de sucesso (entradas válidas)
E-mail válido simples (test@example.com)
E-mail com subdomínio (user@mail.example.com)
E-mail com caracteres permitidos (user.name+tag@example.co)
❌ Cenários de falha (entradas inválidas)
E-mail sem @ (testexample.com)
E-mail sem domínio (test@)
E-mail com domínio inválido (test@.com)
E-mail com TLD inválido (ex: test@example.c)
⚠️ Casos de borda
Valor null
String vazia ("")
String com espaços (" ")
E-mail com caracteres inválidos (test@exa mple.com)
3. Testes unitários em Dart (usando flutter_test)
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailEdit', () {
    
    // ✅ Sucesso
    test('Deve retornar null para e-mail válido simples', () {
      final result = Validators.validateEmailEdit('test@example.com');
      expect(result, isNull);
    });

    test('Deve retornar null para e-mail com subdomínio', () {
      final result = Validators.validateEmailEdit('user@mail.example.com');
      expect(result, isNull);
    });

    test('Deve retornar null para e-mail com caracteres especiais válidos', () {
      final result = Validators.validateEmailEdit('user.name+tag@example.co');
      expect(result, isNull);
    });

    // ❌ Falha
    test('Deve retornar erro para e-mail sem @', () {
      final result = Validators.validateEmailEdit('testexample.com');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve retornar erro para e-mail sem domínio', () {
      final result = Validators.validateEmailEdit('test@');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve retornar erro para domínio inválido', () {
      final result = Validators.validateEmailEdit('test@.com');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve retornar erro para TLD muito curto', () {
      final result = Validators.validateEmailEdit('test@example.c');
      expect(result, 'Formato de e-mail inválido');
    });

    // ⚠️ Borda
    test('Deve retornar null para valor null', () {
      final result = Validators.validateEmailEdit(null);
      expect(result, isNull);
    });

    test('Deve retornar null para string vazia', () {
      final result = Validators.validateEmailEdit('');
      expect(result, isNull);
    });

    test('Deve retornar erro para string com espaços', () {
      final result = Validators.validateEmailEdit('   ');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve retornar erro para e-mail com espaços internos', () {
      final result = Validators.validateEmailEdit('test@exa mple.com');
      expect(result, 'Formato de e-mail inválido');
    });
  });
}

Se quiser, posso também sugerir melhorias na função (por exemplo, tratar espaços com trim() antes da validação) ou aumentar a cobertura com testes parametrizados.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 11 |
| **Testes passaram** | 11 |
| **Testes falharam** | 0 |

### Saída do terminal
00:02 +11: All tests passed!

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
