# ChatGPT × Gemini — comparação das 60 rodadas da Fase 2, mesmo protocolo (v2, 2026-09-25)

Base: `fase2/` (42 limpas + 7 bugs originais do ChatGPT), `fase2-chatgpt-reexec/` (15 bugs do ChatGPT reexecutados em 2026-09-24 com reparo fixo, GPT-5.6 Luna, deslogado) e `fase2-gemini-consolidado/` (3.8 Flash, logado). Pass/fail final cruzado com a última saída de `flutter test` nos três conjuntos: **0 divergências**. Os 39 prompts de reparo da reexecução foram conferidos literalmente: só o template + a saída do terminal. Planilha: `Comparacao_ChatGPT_x_Gemini_60rodadas.xlsx` (abas Pareado, Consolidado, Bugs plantados, Assistida (ref.), Assimetrias, Perguntas).

Esta versão substitui a anterior. O que mudou: as 15 rodadas de bug do ChatGPT que tinham reparo enriquecido pelo operador saíram da comparação e entraram as reexecutadas com o protocolo da réplica. A execução assistida fica em `fase2/_execucao-assistida/` e na aba "Assistida (ref.)", só para as limitações.

Regras: REEXEC fora das 60; formatName em grupo próprio; limpos = 39; bugs = 18. "Taxa" = passando ÷ (passando + falhando) nas rodadas que executam; arquivo que não compila conta 0 passando. "Gerados" = contagem da geração inicial.

---

## 1. Números

### Alvos limpos (39 rodadas cada) — inalterado

| | ChatGPT | Gemini |
|---|---|---|
| Gerados / passando | **576** / 529 | 376 / 342 |
| Taxa (executados) | 96,0% | 94,0% |
| Rodadas 100% verdes | 26 | **31** |
| Compilou na 1ª | 25 | **31** |
| Iterações / no máximo | 50 / 13 | 39 / 10 |

Por nível (gerados, taxa): unitário 374 × 264 (99,7% × 100%); widget 152 × 71 (89% × 78%); integração 50 × 41 (86% × 79%). Por estratégia: ZS 201 × 147, FS 113 × 82, COT 262 × 147.

### Bugs plantados (18 rodadas cada) — ChatGPT agora com reparo fixo

| | ChatGPT | Gemini |
|---|---|---|
| Gerados / passando | 183 / 113 | 119 / 102 |
| Taxa (executados) | 84,3% | 87,2% |
| Rodadas 100% verdes | 8 | 11 |
| Compilou na 1ª | 10 | 12 |
| Arquivo final não compila | **4** (W-CRASH-FS, W-SILENT-FS, W-SILENT-COT, I-SILENT-FS) | 1 (I-SILENT-FS) |
| Iterações / no máximo | 28 / 9 | 21 / 4 |
| **Viu o bug** (mencionou como defeito/suspeita) | **12/18** | 8/18 |
| Asserção que falharia se o bug fosse corrigido, com alerta | **11/18** | 5/18 |
| Canonizou sem alerta | 2 | 5 |
| Não viu | 4 | 5 |
| (B) sobre bug plantado que procede | 1 (I-CRASH-ZS) | 1 (I-CRASH-COT) |
| (B) que não procedem | 1 | 2 |

Por bug (codificação uniforme, pelo código e pelas respostas literais):

| Bug | ChatGPT (reparo fixo) | Gemini |
|---|---|---|
| U-CRASH | caracterizou c/ alerta ZS/COT; FS capturou por falha e manteve — 3/3 | caracterizou ZS/COT; FS só em prosa — 2/3 |
| U-SILENT | caracterizou ×3 | caracterizou ×3 |
| W-CRASH | não viu ×3 (FS não compila; COT 20/21) — viu o I-SILENT vizinho em FS e COT | não viu ×3 |
| W-SILENT | **viu e nomeou nas 3**, fixou o par trocado (ZS 7/8; FS e COT não compilam) | fixou sem nomear nas 3 (10/11, 9/9 s/ cópia, 9/10) |
| I-CRASH | ZS viu, (B) correto na it. 3, teste acomoda; FS não viu, (B) errado; COT canonizou — 0/3 exercitou | ZS/FS não viu, (B) confabulados; COT canonizou e nomeia — 1/3 exercitou |
| I-SILENT | ZS/FS caracterizou c/ alerta (FS não compila); COT canonizou e proíbe o nome digitado | ZS/FS viram sem asserção; COT canonizou |

