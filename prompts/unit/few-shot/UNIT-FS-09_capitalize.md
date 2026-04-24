# UNIT-FS-09

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-FS-09 |
| **Função testada** | capitalize |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de mapa.dart — _capitalize) |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.6 |
| **Data de acesso** | _preencher_ |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 |

---

## Prompt Enviado
Gere testes unitários em Dart usando o pacote flutter_test para a função abaixo.

Antes, veja dois exemplos de testes bem escritos para funções similares:

**Exemplo 1 — teste de validação de campo obrigatório:**
\```dart
group('validateCampoObrigatorio', () {
  test('deve retornar mensagem de erro quando valor é null', () {
    expect(Validators.validateCampoObrigatorio(null), isNotNull);
  });

  test('deve retornar mensagem de erro quando valor é vazio', () {
    expect(Validators.validateCampoObrigatorio(''), isNotNull);
  });

  test('deve retornar null quando valor é preenchido', () {
    expect(Validators.validateCampoObrigatorio('abc'), isNull);
  });
});
\```

**Exemplo 2 — teste de validação com regex:**
\```dart
group('validateTelefone', () {
  test('deve aceitar telefone com 11 dígitos', () {
    expect(Validators.validateTelefone('81999998888'), isNull);
  });

  test('deve rejeitar telefone com letras', () {
    expect(Validators.validateTelefone('8199abc8888'), isNotNull);
  });

  test('deve rejeitar telefone com poucos dígitos', () {
    expect(Validators.validateTelefone('8199'), isNotNull);
  });
});
\```

Agora, gere testes para esta função, seguindo o mesmo padrão dos exemplos:

\```dart
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  } 
\```

A função faz parte da classe Validators em lib/utils/validators.dart de um projeto Flutter chamado "sintonize".

---

## Resposta do LLM
Aqui estão testes unitários seguindo o mesmo padrão dos exemplos, usando o pacote flutter_test:

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('capitalize', () {
    test('deve retornar string vazia quando texto é vazio', () {
      expect(Validators.capitalize(''), equals(''));
    });

    test('deve capitalizar primeira letra de uma única palavra', () {
      expect(Validators.capitalize('hello'), equals('Hello'));
    });

    test('deve converter resto da palavra para minúsculo', () {
      expect(Validators.capitalize('hELLo'), equals('Hello'));
    });

    test('deve capitalizar múltiplas palavras', () {
      expect(
        Validators.capitalize('hello world'),
        equals('Hello World'),
      );
    });

    test('deve lidar com múltiplos espaços entre palavras', () {
      expect(
        Validators.capitalize('hello   world'),
        equals('Hello   World'),
      );
    });

    test('deve manter espaços no início e fim', () {
      expect(
        Validators.capitalize('  hello world  '),
        equals('  Hello World  '),
      );
    });

    test('deve lidar com palavras já capitalizadas corretamente', () {
      expect(
        Validators.capitalize('Hello World'),
        equals('Hello World'),
      );
    });

    test('deve lidar com mistura de maiúsculas e minúsculas', () {
      expect(
        Validators.capitalize('hELLo WoRLD'),
        equals('Hello World'),
      );
    });
  });
}

Se quiser, posso adaptar os testes para cobrir casos com caracteres especiais (acentos, hífens, etc.), que são comuns em português.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 8 |
| **Testes passaram** | 8 |
| **Testes falharam** | 0 |

### Saída do terminal
00:03 +8: All tests passed!

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
