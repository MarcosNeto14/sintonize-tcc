# FASE3-E2E-ZS-02_cadastroFlow — Gemini (rodada limpa)

Rodada 8 do plano (bloco 1 — ZS, Gemini). Documentada a partir de
`fase3-e2e/template_rodada.md`. **Executada em 2026-10-05 na segunda máquina
(`DESKTOP-6ETPO2H`)**, em conversa nova, depois de puxar a rodada 7 (`7d23df2`),
feita na máquina original.

**Resultado em uma linha:** 4 testes gerados; **2/4** na geração. Passaram as
validações e o fluxo completo; falharam o e-mail duplicado e o "nenhum gênero".
Reparo 1 (A): troca o CEP por `50000-000` e tira o Dropdown → **1/4**
(regressão; o fluxo completo também cai). Reparo 2 (A): espera ativa por `pump`
→ **4/4 verde**, mas **sem a asserção da saudação** na `TelaInicialScreen`.

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-E2E-ZS-02_cadastroFlow (limpa) |
| **Modelo** | Gemini |
| **Fluxo alvo** | cadastro — tela de boas-vindas → `CadastroScreen` → `GenerosCadastroScreen` → `TelaInicialScreen` |
| **Estado do `lib/`** | limpo — `git diff ccae44a -- lib/` vazio no worktree de execução, conferido antes da conversa |
| **Worktree usado** | `C:\Users\Marcos\Desktop\sintonize-fase3`, branch `fase3-e2e` na ponta `7d23df2` (o mesmo checkout executa e commita) |
| **Nível da pirâmide** | E2E (integration_test no AVD, emuladores Firebase) |
| **Estratégia de prompt** | Zero-shot |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/zero-shot/FASE3-E2E-ZS-02_cadastroFlow.md` — sha256 `ba091a05d54d5b3abcc808382f2a6c62a37165172c3475d367f81ef45a3a6410`, igual ao de `prompts_prontos/_sha256.txt` |
| **✦ Modelo declarado pelo LLM** | Não perguntado. Vale a mesma regra da rodada 7 (nota de 2026-09-21 em `fase2-gemini/README.md`): o Gemini não declara versão |
| **✦ Verificação externa da versão** | Não consultada. O autor foi lembrado de conferir o seletor em 3.8 Flash antes de colar e não apontou divergência. **Sem print do seletor** (decisão do autor registrada na rodada 7) |
| **Sessão** | Gemini logado, conta Pro, seletor em 3.8 Flash (conferência do autor) |
| **Consultou fontes externas?** | Não — nenhum marcador de citação nas três respostas |
| **Data de acesso** | 2026-10-05 |
| **Conversa nova?** | Sim — `https://gemini.google.com/app/07f6ac9f1e8f70f8` (geração e os 2 reparos) |
| **Versão do Flutter** | Flutter 3.41.6 · Dart 3.11.4 |
| **AVD** | `tcc_e2e` (Pixel 6, API 34, google_apis, x86_64); `emulator-5554` |
| **firebase-tools** | 15.31.0 |

---

## Procedimento operacional (executado)

Antes da conversa / da execução:

- [x] `git pull` na `fase3-e2e` (trouxe a rodada 7); `lib/` limpo (diff vs `ccae44a` vazio); `integration_test/fase3/` só com as subpastas `chatgpt/` e `gemini/`.
- [x] AVD `tcc_e2e` ligado (`-no-snapshot-load -no-boot-anim`), `sys.boot_completed = 1`.
- [x] Emuladores Firebase (`--only auth,firestore --project sintonize-fa494`) desacoplados por `Start-Process cmd /c`, a partir da raiz do worktree.

Na conversa:

- [x] Prompt carregado no clipboard por script (50.404 caracteres, o mesmo tamanho da rodada ChatGPT; início "Gere um teste end-to-end em Dart…", fim "…para os imports do projeto"), **colado e enviado à mão pelo autor**.
- [x] O autor devolveu as respostas **colando o texto na conversa com o Claude** (não pelo clipboard); transcrições salvas sem edição. O código foi salvo sem editar em `integration_test/fase3/cadastro_zs_test.dart`. O modelo nomeou o arquivo `cadastro_fluxo_test.dart`; a convenção fixa `cadastro_zs_test.dart`. Estado final arquivado em `integration_test/fase3/gemini/cadastro_zs_test.dart` (sha256 `5fcb891c07dc79f7552af8bc5c8f5fe370d2b214d1287ebc357b66f9ebb716e1`).

A cada execução (3, todas válidas):

