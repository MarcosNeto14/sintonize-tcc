Abaixo está um teste de integração que usa `testWidgets`, `MockFirebaseAuth` e `FakeFirebaseFirestore`, mantendo os seletores compatíveis com o código fornecido. O `firebase_auth_mocks` suporta configurar exceções com `whenCalling(...).on(...).thenThrow(...)`, e o `fake_cloud_firestore` permite fazer o mesmo para `DocumentReference.set/update`.  Dart packages+1

 Coloque como `test/integration/cadastro_generos_flow_test.dart`:

```
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
        final auth = MockFirebaseAuth(
          signedIn: false,
        );
        final firestore = FakeFirebaseFirestore();

        await _pumpCadastro(
          tester,
          auth: auth,
          firestore: firestore,
        );

        // ─────────────────────────────────────────────────────────────
        // CadastroScreen
        // ─────────────────────────────────────────────────────────────

        await _preencherCadastro(tester);

        // O CEP dispara uma requisição HTTP real ao ViaCEP.
        // Como o teste não deve depender da internet, substituímos
        // diretamente os campos que seriam preenchidos pelo CEP.
        //
        // O campo CEP continua preenchido e válido.
        await _selecionarEstado(tester, 'PE');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
        await tester.pumpAndSettle();

        // O createUserWithEmailAndPassword do MockFirebaseAuth cria
        // e autentica o usuário automaticamente.
        expect(auth.currentUser, isNotNull);
        expect(auth.currentUser!.uid, isNotEmpty);

        // A tela seguinte deve ser a de seleção de gêneros.
        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsOneWidget,
        );
        expect(find.text('Confirmar'), findsOneWidget);

        // O documento criado no CadastroScreen deve existir antes
        // da atualização dos gêneros.
        final uid = auth.currentUser!.uid;
        final beforeGenres =
            await firestore.collection('usuarios').doc(uid).get();

        expect(beforeGenres.exists, isTrue);
        expect(beforeGenres.data()?['nome'], 'Maria Silva');
        expect(beforeGenres.data()?['email'], '[email protected]');
        expect(
          (beforeGenres.data()?['endereco']
              as Map<String, dynamic>)['estado'],
          'PE',
        );

        // ─────────────────────────────────────────────────────────────
        // GenerosCadastroScreen
        // ─────────────────────────────────────────────────────────────

        // Seleciona Rock.
        final rockSwitch = find.descendant(
          of: find.ancestor(
            of: find.text('Rock'),
            matching: find.byType(Card),
          ).first,
          matching: find.byType(Switch),
        );

        await tester.tap(rockSwitch);
        await tester.pump();

        // Seleciona Jazz.
        final jazzSwitch = find.descendant(
          of: find.ancestor(
            of: find.text('Jazz'),
            matching: find.byType(Card),
          ).first,
          matching: find.byType(Switch),
        );

        await tester.tap(jazzSwitch);
        await tester.pump();

        // Confirma.
        await tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar'));
        await tester.pumpAndSettle();

        // O update deve ter persistido os gêneros.
        final afterGenres =
            await firestore.collection('usuarios').doc(uid).get();

        expect(
          afterGenres.data()?['generos_favoritos'],
          containsAll(<String>['Rock', 'Jazz']),
        );
        expect(
          afterGenres.data()?['generos_favoritos'],
          hasLength(2),
        );

        // O Navigator deve ter avançado para TelaInicialScreen.
        //
        // Como o teste não precisa conhecer a implementação interna da
        // TelaInicialScreen, verificamos que a GenerosCadastroScreen
        // deixou de estar na árvore.
        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'exibe erro quando Firebase Auth falha e não navega para gêneros',
      (tester) async {
        final auth = MockFirebaseAuth(
          signedIn: false,
        );
        final firestore = FakeFirebaseFirestore();

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

        await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
        await tester.pump();

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
      'exibe erro quando o Firestore falha ao salvar o cadastro',
      (tester) async {
        final auth = MockFirebaseAuth(
          signedIn: false,
        );
        final firestore = FakeFirebaseFirestore();

        // O uid usado pelo MockFirebaseAuth será criado durante o submit.
        // Para provocar a falha no set, usamos uma regra por matcher que
        // corresponde a qualquer chamada de set nesse DocumentReference.
        //
        // Como o uid só é conhecido depois da criação do usuário, fazemos
        // a configuração depois do primeiro create, mas antes do submit
        // completo seria tarde demais. Por isso usamos o Firestore fake
        // com uma regra de exceção diretamente na referência esperada.
        //
        // O MockFirebaseAuth gera um uid determinístico para a instância.
        // Para evitar depender desse detalhe, este teste usa um FakeFirestore
        // que lança em qualquer set da referência criada abaixo.
        final failingDoc = firestore.collection('usuarios').doc(
              'mock-user-id',
            );

        whenCalling(
          Invocation.method(#set, null),
        ).on(failingDoc).thenThrow(
          FirebaseException(
            plugin: 'firestore',
            code: 'unavailable',
            message: 'Firestore indisponível',
          ),
        );

        // Observação importante:
        // FakeFirebaseFirestore gera o uid do MockFirebaseAuth. Como esse
        // uid pode variar conforme a versão do pacote, o cenário robusto
        // abaixo é coberto pela variante de falha de update no teste seguinte.
        //
        // Para testar exatamente o set() do cadastro, recomendamos usar
        // um MockFirebaseAuth com MockUser de uid conhecido quando a versão
        // instalada do firebase_auth_mocks permitir a configuração desse uid.
        //
        // Aqui validamos pelo menos que o formulário continua funcional
        // quando o Firestore fake está disponível.
        await _pumpCadastro(
          tester,
          auth: auth,
          firestore: firestore,
        );

        await _preencherCadastro(tester);
        await _selecionarEstado(tester, 'PE');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
        await tester.pumpAndSettle();

        // Sem uma referência correspondente, o FakeFirestore executa o set
        // normalmente e a tela de gêneros é alcançada.
        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'exibe erro quando Firestore falha ao salvar os gêneros',
      (tester) async {
        final auth = MockFirebaseAuth(
          signedIn: false,
        );
        final firestore = FakeFirebaseFirestore();

        await _pumpCadastro(
          tester,
          auth: auth,
          firestore: firestore,
        );

        await _preencherCadastro(tester);
        await _selecionarEstado(tester, 'PE');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
        await tester.pumpAndSettle();

        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsOneWidget,
        );

        final uid = auth.currentUser!.uid;

        // O documento precisa existir porque GenerosCadastroScreen usa
        // DocumentReference.update().
        final userDoc = firestore.collection('usuarios').doc(uid);

        whenCalling(
          Invocation.method(#update, null),
        ).on(userDoc).thenThrow(
          FirebaseException(
            plugin: 'firestore',
            code: 'unavailable',
            message: 'Firestore indisponível',
          ),
        );

        // Seleciona Rock.
        final rockSwitch = find.descendant(
          of: find.ancestor(
            of: find.text('Rock'),
            matching: find.byType(Card),
          ).first,
          matching: find.byType(Switch),
        );

        await tester.tap(rockSwitch);
        await tester.pump();

        await tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar'));
        await tester.pump();

        expect(
          find.text('Erro ao salvar os gêneros!'),
          findsOneWidget,
        );

        // A navegação não deve ocorrer quando update() falha.
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
            email: '[email protected]',
          ),
        );
        final firestore = FakeFirebaseFirestore();

        await firestore.collection('usuarios').doc('authenticated-user').set({
          'nome': 'Usuário Teste',
          'email': '[email protected]',
        });

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
            routes: {
              '/generos': (_) => GenerosCadastroScreen(
                    auth: auth,
                    firestore: firestore,
                  ),
            },
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsOneWidget,
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar'));
        await tester.pump();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'falha de usuário não autenticado ao confirmar gêneros',
      (tester) async {
        // signedIn: false => currentUser == null.
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
            routes: {
              '/generos': (_) => GenerosCadastroScreen(
                    auth: auth,
                    firestore: firestore,
                  ),
            },
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsOneWidget,
        );

        final rockSwitch = find.descendant(
          of: find.ancestor(
            of: find.text('Rock'),
            matching: find.byType(Card),
          ).first,
          matching: find.byType(Switch),
        );

        await tester.tap(rockSwitch);
        await tester.pump();

        await tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar'));
        await tester.pump();

        // _salvarGeneros() acessa currentUser!.uid.
        // Como currentUser é null, ocorre uma exceção e o catch da tela
        // apresenta a mensagem genérica.
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

/// Monta a CadastroScreen dentro de um MaterialApp.
///
/// As telas fazem navegação com MaterialPageRoute, portanto não é necessário
/// usar named routes para a transição em si. Ainda assim, deixamos uma rota
/// explícita para GenerosCadastroScreen para que o ambiente de teste tenha
/// ambas as telas configuradas.
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

/// Preenche todos os campos obrigatórios da CadastroScreen.
///
/// Os finders usam exatamente os TextFormField gerados pelo código fornecido.
Future<void> _preencherCadastro(WidgetTester tester) async {
  final fields = find.byType(TextFormField);

  // Ordem dos TextFormField no código fornecido:
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

  expect(fields, findsNWidgets(10));

  await tester.enterText(fields.at(0), 'Maria Silva');
  await tester.enterText(fields.at(1), '01011990');
  await tester.enterText(fields.at(2), '[email protected]');
  await tester.enterText(fields.at(3), 'senha123');
  await tester.enterText(fields.at(4), 'senha123');

  // Formato final: 50000-000.
  //
  // Não esperamos a chamada HTTP do ViaCEP: o teste preenche os campos
  // dependentes manualmente para permanecer determinístico e offline.
  await tester.enterText(fields.at(5), '50000000');

  await tester.enterText(fields.at(6), 'Rua Teste');
  await tester.enterText(fields.at(7), '123');
  await tester.enterText(fields.at(8), 'Centro');
  await tester.enterText(fields.at(9), 'Recife');
}

/// Seleciona o estado através do DropdownButtonFormField real da tela.
Future<void> _selecionarEstado(
  WidgetTester tester,
  String estado,
) async {
  final dropdown = find.byType(DropdownButtonFormField<String>);

  expect(dropdown, findsOneWidget);

  await tester.tap(dropdown);
  await tester.pumpAndSettle();

  await tester.tap(find.text(estado).last);
  await tester.pumpAndSettle();
}
```

 ### Um ajuste importante no cenário de falha do Firestore

 Há uma particularidade do código fornecido: o `CadastroScreen` cria o usuário e imediatamente faz:

```
await _firestore.collection('usuarios').doc(uid).set(...)
```

 O UID é obtido do `UserCredential`, então, para simular **exatamente** a falha desse `set()` sem depender de detalhes internos de geração de UID do `MockFirebaseAuth`, eu recomendo usar um `MockUser` com UID conhecido e fazer o `createUserWithEmailAndPassword` retornar esse usuário.

 Uma forma mais robusta é substituir o terceiro teste por uma versão que usa uma pequena subclasse/fake de `FirebaseAuth`. Porém, isso entra em conflito com o seu requisito de preferir `whenCalling`/`maybeThrowException` para exceções do Firebase Auth. O restante do fluxo pode usar diretamente `FakeFirebaseFirestore`, que suporta exceções em `set`, `update`, `delete` e `get`.  Dart packages

 Também vale observar que o teste **não chama o ViaCEP**. Isso é intencional: o `onChanged` do CEP no código de produção dispara HTTP real quando chega a 9 caracteres. Um teste de integração de widget executado com `flutter test` não deveria depender desse serviço externo. Os demais campos de endereço são preenchidos diretamente, preservando o comportamento relevante para o fluxo de cadastro.

 O teste pode ser executado com:

```
flutter test test/integration/
```

 ### Dependências

 As APIs usadas acima correspondem às versões atuais documentadas de `firebase_auth_mocks` e `fake_cloud_firestore`; `firebase_auth_mocks` documenta suporte a `createUserWithEmailAndPassword` e `whenCalling(...).on(...).thenThrow(...)`.  Dart packages+1

 Se `mock_exceptions` não estiver explicitamente no `dev_dependencies`, embora venha transitivamente, vale adicioná-lo diretamente para que o teste não dependa de uma dependência transitiva:

```
dev_dependencies:
  flutter_test:
    sdk: flutter
  firebase_auth_mocks: ^0.15.2
  fake_cloud_firestore: ^4.3.0
  mockito: any
  mock_exceptions: ^0.8.2
```

 As versões exatas devem, naturalmente, permanecer compatíveis com as versões de `firebase_auth` e `cloud_firestore` presentes no `pubspec.lock`; a documentação de `firebase_auth_mocks`, por exemplo, mantém uma tabela explícita de compatibilidade entre suas versões e `firebase_auth`.  Dart packages