# FASE2-WIDGET-COT-01_CadastroScreen — Réplica Gemini

Rodada **45/60**. Bloco 2 (alvos limpos), lote 9 (`CadastroScreen`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WIDGET-COT-01_CadastroScreen |
| **Função/tela alvo** | `CadastroScreen` |
| **Arquivo(s) de origem** | `lib/cadastro.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/9981ccdf4482094b` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/widget/cadastro_screen_cot_test.dart` |
| **Saídas arquivadas** | `resultados/widget/FASE2-WIDGET-COT-01_iter{0,1,2,3_final}.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/widget/cot/FASE2-WIDGET-COT-01_CadastroScreen.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova — `gemini.google.com/app/9981ccdf4482094b` | Resposta completa |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Não** |
| **Testes gerados** | 10 |
| **Testes passaram (melhor)** | **0/10** |
| **Testes passaram (final, iteração 3)** | **0/10** |
| **Iterações de reparo** | 3 (máximo) |
| **Autoclassificação** | (A), (A), (A) — todas corretas quanto à natureza (erro de teste) |

---

## Iterative Repair Loop

| Iteração | Envio | Resposta | Classificação | Resultado |
|---|---|---|---|---|
| 0 (geração) | automação | análise + mocks + 10 testes; mock de `HttpClient` escrito à mão e mock de asset | — | **não compila** — faltam `dart:async` e `cloud_firestore`; `transform` do mock HTTP com tipo incompatível |
| 1 | **manual (Marcos)**, mesma conversa | arquivo completo; imports adicionados, mock HTTP refeito | **(A)**, correta | **0/10** — 12× `FormatException` ao resolver a imagem (mock do canal `flutter/assets` corrompe o `AssetManifest`) + 5× `Too many elements` (seletor por `Column`) |
| 2 | **manual (Marcos)**, mesma conversa | arquivo completo; troca o mock de canal por `FakeAssetBundle`, seletores por `.first`/índice | **(A)**, correta | **não compila** — removeu `dart:typed_data` que o novo `FakeAssetBundle` usa |
| 3 | automação, mesma conversa | arquivo completo; recoloca `dart:typed_data` | **(A)**, correta | **0/10 (final)** — 14× `UnimplementedError: loadStructuredBinaryData` (o `FakeAssetBundle extends Fake` não implementa o método que o `AssetManifest` chama) + 3 asserções e 1 `No element` |

---

## Observações

1. **O problema que derrubou a suíte foi inventado pelo próprio passo de análise.** Na etapa 2 do COT o modelo afirma que `Image.asset('assets/logo-sintoniza.png')` "gera exceções" em teste e decide mockar o carregador de assets. Não gera: as rodadas 43 e 44, no mesmo alvo, passam sem mock de asset nenhum. Cada versão do mock (canal `flutter/assets`, depois `FakeAssetBundle extends Fake`) quebrou a resolução da imagem em todos os testes, e três reparos foram gastos nesse mock.
2. O mesmo seletor ambíguo por `Column` das rodadas 43 e 44 aparece aqui também (5 testes na iteração 1) — terceira ocorrência independente no alvo.
3. Também inventa infraestrutura para o ViaCEP: `HttpOverrides` com `HttpClient` falso escrito à mão (~100 linhas), onde a ZS e a FS simplesmente não exercitaram o CEP.
4. Regressão na iteração 2 (removeu o import que a própria mudança exigia), já vista no ChatGPT (FASE2-WIDGET-COT-01 da Fase 2 terminou sem compilar).
5. Nenhum (B).
6. ChatGPT na mesma rodada: 24 testes, pico 3/24, final 0 (não compila).

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial

````markdown
Abaixo está o passo a passo completo, cobrindo a análise, a estratégia de mocks, o mapeamento dos cenários de teste e a implementação dos widget tests em Dart.

---

### 1. Análise do Widget

O widget `CadastroScreen` é uma tela de formulário de registro de novos usuários no aplicativo *Sintoniza*. Seus elementos interativos incluem múltiplos campos de texto (`TextFormField` para nome, data de nascimento com máscara dinâmica, e-mail, senha, confirmação de senha, CEP, rua, número, bairro e cidade), um dropdown de seleção de estado (`DropdownButtonFormField`), um botão principal de submissão (`ElevatedButton` "Cadastrar") e um botão de navegação para a tela de login (`TextButton`). O widget interage com a API pública do ViaCEP via requisições HTTP (`http.get`) para autopreenchimento de endereço ao digitar o 9º caractere do CEP, com o `FirebaseAuth` para registrar as credenciais de autenticação, e com o `FirebaseFirestore` para persistir os dados cadastrais sob a coleção `usuarios/{uid}`. Após o cadastro bem-sucedido, ele navega para a tela `GenerosCadastroScreen`.

---

### 2. Identificação das Dependências e Mocks

| Dependência | Pacote / Estratégia de Mock | Como mockar |
| --- | --- | --- |
| **FirebaseAuth** | `firebase_auth_mocks` (`MockFirebaseAuth`) | Injetado diretamente via construtor `CadastroScreen(auth: mockAuth)`. Permite criar usuários em memória e simular instâncias prévias ou falhas. |
| **FirebaseFirestore** | `fake_cloud_firestore` (`FakeFirebaseFirestore`) | Injetado diretamente via construtor `CadastroScreen(firestore: fakeFirestore)`. Grava e lê documentos em memória, permitindo asserções sobre os dados salvos em `usuarios/{uid}`. |
| **HTTP (ViaCEP)** | `package:http/testing.dart` (`MockClient`) ou `HttpOverrides` | Como o método `_fetchAddressFromCEP` chama `http.get` diretamente sem injeção de dependência de client, a interceptação de rede no ambiente de teste do Flutter deve ser feita através de `HttpOverrides.runWithHttpOverrides(...)` ou configurando um `HttpOverrides.global` mockando `HttpClient`, simulando respostas HTTP 200 (com JSON válido ou erro de CEP) e respostas com status de erro (500, 404). |
| **Assets de Imagem** | Mock do carregador de assets do Flutter | Carregar `assets/logo-sintoniza.png` em testes sem bundle gera exceções se o asset não estiver presente. O mock é configurado criando uma imagem transparente 1x1 via bytes padrão ou silenciando o loader com `TestWidgetsFlutterBinding.ensureInitialized()`. |

---

### 3. Cenários de Teste Mapeados

1. **Renderização Básica:**
* Renderização inicial: Verifica a presença da imagem da logo, todos os campos de texto (`Nome`, `Data de Nascimento`, `E-mail`, `Senha`, `Confirmar Senha`, `CEP`, `Rua`, `Número`, `Bairro`, `Cidade`), o dropdown `Estado`, o botão `Cadastrar` e o link `Já tem uma conta? Faça login`.


2. **Validação de Formulário:**
* Submissão com campos obrigatórios vazios: Mensagens de erro de validação devem aparecer para Nome, Data de Nascimento, E-mail, Senha e Número.
* Formatos inválidos:
* Nome com caracteres especiais/números (`"João123"`).
* Data em formato incorreto (`"32/13/2020"`, data futura, ou formato diferente de dd/mm/aaaa).
* E-mail sem formato válido (`"usuario@"`).
* Senha com menos de 6 caracteres.
* Confirmação de senha diferente da senha digitada.
* CEP com formato incorreto.
* Número não numérico.




3. **Interação do Usuário e Máscaras:**
* Inserção de Data: testa a aplicação automática das barras (`dd/mm/aaaa`).
* Inserção de CEP e consulta HTTP com sucesso: preenchimento de 8 dígitos aplica hífen (`12345-678`) e dispara a busca que preenche automaticamente `Rua`, `Bairro`, `Cidade` e `Estado`.
* Consulta de CEP inexistente (`{"erro": true}`): exibe a `SnackBar` com "CEP não encontrado".
* Consulta de CEP com falha de rede/status 500: exibe a `SnackBar` com "Erro ao buscar CEP" ou mensagem de erro.
* Navegação ao tocar em "Já tem uma conta? Faça login": redireciona para `LoginScreen`.


4. **Cenário de Sucesso:**
* Fluxo completo: preenchimento válido de todos os campos, clique em "Cadastrar", criação do usuário no `MockFirebaseAuth`, persistência no `FakeFirebaseFirestore` no caminho `usuarios/{uid}` e navegação para a tela `GenerosCadastroScreen`.


5. **Cenários de Erro (Firebase):**
* Falha de `FirebaseAuthException` (ex: e-mail já em uso ou erro de rede do Firebase): a mensagem do erro deve ser exibida em um `SnackBar`.



---

### 4. Implementação dos Testes Widget (`cadastro_screen_test.dart`)

```dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/login.dart';
import 'package:sintonize/generos-cadastro.dart';

/// Mock do HttpOverrides para interceptar chamadas diretas ao pacote http / dart:io
class TestHttpOverrides extends HttpOverrides {
  final int statusCode;
  final String responseBody;

  TestHttpOverrides({this.statusCode = 200, required this.responseBody});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient(statusCode: statusCode, responseBody: responseBody);
  }
}

class _MockHttpClient implements HttpClient {
  final int statusCode;
  final String responseBody;

  _MockHttpClient({required this.statusCode, required this.responseBody});

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest(statusCode, responseBody);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _MockHttpClientRequest(statusCode, responseBody);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final int statusCode;
  final String responseBody;

  _MockHttpClientRequest(this.statusCode, this.responseBody);

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse(statusCode, responseBody);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  final int statusCode;
  final String responseBody;

  _MockHttpClientResponse(this.statusCode, this.responseBody);

  @override
  int get contentLength => utf8.encode(responseBody).length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  Stream<List<int>> transform<S>(StreamTransformer<List<int>, S> streamTransformer) {
    return Stream.value(utf8.encode(responseBody)).transform(streamTransformer);
  }

  @override
  Stream<List<int>> asBroadcastStream({
    void Function(StreamSubscription<List<int>> subscription)? onListen,
    void Function(StreamSubscription<List<int>> subscription)? onCancel,
  }) {
    return Stream.value(utf8.encode(responseBody)).asBroadcastStream(
      onListen: onListen,
      onCancel: onCancel,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock para asset de imagem 1x1 transparente (evita 404 em Image.asset)
  setUpAll(() {
    final transparentPixel = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ]);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      return ByteData.view(transparentPixel.buffer);
    });
  });

  Widget createWidgetUnderTest({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) {
    return MaterialApp(
      home: CadastroScreen(
        auth: auth ?? MockFirebaseAuth(),
        firestore: firestore ?? FakeFirebaseFirestore(),
      ),
    );
  }

  group('1. Renderização Básica', () {
    testWidgets('Deve renderizar todos os campos de texto, botões e labels corretamente', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
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
      expect(find.widgetWithText(TextButton, 'Já tem uma conta? Faça login'), findsOneWidget);
    });
  });

  group('2. Validação de Formulário', () {
    testWidgets('Deve exibir mensagens de erro ao submeter com campos em branco', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

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

    testWidgets('Deve exibir erros para campos preenchidos com dados inválidos', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Nome com caracteres especiais
      await tester.enterText(find.widgetWithText(TextFormField, '').at(0), 'Lucas 123');

      // Data em formato inválido
      await tester.enterText(find.widgetWithText(TextFormField, '').at(1), '35152030');

      // E-mail inválido
      await tester.enterText(find.widgetWithText(TextFormField, '').at(2), 'email_invalido');

      // Senha curta
      await tester.enterText(find.widgetWithText(TextFormField, '').at(3), '123');

      // Confirmação de senha diferente
      await tester.enterText(find.widgetWithText(TextFormField, '').at(4), '999999');

      // Número não numérico
      final numeroField = find.ancestor(
        of: find.text('Número'),
        matching: find.byType(Column),
      );
      final numeroInput = find.descendant(of: numeroField, matching: find.byType(TextFormField));
      await tester.ensureVisible(numeroInput);
      await tester.enterText(numeroInput, 'A1');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('O nome não pode conter números ou caracteres especiais'), findsOneWidget);
      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.text('As senhas não coincidem'), findsOneWidget);
      expect(find.text('O número deve ser numérico'), findsOneWidget);
    });

    testWidgets('Deve validar que data de nascimento não pode estar no futuro', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final dataField = find.widgetWithText(TextFormField, '').at(1);
      // Preenche 01/01/2099
      await tester.enterText(dataField, '01012099');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      expect(find.text('A data não pode ser no futuro'), findsOneWidget);
    });
  });

  group('3. Interação do Usuário e Integração HTTP (ViaCEP)', () {
    testWidgets('Deve formatar a data automaticamente com barras ao digitar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final dataField = find.widgetWithText(TextFormField, '').at(1);
      await tester.enterText(dataField, '10101995');
      await tester.pump();

      expect(find.text('10/10/1995'), findsOneWidget);
    });

    testWidgets('Deve buscar o CEP e preencher os dados de endereço quando o CEP tiver 9 dígitos', (tester) async {
      final viaCepJson = jsonEncode({
        "cep": "50000-000",
        "logradouro": "Avenida Boa Viagem",
        "bairro": "Boa Viagem",
        "localidade": "Recife",
        "uf": "PE"
      });

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        final cepField = find.ancestor(
          of: find.text('CEP'),
          matching: find.byType(Column),
        );
        final cepInput = find.descendant(of: cepField, matching: find.byType(TextFormField));
        await tester.ensureVisible(cepInput);
        
        // Digita 8 dígitos (o formatter adiciona o hífen, totalizando 9 caracteres)
        await tester.enterText(cepInput, '50000000');
        await tester.pumpAndSettle();

        expect(find.text('Avenida Boa Viagem'), findsOneWidget);
        expect(find.text('Boa Viagem'), findsOneWidget);
        expect(find.text('Recife'), findsOneWidget);
        expect(find.text('PE'), findsWidgets);
      }, TestHttpOverrides(statusCode: 200, responseBody: viaCepJson));
    });

    testWidgets('Deve mostrar SnackBar quando CEP não for encontrado pelo ViaCEP', (tester) async {
      final viaCepJsonError = jsonEncode({"erro": "true"});

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        final cepField = find.ancestor(
          of: find.text('CEP'),
          matching: find.byType(Column),
        );
        final cepInput = find.descendant(of: cepField, matching: find.byType(TextFormField));
        await tester.ensureVisible(cepInput);
        await tester.enterText(cepInput, '99999999');
        await tester.pumpAndSettle();

        expect(find.text('CEP não encontrado'), findsOneWidget);
      }, TestHttpOverrides(statusCode: 200, responseBody: viaCepJsonError));
    });

    testWidgets('Deve navegar para LoginScreen ao clicar em "Já tem uma conta? Faça login"', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final loginBtn = find.widgetWithText(TextButton, 'Já tem uma conta? Faça login');
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('4. Cenário de Sucesso', () {
    testWidgets('Deve registrar no Auth, salvar no Firestore e navegar para GenerosCadastroScreen', (tester) async {
      final mockAuth = MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(createWidgetUnderTest(
          auth: mockAuth,
          firestore: fakeFirestore,
        ));

        // Preenche Nome
        await tester.enterText(find.widgetWithText(TextFormField, '').at(0), 'Carlos Silva');

        // Preenche Data de Nascimento
        await tester.enterText(find.widgetWithText(TextFormField, '').at(1), '15051990');

        // Preenche E-mail
        await tester.enterText(find.widgetWithText(TextFormField, '').at(2), 'carlos@teste.com');

        // Preenche Senha e Confirmação
        await tester.enterText(find.widgetWithText(TextFormField, '').at(3), '123456');
        await tester.enterText(find.widgetWithText(TextFormField, '').at(4), '123456');

        // Preenche CEP
        final cepField = find.ancestor(of: find.text('CEP'), matching: find.byType(Column));
        final cepInput = find.descendant(of: cepField, matching: find.byType(TextFormField));
        await tester.ensureVisible(cepInput);
        await tester.enterText(cepInput, '50000000');
        await tester.pumpAndSettle();

        // Preenche Número
        final numField = find.ancestor(of: find.text('Número'), matching: find.byType(Column));
        final numInput = find.descendant(of: numField, matching: find.byType(TextFormField));
        await tester.ensureVisible(numInput);
        await tester.enterText(numInput, '100');

        // Seleciona Estado
        final dropdown = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdown);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('PE').last);
        await tester.pumpAndSettle();

        // Clica em Cadastrar
        final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarBtn);
        await tester.tap(cadastrarBtn);
        await tester.pumpAndSettle();

        // 1. Verifica se o usuário foi criado no Auth
        expect(mockAuth.currentUser, isNotNull);
        expect(mockAuth.currentUser!.email, 'carlos@teste.com');

        // 2. Verifica se os dados foram salvos no Firestore
        final snapshot = await fakeFirestore
            .collection('usuarios')
            .doc(mockAuth.currentUser!.uid)
            .get();

        expect(snapshot.exists, isTrue);
        expect(snapshot.data()?['nome'], 'Carlos Silva');
        expect(snapshot.data()?['email'], 'carlos@teste.com');
        expect(snapshot.data()?['endereco']['numero'], '100');

        // 3. Verifica se navegou para GenerosCadastroScreen
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      }, TestHttpOverrides(
        statusCode: 200,
        responseBody: jsonEncode({
          "cep": "50000-000",
          "logradouro": "Rua Teste",
          "bairro": "Bairro Teste",
          "localidade": "Recife",
          "uf": "PE"
        }),
      ));
    });
  });

  group('5. Cenários de Erro (Firebase)', () {
    testWidgets('Deve exibir SnackBar com a mensagem de erro quando FirebaseAuth falhar', (tester) async {
      // Cria um MockFirebaseAuth com um usuário já existente para forçar erro de email duplicado
      final mockAuth = MockFirebaseAuth(
        mockUser: MockUser(
          isAnonymous: false,
          uid: 'existente_uid',
          email: 'existente@teste.com',
        ),
      );
      final fakeFirestore = FakeFirebaseFirestore();

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(createWidgetUnderTest(
          auth: mockAuth,
          firestore: fakeFirestore,
        ));

        // Preenche com o e-mail que já existe
        await tester.enterText(find.widgetWithText(TextFormField, '').at(0), 'Usuario Teste');
        await tester.enterText(find.widgetWithText(TextFormField, '').at(1), '10101990');
        await tester.enterText(find.widgetWithText(TextFormField, '').at(2), 'existente@teste.com');
        await tester.enterText(find.widgetWithText(TextFormField, '').at(3), '123456');
        await tester.enterText(find.widgetWithText(TextFormField, '').at(4), '123456');

        final cepField = find.ancestor(of: find.text('CEP'), matching: find.byType(Column));
        final cepInput = find.descendant(of: cepField, matching: find.byType(TextFormField));
        await tester.ensureVisible(cepInput);
        await tester.enterText(cepInput, '50000000');
        await tester.pumpAndSettle();

        final numField = find.ancestor(of: find.text('Número'), matching: find.byType(Column));
        final numInput = find.descendant(of: numField, matching: find.byType(TextFormField));
        await tester.ensureVisible(numInput);
        await tester.enterText(numInput, '42');

        final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarBtn);
        await tester.tap(cadastrarBtn);
        await tester.pumpAndSettle();

        // O MockFirebaseAuth lança FirebaseAuthException(code: 'email-already-in-use')
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('Erro ao cadastrar:'), findsOneWidget);
      }, TestHttpOverrides(
        statusCode: 200,
        responseBody: jsonEncode({
          "cep": "50000-000",
          "logradouro": "Rua Teste",
          "bairro": "Bairro Teste",
          "localidade": "Recife",
          "uf": "PE"
        }),
      ));
    });
  });
}

```
````

### Reparo 1 (manual)

````markdown
### Classificação da causa da falha:

**(A) O teste presume um comportamento que não é o especificado** *(especificamente, erros de compilação no próprio arquivo de teste gerado)*.

**Justificativa:**

A falha ocorreu durante a compilação do arquivo de teste (`test/fase2-gemini/widget/cadastro_screen_cot_test.dart`) antes mesmo de executar qualquer linha de teste ou interagir com o widget. Os erros foram decorrentes de:

1. Ausência do `import 'dart:async';` (fazendo com que `StreamTransformer` e `StreamSubscription` não fossem reconhecidos).
2. Ausência do `import 'package:cloud_firestore/cloud_firestore.dart';` (fazendo com que o tipo `FirebaseFirestore` não fosse encontrado).
3. Assinatura tipada do método `transform<S>` em `_MockHttpClientResponse` incompatível com o contrato de `Stream<List<int>>`. Em vez de reimplementar manualmente a hierarquia de `HttpClient` e `Stream`, a maneira idiomática e segura no Dart é estender `StreamView<List<int>>` para a resposta HTTP ou simplificar o mock.

---

### Código de Testes Corrigido

Aqui está o arquivo completo devidamente corrigido, com as importações adicionadas e a estrutura de mock HTTP corrigida e simplificada:

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/login.dart';
import 'package:sintonize/generos-cadastro.dart';

/// Mock de HttpOverrides para interceptar chamadas HTTP locais no widget test
class TestHttpOverrides extends HttpOverrides {
  final int statusCode;
  final String responseBody;

  TestHttpOverrides({this.statusCode = 200, required this.responseBody});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient(statusCode: statusCode, responseBody: responseBody);
  }
}

