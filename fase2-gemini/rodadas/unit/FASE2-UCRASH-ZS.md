# FASE2-UCRASH-ZS — Réplica Gemini

Rodada **1/60**.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UCRASH-ZS |
| **Bug ID** | U-CRASH |
| **Função/tela alvo** | `Validators.capitalize` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | **Não declara.** A pergunta não foi repetida nesta conversa — ver a nota abaixo. Resposta padrão registrada para a réplica, colhida em 2026-09-21: *"Eu sou o Gemini, um grande modelo de linguagem desenvolvido pelo Google. Como assistente de IA, estou sempre atualizado com as tecnologias mais recentes para ajudar você no dia a dia, seja na escrita de trabalhos acadêmicos, na organização de ideias ou em qualquer outra tarefa que precisar!"* — nenhum número de versão. Print: `../../evidencias/2026-09-21_gemini_pergunta_de_versao_nao_declara.png`. |
| **✦ Verificação externa da versão** | Evidência primária: seletor de modelos do app, conta logada, com `3.8 Flash` ativo antes da primeira mensagem. Print do seletor em `../../evidencias/2026-09-21_gemini_seletor_modelo_com_login_pro.png`. A linha de modelos disponível em 2026-09-21 era `3.5 Flash Lite` / `3.8 Flash` / `3.1 Pro`. Fontes externas consultadas no mesmo dia apontavam `3.6 Flash` como corrente — **defasadas em relação à UI, e a divergência fica registrada**. |
| **Data de acesso** | 2026-09-21 |
| **Conversa nova?** | Sim |
| **Sessão** | Com login, conta Gemini Pro (plano pago) — ver a mudança de condição no README |
| **Branch / estado do código** | `fase2-gemini-piloto`, com os 6 bugs plantados ativos. U-CRASH confirmado antes da execução: `grep -c "word.isEmpty" lib/utils/validators.dart` → `0` |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 · DevTools 2.54.2 |
| **Arquivo de teste** | `test/fase2-gemini/unit/ucrash_zs_test.dart` |
| **Saída arquivada** | `fase2-gemini/resultados/unit/FASE2-UCRASH-ZS.txt` |

**Nota sobre a pergunta de versão.** Ela foi feita uma vez, em 2026-09-21, e o
modelo não divulgou versão alguma. Como a resposta não traz informação e o
seletor é evidência mais forte, a pergunta **deixou de ser repetida a cada
rodada**; a não-divulgação vale como resposta padrão da réplica e o controle
por rodada passa a ser a conferência do seletor. A sessão em que a pergunta
foi feita rodava em `3.5 Flash Lite` e **não é esta conversa** — foi
descartada e não gerou rodada.

---

## Prompt Enviado

Verbatim, de `fase2-gemini/prompts_prontos/FASE2-UCRASH-ZS.md`, do separador
`---` em diante.

````
Gere testes unitários em Dart usando o pacote flutter_test para a seguinte função:

```dart
  /// Origem: lib/mapa.dart (_capitalize)
  /// Capitaliza a primeira letra E aplica toLowerCase no restante —
  /// ex.: "maRIA silva" → "Maria Silva". Trata palavras vazias internas.
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
```

A função faz parte de uma classe chamada Validators no arquivo lib/utils/validators.dart de um projeto Flutter chamado "sintonize".

Requisitos:
- Use a estrutura group() e test() do flutter_test
- Cubra cenários de sucesso e de falha
- Inclua casos de borda
- Os testes devem ser executáveis com `flutter test`
````

---

## Resposta do LLM

````
Aqui está a suíte de testes unitários para a função Validators.capitalize.

Note um detalhe importante sobre a implementação fornecida: apesar do comentário citar "Trata palavras vazias internas", a linha word[0] dispara uma exceção RangeError (Index out of range: index should be less than 0: 0) quando encontra múltiplos espaços consecutivos ou espaços nas extremidades (pois text.split(' ') gera strings vazias "").

Os testes abaixo cobrem os cenários de sucesso, casos de borda e documentam formalmente essas falhas esperadas causadas por strings vazias dentro do split.

Arquivo: test/utils/validators_test.dart
Dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.capitalize', () {
    group('Cenários de Sucesso', () {
      test('deve capitalizar uma única palavra em minúsculo', () {
        final result = Validators.capitalize('teste');
        expect(result, equals('Teste'));
      });

      test('deve capitalizar uma palavra com caracteres mistos (maiúsculos e minúsculos)', () {
        final result = Validators.capitalize('mArIa');
        expect(result, equals('Maria'));
      });

      test('deve converter palavras em caixa alta mantendo apenas a inicial maiúscula', () {
        final result = Validators.capitalize('MARIA SILVA');
        expect(result, equals('Maria Silva'));
      });

      test('deve capitalizar corretamente múltiplas palavras separadas por espaço simples', () {
        final result = Validators.capitalize('joão da silva');
        expect(result, equals('João Da Silva'));
      });

      test('deve manter caracteres acentuados ao capitalizar', () {
        final result = Validators.capitalize('álvaro érico');
        expect(result, equals('Álvaro Érico'));
      });
    });

    group('Casos de Borda Válidos', () {
      test('deve retornar a própria string quando for vazia', () {
        final result = Validators.capitalize('');
        expect(result, equals(''));
      });

      test('deve processar palavras de apenas uma letra', () {
        final result = Validators.capitalize('a b c');
        expect(result, equals('A B C'));
      });

      test('não deve alterar palavras que já começam com números ou símbolos', () {
        final result = Validators.capitalize('123 teste #flutter');
        expect(result, equals('123 Teste #flutter'));
      });
    });

    group('Casos de Falha / Limitações da Implementação Atual', () {
      test('deve lançar RangeError quando houver múltiplos espaços consecutivos', () {
        // split(' ') gera strings vazias "", e word[0] falha com RangeError
        expect(
          () => Validators.capitalize('maria  silva'),
          throwsA(isA<RangeError>()),
        );
      });

      test('deve lançar RangeError se a string contiver apenas espaços', () {
        expect(
          () => Validators.capitalize('   '),
          throwsA(isA<RangeError>()),
        );
      });

      test('deve lançar RangeError se houver espaços no início ou no fim', () {
        expect(
          () => Validators.capitalize(' maria silva '),
          throwsA(isA<RangeError>()),
        );
      });
    });
  });
}
Dica de Correção para a Função
Caso queira que a função de fato suporte múltiplos espaços, espaços nas bordas e palavras vazias sem quebrar, basta adicionar uma verificação de word.isEmpty:

