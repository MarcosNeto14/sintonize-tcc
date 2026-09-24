# FASE2-INT-FS-02_cadastroFlow — Réplica Gemini

Rodada **56/60**. Bloco 3 (integração), lote 13 (`cadastroFlow`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-INT-FS-02_cadastroFlow |
| **Função/tela alvo** | fluxo de cadastro — `CadastroScreen` → `GenerosCadastroScreen` |
| **Arquivo(s) de origem** | `lib/cadastro.dart`, `lib/generos-cadastro.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Pílula do seletor conferida a cada envio: `Flash` (não `Flash-Lite`). |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/8a6c620a7cdb2da5` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos`, alvo limpo. I-CRASH verificado revertido antes da rodada |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 · DevTools 2.54.2 |
| **Arquivo de teste** | `test/fase2-gemini/integration/cadastro_flow_fs_test.dart` |
| **Saídas arquivadas** | `resultados/integration/FASE2-INT-FS-02_{iter0,iter1,iter2,iter3_final}.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) — ver a nota de extração |
| **Versão do prompt** | Original, de `prompts_prontos/integration/few-shot/FASE2-INT-FS-02_cadastroFlow.md`, sem alteração |

---

## Nota de extração — markdown malformado na geração

A resposta da geração veio com **markdown quebrado pelo próprio modelo**: a cerca de abertura foi emitida colada ao fim de uma frase (`...no documento` + '```dart', sem quebra de linha). O app renderizou o primeiro trecho do código **como texto corrido**, não como bloco — e por isso aquele trecho **não tem botão "Copiar o código" e perdeu a indentação na renderização**. O restante virou um segundo bloco, com indentação preservada.

