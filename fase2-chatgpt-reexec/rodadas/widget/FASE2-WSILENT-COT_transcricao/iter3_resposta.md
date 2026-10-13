**Classificação: (A) — o teste foi montado com APIs/dependências incompatíveis com o código atual do projeto.**

 O novo erro é, principalmente, consequência da correção anterior ter deixado o arquivo em um estado misto: removemos o import/declarações do Mockito, mas ainda existem testes que usam `when`, `MockFirebaseAuthWithMockito` e `MockUserCredential`. Além disso, o `whenCalling` pertence ao mecanismo `mock_exceptions` usado pelo `firebase_auth_mocks`, mas ele **não é exportado automaticamente pelo import de `firebase_auth_mocks`**; portanto, é necessário importar `mock_exceptions` explicitamente. A documentação do `firebase_auth_mocks` confirma que a versão 0.14.x usa esse padrão para configurar exceções.  Dart packages+1

 A correção mais limpa agora é **padronizar o arquivo inteiro em `MockFirebaseAuth` \+ `mock_exceptions`**, sem Mockito.

 ## 1\. Imports corretos

 No topo do teste, use:

```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:sintonize/login.dart';
```

 O `mockito` pode ser removido deste arquivo.

 Também remova completamente:

```
class MockFirebaseAuthWithMockito extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}
```

 Não precisamos dessas classes.

 O `firebase_auth_mocks` 0.14.x é compatível com `firebase_auth` 5.x, que é exatamente a combinação que aparece no seu `pub get`.  Dart packages+1

 ## 2\. Um detalhe importante sobre `whenCalling`

 O formato correto é:

```
whenCalling(
  Invocation.method(
    #signInWithEmailAndPassword,
    null,
    {
      #email: 'usuario@email.com',
      #password: '123456',
    },
  ),
)
    .on(auth)
    .thenThrow(
      FirebaseAuthException(code: 'invalid-credential'),
    );
```

 O terceiro argumento de `Invocation.method` contém os parâmetros nomeados.

 A documentação do pacote mostra que é possível omitir os parâmetros nomeados para aceitar qualquer valor, mas, para estes testes, é melhor especificá-los explicitamente.  Dart packages

---

 # 3\. Versão corrigida dos testes

 Eu recomendo substituir o arquivo atual **inteiro** por esta versão, em vez de continuar corrigindo pedaços do arquivo anterior:

 Teste completo do LoginScreen

