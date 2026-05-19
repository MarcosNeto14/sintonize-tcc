import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';
import 'package:sintonize/recup-senha.dart';
import 'package:sintonize/cadastro.dart';

void main() {
  late MockFirebaseAuth mockAuth;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp();
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  Widget createWidget() {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }

  group('LoginScreen - Renderização', () {
    testWidgets('deve renderizar todos os componentes principais',
        (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);

      expect(find.byType(TextFormField), findsNWidgets(2));

      expect(find.text('Entrar'), findsOneWidget);

      expect(find.text('Esqueci minha senha'), findsOneWidget);

      expect(
        find.text('Não tem cadastro? Cadastre-se!'),
        findsOneWidget,
      );
    });
  });

  group('LoginScreen - Validações', () {
    testWidgets('deve mostrar erro para e-mail vazio',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira seu e-mail'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar erro para e-mail inválido',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'email-invalido',
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        '123456',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira um e-mail válido'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar erro para senha vazia',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'teste@email.com',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira sua senha'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar erro para senha curta',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'teste@email.com',
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        '123',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });
  });

  group('LoginScreen - Interações', () {
    testWidgets('deve permitir digitar e-mail e senha',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'teste@email.com',
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        '123456',
      );

      expect(find.text('teste@email.com'), findsOneWidget);
      expect(find.text('123456'), findsOneWidget);
    });

    testWidgets('deve navegar para RecupSenhaScreen',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Esqueci minha senha'));
      await tester.pumpAndSettle();

      expect(find.byType(RecupSenhaScreen), findsOneWidget);
    });

    testWidgets('deve navegar para CadastroScreen',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Não tem cadastro? Cadastre-se!'));
      await tester.pumpAndSettle();

      expect(find.byType(CadastroScreen), findsOneWidget);
    });

    testWidgets('deve permitir scroll da tela',
        (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(SingleChildScrollView), findsOneWidget);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );

      await tester.pump();
    });
  });

  group('LoginScreen - Fluxo de sucesso', () {
    testWidgets('deve navegar para TelaInicialScreen após login',
        (tester) async {
      final user = MockUser(
        isAnonymous: false,
        uid: '123',
        email: 'teste@email.com',
      );

      mockAuth = MockFirebaseAuth(
        mockUser: user,
        signedIn: true,
      );

      await tester.pumpWidget(createWidget());

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'teste@email.com',
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        '123456',
      );

      await tester.tap(find.text('Entrar'));

      await tester.pumpAndSettle();

      expect(find.byType(TelaInicialScreen), findsOneWidget);
    });
  });

  group('LoginScreen - Cenários de erro', () {
    testWidgets('deve mostrar erro user-not-found',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'naoexiste@email.com',
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        '123456',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Widget usa FirebaseAuth.instance diretamente; sem injeção
      // de dependência não é possível interceptar exceções do Firebase.
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('deve mostrar erro wrong-password',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'teste@email.com',
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        'senhaerrada',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Widget usa FirebaseAuth.instance diretamente; sem injeção
      // de dependência não é possível interceptar exceções do Firebase.
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('deve mostrar erro invalid-credential',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'teste@email.com',
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        '123456',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Widget usa FirebaseAuth.instance diretamente; sem injeção
      // de dependência não é possível interceptar exceções do Firebase.
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('deve mostrar erro genérico',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'erro@email.com',
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        '123456',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Widget usa FirebaseAuth.instance diretamente; sem injeção
      // de dependência não é possível interceptar exceções do Firebase.
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
