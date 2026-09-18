**Classificação: (A) — o teste presume uma API que não está disponível no escopo atual.**

 O erro não indica problema no `LoginScreen`. O `firebase_auth_mocks` realmente suporta `whenCalling(...).on(...).thenThrow(...)`, inclusive para `signInWithEmailAndPassword`, mas `whenCalling` pertence ao pacote **`mock_exceptions`** e não está disponível apenas pelo import de `firebase_auth_mocks`. A documentação atual mostra explicitamente essa API e também que `mock_exceptions` é uma dependência do `firebase_auth_mocks`.  Dart packages+2

 Portanto, a correção mínima seria adicionar:

```
import 'package:mock_exceptions/mock_exceptions.dart';
```

 Porém, há uma opção ainda melhor para o seu caso: como você já tem **Mockito** disponível, podemos usar um mock Mockito de `FirebaseAuth` e resolver corretamente o problema de null safety usando `argThat(...)`/`any` com `typed`. Isso evita depender de uma API transitiva de `mock_exceptions`.

 Mas existe uma solução ainda mais simples: **usar `MockFirebaseAuth` \+ importar `mock_exceptions`**. Isso preserva exatamente o fake de Firebase que você já está usando e não exige geração de mocks.

 ## Correção

 Adicione este import no topo:

```
import 'package:mock_exceptions/mock_exceptions.dart';
```

 E mantenha `firebase_auth_mocks`:

```
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
```

 A documentação atual do `firebase_auth_mocks` confirma que `whenCalling` é o mecanismo suportado para fazer métodos como `signInWithEmailAndPassword` lançarem `FirebaseAuthException`.  Dart packages

 Entretanto, recomendo também simplificar os `Invocation` dos testes de erro. **Não precisamos casar os valores de e-mail e senha**, porque esses testes estão verificando especificamente o tratamento dos códigos de erro. A própria API permite omitir parâmetros nomeados; parâmetros omitidos são tratados como `anything`.  Dart packages

 Assim, os cinco testes de erro podem ficar desta forma:

 login\_screen\_cot\_test.dart — correção dos testes de erro

