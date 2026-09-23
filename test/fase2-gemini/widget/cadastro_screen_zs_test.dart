import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// Imports da aplicação
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/login.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: CadastroScreen(
        auth: mockAuth,
        firestore: fakeFirestore,
      ),
    );
  }

  /// Retorna o TextFormField associado a um determinado label de texto
  Finder findFieldByLabel(String label) {
    return find.byWidgetPredicate((widget) {
      if (widget is! TextFormField) return false;
      final element = find.byWidget(widget).evaluate().firstOrNull;
      if (element == null) return false;

      // O _buildTextField coloca o Text e o TextFormField dentro da mesma Column
      final parentColumn = element.findAncestorWidgetOfExactType<Column>();
      if (parentColumn == null) return false;

      return parentColumn.children.any(
        (child) => child is Text && child.data == label,
      );
    });
  }

  group('CadastroScreen - Renderização e Estrutura Inicial', () {
    testWidgets('Deve renderizar todos os campos de formulário e botões essenciais',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Data de Nascimento'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Confirmar Senha'), findsOneWidget);
      expect(find.text('CEP'), findsOneWidget);
      expect(find.text('Rua'), findsOneWidget);
      expect(find.text('Número'), findsOneWidget);
      expect(find.text('Bairro'), findsOneWidget);
      expect(find.text('Cidade'), findsOneWidget);
      expect(find.text('Estado'), findsOneWidget);

      expect(find.widgetWithText(ElevatedButton, 'Cadastrar'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Já tem uma conta? Faça login'),
          findsOneWidget);
    });
  });

  group('CadastroScreen - Validações do Formulário', () {
    testWidgets('Deve exibir erros obrigatórios ao tentar submeter formulário em branco',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
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

    testWidgets('Validações de regras específicas: Nome com caracteres inválidos e Senha curta',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Nome com números
      final nomeField = findFieldByLabel('Nome');
      await tester.ensureVisible(nomeField);
      await tester.enterText(nomeField, 'Marcos 123');

      // Senha curta (< 6 caracteres)
      final senhaField = findFieldByLabel('Senha');
      await tester.ensureVisible(senhaField);
      await tester.enterText(senhaField, '123');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      expect(
        find.text('O nome não pode conter números ou caracteres especiais'),
        findsOneWidget,
      );
      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('Validações de Formato de E-mail, Data Inválida e Divergência de Senhas',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // E-mail inválido
      final emailField = findFieldByLabel('E-mail');
      await tester.ensureVisible(emailField);
      await tester.enterText(emailField, 'emailinvalido.com');

      // Data inválida (dia inexistente para fevereiro)
      final dataField = findFieldByLabel('Data de Nascimento');
      await tester.ensureVisible(dataField);
      await tester.enterText(dataField, '31022020'); // Formatador converte para 31/02/2020

      // Senha e confirmação diferentes
      final senhaField = findFieldByLabel('Senha');
      await tester.ensureVisible(senhaField);
      await tester.enterText(senhaField, 'senha123');

      final confSenhaField = findFieldByLabel('Confirmar Senha');
      await tester.ensureVisible(confSenhaField);
      await tester.enterText(confSenhaField, 'senhaDiferente');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('Dia deve ser entre 01 e 29'), findsOneWidget);
      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });
  });

  group('CadastroScreen - Fluxo de Sucesso e Navegação', () {
    testWidgets('Preenchimento correto cadastra usuário no Auth e persiste no Firestore',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      Future<void> preencherCampo(String label, String valor) async {
        final campo = findFieldByLabel(label);
        await tester.ensureVisible(campo);
        await tester.enterText(campo, valor);
      }

      await preencherCampo('Nome', 'Marcos da Silva');
      await preencherCampo('Data de Nascimento', '15101998');
      await preencherCampo('E-mail', 'marcos@teste.com');
      await preencherCampo('Senha', 'segredo123');
      await preencherCampo('Confirmar Senha', 'segredo123');
      await preencherCampo('CEP', '51020000');
      await preencherCampo('Rua', 'Av Boa Viagem');
      await preencherCampo('Número', '500');
      await preencherCampo('Bairro', 'Boa Viagem');
      await preencherCampo('Cidade', 'Recife');

      // Seleciona o Dropdown de Estado
      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      final itemPE = find.widgetWithText(DropdownMenuItem<String>, 'PE').last;
      await tester.tap(itemPE);
      await tester.pumpAndSettle();

      // Clica em cadastrar
      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      // 1. Verifica criação no Auth
      expect(mockAuth.currentUser, isNotNull);
      expect(mockAuth.currentUser!.email, 'marcos@teste.com');

      // 2. Verifica documento no Firestore
      final uid = mockAuth.currentUser!.uid;
      final docSnapshot =
          await fakeFirestore.collection('usuarios').doc(uid).get();

      expect(docSnapshot.exists, isTrue);
      expect(docSnapshot.data()!['nome'], 'Marcos da Silva');
      expect(docSnapshot.data()!['data_nasc'], '15/10/1998');
      expect(docSnapshot.data()!['endereco']['cidade'], 'Recife');
      expect(docSnapshot.data()!['endereco']['estado'], 'PE');

      // 3. Verifica transição de tela
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
    });

    testWidgets('Toque em "Já tem uma conta? Faça login" deve abrir LoginScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final loginBtn =
          find.widgetWithText(TextButton, 'Já tem uma conta? Faça login');
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}

