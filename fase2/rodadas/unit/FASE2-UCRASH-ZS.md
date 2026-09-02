# FASE2-UCRASH-ZS — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UCRASH-ZS |
| **Bug ID** | U-CRASH |
| **Função/tela alvo** | `capitalize` |
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
  /// Origem: lib/mapa.dart (_capitalize)
  /// Capitaliza a primeira letra E aplica toLowerCase no restante —
  /// ex.: "maRIA silva" → "Maria Silva". Trata palavras vazias internas.
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
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

Resposta completa e verbatim (única mensagem — o modelo identificou o
bug espontaneamente, sem necessidade de prompt de reparo):

```
Claro. Há um detalhe importante: a implementação atual lança RangeError quando encontra uma palavra vazia interna, apesar do comentário dizer que ela trata palavras vazias. Os testes abaixo cobrem tanto o comportamento esperado quanto essa falha da implementação.

Crie, por exemplo, test/utils/validators_test.dart:
```

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.capitalize', () {
    group('Casos de sucesso', () {
      test('deve capitalizar a primeira letra e colocar o restante em minúsculas', () {
        expect(
          Validators.capitalize('maRIA silva'),
          equals('Maria Silva'),
        );
      });

      test('deve capitalizar todas as palavras de um texto', () {
        expect(
          Validators.capitalize('jOÃO DA sILVA'),
          equals('João Da Silva'),
        );
      });

      test('deve preservar uma única palavra corretamente', () {
        expect(
          Validators.capitalize('mARIA'),
          equals('Maria'),
        );
      });

      test('deve retornar o texto vazio quando a entrada for vazia', () {
        expect(
          Validators.capitalize(''),
          equals(''),
        );
      });
    });

    group('Casos de borda', () {
      test('deve aceitar uma palavra com apenas uma letra', () {
        expect(
          Validators.capitalize('a'),
          equals('A'),
        );
      });

      test('deve colocar uma palavra já capitalizada em formato correto', () {
        expect(
          Validators.capitalize('Maria'),
          equals('Maria'),
        );
      });

      test('deve converter uma palavra totalmente em maiúsculas', () {
        expect(
          Validators.capitalize('MARIA'),
          equals('Maria'),
        );
      });

      test('deve tratar corretamente números e caracteres sem letras', () {
        expect(
          Validators.capitalize('123 ABC'),
          equals('123 Abc'),
        );
      });
    });

    group('Casos de falha', () {
      test('deve lançar RangeError quando houver duas palavras separadas por '
          'dois espaços', () {
        expect(
          () => Validators.capitalize('maria  silva'),
          throwsRangeError,
        );
      });

      test('deve lançar RangeError quando houver um espaço no início', () {
        expect(
          () => Validators.capitalize(' maria'),
          throwsRangeError,
        );
      });

      test('deve lançar RangeError quando houver um espaço no final', () {
        expect(
          () => Validators.capitalize('maria '),
          throwsRangeError,
        );
      });

      test('deve lançar RangeError quando houver somente espaços', () {
        expect(
          () => Validators.capitalize('   '),
          throwsRangeError,
        );
      });
    });
  });
}
```

```
Observação importante

Esses testes refletem a implementação fornecida, não o comportamento descrito pelo comentário. O trecho:

word[0]

é o problema: split(' ') transforma espaços consecutivos, ou espaços no início/fim, em strings vazias. Acessar word[0] em uma string vazia gera RangeError.

Se a intenção real é que palavras vazias internas sejam tratadas sem erro, a implementação precisaria ser ajustada. Nesse caso, os testes de falha deveriam ser alterados para esperar o resultado normal, por exemplo:

expect(
  Validators.capitalize('maria silva'),
  equals('Maria Silva'),
);

Assim, flutter test também funcionará como uma verificação de regressão para o comportamento desejado.
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
00:00 +0: loading test/fase2/unit/ucrash_zs_test.dart
00:00 +0: Validators.capitalize Casos de sucesso deve capitalizar a primeira letra e colocar o restante em minúsculas
00:00 +1: Validators.capitalize Casos de sucesso deve capitalizar todas as palavras de um texto
00:00 +2: Validators.capitalize Casos de sucesso deve preservar uma única palavra corretamente
00:00 +3: Validators.capitalize Casos de sucesso deve retornar o texto vazio quando a entrada for vazia
00:00 +4: Validators.capitalize Casos de borda deve aceitar uma palavra com apenas uma letra
00:00 +5: Validators.capitalize Casos de borda deve colocar uma palavra já capitalizada em formato correto
00:00 +6: Validators.capitalize Casos de borda deve converter uma palavra totalmente em maiúsculas
00:00 +7: Validators.capitalize Casos de borda deve tratar corretamente números e caracteres sem letras
00:00 +8: Validators.capitalize Casos de falha deve lançar RangeError quando houver duas palavras separadas por dois espaços
00:00 +9: Validators.capitalize Casos de falha deve lançar RangeError quando houver um espaço no início
00:00 +10: Validators.capitalize Casos de falha deve lançar RangeError quando houver um espaço no final
00:00 +11: Validators.capitalize Casos de falha deve lançar RangeError quando houver somente espaços
00:00 +12: All tests passed!
```

(saída completa, incluindo resolução de dependências, em `fase2/resultados/unit/FASE2-UCRASH-ZS.txt`)

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
| **★ Observações** | Detecção espontânea (sem repair): o modelo notou a divergência entre o comentário ("Trata palavras vazias internas") e o `RangeError` real, explicou a causa (`word[0]` em string vazia) e escreveu os testes já refletindo o comportamento buggy, com alerta de que a implementação provavelmente precisa de correção. |

**Referência de categorias (classificação humana — mesmas da Fase 1):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
