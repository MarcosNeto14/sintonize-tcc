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

