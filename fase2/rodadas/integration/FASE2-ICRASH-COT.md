# FASE2-ICRASH-COT — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-ICRASH-COT |
| **Bug ID** | I-CRASH |
| **Função/tela alvo** | Fluxo de cadastro — `GenerosCadastroScreen._salvarGeneros()` |
| **Arquivo(s) de origem** | `lib/cadastro.dart` + `lib/generos-cadastro.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-02 |
| **Conversa nova?** | Sim — sessão deslogada do ChatGPT, sem histórico prévio |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable) |
| **Arquivo de teste** | `test/fase2/integration/icrash_cot_test.dart` |

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/FASE2-ICRASH-COT.md` — prompt Chain-of-Thought
em 5 passos (analisar o fluxo, identificar dependências, montar a estrutura
de navegação, **listar cenários incluindo explicitamente "usuário não
autenticado ao chegar em GenerosCadastroScreen"**, e só então escrever os
testes). O código embutido usa a mesma `CadastroScreen` simplificada de 4
campos e a mesma `GenerosCadastroScreen` com `SwitchListTile` já observadas
na rodada Few-shot.

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Resposta completa e verbatim (extraída via "Copiar resposta") — 12
`testWidgets()` organizados em 2 grupos, precedidos da análise em 4 passos
solicitada:

```
Abaixo está uma suíte de testes de integração/widget que respeita a restrição de
não modificar as telas. Há, porém, uma limitação importante no código atual:
CadastroScreen recebe auth/firestore por injeção, mas, ao navegar, cria
GenerosCadastroScreen() sem repassar essas dependências. Portanto, os testes
conseguem isolar completamente o cadastro, mas o trecho de salvamento de gêneros
após a navegação usa FirebaseAuth.instance/FirebaseFirestore.instance, e não os
mocks/fakes usados no teste.

1. Análise do fluxo
[...] Há ainda uma falha específica em GenerosCadastroScreen: se não houver
usuário autenticado, currentUser!.uid lança uma exceção antes de entrar no
try/catch.

2. Dependências por tela
[...] Como a tela é instanciada diretamente pelo MaterialPageRoute, os testes
não conseguem injetar esses objetos nesse ponto sem modificar a produção.

[...]

4. Cenários cobertos
[12 cenários, incluindo "Entrada em GenerosCadastroScreen sem usuário
autenticado" e observação sobre ausência de indicador de loading no código]

5. Testes
[12 testWidgets() usando MockFirebaseAuth/FakeFirebaseFirestore + mocks manuais
de Mockito para os cenários de falha de Firestore; find.byType(SwitchListTile)]

Um ponto que precisa ser ajustado antes de executar literalmente
[...]
A limitação arquitetural mais importante é a injeção de dependências: [...] um
teste E2E que realmente valide o mesmo FakeFirebaseFirestore desde o cadastro
até o salvamento dos gêneros não é possível somente com testes: seria necessário
que o código de produção propagasse auth e firestore para GenerosCadastroScreen.
Isso não é algo que o teste consiga corrigir sem modificar o comportamento das
telas.

Também vale notar que o cenário de usuário não autenticado não exibe uma
mensagem de erro: currentUser!.uid acontece antes do try. O teste acima
registra esse comportamento sem alterar o código de produção.
```

**★ Detecção espontânea do bug-alvo:** **sim** — pela segunda vez nesta
dupla de bugs (a primeira foi ZS). A estratégia CoT, ao pedir
explicitamente no passo 4 do próprio prompt um cenário de "usuário não
autenticado", induziu tanto a cobertura do cenário quanto a identificação
correta, na resposta inicial, de que `currentUser!.uid` ocorre fora do
`try`. Também identificou espontaneamente a limitação arquitetural de
`CadastroScreen` não propagar `auth`/`firestore` para
`GenerosCadastroScreen` na navegação real — achado que nenhuma das outras
duas rodadas (ZS, FS) havia declarado tão explicitamente na resposta
inicial.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou? (1ª tentativa)** | Não — 6 erros: `shouldMockUser`/`mockCreateUserWithEmailAndPassword` inexistentes, import de `TelaInicialScreen` ausente, `document.set(any)`/`argThat(...)` com tipo incompatível |
| **Testes gerados (versão inicial)** | 12 |
| **Iteração 1** | Compilou. **0 passaram / 13 falharam** (13 pois a correção também separou um teste em dois) — causa dominante: `findsNWidgets(4)` esperando 4 `TextFormField`, app real tem 10 |
| **Iteração 2** | **10 passaram / 5 falharam** de 15 testes — grande melhora após fornecer a ordem real dos 10 campos |
| **Iteração 3 (final, máximo permitido)** | **11 passaram / 4 falharam** de 15 testes |

