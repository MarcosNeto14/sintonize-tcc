# Medeiros (2026) — "Testes automatizados de acessibilidade com LLMs: uma análise de estratégias de prompt em portais governamentais" — resumo e uso no TCC

## Referência

Medeiros, Gabriele Monteiro de. **Testes automatizados de acessibilidade com LLMs: uma análise de estratégias de prompt em portais governamentais.** Monografia (Bacharelado em Sistemas de Informação) — Departamento de Estatística e Informática, Universidade Federal Rural de Pernambuco, Recife, 2026. Orientador: Cleyton Vanut C. de Magalhães. Repositório: https://github.com/gabdemedeiros/TCC_BSI

```bibtex
@monography{medeiros2026acessibilidade,
  author  = {Medeiros, Gabriele Monteiro de},
  title   = {Testes automatizados de acessibilidade com {LLMs}: uma an{\'a}lise de estrat{\'e}gias de prompt em portais governamentais},
  school  = {Universidade Federal Rural de Pernambuco},
  type    = {Monografia (Bacharelado em Sistemas de Informa{\c{c}}{\~a}o)},
  address = {Recife},
  year    = {2026},
  note    = {Orientador: Cleyton Vanut C. de Magalh{\~a}es. Dispon{\'i}vel em: \url{https://github.com/gabdemedeiros/TCC_BSI}}
}
```
(No estilo SBC, `@monography` não existe: use `@mastersthesis` com `type = {Monografia (Bacharelado)}`, ou `@misc` com `howpublished`.)

## Resumo

Estudo de caso com um único modelo (Gemini 3 Flash, tier pago) gerando *scripts* E2E de acessibilidade (Cypress + Cucumber/Gherkin + Page Object Model) para dois portais do Governo de Pernambuco (Transparência e Portal do Governo). Método em cinco etapas: (1) *stack* e critérios de avaliação; (2) **construção manual de scripts de referência** para os cenários (aumentar/diminuir fonte, escala de cinza, contraste, navegação); (3) elaboração do *prompt*, estruturado em componentes (papel do modelo, objetivo, contexto, fluxo de teste; depois, elementos da interface com seletores reais, restrições como "não inventar seletores", boas práticas) — uma combinação de *zero-shot* com *expert prompting*; (4) execução dos *scripts* gerados em **três iterações**, cada uma com **refinamento do prompt** a partir das falhas observadas (sobretudo seletores inexistentes); (5) avaliação por critérios qualitativos: legibilidade, facilidade de manutenção, **quantidade de ajustes manuais**, uso de seletores corretos, validação das funcionalidades e tempo de execução. Resultado: o refinamento melhora organização, seletores e aderência ao fluxo, mas todos os *scripts* exigiram intervenção humana (seletores, lógica, configuração do Cucumber, validações específicas; iframes inviabilizaram cenários). Conclusão: engenharia de *prompt* apoia a automação e reduz esforço inicial, mas não dispensa o QA. Ameaças declaradas: não determinismo (mitigado com sessão nova por prompt), ajustes manuais como fonte de viés, portais reais mutáveis, avaliação qualitativa da autora; um modelo só, dois portais, um domínio, uma *stack*. Trabalhos futuros: outros modelos (GPT, Claude), outras técnicas de *prompt*, iframes. Inclui capítulo de declaração de uso de IA na escrita.

## O que ela faz igual, diferente e o que o nosso trabalho acrescenta

| Aspecto | Medeiros (2026) | Este TCC |
|---|---|---|
| Nível | só E2E (web, Cypress) | pirâmide completa; E2E móvel (`integration_test`, AVD + emuladores) |
| Baseline humana | *scripts* manuais de referência escritos antes | roteiro manual + testes de referência escritos fora do protocolo; rubrica manual-first |
| Estratégias | 1 prompt base (ZS + expert), refinado em 3 iterações | ZS × FS × COT fixos, byte-idênticos, sem refinamento entre rodadas |
| Reparo | ajustes manuais nos *scripts* + refinamento do prompt | ciclo de reparo pelo próprio modelo, template fixo, (A)/(B), sem ajuste humano no código |
| Oráculo de detecção | validação funcional das funcionalidades reais | defeitos plantados (CRASH/SILENT) + defeitos reais catalogados |
| Modelos | Gemini 3 Flash pago | ChatGPT (deslogado) × Gemini 3.8 Flash (logado) |
| Métricas | qualitativas (legibilidade, manutenção, ajustes, seletores, tempo) | executabilidade + detecção codificada; análise de erro por categoria |
| Convergência de achados | seletores inventados; "não inventar seletores" como restrição; necessidade de fornecer elementos reais da interface | caminho de import inventado (Fase 2), `material.dart`/imports faltando (Fase 3); material do prompt como fator decisivo; recusa do ChatGPT a inventar caminho |

Os dois trabalhos chegam, por caminhos diferentes, à mesma conclusão operacional: **o que o modelo não recebe no prompt ele inventa ou trava**, e o esforço humano migra da escrita do teste para a validação do teste. Isso dá uma triangulação boa para a Discussão — mesmo orientador, mesma família de modelo, domínio e stack diferentes.

## Onde usar no texto

1. **Trabalhos relacionados** — parágrafo próprio (abaixo), ao lado de Schäfer et al. (TestPilot) e dos trabalhos de teste de GUI móvel com LLM (GPTDroid, DroidAgent, QTypist), posicionando o nosso como o único a cobrir os quatro níveis e a usar defeitos plantados como oráculo.
2. **Metodologia da Fase 3** — citar como origem do desenho "referência manual antes, geração depois" (etapa 2 dela ↔ nosso roteiro manual e testes de referência), e marcar a diferença: aqui a referência não entra no prompt e os ajustes humanos no código são proibidos.
3. **Discussão** — convergência dos achados sobre material do prompt (seletores ↔ imports/caminhos) e sobre o papel do QA.
4. **Limitações** — ela mitigou não determinismo com sessão nova por prompt, mesma regra nossa; citar como prática compartilhada.

### Parágrafo pronto para Trabalhos Relacionados (LaTeX)

```latex
Medeiros~\cite{medeiros2026acessibilidade}, em trabalho orientado pelo mesmo
orientador deste, avaliou a geração de \textit{scripts} E2E de acessibilidade
(Cypress, Cucumber/Gherkin e \textit{Page Object Model}) pelo Gemini 3 Flash
para dois portais do Governo de Pernambuco. O desenho parte de \textit{scripts}
manuais de referência e compara com eles os artefatos gerados a partir de um
\textit{prompt} estruturado em componentes (papel, objetivo, contexto, fluxo,
elementos da interface, restrições), refinado em três iterações conforme as
falhas observadas; a avaliação é qualitativa --- legibilidade, manutenção,
quantidade de ajustes manuais, seletores corretos e validação funcional. O
achado central é que o refinamento do \textit{prompt} melhora os
\textit{scripts}, sobretudo quando passa a fornecer seletores reais e a
proibir sua invenção, mas nenhum artefato dispensou intervenção humana. Este
trabalho compartilha com o de Medeiros a construção prévia de uma referência
manual para o nível E2E e a regra de uma sessão nova por \textit{prompt}, e
difere em três pontos: cobre os quatro níveis da pirâmide em uma aplicação
móvel; mantém os \textit{prompts} fixos e idênticos entre três estratégias e
dois modelos, delegando o reparo ao próprio modelo sob um \textit{template}
sem intervenção humana no código; e usa defeitos plantados como oráculo, o
que permite separar a executabilidade dos testes da sua capacidade de
detecção.
```
