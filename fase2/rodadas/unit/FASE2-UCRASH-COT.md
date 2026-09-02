# FASE2-UCRASH-COT — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UCRASH-COT |
| **Bug ID** | U-CRASH |
| **Função/tela alvo** | `capitalize` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.6 "Luna" (autodeclarado, não verificável — ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-02 |
| **Conversa nova?** | Sim — aba anônima, sem histórico |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable) |

---

## Prompt Enviado

```
Quero que você gere testes unitários em Dart para a função abaixo. Antes de escrever os testes, siga estes passos:

1. **Analise a função:** Descreva em 2-3 frases o que ela faz.
2. **Identifique os cenários:** Liste todos os cenários de teste relevantes, incluindo:
   - Cenários de sucesso (entradas válidas)
   - Cenários de falha (entradas inválidas)
   - Casos de borda (limites, valores extremos, entradas inesperadas)
3. **Escreva os testes:** Para cada cenário identificado, escreva um teste usando flutter_test com group() e test().

Função a testar:

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

A função faz parte da classe Validators em lib/utils/validators.dart de um projeto Flutter chamado "sintonize".
Use `import 'package:sintonize/utils/validators.dart';` nos testes.
```

---

## Resposta do LLM

Resposta completa e verbatim (única mensagem — o modelo identificou o
bug já na etapa de análise, antes mesmo de escrever os testes):

```
1. Análise da função

A função capitalize recebe uma String, divide o texto pelos espaços e, para cada palavra, coloca a primeira letra em maiúscula e converte o restante para minúsculas. Ela também preserva os espaços existentes e, pela implementação atual, assume que cada elemento resultante do split(' ') contém pelo menos um caractere — portanto, espaços consecutivos podem causar erro.

2. Cenários de teste

Cenários de sucesso
- String vazia: deve retornar ''.
- Uma palavra já em minúsculas: "maria" → "Maria".
- Uma palavra em maiúsculas: "MARIA" → "Maria".
- Palavra com capitalização misturada: "maRIA" → "Maria".
- Múltiplas palavras: "maRIA silva" → "Maria Silva".
- Todas as palavras em maiúsculas: "MARIA SILVA" → "Maria Silva".
- Palavras com caracteres acentuados: "joÃO" → "João".
- Uma única letra: "a" → "A".
- Números e caracteres especiais: devem permanecer essencialmente inalterados, exceto pela regra de capitalização quando aplicável.

Cenários de falha / entradas inesperadas
- Espaço entre palavras: funciona normalmente.
- Espaços consecutivos: "maria  silva" gera '' como uma das palavras e provoca RangeError.
- Espaço no início: " maria" também gera uma palavra vazia e provoca RangeError.
- Espaço no final: "maria " provoca RangeError.

Observação importante: como os testes devem refletir o comportamento atual da função, os três últimos casos devem verificar que RangeError é lançado. Eles são especialmente úteis porque o comentário diz que a função "trata palavras vazias internas", mas a implementação atual não trata palavras vazias: word[0] falha quando word == ''.

3. Testes com flutter_test
```

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/utils/validators.dart';

