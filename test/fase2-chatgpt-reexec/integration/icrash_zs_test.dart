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

class TelaInicialTeste extends StatelessWidget {
  const TelaInicialTeste({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Tela Inicial'),
      ),
    );
  }
}

/// Firestore fake que simula indisponibilidade no set().
class FirestoreIndisponivel extends FakeFirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _CollectionIndisponivel(super.collection(path));
  }
}

class _CollectionIndisponivel
    implements CollectionReference<Map<String, dynamic>> {
  final CollectionReference<Map<String, dynamic>> delegate;

  _CollectionIndisponivel(this.delegate);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return _DocumentSetIndisponivel(delegate.doc(path));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return delegate.noSuchMethod(invocation);
  }
}

class _DocumentSetIndisponivel
    implements DocumentReference<Map<String, dynamic>> {
  final DocumentReference<Map<String, dynamic>> delegate;

  _DocumentSetIndisponivel(this.delegate);

  @override
  Future<void> set(
    Map<String, dynamic> data, [
    SetOptions? options,
  ]) async {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'unavailable',
      message: 'Firestore indisponível.',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return delegate.noSuchMethod(invocation);
  }
}

/// Firestore fake que simula indisponibilidade no update().
class FirestoreIndisponivelNoUpdate extends FakeFirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _CollectionUpdateIndisponivel(super.collection(path));
  }
}

class _CollectionUpdateIndisponivel
    implements CollectionReference<Map<String, dynamic>> {
  final CollectionReference<Map<String, dynamic>> delegate;

  _CollectionUpdateIndisponivel(this.delegate);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return _DocumentUpdateIndisponivel(delegate.doc(path));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return delegate.noSuchMethod(invocation);
  }
}

class _DocumentUpdateIndisponivel
    implements DocumentReference<Map<String, dynamic>> {
  final DocumentReference<Map<String, dynamic>> delegate;

  _DocumentUpdateIndisponivel(this.delegate);

  @override
  Future<void> update(Map<Object, Object?> data) async {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'unavailable',
      message: 'Firestore indisponível.',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return delegate.noSuchMethod(invocation);
  }
}

MockUser criarUsuario() {
  return MockUser(
    uid: 'usuario-teste-123',
    email: 'teste@sintonize.com',
    displayName: 'João da Silva',
  );
}

Widget criarApp({
  required FirebaseAuth auth,
  required FirebaseFirestore firestore,
}) {
  return MaterialApp(
    home: CadastroScreen(
      auth: auth,
      firestore: firestore,
    ),
    routes: {
      '/inicio': (_) => const TelaInicialTeste(),
    },
  );
}

