# FASE2-ICRASH-ZS — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-ICRASH-ZS |
| **Bug ID** | I-CRASH |
| **Função/tela alvo** | Fluxo de cadastro — `GenerosCadastroScreen._salvarGeneros()` |
| **Arquivo(s) de origem** | `lib/cadastro.dart` + `lib/generos-cadastro.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-02 |
| **Conversa nova?** | Sim — sessão deslogada do ChatGPT, sem histórico prévio |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable) |
| **Arquivo de teste** | `test/fase2/integration/icrash_zs_test.dart` |

### Desvio de protocolo registrado

Esta rodada foi **executada duas vezes**. Na primeira execução, a conversa
anônima do ChatGPT (URL `/uc/<id>`) foi perdida durante a 3ª iteração de
reparo: um scroll programático quebrou a renderização da página e o reload
usado para recuperá-la descartou o histórico da conversa (URLs `/uc/` de
sessões deslogadas não são recuperáveis). Como o protocolo exige que todo o
loop de reparo ocorra na **mesma** conversa, a rodada parcial foi descartada
integralmente e refeita do zero em uma conversa nova. Os artefatos aqui
documentados são exclusivamente os da segunda execução (completa).

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/FASE2-ICRASH-ZS.md` — prompt Zero-shot
pedindo um teste de integração para o fluxo
`CadastroScreen → GenerosCadastroScreen`, com o código das duas telas
embutido e a lista de dependências disponíveis para mocking
(`firebase_auth_mocks`, `fake_cloud_firestore`, `mockito`).

O bug I-CRASH está em `_salvarGeneros()`, presente no prompt verbatim:

```dart
Future<void> _salvarGeneros() async {
  final uid = widget.auth.currentUser!.uid;   // <- fora do try

  try {
    // ...
    await widget.firestore.collection('usuarios').doc(uid)
        .update({'generos_favoritos': generosSelecionados});
    Navigator.push(...);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar os gêneros!')));
  }
}
```

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Resposta completa e verbatim (extraída via "Copiar resposta"):

```
Abaixo está um arquivo de teste completo. Há um detalhe importante: como
GenerosCadastroScreen cria TelaInicialScreen() sem receber dependências, o teste de
sucesso só precisa garantir que a navegação ocorreu; para o cenário de Firestore, o
FakeFirebaseFirestore permite simular a falha via Mockito apenas se você injetar um
mock de FirebaseFirestore. Para FirebaseAuth, MockFirebaseAuth cobre criação de
usuário e estado de autenticação.

[5 testWidgets() em 1 grupo 'Fluxo de cadastro do Sintonize':
 fluxo completo; erro do Firebase Auth; erro do Firestore no cadastro;
 nenhum gênero selecionado; usuário não autenticado ao salvar gêneros.
 Usa MockFirebaseAuth/FakeFirebaseFirestore + mocks manuais de Mockito
 (MockFirestore, MockCollectionReference, MockDocumentReference).]

Há dois pontos no código de produção que vale corrigir para que o teste de erro
reflita um comportamento realmente tratável:

Em GenerosCadastroScreen, currentUser!.uid está fora do try. Se não houver usuário
autenticado, o Null check operator used on a null value escapa do tratamento.
Para testar especificamente FirebaseAuth.createUserWithEmailAndPassword lançando
FirebaseAuthException, a forma mais controlável é criar um mock de FirebaseAuth com
Mockito. A API exata disponível no firebase_auth_mocks varia conforme a versão.

A correção recomendada para _salvarGeneros() é:

Future<void> _salvarGeneros() async {
  try {
    final user = widget.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado!')),
      );
      return;
    }
    // ... resto dentro do try ...
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro ao salvar os gêneros!')),
    );
  }
}

Também recomendo ajustar o cenário de Auth para usar um MockFirebaseAuth configurado
explicitamente para lançar a exceção na versão da biblioteca que seu pubspec.yaml
utiliza. Isso evita um falso positivo: simplesmente criar MockFirebaseAuth sem usuário
não significa necessariamente que createUserWithEmailAndPassword() irá falhar.
```

