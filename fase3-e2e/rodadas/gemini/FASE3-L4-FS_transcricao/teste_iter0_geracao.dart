import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';
import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  // Função auxiliar para aguardar elementos com renderização assíncrona/rede
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

      // Preenche com credenciais incorretas (usuário inexistente ou credencial inválida)
      final camposTexto = find.byType(TextFormField);
      await tester.enterText(camposTexto.at(0), 'usuario_inexistente@sintonize.test');
      await tester.enterText(camposTexto.at(1), 'senhaInvalida123');

      // Toca em "Entrar"
      await tester.tap(find.text('Entrar'));

      // Aguarda o aparecimento do SnackBar na tela
      final snackBarFinder = find.byType(SnackBar);
      await esperar(tester, snackBarFinder);

      // Verifica se o SnackBar foi exibido com a cor de fundo vermelha
      final SnackBar snackBarWidget = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBarWidget.backgroundColor, Colors.red);

      // Valida que uma das mensagens tratadas para credenciais inválidas/inexistentes foi exibida
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

      // Garante que o usuário permanece na LoginScreen
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

      // Preenche com o usuário já populado no Firebase Emulator
      final camposTexto = find.byType(TextFormField);
      await tester.enterText(camposTexto.at(0), 'tester@sintonize.test');
      await tester.enterText(camposTexto.at(1), 'senha123');

      // Toca em "Entrar"
      await tester.tap(find.text('Entrar'));

      // Aguarda a transição e carregamento da TelaInicialScreen
      await esperar(tester, find.byType(TelaInicialScreen));

      // Assegura que saiu da LoginScreen e está na TelaInicialScreen
      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);

      // Verifica a renderização de elementos característicos da tela inicial
      expect(find.text('Minha Conta'), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsOneWidget);
    },
  );
}

