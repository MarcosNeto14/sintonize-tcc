# UNIT-FS-07

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-FS-07 |
| **Função testada** | validateEmailEdit |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de alterar-dados.dart — _validateEmail) |
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

---

## Resposta do LLM
Aqui está um conjunto de testes unitários seguindo exatamente o padrão dos exemplos que você forneceu, usando o pacote flutter_test:

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateEmailEdit', () {
    test('deve retornar null quando valor é null', () {
      expect(Validators.validateEmailEdit(null), isNull);
    });

    test('deve retornar null quando valor é vazio', () {
      expect(Validators.validateEmailEdit(''), isNull);
    });

    test('deve aceitar e-mail válido simples', () {
      expect(Validators.validateEmailEdit('teste@email.com'), isNull);
    });

    test('deve aceitar e-mail com subdomínio', () {
      expect(Validators.validateEmailEdit('user@mail.example.com'), isNull);
    });

    test('deve aceitar e-mail com caracteres especiais válidos', () {
      expect(Validators.validateEmailEdit('user.name+tag@email.co'), isNull);
    });

    test('deve rejeitar e-mail sem @', () {
      expect(Validators.validateEmailEdit('testeemail.com'), isNotNull);
    });

    test('deve rejeitar e-mail sem domínio', () {
      expect(Validators.validateEmailEdit('teste@'), isNotNull);
    });

    test('deve rejeitar e-mail sem TLD', () {
      expect(Validators.validateEmailEdit('teste@email'), isNotNull);
    });

    test('deve rejeitar e-mail com caracteres inválidos', () {
      expect(Validators.validateEmailEdit('teste@ema!l.com'), isNotNull);
    });

    test('deve retornar mensagem de erro para e-mail inválido', () {
      expect(
        Validators.validateEmailEdit('email_invalido'),
        'Formato de e-mail inválido',
      );
    });
  });
}

Esse conjunto cobre:

Casos neutros (null e vazio)
Casos válidos (simples, subdomínio, caracteres especiais permitidos)
Casos inválidos (estrutura incorreta)
Verificação explícita da mensagem de erro

Se quiser, posso também sugerir testes de borda mais extremos (como emails muito longos ou unicode), mas para a maioria dos cenários de app Flutter isso já está bem completo.

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
