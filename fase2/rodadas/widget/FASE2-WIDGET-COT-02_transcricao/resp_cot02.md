## 1\. Análise do widget

 O `LoginScreen` exibe uma tela de login com campos para e-mail e senha, botão **Entrar** e links para recuperação de senha e cadastro. O formulário valida e-mail obrigatório/válido e senha obrigatória com pelo menos 6 caracteres antes de tentar autenticar. No login bem-sucedido, o widget substitui a rota atual por `TelaInicialScreen`; em falhas, exibe um `SnackBar` vermelho com uma mensagem específica para determinados códigos do Firebase. O serviço externo utilizado é o **Firebase Authentication**, recebido opcionalmente por injeção através de `FirebaseAuth? auth`, o que facilita o isolamento nos testes.

 ## 2\. Dependências que precisam de mock

 A dependência externa relevante é:

 - `FirebaseAuth`
  - Método utilizado: `signInWithEmailAndPassword(email: ..., password: ...)`.
  - Pode ser mockado com `MockFirebaseAuth` do pacote `firebase_auth_mocks`.
  - Para o teste de sucesso, o mock deve aceitar as credenciais e permitir verificar a navegação.
  - Para os cenários de erro, o mock deve lançar `FirebaseAuthException` com cada código tratado:
    - `user-not-found`
    - `wrong-password`
    - `invalid-credential`
    - qualquer outro código, para o caminho de erro genérico.
  - Como o widget aceita `auth`, o ideal é sempre passar o mock via `LoginScreen(auth: mockAuth)` e evitar `FirebaseAuth.instance`.

 Também é necessário considerar o asset `assets/logo-sintoniza.png`. O teste deve ter esse asset disponível no `pubspec.yaml`; caso não esteja disponível no ambiente de teste, pode-se evitar depender da renderização da imagem procurando os elementos do formulário por texto/chaves, mas o `pumpWidget` ainda tentará carregar o asset.

 ## 3\. Cenários de teste

 - **Renderização básica**
  - Exibe `E-mail`.
  - Exibe `Senha`.
  - Exibe o botão `Entrar`.
  - Exibe `Esqueci minha senha`.
  - Exibe `Não tem cadastro? Cadastre-se!`.
- **Validação do formulário**
  - Ambos os campos vazios.
  - E-mail vazio com senha preenchida.
  - Senha vazia com e-mail preenchido.
  - E-mail em formato inválido.
  - Senha com menos de 6 caracteres.
  - E-mail e senha válidos não produzem mensagens de validação.
- **Interação do usuário**
  - Digitar e-mail.
  - Digitar senha.
  - Tocar em `Entrar`.
  - Tocar em `Esqueci minha senha` e navegar para `RecupSenhaScreen`.
  - Tocar em `Não tem cadastro? Cadastre-se!` e navegar para `CadastroScreen`.
- **Login bem-sucedido**
  - `signInWithEmailAndPassword` é chamado com os valores digitados.
  - A tela navega para `TelaInicialScreen` usando `pushReplacement`.
- **Erros do Firebase**
  - `user-not-found` → mensagem específica.
  - `wrong-password` → mensagem específica.
  - `invalid-credential` → mensagem específica.
  - Código desconhecido → mensagem genérica.

 Abaixo está um arquivo de testes completo. Ele usa `MockFirebaseAuth` para autenticação e `mockito` apenas onde é útil para verificar a chamada ao Firebase.

 login\_screen\_test.dart

