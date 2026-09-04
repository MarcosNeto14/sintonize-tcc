import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/login.dart';

void main() {
  group('Fluxo de Login', () {
    late MockFirebaseAuth mockAuth;

    Widget montarApp() {
      return MaterialApp(
        home: LoginScreen(auth: mockAuth),
      );
    }

    Future<void> preencherLogin(
      WidgetTester tester, {
      String email = 'usuario@test.com',
      String senha = 'senha123',
    }) async {
      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), email);
      await tester.enterText(campos.at(1), senha);
    }

    void configurarErroDeLogin({
      required String email,
      required String senha,
      required String codigo,
    }) {
      whenCalling(
        Invocation.method(
          #signInWithEmailAndPassword,
          null,
          {
            #email: email,
            #password: senha,
          },
        ),
      ).on(mockAuth).thenThrow(
        FirebaseAuthException(code: codigo),
      );
    }

    testWidgets(
      'credenciais válidas autenticam o usuário',
      (tester) async {
        mockAuth = MockFirebaseAuth(
          signedIn: false,
          mockUser: MockUser(
            uid: 'usuario-123',
            email: 'usuario@test.com',
          ),
        );

        await tester.pumpWidget(montarApp());

        await preencherLogin(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(mockAuth.currentUser, isNotNull);
        expect(
          mockAuth.currentUser!.email,
          equals('usuario@test.com'),
        );
      },
    );

    testWidgets(
      'código user-not-found exibe mensagem de usuário não encontrado',
      (tester) async {
        mockAuth = MockFirebaseAuth(signedIn: false);

        configurarErroDeLogin(
          email: 'usuario@test.com',
          senha: 'senha123',
          codigo: 'user-not-found',
        );

        await tester.pumpWidget(montarApp());

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

        expect(snackBar.backgroundColor, equals(Colors.red));
        expect(mockAuth.currentUser, isNull);
      },
    );

    testWidgets(
      'código wrong-password exibe mensagem de senha incorreta',
      (tester) async {
        mockAuth = MockFirebaseAuth(signedIn: false);

        configurarErroDeLogin(
          email: 'usuario@test.com',
          senha: 'senha123',
          codigo: 'wrong-password',
        );

        await tester.pumpWidget(montarApp());

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

        expect(snackBar.backgroundColor, equals(Colors.red));
        expect(mockAuth.currentUser, isNull);
      },
    );

    testWidgets(
      'código invalid-credential exibe mensagem de credenciais inválidas',
      (tester) async {
        mockAuth = MockFirebaseAuth(signedIn: false);

        configurarErroDeLogin(
          email: 'usuario@test.com',
          senha: 'senha123',
          codigo: 'invalid-credential',
        );

        await tester.pumpWidget(montarApp());

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

        expect(snackBar.backgroundColor, equals(Colors.red));
        expect(mockAuth.currentUser, isNull);
      },
    );

    testWidgets(
      'código desconhecido exibe mensagem de erro inesperado',
      (tester) async {
        mockAuth = MockFirebaseAuth(signedIn: false);

        configurarErroDeLogin(
          email: 'usuario@test.com',
          senha: 'senha123',
          codigo: 'too-many-requests',
        );

        await tester.pumpWidget(montarApp());

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

        expect(snackBar.backgroundColor, equals(Colors.red));
        expect(mockAuth.currentUser, isNull);
      },
    );

    testWidgets(
      'campos vazios impedem tentativa de autenticação',
      (tester) async {
        mockAuth = MockFirebaseAuth(signedIn: false);

        await tester.pumpWidget(montarApp());

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

        expect(mockAuth.currentUser, isNull);
        expect(find.byType(SnackBar), findsNothing);
      },
    );
  });
}
