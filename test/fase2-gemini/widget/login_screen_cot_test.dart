import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/recup-senha.dart';
import 'package:sintonize/tela-inicial.dart';

import 'login_screen_cot_test.mocks.dart';

class TestNavigatorObserver extends NavigatorObserver {
  Route<dynamic>? pushedRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoute = route;
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    pushedRoute = newRoute;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<UserCredential>(),
])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockUserCredential mockUserCredential;
  late TestNavigatorObserver navObserver;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    navObserver = TestNavigatorObserver();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      navigatorObservers: [navObserver],
      home: LoginScreen(auth: mockAuth),
    );
  }

  group('LoginScreen - Renderização Básica', () {
    testWidgets('Deve renderizar os campos de texto e botões principais', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Esqueci minha senha'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Não tem cadastro? Cadastre-se!'), findsOneWidget);
    });
  });

  group('LoginScreen - Validação de Formulário', () {
    testWidgets('Deve exibir mensagens de erro quando os campos estiverem vazios', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      verifyNever(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ));
    });

    testWidgets('Deve exibir mensagem de erro para formato de e-mail inválido', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'email_invalido');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      verifyNever(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ));
    });

    testWidgets('Deve exibir mensagem de erro quando a senha tiver menos de 6 caracteres', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'teste@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), '12345');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      verifyNever(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ));
    });
  });

  group('LoginScreen - Interações e Navegação', () {
    testWidgets('Deve navegar para RecupSenhaScreen ao clicar em Esqueci minha senha', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final buttonFinder = find.widgetWithText(TextButton, 'Esqueci minha senha');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(RecupSenhaScreen), findsOneWidget);
    });

    testWidgets('Deve navegar para CadastroScreen ao clicar em Não tem cadastro? Cadastre-se!', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final buttonFinder = find.widgetWithText(TextButton, 'Não tem cadastro? Cadastre-se!');
      // Garante que o botão entre no campo de visão dentro do SingleChildScrollView
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(CadastroScreen), findsOneWidget);
    });
  });

  group('LoginScreen - Sucesso no Login', () {
    testWidgets('Deve autenticar e navegar para TelaInicialScreen com credenciais válidas', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@sintonize.com',
        password: 'senhaValida123',
      )).thenAnswer((_) async => mockUserCredential);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaValida123');

      final buttonFinder = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);

      // Usamos pump() para processar a resposta assíncrona do signInWithEmailAndPassword
      // sem acionar a renderização completa e ciclo de vida que trava em TelaInicialScreen
      await tester.pump();

      verify(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@sintonize.com',
        password: 'senhaValida123',
      )).called(1);

      // Verifica se a substituição de rota ocorreu e o destino foi configurado para TelaInicialScreen
      expect(navObserver.pushedRoute, isA<MaterialPageRoute>());
      expect(
        (navObserver.pushedRoute as MaterialPageRoute).builder(tester.element(find.byType(LoginScreen))),
        isA<TelaInicialScreen>(),
      );
    });
  });

  group('LoginScreen - Tratamento de Erros do Firebase Auth', () {
    testWidgets('Deve exibir SnackBar de erro com user-not-found', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'naoexiste@sintonize.com',
        password: 'senhaValida123',
      )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'naoexiste@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaValida123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(
        find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.'),
        findsOneWidget,
      );
    });

    testWidgets('Deve exibir SnackBar de erro com wrong-password', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@sintonize.com',
        password: 'senhaIncorreta',
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaIncorreta');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(
        find.text('Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
        findsOneWidget,
      );
    });

    testWidgets('Deve exibir SnackBar de erro com invalid-credential', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@sintonize.com',
        password: 'senhaValida123',
      )).thenThrow(FirebaseAuthException(code: 'invalid-credential'));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaValida123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(
        find.text('As credenciais fornecidas são inválidas. Tente novamente.'),
        findsOneWidget,
      );
    });

    testWidgets('Deve exibir SnackBar com mensagem padrão para erros desconhecidos', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@sintonize.com',
        password: 'senhaValida123',
      )).thenThrow(FirebaseAuthException(code: 'too-many-requests'));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaValida123');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();

      expect(
        find.text('Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.'),
        findsOneWidget,
      );
    });
  });
}

