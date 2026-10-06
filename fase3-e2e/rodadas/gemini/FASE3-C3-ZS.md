# FASE3-C3-ZS — Gemini (rodada com bug C3)

Rodada 11 do plano (bloco 1 — ZS, Gemini). Documentada a partir de
`fase3-e2e/template_rodada.md`. **Executada em 2026-10-05 na segunda máquina
(`DESKTOP-6ETPO2H`)**, em conversa nova. O prompt é o de
`FASE3-E2E-ZS-02_cadastroFlow` (o mesmo da rodada limpa, sem menção a bug); o
teste roda no worktree com o C3 ativo.

**Resultado em uma linha:** 3 testes gerados; **1/3** na geração → 1/3 (A) →
**não compila** (A, `Finder.or` inexistente) → **1/3 final** (A). O fluxo
completo nunca passa do formulário porque o nome do teste, **"Novo Usuario
E2E"**, tem um dígito e é recusado pelo validador. Os três reparos atribuem a
falha ao Dropdown, ao ViaCEP e à espera. **Manual-first: Não viu.**

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-C3-ZS (bug C3) |
| **Modelo** | Gemini |
| **Fluxo alvo** | cadastro — tela de boas-vindas → `CadastroScreen` → `GenerosCadastroScreen` → `TelaInicialScreen` |
| **Bug ativo** | C3 — `lib/cadastro.dart:149`, `'nome': _nomeController.text` → `_emailController.text` |
| **Estado do `lib/`** | worktree em `20edaaa`; `git diff --stat HEAD -- lib/` vazio, conferido antes de cada execução |
| **Worktree usado** | `C:\Users\Marcos\Desktop\sintonize-fase3-C3`, detached em `20edaaa`. `firebase_test_helper.dart` e `seed.dart` idênticos aos da ponta da `fase3-e2e` (conferido por `cmp`) |
| **Nível da pirâmide** | E2E (integration_test no AVD, emuladores Firebase) |
| **Estratégia de prompt** | Zero-shot |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/zero-shot/FASE3-E2E-ZS-02_cadastroFlow.md` — sha256 `ba091a05d54d5b3abcc808382f2a6c62a37165172c3475d367f81ef45a3a6410` |
| **✦ Modelo declarado pelo LLM** | Não perguntado (mesma regra das rodadas Gemini anteriores) |
| **✦ Verificação externa da versão** | Não consultada. O autor foi lembrado de conferir o seletor em 3.8 Flash e não apontou divergência. Sem print do seletor |
| **Sessão** | Gemini logado, conta Pro, seletor em 3.8 Flash (conferência do autor) |
| **Consultou fontes externas?** | Não — nenhum marcador de citação nas respostas |
| **Data de acesso** | 2026-10-05 |
| **Conversa nova?** | Sim — `https://gemini.google.com/app/55a6da8c2e072fc4` (geração, 3 reparos e um reenvio acidental; ver ocorrência 1) |
| **Versão do Flutter** | Flutter 3.41.6 · Dart 3.11.4 |
| **AVD** | `tcc_e2e` (Pixel 6, API 34, google_apis, x86_64); `emulator-5554` |
| **firebase-tools** | 15.31.0 |

---

## Procedimento operacional (executado)

- [x] Prompt carregado no clipboard por script (50.404 caracteres, igual ao da rodada 8), **colado e enviado à mão pelo autor** numa conversa nova.
- [x] O autor devolveu as respostas colando o texto na conversa com o Claude; transcrições salvas sem edição em `FASE3-C3-ZS_transcricao/`.
- [x] Código salvo sem editar em `integration_test/fase3/c3_zs_test.dart` **do worktree C3**. O modelo nomeou `cadastro_fluxo_test.dart` na geração e, a partir do reparo 1, `c3_zs_test.dart` (o nome que leu na saída). Reparos 1 e 2: arquivo completo, substituição integral. Reparo 3: arquivo completo, que só difere do reparo 2 no auxiliar `selecionarEstado` (conferido por `diff`); aplicado como troca desse bloco.
- [x] Antes de cada execução válida: emuladores derrubados e subidos de novo, `seed_test` **no worktree C3**, conferência por REST (1 conta no Auth, 1 doc em `usuarios`, 5 em `musica`). O script aborta se não der 1/1/5 e, depois da ocorrência 2, também se o seed passar de 5 min.
- [x] `flutter test integration_test/fase3/c3_zs_test.dart -d emulator-5554`, no worktree C3, um por comando. Saídas em `resultados/gemini/FASE3-C3-ZS_iter{0,1,2}.txt` e `_iter3_final.txt`.
- [x] Prints do AVD depois de cada execução: `evidencias/gemini/FASE3-C3-ZS_iter{0..3}.png` (tirados depois do fim da suíte; não mostram o ponto da falha).
- [x] Teste final arquivado em `integration_test/fase3/gemini/c3_zs_test.dart` e removido do worktree. O da geração está em `FASE3-C3-ZS_transcricao/teste_iter0_geracao.dart`.
- [x] Reparos: só o template fixo com a saída literal (`prompt_reparo_iter{1,2,3}.txt`: 14.498, 17.647 e 6.257 caracteres).
- [x] Codificação manual-first feita (abaixo).

