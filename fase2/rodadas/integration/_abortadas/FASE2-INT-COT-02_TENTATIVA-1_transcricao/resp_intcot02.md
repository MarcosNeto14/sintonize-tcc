## 1\. Análise do fluxo

 O fluxo começa na `CadastroScreen`, onde o usuário preenche os dados pessoais, credenciais e endereço; após a validação local, a tela chama o Firebase Authentication e cria o documento correspondente em `usuarios/{uid}` no Firestore. Se essas operações forem concluídas, a aplicação navega para `GenerosCadastroScreen`, onde o usuário escolhe um ou mais gêneros musicais. Ao tocar em `Confirmar`, os gêneros selecionados são gravados no mesmo documento do usuário e, em caso de sucesso, ocorre a navegação para `TelaInicialScreen`. Os principais pontos de decisão são a validação do formulário, falha/sucesso do Firebase Auth, falha/s consegue verificar um loading visual que não existe; ele só pode aguucesso do Firestore, ausência de usuário autenticado ao salvar gêneros e a tentativa de confirmar sem selecionar nenhum gênero.

 ## 2\. Dependências e mocks

 | Tela | Dependência | Operação | Estratégia |
| --- | --- | --- | --- |
| `CadastroScreen` | Firebase Auth | `createUserWithEmailAndPassword` | `MockFirebaseAuth` |
| `CadastroScreen` | Firestore | `collection().doc().set()` | `FakeFirebaseFirestore` |
| `CadastroScreen` | HTTP | `GET https://viacep.com.br/...` | `HttpOverrides` para interceptar `http.get` |
| `GenerosCadastroScreen` | Firebase Auth | `currentUser` | `MockFirebaseAuth` |
| `GenerosCadastroScreen` | Firestore | `collection().doc().update()` | `FakeFirebaseFirestore` |
| Erros de Firestore | Firestore | `set/update` lançando exceção | mockito, usando mocks gerados |
| Erros de Auth | Firebase Auth | `createUserWithEmailAndPassword` lançando `FirebaseAuthException` | `MockFirebaseAuth` configurado com exceção |

Para o fluxo feliz, `FakeFirebaseFirestore` é suficiente e ainda permite verificar o documento efetivamente gravado. Para cenários em que precisamos obrigatoriamente fazer `set()` ou `update()` lançar uma exceção, é mais simples usar Mockito.

 Um detalhe importante do código fornecido: a chamada ao ViaCEP é feita diretamente por `http.get`, portanto não existe uma dependência HTTP injetável na tela. O teste abaixo usa `HttpOverrides` sem alterar o código de produção.

 ## 3\. Estrutura de navegação

 Como a `CadastroScreen` usa `Navigator.push` com `MaterialPageRoute`, não é necessário declarar essas duas rotas em `routes:` para a navegação principal funcionar. Basta iniciar o teste com:

```
MaterialApp(
  home: CadastroScreen(
    auth: auth,
    firestore: firestore,
  ),
)
```

 A própria `CadastroScreen` cria a `GenerosCadastroScreen` passando as mesmas instâncias de `auth` e `firestore`.

 Já a `GenerosCadastroScreen` navega para `TelaInicialScreen` sem dependências:

```
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const TelaInicialScreen(),
  ),
);
```

 No teste, portanto, podemos verificar a navegação por `find.text(...)` ou pelo tipo da rota atual, sem modificar as telas.

 Abaixo está um arquivo de teste completo. Ele usa `mockito` para os cenários que precisam forçar falhas de Firebase e `FakeFirebaseFirestore` para os fluxos normais.

 ## 4\. Cenários cobertos

 - Cadastro completo com sucesso:
  - validação;
  - Firebase Auth;
  - criação do documento Firestore;
  - navegação para gêneros;
  - seleção de gêneros;
  - atualização do documento;
  - navegação para tela inicial.