### Saída do terminal (iteração 0 — falha de compilação)

Ver `fase2/resultados/integration/FASE2-ICRASH-COT_iter0.txt`

```
Error: No named parameter with the name 'shouldMockUser'.
Error: Undefined name 'TelaInicialScreen'.
Error: The argument type 'Null' can't be assigned to the parameter type 'Map<String, dynamic>'.
Error: The setter 'mockCreateUserWithEmailAndPassword' isn't defined for the type 'MockFirebaseAuth'.
```

### Saída do terminal (iteração 1 — 0/13)

Ver `fase2/resultados/integration/FASE2-ICRASH-COT_iter1.txt`

```
Expected: exactly 4 matching candidates
  Actual: _TypeWidgetFinder:<Found 10 widgets with type "TextFormField">
   Which: is too many
(repetido em praticamente todos os 13 testes, via helper preencherCadastro)
00:03 +0 -13: Some tests failed.
```

### Saída do terminal (iteração 2 — 10/15)

Ver `fase2/resultados/integration/FASE2-ICRASH-COT_iter2.txt`

```
[5 falhas]:
1) CEP invalido: navegou mesmo assim (Found 1 widget "GenerosCadastroScreen")
2) email-already-in-use: SnackBar nao encontrado
3) Firestore falha ao criar usuario: CadastroScreen nao encontrado (navegou mesmo com stub)
4) [core/no-app] No Firebase App '[DEFAULT]' -- TelaInicialScreen
5) usuario nao autenticado: expectLater(..., throwsA(anything)) nao capturou a excecao
00:05 +10 -5: Some tests failed.
```

### Saída do terminal (iteração 3 — final, 11/15, máximo de reparos atingido)

Ver `fase2/resultados/integration/FASE2-ICRASH-COT_iter3_final.txt`

```
00:03 +7 -1: exibe erro quando o Firebase Auth retorna email-already-in-use [E]
  Expected: exactly one matching candidate
    Actual: Found 0 widgets with text "Erro ao cadastrar: E-mail já cadastrado"

00:04 +7 -2: exibe erro e não navega quando o Firestore falha ao criar usuário [E]
  Expected: exactly one matching candidate
    Actual: Found 0 widgets with type "CadastroScreen"

00:04 +9 -3: seleciona Rock e salva generos_favoritos no Firestore [E]
  Expected: not null
    Actual: <null>
  (comentário no próprio teste: "TelaInicialScreen acessa Firebase.instance
   diretamente e, neste ambiente de teste, a exceção [core/no-app] é o
   resultado observável da navegação.")

00:04 +10 -4: usuário não autenticado gera exceção ao confirmar gênero [E]
  The following _TypeError was thrown running a test:
  Null check operator used on a null value
  #0  _GenerosCadastroScreenState._salvarGeneros (package:sintonize/generos-cadastro.dart:44:34)
  #1  _GenerosCadastroScreenState._confirmar (package:sintonize/generos-cadastro.dart:72:7)

00:05 +11 -4: Some tests failed.
```

---

## ★ Achado metodológico importante

### 1. O bug I-CRASH foi exposto, mas o teste que o expõe conta como "falho" no relatório do `flutter_test`

O teste `usuário não autenticado gera exceção ao confirmar gênero` foi
corrigido na iteração final para usar
`expect(tester.takeException(), isNotNull)` em vez de
`expectLater(..., throwsA(anything))` (que não captura exceções síncronas
lançadas dentro de um `onPressed` não aguardado). Mesmo assim, o teste
aparece como **falho** `[E]` no relatório, com o stack trace apontando
exatamente para `generos-cadastro.dart:44:34` — a linha do bug injetado.
Isso ocorre porque o framework `flutter_test` reporta qualquer exceção não
tratada durante um `tap()`/`pump()` como falha do teste, **independente**
da asserção que o corpo do teste declara. Este é um resultado
metodologicamente positivo (o bug foi capturado e documentado sem
enfraquecer a asserção), mas tecnicamente contabilizado como falha na
contagem `passed/failed` do `flutter_test`. Mesmo padrão observado na
rodada ZS (lá, o teste equivalente também aparecia como `[E]` pelo mesmo
motivo).

### 2. `TelaInicialScreen` — limitação de testabilidade sistemática, agora atingindo o nível Integration