O arquivo de teste foi montado a partir da cópia integral da resposta, removendo apenas as linhas que continham somente cercas (```` ``` ````). **Nenhum token foi alterado e nada foi reindentado** — a indentação ausente nas primeiras linhas é a que o app entregou. A resposta integral, com o defeito, está no Apêndice.

Não é a limitação de automação descrita no `README.md` (guard de dados / perda de indentação por `get_page_text`): aqui o defeito está na saída do modelo, e um envio manual produziria exatamente o mesmo texto.

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
| **Compilou na 1ª execução?** | **Não** — o modelo deixou os imports do projeto **comentados** |
| **Testes gerados** | 2 |
| **Testes passaram (1ª execução válida, iteração 1)** | **1/2** |
| **Testes passaram (final, iteração 3)** | **1/2** |
| **Iterações de reparo** | 3 (máximo) |
| **Tentativas de envio até obter resposta** | 1 (nenhuma recusa) |
| **Autoclassificação** | (A); (A); (A) — todas corretas |

---

## Iterative Repair Loop

| Iteração | Envio | Resposta | Classificação | Resultado |
|---|---|---|---|---|
| 0 (geração) | automação | 2 `testWidgets`, `firebase_auth_mocks` + `fake_cloud_firestore`. Deixa os imports do projeto **comentados**, com a nota "Importe as telas do seu projeto conforme a estrutura de diretórios". Markdown malformado (ver nota de extração) | — | **não compila** — `Method not found: 'CadastroScreen'`, `Undefined name 'GenerosCadastroScreen'`, `Undefined name 'TelaInicialScreen'` |
| 1 | automação, mesma conversa | arquivo completo, com os imports descomentados — porém **relativos** (`import '../../../lib/cadastro.dart';`) em vez de `package:sintonize/...` como o prompt pede | **(A)**, correta | **compila** — **1/2**. Falha: `Bad state: No element` em `enterText`, finder `widgetWithText(TextFormField, 'Nome')` não encontra nada |
| 2 | automação, mesma conversa | **resposta truncada e reiniciada**: começa um arquivo corrigido, corta no meio do preenchimento dos campos e recomeça com uma segunda análise genérica; termina perguntando "Quer compartilhar as linhas 45 a 65 do teste...?" | **(A)**, correta | **sem código aplicável** — arquivo inalterado → **1/2** |
| 3 | automação, mesma conversa | **só orientação genérica**, sem arquivo: três "correções típicas" (`pumpAndSettle`, finder por `Key`, `ensureVisible`), nenhuma ancorada no código real. Termina de novo perguntando se quer compartilhar as linhas 45 a 65 | **(A)**, correta | arquivo inalterado, reexecutado → **1/2 (final)** |

### Nota de procedimento sobre as iterações 2 e 3

Como a iteração 2 não entregou código aplicável, o arquivo não mudou e a saída do terminal da iteração 3 é idêntica à da 2. O reparo 3 foi enviado com essa saída idêntica, mesmo critério da rodada 53: ainda havia reparo legítimo a pedir, já que a falha era do próprio teste e o modelo não a havia corrigido. **Em nenhum momento o modelo foi pressionado a enfraquecer a asserção**; ele simplesmente não entregou arquivo.

Também não foi respondida a pergunta do modelo ("Quer compartilhar as linhas 45 a 65?"). Responder seria fornecer material de apoio fora do prompt padronizado e quebraria a comparabilidade com a Fase 2.

---

## Observações

1. **O modelo pediu contexto em vez de entregar código, duas vezes.** Nas iterações 2 e 3 ele encerra perguntando se pode ver as linhas 45–65 do teste — informação que ele mesmo escreveu duas mensagens antes, na própria conversa. É o primeiro caso na réplica em que o modelo trata o próprio output anterior como indisponível.
2. **Escopo muito estreito: 2 testes** para um fluxo de duas telas com 10 campos de formulário. É a menor suíte de todo o bloco 3 (ZS-01 gerou 7, COT-01 gerou 8, ZS-02 gerou 4).
3. **Ignorou a instrução de import.** O prompt pede `import 'package:sintonize/...'` explicitamente; o modelo usou caminhos relativos `../../../lib/...`. Compila, mas contraria a instrução — e é justamente o tipo de erro que a ajuda de import embutida nos prompts do `playlistFlow` existe para evitar.
4. **A parede da `TelaInicialScreen` não foi alcançada.** Diferente das rodadas 52, 53, 54 e 55, aqui o teste morre antes, no preenchimento do formulário. O único teste que passa é o de validação local (nenhum gênero selecionado).
5. **Markdown malformado na geração** — ver a nota de extração. Vale registrar como ocorrência: é a primeira vez na réplica em que a saída do modelo, e não a ferramenta, degrada o artefato.
6. **Comparação com o ChatGPT na mesma rodada:** ChatGPT fechou em **0/2**; Gemini, em **1/2**. Ambos com escopo igualmente estreito (2 testes) e ambos incapazes de completar o fluxo de cadastro. É a rodada de integração em que os dois modelos mais se aproximam — para baixo.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial (markdown malformado, reproduzido como veio)

````markdown
Aqui está o teste de integração completo utilizando `flutter_test`, `firebase_auth_mocks` e `fake_cloud_firestore`.

O teste cobre o fluxo de ponta a ponta:

1. Preenchimento de todos os campos do formulário na `CadastroScreen` (inclusive seleção do dropdown de estado).
2. Criação do usuário no `FirebaseAuth` e gravação dos dados cadastrais iniciais no `FakeFirebaseFirestore`.
3. Navegação automática para a `GenerosCadastroScreen`.
4. Seleção de gêneros musicais via componente `Switch`.
5. Confirmação e atualização (`update`) do campo `generos_favoritos` no documento```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// Importe as telas do seu projeto conforme a estrutura de diretórios:
// import 'package:sintonize/cadastro.dart';
// import 'package:sintonize/generos-cadastro.dart';
// import 'package:sintonize/tela-inicial.dart';

void main() {
TestWidgetsFlutterBinding.ensureInitialized();

group('Fluxo de Cadastro e Seleção de Gêneros - App Sintonize', () {
late MockFirebaseAuth mockAuth;
late FakeFirebaseFirestore fakeFirestore;

```
setUp(() {
  mockAuth = MockFirebaseAuth(signedIn: false);
  fakeFirestore = FakeFirebaseFirestore();
});

Widget buildTestableWidget() {
  return MaterialApp(
    home: CadastroScreen(
      auth: mockAuth,
      firestore: fakeFirestore,
    ),
  );
}

testWidgets(
  'deve completar com sucesso o cadastro, salvar dados no Firestore, '
  'navegar para seleção de gêneros e atualizar preferências no Firestore',
  (WidgetTester tester) async {
    // Define resolução confortável para comportar formulários longos em testes
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestableWidget());

    // Localizadores por campo de texto
    final nomeField = find.widgetWithText(TextFormField, 'Nome');
    final dataNascField = find.widgetWithText(TextFormField, 'Data de Nascimento');
    final emailField = find.widgetWithText(TextFormField, 'E-mail');
    final senhaField = find.widgetWithText(TextFormField, 'Senha');
    final confSenhaField = find.widgetWithText(TextFormField, 'Confirmar Senha');
    final cepField = find.widgetWithText(TextFormField, 'CEP');
    final numeroField = find.widgetWithText(TextFormField, 'Número');
    final ruaField = find.widgetWithText(TextFormField, 'Rua');
    final bairroField = find.widgetWithText(TextFormField, 'Bairro');
    final cidadeField = find.widgetWithText(TextFormField, 'Cidade');
    final estadoDropdown = find.byType(DropdownButtonFormField<String>);

    // 1. Preenchimento do formulário de cadastro
    await tester.enterText(nomeField, 'Marcos Neto');
    await tester.enterText(dataNascField, '15101998');
    await tester.enterText(emailField, 'marcos.neto@teste.com');
    await tester.enterText(senhaField, 'senhaSegura123');
    await tester.enterText(confSenhaField, 'senhaSegura123');
    await tester.enterText(cepField, '50000000');
    await tester.enterText(numeroField, '100');

    // Preenche campos de endereço diretamente para evitar requisição externa ao ViaCEP no teste
    await tester.enterText(ruaField, 'Rua Principal');
    await tester.enterText(bairroField, 'Boa Viagem');
    await tester.enterText(cidadeField, 'Recife');

    // Seleção do Estado no Dropdown
    await tester.ensureVisible(estadoDropdown);
    await tester.tap(estadoDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('PE').last);
    await tester.pumpAndSettle();

    // 2. Submissão do Cadastro
    final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
    await tester.ensureVisible(cadastrarButton);
    await tester.tap(cadastrarButton);
    await tester.pumpAndSettle();

    // Valida que a transição para GenerosCadastroScreen ocorreu
    expect(find.byType(GenerosCadastroScreen), findsOneWidget);

    // Valida o registro no Firebase Auth
    final currentUser = mockAuth.currentUser;
    expect(currentUser, isNotNull);
    expect(currentUser!.email, equals('marcos.neto@teste.com'));

    // Valida se o documento do usuário foi criado com os dados iniciais
    final userDoc = await fakeFirestore
        .collection('usuarios')
        .doc(currentUser.uid)
        .get();

    expect(userDoc.exists, isTrue);
    expect(userDoc.get('nome'), equals('Marcos Neto'));
    expect(userDoc.get('email'), equals('marcos.neto@teste.com'));
    expect(userDoc.get('endereco.estado'), equals('PE'));
    expect(userDoc.get('endereco.numero'), equals('100'));

    // 3. Seleção de Gêneros Musicais
    final rockSwitch = find.descendant(
      of: find.ancestor(
        of: find.text('Rock'),
        matching: find.byType(Card),
      ),
      matching: find.byType(Switch),
    );

    final jazzSwitch = find.descendant(
      of: find.ancestor(
        of: find.text('Jazz'),
        matching: find.byType(Card),
      ),
      matching: find.byType(Switch),
    );

    await tester.ensureVisible(rockSwitch);
    await tester.tap(rockSwitch);
    await tester.pumpAndSettle();

    await tester.ensureVisible(jazzSwitch);
    await tester.tap(jazzSwitch);
    await tester.pumpAndSettle();

    // 4. Confirmação e Salvamento dos Gêneros
    final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
    await tester.ensureVisible(confirmarButton);
    await tester.tap(confirmarButton);
    await tester.pumpAndSettle();

    // Validação da navegação final
    expect(find.byType(TelaInicialScreen), findsOneWidget);

    // Validação da atualização dos dados no Firestore
    final userDocAtualizado = await fakeFirestore
        .collection('usuarios')
        .doc(currentUser.uid)
        .get();

    final generosFavoritos = List<String>.from(
      userDocAtualizado.get('generos_favoritos'),
    );

    expect(generosFavoritos, containsAll(['Rock', 'Jazz']));
    expect(generosFavoritos, isNot(contains('Pop')));
  },
);

testWidgets(
  'não deve prosseguir em GenerosCadastroScreen se nenhum gênero for selecionado',
  (WidgetTester tester) async {
    // Pré-autentica o usuário para simular chegada direta na tela
    await mockAuth.createUserWithEmailAndPassword(
      email: 'teste@exemplo.com',
      password: 'senha123456',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: GenerosCadastroScreen(
          auth: mockAuth,
          firestore: fakeFirestore,
        ),
      ),
    );

    final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
    await tester.ensureVisible(confirmarButton);
    await tester.tap(confirmarButton);
    await tester.pump();

    expect(
      find.text('Selecione pelo menos um gênero musical!'),
      findsOneWidget,
    );
    expect(find.byType(TelaInicialScreen), findsNothing);
  },
);

```

});
}

```

```
````

### Reparo 1

````markdown
### Classificação da Causa da Falha

**Classificação:** **(A) O teste presume um comportamento que não é o especificado.**

**Justificativa:**
Os erros emitidos pelo compilador do Dart (`Method not found: 'CadastroScreen'`, `Undefined name 'GenerosCadastroScreen'`, `Undefined name 'TelaInicialScreen'`) são erros estáticos de compilação decorrentes da ausência de importação das classes/widgets no arquivo de teste. Como as linhas de importação foram deixadas comentadas como exemplo (`// import ...`), o compilador não encontrou as definições dos tipos utilizados no teste.

---

### Código Corrigido

Abaixo está o arquivo de teste com as importações resolvidas de forma relativa (a partir de `test/fase2-gemini/integration/` para `lib/`), permitindo a compilação e execução corretas independentemente do nome do pacote no `pubspec.yaml`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// Importações relativas dos arquivos da aplicação em lib/
import '../../../lib/cadastro.dart';
import '../../../lib/generos-cadastro.dart';
import '../../../lib/tela-inicial.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Cadastro e Seleção de Gêneros - App Sintonize', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: false);
      fakeFirestore = FakeFirebaseFirestore();
    });

    Widget buildTestableWidget() {
      return MaterialApp(
        home: CadastroScreen(
          auth: mockAuth,
          firestore: fakeFirestore,
        ),
      );
    }

    testWidgets(
      'deve completar com sucesso o cadastro, salvar dados no Firestore, '
      'navegar para seleção de gêneros e atualizar preferências no Firestore',
      (WidgetTester tester) async {
        // Define resolução física para garantir que os formulários caibam na viewport de teste
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildTestableWidget());

        // Localizadores por campo de texto
        final nomeField = find.widgetWithText(TextFormField, 'Nome');
        final dataNascField = find.widgetWithText(TextFormField, 'Data de Nascimento');
        final emailField = find.widgetWithText(TextFormField, 'E-mail');
        final senhaField = find.widgetWithText(TextFormField, 'Senha');
        final confSenhaField = find.widgetWithText(TextFormField, 'Confirmar Senha');
        final cepField = find.widgetWithText(TextFormField, 'CEP');
        final numeroField = find.widgetWithText(TextFormField, 'Número');
        final ruaField = find.widgetWithText(TextFormField, 'Rua');
        final bairroField = find.widgetWithText(TextFormField, 'Bairro');
        final cidadeField = find.widgetWithText(TextFormField, 'Cidade');
        final estadoDropdown = find.byType(DropdownButtonFormField<String>);

        // 1. Preenchimento do formulário de cadastro
        await tester.enterText(nomeField, 'Marcos Neto');
        await tester.enterText(dataNascField, '15101998');
        await tester.enterText(emailField, 'marcos.neto@teste.com');
        await tester.enterText(senhaField, 'senhaSegura123');
        await tester.enterText(confSenhaField, 'senhaSegura123');
        await tester.enterText(cepField, '50000000');
        await tester.enterText(numeroField, '100');

        // Preenche campos de endereço diretamente para dispensar a chamada externa de API
        await tester.enterText(ruaField, 'Rua Principal');
        await tester.enterText(bairroField, 'Boa Viagem');
        await tester.enterText(cidadeField, 'Recife');

        // Seleção do Estado no Dropdown
        await tester.ensureVisible(estadoDropdown);
        await tester.tap(estadoDropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('PE').last);
        await tester.pumpAndSettle();

        // 2. Submissão do Cadastro
        final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarButton);
        await tester.tap(cadastrarButton);
        await tester.pumpAndSettle();

        // Valida que a transição para GenerosCadastroScreen ocorreu
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);

        // Valida o registro no Firebase Auth
        final currentUser = mockAuth.currentUser;
        expect(currentUser, isNotNull);
        expect(currentUser!.email, equals('marcos.neto@teste.com'));

        // Valida se o documento do usuário foi criado com os dados iniciais
        final userDoc = await fakeFirestore
            .collection('usuarios')
            .doc(currentUser.uid)
            .get();

        expect(userDoc.exists, isTrue);
        expect(userDoc.get('nome'), equals('Marcos Neto'));
        expect(userDoc.get('email'), equals('marcos.neto@teste.com'));
        expect(userDoc.get('endereco.estado'), equals('PE'));
        expect(userDoc.get('endereco.numero'), equals('100'));

        // 3. Seleção de Gêneros Musicais
        final rockSwitch = find.descendant(
          of: find.ancestor(
            of: find.text('Rock'),
            matching: find.byType(Card),
          ),
          matching: find.byType(Switch),
        );

        final jazzSwitch = find.descendant(
          of: find.ancestor(
            of: find.text('Jazz'),
            matching: find.byType(Card),
          ),
          matching: find.byType(Switch),
        );

        await tester.ensureVisible(rockSwitch);
        await tester.tap(rockSwitch);
        await tester.pumpAndSettle();

        await tester.ensureVisible(jazzSwitch);
        await tester.tap(jazzSwitch);
        await tester.pumpAndSettle();

        // 4. Confirmação e Salvamento dos Gêneros
        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);
        await tester.pumpAndSettle();

        // Validação da navegação final
        expect(find.byType(TelaInicialScreen), findsOneWidget);

        // Validação da atualização dos dados no Firestore
        final userDocAtualizado = await fakeFirestore
            .collection('usuarios')
            .doc(currentUser.uid)
            .get();

        final generosFavoritos = List<String>.from(
          userDocAtualizado.get('generos_favoritos'),
        );

        expect(generosFavoritos, containsAll(['Rock', 'Jazz']));
        expect(generosFavoritos, isNot(contains('Pop')));
      },
    );

    testWidgets(
      'não deve prosseguir em GenerosCadastroScreen se nenhum gênero for selecionado',
      (WidgetTester tester) async {
        // Pré-autentica o usuário para simular chegada direta na tela
        await mockAuth.createUserWithEmailAndPassword(
          email: 'teste@exemplo.com',
          password: 'senha123456',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        );

        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);
        await tester.pump();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );
  });
}

