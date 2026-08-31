// test/integration/cadastro_flow_cot_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/login.dart';

void main() {
  Widget createWidget(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('CadastroScreen', () {
    testWidgets('renderiza elementos principais da tela',
        (tester) async {
      await tester.pumpWidget(
        createWidget(CadastroScreen()),
      );

      expect(find.text('Cadastrar'), findsOneWidget);
      expect(find.text('JÃ¡ tem uma conta? FaÃ§a login'), findsOneWidget);
      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
    });

    testWidgets('navega para LoginScreen ao tocar no link',
        (tester) async {
      await tester.pumpWidget(
        createWidget(CadastroScreen()),
      );

      final loginLink =
          find.text('JÃ¡ tem uma conta? FaÃ§a login');

      await tester.ensureVisible(loginLink);
      await tester.tap(loginLink);

      // inicia animaÃ§Ã£o/navegaÃ§Ã£o
      await tester.pump(
        const Duration(milliseconds: 500),
      );

      // finaliza frame pendente do Navigator
      await tester.pump();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('exibe erro para nome invÃ¡lido',
        (tester) async {
      await tester.pumpWidget(
        createWidget(CadastroScreen()),
      );

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Joao123',
      );

      final cadastrarButton =
          find.text('Cadastrar');

      await tester.ensureVisible(cadastrarButton);

      await tester.tap(cadastrarButton);

      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.text(
          'O nome nÃ£o pode conter nÃºmeros ou caracteres especiais',
        ),
        findsOneWidget,
      );
    });

    testWidgets('exibe erro para data invÃ¡lida',
        (tester) async {
      await tester.pumpWidget(
        createWidget(CadastroScreen()),
      );

      await tester.enterText(
        find.byType(TextFormField).at(1),
        '32132025',
      );

      final cadastrarButton =
          find.text('Cadastrar');

      await tester.ensureVisible(cadastrarButton);

      await tester.tap(cadastrarButton);

      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.textContaining('MÃªs deve ser entre'),
        findsOneWidget,
      );
    });

    testWidgets('exibe erro para email invÃ¡lido',
        (tester) async {
      await tester.pumpWidget(
        createWidget(CadastroScreen()),
      );

      await tester.enterText(
        find.byType(TextFormField).at(2),
        'email-invalido',
      );

      final cadastrarButton =
          find.text('Cadastrar');

      await tester.ensureVisible(cadastrarButton);

      await tester.tap(cadastrarButton);

      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.text('E-mail invÃ¡lido'),
        findsOneWidget,
      );
    });

    testWidgets('exibe erro para senha curta',
        (tester) async {
      await tester.pumpWidget(
        createWidget(CadastroScreen()),
      );

      await tester.enterText(
        find.byType(TextFormField).at(3),
        '123',
      );

      final cadastrarButton =
          find.text('Cadastrar');

      await tester.ensureVisible(cadastrarButton);

      await tester.tap(cadastrarButton);

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

    testWidgets('exibe erro para senhas diferentes',
        (tester) async {
      await tester.pumpWidget(
        createWidget(CadastroScreen()),
      );

      await tester.enterText(
        find.byType(TextFormField).at(3),
        '123456',
      );

      await tester.enterText(
        find.byType(TextFormField).at(4),
        '654321',
      );

      final cadastrarButton =
          find.text('Cadastrar');

      await tester.ensureVisible(cadastrarButton);

      await tester.tap(cadastrarButton);

      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.text('As senhas nÃ£o coincidem'),
        findsOneWidget,
      );
    });

    testWidgets('exibe erro para CEP invÃ¡lido',
        (tester) async {
      await tester.pumpWidget(
        createWidget(CadastroScreen()),
      );

      await tester.enterText(
        find.byType(TextFormField).at(5),
        '123',
      );

      final cadastrarButton =
          find.text('Cadastrar');

      await tester.ensureVisible(cadastrarButton);

      await tester.tap(cadastrarButton);

      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.text(
          'CEP invÃ¡lido. Formato correto: XXXXX-XXX',
        ),
        findsOneWidget,
      );
    });

    testWidgets('exibe erro para nÃºmero nÃ£o numÃ©rico',
        (tester) async {
      await tester.pumpWidget(
        createWidget(CadastroScreen()),
      );

      await tester.enterText(
        find.byType(TextFormField).at(7),
        'ABC',
      );

      final cadastrarButton =
          find.text('Cadastrar');

      await tester.ensureVisible(cadastrarButton);

      await tester.tap(cadastrarButton);

      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.text('O nÃºmero deve ser numÃ©rico'),
        findsOneWidget,
      );
    });

    testWidgets('botÃ£o cadastrar exige ensureVisible',
        (tester) async {
      await tester.pumpWidget(
        createWidget(CadastroScreen()),
      );

      final cadastrarButton =
          find.text('Cadastrar');

      await tester.ensureVisible(cadastrarButton);

      expect(cadastrarButton, findsOneWidget);
    });

    testWidgets('link login exige ensureVisible',
        (tester) async {
      await tester.pumpWidget(
        createWidget(CadastroScreen()),
      );

      final loginLink =
          find.text('JÃ¡ tem uma conta? FaÃ§a login');

      await tester.ensureVisible(loginLink);

      expect(loginLink, findsOneWidget);
    });
  });

  group('GenerosCadastroScreen', () {
    testWidgets('renderiza lista de gÃªneros',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          GenerosCadastroScreen(),
        ),
      );

      expect(find.text('Rock'), findsOneWidget);
      expect(find.text('Pop'), findsOneWidget);
      expect(find.text('Jazz'), findsOneWidget);
    });

    testWidgets(
        'scrollUntilVisible encontra item lazy do ListView',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          GenerosCadastroScreen(),
        ),
      );

      await tester.scrollUntilVisible(
        find.text('Country'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(find.text('Country'), findsOneWidget);
    });

    testWidgets('seleciona gÃªnero musical',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          GenerosCadastroScreen(),
        ),
      );

      final rockSwitch =
          find.byType(Switch).first;

      await tester.tap(rockSwitch);

      await tester.pump(
        const Duration(milliseconds: 500),
      );

      final switchWidget =
          tester.widget<Switch>(rockSwitch);

      expect(switchWidget.value, true);
    });

    testWidgets(
        'exibe snackbar ao confirmar sem selecionar gÃªnero',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          GenerosCadastroScreen(),
        ),
      );

      final confirmarButton =
          find.text('Confirmar');

      await tester.ensureVisible(confirmarButton);

      await tester.tap(confirmarButton);

      await tester.pump(
        const Duration(milliseconds: 500),
      );

      expect(
        find.text(
          'Selecione pelo menos um gÃªnero musical!',
        ),
        findsOneWidget,
      );
    });
  });
}
