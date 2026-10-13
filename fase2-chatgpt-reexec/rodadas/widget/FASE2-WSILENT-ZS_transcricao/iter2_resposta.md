**Classificação: (A) — o teste presume condições que não são especificadas pelo `LoginScreen` isoladamente.**

 Há dois problemas diferentes, ambos no ambiente/teste:

 1. O login válido realmente navega para `TelaInicialScreen`, mas essa tela chama `FirebaseAuth.instance`, que não foi inicializado no teste. Isso é visível no stack trace:\
    `TelaInicialScreen → FirebaseAuth.instance → Firebase.app()`.\
    O `MockFirebaseAuth` foi corretamente injetado no `LoginScreen`, mas **não é automaticamente o `FirebaseAuth.instance` global usado pela tela seguinte**.
2. O teste de cadastro tenta tocar em um botão que está fora da área visível (`800x600`). O próprio Flutter informa que o `TextButton` está em `y=664`. Portanto, precisamos fazer `ensureVisible` antes do `tap`.

 Não há motivo para enfraquecer as asserções.

 ## Correção

 Para o teste de login válido, há uma solução mais adequada para um **widget test do `LoginScreen`**: não precisamos montar a implementação real de `TelaInicialScreen` para verificar que o login provocou a navegação. Podemos fornecer uma rota inicial que capture a navegação? O problema é que o `LoginScreen` cria diretamente:

```
MaterialPageRoute(
  builder: (context) => const TelaInicialScreen(),
)
```

 Logo, a tela real será construída.

 Nesse caso, como o teste pretende verificar o fluxo completo até a tela inicial, precisamos inicializar Firebase no ambiente de teste **ou** modificar a arquitetura do aplicativo para permitir injeção da dependência também em `TelaInicialScreen`.

 Como você pediu testes para o código existente, a primeira alternativa é a mais apropriada.

 ### 1\. Inicialize o Firebase nos testes

 Adicione:

```
import 'package:firebase_core/firebase_core.dart';
```

 e, antes dos testes, inicialize o Firebase.

 Porém, há um detalhe: uma inicialização Firebase real pode exigir configuração específica da plataforma. Para esse projeto, como o teste já usa `firebase_auth_mocks`, é melhor **não transformar todos os testes em testes dependentes do Firebase real**.

 Portanto, recomendo separar o teste de autenticação do teste de navegação para a tela real e, para o teste de login, verificar a autenticação sem chamar `pumpAndSettle()` depois da navegação.

 Mas há uma consequência importante: `signInWithEmailAndPassword()` conclui e o widget imediatamente executa `Navigator.pushReplacement`. Não conseguimos observar `currentUser` de forma confiável depois que a `TelaInicialScreen` é construída sem lidar com essa dependência.

 A solução mais robusta para o projeto é testar a navegação usando uma implementação controlável da tela inicial. Como `LoginScreen` instancia a tela diretamente, isso exige uma pequena refatoração de produção.

 ### 2\. Há uma pequena melhoria recomendada no `LoginScreen`

 Altere o construtor para permitir uma fábrica de tela inicial:

```
final Widget Function() telaInicialBuilder;

LoginScreen({
  super.key,
  FirebaseAuth? auth,
  Widget Function()? telaInicialBuilder,
})  : auth = auth ?? FirebaseAuth.instance,
      telaInicialBuilder =
          telaInicialBuilder ?? (() => const TelaInicialScreen());
```

 E troque:

```
MaterialPageRoute(
  builder: (context) => const TelaInicialScreen(),
),
```

 por:

```
MaterialPageRoute(
  builder: (context) => telaInicialBuilder(),
),
```

 Isso não muda o comportamento da aplicação em produção: por padrão ela continua abrindo `TelaInicialScreen`.

 Então o teste pode fornecer uma tela falsa:

```
LoginScreen(
  auth: mockAuth,
  telaInicialBuilder: () => const Scaffold(
    body: Text('Tela inicial de teste'),
  ),
)
```

 Essa é uma mudança de testabilidade, não uma alteração da regra de negócio.

 ## Teste corrigido

 Com essa pequena alteração no `login.dart`, substitua os testes de autenticação/navegação pelo seguinte:

 Testes corrigidos de autenticação e navegação

