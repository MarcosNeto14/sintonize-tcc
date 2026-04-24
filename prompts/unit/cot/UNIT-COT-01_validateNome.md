# UNIT-COT-01

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-COT-01 |
| **Função testada** | validateNome |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de cadastro.dart — validator inline do campo Nome) |
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
Quero que você gere testes unitários em Dart para a função abaixo. Antes de escrever os testes, siga estes passos: 1. **Analise a função:** Descreva em 2-3 frases o que ela faz. 2. **Identifique os cenários:** Liste todos os cenários de teste relevantes, incluindo: - Cenários de sucesso (entradas válidas) - Cenários de falha (entradas inválidas) - Casos de borda (limites, valores extremos, entradas inesperadas) 3. **Escreva os testes:** Para cada cenário identificado, escreva um teste usando flutter_test com group() e test(). Função a testar: \
dart
  static String? validateNome(String? value) {
    if (value == null || value.isEmpty) {
      return 'O nome é obrigatório';
    }
    final hasInvalidCharacters = RegExp(r'[^a-zA-ZÀ-ÿ\s]').hasMatch(value);
    if (hasInvalidCharacters) {
      return 'O nome não pode conter números ou caracteres especiais';
    }
    return null;
  } 
\
A função faz parte da classe Validators em lib/utils/validators.dart de um projeto Flutter chamado "sintonize". Use import 'package:sintonize/utils/validators.dart'; nos testes.

---

## Resposta do LLM
1. Análise da função

A função validateNome valida um campo de nome retornando uma mensagem de erro caso o valor seja inválido. Ela verifica se o valor é nulo ou vazio e também se contém caracteres inválidos (como números ou símbolos). Se tudo estiver correto, retorna null, indicando que o valor é válido.

2. Cenários de teste
✅ Cenários de sucesso (entradas válidas)
Nome simples com letras: "Joao"
Nome com espaços: "Joao Silva"
Nome com acentuação: "José Álvarez"
❌ Cenários de falha (entradas inválidas)
Valor null
String vazia: ""
Nome com números: "Joao123"
Nome com caracteres especiais: "Joao@", "Maria!"
⚠️ Casos de borda
String com apenas espaços: " " (passa na regex, mas pode ser considerado inválido dependendo da regra — aqui vai passar como válido)
Nome com caracteres acentuados válidos extremos: "ÀÉÍÓÚ"
Nome com mistura de válido + inválido: "João#"
3. Testes unitários (Dart com flutter_test)
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

Se quiser, posso refatorar a função para tratar " " como inválido também — hoje ela passa silenciosamente, o que pode ser um bug dependendo da regra de negócio.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 10 |
| **Testes passaram** | 10 |
| **Testes falharam** | 0 |

### Saída do terminal
00:14 +10: All tests passed!  

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
