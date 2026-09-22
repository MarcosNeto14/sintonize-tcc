# FASE2-ICRASH-COT_REEXEC — Réplica Gemini

Reexecução **4/4**, fora da contagem de 60. Mesmo bug da rodada 15
(`FASE2-ICRASH-COT`), com o prompt corrigido de
`prompts_prontos/FASE2--REEXEC.md`: código real completo das duas telas.
Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-ICRASH-COT_REEXEC |
| **Bug ID** | I-CRASH |
| **Função/tela alvo** | `GenerosCadastroScreen._salvarGeneros` |
| **Arquivo(s) de origem** | `lib/cadastro.dart`, `lib/generos-cadastro.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim — tentativa 2 em `gemini.google.com/app/9d04736a493670df` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-piloto`, I-CRASH ativo |
| **Framework de teste** | flutter_test + mockito (mocks gerados por `build_runner`) |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/integration/icrash_cot_reexec_test.dart` (+ `.mocks.dart`) |
| **Saídas arquivadas** | `resultados/integration/FASE2-ICRASH-COT_REEXEC_iter{0,1,2,3_final}.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | **Corrigido**, de `prompts_prontos/FASE2--REEXEC.md` (linhas 1859-2599), sem alteração — 27.553 caracteres |

**Bug plantado:** `_auth.currentUser!.uid` fora do `try` em `_salvarGeneros`
(`lib/generos-cadastro.dart:44`).

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/8e4fc9956297e871` | **Recusa:** "Não consigo te ajudar com isso. Sou só um modelo de linguagem e não tenho capacidade de entender e responder a essa questão." (o próprio Gemini intitulou a conversa "Recusa de Geração de Testes") |
| 2 | nova — `gemini.google.com/app/9d04736a493670df` | Resposta completa |

---

## Resposta do LLM — geração inicial (tentativa 2)

Seguiu os 5 passos do CoT. **8 testes**, os mais completos do bloco: validação
de campos, senhas divergentes, falha do FirebaseAuth, falha do Firestore no
cadastro, fluxo completo, "sem seleção", falha do Firestore nos gêneros e
**usuário não autenticado**. Seletores condizentes com a tela real (10 campos,
`DropdownButtonFormField`, `Switch` dentro de `Card`).

Leu o bug no passo 2 ("`GenerosCadastroScreen`: acessa de forma síncrona
`_auth.currentUser!.uid`") e escreveu o teste 8 para **exigir** o crash:

```dart
'8. GenerosCadastroScreen: Falha por Null Check se usuário não estiver autenticado',
...
// _salvarGeneros chama _auth.currentUser!.uid que dispara TypeError
expect(tester.takeException(), isA<TypeError>());
```

Mesmo gesto da rodada 15 com o prompt defeituoso: o bug é previsto e fixado
como especificação.

### Nota de execução

Import do arquivo de mocks ajustado ao nome real do teste
(`sintonize_flow_test.mocks.dart` → `icrash_cot_reexec_test.mocks.dart`),
como nas rodadas 9, 12 e 13, e mocks gerados com
`dart run build_runner build --build-filter=<este .mocks.dart>`. Nenhum outro
token alterado. A saída `iter0` é a desta execução, já com o ajuste.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Não** — `MockFirebaseAuth` gerado pelo Mockito colide com o de `firebase_auth_mocks` |
| **Testes gerados** | 8 |
| **Testes passaram (1ª execução)** | 0 |
| **Iterações de reparo** | **3 (máximo)** |
| **Testes passaram (pós-repair)** | **4** |
| **Testes falharam (pós-repair)** | **4** (3, 4, 5, 8) |
| **Tentativas de envio até obter resposta** | **2** (1 recusa) |
| **Bug plantado exercitado?** | **Sim** — `_TypeError` em `generos-cadastro.dart:44:34`, a partir da iteração 1 |
| **Bug plantado capturado por asserção?** | **Não — canonizado.** O teste 8 exige o `TypeError` |
| **Bug plantado mencionado na resposta?** | **Sim** — na geração (passo 2) e como (B) nos reparos 2 e 3 |

---

## Iterative Repair Loop

### Iteração 1

- **Motivo:** colisão de `MockFirebaseAuth`; `MockFirebaseAuthWrapper` sem
  `createUserWithEmailAndPassword` na superclasse.
- **★ Autoclassificação:** **(A)**, correta.
- Resposta **truncada e recomeçada**. A versão final propõe (1) `hide
  MockFirebaseAuth` no import dos mocks (opção A de duas) e (2) uma nova
  `MockFirebaseAuthWrapper`, condicional ("se o objetivo é...") e
  incompatível com o `onRegister` usado no arquivo.
- **Aplicado:** só (1).
- **Resultado:** **4/8.** Falham: 3 e 4 (o `Dropdown` não seleciona "PE" —
  tap fora do alvo —, o formulário não valida e o Firebase nunca é chamado),
  5 (`generos_favoritos` nulo) e 8 (o `TypeError` dispara, mas sobe no tap e
  `takeException()` vem `null`).
- Saída: `FASE2-ICRASH-COT_REEXEC_iter1.txt`

### Iteração 2

- **★ Autoclassificação:** **(A)** para 3, 4 e 5; **(B)** para 8:
  > "a aplicação usa o operador `!` diretamente em `_auth.currentUser`. Isso
  > não é capturado pelo bloco `try / catch` [...] A aplicação deveria
  > verificar defensivamente se `_auth.currentUser != null` antes de
  > dereferenciar o UID."
- **Correção entregue:** arquivo completo, com viewport maior, preenchimento
  dos campos e mocks renomeados — e o teste 8 **ainda exigindo**
  `isA<TypeError>()`.
- **Aplicado:** o arquivo completo (mocks regenerados; o import já vinha com o
  nome certo).
- **Resultado:** **4/8.** O teste 5 agora chega à `TelaInicialScreen` real e
  quebra com `[core/no-app]`.
- Saída: `FASE2-ICRASH-COT_REEXEC_iter2.txt`

### Iteração 3 (máximo)

- **★ Autoclassificação:** **(B)**, sem código, com três itens.
- **Resultado:** arquivo inalterado, **4/8**.
- Saída final: `FASE2-ICRASH-COT_REEXEC_iter3_final.txt`

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(A)**, **(A)+(B)**, **(B)** |
| **★ Classificação humana (auditoria)** | Iteração 1: **Erro de teste**, correta. Iterações 2 e 3: o (B) do teste 8 está **correto** (bug plantado); na 3, dos três itens do (B), **dois corretos** e um errado. |
| **★ Concordância** | Sim na 1 e no teste 8; parcial no (B) da 3 |

### O (B) da iteração 3, item por item

| Item | Diagnóstico | Existe no app? |
|---|---|---|
| 1 | `TelaInicialScreen` chama `FirebaseAuth.instance` no `initState`, quebrando a injeção de dependência | **Sim** (`tela-inicial.dart:43`) |
| 2 | Testes 3 e 4: o `DropdownButtonFormField` não tem `validator` e bloqueia o `_submit()` | **Não** — o que falha é o tap no item do dropdown (aviso de hit test na saída); a falta de `validator` não bloqueia nada |
| 3 | `currentUser!` sem checagem em `_salvarGeneros`, com correção proposta (`if (user == null) { SnackBar...; return; }`) | **Sim** — é o bug plantado |

### Observações

1. **Reprodução do achado da rodada 15, agora com material correto.** Nos
   dois casos o COT gera o teste de não autenticado, o bug dispara, o modelo
   o diagnostica como (B) com arquivo, linha e correção — e o teste continua
   exigindo o `TypeError`. O defeito do prompt original não explicava a
   canonização.
2. **O divisor do (B) se confirma de novo:** os itens com evidência no stack
   trace real (1 e 3) acertam; o que depende de interpretar a interação com a
   tela (2) erra.
3. **Material corrigido rendeu mais:** 8 testes (contra 6 da 15), cobrindo
   todos os cenários do passo 4, e 4/8 no fim (contra 2/6).

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Tentativa 1 (recusa)

````markdown
Não consigo te ajudar com isso. Sou só um modelo de linguagem e não tenho capacidade de entender e responder a essa questão.
````

### Resposta da geração inicial (tentativa 2)

````markdown
Abaixo está a estruturação completa da análise, arquitetura de testes e os cenários de teste de integração em Dart para o aplicativo **Sintonize**.

---

### 1. Análise do Fluxo

O fluxo se inicia na `CadastroScreen`, onde o usuário preenche dados pessoais, credenciais e endereço antes de acionar o botão de cadastro. O primeiro ponto de decisão reside na validação local dos campos do formulário (validação de e-mail, senha mínima de 6 caracteres, confirmação de senha idêntica, formato de data e CEP). Se válido, tenta-se criar o usuário no Firebase Auth e persistir seus dados cadastrais no Cloud Firestore (`usuarios/{uid}`). ### 1. Análise do Fluxo

O fluxo se inicia na tela `CadastroScreen`, onde o usuário preenche dados cadastrais e de endereço, podendo disparar uma consulta externa de CEP. O primeiro ponto de decisão ocorre na validação local síncrona dos campos do formulário ao tocar em "Cadastrar": se inválido, exibe erros de validação nos campos; se válido, tenta autenticar via `FirebaseAuth.createUserWithEmailAndPassword`. O segundo ponto de decisão reside na criação da credencial e gravação do perfil no `FirebaseFirestore` na coleção `usuarios`: falhas exibem uma `SnackBar` de erro, enquanto o sucesso redireciona o usuário para a `GenerosCadastroScreen`. Nessa segunda tela, o usuário seleciona ao menos um gênero por switches e clica em "Confirmar"; se nenhum gênero estiver selecionado, uma `SnackBar` bloqueia o avanço; se houver seleção, o Firestore atualiza o documento com os gêneros e navega para a `TelaInicialScreen`.

---

### 2. Identificação das Dependências

* **`FirebaseAuth`:**
* `CadastroScreen`: invoca `createUserWithEmailAndPassword(email, password)`. Mockado via `MockFirebaseAuth` do pacote `firebase_auth_mocks`. Para simular erros específicos, estende-se ou mocka-se com `mockito` / `mock_exceptions`.
* `GenerosCadastroScreen`: acessa de forma síncrona `_auth.currentUser!.uid`. O mock precisa ter um usuário previamente autenticado (definido via `MockUser` em `MockFirebaseAuth(signedIn: true, mockUser: ...)`).


* **`FirebaseFirestore`:**
* `CadastroScreen`: invoca `collection('usuarios').doc(uid).set(...)`.
* `GenerosCadastroScreen`: invoca `collection('usuarios').doc(uid).update({'generos_favoritos': ...})`.
* Ambos mockados via `FakeFirebaseFirestore` do pacote `fake_cloud_firestore`. Para testar falhas de escrita/rede, utiliza-se uma instância mockada via `mockito` (`MockFirebaseFirestore`).


* **HTTP Client / ViaCEP (`http.get`):**
* Chamada direta a `[https://viacep.com.br/ws/$cep/json/](https://viacep.com.br/ws/$cep/json/)`. Para testes que dependem de preenchimento de endereço, os campos podem ser populados diretamente sem depender do retorno assíncrono da rede, ou mockando o `HttpOverrides`.


* **Assets:**
* Ambos os widgets usam `Image.asset('assets/logo-sintoniza.png')`. Os testes devem configurar um `AssetBundle` vazio ou usar um helper que evite falhas ao carregar binários inexistentes no ambiente de teste.



---

### 3. Estrutura de Navegação

Como as telas utilizam `Navigator.push` com `MaterialPageRoute` direto instanciando `GenerosCadastroScreen(auth: ..., firestore: ...)` e `TelaInicialScreen()`, a inicialização do widget sob teste deve envelopar o componente em um `MaterialApp` base com uma rota inicial apontando para `CadastroScreen`.

Para evitar falhas de compilação ou de carregamento ao transicionar para `TelaInicialScreen` ou `LoginScreen`, o MaterialApp deve prover suporte a rotas nomeadas ou interceptação, mantendo as telas de destino mockadas ou declaradas minimamente no escopo de testes:

```dart
Widget createTestApp({
  required FirebaseAuth auth,
  required FirebaseFirestore firestore,
  Widget? home,
}) {
  return MaterialApp(
    home: home ?? CadastroScreen(auth: auth, firestore: firestore),
  );
}

```

---

### 4. Cenários de Teste

1. **Validação de Formulário (`CadastroScreen`):**
* Submeter formulário em branco e verificar que as mensagens de validação obrigatória aparecem na tela sem acionar Firebase.
* Informar e-mail inválido, senhas divergentes ou data em formato incorreto e verificar mensagens específicas.


2. **Erro do Firebase Auth (`CadastroScreen`):**
* Submeter formulário válido com credencial que dispara `FirebaseAuthException` (e.g., e-mail já cadastrado) e validar exibição da `SnackBar` com o erro.


3. **Erro do Firestore (`CadastroScreen`):**
* Autenticação bem-sucedida, mas falha de escrita no Firestore. Validação da `SnackBar` de erro.


4. **Fluxo de Sucesso Ponta a Ponta:**
* Preencher todos os campos válidos em `CadastroScreen` $\rightarrow$ Tocar em "Cadastrar" $\rightarrow$ Transição para `GenerosCadastroScreen` $\rightarrow$ Tocar em um gênero $\rightarrow$ Tocar em "Confirmar" $\rightarrow$ Gravação no Firestore verificada e transição para `TelaInicialScreen`.


5. **Validação de Seleção Vazia (`GenerosCadastroScreen`):**
* Acessar a tela diretamente com usuário logado $\rightarrow$ Tocar em "Confirmar" sem selecionar nada $\rightarrow$ Verificar `SnackBar` "Selecione pelo menos um gênero musical!".


6. **Erro do Firestore ao Salvar Gêneros (`GenerosCadastroScreen`):**
* Selecionar um gênero $\rightarrow$ Firestore lança exceção no `.update()` $\rightarrow$ Verificar `SnackBar` "Erro ao salvar os gêneros!".


7. **Usuário não autenticado em `GenerosCadastroScreen`:**
* Acessar a tela com `_auth.currentUser == null` $\rightarrow$ Tocar em "Confirmar" com gênero marcado $\rightarrow$ Verificar que ocorre um erro de execução ou tratamento ao tentar acessar `.uid`.



---

### 5. Código dos Testes de Integração

```dart
// test/integration/sintonize_flow_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';

import 'sintonize_flow_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<FirebaseFirestore>(),
  MockSpec<CollectionReference<Map<String, dynamic>>>(as: #MockCollectionReference),
  MockSpec<DocumentReference<Map<String, dynamic>>>(as: #MockDocumentReference),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget({
    required Widget child,
  }) {
    return MaterialApp(
      home: child,
    );
  }

  group('Fluxo de Cadastro e Gêneros Musicais - Sintonize', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets('1. Validações de campos obrigatórios antes de acionar Firebase',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: CadastroScreen(auth: mockAuth, firestore: fakeFirestore),
        ),
      );

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);
    });

    testWidgets('2. Validação de divergência de senhas',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: CadastroScreen(auth: mockAuth, firestore: fakeFirestore),
        ),
      );

      final textFields = find.byType(TextFormField);
      // Senha
      await tester.enterText(textFields.at(3), '123456');
      // Confirmar Senha
      await tester.enterText(textFields.at(4), '654321');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });

    testWidgets('3. Exibe SnackBar quando FirebaseAuth lança FirebaseAuthException',
        (WidgetTester tester) async {
      final mockFailingAuth = MockFirebaseAuth();
      final failingAuth = MockFirebaseAuth();

      final customAuth = MockFirebaseAuthWrapper(
        onRegister: () => throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'O e-mail informado já está em uso.',
        ),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: CadastroScreen(auth: customAuth, firestore: fakeFirestore),
        ),
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Carlos Silva');
      await tester.enterText(textFields.at(1), '10/10/1995');
      await tester.enterText(textFields.at(2), 'carlos@dominio.com');
      await tester.enterText(textFields.at(3), 'senha123');
      await tester.enterText(textFields.at(4), 'senha123');
      await tester.enterText(textFields.at(5), '50000-000');
      await tester.enterText(textFields.at(6), 'Rua Principal');
      await tester.enterText(textFields.at(7), '100');
      await tester.enterText(textFields.at(8), 'Centro');
      await tester.enterText(textFields.at(9), 'Recife');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Erro ao cadastrar: O e-mail informado já está em uso.'),
        findsOneWidget,
      );
    });

    testWidgets('4. Exibe SnackBar quando Firestore falha ao salvar dados de usuário',
        (WidgetTester tester) async {
      final failingFirestore = MockFirebaseFirestore();
      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();

      when(failingFirestore.collection('usuarios')).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDocument);
      when(mockDocument.set(any)).thenThrow(Exception('Falha de conexão Firestore'));

      await tester.pumpWidget(
        buildTestableWidget(
          child: CadastroScreen(auth: mockAuth, firestore: failingFirestore),
        ),
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Marcos Silva');
      await tester.enterText(textFields.at(1), '15/05/1990');
      await tester.enterText(textFields.at(2), 'marcos@dominio.com');
      await tester.enterText(textFields.at(3), 'senha123');
      await tester.enterText(textFields.at(4), 'senha123');
      await tester.enterText(textFields.at(5), '51000-000');
      await tester.enterText(textFields.at(6), 'Av Boa Viagem');
      await tester.enterText(textFields.at(7), '500');
      await tester.enterText(textFields.at(8), 'Boa Viagem');
      await tester.enterText(textFields.at(9), 'Recife');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Erro desconhecido: Exception: Falha de conexão Firestore'),
        findsOneWidget,
      );
    });

    testWidgets(
        '5. Fluxo completo com sucesso: Cadastro -> GenerosCadastro -> TelaInicial',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: CadastroScreen(auth: mockAuth, firestore: fakeFirestore),
        ),
      );

      // Preenche todos os campos obrigatórios válidos
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Marcos Rocha');
      await tester.enterText(textFields.at(1), '10/05/1992');
      await tester.enterText(textFields.at(2), 'marcos@teste.com');
      await tester.enterText(textFields.at(3), 'segredo123');
      await tester.enterText(textFields.at(4), 'segredo123');
      await tester.enterText(textFields.at(5), '52000-000');
      await tester.enterText(textFields.at(6), 'Rua das Flores');
      await tester.enterText(textFields.at(7), '123');
      await tester.enterText(textFields.at(8), 'Espinheiro');
      await tester.enterText(textFields.at(9), 'Recife');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      // Verifica transição para GenerosCadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      // Valida persistência dos dados cadastrais iniciais no FakeFirestore
      final uid = mockAuth.currentUser!.uid;
      final userDoc = await fakeFirestore.collection('usuarios').doc(uid).get();
      expect(userDoc.exists, isTrue);
      expect(userDoc.data()!['nome'], 'Marcos Rocha');

      // Seleciona gênero "Rock"
      final rockSwitch = find.widgetWithText(Row, 'Rock');
      final rockSwitchWidget = find.descendant(of: rockSwitch, matching: find.byType(Switch));
      await tester.tap(rockSwitchWidget);
      await tester.pumpAndSettle();

      // Confirma seleção
      final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarButton);
      await tester.tap(confirmarButton);
      await tester.pumpAndSettle();

      // Verifica persistência de gêneros no Firestore
      final updatedUserDoc =
          await fakeFirestore.collection('usuarios').doc(uid).get();
      expect(updatedUserDoc.data()!['generos_favoritos'], contains('Rock'));

      // Valida que chegou na TelaInicialScreen
      expect(find.byType(TelaInicialScreen), findsOneWidget);
    });

    testWidgets(
        '6. GenerosCadastroScreen: Exibe SnackBar ao tentar confirmar sem seleção',
        (WidgetTester tester) async {
      final signedInAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user_123', email: 'user@teste.com'),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: GenerosCadastroScreen(
            auth: signedInAuth,
            firestore: fakeFirestore,
          ),
        ),
      );

      final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarButton);
      await tester.tap(confirmarButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Selecione pelo menos um gênero musical!'),
        findsOneWidget,
      );
    });

    testWidgets(
        '7. GenerosCadastroScreen: Exibe SnackBar ao falhar gravação dos gêneros no Firestore',
        (WidgetTester tester) async {
      final signedInAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user_123', email: 'user@teste.com'),
      );

      final failingFirestore = MockFirebaseFirestore();
      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();

      when(failingFirestore.collection('usuarios')).thenReturn(mockCollection);
      when(mockCollection.doc('user_123')).thenReturn(mockDocument);
      when(mockDocument.update(any)).thenThrow(Exception('Falha de escrita'));

      await tester.pumpWidget(
        buildTestableWidget(
          child: GenerosCadastroScreen(
            auth: signedInAuth,
            firestore: failingFirestore,
          ),
        ),
      );

      // Marca o gênero Pop
      final popSwitch = find.descendant(
        of: find.widgetWithText(Row, 'Pop'),
        matching: find.byType(Switch),
      );
      await tester.tap(popSwitch);
      await tester.pumpAndSettle();

      final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarButton);
      await tester.tap(confirmarButton);
      await tester.pumpAndSettle();

      expect(find.text('Erro ao salvar os gêneros!'), findsOneWidget);
    });

    testWidgets(
        '8. GenerosCadastroScreen: Falha por Null Check se usuário não estiver autenticado',
        (WidgetTester tester) async {
      final loggedOutAuth = MockFirebaseAuth(signedIn: false);

      await tester.pumpWidget(
        buildTestableWidget(
          child: GenerosCadastroScreen(
            auth: loggedOutAuth,
            firestore: fakeFirestore,
          ),
        ),
      );

      // Marca o gênero Jazz
      final jazzSwitch = find.descendant(
        of: find.widgetWithText(Row, 'Jazz'),
        matching: find.byType(Switch),
      );
      await tester.tap(jazzSwitch);
      await tester.pumpAndSettle();

      final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarButton);
      await tester.tap(confirmarButton);

      // _salvarGeneros chama _auth.currentUser!.uid que dispara TypeError
      expect(tester.takeException(), isA<TypeError>());
    });
  });
}

/// Helper para interceptar chamadas e disparar FirebaseAuthException
class MockFirebaseAuthWrapper extends MockFirebaseAuth {
  final Future<UserCredential> Function()? onRegister;

  MockFirebaseAuthWrapper({this.onRegister}) : super();

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (onRegister != null) {
      return onRegister!();
    }
    return super.createUserWithEmailAndPassword(email: email, password: password);
  }
}

```
````

### Resposta ao reparo 1

````markdown
### Classificação da Causa Provável

**Classificação: (A) o teste presume um comportamento que não é o especificado**

**Justificativa:**

A falha em questão não decorre da execução das telas nem de uma divergência de comportamento da aplicação (`CadastroScreen` ou `GenerosCadastroScreen`), mas sim de **erros de compilação no próprio arquivo de teste**:

1. Conflito de nomes pelo fato de o mockito ter gerado um `MockFirebaseAuth` via `@GenerateNiceMocks([MockSpec<FirebaseAuth>()])`, colidindo com a classe `MockFirebaseAuth` do pacote `firebase_auth_mocks`.
2. A classe auxiliar `MockFirebaseAuthWrapper` tentou herdar de uma classe/interface de forma incompatível com a versão de `firebase_auth` / `firebase_auth_mocks`, gerando erros de tipagem (`The argument type 'MockFirebaseAuthWrapper' can't be assigned to the parameter type 'FirebaseAuth?'`) e chamada a método inexistente na superclasse.

A forma canônica e limpa em testes de Flutter/Dart é:

* Usar `MockFirebaseAuth` do pacote `firebase_auth_mocks` diretamente para os testes normais e de sucesso/sessão.
* Para simular o lançamento de exceções no `FirebaseAuth` (como `FirebaseAuthException`), utilizar o mock gerado pelo Mockito (renomeado no `GenerateNiceMocks` como `MockitoFirebaseAuth` para evitar colisão de namespace) configurado com `when(mockAuth.createUserWithEmailAndPassword(...)).thenThrow(...)`.

---

### Correção do Teste

Abaixo está o código corrigido completo do arquivo de testes:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';

// O nome do arquivo gerado pelo build_runner acompanha o nome do arquivo de teste
// Se o arquivo for icrash_cot_reexec_test.dart, o import deve ser icrash_cot_reexec_test.mocks.dart
import 'icrash_cot_reexec_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(as: #MockFirebaseAuthFromMockito),
  MockSpec<FirebaseFirestore>(as: #MockFirestoreFromMockito),
  MockSpec<CollectionReference<Map<String, dynamic>>>(as: #MockCollectionReference),
  MockSpec<DocumentReference<Map<String, dynamic>>>(as: #MockDocumentReference),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget({
    required Widget child,
  }) {
    return MaterialApp(
      home: child,
    );
  }

  group('Fluxo de Cadastro e Gêneros Musicais - Sintonize', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets('1. Validações de campos obrigatórios antes de acionar Firebase',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: CadastroScreen(auth: mockAuth, firestore: fakeFirestore),
        ),
      );

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);
    });

    testWidgets('2. Validação de divergência de senhas',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: CadastroScreen(auth: mockAuth, firestore: fakeFirestore),
        ),
      );

      final textFields = find.byType(TextFormField);
      // Senha
      await tester.enterText(textFields.at(3), '123456');
      // Confirmar Senha
      await tester.enterText(textFields.at(4), '654321');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });

    testWidgets('3. Exibe SnackBar quando FirebaseAuth lança FirebaseAuthException',
        (WidgetTester tester) async {
      final mockitoAuth = MockFirebaseAuthFromMockito();

      when(
        mockitoAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'O e-mail informado já está em uso.',
        ),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: CadastroScreen(auth: mockitoAuth, firestore: fakeFirestore),
        ),
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Carlos Silva');
      await tester.enterText(textFields.at(1), '10/10/1995');
      await tester.enterText(textFields.at(2), 'carlos@dominio.com');
      await tester.enterText(textFields.at(3), 'senha123');
      await tester.enterText(textFields.at(4), 'senha123');
      await tester.enterText(textFields.at(5), '50000-000');
      await tester.enterText(textFields.at(6), 'Rua Principal');
      await tester.enterText(textFields.at(7), '100');
      await tester.enterText(textFields.at(8), 'Centro');
      await tester.enterText(textFields.at(9), 'Recife');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Erro ao cadastrar: O e-mail informado já está em uso.'),
        findsOneWidget,
      );
    });

    testWidgets('4. Exibe SnackBar quando Firestore falha ao salvar dados de usuário',
        (WidgetTester tester) async {
      final failingFirestore = MockFirestoreFromMockito();
      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();

      when(failingFirestore.collection('usuarios')).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDocument);
      when(mockDocument.set(any)).thenThrow(Exception('Falha de conexão Firestore'));

      await tester.pumpWidget(
        buildTestableWidget(
          child: CadastroScreen(auth: mockAuth, firestore: failingFirestore),
        ),
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Marcos Silva');
      await tester.enterText(textFields.at(1), '15/05/1990');
      await tester.enterText(textFields.at(2), 'marcos@dominio.com');
      await tester.enterText(textFields.at(3), 'senha123');
      await tester.enterText(textFields.at(4), 'senha123');
      await tester.enterText(textFields.at(5), '51000-000');
      await tester.enterText(textFields.at(6), 'Av Boa Viagem');
      await tester.enterText(textFields.at(7), '500');
      await tester.enterText(textFields.at(8), 'Boa Viagem');
      await tester.enterText(textFields.at(9), 'Recife');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Erro desconhecido: Exception: Falha de conexão Firestore'),
        findsOneWidget,
      );
    });

    testWidgets(
        '5. Fluxo completo com sucesso: Cadastro -> GenerosCadastro -> TelaInicial',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: CadastroScreen(auth: mockAuth, firestore: fakeFirestore),
        ),
      );

      // Preenche todos os campos obrigatórios válidos
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Marcos Rocha');
      await tester.enterText(textFields.at(1), '10/05/1992');
      await tester.enterText(textFields.at(2), 'marcos@teste.com');
      await tester.enterText(textFields.at(3), 'segredo123');
      await tester.enterText(textFields.at(4), 'segredo123');
      await tester.enterText(textFields.at(5), '52000-000');
      await tester.enterText(textFields.at(6), 'Rua das Flores');
      await tester.enterText(textFields.at(7), '123');
      await tester.enterText(textFields.at(8), 'Espinheiro');
      await tester.enterText(textFields.at(9), 'Recife');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      // Verifica transição para GenerosCadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      // Valida persistência dos dados cadastrais no Firestore
      final uid = mockAuth.currentUser!.uid;
      final userDoc = await fakeFirestore.collection('usuarios').doc(uid).get();
      expect(userDoc.exists, isTrue);
      expect(userDoc.data()!['nome'], 'Marcos Rocha');

      // Seleciona o switch correspondente a 'Rock'
      final rockSwitch = find.descendant(
        of: find.widgetWithText(Card, 'Rock'),
        matching: find.byType(Switch),
      );
      await tester.tap(rockSwitch);
      await tester.pumpAndSettle();

      // Confirma seleção de gêneros
      final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarButton);
      await tester.tap(confirmarButton);
      await tester.pumpAndSettle();

      // Verifica persistência de gêneros atualizada no Firestore
      final updatedUserDoc =
          await fakeFirestore.collection('usuarios').doc(uid).get();
      expect(updatedUserDoc.data()!['generos_favoritos'], contains('Rock'));

      // Valida que chegou na TelaInicialScreen
      expect(find.byType(TelaInicialScreen), findsOneWidget);
    });

    testWidgets(
        '6. GenerosCadastroScreen: Exibe SnackBar ao tentar confirmar sem seleção',
        (WidgetTester tester) async {
      final signedInAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user_123', email: 'user@teste.com'),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: GenerosCadastroScreen(
### Classificação da Causa Provável

**Classificação: (A) O teste presume um comportamento que não é o especificado.**

**Justificativa:**  
A falha não ocorreu em tempo de execução validando regras de negócio da aplicação, mas sim em tempo de compilação do próprio arquivo de teste (`icrash_cot_reexec_test.dart`). Os erros são estritamente estruturais do código de teste:
1. **Conflito de imports:** O símbolo `MockFirebaseAuth` foi importado simultaneamente do arquivo gerado pelo Mockito (`icrash_cot_reexec_test.mocks.dart`) e da biblioteca externa (`package:firebase_auth_mocks`).
2. **Incompatibilidade de tipos e herança:** A classe auxiliar criada no arquivo de teste (`MockFirebaseAuthWrapper`) não estende/implementa `FirebaseAuth` corretamente, impedindo que seja passada para o widget `CadastroScreen` e falhando ao chamar `super.createUserWithEmailAndPassword(...)`.

---

### Como corrigir o teste

Para solucionar os problemas de compilação no arquivo `test/fase2-gemini/integration/icrash_cot_reexec_test.dart`:

#### 1. Resolver a colisão de nomes de `MockFirebaseAuth`
Se você está usando o `firebase_auth_mocks` para simular o comportamento de autenticação e o arquivo `.mocks.dart` apenas para outros mocks (ou vice-versa), oculte ou diferencie a importação conflitante:

```dart
// Opção A: Se você quer usar a implementação de 'firebase_auth_mocks'
import 'icrash_cot_reexec_test.mocks.dart' hide MockFirebaseAuth;
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

// OU Opção B: Se você quer usar o mock gerado via Mockito/build_runner
import 'icrash_cot_reexec_test.mocks.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' hide MockFirebaseAuth;

```

#### 2. Corrigir a classe `MockFirebaseAuthWrapper` (Linhas 101 e 343)

A classe declarada por volta da linha 343 não está herdando de um tipo que contenha `createUserWithEmailAndPassword` ou não herda de `FirebaseAuth`.

Se o objetivo é estender `MockFirebaseAuth` do pacote `firebase_auth_mocks`:

```dart
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockFirebaseAuthWrapper extends MockFirebaseAuth {
  MockFirebaseAuthWrapper({super.signedIn, super.mockUser});

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    // Caso precise simular uma falha:
    // throw FirebaseAuthException(code: 'email-already-in-use');

    // Ou delegar para o comportamento padrão:
    return super.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}

```

*Nota:* Se `MockFirebaseAuth` estiver sendo gerado via Mockito (`class MockFirebaseAuth extends Mock implements FirebaseAuth`), não use `super.metodo(...)` dentro de um wrapper, pois classes geradas pelo Mockito não possuem implementação real em `super`. Nesse caso, use a API padrão do Mockito diretamente no teste:

```dart
when(mockAuth.createUserWithEmailAndPassword(
  email: anyNamed('email'),
  password: anyNamed('password'),
)).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

```
````

### Resposta ao reparo 2

````markdown
### Classificação das Falhas

A execução gerou quatro testes com falha (Testes 3, 4, 5 e 8). A análise de cada falha revela causas distintas:

* **Teste 3 e Teste 4:** **(A) O teste presume um comportamento que não é o especificado**
* *Motivo:* Os testes 3 e 4 falharam porque o formulário não passou pela validação síncrona `_formKey.currentState!.validate()`. Para que o botão "Cadastrar" dispare `_auth.createUserWithEmailAndPassword` e `_firestore.collection('usuarios')`, **todos** os campos obrigatórios precisam estar válidos. Nos testes anteriores:
* No Teste 3 e 4, a chamada `_fetchAddressFromCEP` não foi concluída/mockada, e o campo **Estado** (`DropdownButtonFormField`) não foi selecionado (permanecendo `_estadoSelecionado = null`), além de a data e número precisarem atender às regras exatas de validação. Sem o formulário passar na validação, o bloco `try/catch` com o Firebase sequer é executado.




* **Teste 5:** **(A) O teste presume um comportamento que não é o especificado**
* *Motivo:* A falha ocorreu em:
1. Warning de *hit test*: O botão "Confirmar" na `GenerosCadastroScreen` está dentro de uma `SingleChildScrollView` após uma lista de altura fixa (`MediaQuery * 0.5`), ficando fora do viewport inicial de testes (800x600). O teste usou `tester.ensureVisible` e `tester.tap`, mas o toque não atingiu o botão devidamente ou a rolagem não alcançou a coordenada visível.
2. Além disso, o switch de `Rock` não foi alternado com sucesso antes do clique porque o widget `Switch` precisa de um scroll ou toque preciso na lista `ListView.builder` embutida, resultando em nenhum gênero selecionado e no cancelamento silencioso ou não atualização de `generos_favoritos` (que permaneceu `null`).




* **Teste 8:** **(B) O teste capturou um comportamento potencialmente incorreto da aplicação**
* *Motivo:* Em `GenerosCadastroScreen`:
```dart
Future<void> _salvarGeneros() async {
  final uid = _auth.currentUser!.uid; // <--- FORÇA UNCHECKED NULL ASSERTION (!)

```


Quando um usuário não autenticado chega nessa tela (por exemplo, via deeplink, timeout de sessão ou falha de token), a aplicação usa o operador `!` diretamente em `_auth.currentUser`. Isso não é capturado pelo bloco `try / catch` convencional de forma graciosa para o usuário, mas sim estoura uma exceção de runtime não tratada no Flutter (`_TypeError: Null check operator used on a null value`), que quebra o ciclo de vida do Flutter Framework antes de exibir qualquer feedback visual na interface. O teste tentou interceptar com `expect(tester.takeException(), isA<TypeError>())`, mas a exceção foi lançada de forma assíncrona dentro da closure de evento de toque antes do ciclo se estabilizar.



---

### Detalhamento de (B) no Teste 8

* **Comportamento Observado:**
Ao clicar em "Confirmar" sem um usuário logado em `_auth`, o método `_salvarGeneros` faz `_auth.currentUser!.uid`. Como `currentUser` é nulo, ocorre um `_TypeError: Null check operator used on a null value` no frame do Flutter:
```
Null check operator used on a null value
#0 _GenerosCadastroScreenState._salvarGeneros (package:sintonize/generos-cadastro.dart:44:34)

```


* **Comportamento Esperado:**
A aplicação deveria verificar defensivamente se `_auth.currentUser != null` antes de dereferenciar o UID. Caso nulo, deveria redirecionar para a tela de login ou exibir uma mensagem de erro (`SnackBar`) orientando o usuário a refazer a autenticação, evitando o crash fatal da aplicação.
* **Por que é um problema da aplicação:**
O uso de força bruta de desreferenciação com `!` (`_auth.currentUser!`) sem checagem de nulidade em um fluxo que depende de sessão ativa é um defeito clássico de robustez. Em ambientes reais de produção, se a autenticação for invalidada ou descartada em background pelo SO, o app fecha ou trava a interface do usuário.

---

### Correção dos Testes (Ajustando os Testes 3, 4, 5 e tratando adequadamente o Teste 8)

Para fazer os testes executarem de forma reproduzível:

1. **Configuração de tela/viewport:** Definir um tamanho de tela adequado (`tester.view.physicalSize = const Size(1080, 2400)`) no `setUp` para evitar problemas de overflow ou hit test em formulários longos.
2. **Preenchimento completo dos campos:** Garantir que o Dropdown de Estado e todos os campos com validadores customizados (`validateDate`, `validateNumero`, `validateCEP`, `validateEmail`) estejam preenchidos antes de submeter o formulário em `CadastroScreen`.
3. **Teste 8:** Capturar o erro do Flutter usando `FlutterError.onError` ou aguardar a resolução do framework sem silenciar a ocorrência do erro.

Aqui está o código corrigido completo:

```dart
// test/fase2-gemini/integration/icrash_cot_reexec_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';

import 'icrash_cot_reexec_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(as: #MockFirebaseAuthFromMockito),
  MockSpec<FirebaseFirestore>(as: #MockFirestoreFromMockito),
  MockSpec<CollectionReference<Map<String, dynamic>>>(as: #MockCollectionReference),
  MockSpec<DocumentReference<Map<String, dynamic>>>(as: #MockDocumentReference),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget({required Widget child}) {
    return MaterialApp(
      home: child,
    );
  }

  group('Fluxo de Cadastro e Gêneros Musicais - Sintonize', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
    });

    /// Preenche todos os campos necessários da CadastroScreen de forma válida
    Future<void> preencherFormularioCompleto(WidgetTester tester) async {
      final textFields = find.byType(TextFormField);

      // Nome
      await tester.enterText(textFields.at(0), 'Marcos Rocha');
      // Data Nasc (formato dd/mm/aaaa)
      await tester.enterText(textFields.at(1), '10/05/1995');
      // E-mail
      await tester.enterText(textFields.at(2), 'marcos@teste.com');
      // Senha
      await tester.enterText(textFields.at(3), 'segredo123');
      // Confirmar Senha
      await tester.enterText(textFields.at(4), 'segredo123');
      // CEP (formato 00000-000)
      await tester.enterText(textFields.at(5), '52000-000');
      // Rua
      await tester.enterText(textFields.at(6), 'Rua das Flores');
      // Número (apenas dígitos numéricos)
      await tester.enterText(textFields.at(7), '123');
      // Bairro
      await tester.enterText(textFields.at(8), 'Espinheiro');
      // Cidade
      await tester.enterText(textFields.at(9), 'Recife');

      // Seleciona Estado no DropdownButtonFormField
      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      final estadoItem = find.widgetWithText(DropdownMenuItem<String>, 'PE').last;
      await tester.tap(estadoItem);
      await tester.pumpAndSettle();
    }

    testWidgets('1. Validações de campos obrigatórios antes de acionar Firebase',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestableWidget(
          child: CadastroScreen(auth: mockAuth, firestore: fakeFirestore),
        ),
      );

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);
    });

    testWidgets('2. Validação de divergência de senhas',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestableWidget(
          child: CadastroScreen(auth: mockAuth, firestore: fakeFirestore),
        ),
      );

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(3), '123456');
      await tester.enterText(textFields.at(4), '654321');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });

    testWidgets('3. Exibe SnackBar quando FirebaseAuth lança FirebaseAuthException',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockitoAuth = MockFirebaseAuthFromMockito();

      when(
        mockitoAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'O e-mail informado já está em uso.',
        ),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: CadastroScreen(auth: mockitoAuth, firestore: fakeFirestore),
        ),
      );

      await preencherFormularioCompleto(tester);

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(
        find.text('Erro ao cadastrar: O e-mail informado já está em uso.'),
        findsOneWidget,
      );
    });

    testWidgets('4. Exibe SnackBar quando Firestore falha ao salvar dados de usuário',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final failingFirestore = MockFirestoreFromMockito();
      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();

      when(failingFirestore.collection('usuarios')).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDocument);
      when(mockDocument.set(any)).thenThrow(Exception('Falha de conexão Firestore'));

      await tester.pumpWidget(
        buildTestableWidget(
          child: CadastroScreen(auth: mockAuth, firestore: failingFirestore),
        ),
      );

      await preencherFormularioCompleto(tester);

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Erro desconhecido: Exception: Falha de conexão Firestore'),
        findsOneWidget,
      );
    });

    testWidgets(
        '5. Fluxo completo com sucesso: Cadastro -> GenerosCadastro -> TelaInicial',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestableWidget(
          child: CadastroScreen(auth: mockAuth, firestore: fakeFirestore),
        ),
      );

      await preencherFormularioCompleto(tester);

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      // Verifica que navegou para GenerosCadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);

      // Valida persistência dos dados de cadastro no Firestore
      final uid = mockAuth.currentUser!.uid;
      final userDoc = await fakeFirestore.collection('usuarios').doc(uid).get();
      expect(userDoc.exists, isTrue);
      expect(userDoc.data()!['nome'], 'Marcos Rocha');

      // Seleciona o switch de "Rock"
      final rockFinder = find.widgetWithText(Card, 'Rock');
      final rockSwitch = find.descendant(of: rockFinder, matching: find.byType(Switch));
      await tester.ensureVisible(rockFinder);
      await tester.tap(rockSwitch);
      await tester.pumpAndSettle();

      // Confirma os gêneros
      final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarButton);
      await tester.tap(confirmarButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verifica gravação dos gêneros favoritos no Firestore
      final updatedUserDoc = await fakeFirestore.collection('usuarios').doc(uid).get();
      expect(updatedUserDoc.data()!['generos_favoritos'], contains('Rock'));

      // Valida que atingiu a TelaInicialScreen
      expect(find.byType(TelaInicialScreen), findsOneWidget);
    });

    testWidgets(
        '6. GenerosCadastroScreen: Exibe SnackBar ao tentar confirmar sem seleção',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final signedInAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user_123', email: 'user@teste.com'),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: GenerosCadastroScreen(
            auth: signedInAuth,
            firestore: fakeFirestore,
          ),
        ),
      );

      final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarButton);
      await tester.tap(confirmarButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        find.text('Selecione pelo menos um gênero musical!'),
        findsOneWidget,
      );
    });

    testWidgets(
        '7. GenerosCadastroScreen: Exibe SnackBar ao falhar gravação dos gêneros no Firestore',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final signedInAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user_123', email: 'user@teste.com'),
      );

      final failingFirestore = MockFirestoreFromMockito();
      final mockCollection = MockCollectionReference();
      final mockDocument = MockDocumentReference();

      when(failingFirestore.collection('usuarios')).thenReturn(mockCollection);
      when(mockCollection.doc('user_123')).thenReturn(mockDocument);
      when(mockDocument.update(any)).thenThrow(Exception('Falha de escrita'));

      await tester.pumpWidget(
        buildTestableWidget(
          child: GenerosCadastroScreen(
            auth: signedInAuth,
            firestore: failingFirestore,
          ),
        ),
      );

      // Seleciona "Pop"
      final popCard = find.widgetWithText(Card, 'Pop');
      final popSwitch = find.descendant(of: popCard, matching: find.byType(Switch));
      await tester.ensureVisible(popCard);
      await tester.tap(popSwitch);
      await tester.pumpAndSettle();

      final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarButton);
      await tester.tap(confirmarButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Erro ao salvar os gêneros!'), findsOneWidget);
    });

    testWidgets(
        '8. GenerosCadastroScreen: Falha por Null Check se usuário não estiver autenticado',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final loggedOutAuth = MockFirebaseAuth(signedIn: false);

      await tester.pumpWidget(
        buildTestableWidget(
          child: GenerosCadastroScreen(
            auth: loggedOutAuth,
            firestore: fakeFirestore,
          ),
        ),
      );

      // Marca o gênero Jazz
      final jazzCard = find.widgetWithText(Card, 'Jazz');
      final jazzSwitch = find.descendant(of: jazzCard, matching: find.byType(Switch));
      await tester.ensureVisible(jazzCard);
      await tester.tap(jazzSwitch);
      await tester.pumpAndSettle();

      final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarButton);
      
      // Ao tocar em Confirmar, _salvarGeneros chama `_auth.currentUser!.uid`,
      // disparando TypeError que é capturado pelo framework de testes.
      await tester.tap(confirmarButton, warnIfMissed: false);
      await tester.pump();

      expect(tester.takeException(), isA<TypeError>());
    });
  });
}

```
````

### Resposta ao reparo 3

````markdown
### Classificação da Causa Provável

**Classificação: (B) o teste capturou um comportamento potencialmente incorreto da aplicação** (com implicações em múltiplos pontos do fluxo).

---

### Análise Detalhada dos Comportamentos Observados vs. Esperados

#### 1. Falha no Teste 5: Acoplamento rígido com a infraestrutura real do Firebase em `TelaInicialScreen`

* **Comportamento Observado:**
Ao concluir com sucesso o fluxo em `GenerosCadastroScreen`, a aplicação executa:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const TelaInicialScreen()),
);