class _MockHttpClient implements HttpClient {
  final int statusCode;
  final String responseBody;

  _MockHttpClient({required this.statusCode, required this.responseBody});

  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _MockHttpClientRequest(statusCode, responseBody);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _MockHttpClientRequest(statusCode, responseBody);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final int statusCode;
  final String responseBody;

  _MockHttpClientRequest(this.statusCode, this.responseBody);

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async =>
      _MockHttpClientResponse(statusCode, responseBody);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Delegando via StreamView para evitar problemas de herança de Stream.transform
class _MockHttpClientResponse extends StreamView<List<int>> implements HttpClientResponse {
  @override
  final int statusCode;
  final String responseBody;

  _MockHttpClientResponse(this.statusCode, this.responseBody)
      : super(Stream.value(utf8.encode(responseBody)));

  @override
  int get contentLength => utf8.encode(responseBody).length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock para asset de imagem 1x1 transparente (evita erro ao carregar logo-sintoniza.png)
  setUpAll(() {
    final transparentPixel = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ]);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      return ByteData.view(transparentPixel.buffer);
    });
  });

  Widget createWidgetUnderTest({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) {
    return MaterialApp(
      home: CadastroScreen(
        auth: auth ?? MockFirebaseAuth(),
        firestore: firestore ?? FakeFirebaseFirestore(),
      ),
    );
  }

  group('1. Renderização Básica', () {
    testWidgets('Deve renderizar todos os campos de texto, botões e labels corretamente', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
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
      expect(find.widgetWithText(TextButton, 'Já tem uma conta? Faça login'), findsOneWidget);
    });
  });

  group('2. Validação de Formulário', () {
    testWidgets('Deve exibir mensagens de erro ao submeter com campos em branco', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

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

    testWidgets('Deve exibir erros para campos preenchidos com dados inválidos', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Nome com números
      await tester.enterText(find.widgetWithText(TextFormField, '').at(0), 'Lucas 123');

      // Data inválida
      await tester.enterText(find.widgetWithText(TextFormField, '').at(1), '35152030');

      // E-mail inválido
      await tester.enterText(find.widgetWithText(TextFormField, '').at(2), 'email_invalido');

      // Senha curta
      await tester.enterText(find.widgetWithText(TextFormField, '').at(3), '123');

      // Confirmação não coincidente
      await tester.enterText(find.widgetWithText(TextFormField, '').at(4), '999999');

      // Número inválido
      final numeroField = find.ancestor(
        of: find.text('Número'),
        matching: find.byType(Column),
      );
      final numeroInput = find.descendant(of: numeroField, matching: find.byType(TextFormField));
      await tester.ensureVisible(numeroInput);
      await tester.enterText(numeroInput, 'A1');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('O nome não pode conter números ou caracteres especiais'), findsOneWidget);
      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.text('As senhas não coincidem'), findsOneWidget);
      expect(find.text('O número deve ser numérico'), findsOneWidget);
    });

    testWidgets('Deve validar que data de nascimento não pode estar no futuro', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final dataField = find.widgetWithText(TextFormField, '').at(1);
      await tester.enterText(dataField, '01012099');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      expect(find.text('A data não pode ser no futuro'), findsOneWidget);
    });
  });

  group('3. Interação do Usuário e Integração HTTP (ViaCEP)', () {
    testWidgets('Deve formatar a data automaticamente com barras ao digitar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final dataField = find.widgetWithText(TextFormField, '').at(1);
      await tester.enterText(dataField, '10101995');
      await tester.pump();

      expect(find.text('10/10/1995'), findsOneWidget);
    });

    testWidgets('Deve buscar o CEP e preencher os dados de endereço quando o CEP tiver 9 dígitos', (tester) async {
      final viaCepJson = jsonEncode({
        "cep": "50000-000",
        "logradouro": "Avenida Boa Viagem",
        "bairro": "Boa Viagem",
        "localidade": "Recife",
        "uf": "PE"
      });

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        final cepField = find.ancestor(
          of: find.text('CEP'),
          matching: find.byType(Column),
        );
        final cepInput = find.descendant(of: cepField, matching: find.byType(TextFormField));
        await tester.ensureVisible(cepInput);

        await tester.enterText(cepInput, '50000000');
        await tester.pumpAndSettle();

        expect(find.text('Avenida Boa Viagem'), findsOneWidget);
        expect(find.text('Boa Viagem'), findsOneWidget);
        expect(find.text('Recife'), findsOneWidget);
        expect(find.text('PE'), findsWidgets);
      }, TestHttpOverrides(statusCode: 200, responseBody: viaCepJson));
    });

    testWidgets('Deve mostrar SnackBar quando CEP não for encontrado pelo ViaCEP', (tester) async {
      final viaCepJsonError = jsonEncode({"erro": true});

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        final cepField = find.ancestor(
          of: find.text('CEP'),
          matching: find.byType(Column),
        );
        final cepInput = find.descendant(of: cepField, matching: find.byType(TextFormField));
        await tester.ensureVisible(cepInput);
        await tester.enterText(cepInput, '99999999');
        await tester.pumpAndSettle();

        expect(find.text('CEP não encontrado'), findsOneWidget);
      }, TestHttpOverrides(statusCode: 200, responseBody: viaCepJsonError));
    });

    testWidgets('Deve navegar para LoginScreen ao clicar em "Já tem uma conta? Faça login"', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final loginBtn = find.widgetWithText(TextButton, 'Já tem uma conta? Faça login');
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('4. Cenário de Sucesso', () {
    testWidgets('Deve registrar no Auth, salvar no Firestore e navegar para GenerosCadastroScreen', (tester) async {
      final mockAuth = MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(createWidgetUnderTest(
          auth: mockAuth,
          firestore: fakeFirestore,
        ));

        // Preenche Nome
        await tester.enterText(find.widgetWithText(TextFormField, '').at(0), 'Carlos Silva');

        // Preenche Data de Nascimento
        await tester.enterText(find.widgetWithText(TextFormField, '').at(1), '15051990');

        // Preenche E-mail
        await tester.enterText(find.widgetWithText(TextFormField, '').at(2), 'carlos@teste.com');

        // Preenche Senha e Confirmação
        await tester.enterText(find.widgetWithText(TextFormField, '').at(3), '123456');
        await tester.enterText(find.widgetWithText(TextFormField, '').at(4), '123456');

        // Preenche CEP
        final cepField = find.ancestor(of: find.text('CEP'), matching: find.byType(Column));
        final cepInput = find.descendant(of: cepField, matching: find.byType(TextFormField));
        await tester.ensureVisible(cepInput);
        await tester.enterText(cepInput, '50000000');
        await tester.pumpAndSettle();

        // Preenche Número
        final numField = find.ancestor(of: find.text('Número'), matching: find.byType(Column));
        final numInput = find.descendant(of: numField, matching: find.byType(TextFormField));
        await tester.ensureVisible(numInput);
        await tester.enterText(numInput, '100');

        // Seleciona Estado
        final dropdown = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdown);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('PE').last);
        await tester.pumpAndSettle();

        // Clica em Cadastrar
        final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarBtn);
        await tester.tap(cadastrarBtn);
        await tester.pumpAndSettle();

        // 1. Verifica no Auth
        expect(mockAuth.currentUser, isNotNull);
        expect(mockAuth.currentUser!.email, 'carlos@teste.com');

        // 2. Verifica no Firestore
        final snapshot = await fakeFirestore
            .collection('usuarios')
            .doc(mockAuth.currentUser!.uid)
            .get();

        expect(snapshot.exists, isTrue);
        expect(snapshot.data()?['nome'], 'Carlos Silva');
        expect(snapshot.data()?['email'], 'carlos@teste.com');
        expect(snapshot.data()?['endereco']['numero'], '100');

        // 3. Verifica navegação
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      }, TestHttpOverrides(
        statusCode: 200,
        responseBody: jsonEncode({
          "cep": "50000-000",
          "logradouro": "Rua Teste",
          "bairro": "Bairro Teste",
          "localidade": "Recife",
          "uf": "PE"
        }),
      ));
    });
  });

  group('5. Cenários de Erro (Firebase)', () {
    testWidgets('Deve exibir SnackBar com a mensagem de erro quando FirebaseAuth falhar', (tester) async {
      final mockAuth = MockFirebaseAuth(
        mockUser: MockUser(
          isAnonymous: false,
          uid: 'existente_uid',
          email: 'existente@teste.com',
        ),
      );
      final fakeFirestore = FakeFirebaseFirestore();

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(createWidgetUnderTest(
          auth: mockAuth,
          firestore: fakeFirestore,
        ));

        await tester.enterText(find.widgetWithText(TextFormField, '').at(0), 'Usuario Teste');
        await tester.enterText(find.widgetWithText(TextFormField, '').at(1), '10101990');
        await tester.enterText(find.widgetWithText(TextFormField, '').at(2), 'existente@teste.com');
        await tester.enterText(find.widgetWithText(TextFormField, '').at(3), '123456');
        await tester.enterText(find.widgetWithText(TextFormField, '').at(4), '123456');

        final cepField = find.ancestor(of: find.text('CEP'), matching: find.byType(Column));
        final cepInput = find.descendant(of: cepField, matching: find.byType(TextFormField));
        await tester.ensureVisible(cepInput);
        await tester.enterText(cepInput, '50000000');
        await tester.pumpAndSettle();

        final numField = find.ancestor(of: find.text('Número'), matching: find.byType(Column));
        final numInput = find.descendant(of: numField, matching: find.byType(TextFormField));
        await tester.ensureVisible(numInput);
        await tester.enterText(numInput, '42');

        final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarBtn);
        await tester.tap(cadastrarBtn);
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('Erro ao cadastrar:'), findsOneWidget);
      }, TestHttpOverrides(
        statusCode: 200,
        responseBody: jsonEncode({
          "cep": "50000-000",
          "logradouro": "Rua Teste",
          "bairro": "Bairro Teste",
          "localidade": "Recife",
          "uf": "PE"
        }),
      ));
    });
  });
}

