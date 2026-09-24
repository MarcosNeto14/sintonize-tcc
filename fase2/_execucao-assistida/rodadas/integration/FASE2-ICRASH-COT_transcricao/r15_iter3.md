Classificação das cinco falhas, uma por uma:

CEP — (A). O teste presumiu que 50000000 permaneceria sem formatação, mas o TextInputFormatter transforma o valor em 50000-000 antes da validação. O teste deve usar, por exemplo, 123, que continua inválido.
Firebase Auth — (A). O teste usou uma Invocation que não corresponde à chamada real com parâmetros nomeados email e password. A correção é especificar esses parâmetros na Invocation.
Firestore — (A). Pelo mesmo motivo, a configuração anterior não correspondeu adequadamente à chamada real de set(). O teste deve configurar a exceção na própria DocumentReference, usando a lista de argumentos da chamada.
TelaInicialScreen — (A), por limitação de testabilidade. O teste anterior presumiu que a tela poderia ser renderizada normalmente, mas ela acessa diretamente FirebaseAuth.instance/Firestore. O comportamento observável neste ambiente é a exceção [core/no-app]; isso deve ser registrado, sem inicializar Firebase artificialmente e sem fingir que a tela foi validada ponta a ponta.
Usuário não autenticado — (A). A exceção ocorre dentro do callback do botão e é reportada pelo FlutterError, não como Future rejeitada capturável por throwsA. O teste deve usar tester.takeException().

