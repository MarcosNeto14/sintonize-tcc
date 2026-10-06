# FASE3-E2E-COT-01_loginFlow — Gemini (rodada limpa)

Rodada 31 do plano (bloco 3 — COT, Gemini). Documentada a partir de
`fase3-e2e/template_rodada.md`. **Executada em 2026-10-06 na máquina original
(`DellT4i51`)**, em conversa nova, com envio e cópia automatizados (Claude in
Chrome). Interrompida antes da iteração 2 (falta de memória, decisão do autor)
e retomada no mesmo dia, na mesma conversa e no mesmo worktree.

**Resultado em uma linha:** 5 testes gerados; **4/5 nas 4 execuções**, sempre
no teste de sucesso, por três motivos diferentes: `TelaInicialScreen` procurada
cedo demais (iter0), saudação procurada antes do `FutureBuilder` terminar
(iter1) e, nas iterações 2 e 3, o `setState()` após `dispose` pré-existente em
`tela-inicial.dart:161`. **(B), (A), (B)** — o reparo 3 aponta a causa certa
sem código; o reparo 1 diz (B) com causa errada e traz arquivo novo.

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-E2E-COT-01_loginFlow (limpa) |
| **Modelo** | Gemini |
| **Fluxo alvo** | login — boas-vindas → `LoginScreen` → `TelaInicialScreen` |
| **Estado do `lib/`** | limpo — `git diff ccae44a -- lib/` vazio no worktree de execução |
| **Worktree usado** | `C:\Users\marcos.neto\Desktop\sintonize-fase3`, detached em `dc88352` (nenhum commit posterior tocou `lib/`) |
| **Estratégia de prompt** | Chain-of-Thought |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/cot/FASE3-E2E-COT-01_loginFlow.md` — sha256 do blob `199c50d657c4073a112b02cd4fa6c3823ccf1774519c4d2bbeb28c147b27bfdf`, igual ao de `_sha256.txt`; 34.484 caracteres enviados |
| **✦ Modelo declarado pelo LLM** | Não perguntado (regra das rodadas Gemini) |
| **✦ Verificação externa da versão** | Seletor aberto antes do envio: **3.8 Flash** marcado. Print: `evidencias/gemini/FASE3-E2E-COT-01_loginFlow_seletor_38flash.jpg` (com o prompt já no editor) |
| **Sessão** | Gemini logado, conta Pro, 3.8 Flash |
| **Consultou fontes externas?** | Não |
| **Data de acesso** | 2026-10-06 |
| **Conversa nova?** | Sim — `https://gemini.google.com/app/60b70378ac678107` (geração e 3 reparos) |
| **Versão do Flutter / AVD / firebase-tools** | 3.41.6 · Dart 3.11.4 / `tcc_e2e` API 34, `emulator-5554` / 15.31.0 |

---

## Procedimento operacional (executado)

