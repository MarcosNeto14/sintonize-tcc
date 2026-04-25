# UNIT-COT-06

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-COT-06 |
| **Função testada** | validateEmailLogin |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de login.dart — validator inline do TextFormField de email) |
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
  static String? validateEmailLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu e-mail';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Por favor, insira um e-mail válido';
    }
    return null;
  } 
\```

A função faz parte da classe Validators em lib/utils/validators.dart de um projeto Flutter chamado "sintonize".
Use `import 'package:sintonize/utils/validators.dart';` nos testes.

---

## Resposta do LLM
1. Análise da função

A função validateEmailLogin valida uma string de e-mail para login. Ela retorna uma mensagem de erro se o valor for nulo, vazio ou não corresponder a um padrão básico de e-mail; caso contrário, retorna null, indicando que o e-mail é válido.

2. Cenários de teste

✅ Cenários de sucesso (entradas válidas)

E-mail válido simples (test@example.com)
E-mail com subdomínio (user@mail.example.com)
E-mail com caracteres comuns (user.name+tag@example.co.uk)

❌ Cenários de falha (entradas inválidas)

Valor null
String vazia ('')
E-mail sem @ (testexample.com)
E-mail sem domínio (test@)
E-mail sem parte local (@example.com)
E-mail sem ponto no domínio (test@example)

⚠️ Casos de borda

String com espaços (' ')
E-mail com espaços antes/depois (' test@example.com ')
E-mail com múltiplos @ (test@@example.com)
E-mail com caracteres inválidos extremos
3. Testes unitários em Dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailLogin', () {
    
    // ✅ Sucesso
    test('Retorna null para e-mail válido simples', () {
      final result = Validators.validateEmailLogin('test@example.com');
      expect(result, isNull);
    });

    test('Retorna null para e-mail com subdomínio', () {
      final result = Validators.validateEmailLogin('user@mail.example.com');
      expect(result, isNull);
    });

    test('Retorna null para e-mail com caracteres especiais válidos', () {
      final result = Validators.validateEmailLogin('user.name+tag@example.co.uk');
      expect(result, isNull);
    });

    // ❌ Falhas
    test('Retorna erro quando valor é null', () {
      final result = Validators.validateEmailLogin(null);
      expect(result, 'Por favor, insira seu e-mail');
    });

    test('Retorna erro quando valor é vazio', () {
      final result = Validators.validateEmailLogin('');
      expect(result, 'Por favor, insira seu e-mail');
    });

    test('Retorna erro quando não tem @', () {
      final result = Validators.validateEmailLogin('testexample.com');
      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('Retorna erro quando não tem domínio', () {
      final result = Validators.validateEmailLogin('test@');
      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('Retorna erro quando não tem parte local', () {
      final result = Validators.validateEmailLogin('@example.com');
      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('Retorna erro quando não tem ponto no domínio', () {
      final result = Validators.validateEmailLogin('test@example');
      expect(result, 'Por favor, insira um e-mail válido');
    });

    // ⚠️ Bordas
    test('Retorna erro para string com espaços', () {
      final result = Validators.validateEmailLogin('   ');
      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('Valida e-mail com espaços antes/depois (sem trim)', () {
      final result = Validators.validateEmailLogin(' test@example.com ');
      // Regex ainda considera válido porque não há trim
      expect(result, isNull);
    });

    test('Retorna erro para múltiplos @', () {
      final result = Validators.validateEmailLogin('test@@example.com');
      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('Retorna erro para caracteres inválidos extremos', () {
      final result = Validators.validateEmailLogin('@@@');
      expect(result, 'Por favor, insira um e-mail válido');
    });
  });
}

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 13 |
| **Testes passaram** | 13 |
| **Testes falharam** | 0 |

### Saída do terminal
00:02 +13: All tests passed!

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