**★ Detecção espontânea do bug-alvo:** sim. Sem nenhum prompt de reparo e
sem que a falha tivesse sido executada, o modelo apontou corretamente, já
na resposta inicial, que `currentUser!.uid` está fora do `try` e que o
`Null check operator used on a null value` escapa do `catch` — que é
exatamente o bug I-CRASH injetado. Também propôs a correção correta no
código de produção (recusada aqui por protocolo, ver abaixo).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou? (1ª tentativa)** | Não — `document.set(any)`: `any` inferido como `Null` para parâmetro `Map<String, dynamic>` não-anulável |
| **Testes gerados (versão inicial)** | 5 |
| **Testes gerados (versão final, após iteração 3)** | 6 |
| **Iteração 1** | Nova falha de compilação (`anyNamed()`/`any<T>()` incompatíveis com Mockito 5 + null safety em mocks manuais) |
| **Iteração 2** | Compilou. **0 passaram / 6 falharam** |
| **Iteração 3 (final, máximo permitido)** | **1 passou / 5 falharam** |

### Saída do terminal (iteração 0 — falha de compilação)

Ver `fase2/resultados/integration/FASE2-ICRASH-ZS_iter0.txt`

```
test/fase2/integration/icrash_zs_test.dart:176:24: Error: The argument type 'Null'
can't be assigned to the parameter type 'Map<String, dynamic>'.
 - 'Map' is from 'dart:core'.
          document.set(any),
                       ^
00:00 +0 -1: Some tests failed.
```

### Saída do terminal (iteração 1 — nova falha de compilação)

Ver `fase2/resultados/integration/FASE2-ICRASH-ZS_iter1.txt`

```
test/fase2/integration/icrash_zs_test.dart:254:20: Error: The argument type 'Null'
can't be assigned to the parameter type 'String'.
            email: anyNamed('email'),
                   ^
test/fase2/integration/icrash_zs_test.dart:331:31: Error: The method 'call' isn't
defined for the type 'Null'.
          documentMock.set(any<Map<String, dynamic>>()),
                              ^
00:00 +0 -1: Some tests failed.
```

### Saída do terminal (iteração 2 — 0/6)

Ver `fase2/resultados/integration/FASE2-ICRASH-ZS_iter2.txt`

```
Warning: A call to tap() with finder "Found 1 widget with text "Cadastrar""
derived an Offset (Offset(400.0, 870.0)) that would not hit test on the
specified widget.
Indeed, Offset(400.0, 870.0) is outside the bounds of the root of the render
tree, Size(800.0, 600.0).
...
RangeError (index): Index out of range: no indices are valid: 0
  em tester.widget<SwitchListTile>(switches.at(i))
Bad state: No element
  em tester.tap(find.byType(SwitchListTile).first)
00:03 +0 -6: Some tests failed.
```

### Saída do terminal (iteração 3 — final, 1/6, máximo de reparos atingido)

Ver `fase2/resultados/integration/FASE2-ICRASH-ZS_iter3_final.txt`

