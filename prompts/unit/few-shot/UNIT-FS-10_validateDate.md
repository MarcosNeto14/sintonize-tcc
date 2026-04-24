# UNIT-FS-10

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-FS-10 |
| **Função testada** | validateDate |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de cadastro.dart — _validateDate) |
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
static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'A data de nascimento é obrigatória';
    }
    final parts = value.split('/');
    if (parts.length != 3) {
      return 'Formato inválido. Use dd/mm/aaaa';
    }
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return 'Data inválida. Certifique-se de que todos os campos são números';
    }
    if (month < 1 || month > 12) {
      return 'Mês deve ser entre 01 e 12';
    }
    final maxDay = DateTime(year, month + 1, 0).day;
    if (day < 1 || day > maxDay) {
      return 'Dia deve ser entre 01 e $maxDay';
    }
    final date = DateTime(year, month, day);
    if (date.isAfter(DateTime.now())) {
      return 'A data não pode ser no futuro';
    }
    return null;
  } 
\```

A função faz parte da classe Validators em lib/utils/validators.dart de um projeto Flutter chamado "sintonize".

---

## Resposta do LLM
Aqui está um conjunto de testes unitários seguindo o mesmo padrão dos exemplos, cobrindo os principais cenários da função validateDate:

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateDate', () {
    test('deve retornar erro quando valor é null', () {
      expect(Validators.validateDate(null), isNotNull);
    });

    test('deve retornar erro quando valor é vazio', () {
      expect(Validators.validateDate(''), isNotNull);
    });

    test('deve retornar erro quando formato é inválido', () {
      expect(Validators.validateDate('2020-01-01'), isNotNull);
    });

    test('deve retornar erro quando contém valores não numéricos', () {
      expect(Validators.validateDate('aa/bb/cccc'), isNotNull);
    });

    test('deve retornar erro quando mês é menor que 1', () {
      expect(Validators.validateDate('10/00/2020'), isNotNull);
    });

    test('deve retornar erro quando mês é maior que 12', () {
      expect(Validators.validateDate('10/13/2020'), isNotNull);
    });

    test('deve retornar erro quando dia é inválido para o mês', () {
      expect(Validators.validateDate('31/02/2023'), isNotNull);
    });

    test('deve retornar erro quando dia é menor que 1', () {
      expect(Validators.validateDate('00/12/2020'), isNotNull);
    });

    test('deve retornar erro quando data está no futuro', () {
      final futureDate = DateTime.now().add(const Duration(days: 1));
      final formatted =
          '${futureDate.day.toString().padLeft(2, '0')}/'
          '${futureDate.month.toString().padLeft(2, '0')}/'
          '${futureDate.year}';

      expect(Validators.validateDate(formatted), isNotNull);
    });

    test('deve aceitar data válida', () {
      expect(Validators.validateDate('15/08/1995'), isNull);
    });

    test('deve aceitar último dia válido do mês', () {
      expect(Validators.validateDate('30/04/2023'), isNull);
    });

    test('deve aceitar 29 de fevereiro em ano bissexto', () {
      expect(Validators.validateDate('29/02/2024'), isNull);
    });

    test('deve rejeitar 29 de fevereiro em ano não bissexto', () {
      expect(Validators.validateDate('29/02/2023'), isNotNull);
    });
  });
}

Se quiser, posso também refatorar esses testes para ficarem ainda mais descritivos (validando mensagens específicas em vez de apenas isNotNull) ou adicionar testes parametrizados para reduzir repetição.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 13 |
| **Testes passaram** | 13 |
| **Testes falharam** | 0 |

### Saída do terminal
00:04 +13: All tests passed!  

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
