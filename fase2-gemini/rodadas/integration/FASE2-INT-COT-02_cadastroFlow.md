# FASE2-INT-COT-02_cadastroFlow — Réplica Gemini

Rodada **57/60**. Bloco 3 (integração), lote 13 (`cadastroFlow`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-INT-COT-02_cadastroFlow |
| **Função/tela alvo** | fluxo de cadastro — `CadastroScreen` → `GenerosCadastroScreen` |
| **Arquivo(s) de origem** | `lib/cadastro.dart`, `lib/generos-cadastro.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Pílula do seletor conferida a cada envio: `Flash` (não `Flash-Lite`). |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/e0011ec67939e295` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos`, alvo limpo. I-CRASH verificado revertido antes da rodada |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 · DevTools 2.54.2 |
| **Arquivo de teste** | `test/fase2-gemini/integration/cadastro_flow_cot_test.dart` |
| **Saídas arquivadas** | `resultados/integration/FASE2-INT-COT-02_{iter0,iter1,iter2,iter3_final}.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/integration/cot/FASE2-INT-COT-02_cadastroFlow.md`, sem alteração |

---

## Tentativas de envio

| Envio | Canal | Resultado |
|---|---|---|
| Geração | automação | Aceito no primeiro envio. |
| Reparo 1 | automação | Aceito no primeiro envio. |
| Reparo 2 | automação | Aceito no primeiro envio. |
| Reparo 3 | automação | Aceito no primeiro envio. |

**Tentativas de envio até obter resposta: 1 em todos os envios. Nenhuma recusa.**

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 5 |
| **Testes passaram (iteração 0)** | 3/5 |
| **Testes passaram (final, iteração 3)** | **5/5 — todos** |
| **Iterações de reparo** | 3 (máximo) |
| **Tentativas de envio até obter resposta** | 1 (nenhuma recusa) |
| **Autoclassificação** | **(B)**; (A); (A) — todas corretas |

**Primeira suíte 100% verde de todo o bloco 3.**

---

## Iterative Repair Loop

| Iteração | Envio | Resposta | Classificação | Resultado |
|---|---|---|---|---|
| 0 (geração) | automação | análise do fluxo + 5 `testWidgets`, `firebase_auth_mocks` + `fake_cloud_firestore` + `mockito` | — | **compila** — **3/5**. Falhas: `[core/no-app]` da `TelaInicialScreen` e o SnackBar de erro do cadastro |
| 1 | automação, mesma conversa | **arquivo completo**; ataca o `[core/no-app]` com `setupFirebaseCoreMocks()` + `Firebase.initializeApp()` no `setUpAll` | **(B)**, correta — aponta a falta de injeção de dependência na `TelaInicialScreen` e **mesmo assim entrega um contorno que não enfraquece a asserção** | **não carrega** — `Binding has not yet been initialized`: `setupFirebaseCoreMocks()` chamado em `main()` antes do binding |
| 2 | automação, mesma conversa | patch de uma linha: `TestWidgetsFlutterBinding.ensureInitialized();` como primeira instrução de `main()` | **(A)**, correta | aplicado → **4/5**. Resta o SnackBar de erro do cadastro |
| 3 | automação, mesma conversa | **arquivo completo**; diagnostica que o `onChanged` do campo CEP dispara `_fetchAddressFromCEP` e o `ScaffoldMessenger` exibe **a SnackBar do ViaCEP** no lugar da esperada | **(A)**, correta | **5/5 — All tests passed! (final)** |

---

## Observações

1. **A primeira suíte verde do bloco 3, e a única até agora que venceu a parede da `TelaInicialScreen`.** Rodadas 52, 53, 54 e 55 morreram nela. Aqui o modelo classificou o `[core/no-app]` como **(B)** na iteração 1 — diagnóstico correto e igual ao das outras rodadas — mas, em vez de parar no diagnóstico (como fez na rodada 53) ou perseguir o mock até quebrar o arquivo (rodadas 54 e 55), entregou um contorno no **ambiente de teste**: inicializar os canais de plataforma do Firebase Core. Mesma conclusão, terceira reação diferente, e a única que funciona.
2. **O `setupFirebaseCoreMocks()` finalmente funcionou — na quarta tentativa da réplica.** O modelo tentou esse caminho nas rodadas 54 (três vezes) e 55 (uma vez), sempre errando o pré-requisito: ora o import, ora a ordem em relação ao binding. Aqui errou a ordem na iteração 1, recebeu o erro exato do Flutter (que nomeia a correção) e acertou na 2. A diferença não foi conhecimento, foi ter sobrado iteração para ler o erro.
3. **A limitação do ViaCEP prevista nas notas de protocolo apareceu — e foi resolvida pelo modelo.** O prompt antecipava que o campo CEP dispara uma requisição HTTP real sem ponto de injeção. Na iteração 3 o modelo diagnostica exatamente isso: o `onChanged` do CEP chama `_fetchAddressFromCEP`, a requisição falha no ambiente de teste (status 400) e o `ScaffoldMessenger` exibe a SnackBar do ViaCEP **por cima** da esperada. Ajustou o teste sem tocar na aplicação. É o diagnóstico mais fino de toda a réplica até aqui.
4. **Autoclassificação (B) seguida de correção é um caso novo.** Até esta rodada, (B) sempre significou "não corrijo o teste" (rodada 53). Aqui o modelo classifica (B), explica por que o defeito é da aplicação, e **ainda assim** contorna no ambiente de teste sem reduzir escopo nem enfraquecer asserção — que é o que a instrução de reparo permite, mas nenhuma rodada anterior havia feito.
5. **Comparação com o ChatGPT na mesma rodada:** ChatGPT gerou 10 testes e fechou em **9/10**, com **(A) em todas as iterações** — nunca atribuiu nada à aplicação. Gemini gerou 5 e fechou em **5/5**, com um (B) correto pelo caminho. Em número absoluto de testes verdes o ChatGPT entrega mais (9 contra 5); em taxa e em diagnóstico, o Gemini. É o inverso exato da rodada 54, no mesmo par de modelos e no mesmo nível da pirâmide.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
Abaixo está a análise detalhada do fluxo do aplicativo **Sintonize**, seguida pela especificação e implementação dos testes de integração em Dart com Flutter.

---

### 1. Análise do Fluxo

1. O usuário entra na tela `CadastroScreen`, preenche seus dados cadastrais (nome, data de nascimento, e-mail, senhas e endereço/CEP) e aciona o botão "Cadastrar".
2. **Pontos de Decisão no Cadastro:**
* **Validação síncrona:** Se algum campo obrigatório ou formato falhar (ex.: e-mail malformatado, senha curta, senhas divergentes), mensagens de validação aparecem no formulário e nada é enviado.
* **Persistência e Auth:** Se as validações passarem, a conta é criada no `FirebaseAuth` e o documento é gravado em `usuarios/{uid}` no `FirebaseFirestore`. Em caso de erro do Firebase (ex.: e-mail em uso, falha de rede), um `SnackBar` exibe a mensagem de erro. Em caso de sucesso, o app navega via `Navigator.push` para a `GenerosCadastroScreen`.


3. Na `GenerosCadastroScreen`, o usuário visualiza uma lista com switches de gêneros musicais e aciona o botão "Confirmar".
4. **Pontos de Decisão nos Gêneros:**
* Se nenhum gênero estiver marcado, uma `SnackBar` alerta o usuário e impede o avanço.
* Se pelo menos um gênero estiver marcado e o usuário estiver autenticado, a lista `generos_favoritos` é atualizada no documento `usuarios/{uid}` e o app navega para a `TelaInicialScreen`. Se o Firestore falhar, uma `SnackBar` de erro é exibida.



---

### 2. Identificação das Dependências e Estratégia de Mocks

| Serviço | Onde é usado | Estratégia de Mock |
| --- | --- | --- |
| **FirebaseAuth** | `CadastroScreen` (`createUserWithEmailAndPassword`) e `GenerosCadastroScreen` (`currentUser`) | `MockFirebaseAuth` do pacote `firebase_auth_mocks` para simular criação de usuário com sucesso e persistência de sessão. Para testar exceções específicas (`FirebaseAuthException`), usa-se subclasse ou simulação via mock. |
| **FirebaseFirestore** | `CadastroScreen` (`collection('usuarios').doc(uid).set`) e `GenerosCadastroScreen` (`update`) | `FakeFirebaseFirestore` do pacote `fake_cloud_firestore` para gravação em memória e asserção direta do documento resultante. |
| **HTTP (ViaCEP)** | `CadastroScreen` (`_fetchAddressFromCEP`) | Chamada via `http.get`. Para testes focados no fluxo de submissão do formulário, os campos de endereço (`rua`, `bairro`, `cidade`, `estado`) podem ser preenchidos diretamente sem depender da requisição externa de CEP. |

---

### 3. Estrutura de Navegação para Testes

Como as telas utilizam navegação imperativa direta via `MaterialPageRoute`:

* `CadastroScreen` -> faz `Navigator.push(..., GenerosCadastroScreen(auth: widget.auth, firestore: widget.firestore))`
* `GenerosCadastroScreen` -> faz `Navigator.push(..., TelaInicialScreen())`

Para que o teste consiga resolver a `TelaInicialScreen` (cujo arquivo original não está no escopo), fornecemos uma rota default com um widget substituto ou encapsulamos o teste dentro de um `MaterialApp` configurado com tamanho de tela suficiente para evitar overflow de layout nos `SingleChildScrollView` e `ListView`:

```dart
Widget createTestApp({
  required FirebaseAuth auth,
  required FirebaseFirestore firestore,
}) {
  return MaterialApp(
    home: CadastroScreen(
      auth: auth,
      firestore: firestore,
    ),
  );
}

```

---

### 4. Cenários de Teste

1. **Cenário 1 (Sucesso Ponta a Ponta):**
* Usuário preenche todos os campos do formulário na `CadastroScreen`.
* Clica em "Cadastrar".
* Valida criação no `FirebaseAuth` e escrita dos dados em `usuarios/{uid}`.
* Verifica transição para a tela `GenerosCadastroScreen`.
* Seleciona o gênero musical "Rock" no Switch.
* Clica em "Confirmar".
* Valida atualização do campo `generos_favoritos` no documento do usuário no Firestore.
* Verifica navegação para a `TelaInicialScreen`.


2. **Cenário 2 (Erros de Validação no Formulário):**
* Usuário submete o formulário com campos em branco ou senhas divergentes.
* Valida que as mensagens de validação são exibidas sob os campos e nenhuma chamada ao Firebase é feita.


3. **Cenário 3 (Erro do Firebase Auth no Cadastro):**
* Simulação de falha ao cadastrar (`FirebaseAuthException`).
* Valida exibição do `SnackBar` com `"Erro ao cadastrar: ..."`.
* Garante que a tela `GenerosCadastroScreen` não seja aberta.


4. **Cenário 4 (Validação de Seleção em Gêneros):**
* Usuário chega à tela `GenerosCadastroScreen`, não seleciona nenhum gênero e clica em "Confirmar".
* Valida exibição do `SnackBar` `"Selecione pelo menos um gênero musical!"`.


5. **Cenário 5 (Erro ao Salvar Gêneros no Firestore):**
* `GenerosCadastroScreen` tenta atualizar documento com falha ou usuário nulo.
* Valida exibição da mensagem de erro `"Erro ao salvar os gêneros!"`.



---

### 5. Código Completo dos Testes de Integração

```dart
// test/integration/cadastro_fluxo_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

// Mock customizado de FirebaseAuth para cenários de exceção controlada
class FailingMockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw FirebaseAuthException(
      code: 'email-already-in-use',
      message: 'O endereço de e-mail já está em uso.',
    );
  }
}