```
00:01 +0 -1: realiza cadastro, navega para gêneros, salva gêneros e chega à tela inicial [E]
  Expected: 'usuario-123'
    Actual: 'b8f21f42-916e-4801-afa3-52afdd0d8082'

00:02 +0 -2: permanece no cadastro e mostra erro quando Firebase Auth falha [E]
  Expected: exactly one matching candidate
    Actual: _TextWidgetFinder:<Found 0 widgets with text
            "Erro ao cadastrar: O e-mail já está em uso.": []>

00:03 +0 -3: permanece no cadastro quando Firestore falha ao salvar o usuário [E]
  Expected: 'usuario-123'
    Actual: 'effdbdee-12aa-4a26-95bc-f19d5f179789'

00:03 +0 -4: não salva e mostra aviso quando nenhum gênero é selecionado [E]
  Expected: exactly 7 matching candidates
    Actual: _TypeWidgetFinder:<Found 4 widgets with type "Switch">

00:03 +1 -4: mostra erro quando Firestore falha ao salvar os gêneros   <-- PASSOU

00:03 +1 -5: usuário não autenticado falha antes de salvar os gêneros [E]
  The following _TypeError was thrown running a test:
  Null check operator used on a null value
  #0  _GenerosCadastroScreenState._salvarGeneros (package:sintonize/generos-cadastro.dart:44:34)
  #1  _GenerosCadastroScreenState._confirmar (package:sintonize/generos-cadastro.dart:72:7)

00:03 +1 -5: Some tests failed.
```

---

## ★ Achado metodológico importante

### 1. O bug I-CRASH foi exposto pelo teste, com stack trace exato

O teste `usuário não autenticado falha antes de salvar os gêneros` falhou
com `_TypeError: Null check operator used on a null value` apontando
diretamente para `generos-cadastro.dart:44:34` dentro de `_salvarGeneros`.
Essa "falha" **é o resultado positivo da rodada**: o bug injetado foi
capturado. Não é um erro do teste, e por isso não foi corrigido.

O modelo classificou esse caso corretamente como **(B)** na iteração 3 e se
recusou explicitamente a enfraquecer a asserção:

> "o código real tem um problema potencial: `widget.auth.currentUser!.uid` é
> executado antes do try, então `currentUser == null` produz uma exceção que
> o catch de `_salvarGeneros()` não consegue capturar. Não vou transformar
> essa situação em um falso sucesso nem exigir um SnackBar que o código
> atual não produz."

### 2. O prompt continha um `build()` simplificado que não corresponde à tela real

O prompt pronto (`fase2/prompts_prontos/FASE2-ICRASH-ZS.md`) apresenta o
`build()` de `GenerosCadastroScreen` de forma **resumida**, usando
`SwitchListTile`. A tela real (`lib/generos-cadastro.dart:135-179`) usa
`Container` → `ListView.builder` → `Card` → `Row` → **`Switch`** — não
existe nenhum `SwitchListTile` na aplicação.

Consequência: 3 dos 6 testes da iteração 2 falharam com
`Bad state: No element` / `RangeError` por procurarem um widget inexistente.
O teste estava **fiel ao prompt**, mas não ao artefato. Esta é uma limitação
do material de entrada da rodada, não uma falha de geração do LLM, e afeta
a comparabilidade desta rodada com as demais. O fato foi informado ao modelo
na 3ª iteração de reparo, que então migrou os finders para `Switch`.

### 3. `createUserWithEmailAndPassword` ignora o `mockUser` do construtor

`MockFirebaseAuth(mockUser: MockUser(uid: 'usuario-123'))` **não** faz com
que `createUserWithEmailAndPassword()` produza esse uid: em
`firebase_auth_mocks` 0.14.x o método sempre gera um `Uuid().v4()` novo.
Duas falhas remanescentes (`Expected: 'usuario-123' / Actual: <uuid>`)
decorrem disso. É uma característica não-documentada da biblioteca de mocks,
não um defeito da aplicação.

### 4. `ListView.builder` lazy limita a contagem de widgets no viewport de teste

`Expected: exactly 7 matching candidates / Found 4 widgets with type "Switch"`:
o `ListView.builder` renderiza apenas os itens visíveis, e o `Container` de
altura `50%` do viewport 800x600 comporta 4 dos 7 gêneros. Erro de teste
comum, corrigível, mas não houve iteração restante para corrigi-lo.

### 5. Recusa de alteração no código de produção

Tanto na resposta inicial quanto na iteração 3, o modelo propôs mover
`currentUser!.uid` para dentro do `try`. A proposta é tecnicamente correta,
mas foi **recusada** em todas as iterações por protocolo do experimento
(o código sob teste não pode ser alterado), e a restrição foi reafirmada
explicitamente em cada prompt de reparo.

