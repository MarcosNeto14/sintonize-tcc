import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

// Fake customizado para simular lançamentos de FirebaseAuthException sem depender de stubs do Mockito
class FakeFirebaseAuthWithException extends Fake implements FirebaseAuth {
  final FirebaseAuthException exceptionToThrow;

  FakeFirebaseAuthWithException(this.exceptionToThrow);

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw exceptionToThrow;
  }
}

Widget buildTestableWidget({required FirebaseAuth auth}) {
  return MaterialApp(
    home: LoginScreen(auth: auth),
  );
}

void main() {
  // Inicializa o binding e registra os mocks Pigeon oficiais do Firebase Core
  setupFirebaseCoreMocks();

  setUpAll(() async {
    // Inicializa o app Firebase mockado para o ambiente de testes
    await Firebase.initializeApp();
  });

  group('Validações de Formulário (LoginScreen)', () {
    testWidgets('Deve exibir erros quando campos estiverem vazios',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir erro para formato de e-mail inválido',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'email_invalido');
      await tester.enterText(textFields.at(1), '123456');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir erro quando a senha tiver menos de 6 caracteres',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth();
      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'usuario@exemplo.com');
      await tester.enterText(textFields.at(1), '123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pumpAndSettle();

      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });

  group('Tratamento de Exceções do Firebase Auth', () {
    testWidgets(
        'Deve exibir SnackBar vermelho quando usuário não for encontrado',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'user-not-found'),
      );

      await tester.pumpWidget(buildTestableWidget(auth: fakeAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'naoexiste@exemplo.com');
      await tester.enterText(textFields.at(1), 'password123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.'),
        findsOneWidget,
      );

      final SnackBar snackBar = tester.widget(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir SnackBar vermelho quando a senha estiver incorreta',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'wrong-password'),
      );

      await tester.pumpWidget(buildTestableWidget(auth: fakeAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'usuario@exemplo.com');
      await tester.enterText(textFields.at(1), 'wrong_password');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text(
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
        findsOneWidget,
      );
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir SnackBar vermelho para invalid-credential',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'invalid-credential'),
      );

      await tester.pumpWidget(buildTestableWidget(auth: fakeAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'invalido@exemplo.com');
      await tester.enterText(textFields.at(1), 'password123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('As credenciais fornecidas são inválidas. Tente novamente.'),
        findsOneWidget,
      );
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets('Deve exibir erro inesperado para outros códigos do Firebase',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuthWithException(
        FirebaseAuthException(code: 'network-request-failed'),
      );

      await tester.pumpWidget(buildTestableWidget(auth: fakeAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'erro@exemplo.com');
      await tester.enterText(textFields.at(1), 'password123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.'),
        findsOneWidget,
      );
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });

  group('Fluxo de Sucesso Ponta a Ponta', () {
    testWidgets('Login com sucesso deve navegar para TelaInicialScreen',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth(
        mockUser: MockUser(
          isAnonymous: false,
          uid: 'user_123',
          email: 'sucesso@exemplo.com',
          displayName: 'Marcos',
        ),
      );

      await tester.pumpWidget(buildTestableWidget(auth: mockAuth));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'sucesso@exemplo.com');
      await tester.enterText(textFields.at(1), 'senhaSegura123');

      final btnEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(btnEntrar);
      await tester.tap(btnEntrar);

      // Aguarda o pushReplacement resolver
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Assegura que navegou para a TelaInicialScreen e saiu da LoginScreen
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);
    });
  });
}

