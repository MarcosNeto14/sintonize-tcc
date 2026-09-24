# Sintonize — TCC

**Aluno:** Marcos Leite Bezerra Neto
**Curso:** Bacharelado em Sistemas de Informação — UFRPE
**Orientador:** Prof. Cleyton Magalhães

## Sobre

Repositório do experimento do TCC "Uso de Modelos de Linguagem de Grande Escala na Implementação da Pirâmide de Testes: Um Estudo de Caso em uma Aplicação Móvel".

Este repositório contém o código-fonte do app Sintonize (Flutter + Firebase) com as adaptações necessárias para o experimento, os testes gerados por LLM, a documentação de cada rodada experimental e os resultados da análise.

## Etapas do experimento

O trabalho está organizado em três etapas, cada uma com sua própria árvore de artefatos:

| Etapa | Rodadas | Modelo | Artefatos | Situação |
|---|---|---|---|---|
| **Fase 1** — estudo piloto | 48 | ChatGPT | `prompts/`, `results/`, `analise/` | concluída |
| **Fase 2** — estudo principal | 60 | ChatGPT | `fase2/` | concluída |
| **Fase 2 – Gemini** — replicação | 60 | Gemini | `fase2-gemini/` | em andamento |

A **Fase 1** não é mais o estudo principal do TCC, mas seus artefatos permanecem preservados e não devem ser alterados — servem de base de comparação.

A **Fase 2** repete a comparação ZS/FS/COT contra seis bugs propositalmente plantados, mais alvos limpos: 18 rodadas de bug, 3 de `formatName`, 27 de alvos limpos originais e 12 de alvos limpos acrescentados depois para equilibrar widget e integração.

A **Fase 2 – Gemini** replica as 60 rodadas da Fase 2 com os mesmos prompts (cópia byte-idêntica), alvos, bugs e protocolo. **A única variável alterada é o modelo.** Ver `fase2-gemini/README.md` para o mapeamento de branches e o protocolo por rodada.

## Estrutura do repositório

A estrutura espelha os três níveis da pirâmide de testes (unit / widget / integration) entre `prompts/`, `test/` e `results/`, com E2E manual à parte (sem `test/`, pois é executado manualmente). A Fase 2 e sua replicação seguem o mesmo layout em árvores próprias.

- `lib/` — código-fonte do Sintonize (clone do projeto original com refatoração mínima)
- `lib/utils/validators.dart` — classe `Validators` extraída para viabilizar testes unitários
- `test/` — testes Dart gerados por LLM
  - `test/unit/`, `test/widget/`, `test/integration/` — Fase 1 (30 / 9 / 9 arquivos)
  - `test/fase2/{unit,widget,integration}/` — Fase 2
- `prompts/` — **Fase 1:** documentação completa de cada rodada (prompt, resposta, resultado, análise)
  - `prompts/unit/{zero-shot,few-shot,cot}/` — 30 docs `UNIT-*-NN_*.md`
  - `prompts/widget/{zero-shot,few-shot,cot}/` — 9 docs `WIDGET-*-NN_*.md`
  - `prompts/integration/{...}/` — 9 docs do nível integration
  - `prompts/README.md` — protocolo e tabela de rastreabilidade; `prompts/PROMPT_TEMPLATES.md` — templates
- `results/` — **Fase 1:** saídas do `flutter test` de cada rodada
- `analise/` — **Fase 1:** dados consolidados das 48 rodadas
- `e2e-manual/` — **Fase 1:** roteiros dos 4 fluxos E2E manuais
- `fase2/` — **Fase 2** (concluída): `prompts_prontos/` (prompts completos), `rodadas/` (docs por rodada), `resultados/`, `propostas_bugs_fase2.md` (os 6 bugs plantados e as notas de metodologia)
- `fase2-gemini/` — **Fase 2 – Gemini** (em andamento): mesma estrutura, com `prompts_prontos/` byte-idêntico ao da Fase 2
- `package.json` — atalhos npm para comandos Flutter (`npm run test`, `npm run analyze`, etc.); não instala dependências Node, apenas roda Flutter por baixo

> **Status atual do experimento:** Fase 1 concluída (48 rodadas, incluindo os 4 fluxos E2E manuais). Fase 2 concluída (60 rodadas). A replicação com Gemini tem a infraestrutura pronta, mas **nenhuma rodada executada** — a submissão dos prompts é manual.

### Branches

As rodadas da Fase 2 dependem do estado do código, e a branch errada invalida a rodada em silêncio:

| Branch | Estado | Usar para |
|---|---|---|
| `fase2-gemini-piloto` | os 6 bugs plantados ativos (criada a partir de `295fa34`) | as 18 rodadas de bug |
| `fase2-alvos-limpos` | bugs revertidos | rodadas de alvos limpos, incluindo as 3 de `formatName` |
| `fase2-prep` | intermediária — **só 3 dos 6 bugs ativos** | nada; não usar como referência |

**`formatName` não é alvo limpo:** o defeito (`RangeError` por falta da guarda `if (word.isEmpty)`) é pré-existente e idêntico em todas as branches, inclusive `main` — não é contaminação de branch. Suas 3 rodadas rodam junto com o bloco unitário limpo, mas não contam como alvo limpo na análise.

## Como reproduzir

1. Instalar Flutter (SDK Dart `>=2.17.0 <4.0.0`, conforme `pubspec.yaml`) — testado com Flutter 3.41.7
2. Clonar este repositório
3. Rodar `flutter pub get` (ou `npm run get`)
4. Rodar `flutter test test/unit/` para executar os 30 testes unitários

## Metodologia

Os testes foram gerados com três estratégias de engenharia de prompt:

- **Zero-shot (ZS):** prompt simples com o código da função
- **Few-shot (FS):** prompt com exemplos de testes antes da função-alvo
- **Chain-of-Thought (COT):** prompt instruindo raciocínio passo a passo

As Fases 1 e 2 usaram o **ChatGPT**; a replicação usa o **Gemini**. Cada rodada é documentada com metadados completos (data, versão do modelo, prompt exato, resposta do LLM, saída do terminal e iterações de reparo) para garantir transparência e reprodutibilidade. Ver `prompts/README.md` para o protocolo da Fase 1 e `fase2-gemini/README.md` para o da replicação.

A partir da Fase 2, o protocolo de reparo pede que o próprio modelo classifique cada falha como **(A)** teste incorreto ou **(B)** bug real da aplicação, antes de corrigir.

### Registro da versão do modelo

Durante a Fase 2 descobriu-se que o modelo servido sem login **mudou de GPT-5.5 para GPT-5.6 no meio do estudo, sem aviso**, e isso só foi percebido meses depois. Cada rodada passa a registrar dois campos independentes:

- **Modelo declarado pelo LLM** — perguntado no início da sessão, anotado literalmente
- **Verificação externa da versão** — confirmação, por fonte externa, de qual modelo é servido naquela data

A autodeclaração de um modelo sobre a própria identidade não é evidência suficiente sozinha. Perguntado diretamente na Fase 2, o ChatGPT se declarou "GPT-5.6 Luna". Esse é o nome oficial do modelo do tier gratuito/deslogado (OpenAI Help Center, consultado em 2026-09-24): a autodeclaração estava correta, mas continua não sendo evidência suficiente sozinha. Quando os dois campos divergem, **registra-se a divergência, não se resolve**.
