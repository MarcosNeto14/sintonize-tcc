# FASE2-INT-FS-02_cadastroFlow — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-INT-FS-02 |
| **Fluxo testado** | Cadastro — `CadastroScreen` → `GenerosCadastroScreen` (`lib/cadastro.dart`, `lib/generos-cadastro.dart`) |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio das demais rodadas da Fase 2) |
| **Data de acesso** | 2026-09-18 |
| **Conversa nova?** | Sim — `https://chatgpt.com/uc/6aad7949-5400-83ea-80f6-ff92bbf901c1` |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/integration/cadastro_flow_fs_test.dart` |
| **Execução** | Automação de navegador (Claude in Chrome) |
| **Iterações de reparo** | 3 (o máximo permitido) |
| **Resultado final** | **0/2** |

**Verificação pré-rodada:** idêntica à de `FASE2-INT-ZS-02` — bug I-CRASH
revertido, apenas injeção de dependência em relação a `main`. Prompt usado
**sem** desvio.

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/integration/few-shot/FASE2-INT-FS-02_cadastroFlow.md`
— um exemplo de teste de integração bem escrito seguido do código completo das
duas telas colado verbatim (27.879 caracteres, o maior prompt da Fase 2).
Texto exato em `FASE2-INT-FS-02_transcricao/prompt_intfs02.txt`.

---

## Resposta do LLM

Transcrições exatas em `FASE2-INT-FS-02_transcricao/`.

### Mensagem inicial (geração dos testes)

Gerou apenas **2 testes**: o fluxo completo e a validação de "nenhum gênero
selecionado". Suíte bem menor que a da rodada zero-shot no mesmo alvo (3
testes) e a menor de qualquer rodada da Fase 2.

**Erro de geração notável:** todos os três imports do projeto usaram
`package:sintoniza/` em vez de `package:sintonize/` — um erro de **uma única
letra** no nome do package, diferente da alucinação de *caminho* vista em
`CriarPlaylistScreen`. Os nomes de arquivo estavam corretos, inclusive o
hifenizado `generos-cadastro.dart`.

Observações espontâneas corretas na resposta:

- Notou que `CadastroScreen` passa os objetos injetados adiante para
  `GenerosCadastroScreen`, o que permite usar `MockFirebaseAuth` e
  `FakeFirebaseFirestore` sem tocar nos serviços reais.
- Recomendou, por conta própria, **extrair `_fetchAddressFromCEP` para um
  serviço injetável** — a mesma conclusão a que as rodadas de integração do
  fluxo de login chegaram sobre `TelaInicialScreen`, e que o protocolo não
  permite aplicar.

### Iteração 1 (repair) — a suíte não compila

- **Motivo da falha:** `Couldn't resolve the package 'sintoniza'` (3
  ocorrências) e os erros em cascata de símbolos não encontrados.
- **Resposta do LLM:** classificou **(A)**, corrigiu para `package:sintonize/`
  e explicou corretamente que *"o caminho do seu projeto... não determina o
  nome do package Dart. O que determina é o campo `name:` do `pubspec.yaml`"*.
- **Resultado após correção:** **a suíte passa a compilar — 0/2.**

### Iteração 2 (repair) — 2 falhas

- **Motivo da falha:** `Bad state: No element` em `Iterable.single`, dentro de
  `WidgetTester.showKeyboard`; e o `SnackBar` `"Selecione pelo menos um gênero
  musical!"` não encontrado.
- **Resposta do LLM:** classificou **(A)**, atribuiu a "uma forma de
  localizar/interagir com os campos que não corresponde à árvore de widgets
  renderizada" e reescreveu o arquivo completo. Reiterou a análise do ViaCEP,
  notando que o teste não depende dos dados retornados porque sobrescreve os
  campos de endereço depois.
- **Resultado após correção:** **0/2 — sem mudança.** A falha mudou de
  `Bad state: No element` para `Bad state: Too many elements` (agora em
  `scrollUntilVisible`).

