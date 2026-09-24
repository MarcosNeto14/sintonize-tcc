# FASE2-INT-ZS-02_cadastroFlow — Réplica Gemini

Rodada **55/60**. Bloco 3 (integração), lote 13 (`cadastroFlow`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-INT-ZS-02_cadastroFlow |
| **Função/tela alvo** | fluxo de cadastro — `CadastroScreen` → `GenerosCadastroScreen` |
| **Arquivo(s) de origem** | `lib/cadastro.dart`, `lib/generos-cadastro.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Pílula do seletor conferida a cada envio: `Flash` (não `Flash-Lite`). |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/fa76cda26923b1b7` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos`, alvo limpo. **I-CRASH verificado revertido** antes da rodada: `lib/generos-cadastro.dart:44-46` tem `final user = _auth.currentUser;` seguido da guarda `if (user != null)`, sem `currentUser!.uid` |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 · DevTools 2.54.2 |
| **Arquivo de teste** | `test/fase2-gemini/integration/cadastro_flow_zs_test.dart` (sem `.mocks.dart` — mocks manuais) |
| **Saídas arquivadas** | `resultados/integration/FASE2-INT-ZS-02_{iter0,iter1,iter2,iter3_final}.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/integration/zero-shot/FASE2-INT-ZS-02_cadastroFlow.md`, sem alteração |

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
| **Compilou na 1ª execução?** | **Não** (`anyNamed(...)` resolve para `Null` sob null safety) |
| **Testes gerados** | 4 |
| **Testes passaram (1ª execução válida, iteração 1)** | **2/4** |
| **Testes passaram (iteração 2)** | **2/4** (mesmas duas falhas) |
| **Testes passaram (final, iteração 3)** | **0** — o arquivo **não compila** |
| **Iterações de reparo** | 3 (máximo) |
| **Tentativas de envio até obter resposta** | 1 (nenhuma recusa) |
| **Autoclassificação** | (A); (A); (A) — corretas nas iterações 0→1 e 1→2; **a da iteração 3 erra o alvo**, ver observação 2 |

---

## Iterative Repair Loop

| Iteração | Envio | Resposta | Classificação | Resultado |
|---|---|---|---|---|
| 0 (geração) | automação | arquivo completo, 4 `testWidgets`, `firebase_auth_mocks` + `fake_cloud_firestore` + mock manual | — | **não compila** — `anyNamed('email')` / `anyNamed('password')` resolvem para `Null` (linhas 155-156) |
| 1 | automação, mesma conversa | arquivo completo | **(A)**, correta | **compila** — **2/4** |
| 2 | automação, mesma conversa | arquivo completo | **(A)**, correta | **2/4**, exatamente as mesmas duas falhas — a iteração não mudou nada de efetivo |
| 3 | automação, mesma conversa | arquivo completo; introduz `setupFirebaseCoreMocks()` para atacar o `[core/no-app]` | **(A)** | **não compila (final)** — `Method not found: 'setupFirebaseCoreMocks'`, o símbolo não foi importado |

### As 2 falhas persistentes (iterações 1 e 2)

| Teste | Erro |
|---|---|
| deve completar o fluxo de cadastro e salvar gêneros favoritos no Firestore | `[core/no-app]` — `_TelaInicialScreenState.fetchLastRecommendedMusic` (`tela-inicial.dart:43`) |
| deve exibir SnackBar de erro caso o Firebase Auth falhe no cadastro | `Found 0 widgets with text "Erro ao cadastrar: O e-mail já está cadastrado."` |

---

## Observações

1. **A parede é a mesma do lote 12.** A primeira falha é, de novo, `TelaInicialScreen` acessando `FirebaseAuth.instance` no `initState` — agora alcançada pelo fluxo de cadastro, que também termina nela. Quarta rodada de integração seguida a esbarrar no mesmo ponto.
2. **Erro de estratégia idêntico ao da rodada 54, e com o mesmo desfecho.** Na iteração 3 o modelo tenta neutralizar o `[core/no-app]` com `setupFirebaseCoreMocks()` e esquece o import — exatamente o que fez na rodada 54, iteração 1. Lá ele levou três iterações descendo esse caminho até o arquivo parar de carregar; aqui gastou a última e o arquivo parou de compilar. A classificação (A) não está errada quanto à natureza do erro final, mas o alvo escolhido para reparar é a limitação da aplicação, que nenhuma mudança no teste resolve.
3. **A iteração 2 foi desperdiçada.** Entregou arquivo completo novo e o resultado é bit a bit o mesmo: 2/4, as mesmas duas falhas. O modelo reescreveu sem mudar nada de efetivo.
4. **Melhor estado da rodada: 2/4, nas iterações 1 e 2.** O estado final arquivado é o da iteração 3, que não compila. Sem reversão, pelo mesmo critério da rodada 54: o precedente da Fase 2 (`INT-FS-01`) exige regressão reconhecida pelo modelo e proposta fora de escopo, e nenhuma das duas ocorreu.
5. **A limitação do `viacep` prevista nas notas de protocolo não apareceu.** O prompt antecipava que o modelo esbarraria na requisição HTTP real do campo CEP, sem ponto de injeção. O teste dispara o aviso do `flutter_test` sobre `HttpClient` (todas as requisições retornam 400), mas nenhuma das 4 falhas vem daí — o modelo simplesmente não testou o preenchimento automático por CEP.
6. **Comparação com o ChatGPT na mesma rodada:** ChatGPT gerou 3 testes e fechou em **1/3**, também com 3 iterações. Gemini gerou 4, chegou a 2/4 e terminou sem compilar. Nos dois casos o fluxo completo até o Firestore falha; o ChatGPT preservou um resultado executável no fim, o Gemini não.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
Aqui está o arquivo de teste de integração completo utilizando `flutter_test`, `firebase_auth_mocks` e `fake_cloud_firestore`.

Como a `CadastroScreen` possui validações de formulário (incluindo validação de data, CEP, número e estado via Dropdown) e scroll view, o teste realiza as interações com `ensureVisible` e preenchimento dos devidos campos para simular o fluxo real do usuário ponta a ponta.

### `test/integration/cadastro_generos_flow_test.dart`

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

// Mock criado com Mockito para simular falhas específicas no FirebaseAuth
class MockFailingFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Integração: Cadastro -> Gêneros Musicais', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
    });

    Widget createWidgetUnderTest({
      FirebaseAuth? auth,
      FakeFirebaseFirestore? firestore,
    }) {
      return MaterialApp(
        home: CadastroScreen(
          auth: auth ?? mockAuth,
          firestore: firestore ?? fakeFirestore,
        ),
      );
    }

    testWidgets(
      'deve completar o fluxo de cadastro e salvar gêneros favoritos no Firestore',
      (WidgetTester tester) async {
        // Define resolução de tela para evitar estouro de layout durante os testes
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // 1. Identificar e preencher campos do formulário na CadastroScreen
        // Os TextFormFields aparecem na ordem definida na tela:
        // [0] Nome, [1] Data Nasc, [2] Email, [3] Senha, [4] Conf Senha, [5] CEP, [6] Rua, [7] Número, [8] Bairro, [9] Cidade
        final textFields = find.byType(TextFormField);
        expect(textFields, findsNWidgets(10));

        await tester.enterText(textFields.at(0), 'Fulano da Silva');
        await tester.enterText(textFields.at(1), '15051995'); // Formatador insere as barras
        await tester.enterText(textFields.at(2), 'fulano@teste.com');
        await tester.enterText(textFields.at(3), '123456');
        await tester.enterText(textFields.at(4), '123456');
        await tester.enterText(textFields.at(5), '50000000'); // Formatador insere o hífen

        // Garante que o scroll alcance os campos de endereço
        await tester.ensureVisible(textFields.at(6));
        await tester.enterText(textFields.at(6), 'Rua das Flores');
        await tester.enterText(textFields.at(7), '123');
        await tester.enterText(textFields.at(8), 'Centro');
        await tester.enterText(textFields.at(9), 'Recife');

        // Selecionar o Estado no DropdownButtonFormField
        final dropdownFinder = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdownFinder);
        await tester.tap(dropdownFinder);
        await tester.pumpAndSettle();

        // Tocar na opção 'PE' dentro do menu aberto
        final dropdownItem = find.text('PE').last;
        await tester.tap(dropdownItem);
        await tester.pumpAndSettle();

        // Tocar no botão 'Cadastrar'
        final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarButton);
        await tester.tap(cadastrarButton);
        await tester.pumpAndSettle();

        // 2. Verificar se o usuário foi autenticado no Firebase Auth
        expect(mockAuth.currentUser, isNotNull);
        final String uid = mockAuth.currentUser!.uid;
        expect(mockAuth.currentUser!.email, 'fulano@teste.com');

        // 3. Validar se o documento do usuário foi salvo no Firestore
        final userDocSnapshot =
            await fakeFirestore.collection('usuarios').doc(uid).get();
        expect(userDocSnapshot.exists, isTrue);
        expect(userDocSnapshot.data()!['nome'], 'Fulano da Silva');
        expect(userDocSnapshot.data()!['email'], 'fulano@teste.com');
        expect(userDocSnapshot.data()!['endereco']['cidade'], 'Recife');
        expect(userDocSnapshot.data()!['endereco']['estado'], 'PE');

        // 4. Verificar que navegou para GenerosCadastroScreen
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);
        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsOneWidget,
        );

        // 5. Interagir com os switches de seleção de gênero
        // Os gêneros disponíveis são: Rock, Pop, Jazz, Blues, Hip-Hop, Reggae, Country
        final rockRowFinder = find.ancestor(
          of: find.text('Rock'),
          matching: find.byType(Row),
        );
        final popRowFinder = find.ancestor(
          of: find.text('Pop'),
          matching: find.byType(Row),
        );

        final rockSwitch = find.descendant(
          of: rockRowFinder,
          matching: find.byType(Switch),
        );
        final popSwitch = find.descendant(
          of: popRowFinder,
          matching: find.byType(Switch),
        );

        await tester.tap(rockSwitch);
        await tester.pumpAndSettle();
        await tester.tap(popSwitch);
        await tester.pumpAndSettle();

        // 6. Tocar em "Confirmar"
        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);
        await tester.pumpAndSettle();

        // 7. Verificar se os gêneros foram salvos no Firestore
        final updatedDocSnapshot =
            await fakeFirestore.collection('usuarios').doc(uid).get();
        final List<dynamic> generosSalvos =
            updatedDocSnapshot.data()!['generos_favoritos'];

        expect(generosSalvos, containsAll(['Rock', 'Pop']));
        expect(generosSalvos.length, 2);
      },
    );

    testWidgets(
      'deve exibir SnackBar de erro caso o Firebase Auth falhe no cadastro',
      (WidgetTester tester) async {
        final failingAuth = MockFailingFirebaseAuth();
        when(
          failingAuth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'O e-mail já está cadastrado.',
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            auth: failingAuth,
            firestore: fakeFirestore,
          ),
        );
        await tester.pumpAndSettle();

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'Maria Oliveira');
        await tester.enterText(textFields.at(1), '10101990');
        await tester.enterText(textFields.at(2), 'maria@teste.com');
        await tester.enterText(textFields.at(3), '123456');
        await tester.enterText(textFields.at(4), '123456');
        await tester.enterText(textFields.at(5), '50000000');

        await tester.ensureVisible(textFields.at(6));
        await tester.enterText(textFields.at(6), 'Rua Principal');
        await tester.enterText(textFields.at(7), '456');
        await tester.enterText(textFields.at(8), 'Boa Viagem');
        await tester.enterText(textFields.at(9), 'Recife');

        final dropdownFinder = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdownFinder);
        await tester.tap(dropdownFinder);
        await tester.pumpAndSettle();

        await tester.tap(find.text('PE').last);
        await tester.pumpAndSettle();

        final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarButton);
        await tester.tap(cadastrarButton);
        await tester.pumpAndSettle();

        // Deve exibir SnackBar com a mensagem de erro do Firebase Auth
        expect(
          find.text('Erro ao cadastrar: O e-mail já está cadastrado.'),
          findsOneWidget,
        );

        // Não deve navegar para a tela seguinte
        expect(find.byType(GenerosCadastroScreen), findsNothing);
      },
    );

    testWidgets(
      'deve exibir SnackBar se o usuário tentar confirmar sem selecionar nenhum gênero musical',
      (WidgetTester tester) async {
        // Usuário já autenticado
        final authMock = MockFirebaseAuth(signedIn: true);

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: authMock,
              firestore: fakeFirestore,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tenta confirmar diretamente sem ligar nenhum Switch
        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);
        await tester.pumpAndSettle();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'não deve salvar gêneros caso currentUser seja nulo',
      (WidgetTester tester) async {
        // Auth mock com usuário deslogado (currentUser == null)
        final unauthenticatedAuth = MockFirebaseAuth(signedIn: false);

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: unauthenticatedAuth,
              firestore: fakeFirestore,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Seleciona um gênero
        final jazzRowFinder = find.ancestor(
          of: find.text('Jazz'),
          matching: find.byType(Row),
        );
        final jazzSwitch = find.descendant(
          of: jazzRowFinder,
          matching: find.byType(Switch),
        );
        await tester.tap(jazzSwitch);
        await tester.pumpAndSettle();

        // Clica em confirmar
        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);
        await tester.pumpAndSettle();

        // Verifica que nenhuma coleção foi gravada
        final usuariosDocs = await fakeFirestore.collection('usuarios').get();
        expect(usuariosDocs.docs.isEmpty, isTrue);
      },
    );
  });
}

```

### Como executar:

Execute no terminal na raiz do projeto:

```bash
flutter test test/integration/cadastro_generos_flow_test.dart

```
````

### Reparo 1

````markdown
**Classificação da causa provável da falha:**
**(A) O teste presume um comportamento que não é o especificado.**

---

### Diagnóstico

O erro ocorreu durante a fase de compilação do teste e decorre de uma limitação técnica do Mockito com o sistema de **Null Safety** do Dart.

No Dart com Sound Null Safety, o método `createUserWithEmailAndPassword({required String email, required String password})` exige argumentos não-nulos (`String` e não `String?`). A chamada `anyNamed('email')` sem geração de código pelo `build_runner` (ou sem os argumentos específicos de fallback do Mockito) retorna `null`, o que gera a incompatibilidade de tipos em tempo de compilação: `The argument type 'Null' can't be assigned to the parameter type 'String'`.

Como o objetivo desse teste é apenas disparar uma exceção de simulação (`FirebaseAuthException`) quando o método for invocado, podemos:

1. Passar os valores exatos esperados no formulário (`'maria@teste.com'` e `'123456'`) em vez de `anyNamed(...)`; ou
2. Criar uma subclasse direta / Fake que sobrescreve o método e lança a exceção sem depender dos matchers do Mockito.

A abordagem mais limpa, robusta e compatível com Null Safety sem necessidade de rodar `build_runner` é definir uma classe `FailingAuth` simples ou passar os valores esperados.

---

### Código Corrigido

Substitua o arquivo de teste pelo código abaixo:

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

// Fake customizado que lança exceção para evitar problemas de Null Safety do Mockito
class FailingFirebaseAuth extends Fake implements FirebaseAuth {
  final FirebaseAuthException exceptionToThrow;

  FailingFirebaseAuth(this.exceptionToThrow);

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw exceptionToThrow;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Integração: Cadastro -> Gêneros Musicais', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
    });

    Widget createWidgetUnderTest({
      FirebaseAuth? auth,
      FakeFirebaseFirestore? firestore,
    }) {
      return MaterialApp(
        home: CadastroScreen(
          auth: auth ?? mockAuth,
          firestore: firestore ?? fakeFirestore,
        ),
      );
    }

    testWidgets(
      'deve completar o fluxo de cadastro e salvar gêneros favoritos no Firestore',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Preenchimento dos 10 campos de texto do formulário
        final textFields = find.byType(TextFormField);
        expect(textFields, findsNWidgets(10));

        await tester.enterText(textFields.at(0), 'Fulano da Silva');
        await tester.enterText(textFields.at(1), '15051995');
        await tester.enterText(textFields.at(2), 'fulano@teste.com');
        await tester.enterText(textFields.at(3), '123456');
        await tester.enterText(textFields.at(4), '123456');
        await tester.enterText(textFields.at(5), '50000000');

        await tester.ensureVisible(textFields.at(6));
        await tester.enterText(textFields.at(6), 'Rua das Flores');
        await tester.enterText(textFields.at(7), '123');
        await tester.enterText(textFields.at(8), 'Centro');
        await tester.enterText(textFields.at(9), 'Recife');

        // Seleciona Estado
        final dropdownFinder = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdownFinder);
        await tester.tap(dropdownFinder);
        await tester.pumpAndSettle();

        final dropdownItem = find.text('PE').last;
        await tester.tap(dropdownItem);
        await tester.pumpAndSettle();

        // Submete cadastro
        final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarButton);
        await tester.tap(cadastrarButton);
        await tester.pumpAndSettle();

        // Valida usuário criado no Auth
        expect(mockAuth.currentUser, isNotNull);
        final String uid = mockAuth.currentUser!.uid;
        expect(mockAuth.currentUser!.email, 'fulano@teste.com');

        // Valida dados salvos no Firestore
        final userDocSnapshot =
            await fakeFirestore.collection('usuarios').doc(uid).get();
        expect(userDocSnapshot.exists, isTrue);
        expect(userDocSnapshot.data()!['nome'], 'Fulano da Silva');
        expect(userDocSnapshot.data()!['email'], 'fulano@teste.com');
        expect(userDocSnapshot.data()!['endereco']['cidade'], 'Recife');
        expect(userDocSnapshot.data()!['endereco']['estado'], 'PE');

        // Valida transição para GenerosCadastroScreen
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);
        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsOneWidget,
        );

        // Seleciona gêneros
        final rockRowFinder = find.ancestor(
          of: find.text('Rock'),
          matching: find.byType(Row),
        );
        final popRowFinder = find.ancestor(
          of: find.text('Pop'),
          matching: find.byType(Row),
        );

        final rockSwitch = find.descendant(
          of: rockRowFinder,
          matching: find.byType(Switch),
        );
        final popSwitch = find.descendant(
          of: popRowFinder,
          matching: find.byType(Switch),
        );

        await tester.tap(rockSwitch);
        await tester.pumpAndSettle();
        await tester.tap(popSwitch);
        await tester.pumpAndSettle();

        // Confirma seleção
        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);
        await tester.pumpAndSettle();

        // Valida atualização dos gêneros favoritos no documento do usuário
        final updatedDocSnapshot =
            await fakeFirestore.collection('usuarios').doc(uid).get();
        final List<dynamic> generosSalvos =
            updatedDocSnapshot.data()!['generos_favoritos'];

        expect(generosSalvos, containsAll(['Rock', 'Pop']));
        expect(generosSalvos.length, 2);
      },
    );

    testWidgets(
      'deve exibir SnackBar de erro caso o Firebase Auth falhe no cadastro',
      (WidgetTester tester) async {
        final failingAuth = FailingFirebaseAuth(
          FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'O e-mail já está cadastrado.',
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            auth: failingAuth,
            firestore: fakeFirestore,
          ),
        );
        await tester.pumpAndSettle();

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'Maria Oliveira');
        await tester.enterText(textFields.at(1), '10101990');
        await tester.enterText(textFields.at(2), 'maria@teste.com');
        await tester.enterText(textFields.at(3), '123456');
        await tester.enterText(textFields.at(4), '123456');
        await tester.enterText(textFields.at(5), '50000000');

        await tester.ensureVisible(textFields.at(6));
        await tester.enterText(textFields.at(6), 'Rua Principal');
        await tester.enterText(textFields.at(7), '456');
        await tester.enterText(textFields.at(8), 'Boa Viagem');
        await tester.enterText(textFields.at(9), 'Recife');

        final dropdownFinder = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdownFinder);
        await tester.tap(dropdownFinder);
        await tester.pumpAndSettle();

        await tester.tap(find.text('PE').last);
        await tester.pumpAndSettle();

        final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarButton);
        await tester.tap(cadastrarButton);
        await tester.pumpAndSettle();

        // Verifica que a SnackBar com o erro foi exibida
        expect(
          find.text('Erro ao cadastrar: O e-mail já está cadastrado.'),
          findsOneWidget,
        );

        // Garante que não houve navegação
        expect(find.byType(GenerosCadastroScreen), findsNothing);
      },
    );

    testWidgets(
      'deve exibir SnackBar se o usuário tentar confirmar sem selecionar nenhum gênero musical',
      (WidgetTester tester) async {
        final authMock = MockFirebaseAuth(signedIn: true);

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: authMock,
              firestore: fakeFirestore,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);
        await tester.pumpAndSettle();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'não deve salvar gêneros caso currentUser seja nulo',
      (WidgetTester tester) async {
        final unauthenticatedAuth = MockFirebaseAuth(signedIn: false);

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: unauthenticatedAuth,
              firestore: fakeFirestore,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final jazzRowFinder = find.ancestor(
          of: find.text('Jazz'),
          matching: find.byType(Row),
        );
        final jazzSwitch = find.descendant(
          of: jazzRowFinder,
          matching: find.byType(Switch),
        );
        await tester.tap(jazzSwitch);
        await tester.pumpAndSettle();

        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);
        await tester.pumpAndSettle();

        final usuariosDocs = await fakeFirestore.collection('usuarios').get();
        expect(usuariosDocs.docs.isEmpty, isTrue);
      },
    );
  });
}

