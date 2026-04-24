# UNIT-FS-02

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-FS-02 |
| **Função testada** | validateSenha |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de login.dart — validator inline do TextFormField de senha) |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.6 |
| **Data de acesso** | _preencher_ |
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
[COLAR O CÓDIGO DA FUNÇÃO AQUI]
\```

A função faz parte da classe Validators em lib/utils/validators.dart de um projeto Flutter chamado "sintonize".

## Resposta do LLM
Aqui estão os testes unitários seguindo o mesmo padrão dos exemplos que você mostrou:

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateSenha', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateSenha(null), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateSenha(''), isNotNull);
    });

    test('deve retornar mensagem de erro quando senha tem menos de 6 caracteres', () {
      expect(Validators.validateSenha('12345'), isNotNull);
    });

    test('deve retornar null quando senha tem 6 caracteres', () {
      expect(Validators.validateSenha('123456'), isNull);
    });

    test('deve retornar null quando senha tem mais de 6 caracteres', () {
      expect(Validators.validateSenha('123456789'), isNull);
    });
  });
}

Se quiser deixar os testes ainda mais rigorosos, dá pra validar também as mensagens específicas retornadas (em vez de só isNull / isNotNull). Quer que eu gere essa versão também?

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 5 |
| **Testes passaram** | 5 |
| **Testes falharam** | 0 |


### Saída do terminal
00:26 +5: All tests passed!    

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