void main() {
  setUpAll(() {
    // Garante inicialização do Flutter Binding
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Widget buildAppWithScreen({
    required Widget screen,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(1080, 2400)), // Evita overflow de renderização
        child: screen,
      ),
    );
  }

  group('Fluxo de Cadastro e Seleção de Gêneros - Integração', () {
    testWidgets('Cenário 1: Fluxo de sucesso completo ponta a ponta', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuth = MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildAppWithScreen(
        screen: CadastroScreen(
          auth: fakeAuth,
          firestore: fakeFirestore,
        ),
      ));
      await tester.pumpAndSettle();

      // 1. Preenchimento dos campos do formulário
      // Nome
      final nomeField = find.widgetWithText(TextFormField, '');
      await tester.enterText(find.byType(TextFormField).at(0), 'Maria Silva');
      // Data Nasc
      await tester.enterText(find.byType(TextFormField).at(1), '15101998');
      // Email
      await tester.enterText(find.byType(TextFormField).at(2), 'maria@email.com');
      // Senha
      await tester.enterText(find.byType(TextFormField).at(3), 'senha123');
      // Confirmar Senha
      await tester.enterText(find.byType(TextFormField).at(4), 'senha123');
      // CEP
      await tester.enterText(find.byType(TextFormField).at(5), '50000000');
      // Rua
      await tester.enterText(find.byType(TextFormField).at(6), 'Rua Aurora');
      // Número
      await tester.enterText(find.byType(TextFormField).at(7), '100');
      // Bairro
      await tester.enterText(find.byType(TextFormField).at(8), 'Boa Vista');
      // Cidade
      await tester.enterText(find.byType(TextFormField).at(9), 'Recife');

      // Seleção do Estado no Dropdown
      final estadoDropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(estadoDropdown);
      await tester.tap(estadoDropdown);
      await tester.pumpAndSettle();

      final estadoItem = find.text('PE').last;
      await tester.tap(estadoItem);
      await tester.pumpAndSettle();

      // Submissão do formulário
      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      // 2. Asserção pós-cadastro: Autenticação e Firestore
      expect(fakeAuth.currentUser, isNotNull);
      final String uid = fakeAuth.currentUser!.uid;

      final userDoc = await fakeFirestore.collection('usuarios').doc(uid).get();
      expect(userDoc.exists, isTrue);
      expect(userDoc.data()?['nome'], 'Maria Silva');
      expect(userDoc.data()?['email'], 'maria@email.com');
      expect(userDoc.data()?['endereco']['cidade'], 'Recife');

      // 3. Verificação de transição de tela para GenerosCadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      expect(find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'), findsOneWidget);

      // 4. Seleção de gêneros musicais (ativar 'Rock')
      final rockSwitch = find.descendant(
        of: find.widgetWithText(Card, 'Rock'),
        matching: find.byType(Switch),
      );
      await tester.ensureVisible(rockSwitch);
      await tester.tap(rockSwitch);
      await tester.pumpAndSettle();

      // 5. Confirmação dos gêneros
      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarBtn);
      await tester.tap(confirmarBtn);
      await tester.pumpAndSettle();

      // 6. Validação no Firestore da lista de gêneros salvos
      final userDocAtualizado = await fakeFirestore.collection('usuarios').doc(uid).get();
      final List<dynamic> generosSalvos = userDocAtualizado.data()?['generos_favoritos'];
      expect(generosSalvos, contains('Rock'));
      expect(generosSalvos.length, 1);
    });

    testWidgets('Cenário 2: Erros de validação do formulário bloqueiam envio ao Firebase',
        (WidgetTester tester) async {
      final fakeAuth = MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildAppWithScreen(
        screen: CadastroScreen(
          auth: fakeAuth,
          firestore: fakeFirestore,
        ),
      ));
      await tester.pumpAndSettle();

      // Clica em "Cadastrar" sem preencher nada
      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      // Validações esperadas na UI
      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);

      // Garante que nenhuma operação no Firebase foi disparada
      expect(fakeAuth.currentUser, isNull);
      final snapshot = await fakeFirestore.collection('usuarios').get();
      expect(snapshot.docs.isEmpty, isTrue);
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 3: Exibe SnackBar quando o Firebase Auth rejeita o cadastro',
        (WidgetTester tester) async {
      final failingAuth = FailingMockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildAppWithScreen(
        screen: CadastroScreen(
          auth: failingAuth,
          firestore: fakeFirestore,
        ),
      ));
      await tester.pumpAndSettle();

      // Preenche os campos obrigatórios com dados válidos no front
      await tester.enterText(find.byType(TextFormField).at(0), 'Carlos Silva');
      await tester.enterText(find.byType(TextFormField).at(1), '10051995');
      await tester.enterText(find.byType(TextFormField).at(2), 'existente@email.com');
      await tester.enterText(find.byType(TextFormField).at(3), '123456');
      await tester.enterText(find.byType(TextFormField).at(4), '123456');
      await tester.enterText(find.byType(TextFormField).at(5), '50000000');
      await tester.enterText(find.byType(TextFormField).at(7), '12');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      // Valida mensagem de SnackBar de erro
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Erro ao cadastrar: O endereço de e-mail já está em uso.'), findsOneWidget);

      // Não deve avançar de tela
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 4: Exibe aviso caso nenhum gênero seja selecionado',
        (WidgetTester tester) async {
      final fakeAuth = MockFirebaseAuth(signedIn: true);
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildAppWithScreen(
        screen: GenerosCadastroScreen(
          auth: fakeAuth,
          firestore: fakeFirestore,
        ),
      ));
      await tester.pumpAndSettle();

      // Clica direto em "Confirmar" sem marcar switches
      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarBtn);
      await tester.tap(confirmarBtn);
      await tester.pumpAndSettle();

      // Verifica SnackBar de obrigatoriedade
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Selecione pelo menos um gênero musical!'), findsOneWidget);
    });

    testWidgets('Cenário 5: Tratamento de erro quando Firestore falha ao salvar gêneros',
        (WidgetTester tester) async {
      // Mock de autenticação deslogado para forçar não atualização ou documento inexistente
      final emptyAuth = MockFirebaseAuth(signedIn: false);
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildAppWithScreen(
        screen: GenerosCadastroScreen(
          auth: emptyAuth,
          firestore: fakeFirestore,
        ),
      ));
      await tester.pumpAndSettle();

      // Seleciona um gênero
      final popSwitch = find.descendant(
        of: find.widgetWithText(Card, 'Pop'),
        matching: find.byType(Switch),
      );
      await tester.ensureVisible(popSwitch);
      await tester.tap(popSwitch);
      await tester.pumpAndSettle();

      // Clica em confirmar
      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarBtn);
      await tester.tap(confirmarBtn);
      await tester.pumpAndSettle();

      // Como o usuário é nulo, o método _salvarGeneros não executa a navegação
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
    });
  });
}