REEXEC (fora das 60): ChatGPT capturou o I-CRASH por asserção em ZS_REEXEC (intencional, (B) correto mantido) e em COT_REEXEC (por acidente, num teste de falha do Firestore sem `signedIn`); W-SILENT-FS_REEXEC canonizou sem menção e não compilou; FS_REEXEC não escreveu o cenário. Gemini: COT_REEXEC canonizou e nomeou; ZS_REEXEC não executou (2 recusas); FS_REEXEC não escreveu o cenário; W-SILENT-FS_REEXEC canonizou e não compilou.

---

## 2. O que a reexecução mudou — e o que não mudou

**Mudou a aprovação, não a detecção.** Nas 15 rodadas, a execução assistida somava 107 testes passando; a reexecução, 40 (aba Assistida (ref.)). Quatro rodadas que fechavam em 15/15, 9/10, 16/19 e 2/2 terminaram sem compilar. Esse delta é o tamanho da ajuda do operador. Mas a detecção do ChatGPT quase não se moveu: W-SILENT continuou visto e fixado nas 3; I-SILENT continuou visto nas 3; W-CRASH continuou invisível; I-CRASH-ZS continuou com (B) correto na it. 3. A única perda real foi em I-CRASH: sem os 10 campos reais e o `Switch` fornecidos pelo operador, o bug não foi exercitado em nenhuma das 3 originais (antes, ZS e COT o expunham por falha).

**O que a reexecução acrescentou de dado:** o ChatGPT, sem ajuda, prefere parar a chutar — pediu o caminho do arquivo em 4 rodadas FS e, em 2 delas, recusou explicitamente inventar outro ("não seria correto inventar outro caminho"); o Gemini, nas mesmas rodadas, tentou 3 caminhos e colou o widget no teste. Resultado idêntico (não compila), comportamento oposto.

---

## 3. Leituras

**3.1 Aprovação equivalente, diagnóstico diferente — agora sem a ressalva do reparo.** Limpos 96% × 94%; bugs 84% × 87%; suítes verdes 34 × 42 a favor do Gemini. Detecção: viu 12/18 × 8/18, asserção com alerta 11/18 × 5/18. Um texto que comparasse por taxa diria "equivalentes, Gemini um pouco mais limpo"; por detecção, o ChatGPT vê mais e diz mais. Mesma lição do estudo principal, entre modelos.

**3.2 W-SILENT é o divisor.** É o único bug em que os dois modelos escreveram o mesmo teste (um por código de erro) e chegaram a desfechos diferentes na prosa: o ChatGPT disse em 10 das 12 respostas das 3 rodadas que as mensagens pareciam invertidas; o Gemini não disse em nenhuma, nem com o prompt COT que manda listar cada mensagem. Nenhum dos dois converteu a suspeita em asserção — os dois fixaram o par trocado. A diferença entre os modelos está em enxergar uma contradição semântica, não em agir sobre ela.

**3.3 Canonização é o modo de falha dos dois, e o ChatGPT a faz de forma mais consciente.** Gemini: 5 canonizações sem alerta. ChatGPT: 2 sem alerta, mas 10 caracterizações "com alerta" — o modelo escreve que é defeito e, na mesma resposta, fixa o defeito como esperado, às vezes com justificativa explícita ("o teste deve registrar o comportamento atual", "não vou inverter as asserções"). Em I-SILENT-COT chegou a acrescentar `isNot(equals('Playlist de Teste'))`: proíbe o comportamento correto. Para o texto: "viu" e "protegeu" não são exclusivos; o prompt de reparo proíbe enfraquecer asserção sob (B), mas nada diz sobre a geração inicial, que é onde a canonização nasce — e em ZS/COT de I-SILENT a suíte passa de primeira e o reparo nunca é acionado.

