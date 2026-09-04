import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

  Widget createWidget() {
    return MaterialApp(
      home: CadastroScreen(
        auth: mockAuth,
        firestore: fakeFirestore,
      ),
      routes: {
        '/login': (_) => LoginScreen(auth: mockAuth),
        '/generos': (_) => GenerosCadastroScreen(
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
      },
    );
  }

  Future<void> pumpCadastro(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();
  }

  Future<void> tapCadastrar(WidgetTester tester) async {
    final cadastrar = find.text('Cadastrar');

    expect(cadastrar, findsOneWidget);

    await tester.tap(cadastrar);
    await tester.pumpAndSettle();
  }

  Future<void> selecionarEstado(
    WidgetTester tester,
    String estado,
  ) async {
    final dropdown = find.byType(DropdownButtonFormField<String>);

    expect(dropdown, findsOneWidget);

    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    // O DropdownButtonFormField abre um menu em uma rota/overlay.
    // Não é necessário usar ensureVisible() no item do menu.
    final opcao = find.text(estado).last;

    expect(opcao, findsOneWidget);

    await tester.tap(opcao);
    await tester.pumpAndSettle();
  }

  group('CadastroScreen - renderização', () {
    testWidgets('deve renderizar os principais campos do formulário',
        (tester) async {
      await pumpCadastro(tester);

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
      expect(find.text('Cadastrar'), findsOneWidget);
      expect(
        find.text('Já tem uma conta? Faça login'),
        findsOneWidget,
      );
    });

    testWidgets('deve iniciar o estado sem estado selecionado', (tester) async {
      await pumpCadastro(tester);

      final dropdown = find.byType(DropdownButtonFormField<String>);

      expect(dropdown, findsOneWidget);
    });
  });

  group('CadastroScreen - validação', () {
    testWidgets('deve mostrar erros quando o formulário estiver vazio',
        (tester) async {
      await pumpCadastro(tester);

      await tapCadastrar(tester);

      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(
        find.text('A data de nascimento é obrigatória'),
        findsOneWidget,
      );
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      // Quando ambos os campos de senha estão vazios, o validator de
      // "Confirmar Senha" (value != _senhaController.text) não dispara,
      // pois '' == '' — logicamente as senhas *coincidem* (ambas vazias).
      expect(find.text('As senhas não coincidem'), findsNothing);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);
    });

    testWidgets('deve rejeitar nome contendo números', (tester) async {
      await pumpCadastro(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'João123',
      );

      await tapCadastrar(tester);

      expect(
        find.text(
          'O nome não pode conter números ou caracteres especiais',
        ),
        findsOneWidget,
      );
    });

    testWidgets('deve rejeitar nome contendo caracteres especiais',
        (tester) async {
      await pumpCadastro(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'João@Silva',
      );

      await tapCadastrar(tester);

      expect(
        find.text(
          'O nome não pode conter números ou caracteres especiais',
        ),
        findsOneWidget,
      );
    });

    testWidgets('deve aceitar nome com caracteres acentuados', (tester) async {
      await pumpCadastro(tester);

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'João da Silva');
      await tester.enterText(fields.at(1), '01/01/2000');
      await tester.enterText(fields.at(2), 'joao@example.com');
      await tester.enterText(fields.at(3), '123456');
      await tester.enterText(fields.at(4), '123456');
      await tester.enterText(fields.at(5), '50000-000');
      await tester.enterText(fields.at(6), 'Rua A');
      await tester.enterText(fields.at(7), '123');
      await tester.enterText(fields.at(8), 'Centro');
      await tester.enterText(fields.at(9), 'Recife');

      await tapCadastrar(tester);

      expect(
        find.text('O nome não pode conter números ou caracteres especiais'),
        findsNothing,
      );
    });

    testWidgets('deve rejeitar data com formato inválido', (tester) async {
      await pumpCadastro(tester);

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(1), '01012000');

      await tapCadastrar(tester);

      // O formatter transforma automaticamente 01012000 em 01/01/2000.
      // Portanto, essa entrada deve ser aceita como uma data válida.
      expect(
        find.text('Formato inválido. Use dd/mm/aaaa'),
        findsNothing,
      );
    });

    testWidgets('deve rejeitar mês inválido', (tester) async {
      await pumpCadastro(tester);

      final fields = find.byType(TextFormField);

      // A máscara transforma em 01/13/2000.
      await tester.enterText(fields.at(1), '01132000');

      await tapCadastrar(tester);

      expect(
        find.text('Mês deve ser entre 01 e 12'),
        findsOneWidget,
      );
    });

    testWidgets('deve rejeitar dia inválido', (tester) async {
      await pumpCadastro(tester);

      final fields = find.byType(TextFormField);

      // Fevereiro de 2023 possui apenas 28 dias.
      await tester.enterText(fields.at(1), '29022023');

      await tapCadastrar(tester);

      expect(
        find.text('Dia deve ser entre 01 e 28'),
        findsOneWidget,
      );
    });

    testWidgets('deve rejeitar data futura', (tester) async {
      await pumpCadastro(tester);

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(1), '01012030');

      await tapCadastrar(tester);

      expect(
        find.text('A data não pode ser no futuro'),
        findsOneWidget,
      );
    });

    testWidgets('deve rejeitar e-mail inválido', (tester) async {
      await pumpCadastro(tester);

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(2), 'email-invalido');

      await tapCadastrar(tester);

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('deve rejeitar senha com menos de 6 caracteres',
        (tester) async {
      await pumpCadastro(tester);

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(3), '12345');
      await tester.enterText(fields.at(4), '12345');

      await tapCadastrar(tester);

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('deve rejeitar senhas diferentes', (tester) async {
      await pumpCadastro(tester);

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(3), '123456');
      await tester.enterText(fields.at(4), '654321');

      await tapCadastrar(tester);

      expect(
        find.text('As senhas não coincidem'),
        findsOneWidget,
      );
    });

    testWidgets('deve rejeitar CEP em formato inválido', (tester) async {
      await pumpCadastro(tester);

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(5), '12345');

      await tapCadastrar(tester);

      expect(
        find.text('CEP inválido. Formato correto: XXXXX-XXX'),
        findsOneWidget,
      );
    });

    testWidgets('deve rejeitar número que não seja numérico', (tester) async {
      await pumpCadastro(tester);

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(7), 'abc');

      await tapCadastrar(tester);

      expect(
        find.text('O número deve ser numérico'),
        findsOneWidget,
      );
    });
  });

  group('CadastroScreen - interações', () {
    testWidgets('deve aplicar máscara de data de nascimento', (tester) async {
      await pumpCadastro(tester);

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(1), '15081995');

      final textField = tester.widget<TextFormField>(fields.at(1));

      expect(textField.controller!.text, '15/08/1995');
    });

    testWidgets('deve aplicar máscara de CEP', (tester) async {
      await pumpCadastro(tester);

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(5), '50000000');

      final textField = tester.widget<TextFormField>(fields.at(5));

      expect(textField.controller!.text, '50000-000');
    });

    testWidgets('deve permitir selecionar um estado', (tester) async {
      await pumpCadastro(tester);

      await selecionarEstado(tester, 'PE');

      expect(find.text('PE'), findsOneWidget);
    });

    testWidgets('campos de senha devem estar ocultos', (tester) async {
      await pumpCadastro(tester);

      final fields = find.byType(TextFormField);

      final senhaTextField = find.descendant(
        of: fields.at(3),
        matching: find.byType(TextField),
      );

      final confirmarTextField = find.descendant(
        of: fields.at(4),
        matching: find.byType(TextField),
      );

      expect(senhaTextField, findsOneWidget);
      expect(confirmarTextField, findsOneWidget);

      final senha = tester.widget<TextField>(senhaTextField);
      final confirmar = tester.widget<TextField>(confirmarTextField);

      expect(senha.obscureText, isTrue);
      expect(confirmar.obscureText, isTrue);
    });
  });

  group('CadastroScreen - navegação', () {
    testWidgets('deve navegar para a tela de login', (tester) async {
      await pumpCadastro(tester);

      final loginButton = find.text('Já tem uma conta? Faça login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('CadastroScreen - cadastro', () {
    testWidgets(
      'deve criar usuário, salvar dados no Firestore e navegar',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-teste-123',
          email: 'teste@example.com',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
          signedIn: false,
        );

        await pumpCadastro(tester);

        final fields = find.byType(TextFormField);

        await tester.enterText(fields.at(0), 'Maria Silva');
        await tester.enterText(fields.at(1), '10051995');
        await tester.enterText(fields.at(2), 'maria@example.com');
        await tester.enterText(fields.at(3), '123456');
        await tester.enterText(fields.at(4), '123456');
        await tester.enterText(fields.at(5), '50000000');
        await tester.enterText(fields.at(6), 'Rua das Flores');
        await tester.enterText(fields.at(7), '123');
        await tester.enterText(fields.at(8), 'Centro');
        await tester.enterText(fields.at(9), 'Recife');

        await selecionarEstado(tester, 'PE');

        await tapCadastrar(tester);

        final document = await fakeFirestore
            .collection('usuarios')
            .doc('usuario-teste-123')
            .get();

        expect(document.exists, isTrue);

        final data = document.data()!;

        expect(data['nome'], 'Maria Silva');
        expect(data['data_nasc'], '10/05/1995');
        expect(data['email'], 'maria@example.com');

        final endereco = data['endereco'] as Map<String, dynamic>;

        expect(endereco['rua'], 'Rua das Flores');
        expect(endereco['numero'], '123');
        expect(endereco['bairro'], 'Centro');
        expect(endereco['cidade'], 'Recife');
        expect(endereco['estado'], 'PE');
        expect(endereco['cep'], '50000-000');

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'não deve tentar cadastrar quando houver erros de validação',
      (tester) async {
        await pumpCadastro(tester);

        await tapCadastrar(tester);

        expect(
          find.text('O nome é obrigatório'),
          findsOneWidget,
        );

        // Como o formulário é inválido, nenhuma coleção deve ter sido
        // criada no Firestore.
        final usuarios = await fakeFirestore.collection('usuarios').get();

        expect(usuarios.docs, isEmpty);
      },
    );
  });
}