- [x] Emuladores recém-subidos (iteração 0) ou derrubados e subidos de novo (iterações 1 e 2); `seed_test` rodado; conferido por REST antes de cada execução: 1 conta no Auth, 1 doc em `usuarios`, 5 em `musica`. O script aborta se não der 1/1/5.
- [x] `flutter test integration_test/fase3/cadastro_zs_test.dart -d emulator-5554`, um por comando.
- [x] Saídas íntegras em `resultados/gemini/FASE3-E2E-ZS-02_cadastroFlow_iter{0,1}.txt` e `_iter2_final.txt`.
- [x] Print do AVD depois das execuções com falha: `evidencias/gemini/FASE3-E2E-ZS-02_cadastroFlow_iter{0,1}.png`. Mesma limitação das rodadas anteriores: o print sai depois do fim da suíte e mostra o estado do último teste.
- [x] Reparos: só o template fixo com a saída literal, na mesma conversa (`..._transcricao/prompt_reparo_iter{1,2}.txt`, 10.575 e 12.224 caracteres), carregados no clipboard por script e colados pelo autor.

Depois da rodada:

- [x] Teste final arquivado em `integration_test/fase3/gemini/`; doc, resultados, evidências e transcrição commitados juntos na `fase3-e2e`.
- [ ] Codificação manual-first: não se aplica (rodada limpa).

---

## Prompt Enviado

Texto entre o segundo e o terceiro `---` de
`fase3-e2e/prompts_prontos/zero-shot/FASE3-E2E-ZS-02_cadastroFlow.md`, sem
alteração (50.404 caracteres). Não é repetido aqui; o arquivo e o sha256 são o
registro.

---

## Resposta do LLM

Resposta completa em `FASE3-E2E-ZS-02_cadastroFlow_transcricao/iter0_resposta.md`:
apresentação, lista "Detalhes contemplados no teste", o arquivo inteiro e
"Como executar o teste". Em português, sem Canvas aparente, sem fontes
externas. São 4 `testWidgets`, todos com `pumpAndSettle()` como única espera:

1. validações: formulário vazio (6 mensagens de obrigatoriedade) e nome com dígito;
2. e-mail já cadastrado (`tester@sintonize.test`, o do seed): espera SnackBar com "Erro ao cadastrar:";
3. nenhum gênero selecionado: espera "Selecione pelo menos um gênero musical!";
4. fluxo completo: preenche os 10 campos e o Dropdown de estado, confere `currentUser` e o doc `usuarios/{uid}` (nome e cidade), liga Rock e Jazz, confirma, e afirma a `BottomNavigationBar`, "Pesquisa Direta", "Minha Conta", a saudação "…essa é a nossa recomendação de música para você!" e `generos_favoritos` = {Rock, Jazz} no Firestore.

Os testes 2 e 3 preenchem só nome, data, e-mail, senhas, CEP e número.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim, nas três |
| **Testes gerados** | 4 |
| **Testes passaram (iteração 0)** | 2 (validações; fluxo completo) |
| **Testes falharam (iteração 0)** | 2 (e-mail duplicado; nenhum gênero) |
| **Testes passaram (estado final arquivado)** | 4 |
| **Testes falharam (estado final arquivado)** | 0 |
| **Melhor estado intermediário** | = final |
| **Tempo por execução** | iter0: 22 s de teste (Gradle 15 s); iter1: 22 s (Gradle 19 s); iter2: 33 s (Gradle 36 s). Gradle em cache nesta máquina |
| **Prints tirados** | `evidencias/gemini/FASE3-E2E-ZS-02_cadastroFlow_iter0.png`, `_iter1.png` |

### Saída do terminal (iteração 0)

Íntegra em `resultados/gemini/FASE3-E2E-ZS-02_cadastroFlow_iter0.txt`. Núcleo:

```
Expected: exactly one matching candidate
  Actual: _TextContainingWidgetFinder:<Found 0 widgets with text containing Erro ao cadastrar:: []>
  ... cadastro_zs_test.dart:100:7
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS ...
  ... cadastro_zs_test.dart:128:7
Warning: A call to tap() with finder "... DropdownMenuItem<String> ... "PE" ..." derived an Offset (Offset(209.7, 848.0)) that would not hit test on the specified widget.
00:22 +2 -2: Some tests failed.
```

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** nos testes 2 e 3, o que era esperado depois do `_submit` não apareceu. Nesta saída não há rastro de `_submit` rodando depois do fim do teste (na iteração 1 há). A causa não foi provada; ver a auditoria.
- **Prompt de reparo enviado:** template fixo + saída literal de `_iter0.txt` (10.575 caracteres) — `FASE3-E2E-ZS-02_cadastroFlow_transcricao/prompt_reparo_iter1.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `..._transcricao/iter1_resposta.md`. Diagnóstico: o `enterText` "atribui o texto diretamente ao controller sem disparar todas as etapas intermediárias de digitação do TextInputFormatter", então `50000000` ficaria sem hífen e `_validateCEP` barraria o formulário. Sobre o Dropdown: "PE" está fora da área visível e o estado não tem validador. Correção: CEP `50000-000` e datas com barras nos 3 testes que preenchem o formulário; Rua preenchida nos testes 2 e 3; no teste 4, **sai o Dropdown** e Jazz vira Pop.
- **★ Autoclassificação do modelo:** (A) — "O teste presume um comportamento que não é o especificado."
- **Resultado após correção:** **1/4** — Falhou. Regressão: além de 2 e 3, agora cai o fluxo completo (`currentUser` nulo, linha 175). A saída traz duas exceções depois do fim dos testes (`This widget has been unmounted`, em `_CadastroScreenState._submit`, `cadastro.dart:172` e `:176`): o formulário passou a chegar ao Firebase, e a resposta chegou depois do fim do teste.
- **Print:** `evidencias/gemini/FASE3-E2E-ZS-02_cadastroFlow_iter1.png`

### Iteração 2

- **Motivo da falha:** as asserções que dependem do Auth/Firestore rodam logo depois de um `pumpAndSettle()`, que não espera I/O fora do framework.
- **Prompt de reparo enviado:** template fixo + saída literal de `_iter1.txt` (12.224 caracteres) — `..._transcricao/prompt_reparo_iter2.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `..._transcricao/iter2_resposta.md`. Diagnóstico correto e apoiado no rastro: "o pumpAndSettle() retornou imediatamente" porque a requisição ao emulador não agenda frames. Correção: auxiliar `waitForCondition` (laço de `pump(100 ms)`, timeout de 15 s) depois de cada submissão, esperando o SnackBar, o título da tela de gêneros e a `BottomNavigationBar`. **A asserção da saudação (`textContaining('essa é a nossa recomendação de música para você!')`) foi removida** sem menção na resposta.
- **★ Autoclassificação do modelo:** (A) — "O teste presume um comportamento que não é o especificado."
- **Resultado após correção:** **4/4** — Passou.
- **Print:** — (sem falha)

### Iteração 3

Não necessária.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A), (A) |
| **★ Classificação humana (auditoria)** | Iteração 0: **Erro de teste**, causa não provada (ver abaixo). Iteração 1: **Erro de teste** (espera insuficiente por estado assíncrono) |
| **★ Concordância** | Sim na classe, nas duas. No reparo 1 a classe está certa, mas o diagnóstico contradiz o código |
| **★ Observações** | (1) **O diagnóstico do CEP no reparo 1 é falso.** `enterText` passa pelos `inputFormatters`, e o campo CEP começa com `FilteringTextInputFormatter.digitsOnly`. `50000000` e `50000-000` dão o mesmo texto no controller (`50000-000`), e o mesmo vale para as datas. A troca não pode ter sido o que mudou o resultado. A única mudança efetiva nos testes 2 e 3 foi preencher a Rua, que não tem validador. Fica sem causa provada por que o formulário não chegou ao Firebase na iteração 0 (nenhum rastro de `_submit`) e chegou na 1. Uma hipótese não verificada: o CEP com 9 caracteres dispara uma consulta real ao ViaCEP (`_fetchAddressFromCEP`), que reescreve Rua/Bairro/Cidade/Estado de forma assíncrona. (2) **O fluxo completo passou na iteração 0 só com `pumpAndSettle()`** e caiu na iteração 1 por `currentUser` nulo. É a mesma espera insuficiente, com resultado dependente do tempo de resposta do emulador; o teste da geração era frágil, não correto. (3) **O verde final reduziu o escopo:** a saudação na `TelaInicialScreen`, afirmada desde a geração, sumiu no reparo 2 sem justificativa. O fluxo continua verificado pela `BottomNavigationBar`, por "Pesquisa Direta"/"Minha Conta" e pelos gêneros persistidos no Firestore. É o mesmo padrão da ZS-03 do ChatGPT (verde com troca da asserção da saudação) e o oposto da ZS-01 do Gemini, que manteve a saudação. (4) Comparação direta: a ZS-02 do ChatGPT terminou em 2/5 com (A),(A),(B); aqui, 4/4 com (A),(A). |
