import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget createWidget() {
    return MaterialApp(
      home: const CadastroScreen(),
    );
  }

  group('Renderização', () {
    testWidgets('deve renderizar os principais componentes',
        (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Cadastrar'), findsOneWidget);
      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('CEP'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(10));
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });
  });

  group('Validações', () {
    testWidgets('deve validar nome vazio', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.ensureVisible(find.text('Cadastrar'));
      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(find.text('O nome é obrigatório'), findsOneWidget);
    });

    testWidgets('deve validar email inválido', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
          find.widgetWithText(TextFormField, '').at(2),
          'email_invalido');

      await tester.ensureVisible(find.text('Cadastrar'));
      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('deve validar senha curta', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
          find.byType(TextFormField).at(3),
          '123');

      await tester.ensureVisible(find.text('Cadastrar'));
      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget);
    });

    testWidgets('deve validar confirmação de senha',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
          find.byType(TextFormField).at(3),
          '123456');

      await tester.enterText(
          find.byType(TextFormField).at(4),
          '654321');

      await tester.ensureVisible(find.text('Cadastrar'));
      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(find.text('As senhas não coincidem'),
          findsOneWidget);
    });

    testWidgets('deve validar CEP inválido',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
          find.byType(TextFormField).at(5),
          '123');

      await tester.ensureVisible(find.text('Cadastrar'));
      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(
        find.text('CEP inválido. Formato correto: XXXXX-XXX'),
        findsOneWidget,
      );
    });

    testWidgets('deve validar número não numérico',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
          find.byType(TextFormField).at(7),
          'abc');

      await tester.ensureVisible(find.text('Cadastrar'));
      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(
        find.text('O número deve ser numérico'),
        findsOneWidget,
      );
    });
  });

  group('Interações', () {
    testWidgets('deve permitir digitação nos campos',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
          find.byType(TextFormField).at(0),
          'João');

      expect(find.text('João'), findsOneWidget);
    });

    testWidgets('deve renderizar dropdown de estados',
        (tester) async {
      await tester.pumpWidget(createWidget());

      expect(
        find.byType(DropdownButtonFormField<String>),
        findsOneWidget,
      );
    });

    testWidgets('deve realizar scroll',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -300));

      await tester.pump();

      expect(find.byType(SingleChildScrollView),
          findsOneWidget);
    });
  });

  group('Fluxo de sucesso', () {
    testWidgets(
        'deve cadastrar usuário e navegar para próxima tela',
        (tester) async {
      final navigatorObserver = MockNavigatorObserver();

      await tester.pumpWidget(
        MaterialApp(
          home: const CadastroScreen(),
          navigatorObservers: [navigatorObserver],
        ),
      );

      await tester.enterText(
          find.byType(TextFormField).at(0),
          'João Silva');

      await tester.enterText(
          find.byType(TextFormField).at(1),
          '01011990');

      await tester.enterText(
          find.byType(TextFormField).at(2),
          'joao@email.com');

      await tester.enterText(
          find.byType(TextFormField).at(3),
          '123456');

      await tester.enterText(
          find.byType(TextFormField).at(4),
          '123456');

      await tester.enterText(
          find.byType(TextFormField).at(5),
          '12345-678');

      await tester.enterText(
          find.byType(TextFormField).at(6),
          'Rua Teste');

      await tester.enterText(
          find.byType(TextFormField).at(7),
          '100');

      await tester.enterText(
          find.byType(TextFormField).at(8),
          'Centro');

      await tester.enterText(
          find.byType(TextFormField).at(9),
          'Recife');

      // O estado não possui validator obrigatório,
      // então não precisamos selecionar um item
      // para validar o fluxo principal do cadastro.

      await tester.ensureVisible(find.text('Cadastrar'));
      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.byType(GenerosCadastroScreen),
        findsOneWidget,
      );
    });
  });

  group('Tratamento de erros', () {
    testWidgets(
        'deve exibir snackbar quando senhas são diferentes',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(
          find.byType(TextFormField).at(3),
          '123456');

      await tester.enterText(
          find.byType(TextFormField).at(4),
          '654321');

      await tester.ensureVisible(find.text('Cadastrar'));
      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(find.text('As senhas não coincidem'),
          findsOneWidget);
    });

    testWidgets(
        'deve exibir mensagens de validação múltiplas',
        (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.ensureVisible(find.text('Cadastrar'));
      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(find.text('O nome é obrigatório'),
          findsOneWidget);

      expect(find.text('O e-mail é obrigatório'),
          findsOneWidget);

      expect(find.text('A senha é obrigatória'),
          findsOneWidget);

      expect(find.text('O CEP é obrigatório'),
          findsOneWidget);
    });
  });
}