```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/recup-senha.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  late MockFirebaseAuth mockAuth;

  Widget buildTestableWidget() {
    return MaterialApp(
      home: LoginScreen(auth: mockAuth),
    );
  }

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  group('LoginScreen - renderização', () {
    testWidgets('deve renderizar os elementos principais', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Esqueci minha senha'), findsOneWidget);
      expect(
        find.text('Não tem cadastro? Cadastre-se!'),
        findsOneWidget,
      );
    });

    testWidgets('deve renderizar dois campos de texto', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });

  group('LoginScreen - validação', () {
    testWidgets(
      'deve mostrar erros quando os campos estão vazios',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

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
      'deve mostrar erro quando o e-mail está vazio',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsOneWidget,
        );

        expect(
          find.text('Por favor, insira sua senha'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve mostrar erro quando a senha está vazia',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsNothing,
        );

        expect(
          find.text('Por favor, insira sua senha'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve rejeitar e-mail inválido',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

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
      'deve rejeitar senha com menos de 6 caracteres',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

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
          find.text(
            'A senha deve ter pelo menos 6 caracteres',
          ),
          findsOneWidget,
        );
      },
    );
  });

  group('LoginScreen - interação', () {
    testWidgets(
      'deve permitir digitar e-mail e senha',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@email.com',
        );

        await tester.enterText(
          fields.at(1),
          'minhasenha',
        );

        expect(
          find.text('usuario@email.com'),
          findsOneWidget,
        );

        expect(
          find.text('minhasenha'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve navegar para RecupSenhaScreen',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

        await tester.tap(
          find.text('Esqueci minha senha'),
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(RecupSenhaScreen),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve navegar para CadastroScreen',
      (tester) async {
        await tester.pumpWidget(buildTestableWidget());

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

  group('LoginScreen - login com sucesso', () {
    testWidgets(
      'deve realizar login com credenciais válidas',
      (tester) async {
        final user = MockUser(
          uid: 'test-user',
          email: 'usuario@email.com',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
        );

        await tester.pumpWidget(buildTestableWidget());

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
        await tester.pumpAndSettle();

        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );

        expect(
          find.byType(LoginScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve navegar para TelaInicialScreen após login válido',
      (tester) async {
        final user = MockUser(
          uid: 'test-user',
          email: 'usuario@email.com',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
        );

        await tester.pumpWidget(buildTestableWidget());

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
        await tester.pumpAndSettle();

        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve remover espaços do e-mail e senha antes do login',
      (tester) async {
        final user = MockUser(
          uid: 'test-user',
          email: 'usuario@email.com',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
        );

        await tester.pumpWidget(buildTestableWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          '  usuario@email.com  ',
        );

        await tester.enterText(
          fields.at(1),
          '  123456  ',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );
      },
    );
  });

  group('LoginScreen - erros do Firebase Auth', () {
    testWidgets(
      'deve mostrar mensagem para user-not-found',
      (tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              FirebaseAuthException(
                code: 'user-not-found',
              ),
            );

        await tester.pumpWidget(buildTestableWidget());

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

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve mostrar mensagem para wrong-password',
      (tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              FirebaseAuthException(
                code: 'wrong-password',
              ),
            );

        await tester.pumpWidget(buildTestableWidget());

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

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve mostrar mensagem para invalid-credential',
      (tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              FirebaseAuthException(
                code: 'invalid-credential',
              ),
            );

        await tester.pumpWidget(buildTestableWidget());

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

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve mostrar mensagem genérica para código desconhecido',
      (tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              FirebaseAuthException(
                code: 'network-request-failed',
              ),
            );

        await tester.pumpWidget(buildTestableWidget());

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

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'não deve navegar quando Firebase Auth lança uma exceção',
      (tester) async {
        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
              FirebaseAuthException(
                code: 'user-not-found',
              ),
            );

        await tester.pumpWidget(buildTestableWidget());

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
          find.byType(LoginScreen),
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
```

 ### Por que essa versão corrige o erro

 O ponto fundamental é este import:

```
import 'package:mock_exceptions/mock_exceptions.dart';
```

 `whenCalling` é definido nesse pacote. A API pública de `mock_exceptions` declara `whenCalling(Invocation i)` como função de nível superior.  Dart packages+1

 O `firebase_auth_mocks` usa justamente esse mecanismo para configurar exceções no `MockFirebaseAuth`. A documentação atual inclusive lista `signInWithEmailAndPassword` entre os métodos que podem receber `thenThrow`.  Dart packages

 Também simplifiquei:

```
Invocation.method(
  #signInWithEmailAndPassword,
  null,
)
```

 em vez de tentar fornecer:

```
{
  #email: '...',
  #password: '...',
}
```

 Isso é intencional. O pacote documenta que parâmetros nomeados omitidos são tratados como `anything`, então o mock lança a exceção independentemente dos valores enviados.  Dart packages

 Assim, o teste continua verificando exatamente o comportamento importante: **dado que o Firebase lança determinado código de erro, o `LoginScreen` deve apresentar a mensagem correspondente**.

 Se `mock_exceptions` não estiver explicitamente no seu `pubspec.yaml`, adicione-o em `dev_dependencies`:

```
dev_dependencies:
  mock_exceptions: ^0.8.2
```

 Embora seja uma dependência transitiva do `firebase_auth_mocks` atual, declarar diretamente uma dependência que o seu código de teste importa é a opção mais segura. O pacote atualmente documentado é `mock_exceptions 0.8.2`.  Dart packages

 Depois execute:

```
flutter pub get
flutter test test/fase2/widget/login_screen_cot_test.dart
```

 **Não há necessidade de alterar o `LoginScreen`.**