```
````

### Reparo 1

````markdown
### Classificação da Causa Provável da Falha

**Classificação: (B) O teste capturou comportamentos potencialmente incorretos da aplicação.**

---

### Diagnóstico Detalhado

O relatório de execução revelou falhas nos **Cenários 1 e 3**, causadas por problemas na implementação do código da aplicação:

---

#### 1. Falha no Cenário 1: Falta de Injeção de Dependências em `TelaInicialScreen` gerando `[core/no-app]`

* **Comportamento Observado:**
Ao concluir a seleção de gêneros em `GenerosCadastroScreen`, a tela invoca:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const TelaInicialScreen()),
);

```


Ao montar o estado da `TelaInicialScreen` (`initState` $\rightarrow$ `_loadLastRecommendedMusic` $\rightarrow$ `fetchLastRecommendedMusic`), o widget acessa diretamente `FirebaseAuth.instance` estaticamente (sem permitir injeção de dependência e sem verificar se o Firebase foi inicializado). Como o ambiente de teste de widgets não executa o app nativo nem chama `Firebase.initializeApp()`, o Flutter Framework lança a exceção:
```
[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()

```


* **Comportamento Esperado:**
Assim como `CadastroScreen` e `GenerosCadastroScreen` receberam os parâmetros opcionais `this.auth` e `this.firestore` para possibilitar testes de unidade e de integração, a `TelaInicialScreen` deveria permitir receber as instâncias de `auth` e `firestore` (ou um Service locator/Provider/InheritedWidget), repassando as instâncias mockadas através da navegação:
```dart
MaterialPageRoute(
  builder: (context) => TelaInicialScreen(
    auth: widget.auth,
    firestore: widget.firestore,
  ),
)

```


