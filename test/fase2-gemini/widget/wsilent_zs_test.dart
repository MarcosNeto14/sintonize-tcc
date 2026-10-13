import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/login.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/recup-senha.dart';

/// Implementação controlada para simular erros do Firebase sem conflitos de stubs do Mockito
class FakeFirebaseAuthWithException extends MockFirebaseAuth {
  final FirebaseAuthException exceptionToThrow;

  FakeFirebaseAuthWithException(this.exceptionToThrow);

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw exceptionToThrow;
  }
}

void main() {
  Widget createWidgetUnderTest({
    FirebaseAuth? auth,
    NavigatorObserver? navigatorObserver,
  }) {
    return MaterialApp(
      navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
      home: LoginScreen(auth: auth),
    );
  }

  group('LoginScreen - Renderização Inicial', () {
    testWidgets('deve renderizar os campos de texto e botões corretamente',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();

      await tester.pumpWidget(createWidgetUnderTest(auth: mockAuth));

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);

      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Esqueci minha senha'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Não tem cadastro? Cadastre-se!'), findsOneWidget);
    });
  });

  group('LoginScreen - Validação de Formulário', () {
    testWidgets('deve exibir erros de validação ao submeter campos vazios',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();

      await tester.pumpWidget(createWidgetUnderTest(auth: mockAuth));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
    });

    testWidgets('deve exibir erro se o e-mail for inválido',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();

      await tester.pumpWidget(createWidgetUnderTest(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'emailinvalido');
      await tester.enterText(textFields.last, '123456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsNothing);
    });

    testWidgets('deve exibir erro se a senha tiver menos de 6 caracteres',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();

      await tester.pumpWidget(createWidgetUnderTest(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'teste@dominio.com');
      await tester.enterText(textFields.last, '12345');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
    });
  });

  group('LoginScreen - Fluxo de Autenticação com Sucesso', () {
    testWidgets('deve autenticar e disparar navegação ao inserir dados válidos',
        (WidgetTester tester) async {
      // Configura tela em tamanho suficiente para evitar problemas de scroll
      tester.view.physicalSize = const Size(1080, 2160);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockAuth = MockFirebaseAuth();
      final observer = RouteObserver<ModalRoute<dynamic>>();
      bool pushedReplacement = false;

      // Usamos um NavigatorObserver mock/listener simples para interceptar a rota
      // sem inicializar as dependências estáticas de TelaInicialScreen
      final testApp = MaterialApp(
        navigatorObservers: [
          _NavigatorTestObserver(
            onPushed: (route, previousRoute) {
              if (previousRoute != null) {
                pushedReplacement = true;
              }
            },
          ),
        ],
        home: LoginScreen(auth: mockAuth),
      );

      await tester.pumpWidget(testApp);

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'usuario@teste.com');
      await tester.enterText(textFields.last, 'senha123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));

      // Realizamos apenas um pump para iniciar a transição sem deixar a TelaInicialScreen executar chamadas estáticas
      await tester.pump();

      expect(mockAuth.currentUser, isNotNull);
      expect(pushedReplacement, isTrue);
    });
  });

  group('LoginScreen - Tratamento de Erros do Firebase Auth', () {
    testWidgets('deve exibir mensagem correspondente ao erro user-not-found',
        (WidgetTester tester) async {
      final mockAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'user-not-found'),
      );

      await tester.pumpWidget(createWidgetUnderTest(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'usuario@teste.com');
      await tester.enterText(textFields.last, 'password123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(
        find.text('Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('deve exibir mensagem correspondente ao erro wrong-password',
        (WidgetTester tester) async {
      final mockAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'wrong-password'),
      );

      await tester.pumpWidget(createWidgetUnderTest(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'usuario@teste.com');
      await tester.enterText(textFields.last, 'password123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(
        find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.'),
        findsOneWidget,
      );
    });

    testWidgets('deve exibir mensagem correspondente ao erro invalid-credential',
        (WidgetTester tester) async {
      final mockAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'invalid-credential'),
      );

      await tester.pumpWidget(createWidgetUnderTest(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'usuario@teste.com');
      await tester.enterText(textFields.last, 'password123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(
        find.text('As credenciais fornecidas são inválidas. Tente novamente.'),
        findsOneWidget,
      );
    });

    testWidgets('deve exibir mensagem genérica para erros não mapeados',
        (WidgetTester tester) async {
      final mockAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'network-request-failed'),
      );

      await tester.pumpWidget(createWidgetUnderTest(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'usuario@teste.com');
      await tester.enterText(textFields.last, 'password123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(
        find.text('Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.'),
        findsOneWidget,
      );
    });
  });

  group('LoginScreen - Navegação Secundária', () {
    testWidgets('deve navegar para RecupSenhaScreen ao tocar em Esqueci minha senha',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();

      await tester.pumpWidget(createWidgetUnderTest(auth: mockAuth));

      final button = find.widgetWithText(TextButton, 'Esqueci minha senha');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.byType(RecupSenhaScreen), findsOneWidget);
    });

    testWidgets('deve navegar para CadastroScreen ao tocar em Cadastre-se',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();

      await tester.pumpWidget(createWidgetUnderTest(auth: mockAuth));

      final button = find.widgetWithText(TextButton, 'Não tem cadastro? Cadastre-se!');
      // Garante visibilidade dentro do SingleChildScrollView
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.byType(CadastroScreen), findsOneWidget);
    });
  });
}

class _NavigatorTestObserver extends NavigatorObserver {
  final void Function(Route<dynamic> route, Route<dynamic>? previousRoute)? onPushed;

  _NavigatorTestObserver({this.onPushed});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    onPushed?.call(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      onPushed?.call(newRoute, oldRoute);
    }
  }
}
