import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';

Future<void> tapVisible(
  WidgetTester tester,
  Finder finder,
) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}

Future<void> enterTextVisible(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.enterText(finder, text);
}


void main() {
  group('CadastroScreen - fluxo de cadastro', () {
    testWidgets(
      'fluxo de sucesso: valida formulário, cria usuário, salva dados e navega para gêneros',
      (tester) async {
        final auth = MockFirebaseAuth(
          signedIn: false,
          mockUser: MockUser(
            uid: 'usuario-123',
            email: 'ana@example.com',
          ),
        );

        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(campos.at(0), 'Ana');
        await tester.enterText(campos.at(1), 'ana@example.com');
        await tester.enterText(campos.at(2), '123456');
        await tester.enterText(campos.at(3), '123456');

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        // O Auth mock deve ter criado/autenticado o usuário.
        await tapVisible(
  tester,
  find.widgetWithText(ElevatedButton, 'Cadastrar'),
);

await tester.pumpAndSettle();

expect(auth.currentUser, isNotNull);
        expect(auth.currentUser!.uid, isNotEmpty);

        // O documento criado pelo CadastroScreen deve existir.
        final snapshot = await firestore
            .collection('usuarios')
            .doc(auth.currentUser!.uid)
            .get();

        expect(snapshot.exists, isTrue);
        expect(snapshot.data()?['nome'], 'Ana');
        expect(snapshot.data()?['email'], 'ana@example.com');

        // A tela seguinte foi aberta.
        expect(find.text('Rock'), findsOneWidget);
        expect(find.text('Pop'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);
      },
    );

testWidgets(
  'não cadastra quando o nome está vazio',
  (tester) async {
    final auth = MockFirebaseAuth();
    final firestore = FakeFirebaseFirestore();

    await tester.pumpWidget(
      MaterialApp(
        home: CadastroScreen(
          auth: auth,
          firestore: firestore,
        ),
      ),
    );

    final campos = find.byType(TextFormField);

    await enterTextVisible(
      tester,
      campos.at(1),
      'ana@example.com',
    );
    await enterTextVisible(
      tester,
      campos.at(2),
      '123456',
    );
    await enterTextVisible(
      tester,
      campos.at(3),
      '123456',
    );

    await tapVisible(
      tester,
      find.widgetWithText(ElevatedButton, 'Cadastrar'),
    );

    expect(
      find.text('O nome é obrigatório'),
      findsOneWidget,
    );

    expect(auth.currentUser, isNull);
    expect(firestore.dump(), '{}');
  },
);

    testWidgets(
      'não cadastra quando o e-mail está vazio',
      (tester) async {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(campos.at(0), 'Ana');
        await tester.enterText(campos.at(2), '123456');
        await tester.enterText(campos.at(3), '123456');

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(find.text('O e-mail é obrigatório'), findsOneWidget);
        expect(auth.currentUser, isNull);
        expect(firestore.dump(), '{}');
      },
    );

    testWidgets(
      'não cadastra quando a senha tem menos de 6 caracteres',
      (tester) async {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(campos.at(0), 'Ana');
        await tester.enterText(campos.at(1), 'ana@example.com');
        await tester.enterText(campos.at(2), '12345');
        await tester.enterText(campos.at(3), '12345');

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );
        expect(auth.currentUser, isNull);
        expect(firestore.dump(), '{}');
      },
    );

    testWidgets(
      'não cadastra quando as senhas não coincidem',
      (tester) async {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(campos.at(0), 'Ana');
        await tester.enterText(campos.at(1), 'ana@example.com');
        await tester.enterText(campos.at(2), '123456');
        await tester.enterText(campos.at(3), '654321');

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(find.text('As senhas não coincidem'), findsOneWidget);
        expect(auth.currentUser, isNull);
        expect(firestore.dump(), '{}');
      },
    );

    testWidgets(
      'mostra erro quando o Firebase Auth falha',
      (tester) async {
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
            message: 'O e-mail já está em uso',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        final campos = find.byType(TextFormField);


await enterTextVisible(tester, campos.at(0), 'Ana');
await enterTextVisible(tester, campos.at(1), 'ana@example.com');
await enterTextVisible(tester, campos.at(2), '123456');
await enterTextVisible(tester, campos.at(3), '123456');

final cadastrarButton = find.widgetWithText(
  ElevatedButton,
  'Cadastrar',
);

await tapVisible(tester, cadastrarButton);

        expect(
          find.text('Erro ao cadastrar: O e-mail já está em uso'),
          findsOneWidget,
        );

        expect(firestore.dump(), '{}');
      },
    );

    testWidgets(
      'mostra erro desconhecido quando o Firestore falha ao salvar o usuário',
      (tester) async {
        final auth = MockFirebaseAuth(
          signedIn: false,
          mockUser: MockUser(
            uid: 'usuario-erro',
            email: 'ana@example.com',
          ),
        );

        final firestore = FakeFirebaseFirestore();

        final doc = firestore
            .collection('usuarios')
            .doc('usuario-erro');

        // O fake permite simular exceção diretamente no DocumentReference.
        whenCalling(
          Invocation.method(#set, null),
        ).on(doc).thenThrow(
          Exception('Firestore indisponível'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        final campos = find.byType(TextFormField);


await enterTextVisible(tester, campos.at(0), 'Ana');
await enterTextVisible(tester, campos.at(1), 'ana@example.com');
await enterTextVisible(tester, campos.at(2), '123456');
await enterTextVisible(tester, campos.at(3), '123456');

final cadastrarButton = find.widgetWithText(
  ElevatedButton,
  'Cadastrar',
);

await tapVisible(tester, cadastrarButton);

        expect(
          find.textContaining('Erro desconhecido:'),
          findsOneWidget,
        );

        expect(find.text('Rock'), findsNothing);
      },
    );

    testWidgets(
      'não exibe loading porque CadastroScreen não implementa estado de carregamento',
      (tester) async {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Carregando...'), findsNothing);
      },
    );
  });

  group('GenerosCadastroScreen - seleção e salvamento', () {
    testWidgets(
      'não salva quando nenhum gênero foi selecionado',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
          email: 'ana@example.com',
        );

        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: user,
        );

        final firestore = FakeFirebaseFirestore();

        // Criamos o documento porque update() exige que ele exista.
        await firestore
            .collection('usuarios')
            .doc(user.uid)
            .set({
          'nome': 'Ana',
          'email': 'ana@example.com',
        });

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await tester.tap(find.text('Confirmar'));
        await tester.pump();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );

        final snapshot = await firestore
            .collection('usuarios')
            .doc(user.uid)
            .get();

        expect(snapshot.data()?['generos_favoritos'], isNull);
      },
    );

    testWidgets(
      'seleciona gênero e salva corretamente no Firestore',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
          email: 'ana@example.com',
        );

        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: user,
        );

        final firestore = FakeFirebaseFirestore();

        await firestore
            .collection('usuarios')
            .doc(user.uid)
            .set({
          'nome': 'Ana',
          'email': 'ana@example.com',
        });

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
            routes: {
              '/inicio': (_) => const TelaInicialScreen(),
            },
          ),
        );

        final rockSwitch = find.widgetWithText(
          SwitchListTile,
          'Rock',
        );

        expect(rockSwitch, findsOneWidget);

        await tester.tap(rockSwitch);
        await tester.pump();

        final switchWidget = tester.widget<SwitchListTile>(rockSwitch);
        expect(switchWidget.value, isTrue);

        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        final snapshot = await firestore
            .collection('usuarios')
            .doc(user.uid)
            .get();

        expect(
          snapshot.data()?['generos_favoritos'],
          contains('Rock'),
        );

        // O código usa MaterialPageRoute diretamente, portanto a rota
        // nomeada acima não é responsável por esta navegação.
        expect(find.byType(TelaInicialScreen), findsOneWidget);
      },
    );

    testWidgets(
      'salva múltiplos gêneros selecionados',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
          email: 'ana@example.com',
        );

        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: user,
        );

        final firestore = FakeFirebaseFirestore();

        await firestore
            .collection('usuarios')
            .doc(user.uid)
            .set({
          'nome': 'Ana',
          'email': 'ana@example.com',
        });

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
            routes: {
              '/inicio': (_) => const TelaInicialScreen(),
            },
          ),
        );

        await tester.tap(
          find.widgetWithText(SwitchListTile, 'Rock'),
        );
        await tester.tap(
          find.widgetWithText(SwitchListTile, 'Jazz'),
        );
        await tester.pump();

        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        final snapshot = await firestore
            .collection('usuarios')
            .doc(user.uid)
            .get();

        final generos =
            List<String>.from(snapshot.data()?['generos_favoritos'] ?? []);

        expect(generos, containsAll(<String>['Rock', 'Jazz']));
        expect(generos.length, 2);
      },
    );

    testWidgets(
      'mostra erro quando o Firestore falha ao salvar os gêneros',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
          email: 'ana@example.com',
        );

        final auth = MockFirebaseAuth(
          signedIn: true,
          mockUser: user,
        );

        final firestore = FakeFirebaseFirestore();

        await firestore
            .collection('usuarios')
            .doc(user.uid)
            .set({
          'nome': 'Ana',
          'email': 'ana@example.com',
        });

        final doc = firestore
            .collection('usuarios')
            .doc(user.uid);

        whenCalling(
          Invocation.method(#update, null),
        ).on(doc).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
            message: 'Firestore indisponível',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await tester.tap(
          find.widgetWithText(SwitchListTile, 'Rock'),
        );
        await tester.pump();

        await tester.tap(find.text('Confirmar'));
        await tester.pump();

        expect(
          find.text('Erro ao salvar os gêneros!'),
          findsOneWidget,
        );

        // Como o update falhou, não deve haver navegação.
        expect(find.text('Rock'), findsOneWidget);
      },
    );

    testWidgets(
      'usuário não autenticado causa erro ao confirmar',
      (tester) async {
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

        await tester.tap(
          find.widgetWithText(SwitchListTile, 'Rock'),
        );
        await tester.pump();

        // O código acessa currentUser!.uid ANTES do try/catch.
        //
        // Consequentemente, currentUser == null produz uma exceção de
        // null-check em vez de mostrar o SnackBar de erro do Firestore.
        //
        // O pump abaixo permite que o callback assíncrono seja processado.
        await tester.tap(find.text('Confirmar'));
        await tester.pump();

        expect(auth.currentUser, isNull);
        expect(find.text('Erro ao salvar os gêneros!'), findsNothing);
      },
    );
  });

  group('Fluxo ponta a ponta - limitação da implementação atual', () {
    testWidgets(
      'cadastro navega para GenerosCadastroScreen, mas as dependências '
      'injetadas não são propagadas para a segunda tela',
      (tester) async {
        final auth = MockFirebaseAuth(
          signedIn: false,
          mockUser: MockUser(
            uid: 'usuario-123',
            email: 'ana@example.com',
          ),
        );

        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          MaterialApp(
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
              '/inicio': (_) => const TelaInicialScreen(),
            },
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(campos.at(0), 'Ana');
        await tester.enterText(campos.at(1), 'ana@example.com');
        await tester.enterText(campos.at(2), '123456');
        await tester.enterText(campos.at(3), '123456');

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        expect(find.text('Rock'), findsOneWidget);

        final usuario = await firestore
            .collection('usuarios')
            .doc(auth.currentUser!.uid)
            .get();

        expect(usuario.exists, isTrue);

        // Este teste deliberadamente não tenta clicar em Confirmar para
        // concluir o E2E, porque GenerosCadastroScreen foi criada pela
        // produção como:
        //
        //   GenerosCadastroScreen()
        //
        // e, portanto, usa FirebaseAuth.instance/FirebaseFirestore.instance
        // em vez dos mocks injetados neste teste.
      },
    );
  });
}
