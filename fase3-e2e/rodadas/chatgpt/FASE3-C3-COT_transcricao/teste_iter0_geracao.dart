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
    // Garante que um usuário autenticado de um teste anterior não
    // interfira na navegação inicial de outro teste.
    await FirebaseAuth.instance.signOut();
  });

  String uniqueEmail() {
    return 'e2e-${DateTime.now().microsecondsSinceEpoch}@sintonize.test';
  }

  Future<void> openCadastro(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // A HomeScreen contém uma animação de logo de 2 segundos.
    // Não precisamos esperar a animação inteira para encontrar o botão,
    // mas aguardamos a árvore inicial ficar estável.
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
    expect(find.text('Cadastro'), findsOneWidget);

    await tester.tap(find.text('Cadastro'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastrar'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(10));
  }

  Finder field(int index) {
    return find.byType(TextFormField).at(index);
  }

  Future<void> fillValidRegistration(
    WidgetTester tester, {
    required String email,
    String nome = 'Usuário E2E',
    String dataNascimento = '01/01/1990',
    String senha = 'senha123',
    String cep = '01001-000',
    String rua = 'Praça da Sé',
    String numero = '100',
    String bairro = 'Sé',
    String cidade = 'São Paulo',
  }) async {
    // Ordem dos TextFormField na CadastroScreen:
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

    await tester.enterText(field(0), nome);
    await tester.enterText(field(1), dataNascimento);
    await tester.enterText(field(2), email);
    await tester.enterText(field(3), senha);
    await tester.enterText(field(4), senha);

    await tester.enterText(field(5), cep);

    // A busca de CEP é disparada automaticamente quando o campo chega
    // a 9 caracteres no formato XXXXX-XXX.
    //
    // Se o serviço ViaCEP estiver disponível, os campos Rua/Bairro/Cidade
    // e Estado serão preenchidos automaticamente. Para manter o teste
    // determinístico mesmo que o retorno HTTP demore, aguardamos alguns
    // frames e completamos os campos manualmente se necessário.
    await tester.pumpAndSettle();

    if ((tester.widget<TextFormField>(field(6)).controller?.text ?? '').isEmpty) {
      await tester.enterText(field(6), rua);
    }

    await tester.enterText(field(7), numero);

    if ((tester.widget<TextFormField>(field(8)).controller?.text ?? '').isEmpty) {
      await tester.enterText(field(8), bairro);
    }

    if ((tester.widget<TextFormField>(field(9)).controller?.text ?? '').isEmpty) {
      await tester.enterText(field(9), cidade);
    }

    // Dropdown de Estado.
    final dropdown = find.byType(DropdownButtonFormField<String>);
    expect(dropdown, findsOneWidget);

    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    expect(find.text('SP'), findsWidgets);

    // Quando o Dropdown abre, há um item "SP" na lista.
    await tester.tap(find.text('SP').last);
    await tester.pumpAndSettle();
  }

  Future<void> submitRegistration(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Cadastrar'));
    await tester.tap(find.text('Cadastrar'));

    // _submit() contém operações assíncronas no Auth e Firestore.
    // pumpAndSettle aguarda a navegação posterior.
    await tester.pumpAndSettle();
  }

  Future<void> selectGenre(
    WidgetTester tester,
    String genre,
  ) async {
    final textFinder = find.text(genre);
    expect(textFinder, findsOneWidget);

    await tester.ensureVisible(textFinder);

    // O Switch é irmão do Text dentro do Card/Row.
    // Procuramos o Card que contém o texto e depois o Switch daquele Card.
    final card = find.ancestor(
      of: textFinder,
      matching: find.byType(Card),
    );

    expect(card, findsOneWidget);

    final switchFinder = find.descendant(
      of: card,
      matching: find.byType(Switch),
    );

    expect(switchFinder, findsOneWidget);

    await tester.tap(switchFinder);
    await tester.pump();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> currentUserDocument() async {
    final user = FirebaseAuth.instance.currentUser;
    expect(user, isNotNull);

    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .get();
  }

  testWidgets(
    'E2E completo: cadastro -> gêneros -> tela inicial -> dados persistidos',
    (tester) async {
      final email = uniqueEmail();

      await openCadastro(tester);

      await fillValidRegistration(
        tester,
        email: email,
      );

      // Verifica que ainda estamos no formulário antes do submit.
      expect(find.text('Cadastrar'), findsOneWidget);

      await submitRegistration(tester);

      // A navegação só ocorre depois de Auth + Firestore.
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      final user = FirebaseAuth.instance.currentUser;
      expect(user, isNotNull);
      expect(user!.email, email);

      // Comprova que o documento criado pelo próprio fluxo existe.
      var document = await currentUserDocument();

      expect(document.exists, isTrue);

      final registrationData = document.data()!;

      expect(registrationData['nome'], 'Usuário E2E');
      expect(registrationData['data_nasc'], '01/01/1990');
      expect(registrationData['email'], email);
      expect(registrationData['endereco'], isA<Map<String, dynamic>>());

      // Nenhum gênero foi selecionado ainda.
      expect(registrationData.containsKey('generos_favoritos'), isFalse);

      // Seleciona dois gêneros.
      await selectGenre(tester, 'Rock');
      await selectGenre(tester, 'Pop');

      expect(find.text('Confirmar'), findsOneWidget);

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      // A navegação para TelaInicialScreen acontece somente depois
      // do update() no Firestore.
      expect(
        find.textContaining(
          'Usuário E2E, essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      document = await currentUserDocument();

      expect(document.exists, isTrue);

      final data = document.data()!;

      expect(
        data['generos_favoritos'],
        containsAll(<String>['Rock', 'Pop']),
      );
      expect((data['generos_favoritos'] as List).length, 2);
    },
  );

  testWidgets(
    'Validação: nome com caracteres inválidos não cria usuário no Auth',
    (tester) async {
      await openCadastro(tester);

      final email = uniqueEmail();

      final auth = FirebaseAuth.instance;
      final before = await auth.fetchSignInMethodsForEmail(email);

      expect(before, isEmpty);

      await tester.enterText(field(0), 'Usuário123');
      await tester.enterText(field(1), '01/01/1990');
      await tester.enterText(field(2), email);
      await tester.enterText(field(3), 'senha123');
      await tester.enterText(field(4), 'senha123');
      await tester.enterText(field(5), '01001-000');
      await tester.enterText(field(6), 'Rua Teste');
      await tester.enterText(field(7), '100');
      await tester.enterText(field(8), 'Centro');
      await tester.enterText(field(9), 'São Paulo');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'O nome não pode conter números ou caracteres especiais',
        ),
        findsOneWidget,
      );

      // A validação deve impedir createUserWithEmailAndPassword().
      final after = await auth.fetchSignInMethodsForEmail(email);
      expect(after, isEmpty);

      expect(find.text('Cadastrar'), findsOneWidget);
    },
  );

  testWidgets(
    'Validação: data de nascimento inválida não cria usuário no Auth',
    (tester) async {
      await openCadastro(tester);

      final email = uniqueEmail();

      await tester.enterText(field(0), 'Usuário E2E');
      await tester.enterText(field(1), '31/02/1990');
      await tester.enterText(field(2), email);
      await tester.enterText(field(3), 'senha123');
      await tester.enterText(field(4), 'senha123');
      await tester.enterText(field(5), '01001-000');
      await tester.enterText(field(6), 'Rua Teste');
      await tester.enterText(field(7), '100');
      await tester.enterText(field(8), 'Centro');
      await tester.enterText(field(9), 'São Paulo');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Dia deve ser entre 01 e'),
        findsOneWidget,
      );

      expect(
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email),
        isEmpty,
      );
    },
  );

  testWidgets(
    'Validação: e-mail inválido não cria usuário no Auth',
    (tester) async {
      await openCadastro(tester);

      const email = 'email-invalido';

      await tester.enterText(field(0), 'Usuário E2E');
      await tester.enterText(field(1), '01/01/1990');
      await tester.enterText(field(2), email);
      await tester.enterText(field(3), 'senha123');
      await tester.enterText(field(4), 'senha123');
      await tester.enterText(field(5), '01001-000');
      await tester.enterText(field(6), 'Rua Teste');
      await tester.enterText(field(7), '100');
      await tester.enterText(field(8), 'Centro');
      await tester.enterText(field(9), 'São Paulo');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail inválido'), findsOneWidget);

      expect(
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email),
        isEmpty,
      );
    },
  );

  testWidgets(
    'Validação: senha com menos de 6 caracteres não cria usuário',
    (tester) async {
      await openCadastro(tester);

      final email = uniqueEmail();

      await tester.enterText(field(0), 'Usuário E2E');
      await tester.enterText(field(1), '01/01/1990');
      await tester.enterText(field(2), email);
      await tester.enterText(field(3), '123');
      await tester.enterText(field(4), '123');
      await tester.enterText(field(5), '01001-000');
      await tester.enterText(field(6), 'Rua Teste');
      await tester.enterText(field(7), '100');
      await tester.enterText(field(8), 'Centro');
      await tester.enterText(field(9), 'São Paulo');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );

      expect(
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email),
        isEmpty,
      );
    },
  );

  testWidgets(
    'Validação: confirmação de senha diferente não cria usuário',
    (tester) async {
      await openCadastro(tester);

      final email = uniqueEmail();

      await tester.enterText(field(0), 'Usuário E2E');
      await tester.enterText(field(1), '01/01/1990');
      await tester.enterText(field(2), email);
      await tester.enterText(field(3), 'senha123');
      await tester.enterText(field(4), 'senha456');
      await tester.enterText(field(5), '01001-000');
      await tester.enterText(field(6), 'Rua Teste');
      await tester.enterText(field(7), '100');
      await tester.enterText(field(8), 'Centro');
      await tester.enterText(field(9), 'São Paulo');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('As senhas não coincidem'),
        findsOneWidget,
      );

      expect(
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email),
        isEmpty,
      );
    },
  );

  testWidgets(
    'Validação: CEP inválido não cria usuário',
    (tester) async {
      await openCadastro(tester);

      final email = uniqueEmail();

      await tester.enterText(field(0), 'Usuário E2E');
      await tester.enterText(field(1), '01/01/1990');
      await tester.enterText(field(2), email);
      await tester.enterText(field(3), 'senha123');
      await tester.enterText(field(4), 'senha123');
      await tester.enterText(field(5), '123');
      await tester.enterText(field(6), 'Rua Teste');
      await tester.enterText(field(7), '100');
      await tester.enterText(field(8), 'Centro');
      await tester.enterText(field(9), 'São Paulo');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('CEP inválido. Formato correto: XXXXX-XXX'),
        findsOneWidget,
      );

      expect(
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email),
        isEmpty,
      );
    },
  );

  testWidgets(
    'Validação: número não numérico não cria usuário',
    (tester) async {
      await openCadastro(tester);

      final email = uniqueEmail();

      await tester.enterText(field(0), 'Usuário E2E');
      await tester.enterText(field(1), '01/01/1990');
      await tester.enterText(field(2), email);
      await tester.enterText(field(3), 'senha123');
      await tester.enterText(field(4), 'senha123');
      await tester.enterText(field(5), '01001-000');
      await tester.enterText(field(6), 'Rua Teste');
      await tester.enterText(field(7), 'ABC');
      await tester.enterText(field(8), 'Centro');
      await tester.enterText(field(9), 'São Paulo');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('O número deve ser numérico'),
        findsOneWidget,
      );

      expect(
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email),
        isEmpty,
      );
    },
  );

  testWidgets(
    'Firebase Auth: e-mail já cadastrado exibe mensagem de erro',
    (tester) async {
      await openCadastro(tester);

      // Esse usuário é criado pelo seed dos emuladores.
      const existingEmail = 'tester@sintonize.test';

      await tester.enterText(field(0), 'Outro Usuário');
      await tester.enterText(field(1), '01/01/1990');
      await tester.enterText(field(2), existingEmail);
      await tester.enterText(field(3), 'senha123');
      await tester.enterText(field(4), 'senha123');
      await tester.enterText(field(5), '01001-000');
      await tester.enterText(field(6), 'Praça da Sé');
      await tester.enterText(field(7), '100');
      await tester.enterText(field(8), 'Sé');
      await tester.enterText(field(9), 'São Paulo');

      final beforeUser = FirebaseAuth.instance.currentUser;

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      // O cadastro deve falhar no Auth e permanecer na tela.
      expect(find.text('Cadastrar'), findsOneWidget);

      expect(
        find.textContaining('Erro ao cadastrar:'),
        findsOneWidget,
      );

      // Como o teste não fez login, o usuário atual deve continuar nulo.
      expect(FirebaseAuth.instance.currentUser, same(beforeUser));
    },
  );

  testWidgets(
    'Gêneros: confirmar sem seleção mostra erro e não atualiza Firestore',
    (tester) async {
      final email = uniqueEmail();

      await openCadastro(tester);

      await fillValidRegistration(
        tester,
        email: email,
      );

      await submitRegistration(tester);

      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      final documentBefore = await currentUserDocument();

      expect(documentBefore.exists, isTrue);
      expect(
        documentBefore.data()!.containsKey('generos_favoritos'),
        isFalse,
      );

      // Nenhum Switch é acionado.
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Selecione pelo menos um gênero musical!'),
        findsOneWidget,
      );

      // Continua na tela de gêneros.
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      final documentAfter = await currentUserDocument();

      expect(documentAfter.exists, isTrue);
      expect(
        documentAfter.data()!.containsKey('generos_favoritos'),
        isFalse,
      );
    },
  );

  testWidgets(
    'Estado intermediário: cadastro válido permanece na tela de gêneros até confirmar',
    (tester) async {
      final email = uniqueEmail();

      await openCadastro(tester);

      await fillValidRegistration(
        tester,
        email: email,
      );

      await tester.tap(find.text('Cadastrar'));

      // O código da tela não possui indicador visual de loading.
      // Portanto, não testamos um CircularProgressIndicator inexistente.
      //
      // Esperamos explicitamente a conclusão das operações assíncronas
      // que precedem a navegação.
      await tester.pumpAndSettle();

      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      expect(find.text('Confirmar'), findsOneWidget);

      // O usuário ainda não pode chegar à TelaInicialScreen sem
      // confirmar pelo menos um gênero.
      expect(
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
        findsNothing,
      );
    },
  );
}
