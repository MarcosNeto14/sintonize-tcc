# FASE2-WSILENT-COT — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WSILENT-COT |
| **Bug ID** | W-SILENT |
| **Função/tela alvo** | `LoginScreen` (`login()` — mapeamento de erros) |
| **Arquivo(s) de origem** | `lib/login.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-02 |
| **Conversa nova?** | Sim — sessão deslogada do ChatGPT, sem histórico prévio |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable) |

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/FASE2-WSILENT-COT.md` — prompt
Chain-of-Thought pedindo análise em 4 passos, seguido do código
completo de `LoginScreen` (mesmo bug W-SILENT das rodadas ZS/FS:
mensagens de `user-not-found`/`wrong-password` trocadas).

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Resposta completa e verbatim (extraída via "Copiar resposta"):

```
Abaixo está uma suíte de testes focada exclusivamente no comportamento observável do LoginScreen, sem alterar o widget de produção.

1. Análise do widget

O LoginScreen apresenta um formulário de login com campos de e-mail e senha, botão Entrar e logo da aplicação. O formulário valida e-mail e senha localmente antes de chamar signInWithEmailAndPassword. Em caso de sucesso, o widget substitui a rota atual por TelaInicialScreen; em caso de erro de autenticação, exibe um SnackBar vermelho com uma mensagem específica conforme o código retornado pelo Firebase Auth. Os imports cadastro.dart e recup-senha.dart estão presentes, mas não são utilizados nem oferecem elementos interativos neste widget.

2. Dependências que precisam de mock
Firebase Auth — é a única dependência externa efetivamente utilizada pelo widget. Deve ser injetada pelo construtor como MockFirebaseAuth, evitando chamadas reais ao Firebase.
Firestore — FakeFirebaseFirestore não é necessário para estes testes, porque o LoginScreen não acessa Firestore.
HTTP — não há chamadas HTTP no widget, portanto não há nada para mockar.
Navegação — não precisa de mock; pode ser verificada com um MaterialApp e uma rota de destino de teste.
Asset da logo — como o widget usa Image.asset, o teste pressupõe que assets/logo-sintoniza.png esteja declarado no pubspec.yaml.

3. Cenários de teste
Renderização do formulário, labels, campos e botão.
Formulário vazio: mensagens de validação para e-mail e senha.
E-mail inválido.
Senha com menos de 6 caracteres.
E-mail e senha válidos: signInWithEmailAndPassword é chamado com os valores corretos.
Login bem-sucedido: navegação para TelaInicialScreen.
Firebase user-not-found / wrong-password / invalid-credential: mensagem específica exibida.
Código Firebase desconhecido: mensagem genérica exibida.
Entrada de texto e comportamento de senha.
Scroll do formulário, importante porque o conteúdo está dentro de SingleChildScrollView.

Observação importante: o widget não faz nenhuma chamada HTTP nem Firestore, então não existe um cenário de "rede HTTP falhou" específico para cobrir. Uma falha de rede no Firebase Auth pode ser representada por um FirebaseAuthException com código não tratado, caindo na mensagem genérica.

4. Testes completos
[19 testWidgets() em 5 grupos: renderização (3), validação (5), entrada
de dados (2), login com sucesso (2), erros do Firebase Auth (7) — ver
test/fase2/widget/wsilent_cot_test.dart para o texto final pós-reparo]

Há um detalhe relevante sobre firebase_auth_mocks: dependendo da versão usada no pubspec.yaml, a API de configuração da exceção (signInException) pode variar. Se sua versão não expuser essa propriedade, a alternativa mais estável é usar mockito para criar um mock de FirebaseAuth e fazer when(auth.signInWithEmailAndPassword(...)).thenThrow(...). Nesse caso, a estrutura dos testWidgets acima permanece praticamente igual.
```