```
````

### Reparo 2

````markdown
**Classificação da causa provável da falha:**
**(A) o teste presume um comportamento que não é o especificado**

---

### Diagnóstico

Foram identificadas duas falhas distintas causadas por suposições incorretas do ambiente de teste e das interações na árvore de widgets:

1. **Falha 1 (`[core/no-app] No Firebase App '[DEFAULT]' has been created`):**
* Ao tocar em "Confirmar" na `GenerosCadastroScreen`, a tela salva os dados e executa:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const TelaInicialScreen()),
);

```


* Ao chamar `tester.pumpAndSettle()`, o Flutter monta `TelaInicialScreen`, cujo `initState()` invoca diretamente `FirebaseAuth.instance` sem injeção de dependência (`tela-inicial.dart:43:31`), disparando uma exceção porque o Firebase Core nativo não foi inicializado no ambiente de testes headless do `flutter_test`.
* O teste fez `tester.pumpAndSettle()`, que aguarda todas as rotas e animações terminarem, provocando a montagem completa de `TelaInicialScreen`. Em testes de widget/integração de fluxo onde a tela de destino seguinte acessa instâncias estáticas nativas, devemos bombear frames suficientes para concluir a chamada assíncrona do Firestore na tela sob teste (`GenerosCadastroScreen`) sem tentar assentar a inicialização de telas de terceiros que dependem de plugins de plataforma não mockados, ou mockar o canal do `firebase_core`.


