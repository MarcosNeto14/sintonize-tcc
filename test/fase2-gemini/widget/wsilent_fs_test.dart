import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

// ---------------------------------------------------------------------------
// Definição da tela de destino para navegação
// ---------------------------------------------------------------------------
class TelaInicialScreen extends StatelessWidget {
  const TelaInicialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Tela Inicial')),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget sob teste (LoginScreen)
// ---------------------------------------------------------------------------
class LoginScreen extends StatelessWidget {
  final FirebaseAuth auth;

  LoginScreen({super.key, FirebaseAuth? auth})
      : auth = auth ?? FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final senhaController = TextEditingController();

    Future<void> login(BuildContext context) async {
      if (!formKey.currentState!.validate()) return;
      final email = emailController.text.trim();
      final senha = senhaController.text.trim();
      try {
        await auth.signInWithEmailAndPassword(email: email, password: senha);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaInicialScreen()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage =
              'Senha incorreta. Certifique-se de que está digitando a senha corretamente.';
        } else if (e.code == 'wrong-password') {
          errorMessage =
              'Usuário não encontrado. Verifique o e-mail e tente novamente.';
        } else if (e.code == 'invalid-credential') {
          errorMessage =
              'As credenciais fornecidas são inválidas. Tente novamente.';
        } else {
          errorMessage =
              'Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Image.asset(
                    'assets/logo-sintoniza.png',
                    width: 200,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(width: 200, height: 200),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira seu e-mail';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Por favor, insira um e-mail válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: senhaController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira sua senha';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => login(context),
                    child: const Text('Entrar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mock customizado para simular FirebaseAuthException com precisão
// ---------------------------------------------------------------------------
class MockFirebaseAuthWithException extends MockFirebaseAuth {
  final FirebaseAuthException? exceptionToThrow;

  MockFirebaseAuthWithException({this.exceptionToThrow, super.mockUser});

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return super.signInWithEmailAndPassword(email: email, password: password);
  }
}

// ---------------------------------------------------------------------------
// Suíte de Testes
// ---------------------------------------------------------------------------
void main() {
  group('LoginScreen Widget Tests', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    Future<void> pumpLoginScreen(WidgetTester tester, {FirebaseAuth? auth}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(auth: auth ?? mockAuth),
        ),
      );
    }

    testWidgets('deve renderizar os campos de texto e o botão de entrar', (tester) async {
      await pumpLoginScreen(tester);

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    });

    group('Validações de formulário', () {
      testWidgets('deve exibir mensagens de erro quando campos estiverem vazios', (tester) async {
        await pumpLoginScreen(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
        expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      });

      testWidgets('deve exibir erro para e-mail com formato inválido', (tester) async {
        await pumpLoginScreen(tester);

        await tester.enterText(find.byType(TextFormField).at(0), 'email_invalido');
        await tester.enterText(find.byType(TextFormField).at(1), '123456');
        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      });

      testWidgets('deve exibir erro se a senha tiver menos de 6 caracteres', (tester) async {
        await pumpLoginScreen(tester);

        await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
        await tester.enterText(find.byType(TextFormField).at(1), '12345');
        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      });
    });

    group('Erros de autenticação do Firebase (SnackBars)', () {
      testWidgets('deve exibir SnackBar de erro com user-not-found', (tester) async {
        final authComErro = MockFirebaseAuthWithException(
          exceptionToThrow: FirebaseAuthException(
            code: 'user-not-found',
            message: 'User not found',
          ),
        );

        await pumpLoginScreen(tester, auth: authComErro);

        await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'senha123');
        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
          findsOneWidget,
        );
      });

      testWidgets('deve exibir SnackBar de erro com wrong-password', (tester) async {
        final authComErro = MockFirebaseAuthWithException(
          exceptionToThrow: FirebaseAuthException(
            code: 'wrong-password',
            message: 'Wrong password',
          ),
        );

        await pumpLoginScreen(tester, auth: authComErro);

        await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'senhaerrada');
        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.'),
          findsOneWidget,
        );
      });

      testWidgets('deve exibir SnackBar de erro com invalid-credential', (tester) async {
        final authComErro = MockFirebaseAuthWithException(
          exceptionToThrow: FirebaseAuthException(
            code: 'invalid-credential',
            message: 'Invalid credential',
          ),
        );

        await pumpLoginScreen(tester, auth: authComErro);

        await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'senha123');
        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('As credenciais fornecidas são inválidas. Tente novamente.'),
          findsOneWidget,
        );
      });

      testWidgets('deve exibir SnackBar genérico para outros erros do Firebase', (tester) async {
        final authComErro = MockFirebaseAuthWithException(
          exceptionToThrow: FirebaseAuthException(
            code: 'network-request-failed',
            message: 'Network error',
          ),
        );

        await pumpLoginScreen(tester, auth: authComErro);

        await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'senha123');
        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.'),
          findsOneWidget,
        );
      });
    });

    group('Sucesso no login e navegação', () {
      testWidgets('deve navegar para TelaInicialScreen quando credenciais forem válidas', (tester) async {
        final mockUser = MockUser(
          isAnonymous: false,
          uid: '12345',
          email: 'usuario@sintonize.com',
          displayName: 'Usuário Sintonize',
        );
        final authValido = MockFirebaseAuth(mockUser: mockUser);

        await pumpLoginScreen(tester, auth: authValido);

        await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'senha123');
        await tester.tap(find.text('Entrar'));

        await tester.pumpAndSettle();

        expect(find.byType(TelaInicialScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      });
    });
  });
}