```
````

### Reparo 2 (truncada e reiniciada, reproduzida como veio)

````markdown
### Classificação da Causa da Falha

**Classificação:** **(A) O teste presume um comportamento que não é o especificado.**

**Justificativa:**
A exceção `StateError: Bad state: No element` disparada em `WidgetController.state` durante a chamada de `WidgetTester.enterText` na linha 57 (`await tester.enterText(nomeField, 'Marcos Neto');`) ocorre porque o finder:

```dart
find.widgetWithText(TextFormField, 'Nome')

```

não encontrou nenhum widget.

Ao inspecionar o método `_buildTextField` na implementação da tela:

```dart
Widget _buildTextField(String label, TextEditingController controller, ...) {
  return Column(
    children: [
      Text(label, ...), // O texto do label é um widget Text irmão na Column!
      TextFormField(...), // Não possui labelText na InputDecoration, apenas contentPadding e border
    ],
  );
}

```

O texto `'Nome'` não está dentro da árvore do `TextFormField` (não é um `labelText` ou `hintText`), mas sim em um `Text` irmão acima dele dentro da mesma `Column`. Como `find.widgetWithText(A, B)` busca instâncias de `A` que contenham `B` como descendente, nenhum `TextFormField` foi retornado, falhando com `No element`.

Portanto, trata-se de um equívoco na formulação dos finders do teste. Para localizar cada campo de forma precisa e segura, deve-se encontrar o campo associado ao seu label ou utilizar a ordem dos `TextFormField` renderizados.

---

### Código Corrigido

Abaixo está o teste corrigido, utilizando `find.byType(TextFormField).at(...)` de acordo com a ordem dos campos no formulário (ou associando pelo widget ancestral comum):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// Importações relativas dos arquivos da aplicação em lib/
import '../../../lib/cadastro.dart';
import '../../../lib/generos-cadastro.dart';
import '../../../lib/tela-inicial.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Cadastro e Seleção de Gêneros - App Sintonize', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: false);
      fakeFirestore = FakeFirebaseFirestore();
    });

    Widget buildTestableWidget() {
      return MaterialApp(
        home: CadastroScreen(
          auth: mockAuth,
          firestore: fakeFirestore,
        ),
      );
    }

    testWidgets(
      'deve completar com sucesso o cadastro, salvar dados no Firestore, '
      'navegar para seleção de gêneros e atualizar preferências no Firestore',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildTestableWidget());

        // Ordem dos campos TextFormField na CadastroScreen:
        // 0: Nome
        // 1: Data de Nascimento
        // 2: E-mail
        // 3: Senha
        // 4: Confirmar Senha
        // 5: CEP
        // 6: Rua
        // 7: Número
        // 8: Bairro
        // 9: Cidade
        final textFields = find.byType(TextFormField);

        // 1. Preenchimento do formulário de cadastro
        await tester.enterText(textFields.at(0), 'Marcos Neto');
        await tester.enterText(textFields.at(1), '15101998');
        await tester.enterText(textFields.at(2), 'marcos.neto@teste.com');
        await tester.enterText(textFields.at(3), 'senhaSegura123');
        await tester.enterText(textFields.at(4), 'senhaSegura123');
        await tester.enterText(textFields.at(5), '50000000');
        await tester.enterText(textFields.at(6), 'Rua Principal');
        await tester.enterText(textFields.at(7), '100');
        await tester.enterText(textFields.at(8), 'Boa Viagem');
        await tester.enterText(textFields.at(9), 'Recife');

        //### Classificação da Causa Provável

**(A) O teste presume um comportamento que não é o especificado (ou há uma discrepância na implementação do teste em relação à UI renderizada).**

---

### Análise da Falha

O erro ocorre especificamente na linha 57 do arquivo de teste:
```dart
#11 WidgetTester.enterText (package:flutter_test/src/widget_tester.dart:1159:27)
#12 main.<anonymous closure>.<anonymous closure> (file:///.../cadastro_flow_fs_test.dart:57:22)

