import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/cadastro.dart';

void main() {
  group('CadastroScreen Widget Tests', () {

    Future<void> pumpCadastro(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2000));

      await tester.pumpWidget(
        const MaterialApp(
          home: CadastroScreen(),
        ),
      );

      await tester.pumpAndSettle();
    }

    testWidgets('deve exibir erros ao tentar cadastrar campos vazios',
        (tester) async {
      await pumpCadastro(tester);

      final cadastrarBtn = find.text('Cadastrar');

      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);

      await tester.pumpAndSettle();

      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);
    });

    testWidgets('deve validar e-mail inválido', (tester) async {
      await pumpCadastro(tester);

      await tester.enterText(
        find.byType(TextFormField).at(2), // email field
        'email-invalido',
      );

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('deve validar senha mínima de 6 caracteres', (tester) async {
      await pumpCadastro(tester);

      await tester.enterText(
        find.byType(TextFormField).at(3),
        '123',
      );

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('deve validar confirmação de senha', (tester) async {
      await pumpCadastro(tester);

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(3), '123456'); // senha
      await tester.enterText(fields.at(4), '654321'); // confirmação

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });

    testWidgets('deve validar CEP inválido', (tester) async {
      await pumpCadastro(tester);

      await tester.enterText(
        find.byType(TextFormField).at(5),
        '123',
      );

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('CEP inválido. Formato correto: XXXXX-XXX'),
        findsOneWidget,
      );
    });

    testWidgets('deve validar data inválida', (tester) async {
      await pumpCadastro(tester);

      await tester.enterText(
        find.byType(TextFormField).at(1),
        '999999',
      );

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(find.text('Formato inválido. Use dd/mm/aaaa'), findsOneWidget);
    });

    testWidgets('deve validar número não numérico', (tester) async {
      await pumpCadastro(tester);

      await tester.enterText(
        find.byType(TextFormField).at(8),
        'ABC',
      );

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(find.text('O número deve ser numérico'), findsOneWidget);
    });

    testWidgets('deve aceitar nome válido sem erro', (tester) async {
      await pumpCadastro(tester);

      await tester.enterText(
        find.byType(TextFormField).first,
        'João Silva',
      );

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('O nome não pode conter números'),
        findsNothing,
      );
    });
  });
}
