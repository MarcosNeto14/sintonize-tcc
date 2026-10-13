# Limitações do estudo por tipo de validade (estrutura de Baltes et al., 2026, diretriz 5.8) — v1, 2026-10-07

Junta as listas das três fases (comparação ChatGPT × Gemini §4; README da Fase 3 "Limitações e desvios"; consolidado da Fase 3 §7) nas quatro categorias que o artigo pede, com a mitigação adotada e o que fica em aberto. Cada linha aponta o artefato que a sustenta. Itens marcados ● são os que o texto não pode omitir; ○ são secundários (podem ir para apêndice ou para uma frase).

---

## 1. Validade externa — até onde os resultados generalizam

| # | Limitação | Evidência | Mitigação adotada | Em aberto |
|---|---|---|---|---|
| E1 ● | **Condições de sessão distintas entre modelos**: ChatGPT deslogado (GPT-5.5/5.6 nas 49 originais, GPT-5.6 Luna nas 15 reexecutadas e nas 36 E2E — "fastest and lowest-cost" segundo o Help Center da OpenAI, 2026-09-24); Gemini logado Pro, 3.8 Flash. Não é carro-chefe × carro-chefe. | docs de rodada (campos ✦), NOTA_BLOQUEIO, prints do seletor | Mesma versão dentro de cada modelo em cada fase; tentativa deslogada do Gemini registrada e abortada (prompt grande não aceito, ≤ 2 respostas); troca para Luna percebida e declarada | A comparação entre modelos é entre *produtos como o usuário gratuito/padrão os encontra*, não entre modelos de mesma classe |
| E2 ● | **Instabilidade temporal dos modelos proprietários**: ChatGPT mudou de 5.5 para 5.6 durante a Fase 2 sem aviso; nenhuma das interfaces expõe fingerprint, temperatura ou seed | tabela de versões por bloco de rodadas | Data por rodada; autodeclaração + fonte externa; prompts e respostas íntegros versionados | Replicação exata é impossível; só replicação do protocolo |
| E3 ● | **Um aplicativo, um framework**: Sintonize (Flutter + Firebase), com acoplamento estático ao Firebase e validadores duplicados nas telas | T1 do relatório de bugs; `U-CRASH/U-SILENT` só unitários | Três níveis + E2E no mesmo app, para que o efeito do nível seja observável | Generalização a outros stacks é hipótese |
| E4 ○ | **Sem baseline de modelo aberto** (diretriz 5.6) | — | Justificado: o objeto é a interface web usada por desenvolvedores sem API | Trabalho futuro |
| E5 ○ | **Transferência entre modelos** só com dois modelos e n = 1 por célula | pirâmide unificada | Dois modelos cobrem o item mínimo do artigo | Mais modelos, repetições |

## 2. Validade interna — causas alternativas para o que observamos

| # | Limitação | Evidência | Mitigação adotada | Em aberto |
|---|---|---|---|---|
| I1 ● | **Execução assistida**: 15 rodadas de bug do ChatGPT na Fase 2 receberam informação do operador no reparo | `fase2/_execucao-assistida/`, aba "Assistida (ref.)" | **Reexecução integral** das 15 com template fixo (2026-09-24); as originais preservadas fora da contagem; delta medido (107 → 40 testes passando; detecção praticamente igual) | Duas versões do ChatGPT dentro da Fase 2 (49 + 15) |
| I2 ● | **Material de prompt divergente do app**: prompt do I-CRASH com `SwitchListTile` e 4 campos quando a tela tinha 10 e `Switch` | 4 REEXEC; 3 (B) confabulados | REEXEC com prompt corrigido, fora das 60; declarado | I-CRASH original é irrecuperável sem ajuda (0/6) |
| I3 ● | **Caminho de import ausente nos prompts FS** da Fase 2; **`material.dart`/imports de tela** nas gerações E2E do ChatGPT | 4 + 5 rodadas FS sem compilar (Fase 2); 9/16 gerações sem compilar (Fase 3 ChatGPT) | Igual para os dois modelos; contado à parte da taxa | FS × demais mede ausência de material tanto quanto estratégia |
| I4 ● | **Dois regimes de autoria no E2E**: testes de referência escritos pelo Claude Code em regime interativo; rodadas sob protocolo | `integration_test/_referencia/`, declaração no README | Referência isolada, nunca em prompt; usada só como teto de detectabilidade e custo | — |
| I5 ○ | **Três rodadas limpas do ChatGPT** (WIDGET-ZS-02, WIDGET-COT-01, INT-FS-01) com contexto extra no reparo; INT-FS-01 com iteração revertida | docs das rodadas | Declarado; não reexecutado (alvos limpos, sem efeito na detecção) | — |
| I6 ○ | **Consulta à web pelo ChatGPT** em reparos da reexecução e em 6 gerações E2E (5 COT); Gemini nunca | marcadores de fonte nas respostas | Registrado por rodada | Não controlável deslogado; confunde "estratégia COT" com "COT + busca" |
| I7 ○ | **Operação em duas máquinas** na Fase 3; 3 rodadas Gemini trocaram de máquina no meio | README Fase 3 | Anotado por rodada; FS-02 marcada como verde intermitente | — |
| I8 ○ | **Automação de envio** (Claude in Chrome) com interrupções do serviço; perda de indentação possível na extração | `_abortadas/`, botão "Copiar código" | Tentativas abortadas versionadas; regra "3ª tentativa sem resposta → autor decide" | — |
| I9 ○ | **Vazamento/contaminação**: o Sintonize é público? Os modelos podem ter visto o código | — | Não verificável; bugs plantados são inéditos por construção | Declarar |