2. **Falha 2 (`Bad state: No element` no Dropdown):**
* No segundo teste (`deve exibir SnackBar de erro caso o Firebase Auth falhe no cadastro`), ao buscar `find.text('PE').last`, nenhum elemento foi encontrado porque a lista do `DropdownButtonFormField` não rolou até a sigla "PE" ou o popup não renderizou o item na viewport.
* Além disso, para preencher o formulário na `CadastroScreen`, **o campo de estado é opcional na validação** do formulário (`_estadoSelecionado` não possui validação no `validator`), logo a interação com o Dropdown é desnecessária para testar a falha de autenticação do Firebase Auth, ou pode-se selecionar um estado visível logo no topo da lista (ex: `'AC'`).



---

### Código Corrigido

Abaixo está o arquivo ajustado:

* No primeiro teste, usamos `tester.pump()` / `tester.pump(const Duration(milliseconds: 500))` após o toque em "Confirmar" para permitir que a operação `_salvarGeneros()` do Firestore finalize e seja validada, sem estourar o ciclo de vida nativo de `TelaInicialScreen`.
* No teste de falha de autenticação, selecionamos `'AC'` (que é o primeiro item da lista e sempre está visível na abertura do Dropdown) e usamos `ensureVisible` antes de tocar no botão 'Cadastrar'.

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

