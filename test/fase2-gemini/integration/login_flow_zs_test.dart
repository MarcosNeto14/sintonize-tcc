// test/fase2-gemini/integration/login_flow_zs_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as fam;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

// Gera o mock para FirebaseAuth nos cenários que exigem lançar FirebaseAuthException
@GenerateMocks([FirebaseAuth])
import 'login_flow_zs_test.mocks.dart' as mockito_mocks;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Helper para empacotar a LoginScreen em um MaterialApp
  Widget createTestWidget({FirebaseAuth? auth}) {
    return MaterialApp(
      home: LoginScreen(auth: auth),
    );
  }

  // Constantes de teste
  const validEmail = 'usuario@exemplo.com';
  const validPassword = 'senhaValida123';

  group('Fluxo de Integração - Login (Sucesso e Navegação)', () {
    testWidgets('Deve autenticar com sucesso e navegar para TelaInicialScreen',
        (WidgetTester tester) async {
      // 1. Configura mock de autenticação com usuário existente do firebase_auth_mocks
      final mockUser = fam.MockUser(
        uid: 'user-uid-123',
        email: validEmail,
        displayName: 'Carlos',
      );
      final mockAuth = fam.MockFirebaseAuth(mockUser: mockUser);

      // 2. Renderiza a LoginScreen
      await tester.pumpWidget(createTestWidget(auth: mockAuth));
      await tester.pumpAndSettle();

      // 3. Localiza os campos de e-mail e senha por tipo
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));

      await tester.enterText(textFields.at(0), validEmail);
      await tester.enterText(textFields.at(1), validPassword);
      await tester.pump();

      // 4. Clica no botão "Entrar"
      final enterButton = find.widgetWithText(ElevatedButton, 'Entrar');
      expect(enterButton, findsOneWidget);

      await tester.tap(enterButton);
      await tester.pumpAndSettle();

      // 5. Verifica navegação
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);
    });
  });

  group('Validações de Formulário Local (Campos vazios / inválidos)', () {
    testWidgets(
        'Exibe mensagens de validação quando campos estão vazios e bloqueia chamada ao Firebase',
        (WidgetTester tester) async {
      final mockAuth = fam.MockFirebaseAuth();
      await tester.pumpWidget(createTestWidget(auth: mockAuth));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets(
        'Exibe erro quando e-mail é malformatado ou senha tem menos de 6 caracteres',
        (WidgetTester tester) async {
      final mockAuth = fam.MockFirebaseAuth();
      await tester.pumpWidget(createTestWidget(auth: mockAuth));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'email_invalido_sem_arroba');
      await tester.enterText(textFields.at(1), '123');
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });

  group('Cenários de Erro no Firebase (SnackBars de Falha)', () {
    late mockito_mocks.MockFirebaseAuth mockFirebaseAuthMockito;

    setUp(() {
      mockFirebaseAuthMockito = mockito_mocks.MockFirebaseAuth();
    });

    Future<void> executarTesteDeErro(
      WidgetTester tester, {
      required String errorCode,
      required String expectedMessage,
    }) async {
      when(mockFirebaseAuthMockito.signInWithEmailAndPassword(
        email: validEmail,
        password: validPassword,
      )).thenAnswer(
        (_) => throw FirebaseAuthException(code: errorCode),
      );

      await tester.pumpWidget(createTestWidget(auth: mockFirebaseAuthMockito));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), validEmail);
      await tester.enterText(textFields.at(1), validPassword);
      await tester.pump();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(expectedMessage), findsOneWidget);

      final snackBarWidget = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBarWidget.backgroundColor, Colors.red);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    }

    testWidgets('Exibe mensagem adequada quando código é "user-not-found"',
        (WidgetTester tester) async {
      await executarTesteDeErro(
        tester,
        errorCode: 'user-not-found',
        expectedMessage:
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
      );
    });

    testWidgets('Exibe mensagem adequada quando código é "wrong-password"',
        (WidgetTester tester) async {
      await executarTesteDeErro(
        tester,
        errorCode: 'wrong-password',
        expectedMessage:
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
      );
    });

    testWidgets('Exibe mensagem adequada quando código é "invalid-credential"',
        (WidgetTester tester) async {
      await executarTesteDeErro(
        tester,
        errorCode: 'invalid-credential',
        expectedMessage:
            'As credenciais fornecidas são inválidas. Tente novamente.',
      );
    });

    testWidgets(
        'Exibe mensagem genérica quando código for desconhecido/inesperado',
        (WidgetTester tester) async {
      await executarTesteDeErro(
        tester,
        errorCode: 'too-many-requests',
        expectedMessage:
            'Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.',
      );
    });
  });
}