* **Por que é um problema da aplicação:**
A quebra do padrão de injeção de dependência na transição para a `TelaInicialScreen` cria um acoplamento direto e estático com o SDK nativo do Firebase. Isso inviabiliza o fluxo ponta a ponta sem recorrer à inicialização nativa do Firebase Platform Channels.

---

#### 2. Falha no Cenário 3: Validação Silenciosa Bloqueando a Submissão do Formulário

* **Comportamento Observado:**
O teste esperava a mensagem de erro do Firebase Auth em uma SnackBar:
```
Erro ao cadastrar: O endereço de e-mail já está em uso.

```


No entanto, o teste encontrou 0 widgets com esse texto, indicando que `_auth.createUserWithEmailAndPassword` sequer foi executado.
Analisando a validação em `CadastroScreen`:
```dart
void _submit() async {
  if (_formKey.currentState!.validate()) {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(...);

```


Para que `_formKey.currentState!.validate()` retorne `true`, **todos** os `FormFields` com validação precisam ser atendidos.
Na tela original, os seguintes validadores são definidos:
* `_validateDate` (Data de nascimento: formato, mês, dia máximo, ano, futuro)
* `_validateEmail` (E-mail com regex)
* Senha e Confirmação de senha
* `_validateCEP` (Regex `^\d{5}-\d{3}$`)
* `_validateNumero` (`int.tryParse(value) == null`)


No Cenário 3 anterior:
* O campo CEP recebeu `50000000`. O validador `_validateCEP` exige:
```dart
if (value.length != 9 || !RegExp(r'^\d{5}-\d{3}$').hasMatch(value)) {
  return 'CEP inválido. Formato correto: XXXXX-XXX';
}

```


Como foi digitado sem o hífen formatado (`50000000` em vez de `50000-000`), a validação síncrona interceptou o envio antes de chamar o `_auth`, e o formulário abortou a requisição em silêncio (exibindo apenas o erro sob o campo de texto, e não no SnackBar do Firebase).


