# Réplica Fase 2 — Gemini 3.8 Flash: consolidado e leituras

Base: `fase2-gemini-consolidado` (2026-09-24). 64 docs de rodada, 134 saídas de `flutter test`, 70 arquivos de teste. Todos os números abaixo foram cruzados com a última saída de `flutter test` de cada rodada (0 divergências) e com a contagem de `test(`/`testWidgets(` nos arquivos gerados. Planilha: `Fase2_Gemini_Consolidado_60rodadas.xlsx` (abas Rodadas, Consolidado, Bugs plantados, Classificações, Ocorrências).

Regras aplicadas: REEXEC fora das 60; formatName em grupo próprio (não é limpo); alvos limpos = 39 (21 unit + 9 widget + 9 int); bugs plantados = 18. "Passando (final)" é o estado arquivado após a última iteração — arquivo que não compila conta 0.

---

## 1. Tabela consolidada

### 1a. Alvos limpos (39 rodadas)

| Nível | Estr. | Rodadas | Gerados | Passando | Aprov. | 100% verdes | Compilou 1ª | Iter. usadas | No máx. (3) | Tentativas | Recusas | Autoclassificações (e se procedem) |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Unitário | ZS | 7 | 114 | 114 | 100% | 7 | 7 | 1 | 0 | 11 | 4 | (A) ×1 — procede |
| Unitário | FS | 7 | 53 | 53 | 100% | 7 | 7 | 0 | 0 | 9 | 2 | — |
| Unitário | COT | 7 | 97 | 97 | 100% | 7 | 7 | 1 | 0 | 12 | 4 | (A) ×1 — procede |
| Widget | ZS | 3 | 19 | 19 | 100% | 3 | 3 | 5 | 1 | 4 | 0 | (A)(A) · (B)+(A),(A),(A) — (B) procede mas o teste foi removido |
| Widget | FS | 3 | 21 | 21 | 100% | 3 | 3 | 3 | 0 | 6 | 3 | (A)(A) · (B)+(A) — procedem; (B) com teste mantido |
| Widget | COT | 3 | 31 | 15 | 48% | 0 | 0 | 9 | 3 | 7 | 3 | (A)(A)(A) · (A),(A)+(B),(B) · (A)(A)(A) — procedem na categoria |
| Integração | ZS | 3 | 14 | 9 | 64% | 1 | 1 | 6 | 2 | 3 | 0 | (A)(A)(A) · (A)(A)(A)* — *3ª erra o alvo |
| Integração | FS | 3 | 8 | 3 | 38% | 1 | 1 | 6 | 2 | 4 | 1 | (A)(B)(B) · (A)(A)(A) — procedem |
| Integração | COT | 3 | 19 | 11 | 58% | 2 | 2 | 8 | 2 | 3 | 0 | (A)(A)(A) · (B)(A)(A) · (A)(A) — procedem |
| **Total** | | **39** | **376** | **342** | **91%** | **31** | **31** | **39** | **10** | **59** | **17** | |

Por estratégia (todos os níveis): ZS 147 gerados / 142 passando (97%), FS 82 / 77 (94%), COT 147 / 123 (84%). FS gera **56%** do volume de ZS e COT.

### 1b. Bugs plantados (18 rodadas) — aprovação **não** mede detecção

