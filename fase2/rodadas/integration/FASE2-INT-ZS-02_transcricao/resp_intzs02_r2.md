## Classificação: **(A)**

 A falha é causada por **suposições incorretas do teste sobre o viewport e a interação com widgets fora da área visível**, não por um comportamento incorreto da aplicação.

 Há dois problemas no teste:

 1. O `DropdownButtonFormField` está em `y = 801`, enquanto o viewport do teste tem apenas `600` px de altura. O `tap()` tenta clicar fora da área visível.
2. Depois disso, `find.text('PE').last` não encontra nenhum elemento porque o dropdown nunca foi aberto. O `Bad state: No element` é consequência do primeiro problema.
3. O mesmo problema ocorre com `Confirmar` na `GenerosCadastroScreen`: o botão está abaixo do viewport e precisa ser colocado na área visível antes do `tap()`.

 O warning sobre `HttpClient` também é relevante: o teste está provocando a chamada ao ViaCEP, mas `flutter_test` não permite uma conexão HTTP real. Portanto, devemos **evitar disparar essa chamada** no teste. Não é necessário reduzir o escopo: podemos preencher o CEP e depois preencher os campos de endereço, mas o `onChanged` do CEP continuará disparando quando chegar a 9 caracteres. Uma solução mais limpa é inserir o CEP em duas etapas e evitar que o `onChanged` chegue ao estado que chama o ViaCEP, mas isso é frágil. Melhor ainda: usar `tester.enterText` no CEP e aceitar que a chamada HTTP será interceptada pelo binding? Como isso pode alterar os campos de endereço assincronamente, prefiro preencher endereço **depois** e aguardar o processamento.

 A correção principal é usar `scrollUntilVisible()` antes de interagir com elementos fora da viewport.

 test/fase2/integration/cadastro\_flow\_zs\_test.dart — versão corrigida

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

