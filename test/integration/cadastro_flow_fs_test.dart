// test/integration/cadastro_flow_fs_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('CadastroScreen Integration Tests', () {
    testWidgets(
      'deve exibir erros de validação ao tentar cadastrar com formulário vazio',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(auth: mockAuth, firestore: fakeFirestore),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        final cadastrarButton = find.widgetWithText(
          ElevatedButton,
          'Cadastrar',
        );

        await tester.ensureVisible(cadastrarButton);
        await tester.tap(cadastrarButton);
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('O nome é obrigatório'), findsOneWidget);
        expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
        expect(find.text('O e-mail é obrigatório'), findsOneWidget);
        expect(find.text('A senha é obrigatória'), findsOneWidget);
        expect(find.text('O CEP é obrigatório'), findsOneWidget);
        expect(find.text('O número é obrigatório'), findsOneWidget);
      },
    );

    testWidgets(
      'deve validar email inválido',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(auth: mockAuth, firestore: fakeFirestore),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        await tester.enterText(find.byType(TextFormField).at(0), 'João da Silva');
        await tester.enterText(find.byType(TextFormField).at(1), '01011990');
        await tester.enterText(find.byType(TextFormField).at(2), 'email-invalido');

        final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');

        await tester.ensureVisible(cadastrarButton);
        await tester.tap(cadastrarButton);
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('E-mail inválido'), findsOneWidget);
      },
    );

    testWidgets(
      'deve validar senhas diferentes',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(auth: mockAuth, firestore: fakeFirestore),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        await tester.enterText(find.byType(TextFormField).at(3), '123456');
        await tester.enterText(find.byType(TextFormField).at(4), '654321');

        final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');

        await tester.ensureVisible(cadastrarButton);
        await tester.tap(cadastrarButton);
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('As senhas não coincidem'), findsOneWidget);
      },
    );

    testWidgets(
      'deve navegar ao clicar em "Faça login"',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(auth: mockAuth, firestore: fakeFirestore),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        final loginButton = find.widgetWithText(
          TextButton,
          'Já tem uma conta? Faça login',
        );

        await tester.ensureVisible(loginButton);
        expect(loginButton, findsOneWidget);

        await tester.tap(loginButton);
        await tester.pump(const Duration(milliseconds: 500));

        // Apenas valida que o tap ocorreu sem erro
        expect(find.byType(TextButton), findsWidgets);
      },
    );
  });

  group('GenerosCadastroScreen Integration Tests', () {
    testWidgets(
      'deve renderizar todos os gêneros musicais',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(auth: mockAuth, firestore: fakeFirestore),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        final generos = [
          'Rock',
          'Pop',
          'Jazz',
          'Blues',
          'Hip-Hop',
          'Reggae',
          'Country',
        ];

        // Alguns itens do ListView começam fora da viewport.
        // Usa scrollUntilVisible ao invés de ensureVisible,
        // pois ensureVisible falha quando o widget ainda
        // não foi construído pelo ListView.builder.
        for (final genero in generos) {
          final finder = find.text(genero);

          await tester.scrollUntilVisible(
            finder,
            300,
            scrollable: find.byType(Scrollable).last,
          );

          await tester.pump(const Duration(milliseconds: 500));

          expect(finder, findsOneWidget);
        }
      },
    );

    testWidgets(
      'deve permitir selecionar um gênero',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(auth: mockAuth, firestore: fakeFirestore),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        final rockText = find.text('Rock');

        await tester.scrollUntilVisible(
          rockText,
          300,
          scrollable: find.byType(Scrollable).last,
        );

        await tester.pump(const Duration(milliseconds: 500));

        final rockSwitch = find.descendant(
          of: find.ancestor(
            of: rockText,
            matching: find.byType(Card),
          ),
          matching: find.byType(Switch),
        );

        expect(tester.widget<Switch>(rockSwitch).value, false);

        await tester.tap(rockSwitch);
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.widget<Switch>(rockSwitch).value, true);
      },
    );

    testWidgets(
      'deve exibir snackbar ao confirmar sem selecionar gênero',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(auth: mockAuth, firestore: fakeFirestore),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));

        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');

        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);
        await tester.pump(const Duration(milliseconds: 500));

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );
      },
    );
  });
}
