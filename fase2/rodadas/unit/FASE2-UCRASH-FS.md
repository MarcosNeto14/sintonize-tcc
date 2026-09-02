# FASE2-UCRASH-FS — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UCRASH-FS |
| **Bug ID** | U-CRASH |
| **Função/tela alvo** | `capitalize` |
| **Arquivo(s) de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.6 "Luna" (autodeclarado, não verificável — ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-02 |
| **Conversa nova?** | Sim — aba anônima, sem histórico |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable) |

---

## Prompt Enviado

```
Gere testes unitários em Dart usando o pacote flutter_test para a função abaixo.

Antes, veja dois exemplos de testes bem escritos para funções similares:

**Exemplo 1 — teste de validação de campo obrigatório:**
```dart
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
```

**Exemplo 2 — teste de validação com regex:**
```dart
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
```

Agora, gere testes para esta função, seguindo o mesmo padrão dos exemplos:

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
```

---

## Resposta do LLM

Resposta completa e verbatim (mensagem inicial, antes do reparo):

```
Claro. Seguindo o padrão dos exemplos, eu cobrira os casos de string vazia, capitalização simples, múltiplas palavras, letras em maiúsculas/minúsculas e palavras vazias internas.
```

```dart
group('capitalize', () {
  test('deve retornar string vazia quando valor é vazio', () {
    expect(Validators.capitalize(''), '');
  });

  test('deve capitalizar a primeira letra de uma palavra', () {
    expect(Validators.capitalize('maria'), 'Maria');
  });

  test('deve converter o restante da palavra para letras minúsculas', () {
    expect(Validators.capitalize('MARIA'), 'Maria');
  });

  test('deve capitalizar cada palavra de um texto', () {
    expect(Validators.capitalize('maria silva'), 'Maria Silva');
  });

  test('deve corrigir maiúsculas e minúsculas em múltiplas palavras', () {
    expect(Validators.capitalize('maRIA silVA'), 'Maria Silva');
  });

  test('deve preservar espaços internos vazios', () {
    expect(Validators.capitalize('maria  silva'), 'Maria  Silva');
  });
});
```

```
Observação: há um detalhe importante na implementação atual: uma string contendo apenas espaços, como ' ', fará word[0] funcionar para cada palavra porque cada elemento resultante do split(' ') é '' entre os espaços — e isso pode causar RangeError. O comentário diz que a função "trata palavras vazias internas", mas a implementação mostrada não trata efetivamente palavras vazias.

Se essa situação fizer parte do comportamento esperado, vale adicionar um teste para expor o problema antes de corrigir a função.
```

Diferente de FASE2-UCRASH-ZS, aqui o modelo **verbalizou** o risco mas
**não evitou** escrevê-lo no teste gerado — o último caso
(`'maria  silva'` → `'Maria  Silva'`, espaço duplo) de fato aciona o
bug, gerando falha na 1ª execução.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 6 |
| **Testes passaram (1ª execução)** | 5 |
| **Testes falharam (1ª execução)** | 1 |
| **Testes passaram (pós-repair)** | 5 (inalterado) |
| **Testes falharam (pós-repair)** | 1 (inalterado, intencional) |

### Saída do terminal (1ª execução)

```
00:00 +0: loading test/fase2/unit/ucrash_fs_test.dart
00:00 +0: capitalize deve retornar string vazia quando valor é vazio
00:00 +1: capitalize deve capitalizar a primeira letra de uma palavra
00:00 +2: capitalize deve converter o restante da palavra para letras minúsculas
00:00 +3: capitalize deve capitalizar cada palavra de um texto
00:00 +4: capitalize deve corrigir maiúsculas e minúsculas em múltiplas palavras
00:00 +5: capitalize deve preservar espaços internos vazios
00:00 +5 -1: capitalize deve preservar espaços internos vazios [E]
  RangeError (index): Invalid value: Valid value range is empty: 0
  dart:core                                       _StringBase.[]
  package:sintonize/utils/validators.dart 162:18  Validators.capitalize.<fn>
  dart:_internal                                  ListIterable.join
  package:sintonize/utils/validators.dart 163:8   Validators.capitalize
  test\fase2\unit\ucrash_fs_test.dart 27:25       main.<fn>.<fn>
  
00:00 +5 -1: Some tests failed.
```

(saída completa, incluindo resolução de dependências, em
`fase2/resultados/unit/FASE2-UCRASH-FS_iter0.txt`)

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** `RangeError` ao capitalizar `'maria  silva'` (espaço duplo) — `split(' ')` produz uma palavra vazia entre os espaços, e `word[0]` falha nela.
- **Prompt de reparo enviado:** conforme seção "Prompt de reparo" de `FASE2-UCRASH-FS.md`, com a saída do terminal acima colada.
- **Resposta do LLM (completa e verbatim):**

```
Classificação: (B) — o teste capturou um comportamento potencialmente incorreto da aplicação.

O teste está alinhado com a especificação da função, especialmente com o comentário:

"Trata palavras vazias internas."

O que foi observado

Ao executar:

Validators.capitalize('maria  silva')

o split(' ') produz:

['maria', '', 'silva']

Quando o map processa a palavra vazia, a implementação tenta acessar:

word[0]

Como word é '', não existe índice 0, resultando em:

RangeError (index): Invalid value: Valid value range is empty: 0

Comportamento esperado

Considerando a documentação da função, o comportamento esperado para:

'maria  silva'

é preservar o espaço interno e capitalizar as palavras:

'Maria  Silva'

Portanto, não devemos alterar ou enfraquecer o teste para fazê-lo passar. O teste está justamente revelando que a implementação não cumpre o comportamento documentado.

O teste deve permanecer assim:

test('deve preservar espaços internos vazios', () {
  expect(Validators.capitalize('maria  silva'), 'Maria  Silva');
});

A correção deve ser feita na implementação de Validators.capitalize, tratando word.isEmpty antes de acessar word[0]. Isso também evita o mesmo problema para entradas como 'maria da silva'.
```
- **★ Autoclassificação do modelo:** (B) — bug real exposto
- **Resultado após correção:** Falhou (mantido intencionalmente — o modelo não alterou o teste, por julgar que a aplicação é que está incorreta; o `RangeError` persiste, como esperado, já que a aplicação não foi corrigida por protocolo)

---

## ★ Análise de Autoclassificação (preencher após a rodada)

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | Bug real exposto — declarada na iteração de reparo, com recusa explícita a enfraquecer o teste |
| **★ Classificação humana (auditoria)** | Bug real exposto |
| **★ Concordância** | Sim |
| **★ Observações** | Diferente da estratégia zero-shot (que já evitou o caso de espaço duplo na 1ª resposta), aqui o modelo verbalizou o risco mas mesmo assim escreveu um teste que aciona o bug — exigindo o prompt de reparo. Na iteração de reparo, manteve-se firme: recusou-se a enfraquecer a asserção e apontou corretamente a causa raiz e onde a correção deveria ocorrer (na aplicação, não no teste). |

**Referência de categorias (classificação humana — mesmas da Fase 1):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
