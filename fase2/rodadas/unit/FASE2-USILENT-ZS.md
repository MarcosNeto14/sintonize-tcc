# FASE2-USILENT-ZS — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-USILENT-ZS |
| **Bug ID** | U-SILENT |
| **Função/tela alvo** | `validateSenha` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.6 "Luna" (autodeclarado, não verificável — ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-02 |
| **Conversa nova?** | Sim — aba anônima, sem histórico |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable) |

---

## Prompt Enviado

```
Gere testes unitários em Dart usando o pacote flutter_test para a seguinte função:

```dart
  /// Origem: lib/login.dart (validator inline do TextFormField de senha)
  /// Mínimo de 6 caracteres.
  static String? validateSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }
    if (value.length < 7) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }
```

A função faz parte de uma classe chamada Validators no arquivo lib/utils/validators.dart de um projeto Flutter chamado "sintonize".

Requisitos:
- Use a estrutura group() e test() do flutter_test
- Cubra cenários de sucesso e de falha
- Inclua casos de borda
- Os testes devem ser executáveis com `flutter test`
```

---

## Resposta do LLM

Resposta completa e verbatim (única mensagem — assim como em
FASE2-UCRASH-ZS, o modelo identificou a inconsistência espontaneamente,
sem prompt de reparo):

```
Abaixo está um arquivo de teste completo, por exemplo em test/utils/validators_test.dart. Ele cobre null, vazio, comprimentos abaixo do limite, exatamente no limite, acima do limite e caracteres Unicode.
```

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.validateSenha', () {
    group('falhas', () {
      test('deve rejeitar senha nula', () {
        expect(
          Validators.validateSenha(null),
          equals('Por favor, insira sua senha'),
        );
      });

      test('deve rejeitar senha vazia', () {
        expect(
          Validators.validateSenha(''),
          equals('Por favor, insira sua senha'),
        );
      });

      test('deve rejeitar senha com 1 caractere', () {
        expect(
          Validators.validateSenha('a'),
          equals('A senha deve ter pelo menos 6 caracteres'),
        );
      });

      test('deve rejeitar senha com 5 caracteres', () {
        expect(
          Validators.validateSenha('abcde'),
          equals('A senha deve ter pelo menos 6 caracteres'),
        );
      });

      test('deve rejeitar senha com 6 caracteres', () {
        expect(
          Validators.validateSenha('abcdef'),
          equals('A senha deve ter pelo menos 6 caracteres'),
        );
      });
    });

    group('sucesso', () {
      test('deve aceitar senha com 7 caracteres', () {
        expect(
          Validators.validateSenha('abcdefg'),
          isNull,
        );
      });

      test('deve aceitar senha com mais de 7 caracteres', () {
        expect(
          Validators.validateSenha('senha123'),
          isNull,
        );
      });

      test('deve aceitar senha contendo espaços', () {
        expect(
          Validators.validateSenha('abc def'),
          isNull,
        );
      });

      test('deve aceitar senha contendo caracteres especiais', () {
        expect(
          Validators.validateSenha('a@#1234'),
          isNull,
        );
      });
    });

    group('casos de borda', () {
      test('deve considerar exatamente 6 caracteres como inválida', () {
        const senha = '123456';

        expect(senha.length, equals(6));
        expect(
          Validators.validateSenha(senha),
          equals('A senha deve ter pelo menos 6 caracteres'),
        );
      });

      test('deve considerar exatamente 7 caracteres como válida', () {
        const senha = '1234567';

        expect(senha.length, equals(7));
        expect(
          Validators.validateSenha(senha),
          isNull,
        );
      });

      test('deve aceitar senha com caracteres Unicode', () {
        expect(
          Validators.validateSenha('áéíóúçã123'),
          isNull,
        );
      });
    });
  });
}
```

```
Observação importante

Há uma inconsistência entre o comentário e a implementação: o comentário diz "Mínimo de 6 caracteres", mas o código usa:

if (value.length < 7)

Portanto, 6 caracteres são rejeitados e 7 são necessários. Os testes acima refletem o comportamento atual da função, não o comentário.

Se a regra correta for realmente "mínimo de 6", a implementação deveria ser:

if (value.length < 6) {
  return 'A senha deve ter pelo menos 6 caracteres';
}

Nesse caso, o teste de 6 caracteres deverá esperar isNull, e o de 5 caracteres continuará esperando a mensagem de erro.
```

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 12 |
| **Testes passaram (1ª execução)** | 12 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (não necessário) |
| **Testes falharam (pós-repair)** | — (não necessário) |

### Saída do terminal

```
00:00 +0: loading test/fase2/unit/usilent_zs_test.dart
00:00 +0: Validators.validateSenha falhas deve rejeitar senha nula
00:00 +1: Validators.validateSenha falhas deve rejeitar senha vazia
00:00 +2: Validators.validateSenha falhas deve rejeitar senha com 1 caractere
00:00 +3: Validators.validateSenha falhas deve rejeitar senha com 5 caracteres
00:00 +4: Validators.validateSenha falhas deve rejeitar senha com 6 caracteres
00:00 +5: Validators.validateSenha sucesso deve aceitar senha com 7 caracteres
00:00 +6: Validators.validateSenha sucesso deve aceitar senha com mais de 7 caracteres
00:00 +7: Validators.validateSenha sucesso deve aceitar senha contendo espaços
00:00 +8: Validators.validateSenha sucesso deve aceitar senha contendo caracteres especiais
00:00 +9: Validators.validateSenha casos de borda deve considerar exatamente 6 caracteres como inválida
00:00 +10: Validators.validateSenha casos de borda deve considerar exatamente 7 caracteres como válida
00:00 +11: Validators.validateSenha casos de borda deve aceitar senha com caracteres Unicode
00:00 +12: All tests passed!
```

(saída completa, incluindo resolução de dependências, em `fase2/resultados/unit/FASE2-USILENT-ZS.txt`)

---

## Iterative Repair Loop

Não foi necessário — todos os testes passaram na primeira execução.

---

## ★ Análise de Autoclassificação (preencher após a rodada)

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | Bug real exposto — declarada espontaneamente na resposta inicial, sem que o prompt de reparo tenha sido necessário |
| **★ Classificação humana (auditoria)** | Bug real exposto |
| **★ Concordância** | N/A (repair não foi necessário) — mas a autoclassificação (B) declarada na resposta inicial concorda com a classificação humana |
| **★ Observações** | Detecção espontânea (sem repair): diferente de U-CRASH, a pista aqui foi textual — o modelo citou literalmente a discrepância entre o comentário ("Mínimo de 6") e o código (`< 7`), o cenário que motivou manter esse comentário verbatim no prompt (ver `fase2/propostas_bugs_fase2.md`). |

**Referência de categorias (classificação humana — mesmas da Fase 1):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
