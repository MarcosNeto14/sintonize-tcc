Classificação: (A). A causa dominante é o teste ter sido escrito contra a CadastroScreen simplificada do prompt, enquanto a implementação real possui 10 campos. Isso faz o helper de preenchimento falhar antes mesmo de executar a lógica que estava sendo testada. A correção é adaptar o teste à tela real, mantendo os cenários e sem alterar lib/.

Além disso, mantive como B o cenário do usuário não autenticado: a aplicação acessa currentUser!.uid antes do try, então a exceção não tratada é um comportamento potencialmente incorreto e o teste não será enfraquecido para escondê-lo.

O mock_exceptions também é usado conforme o mecanismo documentado para configurar exceções em MockFirebaseAuth/fakes. 
D
Dart packages
+1

import 'dart:async';

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

  Future<void> prepararViewport(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(
      const Size(800, 1600),
    );
  }

  Future<void> restaurarViewport(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(null);
  }

  Finder campo(int indice) {
    return find.byType(TextFormField).at(indice);
  }

  Future<void> preencherTodosObrigatorios(
    WidgetTester tester, {
    String nome = 'João',
    String dataNascimento = '01/01/2000',
    String email = 'joao@example.com',
    String senha = '123456',
    String confirmarSenha = '123456',
    String cep = '50000-000',
    String numero = '123',
  }) async {
    /*
     * Ordem confirmada da CadastroScreen real:
     *
     * 0 Nome
     * 1 Data de Nascimento
     * 2 E-mail
     * 3 Senha
     * 4 Confirmar Senha
     * 5 CEP
     * 6 Rua
     * 7 Numero
     * 8 Bairro
     * 9 Cidade
     *
     * Rua, Bairro e Cidade são opcionais.
     * Estado também é opcional.
     */

    final campos = find.byType(TextFormField);

    expect(
      campos,
      findsNWidgets(10),
      reason:
          'A CadastroScreen real deve conter os 10 TextFormField esperados.',
    );

    await tester.enterText(campo(0), nome);
    await tester.enterText(campo(1), dataNascimento);
    await tester.enterText(campo(2), email);
    await tester.enterText(campo(3), senha);
    await tester.enterText(campo(4), confirmarSenha);
    await tester.enterText(campo(5), cep);

    // Campo 6: Rua — opcional.
    await tester.enterText(campo(6), '');

    await tester.enterText(campo(7), numero);

    // Campo 8: Bairro — opcional.
    await tester.enterText(campo(8), '');

    // Campo 9: Cidade — opcional.
    await tester.enterText(campo(9), '');
  }

  Future<void> pressionarCadastrar(WidgetTester tester) async {
    final botao = find.widgetWithText(
      ElevatedButton,
      'Cadastrar',
    );

    expect(
      botao,
      findsOneWidget,
      reason: 'O botão Cadastrar deve existir na CadastroScreen.',
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
      reason:
          'O botão Confirmar deve existir na GenerosCadastroScreen.',
    );

    await tester.ensureVisible(botao);
    await tester.tap(botao);
    await tester.pump();
  }

  Finder switchDoGenero(
    WidgetTester tester,
    String genero,
  ) {
    final texto = find.text(genero);

    expect(
      texto,
      findsOneWidget,
      reason: 'O gênero "$genero" deveria estar materializado.',
    );

    /*
     * A implementação real usa:
     *
     * Container -> ListView.builder -> Card -> Row -> Switch
     *
     * Portanto procuramos o Switch dentro do Card que contém o texto.
     */
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

        await preencherTodosObrigatorios(
          tester,
          nome: 'João123',
        );

        await pressionarCadastrar(tester);
        await tester.pump();

        // O formulário deve bloquear o submit.
        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );

        // createUserWithEmailAndPassword não deve ter sido executado.
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

        await preencherTodosObrigatorios(
          tester,
          dataNascimento: '01/13/2000',
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

        await preencherTodosObrigatorios(
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

        await preencherTodosObrigatorios(
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
  // 5. Validação — Confirmação de senha
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

        await preencherTodosObrigatorios(
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
    'não chama Firebase quando o CEP está em formato inválido',
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

        await preencherTodosObrigatorios(
          tester,
          cep: '50000000',
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

        await preencherTodosObrigatorios(
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

        whenCalling(
          Invocation.method(
            #createUserWithEmailAndPassword,
            null,
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

        await preencherTodosObrigatorios(tester);

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

        whenCalling(
          Invocation.method(
            #set,
            null,
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

        await preencherTodosObrigatorios(tester);

        await pressionarCadastrar(tester);
        await tester.pumpAndSettle();

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
  // 10. Estado intermediário
  // ===========================================================================

  testWidgets(
    'não exibe indicador de loading porque a aplicação não implementa estado visual de loading',
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

        await preencherTodosObrigatorios(tester);

        /*
         * O código real executa a operação assíncrona, mas não possui:
         *
         * - bool loading;
         * - CircularProgressIndicator;
         * - botão desabilitado durante a operação.
         *
         * Portanto não inventamos uma asserção de loading que não existe.
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
  // 12. Gêneros — sucesso
  // ===========================================================================

  testWidgets(
    'seleciona Rock, salva generos_favoritos e navega para TelaInicialScreen',
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

        final rockSwitch = switchDoGenero(
          tester,
          'Rock',
        );

        await tester.tap(rockSwitch);
        await tester.pump();

        await pressionarConfirmar(tester);

        await tester.pumpAndSettle();

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

        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
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

        whenCalling(
          Invocation.method(
            #update,
            null,
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

        final rockSwitch = switchDoGenero(
          tester,
          'Rock',
        );

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

        final rockSwitch = switchDoGenero(
          tester,
          'Rock',
        );

        await tester.tap(rockSwitch);
        await tester.pump();

        /*
         * CLASSIFICAÇÃO: B — comportamento potencialmente incorreto da aplicação.
         *
         * GenerosCadastroScreen faz:
         *
         *   final uid = widget.auth.currentUser!.uid;
         *
         * antes do try/catch.
         *
         * Com currentUser == null, o null-check lança uma exceção.
         *
         * O comportamento esperado para uma aplicação robusta seria tratar
         * explicitamente a ausência de autenticação, impedindo o update e
         * apresentando uma mensagem apropriada.
         *
         * Não alteramos a asserção para procurar o SnackBar, porque ele não
         * é produzido pelo código atual e isso mascararia o problema.
         */

        await expectLater(
          () => pressionarConfirmar(tester),
          throwsA(anything),
        );
      } finally {
        await restaurarViewport(tester);
      }
    },
  );

  // ===========================================================================
  // 15. Integração — Cadastro -> Generos
  // ===========================================================================

  testWidgets(
    'fluxo de cadastro navega de CadastroScreen para GenerosCadastroScreen',
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

        await preencherTodosObrigatorios(
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
         * Limite conhecido do código da aplicação:
         *
         * CadastroScreen navega para:
         *
         *   GenerosCadastroScreen()
         *
         * sem passar auth/firestore.
         *
         * Portanto, a tela de gêneros criada pela navegação usa as instâncias
         * padrão FirebaseAuth.instance/FirebaseFirestore.instance.
         *
         * O teste não substitui essa realidade por uma falsa integração.
         */
      } finally {
        await restaurarViewport(tester);
      }
    },
  );
}

Uma observação importante sobre a contagem

O arquivo acima contém 15 testWidgets(), porque acrescentei explicitamente a validação de data e CEP e mantive todos os cenários solicitados, além do teste ponta a ponta. Isso é deliberado: o objetivo é cobrir o fluxo real, não preservar artificialmente a quantidade 13 do arquivo anterior.

Há ainda uma diferença importante em relação ao teste anterior: os testes de validação agora preenchem os demais campos obrigatórios. Assim, quando, por exemplo, nome = 'João123', a única causa esperada para o validate() bloquear o _submit() é a validação do nome — e não outro dos seis campos obrigatórios. Isso torna o teste muito mais forte e evita falso positivo.

A API atual do MockFirebaseAuth de fato suporta signedIn, mockUser e exceções via whenCalling(...).on(...).thenThrow(...), que é compatível com a abordagem usada acima. 
D
Dart packages
+1

D
Fontes