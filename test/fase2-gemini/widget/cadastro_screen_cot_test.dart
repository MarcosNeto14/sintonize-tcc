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