Com essas correções, segue o arquivo completo. Nenhuma asserção foi enfraquecida para mascarar um defeito da aplicação.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ===========================================================================
  // Helpers
  // ===========================================================================

  Future<void> prepararViewport(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(
      const Size(800, 1600),
    );
  }

  Future<void> restaurarViewport(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(null);
  }

  Widget buildCadastroApp({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) {
    return MaterialApp(
      home: CadastroScreen(
        auth: auth,
        firestore: firestore,
      ),
    );
  }

  Widget buildGenerosApp({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) {
    return MaterialApp(
      home: GenerosCadastroScreen(
        auth: auth,
        firestore: firestore,
      ),
    );
  }

  Finder campoCadastro(int indice) {
    return find.byType(TextFormField).at(indice);
  }

  Future<void> preencherCadastro(
    WidgetTester tester, {
    String nome = 'João',
    String dataNascimento = '01/01/2000',
    String email = 'joao@example.com',
    String senha = '123456',
    String confirmarSenha = '123456',
    String cep = '50000-000',
    String numero = '123',
  }) async {
    final campos = find.byType(TextFormField);

    expect(
      campos,
      findsNWidgets(10),
      reason:
          'A CadastroScreen real possui exatamente 10 TextFormField.',
    );

    // 0 - Nome
    await tester.enterText(
      campoCadastro(0),
      nome,
    );

    // 1 - Data de nascimento
    await tester.enterText(
      campoCadastro(1),
      dataNascimento,
    );

    // 2 - E-mail
    await tester.enterText(
      campoCadastro(2),
      email,
    );

    // 3 - Senha
    await tester.enterText(
      campoCadastro(3),
      senha,
    );

    // 4 - Confirmar senha
    await tester.enterText(
      campoCadastro(4),
      confirmarSenha,
    );

    // 5 - CEP
    await tester.enterText(
      campoCadastro(5),
      cep,
    );

    // 6 - Rua — opcional.
    await tester.enterText(
      campoCadastro(6),
      '',
    );

    // 7 - Número
    await tester.enterText(
      campoCadastro(7),
      numero,
    );

    // 8 - Bairro — opcional.
    await tester.enterText(
      campoCadastro(8),
      '',
    );

    // 9 - Cidade — opcional.
    await tester.enterText(
      campoCadastro(9),
      '',
    );
  }

  Future<void> pressionarCadastrar(WidgetTester tester) async {
    final botao = find.widgetWithText(
      ElevatedButton,
      'Cadastrar',
    );

    expect(
      botao,
      findsOneWidget,
    );

    await tester.ensureVisible(botao);
    await tester.tap(botao);
    await tester.pump();
  }

  Future<void> pressionarConfirmar(WidgetTester tester) async {
    final botao = find.widgetWithText(
      ElevatedButton,
      'Confirmar',
    );

    expect(
      botao,
      findsOneWidget,
    );

    await tester.ensureVisible(botao);
    await tester.tap(botao);
    await tester.pump();
  }

  Finder switchDoGenero(
    String genero,
  ) {
    final texto = find.text(genero);

    expect(
      texto,
      findsOneWidget,
      reason:
          'O gênero "$genero" deveria estar materializado.',
    );

    final card = find.ancestor(
      of: texto,
      matching: find.byType(Card),
    );

    expect(
      card,
      findsOneWidget,
      reason:
          'O gênero "$genero" deveria estar dentro de um Card.',
    );

    final switchFinder = find.descendant(
      of: card,
      matching: find.byType(Switch),
    );

    expect(
      switchFinder,
      findsOneWidget,
      reason:
          'O gênero "$genero" deveria possuir um Switch.',
    );

    return switchFinder;
  }

  // ===========================================================================
  // 1. Validação — Nome
  // ===========================================================================

  testWidgets(
    'não chama Firebase quando o nome contém números',
    (tester) async {
      await prepararViewport(tester);

      try {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildCadastroApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(
          tester,
          nome: 'João123',
        );

        await pressionarCadastrar(tester);
        await tester.pump();

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );

        expect(
          auth.currentUser,
          isNull,
        );
      } finally {
        await restaurarViewport(tester);
      }
    },
  );

  // ===========================================================================
  // 2. Validação — Data de nascimento
  // ===========================================================================

  testWidgets(
    'não chama Firebase quando a data de nascimento é inválida',
    (tester) async {
      await prepararViewport(tester);

      try {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildCadastroApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(
          tester,
          dataNascimento: '31/02/2000',
        );

        await pressionarCadastrar(tester);
        await tester.pump();

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );

        expect(
          auth.currentUser,
          isNull,
        );
      } finally {
        await restaurarViewport(tester);
      }
    },
  );

  // ===========================================================================
  // 3. Validação — E-mail
  // ===========================================================================

  testWidgets(
    'não chama Firebase quando o e-mail está vazio',
    (tester) async {
      await prepararViewport(tester);

      try {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildCadastroApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(
          tester,
          email: '',
        );

        await pressionarCadastrar(tester);
        await tester.pump();

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );

        expect(
          auth.currentUser,
          isNull,
        );
      } finally {
        await restaurarViewport(tester);
      }
    },
  );

  // ===========================================================================
  // 4. Validação — Senha
  // ===========================================================================

  testWidgets(
    'não chama Firebase quando a senha possui menos de 6 caracteres',
    (tester) async {
      await prepararViewport(tester);

      try {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildCadastroApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(
          tester,
          senha: '12345',
          confirmarSenha: '12345',
        );

        await pressionarCadastrar(tester);
        await tester.pump();

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );

        expect(
          auth.currentUser,
          isNull,
        );
      } finally {
        await restaurarViewport(tester);
      }
    },
  );

  // ===========================================================================
  // 5. Validação — Confirmação da senha
  // ===========================================================================

  testWidgets(
    'não chama Firebase quando as senhas não coincidem',
    (tester) async {
      await prepararViewport(tester);

      try {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildCadastroApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(
          tester,
          senha: '123456',
          confirmarSenha: '654321',
        );

        await pressionarCadastrar(tester);
        await tester.pump();

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );

        expect(
          auth.currentUser,
          isNull,
        );
      } finally {
        await restaurarViewport(tester);
      }
    },
  );

  // ===========================================================================
  // 6. Validação — CEP
  // ===========================================================================

  testWidgets(
    'não chama Firebase quando o CEP é inválido',
    (tester) async {
      await prepararViewport(tester);

      try {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildCadastroApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        /*
         * NÃO usar "50000000" aqui.
         *
         * A aplicação possui _CEPInputFormatter, que transforma:
         *
         *   50000000 -> 50000-000
         *
         * durante tester.enterText().
         *
         * "123" permanece com três dígitos e continua inválido.
         */
        await preencherCadastro(
          tester,
          cep: '123',
        );

        await pressionarCadastrar(tester);
        await tester.pump();

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );

        expect(
          auth.currentUser,
          isNull,
        );
      } finally {
        await restaurarViewport(tester);
      }
    },
  );

  // ===========================================================================
  // 7. Cadastro com sucesso
  // ===========================================================================

  testWidgets(
    'cria usuário, salva dados no Firestore e navega para GenerosCadastroScreen',
    (tester) async {
      await prepararViewport(tester);

      try {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildCadastroApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(
          tester,
          nome: 'João',
          dataNascimento: '01/01/2000',
          email: 'joao@example.com',
          senha: '123456',
          confirmarSenha: '123456',
          cep: '50000-000',
          numero: '123',
        );

        await pressionarCadastrar(tester);
        await tester.pumpAndSettle();

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        expect(
          auth.currentUser,
          isNotNull,
        );

        final uid = auth.currentUser!.uid;

        final documento = await firestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(
          documento.exists,
          isTrue,
        );

        expect(
          documento.data()?['nome'],
          equals('João'),
        );

        expect(
          documento.data()?['email'],
          equals('joao@example.com'),
        );
      } finally {
        await restaurarViewport(tester);
      }
    },
  );

  // ===========================================================================
  // 8. Erro do Firebase Auth
  // ===========================================================================

  testWidgets(
    'exibe erro quando o Firebase Auth retorna email-already-in-use',
    (tester) async {
      await prepararViewport(tester);

      try {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        /*
         * createUserWithEmailAndPassword recebe:
         *
         *   email: ...
         *   password: ...
         *
         * portanto a Invocation precisa representar os parâmetros nomeados.
         *
         * Conforme mock_exceptions/firebase_auth_mocks, parâmetros nomeados
         * omitidos do mapa são tratados como anything; aqui os dois são
         * explicitamente representados para deixar o matcher inequívoco.
         */
        whenCalling(
          Invocation.method(
            #createUserWithEmailAndPassword,
            null,
            {
              #email: anything,
              #password: anything,
            },
          ),
        ).on(auth).thenThrow(
          FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'E-mail já cadastrado',
          ),
        );

        await tester.pumpWidget(
          buildCadastroApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(tester);

        await pressionarCadastrar(tester);
        await tester.pumpAndSettle();

        expect(
          find.text('Erro ao cadastrar: E-mail já cadastrado'),
          findsOneWidget,
        );

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );

        expect(
          auth.currentUser,
          isNull,
        );
      } finally {
        await restaurarViewport(tester);
      }
    },
  );

  // ===========================================================================
  // 9. Erro do Firestore durante cadastro
  // ===========================================================================

  testWidgets(
    'exibe erro e não navega quando o Firestore falha ao criar usuário',
    (tester) async {
      await prepararViewport(tester);

      try {
        final auth = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'usuario-firestore-erro',
            email: 'joao@example.com',
          ),
          signedIn: true,
        );

        final firestore = FakeFirebaseFirestore();

        final document = firestore
            .collection('usuarios')
            .doc('usuario-firestore-erro');

        /*
         * DocumentReference.set() possui um argumento posicional:
         *
         *   set(Map<String, dynamic> data, ...)
         *
         * O matcher precisa representar esse argumento, em vez de usar
         * Invocation.method(#set, null) sem os argumentos da chamada.
         */
        whenCalling(
          Invocation.method(
            #set,
            [
              anything,
            ],
          ),
        ).on(document).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
            message: 'Firestore indisponível',
          ),
        );

        await tester.pumpWidget(
          buildCadastroApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(tester);

        await pressionarCadastrar(tester);
        await tester.pumpAndSettle();

        /*
         * O set() falhou dentro do try do _submit().
         * Portanto Navigator.push() não deve ser executado.
         */
        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );

        expect(
          find.textContaining('Erro desconhecido:'),
          findsOneWidget,
        );
      } finally {
        await restaurarViewport(tester);
      }
    },
  );

  // ===========================================================================
  // 10. Estado intermediário / loading
  // ===========================================================================

  testWidgets(
    'não exibe indicador de loading porque a aplicação não implementa loading visual',
    (tester) async {
      await prepararViewport(tester);

      try {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildCadastroApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(tester);

        /*
         * O código real não possui:
         *
         *   bool loading
         *   CircularProgressIndicator
         *   botão desabilitado durante o submit
         *
         * Portanto a ausência do indicador é o comportamento verificável.
         */
        expect(
          find.byType(CircularProgressIndicator),
          findsNothing,
        );

        await pressionarCadastrar(tester);
        await tester.pumpAndSettle();

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );
      } finally {
        await restaurarViewport(tester);
      }
    },
  );

  // ===========================================================================
  // 11. Gêneros — nenhum selecionado
  // ===========================================================================

  testWidgets(
    'exibe mensagem quando nenhum gênero é selecionado',
    (tester) async {
      await prepararViewport(tester);

      try {
        final auth = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'usuario-123',
            email: 'joao@example.com',
          ),
          signedIn: true,
        );

        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildGenerosApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        expect(
          find.text('Rock'),
          findsOneWidget,
        );

        await pressionarConfirmar(tester);

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );

        /*
         * _confirmar() não chama _salvarGeneros() quando nenhum gênero
         * está selecionado, portanto não deve criar/alterar documento.
         */
        final documento = await firestore
            .collection('usuarios')
            .doc('usuario-123')
            .get();

        expect(
          documento.exists,
          isFalse,
        );
      } finally {
        await restaurarViewport(tester);
      }
    },
  );

  // ===========================================================================
  // 12. Gêneros — sucesso no Firestore
  // ===========================================================================

  testWidgets(
    'seleciona Rock e salva generos_favoritos no Firestore',
    (tester) async {
      await prepararViewport(tester);

      try {
        final auth = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'usuario-123',
            email: 'joao@example.com',
          ),
          signedIn: true,
        );

        final firestore = FakeFirebaseFirestore();

        await firestore
            .collection('usuarios')
            .doc('usuario-123')
            .set({
          'nome': 'João',
          'email': 'joao@example.com',
        });

        await tester.pumpWidget(
          buildGenerosApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        final rockSwitch = switchDoGenero('Rock');

        await tester.tap(rockSwitch);
        await tester.pump();

        await pressionarConfirmar(tester);
        await tester.pump();

        /*
         * A atualização do FakeFirebaseFirestore deve ter ocorrido antes
         * da navegação para TelaInicialScreen.
         */
        final documento = await firestore
            .collection('usuarios')
            .doc('usuario-123')
            .get();

        expect(
          documento.exists,
          isTrue,
        );

        expect(
          documento.data()?['generos_favoritos'],
          equals(['Rock']),
        );

        /*
         * LIMITAÇÃO CONHECIDA DE TESTABILIDADE:
         *
         * GenerosCadastroScreen faz:
         *
         *   Navigator.push(
         *     context,
         *     MaterialPageRoute(
         *       builder: (_) => const TelaInicialScreen(),
         *     ),
         *   );
         *
         * TelaInicialScreen, por sua vez, acessa FirebaseAuth.instance /
         * FirebaseFirestore.instance diretamente no initState.
         *
         * Esses objetos não são os mocks/fakes injetados neste teste.
         *
         * Neste ambiente de teste puro não inicializamos Firebase.initializeApp()
         * artificialmente, pois isso não representa a aplicação real e pode
         * produzir PlatformException de channel.
         *
         * A consequência observável é a exceção [core/no-app].
         */
        final exception = tester.takeException();

        expect(
          exception,
          isNotNull,
          reason:
              'TelaInicialScreen acessa Firebase.instance diretamente e, '
              'neste ambiente de teste, a exceção [core/no-app] é o resultado '
              'observável da navegação.',
        );
      } finally {
        await restaurarViewport(tester);
      }
    },
  );

  // ===========================================================================
  // 13. Gêneros — Firestore indisponível
  // ===========================================================================

  testWidgets(
    'exibe erro e não navega quando o Firestore falha ao salvar gêneros',
    (tester) async {
      await prepararViewport(tester);

      try {
        final auth = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'usuario-erro',
            email: 'joao@example.com',
          ),
          signedIn: true,
        );

        final firestore = FakeFirebaseFirestore();

        await firestore
            .collection('usuarios')
            .doc('usuario-erro')
            .set({
          'nome': 'João',
          'email': 'joao@example.com',
        });

        final document = firestore
            .collection('usuarios')
            .doc('usuario-erro');

        /*
         * update() recebe o Map como argumento posicional.
         */
        whenCalling(
          Invocation.method(
            #update,
            [
              anything,
            ],
          ),
        ).on(document).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
            message: 'Firestore indisponível',
          ),
        );

        await tester.pumpWidget(
          buildGenerosApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        final rockSwitch = switchDoGenero('Rock');

        await tester.tap(rockSwitch);
        await tester.pump();

        await pressionarConfirmar(tester);
        await tester.pumpAndSettle();

        expect(
          find.text('Erro ao salvar os gêneros!'),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      } finally {
        await restaurarViewport(tester);
      }
    },
  );

  // ===========================================================================
  // 14. Usuário não autenticado
  // ===========================================================================

  testWidgets(
    'usuário não autenticado gera exceção ao confirmar gênero',
    (tester) async {
      await prepararViewport(tester);

      try {
        final auth = MockFirebaseAuth(
          signedIn: false,
          mockUser: null,
        );

        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildGenerosApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        final rockSwitch = switchDoGenero('Rock');

        await tester.tap(rockSwitch);
        await tester.pump();

        /*
         * IMPORTANTE:
         *
         * O código da aplicação faz:
         *
         *   final uid = widget.auth.currentUser!.uid;
         *
         * ANTES do try/catch.
         *
         * Portanto currentUser == null provoca uma exceção.
         *
         * _confirmar() também não aguarda _salvarGeneros():
         *
         *   if (...) {
         *     _salvarGeneros();
         *   }
         *
         * Por isso a exceção não é capturada como Future rejeitada por
         * expectLater(..., throwsA(...)).
         *
         * O Flutter Test Framework a disponibiliza via takeException().
         */
        await tester.tap(
          find.widgetWithText(
            ElevatedButton,
            'Confirmar',
          ),
        );

        await tester.pump();

        final exception = tester.takeException();

        expect(
          exception,
          isNotNull,
          reason:
              'currentUser!.uid é executado com currentUser == null e '
              'a exceção deve ser reportada pelo Flutter Test Framework.',
        );
      } finally {
        await restaurarViewport(tester);
      }
    },
  );

  // ===========================================================================
  // 15. Integração — Cadastro -> GenerosCadastroScreen
  // ===========================================================================

  testWidgets(
    'fluxo completo de cadastro navega para GenerosCadastroScreen',
    (tester) async {
      await prepararViewport(tester);

      try {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildCadastroApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(
          tester,
          nome: 'Marcos',
          dataNascimento: '01/01/2000',
          email: 'marcos@example.com',
          senha: '123456',
          confirmarSenha: '123456',
          cep: '50000-000',
          numero: '123',
        );

        await pressionarCadastrar(tester);
        await tester.pumpAndSettle();

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        expect(
          auth.currentUser,
          isNotNull,
        );

        final uid = auth.currentUser!.uid;

        final documento = await firestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(
          documento.exists,
          isTrue,
        );

        expect(
          documento.data()?['nome'],
          equals('Marcos'),
        );

        expect(
          documento.data()?['email'],
          equals('marcos@example.com'),
        );

        /*
         * O fluxo foi validado até a GenerosCadastroScreen.
         *
         * A continuação usando os mesmos mocks não pode ser validada
         * através da navegação real porque CadastroScreen instancia:
         *
         *   GenerosCadastroScreen()
         *
         * sem repassar auth/firestore.
         *
         * Portanto, não substituímos a navegação real por uma rota fake.
         */
      } finally {
        await restaurarViewport(tester);
      }
    },
  );
}


A correção dos matchers segue a API de mock_exceptions: para métodos com parâmetros nomeados, a Invocation pode especificar os nomes (#email, #password), enquanto DocumentReference.set()/update() pode ser configurado pelos argumentos posicionais. 
D
Dart packages
+1

Nota importante sobre o teste 12: ele agora testa o que é efetivamente testável: seleção de Rock → update() no Fake Firestore → generos_favoritos == ['Rock'] → tentativa de navegação → exceção [core/no-app] causada pela TelaInicialScreen. Não inicializei Firebase falso, justamente para não transformar uma limitação conhecida de testabilidade em um falso positivo.

D
Fontes