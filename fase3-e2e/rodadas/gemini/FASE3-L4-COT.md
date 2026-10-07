# FASE3-L4-COT — Gemini (rodada com bug L4)

Rodada 34 do plano (bloco 3 — COT, Gemini). Documentada a partir de
`fase3-e2e/template_rodada.md`. **Executada em 2026-10-06 na segunda máquina
(`DESKTOP-6ETPO2H`)**, em conversa nova, com envio e cópia automatizados
(Claude in Chrome). O prompt é o de `FASE3-E2E-COT-01_loginFlow` (o mesmo da
rodada limpa, sem menção a bug); o teste roda no worktree com o L4 ativo.

**Resultado em uma linha:** 6 testes gerados; **5/6 nas 4 execuções**, sempre
no teste de sucesso (`Found 0 widgets with type "TelaInicialScreen"`). Reparo 1
**(A)** (espera insuficiente pelo I/O do emulador), com arquivo novo que
acrescenta polling e mantém a asserção de destino; reparos 2 e 3 **(B)**, sem
código de teste, dizendo explicitamente que a asserção "deve ser mantida" —
mas apontando causas erradas (exceção fora de `FirebaseAuthException`, `initState`
da `TelaInicialScreen`, `historico_musicas` nulo), nunca a rota trocada.
**Manual-first: Capturou** (já na iteração 0).

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-L4-COT (bug L4) |
| **Modelo** | Gemini |
| **Fluxo alvo** | login — boas-vindas → `LoginScreen` → `TelaInicialScreen` |
| **Bug ativo** | L4 — `lib/login.dart:36`, `MaterialPageRoute(builder: (context) => const TelaInicialScreen())` → `CadastroScreen()` |
| **Estado do `lib/`** | worktree em `eb14334`; `git diff --stat eb14334 -- lib/` vazio; `git diff ccae44a -- lib/` só em `lib/login.dart` (1 linha), conferido antes da geração |
| **Worktree usado** | `C:\Users\Marcos\Desktop\sintonize-fase3-L4`, detached em `eb14334`. `firebase_test_helper.dart` idêntico ao da ponta da `fase3-e2e` (`cmp`); `seed.dart` e `seed_test.dart` iguais a menos de CRLF (`diff --strip-trailing-cr`) |
| **Nível da pirâmide** | E2E (integration_test no AVD, emuladores Firebase) |
| **Estratégia de prompt** | Chain-of-Thought |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/cot/FASE3-E2E-COT-01_loginFlow.md` — sha256 `199c50d657c4073a112b02cd4fa6c3823ccf1774519c4d2bbeb28c147b27bfdf`, igual ao de `_sha256.txt`; 34.484 caracteres enviados (35.458 no editor, os mesmos valores da COT-01 limpa) |
| **✦ Modelo declarado pelo LLM** | Não perguntado (regra das rodadas Gemini) |
| **✦ Verificação externa da versão** | Seletor aberto antes do envio: **3.8 Flash** marcado. Print: `evidencias/gemini/FASE3-L4-COT_seletor_38flash.jpg` |
| **Sessão** | Gemini logado, conta Pro, 3.8 Flash |
| **Consultou fontes externas?** | Não |
| **Data de acesso** | 2026-10-06 |
| **Conversa nova?** | Sim — `https://gemini.google.com/app/eec230273581473b` (geração e 3 reparos) |
| **Versão do Flutter / AVD / firebase-tools** | 3.41.6 · Dart 3.11.4 / `tcc_e2e` API 34, `emulator-5554` / 15.31.0 |

---

## Procedimento operacional (executado)