```
````

### Reparo 2 (manual)

````markdown
### Classificação da causa da falha:

**(A) O teste presume um comportamento que não é o especificado** *(erros de infraestrutura e seletores nos testes)*.

**Justificativa:**

Os testes falharam devido a dois problemas de implementação no próprio arquivo de teste:

1. **Mock de Asset / Imagem:** A tentativa de interceptar o canal `flutter/assets` retornando bytes PNG brutos falhou no Flutter moderno (`FormatException: Message corrupted`), pois o Flutter espera uma mensagem decodificável pelo `StandardMessageCodec` para o `AssetManifestBin`. No ambiente de testes de widget, a abordagem idiomática e segura não requer sobrescrever `flutter/assets` — basta configurar `binding.defaultBinaryMessenger` de forma transparente ou usar uma `DefaultAssetBundle` com um mock simples, ou silenciar o erro de carregamento sem corromper o `AssetManifest`.
2. **`Bad state: Too many elements` ao chamar `tester.ensureVisible()`:** O seletor `find.descendant(of: cepField, matching: find.byType(TextFormField))` e seletores similares encontraram mais de um elemento correspondente (porque dentro de cada `_buildTextField` existe o `TextFormField` e internamente ele contém outros nós/subwidgets, ou porque `find.ancestor` casou com múltiplos `Column` pai). Quando `ensureVisible(finder)` recebe um finder com múltiplos elementos, lança `StateError: Bad state: Too many elements`. A correção é direcionar o finder diretamente ao `TextFormField` correspondente pelo índice ordinal de renderização ou usar `.first`.

---

### Código de Testes Corrigido

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/login.dart';
import 'package:sintonize/generos-cadastro.dart';

/// Mock de HttpOverrides para interceptar chamadas HTTP locais no widget test
class TestHttpOverrides extends HttpOverrides {
  final int statusCode;
  final String responseBody;

  TestHttpOverrides({this.statusCode = 200, required this.responseBody});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient(statusCode: statusCode, responseBody: responseBody);
  }
}

class _MockHttpClient implements HttpClient {
  final int statusCode;
  final String responseBody;

  _MockHttpClient({required this.statusCode, required this.responseBody});

  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _MockHttpClientRequest(statusCode, responseBody);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _MockHttpClientRequest(statusCode, responseBody);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final int statusCode;
  final String responseBody;

  _MockHttpClientRequest(this.statusCode, this.responseBody);

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async =>
      _MockHttpClientResponse(statusCode, responseBody);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse extends StreamView<List<int>>
    implements HttpClientResponse {
  @override
  final int statusCode;
  final String responseBody;

  _MockHttpClientResponse(this.statusCode, this.responseBody)
      : super(Stream.value(utf8.encode(responseBody)));

  @override
  int get contentLength => utf8.encode(responseBody).length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake AssetBundle para fornecer assets válidos ou vazios sem quebrar o AssetManifest
class FakeAssetBundle extends Fake implements AssetBundle {
  @override
  Future<ByteData> load(String key) async {
    // Retorna imagem PNG 1x1 válida codificada em binário
    final pngBytes = [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ];
    return ByteData.view(Uint8List.fromList(pngBytes).buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => '';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Ordem dos campos na tela:
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

  Widget createWidgetUnderTest({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) {
    return DefaultAssetBundle(
      bundle: FakeAssetBundle(),
      child: MaterialApp(
        home: CadastroScreen(
          auth: auth ?? MockFirebaseAuth(),
          firestore: firestore ?? FakeFirebaseFirestore(),
        ),
      ),
    );
  }

  group('1. Renderização Básica', () {
    testWidgets('Deve renderizar todos os campos de texto, botões e labels corretamente', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
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
      expect(find.widgetWithText(TextButton, 'Já tem uma conta? Faça login'), findsOneWidget);
    });
  });

  group('2. Validação de Formulário', () {
    testWidgets('Deve exibir mensagens de erro ao submeter com campos em branco', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

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

    testWidgets('Deve exibir erros para campos preenchidos com dados inválidos', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Nome com números (índice 0)
      await tester.enterText(find.byType(TextFormField).at(0), 'Lucas 123');

      // Data inválida (índice 1)
      await tester.enterText(find.byType(TextFormField).at(1), '35152030');

      // E-mail inválido (índice 2)
      await tester.enterText(find.byType(TextFormField).at(2), 'email_invalido');

      // Senha curta (índice 3)
      await tester.enterText(find.byType(TextFormField).at(3), '123');

      // Confirmação não coincidente (índice 4)
      await tester.enterText(find.byType(TextFormField).at(4), '999999');

      // Número não numérico (índice 7)
      final numeroInput = find.byType(TextFormField).at(7);
      await tester.ensureVisible(numeroInput);
      await tester.enterText(numeroInput, 'A1');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('O nome não pode conter números ou caracteres especiais'), findsOneWidget);
      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.text('As senhas não coincidem'), findsOneWidget);
      expect(find.text('O número deve ser numérico'), findsOneWidget);
    });

    testWidgets('Deve validar que data de nascimento não pode estar no futuro', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final dataField = find.byType(TextFormField).at(1);
      await tester.enterText(dataField, '01012099');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      expect(find.text('A data não pode ser no futuro'), findsOneWidget);
    });
  });

  group('3. Interação do Usuário e Integração HTTP (ViaCEP)', () {
    testWidgets('Deve formatar a data automaticamente com barras ao digitar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final dataField = find.byType(TextFormField).at(1);
      await tester.enterText(dataField, '10101995');
      await tester.pump();

      expect(find.text('10/10/1995'), findsOneWidget);
    });

    testWidgets('Deve buscar o CEP e preencher os dados de endereço quando o CEP tiver 9 dígitos', (tester) async {
      final viaCepJson = jsonEncode({
        "cep": "50000-000",
        "logradouro": "Avenida Boa Viagem",
        "bairro": "Boa Viagem",
        "localidade": "Recife",
        "uf": "PE"
      });

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Campo CEP (índice 5)
        final cepInput = find.byType(TextFormField).at(5);
        await tester.ensureVisible(cepInput);

        await tester.enterText(cepInput, '50000000');
        await tester.pumpAndSettle();

        expect(find.text('Avenida Boa Viagem'), findsOneWidget);
        expect(find.text('Boa Viagem'), findsOneWidget);
        expect(find.text('Recife'), findsOneWidget);
        expect(find.text('PE'), findsWidgets);
      }, TestHttpOverrides(statusCode: 200, responseBody: viaCepJson));
    });

    testWidgets('Deve mostrar SnackBar quando CEP não for encontrado pelo ViaCEP', (tester) async {
      final viaCepJsonError = jsonEncode({"erro": true});

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        final cepInput = find.byType(TextFormField).at(5);
        await tester.ensureVisible(cepInput);
        await tester.enterText(cepInput, '99999999');
        await tester.pumpAndSettle();

        expect(find.text('CEP não encontrado'), findsOneWidget);
      }, TestHttpOverrides(statusCode: 200, responseBody: viaCepJsonError));
    });

    testWidgets('Deve navegar para LoginScreen ao clicar em "Já tem uma conta? Faça login"', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final loginBtn = find.widgetWithText(TextButton, 'Já tem uma conta? Faça login');
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('4. Cenário de Sucesso', () {
    testWidgets('Deve registrar no Auth, salvar no Firestore e navegar para GenerosCadastroScreen', (tester) async {
      final mockAuth = MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(createWidgetUnderTest(
          auth: mockAuth,
          firestore: fakeFirestore,
        ));

        // Nome (0)
        await tester.enterText(find.byType(TextFormField).at(0), 'Carlos Silva');

        // Data de Nascimento (1)
        await tester.enterText(find.byType(TextFormField).at(1), '15051990');

        // E-mail (2)
        await tester.enterText(find.byType(TextFormField).at(2), 'carlos@teste.com');

        // Senha (3) e Confirmar Senha (4)
        await tester.enterText(find.byType(TextFormField).at(3), '123456');
        await tester.enterText(find.byType(TextFormField).at(4), '123456');

        // CEP (5)
        final cepInput = find.byType(TextFormField).at(5);
        await tester.ensureVisible(cepInput);
        await tester.enterText(cepInput, '50000000');
        await tester.pumpAndSettle();

        // Número (7)
        final numInput = find.byType(TextFormField).at(7);
        await tester.ensureVisible(numInput);
        await tester.enterText(numInput, '100');

        // Seleciona Estado
        final dropdown = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdown);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('PE').last);
        await tester.pumpAndSettle();

        // Cadastrar
        final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarBtn);
        await tester.tap(cadastrarBtn);
        await tester.pumpAndSettle();

        // Asserções
        expect(mockAuth.currentUser, isNotNull);
        expect(mockAuth.currentUser!.email, 'carlos@teste.com');

        final snapshot = await fakeFirestore
            .collection('usuarios')
            .doc(mockAuth.currentUser!.uid)
            .get();

        expect(snapshot.exists, isTrue);
        expect(snapshot.data()?['nome'], 'Carlos Silva');
        expect(snapshot.data()?['email'], 'carlos@teste.com');
        expect(snapshot.data()?['endereco']['numero'], '100');

        expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      }, TestHttpOverrides(
        statusCode: 200,
        responseBody: jsonEncode({
          "cep": "50000-000",
          "logradouro": "Rua Teste",
          "bairro": "Bairro Teste",
          "localidade": "Recife",
          "uf": "PE"
        }),
      ));
    });
  });

  group('5. Cenários de Erro (Firebase)', () {
    testWidgets('Deve exibir SnackBar com a mensagem de erro quando FirebaseAuth falhar', (tester) async {
      final mockAuth = MockFirebaseAuth(
        mockUser: MockUser(
          isAnonymous: false,
          uid: 'existente_uid',
          email: 'existente@teste.com',
        ),
      );
      final fakeFirestore = FakeFirebaseFirestore();

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(createWidgetUnderTest(
          auth: mockAuth,
          firestore: fakeFirestore,
        ));

        // Preenche com e-mail já existente
        await tester.enterText(find.byType(TextFormField).at(0), 'Usuario Teste');
        await tester.enterText(find.byType(TextFormField).at(1), '10101990');
        await tester.enterText(find.byType(TextFormField).at(2), 'existente@teste.com');
        await tester.enterText(find.byType(TextFormField).at(3), '123456');
        await tester.enterText(find.byType(TextFormField).at(4), '123456');

        final cepInput = find.byType(TextFormField).at(5);
        await tester.ensureVisible(cepInput);
        await tester.enterText(cepInput, '50000000');
        await tester.pumpAndSettle();

        final numInput = find.byType(TextFormField).at(7);
        await tester.ensureVisible(numInput);
        await tester.enterText(numInput, '42');

        final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarBtn);
        await tester.tap(cadastrarBtn);
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('Erro ao cadastrar:'), findsOneWidget);
      }, TestHttpOverrides(
        statusCode: 200,
        responseBody: jsonEncode({
          "cep": "50000-000",
          "logradouro": "Rua Teste",
          "bairro": "Bairro Teste",
          "localidade": "Recife",
          "uf": "PE"
        }),
      ));
    });
  });
}

```
````

