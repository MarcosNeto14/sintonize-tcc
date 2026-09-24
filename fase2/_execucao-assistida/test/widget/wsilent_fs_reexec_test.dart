import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/login.dart';

void main() {
  group('LoginScreen Widget', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    Widget buildTestWidget({FirebaseAuth? auth}) {
      return MaterialApp(
        home: LoginScreen(auth: auth ?? mockAuth),
      );
    }

    testWidgets('deve exibir erro quando o e-mail está vazio',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira seu e-mail'),
        findsOneWidget,
      );
    });

    testWidgets('deve exibir erro quando o e-mail é inválido',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final campos = find.byType(TextFormField);

      await tester.enterText(
        campos.at(0),
        'email-invalido',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira um e-mail válido'),
        findsOneWidget,
      );
    });

    testWidgets('deve exibir erro quando a senha está vazia',
        (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final campos = find.byType(TextFormField);

      await tester.enterText(
        campos.at(0),
        'usuario@test.com',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira sua senha'),
        findsOneWidget,
      );
    });

    testWidgets(
      'deve exibir erro quando a senha tem menos de 6 caracteres',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final campos = find.byType(TextFormField);

        await tester.enterText(
          campos.at(0),
          'usuario@test.com',
        );

        await tester.enterText(
          campos.at(1),
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
      'não deve autenticar quando o formulário é inválido',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

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
      },
    );

    testWidgets(
      'deve exibir mensagem para user-not-found',
      (tester) async {
        final authComErro = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(authComErro).thenThrow(
              FirebaseAuthException(
                code: 'user-not-found',
              ),
            );

        await tester.pumpWidget(
          buildTestWidget(auth: authComErro),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(
          campos.at(0),
          'usuario@test.com',
        );

        await tester.enterText(
          campos.at(1),
          'senha123',
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
      'deve exibir mensagem para wrong-password',
      (tester) async {
        final authComErro = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(authComErro).thenThrow(
              FirebaseAuthException(
                code: 'wrong-password',
              ),
            );

        await tester.pumpWidget(
          buildTestWidget(auth: authComErro),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(
          campos.at(0),
          'usuario@test.com',
        );

        await tester.enterText(
          campos.at(1),
          'senha123',
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
      'deve exibir mensagem para invalid-credential',
      (tester) async {
        final authComErro = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(authComErro).thenThrow(
              FirebaseAuthException(
                code: 'invalid-credential',
              ),
            );

        await tester.pumpWidget(
          buildTestWidget(auth: authComErro),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(
          campos.at(0),
          'usuario@test.com',
        );

        await tester.enterText(
          campos.at(1),
          'senha123',
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
      'deve exibir mensagem genérica para erro inesperado',
      (tester) async {
        final authComErro = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(authComErro).thenThrow(
              FirebaseAuthException(
                code: 'network-request-failed',
              ),
            );

        await tester.pumpWidget(
          buildTestWidget(auth: authComErro),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(
          campos.at(0),
          'usuario@test.com',
        );

        await tester.enterText(
          campos.at(1),
          'senha123',
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
      'campo de senha deve ocultar o texto digitado',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final senhaField = find.byType(TextFormField).at(1);

        final textField = tester.widget<TextField>(
          find.descendant(
            of: senhaField,
            matching: find.byType(TextField),
          ),
        );

        expect(textField.obscureText, isTrue);
      },
    );

    testWidgets(
      'deve substituir LoginScreen após login bem-sucedido',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(
          buildTestWidget(auth: auth),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(
          campos.at(0),
          'usuario@test.com',
        );

        await tester.enterText(
          campos.at(1),
          'senha123',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.byType(LoginScreen),
          findsNothing,
        );
      },
    );
  });
}
