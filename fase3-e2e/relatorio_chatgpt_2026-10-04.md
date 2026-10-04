# Fase 3 — relatório consolidado do bloco ChatGPT (2026-10-03/04)

Execução de 2026-10-03 23:00 a 2026-10-04 03:38, segunda máquina
(DESKTOP-6ETPO2H), ChatGPT deslogado. As rodadas 1 a 3 tiveram colagem manual
pelo autor. Da rodada 4 em diante o envio foi automatizado (Claude in Chrome),
com o autor ausente. Branch `fase3-e2e`, ponta `de85152`, tudo pushado.
Este relatório resume; a fonte da verdade são os docs de rodada em
`rodadas/chatgpt/` e a seção "Estado em 2026-10-04" do `README.md`.

## 1. Placar

| | Planejadas | Fechadas | Pendentes |
|---|---|---|---|
| ChatGPT | 18 | **16** | 2 (P2-ZS, C3-COT) |
| Gemini | 18 | 0 | 18 (colagem manual pelo autor) |
| **Total** | **36** | **16** | **20** |

Verdes: 3 de 16 (ZS-03, FS-03, COT-01), todos em rodadas limpas e todos após
reparo. Nenhuma rodada passou na geração.

## 2. Rodadas do ChatGPT

"Geração" é a iteração 0; "Final" é o estado depois do último reparo.
"NC" = não compila.

| # | Rodada | Condição | Geração | Final | Autoclassificação | Auditoria humana | Manual-first |
|---|---|---|---|---|---|---|---|
| 1 | ZS-01 login | limpa | 8/9 | 8/9 | B, B, B | erro de teste (espera do Firestore) | — |
| 2 | ZS-02 cadastro | limpa | 1/4 | 2/5 | A, A, B | erro de teste + toque fora do alvo | — |
| 3 | ZS-03 playlist | limpa | NC | **2/2** | A, A+B | verde trocando a asserção da saudação | — |
| 4 | L4-ZS | L4 | 4/5 | 4/5 | A, B, B | bug real exposto | **Capturou** |
| 5 | C3-ZS | C3 | NC | 3/4 | A, A, B | nome com dígito; não chega ao `nome` | **Não viu** |
| 6 | P2-ZS | P2 | — | — | — | 3 respostas sem código | **pendente** |
| 13 | FS-01 login | limpa | 1/2 | 1/2 | B, B, B | erro de teste (transição) | — |
| 14 | FS-02 cadastro | limpa | NC | 0/1 | A, A, A | nome com dígito; lista preguiçosa | — |
| 15 | FS-03 playlist | limpa | NC | **1/1** | A | só faltava import | — |
| 16 | L4-FS | L4 | 1/2 | 1/2 | B, B, B | bug real exposto já na geração | **Capturou** |
| 17 | C3-FS | C3 | NC | 0/1 | A, A, B | nome com dígito | **Não viu** |
| 18 | P2-FS | P2 | NC | 0/1 | A, A, B | `RangeError` do P2, (B) correto | **Capturou** |
| 25 | COT-01 login | limpa | 7/8 | **8/8** | A | espera do Firestore, causa nomeada | — |
| 26 | COT-02 cadastro | limpa | NC | 4/11 | A, B, B | toque fora do alvo; (B) falso | — |
| 27 | COT-03 playlist | limpa | NC | 0/4 | A, A, B | asserção 1 quadro após o toque; (B) falso | — |
| 28 | L4-COT | L4 | 6/7 | 6/7 | A, A, B | bug real exposto; (B) correto | **Capturou** |
| 29 | C3-COT | C3 | 1/11 | — | — | reparo 1 sem resposta ×3 | **pendente** (provisório: Não viu) |
| 30 | P2-COT | P2 | NC | NC | A, A, A | não chegou à lista | **Não viu** |

## 3. Manual-first por bug e estratégia

| Bug | ZS | FS | COT |
|---|---|---|---|
| L4 (login não leva à tela inicial) | Capturou | Capturou | Capturou |
| C3 (`nome` gravado com o e-mail) | Não viu | Não viu | pendente |
| P2 (`RangeError` na lista) | pendente | Capturou | Não viu |

O L4 foi capturado pelas três estratégias. O C3 não foi visto em nenhuma
rodada concluída. O P2 só foi capturado no FS, e pela exceção no `build`,
sem precisar de asserção.

## 4. Padrões observados

- **Import do Material.** 6 das 15 gerações com código não compilam por
  falta de `material.dart`: ZS-03, C3-ZS, FS-02, C3-FS, FS-03 e COT-03.
  Outras falham por tela não importada ou por `app.TelaInicialScreen`.