// Fake customizado para simular falhas no FirebaseAuth
class FailingFirebaseAuth extends Fake implements FirebaseAuth {
  final FirebaseAuthException exceptionToThrow;

  FailingFirebaseAuth(this.exceptionToThrow);

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw exceptionToThrow;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Integração: Cadastro -> Gêneros Musicais', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
    });

    Widget createWidgetUnderTest({
      FirebaseAuth? auth,
      FakeFirebaseFirestore? firestore,
    }) {
      return MaterialApp(
        home: CadastroScreen(
          auth: auth ?? mockAuth,
          firestore: firestore ?? fakeFirestore,
        ),
      );
    }

    testWidgets(
      'deve completar o fluxo de cadastro e salvar gêneros favoritos no Firestore',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // 1. Preenchimento dos campos da CadastroScreen
        final textFields = find.byType(TextFormField);
        expect(textFields, findsNWidgets(10));

        await tester.enterText(textFields.at(0), 'Fulano da Silva');
        await tester.enterText(textFields.at(1), '15051995');
        await tester.enterText(textFields.at(2), 'fulano@teste.com');
        await tester.enterText(textFields.at(3), '123456');
        await tester.enterText(textFields.at(4), '123456');
        await tester.enterText(textFields.at(5), '50000000');

        await tester.ensureVisible(textFields.at(6));
        await tester.enterText(textFields.at(6), 'Rua das Flores');
        await tester.enterText(textFields.at(7), '123');
        await tester.enterText(textFields.at(8), 'Centro');
        await tester.enterText(textFields.at(9), 'Recife');

        // Seleciona Estado: seleciona 'AC' (primeiro item visível)
        final dropdownFinder = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdownFinder);
        await tester.tap(dropdownFinder);
        await tester.pumpAndSettle();

        final dropdownItem = find.text('AC').last;
        await tester.tap(dropdownItem);
        await tester.pumpAndSettle();

        // Submete cadastro
        final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarButton);
        await tester.tap(cadastrarButton);
        await tester.pumpAndSettle();

        // 2. Valida usuário no Firebase Auth
        expect(mockAuth.currentUser, isNotNull);
        final String uid = mockAuth.currentUser!.uid;
        expect(mockAuth.currentUser!.email, 'fulano@teste.com');

        // 3. Valida dados no Firestore
        final userDocSnapshot =
            await fakeFirestore.collection('usuarios').doc(uid).get();
        expect(userDocSnapshot.exists, isTrue);
        expect(userDocSnapshot.data()!['nome'], 'Fulano da Silva');
        expect(userDocSnapshot.data()!['email'], 'fulano@teste.com');
        expect(userDocSnapshot.data()!['endereco']['cidade'], 'Recife');
        expect(userDocSnapshot.data()!['endereco']['estado'], 'AC');

        // 4. Valida transição para GenerosCadastroScreen
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);
        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsOneWidget,
        );

        // 5. Seleciona os gêneros
        final rockRowFinder = find.ancestor(
          of: find.text('Rock'),
          matching: find.byType(Row),
        );
        final popRowFinder = find.ancestor(
          of: find.text('Pop'),
          matching: find.byType(Row),
        );

        final rockSwitch = find.descendant(
          of: rockRowFinder,
          matching: find.byType(Switch),
        );
        final popSwitch = find.descendant(
          of: popRowFinder,
          matching: find.byType(Switch),
        );

        await tester.tap(rockSwitch);
        await tester.pumpAndSettle();
        await tester.tap(popSwitch);
        await tester.pumpAndSettle();

        // 6. Toca no botão "Confirmar"
        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);

        // Aguarda a execução assíncrona do Firestore na GenerosCadastroScreen
        // sem chamar pumpAndSettle para evitar montar TelaInicialScreen (que chama FirebaseAuth.instance nativo)
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // 7. Valida se os gêneros foram salvos no Firestore
        final updatedDocSnapshot =
            await fakeFirestore.collection('usuarios').doc(uid).get();
        final List<dynamic> generosSalvos =
            updatedDocSnapshot.data()!['generos_favoritos'];

        expect(generosSalvos, containsAll(['Rock', 'Pop']));
        expect(generosSalvos.length, 2);
      },
    );

    testWidgets(
      'deve exibir SnackBar de erro caso o Firebase Auth falhe no cadastro',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final failingAuth = FailingFirebaseAuth(
          FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'O e-mail já está cadastrado.',
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            auth: failingAuth,
            firestore: fakeFirestore,
          ),
        );
        await tester.pumpAndSettle();

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'Maria Oliveira');
        await tester.enterText(textFields.at(1), '10101990');
        await tester.enterText(textFields.at(2), 'maria@teste.com');
        await tester.enterText(textFields.at(3), '123456');
        await tester.enterText(textFields.at(4), '123456');
        await tester.enterText(textFields.at(5), '50000000');

        await tester.ensureVisible(textFields.at(6));
        await tester.enterText(textFields.at(6), 'Rua Principal');
        await tester.enterText(textFields.at(7), '456');
        await tester.enterText(textFields.at(8), 'Boa Viagem');
        await tester.enterText(textFields.at(9), 'Recife');

        final dropdownFinder = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdownFinder);
        await tester.tap(dropdownFinder);
        await tester.pumpAndSettle();

        final dropdownItem = find.text('AC').last;
        await tester.tap(dropdownItem);
        await tester.pumpAndSettle();

        final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarButton);
        await tester.tap(cadastrarButton);
        await tester.pumpAndSettle();

        // Verifica que a SnackBar com o erro foi exibida
        expect(
          find.text('Erro ao cadastrar: O e-mail já está cadastrado.'),
          findsOneWidget,
        );

        // Garante que não navegou para a próxima tela
        expect(find.byType(GenerosCadastroScreen), findsNothing);
      },
    );

    testWidgets(
      'deve exibir SnackBar se o usuário tentar confirmar sem selecionar nenhum gênero musical',
      (WidgetTester tester) async {
        final authMock = MockFirebaseAuth(signedIn: true);

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: authMock,
              firestore: fakeFirestore,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);
        await tester.pumpAndSettle();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'não deve salvar gêneros caso currentUser seja nulo',
      (WidgetTester tester) async {
        final unauthenticatedAuth = MockFirebaseAuth(signedIn: false);

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: unauthenticatedAuth,
              firestore: fakeFirestore,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final jazzRowFinder = find.ancestor(
          of: find.text('Jazz'),
          matching: find.byType(Row),
        );
        final jazzSwitch = find.descendant(
          of: jazzRowFinder,
          matching: find.byType(Switch),
        );
        await tester.tap(jazzSwitch);
        await tester.pumpAndSettle();

        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);
        await tester.pumpAndSettle();

        final usuariosDocs = await fakeFirestore.collection('usuarios').get();
        expect(usuariosDocs.docs.isEmpty, isTrue);
      },
    );
  });
}

