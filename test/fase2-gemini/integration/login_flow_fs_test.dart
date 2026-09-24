// test/integration/login_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Importe as telas conforme a estrutura do seu projeto:
import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

// Gerar mock customizado do FirebaseAuth para simular erros específicos
class MockFirebaseAuthWithErrors extends Mock implements FirebaseAuth {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Login - Sintonize', () {
    Widget montarApp(FirebaseAuth auth) {
      return MaterialApp(
        home: LoginScreen(auth: auth),
      );
    }

    testWidgets(
      'Login com credenciais válidas navega com sucesso para TelaInicialScreen',
      (WidgetTester tester) async {
        // Mock padrão do firebase_auth_mocks com o usuário pré-cadastrado
        final mockUser = MockUser(
          uid: 'user123',
          email: 'teste@sintonize.com',
          displayName: 'Teste',
        );
        final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: false);

        await tester.pumpWidget(montarApp(mockAuth));

        // Preenche os campos
        await tester.enterText(
          find.byType(TextFormField).at(0),
          'teste@sintonize.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'senha123',
        );

        // Garante que o botão esteja visível na tela com Scroll
        final botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
        await tester.ensureVisible(botaoEntrar);
        await tester.tap(botaoEntrar);

        // Aguarda transições e navegação
        await tester.pumpAndSettle();

        // Verifica se a tela inicial foi exibida e a tela de login saiu da pilha
        expect(find.byType(TelaInicialScreen), findsOneWidget);
        expect(find.byType(LoginScreen), findsNothing);
      },
    );

    testWidgets(
      'Login com usuário inexistente exibe SnackBar vermelho com erro correspondente',
      (WidgetTester tester) async {
        final mockAuth = MockFirebaseAuthWithErrors();

        // Simula o lançamento de FirebaseAuthException com código 'user-not-found'
        when(
          mockAuth.signInWithEmailAndPassword(
            email: 'naoexiste@sintonize.com',
            password: 'senhaValida123',
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found for that email.',
          ),
        );

        await tester.pumpWidget(montarApp(mockAuth));

        // Preenche campos válidos para passar da validação do Form
        await tester.enterText(
          find.byType(TextFormField).at(0),
          'naoexiste@sintonize.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'senhaValida123',
        );

        final botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
        await tester.ensureVisible(botaoEntrar);
        await tester.tap(botaoEntrar);

        // pump para renderizar a SnackBar (sem settle para mantê-la aberta no frame)
        await tester.pump();

        // Valida texto da mensagem configurada para user-not-found
        const mensagemEsperada =
            'Usuário não encontrado. Verifique o e-mail e tente novamente.';
        expect(find.text(mensagemEsperada), findsOneWidget);

        // Valida cor vermelha da SnackBar
        final snackBarFinder = find.byType(SnackBar);
        expect(snackBarFinder, findsOneWidget);
        final snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
        expect(snackBarWidget.backgroundColor, Colors.red);

        // Garante que permaneceu na tela de Login
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );

    testWidgets(
      'Login com senha incorreta exibe SnackBar vermelho com erro correspondente',
      (WidgetTester tester) async {
        final mockAuth = MockFirebaseAuthWithErrors();

        when(
          mockAuth.signInWithEmailAndPassword(
            email: 'teste@sintonize.com',
            password: 'senhaErrada',
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'wrong-password',
            message: 'Wrong password.',
          ),
        );

        await tester.pumpWidget(montarApp(mockAuth));

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'teste@sintonize.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'senhaErrada',
        );

        final botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
        await tester.ensureVisible(botaoEntrar);
        await tester.tap(botaoEntrar);

        await tester.pump();

        const mensagemEsperada =
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.';
        expect(find.text(mensagemEsperada), findsOneWidget);

        final snackBarWidget = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBarWidget.backgroundColor, Colors.red);
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );

    testWidgets(
      'Campos vazios bloqueiam a chamada ao Firebase e exibem mensagens de validação',
      (WidgetTester tester) async {
        final mockAuth = MockFirebaseAuthWithErrors();

        await tester.pumpWidget(montarApp(mockAuth));

        final botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
        await tester.ensureVisible(botaoEntrar);
        await tester.tap(botaoEntrar);

        await tester.pump();

        // Verifica mensagens de validação do Form
        expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
        expect(find.text('Por favor, insira sua senha'), findsOneWidget);

        // Garante que o método do Firebase não foi chamado
        verifyNever(
          mockAuth.signInWithEmailAndPassword(
            email: anyNamed('email') ?? '',
            password: anyNamed('password') ?? '',
          ),
        );
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );
  });
}

