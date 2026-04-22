# UNIT-ZS-06

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-ZS-06 |
| **Função testada** | validateEmailLogin |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de login.dart — validator inline do TextFormField de email) |
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
static String? validateEmailLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu e-mail';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Por favor, insira um e-mail válido';
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
Aqui está um conjunto completo de testes unitários em Dart usando flutter_test, cobrindo cenários de sucesso, falha e casos de borda para a função validateEmailLogin.

Crie um arquivo, por exemplo:
test/utils/validators_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmailLogin', () {
    test('retorna erro quando o valor é null', () {
      final result = Validators.validateEmailLogin(null);

      expect(result, 'Por favor, insira seu e-mail');
    });

    test('retorna erro quando o valor é vazio', () {
      final result = Validators.validateEmailLogin('');

      expect(result, 'Por favor, insira seu e-mail');
    });

    test('retorna erro quando o valor contém apenas espaços', () {
      final result = Validators.validateEmailLogin('   ');

      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('retorna erro para e-mail sem @', () {
      final result = Validators.validateEmailLogin('usuarioemail.com');

      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('retorna erro para e-mail sem domínio', () {
      final result = Validators.validateEmailLogin('usuario@');

      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('retorna erro para e-mail sem ponto no domínio', () {
      final result = Validators.validateEmailLogin('usuario@dominio');

      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('retorna erro para formato inválido com múltiplos @', () {
      final result = Validators.validateEmailLogin('user@@dominio.com');

      expect(result, 'Por favor, insira um e-mail válido');
    });

    test('retorna null para e-mail válido simples', () {
      final result = Validators.validateEmailLogin('teste@email.com');

      expect(result, isNull);
    });

    test('retorna null para e-mail com subdomínio', () {
      final result =
          Validators.validateEmailLogin('usuario@mail.dominio.com');

      expect(result, isNull);
    });

    test('retorna null para e-mail com números e caracteres válidos', () {
      final result =
          Validators.validateEmailLogin('user123.teste@dominio.co');

      expect(result, isNull);
    });

    test('retorna null para e-mail com caracteres especiais válidos', () {
      final result =
          Validators.validateEmailLogin('user.name+tag@domain.com');

      expect(result, isNull);
    });
  });
}
Como executar

No terminal do projeto Flutter:

flutter test

Se quiser, posso também adaptar os testes para incluir mocks, cobertura com coverage ou integrar com CI.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 11 |
| **Testes passaram** | 11 |
| **Testes falharam** | 0 |

### Saída do terminal
00:02 +11: All tests passed!

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
