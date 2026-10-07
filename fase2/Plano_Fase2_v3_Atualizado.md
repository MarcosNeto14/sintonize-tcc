# Plano Atualizado — Nova Execução com Prompt de Reparo Revisado (v3)

**Status:** decisão fechada com o Cleyton — refazer as 48 rodadas originais
(mesmos alvos, mesmas 3 estratégias), com prompt de reparo revisado e bugs
propositais inseridos em parte dos alvos. Este documento substitui a v2.

---

## 1. Como chegamos aqui (resumo da evolução, para contexto)

1. **Fase A** (reclassificação retrospectiva das 48 rodadas originais) foi
   concluída — ver Seção 2. Ela revelou um problema sério: em 3 rodadas, o
   reparo não corrigiu a causa raiz, apenas enfraqueceu a asserção ou
   removeu o teste até ele "passar".
2. Cogitou-se um Estudo 2 pequeno e controlado (16 rodadas, alvos novos)
   para testar isso isoladamente — essa proposta foi descartada.
3. **Decisão final com o Cleyton:** refazer a execução original inteira,
   corrigindo o protocolo em vez de rodar um estudo à parte.

Os achados da Fase A **não são descartados** — são a justificativa e a
taxonomia usadas na nova execução (ver Seção 2 e 4).

---

## 2. Achados da Fase A (mantidos como referência e motivação)

### Contagem final por categoria (execução original, 48/48 rodadas)

| Categoria                                 | Unitário | Widget | Integração | Total |
| ----------------------------------------- | -------- | ------ | ---------- | ----- |
| Erro de teste                             | 0        | 1      | 4          | 5     |
| Bug real exposto                          | 3        | 0      | 0          | 3     |
| Erro de geração (API/import inexistente)  | 0        | 3      | 1          | 4     |
| Limitação de testabilidade (arquitetural) | 0        | 5      | 1          | 6     |
| Ambíguo / decisão de design               | 2        | 0      | 0          | 2     |
| Sem reparo                                | 25       | 0      | 3          | 28    |

**1 bug real distinto** (`formatName`, um crash, achado independentemente
pelas 3 estratégias). **3 rodadas com asserção enfraquecida/escopo
reduzido** (`INT-ZS-01`, `INT-ZS-03`, `INT-FS-02`) — o achado que motivou
tudo isso.

**Observação importante que orienta a nova execução:** o único bug real
encontrado é do tipo _crash_ — estruturalmente imune a mascaramento (o
Dart não deixa passar por uma exceção não tratada). Um bug _silencioso_
(retorna valor errado, mas plausível, sem travar nada) é o tipo
efetivamente vulnerável ao padrão de asserção enfraquecida. É por isso que
a nova execução precisa dos dois tipos de bug, não só um.

Esses dados seguem disponíveis na planilha de classificação já entregue —
não precisam ser refeitos.

---

## 3. Desenho da nova execução

### Estrutura geral

- **Mesma escala do Estudo 1:** 10 funções (unitário) × 3 telas (widget) ×
  3 fluxos (integração), 3 estratégias (zero-shot / few-shot /
  chain-of-thought) — 48 rodadas, como antes.
- **Bugs propositais entram em parte dos alvos, não em todos** — para
  manter alvos "limpos" como grupo de comparação e não confundir "LLM gera
  teste ruim" com "alvo tinha bug plantado" em 100% dos casos.
- **Dois tipos de bug por alvo escolhido:** crash e silencioso (ver Seção 2).
- **Prompt de reparo revisado, com dois caminhos** (erro de teste × possível
  bug) — ver Seção 4.
- **Autoclassificação pelo modelo + auditoria humana** — ver Seção 5.
- **Sessões novas e independentes**, sem misturar com os dados da execução
  original (Estudo 1), que continuam preservados como estão.

### Pendências para fechar antes de rodar

1. **Quais alvos recebem bug proposital, e quantos** — sugestão: 1/3 dos
   alvos por nível (ex.: 3-4 funções unitárias, 1 tela de widget, 1 fluxo
   de integração), garantindo que sobre uma maioria de alvos "limpos" para
   comparação.
2. **Onde entra o bug crash vs. o silencioso** — pode ser o mesmo alvo com
   duas variantes, ou alvos diferentes; vale decidir com o Cleyton qual
   fica mais limpo de analisar.
