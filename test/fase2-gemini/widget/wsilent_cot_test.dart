import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

import 'wsilent_cot_test.mocks.dart';

@GenerateNiceMocks([MockSpec<FirebaseAuth>(), MockSpec<UserCredential>()])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
  });

  Widget buildTestableWidget({required FirebaseAuth auth}) {
    return MaterialApp(
      home: LoginScreen(auth: auth),
    );
  }

  group('LoginScreen - Renderização Básica', () {
    testWidgets('deve renderizar todos os elementos visuais iniciais', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      // Logo
      expect(find.byType(Image), findsOneWidget);

      // Labels e Textos
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);

      // Campos de entrada e Botão
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });

  group('LoginScreen - Validação de Formulário', () {
    testWidgets('deve exibir mensagens de erro quando os campos estiverem vazios', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      verifyNever(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ));
    });

    testWidgets('deve exibir erro para e-mail com formato inválido', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'emailinvalido');
      await tester.enterText(passwordField, '123456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      verifyNever(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ));
    });

    testWidgets('deve exibir erro quando a senha tiver menos de 6 caracteres', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'usuario@teste.com');
      await tester.enterText(passwordField, '12345');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      verifyNever(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      ));
    });
  });

  group('LoginScreen - Interação do Usuário', () {
    testWidgets('deve ocultar os caracteres no campo de senha', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final passwordFieldFinder = find.byType(TextFormField).at(1);
      final TextField textFieldWidget = tester.widget(
        find.descendant(of: passwordFieldFinder, matching: find.byType(TextField)),
      );

      expect(textFieldWidget.obscureText, isTrue);
    });
  });

  group('LoginScreen - Cenário de Sucesso', () {
    testWidgets('deve autenticar e navegar para TelaInicialScreen com credenciais válidas', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@teste.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);

      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, '  usuario@teste.com  ');
      await tester.enterText(passwordField, '  password123  ');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      verify(mockAuth.signInWithEmailAndPassword(
        email: 'usuario@teste.com',
        password: 'password123',
      )).called(1);

      expect(find.byType(TelaInicialScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });

  group('LoginScreen - Cenários de Erro (FirebaseAuthException)', () {
    testWidgets('deve exibir mensagem correta para código "user-not-found"', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      await tester.enterText(find.byType(TextFormField).at(0), 'user@teste.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('deve exibir mensagem correta para código "wrong-password"', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      await tester.enterText(find.byType(TextFormField).at(0), 'user@teste.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('deve exibir mensagem correta para código "invalid-credential"', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'invalid-credential'));

      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      await tester.enterText(find.byType(TextFormField).at(0), 'user@teste.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('As credenciais fornecidas são inválidas. Tente novamente.'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('deve exibir mensagem genérica para erros inesperados ou de rede', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(code: 'network-request-failed'));

      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      await tester.enterText(find.byType(TextFormField).at(0), 'user@teste.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
