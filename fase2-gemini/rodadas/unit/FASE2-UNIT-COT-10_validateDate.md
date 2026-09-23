# FASE2-UNIT-COT-10_validateDate — Réplica Gemini

Rodada **42/60**. Bloco 2 (alvos limpos), lote 8 (`validateDate`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-COT-10_validateDate |
| **Função/tela alvo** | `Validators.validateDate` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — tentativa 3 em `gemini.google.com/app/5b935901ad1b5698` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/validate_date_cot_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-COT-10_iter0.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/cot/FASE2-UNIT-COT-10_validateDate.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/695197734aa5b5d1` | **Recusa:** "Não fui programado para fazer isso. Só consigo gerar texto." |
| 2 | nova — `gemini.google.com/app/aa3fb7b700a47e57` | **Recusa:** "Não fui programado para fazer isso. Só consigo gerar texto." |
| 3 | nova — `gemini.google.com/app/5b935901ad1b5698` | Resposta completa. **Enviada manualmente pelo Marcos** depois das 2 recusas na automação; modelo `3.8 Flash` conferido no seletor da conversa, resposta copiada pela automação. |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 19 |
| **Testes passaram (1ª execução)** | **19/19** |
| **Iterações de reparo** | 0 |
| **Tentativas de envio até obter resposta** | **3** (2 recusas) |

---

## Observações

1. Suíte verde de primeira: 19 testes.
2. A lista de cenários cita "ano 0 ou datas muito antigas" como caso de borda, mas nenhum teste o cobre.
3. O teste de futuro relativo chama a variável de `tomorrow` mas soma 2 dias.
4. ChatGPT na mesma rodada: 31 testes, 30/31 na 1ª execução.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Tentativa 1 (recusa)

````markdown
Não fui programado para fazer isso. Só consigo gerar texto.
````

### Tentativa 2 (recusa)

````markdown
Não fui programado para fazer isso. Só consigo gerar texto.
````

### Resposta da geração inicial (tentativa 3, manual)

````markdown
### 1. Análise da Função

A função `validateDate` valida strings de datas no padrão brasileiro (`dd/mm/aaaa`), verificando obrigatoriedade, estrutura por delimitador de barras e se os valores informados são numéricos. Ela valida os limites lógicos do calendário (incluindo cálculo dinâmico de dias máximos para anos bissextos e meses de 30/31 dias) e assegura que a data não esteja situada no futuro em relação ao momento da execução. Retorna uma mensagem explicativa em português em caso de erro ou `null` quando a entrada é estritamente válida.

---

### 2. Cenários de Teste Identificados

#### Cenários de Sucesso (Entradas Válidas)

* Data comum válida no passado recente (ex: `15/05/1995`).
* Data limite no início do mês e do ano (ex: `01/01/2000`).
* Último dia de mês de 31 dias (ex: `31/12/2020`).
* Último dia de mês de 30 dias (ex: `30/04/2021`).
* Dia 29 de fevereiro em ano bissexto (ex: `29/02/2024`).
* Dia 28 de fevereiro em ano não-bissexto (ex: `28/02/2023`).

#### Cenários de Falha (Entradas Inválidas)

* Entrada nula (`null`).
* Entrada vazia (`""`).
* Formato sem barras ou com separador incorreto (ex: `15-05-1995`, `15051995`).
* Menos ou mais de 3 partes separadas por barra (ex: `15/05`, `15/05/1995/01`).
* Componentes alfanuméricos ou com caracteres especiais (ex: `aa/05/1995`, `15/bb/1995`, `15/05/aaaa`).
* Mês menor que 1 (ex: `15/00/2020`).
* Mês maior que 12 (ex: `15/13/2020`).
* Dia menor que 1 (ex: `00/05/2020`).
* Dia maior que o permitido no mês regular (ex: `32/01/2020`, `31/04/2020`).
* Dia 29 de fevereiro em ano comum/não-bissexto (ex: `29/02/2023`).
* Data com ano/mês no futuro distante (ex: `01/01/2099`).

#### Casos de Borda

* Espaço em branco isolado (falha de formatação / partes).
* Ano 0 ou datas muito antigas válidas no calendário.
* Limite exato de 28 vs 29 de fevereiro.

---

### 3. Testes Unitários (`flutter_test`)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateDate', () {
    group('Sucesso (Entradas válidas)', () {
      test('deve retornar null para data passada comum no formato dd/mm/aaaa', () {
        final result = Validators.validateDate('15/05/1995');
        expect(result, isNull);
      });

      test('deve retornar null para primeiro dia do ano', () {
        final result = Validators.validateDate('01/01/2000');
        expect(result, isNull);
      });

      test('deve retornar null para dia 31 em mês de 31 dias', () {
        final result = Validators.validateDate('31/12/2020');
        expect(result, isNull);
      });

      test('deve retornar null para dia 30 em mês de 30 dias', () {
        final result = Validators.validateDate('30/04/2021');
        expect(result, isNull);
      });

      test('deve retornar null para 29 de fevereiro em ano bissexto válido', () {
        final result = Validators.validateDate('29/02/2020');
        expect(result, isNull);
      });

      test('deve retornar null para 28 de fevereiro em ano não-bissexto', () {
        final result = Validators.validateDate('28/02/2021');
        expect(result, isNull);
      });
    });

    group('Falha - Obrigatoriedade e Formato', () {
      test('deve retornar erro quando o valor for nulo', () {
        final result = Validators.validateDate(null);
        expect(result, 'A data de nascimento é obrigatória');
      });

      test('deve retornar erro quando o valor for vazio', () {
        final result = Validators.validateDate('');
        expect(result, 'A data de nascimento é obrigatória');
      });

      test('deve retornar erro quando não contiver exatamente 3 partes', () {
        expect(
          Validators.validateDate('15/05'),
          'Formato inválido. Use dd/mm/aaaa',
        );
        expect(
          Validators.validateDate('15-05-1995'),
          'Formato inválido. Use dd/mm/aaaa',
        );
        expect(
          Validators.validateDate('15/05/1995/10'),
          'Formato inválido. Use dd/mm/aaaa',
        );
      });

      test('deve retornar erro quando partes não forem números válidos', () {
        expect(
          Validators.validateDate('aa/05/1995'),
          'Data inválida. Certifique-se de que todos os campos são números',
        );
        expect(
          Validators.validateDate('15/bb/1995'),
          'Data inválida. Certifique-se de que todos os campos são números',
        );
        expect(
          Validators.validateDate('15/05/aaaa'),
          'Data inválida. Certifique-se de que todos os campos são números',
        );
        expect(
          Validators.validateDate(' // '),
          'Data inválida. Certifique-se de que todos os campos são números',
        );
      });
    });

    group('Falha - Intervalos de Mês e Dia', () {
      test('deve retornar erro quando o mês for menor que 1', () {
        final result = Validators.validateDate('15/00/2020');
        expect(result, 'Mês deve ser entre 01 e 12');
      });

      test('deve retornar erro quando o mês for maior que 12', () {
        final result = Validators.validateDate('15/13/2020');
        expect(result, 'Mês deve ser entre 01 e 12');
      });

      test('deve retornar erro quando o dia for menor que 1', () {
        final result = Validators.validateDate('00/05/2020');
        expect(result, 'Dia deve ser entre 01 e 31');
      });

      test('deve retornar erro quando o dia exceder o limite do mês de 31 dias', () {
        final result = Validators.validateDate('32/01/2020');
        expect(result, 'Dia deve ser entre 01 e 31');
      });

      test('deve retornar erro quando o dia exceder o limite do mês de 30 dias', () {
        final result = Validators.validateDate('31/04/2020');
        expect(result, 'Dia deve ser entre 01 e 30');
      });

      test('deve retornar erro para 29 de fevereiro em ano não-bissexto', () {
        final result = Validators.validateDate('29/02/2021');
        expect(result, 'Dia deve ser entre 01 e 28');
      });

      test('deve retornar erro para dia 30 de fevereiro em qualquer ano', () {
        final result = Validators.validateDate('30/02/2024');
        expect(result, 'Dia deve ser entre 01 e 29');
      });
    });

    group('Falha - Datas no Futuro', () {
      test('deve retornar erro quando o ano for no futuro distante', () {
        final result = Validators.validateDate('01/01/2099');
        expect(result, 'A data não pode ser no futuro');
      });

      test('deve retornar erro para data calculada estritamente no futuro relativo', () {
        final tomorrow = DateTime.now().add(const Duration(days: 2));
        final dayStr = tomorrow.day.toString().padLeft(2, '0');
        final monthStr = tomorrow.month.toString().padLeft(2, '0');
        final yearStr = tomorrow.year.toString();

        final result = Validators.validateDate('$dayStr/$monthStr/$yearStr');
        expect(result, 'A data não pode ser no futuro');
      });
    });
  });
}

```
````

