# UNIT-FS-01

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-FS-01 |
| **Função testada** | validateNome |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de cadastro.dart — validator inline do campo Nome) |
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
Gere testes unitários em Dart usando o pacote flutter_test para a função abaixo. Antes, veja dois exemplos de testes bem escritos para funções similares: **Exemplo 1 — teste de validação de campo obrigatório:** \
dart
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
\
**Exemplo 2 — teste de validação com regex:** \
dart
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
\
Agora, gere testes para esta função, seguindo o mesmo padrão dos exemplos: \
dart
  static String? validateNome(String? value) {
    if (value == null || value.isEmpty) {
      return 'O nome é obrigatório';
    }
    final hasInvalidCharacters = RegExp(r'[^a-zA-ZÀ-ÿ\s]').hasMatch(value);
    if (hasInvalidCharacters) {
      return 'O nome não pode conter números ou caracteres especiais';
    }
    return null;
  } 
\
A função faz parte da classe Validators em lib/utils/validators.dart de um projeto Flutter chamado "sintonize".

---

## Resposta do LLM
Aqui estão os testes unitários para a função validateNome, seguindo exatamente o padrão dos exemplos que você forneceu:

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateNome', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateNome(null), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateNome(''), isNotNull);
    });

    test('deve retornar mensagem de erro quando contém números', () {
      expect(Validators.validateNome('Marcos123'), isNotNull);
    });

    test('deve retornar mensagem de erro quando contém caracteres especiais', () {
      expect(Validators.validateNome('Marcos@'), isNotNull);
    });

    test('deve aceitar nome com letras e espaços', () {
      expect(Validators.validateNome('Marcos Neto'), isNull);
    });

    test('deve aceitar nome com acentuação', () {
      expect(Validators.validateNome('José Álvaro'), isNull);
    });
  });
}

Se quiser, posso evoluir isso para cobrir edge cases mais chatos (tipo espaços extras, nomes compostos estranhos, etc.).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 6 |
| **Testes passaram** | 6 |
| **Testes falharam** | 0 |

### Saída do terminal
00:13 +6: All tests passed!            

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
