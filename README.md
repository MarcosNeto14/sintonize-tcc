# Sintonize — TCC

**Aluno:** Marcos Leite Bezerra Neto
**Curso:** Bacharelado em Sistemas de Informação — UFRPE
**Orientador:** Prof. Cleyton Magalhães

## Sobre

Repositório do experimento do TCC "Uso de Modelos de Linguagem de Grande Escala na Implementação da Pirâmide de Testes: Um Estudo de Caso em uma Aplicação Móvel".

Este repositório contém o código-fonte do app Sintonize (Flutter + Firebase) com as adaptações necessárias para o experimento, os testes gerados por LLM, a documentação de cada rodada experimental e os resultados da análise.

## Estrutura do repositório

A estrutura espelha os três níveis da pirâmide de testes (unit / widget / integration) entre `prompts/`, `test/` e `results/`, com E2E manual à parte (sem `test/`, pois é executado manualmente).

- `lib/` — código-fonte do Sintonize (clone do projeto original com refatoração mínima)
- `lib/utils/validators.dart` — classe `Validators` extraída para viabilizar testes unitários
- `test/` — testes Dart gerados pelo ChatGPT
  - `test/unit/` — 30 arquivos (10 funções × 3 estratégias)
  - `test/widget/` — 9 arquivos (3 widgets × 3 estratégias)
- `prompts/` — documentação completa de cada rodada (prompt, resposta, resultado, análise)
  - `prompts/unit/{zero-shot,few-shot,cot}/` — 30 docs `UNIT-*-NN_*.md` (nível unitário, concluído)
  - `prompts/widget/{zero-shot,few-shot,cot}/` — 9 docs `WIDGET-*-NN_*.md` (nível widget, em andamento)
  - `prompts/integration/{zero-shot,few-shot,cot,multi-step,context-enrichment}/` — pastas reservadas para o nível integration (rodadas ainda não executadas)
  - `prompts/e2e/` — pasta reservada para documentação dos fluxos E2E manuais
- `results/` — saídas do `flutter test` para cada rodada (`*-NN.txt`)
  - `results/unit/{zero-shot,few-shot,cot}/` — 30 resultados (concluído)
  - `results/widget/{zero-shot,few-shot,cot}/` — placeholders para os resultados da fase widget
  - `results/integration/{...}/` e `results/e2e/` — placeholders para fases futuras
- `package.json` — atalhos npm para comandos Flutter (`npm run test`, `npm run analyze`, etc.); não instala dependências Node, apenas roda Flutter por baixo

> **Status atual do experimento:** o nível unitário (30 rodadas) está concluído. O nível widget tem prompts criados (9 docs) e testes Dart prontos, mas execução das rodadas ainda não foi documentada. Integration tests e E2E manual estão planejados mas ainda não foram iniciados.

## Como reproduzir

1. Instalar Flutter (SDK Dart `>=2.17.0 <4.0.0`, conforme `pubspec.yaml`) — testado com Flutter 3.41.7
2. Clonar este repositório
3. Rodar `flutter pub get` (ou `npm run get`)
4. Rodar `flutter test test/unit/` para executar os 30 testes unitários

## Metodologia

Os testes foram gerados utilizando o ChatGPT com três estratégias de engenharia de prompt:

- **Zero-shot (ZS):** prompt simples com o código da função
- **Few-shot (FS):** prompt com exemplos de testes antes da função-alvo
- **Chain-of-Thought (COT):** prompt instruindo raciocínio passo a passo

Cada rodada foi documentada com metadados completos (data, versão do modelo, prompt exato, resposta do LLM, saída do terminal e iterações de reparo) para garantir transparência e reprodutibilidade. Ver `prompts/README.md` para o protocolo detalhado e `prompts/PROMPT_TEMPLATES.md` para os templates de prompt.
