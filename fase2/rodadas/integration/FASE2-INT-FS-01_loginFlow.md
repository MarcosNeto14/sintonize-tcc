# FASE2-INT-FS-01_loginFlow — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-INT-FS-01 |
| **Fluxo testado** | `LoginScreen` → `TelaInicialScreen` (`lib/login.dart`, `lib/tela-inicial.dart`) — alvo limpo, bug W-SILENT do piloto revertido |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login). Usou reasoning ("Pensou por Ns") e citou fontes/documentação do `firebase_auth_mocks` em várias respostas — não verificável de forma independente sem login. |
| **Data de acesso** | 2026-09-04 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/integration/login_flow_fs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** mesma verificação da rodada ZS — bug W-SILENT
revertido, `TelaInicialScreen` com a mesma limitação de testabilidade
conhecida (acesso direto a `FirebaseAuth.instance`/`FirebaseFirestore.instance`).

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/integration/few-shot/FASE2-INT-FS-01_loginFlow.md`
— um exemplo de teste de integração de um fluxo de formulário genérico com
`MockFirebaseAuth`, seguido do código completo de `LoginScreen` e
`TelaInicialScreen` e das mesmas instruções da rodada ZS.

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Gerou 6 testes cobrindo apenas `LoginScreen` isoladamente (1 de sucesso,
4 de erro do Firebase Auth, 1 de validação de campos vazios). **Diferente
da rodada ZS**, o modelo **evitou proativamente** testar a navegação real
para `TelaInicialScreen` — o teste de sucesso verifica apenas
`mockAuth.currentUser`, sem `expect(find.byType(TelaInicialScreen), ...)`
— e explicou na prosa por quê: "após um login realizado com
`MockFirebaseAuth`, o teste pode acabar executando o `initState()` da
`TelaInicialScreen`, que por sua vez chama Firestore. Isso torna o teste
dependente de outros serviços." Essa é uma redução de escopo em relação ao
que o prompt pediu explicitamente ("Teste o fluxo completo ponta a ponta:
interações na primeira tela → navegação → estado da tela destino") — mas
ocorreu na geração inicial, não como enfraquecimento de um teste já
existente durante o reparo, portanto não viola o protocolo de reparo (A)/(B)
(que só se aplica a partir da 1ª falha). Registrado como observação, não
como falha de protocolo. Também usou `authExceptions: [...]`, parâmetro
que **não existe** na versão instalada de `firebase_auth_mocks`, apesar de
o exemplo few-shot fornecido não usar essa API (mesma armadilha comum já
vista nas rodadas ZS e nas rodadas de widget).

### Iteração 1 (repair) — 4 erros de compilação (`authExceptions` inexistente)

- **Motivo da falha:** `authExceptions` não é parâmetro de
  `MockFirebaseAuth` em `firebase_auth_mocks` 0.14.2.
- **Resposta do LLM:** classificou **(A)** — citou a documentação do
  pacote confirmando que a API foi removida e substituída por
  `whenCalling(...).on(...).thenThrow(...)`. Reescreveu os 4 testes de
  erro usando esse mecanismo, mantendo as mesmas asserções.
- **Resultado após correção:** Compilou. **5/6 passaram, 1 falhou** — o
  teste de sucesso, mesmo sem testar navegação, ainda falhou com
  `[core/no-app]` (a chamada `mockAuth.currentUser` por si só não aciona o
  Firebase real, mas a suíte completa carrega `LoginScreen`, que não
  aciona `TelaInicialScreen` neste teste — a causa exata desta falha
  específica é diferente da rodada ZS, ver iteração 2).

### Iteração 2 (repair) — regressão: tentativa de inicializar Firebase real piora o resultado (0/6)

- **Motivo da falha:** `[core/no-app]` — mesma causa da rodada ZS:
  `TelaInicialScreen.initState()` acessa `FirebaseAuth.instance`
  diretamente.
- **Resposta do LLM:** classificou **(A)** — "o teste presume que o mock
  substitui o singleton `FirebaseAuth.instance`, mas `firebase_auth_mocks`
  não faz isso automaticamente." Propôs inicializar o Firebase **real**
  via `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
  em um `setUpAll()`, usando o `lib/firebase_options.dart` real do
  projeto (que existe no repositório).