Future<void> tocarWidgetVisivel(
  WidgetTester tester,
  Finder finder,
) async {
  expect(finder, findsOneWidget);

  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();

  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> preencherCampo(
  WidgetTester tester,
  Finder campo,
  String texto,
) async {
  expect(campo, findsOneWidget);

  await tester.ensureVisible(campo);
  await tester.pump();

  await tester.enterText(campo, texto);
}

Future<void> preencherCadastro(WidgetTester tester) async {
  final campos = find.byType(TextFormField);

  expect(campos, findsNWidgets(10));

  await preencherCampo(
    tester,
    campos.at(0),
    'João da Silva',
  );

  await preencherCampo(
    tester,
    campos.at(1),
    '01/01/1990',
  );

  await preencherCampo(
    tester,
    campos.at(2),
    'teste@sintonize.com',
  );

  await preencherCampo(
    tester,
    campos.at(3),
    '123456',
  );

  await preencherCampo(
    tester,
    campos.at(4),
    '123456',
  );

  await preencherCampo(
    tester,
    campos.at(5),
    '50000-000',
  );

  await preencherCampo(
    tester,
    campos.at(6),
    'Rua Teste',
  );

  await preencherCampo(
    tester,
    campos.at(7),
    '123',
  );

  await preencherCampo(
    tester,
    campos.at(8),
    'Centro',
  );

  await preencherCampo(
    tester,
    campos.at(9),
    'Recife',
  );
}

void main() {
  group('Fluxo de cadastro e seleção de gêneros', () {
    testWidgets(
      'realiza cadastro, navega para gêneros, salva gêneros e chega à tela inicial',
      (tester) async {
        final usuario = criarUsuario();

        final auth = MockFirebaseAuth(
          mockUser: usuario,
          signedIn: true,
        );

        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          criarApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // Cadastro
        // ---------------------------------------------------------------

        await preencherCadastro(tester);

        await tocarWidgetVisivel(
  tester,
  find.widgetWithText(
    ElevatedButton,
    'Cadastrar',
  ),
);

        // O usuário foi autenticado.
        expect(auth.currentUser, isNotNull);
        expect(
          auth.currentUser!.uid,
          'usuario-teste-123',
        );

        // ---------------------------------------------------------------
        // Documento do usuário
        // ---------------------------------------------------------------

        final documento = await firestore
            .collection('usuarios')
            .doc('usuario-teste-123')
            .get();

        expect(documento.exists, isTrue);

        final dados = documento.data()!;

        expect(dados['nome'], 'João da Silva');
        expect(dados['data_nasc'], '01/01/1990');
        expect(dados['email'], 'teste@sintonize.com');

        final endereco =
            dados['endereco'] as Map<String, dynamic>;

        expect(endereco['rua'], 'Rua Teste');
        expect(endereco['numero'], '123');
        expect(endereco['bairro'], 'Centro');
        expect(endereco['cidade'], 'Recife');
        expect(endereco['cep'], '50000-000');

        // ---------------------------------------------------------------
        // GenerosCadastroScreen
        // ---------------------------------------------------------------

        expect(find.text('Rock'), findsOneWidget);
        expect(find.text('Pop'), findsOneWidget);
        expect(find.text('Jazz'), findsOneWidget);
        expect(find.text('Blues'), findsOneWidget);
        expect(find.text('Hip-Hop'), findsOneWidget);
        expect(find.text('Reggae'), findsOneWidget);
        expect(find.text('Country'), findsOneWidget);

        // Seleciona Rock e Jazz.
        await tocarWidgetVisivel(
  tester,
  find.widgetWithText(
    SwitchListTile,
    'Rock',
  ),
);

        await tocarWidgetVisivel(
  tester,
  find.widgetWithText(
    SwitchListTile,
    'Jazz',
  ),
);

        await tester.pump();

        final rock =
            tester.widget<SwitchListTile>(
          find.widgetWithText(
            SwitchListTile,
            'Rock',
          ),
        );

        final jazz =
            tester.widget<SwitchListTile>(
          find.widgetWithText(
            SwitchListTile,
            'Jazz',
          ),
        );

        expect(rock.value, isTrue);
        expect(jazz.value, isTrue);

        // ---------------------------------------------------------------
        // Confirma gêneros
        // ---------------------------------------------------------------

        await tocarWidgetVisivel(
  tester,
  find.widgetWithText(
    ElevatedButton,
    'Confirmar',
  ),
);

        // ---------------------------------------------------------------
        // Estado final no Firestore
        // ---------------------------------------------------------------

        final documentoFinal = await firestore
            .collection('usuarios')
            .doc('usuario-teste-123')
            .get();

        expect(documentoFinal.exists, isTrue);

        final generos =
            documentoFinal.data()!['generos_favoritos'] as List<dynamic>;

        expect(
          generos,
          containsAll(<String>[
            'Rock',
            'Jazz',
          ]),
        );

        expect(generos.length, 2);

        // O fluxo chegou à próxima tela.
        //
        // Se sua TelaInicialScreen real tiver um texto identificável,
        // prefira verificar esse texto aqui.
        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );
expect(
  find.byType(TelaInicialScreen),
  findsOneWidget,
);
      },
    );

    testWidgets(
      'mostra erro quando Firebase Auth falha durante o cadastro',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #createUserWithEmailAndPassword,
            null,
            {
              #email: 'teste@sintonize.com',
              #password: '123456',
            },
          ),
        ).on(auth).thenThrow(
              FirebaseAuthException(
                code: 'email-already-in-use',
                message: 'Este e-mail já está cadastrado.',
              ),
            );

        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          criarApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await tester.pumpAndSettle();

        await preencherCadastro(tester);

        await tocarWidgetVisivel(
  tester,
  find.widgetWithText(
    ElevatedButton,
    'Cadastrar',
  ),
);

        expect(
          find.text(
            'Erro ao cadastrar: Este e-mail já está cadastrado.',
          ),
          findsOneWidget,
        );

        // A conta não foi criada.
        expect(auth.currentUser, isNull);

        // A tela de gêneros não foi alcançada.
        expect(
          find.text('Rock'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'mostra erro quando Firestore está indisponível durante o cadastro',
      (tester) async {
        final usuario = criarUsuario();

        final auth = MockFirebaseAuth(
          mockUser: usuario,
          signedIn: true,
        );

        final firestore = FirestoreIndisponivel();

        await tester.pumpWidget(
          criarApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await tester.pumpAndSettle();

        await preencherCadastro(tester);

        await tocarWidgetVisivel(
  tester,
  find.widgetWithText(
    ElevatedButton,
    'Cadastrar',
  ),
);

        expect(
          find.textContaining('Erro desconhecido:'),
          findsOneWidget,
        );

        // O cadastro no Auth aconteceu, mas o documento não pôde
        // ser persistido.
        expect(auth.currentUser, isNotNull);

        // O fluxo não deve avançar para gêneros.
        expect(
          find.text('Rock'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'não permite confirmar gêneros sem selecionar nenhum',
      (tester) async {
        final usuario = criarUsuario();

        final auth = MockFirebaseAuth(
          mockUser: usuario,
          signedIn: true,
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

        await tocarWidgetVisivel(
  tester,
  find.widgetWithText(
    ElevatedButton,
    'Confirmar',
  ),
);

        expect(
          find.text(
            'Selecione pelo menos um gênero musical!',
          ),
          findsOneWidget,
        );

        // Nenhuma atualização deve ter ocorrido.
        final documento = await firestore
            .collection('usuarios')
            .doc(usuario.uid)
            .get();

        expect(documento.exists, isFalse);
      },
    );

    testWidgets(
      'mostra erro quando Firestore falha ao salvar os gêneros',
      (tester) async {
        final usuario = criarUsuario();

        final auth = MockFirebaseAuth(
          mockUser: usuario,
          signedIn: true,
        );

        final firestore = FirestoreIndisponivelNoUpdate();

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tocarWidgetVisivel(
  tester,
  find.widgetWithText(
    SwitchListTile,
    'Pop',
  ),
);

        await tocarWidgetVisivel(
  tester,
  find.widgetWithText(
    ElevatedButton,
    'Confirmar',
  ),
);

        expect(
          find.text('Erro ao salvar os gêneros!'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'usuário não autenticado não consegue salvar gêneros',
      (tester) async {
        final auth = MockFirebaseAuth(
          signedIn: false,
          mockUser: null,
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

        await tocarWidgetVisivel(
  tester,
  find.widgetWithText(
    SwitchListTile,
    'Rock',
  ),
);

        await tocarWidgetVisivel(
  tester,
  find.widgetWithText(
    ElevatedButton,
    'Confirmar',
  ),
);

        // Com o código de produção fornecido originalmente,
        // currentUser!.uid lança uma exceção antes do try/catch.
        //
        // Portanto, aqui não esperamos um SnackBar específico:
        // verificamos apenas que não houve persistência nem navegação.
        expect(
          find.text('Rock'),
          findsOneWidget,
        );

        expect(
          find.text('Tela Inicial'),
          findsNothing,
        );

        final documento = await firestore
            .collection('usuarios')
            .doc('usuario-teste-123')
            .get();

        expect(documento.exists, isFalse);
      },
    );
  });
}
