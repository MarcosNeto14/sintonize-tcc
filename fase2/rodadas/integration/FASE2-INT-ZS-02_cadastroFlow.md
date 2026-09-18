# FASE2-INT-ZS-02_cadastroFlow — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-INT-ZS-02 |
| **Fluxo testado** | Cadastro — `CadastroScreen` → `GenerosCadastroScreen` (`lib/cadastro.dart`, `lib/generos-cadastro.dart`) |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio das demais rodadas da Fase 2) |
| **Data de acesso** | 2026-09-18 |
| **Conversa nova?** | Sim — `https://chatgpt.com/uc/6aad763c-3268-83ea-8eff-cf672fa2840e` |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/integration/cadastro_flow_zs_test.dart` |
| **Execução** | Automação de navegador (Claude in Chrome) |
| **Iterações de reparo** | 3 (o máximo permitido) |
| **Resultado final** | **1/3** |

**Verificação pré-rodada:** o bug **I-CRASH** (`currentUser!.uid` fora do `try`
em `_salvarGeneros()`) foi revertido antes desta rodada.
`git diff main -- lib/cadastro.dart lib/generos-cadastro.dart` mostra apenas a
injeção de dependência de `auth`/`firestore`. Prompt usado **sem** desvio — o
acréscimo do caminho do arquivo foi aplicado apenas ao alvo
`CriarPlaylistScreen`, e aqui não foi necessário: o modelo acertou os imports
de primeira, inclusive o hifenizado `package:sintonize/generos-cadastro.dart`.

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/integration/zero-shot/FASE2-INT-ZS-02_cadastroFlow.md`
— instrução direta de gerar um teste de integração para o fluxo, com o código
completo das **duas** telas colado verbatim (26.913 caracteres, o maior prompt
da Fase 2). Texto exato em `FASE2-INT-ZS-02_transcricao/prompt_intzs02.txt`.

---

## Resposta do LLM

Transcrições exatas em `FASE2-INT-ZS-02_transcricao/`.

### Mensagem inicial (geração dos testes)

Gerou **3 testes**: fluxo completo (cadastro → gêneros → Firestore), erro do
Firebase Auth, e tentativa de salvar gêneros sem usuário autenticado.

Duas observações espontâneas corretas na resposta, ambas antecipando
limitações reais registradas nas notas de protocolo da rodada:

- **ViaCEP:** *"O teste deliberadamente não espera o preenchimento automático
  pelo ViaCEP... a implementação atual chama diretamente `https://viacep.com.br`,
  então depender dela faria o teste ficar sujeito à rede."* Escreveu o teste
  para sobrescrever os campos de endereço manualmente, contornando a ausência
  de injeção do cliente HTTP em vez de tentar mockar `http.get` — que foi o que
  travou a rodada `FASE2-WIDGET-COT-01` no piloto.
- **`GenerosCadastroScreen` não recebe `uid`:** notou que a tela usa
  `auth.currentUser!.uid` e por isso verificou explicitamente que
  `auth.currentUser` está preenchido antes de prosseguir.

### Iteração 1 (repair) — a suíte não compila

- **Motivo da falha:** `'FakeCloudFirestore' isn't a type` (3 ocorrências) — o
  nome real da classe do pacote `fake_cloud_firestore` é `FakeFirebaseFirestore`.
- **Resposta do LLM:** classificou **(A)**, corrigiu o nome da classe e
  reescreveu o arquivo completo.
- **Resultado após correção:** **a suíte passa a compilar — 1/3.**

### Iteração 2 (repair) — 2 falhas (`Bad state: No element`)

- **Motivo da falha:** `Bad state: No element` em `Iterable.last`, dentro de
  `_LastFinderMixin.filter` — o finder do dropdown não encontrava candidatos.
- **Resposta do LLM:** classificou **(A)**, atribuiu a causa a "suposições
  incorretas do teste sobre o viewport e a interação com widgets fora da área
  visível" e reescreveu o arquivo completo. Reafirmou a análise do ViaCEP,
  notando corretamente que o aviso `"all HTTP requests will return status code
  400"` no log é esperado e **não é a causa da falha**.
- **Resultado após correção:** **1/3 — sem mudança.**

### Iteração 3 (repair, última permitida) — 2 falhas (dropdown "PE")