- [x] Seletor conferido (3.8 Flash); prompt carregado no clipboard por script, colado por Ctrl+V e conferido no editor por JavaScript (35.458 caracteres; início "Quero que você gere um teste end-to-end…", fim "…para os imports do projeto."); enviado.
- [x] Respostas: Markdown do botão "Copiar" logo abaixo de cada resposta, conferido no clipboard antes de gravar; salvas sem edição em `FASE3-L4-COT_transcricao/iter{0..3}_resposta.md`.
- [x] Código: maior bloco ```dart, sem editar, em `integration_test/fase3/l4_cot_test.dart` **do worktree L4** (o modelo nomeou o arquivo `login_flow_test.dart` no comentário da primeira linha). Geração: `teste_iter0_geracao.dart` (7.659 caracteres, sha256 `d75bcfbf…6a0e`). Reparo 1: arquivo completo, `teste_iter1.dart` (8.134, sha256 `8896b88b…99c8`). Reparos 2 e 3: sem código de teste (só trechos do app), arquivo reexecutado inalterado (conferido por `cmp` antes de cada execução). Arquivado em `integration_test/fase3/gemini/l4_cot_test.dart` (= `teste_iter1.dart`).
- [x] 4 execuções, cada uma com emuladores Firebase derrubados e subidos de novo, `seed_test` **no worktree L4** e conferência REST 1/1/5. Saídas `resultados/gemini/FASE3-L4-COT_iter{0,1,2}.txt`, `_iter3_final.txt`; prints pós-suíte `evidencias/gemini/FASE3-L4-COT_iter{0..3}.png` (mostram a tela inicial do Android: o app já foi encerrado pelo `tearDownAll`).
- [x] Reparos: template fixo + saída literal (`prompt_reparo_iter{1,2,3}.txt`, 6.599 caracteres cada — as três saídas falham no mesmo ponto).
- [x] Codificação manual-first feita (abaixo).

### Ocorrências de operação

1. **Leitura atrasada do envio da geração.** Logo depois do clique na seta, duas leituras por JavaScript (6 s e 26 s depois) ainda mostravam o editor cheio, nenhuma pergunta e a URL `/app`; a captura de tela mostrava a mensagem enviada e a geração em curso. O script clicou a seta uma segunda vez dentro desse intervalo; a conversa tem **uma** mensagem de geração (conferido: 1 `user-query` antes do reparo 1). Mesmo fenômeno da ocorrência 3 da L4-FS.
2. **URL da conversa.** Antes do reparo 1 a página ainda estava em `/app`; o link do item mais recente da barra lateral apontava para outro id (`a04f10a53118bc47`), que não é desta conversa. A URL real (`eec230273581473b`) apareceu ao enviar o reparo 1, com 2 perguntas e 2 respostas. O cabeçalho de `iter0_resposta.md` foi corrigido para a URL real antes de qualquer outra gravação.
3. **Clipboard ocupado** ao carregar o reparo 2 (`Set-Clipboard` falhou uma vez, logo depois da cópia pelo navegador); repetido 2 s depois, com conferência de tamanho.
4. **Extensão desconectada** durante a espera pelo reparo 3 ("Browser extension is not connected"); reconectou na chamada seguinte, sem recarregar a página e sem nada enviado.

---

## Resposta do LLM

`..._transcricao/iter0_resposta.md`. Passos de raciocínio (análise do fluxo,
dependências — Auth, Firestore, massa do seed —, caminho de navegação, cenários)
e 6 `testWidgets` com um helper `navigateToLoginScreen`: sucesso ponta a ponta
(afirma `LoginScreen` ausente, `TelaInicialScreen` presente e a saudação com
"Tester Sintonize, essa é a nossa recomendação"), campos vazios, e-mail
inválido, senha curta, senha incorreta (SnackBar vermelha) e usuário
inexistente (SnackBar vermelha).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim, nas quatro |
| **Testes gerados** | 6 |
| **Testes passaram (iteração 0 / final)** | 5 / 5 |
| **Testes falharam (iteração 0 / final)** | 1 / 1 — o de sucesso |
| **Melhor estado intermediário** | = final (5/6 nas quatro) |
| **Tempo por execução** | iter0: 14 s de teste (Gradle 12 s); iter1: 24 s (11 s); iter2: 23 s (11 s); iter3: 23 s (11 s). As iterações 1–3 esperam o polling de 10 s do `waitForWidget` |

### Saída do terminal (iteração 0; as outras iguais no ponto da falha)

```
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 0 widgets with type "TelaInicialScreen": []>
   Which: means none were found but one was expected
  file:///C:/Users/Marcos/Desktop/sintonize-fase3-L4/integration_test/fase3/l4_cot_test.dart:59:9
00:14 +5 -1: Some tests failed.
```

Nas iterações 1–3 a mesma asserção falha na linha 79 (depois do `waitForWidget`).

---

## Iterative Repair Loop

| It. | Resposta | ★ Autoclassificação | Ação | Resultado |
|---|---|---|---|---|
| 1 | `iter1_resposta.md` — um único `pumpAndSettle` após o toque "se estabiliza antes do callback da Future do Firebase retornar"; acrescenta `waitForWidget` (polling de 10 s) para a `TelaInicialScreen`, para a saudação e para as SnackBars; arquivo completo | **(A)** | substituído | 5/6 |
| 2 | `iter2_resposta.md` — "mesmo com tempo suficiente … a navegação não ocorre"; os cenários 5 e 6 provam que o Auth responde; suspeita de exceção fora de `FirebaseAuthException` no `login`, de erro no `initState` da `TelaInicialScreen` (`_loadLastRecommendedMusic`, `historico_musicas` nulo) ou de código de erro inesperado do emulador; "a asserção original … deve ser mantida"; sem código de teste | **(B)** | reexecutado inalterado | 5/6 |
| 3 | `iter3_resposta.md` — mesma estrutura e mesmas três hipóteses, resumidas; sem código de teste | **(B)** | reexecutado inalterado | **5/6 (final)** |

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A), (B), (B) |
| **★ Classificação humana (auditoria)** | **(B) nas três** — a falha é o sintoma do L4: o login autentica e navega para a `CadastroScreen` (`login.dart:36`), por isso a `TelaInicialScreen` nunca aparece, com ou sem polling |
| **★ Concordância** | Reparo 1: **não** (classe errada; a espera de 10 s da iteração 1 mostra que não era tempo). Reparos 2 e 3: **classe certa, causa errada** — o modelo raciocina sobre o `login.dart` do prompt, que tem a rota correta, e procura a falha em exceções e no `initState` da tela de destino; não cogita que a rota em execução seja outra |
| **★ Observações** | (1) Nenhum reparo removeu nem enfraqueceu a asserção de destino; o reparo 2 diz por escrito que ela "deve ser mantida". (2) O argumento do reparo 2 — os cenários de erro passam em ~2 s, logo o Auth responde — é correto e é o mesmo que o roteiro manual usa para isolar o passo 5. (3) Mesmo padrão das L4-ZS e L4-FS do Gemini e da L4-COT do ChatGPT: (A),(B),(B) ou (A),(A),(B), sempre com causa errada no (B). (4) Comparação direta: a L4-COT do ChatGPT deu 6/7 nas 4 execuções com (A),(A),(B); aqui, 5/6 nas 4 com (A),(B),(B) — o Gemini chegou ao (B) uma iteração antes. |

---

## ★ Codificação manual-first

| Campo | Valor |
|---|---|
| **Código** | **Capturou** |
| **Iteração em que se define** | 0 |
| **Evidência** | O teste de sucesso falha no passo 5 do roteiro (tela de destino) com a asserção sobre a `TelaInicialScreen` — o que a coluna "com L4" descreve — nas 4 execuções; nenhum reparo trocou a asserção pelo comportamento com bug, e os reparos 2 e 3 a defendem explicitamente |
