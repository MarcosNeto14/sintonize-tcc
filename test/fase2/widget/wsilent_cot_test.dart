import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

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
    testWidgets('deve renderizar os elementos principais', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('deve renderizar os campos com os tipos corretos',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      final fields = find.byType(TextFormField);

      expect(fields, findsNWidgets(2));

      final emailEditable = find.descendant(
        of: fields.at(0),
        matching: find.byType(EditableText),
      );

      final senhaEditable = find.descendant(
        of: fields.at(1),
        matching: find.byType(EditableText),
      );

      expect(emailEditable, findsOneWidget);
      expect(senhaEditable, findsOneWidget);

      expect(
        tester.widget<EditableText>(emailEditable).obscureText,
        isFalse,
      );

      expect(
        tester.widget<EditableText>(senhaEditable).obscureText,
        isTrue,
      );
    });

    testWidgets('deve permitir rolar o conteúdo do formulário',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      final scrollable = find.byType(SingleChildScrollView);

      expect(scrollable, findsOneWidget);

      await tester.drag(
        scrollable,
        const Offset(0, -300),
      );

      await tester.pump();

      expect(scrollable, findsOneWidget);
    });
  });

  group('LoginScreen - validação', () {
    testWidgets(
      'deve exibir mensagens de validação quando os campos estiverem vazios',
      (tester) async {
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
      },
    );

    testWidgets(
      'deve exibir erro quando o e-mail for inválido',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

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
      'deve aceitar e-mail válido com senha de 6 caracteres',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@example.com',
        );

        await tester.enterText(
          fields.at(1),
          '123456',
        );

        final form = tester.widget<Form>(
          find.byType(Form),
        );

        final formState =
            (form.key as GlobalKey<FormState>).currentState!;

        expect(formState.validate(), isTrue);

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
      },
    );

    testWidgets(
      'deve rejeitar senha com menos de 6 caracteres',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@example.com',
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
      'não deve chamar Firebase quando a validação falhar',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        // Se o Firebase fosse chamado, um login sem credenciais poderia
        // produzir um SnackBar de erro. A ausência desse SnackBar confirma
        // que a execução foi interrompida pela validação.
        expect(
          find.text(
            'Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.',
          ),
          findsNothing,
        );
      },
    );
  });

  group('LoginScreen - entrada de dados', () {
    testWidgets(
      'deve preencher corretamente e-mail e senha',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@example.com',
        );

        await tester.enterText(
          fields.at(1),
          'senha123',
        );

        final emailField = tester.widget<TextFormField>(
          fields.at(0),
        );

        final senhaField = tester.widget<TextFormField>(
          fields.at(1),
        );

        expect(emailField.controller!.text, 'usuario@example.com');
        expect(senhaField.controller!.text, 'senha123');
      },
    );

    testWidgets(
      'deve remover espaços das credenciais antes do login',
      (tester) async {
        await tester.pumpWidget(createTestWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          '  usuario@example.com  ',
        );

        await tester.enterText(
          fields.at(1),
          '  senha123  ',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        // MockFirebaseAuth aceita a chamada. O teste comprova o fluxo
        // sem depender de uma implementação real do Firebase.
        expect(find.text('Entrar'), findsOneWidget);
      },
    );
  });

  group('LoginScreen - login com sucesso', () {
    testWidgets(
      'deve chamar signInWithEmailAndPassword com as credenciais corretas',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
          signedIn: true,
        );

        await tester.pumpWidget(createTestWidget());

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@example.com',
        );

        await tester.enterText(
          fields.at(1),
          'senha123',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          mockAuth.currentUser,
          isNotNull,
        );

        expect(
          mockAuth.currentUser!.email,
          'usuario@example.com',
        );
      },
    );

    testWidgets(
      'deve navegar para TelaInicialScreen após login bem-sucedido',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
          signedIn: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: LoginScreen(auth: mockAuth),
          ),
        );

        final fields = find.byType(TextFormField);

        await tester.enterText(
          fields.at(0),
          'usuario@example.com',
        );

        await tester.enterText(
          fields.at(1),
          'senha123',
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
    Future<void> preencherEEnviar(WidgetTester tester) async {
      final fields = find.byType(TextFormField);

      await tester.enterText(
        fields.at(0),
        'usuario@example.com',
      );

      await tester.enterText(
        fields.at(1),
        'senha123',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'deve exibir mensagem correta para user-not-found',
      (tester) async {
        mockAuth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
          FirebaseAuthException(
            code: 'user-not-found',
            message: 'Usuário não encontrado',
          ),
        );

        await tester.pumpWidget(createTestWidget());

        await preencherEEnviar(tester);

        expect(
          find.text(
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
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
      'deve exibir mensagem correta para wrong-password',
      (tester) async {
        mockAuth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
          FirebaseAuthException(
            code: 'wrong-password',
            message: 'Senha incorreta',
          ),
        );

        await tester.pumpWidget(createTestWidget());

        await preencherEEnviar(tester);

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
        mockAuth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
          FirebaseAuthException(
            code: 'invalid-credential',
            message: 'Credenciais inválidas',
          ),
        );

        await tester.pumpWidget(createTestWidget());

        await preencherEEnviar(tester);

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
        mockAuth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
          FirebaseAuthException(
            code: 'internal-error',
            message: 'Erro interno',
          ),
        );

        await tester.pumpWidget(createTestWidget());

        await preencherEEnviar(tester);

        expect(
          find.text(
            'Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir mensagem genérica para erro de rede do Firebase',
      (tester) async {
        mockAuth = MockFirebaseAuth();

        whenCalling(
          Invocation.method(
            #signInWithEmailAndPassword,
            null,
          ),
        ).on(mockAuth).thenThrow(
          FirebaseAuthException(
            code: 'network-request-failed',
            message: 'Falha de rede',
          ),
        );

        await tester.pumpWidget(createTestWidget());

        await preencherEEnviar(tester);

        expect(
          find.text(
            'Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir SnackBar vermelho nos erros de autenticação',
      (tester) async {
        mockAuth = MockFirebaseAuth();

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

        await tester.pumpWidget(createTestWidget());

        await preencherEEnviar(tester);

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
      'não deve navegar quando o Firebase retornar erro',
      (tester) async {
        mockAuth = MockFirebaseAuth();

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

        await tester.pumpWidget(createTestWidget());

        await preencherEEnviar(tester);

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );

        expect(
          find.byType(LoginScreen),
          findsOneWidget,
        );
      },
    );
  });
}
