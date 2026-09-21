# FASE2-UCRASH-ZS — PILOTO DESCARTADO (Gemini 3.5 Flash Lite, sem login)

> **Fora da contagem de 60.** Rodada executada antes da revisão da condição
> experimental de 2026-09-21. Ver `README.md` desta pasta.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UCRASH-ZS (piloto descartado) |
| **Bug ID** | U-CRASH |
| **Função/tela alvo** | `Validators.capitalize` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | 3.5 Flash Lite (adotada com base na evidência de UI) |
| **✦ Modelo declarado pelo Gemini** | **Não perguntado nesta sessão.** O operador não fez a pergunta de versão antes de colar o prompt da rodada. A identificação veio do seletor de modelos da interface, não do modelo. |
| **✦ Verificação externa da versão** | Evidência primária: print do seletor do app Gemini deslogado em 2026-09-21 (`../evidencias/2026-09-21_gemini_seletor_modelo_sem_login.png`) — "3.5 Flash Lite" marcado e único selecionável; "3.6 Flash" e "3.1 Pro" esmaecidos atrás de login. Fontes secundárias consultadas em 2026-09-21 ([freeainews](https://freeainews.com/news/gemini-35-flash-free-tier-2026/), [pecollective](https://pecollective.com/tools/gemini-free-tier-guide/), [Wikipedia — Google Gemini](https://en.wikipedia.org/wiki/Google_Gemini)) afirmam 3.6 Flash como modelo gratuito do app desde 2026-07-21 — **divergem da UI deslogada, e a divergência fica registrada, não resolvida**. A leitura provável é que as fontes descrevem o app com login. |
| **Data de acesso** | 2026-09-21 |
| **Conversa nova?** | Sim |
| **Sessão** | Sem login |
| **Branch / estado do código** | `fase2-gemini-piloto` — os 6 bugs plantados verificados ativos antes da execução |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 · DevTools 2.54.2 |
| **Caminho do teste** | `fase2-gemini/piloto-flash-lite/ucrash_zs_test.dart` (mantido fora de `test/` para não entrar na suíte) |

---

## Prompt Enviado

Copiado verbatim de `fase2-gemini/prompts_prontos/FASE2-UCRASH-ZS.md`, do
separador `---` em diante.

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
Aqui está o código completo para os testes unitários utilizando o pacote flutter_test, estruturado conforme os padrões recomendados em projetos Flutter.

Crie o arquivo de teste no caminho correspondiente (por exemplo, test/utils/validators_test.dart):

Dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart'; // Ajuste o import conforme a estrutura real do seu projeto

void main() {
  group('Validators.capitalize', () {
    group('Cenários de Sucesso', () {
      test('deve capitalizar corretamente um nome simples em letras minúsculas', () {
        final result = Validators.capitalize('maria');
        expect(result, equals('Maria'));
      });

      test('deve corrigir um nome misturado com maiúsculas e minúsculas aleatórias', () {
        final result = Validators.capitalize('maRIA');
        expect(result, equals('Maria'));
      });

      test('deve capitalizar corretamente um nome completo com múltiplos espaços e letras misturadas', () {
        final result = Validators.capitalize('maRIA silva');
        expect(result, equals('Maria Silva'));
      });

      test('deve capitalizar uma frase completa com várias palavras', () {
        final result = Validators.capitalize('joão pedro DE oliveira');
        // Nota: A lógica atual aplica toLowerCase em todo o restante, 
        // então conectores como "de" virarão "De". Se esse for o comportamento esperado:
        expect(result, equals('João Pedro De Oliveira'));
      });
    });

    group('Casos de Borda e Valores Limites', () {
      test('deve retornar uma string vazia quando a entrada for vazia', () {
        final result = Validators.capitalize('');
        expect(result, equals(''));
      });

      test('deve lidar corretamente com uma única letra', () {
        final result = Validators.capitalize('a');
        expect(result, equals('A'));
      });

      test('deve lidar corretamente com uma única letra maiúscula', () {
        final result = Validators.capitalize('Z');
        expect(result, equals('Z'));
      });

      test('deve lidar com espaços extras nas extremidades ou múltiplos espaços', () {
        // Cuidado: split(' ') com espaços múltiplos cria palavras vazias ('') 
        // que podem causar comportamentos indesejados dependendo da implementação.
        // Este teste documenta o comportamento atual da função com espaços.
        expect(() => Validators.capitalize('  '), returnsNormally);
      });
    });

    group('Cenários de Falha / Erros esperados', () {
      test('deve lançar RangeError ao tentar capitalizar uma string contendo apenas um espaço', () {
        // AVISO DE BUG CONHECIDO NA IMPLEMENTAÇÃO:
        // Se a entrada for ' ' (espaço simples), o split gera ['']. 
        // word[0] tenta acessar o índice 0 de uma string vazia, lançando StateError/RangeError.
        expect(
          () => Validators.capitalize(' '),
          throwsA(isA<RangeError>()),
        );
      });

      test('deve lançar RangeError quando houver múltiplos espaços consecutivos gerando vazios internos', () {
        // AVISO DE BUG CONHECIDO NA IMPLEMENTAÇÃO:
        // Espaços duplos como "Ana  Silva" geram strings vazias no split, 
        // disparando RangeError ao tentar pegar word[0].
        expect(
          () => Validators.capitalize('Ana  Silva'),
          throwsA(isA<RangeError>()),
        );
      });
    });
  });
}
Como executar:
Para rodar os testes criados, utilize o comando no terminal na raiz do seu projeto Flutter:

Bash
flutter test test/utils/validators_test.dart
Nota sobre o comportamento: Os testes de falha apontam um comportamento crítico na função atual (Validators.capitalize(' ') ou espaços duplos). Caso queira evitar que a função quebre com espaços duplos, considere ajustar o método utilizando um filtro no split, por exemplo: text.trim().split(RegExp(r'\s+')).
````

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 10 |
| **Testes passaram (1ª execução)** | 9 |
| **Testes falharam (1ª execução)** | 1 |
| **Testes passaram (pós-repair)** | — (nenhum código novo foi produzido no reparo) |
| **Testes falharam (pós-repair)** | — |

### Saída do terminal

Arquivo completo: `FASE2-UCRASH-ZS_iter0.txt`. Trecho da falha:

```
00:00 +7 -1: Validators.capitalize Casos de Borda e Valores Limites deve lidar com espaços extras nas extremidades ou múltiplos espaços [E]
  Expected: return normally
    Actual: <Closure: () => String>
     Which: threw RangeError:<RangeError (index): Invalid value: Valid value range is empty: 0>

  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart 473:18  expect
  test\fase2-gemini\unit\ucrash_zs_test.dart 50:9     main.<fn>.<fn>.<fn>

00:00 +9 -1: Some tests failed.
```

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** contradição interna da própria resposta. O teste
  "deve lidar com espaços extras..." assere `returnsNormally` para `'  '`,
  enquanto o teste "deve lançar RangeError quando houver múltiplos espaços
  consecutivos" assere `throwsA(isA<RangeError>())` para `'Ana  Silva'`.
  Mesma entrada estrutural, mesma causa, asserções opostas.

- **✦ Recusa ao prompt verbatim — desvio registrado.** O prompt de reparo foi
  colado **sem alteração**, conforme o protocolo, e o modelo respondeu apenas:

  ```
  Não consigo te ajudar com isso. Sou só um modelo de linguagem e não tenho
  capacidade de entender e responder a essa questão.
  ```

  O operador então reenviou o mesmo prompt acrescido de **um espaço em branco
  no final** — nenhuma outra alteração — e obteve a resposta completa abaixo.
  O texto não é byte-idêntico ao prompt da rodada, mas a diferença é
  **semanticamente nula**: um caractere de espaço em posição terminal.

  **Interpretação: recusa não determinística.** Não é recusa de política (o
  conteúdo é benigno) nem incompreensão do conteúdo (o mesmo texto, sem
  reescrita alguma, foi respondido em profundidade na segunda tentativa). O
  que se observa é variação entre execuções da mesma entrada.

  **Consequência para o protocolo:** uma recusa isolada não deve ser tratada
  como resultado da rodada. O reenvio do prompt inalterado é a resposta
  correta, e deve ser registrado como tentativa. Recusas repetidas ao mesmo
  prompt, aí sim, são dado.

- **Resposta do LLM (ao prompt alterado):**

  ```
  Classificação da Causa da Falha
  Classificação: (B) — O teste capturou um comportamento potencialmente incorreto da aplicação.

  Análise do Problema
  Comportamento Observado: Quando a função recebe uma string contendo espaços extras nas extremidades ou múltiplos espaços consecutivos (como no teste que avaliou   ), o método text.split(' ') gera elementos vazios ('') na lista resultante. Em seguida, a linha word[0] tenta acessar o índice 0 de uma string vazia, fazendo com que a aplicação lance um RangeError e quebre inesperadamente.

  Comportamento Esperado: Uma função utilitária de formatação de texto (capitalize) deve ser resiliente a entradas comuns de usuários, que frequentemente incluem espaços extras acidentais, múltiplos espaços ou quebras. O comportamento correto seria processar os dados de forma limpa, ignorando ou preservando os espaços de maneira controlada, sem lançar exceções não tratadas que quebram o fluxo da aplicação.

  Por que é um problema na aplicação: Textos vindos de campos de formulários em Flutter (TextField) costumam conter espaços extras no início, no fim ou duplos inseridos por digitação incorreta. Uma função que falha com um RangeError apenas por causa de espaçamento representa um bug de robustez na camada de código de utilitários (Validators), exigindo correção na lógica da função (por exemplo, usando tratamento com trim() ou expressões regulares para ignorar espaços vazios) em vez de enfraquecer o teste.
  ```

- **★ Autoclassificação do modelo:** **(B)** — bug real exposto, declarada
  explicitamente.
- **Resultado após correção:** sem correção. Coerente com o caminho (B) do
  prompt de reparo, o modelo não devolveu código. A rodada encerra em 9/10,
  e não houve iterações 2 e 3.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(B)** na iteração 1. Há também evidência de **(C)** na geração inicial: antes de qualquer falha, o modelo escreveu `AVISO DE BUG CONHECIDO NA IMPLEMENTAÇÃO` em dois testes e asseriu `throwsA(isA<RangeError>())`, ou seja, reconheceu e tratou o U-CRASH já ao gerar. |
| **★ Classificação humana (auditoria)** | **Erro de teste sobre bug real.** O `RangeError` é o U-CRASH e foi corretamente capturado — nisso o modelo acerta. Mas *o teste que falhou* está errado por conta própria: assere `returnsNormally` para uma entrada (`'  '`) estruturalmente idêntica à que ele mesmo assere que lança (`'Ana  Silva'`). A falha não decorre do bug da aplicação; decorre da contradição interna da resposta. |
| **★ Concordância** | **Parcial.** Concordância sobre a existência do bug; discordância sobre a causa *desta* falha. O modelo atribuiu a falha ao bug (B) e não percebeu que havia se contradito — o caminho (B) do prompt, ao proibir enfraquecer asserções, o impediu de revisar a asserção que de fato estava errada. |
| **★ Observações** | 1) O bug foi detectado espontaneamente (C), o resultado mais forte possível para uma rodada de bug plantado — e veio do tier mais fraco do Gemini, em zero-shot. 2) O prompt de reparo foi recusado na primeira tentativa e respondido na segunda, com o texto semanticamente inalterado: recusa não determinística, ver a Iteração 1. 3) A interação (B) × contradição interna é um modo de falha do protocolo de reparo que vale observar nas demais rodadas: quando a resposta inicial se contradiz, a instrução (B) pode travar a correção legítima. |

---

## Por que esta rodada não conta

Ver `README.md` desta pasta. Em resumo: deslogado, o Gemini serve 3.5 Flash
Lite, enquanto a Fase 2 deslogada recebeu GPT-5.5/5.6 do ChatGPT. Manter a
condição faria a réplica comparar tiers desiguais. A partir de 2026-09-21 as
60 rodadas rodam **com login, fixadas em 3.6 Flash**.
