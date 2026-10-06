# FASE3-C3-FS — Gemini (rodada com bug C3)

Rodada 23 do plano (bloco 2 — FS, Gemini). Documentada a partir de
`fase3-e2e/template_rodada.md`. **Executada em 2026-10-06 na máquina original
(`DellT4i51`)**, em conversa nova, com envio e cópia automatizados (Claude in
Chrome). O prompt é o de `FASE3-E2E-FS-02_cadastroFlow` (o mesmo da rodada
limpa, sem menção a bug); o teste roda no worktree com o C3 ativo.

**Resultado em uma linha:** 1 teste gerado; **0/1 nas 4 execuções**, sempre na
asserção `expect(dados['nome'], 'Carlos Silva')` com `Actual:
'novo_usuario_…@sintonize.test'` — o sintoma exato do C3. Reparo 1 **(A)**
(ordem dos campos), reparo 2 **(B)** sem código, descrevendo o sintoma certo
(e-mail gravado em `nome`) com causa errada (controllers recriados), reparo 3
**(A)** (finder do helper). Nenhum reparo mexeu na asserção do nome. **Manual-first:
Capturou** (já na iteração 0).

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-C3-FS (bug C3) |
| **Modelo** | Gemini |
| **Fluxo alvo** | cadastro — boas-vindas → `CadastroScreen` → `GenerosCadastroScreen` → `TelaInicialScreen` |
| **Bug ativo** | C3 — `lib/cadastro.dart:149`, `'nome': _nomeController.text` → `_emailController.text` |
| **Estado do `lib/`** | worktree em `20edaaa`; `git diff --stat HEAD -- lib/` vazio; `git diff ccae44a -- lib/` só em `lib/cadastro.dart` (1 linha) |
| **Worktree usado** | `C:\Users\marcos.neto\Desktop\sintonize-fase3-C3`, detached em `20edaaa`. `firebase_test_helper.dart`, `seed.dart` e `seed_test.dart` iguais aos da ponta da `fase3-e2e` (sem considerar CRLF) |
| **Estratégia de prompt** | Few-shot |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/few-shot/FASE3-E2E-FS-02_cadastroFlow.md` — sha256 do blob `0a48e913d051c4d623495ed73a435ab697b31a56371caae2cb0062143ff1aac2`; 52.384 caracteres enviados |
| **✦ Modelo declarado pelo LLM** | Não perguntado (regra das rodadas Gemini) |
| **✦ Verificação externa da versão** | Seletor aberto antes do envio: **3.8 Flash** marcado. Print: `evidencias/gemini/FASE3-C3-FS_seletor_38flash.png` |
| **Sessão** | Gemini logado, conta Pro, 3.8 Flash |
| **Consultou fontes externas?** | Não |
| **Data de acesso** | 2026-10-06 |
| **Conversa nova?** | Sim — `https://gemini.google.com/app/e87be200ec6e288c` (geração e 3 reparos) |
| **Versão do Flutter / AVD / firebase-tools** | 3.41.6 · Dart 3.11.4 / `tcc_e2e` API 34, `emulator-5554` / 15.31.0 |

---

## Procedimento operacional (executado)

