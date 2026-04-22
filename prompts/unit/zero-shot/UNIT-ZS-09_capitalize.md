# UNIT-ZS-09

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-ZS-09 |
| **Função testada** | capitalize |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de mapa.dart — _capitalize) |
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
Gere testes unitários em Dart usando o pacote flutter_test para a seguinte função: \
dart
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
} 
\
A função faz parte de uma classe chamada Validators no arquivo lib/utils/validators.dart de um projeto Flutter chamado "sintonize". Requisitos: - Use a estrutura group() e test() do flutter_test - Cubra cenários de sucesso e de falha - Inclua casos de borda - Os testes devem ser executáveis com flutter test

---

## Resposta do LLM
Aqui está um conjunto de testes unitários em Dart usando flutter_test que cobre cenários de sucesso, falha e casos de borda para a função capitalize.

Crie o arquivo, por exemplo:
test/utils/validators_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.capitalize', () {
    test('deve capitalizar uma única palavra', () {
      final result = Validators.capitalize('hello');
      expect(result, 'Hello');
    });

    test('deve capitalizar múltiplas palavras', () {
      final result = Validators.capitalize('hello world');
      expect(result, 'Hello World');
    });

    test('deve transformar letras maiúsculas em minúsculas (exceto a primeira)', () {
      final result = Validators.capitalize('hELLo wORLD');
      expect(result, 'Hello World');
    });

    test('deve retornar string vazia quando input for vazio', () {
      final result = Validators.capitalize('');
      expect(result, '');
    });

    test('deve lidar com espaços extras entre palavras', () {
      final result = Validators.capitalize('hello   world');
      expect(result, 'Hello   World');
    });

    test('deve lidar com espaços no início e fim', () {
      final result = Validators.capitalize('  hello world  ');
      expect(result, '  Hello World  ');
    });

    test('deve lidar com palavras de um único caractere', () {
      final result = Validators.capitalize('a b c');
      expect(result, 'A B C');
    });

    test('deve manter números e caracteres especiais', () {
      final result = Validators.capitalize('123 abc! @home');
      expect(result, '123 Abc! @home');
    });

    test('deve lidar com palavras vazias entre espaços', () {
      final result = Validators.capitalize('hello  world');
      expect(result, 'Hello  World');
    });

    test('não deve lançar exceção com string contendo apenas espaços', () {
      final result = Validators.capitalize('     ');
      expect(result, '     ');
    });
  });
}
O que está coberto
✅ Casos comuns (uma palavra, múltiplas palavras)
✅ Normalização de maiúsculas/minúsculas
✅ String vazia
✅ Espaços extras (internos, início e fim)
✅ Caracteres especiais e números
✅ Casos de borda (somente espaços, palavras de 1 letra)
Como rodar

No terminal do projeto Flutter:

flutter test

Se quiser, posso adicionar testes com dados parametrizados (forEach) ou separar em mais grupos (ex: “edge cases”, “formatting”).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 10 |
| **Testes passaram** | 10 |
| **Testes falharam** | 0 |


### Saída do terminal
00:01 +10: All tests passed!

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