O teste `seleciona Rock e salva generos_favoritos no Firestore` tentou
lidar com a limitação já documentada em múltiplas rodadas anteriores
(W-SILENT, W-CRASH): `TelaInicialScreen` acessa
`FirebaseAuth.instance`/`FirebaseFirestore.instance` diretamente no
`initState`, causando `FirebaseException: [core/no-app]`. Desta vez, o
modelo tentou capturar essa exceção explicitamente (em vez de apenas
esperar `findsOneWidget`), mas a asserção específica usada
(`tester.takeException()` em outro ponto do fluxo) não encontrou a
exceção onde esperado, resultando em `Expected: not null / Actual: <null>`
— a mecânica exata de propagação da exceção em `initState` via ciclo de
frames do `flutter_test` não coincidiu com o ponto de captura escolhido.
Ainda assim, o modelo **corretamente se recusou** a contornar a limitação
inicializando um `Firebase.initializeApp()` falso (comportamento já
documentado como não funcional — `PlatformException: channel-error` — e
que havia sido explicitamente desaconselhado no prompt de reparo final).

### 3. `mock_exceptions` não interceptou chamadas com parâmetros nomeados mesmo após ajuste

Duas falhas (`email-already-in-use` e falha do Firestore ao criar usuário)
persistiram até a última iteração: o `whenCalling(Invocation.method(...))`
não interceptou `createUserWithEmailAndPassword()`/`document.set()` mesmo
depois de o prompt de reparo final apontar que esses métodos usam
argumentos nomeados/posicionais reais, não `null`. O modelo respondeu que
"a correção dos matchers segue a API de mock_exceptions: para métodos com
parâmetros nomeados, a Invocation pode especificar os nomes (`#email`,
`#password`)", mas o ajuste aplicado não resolveu — ficou sem iterações
restantes para investigar mais a fundo. Isso é consistente com o padrão,
já registrado em rodadas anteriores, de lacunas de conhecimento
específicas e recorrentes do modelo sobre APIs de teste do ecossistema
Flutter/mocking, desta vez envolvendo o `mock_exceptions` com métodos de
assinatura nomeada.

### 4. Confirmação da divergência de campos entre prompt e app real (mesma da rodada FS)

A causa dominante de falha na iteração 1 (12/13 testes afetados) foi a
mesma já registrada em `FASE2-ICRASH-FS.md`: o `CadastroScreen` do prompt
tem 4 campos, o app real (`lib/cadastro.dart`) tem 10. Nesta rodada, ao
fornecer no prompt de reparo a ordem exata e os validadores dos 10 campos
reais (`Nome, Data de Nascimento, E-mail, Senha, Confirmar Senha, CEP,
Rua, Número, Bairro, Cidade`), o modelo corrigiu a suíte inteira em uma
única iteração, elevando de 0/13 para 10/15 — evidência de que, quando a
causa raiz é fornecida com precisão suficiente, o modelo consegue corrigir
extensamente em um único passo.

---

## Iterative Repair Loop

### Iteração 1

**Prompt de reparo:** os 6 erros de compilação + todo o conhecimento
acumulado das rodadas anteriores (API real do `firebase_auth_mocks`,
`mock_exceptions`, `Switch` vs `SwitchListTile`) fornecido preventivamente
para economizar iterações. Ver `scratchpad/r15_repair1.txt`.

**Classificação declarada pelo modelo (verbatim, início):**

```
Classificação: (A) para os erros apresentados. Eles são causados por
incompatibilidades entre o teste que gerei e as APIs/implementação reais do seu
projeto (firebase_auth_mocks 0.14.x, mock_exceptions e a estrutura real de
GenerosCadastroScreen). Portanto, o teste deve ser corrigido.
```

**Ação:** corrigiu os imports, adotou `mock_exceptions`, trocou
`SwitchListTile` por `Switch`.
**Resultado:** compilou; **0/13** — praticamente todas as falhas pelo
mesmo motivo (4 vs. 10 `TextFormField`).

### Iteração 2

**Prompt de reparo:** a causa raiz confirmada (10 campos reais, com ordem,
labels e validadores exatos extraídos de `lib/cadastro.dart`) + sugestão
de `setSurfaceSize` para o viewport. Ver `scratchpad/r15_repair2.txt`.

**Classificação declarada pelo modelo (verbatim, início):**

```
Classificação: (A). A causa dominante é o teste ter sido escrito contra a
CadastroScreen simplificada do prompt, enquanto a implementação real possui 10
campos. Isso faz o helper de preenchimento falhar antes mesmo de executar a
lógica que estava sendo testada. A correção é adaptar o teste à tela real,
mantendo os cenários e sem alterar lib/.
```

