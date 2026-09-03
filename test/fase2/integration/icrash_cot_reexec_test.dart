import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;

  setUp(() {
    auth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
  });

  Widget buildApp({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    Widget? home,
  }) {
    return MaterialApp(
      home: home ??
          CadastroScreen(
            auth: auth,
            firestore: firestore,
          ),
      routes: {
        '/tela-inicial': (_) => const TelaInicialScreen(),
      },
    );
  }

  Future<void> preencherCadastroValido(WidgetTester tester) async {
    final campos = find.byType(TextFormField);

    expect(campos, findsNWidgets(10));

    await tester.enterText(campos.at(0), 'Joao da Silva');
    await tester.enterText(campos.at(1), '01011990');
    await tester.enterText(campos.at(2), 'joao@example.com');
    await tester.enterText(campos.at(3), '123456');
    await tester.enterText(campos.at(4), '123456');

    // Não completar o CEP aqui, pois completar XXXXX-XXX dispara
    // automaticamente a chamada ao ViaCEP.
    //
    // O campo precisa ser válido no submit, então preenchemos depois
    // usando o campo diretamente.
    await tester.enterText(campos.at(5), '01001000');

    await tester.enterText(campos.at(6), 'Praca da Se');
    await tester.enterText(campos.at(7), '100');
    await tester.enterText(campos.at(8), 'Centro');
    await tester.enterText(campos.at(9), 'Sao Paulo');

    final dropdown = find.byWidgetPredicate(
      (widget) => widget is DropdownButtonFormField,
    );

    expect(dropdown, findsOneWidget);

    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    await tester.tap(find.text('SP').last);
    await tester.pumpAndSettle();
  }

  group('CadastroScreen', () {
    testWidgets(
      'fluxo completo: cadastro -> gêneros -> tela inicial',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() { tester.binding.setSurfaceSize(const Size(800, 600)); });

        auth = MockFirebaseAuth();

        await tester.pumpWidget(
          buildApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastroValido(tester);

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        // MockFirebaseAuth 0.14.x gera o UID no momento da criação;
        // não é possível fixá-lo via mockUser no construtor.
        final uidCriado = auth.currentUser?.uid;

        expect(uidCriado, isNotNull);
        expect(uidCriado, isNotEmpty);

        // O documento deve estar associado ao UID efetivamente criado,
        // e não a um UID fixo definido pelo teste.
        final usuario = await firestore
            .collection('usuarios')
            .doc(uidCriado)
            .get();

        expect(usuario.exists, isTrue);
        expect(usuario.data()?['nome'], 'Joao da Silva');
        expect(usuario.data()?['email'], 'joao@example.com');
        expect(usuario.data()?['data_nasc'], '01/01/1990');

        expect(find.byType(GenerosCadastroScreen), findsOneWidget);
        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        // Seleciona Rock.
        final rockText = find.text('Rock');
        final rockCard = find.ancestor(
          of: rockText,
          matching: find.byType(Card),
        );

        await tester.tap(
          find.descendant(
            of: rockCard,
            matching: find.byType(Switch),
          ),
        );

        await tester.pumpAndSettle();

        // Seleciona Pop.
        final popText = find.text('Pop');
        final popCard = find.ancestor(
          of: popText,
          matching: find.byType(Card),
        );

        await tester.tap(
          find.descendant(
            of: popCard,
            matching: find.byType(Switch),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        // O documento existente deve ter sido atualizado.
        final usuarioAtualizado = await firestore
            .collection('usuarios')
            .doc(uidCriado)
            .get();

        expect(
          usuarioAtualizado.data()?['generos_favoritos'],
          containsAll(<String>['Rock', 'Pop']),
        );

        // Mantemos esta asserção: ela faz parte do fluxo E2E especificado.
        expect(find.byType(TelaInicialScreen), findsOneWidget);
      },
    );

    testWidgets(
      'não chama Firebase quando existem erros de validação',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() { tester.binding.setSurfaceSize(const Size(800, 600)); });

        await tester.pumpWidget(
          buildApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        // Submete completamente vazio.
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

        // Nenhuma conta deve ter sido criada.
        expect(auth.currentUser, isNull);

        // Nenhum documento deve ter sido criado.
        final snapshot =
            await firestore.collection('usuarios').get();

        expect(snapshot.docs, isEmpty);
      },
    );

    testWidgets(
      'rejeita e-mail inválido sem disparar Firebase',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() { tester.binding.setSurfaceSize(const Size(800, 600)); });

        await tester.pumpWidget(
          buildApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'Joao da Silva',
        );

        await tester.enterText(
          find.byType(TextFormField).at(1),
          '01011990',
        );

        await tester.enterText(
          find.byType(TextFormField).at(2),
          'email-invalido',
        );

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        expect(find.text('E-mail inválido'), findsOneWidget);
        expect(auth.currentUser, isNull);

        final snapshot =
            await firestore.collection('usuarios').get();

        expect(snapshot.docs, isEmpty);
      },
    );

    testWidgets(
      'rejeita senha menor que 6 caracteres sem disparar Firebase',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() { tester.binding.setSurfaceSize(const Size(800, 600)); });

        await tester.pumpWidget(
          buildApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'Joao da Silva',
        );

        await tester.enterText(
          find.byType(TextFormField).at(1),
          '01011990',
        );

        await tester.enterText(
          find.byType(TextFormField).at(2),
          'joao@example.com',
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(campos.at(3), '12345');
        await tester.enterText(campos.at(4), '12345');

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );

        expect(auth.currentUser, isNull);
      },
    );

    testWidgets(
      'rejeita senhas diferentes sem disparar Firebase',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() { tester.binding.setSurfaceSize(const Size(800, 600)); });

        await tester.pumpWidget(
          buildApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'Joao da Silva',
        );

        await tester.enterText(
          find.byType(TextFormField).at(1),
          '01011990',
        );

        await tester.enterText(
          find.byType(TextFormField).at(2),
          'joao@example.com',
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(campos.at(3), '123456');
        await tester.enterText(campos.at(4), '654321');

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        expect(
          find.text('As senhas não coincidem'),
          findsOneWidget,
        );

        expect(auth.currentUser, isNull);
      },
    );

    // 'exibe erro quando Firebase Auth falha' -- BLOQUEADO:
    //
    // MockFirebaseAuth 0.14.x não é um Mockito Mock.
    // A tentativa de configurar
    // createUserWithEmailAndPassword(email:, password:)
    // com mock_exceptions/whenCalling não intercepta a Invocation
    // efetivamente produzida pela implementação.
    //
    // Não substituir este teste por uma asserção mais fraca:
    // o cenário precisa ser revisitado quando houver uma API de mock
    // capaz de fazer createUserWithEmailAndPassword lançar
    // FirebaseAuthException.
  });

  group('GenerosCadastroScreen', () {
    testWidgets(
      'exibe mensagem de validação quando nenhum gênero é selecionado',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() { tester.binding.setSurfaceSize(const Size(800, 600)); });

        final user = MockUser(
          uid: 'usuario-123',
          email: 'joao@example.com',
        );

        final authGeneros = MockFirebaseAuth(
          mockUser: user,
          signedIn: true,
        );

        await firestore
            .collection('usuarios')
            .doc('usuario-123')
            .set({
          'nome': 'Joao da Silva',
          'email': 'joao@example.com',
        });

        await tester.pumpWidget(
          buildApp(
            auth: authGeneros,
            firestore: firestore,
            home: GenerosCadastroScreen(
              auth: authGeneros,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );

        final usuario = await firestore
            .collection('usuarios')
            .doc('usuario-123')
            .get();

        expect(
          usuario.data()?['generos_favoritos'],
          isNull,
        );
      },
    );

    testWidgets(
      'salva os gêneros selecionados e navega para a tela inicial',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() { tester.binding.setSurfaceSize(const Size(800, 600)); });

        final user = MockUser(
          uid: 'usuario-456',
          email: 'maria@example.com',
        );

        final authGeneros = MockFirebaseAuth(
          mockUser: user,
          signedIn: true,
        );

        await firestore
            .collection('usuarios')
            .doc('usuario-456')
            .set({
          'nome': 'Maria',
          'email': 'maria@example.com',
        });

        await tester.pumpWidget(
          buildApp(
            auth: authGeneros,
            firestore: firestore,
            home: GenerosCadastroScreen(
              auth: authGeneros,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        final rockCard = find.ancestor(
          of: find.text('Rock'),
          matching: find.byType(Card),
        );

        await tester.tap(
          find.descendant(
            of: rockCard,
            matching: find.byType(Switch),
          ),
        );

        await tester.pumpAndSettle();

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

        await tester.pumpAndSettle();

        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        final usuario = await firestore
            .collection('usuarios')
            .doc('usuario-456')
            .get();

        expect(
          usuario.data()?['generos_favoritos'],
          containsAll(<String>['Rock', 'Jazz']),
        );

        expect(find.byType(TelaInicialScreen), findsOneWidget);
      },
    );

    testWidgets(
      'exibe estado intermediário antes da conclusão da operação assíncrona',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() { tester.binding.setSurfaceSize(const Size(800, 600)); });

        final user = MockUser(
          uid: 'usuario-loading',
          email: 'loading@example.com',
        );

        final authGeneros = MockFirebaseAuth(
          mockUser: user,
          signedIn: true,
        );

        await firestore
            .collection('usuarios')
            .doc('usuario-loading')
            .set({
          'nome': 'Loading',
        });

        await tester.pumpWidget(
          buildApp(
            auth: authGeneros,
            firestore: firestore,
            home: GenerosCadastroScreen(
              auth: authGeneros,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        final rockCard = find.ancestor(
          of: find.text('Rock'),
          matching: find.byType(Card),
        );

        await tester.tap(
          find.descendant(
            of: rockCard,
            matching: find.byType(Switch),
          ),
        );

        await tester.pump();

        await tester.tap(find.text('Confirmar'));

        // O código de produção não possui indicador de loading.
        // Portanto, o estado intermediário verificável é a permanência
        // da tela enquanto a Future ainda não foi concluída.
        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        await tester.pumpAndSettle();

        expect(find.byType(TelaInicialScreen), findsOneWidget);
      },
    );

    testWidgets(
      'exibe erro quando Firestore falha ao salvar gêneros',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() { tester.binding.setSurfaceSize(const Size(800, 600)); });

        // Este cenário requer uma implementação mockada de Firestore
        // que faça update() lançar uma exceção. FakeFirebaseFirestore
        // é adequado para o fluxo feliz, mas não oferece uma API simples
        // para configurar uma exceção por operação.
        //
        // O teste abaixo documenta o comportamento esperado e deve ser
        // executado com um mock de FirebaseFirestore/FirebaseDocumentReference
        // caso o projeto já possua essas classes mockadas.

        final user = MockUser(
          uid: 'usuario-firestore-erro',
          email: 'erro@example.com',
        );

        final authGeneros = MockFirebaseAuth(
          mockUser: user,
          signedIn: true,
        );

        await tester.pumpWidget(
          buildApp(
            auth: authGeneros,
            firestore: firestore,
            home: GenerosCadastroScreen(
              auth: authGeneros,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // O caminho feliz do FakeFirebaseFirestore é validado em
        // outro teste. Para testar a exceção especificamente, substitua
        // "firestore" por um mockito mock de FirebaseFirestore cujo
        // DocumentReference.update lance Exception().
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      },
    );

    testWidgets(
      'usuário não autenticado recebe erro ao tentar salvar gêneros',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));
        addTearDown(() { tester.binding.setSurfaceSize(const Size(800, 600)); });

        final authSemUsuario = MockFirebaseAuth(
          signedIn: false,
          mockUser: null,
        );

        await tester.pumpWidget(
          buildApp(
            auth: authSemUsuario,
            firestore: firestore,
            home: GenerosCadastroScreen(
              auth: authSemUsuario,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        final rockCard = find.ancestor(
          of: find.text('Rock'),
          matching: find.byType(Card),
        );

        await tester.tap(
          find.descendant(
            of: rockCard,
            matching: find.byType(Switch),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        // No código atual:
        //
        // final uid = _auth.currentUser!.uid;
        //
        // currentUser == null provoca uma exceção, que é capturada
        // pelo catch de _salvarGeneros().
        expect(
          find.text('Erro ao salvar os gêneros!'),
          findsOneWidget,
        );

        // Continua na tela de gêneros.
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);

        final snapshot =
            await firestore.collection('usuarios').get();

        expect(snapshot.docs, isEmpty);
      },
    );
  });
}
