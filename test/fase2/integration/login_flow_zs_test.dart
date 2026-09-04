import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  Future<void> pumpLoginScreen(
    WidgetTester tester, {
    required MockFirebaseAuth auth,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (_) => LoginScreen(auth: auth),
          '/login': (_) => LoginScreen(auth: auth),
          '/inicio': (_) => const TelaInicialScreen(),
        },
      ),
    );

    await tester.pump();
  }

  Future<void> preencherLogin(
    WidgetTester tester, {
    String email = 'usuario@email.com',
    String senha = '123456',
  }) async {
    final campos = find.byType(TextFormField);

    expect(campos, findsNWidgets(2));

    await tester.enterText(campos.at(0), email);
    await tester.enterText(campos.at(1), senha);
  }

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('LoginScreen - autenticação', () {
    testWidgets(
      'usuário preenche credenciais válidas, toca em Entrar e navega para TelaInicialScreen',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
          email: 'usuario@email.com',
          displayName: 'Usuário Teste',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
        );

        await fakeFirestore
            .collection('usuarios')
            .doc(user.uid)
            .set({
          'nome': 'Usuário Teste',
          'generos_favoritos': ['rock'],
          'historico_musicas': {
            '2026-09-04': {
              'track_name': 'Imagine',
              'artist_name': 'John Lennon',
            },
          },
        });

        await pumpLoginScreen(
          tester,
          auth: mockAuth,
        );

        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
        expect(find.text('Entrar'), findsOneWidget);

        await preencherLogin(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Firebase retorna user-not-found e LoginScreen exibe SnackBar vermelho',
      (tester) async {
        mockAuth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              FirebaseAuthException(
                code: 'user-not-found',
                message: 'No user found for that email.',
              ),
            );

        await pumpLoginScreen(
          tester,
          auth: mockAuth,
        );

        await preencherLogin(tester);

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

        expect(
          snackBar.backgroundColor,
          Colors.red,
        );

        expect(
          find.byType(LoginScreen),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Firebase retorna wrong-password e LoginScreen exibe SnackBar vermelho',
      (tester) async {
        mockAuth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              FirebaseAuthException(
                code: 'wrong-password',
                message: 'Wrong password.',
              ),
            );

        await pumpLoginScreen(
          tester,
          auth: mockAuth,
        );

        await preencherLogin(tester);

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

        expect(
          snackBar.backgroundColor,
          Colors.red,
        );

        expect(
          find.byType(LoginScreen),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Firebase retorna invalid-credential e LoginScreen exibe mensagem correspondente',
      (tester) async {
        mockAuth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              FirebaseAuthException(
                code: 'invalid-credential',
                message: 'Invalid credential.',
              ),
            );

        await pumpLoginScreen(
          tester,
          auth: mockAuth,
        );

        await preencherLogin(tester);

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

        expect(
          snackBar.backgroundColor,
          Colors.red,
        );
      },
    );

    testWidgets(
      'Firebase retorna código desconhecido e LoginScreen exibe erro genérico',
      (tester) async {
        mockAuth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              FirebaseAuthException(
                code: 'network-request-failed',
                message: 'Network request failed.',
              ),
            );

        await pumpLoginScreen(
          tester,
          auth: mockAuth,
        );

        await preencherLogin(tester);

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

        expect(
          snackBar.backgroundColor,
          Colors.red,
        );
      },
    );
  });

  group('LoginScreen - validação', () {
    testWidgets(
      'campos vazios exibem mensagens de validação',
      (tester) async {
        mockAuth = MockFirebaseAuth();

        // Se a autenticação for chamada indevidamente, o teste falha.
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              Exception(
                'A autenticação não deveria ser chamada com campos inválidos.',
              ),
            );

        await pumpLoginScreen(
          tester,
          auth: mockAuth,
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsOneWidget,
        );

        expect(
          find.text('Por favor, insira sua senha'),
          findsOneWidget,
        );

        expect(
          find.byType(LoginScreen),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'e-mail inválido impede a autenticação',
      (tester) async {
        mockAuth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              Exception(
                'A autenticação não deveria ser chamada com e-mail inválido.',
              ),
            );

        await pumpLoginScreen(
          tester,
          auth: mockAuth,
        );

        await preencherLogin(
          tester,
          email: 'email-invalido',
          senha: '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira um e-mail válido'),
          findsOneWidget,
        );

        expect(
          find.byType(LoginScreen),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'senha com menos de seis caracteres impede a autenticação',
      (tester) async {
        mockAuth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              Exception(
                'A autenticação não deveria ser chamada com senha inválida.',
              ),
            );

        await pumpLoginScreen(
          tester,
          auth: mockAuth,
        );

        await preencherLogin(
          tester,
          email: 'usuario@email.com',
          senha: '12345',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'A senha deve ter pelo menos 6 caracteres',
          ),
          findsOneWidget,
        );

        expect(
          find.byType(LoginScreen),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );
  });
}
