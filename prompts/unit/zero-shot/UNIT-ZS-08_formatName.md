# UNIT-ZS-08

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-ZS-08 |
| **Função testada** | formatName |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de adicionar-musica.dart e outros 5 arquivos — _formatName) |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.6 |
| **Data de acesso** | _preencher_ |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 |

---

## Prompt Enviado
Gere testes unitários em Dart usando o pacote flutter_test para a seguinte função:

\```dart
  static String formatName(String name) {
    if (name.isEmpty) return name;
    return name
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  } 
\```

A função faz parte de uma classe chamada Validators no arquivo lib/utils/validators.dart de um projeto Flutter chamado "sintonize".

Requisitos:
- Use a estrutura group() e test() do flutter_test
- Cubra cenários de sucesso e de falha
- Inclua casos de borda
- Os testes devem ser executáveis com `flutter test`

---

## Resposta do LLM
Aqui está um conjunto de testes unitários usando flutter_test que cobre cenários de sucesso, falha e casos de borda para a função formatName:

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.formatName', () {
    test('Deve capitalizar uma única palavra', () {
      expect(Validators.formatName('joao'), 'Joao');
    });

    test('Deve capitalizar múltiplas palavras', () {
      expect(Validators.formatName('joao silva'), 'Joao Silva');
    });

    test('Deve manter palavras já capitalizadas', () {
      expect(Validators.formatName('Joao Silva'), 'Joao Silva');
    });

    test('Deve lidar com mistura de maiúsculas e minúsculas', () {
      expect(Validators.formatName('jOaO sIlVa'), 'JOaO SIlVa');
    });

    test('Deve retornar string vazia quando input for vazio', () {
      expect(Validators.formatName(''), '');
    });

    test('Deve lidar com espaços extras entre palavras', () {
      expect(Validators.formatName('joao   silva'), 'Joao   Silva');
    });

    test('Deve lidar com espaços no início e fim', () {
      expect(Validators.formatName('  joao silva  '), '  Joao Silva  ');
    });

    test('Deve falhar com palavra vazia no split (edge case)', () {
      expect(
        () => Validators.formatName(' '),
        throwsA(isA<RangeError>()),
      );
    });

    test('Deve lidar com nomes com caracteres especiais', () {
      expect(Validators.formatName('joão da silva'), 'João Da Silva');
    });

    test('Deve lidar com nomes com hífen', () {
      expect(Validators.formatName('joao-pedro'), 'Joao-pedro');
    });
  });
}

Esse arquivo pode ser salvo, por exemplo, em:

test/utils/validators_test.dart

E executado com:

flutter test

Se quiser, posso também ajustar a função para evitar o RangeError no caso de strings com múltiplos espaços (isso é um bug real na implementação atual).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 10 |
| **Testes passaram** | 8 |
| **Testes falharam** | 2 |


### Saída do terminal
00:02 +5 -1: Validators.formatName Deve lidar com espaços extras entre palavras [E]
  RangeError (index): Invalid value: Valid value range is empty: 0
  dart:core                                       _StringBase.[]
  package:sintonize/utils/validators.dart 149:28  Validators.formatName.<fn>
  dart:_internal                                  ListIterable.join
  package:sintonize/utils/validators.dart 150:10  Validators.formatName
  test\unit\format_name_zs_test.dart 27:25        main.<fn>.<fn>


To run this test again: C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe test C:/Users/Marcos/Desktop/Sintonize/test/unit/format_name_zs_test.dart -p vm --plain-name "Validators.formatName Deve lidar com espaços extras entre palavras"
00:02 +5 -2: Validators.formatName Deve lidar com espaços no início e fim [E]
  RangeError (index): Invalid value: Valid value range is empty: 0
  dart:core                                       _StringBase.[]
  package:sintonize/utils/validators.dart 149:28  Validators.formatName.<fn>
  dart:_internal                                  ListIterable.join
  package:sintonize/utils/validators.dart 150:10  Validators.formatName
  test\unit\format_name_zs_test.dart 31:25        main.<fn>.<fn>


To run this test again: C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe test C:/Users/Marcos/Desktop/Sintonize/test/unit/format_name_zs_test.dart -p vm --plain-name "Validators.formatName Deve lidar com espaços no início e fim"
00:02 +8 -2: Some tests failed.

---

## Iterative Repair Loop

### Iteração 1
- **Necessária?** Sim 
- **Motivo da falha:** 
O LLM gerou testes que esperavam
  resultado formatado para inputs com múltiplos espaços
  ('joao   silva'), mas a função crashou com RangeError.
  A causa é que split(' ') gera strings vazias e word[0]
  falha em string vazia. O LLM não analisou o código com
  profundidade suficiente para prever esse comportamento.
  
- **Prompt de correção:**

O teste falhou com o seguinte erro: 00:02 +5 -1: Validators.formatName Deve lidar com espaços extras entre palavras [E] RangeError (index): Invalid value: Valid value range is empty: 0 dart:core _StringBase.[] package:sintonize/utils/validators.dart 149:28 Validators.formatName.<fn> dart:_internal ListIterable.join package:sintonize/utils/validators.dart 150:10 Validators.formatName test\unit\format_name_zs_test.dart 27:25 main.<fn>.<fn> To run this test again: C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe test C:/Users/Marcos/Desktop/Sintonize/test/unit/format_name_zs_test.dart -p vm --plain-name "Validators.formatName Deve lidar com espaços extras entre palavras" 00:02 +5 -2: Validators.formatName Deve lidar com espaços no início e fim [E] RangeError (index): Invalid value: Valid value range is empty: 0 dart:core _StringBase.[] package:sintonize/utils/validators.dart 149:28 Validators.formatName.<fn> dart:_internal ListIterable.join package:sintonize/utils/validators.dart 150:10 Validators.formatName test\unit\format_name_zs_test.dart 31:25 main.<fn>.<fn> To run this test again: C:\src\flutter\bin\cache\dart-sdk\bin\dart.exe test C:/Users/Marcos/Desktop/Sintonize/test/unit/format_name_zs_test.dart -p vm --plain-name "Validators.formatName Deve lidar com espaços no início e fim" 00:02 +8 -2: Some tests failed. Corrija o teste para que ele compile e passe corretamente.


- **Resposta do LLM:**
O erro não está no teste em si — ele revelou um comportamento real da sua função. Quando existem múltiplos espaços, o split(' ') gera strings vazias (''), e aí word[0] quebra com RangeError.

Ou seja: esses cenários NÃO são sucesso, são falhas esperadas com a implementação atual. Então os testes precisam refletir isso.

Aqui está a versão corrigida dos testes (ajustando esses casos para esperar exceção):

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.formatName', () {
    test('Deve capitalizar uma única palavra', () {
      expect(Validators.formatName('joao'), 'Joao');
    });

    test('Deve capitalizar múltiplas palavras', () {
      expect(Validators.formatName('joao silva'), 'Joao Silva');
    });

    test('Deve manter palavras já capitalizadas', () {
      expect(Validators.formatName('Joao Silva'), 'Joao Silva');
    });

    test('Deve lidar com mistura de maiúsculas e minúsculas', () {
      expect(Validators.formatName('jOaO sIlVa'), 'JOaO SIlVa');
    });

    test('Deve retornar string vazia quando input for vazio', () {
      expect(Validators.formatName(''), '');
    });

    test('Deve lançar erro com múltiplos espaços entre palavras', () {
      expect(
        () => Validators.formatName('joao   silva'),
        throwsA(isA<RangeError>()),
      );
    });

    test('Deve lançar erro com espaços no início e fim', () {
      expect(
        () => Validators.formatName('  joao silva  '),
        throwsA(isA<RangeError>()),
      );
    });

    test('Deve lançar erro com string contendo apenas espaço', () {
      expect(
        () => Validators.formatName(' '),
        throwsA(isA<RangeError>()),
      );
    });

    test('Deve lidar com nomes com caracteres especiais', () {
      expect(Validators.formatName('joão da silva'), 'João Da Silva');
    });

    test('Deve lidar com nomes com hífen', () {
      expect(Validators.formatName('joao-pedro'), 'Joao-pedro');
    });
  });
}
💡 Observação importante

Se o comportamento desejado for não quebrar com espaços extras (o que é o mais comum), então o certo não é mudar o teste — é corrigir a função.

Uma versão mais robusta da função seria:

static String formatName(String name) {
  if (name.trim().isEmpty) return name;

  return name
      .trim()
      .split(RegExp(r'\s+'))
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

Se você optar por corrigir a função, aí sim os testes originais (sem throwsA) fazem mais sentido.

Se quiser, posso te entregar também a versão ideal dos testes considerando essa implementação corrigida.


- **Resultado:** 00:00 +10: All tests passed!_

### Iteração 2
- **Necessária?** _preencher (Sim/Não)_
- _(preencher se necessário)_

### Iteração 3
- **Necessária?** _preencher (Sim/Não)_
- _(preencher se necessário)_
