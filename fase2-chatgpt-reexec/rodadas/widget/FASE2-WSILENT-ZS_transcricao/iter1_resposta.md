**Classificação: (A) — o teste presume comportamentos/API que não são especificados pela versão instalada das dependências.**

 Os erros principais são do próprio teste:

 - `firebase_auth_mocks 0.14.2` não possui mais `AuthExceptions` nem o parâmetro `authExceptions`; desde a versão 0.10.0 a biblioteca usa `whenCalling(...).on(...).thenThrow(...)`.  Dart packages+1
- `MockFirebaseAuth` não fornece os getters `signInWithEmailAndPasswordCalled`, `...Email` e `...Password`. A API documentada oferece o método, mas não esses getters.  Dart packages
- `RecupSenhaScreen` e `CadastroScreen` não estavam importados no arquivo de teste.
- `TextFormField` não possui `obscureText`; essa propriedade está no `EditableText` interno.
- Portanto, **não é necessário enfraquecer os testes**. Basta adaptá-los à API efetivamente instalada.

 Para simular exceções com `firebase_auth_mocks 0.14.2`, a abordagem documentada é `whenCalling(...).on(...).thenThrow(...)`.  Dart packages+1

 Há ainda uma questão separada no **código da aplicação**: o `LoginScreen` associa `user-not-found` à mensagem "Senha incorreta" e `wrong-password` à mensagem "Usuário não encontrado". Isso parece semanticamente invertido. **Não vou alterar essa asserção no teste**, porque o teste deve registrar o comportamento atualmente implementado; se a intenção funcional for corrigir essas mensagens, isso deve ser uma alteração em `login.dart`.

 ## 1\. Ajuste no `pubspec.yaml`

 Como o mecanismo de exceções vem do pacote `mock_exceptions`, recomendo declará-lo explicitamente como dependência de desenvolvimento, em vez de depender apenas da dependência transitiva de `firebase_auth_mocks`:

 Dependências de teste

```
dev_dependencies:
  flutter_test:
    sdk: flutter

  firebase_auth_mocks: ^0.14.2
  mock_exceptions: ^0.8.2
  mockito: ^5.6.4
  fake_cloud_firestore: ^3.1.0
```

 A documentação de `firebase_auth_mocks` confirma que `mock_exceptions` é o mecanismo usado para configurar exceções no `MockFirebaseAuth`.  Dart packages+1

 Depois execute:

```
flutter pub get
```

 ## 2\. Teste corrigido

 Substitua o conteúdo do seu `wsilent_zs_test.dart` por:

 test/fase2-chatgpt-reexec/widget/wsilent\_zs\_test.dart

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

  Widget createTestWidget() {
    return MaterialApp(
      home: LoginScreen(auth: mockAuth),
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

  group('LoginScreen - renderização', () {
    testWidgets(
      'deve renderizar os campos e botões principais',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('Esqueci minha senha'), findsOneWidget);
        expect(
          find.text('Não tem cadastro? Cadastre-se!'),
          findsOneWidget,
        );
      },
    );
  });

  group('LoginScreen - validação', () {
    testWidgets(
      'deve mostrar erro quando os campos estão vazios',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

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

        // O formulário é inválido, portanto o mock continua
        // sem usuário autenticado.
        expect(mockAuth.currentUser, isNull);
      },
    );

    testWidgets(
      'deve mostrar erro para e-mail inválido',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await preencherFormulario(
          tester,
          email: 'email-invalido',
          senha: '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira um e-mail válido'),
          findsOneWidget,
        );

        expect(mockAuth.currentUser, isNull);
      },
    );

    testWidgets(
      'deve mostrar erro para senha com menos de 6 caracteres',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await preencherFormulario(
          tester,
          email: 'usuario@email.com',
          senha: '12345',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );

        expect(mockAuth.currentUser, isNull);
      },
    );
  });

  group('LoginScreen - interação com formulário', () {
    testWidgets(
      'deve aceitar entrada de e-mail e senha',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'teste@email.com',
        );

        await tester.enterText(
          fields.at(1),
          'minhaSenha123',
        );

        expect(
          find.text('teste@email.com'),
          findsOneWidget,
        );

        expect(
          find.text('minhaSenha123'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'campo de senha deve ocultar o texto',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final editableFields = find.byType(EditableText);

        expect(editableFields, findsNWidgets(2));

        final senhaField = tester.widget<EditableText>(
          editableFields.at(1),
        );

        expect(senhaField.obscureText, isTrue);
      },
    );
  });

  group('LoginScreen - autenticação', () {
    testWidgets(
      'deve realizar login com credenciais válidas',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await preencherFormulario(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        // MockFirebaseAuth efetivamente autentica o usuário.
        expect(mockAuth.currentUser, isNotNull);
        expect(
          mockAuth.currentUser!.email,
          'usuario@email.com',
        );
      },
    );

    testWidgets(
      'não deve autenticar quando o formulário é inválido',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(mockAuth.currentUser, isNull);
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

        // Mantém exatamente a mensagem atualmente implementada
        // no LoginScreen para o código user-not-found.
        expect(
          find.text(
            'Senha incorreta. Certifique-se de que está digitando '
            'a senha corretamente.',
          ),
          findsOneWidget,
        );

        expect(find.byType(SnackBar), findsOneWidget);
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

        // Mantém exatamente a mensagem atualmente implementada
        // no LoginScreen para o código wrong-password.
        expect(
          find.text(
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
          ),
          findsOneWidget,
        );

        expect(find.byType(SnackBar), findsOneWidget);
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

        expect(find.byType(SnackBar), findsOneWidget);
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

        expect(find.byType(SnackBar), findsOneWidget);
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

        await tester.tap(
          find.text('Não tem cadastro? Cadastre-se!'),
        );
        await tester.pumpAndSettle();

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );
      },
    );
  });
}
```

 ## 3\. Por que essas alterações resolvem os erros

 ### `AuthExceptions`

 Esse foi o maior problema. O seu `firebase_auth_mocks` é **0.14.2**, e a API antiga:

```
MockFirebaseAuth(
  authExceptions: AuthExceptions(...)
)
```

 não existe mais. A própria documentação registra a mudança para:

```
whenCalling(...)
    .on(auth)
    .thenThrow(...);