3. **O que fazer com o acoplamento Firebase conhecido** — ele vai continuar
   aparecendo nas mesmas telas de widget independentemente do prompt novo,
   porque é limitação do código, não do processo de teste. Se não for
   corrigido antes, essas falhas vão se repetir e não vão indicar nada
   sobre o prompt novo — só confirmam o que já se sabe. Perguntar ao
   Cleyton se corrige no app antes, ou se aceita esse ruído conhecido.

---

## 4. O prompt de reparo revisado

Estrutura de dois caminhos, com autoclassificação embutida no próprio
prompt (rascunho — a ajustar antes de usar):

> "O teste falhou com o seguinte erro: [...]. Antes de corrigir, classifique
> a causa provável da falha: (A) o teste presume um comportamento que não é
> o especificado, ou (B) o teste capturou um comportamento potencialmente
> incorreto da aplicação. Declare essa classificação explicitamente.
>
> Se (A): corrija o teste normalmente.
>
> Se (B): não enfraqueça a asserção nem reduza o escopo do teste para
> fazê-lo passar. Descreva o comportamento observado, o comportamento
> esperado, e por que você suspeita de um problema na aplicação, em vez de
> alterar o teste."

Essa regra de não enfraquecer/reduzir nasce diretamente do achado de
`INT-ZS-01`/`INT-ZS-03`/`INT-FS-02`.

---

## 5. Autoclassificação do modelo + auditoria humana

**Decisão fechada:** o próprio modelo se autoclassifica a cada falha (ver
prompt acima) e segue o caminho correspondente. Depois de cada rodada, essa
autoclassificação é auditada por comparação com uma classificação humana
independente, usando a mesma taxonomia da Fase A (Erro de teste / Bug real
/ Erro de geração / Limitação de testabilidade / Ambíguo / Falha de
ambiente).

**Por que auditar em vez de confiar direto:** os dados da Fase A mostram
os dois lados — o modelo já demonstrou algum autodiagnóstico espontâneo
(`UNIT-ZS-03`/`COT-03`, sinalizou ambiguidade sem que fosse pedido), mas
também nunca alertou nos 3 casos onde simplesmente enfraqueceu a asserção.
Não dá para presumir que a autoclassificação é confiável nos casos mais
difíceis — que são justamente os que mais importam.

**Métrica nova que nasce disso:** taxa de concordância entre a
autoclassificação do modelo e a classificação humana, por nível e por
estratégia. Isso vira uma pergunta de pesquisa própria (o LLM consegue se
autodiagnosticar?) e uma contribuição adicional ao TCC, não só uma escolha
de protocolo.

---

## 6. O que isso significa para o TCC

- Os dados da execução original (Estudo 1) **continuam no texto** como
  estão — a nova execução não os substitui, ela os complementa/corrige.
- A Fase A (reclassificação) vira uma seção de achados por si só —
  documenta o problema que motivou a nova execução.
- A nova execução (48 rodadas revisadas) vira uma segunda rodada de
  resultados, comparável à primeira nos alvos "limpos", e com uma análise
  própria nos alvos com bug plantado.
- A taxa de concordância autoclassificação × humano é uma métrica nova,
  reportável em uma seção própria.

---

## 7. Próximos passos concretos

1. Fechar com o Cleyton: quantos/quais alvos recebem bug, e o que fazer
   com o acoplamento Firebase conhecido (Seção 3, pendências 1-3).
2. Finalizar o texto do prompt de reparo revisado (Seção 4).
3. Definir o template de documentação de rodada, já com os campos de
   autoclassificação do modelo e classificação humana lado a lado (para a
   auditoria da Seção 5).
4. Rodar as 48 rodadas novas, com sessões independentes da execução
   original.
5. Consolidar e comparar com os dados do Estudo 1.

## 8. Pendência antiga, ainda sem solução

A questão da trilha (Ciência vs. Tecnologia, diretrizes do CCD-BSI) segue
em aberto. Vale revisitar isso também.

---

## 9. Registro de mudanças

- **v1:** proposta inicial de bugs propositais em todos os níveis, sem
  número definido de rodadas.
- **v2:** escopo reduzido para um Estudo 2 controlado de 16 rodadas
  (alvos novos, dois tipos de bug, comparação pareada prompt antigo×novo),
  para não misturar com o Estudo 1 nem repetir alvos já esgotados.
- **v3 (esta versão):** decisão do Cleyton de refazer a execução original
  inteira (48 rodadas, mesmos alvos/estratégias), com prompt revisado e
  bugs propositais em parte dos alvos — substitui o desenho da v2.
  Autoclassificação do modelo + auditoria humana fecha a decisão de
  protocolo que estava em aberto desde a v1.