### Ocorrências de operação e de ambiente

1. **Reenvio acidental do reparo 3 (fora do protocolo).** Depois da resposta ao reparo 3, o autor colou de novo, sem querer, o mesmo prompt na conversa ("colei o reparo 3 de novo sem querer"). O modelo respondeu sem código, elogiando a própria correção. A resposta está em `FASE3-C3-ZS_transcricao/FORA_DO_PROTOCOLO_reenvio_reparo3_resposta.md` e **não conta como iteração**. O teste executado na iteração 3 é o do reparo 3, sem alteração. O reenvio ocorreu depois do último reparo permitido e não afeta nenhum dado da rodada.
2. **Duas tentativas de execução da iteração 3 abortadas no seed, por falha do AVD.** (a) O app do `seed_test` entrou em "Application Not Responding" e ficou pendurado por mais de 10 min; os processos foram encerrados e o app fechado à força. (b) Na tentativa seguinte, o `seed_test` terminou com "No tests were found" e deixou o Firestore com 0 docs; o script abortou pela conferência (1/0/0). O AVD estava com carga média de 11,5 depois de 2h18 ligado. Foi reiniciado a frio e, com a carga abaixo de 4, a iteração 3 rodou normalmente. **Em nenhuma das duas tentativas o teste da rodada chegou a ser executado**; elas não contam como execução.

---

## Prompt Enviado

Texto entre o segundo e o terceiro `---` de
`fase3-e2e/prompts_prontos/zero-shot/FASE3-E2E-ZS-02_cadastroFlow.md`, sem
alteração (50.404 caracteres). Não é repetido aqui.

---

## Resposta do LLM

Resposta completa em `FASE3-C3-ZS_transcricao/iter0_resposta.md`. São 3
`testWidgets`:

1. formulário vazio: 6 mensagens de obrigatoriedade e nenhuma navegação;
2. e-mail já cadastrado (`tester@sintonize.test`): formulário completo, estado "PE" no Dropdown; espera SnackBar com "Erro ao cadastrar:";
3. fluxo completo: nome **"Novo Usuario E2E"**, formulário completo, "PE", confere a `GenerosCadastroScreen`, o alerta de nenhum gênero, liga Rock e Jazz, confere a `TelaInicialScreen` e lê o doc `usuarios/{uid}`: **`expect(userData['nome'], nomeUsuario)`** (a asserção que pegaria o C3), e-mail, data, cidade, estado e gêneros.

Todas as esperas depois do Firebase são `pumpAndSettle()`. Não afirma a saudação da `TelaInicialScreen`.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim, exceto na iteração 2 (`Finder.or`) |
| **Testes gerados** | 3 |
| **Testes passaram (iteração 0)** | 1 (formulário vazio) |
| **Testes falharam (iteração 0)** | 2 — e-mail duplicado (SnackBar ausente, linha 110); fluxo completo (`GenerosCadastroScreen` ausente, linha 163) |
| **Testes passaram (estado final arquivado)** | 1 |
| **Testes falharam (estado final arquivado)** | 2 — os mesmos (linhas 127 e 176) |
| **Melhor estado intermediário** | 1/3 (iterações 0, 1 e 3) |
| **Tempo por execução** | iter0 69 s (Gradle 19 s); iter1 92 s (19 s); iter2 falha de compilação (12 s); iter3 23 s (24 s) |
| **Prints tirados** | `evidencias/gemini/FASE3-C3-ZS_iter{0,1,2,3}.png` |

### Saída do terminal (iteração 0)

Íntegra em `resultados/gemini/FASE3-C3-ZS_iter0.txt`. Núcleo:

```
Warning: A call to tap() with finder "Found 1 widget with text "PE" (ignoring all but last): [ ... would not hit test ...
Expected: exactly one matching candidate
  Actual: _TextContainingWidgetFinder:<Found 0 widgets with text containing Erro ao cadastrar:: []>
  ... c3_zs_test.dart:110:9
This widget has been unmounted, so the State no longer has a context ...
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 0 widgets with type "GenerosCadastroScreen": []>
  ... c3_zs_test.dart:163:9
01:09 +1 -2: Some tests failed.
```

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** e-mail duplicado — a resposta do Auth chega depois do fim do teste (rastro `unmounted`); fluxo completo — o formulário não é enviado (nome com dígito; ver auditoria).
- **Prompt de reparo enviado:** template fixo + saída literal de `_iter0.txt` — `FASE3-C3-ZS_transcricao/prompt_reparo_iter1.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `..._transcricao/iter1_resposta.md`. Três causas: o toque em "PE" fora do alvo deixaria o estado nulo; a consulta real ao ViaCEP (`_fetchAddressFromCEP`) sobrescreveria os campos; e o `pumpAndSettle()` não espera o Firebase. Correção: troca "PE" por "AC" (primeiro item da lista) e põe `pump(2 s)` + `pumpAndSettle()` depois de cada envio. **Mantém os CEPs e o nome "Novo Usuario E2E".**
- **★ Autoclassificação do modelo:** (A) — "O teste presume um comportamento que não é o especificado (comportamento de interação do teste incorreto)."
- **Resultado após correção:** **1/3** — Falhou. As mesmas falhas (linhas 109 e 165). O toque em "AC" também sai fora do alvo (aviso de hit test). Ainda há o rastro `unmounted` no teste do e-mail duplicado.
- **Print:** `evidencias/gemini/FASE3-C3-ZS_iter1.png`

### Iteração 2

- **Motivo da falha:** o mesmo.
- **Prompt de reparo enviado:** template fixo + saída literal de `_iter1.txt` — `..._transcricao/prompt_reparo_iter2.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `..._transcricao/iter2_resposta.md`. Diagnóstico: o menu modal do Dropdown intercepta o toque, o menu não fecha e bloqueia o "Cadastrar". Correção: auxiliar `selecionarEstado` que procura o `Scrollable` do menu com `find.byType(Dialog).or(...)`, rola até o item e toca com `warnIfMissed: false`; volta a "PE".
- **★ Autoclassificação do modelo:** (A) — "interação incorreta com a rota de popup do DropdownButton do Flutter".
- **Resultado após correção:** **não compila** — `The method 'or' isn't defined for the type 'Finder'` (linha 38).
- **Print:** `evidencias/gemini/FASE3-C3-ZS_iter2.png`

### Iteração 3

- **Motivo da falha:** erro de compilação (API inexistente).
- **Prompt de reparo enviado:** template fixo + saída literal de `_iter2.txt` — `..._transcricao/prompt_reparo_iter3.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `..._transcricao/iter3_resposta.md`. Reconhece que `Finder` não tem `.or()` e reescreve o auxiliar usando o último `Scrollable` da árvore. Nada mais muda.
- **★ Autoclassificação do modelo:** (A) — "erro de sintaxe / compilação na API de testes do Flutter".
- **Resultado após correção:** **1/3** — Falhou. E-mail duplicado (linha 127: SnackBar ausente, agora **sem** rastro `unmounted`) e fluxo completo (linha 176: `GenerosCadastroScreen` ausente). Execução válida, depois das duas tentativas abortadas no seed (ocorrência 2).
- **Print:** `evidencias/gemini/FASE3-C3-ZS_iter3.png`

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A), (A), (A) |
| **★ Classificação humana (auditoria)** | Iterações 0, 1 e 3: **Erro de teste** (o nome com dígito barra o fluxo completo; o caso do e-mail duplicado falha por espera e/ou Dropdown, sem causa única provada). Iteração 2: **Erro de geração** (API inexistente) |
| **★ Concordância** | Sim quanto à classe (A) nas três. Os diagnósticos não acham a causa do fluxo completo |
| **★ Observações** | (1) **O fluxo completo não tinha como passar do formulário.** O nome "Novo Usuario E2E" contém o dígito 2, e o validador de `cadastro.dart` (linhas 234–237) recusa qualquer caractere fora de `[a-zA-ZÀ-ÿ\s]`. O código do validador estava no prompt. Nenhum dos três reparos tocou no nome. É **o mesmo achado da C3-ZS do ChatGPT** ("Usuário E2E"), agora nos dois modelos e com a mesma estratégia. (2) Os diagnósticos se acumulam sem provar nada: Dropdown (reparos 1 a 3), ViaCEP (reparo 1, sem nenhuma mudança no teste por causa dele) e espera de 2 s. O aviso de hit test no Dropdown é real, mas o estado não tem validador, então não barra o envio. (3) No e-mail duplicado, as iterações 0 e 1 mostram o envio acontecendo (rastro `unmounted`: a resposta chegou depois do fim do teste). Na iteração 3 o rastro some; o auxiliar novo pode ter deixado o menu aberto por cima do "Cadastrar" (toques com `warnIfMissed: false` não avisam), mas isso não foi provado. (4) A asserção que pegaria o C3 (`expect(userData['nome'], nomeUsuario)`) existe desde a geração e nunca foi alcançada. (5) A referência (`_referencia/`) não entrou em nenhum prompt. |

---

## Codificação manual-first (rubrica em `roteiro_manual.md`)

| Campo | Valor |
|---|---|
| **Bug da rodada** | C3 |
| **Sintoma manual de referência** | Passo 14: a saudação da `TelaInicialScreen` traz o e-mail no lugar do nome; fora da tela, o campo `nome` do doc `usuarios/{uid}` guarda o e-mail (passo 10) |
| **O teste chegou ao ponto do sintoma?** | Não — o fluxo completo para no envio do formulário (nome com dígito) e nunca chega à tela de gêneros |
| **Código** | **Não viu** (motivo: erro do teste antes do sintoma) |
| **Evidência** | `FASE3-C3-ZS_iter3_final.txt`: falha em `c3_zs_test.dart:176` (`GenerosCadastroScreen` ausente); a asserção `expect(userData['nome'], nomeUsuario)` não é alcançada. Nenhum reparo levantou (B) |
| **Iteração em que o código se define** | 0 (não muda nas seguintes) |
