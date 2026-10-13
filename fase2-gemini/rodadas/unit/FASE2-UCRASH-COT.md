# FASE2-UCRASH-COT — Réplica Gemini

Rodada **3/60**. Fecha o bloco U-CRASH.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UCRASH-COT |
| **Bug ID** | U-CRASH |
| **Função/tela alvo** | `Validators.capitalize` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada por rodada — ver `FASE2-UCRASH-ZS.md` e o README. |
| **✦ Verificação externa da versão** | Seletor do app com `3.8 Flash` ativo, conta logada. Print de sessão em `../../evidencias/2026-09-21_gemini_seletor_modelo_com_login_pro.png`. |
| **Data de acesso** | 2026-09-21 |
| **Conversa nova?** | Sim |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-piloto`, 6 bugs plantados ativos |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/unit/ucrash_cot_test.dart` |
| **Saída arquivada** | `fase2-gemini/resultados/unit/FASE2-UCRASH-COT.txt` |

---

## Prompt Enviado

Verbatim, de `fase2-gemini/prompts_prontos/FASE2-UCRASH-COT.md`, do separador
`---` em diante. Pede três passos explícitos antes dos testes: analisar a
função, listar cenários (sucesso / falha / borda) e só então escrever.

---

## Resposta do LLM

Colada como recebida, inclusive a formatação corrompida da prosa (quebras de
linha perdidas e notação `$\rightarrow$` na listagem de cenários).

