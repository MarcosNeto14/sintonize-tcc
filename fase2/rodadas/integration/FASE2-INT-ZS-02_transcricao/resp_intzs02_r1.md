## Classificação: **(A)**

 A causa é uma **suposição incorreta do teste**, não um comportamento incorreto da aplicação.

 O pacote `fake_cloud_firestore` expõe a classe **`FakeFirebaseFirestore`**, e não `FakeCloudFirestore`. Portanto, o compilador não encontra o tipo usado no teste. A correção é substituir:

```
FakeCloudFirestore
```

 por:

```
FakeFirebaseFirestore
```

 Há também dois ajustes importantes no teste anterior: os `TextFormField`s não contêm os textos dos labels (`Nome`, `E-mail`, etc.), pois os labels são widgets `Text` separados; e, para simular a falha do Firebase Auth de forma confiável, é melhor usar Mockito.

 Abaixo está uma versão corrigida do teste.

 test/fase2/integration/cadastro\_flow\_zs\_test.dart

```
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';

/// Mock de FirebaseAuth para o cenário de erro.
class MockFirebaseAuthWithError extends Mock implements FirebaseAuth {
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de cadastro do Sintonize', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;

    setUp(() {
      firestore = FakeFirebaseFirestore();

      auth = MockFirebaseAuth(
        signedIn: false,
      );
    });

    Future<void> abrirCadastro(WidgetTester tester) async {
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
      // A ordem dos TextFormField na CadastroScreen é:
      //
      // 0 Nome
      // 1 Data de Nascimento
      // 2 E-mail
      // 3 Senha
      // 4 Confirmar Senha
      // 5 CEP
      // 6 Rua
      // 7 Número
      // 8 Bairro
      // 9 Cidade
      final campos = find.byType(TextFormField);

      expect(campos, findsNWidgets(10));

      await tester.enterText(
        campos.at(0),
        'Maria da Silva',
      );

      await tester.enterText(
        campos.at(1),
        '01011990',
      );

      await tester.enterText(
        campos.at(2),
        'maria@example.com',
      );

      await tester.enterText(
        campos.at(3),
        '123456',
      );

      await tester.enterText(
        campos.at(4),
        '123456',
      );

      // Não dependemos do ViaCEP durante o teste.
      await tester.enterText(
        campos.at(5),
        '50000-000',
      );

      await tester.enterText(
        campos.at(6),
        'Rua das Flores',
      );

      await tester.enterText(
        campos.at(7),
        '123',
      );

      await tester.enterText(
        campos.at(8),
        'Centro',
      );

      await tester.enterText(
        campos.at(9),
        'Recife',
      );

      // Seleciona Pernambuco.
      await tester.tap(
        find.byType(DropdownButtonFormField<String>),
      );

      await tester.pumpAndSettle();

      await tester.tap(
        find.text('PE').last,
      );

      await tester.pumpAndSettle();
    }

    Future<void> selecionarGenero(
      WidgetTester tester,
      String genero,
    ) async {
      final generoText = find.text(genero);

      expect(generoText, findsOneWidget);

      final card = find.ancestor(
        of: generoText,
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

    testWidgets(
      'deve completar o cadastro, selecionar gêneros e salvar no Firestore',
      (tester) async {
        // ---------------------------------------------------------------
        // 1. Abre CadastroScreen
        // ---------------------------------------------------------------
        await abrirCadastro(tester);

        expect(find.text('Cadastrar'), findsOneWidget);

        // ---------------------------------------------------------------
        // 2. Preenche o formulário
        // ---------------------------------------------------------------
        await preencherCadastro(tester);

        // ---------------------------------------------------------------
        // 3. Cria a conta
        // ---------------------------------------------------------------
        await tester.tap(
          find.text('Cadastrar'),
        );

        await tester.pumpAndSettle();

        // MockFirebaseAuth deve ter criado/autenticado o usuário.
        expect(auth.currentUser, isNotNull);

        final uid = auth.currentUser!.uid;

        // ---------------------------------------------------------------
        // 4. Verifica documento criado no Firestore
        // ---------------------------------------------------------------
        final documentoAntesDosGeneros = await firestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(
          documentoAntesDosGeneros.exists,
          isTrue,
        );

        final dados = documentoAntesDosGeneros.data()!;

        expect(
          dados['nome'],
          'Maria da Silva',
        );

        expect(
          dados['data_nasc'],
          '01/01/1990',
        );

        expect(
          dados['email'],
          'maria@example.com',
        );

        expect(
          dados['generos_favoritos'],
          isNull,
        );

        final endereco =
            dados['endereco'] as Map<String, dynamic>;

        expect(
          endereco['rua'],
          'Rua das Flores',
        );

        expect(
          endereco['numero'],
          '123',
        );

        expect(
          endereco['bairro'],
          'Centro',
        );

        expect(
          endereco['cidade'],
          'Recife',
        );

        expect(
          endereco['estado'],
          'PE',
        );

        expect(
          endereco['cep'],
          '50000-000',
        );

        // ---------------------------------------------------------------
        // 5. Verifica navegação para GenerosCadastroScreen
        // ---------------------------------------------------------------
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

        // ---------------------------------------------------------------
        // 6. Seleciona gêneros
        // ---------------------------------------------------------------
        await selecionarGenero(tester, 'Rock');
        await selecionarGenero(tester, 'Jazz');
        await selecionarGenero(tester, 'Reggae');

        // ---------------------------------------------------------------
        // 7. Confirma
        // ---------------------------------------------------------------
        await tester.tap(
          find.text('Confirmar'),
        );

        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // 8. Verifica atualização do Firestore
        // ---------------------------------------------------------------
        final documentoFinal = await firestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(
          documentoFinal.exists,
          isTrue,
        );

        final dadosFinais = documentoFinal.data()!;

        final generos =
            List<String>.from(dadosFinais['generos_favoritos'] as List);

        expect(
          generos,
          containsAll(<String>[
            'Rock',
            'Jazz',
            'Reggae',
          ]),
        );

        expect(
          generos.length,
          3,
        );

        // ---------------------------------------------------------------
        // 9. Verifica navegação final
        // ---------------------------------------------------------------
        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir erro quando Firebase Auth falha ao cadastrar',
      (tester) async {
        final failingAuth = MockFirebaseAuthWithError();

        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: failingAuth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await preencherCadastro(tester);

        await tester.tap(
          find.text('Cadastrar'),
        );

        await tester.pumpAndSettle();

        // A aplicação captura FirebaseAuthException e apresenta:
        // "Erro ao cadastrar: O e-mail já está cadastrado."
        expect(
          find.text(
            'Erro ao cadastrar: O e-mail já está cadastrado.',
          ),
          findsOneWidget,
        );

        // Continua na tela de cadastro.
        expect(
          find.text('Cadastrar'),
          findsOneWidget,
        );

        // Como o Auth falhou, nenhum usuário foi autenticado.
        expect(
          failingAuth.currentUser,
          isNull,
        );

        // E nenhum documento foi criado.
        final usuarios = await firestore
            .collection('usuarios')
            .get();

        expect(
          usuarios.docs,
          isEmpty,
        );
      },
    );

    testWidgets(
      'não deve salvar gêneros quando não existe usuário autenticado',
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
        await selecionarGenero(tester, 'Rock');

        // Confirma.
        await tester.tap(
          find.text('Confirmar'),
        );

        await tester.pumpAndSettle();

        // Como currentUser == null, _salvarGeneros() não entra no bloco
        // que executa o update e também não navega.
        expect(
          find.text('Confirmar'),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );

        // Nenhum documento foi criado.
        final usuarios = await firestore
            .collection('usuarios')
            .get();

        expect(
          usuarios.docs,
          isEmpty,
        );
      },
    );
  });
}
```

 ### Dependências

 Confirme que o `pubspec.yaml` contém pelo menos:

```
dev_dependencies:
  flutter_test:
    sdk: flutter
  fake_cloud_firestore: ^3.1.0
  firebase_auth_mocks: ^0.14.2
  mockito: ^5.4.4
```

 As versões podem ser diferentes das suas; o ponto essencial é o nome da classe:

```
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

late FakeFirebaseFirestore firestore;

firestore = FakeFirebaseFirestore();
```

 ### Uma observação sobre o terceiro teste

 Esse teste verifica especificamente o comportamento **atual** da aplicação quando `currentUser == null`: `_confirmar()` percebe que há um gênero selecionado, chama `_salvarGeneros()`, mas `_salvarGeneros()` simplesmente retorna porque `user == null`.

 Portanto, nesse cenário **não aparece SnackBar de erro**. O teste não cria uma expectativa de erro que o código não implementa; ele verifica que não há atualização nem navegação.

 Se o próximo erro for relacionado a `MockFirebaseAuthWithError` ou à assinatura de `FirebaseAuth`, envie o erro de compilação. Essa parte depende bastante da versão de `firebase_auth` instalada no projeto.
