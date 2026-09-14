import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/recup-senha.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class TestNavigatorObserver extends NavigatorObserver {
  bool didReplaceCalled = false;

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    didReplaceCalled = true;

    super.didReplace(
      newRoute: newRoute,
      oldRoute: oldRoute,
    );
  }
}

void main() {
  setUpAll(() {
    // Mockito precisa de um valor dummy para o retorno não-nulável
    // de signInWithEmailAndPassword.
    provideDummy<Future<UserCredential>>(
      Future<UserCredential>.value(MockUserCredential()),
    );
  });

  group('LoginScreen Widget', () {
    Widget buildTestWidget(FirebaseAuth auth) {
      return MaterialApp(
        home: LoginScreen(auth: auth),
      );
    }

    testWidgets(
      'deve exibir erro quando e-mail está vazio',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(
          buildTestWidget(auth),
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir erro quando senha está vazia',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(
          buildTestWidget(auth),
        );

        await tester.enterText(
          find.byType(TextFormField).first,
          'teste@email.com',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira sua senha'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir erro para e-mail inválido',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(
          buildTestWidget(auth),
        );

        await tester.enterText(
          find.byType(TextFormField).first,
          'email-invalido',
        );

        await tester.enterText(
          find.byType(TextFormField).last,
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira um e-mail válido'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir erro para senha com menos de 6 caracteres',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(
          buildTestWidget(auth),
        );

        await tester.enterText(
          find.byType(TextFormField).first,
          'teste@email.com',
        );

        await tester.enterText(
          find.byType(TextFormField).last,
          '123',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve realizar login e navegar para tela inicial',
      (tester) async {
        final auth = MockFirebaseAuth();
        final navigatorObserver = TestNavigatorObserver();

        when(
          auth.signInWithEmailAndPassword(
            email: 'teste@email.com',
            password: '123456',
          ),
        ).thenAnswer(
          (_) async => MockUserCredential(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: LoginScreen(auth: auth),
            navigatorObservers: [navigatorObserver],
          ),
        );

        await tester.enterText(
          find.byType(TextFormField).first,
          'teste@email.com',
        );

        await tester.enterText(
          find.byType(TextFormField).last,
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        verify(
          auth.signInWithEmailAndPassword(
            email: 'teste@email.com',
            password: '123456',
          ),
        ).called(1);

        expect(
          navigatorObserver.didReplaceCalled,
          isTrue,
        );
      },
    );

    testWidgets(
      'deve mostrar mensagem quando usuário não existe',
      (tester) async {
        final auth = MockFirebaseAuth();

        when(
          auth.signInWithEmailAndPassword(
            email: 'naoexiste@email.com',
            password: '123456',
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'user-not-found',
          ),
        );

        await tester.pumpWidget(
          buildTestWidget(auth),
        );

        await tester.enterText(
          find.byType(TextFormField).first,
          'naoexiste@email.com',
        );

        await tester.enterText(
          find.byType(TextFormField).last,
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve mostrar mensagem quando a senha está incorreta',
      (tester) async {
        final auth = MockFirebaseAuth();

        when(
          auth.signInWithEmailAndPassword(
            email: 'teste@email.com',
            password: '123456',
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'wrong-password',
          ),
        );

        await tester.pumpWidget(
          buildTestWidget(auth),
        );

        await tester.enterText(
          find.byType(TextFormField).first,
          'teste@email.com',
        );

        await tester.enterText(
          find.byType(TextFormField).last,
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'Senha incorreta. Certifique-se de que está digitando '
            'a senha corretamente.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve mostrar mensagem para credencial inválida',
      (tester) async {
        final auth = MockFirebaseAuth();

        when(
          auth.signInWithEmailAndPassword(
            email: 'teste@email.com',
            password: '123456',
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'invalid-credential',
          ),
        );

        await tester.pumpWidget(
          buildTestWidget(auth),
        );

        await tester.enterText(
          find.byType(TextFormField).first,
          'teste@email.com',
        );

        await tester.enterText(
          find.byType(TextFormField).last,
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'As credenciais fornecidas são inválidas. Tente novamente.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve mostrar mensagem para erro inesperado do Firebase',
      (tester) async {
        final auth = MockFirebaseAuth();

        when(
          auth.signInWithEmailAndPassword(
            email: 'teste@email.com',
            password: '123456',
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'unknown-error',
          ),
        );

        await tester.pumpWidget(
          buildTestWidget(auth),
        );

        await tester.enterText(
          find.byType(TextFormField).first,
          'teste@email.com',
        );

        await tester.enterText(
          find.byType(TextFormField).last,
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'Erro inesperado ao fazer login. '
            'Por favor, tente novamente mais tarde.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve navegar para recuperação de senha',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(
          buildTestWidget(auth),
        );

        await tester.tap(
          find.text('Esqueci minha senha'),
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(RecupSenhaScreen),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve navegar para cadastro',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(
          buildTestWidget(auth),
        );

        final cadastroButton = find.text(
          'Não tem cadastro? Cadastre-se!',
        );

        await tester.ensureVisible(cadastroButton);
        await tester.tap(cadastroButton);

        await tester.pumpAndSettle();

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );
      },
    );
  });
}