```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/recup-senha.dart';
import 'package:sintonize/tela-inicial.dart';

class MockFirebaseAuthWithMockito extends Mock implements FirebaseAuth {}

void main() {
  late MockFirebaseAuth mockAuth;

  Widget buildTestableWidget({
    FirebaseAuth? auth,
  }) {
    return MaterialApp(
      home: LoginScreen(auth: auth ?? mockAuth),
      routes: {
        '/dummy': (_) => const Scaffold(
              body: Text('Dummy'),
            ),
      },
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
    testWidgets('deve mostrar erros quando os campos estão vazios',
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

      verifyNever(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      );
    });

    testWidgets('deve mostrar erro quando o e-mail está vazio',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(1), '123456');
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

      verifyNever(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      );
    });

    testWidgets('deve mostrar erro quando a senha está vazia',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'usuario@email.com');
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

      verifyNever(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      );
    });

    testWidgets('deve rejeitar e-mail inválido', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'email-invalido');
      await tester.enterText(fields.at(1), '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira um e-mail válido'),
        findsOneWidget,
      );

      verifyNever(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      );
    });

    testWidgets('deve rejeitar senha com menos de 6 caracteres',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'usuario@email.com');
      await tester.enterText(fields.at(1), '12345');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );

      verifyNever(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      );
    });

    testWidgets('não deve mostrar erros para dados válidos',
        (tester) async {
      when(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer(
        (_) async => MockUserCredential(
          user: MockUser(
            uid: 'test-user',
            email: 'usuario@email.com',
          ),
        ),
      );

      await tester.pumpWidget(buildTestableWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'usuario@email.com');
      await tester.enterText(fields.at(1), '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

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
    });
  });

  group('LoginScreen - interação', () {
    testWidgets('deve permitir digitar e-mail e senha', (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'usuario@email.com');
      await tester.enterText(fields.at(1), 'minhasenha');

      expect(
        find.text('usuario@email.com'),
        findsOneWidget,
      );
      expect(
        find.text('minhasenha'),
        findsOneWidget,
      );
    });

    testWidgets(
        'deve navegar para RecupSenhaScreen ao tocar em "Esqueci minha senha"',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(find.text('Esqueci minha senha'));
      await tester.pumpAndSettle();

      expect(find.byType(RecupSenhaScreen), findsOneWidget);
    });

    testWidgets(
        'deve navegar para CadastroScreen ao tocar em "Cadastre-se"',
        (tester) async {
      await tester.pumpWidget(buildTestableWidget());

      await tester.tap(
        find.text('Não tem cadastro? Cadastre-se!'),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CadastroScreen), findsOneWidget);
    });
  });

  group('LoginScreen - login com sucesso', () {
    testWidgets(
        'deve chamar Firebase Auth com e-mail e senha informados',
        (tester) async {
      when(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer(
        (_) async => MockUserCredential(
          user: MockUser(
            uid: 'test-user',
            email: 'usuario@email.com',
          ),
        ),
      );

      await tester.pumpWidget(buildTestableWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'usuario@email.com');
      await tester.enterText(fields.at(1), '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      verify(
        mockAuth.signInWithEmailAndPassword(
          email: 'usuario@email.com',
          password: '123456',
        ),
      ).called(1);
    });

    testWidgets(
        'deve remover LoginScreen e navegar para TelaInicialScreen após login',
        (tester) async {
      when(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer(
        (_) async => MockUserCredential(
          user: MockUser(
            uid: 'test-user',
            email: 'usuario@email.com',
          ),
        ),
      );

      await tester.pumpWidget(buildTestableWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'usuario@email.com');
      await tester.enterText(fields.at(1), '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.byType(TelaInicialScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('deve remover espaços do e-mail e senha antes do login',
        (tester) async {
      when(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer(
        (_) async => MockUserCredential(
          user: MockUser(
            uid: 'test-user',
            email: 'usuario@email.com',
          ),
        ),
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

      verify(
        mockAuth.signInWithEmailAndPassword(
          email: 'usuario@email.com',
          password: '123456',
        ),
      ).called(1);
    });
  });

  group('LoginScreen - erros do Firebase Auth', () {
    testWidgets(
        'deve mostrar mensagem para user-not-found',
        (tester) async {
      when(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'user-not-found',
          message: 'Usuário não encontrado',
        ),
      );

      await tester.pumpWidget(buildTestableWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'usuario@email.com');
      await tester.enterText(fields.at(1), '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text(
          'Usuário não encontrado. Verifique o e-mail e tente novamente.',
        ),
        findsOneWidget,
      );

      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets(
        'deve mostrar mensagem para wrong-password',
        (tester) async {
      when(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'wrong-password',
          message: 'Senha incorreta',
        ),
      );

      await tester.pumpWidget(buildTestableWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'usuario@email.com');
      await tester.enterText(fields.at(1), '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text(
          'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
        ),
        findsOneWidget,
      );

      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets(
        'deve mostrar mensagem para invalid-credential',
        (tester) async {
      when(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Credenciais inválidas',
        ),
      );

      await tester.pumpWidget(buildTestableWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'usuario@email.com');
      await tester.enterText(fields.at(1), '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text(
          'As credenciais fornecidas são inválidas. Tente novamente.',
        ),
        findsOneWidget,
      );

      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets(
        'deve mostrar mensagem genérica para código de erro desconhecido',
        (tester) async {
      when(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'network-request-failed',
          message: 'Erro de rede',
        ),
      );

      await tester.pumpWidget(buildTestableWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'usuario@email.com');
      await tester.enterText(fields.at(1), '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text(
          'Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.',
        ),
        findsOneWidget,
      );

      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets(
        'não deve navegar quando Firebase Auth lança uma exceção',
        (tester) async {
      when(
        mockAuth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'user-not-found',
        ),
      );

      await tester.pumpWidget(buildTestableWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'usuario@email.com');
      await tester.enterText(fields.at(1), '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });
}
```

 ### Observação importante sobre `MockFirebaseAuth` \+ Mockito

 Há uma questão prática no código acima: **`MockFirebaseAuth` e Mockito são duas estratégias diferentes de mocking**. O `MockFirebaseAuth` fornecido por `firebase_auth_mocks` já implementa `FirebaseAuth`, enquanto `MockFirebaseAuthWithMockito` é um mock gerado pelo Mockito. Para evitar confusão, você pode usar **uma única estratégia**.

 Como você explicitamente informou que `firebase_auth_mocks` e `mockito` estão disponíveis, a abordagem mais simples para este widget é usar `MockFirebaseAuth` diretamente e configurar seus comportamentos conforme a API da versão instalada. Se o seu projeto estiver usando uma versão de `firebase_auth_mocks` na qual `MockFirebaseAuth` não funciona com `when(...).thenAnswer(...)` do Mockito, o arquivo acima precisará ser adaptado para a API específica dessa versão.

 Além disso, os imports assumem que o arquivo do widget se chama `login.dart`:

```
import 'package:sintonize/login.dart';
```

 Se o arquivo tiver outro nome, basta alterar **somente esse import** — não é necessário modificar o `LoginScreen`.
