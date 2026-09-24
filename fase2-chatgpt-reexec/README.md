# Fase 2 — Reexecução com ChatGPT (22 rodadas de bug plantado)

## Por que esta reexecução existe

Nas rodadas de bug plantado da Fase 2 original, o prompt de reparo enviado ao
ChatGPT recebeu informação do operador além do template fixo. A réplica com
Gemini usou só o template. Aqui as 18 rodadas de bug plantado e as 4 `_REEXEC`
são refeitas no ChatGPT com o protocolo da réplica, para que a comparação entre
modelos meça só o modelo. Ver
[`fase2/_execucao-assistida/README.md`](../fase2/_execucao-assistida/README.md).

Nada nesta pasta altera `fase2/`, `fase2/_execucao-assistida/` ou `fase2-gemini/`.

**Status:** 5 rodadas executadas (`FASE2-WCRASH-FS`, `FASE2-WCRASH-COT`, `FASE2-WSILENT-ZS`, `FASE2-WSILENT-FS`, `FASE2-WSILENT-COT`).

---

## Protocolo

O protocolo é o de `fase2-gemini/README.md`, seção "Protocolo por rodada", com o
ChatGPT no lugar do Gemini:

1. `git checkout fase2-chatgpt-reexec` e rodar os 6 greps da seção de branches.
   As 6 linhas precisam aparecer.
2. Abrir **conversa nova** no ChatGPT, na condição de sessão definida abaixo. Uma
   conversa por rodada, sem contexto anterior.
3. Registrar o modelo servido (dois campos ✦ do template) e o print em
   `evidencias/`.
4. Colar o prompt da rodada **verbatim**, do separador `---` em diante. A linha
   "colar no ChatGPT" acima do separador não faz parte do prompt.
5. Salvar o teste gerado em `test/fase2-chatgpt-reexec/<nível>/`, rodar
   `flutter test` nesse arquivo e arquivar a saída em `resultados/<nível>/`.
6. Se falhar, enviar o prompt de reparo na **mesma** conversa. São no máximo 3
   iterações, com a autoclassificação (A)/(B)/(C) registrada em cada uma.
7. Preencher o doc em `rodadas/<nível>/` a partir de
   `Template_Documentacao_Rodada_Fase2.md`.

Não edite o teste gerado para fazê-lo passar. Se falha, falha — registre. O
único caminho de mutação permitido é o ciclo de reparo documentado.

### Regras do reparo — o motivo desta pasta

> **1. O prompt de reparo é o template fixo, e nada mais.** O texto vai do
> "O teste falhou com o seguinte erro:" até "alterar o teste.", copiado do
> arquivo de prompt da rodada, com a saída do terminal colada no lugar indicado.
> **Nada além disso:**
> - sem caminho de arquivo
> - sem versões de pacote
> - sem fatos do app
> - sem técnica sugerida
> - sem referência a rodadas anteriores
> - sem aviso de "última iteração"
>
> O texto literal de cada reparo vai no Apêndice do doc da rodada. É a prova de
> que a regra foi seguida.
>
> **2. Perguntas do modelo não são respondidas.** Se o modelo pedir informação,
> o próximo reparo é o mesmo template com a saída atual do terminal.
>
> **3. Se houver várias opções, aplica-se a recomendada.** Quando o modelo
> devolver mais de uma opção, aplica-se a que ele nomear como recomendada. Se não
> nomear nenhuma, aplica-se a primeira. A escolha vai no campo "Opção aplicada".
>
> **4. O operador não reverte iterações.** O estado final é o da última
> iteração aplicada, mesmo que seja pior que um estado anterior. O melhor estado
> intermediário é registrado em campo próprio do doc e não substitui o final.
>
> **5. São no máximo 3 iterações, e cada rodada usa uma conversa nova.**
>
> **6. Recusa ou erro de serviço não conta como iteração.** Reenviar o texto
> **inalterado** em conversa nova e registrar a tentativa em "Tentativas de
> envio". Vale para a geração e para os reparos.

### Extração do código gerado

