# Baltes et al. (2026) aplicado ao TCC — resumo, checklist de relato e textos prontos (v2, 2026-10-07, pós-Fase 3)

Substitui o mapeamento de 25/09, feito antes da Fase 3. Referência e BibTeX: `baltes2026_guidelines_mapeamento_tcc.md` (`@article{baltes2026guidelines}`; arXiv:2508.15503v8, EMSE accepted manuscript; recurso vivo llm-guidelines.org).

## 1. Resumo em um parágrafo (para o Cleyton e para o texto)

Vinte e dois autores (entre eles Marcos Kalinowski, PUC-Rio) propõem uma taxonomia de sete tipos de estudo com LLMs em Engenharia de Software e oito diretrizes de desenho e relato, cada uma com requisitos (*must*) e recomendações (*should*), uma matriz de aplicabilidade por tipo de estudo e um checklist de relato organizado por seção do artigo (Apêndice C, inspirado no CONSORT). A motivação é a baixa reprodutibilidade: de 18 artigos ICSE/ASE 2024 que usaram modelos da OpenAI e publicaram artefatos, só 5 eram executáveis e nenhum reproduziu os resultados (Angermeir et al.); causas: não determinismo, modelos comerciais que mudam sem aviso sob o mesmo nome, formatação de prompt que sozinha desloca a acurácia em até 76 p.p., e relato incompleto de prompts, versões e configurações. As diretrizes: (1) declarar uso e papel do LLM; (2) versão, configuração e data; (3) arquitetura e desenho de prompts, incluindo seleção dos exemplos few-shot; (4) traces de sessão; (5) baselines, benchmarks e métricas com validade de construto e análise de erro; (6) LLM aberto como baseline; (7) validação humana; (8) limitações por tipo de validade e mitigações. **O TCC é do tipo "LLMs for New SE Tools" (4.2.2, geração de testes) com componente de "Benchmarking" (4.2.3, ChatGPT × Gemini).**

## 2. Checklist de relato (Apêndice C) × TCC — estado em 2026-10-07

Legenda: ✔ cumpre · ◐ parcial · ✘ não cumpre · → o que escrever / fazer.

### Introdução
| Item | Estado | → |
|---|---|---|
| Declarar qualquer uso de LLM no estudo: qual, como, onde | ◐ | Parágrafo de declaração de uso com **três papéis** (ver §3.1). Hoje só os modelos sob estudo são óbvios no texto; Claude Code e Claude in Chrome precisam entrar na Introdução/Metodologia, não nos agradecimentos |
| Propósito, tarefas automatizadas, benefício esperado | ✔ | Já é a pergunta de pesquisa |

### Desenho e métodos — modelo e configuração
| Item | Estado | → |
|---|---|---|
| Modelo/versão exatos, configuração, **data de execução** | ✔ | Tabela de versões por bloco (§3.2). Datas por rodada nos docs |
| Parâmetros padrão e justificativa da escolha de modelo/versão | ◐ | Declarar que a interface web não expõe temperatura/seed/system prompt; justificar interface web (condição do desenvolvedor sem API) e tier (gratuito/padrão) |
| Checksums; para ferramentas comerciais, reconhecer limites de reprodutibilidade | ✔ | Sem fingerprint de modelo; sha256 de todos os prompts e dos testes finais; prints do seletor (Gemini) e autodeclaração + Help Center (ChatGPT) |
| [commercial-models] LLM open-weight como baseline + concordância entre modelos | ✘ | Justificar a ausência (objeto = interface web; custo; escopo de TCC) e listar como trabalho futuro — item **5.6** |

