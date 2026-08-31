// test/integration/login_flow_fs_test.dart

import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/recup-senha.dart';

void main() {
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  group('LoginScreen', () {
    testWidgets('deve renderizar campos, botões e links', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(auth: mockAuth),
        ),
      );

      // Não usar pumpAndSettle por causa do padrão do app/Firebase
      await tester.pump(const Duration(seconds: 1));

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

    testWidgets('deve mostrar validação ao tentar login sem email',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(auth: mockAuth),
        ),
      );

      await tester.pump(const Duration(seconds: 1));

      // Preenche apenas senha válida
      await tester.enterText(
        find.byType(TextFormField).at(1),
        '123456',
      );

      await tester.pump();

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira seu e-mail'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar validação para email inválido',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(auth: mockAuth),
        ),
      );

      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'email-invalido',
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        '123456',
      );

      await tester.pump();

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira um e-mail válido'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar validação para senha curta',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(auth: mockAuth),
        ),
      );

      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'teste@email.com',
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        '123',
      );

      await tester.pump();

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('deve permitir digitar email e senha', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(auth: mockAuth),
        ),
      );

      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'usuario@email.com',
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        '123456',
      );

      await tester.pump();

      expect(find.text('usuario@email.com'), findsOneWidget);
      expect(find.text('123456'), findsOneWidget);
    });

    testWidgets(
        'link "Não tem cadastro? Cadastre-se!" deve navegar para CadastroScreen',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(auth: mockAuth),
                    ),
                  ),
                  child: const Text('Abrir'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));

      // padrão obrigatório do app
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(LoginScreen), findsOneWidget);

      // FIX: garante que o botão esteja visível no viewport
      await tester.ensureVisible(
        find.text('Não tem cadastro? Cadastre-se!'),
      );
      await tester.pump();

      await tester.tap(
        find.text('Não tem cadastro? Cadastre-se!'),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CadastroScreen), findsOneWidget);
    });

    testWidgets(
        'link "Esqueci minha senha" deve navegar para RecupSenhaScreen',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(auth: mockAuth),
                    ),
                  ),
                  child: const Text('Abrir'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Abrir'));

      // padrão obrigatório do app
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.tap(find.text('Esqueci minha senha'));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(RecupSenhaScreen), findsOneWidget);
    });

    testWidgets(
        'não deve tentar autenticar quando formulário for inválido',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(auth: mockAuth),
        ),
      );

      await tester.pump(const Duration(seconds: 1));

      // Campos inválidos impedem chamada Firebase
      await tester.enterText(
        find.byType(TextFormField).at(0),
        '',
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        '123',
      );

      await tester.pump();

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira seu e-mail'),
        findsOneWidget,
      );

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });
  });
}
