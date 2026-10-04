import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> abrirCadastro(WidgetTester tester) async {
    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
    expect(find.text('Cadastro'), findsOneWidget);

    await tester.tap(find.text('Cadastro'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastrar'), findsOneWidget);
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

    // A ordem dos TextFormField em CadastroScreen é:
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
    //
    // Rua/Bairro/Cidade podem ser preenchidos automaticamente pelo ViaCEP,
    // mas o teste também garante que o número seja preenchido pela interface.

    await tester.enterText(campos.at(0), nome);
    await tester.enterText(campos.at(1), dataNascimento);
    await tester.enterText(campos.at(2), email);
    await tester.enterText(campos.at(3), senha);
    await tester.enterText(campos.at(4), senha);
    await tester.enterText(campos.at(5), cep);

    // O preenchimento do CEP dispara a consulta ao ViaCEP.
    // Damos tempo para a resposta atualizar Rua/Bairro/Cidade/Estado.
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.enterText(campos.at(7), numero);
  }

  Future<void> selecionarGenero(
    WidgetTester tester,
    String genero,
  ) async {
    final textoGenero = find.text(genero);
    expect(textoGenero, findsOneWidget);

    // O Switch está no mesmo Card do texto do gênero.
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

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
  }

  Future<void> navegarParaGeneros(WidgetTester tester) async {
    expect(find.text('Cadastrar'), findsOneWidget);

    await tester.tap(find.text('Cadastrar'));
    await tester.pumpAndSettle();

    expect(
      find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
      findsOneWidget,
    );
    expect(find.text('Confirmar'), findsOneWidget);
  }

  testWidgets(
    'fluxo E2E completo: cadastro, gêneros, Firestore e tela inicial',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await abrirCadastro(tester);

      final emailUnico =
          'e2e-${DateTime.now().microsecondsSinceEpoch}@sintonize.test';

      await preencherCadastro(
        tester,
        nome: 'Usuário E2E',
        email: emailUnico,
      );

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // O cadastro bem-sucedido deve levar à tela de gêneros.
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );
      expect(find.text('Confirmar'), findsOneWidget);

      // Seleciona dois gêneros pela interface.
      await selecionarGenero(tester, 'Rock');
      await selecionarGenero(tester, 'Jazz');

      // Confirma os gêneros.
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // A confirmação deve navegar para a tela inicial.
      expect(find.textContaining('essa é a nossa recomendação'), findsOneWidget);

      // Verifica diretamente no Firestore o efeito produzido pela UI.
      // Isso não é mock: é o Firestore Emulator usado pelo app.
      final user = FirebaseFirestore.instance;
      final authUser = FirebaseAuth.instance.currentUser;

      // O usuário criado pela interface deve estar autenticado.
      expect(authUser, isNotNull);
      expect(authUser!.email, emailUnico);

      final documento = await user
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

      // Tenta cadastrar sem preencher nenhum campo.
      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

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

      // Continua na tela de cadastro.
      expect(find.text('Cadastrar'), findsOneWidget);
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
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

      // Este usuário é populado pelo ambiente antes da execução.
      await preencherCadastro(
        tester,
        nome: 'Outro Usuário',
        email: 'tester@sintonize.test',
      );

      await tester.tap(find.text('Cadastrar'));

      // Espera a operação do Firebase Auth e a atualização da SnackBar.
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(
        find.textContaining('Erro ao cadastrar:'),
        findsOneWidget,
      );

      // O Firebase deve rejeitar o cadastro e permanecer na CadastroScreen.
      expect(find.text('Cadastrar'), findsOneWidget);
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
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

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Cadastro deve ter sido concluído e a tela de gêneros aberta.
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      // Nenhum Switch é selecionado.
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Selecione pelo menos um gênero musical!'),
        findsOneWidget,
      );

      // Ainda não deve ter navegado para a TelaInicialScreen.
      expect(
        find.text('Confirmar'),
        findsOneWidget,
      );
      expect(
        find.textContaining('essa é a nossa recomendação'),
        findsNothing,
      );

      // Confirma também que o documento ainda não recebeu
      // generos_favoritos por causa dessa tentativa inválida.
      final authUser = FirebaseAuth.instance.currentUser;
      expect(authUser, isNotNull);

      final documento = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(authUser!.uid)
          .get();

      expect(documento.exists, isTrue);
      expect(documento.data()!.containsKey('generos_favoritos'), isFalse);
    },
  );
}