| Nível | Estr. | Gerados | Passando | Iter. | Tent. | Autoclassificações | Detecção |
|---|---|---|---|---|---|---|---|
| Unitário | ZS | 18 | 18 | 0 | 2 | (C)(C) — procedem | U-CRASH e U-SILENT com asserção |
| Unitário | FS | 11 | 11 | 0 | 2 | (C)(C) — procedem | U-CRASH só em prosa; U-SILENT com asserção |
| Unitário | COT | 18 | 18 | 0 | 3 (1 recusa) | (C)(C) — procedem | ambos com asserção |
| Widget | ZS | 16 | 15 | 2 | 3 (1 recusa) | (A),(B) — procedem; (B) não é o bug | W-CRASH não visto; W-SILENT canonizado |
| Widget | FS | 14 | 12 | 5 | 2 | (A)×3 · (A)(A) — categoria correta, correção descaracteriza o teste | não visto; canonizado sobre cópia |
| Widget | COT | 19 | 18 | 1 | 2 | (B) — procede; não é o bug | não visto; canonizado |
| Integração | ZS | 7 | 3 | 4 | 2 | (A)(A)(B) · (A) — **(B) não procede** | I-CRASH não visto; I-SILENT visto em prosa |
| Integração | FS | 6 | 1 | 5 | 2 | (A)(A)(B) · (A)(A) — **(B) não procede** | não visto; visto em prosa |
| Integração | COT | 10 | 6 | 4 | 2 | (A)(A)(B) · (A) — (B) 2/3 itens, **nomeia o bug** | I-CRASH canonizado; I-SILENT canonizado |

Desfecho por bug (6 × 3 estratégias):

| Bug | ZS | FS | COT | Capturado por asserção |
|---|---|---|---|---|
| U-CRASH | (C) + asserção | (C) só prosa | (C) + asserção | 2/3 |
| U-SILENT | (C) + asserção | (C) + asserção | (C) + asserção | 3/3 |
| W-CRASH | não visto | não visto | não visto | 0/3 |
| W-SILENT | canonizado | canonizado (cópia) | canonizado | 0/3 |
| I-CRASH | não visto, (B) confabulado | não visto, (B) confabulado | canonizado, (B) nomeia | 0/3 |
| I-SILENT | visto, não testado | visto, não testado | canonizado | 0/3 |

Totais: **5/18** capturados com asserção (todos unitários), 1 visto só em prosa, 2 vistos e não testados, **5 canonizados** (suíte verde que defende o bug), 5 não vistos.

### 1c. formatName (3 rodadas, bug nativo): 24 gerados, 24 passando, 0 reparos. ZS canoniza o `RangeError` em 3 testes, COT em 2, FS descreve em prosa e não testa. Mesmo padrão de U-CRASH (é a mesma classe de defeito).

### 1d. Reexecuções (fora das 60): WSILENT-FS 0/9 (nunca compilou, canonizado); ICRASH-ZS **não executada** (2 recusas ao prompt de 27 mil chars); ICRASH-FS 0/2 final (melhor 1/2; resposta truncada trocou (B) correto por (A) errado); ICRASH-COT 4/8, (B) nomeia o bug e o teste ainda exige o crash. O material corrigido resolveu compilação e seletores; **não mudou nada na detecção**.

---

## 2. Leituras que os números sustentam

### 2.1 Aprovação e diagnóstico são dimensões que se cruzam em sentido oposto

Quatro casos onde ranking por aprovação inverte o ranking por entendimento:

- **loginFlow (52–54):** aprovação ZS 6/7 > FS 0/4 > COT 0 (não carrega). Diagnóstico: só a FS chegou ao (B) da `TelaInicialScreen` (iter 2) e manteve o teste vermelho; a ZS gastou as 3 iterações em problemas próprios e nunca classificou o `[core/no-app]`; a COT perseguiu o mock da plataforma até o arquivo não carregar. Ressalva ao FS: deixou um (A) próprio (mock manual) sem corrigir — o 0/4 não é todo atribuível ao (B).
- **U-CRASH (1–3):** três suítes 100% verdes e três (C). Mas a FS é (C) só em prosa: 0 asserções tocam o bug. Corrigir o U-CRASH quebraria ZS e COT (sinal correto) e passaria invisível pela FS.
- **W-SILENT (10–12):** 10/11, 9/9, 9/10. Quanto maior a aprovação, mais firmemente o par de mensagens trocado está fixado como especificação. A FS, 9/9, testa uma cópia colada no arquivo — nem a aplicação testa.
- **LoginScreen limpo (46–48):** mesmo (B) correto nas três; ZS remove o teste (8/8), FS contorna no ambiente e mantém (9/9), COT mantém vermelho e explica (10/11). Só a COT cumpre o protocolo à letra; a FS é a mais útil como teste; a ZS tem a melhor aprovação e reduziu escopo.

