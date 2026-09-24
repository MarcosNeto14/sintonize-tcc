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