```

O método `tester.enterText(finder, text)` tenta encontrar o widget editável usando `finder` e chama internamente `tester.state(finder)` / `Iterable.single`. A exceção `Bad state: No element` indica que **o `Finder` fornecido na linha 57 não localizou nenhum elemento na árvore de widgets** no momento da execução.

As causas mais comuns no teste são:

1. **Falta de pump/renderização:** A tela ainda não carregou ou está em estado de transição assíncrona (faltou um `await tester.pumpAndSettle()`).
2. **Finder incompatível com o widget real:** O teste está procurando por uma `Key`, tipo ou texto que não coincide com a tela de cadastro (por exemplo, buscando `find.byType(TextField)` quando o formulário usa um widget customizado ou `TextFormField` envelopado, ou usando uma `Key('campo_email')` inexistente).
3. **Elemento fora da tela:** O campo está dentro de um `SingleChildScrollView` / `ListView` e precisa ser rolado até ficar visível (`await tester.ensureVisible(finder)`).

---

### Diagnóstico e Correção

Como o trecho exato da linha 57 de `cadastro_flow_fs_test.dart` não foi fornecido, a correção envolve ajustar a localização do campo de texto no teste.

#### 1. Verifique a linha 57 do teste

Abra o arquivo `test/fase2-gemini/integration/cadastro_flow_fs_test.dart` na linha 57. Ela tipicamente se parece com:

```dart
// Exemplo comum onde o finder falha:
await tester.enterText(find.byKey(const Key('campoNome')), 'Marcos');
// ou
await tester.enterText(find.byType(TextField).at(0), 'Marcos');

