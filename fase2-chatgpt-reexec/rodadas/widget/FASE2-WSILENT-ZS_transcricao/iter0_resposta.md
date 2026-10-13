Abaixo está um arquivo de teste completo, pensado para `flutter test`, usando `firebase_auth_mocks` para controlar o `FirebaseAuth` injetado no `LoginScreen`.

 > Exemplo de localização: `test/login_test.dart`

 Escrita

```
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/login.dart';

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

  group('LoginScreen - renderização', () {
    testWidgets('deve renderizar os campos e botões principais',
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
    });
  });

  group('LoginScreen - validação', () {
    testWidgets('deve mostrar erro quando os campos estão vazios',
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
    });

    testWidgets('deve mostrar erro para e-mail inválido',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

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

    testWidgets('deve mostrar erro para senha com menos de 6 caracteres',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

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

    testWidgets('não deve chamar Firebase Auth quando formulário é inválido',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        mockAuth.signInWithEmailAndPasswordCalled,
        isFalse,
      );
    });
  });

  group('LoginScreen - autenticação', () {
    testWidgets('deve realizar login com e-mail e senha válidos',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'usuario@email.com');
      await tester.enterText(fields.at(1), '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(
        mockAuth.signInWithEmailAndPasswordCalled,
        isTrue,
      );

      expect(
        mockAuth.signInWithEmailAndPasswordEmail,
        'usuario@email.com',
      );

      expect(
        mockAuth.signInWithEmailAndPasswordPassword,
        '123456',
      );
    });
  });

  group('LoginScreen - erros do Firebase Auth', () {
    Future<void> preencherFormulario(
      WidgetTester tester,
    ) async {
      final fields = find.byType(TextFormField);

      await tester.enterText(fields.at(0), 'usuario@email.com');
      await tester.enterText(fields.at(1), '123456');
    }

    testWidgets(
      'deve mostrar mensagem para user-not-found',
      (WidgetTester tester) async {
        mockAuth = MockFirebaseAuth(
          mockUser: null,
          authExceptions: AuthExceptions(
            signInWithEmailAndPassword:
                FirebaseAuthException(code: 'user-not-found'),
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

        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets(
      'deve mostrar mensagem para wrong-password',
      (WidgetTester tester) async {
        mockAuth = MockFirebaseAuth(
          mockUser: null,
          authExceptions: AuthExceptions(
            signInWithEmailAndPassword:
                FirebaseAuthException(code: 'wrong-password'),
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

        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets(
      'deve mostrar mensagem para invalid-credential',
      (WidgetTester tester) async {
        mockAuth = MockFirebaseAuth(
          mockUser: null,
          authExceptions: AuthExceptions(
            signInWithEmailAndPassword:
                FirebaseAuthException(code: 'invalid-credential'),
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
        mockAuth = MockFirebaseAuth(
          mockUser: null,
          authExceptions: AuthExceptions(
            signInWithEmailAndPassword:
                FirebaseAuthException(code: 'unknown-error'),
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

  group('LoginScreen - interação', () {
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

        final fields = find.byType(TextFormField);

        final senhaField = tester.widget<TextFormField>(
          fields.at(1),
        );

        expect(senhaField.obscureText, isTrue);
      },
    );
  });
}
```

 ### Dependências

 No `pubspec.yaml`, certifique-se de ter as dependências de teste/mock correspondentes:

```
dev_dependencies:
  flutter_test:
    sdk: flutter
  firebase_auth_mocks: ^0.14.0
  mockito: ^5.4.0
  fake_cloud_firestore: ^3.0.0
```

 Depois:

```
flutter pub get
flutter test
```

 ### Observação importante

 O teste injeta `MockFirebaseAuth` através do construtor:

```
LoginScreen(auth: mockAuth)
```

 Isso é importante porque evita que o teste dependa da instância real de `FirebaseAuth.instance`.

 Também há um detalhe interessante no widget fornecido: as mensagens associadas a `user-not-found` e `wrong-password` parecem estar **invertidas** em relação aos nomes dos códigos. Os testes acima reproduzem exatamente o comportamento atual do código, em vez de assumir mensagens diferentes.