import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/login.dart';
import 'package:sintonize/recup-senha.dart';

// Fake determinístico para controlar o comportamento de autenticação
class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  final FirebaseAuthException? exceptionToThrow;

  FakeFirebaseAuth({this.exceptionToThrow});

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    throw UnimplementedError();
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = null;
  });

  Widget createLoginScreen({FirebaseAuth? auth}) {
    return MaterialApp(
      home: LoginScreen(auth: auth),
    );
  }

  group('LoginScreen - Renderização e Estrutura', () {
    testWidgets('Deve renderizar os campos de texto, botões e labels corretamente',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuth();

      await tester.pumpWidget(createLoginScreen(auth: fakeAuth));
      await tester.pump();

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Esqueci minha senha'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Não tem cadastro? Cadastre-se!'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });

  group('LoginScreen - Validações de Formulário', () {
    testWidgets('Deve exibir erros quando tentar submeter com campos vazios',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuth();

      await tester.pumpWidget(createLoginScreen(auth: fakeAuth));
      await tester.pump();

      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(entrarButton);
      await tester.tap(entrarButton);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
    });

    testWidgets('Deve exibir erro quando o formato do e-mail for inválido',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuth();

      await tester.pumpWidget(createLoginScreen(auth: fakeAuth));
      await tester.pump();

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');

      await tester.enterText(emailField, 'email-invalido');
      await tester.enterText(passwordField, '123456');

      await tester.ensureVisible(entrarButton);
      await tester.tap(entrarButton);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsNothing);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsNothing);
    });

    testWidgets('Deve exibir erro quando a senha tiver menos de 6 caracteres',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuth();

      await tester.pumpWidget(createLoginScreen(auth: fakeAuth));
      await tester.pump();

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');

      await tester.enterText(emailField, 'usuario@teste.com');
      await tester.enterText(passwordField, '12345');

      await tester.ensureVisible(entrarButton);
      await tester.tap(entrarButton);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsNothing);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
    });
  });

  group('LoginScreen - Autenticação e Feedback', () {
    testWidgets('Deve exibir SnackBar com mensagem de erro quando o usuário não for encontrado',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuth(
        exceptionToThrow: FirebaseAuthException(code: 'user-not-found'),
      );

      await tester.pumpWidget(createLoginScreen(auth: fakeAuth));
      await tester.pump();

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');

      await tester.enterText(emailField, 'inexistente@teste.com');
      await tester.enterText(passwordField, 'senhaValida123');

      await tester.ensureVisible(entrarButton);
      await tester.tap(entrarButton);

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.'),
        findsOneWidget,
      );
    });

    testWidgets('Deve exibir SnackBar com mensagem de erro quando a senha estiver incorreta',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuth(
        exceptionToThrow: FirebaseAuthException(code: 'wrong-password'),
      );

      await tester.pumpWidget(createLoginScreen(auth: fakeAuth));
      await tester.pump();

      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);
      final entrarButton = find.widgetWithText(ElevatedButton, 'Entrar');

      await tester.enterText(emailField, 'usuario@teste.com');
      await tester.enterText(passwordField, 'senhaIncorreta123');

      await tester.ensureVisible(entrarButton);
      await tester.tap(entrarButton);

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
        findsOneWidget,
      );
    });
  });

  group('LoginScreen - Navegação Secundária', () {
    testWidgets('Deve navegar para RecupSenhaScreen ao clicar em Esqueci minha senha',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuth();

      await tester.pumpWidget(createLoginScreen(auth: fakeAuth));
      await tester.pump();

      final esqueciSenhaButton = find.widgetWithText(TextButton, 'Esqueci minha senha');
      await tester.ensureVisible(esqueciSenhaButton);
      await tester.tap(esqueciSenhaButton);
      await tester.pumpAndSettle();

      expect(find.byType(RecupSenhaScreen), findsOneWidget);
    });

    testWidgets('Deve navegar para CadastroScreen ao clicar em Cadastre-se',
        (WidgetTester tester) async {
      final fakeAuth = FakeFirebaseAuth();

      await tester.pumpWidget(createLoginScreen(auth: fakeAuth));
      await tester.pump();

      final cadastreSeButton = find.widgetWithText(TextButton, 'Não tem cadastro? Cadastre-se!');
      await tester.ensureVisible(cadastreSeButton);
      await tester.tap(cadastreSeButton);
      await tester.pumpAndSettle();

      expect(find.byType(CadastroScreen), findsOneWidget);
    });
  });
}