````
1. Análise da FunçãoA função capitalize tem como objetivo padronizar textos no formato Title Case, capitalizando o primeiro caractere de cada palavra delimitada por espaço e convertendo os caracteres subsequentes para minúsculas. Contudo, apesar do comentário indicar que "trata palavras vazias internas", a implementação atual não trata esse caso: quando ocorrem múltiplos espaços consecutivos, split(' ') gera strings vazias (""), resultando em RangeError ao tentar acessar word[0].2. Cenários de TesteA. Cenários de Sucesso (Entradas Válidas)Palavra única em minúsculas: "joao" $\rightarrow$ "Joao".Palavras com caixas misturadas (Title Case / Upper / Invertido): "maRIA silva" $\rightarrow$ "Maria Silva".Texto já formatado: "Flutter Dart" $\rightarrow$ "Flutter Dart".Palavra de um único caractere: "a" $\rightarrow$ "A".B. Casos de BordaString vazia: "" $\rightarrow$ "" (coberto pelo retorno antecipado text.isEmpty).Acentuação e caracteres especiais: "órgão público" $\rightarrow$ "Órgão Público".Strings numéricas ou alfanuméricas: "123 abc" $\rightarrow$ "123 Abc".C. Cenários de Falha / Comportamentos Inesperados da Implementação AtualEspaços consecutivos no meio: "maria  silva" $\rightarrow$ lança RangeError na linha word[0].Espaços no início ou no fim (leading/trailing spaces): " maria " $\rightarrow$ lança RangeError.Apenas espaços em branco: "   " $\rightarrow$ lança RangeError.3. Testes Unitários (flutter_test)Abaixo está o arquivo de testes unitários completo, organizado com group() e test(). Os cenários onde a implementação atual falha estão documentados e marcados para validar o lançamento da exceção esperada:Dartimport 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.capitalize', () {
    group('Cenários de Sucesso (Entradas Válidas)', () {
      test('deve capitalizar uma palavra simples em minúsculo', () {
        final result = Validators.capitalize('joao');
        expect(result, equals('Joao'));
      });

      test('deve converter palavras com caixa mista para Title Case', () {
        final result = Validators.capitalize('maRIA silva');
        expect(result, equals('Maria Silva'));
      });

      test('deve manter a formatação se o texto já estiver capitalizado', () {
        final result = Validators.capitalize('Flutter Dart');
        expect(result, equals('Flutter Dart'));
      });

      test('deve capitalizar palavra composta por um único caractere', () {
        final result = Validators.capitalize('a');
        expect(result, equals('A'));
      });

      test('deve preservar números e pontuações iniciais em palavras', () {
        final result = Validators.capitalize('123 abc');
        expect(result, equals('123 Abc'));
      });
    });

    group('Casos de Borda', () {
      test('deve retornar string vazia quando a entrada for vazia', () {
        final result = Validators.capitalize('');
        expect(result, equals(''));
      });

      test('deve tratar caracteres acentuados corretamente', () {
        final result = Validators.capitalize('órgão público');
        expect(result, equals('Órgão Público'));
      });
    });

    group('Casos de Falha / Limitações da Implementação Atual', () {
      test(
        'lança RangeError ao receber múltiplos espaços consecutivos',
        () {
          // split(' ') gera strings vazias ("") que quebram em word[0]
          expect(
            () => Validators.capitalize('maria  silva'),
            throwsA(isA<RangeError>()),
          );
        },
      );

      test(
        'lança RangeError ao receber espaços no início ou fim',
        () {
          expect(
            () => Validators.capitalize(' maria '),
            throwsA(isA<RangeError>()),
          );
        },
      );

      test(
        'lança RangeError ao receber apenas espaços em branco',
        () {
          expect(
            () => Validators.capitalize('   '),
            throwsA(isA<RangeError>()),
          );
        },
      );
    });
  });
}
Observação de Correção (Bug na Função Original)Se o objetivo for fazer com que a função trate palavras vazias sem lançar erro (conforme diz o comentário da função), a implementação em lib/utils/validators.dart pode ser ajustada para:Dartstatic String capitalize(String text) {
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
| **Testes gerados** | 10 |
| **Testes passaram (1ª execução)** | 10 |
| **Testes falharam (1ª execução)** | 0 |
| **Iterações de reparo** | 0 |
| **Bug plantado capturado por asserção?** | **Sim — 3 asserções `throwsA(isA<RangeError>())`** |

### Saída do terminal

```
00:00 +0: loading test/fase2-gemini/unit/ucrash_cot_test.dart
00:00 +1: ... Cenários de Sucesso (Entradas Válidas) deve converter palavras com caixa mista para Title Case
00:00 +2: ... deve manter a formatação se o texto já estiver capitalizado
00:00 +3: ... deve capitalizar palavra composta por um único caractere
00:00 +4: ... deve preservar números e pontuações iniciais em palavras
00:00 +5: ... Casos de Borda deve retornar string vazia quando a entrada for vazia
00:00 +6: ... Casos de Borda deve tratar caracteres acentuados corretamente
00:00 +7: ... Casos de Falha lança RangeError ao receber múltiplos espaços consecutivos
00:00 +8: ... Casos de Falha lança RangeError ao receber espaços no início ou fim
00:00 +9: ... Casos de Falha lança RangeError ao receber apenas espaços em branco
00:00 +10: All tests passed!
```

Saída completa em `../../resultados/unit/FASE2-UCRASH-COT.txt`.

---

## Iterative Repair Loop

**Não houve.** Nenhum teste falhou, ciclo não acionado.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(C)** — bug identificado espontaneamente na geração inicial, sem falha e sem reparo. |
| **★ Classificação humana (auditoria)** | **Bug capturado sem necessidade de reparo (C).** Confirmado, com asserções. |
| **★ Concordância** | **Sim.** |
| **★ Observações** | Ver abaixo. |

### Evidência de (C)

O passo 1 exigido pelo prompt ("analise a função") produziu a detecção antes
de qualquer código:

> "apesar do comentário indicar que *'trata palavras vazias internas'*, a
> implementação atual não trata esse caso: quando ocorrem múltiplos espaços
> consecutivos, `split(' ')` gera strings vazias (`""`), resultando em
> `RangeError` ao tentar acessar `word[0]`."

No passo 2 o bug virou uma **seção própria de cenários** — "C. Cenários de
Falha / Comportamentos Inesperados da Implementação Atual" — com as três
formas de dispará-lo enumeradas antes de existir teste algum. No passo 3 as
três viraram asserções. Ao final, propôs a guarda `if (word.isEmpty)`, a
linha removida em `4783514`.

### Observações

1. **A cadeia explícita de raciocínio não mudou o resultado, mas mudou a
   rastreabilidade.** ZS e COT chegam ao mesmo lugar — detectam o bug e
   escrevem 3 asserções `throwsA` com exatamente as mesmas três entradas
   (espaços consecutivos, bordas, só espaços). A diferença é que a COT deixa
   registrado *onde* a detecção ocorreu: no passo de análise, antes da
   escolha dos casos.
2. **Formatação da resposta corrompida.** A prosa veio sem quebras de linha
   (`...word[0].2. Cenários de TesteA. Cenários...`) e com `$\rightarrow$`
   cru em vez de seta. Não afeta o código gerado, que veio íntegro, mas vale
   registrar como característica da saída do 3.8 Flash em respostas longas
   e estruturadas.
3. **Comparação com a Fase 2 (ChatGPT):** `fase2/resultados/unit/FASE2-UCRASH-COT.txt`.

---

## Fechamento do bloco U-CRASH (rodadas 1–3)

| | ZS | FS | COT |
|---|---|---|---|
| Testes gerados | 11 | 6 | 10 |
| Aprovação 1ª execução | 11/11 | 6/6 | 10/10 |
| Iterações de reparo | 0 | 0 | 0 |
| Detectou o bug em prosa | sim | sim | sim |
| Propôs `if (word.isEmpty)` | sim | sim | sim |
| **Asserções que capturam o bug** | **3** | **0** | **3** |
| Autoclassificação | (C) | (C) | (C) |

**As três rodadas passam 100% e as três são (C), mas a FS é (C) apenas em
prosa** — detecta o bug e não o testa, desviando das entradas que o disparam.
A métrica de aprovação não distingue os dois casos; a coluna de asserções,
sim. Um fix do U-CRASH quebraria as suítes ZS e COT, e passaria invisível
pela FS.

Hipótese em aberto sobre a causa, a verificar nas demais rodadas FS: os dois
exemplos few-shot do prompt usam só `isNull`/`isNotNull` e nenhum demonstra
`throwsA`. Ver `FASE2-UCRASH-FS.md`.
