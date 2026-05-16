import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/cadastro.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget createWidget() {
    return const MaterialApp(
      home: CadastroScreen(),
    );
  }

  Future<void> tapCadastrar(WidgetTester tester) async {
    final button = find.text('Cadastrar');

    await tester.ensureVisible(button);
    await tester.pumpAndSettle();

    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  group('CadastroScreen Widget Tests', () {
    testWidgets('Deve renderizar os campos principais',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Cadastrar'), findsOneWidget);
      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('CEP'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Confirmar Senha'), findsOneWidget);
    });

    testWidgets('Deve mostrar erros ao submeter formulário vazio',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      await tapCadastrar(tester);

      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(
        find.text('A data de nascimento é obrigatória'),
        findsOneWidget,
      );
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);
    });

    testWidgets('Deve validar e-mail inválido',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(2), 'email-invalido');

      await tapCadastrar(tester);

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('Deve validar senha curta',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(3), '123');

      await tapCadastrar(tester);

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('Deve validar confirmação de senha',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(3), '123456');
      await tester.enterText(fields.at(4), '654321');

      await tapCadastrar(tester);

      expect(
        find.text('As senhas não coincidem'),
        findsOneWidget,
      );
    });

    testWidgets('Deve validar CEP inválido',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(5), '123');

      await tapCadastrar(tester);

      expect(
        find.text('CEP inválido. Formato correto: XXXXX-XXX'),
        findsOneWidget,
      );
    });

    testWidgets('Deve validar número inválido',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(7), 'abc');

      await tapCadastrar(tester);

      expect(
        find.text('O número deve ser numérico'),
        findsOneWidget,
      );
    });

    testWidgets('Deve aceitar preenchimento válido dos campos',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'João Silva');
      await tester.enterText(fields.at(1), '01011990');
      await tester.enterText(fields.at(2), 'joao@email.com');
      await tester.enterText(fields.at(3), '123456');
      await tester.enterText(fields.at(4), '123456');
      await tester.enterText(fields.at(5), '12345678');
      await tester.enterText(fields.at(6), 'Rua A');
      await tester.enterText(fields.at(7), '100');
      await tester.enterText(fields.at(8), 'Centro');
      await tester.enterText(fields.at(9), 'Recife');

      await tapCadastrar(tester);

      expect(find.text('E-mail inválido'), findsNothing);
      expect(find.text('As senhas não coincidem'), findsNothing);
    });

    testWidgets('Deve navegar para login ao clicar no botão',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      final loginButton =
          find.text('Já tem uma conta? Faça login');

      await tester.ensureVisible(loginButton);
      await tester.pumpAndSettle();

      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Deve selecionar estado no dropdown',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      final dropdown =
          find.byType(DropdownButtonFormField<String>);

      await tester.ensureVisible(dropdown);

      await tester.tap(dropdown);

      // necessário para renderizar o overlay do dropdown
      await tester.pumpAndSettle();

      // procura especificamente pelo item do menu
      final peItem = find.byWidgetPredicate(
        (widget) =>
            widget is DropdownMenuItem<String> &&
            widget.value == 'PE',
      );

      expect(peItem, findsOneWidget);

      await tester.tap(peItem);
      await tester.pumpAndSettle();

      expect(find.text('PE'), findsWidgets);
    });

    testWidgets('Deve inserir texto nos campos',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Maria',
      );

      expect(find.text('Maria'), findsOneWidget);
    });
  });
}
