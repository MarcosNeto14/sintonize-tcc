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

