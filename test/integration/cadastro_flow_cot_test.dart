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
        createWidget(const CadastroScreen()),
      );

      expect(find.text('Cadastrar'), findsOneWidget);
      expect(find.text('Já tem uma conta? Faça login'), findsOneWidget);
      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
    });

    testWidgets('navega para LoginScreen ao tocar no link',
        (tester) async {
      await tester.pumpWidget(
        createWidget(const CadastroScreen()),
      );

      final loginLink =
          find.text('Já tem uma conta? Faça login');

      await tester.ensureVisible(loginLink);
      await tester.tap(loginLink);

      // inicia animação/navegação
      await tester.pump(
        const Duration(milliseconds: 500),
      );

      // finaliza frame pendente do Navigator
      await tester.pump();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('exibe erro para nome inválido',
        (tester) async {
      await tester.pumpWidget(
        createWidget(const CadastroScreen()),
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
          'O nome não pode conter números ou caracteres especiais',
        ),
        findsOneWidget,
      );
    });

    testWidgets('exibe erro para data inválida',
        (tester) async {
      await tester.pumpWidget(
        createWidget(const CadastroScreen()),
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
        find.textContaining('Mês deve ser entre'),
        findsOneWidget,
      );
    });

    testWidgets('exibe erro para email inválido',
        (tester) async {
      await tester.pumpWidget(
        createWidget(const CadastroScreen()),
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
        find.text('E-mail inválido'),
        findsOneWidget,
      );
    });

    testWidgets('exibe erro para senha curta',
        (tester) async {
      await tester.pumpWidget(
        createWidget(const CadastroScreen()),
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
        createWidget(const CadastroScreen()),
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
        find.text('As senhas não coincidem'),
        findsOneWidget,
      );
    });

    testWidgets('exibe erro para CEP inválido',
        (tester) async {
      await tester.pumpWidget(
        createWidget(const CadastroScreen()),
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
          'CEP inválido. Formato correto: XXXXX-XXX',
        ),
        findsOneWidget,
      );
    });

    testWidgets('exibe erro para número não numérico',
        (tester) async {
      await tester.pumpWidget(
        createWidget(const CadastroScreen()),
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
        find.text('O número deve ser numérico'),
        findsOneWidget,
      );
    });

    testWidgets('botão cadastrar exige ensureVisible',
        (tester) async {
      await tester.pumpWidget(
        createWidget(const CadastroScreen()),
      );

      final cadastrarButton =
          find.text('Cadastrar');

      await tester.ensureVisible(cadastrarButton);

      expect(cadastrarButton, findsOneWidget);
    });

    testWidgets('link login exige ensureVisible',
        (tester) async {
      await tester.pumpWidget(
        createWidget(const CadastroScreen()),
      );

      final loginLink =
          find.text('Já tem uma conta? Faça login');

      await tester.ensureVisible(loginLink);

      expect(loginLink, findsOneWidget);
    });
  });

  group('GenerosCadastroScreen', () {
    testWidgets('renderiza lista de gêneros',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          const GenerosCadastroScreen(),
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
          const GenerosCadastroScreen(),
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

    testWidgets('seleciona gênero musical',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          const GenerosCadastroScreen(),
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
        'exibe snackbar ao confirmar sem selecionar gênero',
        (tester) async {
      await tester.pumpWidget(
        createWidget(
          const GenerosCadastroScreen(),
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
          'Selecione pelo menos um gênero musical!',
        ),
        findsOneWidget,
      );
    });
  });
}
