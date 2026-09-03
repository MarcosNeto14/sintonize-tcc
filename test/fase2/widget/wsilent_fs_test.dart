import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  group('LoginScreen Widget', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    testWidgets('deve mostrar erro quando o e-mail está vazio', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(auth: mockAuth),
        ),
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira seu e-mail'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar erro quando o e-mail é inválido', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(auth: mockAuth),
        ),
      );

      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), 'email-invalido');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira um e-mail válido'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar erro quando a senha está vazia', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(auth: mockAuth),
        ),
      );

      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), 'user@test.com');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira sua senha'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar erro quando a senha tem menos de 6 caracteres',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(auth: mockAuth),
        ),
      );

      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), 'user@test.com');
      await tester.enterText(campos.at(1), '12345');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets(
      'deve exibir mensagem quando o Firebase retorna user-not-found',
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
          MaterialApp(
            home: LoginScreen(auth: authComErro),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(campos.at(0), 'user@test.com');
        await tester.enterText(campos.at(1), 'senha123');

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
          ),
          findsOneWidget,
        );

        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets(
      'deve exibir mensagem quando o Firebase retorna wrong-password',
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
          MaterialApp(
            home: LoginScreen(auth: authComErro),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(campos.at(0), 'user@test.com');
        await tester.enterText(campos.at(1), 'senha123');

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
          ),
          findsOneWidget,
        );

        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets(
      'deve exibir mensagem quando o Firebase retorna invalid-credential',
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
          MaterialApp(
            home: LoginScreen(auth: authComErro),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(campos.at(0), 'user@test.com');
        await tester.enterText(campos.at(1), 'senha123');

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'As credenciais fornecidas são inválidas. Tente novamente.',
          ),
          findsOneWidget,
        );

        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets(
      'deve exibir mensagem genérica para erro inesperado do Firebase',
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
          MaterialApp(
            home: LoginScreen(auth: authComErro),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(campos.at(0), 'user@test.com');
        await tester.enterText(campos.at(1), 'senha123');

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.',
          ),
          findsOneWidget,
        );

        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets(
      'deve permitir informar e-mail e senha corretamente',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: LoginScreen(auth: mockAuth),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(campos.at(0), 'user@test.com');
        await tester.enterText(campos.at(1), 'senha123');

        expect(
          find.text('user@test.com'),
          findsOneWidget,
        );

        expect(
          campos,
          findsNWidgets(2),
        );

        final senhaField = find.descendant(
          of: campos.at(1),
          matching: find.byType(EditableText),
        );

        expect(
          senhaField,
          findsOneWidget,
        );

        final editableText = tester.widget<EditableText>(senhaField);

        expect(
          editableText.obscureText,
          isTrue,
        );

        expect(find.text('Entrar'), findsOneWidget);
      },
    );

    testWidgets(
      'deve navegar para TelaInicialScreen após login bem-sucedido',
      (tester) async {
        final auth = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'usuario-123',
            email: 'user@test.com',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: LoginScreen(auth: auth),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(campos.at(0), 'user@test.com');
        await tester.enterText(campos.at(1), 'senha123');

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );
      },
    );
  });
}
