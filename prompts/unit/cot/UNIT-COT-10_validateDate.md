# UNIT-COT-10

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-COT-10 |
| **Função testada** | validateDate |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de cadastro.dart — _validateDate) |
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
Use `import 'package:sintonize/utils/validators.dart';` nos testes.

---

## Resposta do LLM
1. Análise da função

A função validateDate valida uma string de data no formato dd/mm/aaaa. Ela verifica se a data está presente, se o formato é correto, se os valores são numéricos e se representam uma data válida no calendário. Além disso, garante que a data não seja futura.

2. Cenários de teste
✅ Cenários de sucesso (válidos)
Data válida no formato correto (ex: 15/08/1995)
Data válida no limite do mês (ex: 31/01/2020, 29/02/2020 ano bissexto)
Data igual à data atual
❌ Cenários de falha (inválidos)
Valor null
String vazia
Formato incorreto (ex: 15-08-1995, 15081995, 15/08)
Valores não numéricos (ex: aa/bb/cccc)
Mês inválido (<1 ou >12)
Dia inválido (<1 ou >máximo do mês)
Data futura
⚠️ Casos de borda
Fevereiro em ano não bissexto (29/02/2021)
Dia 0 (00/01/2020)
Mês 0 (10/00/2020)
Último dia válido de cada mês
Data exatamente hoje
3. Testes unitários em Dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateDate', () {
    
    // ---------------------------
    // Sucesso
    // ---------------------------
    test('Deve retornar null para data válida', () {
      expect(Validators.validateDate('15/08/1995'), null);
    });

    test('Deve aceitar data no limite do mês', () {
      expect(Validators.validateDate('31/01/2020'), null);
    });

    test('Deve aceitar 29/02 em ano bissexto', () {
      expect(Validators.validateDate('29/02/2020'), null);
    });

    test('Deve aceitar a data de hoje', () {
      final now = DateTime.now();
      final today =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      expect(Validators.validateDate(today), null);
    });

    // ---------------------------
    // Falhas - obrigatoriedade
    // ---------------------------
    test('Deve retornar erro se valor for null', () {
      expect(
        Validators.validateDate(null),
        'A data de nascimento é obrigatória',
      );
    });

    test('Deve retornar erro se valor for vazio', () {
      expect(
        Validators.validateDate(''),
        'A data de nascimento é obrigatória',
      );
    });

    // ---------------------------
    // Falhas - formato
    // ---------------------------
    test('Deve retornar erro para formato inválido', () {
      expect(
        Validators.validateDate('15-08-1995'),
        'Formato inválido. Use dd/mm/aaaa',
      );
    });

    test('Deve retornar erro para formato incompleto', () {
      expect(
        Validators.validateDate('15/08'),
        'Formato inválido. Use dd/mm/aaaa',
      );
    });

    // ---------------------------
    // Falhas - valores não numéricos
    // ---------------------------
    test('Deve retornar erro para valores não numéricos', () {
      expect(
        Validators.validateDate('aa/bb/cccc'),
        'Data inválida. Certifique-se de que todos os campos são números',
      );
    });

    // ---------------------------
    // Falhas - mês inválido
    // ---------------------------
    test('Deve retornar erro para mês menor que 1', () {
      expect(
        Validators.validateDate('10/00/2020'),
        'Mês deve ser entre 01 e 12',
      );
    });

    test('Deve retornar erro para mês maior que 12', () {
      expect(
        Validators.validateDate('10/13/2020'),
        'Mês deve ser entre 01 e 12',
      );
    });

    // ---------------------------
    // Falhas - dia inválido
    // ---------------------------
    test('Deve retornar erro para dia menor que 1', () {
      expect(
        Validators.validateDate('00/01/2020'),
        'Dia deve ser entre 01 e 31',
      );
    });

    test('Deve retornar erro para dia maior que o permitido no mês', () {
      expect(
        Validators.validateDate('31/04/2020'),
        'Dia deve ser entre 01 e 30',
      );
    });

    test('Deve retornar erro para 29/02 em ano não bissexto', () {
      expect(
        Validators.validateDate('29/02/2021'),
        'Dia deve ser entre 01 e 28',
      );
    });

    // ---------------------------
    // Falhas - data futura
    // ---------------------------
    test('Deve retornar erro para data futura', () {
      final future = DateTime.now().add(Duration(days: 1));
      final futureDate =
          '${future.day.toString().padLeft(2, '0')}/${future.month.toString().padLeft(2, '0')}/${future.year}';

      expect(
        Validators.validateDate(futureDate),
        'A data não pode ser no futuro',
      );
    });
  });
}

Se quiser, posso também adaptar esses testes para usar mockito ou congelar o tempo (para evitar instabilidade em testes com DateTime.now()).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 15 |
| **Testes passaram** | 15 |
| **Testes falharam** | 0 |

### Saída do terminal
00:02 +15: All tests passed!

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
