import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginScreen Widget', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    Widget createWidget(FirebaseAuth auth) {
      return MaterialApp(
        home: LoginScreen(auth: auth),
      );
    }

    Future<void> preencherFormulario(
      WidgetTester tester, {
      String email = 'usuario@test.com',
      String senha = 'senha123',
    }) async {
      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), email);
      await tester.enterText(campos.at(1), senha);
    }

    MockFirebaseAuth criarAuthComErro(String codigo) {
      final auth = MockFirebaseAuth();

      whenCalling(
        Invocation.method(
          #signInWithEmailAndPassword,
          null,
          {
            #email: 'usuario@test.com',
            #password: 'senha123',
          },
        ),
      ).on(auth).thenThrow(
            FirebaseAuthException(code: codigo),
          );

      return auth;
    }

    testWidgets(
      'deve exibir erro quando o e-mail está vazio',
      (tester) async {
        await tester.pumpWidget(createWidget(mockAuth));

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir erro quando o e-mail é inválido',
      (tester) async {
        await tester.pumpWidget(createWidget(mockAuth));

        await preencherFormulario(
          tester,
          email: 'email-invalido',
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
      'deve exibir erro quando a senha está vazia',
      (tester) async {
        await tester.pumpWidget(createWidget(mockAuth));

        await preencherFormulario(
          tester,
          senha: '',
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
      'deve exibir erro quando a senha tem menos de 6 caracteres',
      (tester) async {
        await tester.pumpWidget(createWidget(mockAuth));

        await preencherFormulario(
          tester,
          senha: '12345',
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
      'deve exibir mensagem para user-not-found',
      (tester) async {
        final authComErro = criarAuthComErro('user-not-found');

        await tester.pumpWidget(createWidget(authComErro));

        await preencherFormulario(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Senha incorreta. Certifique-se de que está digitando '
            'a senha corretamente.',
          ),
          findsOneWidget,
        );

        expect(
          find.byType(SnackBar),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir mensagem para wrong-password',
      (tester) async {
        final authComErro = criarAuthComErro('wrong-password');

        await tester.pumpWidget(createWidget(authComErro));

        await preencherFormulario(tester);

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
        final authComErro = criarAuthComErro('invalid-credential');

        await tester.pumpWidget(createWidget(authComErro));

        await preencherFormulario(tester);

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
        final authComErro = criarAuthComErro('unknown-error');

        await tester.pumpWidget(createWidget(authComErro));

        await preencherFormulario(tester);

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
      'deve realizar login com credenciais válidas',
      (tester) async {
        await tester.pumpWidget(createWidget(mockAuth));

        await preencherFormulario(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          mockAuth.currentUser,
          isNotNull,
        );

        expect(
          mockAuth.currentUser!.email,
          'usuario@test.com',
        );
      },
    );
  });
}