Vale o procedimento de `fase2-gemini/README.md`, seção "Extração do código
gerado". Se a extração automática perder a indentação, o operador cola a resposta
manualmente e o arquivo verbatim substitui a versão reconstruída. O doc registra
qual caminho foi usado.

---

## Ameaças à validade — pedidos de informação de ambiente

**Decisão (2026-09-24, após a rodada 1):** quando o modelo pede informação de
ambiente, como o caminho real de um arquivo, o pedido **não é respondido**,
conforme a regra 2 do reparo. Não há braço secundário com contexto
padronizado. A decisão vale para as 22 rodadas.

**Por que não responder.** Responder caso a caso foi o que contaminou a Fase 2
original, isolada em `fase2/_execucao-assistida/`. Responder só quando o
modelo pergunta também premiaria o modelo que pergunta em relação ao que
chuta: na mesma rodada, o Gemini não perguntou e colou o widget no teste. E a
réplica Gemini já foi executada sem essa ajuda.

**Ameaça a declarar na redação.** Um import inexistente não tem relação com o
que o estudo mede. Quando a rodada trava nesse erro, o resultado vira
"compila / não compila", e o bug plantado nem chega a ser testado. A ameaça
não se distribui ao acaso:
- **Construto:** a métrica de reparo passa a medir se o modelo conhece o layout
  do repositório, e não se ele gera bons testes ou detecta o bug.
- **Interna, entre estratégias:** nenhum prompt FS traz a linha de import, e
  todos os COT trazem (ver a tabela "As 22 rodadas"). A regra de não responder
  pesa sobre o FS, e isso confunde a comparação ZS × FS × COT.
- **Entre modelos:** um modelo que pede a informação fica travado; um que
  inventa um caminho ou cola o widget no teste pode "passar" testando uma cópia,
  não a aplicação.

**Tratamento na análise:**
- classificar essas rodadas como **"bloqueio por informação de ambiente
  ausente"**, separadas de "erro de teste";
- reportar duas métricas: compilação e detecção do bug **entre as rodadas que
  chegaram a executar**.

**Ocorrências:** `FASE2-WSILENT-FS` (rodada 4) repetiu o padrão: pedido de caminho nos três reparos, cópia do widget colada no teste na iteração 2, nenhuma iteração compilada.

**Primeira ocorrência:** `FASE2-WCRASH-FS`, rodada 1. O modelo pediu o
caminho nos reparos 1, 2 e 3 e a rodada terminou sem compilar. Na Fase 2
original, com o caminho fornecido pelo operador, a mesma rodada fechou em
15/15.

---

## Condição de sessão

**Condição:** sessão deslogada, a mesma das 49 rodadas do ChatGPT que já são
válidas. Mudar a condição no meio do conjunto criaria uma variável nova dentro do
ChatGPT, e é dentro do ChatGPT que está a comparação primária do estudo, entre
estratégias.

**Controle por sessão:**
- **(a) Pergunta de versão.** Antes do prompt, perguntar ao modelo qual versão ele
  é e registrar a resposta literal como autodeclaração. Sozinha, ela não é
  confiável.
- **(b) Fonte externa.** Registrar qual modelo é servido sem login nessa data, com
  URL e data de consulta.
- **(c) Print da tela** em `evidencias/`, um por sessão de trabalho.

**Repetir (b) a cada dia de execução.** Foi essa conferência que faltou na Fase 2
e deixou a troca GPT-5.5→5.6 passar despercebida.

**Critério de saída:** se a fonte externa indicar que o tier deslogado passou a
servir um modelo claramente inferior ao padrão pago, a condição deixa de
significar "modelo padrão". Nesse caso, a reexecução migra para sessão logada,
com a justificativa escrita antes da rodada seguinte.

Se a autodeclaração e a fonte externa divergirem, registre a divergência, não a
resolva.

---

## Condições de sessão nos dois modelos