Dart
static String capitalize(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}
````

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 11 |
| **Testes passaram (1ª execução)** | 11 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — |
| **Testes falharam (pós-repair)** | — |
| **Iterações de reparo** | 0 |

### Saída do terminal

```
00:00 +0: loading test/fase2-gemini/unit/ucrash_zs_test.dart
00:00 +1: Validators.capitalize Cenários de Sucesso deve capitalizar uma palavra com caracteres mistos (maiúsculos e minúsculos)
00:00 +2: Validators.capitalize Cenários de Sucesso deve converter palavras em caixa alta mantendo apenas a inicial maiúscula
00:00 +3: Validators.capitalize Cenários de Sucesso deve capitalizar corretamente múltiplas palavras separadas por espaço simples
00:00 +4: Validators.capitalize Cenários de Sucesso deve manter caracteres acentuados ao capitalizar
00:00 +5: Validators.capitalize Casos de Borda Válidos deve retornar a própria string quando for vazia
00:00 +6: Validators.capitalize Casos de Borda Válidos deve processar palavras de apenas uma letra
00:00 +7: Validators.capitalize Casos de Borda Válidos não deve alterar palavras que já começam com números ou símbolos
00:00 +8: Validators.capitalize Casos de Falha / Limitações da Implementação Atual deve lançar RangeError quando houver múltiplos espaços consecutivos
00:00 +9: Validators.capitalize Casos de Falha / Limitações da Implementação Atual deve lançar RangeError se a string contiver apenas espaços
00:00 +10: Validators.capitalize Casos de Falha / Limitações da Implementação Atual deve lançar RangeError se houver espaços no início ou no fim
00:00 +11: All tests passed!
```

Saída completa em `../../resultados/unit/FASE2-UCRASH-ZS.txt`.

---

## Iterative Repair Loop

**Não houve.** Nenhum teste falhou na primeira execução, logo o ciclo de
reparo não foi acionado e nenhuma das 3 iterações foi usada.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(C)** — bug identificado espontaneamente na geração inicial, sem falha e sem reparo. |
| **★ Classificação humana (auditoria)** | **Bug capturado sem necessidade de reparo (C).** Confirmado. |
| **★ Concordância** | **Sim.** |
| **★ Observações** | Ver abaixo. |

### Evidência de (C)

O modelo não só capturou o U-CRASH como o **contradisse explicitamente contra
a docstring**, antes de qualquer execução:

> "apesar do comentário citar *'Trata palavras vazias internas'*, a linha
> `word[0]` dispara uma exceção `RangeError` (...) quando encontra múltiplos
> espaços consecutivos ou espaços nas extremidades (pois `text.split(' ')`
> gera strings vazias `""`)."

Isso é notável porque a docstring **afirma o oposto do que o código faz** — o
U-CRASH foi plantado removendo a guarda e deixando o comentário intacto. O
modelo confiou no código, não no comentário.

Em seguida nomeou o grupo de testes de `Casos de Falha / Limitações da
Implementação Atual` e escreveu três asserções de `RangeError` cobrindo as
três formas de disparar o bug: espaços consecutivos (`'maria  silva'`), string
só de espaços (`'   '`) e espaços nas bordas (`' maria silva '`).

Por fim, **propôs a correção exata do bug plantado**:

```dart
if (word.isEmpty) return word;
```

Essa é literalmente a linha removida para criar o U-CRASH. Ver o commit
`4783514`.

### Observações

1. **Resultado máximo para uma rodada de bug plantado**, em zero-shot, sem
   nenhum reparo: detectou, documentou, testou as três variantes e propôs o
   fix correto.
2. **A docstring enganosa não funcionou como distrator.** É um bom sinal sobre
   a leitura do código em detrimento do comentário, e vale comparar com o que
   as demais estratégias (FS, COT) fizerem com o mesmo material.
3. **Nenhum teste contraditório.** Vale o contraste com o piloto descartado em
   `3.5 Flash Lite`, que, com o mesmo prompt, também detectou o bug mas
   escreveu uma asserção de `returnsNormally` conflitante com as próprias
   asserções de `RangeError`, e falhou 1/10. Ver `../../piloto-flash-lite/`.
4. **Comparação com a Fase 2 (ChatGPT):** ver `fase2/resultados/unit/FASE2-UCRASH-ZS.txt`
   e o doc correspondente em `fase2/rodadas/unit/`.
