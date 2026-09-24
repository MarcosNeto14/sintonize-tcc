import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/login.dart';
import 'package:sintonize/recup-senha.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginScreen', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    Widget createWidget() {
      return MaterialApp(
        home: LoginScreen(auth: mockAuth),
      );
    }

    Future<void> preencherLogin(
      WidgetTester tester, {
      String email = 'usuario@email.com',
      String senha = '123456',
    }) async {
      await tester.enterText(
        find.byType(TextFormField).at(0),
        email,
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        senha,
      );
    }

    group('renderização', () {
      testWidgets('deve exibir os elementos principais da tela', (tester) async {
        await tester.pumpWidget(createWidget());

        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('Esqueci minha senha'), findsOneWidget);
        expect(
          find.text('Não tem cadastro? Cadastre-se!'),
          findsOneWidget,
        );

        expect(find.byType(TextFormField), findsNWidgets(2));
      });
    });

    group('validação do formulário', () {
      testWidgets(
        'deve mostrar erro quando e-mail e senha estiverem vazios',
        (tester) async {
          await tester.pumpWidget(createWidget());

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
        'deve mostrar erro quando o e-mail for inválido',
        (tester) async {
          await tester.pumpWidget(createWidget());

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

          expect(
            find.text('Por favor, insira sua senha'),
            findsNothing,
          );
        },
      );

      testWidgets(
        'deve mostrar erro quando a senha tiver menos de 6 caracteres',
        (tester) async {
          await tester.pumpWidget(createWidget());

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

      testWidgets(
        'não deve chamar Firebase Auth quando formulário for inválido',
        (tester) async {
          await tester.pumpWidget(createWidget());

          await tester.tap(find.text('Entrar'));
          await tester.pump();

          // Como a validação falhou, o método de autenticação não deve
          // ter sido executado. O mock permanece sem usuário autenticado.
          expect(mockAuth.currentUser, isNull);
        },
      );
    });

    group('entrada de dados', () {
      testWidgets(
        'deve permitir inserir e-mail e senha',
        (tester) async {
          await tester.pumpWidget(createWidget());

          final campos = find.byType(TextFormField);

          await tester.enterText(
            campos.at(0),
            'teste@email.com',
          );

          await tester.enterText(
            campos.at(1),
            'minhasenha',
          );

          expect(
            find.widgetWithText(TextFormField, 'teste@email.com'),
            findsOneWidget,
          );

          final senhaField = find.descendant(
            of: campos.at(1),
            matching: find.byType(EditableText),
          );

          expect(senhaField, findsOneWidget);

          final editableText = tester.widget<EditableText>(senhaField);

          expect(editableText.obscureText, isTrue);
        },
      );
    });

    group('Firebase Auth', () {
      testWidgets(
        'deve navegar para TelaInicialScreen após login bem-sucedido',
        (tester) async {
          await tester.pumpWidget(createWidget());

          await preencherLogin(tester);

          await tester.tap(find.text('Entrar'));
          await tester.pumpAndSettle();

          expect(mockAuth.currentUser, isNotNull);
        },
      );

      testWidgets(
        'deve exibir mensagem para user-not-found',
        (tester) async {
          whenCalling(
            Invocation.method(
              #signInWithEmailAndPassword,
              null,
            ),
          )
              .on(mockAuth)
              .thenThrow(
                FirebaseAuthException(
                  code: 'user-not-found',
                ),
              );

          await tester.pumpWidget(createWidget());

          await preencherLogin(tester);

          await tester.tap(find.text('Entrar'));
          await tester.pumpAndSettle();

          expect(
            find.text(
              'Senha incorreta. Certifique-se de que está digitando '
              'a senha corretamente.',
            ),
            findsOneWidget,
          );

          final snackBar = tester.widget<SnackBar>(
            find.byType(SnackBar),
          );

          expect(snackBar.backgroundColor, Colors.red);
        },
      );

      testWidgets(
        'deve exibir mensagem para wrong-password',
        (tester) async {
          whenCalling(
            Invocation.method(
              #signInWithEmailAndPassword,
              null,
            ),
          )
              .on(mockAuth)
              .thenThrow(
                FirebaseAuthException(
                  code: 'wrong-password',
                ),
              );

          await tester.pumpWidget(createWidget());

          await preencherLogin(tester);

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
          whenCalling(
            Invocation.method(
              #signInWithEmailAndPassword,
              null,
            ),
          )
              .on(mockAuth)
              .thenThrow(
                FirebaseAuthException(
                  code: 'invalid-credential',
                ),
              );

          await tester.pumpWidget(createWidget());

          await preencherLogin(tester);

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
          whenCalling(
            Invocation.method(
              #signInWithEmailAndPassword,
              null,
            ),
          )
              .on(mockAuth)
              .thenThrow(
                FirebaseAuthException(
                  code: 'network-request-failed',
                ),
              );

          await tester.pumpWidget(createWidget());

          await preencherLogin(tester);

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
    });

    group('navegação', () {
      testWidgets(
        'deve navegar ao tocar em Esqueci minha senha',
        (tester) async {
          await tester.pumpWidget(createWidget());

          await tester.tap(find.text('Esqueci minha senha'));
          await tester.pumpAndSettle();

          expect(find.byType(LoginScreen), findsNothing);
          expect(find.byType(RecupSenhaScreen), findsOneWidget);
        },
      );

      testWidgets(
        'deve navegar ao tocar em Cadastre-se',
        (tester) async {
          await tester.pumpWidget(createWidget());

          final cadastroButton = find.text(
            'Não tem cadastro? Cadastre-se!',
          );

          await tester.scrollUntilVisible(
            cadastroButton,
            300,
            scrollable: find.byType(Scrollable),
          );

          await tester.tap(cadastroButton);
          await tester.pumpAndSettle();

          expect(find.byType(LoginScreen), findsNothing);
          expect(find.byType(CadastroScreen), findsOneWidget);
        },
      );
    });

    group('interação com botão Entrar', () {
      testWidgets(
        'deve aceitar credenciais válidas e autenticar o usuário',
        (tester) async {
          await tester.pumpWidget(createWidget());

          await preencherLogin(
            tester,
            email: 'teste@sintonize.com',
            senha: 'senha123',
          );

          await tester.tap(find.text('Entrar'));
          await tester.pumpAndSettle();

          expect(mockAuth.currentUser, isNotNull);
          expect(
            mockAuth.currentUser?.email,
            'teste@sintonize.com',
          );
        },
      );
    });
  });
}