Consequência para o texto: reportar sempre duas colunas — aprovação final e "asserção que captura / (B) que procede" — e nunca ordenar estratégias pela primeira sozinha.

### 2.2 Detecção depende de haver incoerência local e sintaticamente visível no material, não do nível em si

6/6 no unitário, 0/6 no widget, 0/6 capturado na integração (1 nomeado). Nos dois bugs detectados havia texto afirmando X ao lado de código fazendo não-X em 10 linhas (docstring "trata palavras vazias" × `word[0]`; "mínimo 6" × `< 7`). Nos quatro não detectados, ou a contradição está a 100 linhas de distância (`??` no `itemBuilder`, ausente no filtro), ou é puramente semântica (`user-not-found` × frase em português), ou exige um dado que não é o dado óbvio (documento sem `artist_name`; usuário deslogado). A W-SILENT-COT é o caso-limite: o prompt mandava listar cada código de erro com sua mensagem, o modelo listou o par invertido em linhas consecutivas e chamou de "correta". O passo de análise transcreveu, não avaliou.

A degradação é progressiva: no unitário detecta antes de testar; no widget escreve o teste certo com o dado errado (W-CRASH) ou fixa o defeito (W-SILENT); na integração deixa de escrever o teste pedido (I-CRASH ZS/FS, mesmo com "usuário não autenticado" no requisito).

### 2.3 Canonização é o modo de falha dominante — e é pior que não-detecção

5/18 rodadas de bug terminaram com suíte verde que **exige** o comportamento defeituoso (W-SILENT ×3, I-CRASH-COT, I-SILENT-COT), mais 2 de 3 do formatName. Em I-CRASH-COT (e no REEXEC) o texto da mesma resposta chama o `currentUser!` de defeito e o teste espera o `TypeError`. O modelo trata o código recebido como especificação; onde nada no material diz qual é o comportamento pretendido, visibilidade não basta — I-SILENT foi o bug mais visto (3/3 mencionaram) e o menos pego (0/3).

Sobre o prompt de reparo: **zero enfraquecimentos sob (B)** em 60 rodadas, como no ChatGPT. Mas há 2 enfraquecimentos sob (A) (I-CRASH-COT iter 2: `isA<TypeError>` → `isNotNull`; I-SILENT-ZS: `contains` → `isNotEmpty`), 1 remoção de teste após (B) (WIDGET-ZS-02) e 2 casos de "trocar o sujeito do teste" (W-CRASH-FS e W-SILENT-FS colaram o widget dentro do arquivo de teste — suíte compila, passa e não importa nada de `package:sintonize`). O prompt protege a asserção; não protege o alvo nem o escopo.

### 2.4 Estratégias

- **Volume:** ZS e COT empatam (147 testes cada nos limpos); FS gera 56% disso. No unitário, FS espelha a estrutura enxuta dos exemplos (5–9 testes).
- **Custo de reparo:** COT usa mais iterações (18 nos limpos vs 12 ZS e 9 FS) e tem mais rodadas no máximo (5 vs 3 e 2). Nos limpos de widget, COT compilou de primeira em 0/3 (mocks gerados com `.mocks.dart` de nome presumido; mock de asset inventado na 45).
- **Few-shot ancora forma, não valores.** Hipótese das rodadas 2 e 5 (exemplos só com `isNull`/`isNotNull` afastam `throwsA`) sobrevive no unitário: U-CRASH-FS não testou a exceção; U-SILENT-FS, cuja asserção necessária era comparação de string, capturou. Mas W-SILENT-FS e I-SILENT-FS tinham nos exemplos **exatamente a asserção que exporia o bug** e a descartaram, copiando o resto do padrão (inclusive a API inexistente). Quando exemplo e código discordam, o código vence sem aviso.
- **A comparação FS × demais está contaminada no widget/integração:** todo prompt FS vem sem a linha de import. Cinco rodadas FS travaram nisso (8, 11, 14, 17, REEXEC W-SILENT); o modelo deriva o nome do arquivo do nome da classe e nunca tenta a raiz de `lib/`. A única FS que acertou o import (14) tinha o caminho num cabeçalho de comentário do prompt. Declarar como limitação herdada da Fase 2.
- **COT é a única que exercitou o I-CRASH** (a lista obrigatória de cenários incluiu "não autenticado"; ZS tinha o mesmo requisito em prosa e não gerou) e a única que venceu a parede da `TelaInicialScreen` na integração (57, com (B) seguido de contorno legítimo). Também é a que mais produz respostas malformadas/reiniciadas no bloco de integração.

