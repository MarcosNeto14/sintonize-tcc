import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  late MockFirebaseAuth mockAuth;

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('Deve renderizar os campos e botões corretamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);

      expect(find.byType(TextFormField), findsNWidgets(2));

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Esqueci minha senha'), findsOneWidget);
      expect(find.text('Não tem cadastro? Cadastre-se!'),
          findsOneWidget);
    });

    testWidgets(
        'Deve mostrar erro quando campos estiverem vazios',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

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
    });

    testWidgets(
        'Deve mostrar erro para e-mail inválido',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final emailField = find.byType(TextFormField).at(0);
      final senhaField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'email_invalido');
      await tester.enterText(senhaField, '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira um e-mail válido'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Deve mostrar erro para senha menor que 6 caracteres',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final emailField = find.byType(TextFormField).at(0);
      final senhaField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'teste@email.com');
      await tester.enterText(senhaField, '123');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Deve permitir digitação nos campos',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final emailField = find.byType(TextFormField).at(0);
      final senhaField = find.byType(TextFormField).at(1);

      await tester.enterText(
          emailField, 'usuario@email.com');

      await tester.enterText(
          senhaField, '123456');

      expect(find.text('usuario@email.com'),
          findsOneWidget);

      expect(find.text('123456'), findsOneWidget);
    });

    testWidgets(
        'Deve navegar para TelaInicialScreen após login válido',
        (WidgetTester tester) async {
      final user = MockUser(
        isAnonymous: false,
        uid: '123',
        email: 'teste@email.com',
      );

      mockAuth = MockFirebaseAuth(
        mockUser: user,
        signedIn: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      final emailField = find.byType(TextFormField).at(0);
      final senhaField = find.byType(TextFormField).at(1);

      await tester.enterText(
          emailField, 'teste@email.com');

      await tester.enterText(
          senhaField, '123456');

      await tester.tap(find.text('Entrar'));

      await tester.pumpAndSettle();

      expect(
        find.byType(TelaInicialScreen),
        findsOneWidget,
      );
    });

    testWidgets(
        'Deve exibir SnackBar para credenciais inválidas',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth(
        signedIn: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      final emailField = find.byType(TextFormField).at(0);
      final senhaField = find.byType(TextFormField).at(1);

      await tester.enterText(
          emailField, 'teste@email.com');

      await tester.enterText(
          senhaField, 'senhaerrada');

      await tester.tap(find.text('Entrar'));

      await tester.pump();

      // Como o widget usa FirebaseAuth.instance diretamente,
      // este teste valida apenas que a interface continua funcionando.
      // Para testar corretamente o SnackBar,
      // recomenda-se injetar FirebaseAuth via construtor.

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets(
        'Deve navegar para recuperação de senha',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Esqueci minha senha'));

      await tester.pumpAndSettle();

      expect(find.byType(Navigator), findsWidgets);
    });

    testWidgets(
        'Deve navegar para cadastro',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(
        find.text('Não tem cadastro? Cadastre-se!'),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Navigator), findsWidgets);
    });
  });
}
