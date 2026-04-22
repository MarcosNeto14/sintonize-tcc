# UNIT-ZS-02

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-ZS-02 |
| **Função testada** | validateSenha |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de login.dart — validator inline do TextFormField de senha) |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.6 |
| **Data de acesso** | 20/04/2026 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 |

---

## Prompt Enviado
Gere testes unitários em Dart usando o pacote flutter_test para a seguinte função: \
dart
  static String? validateSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  } 
\
A função faz parte de uma classe chamada Validators no arquivo lib/utils/validators.dart de um projeto Flutter chamado "sintonize". Requisitos: - Use a estrutura group() e test() do flutter_test - Cubra cenários de sucesso e de falha - Inclua casos de borda - Os testes devem ser executáveis com flutter test

---

## Resposta do LLM
Aqui está um conjunto de testes unitários em Dart usando o pacote flutter_test, cobrindo cenários de sucesso, falha e casos de borda para a função validateSenha.

Crie um arquivo de teste, por exemplo:

test/utils/validators_test.dart
Código completo dos testes:
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateSenha', () {
    test('deve retornar erro quando valor for null', () {
      final result = Validators.validateSenha(null);

      expect(result, 'Por favor, insira sua senha');
    });

    test('deve retornar erro quando valor for vazio', () {
      final result = Validators.validateSenha('');

      expect(result, 'Por favor, insira sua senha');
    });

    test('deve retornar erro quando senha tiver menos de 6 caracteres', () {
      final result = Validators.validateSenha('12345');

      expect(result, 'A senha deve ter pelo menos 6 caracteres');
    });

    test('deve aceitar senha com exatamente 6 caracteres (caso de borda)', () {
      final result = Validators.validateSenha('123456');

      expect(result, isNull);
    });

    test('deve aceitar senha com mais de 6 caracteres', () {
      final result = Validators.validateSenha('1234567');

      expect(result, isNull);
    });

    test('deve aceitar senha com caracteres especiais', () {
      final result = Validators.validateSenha('abc@123');

      expect(result, isNull);
    });

    test('deve tratar espaços como caracteres válidos', () {
      final result = Validators.validateSenha('123 56');

      expect(result, isNull);
    });
  });
}
O que está sendo coberto
❌ Falhas:
null
string vazia
menos de 6 caracteres
✅ Sucesso:
exatamente 6 caracteres (borda)
mais de 6 caracteres
caracteres especiais
espaços
Como executar

No terminal do projeto Flutter:

flutter test

Se quiser, posso também sugerir melhorias na função (ex: exigir números, letras maiúsculas, etc.) ou expandir os testes para validações mais robustas.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 7 |
| **Testes passaram** | 7 |
| **Testes falharam** | 0 |

### Saída do terminal

00:02 +7: All tests passed!

---

## Iterative Repair Loop

### Iteração 1

- **Necessária?** _preencher (Sim/Não)_
- _(preencher se necessário)_

### Iteração 2

- **Necessária?** _preencher (Sim/Não)_
- _(preencher se necessário)_

### Iteração 3

- **Necessária?** _preencher (Sim/Não)_
- _(preencher se necessário)_