## 3. Validade de construto — as métricas medem o que dizemos

| # | Limitação | Evidência | Mitigação adotada | Em aberto |
|---|---|---|---|---|
| C1 ● | **Aprovação ≠ correção**: um teste verde pode fixar um defeito como comportamento esperado | Canonizou = 7 + 7 na pirâmide; R5 canonizado com comentário | Duas dimensões separadas desde o desenho: taxa de aprovação **e** detecção codificada manual-first; bugs plantados como oráculo | — |
| C2 ● | **Detecção é codificação humana de um único avaliador** (o autor), sobre prosa e código | rubrica em 5 categorias; `roteiro_manual.md` | Rubrica escrita antes; verificável contra o código ((B) procede?); auditoria externa de pass/fail (0 divergências nas 3 fases) | Sem concordância inter-avaliador (α de Krippendorff); amostra para o orientador |
| C3 ● | **Rótulos de rubrica mudaram de significado entre fases** ("Viu sem asserção" → "Chegou sem afirmar") | nota de equivalência no consolidado da Fase 3 | Mapeamento explícito; 1 rodada afetada (Gemini C3-COT = Não viu) | — |
| C4 ○ | **"Gerados"** conta a geração inicial; suítes substituídas no reparo (W-SILENT-ZS 14 → 8) e divididas (ZS-02 E2E 4 → 5) distorcem a taxa por teste | planilhas | Leitura por rodada ("verdes") como medida principal | — |
| C5 ○ | **Autoclassificação (A)/(B)** mede o que o modelo *declara*, não o que ele *faz*: (B) sem código → reexecução inalterada; (B) com classe certa e causa errada | Fase 3 §3: 20 e 18 (B), 11 e 1 falsos | Auditoria de cada (B); "classe" e "causa" separadas | — |
| C6 ○ | **Bugs plantados são 9 e escolhidos pelo autor** (com apoio do CLI); cobrem CRASH/SILENT por nível, não a distribuição real de defeitos | `propostas_bugs_fase2.md`, lista da Fase 3 | Critérios de escolha registrados; 5 defeitos reais não plantados como contraprova | — |

## 4. Confiabilidade — repetir daria o mesmo?

| # | Limitação | Evidência | Mitigação adotada | Em aberto |
|---|---|---|---|---|
| R1 ● | **n = 1 por célula** (alvo × estratégia × modelo); sem repetição e sem estatística inferencial | desenho | Declarado como estudo de caso exploratório; nenhum teste de hipótese; leituras por padrão (6/6, 0/6), não por diferença de percentuais | Repetições por célula |
| R2 ● | **Não determinismo dos modelos**: mesma entrada, saídas diferentes (ZS-01 limpa × L4-ZS Gemini: mesmo prompt, estruturas próximas e asserções diferentes) | docs | Prompts byte-idênticos (sha256); conversa nova por rodada | — |
| R3 ● | **Não determinismo do E2E**: mesma suíte, resultados diferentes (ChatGPT COT-02 6/11 e 4/11; Gemini FS-02 0/1 → 1/1 entre máquinas) | README Fase 3 (b) | Regra escrita: resultado = execução única registrada; instabilidade anotada | Novo em relação à Fase 2, onde `flutter test` era determinístico |
| R4 ● | **Limites do serviço gratuito**: 2 células do ChatGPT E2E sem dado (prompt ≥ 50 k chars; reparo de 58 k vazio ×3); recusas do Gemini (21 em 17 rodadas na Fase 2; ZS_REEXEC perdida) | `_PENDENTE` → fechamento, prints | Categoria "sem dado por limitação do serviço", fora da contagem; sem logar nem filtrar para não mudar a condição | A interface gratuita é parte da condição experimental |
| R5 ○ | **Dependência de infraestrutura**: AVD, Firebase Emulator, ViaCEP real (rede externa), Gradle; custo fixo medido (132 s boot, 362 s primeiro build) | `custo_e_referencia.md` | Ambiente declarado (versões, AVD, flags); seed conferido por REST antes de cada execução | — |
| R6 ○ | **Pacote de replicação**: repositório com prompts, transcrições, saídas, testes e planilhas; conversas deslogadas do ChatGPT não recuperáveis | README de cada fase | Transcrições íntegras versionadas no momento | — |

---

## Como isso vira texto

- **Seção "Ameaças à validade"** com os quatro subtítulos do artigo, só com os itens ●, uma frase cada + mitigação. Cita Baltes et al. (2026) na abertura: "organizamos as ameaças segundo a diretriz 5.8".
- **Apêndice "Desvios e ocorrências"** com a tabela completa (● e ○) e os apontadores para o repositório.
- **Três frases que o texto precisa ter literalmente:** (1) os resultados comparam os produtos ChatGPT e Gemini nas condições em que o desenvolvedor sem API os encontra, não os modelos em paridade de tier; (2) taxa de aprovação e detecção são dimensões independentes e um texto que reportasse só a primeira concluiria o oposto do que a segunda mostra; (3) toda codificação de detecção é de um único avaliador, verificável contra o código e as saídas versionadas.
- **Ligação com a diretriz 5.1 (declarar uso de LLM):** três papéis — LLMs sob estudo (ChatGPT, Gemini), LLM de apoio operacional (Claude Code: documentação, execução, patches por script, testes de referência do E2E) e automação de envio (Claude in Chrome). Entra na Metodologia, não nos agradecimentos.