```

#### 2. Padrão de correção no teste

Substitua ou ajuste a sequência de interação com o formulário para garantir que:

* A tela foi totalmente estabilizada após a navegação inicial;
* O campo seja localizado pelo seletor correto existente no widget de cadastro;
* O widget seja rolado para a área visível antes do input, se necessário.

```dart
// 1. Garanta que a tela terminou todas as animações/carregamento inicial
await tester.pumpAndSettle();

// 2. Defina o finder correto de acordo com a UI real
// Opção A: se o campo usa Key
final campoFinder = find.byKey(const Key('nome_field')); 

// Opção B: se usa labelText / hintText
// final campoFinder = find.widgetWithText(TextFormField, 'Nome');

// 3. Se a tela tiver scroll (SingleChildScrollView/ListView), garanta visibilidade:
await tester.ensureVisible(campoFinder);
await tester.pumpAndSettle();

// 4. Agora realize o enterText com segurança
await tester.enterText(campoFinder, 'Valor de Teste');
await tester.pumpAndSettle();

```

Caso o formulário utilize múltiplos campos em sequência (ex: Nome, E-mail, Senha), confirme se as chaves (`Key`) ou os índices de `find.byType(TextField)` / `find.byType(TextFormField)` coincidem exatamente com a estrutura declarada no arquivo da tela de cadastro.
````

### Reparo 3

````markdown
### Classificação da Causa Provável

**(A) O teste presume um comportamento que não é o especificado (ou cometeu um erro de implementação na busca do elemento)**

---

### Diagnóstico Detalhado

O rastreamento da pilha indica exatamente onde e por que a falha ocorreu:

```text
#0      Iterable.single (dart:core/iterable.dart:694:25)
#1      WidgetController.state (package:flutter_test/src/controller.dart:927:42)
#2      WidgetTester.showKeyboard.<anonymous closure>
...
#11     WidgetTester.enterText (package:flutter_test/src/widget_tester.dart:1159:27)
#12     main.<anonymous closure>.<anonymous closure> (cadastro_flow_fs_test.dart:57:22)