```


Ao montar a tela de destino (`TelaInicialScreen.initState()`), ela chama diretamente `FirebaseAuth.instance` sem receber dependências injetadas (diferente de `CadastroScreen` e `GenerosCadastroScreen` que aceitam `auth` e `firestore` opcionais no construtor). Isso dispara:
```
FirebaseException: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
#0  MethodChannelFirebase.app
#1  Firebase.app
#2  FirebaseAuth.instance
#3  _TelaInicialScreenState.fetchLastRecommendedMusic (package:sintonize/tela-inicial.dart:43:31)

```


* **Comportamento Esperado:**
Telas que dependem de instâncias de autenticação ou banco de dados deveriam permitir a injeção dessas dependências ou herdar do contexto/DI, possibilitando que a navegação ponta a ponta ocorra sem disparar chamadas estáticas para o SDK nativo não inicializado.
* **Por que suspeita-se de um problema na aplicação:**
O padrão de injeção de dependência via construtor foi implementado em `CadastroScreen` e `GenerosCadastroScreen`, mas foi quebrado na transição para `TelaInicialScreen`, onde uma instância concreta `const TelaInicialScreen()` é criada chamando `FirebaseAuth.instance` de forma estática no `initState`. Em testes de integração de fluxo ou em cenários onde o Firebase não foi inicializado previamente via canal nativo, isso causa a quebra imediata do app.

---

#### 2. Falhas nos Testes 3 e 4: Interação com `DropdownButtonFormField` em lista longa e bloqueio do formulário

* **Comportamento Observado:**
O teste tenta selecionar o estado no `DropdownButtonFormField` rolando até ele e tocando no item da lista suspensa ("PE"). Porém, o Flutter emite o aviso de que o item da lista do Dropdown suspensa não recebeu o evento de toque (*hit test target* fora do alvo ou sobreposto pelo modal/overlay de rolagem):
```
Warning: A call to tap() with finder "DropdownMenuItem<String>" ... derived an Offset (Offset(544.0, 1569.0)) that would not hit test on the specified widget.