### Desenho e métodos — sistema e prompts
| Item | Estado | → |
|---|---|---|
| Zero/one/few-shot declarado | ✔ | É a variável independente |
| Reuso de prompts entre modelos e configurações | ✔ | Byte-idênticos (sha256) nos dois modelos, nas Fases 2 e 3 |
| Setup *standalone* (prompt direto, sem pré/pós-processamento) | ✔ | Declarar explicitamente: nenhum pré-processamento; pós-processamento = salvar o bloco de código sem edição e rodar `flutter test` |
| Publicar todos os prompts (material suplementar) + exemplos representativos no texto | ✔ | 68 (Fase 2) + 9 (Fase 3) no repositório; apêndice com um ZS/FS/COT representativo |
| [few-shot] Explicar como os exemplos foram escolhidos | ◐ | Fase 3 escrito (`prompts_prontos/README.md`, 5 critérios). **Fase 2 falta**: escrever que os exemplos vieram do template do piloto, que o exemplo de integração tinha API inexistente (`MockFirebaseAuth(authExceptions:)`) e foi reescrito antes da Fase 2 (nota de protocolo dos prompts), e que o exemplo FS de unitário/widget preservou o defeito conhecido de propósito — com as 4 REEXEC como controle |
| [context-files] Descrever mecanismos de configuração (CLAUDE.md etc.) | ◐ | O **CLAUDE.md do repositório** configura o Claude Code que operou o estudo. Declarar e incluir como suplementar; não afeta os modelos sob estudo |
| [tool-use] / [agents] | ✔ (n/a aos modelos sob estudo) | ChatGPT fez busca na web por conta própria em 6 gerações E2E e em reparos da reexecução — relatar como ferramenta não controlada (§3.3) |
| [benchmarking] Harness e infraestrutura além da chamada ao modelo | ◐ | Descrever: Claude in Chrome para envio/cópia; scripts de execução; AVD + Firebase Emulator Suite + seed por REST (Fase 3); worktrees por bug |
| [long-prompts] Tratamento de entrada para prompts longos | ◐ | Declarar tamanhos (34–57 k chars no E2E; reparos até 141 k), o teste de aceitação de 29/09 e as 2 células sem dado por limite do serviço |
| Hospedagem/acesso aos modelos | ✔ | Interface web; sessão deslogada (ChatGPT) × logada (Gemini), com justificativa |
| Racional e evolução dos prompts; refinamentos sugeridos por LLM | ◐ | Escrever: piloto → Fase 2 (template de reparo em duas vias, pedido do orientador) → Fase 3 (adaptação para `integration_test`, bloco fixo de ambiente). Nenhum refinamento sugerido pelos modelos foi incorporado |
| Código sob licença aberta | ◐ | Decidir licença do repositório |

### Traces de sessão
| Item | Estado | → |
|---|---|---|
| Logs completos (prompts e respostas) como suplementar | ✔ | Transcrições íntegras por iteração, prompts de reparo literais (86/86 verificados na Fase 3), saídas de `flutter test`, URLs das conversas. Declarar o que não é observável: conversas deslogadas do ChatGPT não recuperáveis; extração por automação pode perder indentação |
| Formato de trace e versão da ferramenta | ◐ | Dizer: Markdown por iteração; sem formato aberto (OpenTelemetry) — recomendação, não requisito |

### Benchmarks e métricas
| Item | Estado | → |
|---|---|---|
| Justificar métricas; não basta "outros usaram" | ◐ | Escrever a justificativa: aprovação mede executabilidade; detecção mede o construto de interesse (o teste protege contra o defeito?); as duas são necessárias porque um teste verde pode canonizar um defeito (dado próprio: 14 canonizações, R5) |
| Validade de construto das métricas | ✔ | Já separada (C1–C6 do mapa de limitações) |
| Definição operacional do fenômeno | ◐ | Definir "detecção" pela rubrica de 5 categorias, com a regra de precedência e a equivalência Fase 2/3 |
| Capacidades que o benchmark confunde com o alvo | ◐ | Nomear: inferência de caminho de import, compilação de Dart, espera por I/O no AVD — confundem "gerar teste que detecta" com "gerar teste que roda". Reportar que 9 dos 14 "Não viu" são cenário não coberto e 4 são erro de teste anterior |
| **Análise de erro por categoria e frequência** | ✔ | Já existe nas três fases (erro de teste / geração / limitação de testabilidade / material / serviço). Levar para Resultados como tabela |
| Amostragem dos problemas (alvos, bugs) | ◐ | Alvos = todas as funções de `validators.dart` e as 3 telas com Firebase injetável; bugs = critérios de `propostas_bugs_fase2.md` + lista da Fase 3. Declarar como amostragem por conveniência e discutir generalização |
| Justificar o número de repetições | ✘ → declarar | n = 1 por célula, por custo; declarar como estudo exploratório; não reportar distribuição |
| [new-benchmark] Contaminação: held-out, canary | ◐ | Bugs plantados são inéditos por construção (equivale a held-out); verificar se o repositório do Sintonize é público (**pendência**) |
| [multi-rater] Distribuição de ratings | n/a | Avaliador único (ver Validação humana) |

