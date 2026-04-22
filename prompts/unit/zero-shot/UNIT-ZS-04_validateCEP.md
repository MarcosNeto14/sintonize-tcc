# UNIT-ZS-04

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-ZS-04 |
| **Função testada** | validateCEP |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de cadastro.dart — _validateCEP) |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.6 |
| **Data de acesso** | 21/04/2026 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 |

---

## Prompt Enviado
Gere testes unitários em Dart usando o pacote flutter_test para a seguinte função: \
dart
  static String? validateCEP(String? value) {
    if (value == null || value.isEmpty) {
      return 'O CEP é obrigatório';
    }
    if (value.length != 9 || !RegExp(r'^\d{5}-\d{3}$').hasMatch(value)) {
      return 'CEP inválido. Formato correto: XXXXX-XXX';
    }
    return null;
  } 
\
A função faz parte de uma classe chamada Validators no arquivo lib/utils/validators.dart de um projeto Flutter chamado "sintonize". Requisitos: - Use a estrutura group() e test() do flutter_test - Cubra cenários de sucesso e de falha - Inclua casos de borda - Os testes devem ser executáveis com flutter test

---

## Resposta do LLM
Aqui está um conjunto completo de testes unitários usando flutter_test para a função validateCEP. Eles cobrem casos de sucesso, falhas e bordas, organizados com group() e test() conforme solicitado.

Crie o arquivo de teste, por exemplo:
test/utils/validators_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateCEP', () {
    // 🔴 Casos de falha - valor nulo ou vazio
    test('deve retornar erro quando valor for null', () {
      final result = Validators.validateCEP(null);
      expect(result, 'O CEP é obrigatório');
    });

    test('deve retornar erro quando valor for vazio', () {
      final result = Validators.validateCEP('');
      expect(result, 'O CEP é obrigatório');
    });

    // 🔴 Casos de falha - formato inválido
    test('deve retornar erro quando CEP não tem hífen', () {
      final result = Validators.validateCEP('12345678');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    test('deve retornar erro quando CEP tem letras', () {
      final result = Validators.validateCEP('1234A-678');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    test('deve retornar erro quando CEP tem menos de 9 caracteres', () {
      final result = Validators.validateCEP('1234-678');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    test('deve retornar erro quando CEP tem mais de 9 caracteres', () {
      final result = Validators.validateCEP('123456-7890');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    test('deve retornar erro quando hífen está na posição errada', () {
      final result = Validators.validateCEP('123-45678');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    // 🟡 Casos de borda
    test('deve falhar com espaços extras', () {
      final result = Validators.validateCEP(' 12345-678 ');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    test('deve falhar com caracteres especiais', () {
      final result = Validators.validateCEP('12345@678');
      expect(result, 'CEP inválido. Formato correto: XXXXX-XXX');
    });

    // 🟢 Caso de sucesso
    test('deve retornar null para CEP válido', () {
      final result = Validators.validateCEP('12345-678');
      expect(result, isNull);
    });
  });
}
Como executar

No terminal do projeto Flutter:

flutter test
Observações úteis
Os testes cobrem:
Entradas nulas e vazias
Formatos inválidos (sem hífen, com letras, tamanho errado)
Casos de borda (espaços, caracteres especiais)
Caso válido esperado
Se você quiser melhorar a função futuramente (por exemplo, fazer trim() antes da validação), alguns testes de borda podem mudar de comportamento — o que é ótimo para detectar regressões.

Se quiser, posso também gerar testes parametrizados (testWidgets ou parameterized tests) ou sugerir melhorias na função.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 10 |
| **Testes passaram** | 10 |
| **Testes falharam** | 0 |

### Saída do terminal

00:03 +10: All tests passed!

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