void main() {
  group('Validators.capitalize', () {
    group('cenários de sucesso', () {
      test('deve retornar uma string vazia quando a entrada for vazia', () {
        expect(Validators.capitalize(''), '');
      });

      test('deve capitalizar uma única palavra em minúsculas', () {
        expect(Validators.capitalize('maria'), 'Maria');
      });

      test('deve normalizar uma palavra em maiúsculas', () {
        expect(Validators.capitalize('MARIA'), 'Maria');
      });

      test('deve normalizar uma palavra com capitalização misturada', () {
        expect(Validators.capitalize('maRIA'), 'Maria');
      });

      test('deve capitalizar todas as palavras de um nome', () {
        expect(
          Validators.capitalize('maRIA silva'),
          'Maria Silva',
        );
      });

      test('deve normalizar um nome completamente em maiúsculas', () {
        expect(
          Validators.capitalize('MARIA SILVA'),
          'Maria Silva',
        );
      });

      test('deve preservar e normalizar caracteres acentuados', () {
        expect(
          Validators.capitalize('joÃO da silva'),
          'João Da Silva',
        );
      });

      test('deve capitalizar uma palavra com apenas um caractere', () {
        expect(Validators.capitalize('a'), 'A');
      });

      test('deve preservar números e caracteres especiais', () {
        expect(
          Validators.capitalize('123 abc @TESTE'),
          '123 Abc @teste',
        );
      });
    });

    group('cenários de falha e entradas inesperadas', () {
      test('deve lançar RangeError quando houver espaços consecutivos', () {
        expect(
          () => Validators.capitalize('maria  silva'),
          throwsRangeError,
        );
      });

      test('deve lançar RangeError quando houver espaço no início', () {
        expect(
          () => Validators.capitalize(' maria'),
          throwsRangeError,
        );
      });

      test('deve lançar RangeError quando houver espaço no final', () {
        expect(
          () => Validators.capitalize('maria '),
          throwsRangeError,
        );
      });
    });
  });
}
```

```
Um ponto importante é que não seria correto escrever um teste esperando "Maria Silva" para "maria  silva", apesar do comentário da função sugerir esse comportamento. O código fornecido atualmente acessa word[0] sem verificar se word está vazio, então o teste deve documentar o comportamento real e, se a intenção for corrigir o bug, os testes podem ser ajustados para exigir o comportamento desejado.
```

Nota: nos testes de "sucesso", o modelo incluiu um caso não pedido
explicitamente (`'joÃO da silva'` → `'João Da Silva'`), capitalizando
uma palavra minúscula extra ("da") no meio — comportamento
correto/consistente com a função, mas fora do escopo estrito do
exemplo do comentário original.

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
00:00 +0: loading test/fase2/unit/ucrash_cot_test.dart
00:00 +0: Validators.capitalize cenários de sucesso deve retornar uma string vazia quando a entrada for vazia
00:00 +1: Validators.capitalize cenários de sucesso deve capitalizar uma única palavra em minúsculas
00:00 +2: Validators.capitalize cenários de sucesso deve normalizar uma palavra em maiúsculas
00:00 +3: Validators.capitalize cenários de sucesso deve normalizar uma palavra com capitalização misturada
00:00 +4: Validators.capitalize cenários de sucesso deve capitalizar todas as palavras de um nome
00:00 +5: Validators.capitalize cenários de sucesso deve normalizar um nome completamente em maiúsculas
00:00 +6: Validators.capitalize cenários de sucesso deve preservar e normalizar caracteres acentuados
00:00 +7: Validators.capitalize cenários de sucesso deve capitalizar uma palavra com apenas um caractere
00:00 +8: Validators.capitalize cenários de sucesso deve preservar números e caracteres especiais
00:00 +9: Validators.capitalize cenários de falha e entradas inesperadas deve lançar RangeError quando houver espaços consecutivos
00:00 +10: Validators.capitalize cenários de falha e entradas inesperadas deve lançar RangeError quando houver espaço no início
00:00 +11: Validators.capitalize cenários de falha e entradas inesperadas deve lançar RangeError quando houver espaço no final
00:00 +12: All tests passed!
```

(saída completa, incluindo resolução de dependências, em `fase2/resultados/unit/FASE2-UCRASH-COT.txt`)

---

## Iterative Repair Loop

Não foi necessário — todos os testes passaram na primeira execução.

---

## ★ Análise de Autoclassificação (preencher após a rodada)

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | Bug real exposto — declarada já na etapa de análise (passo 1 do raciocínio guiado), antes mesmo de identificar cenários ou escrever testes |
| **★ Classificação humana (auditoria)** | Bug real exposto |
| **★ Concordância** | N/A (repair não foi necessário) — mas a autoclassificação concorda com a classificação humana |
| **★ Observações** | Das três estratégias em U-CRASH até agora, CoT foi a que detectou o bug mais cedo no processo — já na fase 1 de análise, antes de sequer listar os cenários — e, diferente de FS, não deixou nenhuma lacuna entre o alerta verbal e os testes gerados: todos os testes de "falha" batem com o comportamento real. |

**Referência de categorias (classificação humana — mesmas da Fase 1):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