- **Motivo da falha:** `Found 0 widgets with text "PE"` dentro do helper
  `preencherCadastro`.
- **Resposta do LLM:** classificou **(A)** e entregou um **patch cirúrgico**
  na função `preencherCadastro`, explicando que o `DropdownButtonFormField`
  contém os 27 estados em um menu rolável e que nem todos os
  `DropdownMenuItem` estão simultaneamente disponíveis ao finder — a correção
  é abrir o dropdown e rolar o `Scrollable` do menu até `PE` ficar visível.
  **Recusou explicitamente o atalho de mascarar o problema:** *"Também não
  recomendo simplesmente colocar `warnIfMissed: false` nos `tap()`. Isso
  esconderia uma interação que realmente não aconteceu."*
- **Resultado após correção:** **1/3 — sem mudança.** As falhas mudaram de
  natureza (o dropdown deixou de ser o ponto de parada), mas os dois testes
  continuaram falhando.

---

## Resultado Final

**1/3** (`00:05 +1 -2`)

| # | Teste | Resultado |
|---|---|---|
| 1 | deve completar o cadastro, selecionar gêneros e salvar no Firestore | ❌ `type 'Null' is not a subtype of type 'List<dynamic>' in type cast` |
| 2 | deve exibir erro quando Firebase Auth falha ao cadastrar | ❌ `Found 0 widgets with text "Erro ao cadastrar: O e-mail já está cadastrado."` |
| 3 | não deve salvar gêneros quando não existe usuário autenticado | ✅ |

Falha 1 (`cadastro_flow_zs_test.dart:402`): o teste lê
`dadosFinais['generos_favoritos'] as List` e recebe `null` — o documento
existe, mas o campo que `_salvarGeneros()` deveria gravar não está lá,
indicando que a persistência dos gêneros não chegou a ocorrer no ambiente de
teste.

Falha 2: o `SnackBar` de erro do cadastro não foi encontrado.

---

## Achados

Nenhum achado **(B)** formal — o modelo classificou **(A)** nas três
iterações e em nenhum momento atribuiu as falhas à aplicação.

### Notas qualitativas para a análise comparativa

- **Pior resultado de qualquer rodada da Fase 2 que chegou a compilar** (1/3,
  33%). Contrasta fortemente com o nível widget, onde as três rodadas
  anteriores fecharam em 15/18, 8/8, 11/13 e 19/19.
- **Progressão estagnada:** 0 (não compila) → 1 → 1 → 1. Diferente das rodadas
  de widget 33–36, onde cada iteração de reparo produziu ganho mensurável,
  aqui as duas últimas iterações **não moveram o placar**, embora tenham
  mudado a natureza das falhas. O orçamento de 3 iterações se mostrou
  insuficiente para um fluxo que atravessa duas telas com duas dependências
  externas não injetáveis.
- **O modelo antecipou corretamente a limitação do ViaCEP antes de qualquer
  falha**, e projetou o teste para contorná-la — comportamento mais maduro que
  o da rodada `FASE2-WIDGET-COT-01` do piloto, que tentou mockar `http.get` e
  terminou com a suíte não compilando.
- **Recusou dois atalhos que teriam inflado o placar:** `warnIfMissed: false`
  nos `tap()` (iteração 3) e depender da rede real para o ViaCEP (geração
  inicial). Em ambos os casos justificou que a correção esconderia um problema
  em vez de resolvê-lo.
- **Padrão de reescrita completa vs. patch cirúrgico:** as iterações 1 e 2
  reescreveram o arquivo inteiro e não houve regressão (ao contrário do que
  ocorreu em `FASE2-WIDGET-COT-01`), mas também não houve ganho na iteração 2.
  A única iteração com patch cirúrgico foi a 3, e também não destravou.
- Comparar com as rodadas de integração do fluxo de **login** (`INT-*-01`), que
  fecharam em 7/8 (ZS), 5/6 (FS) e 10/10 (COT): o fluxo de cadastro é
  materialmente mais difícil de testar — duas telas, um `DropdownButtonFormField`
  com 27 itens roláveis, uma chamada HTTP real sem injeção e persistência no
  Firestore, contra uma única tela com apenas o `FirebaseAuth` injetado.