### 2.5 O caminho (B): 12 declarados, 2 não procedem, 1 nomeia um bug plantado

Divisor claro: o (B) acerta quando a evidência vem do app real (stack trace apontando `tela-inicial.dart:43` ou `generos-cadastro.dart:44`) e erra quando vem só do snippet do prompt. Os dois (B) que não procedem (13, 14) são das rodadas com material divergente do app, e vêm bem argumentados — prescrevem como correção o que `lib/cadastro.dart` já faz. Um (B) errado é um laudo, não um patch; para o texto, isso qualifica o valor do caminho (B): útil na medida em que o modelo enxerga a aplicação.

O achado colateral mais consistente da réplica é a `TelaInicialScreen` (acesso estático a `FirebaseAuth.instance` no `initState`): diagnosticado como (B) em 10, 12, 15, 46, 47, 48, 53, 57 e REEXEC — 9 vezes, em conversas independentes, nas três estratégias. Não é plantado; é limitação de testabilidade real e pré-existente, e derrubou 4 das 6 rodadas de loginFlow/cadastroFlow limpas.

### 2.6 Custos fixos do protocolo (independem do modelo)

- `.mocks.dart` com nome presumido queima a iteração 0 (48, 51, 52 — e a INT-COT-02 do ChatGPT): o nome do arquivo de teste é decidido pelo operador depois da geração.
- Viewport 800×600 (43, 46, 13–15): botões fora da área de toque.
- Ajuda de import: o lote CriarPlaylistScreen/playlistFlow (6 rodadas limpas) fechou 5 sem reparo e 100% em todas — é o alvo que teve 0% na Fase 1. Mede o prompt corrigido, não o modelo. Empate perfeito com o ChatGPT na 58.
- ViaCEP: apareceu só na 57 (SnackBar do ViaCEP por cima da esperada — diagnosticado e contornado pelo modelo) e na 45 (mock HTTP à mão). Nas demais o modelo simplesmente não testou o CEP.

### 2.7 Ruído operacional — divergência com o LEIA-PRIMEIRO

O LEIA-PRIMEIRO fala em "duas recusas genéricas". Os docs registram **21 recusas em 17 das 60 rodadas** (mais 2 erros de serviço; 5 recusas e 1 rodada perdida nas REEXEC). Distribuição: 2 no bloco de bugs, 10 no unitário limpo, 2 no formatName, 6 no widget limpo, 1 na integração limpa. Três rodadas (37, 40, 42) tiveram 2 recusas seguidas e só responderam com envio manual; a 51 teve recusa no reparo, contornada com um espaço em branco no final. As recusas se concentram nos envios automatizados, mas a 52 (toda automatizada, zero recusas) é contraexemplo — o fator não está isolado. Trate como ruído a reportar com o número certo, e revise a seção do README que trata a contagem de tentativas como dado do modelo.

Malformações: 3 respostas com markdown quebrado pelo próprio modelo (56, 59, 60 — todas integração), mais pelo menos 12 respostas truncadas e recomeçadas em rodadas diversas (3, 17, 18, 20, 21, 26, 31, 32, 39, 43, 56 e 3 REEXEC). Em ICRASH-FS_REEXEC o truncamento mudou o resultado: o rascunho dizia (B) correto, a versão final (A) com correção que não compila.

