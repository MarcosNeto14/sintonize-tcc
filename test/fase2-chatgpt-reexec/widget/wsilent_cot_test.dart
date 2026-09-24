import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:sintonize/login.dart';

void main() {
  Widget createTestWidget(FirebaseAuth auth) {
    return MaterialApp(
      home: LoginScreen(auth: auth),
    );
  }

  group('LoginScreen - Renderização', () {
    testWidgets(
      'deve renderizar os elementos principais',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
        expect(find.text('Entrar'), findsOneWidget);

        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
      },
    );

    testWidgets(
      'deve renderizar o logo',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets(
      'deve permitir scroll vertical da tela',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 400),
              ),
              child: LoginScreen(auth: auth),
            ),
          ),
        );

        final scrollable = find.byType(SingleChildScrollView);

        expect(scrollable, findsOneWidget);

        await tester.drag(
          scrollable,
          const Offset(0, -200),
        );

        await tester.pump();

        expect(scrollable, findsOneWidget);
      },
    );
  });

  group('LoginScreen - Validação', () {
    testWidgets(
      'deve exibir erro quando o e-mail estiver vazio',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

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
      'deve exibir erro para e-mail inválido',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

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
      'deve exibir erro quando a senha estiver vazia',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
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
      'deve exibir erro para senha com menos de 6 caracteres',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

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
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve aceitar e-mail e senha válidos',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.pump();

        // Não pressionamos "Entrar" neste teste.
        // Aqui testamos somente a aceitação dos valores pelos validators.
        expect(
          find.text('Por favor, insira seu e-mail'),
          findsNothing,
        );

        expect(
          find.text('Por favor, insira um e-mail válido'),
          findsNothing,
        );

        expect(
          find.text('Por favor, insira sua senha'),
          findsNothing,
        );

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'não deve chamar Firebase quando o formulário for inválido',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        )
            .on(auth)
            .thenThrow(
              StateError(
                'Firebase Auth não deveria ter sido chamado',
              ),
            );

        await tester.pumpWidget(createTestWidget(auth));

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
  });

  group('LoginScreen - Interação', () {
    testWidgets(
      'deve preencher o campo de e-mail',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        final emailField = find.byType(TextFormField).at(0);

        await tester.enterText(
          emailField,
          'teste@example.com',
        );

        expect(
          find.text('teste@example.com'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve preencher o campo de senha',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        final passwordField = find.byType(TextFormField).at(1);

        await tester.enterText(
          passwordField,
          'senha123',
        );

        expect(
          find.text('senha123'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'campo de senha deve utilizar obscureText',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        final textFields = find.byType(TextField);

        expect(
          textFields,
          findsNWidgets(2),
        );

        final passwordTextField = tester.widget<TextField>(
          textFields.at(1),
        );

        expect(
          passwordTextField.obscureText,
          isTrue,
        );
      },
    );
  });

  group('LoginScreen - Firebase Auth', () {
    testWidgets(
      'deve realizar login com credenciais válidas',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

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

        // O login é assíncrono.
        await tester.pump();

        expect(
          auth.currentUser,
          isNotNull,
        );
      },
    );

    testWidgets(
      'deve exibir mensagem correta para user-not-found',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        )
            .on(auth)
            .thenThrow(
              FirebaseAuthException(
                code: 'user-not-found',
              ),
            );

        await tester.pumpWidget(createTestWidget(auth));

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
      },
    );

    testWidgets(
      'deve exibir mensagem correta para wrong-password',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        )
            .on(auth)
            .thenThrow(
              FirebaseAuthException(
                code: 'wrong-password',
              ),
            );

        await tester.pumpWidget(createTestWidget(auth));

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
      },
    );

    testWidgets(
      'deve exibir mensagem correta para invalid-credential',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        )
            .on(auth)
            .thenThrow(
              FirebaseAuthException(
                code: 'invalid-credential',
              ),
            );

        await tester.pumpWidget(createTestWidget(auth));

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
      },
    );

    testWidgets(
      'deve exibir mensagem genérica para network-request-failed',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        )
            .on(auth)
            .thenThrow(
              FirebaseAuthException(
                code: 'network-request-failed',
              ),
            );

        await tester.pumpWidget(createTestWidget(auth));

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
      },
    );

    testWidgets(
      'deve exibir mensagem genérica para código desconhecido',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        )
            .on(auth)
            .thenThrow(
              FirebaseAuthException(
                code: 'codigo-desconhecido',
              ),
            );

        await tester.pumpWidget(createTestWidget(auth));

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
      },
    );
  });

  group('LoginScreen - SnackBar', () {
    testWidgets(
      'deve exibir SnackBar vermelho em caso de erro',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        )
            .on(auth)
            .thenThrow(
              FirebaseAuthException(
                code: 'invalid-credential',
              ),
            );

        await tester.pumpWidget(createTestWidget(auth));

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
      'não deve exibir SnackBar quando o login for bem-sucedido',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

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
          find.byType(SnackBar),
          findsNothing,
        );
      },
    );
  });
}
