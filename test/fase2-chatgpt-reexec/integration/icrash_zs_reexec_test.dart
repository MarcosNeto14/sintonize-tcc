import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de cadastro → gêneros', () {
    testWidgets(
      'cadastra usuário, navega para gêneros, salva gêneros e chega à tela inicial',
      (tester) async {
        final auth = MockFirebaseAuth(signedIn: false);
        final firestore = FakeFirebaseFirestore();

        await _pumpCadastro(
          tester,
          auth: auth,
          firestore: firestore,
        );

        await _preencherCadastro(tester);

        // O Dropdown está dentro do SingleChildScrollView.
        await _selecionarEstado(tester, 'PE');

        await _tapCadastro(tester);

        expect(auth.currentUser, isNotNull);
        expect(auth.currentUser!.uid, isNotEmpty);

        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsOneWidget,
        );

        final uid = auth.currentUser!.uid;

        final cadastro = await firestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(cadastro.exists, isTrue);
        expect(cadastro.data()?['nome'], 'Maria Silva');
        expect(cadastro.data()?['data_nasc'], '01/01/1990');
        expect(cadastro.data()?['email'], 'teste@example.com');

        final endereco =
            cadastro.data()?['endereco'] as Map<String, dynamic>;

        expect(endereco['rua'], 'Rua Teste');
        expect(endereco['numero'], '123');
        expect(endereco['bairro'], 'Centro');
        expect(endereco['cidade'], 'Recife');
        expect(endereco['estado'], 'PE');
        expect(endereco['cep'], '50000-000');

        // Seleciona Rock.
        await _selecionarGenero(tester, 'Rock');

        // Seleciona Jazz.
        await _selecionarGenero(tester, 'Jazz');

        await _tapConfirmar(tester);

        final documentoFinal = await firestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(
          documentoFinal.data()?['generos_favoritos'],
          containsAll(<String>['Rock', 'Jazz']),
        );

        expect(
          documentoFinal.data()?['generos_favoritos'],
          hasLength(2),
        );

        // A GenerosCadastroScreen deve ter sido substituída pela
        // TelaInicialScreen.
        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'exibe erro quando Firebase Auth falha e não navega para gêneros',
      (tester) async {
        final auth = MockFirebaseAuth(signedIn: false);
        final firestore = FakeFirebaseFirestore();

        whenCalling(
          Invocation.method(
            #createUserWithEmailAndPassword,
            null,
            {
              #email: 'teste@example.com',
              #password: 'senha123',
            },
          ),
        ).on(auth).thenThrow(
          FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'E-mail já está em uso.',
          ),
        );

        await _pumpCadastro(
          tester,
          auth: auth,
          firestore: firestore,
        );

        await _preencherCadastro(tester);
        await _selecionarEstado(tester, 'PE');
        await _tapCadastro(tester);

        await tester.pumpAndSettle();

        expect(
          find.text('Erro ao cadastrar: E-mail já está em uso.'),
          findsOneWidget,
        );

        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsNothing,
        );

        expect(auth.currentUser, isNull);
      },
    );

    testWidgets(
      'exibe erro quando Firestore falha ao salvar os gêneros',
      (tester) async {
        final auth = MockFirebaseAuth(signedIn: false);
        final firestore = FakeFirebaseFirestore();

        await _pumpCadastro(
          tester,
          auth: auth,
          firestore: firestore,
        );

        await _preencherCadastro(tester);
        await _selecionarEstado(tester, 'PE');
        await _tapCadastro(tester);

        await tester.pumpAndSettle();

        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsOneWidget,
        );

        final uid = auth.currentUser!.uid;
        final userDoc = firestore.collection('usuarios').doc(uid);

        // O documento foi criado pelo cadastro. Agora interceptamos
        // exatamente o update() executado pela GenerosCadastroScreen.
        whenCalling(
          Invocation.method(
            #update,
            null,
            {
              #data: {
                'generos_favoritos': ['Rock'],
              },
            },
          ),
        ).on(userDoc).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
            message: 'Firestore indisponível',
          ),
        );

        await _selecionarGenero(tester, 'Rock');
        await _tapConfirmar(tester);

        await tester.pumpAndSettle();

        expect(
          find.text('Erro ao salvar os gêneros!'),
          findsOneWidget,
        );

        // Como update() falhou, a navegação não deve ocorrer.
        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'impede confirmação quando nenhum gênero foi selecionado',
      (tester) async {
        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
            isAnonymous: false,
            uid: 'authenticated-user',
            email: 'teste@example.com',
          ),
        );

        final firestore = FakeFirebaseFirestore();

        await firestore
            .collection('usuarios')
            .doc('authenticated-user')
            .set({
          'nome': 'Usuário Teste',
          'email': 'teste@example.com',
        });

        await _pumpGeneros(
          tester,
          auth: auth,
          firestore: firestore,
        );

        await _tapConfirmar(tester);

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );

        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'exibe erro quando usuário não está autenticado',
      (tester) async {
        final auth = MockFirebaseAuth(signedIn: false);
        final firestore = FakeFirebaseFirestore();

        await _pumpGeneros(
          tester,
          auth: auth,
          firestore: firestore,
        );

        expect(auth.currentUser, isNull);

        await _selecionarGenero(tester, 'Rock');
        await _tapConfirmar(tester);

        await tester.pumpAndSettle();

        // _salvarGeneros() faz:
        //
        // final uid = _auth.currentUser!.uid;
        //
        // Como currentUser == null, ocorre uma exceção que é capturada
        // pelo catch da tela.
        expect(
          find.text('Erro ao salvar os gêneros!'),
          findsOneWidget,
        );

        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsOneWidget,
        );
      },
    );
  });
}