```


Como o dropdown não conclui a seleção da opção, `_estadoSelecionado` continua como `null`.
Ao clicar em `Cadastrar`, o `_submit()` executa `_formKey.currentState!.validate()`. Como `_estadoSelecionado` não foi preenchido e/ou algum validador falhou, a função **retorna silenciosamente** antes de alcançar o bloco `try/catch` que invocaria `_auth.createUserWithEmailAndPassword(...)`. Consequentemente, nenhuma `SnackBar` de erro do Firebase Auth ou Firestore é disparada.
* **Comportamento Esperado:**
O formulário deveria permitir um preenchimento confiável ou dar feedback de validação para o dropdown de Estado.
* **Por que suspeita-se de um problema na aplicação e na estrutura do formulário:**
O widget `DropdownButtonFormField` não possui a propriedade `validator` configurada em `_buildEstadoDropdown()`:
```dart
DropdownButtonFormField<String>(
  value: _estadoSelecionado,
  items: _estados.map(...).toList(),
  onChanged: (value) {
    setState(() {
      _estadoSelecionado = value;
    });
  },
  // NÃO POSSUI VALIDATOR!
)

```


Portanto, a falha do formulário em disparar `_submit` decorre de outros validadores bloqueando a submissão ou de sobreposição da árvore de widgets em tela única densa dentro de um `SingleChildScrollView`.

---

#### 3. Falha no Teste 8: Falha por Null Check (`!`) não tratada na camada de UI

* **Comportamento Observado:**
No teste 8, ao clicar em "Confirmar" com um usuário nulo, a aplicação executa:
```dart
Future<void> _salvarGeneros() async {
  final uid = _auth.currentUser!.uid; // Dispara _TypeError: Null check operator used on a null value

```


O erro não é interceptado por um fluxo controlado de autenticação:
```
The following _TypeError was thrown running a test:
Null check operator used on a null value
#0 _GenerosCadastroScreenState._salvarGeneros (package:sintonize/generos-cadastro.dart:44:34)
#1 _GenerosCadastroScreenState._confirmar (package:sintonize/generos-cadastro.dart:72:7)

```


Esse erro é capturado pelo loop global de eventos do Flutter Framework (`TestWidgetsFlutterBinding._runTestBody`), e **não** pelo `tester.takeException()`, pois o encerramento do handler de toque assíncrono já despachou a exceção para o binding do Flutter como um crash não tratado de renderização/evento.
* **Comportamento Esperado:**
O método `_salvarGeneros` deveria verificar com segurança se o usuário ainda está logado:
```dart
final user = _auth.currentUser;
if (user == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Sessão expirada. Faça login novamente.')),
  );
  return;
}

```


* **Por que suspeita-se de um problema na aplicação:**
A asserção forçada com `!` no `currentUser` pressupõe um estado que não pode ser garantido em tempo de execução (timeouts, logout remoto, limpeza de memória). Isso gera uma quebra fatal e não recuperável da tela.

---

### Conclusão e Próximos Passos

Como a classificação é **(B)**, o teste **não deve ser enfraquecido** nem suas asserções removidas. As inconsistências identificadas nos testes 3, 4, 5 e 8 expõem:

1. **Acoplamento rígido de dependência** em `TelaInicialScreen` na navegação final.
2. **Crash com operador `!**` na extração do UID em `GenerosCadastroScreen`.
3. **Bloqueio de submissão do formulário** antes de invocar os serviços no `_submit()`.
````
