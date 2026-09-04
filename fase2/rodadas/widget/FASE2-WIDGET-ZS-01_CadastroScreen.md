# FASE2-WIDGET-ZS-01_CadastroScreen — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WIDGET-ZS-01 |
| **Tela testada** | `CadastroScreen` — `lib/cadastro.dart` (alvo limpo, sem bug plantado) |
| **Arquivo de origem** | `lib/cadastro.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das demais rodadas da Fase 2, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-04 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/widget/cadastro_screen_zs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `lib/cadastro.dart` não tem bug plantado — as
únicas diferenças em relação a `main` são a injeção de dependência
(`auth`/`firestore` opcionais) adicionada para testabilidade. Código
colado verbatim no prompt, sem simplificação. Primeira rodada de nível
widget do escopo revisado das 30 rodadas limpas.

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/widget/zero-shot/FASE2-WIDGET-ZS-01_CadastroScreen.md`
— código completo de `CadastroScreen` (formulário de cadastro com 10
campos, máscaras de data/CEP, chamada HTTP real a `viacep.com.br`,
dropdown de estado, submissão via Firebase Auth + Firestore, navegação
para `GenerosCadastroScreen`), mais instruções de mocking
(`firebase_auth_mocks`, `fake_cloud_firestore`, `mockito`) e requisitos de
cobertura (renderização, validação, interação, `flutter test`).

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Gerou 22 testes em 5 grupos (`renderização`, `validação`, `interações`,
`navegação`, `cadastro`), usando `firebase_auth_mocks` +
`fake_cloud_firestore` conforme solicitado. Cobriu: renderização de todos
os campos, validação de cada um dos 8 validators do formulário
(individualmente e em conjunto quando vazio), aplicação das máscaras de
data e CEP, seleção de estado via dropdown, ocultação de senha, navegação
para login, e o fluxo completo de cadastro com verificação do documento
persistido no Firestore fake.

Identificou espontaneamente, na prosa de fechamento, dois riscos reais do
próprio código de produção antes mesmo de qualquer execução: (1) o widget
faz uma chamada HTTP real a `viacep.com.br` ao completar 8 dígitos do CEP
— exatamente o risco já sinalizado na nota de protocolo do operador — e
recomendou refatorar para injeção de serviço HTTP; (2) a compatibilidade
de `firebase_auth_mocks` com `createUserWithEmailAndPassword` pode variar
por versão do pacote.

### Iteração 1 (repair) — erro de compilação

- **Motivo da falha:** `TextFormField` não expõe um getter público
  `obscureText` (o parâmetro é repassado internamente ao `TextField`, mas
  não fica acessível pela instância do `TextFormField`) — erro de
  compilação, não de execução.
- **Resposta do LLM:** classificou **(A)** e corrigiu inspecionando o
  `TextField` descendente via `find.descendant` em vez de acessar a
  propriedade inexistente diretamente no `TextFormField`.
- **Resultado após correção:** Compilou; 7/22 passaram, 15 falharam (nova
  classe de erro).

### Iteração 2 (repair) — 15 falhas por elementos fora da viewport

- **Motivo da falha:** o formulário usa `SingleChildScrollView` e é mais
  alto que os 600px da viewport padrão do `WidgetTester`; `tester.tap()`
  não rola a tela automaticamente, então `tap(find.text('Cadastrar'))` e
  `tap(find.byType(DropdownButtonFormField))` computavam um offset fora
  dos limites da superfície de teste (`Size(800.0, 600.0)`), fazendo o tap
  não acionar o botão e as asserções subsequentes falharem por não
  encontrar os textos de erro/seleção esperados.
- **Resposta do LLM:** classificou **(A)** e introduziu os helpers
  `tapCadastrar`/`selecionarEstado` usando `tester.ensureVisible(...)`
  antes de cada tap, para rolar o elemento até a área visível.
- **Resultado após correção:** 14/22 passaram, 8 falharam (queda de 15
  para 8, mas `ensureVisible` não resolveu completamente).

### Iteração 3 (repair, última permitida) — 8 falhas residuais em 2 padrões

- **Motivo da falha (Padrão 1):** mesmo após `ensureVisible`, o botão
  "Cadastrar" ainda ficava com o centro a `Offset(400.0, 626.0)`, 26px
  além do limite da viewport de 600px — `ensureVisible` não conseguiu
  trazer completamente o botão para a área visível dado o pouco conteúdo
  restante abaixo dele no `Column`. No dropdown, o item "PE" do menu
  simplesmente não era encontrado após o tap no controle
  (`Bad state: No element`), sugerindo que o overlay do menu não abria de
  forma confiável nessa viewport reduzida.
- **Motivo da falha (Padrão 2):** o teste do formulário vazio esperava a
  mensagem `'As senhas não coincidem'`, mas o validator de "Confirmar
  Senha" é `if (value != _senhaController.text)` — com ambos os campos
  vazios, `'' != ''` é `false`, então a mensagem nunca aparece nesse
  cenário. Presunção incorreta do teste, não um bug da aplicação.
- **Resposta do LLM:** classificou **ambos os padrões como (A)**. Para o
  Padrão 1, recomendou uma solução mais robusta que `ensureVisible`:
  aumentar a superfície de teste via `tester.view.physicalSize = const
  Size(1200, 1800)` (com `addTearDown` para resetar), eliminando a
  necessidade de rolagem manual. Para o Padrão 2, corrigiu a asserção para
  `findsNothing`, com comentário explicando a causa raiz.
- **Resultado após correção:** 21/22 passaram, 1 falhou (última iteração
  permitida — falha final documentada, não corrigida por esgotamento do
  limite de reparo).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Não na geração inicial (erro de compilação); sim após iteração 1 |
