# Pirâmide unificada — unitário → widget → integração → E2E, ChatGPT × Gemini (2026-10-07)

Base: Fase 2 ChatGPT (60 rodadas: 49 originais + 15 reexecutadas com reparo fixo), Fase 2 Gemini (60), Fase 3 (36 E2E). Pass/fail = última saída de `flutter test`, verificada externamente nas três fases (0 divergências). REEXEC e formatName fora. Planilha: `Piramide_Unificada_ChatGPT_x_Gemini.xlsx` (aba Rodadas com as 164 linhas; abas Pirâmide e Detecção por bug com fórmulas sobre ela).

Regras: taxa = passando ÷ (passando + falhando) nas rodadas cujo arquivo final executa; não compila = 0 passando, fora da taxa, contado à parte. Detecção na codificação uniforme da Fase 2; "Chegou sem afirmar" da Fase 3 (Gemini C3-COT) = Não viu. E2E do ChatGPT: 7 rodadas de bug com dado; P2-ZS e C3-COT sem dado por limitação do serviço, fora da contagem.

## 1. Alvos limpos

| Nível | Modelo | Rodadas | Gerados / passando | Taxa | Verdes | Compilou 1ª | Iterações | (B) emitidos |
|---|---|---|---|---|---|---|---|---|
| Unitário | ChatGPT | 21 | 374 / 373 | 99,7% | 20 | 21 | 6 | 1 |
| Unitário | Gemini | 21 | 264 / 264 | 100% | 21 | 21 | 2 | 0 |
| Widget | ChatGPT | 9 | 152 / 113 | 89,0% | 2 | 3 | 24 | 5 |
| Widget | Gemini | 9 | 71 / 55 | 77,5% | 6 | 6 | 17 | 4 |
| Integração | ChatGPT | 9 | 50 / 43 | 86,0% | 4 | 1 | 20 | 1 |
| Integração | Gemini | 9 | 41 / 23 | 79,3% | 4 | 4 | 20 | 3 |
| **E2E** | ChatGPT | 9 | 43 / 26 | **60,5%** | 3 | 4 | 22 | **11** |
| **E2E** | Gemini | 9 | 29 / 25 | **89,3%** | 6 | 8 | 17 | 7 |
| Todos | ChatGPT | 48 | 619 / 555 | 93,4% | 29 | 29 | 72 | 18 |
| Todos | Gemini | 48 | 405 / 367 | 93,6% | 37 | 39 | 56 | 14 |

## 2. Bugs plantados

| Nível | Modelo | Rodadas | Taxa | Verdes | Compilou 1ª | Não compila no final | Capturou | Caracterizou c/ alerta | Viu sem asserção | Canonizou | Não viu |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Unitário | ChatGPT | 6 | 98,4% | 5 | 6 | 0 | 1 | 5 | 0 | 0 | 0 |
| Unitário | Gemini | 6 | 100% | 6 | 6 | 0 | 0 | 5 | 1 | 0 | 0 |
| Widget | ChatGPT | 6 | 95,3% | 1 | 2 | 3 | 0 | 3 | 0 | 0 | 3 |
| Widget | Gemini | 6 | 91,8% | 3 | 4 | 0 | 0 | 0 | 0 | 3 | 3 |
| Integração | ChatGPT | 6 | 37,9% | 2 | 2 | 1 | 0 | 2 | 1 | 2 | 1 |
| Integração | Gemini | 6 | 47,6% | 2 | 2 | 1 | 0 | 0 | 2 | 2 | 2 |
| **E2E** | ChatGPT | 7 (+2 s/ dado) | 70,0% | 0 | 3 | 1 | **4** | 0 | 0 | **0** | 3 |
| **E2E** | Gemini | 9 | 55,2% | 1 | 8 | 0 | **7** | 0 | 0 | **0** | 2 |
| Todos | ChatGPT | 25 | 82,5% | 8 | 13 | 5 | 5 | 10 | 1 | 2 | 7 |
| Todos | Gemini | 27 | 80,8% | 12 | 20 | 1 | 7 | 5 | 3 | 5 | 7 |

Por bug (aba "Detecção por bug"): U-CRASH/U-SILENT caracterizados por quase todos; W-CRASH invisível nos 2 modelos × 3 estratégias; W-SILENT caracterizado ×3 no ChatGPT, canonizado ×3 no Gemini; I-CRASH nunca capturado nas originais; I-SILENT caracterizado (ChatGPT) / visto em prosa (Gemini), canonizado em COT nos dois; L4 capturado 6/6; P2 capturado 5/5 das que chegaram à lista; C3 capturado só pela FS do Gemini.

## 3. Por estratégia (todos os níveis)