- **Resultado após aplicar a correção:** **Piorou.** `setUpAll` falhou
  com `PlatformException(channel-error, Unable to establish connection on
  channel.)` antes de qualquer teste rodar — o ambiente `flutter_test`
  não fornece o canal de plataforma nativo necessário para inicializar o
  Firebase de verdade. Resultado: **0/6 passaram** (regressão de 5/6 para
  0/6 — o mesmo teste que antes falhava sozinho agora impede a suíte
  inteira de rodar).

### Iteração 3 (repair, última permitida) — reclassificação correta, correção real está fora de escopo

- **Motivo da falha:** `PlatformException(channel-error)` em `setUpAll`,
  com a nota do operador explicitando a regressão (5/6 → 0/6).
- **Resposta do LLM:** classificou **(A)** novamente, mas desta vez com
  autocrítica precisa: reconheceu que a correção da iteração 2 estava
  errada ("**não devemos inicializar Firebase real no `setUpAll`**") e
  investigou a causa raiz até a conclusão de que **não existe correção
  possível apenas no arquivo de teste**: `LoginScreen` instancia
  `TelaInicialScreen` diretamente (`Navigator.pushReplacement(...,
  builder: (context) => const TelaInicialScreen())`), sem nenhum ponto de
  injeção, então qualquer teste que dispare a navegação real
  inevitavelmente aciona `FirebaseAuth.instance`/`FirebaseFirestore.instance`
  dentro de `TelaInicialScreen`. Declarou explicitamente "não devemos
  retirar a asserção de navegação" e propôs, como única solução real, uma
  refatoração de `lib/login.dart` para aceitar um `telaInicialBuilder`
  opcional injetável (mesmo padrão de DI já usado em `auth`).
- **Ação do operador:** a proposta de alterar `lib/login.dart` **não foi
  aplicada** — fora do escopo do protocolo do experimento. Como a
  correção da iteração 2 foi uma regressão reconhecida pelo próprio
  modelo, o arquivo de teste foi **revertido ao estado da iteração 1**
  (sem a inicialização real do Firebase), preservando o resultado válido
  mais recente.
- **Resultado final (limite de reparo esgotado):** 5/6 passaram, 1 falhou
  — mesma falha documentada como achado, sem alteração do teste além da
  reversão da regressão nem da aplicação.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Não na geração inicial (4 erros de `authExceptions`); sim a partir da iteração 1 |
| **Testes gerados** | 6 (escopo mais estreito que a rodada ZS — não testa navegação para `TelaInicialScreen`) |
| **Testes passaram (1ª execução válida, iteração 1)** | 5 |
| **Testes falharam (1ª execução válida, iteração 1)** | 1 |
| **Testes passaram (iteração 2, aplicada e depois revertida)** | 0 (regressão) |
| **Testes passaram (pós-repair, iteração 3/3 — final, revertido para iteração 1)** | 5 |
| **Testes falharam (pós-repair, iteração 3/3 — final)** | 1 |

### Saída do terminal (iteração 0 — erro de compilação)

```
test/fase2/integration/login_flow_fs_test.dart:61:11: Error: No named parameter with the name 'authExceptions'.
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/integration/few-shot/FASE2-INT-FS-01_loginFlow_iter0.txt`)

### Saída do terminal (iteração 1 — 5/6)

```
[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
...
00:03 +5 -1: Some tests failed.
```

(saída completa em `fase2/resultados/integration/few-shot/FASE2-INT-FS-01_loginFlow_iter1.txt`)

### Saída do terminal (iteração 2 — regressão, 0/6)

```
00:00 +0: (setUpAll)
00:00 +0 -1: (setUpAll) [E]
  PlatformException(channel-error, Unable to establish connection on channel., null, null)
00:00 +0 -1: (tearDownAll)
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/integration/few-shot/FASE2-INT-FS-01_loginFlow_iter2.txt`)

### Saída do terminal (iteração 3 — final, revertido, 5/6)

