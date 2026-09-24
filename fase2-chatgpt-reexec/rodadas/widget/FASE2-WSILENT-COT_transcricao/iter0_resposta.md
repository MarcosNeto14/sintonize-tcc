## 1. Análise do widget

 O `LoginScreen` apresenta uma tela de login com campos de e-mail e senha, botão **Entrar** e validações locais para os dois campos. Ao enviar o formulário, ele chama `FirebaseAuth.signInWithEmailAndPassword` e, em caso de sucesso, navega para `TelaInicialScreen` usando `pushReplacement`. Em caso de `FirebaseAuthException`, exibe um `SnackBar` vermelho com uma mensagem diferente para `user-not-found`, `wrong-password`, `invalid-credential` ou outros erros. Os únicos serviços externos efetivamente usados por este widget são **Firebase Authentication**; Firestore e HTTP não são utilizados diretamente.

 ## 2\. Dependências que precisam de mock

 - **Firebase Auth:** precisa ser mockado porque `signInWithEmailAndPassword()` é chamado durante o teste.
  - Para o fluxo de sucesso, `MockFirebaseAuth` de `firebase_auth_mocks` é adequado.
  - Para testar precisamente cada exceção/código retornado, podemos usar Mockito para criar um `FirebaseAuth` mockado e fazer `thenThrow(FirebaseAuthException(...))`.
- **Firestore:** não é usado pelo `LoginScreen`, portanto **não precisa de mock**.
- **HTTP:** não é usado pelo `LoginScreen`, portanto **não precisa de mock**.
- **Assets:** o widget usa `assets/logo-sintoniza.png`. O asset deve estar declarado no `pubspec.yaml` do projeto; não é necessário mockar a imagem.

 ## 3\. Cenários de teste

 Os testes abaixo cobrem:

 - Renderização dos textos **E-mail**, **Senha** e **Entrar**.
- Existência dos dois `TextFormField`.
- Validação de e-mail vazio.
- Validação de e-mail inválido.
- Validação de senha vazia.
- Validação de senha com menos de 6 caracteres.
- Aceitação de e-mail e senha válidos.
- Entrada de texto nos campos.
- Scroll da tela.
- Login com credenciais válidas.
- Navegação para `TelaInicialScreen` após sucesso.
- `user-not-found` → mensagem correspondente implementada pelo widget.
- `wrong-password` → mensagem correspondente implementada pelo widget.
- `invalid-credential` → mensagem correspondente implementada pelo widget.
- Código de erro desconhecido → mensagem genérica.
- Garantia de que uma falha de validação impede a chamada ao Firebase.
- Garantia de que o botão dispara o fluxo de login.

 > **Observação importante:** as mensagens dos testes abaixo reproduzem exatamente o comportamento do código fornecido. Embora os textos associados a `user-not-found` e `wrong-password` pareçam semanticamente invertidos, os testes devem validar o comportamento atual, sem modificar o widget.

 ## 4\. Testes completos

 O arquivo pode, por exemplo, ser `test/login_test.dart`.