```
````

### Reparo 3

````markdown
**Classificação da causa provável da falha:**
**(A) o teste presume um comportamento que não é o especificado**

---

### Diagnóstico

As duas falhas decorrem de suposições erradas sobre como o ambiente de teste lida com o ciclo de vida do Flutter e canais de plataforma:

1. **Falha 1 (`[core/no-app] No Firebase App '[DEFAULT]' has been created`):**
* Na linha `_salvarGeneros()`, o código faz:
```dart
await _firestore.collection('usuarios').doc(user.uid).update({...});
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const TelaInicialScreen()),
);

```


* Mesmo chamando `tester.pump(const Duration(milliseconds: 200))` sem dar `pumpAndSettle()`, o frame seguinte imediatamente começa a montar a rota recém-empurrada (`TelaInicialScreen`).
* A `TelaInicialScreen` acessa `FirebaseAuth.instance` estático no seu `initState()`. Como nenhum `Firebase.initializeApp()` foi chamado no ambiente de testes, o `firebase_core` joga a exceção `[core/no-app]`.
* **Solução padrão no Flutter:** Inicializar os mocks de canais de plataforma do `firebase_core` no setup dos testes (usando `setupFirebaseCoreMocks()` do `firebase_core_platform_interface` ou definindo o `MethodChannelFirebase.channel`), permitindo que chamadas como `Firebase.initializeApp()` e acessos a `FirebaseAuth.instance` funcionem sem crash no runner de testes.


2. **Falha 2 (`Found 0 widgets with text "Erro ao cadastrar: O e-mail já está cadastrado."`):**
* Ao analisar o código de `_submit()` da `CadastroScreen`:
```dart
} on FirebaseAuthException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Erro ao cadastrar: ${e.message}")),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Erro desconhecido: $e")),
  );
}