| **Testes gerados** | 22 |
| **Testes passaram (1ª execução válida, pós-compilação)** | 7 |
| **Testes falharam (1ª execução válida)** | 15 |
| **Testes passaram (pós-repair, iteração 3/3 — final)** | 21 |
| **Testes falharam (pós-repair, iteração 3/3 — final)** | 1 |

### Saída do terminal (iteração 0 — erro de compilação)

```
test/fase2/widget/cadastro_screen_zs_test.dart:354:20: Error: The getter 'obscureText' isn't defined for the type 'TextFormField'.
...
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/widget/zero-shot/FASE2-WIDGET-ZS-01_CadastroScreen_iter0.txt`)

### Saída do terminal (iteração 1 — 15 falhas)

```
00:12 +7 -15: Some tests failed.
```

(saída completa em `fase2/resultados/widget/zero-shot/FASE2-WIDGET-ZS-01_CadastroScreen_iter1.txt`)

### Saída do terminal (iteração 2 — 8 falhas)

```
00:16 +14 -8: Some tests failed.
```

(saída completa em `fase2/resultados/widget/zero-shot/FASE2-WIDGET-ZS-01_CadastroScreen_iter2.txt`)

### Saída do terminal (iteração 3 — final, 21/22)

```
00:11 +20 -1: CadastroScreen - cadastro deve criar usuário, salvar dados no Firestore e navegar [E]
  Expected: true
    Actual: <false>
00:12 +21 -1: Some tests failed.
```

(saída completa em `fase2/resultados/widget/zero-shot/FASE2-WIDGET-ZS-01_CadastroScreen_iter3_final.txt`)

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** erro de compilação — `obscureText` não é getter de `TextFormField`.
- **Prompt de reparo enviado:** erro de compilação completo.
- **Resposta do LLM:** classificação **(A)**; corrigiu usando `find.descendant` para acessar o `TextField` interno.
- **Resultado após correção:** Compilou; 7/22 passaram, 15 falharam.

### Iteração 2

- **Motivo da falha:** 15 testes falhando por `tap()` em elementos fora da viewport de 600px (botão "Cadastrar" e dropdown de estado).
- **Prompt de reparo enviado:** dois exemplos representativos do erro de hit-test fora dos limites, mais o resumo final.
- **Resposta do LLM:** classificação **(A)**; introduziu helpers `tapCadastrar`/`selecionarEstado` com `tester.ensureVisible(...)`.
- **Resultado após correção:** 14/22 passaram, 8 falharam.

### Iteração 3 (máximo)

- **Motivo da falha:** 2 padrões residuais — (1) `ensureVisible` insuficiente para trazer botão/dropdown totalmente à vista; (2) presunção incorreta sobre o validator de confirmação de senha com ambos os campos vazios.
- **Prompt de reparo enviado:** os dois padrões de erro, pedindo classificação separada para cada um.
- **Resposta do LLM:** classificação **(A) para ambos**; substituiu a estratégia de scroll por aumento da superfície de teste (`tester.view.physicalSize`) e corrigiu a asserção de "As senhas não coincidem" para `findsNothing`.
- **Resultado após correção:** 21/22 passaram, 1 falhou — **limite de reparo esgotado, falha final documentada sem correção adicional**, conforme protocolo do repositório.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) em todas as 3 iterações |
| **★ Classificação humana (auditoria)** | Iterações 1 e 3 (Padrão 2): concordo — erro de teste genuíno (API mal utilizada; presunção lógica incorreta sobre o validator). Iteração 2 e Padrão 1 da iteração 3: concordo com a causa (ambiente de teste, viewport insuficiente), mas a categoria mais precisa é **Limitação de testabilidade** — o problema não é uma presunção sobre a *lógica de negócio* da tela, e sim sobre uma característica do ambiente de teste do Flutter (viewport fixa de 800×600 por padrão) interagindo com um layout rolável real. |
| **★ Concordância** | Sim quanto à causa raiz em todas as iterações; classificação humana refina a categoria do Padrão 1/iteração 2 para "Limitação de testabilidade" em vez de simplesmente "Erro de teste" |
| **★ Observações** | Falha final não resolvida (1/22): `document.exists` retorna `false` no Firestore fake após o fluxo completo de cadastro, apesar de todos os campos serem preenchidos com valores válidos e o botão ser efetivamente tocado. Hipótese mais provável, já antecipada pelo próprio modelo na resposta inicial: incompatibilidade de versão entre `firebase_auth_mocks` (0.14.2, conforme `pubspec.lock`) e a chamada `createUserWithEmailAndPassword` — o `UserCredential` retornado pelo mock pode não corresponder ao `MockUser` configurado, fazendo `_submit()` falhar silenciosamente antes do `_firestore.collection('usuarios').doc(uid).set(...)`, sem lançar exceção capturável pelo teste (o catch genérico da tela pode estar absorvendo um erro que não produz nenhum SnackBar visível dentro do tempo de `pumpAndSettle`). Não investigado a fundo por já ter esgotado as 3 iterações de reparo permitidas pelo protocolo; registrado como achado em aberto, não como bug do `CadastroScreen`, já que a única rodada com Firebase Auth real (piloto WSILENT) não relatou esse tipo de falha usando o mesmo pacote de mock. Esta é a primeira rodada de nível widget da Fase 2 revisada — o alto custo de reparo (3 iterações completas, uma delas corrigindo um erro de compilação) contrasta fortemente com a taxa de sucesso de primeira tentativa observada nas 24 rodadas unitárias (a maioria sem nenhum reparo), consistente com a expectativa de que testes de widget com Firebase/scroll/navegação são estruturalmente mais difíceis de acertar de primeira do que testes unitários de funções puras. |

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