### Validação humana
| Item | Estado | → |
|---|---|---|
| Definir o construto medido e o instrumento | ✔ | Construto: "o teste gerado protege contra o defeito?"; instrumento: rubrica + roteiro manual (Fase 3) + auditoria de cada (B) |
| Compartilhar o instrumento | ✔ | `roteiro_manual.md`, rubrica, `template_rodada.md` no repositório |
| LLM substituindo humano: justificar | ✔ | A autoclassificação (A)/(B) do modelo **não substitui** o humano: toda (B) foi auditada; reportar concordância classe/causa (Fase 3: ChatGPT 9/20 corretos, Gemini 17/18) |
| Concordância inter-avaliador | ✘ | Avaliador único. **Pendência**: amostra recodificada pelo orientador (18 rodadas de bug de um modelo da Fase 2) para reportar concordância |

### Resultados
| Item | Estado | → |
|---|---|---|
| Repetir experimentos e reportar distribuição | ✘ → declarar | n = 1; leituras por padrão, não por percentual |
| Baseline tradicional (não-LLM) | ◐ | Fase 3: o roteiro manual e o E2E manual de maio são a linha de base humana; os testes de referência (Claude Code interativo) são o teto de detectabilidade. Declarar os dois papéis |
| Métricas estabelecidas | ✔ | Taxa de aprovação, compilou na 1ª, iterações; detecção é métrica própria, justificada |
| [comparing-models] Estatística inferencial ao comparar modelos | ✘ → declarar | Sem teste de hipótese com n = 1 por célula; a comparação ChatGPT × Gemini é descritiva e qualitativa. Escrever isso explicitamente, com a frase do artigo ("summary statistics alone are insufficient") como motivo de não extrapolar |

### Limitações e ameaças à validade
| Item | Estado | → |
|---|---|---|
| Vazamento de dados | ◐ | Pendência: repositório público? |
| Não determinismo e generalização | ✔ | `limitacoes_validade.md` R1–R4, E1–E5 |
| Generalização entre LLMs e no tempo; diferenças de versão | ✔ | Dois modelos; troca 5.5 → 5.6; Luna × Flash |
| Estratégias de mitigação (pacote de replicação, validação humana, re-execução) | ✔ | Repositório; auditoria humana; reexecução das 15; verificação externa 0 divergências |

## 3. Textos prontos (português, para colar e ajustar)

### 3.1 Declaração de uso de LLM (Introdução ou abertura da Metodologia)

> Este trabalho envolve modelos de linguagem em três papéis distintos, relatados conforme as diretrizes de Baltes et al. (2026). (i) **Modelos sob estudo**: ChatGPT e Gemini, acessados pela interface web, geraram os testes e autoclassificaram as falhas no ciclo de reparo; são o objeto da comparação. (ii) **Apoio operacional**: o Claude Code (Anthropic) foi usado pelo autor para versionar artefatos, executar `flutter test`, aplicar os testes gerados por script sem edição, montar planilhas e documentar as rodadas; na Fase 3, escreveu também três testes E2E de referência em regime interativo, usados apenas como prova de detectabilidade dos bugs e nunca incluídos nos prompts. (iii) **Automação de envio**: a extensão Claude in Chrome colou os prompts e copiou as respostas na maior parte das rodadas, sem alterar o conteúdo. Nenhum modelo de linguagem participou da codificação de detecção nem da auditoria das autoclassificações, feitas pelo autor.

### 3.2 Versões e condições de sessão (Metodologia)

> Tabela: bloco de rodadas · modelo · versão · fonte da versão · sessão · datas.
> Fase 2 ChatGPT, 49 rodadas: GPT-5.5/5.6 (autodeclaração; sem seletor), deslogado, 2026-09-03 a 09-20. Fase 2 ChatGPT, 15 reexecutadas: GPT-5.6 Luna (autodeclaração + Help Center OpenAI, 24/09/2026), deslogado, 2026-09-24. Fase 2 Gemini, 64: Gemini 3.8 Flash (seletor, print por sessão), logado/Pro, 2026-09-2x. Fase 3: ChatGPT GPT-5.6 Luna deslogado e Gemini 3.8 Flash logado, 2026-10-02 a 10-06.
> As interfaces web não expõem temperatura, *seed*, *system prompt* nem identificador de build; a reprodutibilidade possível é a do protocolo, não a da saída (Baltes et al., 2026, diretriz 5.2). A condição de sessão difere entre os modelos por restrição prática — a sessão deslogada do Gemini não aceitava os prompts do estudo e limitava a duas respostas — e é tratada como ameaça à validade externa.