```
[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
...
00:07 +5 -1: Some tests failed.
```

(saída completa em `fase2/resultados/integration/few-shot/FASE2-INT-FS-01_loginFlow_iter3_final.txt`)

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** `authExceptions` não existe em `firebase_auth_mocks` 0.14.2.
- **Resposta do LLM:** classificação **(A)**; corrigiu com `whenCalling(...)`.
- **Resultado após correção:** Compilou; 5/6 passaram, 1 falhou (`[core/no-app]`).

### Iteração 2

- **Motivo da falha:** mesma limitação de `TelaInicialScreen` da rodada ZS.
- **Resposta do LLM:** classificação **(A)**; propôs inicializar Firebase real via `setUpAll`.
- **Resultado após aplicar:** **Regressão** — 0/6 passaram (`PlatformException(channel-error)` em `setUpAll`, impedindo toda a suíte).

### Iteração 3 (máximo)

- **Motivo da falha:** regressão da iteração 2, reportada ao modelo com nota explícita do operador.
- **Resposta do LLM:** classificação **(A)**; reconheceu o próprio erro da iteração 2, concluiu que não há correção possível apenas no teste, propôs refatoração de `lib/login.dart` (fora de escopo).
- **Ação do operador:** revertido o teste ao estado da iteração 1 (a regressão da iteração 2 não foi mantida).
- **Resultado final:** 5/6 passaram, 1 falhou — **limite de reparo esgotado, achado documentado sem alteração da aplicação**.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) nas 3 iterações |
| **★ Classificação humana (auditoria)** | Iteração 1: concordo — causa raiz corretamente diagnosticada. Iteração 2: **discordo da eficácia** — o diagnóstico da causa (singleton não substituído) estava correto, mas a correção proposta (inicializar Firebase real em `setUpAll`) piorou o resultado (regressão de 5/6 para 0/6), sem que o modelo tivesse indicado essa possibilidade como risco antes de o operador aplicar e testar. Reclassifico como **Erro de geração** para essa iteração especificamente. Iteração 3: concordo com a classificação (A) e, principalmente, com a autocorreção — o modelo reconheceu seu próprio erro da iteração anterior, evitou repeti-lo, e chegou à conclusão correta (mesma da rodada ZS, por caminho diferente: uma classificação nominal (A) que, na prática, resulta na mesma limitação estrutural que a rodada ZS chamou de (B)) de que a única correção real está fora do escopo do teste. Reclassifico a categoria humana final como **Limitação de testabilidade**, mesma da rodada ZS. |
| **★ Concordância** | Parcial — concordo com o diagnóstico de causa em todas as iterações e com a conclusão final, mas diverjo quanto à eficácia da correção proposta na iteração 2, que constituiu uma regressão real e mensurável |
| **★ Observações** | **Terceira rodada consecutiva** (após `FASE2-WIDGET-FS-01` e `FASE2-WIDGET-COT-01`) em que uma correção do modelo, aplicada integralmente conforme instruído, **piora objetivamente o resultado** antes de ser corrigida — desta vez o padrão foi mais brando (regressão detectada e corrigida na iteração seguinte, dentro do próprio limite de 3 iterações, sem necessidade de intervenção manual como nas rodadas de widget) e o próprio modelo reconheceu o erro sem que o operador precisasse apontá-lo explicitamente (o operador apenas relatou o novo erro, sem sugerir a causa). Isso é uma diferença qualitativa importante: nas rodadas de widget, o modelo nunca reconheceu que sua própria correção tinha causado o problema mais grave; aqui, ele o fez. Compatível com a rodada ZS: as duas estratégias (zero-shot e few-shot), de forma independente, convergiram para a mesma conclusão de fundo sobre `TelaInicialScreen`/`LoginScreen` — a diferença é que a rodada ZS chegou lá em 1 iteração de diagnóstico (B) sem regressão, e a rodada FS levou 2 iterações e uma regressão intermediária antes de chegar à mesma conclusão. Isso é uma terceira confirmação independente (após ZS e as 3 rodadas W-SILENT do piloto) da mesma limitação sistêmica de design em `TelaInicialScreen`. |

---

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