Além disso, o formulário possui um bug estrutural na própria tela: a busca de CEP (`_fetchAddressFromCEP`) faz um `http.get` sem injeção de `Client`, disparando a requisição na rede real (gerando o `Warning: At least one test in this suite creates an HttpClient...`).

---

### Solução no Ambiente de Testes (Sem Modificar o Código de Produção)

Mantendo a integridade das asserções e sem flexibilizar as regras do teste:

1. **Para contornar o acoplamento do Firebase Core (`[core/no-app]` no Cenário 1):**
Podemos configurar a interface de plataforma do `firebase_core` em tempo de teste usando o canal de mock padrão da biblioteca de testes do Firebase (`setupFirebaseCoreMocks()` do `firebase_core_platform_interface` ou simulando a instância padrão antes do teste). Isso inicializa o `[DEFAULT]` app para que a `TelaInicialScreen` não quebre ao chamar `FirebaseAuth.instance`.
2. **Para o Cenário 3:**
Garantir que o valor inserido no campo de CEP passe pela validação do formato estrito exigido pelo formulário (`50000-000` ou usando o formatter), fazendo com que a validação passe e o `_auth` seja de fato chamado, testando a captura do `FirebaseAuthException`.

Abaixo está o arquivo de testes corrigido e configurado adequadamente:

```dart
// test/integration/cadastro_flow_cot_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

// Mock de FirebaseAuth que simula rejeição de credenciais por e-mail duplicado
class FailingMockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw FirebaseAuthException(
      code: 'email-already-in-use',
      message: 'O endereço de e-mail já está em uso.',
    );
  }
}

void main() {
  // Inicializa canais da plataforma do Firebase Core para testes em memória,
  // evitando o crash [core/no-app] ao carregar telas acopladas como TelaInicialScreen
  setupFirebaseCoreMocks();

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  Widget buildAppWithScreen({
    required Widget screen,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(1080, 2400)),
        child: screen,
      ),
    );
  }

  group('Fluxo de Cadastro e Seleção de Gêneros - Integração', () {
    testWidgets('Cenário 1: Fluxo de sucesso completo ponta a ponta', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuth = MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildAppWithScreen(
        screen: CadastroScreen(
          auth: fakeAuth,
          firestore: fakeFirestore,
        ),
      ));
      await tester.pumpAndSettle();

      // 1. Preenchimento de todos os campos com dados válidos
      await tester.enterText(find.byType(TextFormField).at(0), 'Maria Silva');
      await tester.enterText(find.byType(TextFormField).at(1), '15/10/1998');
      await tester.enterText(find.byType(TextFormField).at(2), 'maria@email.com');
      await tester.enterText(find.byType(TextFormField).at(3), 'senha123');
      await tester.enterText(find.byType(TextFormField).at(4), 'senha123');
      await tester.enterText(find.byType(TextFormField).at(5), '50000-000');
      await tester.enterText(find.byType(TextFormField).at(6), 'Rua Aurora');
      await tester.enterText(find.byType(TextFormField).at(7), '100');
      await tester.enterText(find.byType(TextFormField).at(8), 'Boa Vista');
      await tester.enterText(find.byType(TextFormField).at(9), 'Recife');

      // Seleção do Estado no Dropdown
      final estadoDropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(estadoDropdown);
      await tester.tap(estadoDropdown);
      await tester.pumpAndSettle();

      final estadoItem = find.text('PE').last;
      await tester.tap(estadoItem);
      await tester.pumpAndSettle();

      // Submissão do formulário
      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      // 2. Asserções do Firebase Auth e Firestore
      expect(fakeAuth.currentUser, isNotNull);
      final String uid = fakeAuth.currentUser!.uid;

      final userDoc = await fakeFirestore.collection('usuarios').doc(uid).get();
      expect(userDoc.exists, isTrue);
      expect(userDoc.data()?['nome'], 'Maria Silva');
      expect(userDoc.data()?['email'], 'maria@email.com');
      expect(userDoc.data()?['endereco']['cidade'], 'Recife');

      // 3. Verificação de transição de tela para GenerosCadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      expect(find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'), findsOneWidget);

      // 4. Seleção de gênero musical ('Rock')
      final rockSwitch = find.descendant(
        of: find.widgetWithText(Card, 'Rock'),
        matching: find.byType(Switch),
      );
      await tester.ensureVisible(rockSwitch);
      await tester.tap(rockSwitch);
      await tester.pumpAndSettle();

      // 5. Confirmação dos gêneros e transição
      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarBtn);
      await tester.tap(confirmarBtn);
      await tester.pumpAndSettle();

      // 6. Validação no Firestore
      final userDocAtualizado = await fakeFirestore.collection('usuarios').doc(uid).get();
      final List<dynamic> generosSalvos = userDocAtualizado.data()?['generos_favoritos'];
      expect(generosSalvos, contains('Rock'));
      expect(generosSalvos.length, 1);
    });

    testWidgets('Cenário 2: Erros de validação do formulário bloqueiam envio ao Firebase',
        (WidgetTester tester) async {
      final fakeAuth = MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildAppWithScreen(
        screen: CadastroScreen(
          auth: fakeAuth,
          firestore: fakeFirestore,
        ),
      ));
      await tester.pumpAndSettle();

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);

      expect(fakeAuth.currentUser, isNull);
      final snapshot = await fakeFirestore.collection('usuarios').get();
      expect(snapshot.docs.isEmpty, isTrue);
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 3: Exibe SnackBar quando o Firebase Auth rejeita o cadastro',
        (WidgetTester tester) async {
      final failingAuth = FailingMockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildAppWithScreen(
        screen: CadastroScreen(
          auth: failingAuth,
          firestore: fakeFirestore,
        ),
      ));
      await tester.pumpAndSettle();

      // Preenche rigorosamente todos os validadores síncronos para que a requisição
      // chegue de fato à camada de autenticação (_auth.createUserWithEmailAndPassword)
      await tester.enterText(find.byType(TextFormField).at(0), 'Carlos Silva');
      await tester.enterText(find.byType(TextFormField).at(1), '10/05/1995');
      await tester.enterText(find.byType(TextFormField).at(2), 'existente@email.com');
      await tester.enterText(find.byType(TextFormField).at(3), '123456');
      await tester.enterText(find.byType(TextFormField).at(4), '123456');
      await tester.enterText(find.byType(TextFormField).at(5), '50000-000'); // Formato XXXXX-XXX exigido pelo validador
      await tester.enterText(find.byType(TextFormField).at(6), 'Rua Principal');
      await tester.enterText(find.byType(TextFormField).at(7), '12'); // Numérico
      await tester.enterText(find.byType(TextFormField).at(8), 'Centro');
      await tester.enterText(find.byType(TextFormField).at(9), 'Recife');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      // A SnackBar agora deve ser encontrada com a mensagem original da exceção
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.textContaining('Erro ao cadastrar: O endereço de e-mail já está em uso.'),
        findsOneWidget,
      );

      // Garante que não transitou de tela após o erro
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 4: Exibe aviso caso nenhum gênero seja selecionado',
        (WidgetTester tester) async {
      final fakeAuth = MockFirebaseAuth(signedIn: true);
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildAppWithScreen(
        screen: GenerosCadastroScreen(
          auth: fakeAuth,
          firestore: fakeFirestore,
        ),
      ));
      await tester.pumpAndSettle();

      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarBtn);
      await tester.tap(confirmarBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Selecione pelo menos um gênero musical!'), findsOneWidget);
    });

    testWidgets('Cenário 5: Tratamento de erro quando Firestore falha ao salvar gêneros',
        (WidgetTester tester) async {
      final emptyAuth = MockFirebaseAuth(signedIn: false);
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildAppWithScreen(
        screen: GenerosCadastroScreen(
          auth: emptyAuth,
          firestore: fakeFirestore,
        ),
      ));
      await tester.pumpAndSettle();

      final popSwitch = find.descendant(
        of: find.widgetWithText(Card, 'Pop'),
        matching: find.byType(Switch),
      );
      await tester.ensureVisible(popSwitch);
      await tester.tap(popSwitch);
      await tester.pumpAndSettle();

      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarBtn);
      await tester.tap(confirmarBtn);
      await tester.pumpAndSettle();

      // Sem sessão de usuário válida, a tela permanece em GenerosCadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
    });
  });
}

```
````