**★ Nenhuma detecção espontânea do bug-alvo nesta rodada (diferente de
ZS e FS):** ao contrário das duas rodadas anteriores de W-SILENT, o
modelo **não comentou** a inversão das mensagens `user-not-found`/
`wrong-password` na resposta inicial — apesar de os testes gerados
reproduzirem corretamente o comportamento real (buggy) da aplicação
(ex.: o teste para `user-not-found` espera a mensagem "Senha
incorreta..."). A observação sobre a inversão só apareceu depois,
durante a 1ª iteração de reparo (ver abaixo), motivada por um comentário
do próprio experimentador no prompt de reparo, não espontaneamente.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou? (1ª tentativa)** | Não — `TextFormField.obscureText` (erro já visto em WSILENT-ZS/FS) e `MockFirebaseAuth.signInException` (API inexistente na versão 0.14.2) |
| **Testes gerados** | 19 |
| **Testes passaram (após iteração 1 — APIs corrigidas)** | 15 |
| **Testes falharam (após iteração 1)** | 4 (todas `FirebaseException` de `TelaInicialScreen`) |
| **Testes passaram (após iteração 2 — teste de validação isolado)** | Nova falha de compilação (`form.key` tipado como `Key?`) |
| **Testes passaram (após iteração 3 — final, máximo permitido)** | 16 |
| **Testes falharam (após iteração 3 — final)** | 3 |

### Saída do terminal (iteração 0 — falha de compilação)

```
test/fase2/widget/wsilent_cot_test.dart:78:18: Error: The getter 'obscureText' isn't defined for the type 'TextFormField'.
test/fase2/widget/wsilent_cot_test.dart:371:18: Error: The setter 'signInException' isn't defined for the type 'MockFirebaseAuth'.
(erro de signInException repetido em 7 testes)
Compilation failed for testPath=test/fase2/widget/wsilent_cot_test.dart
```

(saída completa em `fase2/resultados/widget/FASE2-WSILENT-COT_iter0.txt`)

### Saída do terminal (iteração 1 — 15/19)

4 falhas, todas `FirebaseException: [core/no-app] No Firebase App '[DEFAULT]' has been created`:
1. `deve aceitar e-mail válido com senha de 6 caracteres`
2. `deve remover espaços das credenciais antes do login`
3. `deve chamar signInWithEmailAndPassword com as credenciais corretas`
4. `deve navegar para TelaInicialScreen após login bem-sucedido`

Diferente das rodadas ZS/FS (onde só 1-2 testes eram afetados), aqui **4 testes** quebraram pela mesma causa: como `MockFirebaseAuth()` sem configuração aceita qualquer credencial, qualquer teste que chama `login()` com dados válidos (mesmo sem a intenção de testar navegação) aciona `Navigator.pushReplacement` → `TelaInicialScreen` → crash.

(saída completa em `fase2/resultados/widget/FASE2-WSILENT-COT_iter1.txt`)

### Saída do terminal (iteração 2 — nova falha de compilação)

```
test/fase2/widget/wsilent_cot_test.dart:155:37: Error: The getter 'currentState' isn't defined for the type 'Key'.
        final formState = form.key!.currentState!;
                                    ^^^^^^^^^^^^
Compilation failed for testPath=test/fase2/widget/wsilent_cot_test.dart
```

Ao tentar isolar o teste de validação (usando `form.key!.currentState!`
para chamar `FormState.validate()` diretamente, evitando disparar
`login()`), o modelo cometeu um **novo erro de tipagem**: `Form.key` é
declarado como `Key?` na API pública do Flutter, não como
`GlobalKey<FormState>?`, exigindo um cast explícito.

(saída completa em `fase2/resultados/widget/FASE2-WSILENT-COT_iter2.txt`)

### Saída do terminal (iteração 3 — final, 16/19, máximo de reparos atingido)

```
00:03 +9 -3: LoginScreen - login com sucesso deve navegar para TelaInicialScreen após login bem-sucedido [E]
00:04 +16 -3: Some tests failed.
```

3 falhas finais, todas a mesma limitação de testabilidade de
`TelaInicialScreen` (documentada em `FASE2-WSILENT-ZS`): "deve remover
espaços das credenciais antes do login", "deve chamar
signInWithEmailAndPassword com as credenciais corretas" e "deve navegar
para TelaInicialScreen após login bem-sucedido". O 4º teste do grupo
("deve aceitar e-mail válido com senha de 6 caracteres") foi corrigido
com sucesso ao isolar a validação via `FormState.validate()`, sem
disparar `login()`.

(saída completa em `fase2/resultados/widget/FASE2-WSILENT-COT_iter3_final.txt`)

---

## ⚠️ Achado metodológico importante

Esta é a rodada mais rica em achados metodológicos do bloco W-SILENT:

1. **Ausência de detecção espontânea** — ao contrário de WSILENT-ZS e
   WSILENT-FS, o modelo não comentou a inversão das mensagens de erro
   na resposta inicial. Isso é evidência de que a detecção espontânea
   não é garantida por estratégia — mesmo Chain-of-Thought, que pede
   explicitamente uma "análise" antes de escrever os testes, não
   detectou o problema desta vez. O modelo só descreveu a inconsistência
   depois de ser questionado no prompt de reparo (e mesmo assim, o
   experimentador é quem primeiro trouxe o assunto à tona, ao explicar
   o contexto do erro de compilação).

2. **A limitação de `TelaInicialScreen` teve impacto ampliado** — a
   suíte COT, por ser mais extensa (19 testes vs. 14 e 10 nas rodadas
   ZS/FS), teve **4 testes** (não apenas 1) afetados pela mesma
   limitação de testabilidade, porque testes que não pretendiam
   verificar navegação (validação, entrada de dados, chamada correta do
   Auth) acabaram, como efeito colateral, disparando um login
   bem-sucedido completo. Apenas 1 desses 4 pôde ser corrigido dentro
   do escopo (isolando a validação via `FormState.validate()` em vez de
   tocar o botão "Entrar"); os outros 3 dependem estruturalmente de
   `login()` acoplar autenticação e navegação em uma única função, sem
   ponto de extensão para testar uma sem a outra.

3. **Um 4º tipo de erro de API/tipagem do Flutter** — além dos já
   conhecidos `TextFormField.obscureText` (repetido pela 3ª vez,
   confirmando ser uma lacuna de conhecimento consistente do modelo) e
   `MockFirebaseAuth.signInException` (mais uma API inexistente/de
   versão diferente, desta vez nem sugerida por um exemplo few-shot —
   o modelo simplesmente presumiu que existia), a rodada revelou um
   novo erro: `Form.key` tem tipo estático `Key?`, exigindo cast
   explícito para `GlobalKey<FormState>?` antes de acessar
   `.currentState`. O modelo corrigiu prontamente ao ser apontado.

4. Fechando o bloco W-SILENT (3/3 rodadas), o padrão de detecção do
   bug-alvo foi: ZS ✅ espontânea, FS ✅ espontânea, COT ❌ (sem
   detecção espontânea, mas presente nos testes desde o início e
   reconhecida quando questionada) — uma inversão do padrão observado
   no bloco W-CRASH, onde nenhuma das 3 estratégias detectou o bug.

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** compilação — dois erros de API distintos (`obscureText` em `TextFormField`; `signInException` em `MockFirebaseAuth`, ambos inexistentes na versão 0.14.2 instalada).
- **Prompt de reparo enviado:** os dois erros colados (resumindo a repetição de `signInException` em 7 testes), com a assinatura real das classes e sugestão de `mock_exceptions`/`whenCalling` e `find.descendant(..., matching: find.byType(EditableText))` como alternativas compatíveis.
- **Resposta do LLM (completa e verbatim):**

```
Classificação: (A) — o teste presume APIs/comportamentos que não existem

Os dois erros são causados pelo teste, não indicam por si só um defeito no LoginScreen:
TextFormField não expõe obscureText diretamente. A propriedade pertence ao EditableText interno.
firebase_auth_mocks 0.14.2 não possui MockFirebaseAuth.signInException; portanto, a exceção precisa ser configurada usando o mecanismo de mock_exceptions/whenCalling.

[... correções completas para os dois problemas, usando find.descendant(of:, matching: find.byType(EditableText)) e whenCalling(Invocation.method(#signInWithEmailAndPassword, null)).on(mockAuth).thenThrow(...) para os 7 testes de erro ...]

Um ponto adicional importante

Há uma inconsistência semântica no próprio widget que os testes anteriores corretamente capturaram e que não deve ser corrigida no teste:
Firebase retorna user-not-found → aplicação mostra "Senha incorreta..."
Firebase retorna wrong-password → aplicação mostra "Usuário não encontrado..."
Normalmente seria esperado o contrário. Porém, como você pediu explicitamente testes sem modificar o widget, os testes devem documentar o comportamento atualmente implementado, mesmo que ele pareça invertido. Portanto, isso é diferente da classificação (A) dos erros de compilação: a API inexistente é problema do teste; as mensagens invertidas são um possível problema da aplicação e devem permanecer explicitamente cobertas pelos testes.
```

- **Resultado:** compilou; 15/19 passaram, 4 falharam (todas `FirebaseException` de `TelaInicialScreen`, detalhadas acima).

### Iteração 2

- **Motivo da falha:** 4 falhas com a mesma causa raiz (limitação de testabilidade de `TelaInicialScreen`, já documentada em `FASE2-WSILENT-ZS`).
- **Prompt de reparo enviado:** as 4 falhas coladas, com o contexto já conhecido da limitação (incluindo que `Firebase.initializeApp()` com opções falsas não resolve), pedindo classificação individual e propostas de correção apenas para os 3 testes que não tinham como objetivo verificar navegação diretamente.
- **Resposta do LLM (resumo — completa em `fase2/resultados/widget/FASE2-WSILENT-COT_iter2.txt` e no histórico da conversa):** classificou os 4 como (A) quanto à causa imediata, mas reconheceu que **apenas o teste 1** ("e-mail válido com senha de 6 caracteres") tinha uma correção limpa (usar `FormState.validate()` diretamente, sem tocar o botão "Entrar", evitando `login()` por completo). Para os testes 2 e 3, declarou explicitamente que **não há uma forma robusta de isolar o comportamento desejado** via API pública do widget, sem recorrer a truques de timing (`pump()` vs. `pumpAndSettle()`) que tornariam o teste frágil — recomendou não fazer isso. Para o teste 4, manteve a classificação (B) já estabelecida.
- **Resultado:** nova falha de **compilação** ao aplicar a correção do teste 1 — `form.key!.currentState!` não compila porque `Form.key` é tipado como `Key?`, não `GlobalKey<FormState>?`.

### Iteração 3 (final — máximo permitido)

- **Motivo da falha:** erro de tipagem no cast de `form.key`.
- **Prompt de reparo enviado:** o erro de compilação colado, com a correção esperada (cast explícito) sugerida no próprio prompt.
- **Resposta do LLM (completa e verbatim):**

```
Classificação: (A)

A falha é exclusivamente do teste: Widget.key tem tipo estático Key?, portanto o compilador não sabe que, neste caso específico, a chave é uma GlobalKey<FormState>. Não há indicação de problema no LoginScreen.

A correção é fazer o cast explicitamente, como você indicou.

[... teste corrigido usando (form.key as GlobalKey<FormState>).currentState! ...]

Os outros três permanecem conforme a classificação anterior: 2 e 3 são (A), mas não há uma correção robusta dentro do escopo atual sem lidar com o acoplamento à navegação; 4 é (B) e não deve ter sua asserção enfraquecida.
```

- **Resultado:** 16/19 passaram. O teste de validação isolada foi corrigido com sucesso. Os 3 testes restantes (2 classificados como A sem correção viável no escopo, 1 como B) permanecem falhos — todos pela mesma limitação de testabilidade de `TelaInicialScreen`. **Repair loop encerrado no limite de 3 iterações, sem 100% dos testes passando — resultado final: 16/19.**

---

## ★ Análise de Autoclassificação (preencher após a rodada)

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) na iteração 1 (duas APIs inexistentes, corretas); (A)/(B) mistas na iteração 2 (reconheceu corretamente que 1 dos 4 testes tinha correção limpa, e que 2 não tinham correção viável no escopo apesar de rotulados A, e 1 era B); (A) na iteração 3 (erro de tipagem, corrigido corretamente) |
| **★ Classificação humana (auditoria)** | Erro de geração (iteração 1 — duas APIs inexistentes) / Erro de teste corrigível (1 dos 4 testes da iteração 2) / Limitação de testabilidade (3 dos 4 testes — apesar de o modelo rotular 2 deles como "A" nominalmente, sua própria explicação de que "não há correção robusta via API pública" os torna, na prática, casos de limitação de testabilidade, não erro de teste comum) / Erro de teste (iteração 3 — cast de tipo) |
| **★ Concordância** | Concorda parcialmente — o modelo foi tecnicamente correto em cada classificação individual, mas sua rotulagem (A) para os testes 2 e 3 da iteração 2 é inconsistente com sua própria conclusão de que não existe correção sem alterar a arquitetura da aplicação; na prática, deveriam ter sido rotulados (B) desde essa iteração |
| **★ Observações** | Rodada mais instrutiva do bloco W-SILENT: nenhuma detecção espontânea do bug-alvo (diferente de ZS/FS); a limitação de `TelaInicialScreen` teve impacto ampliado (4 de 19 testes, vs. 1-2 nas rodadas anteriores) por causa do maior número de testes gerados pela estratégia CoT; e um 4º tipo distinto de erro de API/tipagem do Flutter foi cometido pelo modelo, reforçando o padrão de lacunas de conhecimento específicas e recorrentes em APIs de teste do Flutter (não apenas um acaso pontual). Esgotou as 3 iterações permitidas sem 100% — resultado final 16/19, documentado como está por protocolo. |

**Referência de categorias (classificação humana — mesmas da Fase 1):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