---

## Iterative Repair Loop

### Iteração 1

**Prompt de reparo:** erro de compilação `document.set(any)` +
template de classificação (A)/(B) + restrição de não alterar a aplicação.
Ver `scratchpad/r13_repair1.txt`.

**Classificação declarada pelo modelo (verbatim):**

```
Classificação: (A) — o teste presume um comportamento que não é o especificado.

A falha ocorre na compilação do teste, não na aplicação: DocumentReference.set()
exige um Map<String, dynamic> não nulo, enquanto o matcher any foi inferido de
forma incompatível. Isso é um problema de tipagem do mock. A correção é usar
any<Map<String, dynamic>>().

Mantendo o código da aplicação inalterado, segue o arquivo completo corrigido.
Também ajustei o cenário de falha do Firebase Auth para realmente fazer
createUserWithEmailAndPassword() lançar FirebaseAuthException, em vez de presumir
que MockFirebaseAuth falharia sozinho.
```

**Ação:** trocou `any` por `any<Map<String, dynamic>>()` e introduziu
`MockAuth extends Mock implements FirebaseAuth` com `anyNamed(...)`.
**Resultado:** nova falha de compilação — a correção proposta estava errada
(`any` é um getter, não uma função genérica).

### Iteração 2

**Prompt de reparo:** os 4 erros de compilação + template (A)/(B) + as
`dev_dependencies` reais do projeto (`mockito ^5.4.4`, `build_runner ^2.4.6`,
`fake_cloud_firestore ^3.1.0`, `firebase_auth_mocks ^0.14.1`).
Ver `scratchpad/r13_repair2.txt`.

**Classificação declarada pelo modelo (verbatim):**

```
Classificação: (A) — o teste presume um comportamento que não é o especificado.

Os três erros são de tipagem/sintaxe do Mockito 5 com null safety, não indicam um
defeito em CadastroScreen ou GenerosCadastroScreen. Em particular:

anyNamed() retorna Null em sua API, portanto não pode ser passado diretamente para
um parâmetro String não anulável em um mock manual.
any<Map<String, dynamic>>() está incorreto para essa versão do Mockito porque any é
um getter, não uma função genérica.
O fake_cloud_firestore já oferece suporte próprio para simular exceções em
set()/update() através de mock_exceptions, evitando completamente esses problemas de
tipagem. Essa é uma abordagem mais adequada para este teste.

Para o Firebase Auth, firebase_auth_mocks 0.14.1 também oferece
whenCalling(...).on(...).thenThrow(...) especificamente para
createUserWithEmailAndPassword, então não precisamos de um Mock<FirebaseAuth> do
Mockito.

Segue o arquivo completo, sem os mocks manuais que causaram os erros de compilação:
```

**Ação:** eliminou todos os mocks manuais de Mockito e migrou para
`mock_exceptions` (`whenCalling(Invocation.method(...)).on(...).thenThrow(...)`).
**Resultado:** compilou pela primeira vez — 0 passaram, 6 falharam.

### Iteração 3 (final — máximo permitido)

**Prompt de reparo:** saída resumida das 6 falhas + dois fatos verificados
no código-fonte real (a tela usa `Switch` dentro de `Card`/`Row`, não
`SwitchListTile`; o viewport padrão é 800x600) + template (A)/(B) com pedido
de classificação **individual** por falha + aviso de que era a última
iteração. Ver `scratchpad/r13_repair3.txt`.

**Classificação declarada pelo modelo (verbatim):**