```

1. **Origem do erro:** O erro `Bad state: No element` ocorre na linha 57 do arquivo de teste durante a chamada a `tester.enterText(finder, 'texto')`.
2. **Causa raiz:** O `enterText` tenta focar o campo chamando internamente `tester.state<EditableTextState>(finder)`. Para obter o estado do widget, o Flutter executa `.single` no `Iterable` retornado pelo `Finder`. Como o `Finder` fornecido na linha 57 encontrou **zero** elementos na árvore de widgets no momento da execução, `Iterable.single` lançou `Bad state: No element`.
3. **Motivo de ser (A):** Não se trata de uma regra de negócio ou asserção do app falhando (como um `expect` que recebeu valor inesperado), mas sim de um seletor no script de teste procurando um campo que não existe com aquele identificador, que mudou de tela antes da hora, ou que ainda não foi renderizado (falta de `pumpAndSettle()`).

---

### Correções Típicas para o Arquivo de Teste

Verifique a **linha 57** de `cadastro_flow_fs_test.dart`. As causas mais frequentes e suas respectivas soluções são:

#### 1. Falta de sincronização / renderização assíncrona

Se houve uma navegação ou animação antes da linha 57, o campo pode ainda não estar na tela:

```dart
// Adicione pumpAndSettle antes de interagir com o campo
await tester.pumpAndSettle();
await tester.enterText(meuFinder, 'valor');

```

#### 2. Finder incorreto ou desalinhado com o widget

Verifique se a `Key`, o texto de label/hint ou o tipo do widget coincidem com a implementação real da tela:

```dart
// Se estiver usando find.byKey:
// Garanta que o TextFormField/TextField no código de produção realmente possua a Key correspondente:
// ex: TextField(key: const Key('campo_email'), ...)
final emailFinder = find.byKey(const Key('campo_email'));

// Se estiver usando find.widgetWithText:
final emailFinder = find.widgetWithText(TextFormField, 'E-mail');

await tester.enterText(emailFinder, 'usuario@teste.com');

```

#### 3. Campo fora da área visível (necessita scroll)

Se o formulário for longo e estiver dentro de uma `ListView` ou `SingleChildScrollView`, garanta que o campo seja rolado até ficar visível antes de tentar inserir texto:

```dart
await tester.ensureVisible(emailFinder);
await tester.pumpAndSettle();
await tester.enterText(emailFinder, 'usuario@teste.com');

```
````
