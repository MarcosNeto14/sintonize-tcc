# FASE2-UNIT-FS-08_formatName — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-FS-08 |
| **Função testada** | `Validators.formatName` (preserva o restante da palavra — origem `adicionar-musica.dart`) |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das demais rodadas da Fase 2, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-04 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/unit/format_name_fs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `formatName` não é alvo de nenhum bug plantado
da Fase 2, mas tem um bug real e pré-existente (já identificado na Fase 1):
ausência da guarda `if (word.isEmpty)` faz `word[0]` lançar `RangeError`
quando `split(' ')` produz uma string vazia (espaços consecutivos, inicial
ou final).

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/few-shot/FASE2-UNIT-FS-08_formatName.md`
— mesmos dois exemplos padrão seguidos do corpo verbatim de `formatName`.

```dart
  static String formatName(String name) {
    if (name.isEmpty) return name;
    return name
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
```

---

## Resposta do LLM

Gerou 4 testes: string vazia, nome simples, múltiplas palavras (`'joao da
silva'` → `'Joao Da Silva'`) e a característica que distingue esta função
de `capitalize` — preserva a caixa do restante da palavra (`'jOAO dA
sIlVa'` → `'JOAO DA SIlVa'`, verificado e correto).

**Identificou o bug verbalmente, mas não o testou.** Ao final da resposta,
o modelo escreveu: *"vale notar que a função pode lançar erro para entradas
contendo espaços consecutivos, porque `word` pode ser uma string vazia"* —
diagnóstico correto e preciso do `RangeError`. No entanto, diferente da
rodada `FASE2-UNIT-ZS-08` (mesma função, zero-shot), em que o modelo
**escreveu um grupo de testes dedicado** (`throwsRangeError` para 4
variações de espaço), aqui a suíte few-shot **não contém nenhum teste**
para esse comportamento — a observação ficou apenas em texto solto após o
código.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 4 |
| **Testes passaram (1ª execução)** | 4 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (repair não foi necessário) |
| **Testes falharam (pós-repair)** | — |

### Saída do terminal (iteração 0 — final, 4/4)

```
00:00 +4: All tests passed!
```

(saída completa em `fase2/resultados/unit/few-shot/FASE2-UNIT-FS-08_formatName_iter0_final.txt`)

---

## Iterative Repair Loop

Não houve. A suíte passou 4/4 na primeira execução — mas por não conter
nenhum teste do cenário de bug, não por tê-lo tratado corretamente.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (C) parcial — o modelo identificou corretamente o bug real na geração inicial (mesma causa raiz de UNIT-ZS-08: `word[0]` sobre palavra vazia), mas **não converteu esse conhecimento em um teste**, ao contrário da rodada zero-shot equivalente. |
| **★ Classificação humana (auditoria)** | Limitação de testabilidade / Ambíguo — o diagnóstico textual está correto e completo, mas a suíte entregue não exerce o comportamento identificado; não há teste a rotular como (A)/(B)/(C) no sentido estrito da definição, pois "(C)" pressupõe que o teste *se ajustou* ao bug, não apenas que o texto o menciona. |
| **★ Concordância** | N/A — divergência qualitativa entre estratégias, não uma discordância modelo-vs-humano sobre um teste específico |
| **★ Observações** | Contraste direto com `FASE2-UNIT-ZS-08` (mesma função, mesmo bug, zero-shot): lá o modelo **testou** o `RangeError` com um grupo dedicado de 4 casos; aqui, few-shot, o modelo **apenas comentou** o mesmo bug em prosa, sem gerar asserção alguma para ele. Ambos os prompts omitem a docstring e não instruem explicitamente a testar bugs; a diferença de comportamento entre as duas estratégias, para o mesmo bug na mesma função, é o dado mais direto desta rodada para a comparação ZS vs. FS quanto à profundidade de exploração de casos de borda não solicitados explicitamente. |

---

**Referência de categorias (classificação humana — mesmas da Fase 1, + (C) da Fase 2):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
| Bug capturado sem necessidade de reparo (C) | O modelo já identificou e se ajustou ao bug real na geração inicial, sem falha nem ciclo de reparo |
