# FASE2-INT-COT-02_cadastroFlow — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-INT-COT-02 |
| **Fluxo testado** | Cadastro — `CadastroScreen` → `GenerosCadastroScreen` (`lib/cadastro.dart`, `lib/generos-cadastro.dart`) |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio das demais rodadas da Fase 2) |
| **Data de acesso** | 2026-09-20 |
| **Conversa nova?** | Sim — reexecução em conversa nova, conforme decisão registrada em `fase2/rodadas/integration/_abortadas/FASE2-INT-COT-02_TENTATIVA-1.md` (tentativa 1, de 2026-09-18, abortada por limite de tamanho de resposta) |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable) |
| **Arquivo de teste** | `test/fase2/integration/cadastro_flow_cot_test.dart` |
| **Execução** | Manual — prompt colado pelo autor no ChatGPT, respostas coladas nesta conversa; código salvo e `flutter test` executado por automação de terminal |
| **Iterações de reparo** | 3 (o máximo permitido) |
| **Resultado final** | **9/10** |

**Verificação pré-rodada:** idêntica à de `FASE2-INT-ZS-02`/`FASE2-INT-FS-02`
— bug I-CRASH revertido, apenas injeção de dependência em relação a `main`.
Prompt idêntico ao usado na tentativa 1 abortada, sem nenhuma alteração —
a causa do aborto anterior foi acúmulo de contexto na conversa, não o alvo.

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/integration/cot/FASE2-INT-COT-02_cadastroFlow.md`
— instrução chain-of-thought (analisar fluxo, identificar dependências,
montar navegação, listar cenários, então escrever os testes) com o código
completo das duas telas colado verbatim (~27,5 mil caracteres, o maior
prompt da Fase 2).

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Seguiu corretamente as 5 etapas do chain-of-thought pedidas no prompt.
Gerou **12 testWidgets**, a maior suíte inicial de qualquer rodada do alvo
`cadastroFlow` (contra 3 em ZS e 2 em FS). Cobriu: 7 validações locais, 2
cenários de falha do Firebase (Auth e Firestore no cadastro), o fluxo
ponta a ponta completo, confirmação sem gênero selecionado e falha do
Firestore ao salvar gêneros.

Observação espontânea correta: identificou que o CEP não precisa disparar
o ViaCEP porque o endereço pode ser preenchido manualmente, evitando
dependência de rede — mesma solução adotada pelas rodadas ZS/FS deste
alvo.

**Erro de geração:** usou `whenCalling(...)` (API do pacote
`mock_exceptions`) em 3 pontos sem importar o pacote — suíte não compilou
na primeira tentativa.

### Iteração 1 (repair) — não compila

- **Motivo da falha:** `Method not found: 'whenCalling'` (3 ocorrências) —
  import de `package:mock_exceptions/mock_exceptions.dart` ausente.
- **Resposta do LLM:** classificou **(A)**, mas na primeira resposta
  **não entregou o arquivo corrigido** — apenas descreveu em prosa a
  correção pretendida (remover as 3 ocorrências de `whenCalling` e usar
  Security Rules do `fake_cloud_firestore` para simular falhas de
  Firestore). Foi necessário pedir explicitamente o arquivo completo
  ("diagnóstico sem entrega", mesmo padrão já visto em `FASE2-INT-FS-02`
  e na tentativa 1 abortada desta própria rodada).
- **Resposta seguinte (mesma iteração):** entregou o arquivo completo,
  removendo as 3 ocorrências de `whenCalling` e substituindo a simulação
  de falha do Firestore por `FakeFirebaseFirestore` configurado com
  `securityRules` (`allow write: if false` / `allow update: if false`).
- **Resultado após correção:** **suíte compila — 1/12.**

### Iteração 2 (repair) — 11 falhas

- **Motivo da falha:** duas causas independentes:
  1. 10 testes falharam porque os botões "Cadastrar" e "Confirmar" ficam
     fora da viewport de 600px do teste (`SingleChildScrollView`) e o
     `tap()` "erra" silenciosamente (`warnIfMissed` apenas avisa, não
     falha) — o formulário nunca era submetido.
  2. 1 teste (`Firestore recusa a atualização dos gêneros`) falhou com
     `Bad state: No element` em `Method.fromNameInFirebase` — a Security
     Rule usada (`allow create: if ...`) não é reconhecida pelo parser da
     versão instalada de `fake_firebase_security_rules`.
- **Resposta do LLM:** classificou **(A)** para os dois grupos. Corrigiu
  o primeiro com um helper `tapAndSettle()` que chama
  `tester.ensureVisible()` antes de cada `tap()`. Para o segundo,
  **removeu os dois testes de falha de Firestore** em vez de insistir em
  sintaxe de Security Rules não confirmada como suportada pela versão
  instalada — reduziu a suíte de 12 para 10 testes, justificando
  explicitamente a decisão em vez de mascará-la.
- **Resultado após correção:** **9/10 — apenas o teste ponta a ponta
  falha.**

### Iteração 3 (repair, última permitida) — 1 falha

- **Motivo da falha:** `Bad state: No element` em `Iterable.last`, dentro
  de `WidgetController.ensureVisible`, ao tentar localizar `find.text('PE').last`
  — o menu do `DropdownButtonFormField` (27 estados) abre em um `Overlay`
  próprio, e o item "PE" não está renderizado no momento da chamada.
- **Resposta do LLM:** classificou **(A)** e reescreveu o helper de
  seleção de estado (`selecionarEstado`) para, após abrir o dropdown,
  iterar sobre todos os `Scrollable` disponíveis na árvore e tentar
  `scrollUntilVisible` em cada um até encontrar o item — sem assumir qual
  implementação interna de menu o Flutter está usando.
- **Resultado após correção:** **9/10 — sem mudança no placar.** A falha
  mudou de natureza: o dropdown deixou de ser o ponto de parada, mas o
  mesmo teste ponta a ponta voltou a falhar mais adiante, com
  `type 'Null' is not a subtype of type 'List<dynamic>' in type cast` ao
  ler `generos_favoritos` — indicando que o `tap()` em "Confirmar" (dentro
  de `GenerosCadastroScreen`) também esbarrou no mesmo problema de
  visibilidade de botão fora da viewport, desta vez não coberto pelo
  `tapAndSettle()` a tempo de ser corrigido dentro do orçamento de 3
  iterações.

---

## Resultado Final

**9/10** (`00:05 +9 -1`)

| # | Teste | Resultado |
|---|---|---|
| 1 | não chama Firebase quando campos obrigatórios estão vazios | ✅ |
| 2 | não chama Firebase quando o e-mail é inválido | ✅ |
| 3 | não chama Firebase quando a data de nascimento é inválida | ✅ |
| 4 | não chama Firebase quando a senha tem menos de seis caracteres | ✅ |
| 5 | não chama Firebase quando as senhas não coincidem | ✅ |
| 6 | não chama Firebase quando o CEP é inválido | ✅ |
| 7 | não chama Firebase quando o número do endereço não é numérico | ✅ |
| 8 | cria conta, salva usuário, navega para gêneros, salva gêneros e vai para tela inicial | ❌ `type 'Null' is not a subtype of type 'List<dynamic>' in type cast` |
| 9 | mostra erro ao confirmar sem selecionar nenhum gênero | ✅ |
| 10 | não salva e permanece na tela quando não há usuário autenticado | ✅ |

---

## Achados

Nenhum achado **(B)** — o modelo classificou **(A)** em todas as
iterações, e a auditoria concorda: as falhas têm origem em técnica de
teste (tap fora da viewport, sintaxe de Security Rules não suportada),
não em comportamento incorreto de `CadastroScreen`/`GenerosCadastroScreen`.

### Notas qualitativas para a análise comparativa

- **Melhor resultado de qualquer rodada do alvo `cadastroFlow`:** 9/10
  (90%), contra 1/3 (ZS) e 0/2 (FS). A diferença mais provável é a
  própria estratégia chain-of-thought forçando o modelo a mapear
  explicitamente as dependências e cenários antes de escrever código —
  a suíte inicial já nasceu maior (12 testes) e mais estruturada.
- **"Diagnóstico sem entrega" na iteração 1** é o segundo caso desse
  padrão documentado no alvo `cadastroFlow` nesta fase (o primeiro foi
  `FASE2-INT-FS-02`, e também apareceu na tentativa 1 abortada desta
  mesma rodada). O modelo tende a descrever a correção em prosa antes de
  efetivamente aplicá-la ao código quando o arquivo é grande.
- **Recusou "inventar" API não confirmada**: ao esbarrar na sintaxe de
  Security Rules não suportada pela versão instalada, optou por remover
  o cenário em vez de arriscar uma sintaxe alternativa não verificada —
  mesma postura conservadora observada em outras rodadas da Fase 2
  (ex.: recusa de inventar caminho de arquivo em `FASE2-WSILENT-FS_REEXEC`).
- **Progressão de reparo com ganho real:** 0 (não compila) → 1 → 9 → 9.
  Ao contrário de `FASE2-INT-ZS-02`/`FASE2-INT-FS-02`, onde as duas
  últimas iterações não moveram o placar, aqui a iteração 2 produziu um
  salto grande (1 → 9) ao corrigir o problema sistêmico de visibilidade
  de botão. A iteração 3 não teve o mesmo efeito porque o problema
  reapareceu em um segundo ponto do mesmo teste (o botão "Confirmar" de
  `GenerosCadastroScreen`), fora do escopo do que havia sido corrigido.
- **Único teste que nunca passou:** o fluxo ponta a ponta completo — o
  mais longo e o único que atravessa as duas telas, dois botões
  submissíveis e um `DropdownButtonFormField` com 27 itens roláveis.
  Mesmo padrão de dificuldade concentrada no teste end-to-end já visto em
  ZS/FS deste alvo.
- **Redução de escopo justificada, não mascarada:** a suíte caiu de 12
  para 10 testes na iteração 2, mas por uma decisão explícita e
  documentada (sintaxe de Security Rules incompatível), não por
  enfraquecimento de asserção.
- **Comparação com o fluxo de login (`INT-*-01`):** login fechou em 7/8,
  5/6 e 10/10; cadastro fechou em 1/3 (ZS), 0/2 (FS) e agora 9/10 (COT).
  A rodada chain-of-thought é a primeira do alvo `cadastroFlow` a se
  aproximar do desempenho do fluxo de login, sugerindo que o orçamento de
  3 iterações **é** suficiente para este alvo mais difícil, desde que a
  suíte inicial já venha bem estruturada.

---

## ★ Análise de Autoclassificação

### Quanto ao bug-alvo I-CRASH (revertido — alvo limpo)

Não aplicável — I-CRASH foi revertido antes desta rodada; não há bug
plantado para detectar neste alvo.

### Quanto às falhas da rodada

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) em todas as iterações |
| **★ Classificação humana (auditoria)** | Erro de geração (iteração 1 — import ausente de `mock_exceptions`) / Erro de geração (iteração 2 — tap fora da viewport; sintaxe de Security Rules incompatível com a versão instalada) / Erro de geração (iteração 3 — mesma classe de problema de visibilidade de botão, em ponto diferente do teste) |
| **★ Concordância** | Concorda integralmente em todas as 3 iterações |
| **★ Observações** | Nenhuma das falhas foi atribuída a comportamento incorreto das telas, e a auditoria confirma: todas têm origem em técnica de teste (imports, visibilidade de widget em viewport pequena, API de terceiros). Resultado final documentado como está — 9/10, limite de 3 iterações atingido. |

**Referência de categorias (classificação humana — mesmas da Fase 1, + (C) da Fase 2):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
| Bug capturado sem necessidade de reparo (C) | O modelo já identificou e se ajustou ao bug real na geração inicial, sem falha nem ciclo de reparo |
