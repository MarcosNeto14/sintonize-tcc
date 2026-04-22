# UNIT-ZS-07

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-ZS-07 |
| **Função testada** | validateEmailEdit |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de alterar-dados.dart — _validateEmail) |
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
  static String? validateEmailEdit(String? value) {
    if (value != null && value.isNotEmpty) {
      const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
      if (!RegExp(emailRegex).hasMatch(value)) {
        return 'Formato de e-mail inválido';
      }
    }
    return null;
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
Aqui vai um conjunto completo de testes unitários em Dart usando o pacote flutter_test, cobrindo cenários de sucesso, falha e casos de borda para a função validateEmailEdit.

📁 Exemplo de arquivo

Crie um arquivo como:
test/utils/validators_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailEdit', () {
    // ✅ Cenários de sucesso (retorno null)
    test('Deve retornar null para e-mail válido simples', () {
      final result = Validators.validateEmailEdit('teste@email.com');
      expect(result, isNull);
    });

    test('Deve retornar null para e-mail com subdomínio', () {
      final result = Validators.validateEmailEdit('user@mail.domain.com');
      expect(result, isNull);
    });

    test('Deve retornar null para e-mail com caracteres especiais válidos', () {
      final result = Validators.validateEmailEdit('user.name+tag@domain.co');
      expect(result, isNull);
    });

    test('Deve retornar null quando valor é null', () {
      final result = Validators.validateEmailEdit(null);
      expect(result, isNull);
    });

    test('Deve retornar null quando valor é string vazia', () {
      final result = Validators.validateEmailEdit('');
      expect(result, isNull);
    });

    // ❌ Cenários de falha (retorno com erro)
    test('Deve retornar erro para e-mail sem @', () {
      final result = Validators.validateEmailEdit('emailinvalido.com');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve retornar erro para e-mail sem domínio', () {
      final result = Validators.validateEmailEdit('teste@');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve retornar erro para e-mail sem TLD', () {
      final result = Validators.validateEmailEdit('teste@email');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve retornar erro para e-mail com espaços', () {
      final result = Validators.validateEmailEdit('teste @email.com');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve retornar erro para e-mail com caracteres inválidos', () {
      final result = Validators.validateEmailEdit('teste#email.com');
      expect(result, 'Formato de e-mail inválido');
    });

    // ⚠️ Casos de borda
    test('Deve retornar erro para e-mail com TLD de 1 caractere', () {
      final result = Validators.validateEmailEdit('teste@email.c');
      expect(result, 'Formato de e-mail inválido');
    });

    test('Deve aceitar TLD com 2 caracteres (mínimo válido)', () {
      final result = Validators.validateEmailEdit('teste@email.co');
      expect(result, isNull);
    });

    test('Deve retornar erro para múltiplos @', () {
      final result = Validators.validateEmailEdit('teste@@email.com');
      expect(result, 'Formato de e-mail inválido');
    });
  });
}
✔️ O que está coberto
Entradas válidas (incluindo variações reais de e-mail)
Entradas inválidas comuns
Casos de borda importantes (null, vazio, TLD mínimo, múltiplos @)
Comportamento esperado da regex
▶️ Como rodar

No terminal, na raiz do projeto Flutter:

flutter test

Se quiser, posso adaptar isso pra usar setUp, tearDown ou até gerar testes baseados em tabela (data-driven), que fica bem útil pra QA automatizado 😉

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 13 |
| **Testes passaram** | 13 |
| **Testes falharam** | 0 |


### Saída do terminal
00:02 +13: All tests passed!

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