### Iteração 3 (repair, última permitida) — 2 falhas

- **Motivo da falha:** `Bad state: Too many elements` em `Iterable.single`,
  dentro de `WidgetController.scrollUntilVisible`.
- **Resposta do LLM:** classificou **(A)** — "uma forma de rolagem que não é
  compatível com a árvore de widgets encontrada" — e reescreveu o arquivo
  completo. Separou corretamente o aviso de HTTP do problema real:
  *"[o warning do HttpClient] é relevante, mas **não é a exceção que derrubou
  esses testes**"*, e reafirmou que injetar o serviço de ViaCEP seria a
  melhoria estrutural correta, *"mas não precisamos fazer isso para corrigir o
  `Bad state: Too many elements`"*.
- **Resultado após correção:** **0/2 — sem mudança.** A falha voltou a ser
  `Bad state: No element` (em `_LastFinderMixin.filter`) mais o SnackBar não
  encontrado — ou seja, **oscilou de volta** para o estado da iteração 2.

---

## Resultado Final

**0/2** (`00:05 +0 -2`)

| # | Teste | Resultado |
|---|---|---|
| 1 | fluxo completo: cadastra usuário, cria documento, seleciona gêneros e salva no Firestore | ❌ `Bad state: No element` (`_LastFinderMixin.filter`) |
| 2 | não permite confirmar gêneros sem selecionar pelo menos um gênero | ❌ `Found 0 widgets with text "Selecione pelo menos um gênero musical!"` |

---

## Achados

Nenhum achado **(B)** — o modelo classificou **(A)** nas três iterações.

### Notas qualitativas para a análise comparativa

- **Pior resultado de toda a Fase 2: 0/2.** Nenhum teste passou no estado
  final, apesar de a suíte compilar desde a iteração 1.
- **Progressão nula e oscilante:** 0 (não compila) → 0 → 0 → 0. Mais grave que
  a estagnação da rodada zero-shot do mesmo alvo (que ao menos manteve 1
  teste passando): aqui a falha do primeiro teste **oscilou** entre
  `Bad state: No element` (iter. 1), `Too many elements` (iter. 2) e de volta a
  `No element` (iter. 3) — o modelo circulou entre duas formulações do finder
  sem convergir.
- **Erro de geração raro:** `package:sintoniza/` em vez de `sintonize` — erro
  de **uma letra no nome do package**, não de caminho. Distinto da alucinação
  de diretório observada em `CriarPlaylistScreen`, e não corrigível pela mesma
  medida (informar o caminho do arquivo no prompt não teria evitado este erro).
  Custou uma das 3 iterações de reparo.
- **Suíte mínima:** 2 testes, a menor de qualquer rodada da Fase 2 — contra 3
  na zero-shot e 19 na chain-of-thought do nível widget. A few-shot,
  que no alvo `CriarPlaylistScreen` gerou a **maior** cobertura relativa ao
  zero-shot, aqui gerou a menor.
- **Qualidade do diagnóstico ≠ qualidade do resultado.** As análises em prosa
  foram consistentemente boas nas três iterações: separou corretamente o aviso
  de HTTP da causa real das falhas, explicou corretamente que o nome do package
  vem do `pubspec.yaml` e não do diretório, e identificou por conta própria
  que extrair `_fetchAddressFromCEP` para um serviço injetável seria a
  melhoria estrutural correta. Nada disso se converteu em um teste que passa.
- **Fluxo de cadastro × fluxo de login (integração):** login fechou em 7/8,
  5/6 e 10/10; cadastro fechou em 1/3 (ZS) e 0/2 (FS). A diferença é grande e
  consistente, e a explicação mais provável é estrutural — o fluxo de cadastro
  atravessa duas telas, um `DropdownButtonFormField` com 27 itens roláveis, uma
  chamada HTTP real sem injeção e persistência no Firestore. **O orçamento de
  3 iterações de reparo parece insuficiente para este alvo**, independentemente
  da estratégia de prompt.
