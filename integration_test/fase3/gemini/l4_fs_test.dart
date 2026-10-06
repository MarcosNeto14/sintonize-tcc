import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sintonize/main.dart';
import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  setUp(() async {
    await FirebaseAuth.instance.signOut();
  });

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('Elemento não apareceu a tempo: $finder');
  }

  testWidgets(
    'Login: falha ao autenticar exibe SnackBar vermelho com mensagem de erro',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navega da HomeScreen para a LoginScreen
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);

      // Preenche os campos com credenciais incorretas
      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'usuario_inexistente@sintonize.test');
      await tester.enterText(campos.at(1), 'senhaInvalida123');

      // Fecha o teclado virtual para não cobrir o botão nem afetar o layout
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Rola até o botão "Entrar" e clica
      final botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(botaoEntrar);
      await tester.pumpAndSettle();
      await tester.tap(botaoEntrar);
      await tester.pump();

      // Aguarda o aparecimento do SnackBar na tela
      final snackBarFinder = find.byType(SnackBar);
      await esperar(tester, snackBarFinder);

      final SnackBar snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBarWidget.backgroundColor, Colors.red);

      final mensagemEncontrada = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.data ==
                    'Usuário não encontrado. Verifique o e-mail e tente novamente.' ||
                widget.data ==
                    'As credenciais fornecidas são inválidas. Tente novamente.' ||
                widget.data ==
                    'Senha incorreta. Certifique-se de que está digitando a senha corretamente.'),
      );
      expect(mensagemEncontrada, findsOneWidget);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    },
  );

  testWidgets(
    'Login: sucesso ao autenticar redireciona para a TelaInicialScreen',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navega da HomeScreen para a LoginScreen
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);

      // Preenche os campos com credenciais válidas do emulador
      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'tester@sintonize.test');
      await tester.enterText(campos.at(1), 'senha123');

      // Fecha o teclado virtual para garantir visão desobstruída
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Rola até o botão "Entrar" e clica
      final botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(botaoEntrar);
      await tester.pumpAndSettle();
      await tester.tap(botaoEntrar);
      await tester.pump();

      // Aguarda a autenticação e transição para TelaInicialScreen
      await esperar(tester, find.byType(TelaInicialScreen));
      await tester.pumpAndSettle();

      // Confirma que a LoginScreen foi substituída pela TelaInicialScreen
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);

      // Valida que a barra inferior está presente
      expect(find.text('Minha Conta'), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsOneWidget);
    },
  );
}

