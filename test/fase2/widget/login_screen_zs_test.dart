import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/recup-senha.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  Widget createTestWidget({
    FirebaseAuth? auth,
  }) {
    return MaterialApp(
      home: LoginScreen(
        auth: auth ?? mockAuth,
      ),
    );
  }

  Future<void> preencherLogin(
    WidgetTester tester, {
    String email = 'usuario@email.com',
    String senha = '123456',
  }) async {
    final campos = find.byType(TextFormField);

    await tester.enterText(campos.at(0), email);
    await tester.enterText(campos.at(1), senha);
  }

  group('LoginScreen - validação', () {
    testWidgets(
      'exibe erros quando e-mail e senha estão vazios',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

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
      'exibe erro quando o e-mail é inválido',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

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
      },
    );

    testWidgets(
      'exibe erro quando a senha tem menos de 6 caracteres',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        await preencherLogin(
          tester,
          email: 'usuario@email.com',
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
  });

  group('LoginScreen - interação', () {
    testWidgets(
      'permite preencher e-mail e senha',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        await preencherLogin(tester);

        expect(
          find.text('usuario@email.com'),
          findsOneWidget,
        );

        // Como o campo de senha usa obscureText, o texto digitado
        // não deve ser procurado como Text widget.
        final senhaField = tester.widget<TextFormField>(
          find.byType(TextFormField).at(1),
        );

        expect(senhaField.controller?.text, '123456');
      },
    );

    testWidgets(
      'botão Esqueci minha senha navega para RecupSenhaScreen',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        final botao = find.text('Esqueci minha senha');

        await tester.ensureVisible(botao);
        await tester.tap(botao);
        await tester.pumpAndSettle();

        expect(
          find.byType(RecupSenhaScreen),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'botão de cadastro navega para CadastroScreen',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        final botao = find.text('Não tem cadastro? Cadastre-se!');

        // O botão fica inicialmente abaixo da viewport de 600px
        // utilizada pelo teste.
        await tester.ensureVisible(botao);
        await tester.tap(botao);
        await tester.pumpAndSettle();

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );
      },
    );
  });

  group('LoginScreen - Firebase Auth', () {
    testWidgets(
      'mostra mensagem de usuário não encontrado',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(auth).thenThrow(
              FirebaseAuthException(
                code: 'user-not-found',
                message: 'Usuário não encontrado',
              ),
            );

        await tester.pumpWidget(
          createTestWidget(auth: auth),
        );

        await preencherLogin(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);

        expect(
          find.text(
            'Usuário não encontrado. '
            'Verifique o e-mail e tente novamente.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'mostra mensagem de senha incorreta',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(auth).thenThrow(
              FirebaseAuthException(
                code: 'wrong-password',
                message: 'Senha incorreta',
              ),
            );

        await tester.pumpWidget(
          createTestWidget(auth: auth),
        );

        await preencherLogin(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);

        expect(
          find.text(
            'Senha incorreta. '
            'Certifique-se de que está digitando a senha corretamente.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'mostra mensagem para credencial inválida',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(auth).thenThrow(
              FirebaseAuthException(
                code: 'invalid-credential',
                message: 'Credencial inválida',
              ),
            );

        await tester.pumpWidget(
          createTestWidget(auth: auth),
        );

        await preencherLogin(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);

        expect(
          find.text(
            'As credenciais fornecidas são inválidas. '
            'Tente novamente.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'mostra mensagem genérica para erro inesperado',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(auth).thenThrow(
              FirebaseAuthException(
                code: 'internal-error',
                message: 'Erro interno',
              ),
            );

        await tester.pumpWidget(
          createTestWidget(auth: auth),
        );

        await preencherLogin(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(find.byType(SnackBar), findsOneWidget);

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
      'realiza login com credenciais válidas',
      (tester) async {
        final auth = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'test-user',
            email: 'usuario@email.com',
          ),
        );

        await tester.pumpWidget(
          createTestWidget(auth: auth),
        );

        await preencherLogin(
          tester,
          email: 'usuario@email.com',
          senha: '123456',
        );

        await tester.tap(find.text('Entrar'));

        // O LoginScreen deve tentar navegar para TelaInicialScreen.
        //
        // Não inicializamos Firebase artificialmente aqui.
        // TelaInicialScreen acessa FirebaseAuth.instance diretamente,
        // portanto o teste pode expor essa dependência.
        await tester.pump();

        expect(auth.currentUser, isNotNull);
        expect(
          auth.currentUser!.email,
          'usuario@email.com',
        );
      },
    );
  });

  group('LoginScreen - elementos da interface', () {
    testWidgets(
      'renderiza os principais elementos',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('Esqueci minha senha'), findsOneWidget);
        expect(
          find.text('Não tem cadastro? Cadastre-se!'),
          findsOneWidget,
        );

        expect(
          find.byType(TextFormField),
          findsNWidgets(2),
        );

        expect(
          find.byType(ElevatedButton),
          findsOneWidget,
        );

        expect(
          find.byType(TextButton),
          findsNWidgets(2),
        );
      },
    );
  });
}
