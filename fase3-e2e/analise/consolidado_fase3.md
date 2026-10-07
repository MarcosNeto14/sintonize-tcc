# Fase 3 — Dados consolidados (E2E, ZS × FS × COT, ChatGPT × Gemini)

**Experimento:** comparação ZS × FS × COT para geração automatizada de testes
E2E (`integration_test`, AVD + Firebase Emulator Suite) em dois modelos:
ChatGPT (GPT-5.6 Luna, sessão deslogada) e Gemini (3.8 Flash, logado/Pro).
**Desenho:** 3 fluxos × 3 estratégias × 2 modelos × {limpo, com bug} = 36
rodadas; 3 bugs plantados (L4 login, C3 cadastro, P2 playlist), um por fluxo.
**Data de consolidação:** 2026-10-06. **Rodadas fechadas: 34/36** — ChatGPT
16/18 (P2-ZS e C3-COT pendentes, ver README "Limitações e desvios (d)"),
Gemini 18/18.
**Fonte:** um doc por rodada em `fase3-e2e/rodadas/<modelo>/`, saídas íntegras
em `fase3-e2e/resultados/<modelo>/`, testes finais em
`integration_test/fase3/<modelo>/`. Formato espelha `analise/dados_consolidados.md`
(Fase 1): há um único nível (E2E), então a tabela nível×estratégia vira
estratégia×modelo.

Convenções: **it0** = execução da geração; **final** = estado arquivado após
no máximo 3 reparos (reparo sem código → reexecução inalterada); **Compilou**
= a geração compilou; **(B) c/f** = reparos autoclassificados (B) com classe
correta / falsa segundo a auditoria; **Fontes** = a geração trouxe marcadores
de fontes externas; **Manual-first** = rubrica de `roteiro_manual.md` (só
rodadas com bug).

---

## 1. Rodadas limpas (9 por modelo)

### 1.1 ChatGPT

| ID | Estr. | Fluxo | Gerados | Compilou | it0 | final | Reparos | Autoclass. | (B) c/f | Fontes | Nota |
|---|---|---|---|---|---|---|---|---|---|---|---|
| ZS-01 | ZS | login | 9 | sim | 8/9 | 8/9 | 3 | B,B,B | 0/3 | não | arquivo intocado nos 3 reparos |
| ZS-02 | ZS | cadastro | 4→5 | sim | 1/4 | 2/5 | 3 | A,A,B | 0/1 | não | 2 tentativas interrompidas pelo serviço antes |
| ZS-03 | ZS | playlist | 2 | **não** | — | 2/2 | 2 | A,A+B | 1/0 | não | verde **reduzindo** a asserção da saudação |
| FS-01 | FS | login | 2 | sim | 1/2 | 1/2 | 3 | B,B,B | 1/2 | não | causa instável (transição / `setState`) |
| FS-02 | FS | cadastro | 1 | **não** | — | 0/1 | 3 | A,A,A | — | não | nome com dígito (it.1–2); "Reggae" fora do viewport (it.3) |
| FS-03 | FS | playlist | 1 | **não** | — | 1/1 | 1 | A | — | não | import |
| COT-01 | COT | login | 8 | sim | 7/8 | 8/8 | 1 | A | — | **sim** | verde **reduzindo** a saudação |
| COT-02 | COT | cadastro | 11 | **não** | — | 4/11 | 3 | A,B,B | 0/2 | **sim** | **instável**: 6/11 e 4/11 com o mesmo arquivo |
| COT-03 | COT | playlist | 4 | **não** | — | 0/4 | 3 | A,A,B | 0/1 | **sim** | 2 gerações/reparos sem compilar |

### 1.2 Gemini

| ID | Estr. | Fluxo | Gerados | Compilou | it0 | final | Reparos | Autoclass. | (B) c/f | Fontes | Nota |
|---|---|---|---|---|---|---|---|---|---|---|---|
| ZS-01 | ZS | login | 5 | **não** | — | 5/5 | 2 | A,A | — | não | sem enfraquecer asserções |
| ZS-02 | ZS | cadastro | 4 | sim | 2/4 | 4/4 | 2 | A,A | — | não | verde **sem** a saudação |
| ZS-03 | ZS | playlist | 2 | sim | 2/2 | 2/2 | 0 | — | — | não | verde de primeira |
| FS-01 | FS | login | 2 | sim | 1/2 | 1/2 | 3 | B,B,B | 3/0 | não | defeito pré-existente (`tela-inicial.dart:161`) |
| FS-02 | FS | cadastro | 1 | sim | 0/1 | 1/1 | 3 | A,B,B | 2/0 | não | **instável**: 0/1, 0/1, 1/1 com o mesmo arquivo; it.3 em outra máquina |
| FS-03 | FS | playlist | 1 | sim | 1/1 | 1/1 | 0 | — | — | não | verde de primeira |
| COT-01 | COT | login | 5 | sim | 4/5 | 4/5 | 3 | B,A,B | 1/1 | não | it.2–3 no defeito pré-existente |
| COT-02 | COT | cadastro | 4 | sim | 0/4 | 3/4 | 3 | A,A,A | — | não | resto = SnackBar do ViaCEP antes da do Auth |
| COT-03 | COT | playlist | 4 | sim | 3/4 | 4/4 | 1 | A | — | não | manteve a checagem do Firestore |

