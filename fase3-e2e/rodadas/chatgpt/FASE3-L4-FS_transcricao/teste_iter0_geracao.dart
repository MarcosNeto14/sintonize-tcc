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

  Future<void> esperar(
    WidgetTester tester,
    Finder finder, {
    int tentativas = 40,
  }) async {
    for (var i = 0; i < tentativas; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu: $finder');
  }

  Future<void> abrirLogin(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  }

  Future<void> preencherLogin(
    WidgetTester tester, {
    required String email,
    required String senha,
  }) async {
    final campos = find.byType(TextFormField);

    expect(campos, findsNWidgets(2));

    await tester.enterText(campos.at(0), email);
    await tester.enterText(campos.at(1), senha);
  }

  testWidgets(
    'login com credenciais válidas navega para a TelaInicialScreen',
    (tester) async {
      // Garante que não exista uma sessão anterior.
      await FirebaseAuth.instance.signOut();

      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: 'senha123',
      );

      await tester.tap(find.text('Entrar'));

      await esperar(
        tester,
        find.byType(TelaInicialScreen),
      );

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);
    },
  );

  testWidgets(
    'login com usuário inexistente exibe SnackBar vermelho com a mensagem correta',
    (tester) async {
      // A sessão do teste anterior não deve interferir neste fluxo.
      await FirebaseAuth.instance.signOut();

      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'usuario-inexistente@sintonize.test',
        senha: 'senha123',
      );

      await tester.tap(find.text('Entrar'));

      final snackBar = find.byType(SnackBar);

      await esperar(
        tester,
        snackBar,
      );

      expect(
        find.text(
          'Usuário não encontrado. Verifique o e-mail e tente novamente.',
        ),
        findsOneWidget,
      );

      expect(
        find.byType(LoginScreen),
        findsOneWidget,
      );

      expect(
        find.byType(TelaInicialScreen),
        findsNothing,
      );

      final snackBarWidget = tester.widget<SnackBar>(snackBar);

      expect(snackBarWidget.backgroundColor, Colors.red);
    },
  );
}
