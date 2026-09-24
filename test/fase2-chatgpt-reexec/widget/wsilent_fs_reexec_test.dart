import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

// IMPORTANTE:
// ajuste este import para o caminho REAL onde LoginScreen está definido.
//
// Exemplo:
// import 'package:sintonize/screens/login_screen.dart';
//
// O caminho abaixo é apenas ilustrativo:
// import 'package:sintonize/login_screen.dart';

import 'package:sintonize/COLOQUE_AQUI_O_CAMINHO_CORRETO.dart';

void main() {
  group('LoginScreen Widget', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    Future<void> pumpLoginScreen(
      WidgetTester tester, {
      FirebaseAuth? auth,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(auth: auth ?? mockAuth),
        ),
      );
    }

    testWidgets(
      'deve mostrar erro quando o e-mail está vazio',
      (tester) async {
        await pumpLoginScreen(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve mostrar erro quando a senha está vazia',
      (tester) async {
        await pumpLoginScreen(tester);

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'user@test.com',
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
      'deve mostrar erro para e-mail inválido',
      (tester) async {
        await pumpLoginScreen(tester);

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'email-invalido',
        );

        await tester.enterText(
          find.byType(TextFormField).at(1),
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
      'deve mostrar erro para senha com menos de 6 caracteres',
      (tester) async {
        await pumpLoginScreen(tester);

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'user@test.com',
        );

        await tester.enterText(
          find.byType(TextFormField).at(1),
          '12345',
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
      'deve exibir mensagem para erro user-not-found',
      (tester) async {
        final authComErro = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(authComErro).thenThrow(
              FirebaseAuthException(code: 'user-not-found'),
            );

        await pumpLoginScreen(
          tester,
          auth: authComErro,
        );

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'user@test.com',
        );

        await tester.enterText(
          find.byType(TextFormField).at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

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
      'deve exibir mensagem para erro wrong-password',
      (tester) async {
        final authComErro = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(authComErro).thenThrow(
              FirebaseAuthException(code: 'wrong-password'),
            );

        await pumpLoginScreen(
          tester,
          auth: authComErro,
        );

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'user@test.com',
        );

        await tester.enterText(
          find.byType(TextFormField).at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir mensagem para erro invalid-credential',
      (tester) async {
        final authComErro = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(authComErro).thenThrow(
              FirebaseAuthException(code: 'invalid-credential'),
            );

        await pumpLoginScreen(
          tester,
          auth: authComErro,
        );

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'user@test.com',
        );

        await tester.enterText(
          find.byType(TextFormField).at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'As credenciais fornecidas são inválidas. Tente novamente.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir mensagem genérica para erro desconhecido',
      (tester) async {
        final authComErro = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(authComErro).thenThrow(
              FirebaseAuthException(code: 'erro-desconhecido'),
            );

        await pumpLoginScreen(
          tester,
          auth: authComErro,
        );

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'user@test.com',
        );

        await tester.enterText(
          find.byType(TextFormField).at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

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
      'deve autenticar com e-mail e senha válidos',
      (tester) async {
        final auth = MockFirebaseAuth();

        await pumpLoginScreen(
          tester,
          auth: auth,
        );

        await tester.enterText(
          find.byType(TextFormField).at(0),
          '  user@test.com  ',
        );

        await tester.enterText(
          find.byType(TextFormField).at(1),
          '  123456  ',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(auth.currentUser, isNotNull);
        expect(auth.currentUser!.email, 'user@test.com');

        // O LoginScreen usa pushReplacement após o login.
        // Portanto, ele não deve mais estar na árvore.
        expect(find.byType(LoginScreen), findsNothing);
      },
    );

    testWidgets(
      'não deve autenticar quando o formulário é inválido',
      (tester) async {
        await pumpLoginScreen(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsOneWidget,
        );

        expect(find.byType(LoginScreen), findsOneWidget);
      },
    );
  });
}