### 1.3 Resumo das limpas por estratégia × modelo

| Modelo | Estr. | Rodadas | Gerados | Pass final | Taxa final | Verdes | Compilou na geração | Reparos (total) | Verde reduzindo escopo |
|---|---|---|---|---|---|---|---|---|---|
| ChatGPT | ZS | 3 | 16 | 12 | 75% | 1 | 2/3 | 8 | 1 (ZS-03) |
| ChatGPT | FS | 3 | 4 | 2 | 50% | 1 | 1/3 | 7 | 0 |
| ChatGPT | COT | 3 | 23 | 12 | 52% | 1 | 1/3 | 7 | 1 (COT-01) |
| Gemini | ZS | 3 | 11 | 11 | 100% | 3 | 2/3 | 4 | 1 (ZS-02) |
| Gemini | FS | 3 | 4 | 3 | 75% | 2 | 3/3 | 6 | 0 |
| Gemini | COT | 3 | 13 | 11 | 85% | 1 | 3/3 | 7 | 0 |
| **ChatGPT** | **todas** | 9 | 43 | 26 | 60% | 3 | **4/9** | 22 | 2 |
| **Gemini** | **todas** | 9 | 28 | 25 | 89% | 6 | **8/9** | 17 | 1 |

"Gerados" na ZS-02 do ChatGPT conta os 5 do arquivo final. Taxas sobre testes
somados são distorcidas pelo número de testes por arquivo (ChatGPT gera suítes
maiores: 11 na COT-02, 8–9 no login); a leitura por rodada (coluna "Verdes") é
a mais fiel.

---

## 2. Rodadas com bug (9 por modelo; 7 fechadas no ChatGPT)

### 2.1 ChatGPT

| ID | Bug | Estr. | Gerados | Compilou | it0 | final | Reparos | Autoclass. | (B) c/f | Fontes | Manual-first (it. em que se define) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| L4-ZS | L4 | ZS | 5 | sim | 4/5 | 4/5 | 3 | A,B,B | 2/0 | não | **Capturou** (1) |
| L4-FS | L4 | FS | 2 | sim | 1/2 | 1/2 | 3 | B,B,B | 3/0 | não | **Capturou** (0) |
| L4-COT | L4 | COT | 7 | sim | 6/7 | 6/7 | 3 | A,A,B | 1/0 | não | **Capturou** (1) |
| C3-ZS | C3 | ZS | 4 | **não** | — | 3/4 | 3 | A,A,B | 0/1 | **sim** | **Não viu** (nome com dígito) |
| C3-FS | C3 | FS | 1 | **não** | — | 0/1 | 3 | A,A,B | 0/1 | não | **Não viu** (nome com dígito) |
| C3-COT | C3 | COT | 11 | sim | 1/11 | **pendente** | — | — | — | **sim** | (Não viu provisório) |
| P2-ZS | P2 | ZS | — | **pendente** (3 gerações sem código) | — | — | — | — | — | — | — |
| P2-FS | P2 | FS | 1 | **não** | — | 0/1 | 3 | A,A,B | 1/0 | não | **Capturou** (2) |
| P2-COT | P2 | COT | 4 | **não** | — | não compila | 3 | A,A,A | — | **sim** | **Não viu** |

### 2.2 Gemini

| ID | Bug | Estr. | Gerados | Compilou | it0 | final | Reparos | Autoclass. | (B) c/f | Fontes | Manual-first (it.) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| L4-ZS | L4 | ZS | 5 | sim | 4/5 | 4/5 | 3 | A,A,B | 1/0 | não | **Capturou** (0) |
| L4-FS | L4 | FS | 2 | sim | 1/2 | 1/2 | 3 | A,A,B | 1/0 | não | **Capturou** (0) |
| L4-COT | L4 | COT | 6 | sim | 5/6 | 5/6 | 3 | A,B,B | 2/0 | não | **Capturou** (0) |
| C3-ZS | C3 | ZS | 3 | sim | 1/3 | 1/3 | 3 | A,A,A | — | não | **Não viu** (nome com dígito; it.2 não compilou) |
| C3-FS | C3 | FS | 1 | sim | 0/1 | 0/1 | 3 | A,B,A | 1/0 | não | **Capturou** (0) — `expect(dados['nome'], …)` |
| C3-COT | C3 | COT | 5 | sim | 2/5 | 5/5 | 1 | A | — | não | **Viu sem asserção** (0) — verde com o bug |
| P2-ZS | P2 | ZS | 2 | sim | 0/2 | 0/2 | 3 | B,B,B | 3/0 | não | **Capturou** (0) |
| P2-FS | P2 | FS | 1 | **não** | — | 0/1 | 3 | A,A,A | — | não | **Capturou** (1) |
| P2-COT | P2 | COT | 4 | sim | 0/4 | 0/4 | 3 | B,B,B | 3/0 | não | **Capturou** (0) |

