# FASE2-WIDGET-ZS-01_CadastroScreen — Réplica Gemini

Rodada **43/60**. Bloco 2 (alvos limpos), lote 9 (`CadastroScreen`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WIDGET-ZS-01_CadastroScreen |
| **Função/tela alvo** | `CadastroScreen` |
| **Arquivo(s) de origem** | `lib/cadastro.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/8aae96528e5237fa` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/widget/cadastro_screen_zs_test.dart` |
| **Saídas arquivadas** | `resultados/widget/FASE2-WIDGET-ZS-01_iter{0,1,2,3_final}.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/widget/zero-shot/FASE2-WIDGET-ZS-01_CadastroScreen.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/8aae96528e5237fa` | Resposta completa (truncada e recomeçada; versão final usada) |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 6 |
| **Testes passaram (1ª execução)** | **3/6** |
| **Testes passaram (final, iteração 3/3)** | **3/6** |
| **Iterações de reparo** | 3 (2 recusas + 1 resposta, esta enviada manualmente) |
| **Autoclassificação** | (A) na única resposta de reparo |

---

## Iterative Repair Loop

| Iteração | Envio | Resposta | Classificação | Resultado |
|---|---|---|---|---|
| 0 (geração) | automação | suíte de 6 testes (truncada e recomeçada; usada a versão final) | — | **3/6** — 3× `Bad state: Too many elements` (`find.ancestor(of: find.text(label), matching: find.byType(Column))` casa várias `Column` aninhadas) |
| 1 | automação, mesma conversa | **Recusa:** "Não fui programado para fazer isso. Só consigo gerar texto." | — | arquivo reexecutado inalterado: 3/6 |
| 2 | automação, mesma conversa | **Recusa:** mesma frase | — | arquivo reexecutado inalterado: 3/6 |
| 3 | **manual (Marcos)**, mesma conversa | arquivo completo reescrito com helper `findFieldByLabel` (predicado sobre a `Column` pai) | **(A)** — seletor ambíguo | **3/6 (final)** — mesmos 3 testes: 1× `Bad state: No element`, 2× mensagem de validação não encontrada |

Regra aplicada: recusa dentro do reparo conta como a iteração (decidida no bloco 1). Duas recusas seguidas → envio manual pelo operador (regra desta sessão). Antes do reparo 2, um `ctrl+v` colou texto alheio do clipboard do operador; o campo foi limpo antes do envio e nada saiu.

---

## Observações

1. Os 3 testes que passam (renderização, obrigatórios em branco, navegação para login) não dependem de localizar um campo específico. Os 3 que falham dependem — a suíte nunca conseguiu digitar num campo identificado por label.
2. A geração truncou dentro do bloco de código e recomeçou com uma abordagem diferente (a 1ª versão usava `find.byType(TextFormField).at(i)`, a 2ª usa ancestor de `Column`); o arquivo é a 2ª, a única completa. A 1ª estratégia, descartada pelo recomeço, talvez não tivesse o problema.
3. Nenhuma falha é defeito da aplicação; nenhum (B).
4. ChatGPT na mesma rodada: 22 testes, 7 → 21/22 após 3 iterações.

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
Aqui está a suíte de testes de widget completa usando `flutter_test`, `firebase_auth_mocks` e `fake_cloud_firestore`.

Como a tela renderiza `Image.asset('assets/logo-sintoniza.png')`, os testes configuram um mock de `AssetBundle` de 1 pixel transparente para evitar exceções de asset ausente no ambiente de teste.

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sintonize/cadastro.dart'; // Ajuste se o nome do arquivo for diferente

/// Bundle mock para carregar a imagem do asset sem erros no flutter_test
class _TestAssetBundle extends CachingAssetBundle {
  // 1x1 PNG transparente em bytes
  static final Uint8List _transparentPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
  );

  @override
  Future<ByteData> load(String key) async {
    return ByteData.sublistView(_transparentPng);
  }
}

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget createCadastroScreen() {
    return DefaultAssetBundle(
      bundle: _TestAssetBundle(),
      child: MaterialApp(
        home: CadastroScreen(
          auth: mockAuth,
          firestore: fakeFirestore,
        ),
      ),
    );
  }

  group('CadastroScreen - Renderização e Layout Inicial', () {
    testWidgets('Deve renderizar todos os campos e botões principais', (WidgetTester tester) async {
      await tester.pumpWidget(createCadastroScreen());

      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Data de Nascimento'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Confirmar Senha'), findsOneWidget);
      expect(find.text('CEP'), findsOneWidget);
      expect(find.text('Rua'), findsOneWidget);
      expect(find.text('Número'), findsOneWidget);
      expect(find.text('Bairro'), findsOneWidget);
      expect(find.text('Cidade'), findsOneWidget);
      expect(find.text('Estado'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Cadastrar'), findsOneWidget);
      expect(find.text('Já tem uma conta? Faça login'), findsOneWidget);
    });
  });

  group('CadastroScreen - Validações do Formulário', () {
    testWidgets('Deve exibir erros de campos obrigatórios ao clicar em Cadastrar com formulário vazio', (WidgetTester tester) async {
      await tester.pumpWidget(createCadastroScreen());

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

    testWidgets('Deve validar formato e caracteres do Nome', (WidgetTester tester) async {
      await tester.pumpWidget(createCadastroScreen());

      final nomeField = find.byType(TextFormField).at(0);
      await tester.enterText(nomeField, 'João123');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('O nome não pode conter números ou caracteres especiais'), findsOneWidget);
    });

    testWidgets('Deve validar regras da Data de Nascimento (formato, mês, limites e futuro)', (WidgetTester tester) async {
      await tester.pumpWidget(createCadastroScreen());

      final dataField = find.byType(TextFormField).at(1);

      // Mês inválido
      await tester.enterText(dataField, '10/13/2000');
      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();
      expect(find.text('Mês deve ser entre 01 e 12'), findsOneWidget);

      // Data no futuro
      await tester.enterText(dataField, '01/01/2099');
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();
      expect(find.text('A data não pode ser no futuro'), findsOneWidget);
    });

    testWidgets('Deve validar formato do E-mail', (WidgetTester tester) async {
      await tester.pumpWidget(createCadastroScreen());

      final emailField = find.byType(TextFormField).at(2);
      await tester.enterText(emailField, 'emailinvalido');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('Deve validar tamanho mínimo da Senha e divergência na confirmação', (WidgetTester tester) async {
      await tester.pumpWidget(createCadastroScreen());

      final senhaField = find.byType(TextFormField).at(3);
      final confSenhaField = find.byType(TextFormField).at(4);

      // Senha menor que 6 caracteres
      await tester.enterText(senhaField, '12345');
      await tester.enterText(confSenhaField, '12345');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);

      // Senhas diferentes
      await tester.enterText(senhaField, 'senha123');
      await tester.enterText(confSenhaField, 'outrasenha');
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });

    testWidgets('Deve validar que o Número residencial é estritamente numérico', (WidgetTester tester) async {
      await tester.pumpWidget(createCadastroScreen());

      final numeroField = find.byType(TextFormField).at(7);
      await tester.ensureVisible(numeroField);
      await tester.enterText(numeroField, 'ABC');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('O número deve ser numérico'), findsOneWidget);
    });
  });

  group('CadastroScreen - Fluxo de Submissão e Persistência', () {
    testWidgets('Deve registrar no Auth e persistir dados no Firestore ao preencher tudo corretamente', (WidgetTester tester) async {
      await tester.pumpWidget(createCadastroScreen());

      // Preenchimento dos campos na ordem que aparecem na árvore de widgets
      await tester.enterText(find.byType(TextFormField).at(0), 'Carlos da Silva'); // Nome
      await tester.enterText(find.byType(TextFormField).at(1), '15/05/1995');      // Data Nasc
      await tester.enterText(find.byType(TextFormField).at(2), 'carlos@teste.com');// Email
      await tester.enterText(find.byType(TextFormField).at(3), '123456');          // Senha
      await tester.enterText(find.byType(TextFormField).at(4), '123456');          // Confirmar Senha
      await tester.enterText(find.byType(TextFormField).at(5), '50000-000');       // CEP

      final ruaField = find.byType(TextFormField).at(6);
      await tester.ensureVisible(ruaField);
      await tester.enterText(ruaField, 'Rua das Flores');

      final numeroField = find.byType(TextFormField).at(7);
      await tester.enterText(numeroField, '120');

      final bairroField = find.byType(TextFormField).at(8);
      await tester.enterText(bairroField, 'Boa Vista');

      final cidadeField = find.byType(TextFormField).at(9);
      await tester.enterText(cidadeField, 'Recife');

      // Seleção do Estado no Dropdown
      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      final estadoOpcao = find.widgetWithText(DropdownMenuItem<String>, 'PE').last;
      await tester.tap(estadoOpcao);
      await tester.pumpAndSettle();

      // Submissão do formulário
      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      // 1. Verifica se o usuário foi criado no Auth mockado
      expect(mockAuth.currentUser, isNotNull);
      expect(mockAuth.currentUser!.email, 'carlos@teste.com');

      // 2. Verifica se o documento correspondente foi gravado no Firestore
      final uid = mockAuth.currentUser!.uid;
      final docSnapshot = await fakeFirestore.collection('usuarios').doc(uid).get();

      expect(docSnapshot.exists, isTrue);
      final data = docSnapshot.data()!;
      expect(data['nome'], 'Carlos da Silva');
      expect(data['data_nasc'], '15/05/1995');
      expect(data['email'], 'carlos@teste.com');
      expect(data['endereco']['rua'], 'Rua das Flores');
      expect(data['endereco']['numero'], '120');
      expect(data['endereco']['bairro'], 'Boa Vista');
      expect(data['endereco']['cidade'], 'Recife');
      expect(data['endereco']['estado'], 'PE');
      expect(data['endereco']['cep'], '50000-000');
    });

    testWidgets('Deve exibir SnackBar com erro caso a autenticação falhe', (WidgetTester tester) async {
      await tester.pumpWidget(createCadastroScreen());

      // Preenche os campos obrigatórios
      await tester.enterText(find.byType(TextFormField).at(0), 'Carlos Silva');
      await tester.enterText(find.byType(TextFormField).at(1), '10/10/1990');
      await tester.enterText(find.byType(TextFormField).at(2), 'carlos@teste.com');
      await tester.enterText(find.byType(TextFormField).at(3), '123456');
      await tester.enterText(find.byType(TextFormField).at(4), '123456');
      await tester.enterText(find.byType(TextFormField).at(5Aqui está a suíte de testes de widget completa em Dart usando `flutter_test`, configurada com `firebase_auth_mocks` e `fake_cloud_firestore`.

Para cobrir a chamada HTTP do ViaCEP sem depender de rede externa e evitar falhas no carregamento do asset de imagem durante a execução do `flutter test`, criamos um mock HTTP com o pacote `http/testing.dart` (ou mockito) e injetamos o ambiente seguro de testes.

### Arquivo: `test/cadastro_screen_test.dart`

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Imports da aplicação
import 'package:sintonize/cadastro.dart'; // Ajuste conforme o caminho do seu arquivo
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/login.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: CadastroScreen(
        auth: mockAuth,
        firestore: fakeFirestore,
      ),
    );
  }

  group('CadastroScreen - Renderização e Estrutura Inicial', () {
    testWidgets('Deve renderizar todos os campos de formulário e botões essenciais',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Data de Nascimento'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Confirmar Senha'), findsOneWidget);
      expect(find.text('CEP'), findsOneWidget);
      expect(find.text('Rua'), findsOneWidget);
      expect(find.text('Número'), findsOneWidget);
      expect(find.text('Bairro'), findsOneWidget);
      expect(find.text('Cidade'), findsOneWidget);
      expect(find.text('Estado'), findsOneWidget);

      expect(find.widgetWithText(ElevatedButton, 'Cadastrar'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Já tem uma conta? Faça login'),
          findsOneWidget);
    });
  });

  group('CadastroScreen - Validações do Formulário', () {
    testWidgets('Deve exibir erros obrigatórios ao tentar submeter formulário em branco',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Rola até o botão de cadastrar e clica
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
    });

    testWidgets('Validações de regras específicas: Nome com caracteres inválidos e Senha curta',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Nome com números/símbolos
      final nomeField = find.ancestor(
        of: find.text('Nome'),
        matching: find.byType(Column),
      );
      await tester.enterText(
          find.descendant(of: nomeField, matching: find.byType(TextFormField)),
          'Marcos 123');

      // Senha curta
      final senhaField = find.ancestor(
        of: find.text('Senha'),
        matching: find.byType(Column),
      );
      await tester.enterText(
          find.descendant(of: senhaField, matching: find.byType(TextFormField)),
          '123');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      expect(
        find.text('O nome não pode conter números ou caracteres especiais'),
        findsOneWidget,
      );
      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('Validações de Formato de E-mail, Data Inválida e Divergência de Senhas',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // E-mail inválido
      final emailField = find.ancestor(
        of: find.text('E-mail'),
        matching: find.byType(Column),
      );
      await tester.enterText(
          find.descendant(of: emailField, matching: find.byType(TextFormField)),
          'emailinvalido.com');

      // Data com formato inválido
      final dataField = find.ancestor(
        of: find.text('Data de Nascimento'),
        matching: find.byType(Column),
      );
      await tester.enterText(
          find.descendant(of: dataField, matching: find.byType(TextFormField)),
          '31022020'); // Formatter irá transformar em 31/02/2020

      // Senhas divergentes
      final senhaField = find.ancestor(
        of: find.text('Senha'),
        matching: find.byType(Column),
      );
      await tester.enterText(
          find.descendant(of: senhaField, matching: find.byType(TextFormField)),
          'senha123');

      final confSenhaField = find.ancestor(
        of: find.text('Confirmar Senha'),
        matching: find.byType(Column),
      );
      await tester.enterText(
          find.descendant(
              of: confSenhaField, matching: find.byType(TextFormField)),
          'senhaDiferente');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('Dia deve ser entre 01 e 29'), findsOneWidget); // Ano bissexto 2020
      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });
  });

  group('CadastroScreen - Fluxo de Sucesso e Navegação', () {
    testWidgets('Preenchimento correto cadastra usuário no Auth e persiste no Firestore',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Helper para preenchimento por label
      Future<void> preencherCampo(String label, String valor) async {
        final campo = find.ancestor(
          of: find.text(label),
          matching: find.byType(Column),
        );
        final input = find.descendant(of: campo, matching: find.byType(TextFormField));
        await tester.ensureVisible(input);
        await tester.enterText(input, valor);
      }

      await preencherCampo('Nome', 'Marcos da Silva');
      await preencherCampo('Data de Nascimento', '15101998'); // Formata para 15/10/1998
      await preencherCampo('E-mail', 'marcos@teste.com');
      await preencherCampo('Senha', 'segredo123');
      await preencherCampo('Confirmar Senha', 'segredo123');
      await preencherCampo('CEP', '51020000'); // Formata para 51020-000
      await preencherCampo('Rua', 'Av Boa Viagem');
      await preencherCampo('Número', '500');
      await preencherCampo('Bairro', 'Boa Viagem');
      await preencherCampo('Cidade', 'Recife');

      // Seleciona Dropdown de Estado
      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      final itemPE = find.widgetWithText(DropdownMenuItem<String>, 'PE').last;
      await tester.tap(itemPE);
      await tester.pumpAndSettle();

      // Clica em cadastrar
      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      // Verifica criação no Auth Mock
      expect(mockAuth.currentUser, isNotNull);
      expect(mockAuth.currentUser!.email, 'marcos@teste.com');

      // Verifica gravação no Firestore Mock
      final uid = mockAuth.currentUser!.uid;
      final docSnapshot =
          await fakeFirestore.collection('usuarios').doc(uid).get();

      expect(docSnapshot.exists, isTrue);
      expect(docSnapshot.data()!['nome'], 'Marcos da Silva');
      expect(docSnapshot.data()!['data_nasc'], '15/10/1998');
      expect(docSnapshot.data()!['endereco']['cidade'], 'Recife');
      expect(docSnapshot.data()!['endereco']['estado'], 'PE');

      // Verifica transição para GenerosCadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
    });

    testWidgets('Toque em "Já tem uma conta? Faça login" deve abrir LoginScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final loginBtn =
          find.widgetWithText(TextButton, 'Já tem uma conta? Faça login');
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}

```

### Configuração necessária no `pubspec.yaml` (dev_dependencies)

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  firebase_auth_mocks: ^0.13.0
  fake_cloud_firestore: ^3.1.0
  http: ^1.2.0

```
````

### Reparo 1 (recusa)

````markdown
Não fui programado para fazer isso. Só consigo gerar texto.
````

### Reparo 2 (recusa)

````markdown
Não fui programado para fazer isso. Só consigo gerar texto.
````

### Reparo 3 (manual)

````markdown
### Classificação da Causa da Falha

**Classificação: (A) O teste presume um comportamento que não é o especificado.**

#### Justificativa

O erro lançado pelo Flutter Test Framework foi:

```text
StateError: Bad state: Too many elements

```

Essa exceção ocorreu porque a estratégia de busca usada no teste (`find.ancestor(of: find.text(...), matching: find.byType(Column))`) encontrou múltiplos widgets `Column` aninhados na árvore hierárquica do Flutter (a `Column` do método `_buildTextField`, a `Column` do `Card`, a `Column` do `Form`, etc.). Quando `find.descendant` ou `tester.enterText` tenta operar sobre essa árvore sem especificar o elemento unívoco, o `WidgetFinder` falha ao tentar extrair um único widget com `.single`.

Além disso:

* A tela possui uma `SingleChildScrollView`, de modo que os campos inferiores e botões precisam ser rolados até a área visível (`ensureVisible`) antes de receberem foco ou cliques.
* A navegação final para `GenerosCadastroScreen` instancia um widget externo que também espera receber os mocks de `auth` e `firestore`.

---

### Correção dos Testes

Abaixo está o arquivo corrigido. Em vez de encadear seletores complexos de `Column`, a busca pelos campos de texto é feita diretamente pelo `TextFormField`, usando a ordem estruturada em que eles são declarados na tela, ou buscando pelo `TextField` irmão imediato dentro do `_buildTextField`:

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// Imports da aplicação
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/login.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: CadastroScreen(
        auth: mockAuth,
        firestore: fakeFirestore,
      ),
    );
  }

  /// Retorna o TextFormField associado a um determinado label de texto
  Finder findFieldByLabel(String label) {
    return find.byWidgetPredicate((widget) {
      if (widget is! TextFormField) return false;
      final element = find.byWidget(widget).evaluate().firstOrNull;
      if (element == null) return false;

      // O _buildTextField coloca o Text e o TextFormField dentro da mesma Column
      final parentColumn = element.findAncestorWidgetOfExactType<Column>();
      if (parentColumn == null) return false;

      return parentColumn.children.any(
        (child) => child is Text && child.data == label,
      );
    });
  }

  group('CadastroScreen - Renderização e Estrutura Inicial', () {
    testWidgets('Deve renderizar todos os campos de formulário e botões essenciais',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Data de Nascimento'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Confirmar Senha'), findsOneWidget);
      expect(find.text('CEP'), findsOneWidget);
      expect(find.text('Rua'), findsOneWidget);
      expect(find.text('Número'), findsOneWidget);
      expect(find.text('Bairro'), findsOneWidget);
      expect(find.text('Cidade'), findsOneWidget);
      expect(find.text('Estado'), findsOneWidget);

      expect(find.widgetWithText(ElevatedButton, 'Cadastrar'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Já tem uma conta? Faça login'),
          findsOneWidget);
    });
  });

  group('CadastroScreen - Validações do Formulário', () {
    testWidgets('Deve exibir erros obrigatórios ao tentar submeter formulário em branco',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

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
    });

    testWidgets('Validações de regras específicas: Nome com caracteres inválidos e Senha curta',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Nome com números
      final nomeField = findFieldByLabel('Nome');
      await tester.ensureVisible(nomeField);
      await tester.enterText(nomeField, 'Marcos 123');

      // Senha curta (< 6 caracteres)
      final senhaField = findFieldByLabel('Senha');
      await tester.ensureVisible(senhaField);
      await tester.enterText(senhaField, '123');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      expect(
        find.text('O nome não pode conter números ou caracteres especiais'),
        findsOneWidget,
      );
      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('Validações de Formato de E-mail, Data Inválida e Divergência de Senhas',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // E-mail inválido
      final emailField = findFieldByLabel('E-mail');
      await tester.ensureVisible(emailField);
      await tester.enterText(emailField, 'emailinvalido.com');

      // Data inválida (dia inexistente para fevereiro)
      final dataField = findFieldByLabel('Data de Nascimento');
      await tester.ensureVisible(dataField);
      await tester.enterText(dataField, '31022020'); // Formatador converte para 31/02/2020

      // Senha e confirmação diferentes
      final senhaField = findFieldByLabel('Senha');
      await tester.ensureVisible(senhaField);
      await tester.enterText(senhaField, 'senha123');

      final confSenhaField = findFieldByLabel('Confirmar Senha');
      await tester.ensureVisible(confSenhaField);
      await tester.enterText(confSenhaField, 'senhaDiferente');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('Dia deve ser entre 01 e 29'), findsOneWidget);
      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });
  });

  group('CadastroScreen - Fluxo de Sucesso e Navegação', () {
    testWidgets('Preenchimento correto cadastra usuário no Auth e persiste no Firestore',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      Future<void> preencherCampo(String label, String valor) async {
        final campo = findFieldByLabel(label);
        await tester.ensureVisible(campo);
        await tester.enterText(campo, valor);
      }

      await preencherCampo('Nome', 'Marcos da Silva');
      await preencherCampo('Data de Nascimento', '15101998');
      await preencherCampo('E-mail', 'marcos@teste.com');
      await preencherCampo('Senha', 'segredo123');
      await preencherCampo('Confirmar Senha', 'segredo123');
      await preencherCampo('CEP', '51020000');
      await preencherCampo('Rua', 'Av Boa Viagem');
      await preencherCampo('Número', '500');
      await preencherCampo('Bairro', 'Boa Viagem');
      await preencherCampo('Cidade', 'Recife');

      // Seleciona o Dropdown de Estado
      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      final itemPE = find.widgetWithText(DropdownMenuItem<String>, 'PE').last;
      await tester.tap(itemPE);
      await tester.pumpAndSettle();

      // Clica em cadastrar
      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      // 1. Verifica criação no Auth
      expect(mockAuth.currentUser, isNotNull);
      expect(mockAuth.currentUser!.email, 'marcos@teste.com');

      // 2. Verifica documento no Firestore
      final uid = mockAuth.currentUser!.uid;
      final docSnapshot =
          await fakeFirestore.collection('usuarios').doc(uid).get();

      expect(docSnapshot.exists, isTrue);
      expect(docSnapshot.data()!['nome'], 'Marcos da Silva');
      expect(docSnapshot.data()!['data_nasc'], '15/10/1998');
      expect(docSnapshot.data()!['endereco']['cidade'], 'Recife');
      expect(docSnapshot.data()!['endereco']['estado'], 'PE');

      // 3. Verifica transição de tela
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
    });

    testWidgets('Toque em "Já tem uma conta? Faça login" deve abrir LoginScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final loginBtn =
          find.widgetWithText(TextButton, 'Já tem uma conta? Faça login');
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}

```
````

