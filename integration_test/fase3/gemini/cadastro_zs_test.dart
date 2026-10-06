// ===== integration_test/fase3/cadastro_fluxo_test.dart =====
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintonize/main.dart';
import '../firebase_test_helper.dart';

/// Helper para aguardar condições assíncronas de I/O (Firebase)
Future<void> waitForCondition(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 15),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  expect(finder, findsOneWidget);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  setUp(() async {
    await FirebaseAuth.instance.signOut();
  });

  tearDown(() async {
    await FirebaseAuth.instance.signOut();
  });

  group('E2E - Fluxo de Cadastro e Seleção de Gêneros Musicais', () {
    testWidgets('Validações de campos obrigatórios e formato inválido na tela de cadastro',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final cadastroButtonHome = find.widgetWithText(ElevatedButton, 'Cadastro');
      expect(cadastroButtonHome, findsOneWidget);
      await tester.tap(cadastroButtonHome);
      await tester.pumpAndSettle();

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);

      final nomeField = find.descendant(
        of: find.byType(Form),
        matching: find.byType(TextFormField),
      ).first;
      await tester.enterText(nomeField, 'Maria123');

      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(
        find.text('O nome não pode conter números ou caracteres especiais'),
        findsOneWidget,
      );
    });

    testWidgets('Erro ao tentar cadastrar e-mail já existente no Firebase Auth',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);

      await tester.enterText(textFields.at(0), 'Usuario Duplicado');
      await tester.enterText(textFields.at(1), '15/10/1995');
      await tester.enterText(textFields.at(2), 'tester@sintonize.test');
      await tester.enterText(textFields.at(3), 'senha123');
      await tester.enterText(textFields.at(4), 'senha123');
      await tester.enterText(textFields.at(5), '50000-000');
      await tester.enterText(textFields.at(6), 'Rua Principal');
      await tester.enterText(textFields.at(7), '100');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pump();

      // Aguarda ativamente a resposta assíncrona do emulador Auth
      final errorSnackBar = find.textContaining('Erro ao cadastrar:');
      await waitForCondition(tester, errorSnackBar);
      expect(errorSnackBar, findsOneWidget);
    });

    testWidgets('Validação de seleção obrigatória de gêneros na GenerosCadastroScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      final uniqueEmail = 'semgenero_${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      await tester.enterText(textFields.at(0), 'Usuario Sem Genero');
      await tester.enterText(textFields.at(1), '10/10/1998');
      await tester.enterText(textFields.at(2), uniqueEmail);
      await tester.enterText(textFields.at(3), 'senha123');
      await tester.enterText(textFields.at(4), 'senha123');
      await tester.enterText(textFields.at(5), '50000-000');
      await tester.enterText(textFields.at(6), 'Rua dos Testes');
      await tester.enterText(textFields.at(7), '42');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pump();

      // Aguarda a criação no Auth/Firestore e a transição para GenerosCadastroScreen
      final tituloGeneros = find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA');
      await waitForCondition(tester, tituloGeneros);
      expect(tituloGeneros, findsOneWidget);

      final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarButton);
      await tester.tap(confirmarButton);
      await tester.pump();

      final snackBarValidacao = find.text('Selecione pelo menos um gênero musical!');
      await waitForCondition(tester, snackBarValidacao);
      expect(snackBarValidacao, findsOneWidget);
    });

    testWidgets('Fluxo completo com sucesso: Cadastro -> GenerosCadastro -> TelaInicial e persistência no Firestore',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueEmail = 'novo_usuario_$timestamp@sintonize.test';
      const nomeUsuario = 'Novo Membro Sintonize';

      await tester.enterText(textFields.at(0), nomeUsuario);
      await tester.enterText(textFields.at(1), '20/05/2000');
      await tester.enterText(textFields.at(2), uniqueEmail);
      await tester.enterText(textFields.at(3), 'segredo123');
      await tester.enterText(textFields.at(4), 'segredo123');
      await tester.enterText(textFields.at(5), '50000-000');
      await tester.enterText(textFields.at(6), 'Rua das Flores');
      await tester.enterText(textFields.at(7), '777');
      await tester.enterText(textFields.at(8), 'Boa Viagem');
      await tester.enterText(textFields.at(9), 'Recife');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pump();

      // Aguarda a transição de navegação após Auth e Firestore
      final tituloGeneros = find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA');
      await waitForCondition(tester, tituloGeneros);

      final currentUser = FirebaseAuth.instance.currentUser;
      expect(currentUser, isNotNull);
      expect(currentUser!.email, uniqueEmail);

      final userDocRef = FirebaseFirestore.instance.collection('usuarios').doc(currentUser.uid);
      final docAntesGeneros = await userDocRef.get();
      expect(docAntesGeneros.exists, isTrue);
      expect(docAntesGeneros.data()?['nome'], nomeUsuario);
      expect(docAntesGeneros.data()?['endereco']['cidade'], 'Recife');

      // Seleciona os gêneros Rock e Pop
      final switchRock = find.descendant(
        of: find.ancestor(of: find.text('Rock'), matching: find.byType(Row)),
        matching: find.byType(Switch),
      );
      await tester.tap(switchRock);
      await tester.pumpAndSettle();

      final switchPop = find.descendant(
        of: find.ancestor(of: find.text('Pop'), matching: find.byType(Row)),
        matching: find.byType(Switch),
      );
      await tester.tap(switchPop);
      await tester.pumpAndSettle();

      // Confirma e aguarda a navegação para TelaInicialScreen
      final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarButton);
      await tester.tap(confirmarButton);
      await tester.pump();

      final navBar = find.byType(BottomNavigationBar);
      await waitForCondition(tester, navBar);

      expect(find.text('Pesquisa Direta'), findsOneWidget);
      expect(find.text('Minha Conta'), findsOneWidget);

      // Validação final de persistência no Firestore
      final docAposGeneros = await userDocRef.get();
      final List<dynamic> generosSalvos = docAposGeneros.data()?['generos_favoritos'] ?? [];
      expect(generosSalvos, containsAll(['Rock', 'Pop']));
      expect(generosSalvos.length, 2);
    });
  });
}