**Ação:** reescreveu o helper de preenchimento com os 10 campos reais nas
posições corretas, ajustando cada teste de validação para preencher todos
os campos obrigatórios exceto o campo sob teste.
**Resultado:** salto de 0/13 para **10/15** (dois novos testes: separou um
cenário em dois). As 5 falhas remanescentes foram as descritas acima.

### Iteração 3 (final — máximo permitido)

**Prompt de reparo:** as 5 falhas remanescentes, com diagnóstico técnico
específico para cada uma (formatter automático de CEP, sintaxe de
`Invocation.method` para métodos com parâmetros nomeados, limitação
conhecida de `TelaInicialScreen` com instrução explícita de não tentar
`Firebase.initializeApp()` falso, e a mecânica de `tester.takeException()`
para exceções síncronas em `onPressed`) + aviso de última iteração. Ver
`scratchpad/r15_repair3.txt`.

**Classificação declarada pelo modelo (verbatim, início):**

```
Classificação das cinco falhas, uma por uma:
[classificação individual — resumo: (A) para CEP e takeException; (A) técnico
mas correção não confirmada para os dois casos de mock_exceptions; (B)/limitação
de testabilidade reconhecida explicitamente para TelaInicialScreen, sem tentar
contornar com Firebase.initializeApp() falso]
```

**Ação:** corrigiu o valor de CEP inválido (`'123'` em vez de `'50000000'`),
ajustou a asserção do cenário de usuário não autenticado para
`tester.takeException()`, tentou ajustar a sintaxe de `Invocation.method`
para os dois casos de `mock_exceptions`, e manteve a captura de exceção do
`TelaInicialScreen` sem inicializar Firebase falso.
**Resultado final:** **11/15** — o CEP e a asserção de usuário não
autenticado foram corrigidos (embora este último ainda apareça como `[E]`
pelo motivo do achado 1); os dois casos de `mock_exceptions` com parâmetros
nomeados e a mecânica exata de `TelaInicialScreen` permaneceram sem
solução. Máximo de iterações atingido — documentado como está, por
protocolo.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) nas iterações 1 e 2 (ambas corretas e bem fundamentadas); iteração 3 com classificação individual das 5 falhas — (A) para 3 delas (CEP, takeException, mocks nomeados) e reconhecimento explícito de limitação de testabilidade para a 4ª (`TelaInicialScreen`), sem tentativa de camuflagem |
| **★ Classificação humana (auditoria)** | Iteração 1: **Erro de geração** (parâmetros inexistentes do `firebase_auth_mocks`). Iteração 2→3, falha do CEP: **Erro de teste**, corrigido corretamente. Falha do `mock_exceptions` (2 casos): **Erro de geração** não resolvido — a correção proposta pelo modelo não funcionou na prática, mas o diagnóstico da causa (parâmetros nomeados) está provavelmente correto, faltando a sintaxe exata. Falha do `TelaInicialScreen`: **Limitação de testabilidade**, consistente com o achado sistemático de rodadas anteriores. Falha do usuário não autenticado: **Bug real exposto** — o teste captura corretamente o bug I-CRASH, e a contagem "falho" é um artefato do `flutter_test`, não um defeito do teste |
| **★ Concordância** | Concorda substancialmente. A classificação do modelo nas 3 iterações foi tecnicamente correta em cada caso individual, incluindo o reconhecimento honesto de uma limitação de testabilidade que não tenta mascarar. Diverge apenas no sentido de que duas das "correções (A)" propostas na iteração final não funcionaram de fato — o diagnóstico foi correto, mas a implementação da correção não |
| **★ Observações** | Melhor rodada do bloco I-CRASH em taxa de sucesso final (11/15 ≈ 73%, contra 1/6 ≈ 17% em ZS e 0/2 em FS), e a única a apresentar **duas** detecções espontâneas relevantes na resposta inicial: o bug I-CRASH em si e a limitação arquitetural de propagação de dependências na navegação `Cadastro → Gêneros`. O passo explícito do CoT pedindo o cenário "usuário não autenticado" no prompt parece ter sido decisivo para essa cobertura mais completa. A correção de causa raiz mais eficaz da rodada foi fornecer a ordem exata dos 10 campos reais do formulário — uma única iteração elevou o resultado de 0/13 para 10/15, reforçando que a precisão do diagnóstico fornecido no prompt de reparo tem impacto direto e proporcional na eficácia da correção do modelo. |

### Categorias de classificação humana

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
