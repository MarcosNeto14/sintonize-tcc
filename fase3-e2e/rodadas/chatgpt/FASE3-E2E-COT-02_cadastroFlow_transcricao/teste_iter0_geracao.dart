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

  Future<void> startApp(WidgetTester tester) async {
    await FirebaseAuth.instance.signOut();

    await tester.pumpWidget(const app.MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
  }

  Future<void> goToCadastro(WidgetTester tester) async {
    await tester.tap(find.text('Cadastro'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastrar'), findsOneWidget);
    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
  }

  Finder formField(int index) {
    return find.byType(TextFormField).at(index);
  }

  Future<void> fillValidCadastro(
    WidgetTester tester, {
    required String email,
    String nome = 'Usuario Teste',
    String dataNascimento = '01/01/1990',
    String senha = 'senha123',
    String cep = '01001000',
    String numero = '100',
  }) async {
    /*
     * Ordem dos TextFormField em CadastroScreen:
     *
     * 0 Nome
     * 1 Data de Nascimento
     * 2 E-mail
     * 3 Senha
     * 4 Confirmar Senha
     * 5 CEP
     * 6 Rua
     * 7 Número
     * 8 Bairro
     * 9 Cidade
     */

    await tester.enterText(formField(0), nome);
    await tester.enterText(formField(1), dataNascimento);
    await tester.enterText(formField(2), email);
    await tester.enterText(formField(3), senha);
    await tester.enterText(formField(4), senha);

    await tester.enterText(formField(5), cep);

    /*
     * Ao completar 8 dígitos, o formatter transforma:
     * 01001000 -> 01001-000
     *
     * e o onChanged dispara a chamada HTTP ao ViaCEP.
     */
    await _waitUntil(
      tester,
      () =>
          find.text('Rua').evaluate().isNotEmpty &&
          formField(6).evaluate().isNotEmpty,
    );

    /*
     * Aguarda o preenchimento assíncrono do ViaCEP.
     * Para 01001000 esperamos o endereço oficial correspondente.
     */
    await _waitUntil(
      tester,
      () {
        final ruaController = _textControllerFor(formField(6));
        final bairroController = _textControllerFor(formField(8));
        final cidadeController = _textControllerFor(formField(9));

        return ruaController?.text.isNotEmpty == true &&
            bairroController?.text.isNotEmpty == true &&
            cidadeController?.text.isNotEmpty == true;
      },
    );

    await tester.enterText(formField(7), numero);
  }

  Future<void> submitCadastro(WidgetTester tester) async {
    await tester.tap(find.text('Cadastrar'));

    await _waitUntil(
      tester,
      () => find.text(
        'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
      ).evaluate().isNotEmpty,
      timeout: const Duration(seconds: 20),
    );
  }

  Future<void> selectGenero(
    WidgetTester tester,
    String genero,
  ) async {
    final textFinder = find.text(genero);
    expect(textFinder, findsOneWidget);

    /*
     * O texto e o Switch estão no mesmo Row/Card.
     * Encontramos o Switch mais próximo do Card que contém o gênero.
     */
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

  Future<void> confirmGeneros(
    WidgetTester tester,
  ) async {
    await tester.tap(find.text('Confirmar'));

    await _waitUntil(
      tester,
      () => find.byType(app.TelaInicialScreen).evaluate().isNotEmpty,
      timeout: const Duration(seconds: 20),
    );
  }

  Future<void> _waitUntil(
    WidgetTester tester,
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 10),
    Duration step = const Duration(milliseconds: 100),
  }) async {
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(step);

      if (condition()) {
        return;
      }
    }

    throw TestFailure(
      'Condição não satisfeita dentro de ${timeout.inSeconds}s.',
    );
  }

  TextEditingController? _textControllerFor(Finder finder) {
    final element = finder.evaluate().firstOrNull;

    if (element == null) {
      return null;
    }

    final widget = element.widget;

    if (widget is TextFormField) {
      return widget.controller;
    }

    return null;
  }

  Future<void> expectValidationError(
    WidgetTester tester,
    String message,
  ) async {
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    expect(find.text(message), findsOneWidget);

    /*
     * A tela de cadastro continua aberta, portanto nenhuma navegação
     * para GenerosCadastroScreen ocorreu.
     */
    expect(
      find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
      findsNothing,
    );
  }

  group('Fase 3 - Cadastro e seleção de gêneros', () {
    testWidgets(
      'Fluxo E2E completo: cadastro -> gêneros -> tela inicial',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        final email =
            'e2e-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

        await fillValidCadastro(
          tester,
          email: email,
        );

        /*
         * Verifica que os dados retornados pelo ViaCEP foram usados
         * antes de disparar o cadastro.
         */
        final rua = _textControllerFor(formField(6));
        final bairro = _textControllerFor(formField(8));
        final cidade = _textControllerFor(formField(9));

        expect(rua?.text.isNotEmpty, isTrue);
        expect(bairro?.text.isNotEmpty, isTrue);
        expect(cidade?.text.isNotEmpty, isTrue);

        await submitCadastro(tester);

        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        expect(find.text('Rock'), findsOneWidget);
        expect(find.text('Pop'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await selectGenero(tester, 'Rock');
        await selectGenero(tester, 'Pop');

        await confirmGeneros(tester);

        expect(find.byType(app.TelaInicialScreen), findsOneWidget);

        /*
         * TelaInicialScreen consulta o documento do usuário e exibe
         * o nome formatado. Como o nome cadastrado foi "Usuario Teste",
         * a mensagem esperada é esta.
         */
        await _waitUntil(
          tester,
          () => find
              .text(
                'Usuario Teste, essa é a nossa recomendação de música para você!',
              )
              .evaluate()
              .isNotEmpty,
          timeout: const Duration(seconds: 20),
        );

        expect(
          find.text(
            'Usuario Teste, essa é a nossa recomendação de música para você!',
          ),
          findsOneWidget,
        );

        /*
         * Como Rock e Pop estão entre os gêneros selecionados e existem
         * músicas desses gêneros no Firestore, a recomendação deve ser
         * uma das duas músicas compatíveis.
         */
        final recomendacoes = <String>[
          'Bohemian Rhapsody',
          'Billie Jean',
        ];

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Text && recomendacoes.contains(widget.data),
          ),
          findsOneWidget,
        );

        /*
         * Confirma diretamente no Firestore o estado final produzido
         * pela interface. A leitura é apenas uma verificação do teste;
         * nenhum dado do fluxo é criado/modificado por fora da UI.
         */
        final user = FirebaseAuth.instance.currentUser;
        expect(user, isNotNull);

        final snapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .get();

        expect(snapshot.exists, isTrue);

        final data = snapshot.data()!;

        expect(data['nome'], 'Usuario Teste');
        expect(data['email'], email);

        final generos = List<String>.from(
          data['generos_favoritos'] ?? const [],
        );

        expect(generos, containsAll(<String>['Rock', 'Pop']));
      },
    );

    testWidgets(
      'Validação: nome com números não dispara Firebase',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(formField(0), 'Usuario123');

        await expectValidationError(
          tester,
          'O nome não pode conter números ou caracteres especiais',
        );

        expect(
          find.text('Cadastrar'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Validação: data de nascimento inválida',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(formField(1), '31/02/1990');

        await expectValidationError(
          tester,
          'Dia deve ser entre 01 e 28',
        );
      },
    );

    testWidgets(
      'Validação: e-mail inválido não dispara Firebase',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(
          formField(2),
          'email-invalido',
        );

        await expectValidationError(
          tester,
          'E-mail inválido',
        );
      },
    );

    testWidgets(
      'Validação: senha com menos de seis caracteres',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(
          formField(3),
          '12345',
        );
        await tester.enterText(
          formField(4),
          '12345',
        );

        await expectValidationError(
          tester,
          'A senha deve ter pelo menos 6 caracteres',
        );
      },
    );

    testWidgets(
      'Validação: senhas diferentes',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(
          formField(3),
          'senha123',
        );
        await tester.enterText(
          formField(4),
          'senha456',
        );

        await expectValidationError(
          tester,
          'As senhas não coincidem',
        );
      },
    );

    testWidgets(
      'Validação: CEP inválido',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        /*
         * O formatter não deixa chegar a um CEP válido, portanto
         * nenhuma chamada ao ViaCEP é necessária neste cenário.
         */
        await tester.enterText(
          formField(5),
          '123',
        );

        await expectValidationError(
          tester,
          'CEP inválido. Formato correto: XXXXX-XXX',
        );
      },
    );

    testWidgets(
      'Validação: número do endereço não numérico',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(
          formField(7),
          'ABC',
        );

        await expectValidationError(
          tester,
          'O número deve ser numérico',
        );
      },
    );

    testWidgets(
      'Firebase Auth: e-mail já cadastrado',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        /*
         * Este usuário existe no estado inicial do Auth Emulator.
         */
        await fillValidCadastro(
          tester,
          email: 'tester@sintonize.test',
        );

        await tester.tap(find.text('Cadastrar'));

        /*
         * O Auth Emulator deve rejeitar createUserWithEmailAndPassword.
         * O app captura FirebaseAuthException e mostra SnackBar.
         */
        await _waitUntil(
          tester,
          () => find
              .textContaining('Erro ao cadastrar:')
              .evaluate()
              .isNotEmpty,
          timeout: const Duration(seconds: 20),
        );

        expect(
          find.textContaining('Erro ao cadastrar:'),
          findsOneWidget,
        );

        /*
         * O fluxo não pode avançar para gêneros.
         */
        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsNothing,
        );

        expect(find.text('Cadastrar'), findsOneWidget);
      },
    );

    testWidgets(
      'Fluxo de gêneros: confirmar sem selecionar nenhum',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        final email =
            'sem-genero-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

        await fillValidCadastro(
          tester,
          email: email,
        );

        await submitCadastro(tester);

        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        /*
         * Nenhum Switch é alterado.
         */
        await tester.tap(find.text('Confirmar'));
        await tester.pump();

        expect(
          find.text(
            'Selecione pelo menos um gênero musical!',
          ),
          findsOneWidget,
        );

        /*
         * O Firestore não deve ser atualizado e a navegação não ocorre.
         */
        expect(
          find.byType(app.TelaInicialScreen),
          findsNothing,
        );

        expect(
          find.text('Confirmar'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Estado intermediário/final: TelaInicial carrega nome e recomendação',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        final email =
            'loading-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

        await fillValidCadastro(
          tester,
          email: email,
        );

        await submitCadastro(tester);

        await selectGenero(tester, 'Rock');
        await confirmGeneros(tester);

        expect(find.byType(app.TelaInicialScreen), findsOneWidget);

        /*
         * O código de TelaInicialScreen usa FutureBuilder para o nome.
         * O estado "Carregando..." é legítimo enquanto a leitura do
         * Firestore ainda está pendente, mas em um teste E2E real não
         * devemos exigir que a janela de timing seja capturada.
         *
         * Portanto, validamos o estado final observável depois que as
         * respostas dos emuladores chegaram.
         */
        await _waitUntil(
          tester,
          () => find
              .text(
                'Usuario Teste, essa é a nossa recomendação de música para você!',
              )
              .evaluate()
              .isNotEmpty,
          timeout: const Duration(seconds: 20),
        );

        expect(
          find.text(
            'Usuario Teste, essa é a nossa recomendação de música para você!',
          ),
          findsOneWidget,
        );

        expect(find.text('Bohemian Rhapsody'), findsOneWidget);
      },
    );
  });
}
