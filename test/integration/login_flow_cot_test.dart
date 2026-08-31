// test/integration/login_flow_cot_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/recup-senha.dart';

void main() {
  Widget createApp(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('LoginScreen - RenderizaÃ§Ã£o', () {
    testWidgets('deve renderizar elementos principais da tela',
        (tester) async {
      await tester.pumpWidget(
        createApp(LoginScreen()),
      );

      await tester.pump(const Duration(seconds: 1));

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);

      expect(find.text('Entrar'), findsOneWidget);

      expect(find.text('Esqueci minha senha'), findsOneWidget);

      expect(
        find.text('NÃ£o tem cadastro? Cadastre-se!'),
        findsOneWidget,
      );

      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });

  group('LoginScreen - ValidaÃ§Ãµes', () {
    testWidgets('deve validar e-mail vazio',
        (tester) async {
      await tester.pumpWidget(
        createApp(LoginScreen()),
      );

      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Entrar'));

      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.text('Por favor, insira seu e-mail'),
        findsOneWidget,
      );
    });

    testWidgets('deve validar e-mail invÃ¡lido',
        (tester) async {
      await tester.pumpWidget(
        createApp(LoginScreen()),
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

      await tester.tap(find.text('Entrar'));

      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.text('Por favor, insira um e-mail vÃ¡lido'),
        findsOneWidget,
      );
    });

    testWidgets('deve validar senha vazia',
        (tester) async {
      await tester.pumpWidget(
        createApp(LoginScreen()),
      );

      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'teste@email.com',
      );

      await tester.tap(find.text('Entrar'));

      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.text('Por favor, insira sua senha'),
        findsOneWidget,
      );
    });

    testWidgets('deve validar senha curta',
        (tester) async {
      await tester.pumpWidget(
        createApp(LoginScreen()),
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

      await tester.tap(find.text('Entrar'));

      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.text(
          'A senha deve ter pelo menos 6 caracteres',
        ),
        findsOneWidget,
      );
    });
  });

  group('LoginScreen - NavegaÃ§Ã£o', () {
    testWidgets(
        'deve navegar para RecupSenhaScreen ao tocar em "Esqueci minha senha"',
        (tester) async {
      await tester.pumpWidget(
        createApp(LoginScreen()),
      );

      await tester.pump(const Duration(seconds: 1));

      await tester.tap(
        find.text('Esqueci minha senha'),
      );

      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.byType(RecupSenhaScreen),
        findsOneWidget,
      );
    });

    testWidgets(
        'deve navegar para tela de cadastro ao tocar em cadastro',
        (tester) async {
      await tester.pumpWidget(
        createApp(
          Builder(
            builder: (context) {
              return LoginScreen();
            },
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));

      await tester.tap(
        find.text('NÃ£o tem cadastro? Cadastre-se!'),
      );

      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('RecupSenhaScreen', () {
    testWidgets('deve renderizar elementos da tela',
        (tester) async {
      await tester.pumpWidget(
        createApp(const RecupSenhaScreen()),
      );

      await tester.pump(const Duration(seconds: 1));

      expect(
        find.text('Digite seu e-mail'),
        findsOneWidget,
      );

      expect(
        find.text('Recuperar Senha'),
        findsOneWidget,
      );

      expect(
        find.text('Voltar para Login'),
        findsOneWidget,
      );
    });

    testWidgets('deve validar email vazio',
        (tester) async {
      await tester.pumpWidget(
        createApp(const RecupSenhaScreen()),
      );

      await tester.pump(const Duration(seconds: 1));

      await tester.tap(
        find.text('Recuperar Senha'),
      );

      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.text('Por favor, insira seu e-mail'),
        findsOneWidget,
      );
    });

    testWidgets(
        'deve mostrar snackbar ao enviar recuperaÃ§Ã£o com email vÃ¡lido',
        (tester) async {
      await tester.pumpWidget(
        createApp(const RecupSenhaScreen()),
      );

      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(
        find.byType(TextFormField),
        'teste@email.com',
      );

      await tester.tap(
        find.text('Recuperar Senha'),
      );

      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.text('Link de recuperaÃ§Ã£o enviado!'),
        findsOneWidget,
      );
    });

    testWidgets(
        'deve voltar para LoginScreen ao tocar em voltar',
        (tester) async {
      await tester.pumpWidget(
        createApp(const RecupSenhaScreen()),
      );

      await tester.pump(const Duration(seconds: 1));

      await tester.tap(
        find.text('Voltar para Login'),
      );

      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.byType(LoginScreen),
        findsOneWidget,
      );
    });
  });
}
