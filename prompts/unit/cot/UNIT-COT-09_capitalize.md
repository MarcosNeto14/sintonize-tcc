# UNIT-COT-09

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-COT-09 |
| **Função testada** | capitalize |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de mapa.dart — _capitalize) |
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
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
} 
\```

A função faz parte da classe Validators em lib/utils/validators.dart de um projeto Flutter chamado "sintonize".
Use `import 'package:sintonize/utils/validators.dart';` nos testes.

---

## Resposta do LLM
1. Análise da função

A função capitalize recebe uma string e transforma a primeira letra de cada palavra em maiúscula, enquanto o restante da palavra é convertido para minúsculas. Ela divide o texto por espaços, aplica a transformação em cada palavra e depois junta tudo novamente. Caso a string esteja vazia, ela retorna o próprio valor sem alterações.

2. Cenários de teste
✅ Cenários de sucesso (entradas válidas)
Texto com uma única palavra em minúsculas ("hello" → "Hello")
Texto com múltiplas palavras ("hello world" → "Hello World")
Texto já capitalizado corretamente ("Hello World" → "Hello World")
Texto com letras maiúsculas misturadas ("hELLo wORLD" → "Hello World")
❌ Cenários de falha / entradas inválidas
String vazia ("" → "")
⚠️ Casos de borda
Texto com múltiplos espaços entre palavras ("hello world" → "Hello World")
Texto com espaços no início e no fim (" hello world " → " Hello World ")
Texto contendo palavras vazias (ex: múltiplos espaços consecutivos)
Texto com caracteres especiais ("hello-world" → "Hello-world")
Texto com números ("hello 123 world" → "Hello 123 World")
3. Testes unitários em Dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.capitalize', () {
    // ✅ Cenários de sucesso
    test('Deve capitalizar uma única palavra', () {
      expect(Validators.capitalize('hello'), 'Hello');
    });

    test('Deve capitalizar múltiplas palavras', () {
      expect(Validators.capitalize('hello world'), 'Hello World');
    });

    test('Deve manter texto já capitalizado corretamente', () {
      expect(Validators.capitalize('Hello World'), 'Hello World');
    });

    test('Deve corrigir palavras com letras misturadas', () {
      expect(Validators.capitalize('hELLo wORLD'), 'Hello World');
    });

    // ❌ Cenário de falha
    test('Deve retornar string vazia quando input for vazio', () {
      expect(Validators.capitalize(''), '');
    });

    // ⚠️ Casos de borda
    test('Deve preservar múltiplos espaços entre palavras', () {
      expect(
        Validators.capitalize('hello   world'),
        'Hello   World',
      );
    });

    test('Deve preservar espaços no início e no fim', () {
      expect(
        Validators.capitalize('  hello world  '),
        '  Hello World  ',
      );
    });

    test('Deve lidar com palavras vazias (espaços consecutivos)', () {
      expect(
        Validators.capitalize('hello  world'),
        'Hello  World',
      );
    });

    test('Deve lidar com caracteres especiais', () {
      expect(
        Validators.capitalize('hello-world'),
        'Hello-world',
      );
    });

    test('Deve lidar com números no texto', () {
      expect(
        Validators.capitalize('hello 123 world'),
        'Hello 123 World',
      );
    });
  });
}

Se quiser, posso também sugerir melhorias na função (por exemplo, lidar melhor com hífens ou pontuação).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 10 |
| **Testes passaram** | 10 |
| **Testes falharam** | 0 |

### Saída do terminal
00:02 +10: All tests passed!

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
