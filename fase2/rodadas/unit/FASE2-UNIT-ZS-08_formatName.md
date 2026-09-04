# FASE2-UNIT-ZS-08_formatName — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-UNIT-ZS-08 |
| **Função testada** | `Validators.formatName` (preserva o restante da palavra — origem `adicionar-musica.dart`) |
| **Arquivo de origem** | `lib/utils/validators.dart` |
| **Nível da pirâmide** | Unitário |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das 18 rodadas do piloto e das 4 reexecuções, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-03 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable), Dart 3.11.5 |
| **Arquivo de teste** | `test/fase2/unit/format_name_zs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `formatName` **não é alvo de nenhum bug plantado da
Fase 2** — não faz parte dos 6 bugs do piloto. O código-fonte é
byte-idêntico a `main` (`git diff main -- lib/utils/validators.dart` vazio).
No entanto, `formatName` **tem um bug real e pré-existente**, já identificado
na Fase 1 (Estudo 1): a ausência da guarda `if (word.isEmpty)` faz
`word[0]` lançar `RangeError` quando `split(' ')` produz uma string vazia
(entrada com espaços consecutivos, inicial ou final). Ver a investigação
completa dessa divergência entre artefatos da Fase 1 registrada na sessão de
2026-09-03. O prompt pronto contém o corpo verbatim da função, sem docstring.

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/unit/zero-shot/FASE2-UNIT-ZS-08_formatName.md`,
template zero-shot idêntico ao usado na Fase 1.

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

### Mensagem inicial (geração dos testes)

O modelo **identificou o bug real antes de escrever qualquer teste**, na
primeira frase da resposta:

> Claro. Como a função acessa word[0], há um caso de borda importante: nomes com espaços consecutivos geram palavras vazias e causam RangeError. Os testes abaixo cobrem comportamento esperado, entradas que expõem essa falha e bordas.

Gerou 13 testes em 3 grupos. O grupo `Casos de falha` inteiro (4 testes)
asserta `throwsRangeError` para: espaços consecutivos, string só de espaços,
espaço no início, espaço no final — os quatro cenários que de fato lançam a
exceção na implementação real. O grupo `Casos de sucesso` cobre string vazia,
nome simples, múltiplas palavras (`'joao da silva'` → `'Joao Da Silva'`) e a
característica que distingue esta função de `capitalize`: **preserva** a caixa
do restante da palavra (`'jOaO dA sIlVa'` → `'JOaO DA SIlVa'`, não
`'Joao Da Silva'`).

Encerrou com uma observação equivalente à recusa de enfraquecer a asserção:

> Observação: os testes de falha documentam o comportamento atual da implementação. Se a intenção for que formatName('joao silva') produza 'Joao Silva' em vez de lançar RangeError, a implementação precisará ser ajustada antes de mudar esses testes.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 13 |
| **Testes passaram (1ª execução)** | 13 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (repair não foi necessário) |
| **Testes falharam (pós-repair)** | — |

### Saída do terminal (iteração 0 — final, 13/13)

```
00:00 +13: All tests passed!
```

(saída completa em `fase2/resultados/unit/zero-shot/FASE2-UNIT-ZS-08_formatName_iter0_final.txt`)

---

## Iterative Repair Loop

Não houve. A suíte passou 13/13 na primeira execução, portanto nenhum prompt
de reparo foi enviado e nenhuma autoclassificação (A)/(B) foi solicitada.
Conforme a "Nota sobre (C)" do `fase2/Template_Documentacao_Rodada_Fase2.md`,
a evidência de (C) é registrada diretamente na seção de autoclassificação
abaixo, referenciando a resposta de geração inicial citada acima.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(C)** — bug real identificado espontaneamente na geração inicial, sem falha nem reparo. Evidência: a primeira frase da resposta nomeia a causa exata (`word[0]` sobre palavra vazia) antes de qualquer teste ser escrito, e a suíte inteira — inclusive um grupo dedicado — é construída para expor o comportamento real em vez de presumir uma versão corrigida da função. |
| **★ Classificação humana (auditoria)** | Bug capturado sem necessidade de reparo (C) |
| **★ Concordância** | Sim |
| **★ Observações** | Ver abaixo. |

### Observações

1. **Contraste direto com o achado de UNIT-COT-08 na Fase 1.** Na rodada
   original de `formatName` (chain-of-thought, Fase 1), o mesmo bug só foi
   detectado **depois** de uma execução falhar (4/8 na 1ª execução) — e a
   correção aplicada naquele momento alterou o **código-fonte** em vez do
   teste, episódio único no experimento e já investigado como divergência
   entre artefatos. Aqui, zero-shot, na Fase 2, o mesmo bug foi identificado
   **antes** de qualquer execução, e a suíte nasceu correta. É o contraste mais
   direto disponível no experimento entre "detecção reativa via falha" e
   "detecção espontânea via leitura do código" — mesma função, bug idêntico,
   estratégias e fases diferentes.

2. **Distinção correta entre as duas funções de capitalização do projeto.**
   Sem qualquer pista textual (a docstring foi omitida), o modelo produziu a
   asserção `'jOaO dA sIlVa'` → `'JOaO DA SIlVa'` (preserva o restante),
   inferida unicamente de `word.substring(1)` sem `.toLowerCase()`. Essa é
   exatamente a diferença que separa `formatName` de `capitalize`
   (que teria produzido `'Joao Da Silva'`) — inconsistência documentada no
   projeto e que o prompt não menciona.

3. **Nenhuma tentativa de "consertar" a função.** O template zero-shot não
   instrui explicitamente a não alterar a implementação (diferente dos
   prompts de widget/integração, que trazem "Não modifique o código"). Ainda
   assim o modelo não alterou nada e devolveu apenas o arquivo de teste,
   respeitando o protocolo por iniciativa própria.

4. **Rodada mais rápida e menos custosa da série até aqui** (nenhuma iteração,
   suíte pequena e coesa) — coerente com a hipótese acumulada nas rodadas
   anteriores: quando o comportamento relevante está plenamente exposto no
   corpo da função (aqui, o acesso incondicional a `word[0]` é visualmente
   óbvio), a taxa de acerto de primeira tentativa é alta.

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
