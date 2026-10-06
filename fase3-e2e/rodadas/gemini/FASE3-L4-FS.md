# FASE3-L4-FS — Gemini (rodada com bug L4)

Rodada 22 do plano (bloco 2 — FS, Gemini). Documentada a partir de
`fase3-e2e/template_rodada.md`. **Executada em 2026-10-06 na máquina original
(`DellT4i51`)**, em conversa nova, com envio e cópia automatizados (Claude in
Chrome). O prompt é o de `FASE3-E2E-FS-01_loginFlow` (o mesmo da rodada limpa,
sem menção a bug); o teste roda no worktree com o L4 ativo.

**Resultado em uma linha:** 2 testes gerados; **1/2 nas 4 execuções**, sempre no
teste de sucesso (`Elemento não apareceu a tempo: Found 0 widgets with type
"TelaInicialScreen"`). Reparos 1 e 2 **(A)** (SnackBar remanescente / toque
fora do alvo), com arquivo novo e a asserção de destino mantida; reparo 3
**(B)** sem código, apontando para a `LoginScreen` com uma causa errada
(`GlobalKey` e controllers recriados no `build`). **Manual-first: Capturou** (já
na iteração 0).

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-L4-FS (bug L4) |
| **Modelo** | Gemini |
| **Fluxo alvo** | login — boas-vindas → `LoginScreen` → `TelaInicialScreen` |
| **Bug ativo** | L4 — `lib/login.dart:36`, `MaterialPageRoute(builder: (context) => const TelaInicialScreen())` → `CadastroScreen()` |
| **Estado do `lib/`** | worktree em `eb14334`; `git diff --stat HEAD -- lib/` vazio; `git diff ccae44a -- lib/` só em `lib/login.dart` (1 linha) |
| **Worktree usado** | `C:\Users\marcos.neto\Desktop\sintonize-fase3-L4`, detached em `eb14334`. `firebase_test_helper.dart`, `seed.dart` e `seed_test.dart` iguais aos da ponta da `fase3-e2e` (o helper difere só em CRLF) |
| **Estratégia de prompt** | Few-shot |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/few-shot/FASE3-E2E-FS-01_loginFlow.md` — sha256 do blob `926c6b8598ad69e1e10bd1f28fec0322cc3e8642770e1fc3a4a49a4ab6639df3`; 35.008 caracteres enviados (o mesmo da rodada 19) |
| **✦ Modelo declarado pelo LLM** | Não perguntado (regra das rodadas Gemini) |
| **✦ Verificação externa da versão** | Seletor aberto antes do envio: **3.8 Flash** marcado. Print: `evidencias/gemini/FASE3-L4-FS_seletor_38flash.png` |
| **Sessão** | Gemini logado, conta Pro, 3.8 Flash |
| **Consultou fontes externas?** | Não |
| **Data de acesso** | 2026-10-06 |
| **Conversa nova?** | Sim — `https://gemini.google.com/app/97eb647a54bf7405` (geração e 3 reparos) |
| **Versão do Flutter / AVD / firebase-tools** | 3.41.6 · Dart 3.11.4 / `tcc_e2e` API 34, `emulator-5554` / 15.31.0 |

---

## Procedimento operacional (executado)

