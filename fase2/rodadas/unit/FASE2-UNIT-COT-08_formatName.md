# FASE2-UNIT-COT-08_formatName — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-COT-08 |
| **Função testada** | `Validators.formatName` (preserva o restante da palavra — origem `adicionar-musica.dart`) |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das demais rodadas da Fase 2, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-04 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/unit/format_name_cot_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `formatName` não é alvo de nenhum bug plantado
da Fase 2, mas tem o bug real pré-existente (`RangeError` em `word[0]`
para strings com espaços consecutivos/extremidade), já documentado nas
rodadas ZS-08 (testou e capturou) e FS-08 (identificou em prosa, mas não
testou) desta série.

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/cot/FASE2-UNIT-COT-08_formatName.md`
— prompt estruturado em 3 passos (analisar, identificar cenários, escrever
testes).

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

Identificou o `RangeError` já na etapa 2 (identificação de cenários),
antes de escrever qualquer teste, classificando-o explicitamente como
"Cenários de falha / entradas problemáticas" com a causa técnica correta
("a implementação atual lança `RangeError`, pois tenta acessar `word[0]`
em uma palavra vazia"). Diferente de `FASE2-UNIT-FS-08` (mesma função,
few-shot, mesma sessão de estratégias), aqui o modelo **converteu a
identificação em 4 testes reais** usando `throwsRangeError`, cobrindo:
string só de espaços (3 espaços), espaços consecutivos (2 espaços),
espaço inicial e espaço final — replicando integralmente a cobertura da
rodada zero-shot equivalente (`FASE2-UNIT-ZS-08`).

Encerrou com uma observação de qualidade rara nesta série: sugeriu
explicitamente que, **se a função devesse tratar espaços extras
normalmente**, os testes de falha poderiam ser convertidos em testes de
sucesso (`' joao silva '` → `'Joao Silva'`) — sem fazer essa alteração por
conta própria, apenas registrando a alternativa como hipótese.

O código foi obtido via clipboard (botão "copiar") para confirmar a
contagem exata de espaços nos literais de teste (3 espaços em `'   '`, 2
espaços em `'joao  silva'`) — `get_page_text` colapsa espaços consecutivos.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 15 |
| **Testes passaram (1ª execução)** | 15 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (repair não foi necessário) |
| **Testes falharam (pós-repair)** | — |

### Saída do terminal (iteração 0 — final, 15/15)

```
00:00 +15: All tests passed!
```

(saída completa em `fase2/resultados/unit/cot/FASE2-UNIT-COT-08_formatName_iter0_final.txt`)

---

## Iterative Repair Loop

Não houve. A suíte passou 15/15 na primeira execução — inclusive os 4
testes que exercitam o bug real via `throwsRangeError`.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(C)** — bug real identificado espontaneamente na geração inicial, com testes dedicados construídos para expor o comportamento real, sem falha nem ciclo de reparo. Evidência: a etapa de "cenários de falha" nomeia a causa exata (`word[0]` sobre palavra vazia) antes de qualquer código, e os 4 testes subsequentes usam `throwsRangeError` para confirmar exatamente esse comportamento. |
| **★ Classificação humana (auditoria)** | Bug capturado sem necessidade de reparo (C) |
| **★ Concordância** | Sim |
| **★ Observações** | Completa o conjunto de 3 estratégias para `formatName` nesta sessão: ZS testou o bug (C) com grupo dedicado; FS apenas mencionou o bug em prosa sem testá-lo; CoT testou o bug (C) com grupo dedicado, igualando o ZS. Isso sugere que a few-shot, quando os exemplos fornecidos não cobrem bugs de runtime (os dois exemplos padrão desta Fase 2 são só validações de retorno `String?`), pode ser a estratégia menos propensa a converter uma observação correta em teste — enquanto zero-shot e chain-of-thought, sem essa ancoragem, tendem a agir sobre o que identificam. |

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
