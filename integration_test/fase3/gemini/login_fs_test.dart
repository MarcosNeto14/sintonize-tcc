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

  tearDown(() async {
    // Garante que o usuário seja desconectado entre os testes
    await FirebaseAuth.instance.signOut();
  });

  /// Aguarda recursivamente até que o [finder] apareça na árvore de widgets.
  Future<void> esperar(WidgetTester tester, Finder finder, {int tentativas = 40}) async {
    for (var i = 0; i < tentativas; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('Elemento não encontrado no tempo limite: $finder');
  }

  /// Navega da tela de boas-vindas inicial (HomeScreen) para a LoginScreen.
  Future<void> abrirTelaLogin(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final botaoLogin = find.widgetWithText(ElevatedButton, 'Login');
    await tester.tap(botaoLogin);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  }

  group('Fluxo E2E: Autenticação de Usuário (Login)', () {
    testWidgets('Sucesso: realiza login com credenciais válidas e navega para TelaInicialScreen',
        (tester) async {
      await abrirTelaLogin(tester);

      // Preenche os campos de e-mail e senha
      final camposTexto = find.byType(TextFormField);
      await tester.enterText(camposTexto.at(0), 'tester@sintonize.test');
      await tester.enterText(camposTexto.at(1), 'senha123');
      await tester.pumpAndSettle();

      // Clica em 'Entrar'
      final botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(botaoEntrar);

      // Aguarda a autenticação assíncrona e a transição para a TelaInicialScreen
      await esperar(tester, find.byType(TelaInicialScreen));

      // Assegura que saiu da LoginScreen e exibe os elementos da TelaInicialScreen
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);
      expect(find.text('Minha Conta'), findsOneWidget);
    });

    testWidgets('Falha: exibe SnackBar vermelho com erro ao informar credenciais incorretas',
        (tester) async {
      await abrirTelaLogin(tester);

      // Preenche credenciais incorretas/inexistentes
      final camposTexto = find.byType(TextFormField);
      await tester.enterText(camposTexto.at(0), 'naoexiste@sintonize.test');
      await tester.enterText(camposTexto.at(1), 'senhaerrada');
      await tester.pumpAndSettle();

      // Clica em 'Entrar'
      final botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(botaoEntrar);

      // Aguarda o SnackBar de erro ser exibido na tela
      final snackBarFinder = find.byType(SnackBar);
      await esperar(tester, snackBarFinder);

      // Valida que o SnackBar possui a cor de fundo vermelha
      final SnackBar snackBar = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBar.backgroundColor, Colors.red);

      // Valida mensagens esperadas de erro do FirebaseAuth (user-not-found ou invalid-credential)
      final mensagemErro = find.byWidgetPredicate((widget) {
        if (widget is Text && widget.data != null) {
          return widget.data!.contains('Usuário não encontrado') ||
              widget.data!.contains('As credenciais fornecidas são inválidas');
        }
        return false;
      });

      expect(mensagemErro, findsOneWidget);

      // Permanece na tela de login
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });
}