- [x] Seletor conferido (3.8 Flash); prompt colado por Ctrl+V e conferido no editor (36.027 no editor para 35.008 no texto; início e fim conferidos); enviado.
- [x] Respostas: Markdown do botão "Copiar" logo abaixo de cada resposta, conferido no clipboard antes de gravar; salvas sem edição em `FASE3-L4-FS_transcricao/iter{0..3}_resposta.md`.
- [x] Código: maior bloco ```dart, sem editar, em `integration_test/fase3/l4_fs_test.dart` **do worktree L4**. Reparos 1 e 2 trouxeram arquivo completo (`teste_iter1.dart`, `teste_iter2.dart`; no reparo 2 o maior dos 5 blocos é o arquivo completo, os outros são trechos do app). Reparo 3: sem código de teste (3 blocos: a mensagem de erro e dois trechos de `login.dart`), arquivo reexecutado inalterado (conferido por `cmp`). Arquivado em `integration_test/fase3/gemini/l4_fs_test.dart` (sha256 `d80696510e81843f7dc83527b3c2929da18fa30d02058c8e40c4ecb7c78b1258`).
- [x] 4 execuções, cada uma com emuladores Firebase derrubados e subidos de novo, `seed_test` **no worktree L4** e conferência REST 1/1/5 (o script aborta se não der). Saídas `resultados/gemini/FASE3-L4-FS_iter{0,1,2}.txt`, `_iter3_final.txt`; prints pós-suíte `evidencias/gemini/FASE3-L4-FS_iter{0..3}.png` (tirados depois do fim da suíte; não mostram o sintoma).
- [x] Reparos: template fixo + saída literal (`prompt_reparo_iter{1,2,3}.txt`; 5.839, 5.840 e 5.840 caracteres). O montador do reparo foi validado reconstruindo byte a byte o `prompt_reparo_iter1.txt` da rodada 19.
- [x] Codificação manual-first feita (abaixo).

### Ocorrências de operação

1. **Reparo 1 enviado duas vezes, a primeira sem efeito.** Depois do primeiro clique na seta, a conversa recarregada mostrava só a mensagem da geração (1 pergunta, 1 resposta): o reparo não chegou ao modelo. Foi colado e enviado de novo, e só esse segundo envio aparece na conversa. O modelo recebeu o reparo 1 uma única vez.
2. **Abas travadas.** Duas abas do Gemini congelaram (captura de tela sem resposta, `innerWidth` 0) e foram trocadas por abas novas; nada foi enviado nelas.
3. **Leitura atrasada do envio da geração.** Logo depois do envio do prompt, uma leitura por JavaScript ainda mostrava o editor cheio e nenhuma pergunta; a captura de tela mostrava o envio feito. Não houve reenvio.

---

## Resposta do LLM

`..._transcricao/iter0_resposta.md`. Dois `testWidgets`, com auxiliar
`esperar` (laço de `pump`):

1. **falha:** credenciais inválidas, espera o SnackBar, confere fundo vermelho e a mensagem, `LoginScreen` presente e `TelaInicialScreen` ausente — passa nas 4;
2. **sucesso:** login com o usuário do seed, espera a `TelaInicialScreen`, afirma `LoginScreen` ausente, `TelaInicialScreen`, "Minha Conta" e "Pesquisa Direta" — falha nas 4 em `esperar(... TelaInicialScreen)`.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim, nas quatro |
| **Testes gerados** | 2 |
| **Testes passaram (iteração 0 / final)** | 1 / 1 (o de falha) |
| **Testes falharam (iteração 0 / final)** | 1 / 1 — o de sucesso, no ponto do sintoma |
| **Tempo por execução** | 24–38 s de teste |

### Saída do terminal (iteração 0; as outras iguais no ponto da falha)

```
The following TestFailure was thrown running a test:
Elemento não apareceu a tempo: Found 0 widgets with type "TelaInicialScreen": []
00:27 +1 -1: Some tests failed.
```

---

## Iterative Repair Loop

| It. | Resposta | ★ Autoclassificação | Ação | Resultado |
|---|---|---|---|---|
| 1 | `iter1_resposta.md` — atribui a falha a um SnackBar do teste anterior bloqueando o toque em "Entrar" e a sessão do Auth retida; arquivo novo com `signOut()` no `setUp`, limpeza do SnackBar e `ensureVisible` | **(A)** | substituído | 1/2 |
| 2 | `iter2_resposta.md` — cita `login()` e os validadores de `login.dart` (do prompt) e atribui a falha ao toque durante a transição/teclado; arquivo novo com fechamento do teclado, `ensureVisible` e `pumpAndSettle` | **(A)** | substituído | 1/2 |
| 3 | `iter3_resposta.md` — sem código de teste. Afirma que, com entrada válida, a navegação para `TelaInicialScreen` não ocorre e culpa `GlobalKey`/controllers criados no `build` de um `StatelessWidget` e o `BuildContext` após o `await` | **(B)** | reexecutado inalterado | **1/2 (final)** |

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A), (A), (B) |
| **★ Classificação humana (auditoria)** | **(B) nas três** — a falha é o sintoma do L4: o login autentica e navega para a `CadastroScreen` (`login.dart:36`), por isso a `TelaInicialScreen` nunca aparece |
| **★ Concordância** | Reparos 1 e 2: **não** (as causas propostas — SnackBar, toque fora do alvo — não aparecem na saída, que não tem aviso de hit-test). Reparo 3: **classe certa, causa errada** — aponta a `LoginScreen`, mas não a rota trocada; o modelo cita a rota correta do prompt (`TelaInicialScreen`), não a do app em execução |
| **★ Observações** | (1) Os dois reparos (A) mudaram o caminho até o botão, mas mantiveram as asserções de destino (`TelaInicialScreen` presente, `LoginScreen` ausente): o teste nunca foi ajustado ao bug. (2) Mesmo padrão da L4-ZS do Gemini: (A),(A),(B) com causa errada. |

---

## ★ Codificação manual-first

| Campo | Valor |
|---|---|
| **Código** | **Capturou** |
| **Iteração em que se define** | 0 |
| **Evidência** | O teste de sucesso falha no passo 5 do roteiro (tela de destino) com a asserção sobre a `TelaInicialScreen` — o que a coluna "com L4" descreve — nas 4 execuções; nenhum reparo trocou a asserção pelo comportamento com bug |