**3.4 O ciclo de reparo, sem operador, regride mais no ChatGPT.** Nas 15 reexecutadas, 7 iterações pioraram o estado (arquivo que compilava deixou de compilar): patches parciais que deixaram o arquivo em estado misto (W-SILENT-COT), bloco terminado em `),` (W-CRASH-COT), redeclaração de variável (I-CRASH-COT), erro de tipo em arquivo completo. O Gemini regrediu em 3 rodadas limpas (INT-COT-01, INT-ZS-02, ICRASH-FS_REEXEC). O ChatGPT também substituiu suítes inteiras por versões menores (W-SILENT-ZS 14→8) e propôs alterar `pubspec.yaml` e `login.dart` em 4 rodadas — nada aplicado.

**3.5 FS sem caminho de import é um beco nos dois.** ChatGPT: 4 rodadas FS sem compilar; Gemini: 5. Em nenhum caso o modelo tentou a raiz de `lib/`. A comparação FS × demais no widget e na integração mede a ausência do caminho tanto quanto a estratégia; declarar.

**3.6 I-CRASH com prompt original é irrecuperável sem ajuda.** 0/6 rodadas originais exercitaram o bug nos dois modelos; as duas únicas exposições (ChatGPT ZS_REEXEC e COT_REEXEC) vieram com o prompt corrigido — e o Gemini perdeu a ZS_REEXEC por recusa. O material divergente (`SwitchListTile`, 4 campos) também é a origem dos 3 (B) confabulados (Gemini ZS/FS, ChatGPT FS).

**3.7 Volume.** O ChatGPT gera 1,5× mais nos limpos e nos bugs (183 × 119); por rodada, mais em 45 das 60 (empate 6, Gemini 9), e isso não vira aprovação. Suítes maiores tocam mais vezes na `TelaInicialScreen` e no viewport.

**3.8 Achados reais não plantados** (para o relatório de bugs): `TelaInicialScreen` acoplada ao Firebase global — diagnosticada como (B) ou limitação em 9 rodadas do Gemini e em pelo menos 8 do ChatGPT; `validateEmailLogin` sem âncora (ChatGPT UNIT-COT-06, (B) mantido); `artist_name` nulo em `criar_playlist.dart:169-170` (ChatGPT WIDGET-FS-03); item `PE` do dropdown de Estado não localizável em teste (ChatGPT I-CRASH REEXEC ×3, ZS_REEXEC original) — este último é limitação de testabilidade, não bug.

---

## 4. Limitações a declarar

1. Execução assistida: 15 rodadas de bug do ChatGPT foram reexecutadas em 2026-09-24 porque o reparo original recebeu informação do operador; as originais estão preservadas em `fase2/_execucao-assistida/`. Delta: 107 → 40 testes passando; detecção praticamente igual.
2. Duas versões no ChatGPT: GPT-5.5/5.6 (autodeclaração, sem seletor) nas 49 originais; GPT-5.6 Luna (autodeclaração + Help Center, print por rodada) nas 15. Gemini 3.8 Flash em todas.
3. Tier: ChatGPT deslogado recebe Luna, "fastest and lowest-cost" da família (Help Center, 2026-09-24); Gemini logado em 3.8 Flash, padrão do produto. Não é carro-chefe × carro-chefe.
4. Três rodadas limpas do ChatGPT (WIDGET-ZS-02, WIDGET-COT-01, INT-FS-01) tiveram contexto extra no reparo a pedido do modelo; INT-FS-01 teve uma iteração revertida.
5. Perguntas do modelo ao operador não respondidas nos dois lados — bloqueio por informação de ambiente ausente em 4 (ChatGPT) e 5 (Gemini) rodadas FS.
6. O ChatGPT fez busca na web por conta própria em vários reparos da reexecução; não controlado.
7. Recusas: 21 em 17 rodadas no Gemini, 0 no ChatGPT.
8. A planilha `Fase2_Consolidado_60rodadas.xlsx` do autor conta as REEXEC no lugar das originais; alinhar.
