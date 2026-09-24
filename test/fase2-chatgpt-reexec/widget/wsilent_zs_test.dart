import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/recup-senha.dart';

void main() {
  late MockFirebaseAuth mockAuth;
Widget createTestWidget() {
  return MaterialApp(
    home: LoginScreen(
      auth: mockAuth,
    ),
  );
}

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  Future<void> preencherFormulario(
    WidgetTester tester, {
    String email = 'usuario@email.com',
    String senha = '123456',
  }) async {
    final fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), email);
    await tester.enterText(fields.at(1), senha);
  }

  group('LoginScreen - autenticação', () {
testWidgets(
  'deve realizar login com credenciais válidas',
  (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await preencherFormulario(tester);

    await tester.tap(find.text('Entrar'));

    // Processa o Future retornado pelo signInWithEmailAndPassword,
    // mas não usa pumpAndSettle(), pois a tela seguinte depende
    // de FirebaseAuth.instance.
    await tester.pump();

    expect(
      mockAuth.currentUser,
      isNotNull,
    );

    expect(
      mockAuth.currentUser!.email,
      'usuario@email.com',
    );
  },
);

    testWidgets(
      'não deve autenticar quando o formulário é inválido',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          mockAuth.currentUser,
          isNull,
        );
      },
    );
  });

  group('LoginScreen - navegação', () {
    testWidgets(
      'deve navegar para recuperação de senha',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.text('Esqueci minha senha'));
        await tester.pumpAndSettle();

        expect(
          find.byType(RecupSenhaScreen),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve navegar para cadastro',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

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

  group('LoginScreen - erros do Firebase Auth', () {
    testWidgets(
      'deve mostrar mensagem para user-not-found',
      (WidgetTester tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
            {
              #email: anything,
              #password: anything,
            },
          ),
        ).on(mockAuth).thenThrow(
          FirebaseAuthException(
            code: 'user-not-found',
          ),
        );

        await tester.pumpWidget(createTestWidget());

        await preencherFormulario(tester);

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
      'deve mostrar mensagem para wrong-password',
      (WidgetTester tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
            {
              #email: anything,
              #password: anything,
            },
          ),
        ).on(mockAuth).thenThrow(
          FirebaseAuthException(
            code: 'wrong-password',
          ),
        );

        await tester.pumpWidget(createTestWidget());

        await preencherFormulario(tester);

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
      'deve mostrar mensagem para invalid-credential',
      (WidgetTester tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
            {
              #email: anything,
              #password: anything,
            },
          ),
        ).on(mockAuth).thenThrow(
          FirebaseAuthException(
            code: 'invalid-credential',
          ),
        );

        await tester.pumpWidget(createTestWidget());

        await preencherFormulario(tester);

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
      'deve mostrar mensagem genérica para código desconhecido',
      (WidgetTester tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
            {
              #email: anything,
              #password: anything,
            },
          ),
        ).on(mockAuth).thenThrow(
          FirebaseAuthException(
            code: 'unknown-error',
          ),
        );

        await tester.pumpWidget(createTestWidget());

        await preencherFormulario(tester);

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
  });
}
