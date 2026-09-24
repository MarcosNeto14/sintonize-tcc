**Classificação: (A) o teste presume uma API que não existe na versão instalada de `firebase_auth_mocks` 0.14.2.**

 O erro acontece antes de qualquer teste ser executado. O `MockFirebaseAuth` não possui os setters que eu usei:

```
authComErro.mockUserCredentials = ...
authComErro.signInWithEmailAndPassword = ...
```

 Essas linhas foram incorretas para a API dessa versão. **Não há evidência de problema no `LoginScreen`**, portanto devemos corrigir o teste.

 A maneira adequada aqui é usar `MockFirebaseAuth` com `whenCalling(...).on(...).thenThrow(...)`, que é justamente o mecanismo oferecido pela versão instalada. Para evitar outra suposição sobre APIs internas, também podemos usar uma função auxiliar para configurar cada erro.

 Widget tests corrigidos para firebase\_auth\_mocks 0.14.2

```
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginScreen Widget', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    Widget createWidget(FirebaseAuth auth) {
      return MaterialApp(
        home: LoginScreen(auth: auth),
      );
    }

    Future<void> preencherFormulario(
      WidgetTester tester, {
      String email = 'usuario@test.com',
      String senha = 'senha123',
    }) async {
      final campos = find.byType(TextFormField);

      await tester.enterText(campos.at(0), email);
      await tester.enterText(campos.at(1), senha);
    }

    MockFirebaseAuth criarAuthComErro(String codigo) {
      final auth = MockFirebaseAuth();

      whenCalling(
        Invocation.method(
          #signInWithEmailAndPassword,
          null,
          {
            #email: 'usuario@test.com',
            #password: 'senha123',
          },
        ),
      ).on(auth).thenThrow(
            FirebaseAuthException(code: codigo),
          );

      return auth;
    }

    testWidgets(
      'deve exibir erro quando o e-mail está vazio',
      (tester) async {
        await tester.pumpWidget(createWidget(mockAuth));

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir erro quando o e-mail é inválido',
      (tester) async {
        await tester.pumpWidget(createWidget(mockAuth));

        await preencherFormulario(
          tester,
          email: 'email-invalido',
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
      'deve exibir erro quando a senha está vazia',
      (tester) async {
        await tester.pumpWidget(createWidget(mockAuth));

        await preencherFormulario(
          tester,
          senha: '',
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
      'deve exibir erro quando a senha tem menos de 6 caracteres',
      (tester) async {
        await tester.pumpWidget(createWidget(mockAuth));

        await preencherFormulario(
          tester,
          senha: '12345',
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
      'deve exibir mensagem para user-not-found',
      (tester) async {
        final authComErro = criarAuthComErro('user-not-found');

        await tester.pumpWidget(createWidget(authComErro));

        await preencherFormulario(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Senha incorreta. Certifique-se de que está digitando '
            'a senha corretamente.',
          ),
          findsOneWidget,
        );

        expect(
          find.byType(SnackBar),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir mensagem para wrong-password',
      (tester) async {
        final authComErro = criarAuthComErro('wrong-password');

        await tester.pumpWidget(createWidget(authComErro));

        await preencherFormulario(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir mensagem para invalid-credential',
      (tester) async {
        final authComErro = criarAuthComErro('invalid-credential');

        await tester.pumpWidget(createWidget(authComErro));

        await preencherFormulario(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'As credenciais fornecidas são inválidas. Tente novamente.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir mensagem genérica para erro desconhecido',
      (tester) async {
        final authComErro = criarAuthComErro('unknown-error');

        await tester.pumpWidget(createWidget(authComErro));

        await preencherFormulario(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Erro inesperado ao fazer login. '
            'Por favor, tente novamente mais tarde.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve realizar login com credenciais válidas',
      (tester) async {
        await tester.pumpWidget(createWidget(mockAuth));

        await preencherFormulario(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          mockAuth.currentUser,
          isNotNull,
        );

        expect(
          mockAuth.currentUser!.email,
          'usuario@test.com',
        );
      },
    );
  });
}
```

 ### O que foi corrigido

 A parte problemática anterior:

```
authComErro.signInWithEmailAndPassword = (...) async {
  throw FirebaseAuthException(...);
};
```

 foi removida.

 Agora o mock é configurado pela API de interceptação:

```
whenCalling(
  Invocation.method(
    #signInWithEmailAndPassword,
    null,
    {
      #email: 'usuario@test.com',
      #password: 'senha123',
    },
  ),
).on(auth).thenThrow(
  FirebaseAuthException(code: codigo),
);
```

 Isso é particularmente importante porque o `LoginScreen` chama:

```
await auth.signInWithEmailAndPassword(
  email: email,
  password: senha,
);
```

 e, nos testes de erro, queremos que **essa chamada específica** produza a exceção correspondente.

 ### Uma ressalva importante

 O arquivo acima continua contendo a implementação de `LoginScreen` apenas se você estiver usando a versão autocontida que enviei anteriormente. Se o seu arquivo de teste **já contém a classe `LoginScreen` real**, mantenha-a.

 Se você estiver testando a classe que está no projeto, o ideal é substituir a implementação duplicada por:

```
import 'package:sintonize/SEU_CAMINHO_REAL.dart';
```

 e deixar somente os testes.

 Também mantive deliberadamente estas duas asserções:

 - `user-not-found` → `"Senha incorreta..."`
- `wrong-password` → `"Usuário não encontrado..."`

 porque são exatamente as mensagens produzidas pelo código que você forneceu. **Não vou inverter as asserções apenas para corresponder ao significado convencional dos códigos do Firebase**; isso seria alterar o teste diante de um possível problema da aplicação. Se posteriormente o teste executar e demonstrar essa divergência como comportamento indesejado, aí temos um caso separado para analisar.