### Reparo 2

````markdown
### Classificação da Causa Provável da Falha

**Classificação: (A) O teste presume um comportamento que não é o especificado.**

---

### Diagnóstico Detalhado

* **Causa do Erro:**
A função `setupFirebaseCoreMocks()` registra handlers de mensagens de plataforma nos canais binários (`TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger`). Para acessar o getter `instance`, o binding do Flutter precisa ter sido instanciado previamente.
No arquivo de teste anterior, `setupFirebaseCoreMocks()` foi chamada antes de `TestWidgetsFlutterBinding.ensureInitialized()`:
```dart
void main() {
  setupFirebaseCoreMocks(); // Erro: O binding ainda não foi inicializado!

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    ...
  });

```


* **Correção:**
Basta invocar `TestWidgetsFlutterBinding.ensureInitialized()` como a primeiríssima instrução dentro da função `main()`, logo antes de `setupFirebaseCoreMocks()`. Em seguida, no `setUpAll`, a inicialização do Firebase Core (`await Firebase.initializeApp()`) pode prosseguir com segurança.

---

### Código Completo Corrigido dos Testes

```dart
// test/fase2-gemini/integration/cadastro_flow_cot_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

// Mock de FirebaseAuth que simula rejeição de credenciais por e-mail duplicado
class FailingMockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw FirebaseAuthException(
      code: 'email-already-in-use',
      message: 'O endereço de e-mail já está em uso.',
    );
  }
}

void main() {
  // 1. O TestWidgetsFlutterBinding DEVE ser inicializado antes de qualquer mock de canal binário
  TestWidgetsFlutterBinding.ensureInitialized();

  // 2. Configura os handlers de plataforma do Firebase Core para testes em memória
  setupFirebaseCoreMocks();

  setUpAll(() async {
    // 3. Inicializa o Firebase App padrão para evitar o erro [core/no-app] ao navegar para telas como TelaInicialScreen
    await Firebase.initializeApp();
  });

  Widget buildAppWithScreen({
    required Widget screen,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(1080, 2400)),
        child: screen,
      ),
    );
  }

  group('Fluxo de Cadastro e Seleção de Gêneros - Integração', () {
    testWidgets('Cenário 1: Fluxo de sucesso completo ponta a ponta', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuth = MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildAppWithScreen(
        screen: CadastroScreen(
          auth: fakeAuth,
          firestore: fakeFirestore,
        ),
      ));
      await tester.pumpAndSettle();

      // 1. Preenchimento de todos os campos do formulário
      await tester.enterText(find.byType(TextFormField).at(0), 'Maria Silva');
      await tester.enterText(find.byType(TextFormField).at(1), '15/10/1998');
      await tester.enterText(find.byType(TextFormField).at(2), 'maria@email.com');
      await tester.enterText(find.byType(TextFormField).at(3), 'senha123');
      await tester.enterText(find.byType(TextFormField).at(4), 'senha123');
      await tester.enterText(find.byType(TextFormField).at(5), '50000-000');
      await tester.enterText(find.byType(TextFormField).at(6), 'Rua Aurora');
      await tester.enterText(find.byType(TextFormField).at(7), '100');
      await tester.enterText(find.byType(TextFormField).at(8), 'Boa Vista');
      await tester.enterText(find.byType(TextFormField).at(9), '**Classificação:** (A) o teste presume um comportamento que não é o especificado (especificamente, uma falha de setup do próprio ambiente de teste).

---

### Diagnóstico

O erro ocorreu na linha 32 do arquivo de teste (`cadastro_flow_cot_test.dart`), dentro do método `main()`, ao chamar `setupFirebaseCoreMocks()`. 

O pacote Firebase (via `TestDefaultBinaryMessengerBinding`) depende dos canais de plataforma (*platform channels*) do Flutter para registrar os mocks. No entanto, o motor de testes do Flutter (`flutter_test`) só inicializa o binding automaticamente quando entra no callback de um `testWidgets(...)`. Quando chamadas assíncronas ou configurações de mocks que utilizam canais de mensagens são executadas diretamente no corpo da função `main()` ou em um `setUpAll()`, a instância do binding ainda não existe, resultando na exceção:

```text
Binding has not yet been initialized.
The "instance" getter on the TestDefaultBinaryMessengerBinding binding mixin is only available once that binding has been initialized.