### 3.3 Prompts (Metodologia)

> Todos os prompts são publicados no repositório com sha256; cada documento de rodada registra o hash do prompt usado. Os prompts são idênticos byte a byte entre os modelos. Configuração *standalone*: o texto é colado numa conversa nova, sem pré-processamento; o pós-processamento consiste em salvar o bloco de código sem edição e executá-lo. Os exemplos few-shot foram selecionados por [critérios da Fase 2 — escrever] e, na Fase 3, por cinco critérios documentados (mesma tecnologia do alvo; fluxo que não é alvo nem compartilha o sintoma; aplicativo fictício; mesma forma nos três; sem menção a bug nem às armadilhas conhecidas), conforme a diretriz 5.3. O prompt de reparo é um template fixo com a saída literal do terminal; o operador não acrescenta informação — a única exceção, 15 rodadas da Fase 2, foi isolada e reexecutada. O ChatGPT consultou a web por iniciativa própria em algumas gerações e reparos; isso é registrado por rodada e não foi controlável na sessão deslogada.

### 3.4 Métricas e definição operacional (Metodologia)

> Duas dimensões independentes. **Executabilidade**: compilou na geração, testes passando/falhando na última execução, iterações de reparo, taxa de aprovação (passando ÷ executados; arquivo que não compila é contado à parte). **Detecção**: para cada rodada com bug plantado, o teste final e as respostas são codificados em Capturou / Caracterizou com alerta / Viu sem asserção / Canonizou / Não viu, nesta ordem de precedência, contra um oráculo (o bug plantado) e, na Fase 3, contra o roteiro manual. A separação é necessária porque um teste pode passar fixando o defeito como comportamento esperado — observamos 14 canonizações, incluindo um defeito real documentado em comentário pelo modelo. Aprovação, sozinha, mede o construto errado (Baltes et al., 2026, 5.5).

### 3.5 Resultados — frase de enquadramento

> Com uma rodada por célula (alvo × estratégia × modelo) e sem repetição, os resultados são descritivos; não aplicamos testes de hipótese nem reportamos distribuições, e as diferenças entre modelos são lidas por padrões consistentes (por exemplo, 6/6 e 0/6), não por diferenças percentuais, conforme a recomendação de Baltes et al. (2026) de não comparar modelos apenas por estatísticas resumidas.

### 3.6 Limitações — abertura

> Organizamos as ameaças segundo os quatro tipos de validade da diretriz 5.8 de Baltes et al. (2026): externa, interna, de construto e confiabilidade (tabela em `limitacoes_validade.md`, itens ●). Não incluímos um modelo open-weight como baseline (5.6) porque o objeto do estudo é a interface web tal como o desenvolvedor sem API a encontra; registramos como trabalho futuro.

## 4. Onde citar

Introdução (reprodutibilidade; Angermeir et al. via Baltes) · Metodologia (abertura: tipo de estudo 4.2.2 + 4.2.3; §3.1–3.4) · Resultados (análise de erro por categoria; §3.5) · Limitações (§3.6) · Trabalhos relacionados (Schäfer et al./TestPilot como exemplo de 4.2.2 citado pelo artigo).

## 5. Pendências acumuladas (resolver no final)

1. Repositório do Sintonize é público? (I9 / vazamento)
2. Concordância inter-avaliador: amostra recodificada pelo Cleyton (C2).
3. Fase 2: escrever como os exemplos few-shot foram selecionados (5.3).
4. Licença do repositório (código sob licença aberta).
5. Incluir CLAUDE.md e scripts como material suplementar declarado.
6. Coluna "Ajuda de import" da planilha Gemini (lista dos 10 prompts).
7. Referência E2E ("trabalho da Gabi") — localizar ou usar GPTDroid/DroidAgent/QTypist.
8. Trilha (Ciência × Tecnologia) e aprovação do formato SBC.
9. Decidir se R1–R5 viram issues no repositório do Sintonize.
