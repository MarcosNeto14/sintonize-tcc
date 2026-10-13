import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(as: #MockFirebaseAuthService),
  MockSpec<FirebaseFirestore>(as: #MockFirestoreService),
])
import 'icrash_zs_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget createTestWidget({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) {
    return MaterialApp(
      home: CadastroScreen(
        auth: auth,
        firestore: firestore,
      ),
      routes: {
        '/generos': (context) => GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
      },
    );
  }

  group('Fluxo de Cadastro e Seleção de Gêneros - Sintonize', () {
    testWidgets(
      'Deve preencher o formulário, criar usuário, redirecionar e salvar gêneros com sucesso no Firestore',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          createTestWidget(
            auth: mockAuth,
            firestore: fakeFirestore,
          ),
        );
        await tester.pumpAndSettle();

        final textFields = find.byType(TextFormField);
        expect(textFields, findsNWidgets(10));

        await tester.enterText(textFields.at(0), 'João da Silva');
        await tester.enterText(textFields.at(1), '15/05/1995');
        await tester.enterText(textFields.at(2), 'joao@email.com');
        await tester.enterText(textFields.at(3), 'senha123');
        await tester.enterText(textFields.at(4), 'senha123');
        await tester.enterText(textFields.at(5), '50000-000');
        await tester.enterText(textFields.at(6), 'Rua das Flores');
        await tester.enterText(textFields.at(7), '123');
        await tester.enterText(textFields.at(8), 'Centro');
        await tester.enterText(textFields.at(9), 'Recife');
        await tester.pumpAndSettle();

        final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.scrollUntilVisible(cadastrarBtn, 100);
        await tester.tap(cadastrarBtn);
        await tester.pumpAndSettle();

        expect(mockAuth.currentUser, isNotNull);
        final String uid = mockAuth.currentUser!.uid;

        final docUsuario = await fakeFirestore.collection('usuarios').doc(uid).get();
        expect(docUsuario.exists, isTrue);
        expect(docUsuario.data()!['nome'], equals('João da Silva'));
        expect(docUsuario.data()!['email'], equals('joao@email.com'));

        expect(find.byType(GenerosCadastroScreen), findsOneWidget);
        expect(find.text('Rock'), findsOneWidget);
        expect(find.text('Pop'), findsOneWidget);

        final rockSwitch = find.widgetWithText(SwitchListTile, 'Rock');
        final jazzSwitch = find.widgetWithText(SwitchListTile, 'Jazz');

        await tester.tap(rockSwitch);
        await tester.pumpAndSettle();

        await tester.tap(jazzSwitch);
        await tester.pumpAndSettle();

        final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.tap(confirmarBtn);
        await tester.pumpAndSettle();

        final docAtualizado = await fakeFirestore.collection('usuarios').doc(uid).get();
        final List<dynamic> generosSalvos = docAtualizado.data()!['generos_favoritos'];

        expect(generosSalvos, containsAll(['Rock', 'Jazz']));
        expect(generosSalvos.length, equals(2));
      },
    );

    testWidgets(
      'Não deve avançar quando houver campos inválidos no formulário de cadastro',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          createTestWidget(auth: mockAuth, firestore: fakeFirestore),
        );
        await tester.pumpAndSettle();

        final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.scrollUntilVisible(cadastrarBtn, 100);
        await tester.tap(cadastrarBtn);
        await tester.pumpAndSettle();

        expect(find.text('O nome é obrigatório'), findsOneWidget);
        expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
        expect(find.text('O e-mail é obrigatório'), findsOneWidget);
        expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);

        expect(mockAuth.currentUser, isNull);
        expect(find.byType(GenerosCadastroScreen), findsNothing);
      },
    );

    testWidgets(
      'Deve exibir SnackBar com erro caso a criação no Firebase Auth falhe',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final failingAuth = MockFirebaseAuthService();
        when(failingAuth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        )).thenThrow(
          FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'O endereço de email já está cadastrado.',
          ),
        );

        await tester.pumpWidget(
          createTestWidget(auth: failingAuth, firestore: fakeFirestore),
        );
        await tester.pumpAndSettle();

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'Maria Santos');
        await tester.enterText(textFields.at(1), '10/10/1990');
        await tester.enterText(textFields.at(2), 'email@existente.com');
        await tester.enterText(textFields.at(3), 'senhaValida1');
        await tester.enterText(textFields.at(4), 'senhaValida1');
        await tester.enterText(textFields.at(5), '50000-111');
        await tester.enterText(textFields.at(6), 'Rua Teste');
        await tester.enterText(textFields.at(7), '999');
        await tester.enterText(textFields.at(8), 'Bairro Teste');
        await tester.enterText(textFields.at(9), 'Cidade Teste');
        await tester.pumpAndSettle();

        final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.scrollUntilVisible(cadastrarBtn, 100);
        await tester.tap(cadastrarBtn);
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('Erro ao cadastrar'), findsOneWidget);
        expect(find.byType(GenerosCadastroScreen), findsNothing);
      },
    );

    testWidgets(
      'Deve exibir aviso se tentar confirmar sem selecionar nenhum gênero musical',
      (WidgetTester tester) async {
        await mockAuth.createUserWithEmailAndPassword(
          email: 'usuario@teste.com',
          password: 'password123',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.tap(confirmarBtn);
        await tester.pumpAndSettle();

        expect(find.text('Selecione pelo menos um gênero musical!'), findsOneWidget);
      },
    );

    testWidgets(
      'Deve tratar erro de salvamento no Firestore na GenerosCadastroScreen',
      (WidgetTester tester) async {
        await mockAuth.createUserWithEmailAndPassword(
          email: 'usuario@teste.com',
          password: 'password123',
        );

        final mockFailingFirestore = MockFirestoreService();

        when(mockFailingFirestore.collection(any)).thenAnswer((_) {
          throw FirebaseException(plugin: 'firestore', message: 'Indisponível');
        });

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: mockAuth,
              firestore: mockFailingFirestore,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(SwitchListTile, 'Pop'));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar'));
        await tester.pumpAndSettle();

        expect(find.text('Erro ao salvar os gêneros!'), findsOneWidget);
      },
    );
  });
}
