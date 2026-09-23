import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// Ajuste o caminho de importação conforme seu projeto:
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

void main() {
  group('CadastroScreen Widget Tests', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore mockFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = FakeFirebaseFirestore();
    });

    // Helper robusto para encontrar o TextFormField específico pelo texto do seu rótulo
    Finder findFieldByLabel(String label) {
      return find.byWidgetPredicate((widget) {
        if (widget is! Column) return false;
        final children = widget.children;
        if (children.isEmpty) return false;
        final firstChild = children.first;
        if (firstChild is Text && firstChild.data == label) {
          return children.any((c) => c is TextFormField);
        }
        return false;
      });
    }

    // Retorna o TextFormField filho da coluna identificada pelo rótulo
    Finder getField(String label) {
      return find.descendant(
        of: findFieldByLabel(label),
        matching: find.byType(TextFormField),
      );
    }

    Future<void> pumpCadastroScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CadastroScreen(
            auth: mockAuth,
            firestore: mockFirestore,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('deve renderizar os componentes principais da tela de cadastro',
        (tester) async {
      await pumpCadastroScreen(tester);

      expect(find.byType(Form), findsOneWidget);
      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Data de Nascimento'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Cadastrar'), findsOneWidget);
      expect(find.text('Já tem uma conta? Faça login'), findsOneWidget);
    });

    testWidgets('deve exibir mensagens de erro para campos obrigatórios vazios',
        (tester) async {
      await pumpCadastroScreen(tester);

      final cadastrarBtn = find.text('Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pump();

      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);
    });

    testWidgets('deve validar nome com caracteres especiais ou números',
        (tester) async {
      await pumpCadastroScreen(tester);

      final nomeField = getField('Nome');
      await tester.enterText(nomeField, 'João 123');

      final cadastrarBtn = find.text('Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pump();

      expect(
        find.text('O nome não pode conter números ou caracteres especiais'),
        findsOneWidget,
      );
    });

    testWidgets('deve validar formato incorreto de e-mail', (tester) async {
      await pumpCadastroScreen(tester);

      final emailField = getField('E-mail');
      await tester.enterText(emailField, 'email_invalido.com');

      final cadastrarBtn = find.text('Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pump();

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('deve validar tamanho mínimo da senha e divergência na confirmação',
        (tester) async {
      await pumpCadastroScreen(tester);

      final senhaField = getField('Senha');
      final confSenhaField = getField('Confirmar Senha');

      // 1. Senha curta
      await tester.enterText(senhaField, '123');
      await tester.enterText(confSenhaField, '123');

      final cadastrarBtn = find.text('Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );

      // 2. Senhas diferentes
      await tester.enterText(senhaField, '123456');
      await tester.enterText(confSenhaField, 'abcdef');
      await tester.tap(cadastrarBtn);
      await tester.pump();

      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });

    testWidgets('deve validar formato e obrigatoriedade do CEP', (tester) async {
      await pumpCadastroScreen(tester);

      final cepField = getField('CEP');
      await tester.ensureVisible(cepField);

      // Inserção com menos de 9 caracteres
      await tester.enterText(cepField, '12345');

      final cadastrarBtn = find.text('Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pump();

      expect(
        find.text('CEP inválido. Formato correto: XXXXX-XXX'),
        findsOneWidget,
      );
    });

    testWidgets(
        'deve cadastrar usuário no Firebase Auth, salvar no Firestore e navegar com sucesso',
        (tester) async {
      await pumpCadastroScreen(tester);

      // 1. Preenchimento dos dados pessoais
      await tester.enterText(getField('Nome'), 'Maria Silva');
      await tester.enterText(getField('Data de Nascimento'), '15/05/1995');
      await tester.enterText(getField('E-mail'), 'mariasilva@teste.com');
      await tester.enterText(getField('Senha'), 'senhaForte123');
      await tester.enterText(getField('Confirmar Senha'), 'senhaForte123');

      // 2. Preenchimento do endereço
      final cepField = getField('CEP');
      await tester.ensureVisible(cepField);
      await tester.enterText(cepField, '50000-000');
      await tester.pump();

      final ruaField = getField('Rua');
      await tester.ensureVisible(ruaField);
      await tester.enterText(ruaField, 'Rua das Flores');

      final numeroField = getField('Número');
      await tester.ensureVisible(numeroField);
      await tester.enterText(numeroField, '123');

      final bairroField = getField('Bairro');
      await tester.ensureVisible(bairroField);
      await tester.enterText(bairroField, 'Centro');

      final cidadeField = getField('Cidade');
      await tester.ensureVisible(cidadeField);
      await tester.enterText(cidadeField, 'Recife');

      // 3. Seleção do Estado no Dropdown
      // Localiza o DropdownButton dentro do formulário e abre a lista de opções
      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // 'AC' é o primeiro item da lista _estados e sempre estará visível no topo do popup
      final estadoItem = find.text('AC').last;
      expect(estadoItem, findsOneWidget);
      await tester.tap(estadoItem);
      await tester.pumpAndSettle();

      // 4. Submissão do formulário
      final cadastrarBtn = find.text('Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      // Validação 1: Criação de usuário no Firebase Auth Mock
      expect(mockAuth.currentUser, isNotNull);
      expect(mockAuth.currentUser!.email, equals('mariasilva@teste.com'));

      // Validação 2: Dados persistidos no Firestore Fake
      final uid = mockAuth.currentUser!.uid;
      final docSnapshot =
          await mockFirestore.collection('usuarios').doc(uid).get();

      expect(docSnapshot.exists, isTrue);
      expect(docSnapshot.data()?['nome'], equals('Maria Silva'));
      expect(docSnapshot.data()?['data_nasc'], equals('15/05/1995'));
      expect(docSnapshot.data()?['email'], equals('mariasilva@teste.com'));
      expect(docSnapshot.data()?['endereco']['rua'], equals('Rua das Flores'));
      expect(docSnapshot.data()?['endereco']['numero'], equals('123'));
      expect(docSnapshot.data()?['endereco']['cidade'], equals('Recife'));
      expect(docSnapshot.data()?['endereco']['estado'], equals('AC'));

      // Validação 3: Navegação para GenerosCadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
    });
  });
}

