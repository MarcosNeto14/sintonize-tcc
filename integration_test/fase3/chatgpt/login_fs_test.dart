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
    Duration timeout = const Duration(seconds: 10),
  }) async {
    const intervalo = Duration(milliseconds: 250);
    final tentativas =
        timeout.inMilliseconds ~/ intervalo.inMilliseconds;

    for (var i = 0; i < tentativas; i++) {
      await tester.pump(intervalo);

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

    await esperar(
      tester,
      find.byType(LoginScreen),
    );

    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  }

  tearDown(() async {
    // Garante que um teste não deixe a sessão autenticada
    // para o teste seguinte.
    await FirebaseAuth.instance.signOut();
  });

  testWidgets(
    'login: credenciais válidas levam para a TelaInicialScreen',
    (tester) async {
      await abrirLogin(tester);

      final campos = find.byType(TextFormField);

      expect(campos, findsNWidgets(2));

      await tester.enterText(
        campos.at(0),
        'tester@sintonize.test',
      );

      await tester.enterText(
        campos.at(1),
        'senha123',
      );

      await tester.tap(find.text('Entrar'));

      await esperar(
        tester,
        find.byType(TelaInicialScreen),
      );

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);

      // A TelaInicialScreen carrega o nome do usuário pelo Firestore.
      // Esperamos pelo texto que confirma que a tela está realmente
      // utilizando o usuário autenticado.
      await esperar(
        tester,
        find.textContaining('Tester Sintonize'),
      );

      expect(
        find.textContaining(
          'Tester Sintonize, essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      expect(
        FirebaseAuth.instance.currentUser?.email,
        'tester@sintonize.test',
      );
    },
  );

  testWidgets(
    'login: usuário inexistente exibe SnackBar de usuário não encontrado',
    (tester) async {
      await abrirLogin(tester);

      final campos = find.byType(TextFormField);

      await tester.enterText(
        campos.at(0),
        'usuario-inexistente@sintonize.test',
      );

      await tester.enterText(
        campos.at(1),
        'senha123',
      );

      await tester.tap(find.text('Entrar'));

      const mensagem =
          'Usuário não encontrado. Verifique o e-mail e tente novamente.';

      await esperar(
        tester,
        find.text(mensagem),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);

      final snackBar = find.byType(SnackBar);

      expect(snackBar, findsOneWidget);
      expect(find.text(mensagem), findsOneWidget);

      final SnackBar widget =
          tester.widget<SnackBar>(snackBar);

      expect(widget.backgroundColor, Colors.red);
    },
  );
}