### 2.8 O que já dá para responder das 8 perguntas da comparação

Com o que os docs trazem do ChatGPT (falta o conjunto completo de `fase2/` para fechar):

1. **Detectou os 6 bugs?** Não. Unitários 6/6 (C), como o ChatGPT. W-CRASH 0/3 nos dois modelos (mesma lacuna: nenhum mock sem `artist_name`). W-SILENT: o ChatGPT teve (C) espontâneo na FS reexecutada e (B) hesitante na COT; o Gemini canonizou nas 3 — **diferença entre modelos**. I-CRASH: ChatGPT (B) explícito em ZS/COT reexecutadas; Gemini só a COT nomeia, e canoniza. I-SILENT: ChatGPT "teste que passa documentando o bug" nas 3; Gemini viu nas 3 e canonizou na COT — mesmo padrão.
2. **Asserção enfraquecida sob (B)?** Nenhuma nos dois. Gemini: 2 sob (A), 1 remoção de teste, 2 "trocar o sujeito".
3. **Lacunas W-CRASH e I-CRASH-FS repetiram?** Sim, as duas — padrão do problema, não do modelo.
4. **Alucinou o caminho de CriarPlaylistScreen?** Onde havia ajuda, não. Onde não havia (W-CRASH-FS, I-SILENT-FS), sim, três caminhos por rodada, nunca a raiz.
5. **ViaCEP?** Só na 57 (resolvido) e na 45 (mock à mão). CadastroScreen COT terminou 0/10 nos dois modelos, por motivos diferentes (ChatGPT: não compilou; Gemini: mock de asset inventado).
6. **Volume (pelas notas "ChatGPT na mesma rodada" dos docs):** no unitário o ChatGPT gera mais em 18 de 24 lotes (ex.: validateEmailEdit COT 37 × 16; validateDate ZS 34 × 23); as 6 exceções são 5 rodadas FS e a ZS de validateEmail (25 × 26). No widget o ChatGPT gera 2–3× mais em 8 de 8 lotes com nota (Cadastro 22–24 × 6–10; a 51 não traz o número). Na integração, ChatGPT mais em 5 de 9 (loginFlow 8/6/10 × 7/4/8), empate em 2 (56, 58) e Gemini mais em 2 (55: 4 × 3; 60: 6 × 5). O exemplo do orientador ("Gemini gerou mais testes unitários de frontend") **não se confirma** nos dados — é o contrário; o Gemini só produz suítes maiores em few-shot unitário e em duas rodadas de integração.
7. **Concordância autoclassificação × humana (Gemini):** (C) 6/6; (A) 51 declarados, todos corretos na natureza da falha, 12 com correção errada, regressiva ou que descaracteriza o teste; (B) 12 declarados, 10 procedem, 2 confabulados. Falta o mesmo cálculo para o ChatGPT.
8. **Bugs vizinhos por acaso?** Sim, no sentido inverso: a WIDGET-ZS-03 e a INT-ZS-03 (limpas) conferem o nome digitado no Firestore e pegariam o I-SILENT se ele estivesse ativo. O W-CRASH não foi tocado por ninguém.

---

## 3. Correções pendentes no material

- `LEIA-PRIMEIRO.md`, item 6: "duas recusas" → 21 em 17 rodadas (+5 nas REEXEC).
- `fase2-gemini/README.md`: "Status: Nenhuma das 60 rodadas executada" e estrutura com `rodadas/` vazio — desatualizados; seção "Recusas não determinísticas" ainda trata tentativas como dado do modelo.
- `piloto-flash-lite/README.md`, linha 30: diz que as 60 rodariam em "3.6 Flash"; foi 3.8.
- Registrar em `fase2/propostas_bugs_fase2.md` a interação W-CRASH / I-SILENT (pendência antiga) e agora também a `TelaInicialScreen` como limitação de testabilidade recorrente (9 diagnósticos).