```

 desde `firebase_auth_mocks 0.10.0`.  Dart packages+1

 Por isso agora o teste faz:

```
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
  FirebaseAuthException(code: 'wrong-password'),
);
```

 Isso também permite testar especificamente o tratamento do `FirebaseAuthException` no widget.

 ### Getters `signInWithEmailAndPasswordCalled`

 Esses getters simplesmente não fazem parte de `MockFirebaseAuth 0.14.2`. A API documentada expõe `signInWithEmailAndPassword`, `currentUser` e outros comportamentos, mas não esses getters de rastreamento.  Dart packages

 Em vez de inventar uma API, o teste de sucesso verifica o efeito observável:

```
expect(mockAuth.currentUser, isNotNull);
expect(mockAuth.currentUser!.email, 'usuario@email.com');
```

 Isso testa o resultado real da autenticação simulada.

 ### `obscureText`

 O `TextFormField` não expõe diretamente essa propriedade. O campo cria um `EditableText` internamente. Portanto, o teste correto é:

```
final senhaField = tester.widget<EditableText>(
  find.byType(EditableText).at(1),
);

expect(senhaField.obscureText, isTrue);
```

 ### Imports de navegação

 Como o teste usa:

```
find.byType(RecupSenhaScreen)
find.byType(CadastroScreen)
```

 é necessário importar as classes:

```
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/recup-senha.dart';
```

 O `MaterialApp` continua sendo usado, conforme solicitado, para fornecer o `Navigator` necessário.

 ## 4\. Um ponto que merece correção no aplicativo

 Existe uma possível inconsistência **fora do teste**.

 Atualmente o `login.dart` faz:

```
if (e.code == 'user-not-found') {
  errorMessage = 'Senha incorreta...';
} else if (e.code == 'wrong-password') {
  errorMessage = 'Usuário não encontrado...';
}
```

 Ou seja:

 | Código Firebase | Mensagem atualmente exibida |
| --- | --- |
| `user-not-found` | "Senha incorreta..." |
| `wrong-password` | "Usuário não encontrado..." |

Os nomes dos códigos indicam uma semântica diferente dessas mensagens. Portanto, isso é um caso de **comportamento potencialmente incorreto da aplicação**, não um motivo para enfraquecer o teste.

 O teste corrigido deliberadamente preserva o comportamento atual para que, quando você decidir corrigir `login.dart`, os testes possam ser alterados junto com a regra funcional esperada.

 Por fim, os avisos de que existem versões mais novas dos pacotes **não são a causa da falha mostrada**. O compilador chegou às incompatibilidades específicas da API `firebase_auth_mocks 0.14.2`; atualizar indiscriminadamente todas as dependências não é necessário para corrigir esse erro.  Dart packages