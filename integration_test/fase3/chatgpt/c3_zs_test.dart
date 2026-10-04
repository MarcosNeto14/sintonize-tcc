import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  setUp(() async {
    // Cada cenário começa sem usuário autenticado.
    // O usuário previamente populado no emulator continua existindo.
    await FirebaseAuth.instance.signOut();
  });

  Future<void> abrirCadastro(WidgetTester tester) async {
    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
    expect(find.text('Cadastro'), findsOneWidget);

    await tester.tap(find.text('Cadastro'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastrar'), findsOneWidget);
  }

  Future<void> rolarAteCadastrar(WidgetTester tester) async {
    final cadastrar = find.text('Cadastrar');

    expect(cadastrar, findsOneWidget);

    // CadastroScreen usa um SingleChildScrollView.
    // O botão pode estar abaixo da viewport no emulador.
    await tester.scrollUntilVisible(
      cadastrar,
      500,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.pumpAndSettle();

    // Garante que o centro do botão está efetivamente visível
    // antes de tentar o toque.
    expect(
      tester.getBottomRight(cadastrar).dy,
      lessThanOrEqualTo(tester.view.physicalSize.height),
    );
  }

  Future<void> clicarCadastrar(WidgetTester tester) async {
    await rolarAteCadastrar(tester);

    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();
  }

  Future<void> preencherCadastro(
    WidgetTester tester, {
    required String nome,
    required String email,
    String senha = 'senha123',
    String dataNascimento = '01/01/2000',
    String cep = '01001-000',
    String numero = '100',
  }) async {
    final campos = find.byType(TextFormField);

    expect(campos, findsNWidgets(10));

    // Ordem dos TextFormField em CadastroScreen:
    //
    // 0 Nome
    // 1 Data de Nascimento
    // 2 E-mail
    // 3 Senha
    // 4 Confirmar Senha
    // 5 CEP
    // 6 Rua
    // 7 Número
    // 8 Bairro
    // 9 Cidade

    await tester.enterText(campos.at(0), nome);
    await tester.enterText(campos.at(1), dataNascimento);
    await tester.enterText(campos.at(2), email);
    await tester.enterText(campos.at(3), senha);
    await tester.enterText(campos.at(4), senha);
    await tester.enterText(campos.at(5), cep);

    // O CEP dispara uma consulta ao ViaCEP.
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.enterText(campos.at(7), numero);
  }

  Future<void> selecionarGenero(
    WidgetTester tester,
    String genero,
  ) async {
    final textoGenero = find.text(genero);

    expect(textoGenero, findsOneWidget);

    final card = find.ancestor(
      of: textoGenero,
      matching: find.byType(Card),
    );

    expect(card, findsOneWidget);

    final switchFinder = find.descendant(
      of: card,
      matching: find.byType(Switch),
    );

    expect(switchFinder, findsOneWidget);

    // Os gêneros ficam dentro de um ListView.
    // Garante que o switch esteja visível antes do toque.
    await tester.scrollUntilVisible(
      switchFinder,
      300,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.pumpAndSettle();

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'fluxo E2E completo: cadastro, gêneros, Firestore e tela inicial',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 1. Tela inicial -> Cadastro
      await abrirCadastro(tester);

      // 2. Preenche cadastro pela interface
      final emailUnico =
          'e2e-${DateTime.now().microsecondsSinceEpoch}@sintonize.test';

      await preencherCadastro(
        tester,
        nome: 'Usuário E2E',
        email: emailUnico,
      );

      // 3. Cadastro -> GenerosCadastroScreen
      await clicarCadastrar(tester);

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsOneWidget,
      );
      expect(find.text('Confirmar'), findsOneWidget);

      // 4. Seleciona gêneros pela interface.
      await selecionarGenero(tester, 'Rock');
      await selecionarGenero(tester, 'Jazz');

      // 5. Confirma.
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 6. Deve chegar à TelaInicialScreen.
      expect(
        find.textContaining('essa é a nossa recomendação'),
        findsOneWidget,
      );

      // 7. Verifica que o Firebase Auth realmente criou o usuário.
      final authUser = FirebaseAuth.instance.currentUser;

      expect(authUser, isNotNull);
      expect(authUser!.email, emailUnico);

      // 8. Verifica no Firestore o documento produzido pela aplicação.
      final documento = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(authUser.uid)
          .get();

      expect(documento.exists, isTrue);

      final dados = documento.data()!;

      expect(dados['nome'], 'Usuário E2E');
      expect(dados['email'], emailUnico);

      expect(
        dados['generos_favoritos'],
        containsAll(<String>['Rock', 'Jazz']),
      );

      expect(
        (dados['generos_favoritos'] as List).length,
        2,
      );
    },
  );

  testWidgets(
    'valida campos obrigatórios no cadastro',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await abrirCadastro(tester);

      // O botão precisa ser colocado na viewport antes do toque.
      await clicarCadastrar(tester);

      expect(
        find.text('O nome é obrigatório'),
        findsOneWidget,
      );

      expect(
        find.text('A data de nascimento é obrigatória'),
        findsOneWidget,
      );

      expect(
        find.text('O e-mail é obrigatório'),
        findsOneWidget,
      );

      expect(
        find.text('A senha é obrigatória'),
        findsOneWidget,
      );

      expect(
        find.text('O CEP é obrigatório'),
        findsOneWidget,
      );

      expect(
        find.text('O número é obrigatório'),
        findsOneWidget,
      );

      expect(find.text('Cadastrar'), findsOneWidget);

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'rejeita e-mail já cadastrado pelo Firebase Auth',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await abrirCadastro(tester);

      // Usuário criado pelo setup do ambiente.
      await preencherCadastro(
        tester,
        nome: 'Outro Usuário',
        email: 'tester@sintonize.test',
      );

      await clicarCadastrar(tester);

      // Firebase Auth deve rejeitar o e-mail duplicado.
      expect(
        find.textContaining('Erro ao cadastrar:'),
        findsOneWidget,
      );

      // Continua na CadastroScreen.
      expect(find.text('Cadastrar'), findsOneWidget);

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'não permite confirmar sem selecionar gênero musical',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await abrirCadastro(tester);

      final emailUnico =
          'e2e-genero-${DateTime.now().microsecondsSinceEpoch}@sintonize.test';

      await preencherCadastro(
        tester,
        nome: 'Teste Sem Gênero',
        email: emailUnico,
      );

      await clicarCadastrar(tester);

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsOneWidget,
      );

      // Não seleciona nenhum gênero.
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      // O comportamento esperado pela aplicação é mostrar o SnackBar.
      expect(
        find.text('Selecione pelo menos um gênero musical!'),
        findsOneWidget,
      );

      // E permanecer na tela de gêneros.
      expect(find.text('Confirmar'), findsOneWidget);

      expect(
        find.textContaining('essa é a nossa recomendação'),
        findsNothing,
      );

      // O documento foi criado durante o cadastro, mas não deve
      // possuir generos_favoritos porque _salvarGeneros() não foi chamado.
      final authUser = FirebaseAuth.instance.currentUser;

      expect(authUser, isNotNull);

      final documento = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(authUser!.uid)
          .get();

      expect(documento.exists, isTrue);

      expect(
        documento.data()!.containsKey('generos_favoritos'),
        isFalse,
      );
    },
  );
}
