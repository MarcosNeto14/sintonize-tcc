import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/recup-senha.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  late MockFirebaseAuth mockAuth;

  Widget buildTestableWidget() {
    return MaterialApp(
      home: LoginScreen(auth: mockAuth),
    );
  }

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  group('LoginScreen - renderização', () {
    testWidgets('deve renderizar os elementos principais', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Esqueci minha senha'), findsOneWidget);
      expect(
        find.text('Não tem cadastro? Cadastre-se!'),
        findsOneWidget,
      );
    });

    testWidgets('deve renderizar dois campos de texto', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });

  group('LoginScreen - validação', () {
    testWidgets(
      'deve mostrar erros quando os campos estão vazios',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

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
      'deve mostrar erro quando o e-mail está vazio',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsOneWidget,
        );

        expect(
          find.text('Por favor, insira sua senha'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve mostrar erro quando a senha está vazia',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsNothing,
        );

        expect(
          find.text('Por favor, insira sua senha'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve rejeitar e-mail inválido',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'email-invalido',
        );

        await tester.enterText(
          fields.at(1),
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
      'deve rejeitar senha com menos de 6 caracteres',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '12345',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'A senha deve ter pelo menos 6 caracteres',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('LoginScreen - interação', () {
    testWidgets(
      'deve permitir digitar e-mail e senha',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          'minhasenha',
        );

        expect(
          find.text('usuario@email.com'),
          findsOneWidget,
        );

        expect(
          find.text('minhasenha'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve navegar para RecupSenhaScreen',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

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
      'deve navegar para CadastroScreen',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

        final cadastroButton = find.text(
          'Não tem cadastro? Cadastre-se!',
        );

        // O botão pode estar abaixo da viewport devido ao
        // SingleChildScrollView.
        await tester.ensureVisible(cadastroButton);
        await tester.pumpAndSettle();

        await tester.tap(cadastroButton);
        await tester.pumpAndSettle();

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );
      },
    );
  });

  group('LoginScreen - login com sucesso', () {
    testWidgets(
      'deve realizar login com credenciais válidas',
      (tester) async {
        final user = MockUser(
          uid: 'test-user',
          email: 'usuario@email.com',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
        );

        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );

        expect(
          find.byType(LoginScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve navegar para TelaInicialScreen após login válido',
      (tester) async {
        final user = MockUser(
          uid: 'test-user',
          email: 'usuario@email.com',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
        );

        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve remover espaços do e-mail e senha antes do login',
      (tester) async {
        final user = MockUser(
          uid: 'test-user',
          email: 'usuario@email.com',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
        );

        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          '  usuario@email.com  ',
        );

        await tester.enterText(
          fields.at(1),
          '  123456  ',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );
      },
    );
  });

  group('LoginScreen - erros do Firebase Auth', () {
    testWidgets(
      'deve mostrar mensagem para user-not-found',
      (tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              FirebaseAuthException(
                code: 'user-not-found',
              ),
            );

        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
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

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve mostrar mensagem para wrong-password',
      (tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              FirebaseAuthException(
                code: 'wrong-password',
              ),
            );

        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
          ),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve mostrar mensagem para invalid-credential',
      (tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              FirebaseAuthException(
                code: 'invalid-credential',
              ),
            );

        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
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

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve mostrar mensagem genérica para código desconhecido',
      (tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              FirebaseAuthException(
                code: 'network-request-failed',
              ),
            );

        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.',
          ),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'não deve navegar quando Firebase Auth lança uma exceção',
      (tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              FirebaseAuthException(
                code: 'user-not-found',
              ),
            );

        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

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
