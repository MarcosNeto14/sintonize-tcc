# UNIT-ZS-05

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-ZS-05 |
| **Função testada** | validateEmail |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de cadastro.dart — _validateEmail) |
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

\
dart static String? validateEmail(String? value) { if (value == null || value.isEmpty) { return 'O e-mail é obrigatório'; } const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; final regex = RegExp(pattern); if (!regex.hasMatch(value)) { return 'E-mail inválido'; } return null; } \
A função faz parte de uma classe chamada Validators no arquivo lib/utils/validators.dart de um projeto Flutter chamado "sintonize".

Requisitos:
- Use a estrutura group() e test() do flutter_test
- Cubra cenários de sucesso e de falha
- Inclua casos de borda
- Os testes devem ser executáveis com `flutter test`

---

## Resposta do LLM
Aqui está um conjunto de testes unitários completos para a função validateEmail, usando o pacote flutter_test. Eles cobrem cenários de sucesso, falha e casos de borda, organizados com group() e test() conforme solicitado.

Crie o arquivo, por exemplo:
test/utils/validators_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateEmail', () {
    // 🔴 Casos de falha

    test('retorna erro quando valor é null', () {
      final result = Validators.validateEmail(null);
      expect(result, 'O e-mail é obrigatório');
    });

    test('retorna erro quando valor é vazio', () {
      final result = Validators.validateEmail('');
      expect(result, 'O e-mail é obrigatório');
    });

    test('retorna erro quando não possui @', () {
      final result = Validators.validateEmail('emailinvalido.com');
      expect(result, 'E-mail inválido');
    });

    test('retorna erro quando não possui domínio', () {
      final result = Validators.validateEmail('teste@');
      expect(result, 'E-mail inválido');
    });

    test('retorna erro quando domínio não tem TLD', () {
      final result = Validators.validateEmail('teste@dominio');
      expect(result, 'E-mail inválido');
    });

    test('retorna erro com caracteres inválidos', () {
      final result = Validators.validateEmail('teste@dominio!.com');
      expect(result, 'E-mail inválido');
    });

    // 🟢 Casos de sucesso

    test('retorna null para e-mail válido simples', () {
      final result = Validators.validateEmail('teste@email.com');
      expect(result, isNull);
    });

    test('retorna null para e-mail com subdomínio', () {
      final result = Validators.validateEmail('user@mail.server.com');
      expect(result, isNull);
    });

    test('retorna null para e-mail com caracteres especiais válidos', () {
      final result = Validators.validateEmail('user.name+tag@domain.co');
      expect(result, isNull);
    });

    // ⚠️ Casos de borda

    test('retorna erro para e-mail com espaço', () {
      final result = Validators.validateEmail('teste @email.com');
      expect(result, 'E-mail inválido');
    });

    test('retorna erro para e-mail com TLD de 1 caractere', () {
      final result = Validators.validateEmail('teste@email.c');
      expect(result, 'E-mail inválido');
    });

    test('retorna null para e-mail com TLD longo', () {
      final result = Validators.validateEmail('teste@email.technology');
      expect(result, isNull);
    });

    test('retorna erro para múltiplos @', () {
      final result = Validators.validateEmail('teste@@email.com');
      expect(result, 'E-mail inválido');
    });

    test('retorna erro para string com apenas espaços', () {
      final result = Validators.validateEmail('   ');
      expect(result, 'E-mail inválido');
    });
  });
}
Observações rápidas

Os testes podem ser executados normalmente com:

flutter test
A estrutura cobre:
Validação de entrada nula/vazia
Formatos inválidos comuns
Formatos válidos variados
Casos extremos (edge cases)

Se quiser, posso expandir com testes parametrizados (forEach) ou usar setUp() para organizar melhor cenários repetitivos.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 14 |
| **Testes passaram** | 14 |
| **Testes falharam** | 0 |


### Saída do terminal
00:02 +14: All tests passed!

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