```
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/recup-senha.dart';

void main() {
  late MockFirebaseAuth mockAuth;

  Widget createTestWidget({
    Widget Function()? telaInicialBuilder,
  }) {
    return MaterialApp(
      home: LoginScreen(
        auth: mockAuth,
        telaInicialBuilder: telaInicialBuilder,
      ),
    );
  }

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  Future<void> preencherFormulario(
    WidgetTester tester, {
    String email = 'usuario@email.com',
    String senha = '123456',
  }) async {
    final fields = find.byType(TextFormField);

    await tester.enterText(fields.at(0), email);
    await tester.enterText(fields.at(1), senha);
  }

  group('LoginScreen - autenticação', () {
    testWidgets(
      'deve realizar login com credenciais válidas',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            telaInicialBuilder: () => const Scaffold(
              body: Text('Tela inicial de teste'),
            ),
          ),
        );

        await preencherFormulario(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          mockAuth.currentUser,
          isNotNull,
        );

        expect(
          mockAuth.currentUser!.email,
          'usuario@email.com',
        );

        expect(
          find.text('Tela inicial de teste'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'não deve autenticar quando o formulário é inválido',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          mockAuth.currentUser,
          isNull,
        );
      },
    );
  });

  group('LoginScreen - navegação', () {
    testWidgets(
      'deve navegar para recuperação de senha',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.text('Esqueci minha senha'));
        await tester.pumpAndSettle();

        expect(
          find.byType(RecupSenhaScreen),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve navegar para cadastro',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final cadastroButton = find.text(
          'Não tem cadastro? Cadastre-se!',
        );

        await tester.ensureVisible(cadastroButton);
        await tester.tap(cadastroButton);

        await tester.pumpAndSettle();

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );
      },
    );
  });

  group('LoginScreen - erros do Firebase Auth', () {
    testWidgets(
      'deve mostrar mensagem para user-not-found',
      (WidgetTester tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
            {
              #email: anything,
              #password: anything,
            },
          ),
        ).on(mockAuth).thenThrow(
          FirebaseAuthException(
            code: 'user-not-found',
          ),
        );

        await tester.pumpWidget(createTestWidget());

        await preencherFormulario(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'Senha incorreta. Certifique-se de que está digitando '
            'a senha corretamente.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve mostrar mensagem para wrong-password',
      (WidgetTester tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
            {
              #email: anything,
              #password: anything,
            },
          ),
        ).on(mockAuth).thenThrow(
          FirebaseAuthException(
            code: 'wrong-password',
          ),
        );

        await tester.pumpWidget(createTestWidget());

        await preencherFormulario(tester);

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
      'deve mostrar mensagem para invalid-credential',
      (WidgetTester tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
            {
              #email: anything,
              #password: anything,
            },
          ),
        ).on(mockAuth).thenThrow(
          FirebaseAuthException(
            code: 'invalid-credential',
          ),
        );

        await tester.pumpWidget(createTestWidget());

        await preencherFormulario(tester);

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
      'deve mostrar mensagem genérica para código desconhecido',
      (WidgetTester tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
            {
              #email: anything,
              #password: anything,
            },
          ),
        ).on(mockAuth).thenThrow(
          FirebaseAuthException(
            code: 'unknown-error',
          ),
        );

        await tester.pumpWidget(createTestWidget());

        await preencherFormulario(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text(
            'Erro inesperado ao fazer login. '
            'Por favor, tente novamente mais tarde.',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
```

 ## Alteração necessária no `login.dart`

 O construtor fica assim:

 Ajuste de testabilidade no LoginScreen

```
class LoginScreen extends StatelessWidget {
  final FirebaseAuth auth;
  final Widget Function() telaInicialBuilder;

  LoginScreen({
    super.key,
    FirebaseAuth? auth,
    Widget Function()? telaInicialBuilder,
  })  : auth = auth ?? FirebaseAuth.instance,
        telaInicialBuilder =
            telaInicialBuilder ?? (() => const TelaInicialScreen());

  @override
  Widget build(BuildContext context) {
    // ...
```

 E a navegação:

```
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => telaInicialBuilder(),
  ),
);
```

 ### Por que não inicializar Firebase apenas para esse teste?

 Porque isso faria o teste de `LoginScreen` depender de uma infraestrutura que ele próprio não precisa para autenticar: o `FirebaseAuth` já está sendo injetado.

 O problema aparece somente porque **a navegação constrói uma segunda tela que ignora a dependência injetada** e chama `FirebaseAuth.instance` diretamente.

 Assim, a falha revelou uma questão de testabilidade da composição das telas, mas, para o objetivo do teste, a correção mais limpa é permitir a injeção da tela seguinte.

 E o segundo erro é puramente de viewport: `ensureVisible()` deve ser usado antes do `tap` no botão de cadastro, porque o layout do `SingleChildScrollView` colocou o botão abaixo dos 600 px disponíveis.

 **Importante:** mantive intactas as asserções das mensagens `user-not-found`/`wrong-password`. Como observado anteriormente, elas parecem semanticamente trocadas no aplicativo; isso é uma possível questão de **(B)** na implementação, não algo que devemos mascarar no teste.