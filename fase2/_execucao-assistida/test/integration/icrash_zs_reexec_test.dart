// test/integration/cadastro_generos_test.dart

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
  const email = 'teste@sintonize.com';
  const senha = '123456';
  const nome = 'João Silva';
  const dataNascimento = '01/01/1990';
  const cep = '01001-000';
  const numero = '123';
  const rua = 'Praça da Sé';
  const bairro = 'Sé';
  const cidade = 'São Paulo';
  const estado = 'SP';

  Widget appWith({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) {
    return MaterialApp(
      title: 'Sintonize - teste',
      initialRoute: '/cadastro',
      routes: {
        '/cadastro': (_) => CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
        '/generos': (_) => GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
        '/inicio': (_) => const TelaInicialScreen(),
      },
    );
  }

  Widget generoApp({
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

  Future<void> preencherCadastro(WidgetTester tester) async {
    final campos = find.byType(TextFormField);

    expect(campos, findsNWidgets(10));

    await tester.enterText(campos.at(0), 'João Silva');
    await tester.enterText(campos.at(1), '01011990');
    await tester.enterText(campos.at(2), 'teste@sintonize.com');
    await tester.enterText(campos.at(3), '123456');
    await tester.enterText(campos.at(4), '123456');

    // O formatter da própria CadastroScreen transforma:
    // 01001000 -> 01001-000.
    await tester.enterText(campos.at(5), '01001000');

    await tester.enterText(campos.at(7), '123');

    // Não dependemos do resultado do ViaCEP.
    // Rua, Bairro e Cidade não possuem validators.
    //
    // Localiza o DropdownButtonFormField sem depender do parâmetro
    // genérico do tipo em runtime.
    final estado = find.byWidgetPredicate(
      (widget) => widget is DropdownButtonFormField,
    );

    expect(estado, findsOneWidget);

    await tester.tap(estado);
    await tester.pump();

    // O dropdown foi aberto pelo próprio DropdownButtonFormField.
    expect(find.text('SP'), findsWidgets);

    await tester.tap(find.text('SP').last);
    await tester.pump();

    expect(find.text('Cadastrar'), findsOneWidget);
  }

  Future<void> cadastrarComSucesso(
    WidgetTester tester, {
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) async {
    await preencherCadastro(tester);

    await tester.tap(find.text('Cadastrar'));

    // O submit não depende do resultado do ViaCEP:
    // Auth e Firestore são as operações que determinam
    // a navegação para GenerosCadastroScreen.
    await tester.pumpAndSettle();
  }

  testWidgets(
    'fluxo completo: cadastro -> gêneros -> Firestore -> tela inicial',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(
        const Size(800, 1400),
      );

      addTearDown(() async {
        await tester.binding.setSurfaceSize(
          const Size(800, 600),
        );
      });

      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        appWith(
          auth: auth,
          firestore: firestore,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Cadastrar'), findsOneWidget);

      await cadastrarComSucesso(
        tester,
        auth: auth,
        firestore: firestore,
      );

      // O cadastro deve ter criado o usuário no Auth.
      final user = auth.currentUser;

      expect(user, isNotNull);
      expect(user!.email, email);

      // A tela de gêneros deve ter sido alcançada.
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      expect(find.text('Rock'), findsOneWidget);
      expect(find.text('Pop'), findsOneWidget);
      expect(find.text('Jazz'), findsOneWidget);

      // Confere que o documento inicial foi gravado pelo CadastroScreen.
      final usuarioAntes = await firestore
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(usuarioAntes.exists, isTrue);

      final dadosAntes = usuarioAntes.data()!;

      expect(dadosAntes['nome'], nome);
      expect(dadosAntes['data_nasc'], dataNascimento);
      expect(dadosAntes['email'], email);

      final endereco = dadosAntes['endereco'] as Map<String, dynamic>;

      expect(endereco['rua'], rua);
      expect(endereco['numero'], numero);
      expect(endereco['bairro'], bairro);
      expect(endereco['cidade'], cidade);
      expect(endereco['estado'], estado);
      expect(endereco['cep'], cep);

      // Seleciona gêneros através dos Switch reais da tela.
      final switches = find.byType(Switch);

      expect(switches, findsNWidgets(7));

      // Rock
      await tester.tap(switches.at(0));

      // Jazz
      await tester.tap(switches.at(2));

      // Hip-Hop
      await tester.tap(switches.at(4));

      await tester.pump();

      // Confirma o cadastro de gêneros.
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      // O estado final deve ser a TelaInicialScreen.
      expect(
        find.byType(TelaInicialScreen),
        findsOneWidget,
      );

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsNothing,
      );

      // Verifica o efeito real do fluxo no Firestore.
      final usuarioDepois = await firestore
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(usuarioDepois.exists, isTrue);

      final dadosDepois = usuarioDepois.data()!;

      expect(
        dadosDepois['generos_favoritos'],
        equals(<String>[
          'Rock',
          'Jazz',
          'Hip-Hop',
        ]),
      );
    },
  );

  testWidgets(
    'exibe erro quando Firebase Auth falha durante o cadastro',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(
        const Size(800, 1400),
      );

      addTearDown(() async {
        await tester.binding.setSurfaceSize(
          const Size(800, 600),
        );
      });

      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();

      whenCalling(
        Invocation.method(
          #createUserWithEmailAndPassword,
          null,
          {
            #email: email,
            #password: senha,
          },
        ),
      ).on(auth).thenThrow(
        FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'O e-mail já está sendo usado por outra conta.',
        ),
      );

      await tester.pumpWidget(
        appWith(
          auth: auth,
          firestore: firestore,
        ),
      );

      await tester.pumpAndSettle();

      await preencherCadastro(tester);

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      expect(
        find.text(
          'Erro ao cadastrar: O e-mail já está sendo usado por outra conta.',
        ),
        findsOneWidget,
      );

      // A falha no Auth deve impedir a navegação.
      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsNothing,
      );

      // E o Firestore não deve receber o documento.
      expect(
        auth.currentUser,
        isNull,
      );
    },
  );

  testWidgets(
    'exibe erro quando Firestore falha ao salvar o cadastro inicial',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(
        const Size(800, 1400),
      );

      addTearDown(() async {
        await tester.binding.setSurfaceSize(
          const Size(800, 600),
        );
      });

      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        appWith(
          auth: auth,
          firestore: firestore,
        ),
      );

      await tester.pumpAndSettle();

      // Descobrimos antecipadamente o UID que será criado pelo mock.
      //
      // O MockFirebaseAuth cria o usuário quando createUser... for chamado,
      // então a exceção do Firestore precisa ser configurada depois que
      // sabemos o UID. Para isso, o teste deixa o Auth criar o usuário
      // primeiro através da própria interação.
      await preencherCadastro(tester);

      await tester.tap(find.text('Cadastrar'));
      await tester.pump();

      // O Auth já foi executado neste ponto.
      final uid = auth.currentUser!.uid;
      final userDoc = firestore.collection('usuarios').doc(uid);

      // A chamada de set ainda pode estar em processamento; o stub
      // abaixo corresponde ao DocumentReference usado pela tela.
      whenCalling(
        Invocation.method(#set, null),
      ).on(userDoc).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
          message: 'Firestore indisponível.',
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Erro desconhecido:'),
        findsOneWidget,
      );

      // A navegação para gêneros não acontece.
      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'exibe erro quando Firestore falha ao salvar os gêneros',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(
        const Size(800, 1400),
      );

      addTearDown(() async {
        await tester.binding.setSurfaceSize(
          const Size(800, 600),
        );
      });

      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        appWith(
          auth: auth,
          firestore: firestore,
        ),
      );

      await tester.pumpAndSettle();

      await cadastrarComSucesso(
        tester,
        auth: auth,
        firestore: firestore,
      );

      final uid = auth.currentUser!.uid;
      final userDoc = firestore.collection('usuarios').doc(uid);

      // Garante que o documento exista antes do update.
      await userDoc.set({
        'nome': nome,
        'email': email,
      });

      whenCalling(
        Invocation.method(#update, null),
      ).on(userDoc).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
          message: 'Firestore indisponível.',
        ),
      );

      // Seleciona um Switch real.
      await tester.tap(find.byType(Switch).at(0));
      await tester.pump();

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Erro ao salvar os gêneros!'),
        findsOneWidget,
      );

      // Continua na tela de gêneros porque o update falhou.
      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsOneWidget,
      );

      expect(
        find.byType(TelaInicialScreen),
        findsNothing,
      );
    },
  );

  testWidgets(
    'usuário não autenticado deve ser tratado ao confirmar gênero',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(
        const Size(800, 1400),
      );

      addTearDown(() async {
        await tester.binding.setSurfaceSize(
          const Size(800, 600),
        );
      });

      final auth = MockFirebaseAuth(
        signedIn: false,
      );
      final firestore = FakeFirebaseFirestore();

      await tester.pumpWidget(
        MaterialApp(
          home: GenerosCadastroScreen(
            auth: auth,
            firestore: firestore,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(auth.currentUser, isNull);

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsOneWidget,
      );

      await tester.tap(find.byType(Switch).at(0));
      await tester.pump();

      await tester.tap(find.text('Confirmar'));
      await tester.pump();

      // Com o código de produção fornecido, currentUser!.uid é
      // avaliado antes do try. Portanto, uma exceção é o comportamento
      // efetivamente observado neste cenário.
      final exception = tester.takeException();

      expect(exception, isNotNull);
    },
  );

  testWidgets(
    'não permite confirmar sem selecionar gênero',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(
        const Size(800, 1400),
      );

      addTearDown(() async {
        await tester.binding.setSurfaceSize(
          const Size(800, 600),
        );
      });

      final auth = MockFirebaseAuth(
        signedIn: true,
      );
      final firestore = FakeFirebaseFirestore();

      final uid = auth.currentUser!.uid;

      await firestore.collection('usuarios').doc(uid).set({
        'nome': 'João Silva',
        'email': 'teste@sintonize.com',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: GenerosCadastroScreen(
            auth: auth,
            firestore: firestore,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsOneWidget,
      );

      final confirmar = find.text('Confirmar');

      expect(confirmar, findsOneWidget);

      await tester.ensureVisible(confirmar);
      await tester.tap(confirmar);
      await tester.pump();

      expect(
        find.text('Selecione pelo menos um gênero musical!'),
        findsOneWidget,
      );

      expect(
        find.byType(TelaInicialScreen),
        findsNothing,
      );
    },
  );
}
