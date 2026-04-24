# UNIT-FS-05

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-FS-05 |
| **Função testada** | validateEmail |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de cadastro.dart — _validateEmail) |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.6 |
| **Data de acesso** | 2026-04-24 |
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

---

## Resposta do LLM
Aqui está um conjunto de testes unitários seguindo o mesmo padrão dos seus exemplos, usando flutter_test e cobrindo os principais cenários da função validateEmail:

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateEmail', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateEmail(null), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateEmail(''), isNotNull);
    });

    test('deve aceitar e-mail válido simples', () {
      expect(Validators.validateEmail('teste@email.com'), isNull);
    });

    test('deve aceitar e-mail com subdomínio', () {
      expect(Validators.validateEmail('user@mail.example.com'), isNull);
    });

    test('deve aceitar e-mail com caracteres especiais válidos', () {
      expect(Validators.validateEmail('user.name+tag@email.co'), isNull);
    });

    test('deve rejeitar e-mail sem @', () {
      expect(Validators.validateEmail('testeemail.com'), isNotNull);
    });

    test('deve rejeitar e-mail sem domínio', () {
      expect(Validators.validateEmail('teste@'), isNotNull);
    });

    test('deve rejeitar e-mail sem sufixo do domínio', () {
      expect(Validators.validateEmail('teste@email'), isNotNull);
    });

    test('deve rejeitar e-mail com caracteres inválidos', () {
      expect(Validators.validateEmail('teste@ema!l.com'), isNotNull);
    });

    test('deve rejeitar e-mail com espaço', () {
      expect(Validators.validateEmail('teste @email.com'), isNotNull);
    });
  });
}

Esse conjunto cobre:

Casos obrigatórios (null e vazio)
Casos válidos comuns e mais completos
Vários formatos inválidos importantes (estrutura, caracteres e formatação)

Se quiser, posso também incluir testes verificando as mensagens exatas retornadas (em vez de apenas isNotNull).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 10 |
| **Testes passaram** | 10 |
| **Testes falharam** | 0 |

### Saída do terminal
00:03 +10: All tests passed!  

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
