import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/recup-senha.dart';
import 'package:sintonize/tela-inicial.dart';

// Fake customizado que herda do MockFirebaseAuth para simular erros específicos sem violar Null Safety
class ExceptionMockFirebaseAuth extends MockFirebaseAuth {
  final FirebaseAuthException? exceptionToThrow;

  ExceptionMockFirebaseAuth({this.exceptionToThrow});

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return super.signInWithEmailAndPassword(email: email, password: password);
  }
}

// Configuração para permitir chamadas globais do Firebase no ambiente de teste
void setupFirebaseCoreMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocksPlatform();
}

void setupFirebaseCoreMocksPlatform() {
  FirebasePlatform.instance = _MockFirebasePlatform();
}

class _MockFirebasePlatform extends FirebasePlatform {
  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return _MockFirebaseAppPlatform(name);
  }

  @override
  List<FirebaseAppPlatform> get apps => [_MockFirebaseAppPlatform(defaultFirebaseAppName)];
}

class _MockFirebaseAppPlatform extends FirebaseAppPlatform {
  _MockFirebaseAppPlatform(String name)
      : super(
          name,
          const FirebaseOptions(
            apiKey: 'mock_api_key',
            appId: 'mock_app_id',
            messagingSenderId: 'mock_sender_id',
            projectId: 'mock_project_id',
          ),
        );
}

void main() {
  setUpAll(() {
    setupFirebaseCoreMocks();
  });

  group('LoginScreen Widget Tests', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    Future<void> pumpLoginScreen(
      WidgetTester tester, {
      FirebaseAuth? authInstance,
    }) async {
      // Ajusta o tamanho da tela virtual para evitar overflow de layout
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(auth: authInstance ?? mockAuth),
        ),
      );
    }

    testWidgets('deve renderizar todos os elementos visuais principais', (tester) async {
      await pumpLoginScreen(tester);

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Esqueci minha senha'), findsOneWidget);
      expect(find.text('Não tem cadastro? Cadastre-se!'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    group('Validações de Formulário', () {
      testWidgets('deve exibir erros de validação quando os campos estão vazios', (tester) async {
        await pumpLoginScreen(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
        expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      });

      testWidgets('deve exibir erro para formato de e-mail inválido', (tester) async {
        await pumpLoginScreen(tester);

        final emailField = find.byType(TextFormField).at(0);
        await tester.enterText(emailField, 'email-invalido');

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      });

      testWidgets('deve exibir erro quando a senha tem menos de 6 caracteres', (tester) async {
        await pumpLoginScreen(tester);

        final emailField = find.byType(TextFormField).at(0);
        final senhaField = find.byType(TextFormField).at(1);

        await tester.enterText(emailField, 'usuario@teste.com');
        await tester.enterText(senhaField, '12345');

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      });
    });

    group('Fluxo de Autenticação e Navegação', () {
      testWidgets('deve navegar para TelaInicialScreen em caso de credenciais corretas', (tester) async {
        final user = MockUser(
          isAnonymous: false,
          uid: 'uid123',
          email: 'usuario@teste.com',
        );
        mockAuth = MockFirebaseAuth(mockUser: user);

        await pumpLoginScreen(tester, authInstance: mockAuth);

        final emailField = find.byType(TextFormField).at(0);
        final senhaField = find.byType(TextFormField).at(1);

        await tester.enterText(emailField, 'usuario@teste.com');
        await tester.enterText(senhaField, 'senha123');

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsNothing);
        expect(find.byType(TelaInicialScreen), findsOneWidget);
      });

      testWidgets('deve exibir SnackBar de erro com mensagem tratada para user-not-found', (tester) async {
        final mockExceptionAuth = ExceptionMockFirebaseAuth(
          exceptionToThrow: FirebaseAuthException(code: 'user-not-found'),
        );

        await pumpLoginScreen(tester, authInstance: mockExceptionAuth);

        await tester.enterText(find.byType(TextFormField).at(0), 'inexistente@teste.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'password123');

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.'),
          findsOneWidget,
        );
      });

      testWidgets('deve exibir SnackBar de erro com mensagem tratada para wrong-password', (tester) async {
        final mockExceptionAuth = ExceptionMockFirebaseAuth(
          exceptionToThrow: FirebaseAuthException(code: 'wrong-password'),
        );

        await pumpLoginScreen(tester, authInstance: mockExceptionAuth);

        await tester.enterText(find.byType(TextFormField).at(0), 'usuario@teste.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'senhaerrada');

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
          findsOneWidget,
        );
      });
    });

    group('Navegação dos Botões Secundários', () {
      testWidgets('deve navegar para RecupSenhaScreen ao tocar em "Esqueci minha senha"', (tester) async {
        await pumpLoginScreen(tester);

        final button = find.text('Esqueci minha senha');
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();

        expect(find.byType(RecupSenhaScreen), findsOneWidget);
      });

      testWidgets('deve navegar para CadastroScreen ao tocar em "Não tem cadastro? Cadastre-se!"', (tester) async {
        await pumpLoginScreen(tester);

        final button = find.text('Não tem cadastro? Cadastre-se!');
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();

        expect(find.byType(CadastroScreen), findsOneWidget);
      });
    });
  });
}