### Reparo 3

````markdown
### Classificação da causa da falha:

**(A) O teste presume um comportamento que não é o especificado** *(especificamente, erro de compilação por falta do import `dart:typed_data` no arquivo de teste)*.

**Justificativa:**

A falha ocorreu antes da execução de qualquer teste ou de qualquer linha de lógica do widget. O compilador do Dart não encontrou as declarações dos tipos `ByteData` e `Uint8List` na classe `FakeAssetBundle` porque o import `import 'dart:typed_data';` foi omitido no topo do arquivo de teste.

---

### Código de Testes Corrigido

Adicionado `import 'dart:typed_data';` no topo do arquivo:

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/login.dart';
import 'package:sintonize/generos-cadastro.dart';

/// Mock de HttpOverrides para interceptar chamadas HTTP locais no widget test
class TestHttpOverrides extends HttpOverrides {
  final int statusCode;
  final String responseBody;

  TestHttpOverrides({this.statusCode = 200, required this.responseBody});

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient(statusCode: statusCode, responseBody: responseBody);
  }
}

class _MockHttpClient implements HttpClient {
  final int statusCode;
  final String responseBody;

  _MockHttpClient({required this.statusCode, required this.responseBody});

  @override
  Future<HttpClientRequest> getUrl(Uri url) async =>
      _MockHttpClientRequest(statusCode, responseBody);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _MockHttpClientRequest(statusCode, responseBody);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final int statusCode;
  final String responseBody;