- [x] Seletor conferido (3.8 Flash); prompt colado por Ctrl+V e conferido no editor (53.940 no editor para 52.384 no texto; início e fim conferidos); enviado.
- [x] Respostas: Markdown do botão "Copiar" logo abaixo de cada resposta, conferido no clipboard antes de gravar; salvas sem edição em `FASE3-C3-FS_transcricao/iter{0..3}_resposta.md`.
- [x] Código: maior bloco ```dart, sem editar, em `integration_test/fase3/c3_fs_test.dart` **do worktree C3**. Reparos 1 e 3 trouxeram arquivo completo (`teste_iter1.dart`, `teste_iter3.dart`). Reparo 2: sem código de teste (6 blocos, todos trechos — a asserção, o valor gravado e partes de `cadastro.dart`), arquivo reexecutado inalterado (conferido por `cmp`). Arquivado em `integration_test/fase3/gemini/c3_fs_test.dart` (sha256 `bf6c474715353e6bf44c9e97809cce1eb00d8ee39b0fde4d57aaf36acfe8fa85`).
- [x] 4 execuções, cada uma com emuladores Firebase derrubados e subidos de novo, `seed_test` **no worktree C3** e conferência REST 1/1/5. Saídas `resultados/gemini/FASE3-C3-FS_iter{0,1,2}.txt`, `_iter3_final.txt`; prints pós-suíte `evidencias/gemini/FASE3-C3-FS_iter{0..3}.png`.
- [x] Reparos: template fixo + saída literal (`prompt_reparo_iter{1,2,3}.txt`; 8.518, 5.905 e 5.905 caracteres).
- [x] Codificação manual-first feita (abaixo).

### Ocorrências de operação

1. **Reparo 1: erro genérico do Gemini.** O primeiro envio do reparo 1 voltou com "I seem to be encountering an error. Can I try something else for you?". Seguindo a orientação do autor (README, "Estado em 2026-10-06"), a mensagem foi editada acrescentando " ." ao fim e reenviada ("Atualizar"); o texto enviado passou de 8.518 para 8.520 caracteres, igual no resto. A resposta registrada é a desse reenvio. A recusa não conta como iteração nem como dado do modelo.
2. **Abas travadas** (`innerWidth` 0 depois de execuções longas): trocadas por abas novas duas vezes; nada foi enviado nelas.

---

## Resposta do LLM

`..._transcricao/iter0_resposta.md`. Um `testWidgets`: abre o cadastro,
preenche os campos (nome "Carlos Silva", e-mail com timestamp), arrasta o
formulário, escolhe "PE", toca "Cadastrar", espera a `GenerosCadastroScreen`,
escolhe Rock e Pop, confirma, espera a `TelaInicialScreen` e confere o Auth e o
documento em `usuarios`: `nome`, `email`, `data_nasc`, cidade, estado e
`generos_favoritos`.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim, nas quatro |
| **Testes gerados** | 1 |
| **Testes passaram (iteração 0 / final)** | 0 / 0 |
| **Testes falharam (iteração 0 / final)** | 1 / 1 — na asserção do `nome`, no ponto do sintoma |
| **Tempo por execução** | 28–54 s de teste (primeiro build do worktree C3 na iteração 0) |

### Saída do terminal (iteração 0; as outras iguais no ponto da falha)

```
The following TestFailure was thrown running a test:
Expected: 'Carlos Silva'
  Actual: 'novo_usuario_1791303120692@sintonize.test'
   Which: is different.
00:31 +0 -1: Some tests failed.
```

A iteração 0 tem ainda um aviso de toque fora do alvo em "PE"; o fluxo seguiu
mesmo assim até o Firestore. Nas iterações 1–3 não há aviso.

---

## Iterative Repair Loop

| It. | Resposta | ★ Autoclassificação | Ação | Resultado |
|---|---|---|---|---|
| 1 | `iter1_resposta.md` — atribui a falha à ordem dos `TextFormField` (o e-mail teria sido digitado no campo do nome); arquivo novo com preenchimento por rótulo (`preencherCampoPorLabel`) | **(A)** | substituído | 0/1 (mesma asserção) |
| 2 | `iter2_resposta.md` — sem código. Descreve o e-mail gravado em `nome`, mantém a asserção e suspeita de troca/reuso de controllers ou de chaves nos campos de `CadastroScreen` | **(B)** | reexecutado inalterado | 0/1 |
| 3 | `iter3_resposta.md` — volta a culpar o teste: o finder do helper (`find.ancestor(... Column).first`) englobaria vários campos; arquivo novo com outro finder | **(A)** | substituído | **0/1 (final)** |

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A), (B), (A) |
| **★ Classificação humana (auditoria)** | **(B) nas três** — a falha é o sintoma do C3: `cadastro.dart:149` grava `_emailController.text` em `nome` |
| **★ Concordância** | Reparo 1: **não**. Reparo 2: **classe e sintoma certos, causa errada** — descreve exatamente o que foi gravado, mas atribui a controllers recriados, não à linha trocada (o prompt mostra o `cadastro.dart` limpo, com `'nome': _nomeController.text`). Reparo 3: **não** (volta para (A) depois de ter dito (B), sem saída nova que justifique a troca) |
| **★ Observações** | (1) Os três reparos mantiveram `expect(dados['nome'], 'Carlos Silva')`: o teste nunca foi ajustado ao bug. (2) Oscilação (A)→(B)→(A) com a mesma saída nas iterações 1 e 2. (3) Primeira rodada C3 do Gemini a chegar ao sintoma: na C3-ZS o teste parava antes (nome com dígito barrava o formulário, "Não viu"). |

---

## ★ Codificação manual-first

| Campo | Valor |
|---|---|
| **Código** | **Capturou** |
| **Iteração em que se define** | 0 |
| **Evidência** | Falha na asserção sobre o `nome` gravado no Firestore, com o e-mail como valor real — o que a coluna "com C3" descreve — nas 4 execuções; nenhum reparo trocou a asserção |