```


* O teste usou uma classe `class FailingFirebaseAuth extends Fake implements FirebaseAuth`.
* No Dart, classes `Fake` do pacote `test` / `mockito` lançam `NoSuchMethodError` para **qualquer** membro que seja acessado e não tenha sido explicitamente implementado.
* Quando o Flutter ou o código interno acessa getters/métodos de `FirebaseAuth` (como `app`, `currentUser`, `setLanguageCode`, etc.) antes ou depois de chamar `createUserWithEmailAndPassword`, a classe `Fake` lança um `NoSuchMethodError`.
* Esse erro cai no bloco genérico `catch (e)`, exibindo `"Erro desconhecido: NoSuchMethodError: ..."` em vez do bloco `on FirebaseAuthException catch (e)`.
* **Solução:** Em vez de usar `Fake`, devemos configurar um `MockFirebaseAuth` do pacote `firebase_auth_mocks` ou utilizar mockito com `MockFirebaseAuth` com herança apropriada, ou simplesmente estender `MockFirebaseAuth` da lib `firebase_auth_mocks` (que já implementa todos os métodos padrão e getters de forma segura sem lançar `NoSuchMethodError`).



---

### Código Corrigido

Abaixo está o teste corrigido. Configura-se o ambiente de mock do Firebase Core e estende-se `MockFirebaseAuth` para simular o erro sem quebrar chamadas internas com `NoSuchMethodError`:

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

// Estende MockFirebaseAuth para herdar todas as propriedades sem disparar NoSuchMethodError
class FailingMockFirebaseAuth extends MockFirebaseAuth {
  final FirebaseAuthException exceptionToThrow;

  FailingMockFirebaseAuth(this.exceptionToThrow);

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw exceptionToThrow;
  }
}

// Configura o mock da plataforma Firebase para evitar [core/no-app] ao montar telas posteriores
void setupMockFirebaseCore() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
}

void main() {
  setupMockFirebaseCore();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('Fluxo de Integração: Cadastro -> Gêneros Musicais', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
    });

    Widget createWidgetUnderTest({
      FirebaseAuth? auth,
      FakeFirebaseFirestore? firestore,
    }) {
      return MaterialApp(
        home: CadastroScreen(
          auth: auth ?? mockAuth,
          firestore: firestore ?? fakeFirestore,
        ),
      );
    }

    testWidgets(
      'deve completar o fluxo de cadastro e salvar gêneros favoritos no Firestore',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // 1. Preenchimento dos campos da CadastroScreen
        final textFields = find.byType(TextFormField);
        expect(textFields, findsNWidgets(10));

        await tester.enterText(textFields.at(0), 'Fulano da Silva');
        await tester.enterText(textFields.at(1), '15051995');
        await tester.enterText(textFields.at(2), 'fulano@teste.com');
        await tester.enterText(textFields.at(3), '123456');
        await tester.enterText(textFields.at(4), '123456');
        await tester.enterText(textFields.at(5), '50000000');

        await tester.ensureVisible(textFields.at(6));
        await tester.enterText(textFields.at(6), 'Rua das Flores');
        await tester.enterText(textFields.at(7), '123');
        await tester.enterText(textFields.at(8), 'Centro');
        await tester.enterText(textFields.at(9), 'Recife');

        // Seleciona Estado: seleciona 'AC'
        final dropdownFinder = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdownFinder);
        await tester.tap(dropdownFinder);
        await tester.pumpAndSettle();

        final dropdownItem = find.text('AC').last;
        await tester.tap(dropdownItem);
        await tester.pumpAndSettle();

        // Submete cadastro
        final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarButton);
        await tester.tap(cadastrarButton);
        await tester.pumpAndSettle();

        // 2. Valida usuário no Firebase Auth
        expect(mockAuth.currentUser, isNotNull);
        final String uid = mockAuth.currentUser!.uid;
        expect(mockAuth.currentUser!.email, 'fulano@teste.com');

        // 3. Valida dados no Firestore
        final userDocSnapshot =
            await fakeFirestore.collection('usuarios').doc(uid).get();
        expect(userDocSnapshot.exists, isTrue);
        expect(userDocSnapshot.data()!['nome'], 'Fulano da Silva');
        expect(userDocSnapshot.data()!['email'], 'fulano@teste.com');
        expect(userDocSnapshot.data()!['endereco']['cidade'], 'Recife');
        expect(userDocSnapshot.data()!['endereco']['estado'], 'AC');

        // 4. Valida transição para GenerosCadastroScreen
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);
        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsOneWidget,
        );

        // 5. Seleciona os gêneros
        final rockRowFinder = find.ancestor(
          of: find.text('Rock'),
          matching: find.byType(Row),
        );
        final popRowFinder = find.ancestor(
          of: find.text('Pop'),
          matching: find.byType(Row),
        );

        final rockSwitch = find.descendant(
          of: rockRowFinder,
          matching: find.byType(Switch),
        );
        final popSwitch = find.descendant(
          of: popRowFinder,
          matching: find.byType(Switch),
        );

        await tester.tap(rockSwitch);
        await tester.pumpAndSettle();
        await tester.tap(popSwitch);
        await tester.pumpAndSettle();

        // 6. Toca no botão "Confirmar"
        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);
        await tester.pumpAndSettle();

        // 7. Valida se os gêneros foram salvos no Firestore
        final updatedDocSnapshot =
            await fakeFirestore.collection('usuarios').doc(uid).get();
        final List<dynamic> generosSalvos =
            updatedDocSnapshot.data()!['generos_favoritos'];

        expect(generosSalvos, containsAll(['Rock', 'Pop']));
        expect(generosSalvos.length, 2);
      },
    );

    testWidgets(
      'deve exibir SnackBar de erro caso o Firebase Auth falhe no cadastro',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final failingAuth = FailingMockFirebaseAuth(
          FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'O e-mail já está cadastrado.',
          ),
        );

        await tester.pumpWidget(
          createWidgetUnderTest(
            auth: failingAuth,
            firestore: fakeFirestore,
          ),
        );
        await tester.pumpAndSettle();

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'Maria Oliveira');
        await tester.enterText(textFields.at(1), '10101990');
        await tester.enterText(textFields.at(2), 'maria@teste.com');
        await tester.enterText(textFields.at(3), '123456');
        await tester.enterText(textFields.at(4), '123456');
        await tester.enterText(textFields.at(5), '50000000');

        await tester.ensureVisible(textFields.at(6));
        await tester.enterText(textFields.at(6), 'Rua Principal');
        await tester.enterText(textFields.at(7), '456');
        await tester.enterText(textFields.at(8), 'Boa Viagem');
        await tester.enterText(textFields.at(9), 'Recife');

        final dropdownFinder = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdownFinder);
        await tester.tap(dropdownFinder);
        await tester.pumpAndSettle();

        final dropdownItem = find.text('AC').last;
        await tester.tap(dropdownItem);
        await tester.pumpAndSettle();

        final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarButton);
        await tester.tap(cadastrarButton);
        await tester.pumpAndSettle();

        // Verifica que a SnackBar com o erro do FirebaseAuthException foi exibida
        expect(
          find.text('Erro ao cadastrar: O e-mail já está cadastrado.'),
          findsOneWidget,
        );

        // Garante que não navegou para a tela seguinte
        expect(find.byType(GenerosCadastroScreen), findsNothing);
      },
    );

    testWidgets(
      'deve exibir SnackBar se o usuário tentar confirmar sem selecionar nenhum gênero musical',
      (WidgetTester tester) async {
        final authMock = MockFirebaseAuth(signedIn: true);

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: authMock,
              firestore: fakeFirestore,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);
        await tester.pumpAndSettle();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'não deve salvar gêneros caso currentUser seja nulo',
      (WidgetTester tester) async {
        final unauthenticatedAuth = MockFirebaseAuth(signedIn: false);

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: unauthenticatedAuth,
              firestore: fakeFirestore,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final jazzRowFinder = find.ancestor(
          of: find.text('Jazz'),
          matching: find.byType(Row),
        );
        final jazzSwitch = find.descendant(
          of: jazzRowFinder,
          matching: find.byType(Switch),
        );
        await tester.tap(jazzSwitch);
        await tester.pumpAndSettle();

        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);
        await tester.pumpAndSettle();

        final usuariosDocs = await fakeFirestore.collection('usuarios').get();
        expect(usuariosDocs.docs.isEmpty, isTrue);
      },
    );
  });
}

```
````