| | ChatGPT (64 rodadas) | Gemini (64 rodadas) |
|---|---|---|
| **Sessão** | deslogada | logada, conta Pro |
| **Modelo** | GPT-5.6 Luna (tier gratuito; "fastest and lowest-cost" da família, segundo a OpenAI) — autodeclarado e confirmado pela fonte do item d | 3.8 Flash fixado no seletor, print por sessão |
| **Posição na linha do fornecedor** | modelo do tier gratuito | 3.8 Flash, padrão do produto, com 3.5 Flash Lite abaixo e 3.1 Pro acima |
| **Por quê** | condição original da Fase 2, mantida | deslogado era inviável — ver motivos |

**Limitação a declarar:** a comparação não é carro-chefe × carro-chefe nos dois
lados. No ChatGPT roda o modelo do tier gratuito, o mais barato da família GPT-5.6.
No Gemini roda o padrão do produto, que fica no meio da linha.

**Motivos do Gemini logado, cada um com o que o sustenta:**

**a. Deslogado, o Gemini rebaixa o modelo em relação ao padrão do produto.** Sem
login, o seletor do Gemini travava em 3.5 Flash Lite, abaixo do 3.8 Flash, que é o
padrão do produto. Evidência:
- `fase2-gemini/evidencias/2026-09-21_gemini_seletor_modelo_sem_login.png`
- `fase2-gemini/README.md`, seção "Mudança de condição".

À época, acreditava-se que o ChatGPT deslogado servia o modelo padrão. A fonte de
2026-09-24 (item d) mostra que ele servia GPT-5.6 Luna, o modelo do tier gratuito.
A decisão de logar o Gemini se sustenta pelo rebaixamento em relação ao padrão do
produto e pelo item b, não mais pela comparação entre os dois modelos.

**b. Deslogado, a conversa bloqueava o ciclo de reparo.** Depois de uma resposta
em Canvas, a conversa passava a rejeitar qualquer mensagem seguinte com o erro
1184. O bloqueio persistiu em 5 reenvios. Como o Gemini abre Canvas
espontaneamente para respostas de código, o prompt de reparo, obrigatório no
protocolo, não podia ser enviado.

Evidência: a tentativa abortada de `UCRASH-ZS` em 2026-09-20, versionada em
`fase2-gemini/rodadas/unit/_abortadas/2026-09-20_UCRASH-ZS_deslogado/`:
- `FASE2-UCRASH-ZS_transcricao/NOTA_BLOQUEIO.md`: o erro, os reenvios e o diagnóstico;
- `FASE2-UCRASH-ZS_transcricao/canvas_gerado_verbatim.dart`;
- `FASE2-UCRASH-ZS_transcricao/prompt_geracao_enviado.txt`;
- `FASE2-UCRASH-ZS_transcricao/prompt_reparo_iter1_NAO_ENVIADO.txt`;
- `FASE2-UCRASH-ZS_iter0.txt`: 6 testes passaram e 2 falharam.

**c. Relato do autor: deslogado, o Gemini não aceitava prompts longos nem
entregava mais de duas respostas por conversa.** **Não sustenta a decisão; fica
registrado por transparência.** O bloqueio do reparo em si está documentado no
item b. Já as duas causas do relato foram testadas e **descartadas
explicitamente** pela `NOTA_BLOQUEIO.md` do item b:
- *"O **mesmo** prompt de reparo, enviado como **primeira** mensagem de uma
  conversa nova, é aceito e respondido normalmente [...] Logo **não é** tamanho
  da mensagem"*;
- *"um follow-up curto ("ok") foi aceito normalmente. Logo **não é** limite de
  turnos por conversa."*

Fica registrado como relato do autor contradito pelo artefato de 2026-09-20.

**Os motivos que sustentam a decisão de logar o Gemini são a e b.**

**d. No ChatGPT, logar em conta gratuita não mudaria o modelo.** A sessão
deslogada e a conta Free logada recebem o mesmo modelo, GPT-5.6 Luna. A
equivalência **não** se estende a contas pagas, que recebem GPT-5.6 Sol.

