import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

// Caso necessário, importe os arquivos reais do seu projeto:
import 'package:sintonize/login_screen.dart';
import 'package:sintonize/tela_inicial_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    // Helper para montar o widget em ambiente de teste
    Widget createWidgetUnderTest({FirebaseAuth? auth}) {
      return MaterialApp(
        home: LoginScreen(auth: auth ?? mockAuth),
      );
    }

    testWidgets('deve renderizar os campos de email, senha, botão e imagem', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    });

    group('Validações de Formulário', () {
      testWidgets('deve exibir erros de obrigatoriedade quando campos estão vazios', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
        await tester.pump();

        expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
        expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      });

      testWidgets('deve exibir erro quando formato de e-mail é inválido', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        await tester.enterText(find.byType(TextFormField).at(0), 'email_invalido');
        await tester.enterText(find.byType(TextFormField).at(1), '123456');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
        await tester.pump();

        expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
        expect(find.text('Por favor, insira sua senha'), findsNothing);
      });

      testWidgets('deve exibir erro quando a senha tem menos de 6 caracteres', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
        await tester.enterText(find.byType(TextFormField).at(1), '12345');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
        await tester.pump();

        expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      });
    });

    group('Tratamento de Exceções do Firebase Auth', () {
      testWidgets('deve exibir SnackBar de "user-not-found"', (tester) async {
        final authComErro = MockFirebaseAuth();
        whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
            .on(authComErro)
            .thenThrow(FirebaseAuthException(code: 'user-not-found'));

        await tester.pumpWidget(createWidgetUnderTest(auth: authComErro));

        await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'senha123');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text('Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
          findsOneWidget,
        );
      });

      testWidgets('deve exibir SnackBar de "wrong-password"', (tester) async {
        final authComErro = MockFirebaseAuth();
        whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
            .on(authComErro)
            .thenThrow(FirebaseAuthException(code: 'wrong-password'));

        await tester.pumpWidget(createWidgetUnderTest(auth: authComErro));

        await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'senhaerrada');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.'),
          findsOneWidget,
        );
      });

      testWidgets('deve exibir SnackBar de "invalid-credential"', (tester) async {
        final authComErro = MockFirebaseAuth();
        whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
            .on(authComErro)
            .thenThrow(FirebaseAuthException(code: 'invalid-credential'));

        await tester.pumpWidget(createWidgetUnderTest(auth: authComErro));

        await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'senha123');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text('As credenciais fornecidas são inválidas. Tente novamente.'),
          findsOneWidget,
        );
      });

      testWidgets('deve exibir mensagem genérica para erros inesperados', (tester) async {
        final authComErro = MockFirebaseAuth();
        whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
            .on(authComErro)
            .thenThrow(FirebaseAuthException(code: 'network-request-failed'));

        await tester.pumpWidget(createWidgetUnderTest(auth: authComErro));

        await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
        await tester.enterText(find.byType(TextFormField).at(1), 'senha123');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text('Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.'),
          findsOneWidget,
        );
      });
    });

    group('Fluxo de Sucesso', () {
      testWidgets('deve navegar para TelaInicialScreen ao realizar login com sucesso', (tester) async {
        // MockFirebaseAuth autentica com sucesso por padrão se não lançar exceção
        await tester.pumpWidget(createWidgetUnderTest(auth: mockAuth));

        await tester.enterText(find.byType(TextFormField).at(0), 'usuario@sintonize.com');
        await tester.enterText(find.byType(TextFormField).at(1), '123456');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
        await tester.pumpAndSettle();

        // Garante que navegou para a TelaInicialScreen e substituiu a rota
        expect(find.byType(TelaInicialScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      });
    });
  });
}