- [x] Seletor conferido (3.8 Flash); prompt colado por Ctrl+V e conferido no editor (35.458 no editor para 34.484 no texto; início "Quero que você gere um teste end-to-end…", fim "…para os imports do projeto."); enviado.
- [x] Respostas: Markdown do botão "Copiar" logo abaixo de cada resposta, conferido no clipboard antes de gravar; salvas sem edição em `FASE3-E2E-COT-01_loginFlow_transcricao/iter{0..3}_resposta.md`.
- [x] Código: maior bloco ```dart, sem editar, em `integration_test/fase3/login_cot_test.dart`. Reparos 1 e 2 trouxeram arquivo completo (`teste_iter1.dart`, `teste_iter2.dart`); reparo 3 sem código de teste (só a mensagem de erro e o `_loadLastRecommendedMusic` do app), arquivo reexecutado inalterado (conferido por `cmp`). Arquivado em `integration_test/fase3/gemini/login_cot_test.dart` (sha256 `400617c6e7fc67470714b366e51aa5ba5769ed701e893fc2fd6d3660d1d903d6`).
- [x] 4 execuções, cada uma com emuladores Firebase subidos de novo, `seed_test` e conferência REST 1/1/5. Saídas `resultados/gemini/FASE3-E2E-COT-01_loginFlow_iter{0,1,2}.txt`, `_iter3_final.txt`; prints pós-suíte `evidencias/gemini/..._iter{0..3}.png`.
- [x] Reparos: template fixo + saída literal (`prompt_reparo_iter{1,2,3}.txt`; 8.014, 6.449 e 7.056 caracteres).
- [ ] Manual-first: não se aplica (rodada limpa).

### Ocorrências de operação

1. **Interrupção antes da iteração 2.** Na primeira tentativa da iteração 2, o `flutter test` do `seed_test` travou depois de instalar o APK (mais de 10 min, nenhum teste executado; a máquina tinha 0,5–1,0 GB de RAM livre) e foi encerrado; a segunda tentativa foi interrompida pelo autor durante o build. A saída parcial ficou em `resultados/gemini/..._iter2_interrompida.txt` (só o build) e não é resultado. A rodada foi retomada no mesmo dia com AVD e emuladores subidos de novo; a iteração 2 válida é `_iter2.txt`. O modelo não recebeu nada entre o reparo 2 e o reparo 3 além do que está nas transcrições.
2. **Reparo 1 com cerca solta** no Markdown copiado (linha 58, um ```` ``` ```` de fechamento sem abertura); o teste é o bloco ```` ```dart ```` das linhas 74–258, que bate com os 3 blocos renderizados na página.

---

## Resposta do LLM

`..._transcricao/iter0_resposta.md`. Passos de raciocínio (análise do fluxo,
cenários, decisões) e 5 `testWidgets`: login com sucesso (afirma
`TelaInicialScreen` presente, `LoginScreen` ausente e a saudação), campos
vazios, e-mail mal formatado e senha curta, senha incorreta e usuário
inexistente (SnackBar vermelho e mensagem).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim, nas quatro |
| **Testes gerados** | 5 |
| **Testes passaram (iteração 0 / final)** | 4 / 4 |
| **Testes falharam (iteração 0 / final)** | 1 / 1 — o de sucesso |
| **Tempo por execução** | 23–29 s de teste |

### Saída do terminal

Iteração 0:
```
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 0 widgets with type "TelaInicialScreen": []>
```

Iteração 1:
```
Actual: _TextContainingWidgetFinder:<Found 0 widgets with text containing essa é a nossa
recomendação de música para você!: []>
```

Iterações 2 e 3:
```
The following assertion was thrown running a test (but after the test had completed):
setState() called after dispose(): _TelaInicialScreenState#… (lifecycle state: defunct, not mounted)
#2      _TelaInicialScreenState._loadLastRecommendedMusic (package:sintonize/tela-inicial.dart:161:5)
```

---

## Iterative Repair Loop

| It. | Resposta | ★ Autoclassificação | Ação | Resultado |
|---|---|---|---|---|
| 1 | `iter1_resposta.md` — diz que o app usa um `BuildContext` inválido no `Navigator.pushReplacement` depois do `await` (cita `login.dart`); mesmo assim traz arquivo completo, com esperas ativas no lugar do `pumpAndSettle` | **(B)** | substituído | 4/5 (agora na saudação) |
| 2 | `iter2_resposta.md` — a navegação passou; a saudação vem de um `FutureBuilder` com leitura do Firestore e ainda não estava na tela; arquivo novo esperando o texto | **(A)** | substituído | 4/5 (`setState` após `dispose`) |
| 3 | `iter3_resposta.md` — sem código de teste: `_loadLastRecommendedMusic` chama `setState` sem checar `mounted`; correção no app | **(B)** | reexecutado inalterado | **4/5 (final)** |

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (B), (A), (B) |
| **★ Classificação humana (auditoria)** | Reparo 1: **(A)** — a `TelaInicialScreen` aparece quando o teste espera o bastante (iteração 1 passou desse ponto); não há defeito no `login.dart` limpo. Reparo 2: **(A) correto**. Reparo 3: **defeito pré-existente da aplicação** (real, não plantado), o mesmo da FS-01/FS-02 |
| **★ Concordância** | Reparo 1: **não** (classe e causa erradas, mas o arquivo novo corrigiu a espera). Reparo 2: **sim**. Reparo 3: **sim**, com arquivo, linha e correção |
| **★ Observações** | (1) O `setState()` após `dispose` de `tela-inicial.dart:161` derruba de novo o teste de sucesso do login, como na FS-01 do Gemini; aqui só aparece depois que o teste passa a esperar a saudação. (2) Nenhum reparo removeu asserções de destino ou de saudação. |