Fontes, ambas consultadas em 2026-09-24:
- OpenAI Help Center, "GPT-5.6 and GPT-6 Pro in ChatGPT",
  <https://help.openai.com/en/articles/20001354-gpt-56-and-gpt-6-pro-in-chatgpt>
  ("Updated: 8 days ago"):
  > "Logged-out users do not have access to GPT-5.6 Sol. Free and Go users do not
  > have access to GPT-5.6 Sol. Their default model is GPT-5.6 Luna, which also
  > powers Think."
  >
  > "GPT-5.6 Sol powers Instant, Medium, High, and Extra High on eligible paid plans"
  >
  > "Luna is the fastest and lowest-cost model in the GPT-5.6 family."
- OpenAI Help Center, "ChatGPT Free Tier FAQ",
  <https://help.openai.com/en/articles/9275245-chatgpt-free-tier-faq>
  ("Updated: 3 days ago"):
  > "Free users have access to GPT-5.6 Luna."

---

## Branches

As 22 rodadas rodam em **`fase2-chatgpt-reexec`**, a branch de execução desta
reexecução. Ela foi criada de `fase2-gemini-alvos-limpos`, então tem os docs
completos (`fase2/`, `fase2/_execucao-assistida/`, `fase2-gemini/` e esta pasta).
O `lib/` dela foi trazido de `fase2-gemini-piloto` num commit próprio ("Reativa os
6 bugs plantados..."). Com isso, o `lib/` fica igual ao da piloto, com os 6 bugs
ativos.

A referência do estado com bugs continua sendo `fase2-gemini-piloto`, criada a
partir de `295fa34`, o único commit com os 6 bugs ativos ao mesmo tempo. Não use
`fase2-prep`, que só tem 3 dos 6 bugs ativos. Detalhes em
`fase2-gemini/README.md`, seção "Mapeamento rodada ↔ estado do código".

Conferido em 2026-09-24:
- `fase2-gemini-piloto` existe localmente e no remoto;
- `295fa34` é ancestral dela;
- o `lib/` dela é idêntico ao de `295fa34`;
- entre ela e `fase2-gemini-alvos-limpos`, o `lib/` difere só nas 6 reversões
  de bug;
- as 6 linhas abaixo aparecem em `fase2-chatgpt-reexec`.

**Verificação do estado — as 6 linhas devem aparecer antes de qualquer rodada:**

```bash
grep -n "value.length < 7"                    lib/utils/validators.dart   # U-SILENT
grep -c "word.isEmpty"                        lib/utils/validators.dart   # U-CRASH: deve dar 0
grep -n "musica\['artist_name'\].toLowerCase" lib/criar_playlist.dart     # W-CRASH
grep -n "'nome': 'Nova Playlist'"             lib/criar_playlist.dart     # I-SILENT
grep -n "currentUser!.uid"                    lib/generos-cadastro.dart   # I-CRASH
grep -n -A1 "e.code == 'user-not-found'"      lib/login.dart              # W-SILENT
```

No W-SILENT, a linha seguinte ao `user-not-found` deve ser a mensagem de
**senha incorreta**. É essa a troca.

---

## Estrutura

```
fase2-chatgpt-reexec/
├── README.md                              (este arquivo)
├── Template_Documentacao_Rodada_Fase2.md  (template da réplica + campos ◆ do reparo fixo)
├── prompts_prontos/                       (18 prompts de bug + FASE2--REEXEC.md, byte-idênticos)
├── evidencias/                            (prints do seletor/da tela, um por sessão)
├── rodadas/{unit,widget,integration}/     (docs por rodada)
└── resultados/{unit,widget,integration}/  (saídas de flutter test, uma por iteração)

test/fase2-chatgpt-reexec/{unit,widget,integration}/   (testes gerados)
```

### Prompts — cópia literal

Os 19 arquivos de `prompts_prontos/` foram copiados de `fase2-gemini/prompts_prontos/`
sem alteração. O blob git de cada um (`git hash-object`) é idêntico ao do
arquivo correspondente em `fase2/prompts_prontos/`: 19/19.

O `sha256sum` direto do working tree bate em 18/19. A exceção é
`FASE2--REEXEC.md`, e a diferença é só de fim de linha no checkout: a cópia de
`fase2/` está com LF e a de `fase2-gemini/` com CRLF, por `core.autocrlf=true`.
No índice os dois arquivos apontam para o mesmo blob, `5e9cc73`.

---

## As 22 rodadas

"Ajuda de import" indica se o corpo enviado ao modelo traz a linha
`Use import 'package:sintonize/...'`. Isso foi conferido em cada arquivo, entre o
separador do prompt e a seção de reparo.

| # | ID | Bug | Estratégia | Prompt | Ajuda de import | Status |
|---|---|---|---|---|---|---|
| 1 | FASE2-UCRASH-ZS | U-CRASH | ZS | original | não | pendente |
| 2 | FASE2-UCRASH-FS | U-CRASH | FS | original | não | pendente |
| 3 | FASE2-UCRASH-COT | U-CRASH | COT | original | sim (`utils/validators.dart`) | pendente |
| 4 | FASE2-USILENT-ZS | U-SILENT | ZS | original | não | pendente |
| 5 | FASE2-USILENT-FS | U-SILENT | FS | original | não | pendente |
| 6 | FASE2-USILENT-COT | U-SILENT | COT | original | sim (`utils/validators.dart`) | pendente |
| 7 | FASE2-WCRASH-ZS | W-CRASH | ZS | original | sim (`criar_playlist.dart`) | pendente |
| 8 | FASE2-WCRASH-FS | W-CRASH | FS | original | não | **feita (1/15)** — não compila, 3 iterações |
| 9 | FASE2-WCRASH-COT | W-CRASH | COT | original | sim (`criar_playlist.dart`) | **feita (2/15)** — 20/21, 3 iterações |
| 10 | FASE2-WSILENT-ZS | W-SILENT | ZS | original | sim (`login.dart`) | **feita (3/15)** — 7/8 (melhor 12/14), W-SILENT visto e canonizado |
| 11 | FASE2-WSILENT-FS | W-SILENT | FS | original | não | **feita (4/15)** — não compila; W-SILENT visto e canonizado |
| 12 | FASE2-WSILENT-COT | W-SILENT | COT | original | sim (`login.dart`) | **feita (5/15)** — não compila (melhor 10/21); W-SILENT visto e canonizado |
| 13 | FASE2-ICRASH-ZS | I-CRASH | ZS | original | sim (`cadastro.dart`, `generos-cadastro.dart`) | pendente |
| 14 | FASE2-ICRASH-FS | I-CRASH | FS | original | não | pendente |
| 15 | FASE2-ICRASH-COT | I-CRASH | COT | original | genérica (`package:sintonize/...`) | pendente |
| 16 | FASE2-ISILENT-ZS | I-SILENT | ZS | original | sim (`criar_playlist.dart`) | pendente |
| 17 | FASE2-ISILENT-FS | I-SILENT | FS | original | não | pendente |
| 18 | FASE2-ISILENT-COT | I-SILENT | COT | original | sim (`criar_playlist.dart`) | pendente |
| 19 | FASE2-WSILENT-FS_REEXEC | W-SILENT | FS | corrigido (`FASE2--REEXEC.md`, l. 37–225) | não | pendente |
| 20 | FASE2-ICRASH-ZS_REEXEC | I-CRASH | ZS | corrigido (l. 226–1010) | sim (`cadastro.dart`, `generos-cadastro.dart`) | pendente |
| 21 | FASE2-ICRASH-FS_REEXEC | I-CRASH | FS | corrigido (l. 1011–1841) | não | pendente |
| 22 | FASE2-ICRASH-COT_REEXEC | I-CRASH | COT | corrigido (l. 1842–2624) | genérica (`package:sintonize/...`) | pendente |

Nenhum prompt FS traz a ajuda de import, e todos os COT trazem. Nos ZS, só os
de widget e integração trazem. A assimetria vem dos prompts originais e é
preservada. As 4 `_REEXEC` ficam fora da manchete, como em `fase2/` e
`fase2-gemini/`.

> **Correção a `fase2-gemini/README.md`:** a seção "Desvios preservados" de lá
> diz que, no piloto, só W-CRASH-{ZS,COT} e I-SILENT-{ZS,COT} trazem a ajuda de
> import. A tabela acima, conferida arquivo a arquivo, mostra 10 dos 18. Aquele
> README não foi alterado.