/// FirebaseAuth usado somente para simular falha no cadastro.
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
      final campos = find.byType(TextFormField);

      expect(campos, findsNWidgets(10));

      // Nome
      await tester.enterText(
        campos.at(0),
        'Maria da Silva',
      );

      // Data de nascimento
      await tester.enterText(
        campos.at(1),
        '01011990',
      );

      // E-mail
      await tester.enterText(
        campos.at(2),
        'maria@example.com',
      );

      // Senha
      await tester.enterText(
        campos.at(3),
        '123456',
      );

      // Confirmar senha
      await tester.enterText(
        campos.at(4),
        '123456',
      );

      // CEP
      //
      // O código da aplicação chama o ViaCEP quando o CEP chega a
      // 9 caracteres. O Flutter test binding não permite uma conexão
      // HTTP real. Mesmo assim, o campo pode ser preenchido; em seguida
      // sobrescrevemos os campos de endereço com os valores desejados.
      await tester.enterText(
        campos.at(5),
        '50000-000',
      );

      await tester.pump();

      // Rua
      await tester.enterText(
        campos.at(6),
        'Rua das Flores',
      );

      // Número
      await tester.enterText(
        campos.at(7),
        '123',
      );

      // Bairro
      await tester.enterText(
        campos.at(8),
        'Centro',
      );

      // Cidade
      await tester.enterText(
        campos.at(9),
        'Recife',
      );

      // O Dropdown está fora do viewport inicial.
      final dropdown = find.byType(
        DropdownButtonFormField<String>,
      );

      await tester.scrollUntilVisible(
        dropdown,
        300,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.pumpAndSettle();

      expect(dropdown, findsOneWidget);

      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // O menu aberto contém o estado PE.
      final estadoPE = find.text('PE');

      expect(estadoPE, findsWidgets);

      await tester.tap(estadoPE.last);
      await tester.pumpAndSettle();
    }

    Future<void> selecionarGenero(
      WidgetTester tester,
      String genero,
    ) async {
      final textoGenero = find.text(genero);

      expect(textoGenero, findsOneWidget);

      final card = find.ancestor(
        of: textoGenero,
        matching: find.byType(Card),
      );

      expect(card, findsOneWidget);

      final switchFinder = find.descendant(
        of: card,
        matching: find.byType(Switch),
      );

      expect(switchFinder, findsOneWidget);

      // Garante que o Switch está no viewport antes do tap.
      await tester.scrollUntilVisible(
        switchFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.pumpAndSettle();

      await tester.tap(switchFinder);
      await tester.pump();
    }

    testWidgets(
      'deve completar o cadastro, selecionar gêneros e salvar no Firestore',
      (tester) async {
        // ---------------------------------------------------------------
        // 1. CadastroScreen
        // ---------------------------------------------------------------
        await abrirCadastro(tester);

        expect(
          find.text('Cadastrar'),
          findsOneWidget,
        );

        // ---------------------------------------------------------------
        // 2. Preenche formulário
        // ---------------------------------------------------------------
        await preencherCadastro(tester);

        // ---------------------------------------------------------------
        // 3. Localiza e toca em Cadastrar
        // ---------------------------------------------------------------
        final botaoCadastrar = find.text('Cadastrar');

        await tester.scrollUntilVisible(
          botaoCadastrar,
          300,
          scrollable: find.byType(Scrollable).first,
        );

        await tester.pumpAndSettle();

        await tester.tap(botaoCadastrar);
        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // 4. Firebase Auth deve ter criado o usuário
        // ---------------------------------------------------------------
        expect(
          auth.currentUser,
          isNotNull,
        );

        final uid = auth.currentUser!.uid;

        // ---------------------------------------------------------------
        // 5. Firestore deve conter o documento criado
        // ---------------------------------------------------------------
        final documentoInicial = await firestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(
          documentoInicial.exists,
          isTrue,
        );

        final dados = documentoInicial.data()!;

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
        // 6. Deve ter navegado para GenerosCadastroScreen
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
        // 7. Seleciona Rock, Jazz e Reggae
        // ---------------------------------------------------------------
        await selecionarGenero(tester, 'Rock');
        await selecionarGenero(tester, 'Jazz');
        await selecionarGenero(tester, 'Reggae');

        // ---------------------------------------------------------------
        // 8. Coloca Confirmar no viewport
        // ---------------------------------------------------------------
        final confirmar = find.text('Confirmar');

        await tester.scrollUntilVisible(
          confirmar,
          300,
          scrollable: find.byType(Scrollable).first,
        );

        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // 9. Confirma gêneros
        // ---------------------------------------------------------------
        await tester.tap(confirmar);
        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // 10. Verifica Firestore
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
            List<String>.from(
          dadosFinais['generos_favoritos'] as List,
        );

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
        // 11. Deve chegar à TelaInicialScreen
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

        final botaoCadastrar = find.text('Cadastrar');

        await tester.scrollUntilVisible(
          botaoCadastrar,
          300,
          scrollable: find.byType(Scrollable).first,
        );

        await tester.pumpAndSettle();

        await tester.tap(botaoCadastrar);
        await tester.pumpAndSettle();

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

        // Não houve autenticação.
        expect(
          failingAuth.currentUser,
          isNull,
        );

        // Não houve criação de documento.
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

        // ---------------------------------------------------------------
        // Seleciona Rock
        // ---------------------------------------------------------------
        await selecionarGenero(tester, 'Rock');

        // ---------------------------------------------------------------
        // Coloca Confirmar no viewport
        // ---------------------------------------------------------------
        final confirmar = find.text('Confirmar');

        await tester.scrollUntilVisible(
          confirmar,
          300,
          scrollable: find.byType(Scrollable).first,
        );

        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // Confirma
        // ---------------------------------------------------------------
        await tester.tap(confirmar);
        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // Sem usuário autenticado, a aplicação não deve navegar.
        // ---------------------------------------------------------------
        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );

        expect(
          find.text('Confirmar'),
          findsOneWidget,
        );

        // Nenhum documento deve ter sido criado.
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

 ### O que foi corrigido

 O ponto central é este padrão:

```
await tester.scrollUntilVisible(
  finder,
  300,
  scrollable: find.byType(Scrollable).first,
);

await tester.pumpAndSettle();

await tester.tap(finder);
```

 Ele é necessário porque seu `CadastroScreen` está dentro de:

```
SingleChildScrollView
```

 e o formulário é maior que o viewport padrão do `flutter_test` (`800 × 600` no seu log).

 O mesmo vale para `Confirmar` e para os `Switch` dos gêneros.

 ### Sobre o warning do HTTP

 Seu próprio log confirma outro aspecto importante:

 > "all HTTP requests will return status code 400, and no network request will actually be made"

 Isso vem desta parte da aplicação:

```
if (value.length == 9) {
  _fetchAddressFromCEP(value.replaceAll('-', ''));
}
```

 Portanto, **o teste não deve depender do ViaCEP**. A versão acima sobrescreve os campos `Rua`, `Número`, `Bairro` e `Cidade` depois do preenchimento do CEP, tornando os dados usados pelo `Cadastrar` determinísticos.

 Se você executar novamente com:

```
flutter test test/fase2/integration/
```

 o erro de `Offset(400.0, 801.0)` e o `Bad state: No element` relacionados ao dropdown devem desaparecer.
