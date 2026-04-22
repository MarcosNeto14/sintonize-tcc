# Templates de Prompt — Protocolo Experimental

**Projeto:** Sintonize (Flutter + Firebase)
**Objetivo:** Referência rápida dos prompts para cada estratégia de engenharia de prompt usada no experimento.

**Instruções de uso:**
1. Copie o template da estratégia desejada
2. Substitua `[COLAR O CÓDIGO DA FUNÇÃO AQUI]` pelo código da função-alvo (de `lib/utils/validators.dart`)
3. Cole no ChatGPT em uma **conversa nova**
4. Documente tudo usando o template de `Template_Documentacao_Rodada.md`

---

## Estratégia 1 — ZERO-SHOT

```
Gere testes unitários em Dart usando o pacote flutter_test para a seguinte função:

\```dart
[COLAR O CÓDIGO DA FUNÇÃO AQUI]
\```

A função faz parte de uma classe chamada Validators no arquivo lib/utils/validators.dart de um projeto Flutter chamado "sintonize".

Requisitos:
- Use a estrutura group() e test() do flutter_test
- Cubra cenários de sucesso e de falha
- Inclua casos de borda
- Os testes devem ser executáveis com `flutter test`
```

---

## Estratégia 2 — FEW-SHOT

```
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
```

---

## Estratégia 3 — CHAIN-OF-THOUGHT (CoT)

```
Quero que você gere testes unitários em Dart para a função abaixo. Antes de escrever os testes, siga estes passos:

1. **Analise a função:** Descreva em 2-3 frases o que ela faz.
2. **Identifique os cenários:** Liste todos os cenários de teste relevantes, incluindo:
   - Cenários de sucesso (entradas válidas)
   - Cenários de falha (entradas inválidas)
   - Casos de borda (limites, valores extremos, entradas inesperadas)
3. **Escreva os testes:** Para cada cenário identificado, escreva um teste usando flutter_test com group() e test().

Função a testar:

\```dart
[COLAR O CÓDIGO DA FUNÇÃO AQUI]
\```

A função faz parte da classe Validators em lib/utils/validators.dart de um projeto Flutter chamado "sintonize".
Use `import 'package:sintonize/utils/validators.dart';` nos testes.
```

---

## Ordem de execução das funções

| # | Função | Complexidade |
|---|---|---|
| 01 | validateNome | Baixa |
| 02 | validateSenha | Baixa |
| 03 | validateNumero | Baixa |
| 04 | validateCEP | Média |
| 05 | validateEmail | Média |
| 06 | validateEmailLogin | Média |
| 07 | validateEmailEdit | Média |
| 08 | formatName | Média |
| 09 | capitalize | Média |
| 10 | validateDate | Alta |

**Total de rodadas:** 10 funções × 3 estratégias = 30 rodadas para o nível unitário.

---

## Prompt para Iterative Repair Loop

Quando um teste falhar, use este template na **mesma conversa** do ChatGPT:

```
O teste falhou com o seguinte erro:

\```
[COLAR A SAÍDA DE ERRO DO TERMINAL AQUI]
\```

Corrija o teste para que ele compile e passe corretamente.
```

**Limite:** máximo 3 iterações de reparo por rodada.