```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:sintonize/login.dart';

class MockFirebaseAuthWithMockito extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  Widget createTestWidget(FirebaseAuth auth) {
    return MaterialApp(
      home: LoginScreen(auth: auth),
    );
  }

  group('LoginScreen - Renderização', () {
    testWidgets('deve renderizar os elementos principais', (tester) async {
      final auth = MockFirebaseAuth();

      await tester.pumpWidget(createTestWidget(auth));

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('deve renderizar o logo', (tester) async {
      final auth = MockFirebaseAuth();

      await tester.pumpWidget(createTestWidget(auth));

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('deve permitir scroll vertical da tela', (tester) async {
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

      await tester.drag(scrollable, const Offset(0, -200));
      await tester.pump();

      expect(scrollable, findsOneWidget);
    });
  });

  group('LoginScreen - Validação do formulário', () {
    testWidgets('deve exibir erro quando o e-mail estiver vazio', (
      tester,
    ) async {
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
    });

    testWidgets('deve exibir erro para e-mail inválido', (tester) async {
      final auth = MockFirebaseAuth();

      await tester.pumpWidget(createTestWidget(auth));

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'email-invalido');
      await tester.enterText(fields.at(1), '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira um e-mail válido'),
        findsOneWidget,
      );
    });

    testWidgets('deve exibir erro quando a senha estiver vazia', (
      tester,
    ) async {
      final auth = MockFirebaseAuth();

      await tester.pumpWidget(createTestWidget(auth));

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'usuario@email.com');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira sua senha'),
        findsOneWidget,
      );
    });

    testWidgets('deve exibir erro para senha com menos de 6 caracteres', (
      tester,
    ) async {
      final auth = MockFirebaseAuth();

      await tester.pumpWidget(createTestWidget(auth));

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'usuario@email.com');
      await tester.enterText(fields.at(1), '12345');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets('deve aceitar e-mail e senha válidos', (tester) async {
      final auth = MockFirebaseAuth();

      await tester.pumpWidget(createTestWidget(auth));

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'usuario@email.com');
      await tester.enterText(fields.at(1), '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

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
    });

    testWidgets(
      'não deve chamar Firebase quando o formulário for inválido',
      (tester) async {
        final auth = MockFirebaseAuthWithMockito();

        await tester.pumpWidget(createTestWidget(auth));

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        verifyNever(
          auth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        );
      },
    );
  });

  group('LoginScreen - Interação com os campos', () {
    testWidgets('deve preencher o campo de e-mail', (tester) async {
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
    });

    testWidgets('deve preencher o campo de senha', (tester) async {
      final auth = MockFirebaseAuth();

      await tester.pumpWidget(createTestWidget(auth));

      final senhaField = find.byType(TextFormField).at(1);

      await tester.enterText(
        senhaField,
        'senha123',
      );

      expect(
        find.text('senha123'),
        findsOneWidget,
      );
    });

    testWidgets('campo de senha deve utilizar obscureText', (tester) async {
      final auth = MockFirebaseAuth();

      await tester.pumpWidget(createTestWidget(auth));

      final passwordField =
          tester.widget<TextFormField>(find.byType(TextFormField).at(1));

      expect(passwordField.obscureText, isTrue);
    });
  });

  group('LoginScreen - Login com sucesso', () {
    testWidgets(
      'deve chamar Firebase Auth com e-mail e senha corretos',
      (tester) async {
        final auth = MockFirebaseAuthWithMockito();
        final credential = MockUserCredential();

        when(
          auth.signInWithEmailAndPassword(
            email: 'usuario@email.com',
            password: '123456',
          ),
        ).thenAnswer((_) async => credential);

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

        verify(
          auth.signInWithEmailAndPassword(
            email: 'usuario@email.com',
            password: '123456',
          ),
        ).called(1);
      },
    );

    testWidgets(
      'deve navegar para TelaInicialScreen após login bem-sucedido',
      (tester) async {
        final auth = MockFirebaseAuthWithMockito();
        final credential = MockUserCredential();

        when(
          auth.signInWithEmailAndPassword(
            email: 'usuario@email.com',
            password: '123456',
          ),
        ).thenAnswer((_) async => credential);

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

        await tester.pumpAndSettle();

        expect(
          find.byType(LoginScreen),
          findsNothing,
        );
      },
    );
  });

  group('LoginScreen - Erros do Firebase Auth', () {
    testWidgets(
      'deve exibir mensagem correta para user-not-found',
      (tester) async {
        final auth = MockFirebaseAuthWithMockito();

        when(
          auth.signInWithEmailAndPassword(
            email: 'usuario@email.com',
            password: '123456',
          ),
        ).thenThrow(
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
        final auth = MockFirebaseAuthWithMockito();

        when(
          auth.signInWithEmailAndPassword(
            email: 'usuario@email.com',
            password: '123456',
          ),
        ).thenThrow(
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
        final auth = MockFirebaseAuthWithMockito();

        when(
          auth.signInWithEmailAndPassword(
            email: 'usuario@email.com',
            password: '123456',
          ),
        ).thenThrow(
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
      'deve exibir mensagem genérica para código de erro desconhecido',
      (tester) async {
        final auth = MockFirebaseAuthWithMockito();

        when(
          auth.signInWithEmailAndPassword(
            email: 'usuario@email.com',
            password: '123456',
          ),
        ).thenThrow(
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
      'deve exibir mensagem genérica para erro de rede',
      (tester) async {
        final auth = MockFirebaseAuthWithMockito();

        when(
          auth.signInWithEmailAndPassword(
            email: 'usuario@email.com',
            password: '123456',
          ),
        ).thenThrow(
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

        final snackBar = find.byType(SnackBar);

        expect(snackBar, findsOneWidget);
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
      'deve exibir SnackBar com fundo vermelho em caso de erro',
      (tester) async {
        final auth = MockFirebaseAuthWithMockito();

        when(
          auth.signInWithEmailAndPassword(
            email: 'usuario@email.com',
            password: '123456',
          ),
        ).thenThrow(
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
        final auth = MockFirebaseAuthWithMockito();
        final credential = MockUserCredential();

        when(
          auth.signInWithEmailAndPassword(
            email: 'usuario@email.com',
            password: '123456',
          ),
        ).thenAnswer((_) async => credential);

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

 ### Observações sobre o código de teste

 Há dois pontos importantes para esse conjunto de testes:

 1. **`FakeCloudFirestore` não é necessário.** Embora esteja disponível no projeto, `LoginScreen` não faz nenhuma operação Firestore. Adicionar um fake de Firestore aos testes não aumentaria a cobertura desse widget.
2. **Não existe uma chamada HTTP no widget.** Portanto, não há cenário de rede HTTP independente a mockar. O teste de `network-request-failed` representa a falha de rede reportada pelo próprio Firebase Auth.
3. O teste de navegação verifica que `LoginScreen` deixa de estar na árvore depois do `pushReplacement`. Isso evita acoplar o teste à implementação interna de `TelaInicialScreen`, embora o `tela-inicial.dart` precise ser compilável para que o teste possa executar.
4. Se `TelaInicialScreen` fizer inicializações externas no `initState` — por exemplo, Firestore ou HTTP — essas dependências pertencem aos testes/arquitetura de `TelaInicialScreen`, não ao mock de `LoginScreen`.
5. Dependendo da versão de `mockito`/`firebase_auth` no `pubspec.yaml`, o `MockFirebaseAuthWithMockito` pode exigir a geração de mocks em vez da implementação manual. Nesse caso, a alternativa é gerar um `MockFirebaseAuth` com Mockito e manter exatamente a mesma estratégia de `when(...).thenThrow(...)` usada nos testes acima.