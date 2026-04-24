# UNIT-FS-04

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-FS-04 |
| **Função testada** | validateCEP |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de cadastro.dart — _validateCEP) |
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
A função faz parte da classe Validators em lib/utils/validators.dart de um projeto Flutter chamado "sintonize".

---

## Resposta do LLM
Aqui estão os testes unitários para a função validateCEP, seguindo o mesmo padrão dos exemplos fornecidos:

import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('validateCEP', () {
    test('deve retornar mensagem de erro quando valor é null', () {
      expect(Validators.validateCEP(null), isNotNull);
    });

    test('deve retornar mensagem de erro quando valor é vazio', () {
      expect(Validators.validateCEP(''), isNotNull);
    });

    test('deve aceitar CEP no formato válido XXXXX-XXX', () {
      expect(Validators.validateCEP('50740-540'), isNull);
    });

    test('deve rejeitar CEP sem hífen', () {
      expect(Validators.validateCEP('50740540'), isNotNull);
    });

    test('deve rejeitar CEP com letras', () {
      expect(Validators.validateCEP('50A40-540'), isNotNull);
    });

    test('deve rejeitar CEP com tamanho incorreto', () {
      expect(Validators.validateCEP('50740-54'), isNotNull);
    });

    test('deve rejeitar CEP com formato incorreto', () {
      expect(Validators.validateCEP('5074-0540'), isNotNull);
    });
  });
}

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim   |
| **Testes gerados** | 7 |
| **Testes passaram** | 7 |
| **Testes falharam** | 0 |

### Saída do terminal
00:04 +7: All tests passed!

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