### 2.3 Detecção uniforme — bug × estratégia × modelo (manual-first)

| Bug (tipo) | Estr. | ChatGPT | Gemini |
|---|---|---|---|
| **L4** login → `CadastroScreen` (SILENT, tela de destino) | ZS | Capturou | Capturou |
| | FS | Capturou | Capturou |
| | COT | Capturou | Capturou |
| **C3** `nome` = e-mail (SILENT, só na saudação / no doc) | ZS | Não viu | Não viu |
| | FS | Não viu | **Capturou** |
| | COT | pendente | Viu sem asserção |
| **P2** `itemCount + 1` (CRASH, `RangeError` no build) | ZS | pendente | Capturou |
| | FS | Capturou | Capturou |
| | COT | Não viu | Capturou |

| Modelo | Capturou | Viu sem asserção | Não viu | Canonizou / Caracterizou | Pendentes |
|---|---|---|---|---|---|
| ChatGPT (7 fechadas) | 4 (L4 ×3, P2-FS) | 0 | 3 (C3-ZS, C3-FS, P2-COT) | 0 / 0 | 2 |
| Gemini (9) | 7 (L4 ×3, C3-FS, P2 ×3) | 1 (C3-COT) | 1 (C3-ZS) | 0 / 0 | 0 |

Leitura por bug: **L4** — 6/6 Capturou: basta afirmar o tipo da tela de
destino, e nenhum reparo (A) trocou essa asserção pelo comportamento com bug
(Canonizou = 0). **P2** — Capturou em todas as que compilaram até a lista
(5/5); o CRASH entrega arquivo:linha sem asserção. **C3** — o discriminador:
só a FS do Gemini afirmou o campo `nome` do documento; a COT do Gemini chegou
ao sintoma e afirmou a saudação sem o nome; 4 rodadas (5 com a pendente) nem
chegaram, pelo nome com dígito (README, "Limitações (a)").

---

## 3. Autoclassificação (B): corretos e falsos

Contagem por reparo. "Correto" = a auditoria confirma defeito da aplicação
(plantado ou pré-existente); "falso" = era erro do teste. Causa certa/errada
registrada à parte.

| Modelo | Contexto | (B) emitidos | Corretos na classe | Falsos | Causa certa entre os corretos |
|---|---|---|---|---|---|
| ChatGPT | limpas | 11 | 2 (ZS-03 r2; FS-01 it.2 — `setState` pré-existente) | 9 (ZS-01 ×3, ZS-02, FS-01 ×2, COT-02 ×2, COT-03) | 2/2 |
| ChatGPT | bug | 9 | 7 (L4-ZS ×2, L4-FS ×3, L4-COT, P2-FS) | 2 (C3-ZS, C3-FS) | 2/7 (L4-COT r3 cita `pushReplacement`; P2-FS r3 exato); nos demais L4 a hipótese é seed/Auth |
| **ChatGPT** | **total** | **20** | **9** | **11** | |
| Gemini | limpas | 7 | 6 (FS-01 ×3, FS-02 ×2, COT-01 r3) | 1 (COT-01 r1) | 6/6 (arquivo, linha e `mounted`) |
| Gemini | bug | 11 | 11 (L4-ZS, L4-FS, L4-COT ×2, C3-FS, P2-ZS ×3, P2-COT ×3) | 0 | 1 clara (P2-ZS r3 cita `itemCount`) + 3 parciais (P2-COT: linha e índice certos, causa de rebuild); L4 ×4 e C3-FS com causa errada |
| **Gemini** | **total** | **18** | **17** | **1** | |

Padrão: nas rodadas com bug os dois modelos acertam a **classe** e erram a
**causa** nos SILENT (raciocinam sobre o código do prompt, que está correto, e
nunca cogitam que o código em execução difira); no CRASH acertam arquivo e
linha. Nas limpas, o ChatGPT emite (B) falsos com frequência (9 de 11) e o
Gemini quase não (1 de 7) — os (B) corretos das limpas são o `setState()` após
`dispose` real de `tela-inicial.dart:161` (README, "Limitações (c)").

---

## 4. Compilação na geração e fontes externas

