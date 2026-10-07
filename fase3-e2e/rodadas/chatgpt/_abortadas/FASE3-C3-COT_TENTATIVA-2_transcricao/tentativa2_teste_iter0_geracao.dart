import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart' as app;

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  tearDown(() async {
    // Os testes de sucesso criam usuários reais no Auth emulator.
    // Garantimos que o próximo testWidgets comece sem usuário autenticado.
    await FirebaseAuth.instance.signOut();
  });

  /// Inicia o aplicativo real.
  Future<void> startApp(WidgetTester tester) async {
    app.main();

    // Primeira renderização.
    await tester.pump();

    // HomeScreen possui AnimatedOpacity de 2 segundos.
    await tester.pumpAndSettle(
      const Duration(milliseconds: 2500),
    );

    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
  }

  /// Navega da HomeScreen até a CadastroScreen.
  Future<void> openCadastro(WidgetTester tester) async {
    await tester.tap(find.text('Cadastro'));

    await tester.pumpAndSettle();

    expect(find.text('Cadastrar'), findsOneWidget);
    expect(find.text('Já tem uma conta? Faça login'), findsOneWidget);
  }

  /// Localiza os TextFormFields da CadastroScreen.
  ///
  /// Ordem definida pela implementação:
  /// 0 Nome
  /// 1 Data de Nascimento
  /// 2 E-mail
  /// 3 Senha
  /// 4 Confirmar Senha
  /// 5 CEP
  /// 6 Rua
  /// 7 Número
  /// 8 Bairro
  /// 9 Cidade
  Finder registrationField(int index) {
    return find.byType(TextFormField).at(index);
  }

  /// Preenche um cadastro válido pela interface.
  ///
  /// O CEP 01001-000 dispara a chamada HTTP ao ViaCEP.
  /// Mesmo que a consulta externa falhe, Rua/Bairro/Cidade não possuem
  /// validators, portanto o fluxo de cadastro continua testável.
  Future<void> fillValidRegistration(
    WidgetTester tester, {
    required String email,
    String nome = 'Usuario E2E',
    String dataNascimento = '01/01/2000',
    String senha = 'senha123',
    String cep = '01001000',
    String numero = '123',
    String ruaFallback = 'Rua E2E',
    String bairroFallback = 'Centro',
    String cidadeFallback = 'Recife',
  }) async {
    final fields = find.byType(TextFormField);

    expect(fields, findsNWidgets(10));

    await tester.enterText(
      fields.at(0),
      nome,
    );

    await tester.enterText(
      fields.at(1),
      dataNascimento,
    );

    await tester.enterText(
      fields.at(2),
      email,
    );

    await tester.enterText(
      fields.at(3),
      senha,
    );

    await tester.enterText(
      fields.at(4),
      senha,
    );

    // O formatter transforma 01001000 em 01001-000 e dispara
    // _fetchAddressFromCEP() quando chegar a 9 caracteres.
    await tester.enterText(
      fields.at(5),
      cep,
    );

    // Damos tempo para a requisição HTTP ao ViaCEP.
    //
    // A resposta não é necessária para validar Auth/Firestore porque
    // rua, bairro e cidade não possuem validators.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 2));

    // Caso o ViaCEP não esteja disponível, os campos continuam podendo
    // ser preenchidos manualmente.
    if (tester
        .widget<TextFormField>(fields.at(6))
        .controller!
        .text
        .isEmpty) {
      await tester.enterText(
        fields.at(6),
        ruaFallback,
      );
    }

    if (tester
        .widget<TextFormField>(fields.at(8))
        .controller!
        .text
        .isEmpty) {
      await tester.enterText(
        fields.at(8),
        bairroFallback,
      );
    }

    if (tester
        .widget<TextFormField>(fields.at(9))
        .controller!
        .text
        .isEmpty) {
      await tester.enterText(
        fields.at(9),
        cidadeFallback,
      );
    }

    await tester.enterText(
      fields.at(7),
      numero,
    );

    // O estado pode ter sido preenchido pelo ViaCEP.
    // Se não foi, selecionamos SP manualmente.
    final dropdown = find.byType(DropdownButtonFormField<String>);

    expect(dropdown, findsOneWidget);

    final dropdownWidget =
        tester.widget<DropdownButtonFormField<String>>(dropdown);

    if (dropdownWidget.value == null) {
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('SP').last);
      await tester.pumpAndSettle();
    }
  }

  /// Aguarda uma tela pelo texto principal.
  Future<void> waitForText(
    WidgetTester tester,
    String text, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      if (find.text(text).evaluate().isNotEmpty) {
        return;
      }

      await tester.pump(const Duration(milliseconds: 100));
    }

    fail('Texto "$text" não apareceu dentro de $timeout.');
  }

  /// Cria um e-mail diferente para cada cenário.
  String uniqueEmail(String scenario) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return '$scenario-$timestamp@sintonize.test';
  }

  /// Navega até a GenerosCadastroScreen usando a UI real.
  Future<String> createUserAndReachGenres(
    WidgetTester tester, {
    required String scenario,
  }) async {
    final email = uniqueEmail(scenario);

    await startApp(tester);
    await openCadastro(tester);

    await fillValidRegistration(
      tester,
      email: email,
    );

    await tester.tap(find.text('Cadastrar'));

    // O fluxo é:
    // validação -> Firebase Auth -> Firestore set -> Navigator.push.
    await waitForText(
      tester,
      'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
    );

    expect(
      find.text('Confirmar'),
      findsOneWidget,
    );

    return email;
  }

  group('Cadastro e gêneros — E2E', () {
    testWidgets(
      'sucesso ponta a ponta: cadastro -> gêneros -> TelaInicial',
      (tester) async {
        final email = uniqueEmail('sucesso');

        await startApp(tester);

        // HomeScreen -> CadastroScreen.
        await openCadastro(tester);

        // Cadastro completo pela interface.
        await fillValidRegistration(
          tester,
          email: email,
          nome: 'Usuario Sucesso',
        );

        // Firebase Auth + Firestore + navegação.
        await tester.tap(find.text('Cadastrar'));

        await waitForText(
          tester,
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        );

        // Confirmamos que o Auth criou o usuário real no emulator.
        final createdUser = FirebaseAuth.instance.currentUser;

        expect(createdUser, isNotNull);
        expect(createdUser!.email, email);

        final uid = createdUser.uid;

        // Confirmamos o documento criado pelo CadastroScreen.
        final beforeGenres = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(beforeGenres.exists, isTrue);

        final beforeData = beforeGenres.data()!;

        expect(
          beforeData['nome'],
          'Usuario Sucesso',
        );

        expect(
          beforeData['email'],
          email,
        );

        expect(
          beforeData['data_nasc'],
          '01/01/2000',
        );

        expect(
          beforeData['endereco'],
          isA<Map<String, dynamic>>(),
        );

        // Ainda não selecionamos gêneros.
        expect(
          beforeData.containsKey('generos_favoritos'),
          isFalse,
        );

        // Seleciona Rock.
        final rockSwitch = find.ancestor(
          of: find.text('Rock'),
          matching: find.byType(Card),
        );

        expect(rockSwitch, findsOneWidget);

        final rockCard = rockSwitch;
        await tester.tap(
          find.descendant(
            of: rockCard,
            matching: find.byType(Switch),
          ),
        );

        // Seleciona Pop.
        final popCard = find.ancestor(
          of: find.text('Pop'),
          matching: find.byType(Card),
        );

        expect(popCard, findsOneWidget);

        await tester.tap(
          find.descendant(
            of: popCard,
            matching: find.byType(Switch),
          ),
        );

        await tester.pumpAndSettle();

        // Confirmar -> Firestore update -> TelaInicial.
        await tester.tap(find.text('Confirmar'));

        await waitForText(
          tester,
          'essa é a nossa recomendação de música para você!',
        );

        expect(
          find.byType(BottomNavigationBar),
          findsOneWidget,
        );

        // Verificação final do documento real.
        final afterGenres = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(afterGenres.exists, isTrue);

        final data = afterGenres.data()!;

        expect(
          data['generos_favoritos'],
          containsAll(<String>[
            'Rock',
            'Pop',
          ]),
        );

        expect(
          (data['generos_favoritos'] as List).length,
          2,
        );
      },
    );

    testWidgets(
      'validações locais impedem Firebase quando os campos são inválidos',
      (tester) async {
        await startApp(tester);
        await openCadastro(tester);

        final fields = find.byType(TextFormField);

        expect(fields, findsNWidgets(10));

        // Nome inválido.
        await tester.enterText(
          fields.at(0),
          'Usuario123',
        );

        // Data inválida.
        await tester.enterText(
          fields.at(1),
          '32/13/2030',
        );

        // E-mail inválido.
        await tester.enterText(
          fields.at(2),
          'email-invalido',
        );

        // Senha curta.
        await tester.enterText(
          fields.at(3),
          '123',
        );

        // Confirmação diferente.
        await tester.enterText(
          fields.at(4),
          '456',
        );

        // CEP inválido.
        await tester.enterText(
          fields.at(5),
          '123',
        );

        // Número não numérico.
        await tester.enterText(
          fields.at(7),
          'abc',
        );

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        // Cada erro deve ter sido produzido pela validação local.
        expect(
          find.text(
            'O nome não pode conter números ou caracteres especiais',
          ),
          findsOneWidget,
        );

        expect(
          find.text('Mês deve ser entre 01 e 12'),
          findsOneWidget,
        );

        expect(
          find.text('E-mail inválido'),
          findsOneWidget,
        );

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );

        expect(
          find.text('As senhas não coincidem'),
          findsOneWidget,
        );

        expect(
          find.text('CEP inválido. Formato correto: XXXXX-XXX'),
          findsOneWidget,
        );

        expect(
          find.text('O número deve ser numérico'),
          findsOneWidget,
        );

        // Continua na CadastroScreen.
        expect(
          find.text('Cadastrar'),
          findsOneWidget,
        );

        // Nenhum usuário foi autenticado/criado.
        expect(
          FirebaseAuth.instance.currentUser,
          isNull,
        );
      },
    );

    testWidgets(
      'e-mail já cadastrado mostra erro do Firebase Auth',
      (tester) async {
        await startApp(tester);
        await openCadastro(tester);

        await fillValidRegistration(
          tester,
          email: 'tester@sintonize.test',
          nome: 'Outro Tester',
        );

        await tester.tap(find.text('Cadastrar'));

        // O Auth emulator já contém esse e-mail.
        await waitForText(
          tester,
          'Erro ao cadastrar:',
        );

        expect(
          find.textContaining('Erro ao cadastrar:'),
          findsOneWidget,
        );

        // O cadastro não avança para gêneros.
        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsNothing,
        );

        expect(
          find.text('Cadastrar'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'confirmar sem gênero mostra validação e não atualiza Firestore',
      (tester) async {
        await createUserAndReachGenres(
          tester,
          scenario: 'sem-genero',
        );

        final user = FirebaseAuth.instance.currentUser;

        expect(user, isNotNull);

        final uid = user!.uid;

        final before = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(before.exists, isTrue);

        // Nenhum Switch é selecionado.
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Selecione pelo menos um gênero musical!',
          ),
          findsOneWidget,
        );

        // Continua na tela de gêneros.
        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        expect(
          find.text('Confirmar'),
          findsOneWidget,
        );

        // Como _confirmar() não chama _salvarGeneros(), o campo não
        // deve ser criado/alterado no Firestore.
        final after = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(after.exists, isTrue);

        expect(
          after.data()!.containsKey('generos_favoritos'),
          isFalse,
        );
      },
    );

    testWidgets(
      'seleção de gênero único é persistida no documento do usuário',
      (tester) async {
        await createUserAndReachGenres(
          tester,
          scenario: 'genero-unico',
        );

        final user = FirebaseAuth.instance.currentUser;

        expect(user, isNotNull);

        final uid = user!.uid;

        // Seleciona apenas Jazz.
        final jazzCard = find.ancestor(
          of: find.text('Jazz'),
          matching: find.byType(Card),
        );

        expect(jazzCard, findsOneWidget);

        await tester.tap(
          find.descendant(
            of: jazzCard,
            matching: find.byType(Switch),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Confirmar'));

        await waitForText(
          tester,
          'essa é a nossa recomendação de música para você!',
        );

        final document = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(document.exists, isTrue);

        expect(
          document.data()!['generos_favoritos'],
          ['Jazz'],
        );
      },
    );

    testWidgets(
      'estado intermediário da TelaInicial pode exibir carregamento antes dos dados',
      (tester) async {
        await createUserAndReachGenres(
          tester,
          scenario: 'loading-final',
        );

        final user = FirebaseAuth.instance.currentUser;

        expect(user, isNotNull);

        final jazzCard = find.ancestor(
          of: find.text('Jazz'),
          matching: find.byType(Card),
        );

        await tester.tap(
          find.descendant(
            of: jazzCard,
            matching: find.byType(Switch),
          ),
        );

        // Dispara a navegação para TelaInicial.
        await tester.tap(find.text('Confirmar'));

        // Fazemos somente um frame. Isso permite capturar o estado
        // intermediário caso o FutureBuilder ainda esteja aguardando.
        await tester.pump();

        final loadingVisible =
            find.text('Carregando...').evaluate().isNotEmpty;

        // Não fazemos assert obrigatório aqui porque a resposta do
        // emulator pode chegar antes deste frame. O importante é que
        // o teste aguarde o estado final corretamente.
        if (loadingVisible) {
          expect(find.text('Carregando...'), findsOneWidget);
        }

        // Condição definitiva do teste.
        await waitForText(
          tester,
          'essa é a nossa recomendação de música para você!',
        );

        expect(
          find.byType(BottomNavigationBar),
          findsOneWidget,
        );
      },
    );
  });
}