- Validação de nome inválido sem chamada ao Firebase.
- Validação de e-mail inválido sem chamada ao Firebase.
- Validação de senha curta sem chamada ao Firebase.
- Validação de senhas diferentes sem chamada ao Firebase.
- Validação de CEP inválido sem chamada ao Firebase.
- Validação de número inválido sem chamada ao Firebase.
- Data de nascimento inválida sem chamada ao Firebase.
- Falha do Firebase Auth e SnackBar correspondente.
- Falha do Firestore durante a criação do usuário e mensagem de erro.
- Tentativa de confirmar gêneros sem selecionar nenhum.
- Falha do Firestore ao salvar gêneros.
- Usuário não autenticado ao salvar gêneros.
- Estado de loading: **não existe indicador de loading implementado nas telas fornecidas**, então não há um estado visual de loading real que possa ser validado sem modificar o código. O teste de erro/sucesso aguarda as operações assíncronas e valida os estados visíveis resultantes.

 ## 5\. Testes

 Como alguns testes precisam mockar `FirebaseAuth`/Firestore diretamente, gere os mocks do Mockito com `build_runner`. O arquivo abaixo pressupõe que exista `test/mocks.mocks.dart`, gerado a partir das anotações presentes no próprio arquivo.

```
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';

import 'cadastro_fluxo_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de cadastro e seleção de gêneros', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;

    setUp(() {
      firestore = FakeFirebaseFirestore();

      auth = MockFirebaseAuth(
        signedIn: false,
      );
    });

    testWidgets(
      'fluxo completo: cadastro -> gêneros -> tela inicial',
      (tester) async {
        final mockUser = MockUser(
          uid: 'usuario-123',
          email: 'joao@example.com',
          displayName: 'João',
        );

        auth = MockFirebaseAuth(
          signedIn: false,
          mockUser: mockUser,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Nome
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome'),
          'João Silva',
        );

        // Data de nascimento
        await tester.enterText(
          find.widgetWithText(
            TextFormField,
            'Data de Nascimento',
          ),
          '01011990',
        );

        // E-mail
        await tester.enterText(
          find.widgetWithText(TextFormField, 'E-mail'),
          'joao@example.com',
        );

        // Senha
        final textFields = find.byType(TextFormField);

        // Os dois campos de senha são encontrados por posição.
        await tester.enterText(textFields.at(3), '123456');
        await tester.enterText(textFields.at(4), '123456');

        // CEP.
        //
        // O teste instala um HttpOverrides que intercepta a chamada
        // para o ViaCEP.
        await tester.enterText(
          find.widgetWithText(TextFormField, 'CEP'),
          '01001000',
        );

        await tester.pump();

        // Aguarda o GET do ViaCEP.
        await tester.pumpAndSettle();

        // Número
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Número'),
          '100',
        );

        // Estado.
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pump();

        await tester.tap(find.text('SP').last);
        await tester.pump();

        // O endereço pode ter sido preenchido pelo mock do ViaCEP.
        expect(
          find.text('Praça da Sé'),
          findsOneWidget,
        );

        // Cadastra.
        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        // A tela de gêneros deve ter aparecido.
        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        // Seleciona Rock.
        final rockText = find.text('Rock');
        expect(rockText, findsOneWidget);

        final rockSwitch = find.ancestor(
          of: rockText,
          matching: find.byType(Card),
        );

        await tester.tap(
          find.descendant(
            of: rockSwitch,
            matching: find.byType(Switch),
          ),
        );

        await tester.pump();

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

        await tester.pump();

        // Confirma.
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        // A tela inicial deve ter sido alcançada.
        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );

        // Verifica o documento criado e posteriormente atualizado.
        final document = await firestore
            .collection('usuarios')
            .doc(mockUser.uid)
            .get();

        expect(document.exists, isTrue);

        expect(document.data()?['nome'], 'João Silva');
        expect(document.data()?['email'], 'joao@example.com');

        expect(
          document.data()?['generos_favoritos'],
          containsAll(<String>['Rock', 'Pop']),
        );
      },
    );

    testWidgets(
      'nome inválido impede o cadastro e não chama Firebase Auth',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome'),
          'João123',
        );

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(
          find.text(
            'O nome não pode conter números ou caracteres especiais',
          ),
          findsOneWidget,
        );

        verifyNever(
          auth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        );
      },
    );

    testWidgets(
      'e-mail inválido impede o cadastro e não chama Firebase Auth',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome'),
          'João Silva',
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'E-mail'),
          'email-invalido',
        );

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(
          find.text('E-mail inválido'),
          findsOneWidget,
        );

        verifyNever(
          auth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        );
      },
    );

    testWidgets(
      'senha menor que 6 caracteres impede o cadastro',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        final textFields = find.byType(TextFormField);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome'),
          'João Silva',
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'E-mail'),
          'joao@example.com',
        );

        await tester.enterText(
          textFields.at(3),
          '123',
        );

        await tester.enterText(
          textFields.at(4),
          '123',
        );

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );

        verifyNever(
          auth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        );
      },
    );

    testWidgets(
      'senhas diferentes impedem o cadastro',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        final textFields = find.byType(TextFormField);

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome'),
          'João Silva',
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'E-mail'),
          'joao@example.com',
        );

        await tester.enterText(
          textFields.at(3),
          '123456',
        );

        await tester.enterText(
          textFields.at(4),
          '654321',
        );

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(
          find.text('As senhas não coincidem'),
          findsOneWidget,
        );

        verifyNever(
          auth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        );
      },
    );

    testWidgets(
      'CEP inválido impede o cadastro',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome'),
          'João Silva',
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'E-mail'),
          'joao@example.com',
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'CEP'),
          '123',
        );

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(
          find.text('CEP inválido. Formato correto: XXXXX-XXX'),
          findsOneWidget,
        );

        verifyNever(
          auth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        );
      },
    );

    testWidgets(
      'número do endereço não numérico impede o cadastro',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome'),
          'João Silva',
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'E-mail'),
          'joao@example.com',
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Número'),
          'abc',
        );

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(
          find.text('O número deve ser numérico'),
          findsOneWidget,
        );

        verifyNever(
          auth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        );
      },
    );

    testWidgets(
      'data de nascimento inválida impede o cadastro',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Data de Nascimento'),
          '31132000',
        );

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(
          find.text('Mês deve ser entre 01 e 12'),
          findsOneWidget,
        );

        verifyNever(
          auth.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        );
      },
    );

    testWidgets(
      'falha no Firebase Auth exibe mensagem de erro',
      (tester) async {
        final authWithError = MockFirebaseAuth(
          signedIn: false,
          exceptionForCreateUserWithEmailAndPassword:
              FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'O e-mail já está cadastrado.',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: authWithError,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await _preencherCadastroMinimo(
          tester,
          cep: '01001000',
        );

        await tester.tap(find.text('Cadastrar'));

        // Primeiro frame enquanto a Future está pendente.
        await tester.pump();

        await tester.pumpAndSettle();

        expect(
          find.text(
            'Erro ao cadastrar: O e-mail já está cadastrado.',
          ),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'falha no Firestore ao criar usuário exibe erro desconhecido',
      (tester) async {
        final authSuccess = MockFirebaseAuth(
          signedIn: false,
          mockUser: MockUser(
            uid: 'usuario-firestore-error',
            email: 'joao@example.com',
          ),
        );

        final firestoreMock = MockFirebaseFirestore();
        final usuarios = MockCollectionReference();
        final documento = MockDocumentReference();

        when(firestoreMock.collection('usuarios'))
            .thenReturn(usuarios);

        when(usuarios.doc('usuario-firestore-error'))
            .thenReturn(documento);

        when(documento.set(any))
            .thenThrow(Exception('Firestore indisponível'));

        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: authSuccess,
              firestore: firestoreMock,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await _preencherCadastroMinimo(
          tester,
          cep: '01001000',
        );

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Erro desconhecido:'),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'confirmar sem gênero selecionado exibe mensagem de validação',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Confirmar'));
        await tester.pump();

        expect(
          find.text(
            'Selecione pelo menos um gênero musical!',
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
      'usuário não autenticado não salva gêneros nem navega',
      (tester) async {
        final unauthenticatedAuth = MockFirebaseAuth(
          signedIn: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: unauthenticatedAuth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

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

        await tester.pump();

        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'falha do Firestore ao salvar gêneros exibe mensagem de erro',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-generos-error',
          email: 'joao@example.com',
        );

        final authMock = MockFirebaseAuth(
          signedIn: true,
          mockUser: user,
        );

        final firestoreMock = MockFirebaseFirestore();
        final usuarios = MockCollectionReference();
        final documento = MockDocumentReference();

        when(firestoreMock.collection('usuarios'))
            .thenReturn(usuarios);

        when(usuarios.doc(user.uid))
            .thenReturn(documento);

        when(documento.update(any))
            .thenThrow(Exception('Firestore indisponível'));

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: authMock,
              firestore: firestoreMock,
            ),
          ),
        );

        await tester.pumpAndSettle();

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

        await tester.pump();

        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        expect(
          find.text('Erro ao salvar os gêneros!'),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );
  });
}

/// Preenche os campos necessários para passar pela validação do formulário.
///
/// O teste não depende dos valores preenchidos automaticamente pelo ViaCEP.
/// Depois do CEP ser digitado, os campos obrigatórios são preenchidos
/// explicitamente quando necessário.
Future<void> _preencherCadastroMinimo(
  WidgetTester tester, {
  required String cep,
}) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Nome'),
    'João Silva',
  );

  await tester.enterText(
    find.widgetWithText(
      TextFormField,
      'Data de Nascimento',
    ),
    '01011990',
  );

  await tester.enterText(
    find.widgetWithText(TextFormField, 'E-mail'),
    'joao@example.com',
  );

  final textFields = find.byType(TextFormField);

  await tester.enterText(
    textFields.at(3),
    '123456',
  );

  await tester.enterText(
    textFields.at(4),
    '123456',
  );

  await tester.enterText(
    find.widgetWithText(TextFormField, 'CEP'),
    cep,
  );

  await tester.pumpAndSettle();

  await tester.enterText(
    find.widgetWithText(TextFormField, 'Número'),
    '100',
  );

  // Garante que o estado esteja selecionado independentemente
  // do resultado do mock do ViaCEP.
  await tester.tap(
    find.byType(DropdownButtonFormField<String>),
  );

  await tester.pump();

  await tester.tap(find.text('SP').last);
  await tester.pump();
}

/// Intercepta o acesso HTTP feito diretamente pelo código da tela.
///
/// Este override deve ser instalado no teste que exercita o preenchimento
/// do CEP, antes do widget ser construído.
class _ViaCepHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient();
  }
}

/// HttpClient mínimo para interceptar a chamada do ViaCEP.
class _FakeHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _FakeHttpClientRequest(url);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeHttpClientRequest implements HttpClientRequest {
  final Uri url;

  _FakeHttpClientRequest(this.url);

  @override
  Future<HttpClientResponse> close() async {
    return _FakeHttpClientResponse();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class _FakeHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    const body = '''
{
  "cep": "01001-000",
  "logradouro": "Praça da Sé",
  "complemento": "lado ímpar",
  "bairro": "Sé",
  "localidade": "São Paulo",
  "uf": "SP",
  "ibge": "3550308",
  "gia": "1004",
  "ddd": "11",
  "siafi": "7107"
}
''';

    final bytes = utf8.encode(body);

    return Stream<List<int>>.fromIterable([bytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
```

 ### Ajuste necessário no `HttpOverrides`

 Há uma particularidade importante: o teste acima precisa instalar o `_ViaCepHttpOverrides` antes dos testes que digitam o CEP. Como `HttpOverrides` é global, recomendo fazer isso no `setUpAll` e restaurá-lo no `tearDownAll`:

```
setUpAll(() {
  HttpOverrides.global = _ViaCepHttpOverrides();
});

tearDownAll(() {
  HttpOverrides.global = null;
});
```

 Assim, o início do `main()` fica:

```
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = _ViaCepHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('Fluxo de cadastro e seleção de gêneros', () {
    // ...
  });
}
```

 Há também uma limitação estrutural do código original que vale destacar: **não existe estado de loading na UI**. `_submit()` e `_salvarGeneros()` aguardam as Futures, mas nenhum `CircularProgressIndicator`, texto de "carregando" ou desabilitação do botão é produzido. Portanto, um teste não consegue verificar um loading visual que não existe; ele só pode aguardar a conclusão da operação e verificar sucesso ou erro.

 Para gerar os mocks do Mockito, caso ainda não exista o arquivo `cadastro_fluxo_test.mocks.dart`, execute:

```
dart run build_runner build --delete-conflicting-outputs
```

 E depois:

```
flutter test test/cadastro_fluxo_test.dart
```

 Um ponto adicional: como o fluxo real usa `Navigator.push` com `MaterialPageRoute`, **não é necessário alterar nenhuma das telas nem adicionar rotas nomeadas**. Os testes acima passam as dependências mockadas diretamente para as telas, preservando o código de produção.