| Estratégia | Modelo | Limpos: taxa | Verdes /16 | Compilou 1ª /16 | Bugs: Capturou + Caracterizou | Canonizou | Não viu |
|---|---|---|---|---|---|---|---|
| ZS | ChatGPT | 95,9% | 10 | 11 | 5 /8 | 0 | 2 |
| ZS | Gemini | 99,4% | 14 | 13 | 4 /9 | 1 | 3 |
| FS | ChatGPT | 88,0% | 9 | 9 | 6 /9 | 0 | 3 |
| FS | Gemini | 93,0% | 13 | 14 | 4 /9 | 1 | 2 |
| COT | ChatGPT | 93,8% | 10 | 9 | 4 /8 | 2 | 2 |
| COT | Gemini | 88,2% | 10 | 12 | 4 /9 | 3 | 2 |

## 4. Leituras

**4.1 A aprovação cai com o nível no ChatGPT e não no Gemini.** ChatGPT: 99,7 → 89 → 86 → 60%. Gemini: 100 → 78 → 79 → **89%**. O E2E do Gemini é mais verde que seu widget e sua integração — porque o obstáculo dos níveis intermediários (mockar `FirebaseAuth.instance` estático na `TelaInicialScreen`, caminho de import, APIs de mock inexistentes) desaparece quando o app roda de verdade contra os emuladores. No ChatGPT o E2E é o pior nível: 5 de 9 gerações sem compilar (`material.dart` e imports de tela faltando) e 11 reparos (B), 9 deles falsos.

**4.2 Compilar na primeira é a diferença entre os modelos a partir do widget.** Limpos: ChatGPT 21/21 → 3/9 → 1/9 → 4/9; Gemini 21/21 → 6/9 → 4/9 → 8/9. A taxa final mascara isso (o ChatGPT recupera no reparo); o custo em iterações não: 72 × 56.

**4.3 A detecção muda de natureza conforme sobe.** Unitário: os dois *caracterizam* (asserção fixa o bug, resposta avisa) — 11 de 12. Widget: o ChatGPT caracteriza o W-SILENT e o Gemini canoniza; W-CRASH não existe para nenhum. Integração: pior nível, com canonização nos dois e o I-CRASH nunca exercitado. **E2E: Capturou vira a norma (4/7 e 7/9) e Canonizou zera nos dois modelos.** A razão é estrutural: navegação errada e `RangeError` não são "fixáveis" por asserção — o teste falha e o modelo não tem como acomodar sem remover o cenário, o que o template de reparo proíbe sob (B). O único bug E2E acomodável (C3, texto na saudação) teve o pior resultado: 1 captura em 8 com dado.

**4.4 Capturar não é diagnosticar.** Nas 11 capturas E2E, a classe (B) foi correta mas a causa quase sempre errada (L4: nenhum dos 12 reparos cogitou a rota trocada; raciocinam sobre o `login.dart` do prompt, que está certo). O (B) correto com causa certa só aparece em CRASH com arquivo:linha na saída (P2) — e nas rodadas limpas, nos defeitos reais não plantados (`setState` após `dispose`, `tela-inicial.dart:161`; `criar_playlist.dart:41`).

**4.5 Estratégia não é o fator.** Nenhuma estratégia vence nos dois modelos em aprovação ou detecção. FS tem a pior aprovação nos dois (caminho de import na Fase 2; `material.dart` na Fase 3) — mede a ausência de material tanto quanto a estratégia. COT concentra as canonizações (2 + 3 das 7) e as consultas à web do ChatGPT (5 das 6). A detecção por estratégia é plana: 4–6 "viu" por 8–9 rodadas em todas as células.

**4.6 Volume.** O ChatGPT gera 1,5× mais em todos os níveis (619 × 405 limpos; 207 × 148 bugs) e isso não vira aprovação nem detecção; vira iteração.

**4.7 Erros de teste antes do sintoma e cenário não coberto são a maior fonte de "Não viu".** Fase 2: caminho de import (FS) e material divergente do I-CRASH (lacunas de material); Fase 3: nome com dígito ("Usuário E2E") derrubou 3 das 5 rodadas de C3 antes do sintoma — e aqui **não** é lacuna de material: a regra `RegExp(r'[^a-zA-ZÀ-ÿ\s]')` → "O nome não pode conter números" está no `cadastro.dart` colado verbatim no prompt; o modelo tinha a regra e não a aplicou ao próprio dado de teste. Dos 14 "Não viu" da pirâmide, 4 são rodadas derrubadas por erro de teste antes do sintoma (C3-ZS e C3-FS do ChatGPT, P2-COT do ChatGPT, C3-ZS do Gemini), 9 são cenário nunca coberto (W-CRASH ×6, I-CRASH ZS/FS do Gemini e FS do ChatGPT) e 1 chegou ao sintoma sem afirmá-lo (C3-COT do Gemini).

**4.8 Para declarar com a tabela.** Condições de sessão distintas (ChatGPT deslogado, Luna; Gemini logado, 3.8 Flash); 2 células do ChatGPT no E2E sem dado por limitação do serviço; não determinismo do E2E (COT-02 ChatGPT, FS-02 Gemini); n = 1 por célula, sem inferência estatística; (B) corretos/falsos auditados por um único avaliador.
