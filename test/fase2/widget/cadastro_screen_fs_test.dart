import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/login.dart';

void main() {
  group('CadastroScreen Widget', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
    });

    Future<void> pumpCadastroScreen(WidgetTester tester) async {
      // O formulário é maior que a viewport padrão do WidgetTester.
      // Aumentamos a superfície para que os elementos possam ser
      // atingidos diretamente sem alterar o comportamento do widget.
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: CadastroScreen(
            auth: mockAuth,
            firestore: fakeFirestore,
          ),
        ),
      );

      await tester.pump();
    }

    testWidgets('deve renderizar os principais campos do formulário',
        (tester) async {
      await pumpCadastroScreen(tester);

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
    });

    testWidgets('deve mostrar erro quando nome está vazio', (tester) async {
      await pumpCadastroScreen(tester);

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(find.text('O nome é obrigatório'), findsOneWidget);
    });

    testWidgets('deve mostrar erro quando data de nascimento está vazia',
        (tester) async {
      await pumpCadastroScreen(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'João da Silva',
      );

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(
        find.text('A data de nascimento é obrigatória'),
        findsOneWidget,
      );
    });

    testWidgets('deve rejeitar data de nascimento com formato inválido',
        (tester) async {
      await pumpCadastroScreen(tester);

      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), 'João da Silva');
      await tester.enterText(campos.at(1), '0101');

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(
        find.text('Formato inválido. Use dd/mm/aaaa'),
        findsOneWidget,
      );
    });

    testWidgets('deve rejeitar mês inválido na data de nascimento',
        (tester) async {
      await pumpCadastroScreen(tester);

      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), 'João da Silva');
      await tester.enterText(campos.at(1), '01132000');

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(
        find.text('Mês deve ser entre 01 e 12'),
        findsOneWidget,
      );
    });

    testWidgets('deve rejeitar dia inválido na data de nascimento',
        (tester) async {
      await pumpCadastroScreen(tester);

      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), 'João da Silva');
      await tester.enterText(campos.at(1), '30022020');

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(
        find.text('Dia deve ser entre 01 e 29'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar erro quando nome contém números',
        (tester) async {
      await pumpCadastroScreen(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'João123',
      );

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(
        find.text(
          'O nome não pode conter números ou caracteres especiais',
        ),
        findsOneWidget,
      );
    });

    testWidgets('deve aceitar nome com acentos', (tester) async {
      await pumpCadastroScreen(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'José da Silva',
      );

      expect(
        find.text(
          'O nome não pode conter números ou caracteres especiais',
        ),
        findsNothing,
      );

      expect(find.text('O nome é obrigatório'), findsNothing);
    });

    testWidgets('deve mostrar erro quando e-mail está vazio', (tester) async {
      await pumpCadastroScreen(tester);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'João da Silva',
      );

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
    });

    testWidgets('deve mostrar erro para e-mail inválido', (tester) async {
      await pumpCadastroScreen(tester);

      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), 'João da Silva');
      await tester.enterText(campos.at(2), 'email-invalido');

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('deve aceitar e-mail válido', (tester) async {
      await pumpCadastroScreen(tester);

      final form = find.byType(Form);
      final emailField = find.byType(TextFormField).at(2);

      await tester.enterText(emailField, 'joao@example.com');

      final formState = tester.state<FormState>(form);

      expect(formState.validate(), isFalse);
    });

    testWidgets('deve mostrar erro quando senha está vazia', (tester) async {
      await pumpCadastroScreen(tester);

      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), 'João da Silva');
      await tester.enterText(campos.at(1), '01012000');
      await tester.enterText(campos.at(2), 'joao@example.com');

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(find.text('A senha é obrigatória'), findsOneWidget);
    });

    testWidgets('deve rejeitar senha com menos de 6 caracteres',
        (tester) async {
      await pumpCadastroScreen(tester);

      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), 'João da Silva');
      await tester.enterText(campos.at(1), '01012000');
      await tester.enterText(campos.at(2), 'joao@example.com');
      await tester.enterText(campos.at(3), '12345');

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar erro quando as senhas não coincidem',
        (tester) async {
      await pumpCadastroScreen(tester);

      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), 'João da Silva');
      await tester.enterText(campos.at(1), '01012000');
      await tester.enterText(campos.at(2), 'joao@example.com');
      await tester.enterText(campos.at(3), '123456');
      await tester.enterText(campos.at(4), '654321');

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });

    testWidgets('deve mostrar erro quando CEP está vazio', (tester) async {
      await pumpCadastroScreen(tester);

      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), 'João da Silva');
      await tester.enterText(campos.at(1), '01012000');
      await tester.enterText(campos.at(2), 'joao@example.com');
      await tester.enterText(campos.at(3), '123456');
      await tester.enterText(campos.at(4), '123456');

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(find.text('O CEP é obrigatório'), findsOneWidget);
    });

    testWidgets('deve formatar CEP no padrão XXXXX-XXX', (tester) async {
      await pumpCadastroScreen(tester);

      final cepField = find.byType(TextFormField).at(5);

      await tester.enterText(cepField, '12345678');

      expect(
        tester.widget<TextFormField>(cepField).controller!.text,
        '12345-678',
      );
    });

    testWidgets('deve rejeitar CEP inválido', (tester) async {
      await pumpCadastroScreen(tester);

      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), 'João da Silva');
      await tester.enterText(campos.at(1), '01012000');
      await tester.enterText(campos.at(2), 'joao@example.com');
      await tester.enterText(campos.at(3), '123456');
      await tester.enterText(campos.at(4), '123456');
      await tester.enterText(campos.at(5), '12345');

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(
        find.text('CEP inválido. Formato correto: XXXXX-XXX'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar erro quando número está vazio', (tester) async {
      await pumpCadastroScreen(tester);

      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), 'João da Silva');
      await tester.enterText(campos.at(1), '01012000');
      await tester.enterText(campos.at(2), 'joao@example.com');
      await tester.enterText(campos.at(3), '123456');
      await tester.enterText(campos.at(4), '123456');
      await tester.enterText(campos.at(5), '12345678');

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(find.text('O número é obrigatório'), findsOneWidget);
    });

    testWidgets('deve rejeitar número contendo letras', (tester) async {
      await pumpCadastroScreen(tester);

      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), 'João da Silva');
      await tester.enterText(campos.at(1), '01012000');
      await tester.enterText(campos.at(2), 'joao@example.com');
      await tester.enterText(campos.at(3), '123456');
      await tester.enterText(campos.at(4), '123456');
      await tester.enterText(campos.at(5), '12345678');
      await tester.enterText(campos.at(7), '12A');

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(
        find.text('O número deve ser numérico'),
        findsOneWidget,
      );
    });

    testWidgets('deve permitir selecionar um estado', (tester) async {
      await pumpCadastroScreen(tester);

      final dropdown = find.byType(DropdownButtonFormField<String>);

      expect(dropdown, findsOneWidget);

      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      expect(find.text('PE'), findsOneWidget);

      await tester.tap(find.text('PE').last);
      await tester.pumpAndSettle();

      expect(find.text('PE'), findsOneWidget);
    });

    testWidgets('deve navegar para login ao tocar no botão de login',
        (tester) async {
      await pumpCadastroScreen(tester);

      await tester.tap(
        find.text('Já tem uma conta? Faça login'),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets(
      'deve cadastrar usuário e salvar dados no Firestore',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1800);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final user = MockUser(
          uid: 'usuario-teste',
          email: 'joao@example.com',
        );

        final auth = MockFirebaseAuth(
          mockUser: user,
          signedIn: false,
        );

        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pump();

        final campos = find.byType(TextFormField);

        await tester.enterText(campos.at(0), 'João da Silva');
        await tester.enterText(campos.at(1), '01012000');
        await tester.enterText(campos.at(2), 'joao@example.com');
        await tester.enterText(campos.at(3), '123456');
        await tester.enterText(campos.at(4), '123456');
        await tester.enterText(campos.at(5), '12345678');
        await tester.enterText(campos.at(6), 'Rua Teste');
        await tester.enterText(campos.at(7), '123');
        await tester.enterText(campos.at(8), 'Centro');
        await tester.enterText(campos.at(9), 'Recife');

        final dropdown = find.byType(DropdownButtonFormField<String>);

        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        await tester.tap(find.text('PE').last);
        await tester.pumpAndSettle();

        expect(find.text('PE'), findsOneWidget);

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        final snapshot = await firestore
            .collection('usuarios')
            .doc('usuario-teste')
            .get();

        // Esta é a asserção principal: o cadastro válido precisa
        // efetivamente criar o documento.
        expect(snapshot.exists, isTrue);

        expect(snapshot.data()?['nome'], 'João da Silva');
        expect(snapshot.data()?['data_nasc'], '01/01/2000');
        expect(snapshot.data()?['email'], 'joao@example.com');

        final endereco = snapshot.data()?['endereco'] as Map<String, dynamic>;

        expect(endereco['rua'], 'Rua Teste');
        expect(endereco['numero'], '123');
        expect(endereco['bairro'], 'Centro');
        expect(endereco['cidade'], 'Recife');
        expect(endereco['estado'], 'PE');
        expect(endereco['cep'], '12345-678');
      },
    );

    testWidgets('deve exibir SnackBar quando Firebase Auth falhar',
        (tester) async {
      // Também é um pumpWidget manual.
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final auth = MockFirebaseAuth();

      whenCalling(
        Invocation.method(
          #createUserWithEmailAndPassword,
          null,
        ),
      ).on(auth).thenThrow(
            FirebaseAuthException(
              code: 'email-already-in-use',
              message: 'O e-mail já está cadastrado.',
            ),
          );

      await tester.pumpWidget(
        MaterialApp(
          home: CadastroScreen(
            auth: auth,
            firestore: fakeFirestore,
          ),
        ),
      );

      await tester.pump();

      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), 'João da Silva');
      await tester.enterText(campos.at(1), '01012000');
      await tester.enterText(campos.at(2), 'joao@example.com');
      await tester.enterText(campos.at(3), '123456');
      await tester.enterText(campos.at(4), '123456');
      await tester.enterText(campos.at(5), '12345678');
      await tester.enterText(campos.at(7), '123');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Erro ao cadastrar: O e-mail já está cadastrado.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('deve esconder o texto dos campos de senha', (tester) async {
      await pumpCadastroScreen(tester);

      final campos = find.byType(TextFormField);

      final senhaTextField = find.descendant(
        of: campos.at(3),
        matching: find.byType(TextField),
      );

      final confirmarSenhaTextField = find.descendant(
        of: campos.at(4),
        matching: find.byType(TextField),
      );

      expect(senhaTextField, findsOneWidget);
      expect(confirmarSenhaTextField, findsOneWidget);

      final senha = tester.widget<TextField>(senhaTextField);
      final confirmarSenha = tester.widget<TextField>(confirmarSenhaTextField);

      expect(senha.obscureText, isTrue);
      expect(confirmarSenha.obscureText, isTrue);
    });
  });
}