```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:sintonize/login.dart';

void main() {
  Widget createTestWidget(FirebaseAuth auth) {
    return MaterialApp(
      home: LoginScreen(auth: auth),
    );
  }

  group('LoginScreen - Renderização', () {
    testWidgets(
      'deve renderizar os elementos principais',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
        expect(find.text('Entrar'), findsOneWidget);

        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
      },
    );

    testWidgets(
      'deve renderizar o logo',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        expect(find.byType(Image), findsOneWidget);
      },
    );

    testWidgets(
      'deve permitir scroll vertical da tela',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 400),
              ),
              child: LoginScreen(auth: auth),
            ),
          ),
        );

        final scrollable = find.byType(SingleChildScrollView);

        expect(scrollable, findsOneWidget);

        await tester.drag(
          scrollable,
          const Offset(0, -200),
        );

        await tester.pump();

        expect(scrollable, findsOneWidget);
      },
    );
  });

  group('LoginScreen - Validação', () {
    testWidgets(
      'deve exibir erro quando o e-mail estiver vazio',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsOneWidget,
        );

        expect(
          find.text('Por favor, insira sua senha'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir erro para e-mail inválido',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'email-invalido',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira um e-mail válido'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir erro quando a senha estiver vazia',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira sua senha'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir erro para senha com menos de 6 caracteres',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '12345',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve aceitar e-mail e senha válidos',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.pump();

        // Não pressionamos "Entrar" neste teste.
        // Aqui testamos somente a aceitação dos valores pelos validators.
        expect(
          find.text('Por favor, insira seu e-mail'),
          findsNothing,
        );

        expect(
          find.text('Por favor, insira um e-mail válido'),
          findsNothing,
        );

        expect(
          find.text('Por favor, insira sua senha'),
          findsNothing,
        );

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'não deve chamar Firebase quando o formulário for inválido',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        )
            .on(auth)
            .thenThrow(
              StateError(
                'Firebase Auth não deveria ter sido chamado',
              ),
            );

        await tester.pumpWidget(createTestWidget(auth));

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsOneWidget,
        );

        expect(
          find.text('Por favor, insira sua senha'),
          findsOneWidget,
        );
      },
    );
  });

  group('LoginScreen - Interação', () {
    testWidgets(
      'deve preencher o campo de e-mail',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        final emailField = find.byType(TextFormField).at(0);

        await tester.enterText(
          emailField,
          'teste@example.com',
        );

        expect(
          find.text('teste@example.com'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve preencher o campo de senha',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        final passwordField = find.byType(TextFormField).at(1);

        await tester.enterText(
          passwordField,
          'senha123',
        );

        expect(
          find.text('senha123'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'campo de senha deve utilizar obscureText',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        final textFields = find.byType(TextField);

        expect(
          textFields,
          findsNWidgets(2),
        );

        final passwordTextField = tester.widget<TextField>(
          textFields.at(1),
        );

        expect(
          passwordTextField.obscureText,
          isTrue,
        );
      },
    );
  });

  group('LoginScreen - Firebase Auth', () {
    testWidgets(
      'deve realizar login com credenciais válidas',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));

        // O login é assíncrono.
        await tester.pump();

        expect(
          auth.currentUser,
          isNotNull,
        );
      },
    );

    testWidgets(
      'deve exibir mensagem correta para user-not-found',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        )
            .on(auth)
            .thenThrow(
              FirebaseAuthException(
                code: 'user-not-found',
              ),
            );

        await tester.pumpWidget(createTestWidget(auth));

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir mensagem correta para wrong-password',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        )
            .on(auth)
            .thenThrow(
              FirebaseAuthException(
                code: 'wrong-password',
              ),
            );

        await tester.pumpWidget(createTestWidget(auth));

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir mensagem correta para invalid-credential',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        )
            .on(auth)
            .thenThrow(
              FirebaseAuthException(
                code: 'invalid-credential',
              ),
            );

        await tester.pumpWidget(createTestWidget(auth));

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'As credenciais fornecidas são inválidas. Tente novamente.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir mensagem genérica para network-request-failed',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        )
            .on(auth)
            .thenThrow(
              FirebaseAuthException(
                code: 'network-request-failed',
              ),
            );

        await tester.pumpWidget(createTestWidget(auth));

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir mensagem genérica para código desconhecido',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        )
            .on(auth)
            .thenThrow(
              FirebaseAuthException(
                code: 'codigo-desconhecido',
              ),
            );

        await tester.pumpWidget(createTestWidget(auth));

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('LoginScreen - SnackBar', () {
    testWidgets(
      'deve exibir SnackBar vermelho em caso de erro',
      (tester) async {
        final auth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        )
            .on(auth)
            .thenThrow(
              FirebaseAuthException(
                code: 'invalid-credential',
              ),
            );

        await tester.pumpWidget(createTestWidget(auth));

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        final snackBar = tester.widget<SnackBar>(
          find.byType(SnackBar),
        );

        expect(
          snackBar.backgroundColor,
          Colors.red,
        );
      },
    );

    testWidgets(
      'não deve exibir SnackBar quando o login for bem-sucedido',
      (tester) async {
        final auth = MockFirebaseAuth();

        await tester.pumpWidget(createTestWidget(auth));

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));

        await tester.pump();

        expect(
          find.byType(SnackBar),
          findsNothing,
        );
      },
    );
  });
}
```

 ## 4\. E a navegação?

 Eu **não colocaria o teste de navegação nessa versão isolada do `LoginScreen` ainda**.

 O problema não é a asserção:

```
expect(find.byType(LoginScreen), findsNothing);
```

 O problema é que o destino é construído diretamente pelo widget:

```
MaterialPageRoute(
  builder: (context) => const TelaInicialScreen(),
)
```

 e `TelaInicialScreen` imediatamente executa:

```
FirebaseAuth.instance
```

 Isso foi confirmado pelo stack trace que você forneceu.

 Portanto, temos duas coisas diferentes:

 - **Comportamento esperado do LoginScreen:** login bem-sucedido → `pushReplacement` para `TelaInicialScreen`.
- **Problema encontrado durante o teste:** a `TelaInicialScreen` possui uma dependência global em `FirebaseAuth.instance` que não está inicializada no ambiente do teste.

 Não devemos eliminar a cobertura da navegação apenas para obter um teste verde. O teste de navegação pode ser tratado separadamente como teste de integração, com a inicialização/configuração apropriada do Firebase e das demais dependências de `TelaInicialScreen`.

 ### Por que a correção anterior estava errada

 A mensagem anterior sugeriu que `whenCalling` poderia ser usado sem adicionar explicitamente `mock_exceptions`. O erro atual mostra exatamente a consequência disso. O pacote `firebase_auth_mocks` documenta `whenCalling(...).on(...).thenThrow(...)`, mas esse mecanismo vem do pacote `mock_exceptions`, que aparece entre as dependências do pacote.  Dart packages

 Além disso, o seu projeto está em:

```
firebase_auth          5.5.0
firebase_auth_mocks    0.14.2
```

 Essa combinação é coerente com a tabela de compatibilidade publicada pelo pacote.  Dart packages

 Portanto, **não é necessário atualizar as dependências** para corrigir esse erro. O principal é limpar o arquivo de todos os vestígios do Mockito e importar `mock_exceptions` diretamente.