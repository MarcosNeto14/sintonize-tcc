# UNIT-COT-02

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | UNIT-COT-02 |
| **Função testada** | validateSenha |
| **Arquivo de origem** | lib/utils/validators.dart (extraída de login.dart — validator inline do TextFormField de senha) |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.6 |
| **Data de acesso** | _preencher_ |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 |

---

## Prompt Enviado
Quero que você gere testes unitários em Dart para a função abaixo. Antes de escrever os testes, siga estes passos:

1. **Analise a função:** Descreva em 2-3 frases o que ela faz.
2. **Identifique os cenários:** Liste todos os cenários de teste relevantes, incluindo:
   - Cenários de sucesso (entradas válidas)
   - Cenários de falha (entradas inválidas)
   - Casos de borda (limites, valores extremos, entradas inesperadas)
3. **Escreva os testes:** Para cada cenário identificado, escreva um teste usando flutter_test com group() e test().

Função a testar:

\```dart
  static String? validateSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  } 
\```

A função faz parte da classe Validators em lib/utils/validators.dart de um projeto Flutter chamado "sintonize".
Use `import 'package:sintonize/utils/validators.dart';` nos testes.

---

## Resposta do LLM
1. Análise da função

A função validateSenha valida uma senha fornecida pelo usuário. Ela retorna uma mensagem de erro caso a senha seja nula, vazia ou tenha menos de 6 caracteres; caso contrário, retorna null, indicando que a senha é válida.

2. Cenários de teste

✅ Cenários de sucesso (entradas válidas)

Senha com exatamente 6 caracteres
Senha com mais de 6 caracteres

❌ Cenários de falha (entradas inválidas)

Senha null
Senha vazia ("")
Senha com menos de 6 caracteres (ex: 1 a 5 caracteres)

⚠️ Casos de borda

Senha com exatamente 6 caracteres (limite inferior válido)
Senha com 5 caracteres (limite inferior inválido)
Senha com espaços (ex: " " → 6 espaços, ainda é válida pela função atual)
3. Testes unitários em Dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateSenha', () {
    
    // ❌ Cenários de falha
    test('deve retornar erro quando senha for null', () {
      final result = Validators.validateSenha(null);
      expect(result, 'Por favor, insira sua senha');
    });

    test('deve retornar erro quando senha for vazia', () {
      final result = Validators.validateSenha('');
      expect(result, 'Por favor, insira sua senha');
    });

    test('deve retornar erro quando senha tiver menos de 6 caracteres', () {
      final result = Validators.validateSenha('12345');
      expect(result, 'A senha deve ter pelo menos 6 caracteres');
    });

    test('deve retornar erro para senha com 1 caractere', () {
      final result = Validators.validateSenha('1');
      expect(result, 'A senha deve ter pelo menos 6 caracteres');
    });

    // ⚠️ Casos de borda
    test('deve aceitar senha com exatamente 6 caracteres', () {
      final result = Validators.validateSenha('123456');
      expect(result, null);
    });

    test('deve rejeitar senha com 5 caracteres (limite inferior inválido)', () {
      final result = Validators.validateSenha('12345');
      expect(result, 'A senha deve ter pelo menos 6 caracteres');
    });

    test('deve aceitar senha com 6 espaços (regra atual permite)', () {
      final result = Validators.validateSenha('      ');
      expect(result, null);
    });

    // ✅ Cenários de sucesso
    test('deve aceitar senha com mais de 6 caracteres', () {
      final result = Validators.validateSenha('1234567');
      expect(result, null);
    });

    test('deve aceitar senha longa', () {
      final result = Validators.validateSenha('minhaSenhaSuperSegura123');
      expect(result, null);
    });
  });
}

Se quiser, posso também sugerir melhorias na função (por exemplo, impedir senhas só com espaços ou exigir caracteres especiais).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 9 |
| **Testes passaram** | 9 |
| **Testes falharam** | 0 |

### Saída do terminal
00:03 +9: All tests passed!  

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
