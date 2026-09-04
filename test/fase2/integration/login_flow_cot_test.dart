import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

Future<void> initializeFirebaseForTest() async {
  setupFirebaseCoreMocks();

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'fake-api-key',
        appId: '1:1234567890:android:integration-test',
        messagingSenderId: '1234567890',
        projectId: 'sintonize-integration-test',
      ),
    );
  } on FirebaseException catch (e) {
    // Permite que o arquivo seja executado mais de uma vez no mesmo
    // processo de testes.
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }
}

Widget buildTestApp({
  required MockFirebaseAuth auth,
}) {
  return MaterialApp(
    home: LoginScreen(auth: auth),
  );
}

Future<void> fillValidLogin(WidgetTester tester) async {
  final textFields = find.byType(TextFormField);

  await tester.enterText(
    textFields.at(0),
    'usuario@sintonize.com',
  );

  await tester.enterText(
    textFields.at(1),
    '123456',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeFirebaseForTest();
  });

  group('LoginScreen - fluxo de autenticação', () {
    testWidgets(
      'faz login com sucesso e navega para TelaInicialScreen',
      (WidgetTester tester) async {
        final auth = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'usuario-123',
            email: 'usuario@sintonize.com',
            isAnonymous: false,
          ),
        );

        await tester.pumpWidget(
          buildTestApp(auth: auth),
        );

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(TelaInicialScreen), findsNothing);

        await fillValidLogin(tester);

        await tester.tap(find.text('Entrar'));

        // Aguarda:
        // 1. signInWithEmailAndPassword()
        // 2. conclusão do Future
        // 3. Navigator.pushReplacement()
        // 4. construção da TelaInicialScreen
        // 5. Futures iniciados pela TelaInicialScreen.
        await tester.pumpAndSettle();

        expect(find.byType(TelaInicialScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      },
    );

    testWidgets(
      'não chama autenticação quando o e-mail está vazio',
      (WidgetTester tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(
          buildTestApp(auth: auth),
        );

        final textFields = find.byType(TextFormField);

        await tester.enterText(
          textFields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsOneWidget,
        );

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(TelaInicialScreen), findsNothing);

        // Como a validação retorna antes de signInWithEmailAndPassword,
        // o MockFirebaseAuth continua sem usuário autenticado.
        expect(auth.currentUser, isNull);
      },
    );

    testWidgets(
      'não chama autenticação quando o e-mail é inválido',
      (WidgetTester tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(
          buildTestApp(auth: auth),
        );

        final textFields = find.byType(TextFormField);

        await tester.enterText(
          textFields.at(0),
          'email-invalido',
        );

        await tester.enterText(
          textFields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira um e-mail válido'),
          findsOneWidget,
        );

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(auth.currentUser, isNull);
      },
    );

    testWidgets(
      'não chama autenticação quando a senha está vazia',
      (WidgetTester tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(
          buildTestApp(auth: auth),
        );

        final textFields = find.byType(TextFormField);

        await tester.enterText(
          textFields.at(0),
          'usuario@sintonize.com',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira sua senha'),
          findsOneWidget,
        );

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(auth.currentUser, isNull);
      },
    );

    testWidgets(
      'não chama autenticação quando a senha tem menos de 6 caracteres',
      (WidgetTester tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(
          buildTestApp(auth: auth),
        );

        final textFields = find.byType(TextFormField);

        await tester.enterText(
          textFields.at(0),
          'usuario@sintonize.com',
        );

        await tester.enterText(
          textFields.at(1),
          '12345',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(auth.currentUser, isNull);
      },
    );

    testWidgets(
      'exibe SnackBar vermelho para user-not-found',
      (WidgetTester tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(auth).thenThrow(
          FirebaseAuthException(
            code: 'user-not-found',
          ),
        );

        await tester.pumpWidget(
          buildTestApp(auth: auth),
        );

        await fillValidLogin(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
          ),
          findsOneWidget,
        );

        final snackBar = tester.widget<SnackBar>(
          find.byType(SnackBar),
        );

        expect(snackBar.backgroundColor, Colors.red);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );

    testWidgets(
      'exibe SnackBar vermelho para wrong-password',
      (WidgetTester tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(auth).thenThrow(
          FirebaseAuthException(
            code: 'wrong-password',
          ),
        );

        await tester.pumpWidget(
          buildTestApp(auth: auth),
        );

        await fillValidLogin(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
          ),
          findsOneWidget,
        );

        final snackBar = tester.widget<SnackBar>(
          find.byType(SnackBar),
        );

        expect(snackBar.backgroundColor, Colors.red);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );

    testWidgets(
      'exibe SnackBar vermelho para invalid-credential',
      (WidgetTester tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(auth).thenThrow(
          FirebaseAuthException(
            code: 'invalid-credential',
          ),
        );

        await tester.pumpWidget(
          buildTestApp(auth: auth),
        );

        await fillValidLogin(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'As credenciais fornecidas são inválidas. Tente novamente.',
          ),
          findsOneWidget,
        );

        final snackBar = tester.widget<SnackBar>(
          find.byType(SnackBar),
        );

        expect(snackBar.backgroundColor, Colors.red);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );

    testWidgets(
      'exibe mensagem genérica para código Firebase desconhecido',
      (WidgetTester tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(auth).thenThrow(
          FirebaseAuthException(
            code: 'network-request-failed',
          ),
        );

        await tester.pumpWidget(
          buildTestApp(auth: auth),
        );

        await fillValidLogin(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.',
          ),
          findsOneWidget,
        );

        final snackBar = tester.widget<SnackBar>(
          find.byType(SnackBar),
        );

        expect(snackBar.backgroundColor, Colors.red);
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );

    testWidgets(
      'mantém LoginScreen quando autenticação falha',
      (WidgetTester tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(auth).thenThrow(
          FirebaseAuthException(
            code: 'user-not-found',
          ),
        );

        await tester.pumpWidget(
          buildTestApp(auth: auth),
        );

        await fillValidLogin(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(TelaInicialScreen), findsNothing);
        expect(find.byType(SnackBar), findsOneWidget);
      },
    );
  });
}
