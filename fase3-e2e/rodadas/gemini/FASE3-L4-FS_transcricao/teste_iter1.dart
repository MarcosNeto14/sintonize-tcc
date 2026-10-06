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
    // Garante que não haja sessão autenticada ativa antes de cada teste
    await FirebaseAuth.instance.signOut();
  });

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
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
      await tester.tap(find.text('Login'));
      await esperar(tester, find.byType(LoginScreen));
      await tester.pumpAndSettle();

      // Preenche com credenciais incorretas
      final camposTexto = find.byType(TextFormField);
      await tester.enterText(camposTexto.at(0), 'usuario_inexistente@sintonize.test');
      await tester.enterText(camposTexto.at(1), 'senhaInvalida123');
      await tester.pumpAndSettle();

      final botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(botaoEntrar);
      await tester.tap(botaoEntrar);
      await tester.pump();

      // Aguarda o aparecimento do SnackBar na tela
      final snackBarFinder = find.byType(SnackBar);
      await esperar(tester, snackBarFinder);

      // Verifica a cor vermelha de fundo
      final SnackBar snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBarWidget.backgroundColor, Colors.red);

      // Valida a mensagem mapeada para credencial inválida/usuário não encontrado
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

      // Permanece na LoginScreen
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
      await tester.tap(find.text('Login'));
      await esperar(tester, find.byType(LoginScreen));
      await tester.pumpAndSettle();

      // Preenche com credenciais válidas existentes no emulador
      final camposTexto = find.byType(TextFormField);
      await tester.enterText(camposTexto.at(0), 'tester@sintonize.test');
      await tester.enterText(camposTexto.at(1), 'senha123');
      await tester.pumpAndSettle();

      // Garante visibilidade e clica no botão Entrar
      final botaoEntrar = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.ensureVisible(botaoEntrar);
      await tester.tap(botaoEntrar);
      await tester.pump();

      // Aguarda a transição e renderização da TelaInicialScreen
      await esperar(tester, find.byType(TelaInicialScreen));

      // Assegura saída da LoginScreen e presença da TelaInicialScreen
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);

      // Valida elementos da barra inferior da tela inicial
      expect(find.text('Minha Conta'), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsOneWidget);
    },
  );
}