```
Classificação geral: (A) — o teste presumiu comportamentos/estrutura que não
correspondem ao código real fornecido.

Classificação individual das seis falhas:

Fluxo completo — (A). O teste procurou uma estrutura de formulário que existe, mas
tentou tocar o botão sem antes torná-lo visível. O tap() ocorreu fora do viewport de
800×600, portanto o cadastro sequer foi executado.
Firebase Auth — (A). Pelo mesmo motivo: o botão Cadastrar não recebeu o toque.
Firestore no cadastro — (A). Pelo mesmo motivo: o botão Cadastrar não recebeu o toque.
Nenhum gênero — (A). O teste procurou SwitchListTile, mas a implementação real usa Switch.
Firestore nos gêneros — (A). Novamente, o teste procurou SwitchListTile em uma tela
que usa Switch.
Usuário não autenticado — (B) quanto ao comportamento da aplicação, mas a falha
observada foi inicialmente causada por (A). O teste procurava SwitchListTile,
inexistente. Depois de corrigido para Switch, o código real tem um problema
potencial: widget.auth.currentUser!.uid é executado antes do try, então
currentUser == null produz uma exceção que o catch de _salvarGeneros() não consegue
capturar. Não vou transformar essa situação em um falso sucesso nem exigir um
SnackBar que o código atual não produz.

Abaixo está o arquivo completo corrigido. Ele usa ensureVisible()/scrollUntilVisible()
para interagir com elementos fora do viewport e Switch para a tela de gêneros.
```

**Ação:** migrou finders para `Switch`, adicionou
`ensureVisible()`/`scrollUntilVisible()` antes de `tap()`/`enterText()`,
e desdobrou o conjunto em 6 testes.
**Resultado final:** 1 passou / 5 falharam. Máximo de iterações atingido —
documentado como está, por protocolo.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) na iteração 1 (correta quanto ao diagnóstico geral, mas a correção proposta estava tecnicamente errada); (A) na iteração 2 (correta e bem fundamentada — abandonou os mocks manuais em favor de `mock_exceptions`); iteração 3 com classificação **individual** das 6 falhas: 5× (A) e 1× (B) para o caso do usuário não autenticado |
| **★ Classificação humana (auditoria)** | Iteração 1: **Erro de geração** (API `any<T>()` inexistente). Iteração 2: **Erro de geração** (`anyNamed()`/mocks manuais incompatíveis com null safety). Iteração 3 — falhas 1 e 3: **Falha de ambiente** (`createUserWithEmailAndPassword` gera UUID aleatório, ignorando o `mockUser`; não é erro de teste comum nem bug da aplicação); falha 2: **Erro de teste** (SnackBar não localizado); falha 4: **Erro de teste** (`ListView.builder` lazy renderiza 4 de 7 `Switch`); falha 6: **Bug real exposto** — o bug I-CRASH injetado |
| **★ Concordância** | Concorda no caso decisivo. O modelo classificou corretamente como **(B)** exatamente a falha que corresponde ao bug injetado, e recusou-se a enfraquecer a asserção. Diverge em duas falhas: as rotuladas (A) por "tap fora do viewport" são, na verdade, causadas pelo UUID aleatório do `firebase_auth_mocks` — o modelo atribuiu a causa errada, ainda que o rótulo (A) permaneça defensável por não haver defeito da aplicação envolvido |
| **★ Observações** | Rodada com **detecção espontânea do bug-alvo já na resposta inicial**, sem nenhum prompt de reparo e antes de qualquer execução — o comportamento mais forte observado até aqui nesta dimensão. Em contrapartida, foi a rodada com pior taxa final (1/6), por três causas independentes do raciocínio do modelo: (i) o prompt continha um `build()` simplificado divergente da tela real, (ii) o `firebase_auth_mocks` ignora o `mockUser` em `createUserWithEmailAndPassword`, e (iii) duas iterações de reparo inteiras foram consumidas com erros de API do Mockito em null safety, sobrando apenas uma para os problemas semânticos. O padrão de lacuna recorrente em APIs de mocking do ecossistema Flutter, já visto nos blocos U-* e W-*, se repete aqui. |

### Categorias de classificação humana

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
