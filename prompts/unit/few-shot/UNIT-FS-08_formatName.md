# UNIT-FS-08

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-FS-08 |
| **Função testada** | formatName |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de adicionar-musica.dart e outros 5 arquivos — _formatName) |
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
  static String formatName(String name) {
    if (name.isEmpty) return name;
    return name
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  } 
\```

A função faz parte da classe Validators em lib/utils/validators.dart de um projeto Flutter chamado "sintonize".


---

## Resposta do LLM
Seguindo o mesmo estilo dos exemplos (com group, nomes descritivos e casos claros), aqui estão testes unitários para a função formatName:

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('formatName', () {
    test('deve retornar string vazia quando nome for vazio', () {
      expect(Validators.formatName(''), equals(''));
    });

    test('deve capitalizar primeira letra de uma única palavra', () {
      expect(Validators.formatName('joao'), equals('Joao'));
    });

    test('deve capitalizar cada palavra separada por espaço', () {
      expect(Validators.formatName('joao silva'), equals('Joao Silva'));
    });

    test('deve manter palavras já capitalizadas corretamente', () {
      expect(Validators.formatName('Maria Souza'), equals('Maria Souza'));
    });

    test('deve corrigir mistura de maiúsculas e minúsculas', () {
      expect(Validators.formatName('jOaO sIlVa'), equals('JOaO SIlVa'));
    });

    test('deve funcionar com múltiplos espaços entre palavras', () {
      expect(
        Validators.formatName('joao   silva'),
        equals('Joao   Silva'),
      );
    });

    test('deve funcionar com apenas uma letra', () {
      expect(Validators.formatName('j'), equals('J'));
    });
  });
}
Observações importantes
A função não normaliza o restante da palavra para minúsculo, então "jOaO" vira "JOaO" (mantém o restante como está).
Espaços extras são preservados porque o split(' ') mantém posições vazias.
Não há tratamento de null, então não incluí esse caso (seria erro de runtime).

Se quiser, posso sugerir melhorias na função (ex: normalizar para "Joao Silva" corretamente).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 7 |
| **Testes passaram** | 6 |
| **Testes falharam** | 1 |

### Saída do terminal
00:04 +5 -1: formatName deve funcionar com múltiplos espaços entre palavras [E]                                                                                                                               
  RangeError (index): Invalid value: Valid value range is empty: 0
  dart:core                                       _StringBase.[]
  package:sintonize/utils/validators.dart 149:28  Validators.formatName.<fn>
  dart:_internal                                  ListIterable.join
  package:sintonize/utils/validators.dart 150:10  Validators.formatName
  test\unit\format_name_fs_test.dart 28:20        main.<fn>.<fn>
  

To run this test again: C:\Users\marcos.neto\flutter\bin\cache\dart-sdk\bin\dart.exe test C:/Users/marcos.neto/Desktop/sintonize-tcc/test/unit/format_name_fs_test.dart -p vm --plain-name "formatName deve funcionar com múltiplos espaços entre palavras"
00:04 +6 -1: Some tests failed.                   

---

## Iterative Repair Loop

### Iteração 1
- **Necessária?**  Sim
- **Motivo da falha:** 
O LLM identificou corretamente nas
  suas observações que "split(' ') mantém posições vazias",
  mas mesmo assim gerou um teste que esperava resultado
  formatado ('Joao   Silva') em vez de prever o RangeError
  causado por word[0] em string vazia. Houve contradição
  entre a análise textual do LLM e o código de teste gerado.
  Mesmo erro observado na estratégia zero-shot (UNIT-ZS-08),
  indicando que a presença de exemplos (few-shot) não ajudou
  a prevenir esse tipo de falha.
- **Prompt de correção:**

O teste falhou com o seguinte erro:

\
formatName deve funcionar com múltiplos espaços entre palavras [E] RangeError (index): Invalid value: Valid value range is empty: 0 dart:core _StringBase.[] package:sintonize/utils/validators.dart 149:28 Validators.formatName.<fn> dart:_internal ListIterable.join package:sintonize/utils/validators.dart 150:10 Validators.formatName test\unit\format_name_fs_test.dart 28:20 main.<fn>.<fn> \
Corrija o teste para que ele compile e passe corretamente.


- **Resposta do LLM:**
Esse erro não é do teste em si — ele acontece porque a função quebra quando existem múltiplos espaços ('' vira uma “palavra” vazia e word[0] estoura).

Como o objetivo aqui é corrigir o teste para refletir o comportamento atual da função (sem alterá-la), o teste de múltiplos espaços deve ser ajustado para esperar a exceção.

Aqui vai a versão corrigida:

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('formatName', () {
    test('deve retornar string vazia quando nome for vazio', () {
      expect(Validators.formatName(''), equals(''));
    });

    test('deve capitalizar primeira letra de uma única palavra', () {
      expect(Validators.formatName('joao'), equals('Joao'));
    });

    test('deve capitalizar cada palavra separada por espaço', () {
      expect(Validators.formatName('joao silva'), equals('Joao Silva'));
    });

    test('deve manter palavras já capitalizadas corretamente', () {
      expect(Validators.formatName('Maria Souza'), equals('Maria Souza'));
    });

    test('deve corrigir mistura de maiúsculas e minúsculas', () {
      expect(Validators.formatName('jOaO sIlVa'), equals('JOaO SIlVa'));
    });

    test('deve lançar erro quando houver múltiplos espaços', () {
      expect(
        () => Validators.formatName('joao   silva'),
        throwsA(isA<RangeError>()),
      );
    });

    test('deve funcionar com apenas uma letra', () {
      expect(Validators.formatName('j'), equals('J'));
    });
  });
}
Por que isso resolve?
O teste agora está alinhado com a implementação atual.
Evita falha por RangeError.
Continua cobrindo o edge case de múltiplos espaços.

Se quiser evoluir a função depois, o ideal seria ignorar palavras vazias — aí sim esse teste poderia voltar a esperar "Joao Silva".

- **Resultado:** Passou

### Iteração 2
- **Necessária?** _preencher (Sim/Não)_
- _(preencher se necessário)_

### Iteração 3
- **Necessária?** _preencher (Sim/Não)_
- _(preencher se necessário)_