```

---

### Correção

Adicione `TestWidgetsFlutterBinding.ensureInitialized();` como a primeira instrução dentro do `main()` do seu arquivo de teste:

```dart
import 'package:flutter_test/flutter_test.dart';
// outros imports...

void main() {
  // Inicializa o binding de testes antes de configurar mocks ou canais de plataforma
  TestWidgetsFlutterBinding.ensureInitialized();

  // Chamada existente para mock do Firebase
  setupFirebaseCoreMocks();

  // Demais configurações e testes...
  testWidgets('Fluxo de cadastro...', (WidgetTester tester) async {
    // ...
  });
}

```
````

### Reparo 3

````markdown
### Classificação da Causa Provável da Falha

**Classificação: (A) o teste presume um comportamento que não é o especificado.**

---

### Diagnóstico Detalhado

O teste presumiu que a `SnackBar` de erro de autenticação do Firebase (`"Erro ao cadastrar: ..."`) seria exibida imediatamente após o clique no botão "Cadastrar", desconsiderando o funcionamento do `ScaffoldMessenger` e o efeito colateral do campo de CEP:

1. **Disparo do `onChanged` do CEP:**
Ao preencher o campo de CEP com 9 caracteres (`50000-000`), a função `onChanged` é executada e chama `_fetchAddressFromCEP('50000000')`.
2. **Falha de rede esperada no ambiente de testes:**
Como a requisição para o ViaCEP utiliza a biblioteca `http` diretamente e o ambiente de testes do Flutter bloqueia tráfego HTTP real (retornando status 400 por padrão), o bloco `else` de `_fetchAddressFromCEP` é acionado:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Erro ao buscar CEP')),
);

```


3. **Enfileiramento no `ScaffoldMessenger`:**
No Flutter, o `ScaffoldMessenger` exibe `SnackBar`s em uma **fila sequencial (FIFO)** com duração padrão de 4 segundos.
Quando o botão "Cadastrar" foi clicado em seguida, o erro do Firebase Auth foi disparado com sucesso e o código invocou `showSnackBar(SnackBar(content: Text("Erro ao cadastrar: ...")))`. No entanto, como a `SnackBar` anterior (`"Erro ao buscar CEP"`) ainda estava sendo apresentada na tela, a mensagem do Firebase ficou aguardando na fila e não chegou a ser montada na árvore de widgets no momento da asserção.

---

### Correção

Para que a `SnackBar` de autenticação seja renderizada e inspecionada pelo teste, basta dispensar as `SnackBar`s pendentes ou aguardar o tempo de exibição da `SnackBar` de CEP antes de acionar o botão "Cadastrar" (ou limpar a fila via `ScaffoldMessenger.clearSnackBars()`).

Abaixo está o código completo corrigido:

```dart
// test/fase2-gemini/integration/cadastro_flow_cot_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

// Mock de FirebaseAuth que simula rejeição de credenciais por e-mail duplicado
class FailingMockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw FirebaseAuthException(
      code: 'email-already-in-use',
      message: 'O endereço de e-mail já está em uso.',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  Widget buildAppWithScreen({
    required Widget screen,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(size: Size(1080, 2400)),
        child: screen,
      ),
    );
  }

  group('Fluxo de Cadastro e Seleção de Gêneros - Integração', () {
    testWidgets('Cenário 1: Fluxo de sucesso completo ponta a ponta', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeAuth = MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildAppWithScreen(
        screen: CadastroScreen(
          auth: fakeAuth,
          firestore: fakeFirestore,
        ),
      ));
      await tester.pumpAndSettle();

      // 1. Preenchimento de todos os campos do formulário
      await tester.enterText(find.byType(TextFormField).at(0), 'Maria Silva');
      await tester.enterText(find.byType(TextFormField).at(1), '15/10/1998');
      await tester.enterText(find.byType(TextFormField).at(2), 'maria@email.com');
      await tester.enterText(find.byType(TextFormField).at(3), 'senha123');
      await tester.enterText(find.byType(TextFormField).at(4), 'senha123');
      await tester.enterText(find.byType(TextFormField).at(5), '50000-000');
      await tester.enterText(find.byType(TextFormField).at(6), 'Rua Aurora');
      await tester.enterText(find.byType(TextFormField).at(7), '100');
      await tester.enterText(find.byType(TextFormField).at(8), 'Boa Vista');
      await tester.enterText(find.byType(TextFormField).at(9), 'Recife');

      // Seleção do Estado no Dropdown
      final estadoDropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(estadoDropdown);
      await tester.tap(estadoDropdown);
      await tester.pumpAndSettle();

      final estadoItem = find.text('PE').last;
      await tester.tap(estadoItem);
      await tester.pumpAndSettle();

      // Submissão do formulário
      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      // 2. Asserções do Firebase Auth e Firestore
      expect(fakeAuth.currentUser, isNotNull);
      final String uid = fakeAuth.currentUser!.uid;

      final userDoc = await fakeFirestore.collection('usuarios').doc(uid).get();
      expect(userDoc.exists, isTrue);
      expect(userDoc.data()?['nome'], 'Maria Silva');
      expect(userDoc.data()?['email'], 'maria@email.com');
      expect(userDoc.data()?['endereco']['cidade'], 'Recife');

      // 3. Verificação de transição de tela para GenerosCadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      expect(find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'), findsOneWidget);

      // 4. Seleção de gênero musical ('Rock')
      final rockSwitch = find.descendant(
        of: find.widgetWithText(Card, 'Rock'),
        matching: find.byType(Switch),
      );
      await tester.ensureVisible(rockSwitch);
      await tester.tap(rockSwitch);
      await tester.pumpAndSettle();

      // 5. Confirmação dos gêneros e transição
      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarBtn);
      await tester.tap(confirmarBtn);
      await tester.pumpAndSettle();

      // 6. Validação no Firestore
      final userDocAtualizado = await fakeFirestore.collection('usuarios').doc(uid).get();
      final List<dynamic> generosSalvos = userDocAtualizado.data()?['generos_favoritos'];
      expect(generosSalvos, contains('Rock'));
      expect(generosSalvos.length, 1);
    });

    testWidgets('Cenário 2: Erros de validação do formulário bloqueiam envio ao Firebase',
        (WidgetTester tester) async {
      final fakeAuth = MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildAppWithScreen(
        screen: CadastroScreen(
          auth: fakeAuth,
          firestore: fakeFirestore,
        ),
      ));
      await tester.pumpAndSettle();

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);

      expect(fakeAuth.currentUser, isNull);
      final snapshot = await fakeFirestore.collection('usuarios').get();
      expect(snapshot.docs.isEmpty, isTrue);
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 3: Exibe SnackBar quando o Firebase Auth rejeita o cadastro',
        (WidgetTester tester) async {
      final failingAuth = FailingMockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildAppWithScreen(
        screen: CadastroScreen(
          auth: failingAuth,
          firestore: fakeFirestore,
        ),
      ));
      await tester.pumpAndSettle();

      // Preenche os campos para que o formulário passe nas validações síncronas
      await tester.enterText(find.byType(TextFormField).at(0), 'Carlos Silva');
      await tester.enterText(find.byType(TextFormField).at(1), '10/05/1995');
      await tester.enterText(find.byType(TextFormField).at(2), 'existente@email.com');
      await tester.enterText(find.byType(TextFormField).at(3), '123456');
      await tester.enterText(find.byType(TextFormField).at(4), '123456');
      await tester.enterText(find.byType(TextFormField).at(5), '50000-000');
      await tester.enterText(find.byType(TextFormField).at(6), 'Rua Principal');
      await tester.enterText(find.byType(TextFormField).at(7), '12');
      await tester.enterText(find.byType(TextFormField).at(8), 'Centro');
      await tester.enterText(find.byType(TextFormField).at(9), 'Recife');

      // Limpa qualquer SnackBar gerada pela busca assíncrona de CEP no onChanged
      tester.state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger)).clearSnackBars();
      await tester.pump();

      // Clica em "Cadastrar"
      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      // Agora a SnackBar do erro de autenticação é a única exibida
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.textContaining('Erro ao cadastrar: O endereço de e-mail já está em uso.'),
        findsOneWidget,
      );

      // Garante que permaneceu na tela de cadastro
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 4: Exibe aviso caso nenhum gênero seja selecionado',
        (WidgetTester tester) async {
      final fakeAuth = MockFirebaseAuth(signedIn: true);
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildAppWithScreen(
        screen: GenerosCadastroScreen(
          auth: fakeAuth,
          firestore: fakeFirestore,
        ),
      ));
      await tester.pumpAndSettle();

      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarBtn);
      await tester.tap(confirmarBtn);
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Selecione pelo menos um gênero musical!'), findsOneWidget);
    });

    testWidgets('Cenário 5: Tratamento de erro quando Firestore falha ao salvar gêneros',
        (WidgetTester tester) async {
      final emptyAuth = MockFirebaseAuth(signedIn: false);
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(buildAppWithScreen(
        screen: GenerosCadastroScreen(
          auth: emptyAuth,
          firestore: fakeFirestore,
        ),
      ));
      await tester.pumpAndSettle();

      final popSwitch = find.descendant(
        of: find.widgetWithText(Card, 'Pop'),
        matching: find.byType(Switch),
      );
      await tester.ensureVisible(popSwitch);
      await tester.tap(popSwitch);
      await tester.pumpAndSettle();

      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarBtn);
      await tester.tap(confirmarBtn);
      await tester.pumpAndSettle();

      // Sem sessão de usuário válida, a tela não transiciona
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
    });
  });
}

```
````
