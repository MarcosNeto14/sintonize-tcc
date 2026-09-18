Abaixo está um arquivo de teste de integração cobrindo o fluxo principal e os dois cenários de erro. Há um detalhe importante: como `GenerosCadastroScreen` usa `auth.currentUser`, o mock de Auth precisa permanecer autenticado entre as duas telas.

 test/integration/cadastro\_generos\_test.dart

```
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de cadastro e seleção de gêneros', () {
    late FakeCloudFirestore firestore;
    late MockFirebaseAuth auth;

    Future<void> pumpCadastro(
      WidgetTester tester, {
      required FirebaseAuth auth,
      required FakeCloudFirestore firestore,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => CadastroScreen(
                  auth: auth,
                  firestore: firestore,
                ),
            '/generos': (context) => GenerosCadastroScreen(
                  auth: auth,
                  firestore: firestore,
                ),
            '/inicio': (context) => const TelaInicialScreen(),
          },
        ),
      );

      await tester.pumpAndSettle();
    }

    Future<void> preencherCadastro(WidgetTester tester) async {
      final nome = find.widgetWithText(TextFormField, 'Nome');
      final dataNascimento =
          find.widgetWithText(TextFormField, 'Data de Nascimento');
      final email = find.widgetWithText(TextFormField, 'E-mail');
      final senha = find.widgetWithText(TextFormField, 'Senha');
      final confirmarSenha =
          find.widgetWithText(TextFormField, 'Confirmar Senha');
      final cep = find.widgetWithText(TextFormField, 'CEP');
      final rua = find.widgetWithText(TextFormField, 'Rua');
      final numero = find.widgetWithText(TextFormField, 'Número');
      final bairro = find.widgetWithText(TextFormField, 'Bairro');
      final cidade = find.widgetWithText(TextFormField, 'Cidade');

      await tester.enterText(nome, 'Maria da Silva');
      await tester.enterText(dataNascimento, '01011990');
      await tester.enterText(email, 'maria@example.com');
      await tester.enterText(senha, '123456');
      await tester.enterText(confirmarSenha, '123456');

      // O CEP é preenchido diretamente. Assim evitamos que o teste dependa
      // da API externa do ViaCEP.
      await tester.enterText(cep, '50000-000');

      await tester.enterText(rua, 'Rua das Flores');
      await tester.enterText(numero, '123');
      await tester.enterText(bairro, 'Centro');
      await tester.enterText(cidade, 'Recife');

      // Seleciona um estado.
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('PE').last);
      await tester.pumpAndSettle();
    }

    setUp(() {
      firestore = FakeCloudFirestore();

      auth = MockFirebaseAuth(
        signedIn: false,
      );
    });

    testWidgets(
      'deve cadastrar usuário, navegar para gêneros, salvar gêneros e chegar à tela inicial',
      (tester) async {
        await pumpCadastro(
          tester,
          auth: auth,
          firestore: firestore,
        );

        // 1. Preenche o formulário.
        await preencherCadastro(tester);

        // 2. Submete o cadastro.
        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        // O MockFirebaseAuth cria o usuário e mantém currentUser.
        expect(auth.currentUser, isNotNull);

        final uid = auth.currentUser!.uid;

        // 3. Verifica que o documento inicial foi criado.
        final cadastroDoc =
            await firestore.collection('usuarios').doc(uid).get();

        expect(cadastroDoc.exists, isTrue);
        expect(cadastroDoc.data()?['nome'], 'Maria da Silva');
        expect(cadastroDoc.data()?['data_nasc'], '01/01/1990');
        expect(cadastroDoc.data()?['email'], 'maria@example.com');

        final endereco =
            cadastroDoc.data()?['endereco'] as Map<String, dynamic>;

        expect(endereco['rua'], 'Rua das Flores');
        expect(endereco['numero'], '123');
        expect(endereco['bairro'], 'Centro');
        expect(endereco['cidade'], 'Recife');
        expect(endereco['estado'], 'PE');
        expect(endereco['cep'], '50000-000');

        // 4. Verifica a navegação para GenerosCadastroScreen.
        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        expect(find.text('Confirmar'), findsOneWidget);

        // 5. Seleciona gêneros.
        //
        // Como cada gênero possui um Switch, usamos o texto do gênero para
        // encontrar o Card correspondente e, dentro dele, o Switch.
        Future<void> selecionarGenero(String genero) async {
          final card = find.ancestor(
            of: find.text(genero),
            matching: find.byType(Card),
          );

          await tester.tap(
            find.descendant(
              of: card,
              matching: find.byType(Switch),
            ),
          );

          await tester.pump();
        }

        await selecionarGenero('Rock');
        await selecionarGenero('Jazz');
        await selecionarGenero('Reggae');

        // 6. Confirma os gêneros.
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        // 7. O documento deve conter os gêneros selecionados.
        final documentoFinal =
            await firestore.collection('usuarios').doc(uid).get();

        expect(
          documentoFinal.data()?['generos_favoritos'],
          containsAll(<String>[
            'Rock',
            'Jazz',
            'Reggae',
          ]),
        );

        expect(
          (documentoFinal.data()?['generos_favoritos'] as List).length,
          3,
        );

        // 8. A tela seguinte deve ter sido aberta.
        expect(find.byType(TelaInicialScreen), findsOneWidget);
      },
    );

    testWidgets(
      'deve exibir erro quando o Firebase Auth falha ao cadastrar',
      (tester) async {
        final authComErro = MockFirebaseAuth(
          signedIn: false,
          mockUser: null,
        );

        // O MockFirebaseAuth permite simular uma exceção através de
        // shouldFailOnSignIn, mas createUserWithEmailAndPassword é o método
        // exercitado pela tela. Para manter o teste independente da API
        // externa, usamos um FakeFirebaseAuth abaixo.
        final failingAuth = _FailingFirebaseAuth();

        await pumpCadastro(
          tester,
          auth: failingAuth,
          firestore: firestore,
        );

        await preencherCadastro(tester);

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Erro ao cadastrar:'),
          findsOneWidget,
        );

        // Continua na tela de cadastro.
        expect(find.text('Cadastrar'), findsOneWidget);

        // Nenhum usuário/documento deve ter sido criado.
        expect(failingAuth.currentUser, isNull);

        final usuarios = await firestore.collection('usuarios').get();
        expect(usuarios.docs, isEmpty);

        // Evita warning de variável não utilizada em versões diferentes
        // do package.
        expect(authComErro.currentUser, isNull);
      },
    );

    testWidgets(
      'deve não salvar gêneros quando não existe usuário autenticado',
      (tester) async {
        final authSemUsuario = MockFirebaseAuth(
          signedIn: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: authSemUsuario,
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

        // Seleciona Rock.
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

        // Confirma.
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        // Como currentUser é null, _salvarGeneros não executa update
        // e também não navega para a TelaInicial.
        expect(find.text('Confirmar'), findsOneWidget);
        expect(find.byType(TelaInicialScreen), findsNothing);

        // Nenhum documento foi criado/modificado.
        final usuarios = await firestore.collection('usuarios').get();
        expect(usuarios.docs, isEmpty);
      },
    );
  });
}

/// FirebaseAuth mínimo para testar a falha de createUserWithEmailAndPassword.
///
/// A tela só utiliza:
/// - createUserWithEmailAndPassword()
/// - currentUser (na tela de gêneros)
///
/// Por isso o restante da API fica delegado ao comportamento padrão
//// ou não é necessário para este cenário.
class _FailingFirebaseAuth implements FirebaseAuth {
  @override
  User? get currentUser => null;

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw FirebaseAuthException(
      code: 'email-already-in-use',
      message: 'O e-mail já está cadastrado.',
    );
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
```

 ### Ajuste importante no teste de erro

 Há uma questão de compatibilidade que vale destacar: `FirebaseAuth` é uma interface bastante grande e sua API pode variar entre versões do `firebase_auth`. O `_FailingFirebaseAuth` acima usa `noSuchMethod`, o que normalmente funciona para esse tipo de mock manual, mas **pode deixar de compilar dependendo da versão exata do Firebase instalada no projeto**.

 Uma abordagem mais robusta é criar um mockito específico de `FirebaseAuth` e configurar apenas o método utilizado:

```
class MockAuth extends Mock implements FirebaseAuth {}
```

 E no teste:

```
final auth = MockAuth();

when(
  auth.createUserWithEmailAndPassword(
    email: anyNamed('email'),
    password: anyNamed('password'),
  ),
).thenThrow(
  FirebaseAuthException(
    code: 'email-already-in-use',
    message: 'O e-mail já está cadastrado.',
  ),
);
```

 Nesse caso, recomendo usar **Mockito para o cenário de exceção** e `MockFirebaseAuth` para o fluxo feliz.

 ### Um ponto sobre o CEP

 O teste deliberadamente não espera o preenchimento automático pelo ViaCEP. Isso é importante para um teste de integração executável offline/reprodutível: a implementação atual chama diretamente `https://viacep.com.br`, então depender dela faria o teste ficar sujeito a rede, indisponibilidade do serviço e alterações externas.

 Também há uma particularidade no seu código: o `GenerosCadastroScreen` não recebe o `uid`; ele usa `auth.currentUser!.uid`. Por isso o teste verifica explicitamente que, depois do cadastro, `auth.currentUser` está preenchido antes de continuar.

 Se você quiser, posso também transformar isso em uma **versão usando `mockito` 100% (Auth + Firestore)**, incluindo o `@GenerateMocks`, `build_runner` e os stubs necessários para `UserCredential/User`.
