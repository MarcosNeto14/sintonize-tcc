# FASE2-UNIT-ZS-03_validateNumero — Réplica Gemini

Rodada **22/60**. Bloco 2 (alvos limpos), lote 2 (`validateNumero`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-ZS-03_validateNumero |
| **Função/tela alvo** | `Validators.validateNumero` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim — `gemini.google.com/app/39a02b1c69375185` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/validate_numero_zs_test.dart` |
| **Saídas arquivadas** | `resultados/unit/FASE2-UNIT-ZS-03_iter{0,1}.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/unit/zero-shot/FASE2-UNIT-ZS-03_validateNumero.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/39a02b1c69375185` | Resposta completa |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 13 |
| **Testes passaram (1ª execução)** | 12/13 |
| **Iterações de reparo** | 1 |
| **Testes passaram (pós-repair)** | **13/13** |
| **Tentativas de envio até obter resposta** | **1** |

---

## Iterative Repair Loop

### Iteração 1

- **Motivo:** `deve retornar erro quando houver espaços no início, meio ou fim` — `Expected: 'O número deve ser numérico'`, `Actual: <null>` para `' 123'`.
- **★ Autoclassificação:** **(A)**, correta. Explicou que `int.tryParse` aceita espaços nas extremidades e rejeita os internos.
- **Correção entregue:** parcial — um teste novo e o grupo "Casos de Borda" inteiro reescrito, para substituir o anterior. **Aplicado:** o grupo, no lugar do original (o restante do arquivo intocado).
- **Resultado:** **13/13.**
- Saída: `FASE2-UNIT-ZS-03_iter1.txt`

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) |
| **★ Classificação humana (auditoria)** | Erro de teste — premissa falsa sobre a API do Dart |
| **★ Concordância** | Sim |

---

## Observações

1. A falha é uma premissa errada sobre `int.tryParse` (achou que espaços nas pontas seriam rejeitados), não um defeito da função. O reparo convergiu na primeira iteração.
2. Primeira tentativa respondida de primeira desde a reexecução 1/4 — quebra a sequência de 9 recusas.
3. ChatGPT na mesma rodada: 14 testes.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
Aqui está o arquivo de testes unitários completo para a função `validateNumero`, cobrindo cenários válidos, inválidos e casos de borda.

Crie o arquivo no caminho **`test/utils/validators_test.dart`**:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators - validateNumero', () {
    const errorObrigatorio = 'O número é obrigatório';
    const errorNumerico = 'O número deve ser numérico';

    group('Cenários de Sucesso', () {
      test('deve retornar null para inteiros positivos comuns', () {
        expect(Validators.validateNumero('1'), isNull);
        expect(Validators.validateNumero('42'), isNull);
        expect(Validators.validateNumero('123456789'), isNull);
      });

      test('deve retornar null para o número zero', () {
        expect(Validators.validateNumero('0'), isNull);
      });

      test('deve retornar null para inteiros negativos válidos', () {
        expect(Validators.validateNumero('-1'), isNull);
        expect(Validators.validateNumero('-999'), isNull);
      });

      test('deve retornar null para valores com sinal explícito de positivo', () {
        // int.tryParse('+5') é interpretado como 5
        expect(Validators.validateNumero('+5'), isNull);
      });
    });

    group('Cenários de Falha - Campo obrigatório', () {
      test('deve retornar erro quando o valor for nulo', () {
        final result = Validators.validateNumero(null);
        expect(result, equals(errorObrigatorio));
      });

      test('deve retornar erro quando a string for vazia', () {
        final result = Validators.validateNumero('');
        expect(result, equals(errorObrigatorio));
      });
    });

    group('Cenários de Falha - Formato não numérico', () {
      test('deve retornar erro para letras ou palavras', () {
        expect(Validators.validateNumero('abc'), equals(errorNumerico));
        expect(Validators.validateNumero('dez'), equals(errorNumerico));
      });

      test('deve retornar erro para caracteres especiais e pontuação', () {
        expect(Validators.validateNumero('@#\$%'), equals(errorNumerico));
        expect(Validators.validateNumero('-'), equals(errorNumerico));
        expect(Validators.validateNumero('+'), equals(errorNumerico));
      });

      test('deve retornar erro para combinações alfanuméricas', () {
        expect(Validators.validateNumero('12a'), equals(errorNumerico));
        expect(Validators.validateNumero('b45'), equals(errorNumerico));
      });

      test('deve retornar erro para números com ponto flutuante / decimais', () {
        // int.tryParse rejeita casas decimais
        expect(Validators.validateNumero('10.5'), equals(errorNumerico));
        expect(Validators.validateNumero('10,5'), equals(errorNumerico));
      });
    });

    group('Casos de Borda', () {
      test('deve retornar erro numérico para strings compostas apenas por espaços', () {
        // '   ' não é vazio (length > 0), mas int.tryParse('   ') falha
        expect(Validators.validateNumero('   '), equals(errorNumerico));
      });

      test('deve retornar erro quando houver espaços no início, meio ou fim', () {
        // int.tryParse não faz trim automático
        expect(Validators.validateNumero(' 123'), equals(errorNumerico));
        expect(Validators.validateNumero('123 '), equals(errorNumerico));
        expect(Validators.validateNumero('12 3'), equals(errorNumerico));
      });

      test('deve validar limites de representação de inteiros de 64 bits', () {
        // Maior valor para inteiro de 64 bits com sinal
        expect(Validators.validateNumero('9223372036854775807'), isNull);
        // Menor valor para inteiro de 64 bits com sinal
        expect(Validators.validateNumero('-9223372036854775808'), isNull);

        // Estouro de precisão (overflow de 64 bits falha no tryParse da VM Dart)
        expect(Validators.validateNumero('9223372036854775808'), equals(errorNumerico));
      });
    });
  });
}

```

---

### Como rodar os testes

No terminal da raiz do seu projeto `sintonize`:

```bash
# Executa apenas este arquivo de teste
flutter test test/utils/validators_test.dart

# Ou roda com visualização detalhada de cada caso
flutter test test/utils/validators_test.dart --reporter expanded

```
````

### Resposta ao reparo 1

````markdown
### Classificação da Causa

**(A) O teste presume um comportamento que não é o especificado.**

---

### Análise da Falha

A falha ocorreu no seguinte teste:

```dart
test('deve retornar erro quando houver espaços no início, meio ou fim', () {
  expect(Validators.validateNumero(' 123'), equals(errorNumerico)); // <- FALHA AQUI
  expect(Validators.validateNumero('123 '), equals(errorNumerico));
  expect(Validators.validateNumero('12 3'), equals(errorNumerico));
});

```

A premissa do teste assumiu incorretamente que `int.tryParse` rejeitaria entradas com espaços nas extremidades (ex.: `' 123'`).

No Dart, a implementação de `int.tryParse(source)` **aceita e ignora automaticamente espaços em branco no início e no fim da string** (leading/trailing whitespace). Portanto:

* `int.tryParse(' 123')` avalia com sucesso para `123`.
* `int.tryParse('123 ')` avalia com sucesso para `123`.
* `int.tryParse('12 3')` falha e retorna `null` (espaço interno).

Como a função sob teste segue estritamente o contrato de delegar a validação numérica para `int.tryParse(value)`, entradas como `' 123'` e `'123 '` retornam `null` (são consideradas válidas pela função), fazendo com que a asserção `equals('O número deve ser numérico')` falhe.

---

### Correção do Teste

Para refletir a especificação real da função (e o comportamento nativo de `int.tryParse`), ajustamos o teste separando o comportamento dos espaços internos (que invalidam o número) dos espaços nas extremidades (que são aceitos pelo parser):

```dart
      test('deve aceitar espaços nas extremidades e rejeitar espaços internos', () {
        // int.tryParse permite leading e trailing whitespaces
        expect(Validators.validateNumero(' 123'), isNull);
        expect(Validators.validateNumero('123 '), isNull);

        // Espaço no meio quebra a formatação do inteiro
        expect(Validators.validateNumero('12 3'), equals(errorNumerico));
      });

```

#### Bloco de "Casos de Borda" atualizado:

```dart
    group('Casos de Borda', () {
      test('deve retornar erro numérico para strings compostas apenas por espaços', () {
        // '   ' não é vazio (length > 0), mas int.tryParse('   ') resulta em null
        expect(Validators.validateNumero('   '), equals(errorNumerico));
      });

      test('deve aceitar espaços nas extremidades e rejeitar espaços internos', () {
        // int.tryParse aceita leading e trailing whitespaces nativamente
        expect(Validators.validateNumero(' 123'), isNull);
        expect(Validators.validateNumero('123 '), isNull);

        // Espaços intercalados invalidam o número
        expect(Validators.validateNumero('12 3'), equals(errorNumerico));
      });

      test('deve validar limites de representação de inteiros de 64 bits', () {
        expect(Validators.validateNumero('9223372036854775807'), isNull);
        expect(Validators.validateNumero('-9223372036854775808'), isNull);

        expect(Validators.validateNumero('9223372036854775808'), equals(errorNumerico));
      });
    });

```
````