/// -------------------------------------------------------------------------
/// Montagem das telas
/// -------------------------------------------------------------------------

Future<void> _pumpCadastro(
  WidgetTester tester, {
  required MockFirebaseAuth auth,
  required FakeFirebaseFirestore firestore,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CadastroScreen(
        auth: auth,
        firestore: firestore,
      ),
      routes: {
        '/cadastro': (_) => CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
        '/generos': (_) => GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
      },
    ),
  );

  await tester.pumpAndSettle();
}

Future<void> _pumpGeneros(
  WidgetTester tester, {
  required MockFirebaseAuth auth,
  required FakeFirebaseFirestore firestore,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GenerosCadastroScreen(
        auth: auth,
        firestore: firestore,
      ),
      routes: {
        '/cadastro': (_) => CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
        '/generos': (_) => GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
      },
    ),
  );

  await tester.pumpAndSettle();
}

/// -------------------------------------------------------------------------
/// CadastroScreen
/// -------------------------------------------------------------------------

Future<void> _preencherCadastro(WidgetTester tester) async {
  final fields = find.byType(TextFormField);

  expect(fields, findsNWidgets(10));

  await tester.enterText(
    fields.at(0),
    'Maria Silva',
  );

  await tester.enterText(
    fields.at(1),
    '01011990',
  );

  await tester.enterText(
    fields.at(2),
    'teste@example.com',
  );

  await tester.enterText(
    fields.at(3),
    'senha123',
  );

  await tester.enterText(
    fields.at(4),
    'senha123',
  );

  // O formatter transforma automaticamente:
  // 50000000 → 50000-000
  //
  // O onChanged da tela dispara uma tentativa de chamada ao ViaCEP.
  // Em flutter_test essa requisição não vai para a internet.
  await tester.enterText(
    fields.at(5),
    '50000000',
  );

  await tester.enterText(
    fields.at(6),
    'Rua Teste',
  );

  await tester.enterText(
    fields.at(7),
    '123',
  );

  await tester.enterText(
    fields.at(8),
    'Centro',
  );

  await tester.enterText(
    fields.at(9),
    'Recife',
  );
}

Future<void> _selecionarEstado(
  WidgetTester tester,
  String estado,
) async {
  final dropdown = find.byType(
    DropdownButtonFormField<String>,
  );

  expect(dropdown, findsOneWidget);

  // Corrige o problema observado:
  // o dropdown está abaixo da viewport de 600px.
  await tester.ensureVisible(dropdown);
  await tester.pumpAndSettle();

  await tester.tap(
    dropdown,
    warnIfMissed: true,
  );

  await tester.pumpAndSettle();

  // Depois que o dropdown abre, o DropdownMenuItem passa a fazer parte
  // da árvore visível.
  final option = find.text(estado);

  expect(option, findsWidgets);

  await tester.tap(option.last);
  await tester.pumpAndSettle();
}

Future<void> _tapCadastro(
  WidgetTester tester,
) async {
  final button = find.widgetWithText(
    ElevatedButton,
    'Cadastrar',
  );

  expect(button, findsOneWidget);

  // O botão também está abaixo da viewport em uma tela 800x600.
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();

  await tester.tap(button);
  await tester.pumpAndSettle();
}

/// -------------------------------------------------------------------------
/// GenerosCadastroScreen
/// -------------------------------------------------------------------------

Future<void> _selecionarGenero(
  WidgetTester tester,
  String genero,
) async {
  final text = find.text(genero);

  expect(text, findsOneWidget);

  final card = find.ancestor(
    of: text,
    matching: find.byType(Card),
  );

  expect(card, findsOneWidget);

  final switchFinder = find.descendant(
    of: card,
    matching: find.byType(Switch),
  );

  expect(switchFinder, findsOneWidget);

  // Garante que o Switch esteja dentro da viewport antes do tap.
  await tester.ensureVisible(switchFinder);
  await tester.pumpAndSettle();

  await tester.tap(switchFinder);
  await tester.pumpAndSettle();

  final switchWidget =
      tester.widget<Switch>(switchFinder);

  expect(switchWidget.value, isTrue);
}

Future<void> _tapConfirmar(
  WidgetTester tester,
) async {
  final button = find.widgetWithText(
    ElevatedButton,
    'Confirmar',
  );

  expect(button, findsOneWidget);

  // O botão fica abaixo da área visível da SingleChildScrollView.
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();

  await tester.tap(button);
  await tester.pumpAndSettle();
}