- **Espera assíncrona.** O `pumpAndSettle` não espera o Firestore. Isso
  derruba a asserção da saudação no login (ZS-01, ZS-03, COT-01) e as
  asserções feitas um quadro após uma navegação (COT-03, P2-COT).
- **Nome com dígito.** "Usuário E2E" tem o dígito 2 e é recusado pelo
  validador do cadastro. Aconteceu em C3-ZS, FS-02, C3-FS e C3-COT, e é o que
  impede o C3 de ser visto.
- **Toque fora do alvo.** Com o teclado aberto, o toque em "Cadastrar" cai
  fora do botão (`would not hit test`). Na COT-02 o mesmo arquivo deu 6/11,
  6/11 e 4/11, então o resultado dessas rodadas não é determinístico.
- **Falsos (B).** Em rodadas limpas o modelo classificou como (B) falhas do
  próprio teste: ZS-01 e FS-01 nas três iterações, e COT-02 e COT-03 no fim.
  Na COT-03 ele tomou o `setState()` após `dispose()`, efeito da falha, como
  causa. Na P2-COT ele acertou isso no reparo 2 e recuou no reparo 3.
- **(B) corretos.** Nas rodadas com L4 e na P2-FS, o (B) apontou o defeito
  real, com a pista certa (`Navigator.pushReplacement`; índice 5 numa lista
  de 0 a 4).
- **Fontes externas.** 5 das 6 respostas de geração do bloco COT citaram
  "Documentação Flutter" (botão "Fontes"); a exceção é a L4-COT. Fora do COT,
  só a C3-ZS citou. Nenhum reparo citou.
- **Reparos que pioram.** Em P2-FS o reparo 1 removeu `material.dart`; em
  P2-COT o reparo 2 criou uma referência antes da declaração.

## 5. Pendências e decisões do autor

1. **P2-ZS.** Três respostas só com preâmbulo, sem código. Opções: repetir
   mais tarde, mudar para sessão logada pelo critério de saída, ou registrar
   como geração sem código. Nota em
   `rodadas/chatgpt/_abortadas/FASE3-P2-ZS_tentativas-sem-codigo.md`.
2. **C3-COT.** A iteração 0 rodou (1/11). O reparo 1 tem 57.926 caracteres,
   porque leva a saída literal do terminal, e recebeu turno vazio três vezes.
   Mesmas opções. Nota em `rodadas/chatgpt/FASE3-C3-COT_PENDENTE.md`.
3. **Gemini, 18 rodadas.** Exigem colagem manual pelo autor. A infraestrutura
   é a mesma: prompts prontos, worktrees dos bugs e scripts de execução.
4. **Controles de versão.** O autor dispensou repetir a autodeclaração e o
   Help Center em 2026-10-04. Isso diverge da regra (b) do `CLAUDE.md`, que
   pede fonte externa a cada dia. A divergência está registrada no README e
   não foi resolvida.
5. **Print da falha.** O `screencap` depois do `flutter test` só mostra a
   falha quando ela acontece no último teste. Falta decidir se isso basta.
6. **Defeitos pré-existentes vistos de passagem.** `setState()` sem checar
   `mounted` em `tela-inicial.dart:161` e em `criar_playlist.dart:41`. São
   dados, não foram corrigidos.

## 6. Commits da noite (`fase3-e2e`)

| Hora | Commit | Rodada |
|---|---|---|
| 23:11 | `656e851` | 1 ZS-01 |
| 23:48 | `6606bca` | 2 ZS-02 |
| 00:04 | `a7a3dc5` | 3 ZS-03 |
| 00:32 | `eb55d17` | 4 L4-ZS e worktrees dos bugs |
| 00:48 | `49e6cec` | 5 C3-ZS |
| 00:54 | `99f53d7` | 6 P2-ZS pendente |
| 01:08 | `1306f2c` | 13 FS-01 |
| 01:22 | `11e7536` | 16 L4-FS |
| 01:36 | `776cb3d` | 14 FS-02 |
| 01:50 | `898d8d7` | 17 C3-FS |
| 01:58 | `fff263e` | 15 FS-03 |
| 02:11 | `cd8085b` | 18 P2-FS |
| 02:20 | `ee9525f` | 25 COT-01 |
| 02:36 | `caa06a9` | 28 L4-COT |
| 02:58 | `1c3ba70` | 26 COT-02 |
| 03:12 | `c224545` | 27 COT-03 |
| 03:22 | `ce915c6` | 29 C3-COT pendente |
| 03:38 | `de85152` | 30 P2-COT |