| Modelo | Rodadas fechadas | Não compilou na geração | Causa dominante | Gerações com fontes externas |
|---|---|---|---|---|
| ChatGPT | 16 | **9** (ZS-03, FS-02, FS-03, COT-02, COT-03, C3-ZS, C3-FS, P2-FS, P2-COT) | `material.dart` / import de tela faltando (7); ordem de declaração (COT-02); classe não exportada (P2-COT) | **6** (C3-ZS, COT-01, COT-02, COT-03, P2-COT; C3-COT pendente) — todas COT exceto C3-ZS |
| Gemini | 18 | **2** (ZS-01: `Finder.matches` inexistente; P2-FS: código cortado e recomeçado no bloco) + 1 reparo (C3-ZS r2: `Finder.or`) | API inexistente | **0** |

---

## 5. Instabilidade registrada (README, "Limitações (b)")

| Rodada | Mesmo arquivo, resultados diferentes |
|---|---|
| ChatGPT COT-02 | 6/11 (it.1) e 4/11 (final) — toque em "Cadastrar" com o teclado aberto |
| Gemini FS-02 | 0/1, 0/1, 1/1 (it.1–3) — `setState` após `dispose` intermitente; it.3 em outra máquina |
| ChatGPT FS-01 | 1/2 ×4, por duas causas diferentes (transição ×3, `setState` ×1) |

---

## 6. Achados principais

1. **Detecção dos bugs plantados não depende da estratégia; depende do tipo
   de bug e de uma asserção específica.** L4 (tela de destino) e P2 (crash)
   foram capturados por todas as rodadas que chegaram ao ponto do sintoma, em
   ZS, FS e COT, nos dois modelos. C3 (dado errado num texto) só foi capturado
   quando o teste afirmou o campo gravado (Gemini FS); a COT do Gemini passou
   pelo sintoma sem afirmá-lo (verde com o bug).
2. **O principal obstáculo foi chegar ao sintoma, não reconhecê-lo:**
   gerações que não compilam (ChatGPT 9/16), toques fora do viewport, espera
   insuficiente por I/O do emulador e o nome com dígito derrubaram rodadas
   antes do alvo. Todos são erros do teste com a regra disponível no prompt.
3. **Reparos (B) nunca enfraqueceram o teste** nas rodadas com bug (Canonizou
   = 0); os reparos (A) que mexeram em asserções o fizeram nas limpas, para
   ficar verde (ChatGPT ZS-03, COT-01; Gemini ZS-02 — saudação retirada).
4. **Diferença entre modelos** (sob condições de sessão diferentes — ver
   README): o Gemini compila mais, fecha mais rodadas verdes (6/9 vs 3/9),
   emite menos (B) falsos (1 vs 11) e não consulta a web; o ChatGPT gera
   suítes maiores e consultou fontes externas em 6 gerações, todas com
   `material.dart` ou imports faltando em 4 delas.
5. **Dois defeitos reais não plantados** foram expostos e, em parte,
   diagnosticados pelos modelos (`setState()` após `dispose` em
   `tela-inicial.dart:161` e `criar_playlist.dart:41`) — README,
   "Limitações (c)".
6. **Custo:** uma execução E2E leva 20–90 s de teste mais 11–75 s de Gradle
   com cache; uma rodada completa (4 execuções + 3 reparos) ~45 min com envio
   automatizado (`analise/custo_e_referencia.md` para o custo fixo do ambiente).

---

## 7. Notas metodológicas

- Sessões: ChatGPT **deslogado** (igual às Fases 2 e reexecução), GPT-5.6
  Luna por autodeclaração até 2026-10-04 (controles diários dispensados pelo
  autor depois — divergência do `CLAUDE.md` registrada no README); Gemini
  **logado**, Pro, 3.8 Flash fixado, print do seletor por rodada.
- Envio: ChatGPT automatizado (Claude in Chrome), com interrupções do serviço
  registradas em `_abortadas/`; Gemini manual (05/10) e automatizado (06/10);
  as duas rodadas pendentes seguem a decisão do README "(d)".
- Reparo = template fixo + saída literal, máx. 3; reparo sem código →
  reexecução inalterada (precedente FASE2-ICRASH-ZS). Nenhum operador
  acrescentou informação ao reparo (ao contrário das 15 rodadas isoladas da
  Fase 2).
- Duas máquinas (`DellT4i51`, `DESKTOP-6ETPO2H`); rodadas que trocaram de
  máquina no meio: Gemini FS-02, COT-01, COT-02 (anotado em cada doc).
- Testes de referência (`integration_test/_referencia/`) nunca entraram em
  prompt; teto de comparação: L4/C3/P2 Capturou.
- Prints pós-suíte na segunda máquina mostram a home do Android (o app é
  encerrado pelo `tearDownAll`) e não evidenciam a falha; a evidência é a
  saída íntegra do `flutter test` em `resultados/`.