  _MockHttpClientRequest(this.statusCode, this.responseBody);

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async =>
      _MockHttpClientResponse(statusCode, responseBody);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse extends StreamView<List<int>>
    implements HttpClientResponse {
  @override
  final int statusCode;
  final String responseBody;

  _MockHttpClientResponse(this.statusCode, this.responseBody)
      : super(Stream.value(utf8.encode(responseBody)));

  @override
  int get contentLength => utf8.encode(responseBody).length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake AssetBundle para fornecer assets válidos sem corromper o AssetManifest
class FakeAssetBundle extends Fake implements AssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final pngBytes = [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ];
    return ByteData.view(Uint8List.fromList(pngBytes).buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => '';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Ordem dos campos na tela:
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

  Widget createWidgetUnderTest({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) {
    return DefaultAssetBundle(
      bundle: FakeAssetBundle(),
      child: MaterialApp(
        home: CadastroScreen(
          auth: auth ?? MockFirebaseAuth(),
          firestore: firestore ?? FakeFirebaseFirestore(),
        ),
      ),
    );
  }

  group('1. Renderização Básica', () {
    testWidgets('Deve renderizar todos os campos de texto, botões e labels corretamente', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
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
      expect(find.widgetWithText(TextButton, 'Já tem uma conta? Faça login'), findsOneWidget);
    });
  });

  group('2. Validação de Formulário', () {
    testWidgets('Deve exibir mensagens de erro ao submeter com campos em branco', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

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

    testWidgets('Deve exibir erros para campos preenchidos com dados inválidos', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Nome com números (índice 0)
      await tester.enterText(find.byType(TextFormField).at(0), 'Lucas 123');

      // Data inválida (índice 1)
      await tester.enterText(find.byType(TextFormField).at(1), '35152030');

      // E-mail inválido (índice 2)
      await tester.enterText(find.byType(TextFormField).at(2), 'email_invalido');

      // Senha curta (índice 3)
      await tester.enterText(find.byType(TextFormField).at(3), '123');

      // Confirmação não coincidente (índice 4)
      await tester.enterText(find.byType(TextFormField).at(4), '999999');

      // Número não numérico (índice 7)
      final numeroInput = find.byType(TextFormField).at(7);
      await tester.ensureVisible(numeroInput);
      await tester.enterText(numeroInput, 'A1');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('O nome não pode conter números ou caracteres especiais'), findsOneWidget);
      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.text('As senhas não coincidem'), findsOneWidget);
      expect(find.text('O número deve ser numérico'), findsOneWidget);
    });

    testWidgets('Deve validar que data de nascimento não pode estar no futuro', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final dataField = find.byType(TextFormField).at(1);
      await tester.enterText(dataField, '01012099');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      expect(find.text('A data não pode ser no futuro'), findsOneWidget);
    });
  });

  group('3. Interação do Usuário e Integração HTTP (ViaCEP)', () {
    testWidgets('Deve formatar a data automaticamente com barras ao digitar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final dataField = find.byType(TextFormField).at(1);
      await tester.enterText(dataField, '10101995');
      await tester.pump();

      expect(find.text('10/10/1995'), findsOneWidget);
    });

    testWidgets('Deve buscar o CEP e preencher os dados de endereço quando o CEP tiver 9 dígitos', (tester) async {
      final viaCepJson = jsonEncode({
        "cep": "50000-000",
        "logradouro": "Avenida Boa Viagem",
        "bairro": "Boa Viagem",
        "localidade": "Recife",
        "uf": "PE"
      });

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Campo CEP (índice 5)
        final cepInput = find.byType(TextFormField).at(5);
        await tester.ensureVisible(cepInput);

        await tester.enterText(cepInput, '50000000');
        await tester.pumpAndSettle();

        expect(find.text('Avenida Boa Viagem'), findsOneWidget);
        expect(find.text('Boa Viagem'), findsOneWidget);
        expect(find.text('Recife'), findsOneWidget);
        expect(find.text('PE'), findsWidgets);
      }, TestHttpOverrides(statusCode: 200, responseBody: viaCepJson));
    });

    testWidgets('Deve mostrar SnackBar quando CEP não for encontrado pelo ViaCEP', (tester) async {
      final viaCepJsonError = jsonEncode({"erro": true});

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        final cepInput = find.byType(TextFormField).at(5);
        await tester.ensureVisible(cepInput);
        await tester.enterText(cepInput, '99999999');
        await tester.pumpAndSettle();

        expect(find.text('CEP não encontrado'), findsOneWidget);
      }, TestHttpOverrides(statusCode: 200, responseBody: viaCepJsonError));
    });

    testWidgets('Deve navegar para LoginScreen ao clicar em "Já tem uma conta? Faça login"', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final loginBtn = find.widgetWithText(TextButton, 'Já tem uma conta? Faça login');
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('4. Cenário de Sucesso', () {
    testWidgets('Deve registrar no Auth, salvar no Firestore e navegar para GenerosCadastroScreen', (tester) async {
      final mockAuth = MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(createWidgetUnderTest(
          auth: mockAuth,
          firestore: fakeFirestore,
        ));

        // Nome (0)
        await tester.enterText(find.byType(TextFormField).at(0), 'Carlos Silva');

        // Data de Nascimento (1)
        await tester.enterText(find.byType(TextFormField).at(1), '15051990');

        // E-mail (2)
        await tester.enterText(find.byType(TextFormField).at(2), 'carlos@teste.com');

        // Senha (3) e Confirmar Senha (4)
        await tester.enterText(find.byType(TextFormField).at(3), '123456');
        await tester.enterText(find.byType(TextFormField).at(4), '123456');

        // CEP (5)
        final cepInput = find.byType(TextFormField).at(5);
        await tester.ensureVisible(cepInput);
        await tester.enterText(cepInput, '50000000');
        await tester.pumpAndSettle();

        // Número (7)
        final numInput = find.byType(TextFormField).at(7);
        await tester.ensureVisible(numInput);
        await tester.enterText(numInput, '100');

        // Seleciona Estado
        final dropdown = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdown);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('PE').last);
        await tester.pumpAndSettle();

        // Cadastrar
        final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarBtn);
        await tester.tap(cadastrarBtn);
        await tester.pumpAndSettle();

        // Asserções
        expect(mockAuth.currentUser, isNotNull);
        expect(mockAuth.currentUser!.email, 'carlos@teste.com');

        final snapshot = await fakeFirestore
            .collection('usuarios')
            .doc(mockAuth.currentUser!.uid)
            .get();

        expect(snapshot.exists, isTrue);
        expect(snapshot.data()?['nome'], 'Carlos Silva');
        expect(snapshot.data()?['email'], 'carlos@teste.com');
        expect(snapshot.data()?['endereco']['numero'], '100');

        expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      }, TestHttpOverrides(
        statusCode: 200,
        responseBody: jsonEncode({
          "cep": "50000-000",
          "logradouro": "Rua Teste",
          "bairro": "Bairro Teste",
          "localidade": "Recife",
          "uf": "PE"
        }),
      ));
    });
  });

  group('5. Cenários de Erro (Firebase)', () {
    testWidgets('Deve exibir SnackBar com a mensagem de erro quando FirebaseAuth falhar', (tester) async {
      final mockAuth = MockFirebaseAuth(
        mockUser: MockUser(
          isAnonymous: false,
          uid: 'existente_uid',
          email: 'existente@teste.com',
        ),
      );
      final fakeFirestore = FakeFirebaseFirestore();

      await HttpOverrides.runWithHttpOverrides(() async {
        await tester.pumpWidget(createWidgetUnderTest(
          auth: mockAuth,
          firestore: fakeFirestore,
        ));

        // Preenche com e-mail já existente
        await tester.enterText(find.byType(TextFormField).at(0), 'Usuario Teste');
        await tester.enterText(find.byType(TextFormField).at(1), '10101990');
        await tester.enterText(find.byType(TextFormField).at(2), 'existente@teste.com');
        await tester.enterText(find.byType(TextFormField).at(3), '123456');
        await tester.enterText(find.byType(TextFormField).at(4), '123456');

        final cepInput = find.byType(TextFormField).at(5);
        await tester.ensureVisible(cepInput);
        await tester.enterText(cepInput, '50000000');
        await tester.pumpAndSettle();

        final numInput = find.byType(TextFormField).at(7);
        await tester.ensureVisible(numInput);
        await tester.enterText(numInput, '42');

        final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarBtn);
        await tester.tap(cadastrarBtn);
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('Erro ao cadastrar:'), findsOneWidget);
      }, TestHttpOverrides(
        statusCode: 200,
        responseBody: jsonEncode({
          "cep": "50000-000",
          "logradouro": "Rua Teste",
          "bairro": "Bairro Teste",
          "localidade": "Recife",
          "uf": "PE"
        }),
      ));
    });
  });
}

```
````

