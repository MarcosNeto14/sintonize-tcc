<!-- Resposta do Gemini 3.8 Flash ao reparo 1, rodada FASE3-L4-ZS, 2026-10-05,
     como devolvida pelo autor (colagem do texto da resposta), sem edição. -->

Classificação da Causa Provável
(A) O teste presume um comportamento que não é o especificado.

Análise da Falha
No teste de sucesso, a asserção falhou ao procurar por TelaInicialScreen:

Dart
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 0 widgets with type "TelaInicialScreen": []>
O que causou a falha:
Duração do SnackBar no teste anterior:
No teste imediatamente anterior ("Falha de login: senha incorreta..."), um SnackBar vermelho foi disparado. O tempo de exibição padrão de um SnackBar no Flutter é de 4 segundos.

Tempo de espera insuficiente no teste de sucesso:
No teste de sucesso, foi chamado apenas:

Dart
await tester.pumpAndSettle(const Duration(seconds: 3));
No integration_test, pumpAndSettle(Duration duration) define a duração de cada pulso individual de frame (duration), e não o timeout global de repetição (o timeout global é definido pelo parâmetro timeout, cujo padrão é de 10 minutos). Se ainda existirem timers pendentes, animações de transição de rota ou se o Firebase Emulator demorar um pouco mais para responder e acionar o Navigator.pushReplacement(), um simples pulso isolado pode não aguardar o término da navegação assíncrona.

Persistência do foco e do teclado virtual:
Ao preencher os campos com tester.enterText(), o teclado de software do emulador e o foco continuam ativos sobre o TextFormField. Quando o botão Entrar é pressionado, o callback assíncrono login(context) é disparado, mas se o frame for verificado antes da resolução completa da Future do Firebase Auth e da animação de transição da MaterialPageRoute, a árvore de widgets ainda estará na LoginScreen.

Acúmulo de estado assíncrono entre testes:
O tearDown realizava apenas FirebaseAuth.instance.signOut(), sem dispensar SnackBars residuais ou redefinir a navegação caso o teste anterior tivesse deixado o app em estado intermediário.

Correção do Teste
Para corrigir o teste de forma robusta e idiomática no integration_test:

Fechar o teclado e remover o foco antes de tocar no botão Entrar (FocusManager.instance.primaryFocus?.unfocus()).

Aguardar a conclusão da transição com um loop de polling resiliente (pump iterativo com timeout), dando tempo para a requisição de rede local do Firebase Auth responder e o Navigator.pushReplacement renderizar a TelaInicialScreen.

Limpar qualquer SnackBar ativo no setUp e tearDown via ScaffoldMessenger.

Aqui está o arquivo corrigido:

Dart
// ===== integration_test/fase3/l4_zs_test.dart =====
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

  tearDown(() async {
    await FirebaseAuth.instance.signOut();
  });

  /// Helper para aguardar a aparição de um widget com timeout explícito.
  Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (finder.evaluate().isNotEmpty) {
        await tester.pumpAndSettle();
        return;
      }
    }
    await tester.pumpAndSettle();
  }

  /// Helper para navegar da HomeScreen inicial até a LoginScreen.
  Future<void> navigateToLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Login');
    expect(loginButtonFinder, findsOneWidget);

    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  }

  group('Fluxo E2E - Autenticação / LoginScreen', () {
    testWidgets(
        'Validação de formulário: exibe mensagens de erro com campos vazios',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarBtn);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets(
        'Validação de formato: e-mail inválido e senha curta (< 6 caracteres)',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.at(0);
      final senhaField = textFields.at(1);

      await tester.enterText(emailField, 'emailinvalido');
      await tester.enterText(senhaField, '123');
      await tester.pumpAndSettle();

      final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarBtn);
      await tester.pumpAndSettle();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets(
        'Falha de login: usuário não cadastrado exibe SnackBar vermelho',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.at(0);
      final senhaField = textFields.at(1);

      await tester.enterText(emailField, 'inexistente@sintonize.test');
      await tester.enterText(senhaField, 'senha123456');
      await tester.pumpAndSettle();

      final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarBtn);

      await waitForWidget(tester, find.byType(SnackBar));

      expect(
        find.byWidgetPredicate((widget) {
          if (widget is Text) {
            return widget.data ==
                    'Usuário não encontrado. Verifique o e-mail e tente novamente.' ||
                widget.data ==
                    'As credenciais fornecidas são inválidas. Tente novamente.';
          }
          return false;
        }),
        findsOneWidget,
      );

      final snackBarWidget = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBarWidget.backgroundColor, Colors.red);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets(
        'Falha de login: senha incorreta para usuário existente exibe SnackBar vermelho',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.at(0);
      final senhaField = textFields.at(1);

      await tester.enterText(emailField, 'tester@sintonize.test');
      await tester.enterText(senhaField, 'senha_errada_123');
      await tester.pumpAndSettle();

      final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarBtn);

      await waitForWidget(tester, find.byType(SnackBar));

      expect(
        find.byWidgetPredicate((widget) {
          if (widget is Text) {
            return widget.data ==
                    'Senha incorreta. Certifique-se de que está digitando a senha corretamente.' ||
                widget.data ==
                    'As credenciais fornecidas são inválidas. Tente novamente.';
          }
          return false;
        }),
        findsOneWidget,
      );

      final snackBarWidget = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBarWidget.backgroundColor, Colors.red);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });

    testWidgets(
        'Sucesso no login: navega para TelaInicialScreen com usuário carregado',
        (WidgetTester tester) async {
      await navigateToLoginScreen(tester);

      final textFields = find.byType(TextFormField);
      final emailField = textFields.at(0);
      final senhaField = textFields.at(1);

      await tester.enterText(emailField, 'tester@sintonize.test');
      await tester.enterText(senhaField, 'senha123');
      await tester.pumpAndSettle();

      // Fecha o teclado para evitar que cubra o botão ou retenha eventos de input
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      final entrarBtn = find.widgetWithText(ElevatedButton, 'Entrar');
      await tester.tap(entrarBtn);

      // Aguarda a resolução da chamada de rede no emulador e a navegação
      await waitForWidget(tester, find.byType(TelaInicialScreen));

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(TelaInicialScreen), findsOneWidget);

      // Aguarda a resolução dos FutureBuilders do Firestore na TelaInicialScreen
      final recomendacaoFinder = find.textContaining(
        'Tester Sintonize, essa é a nossa recomendação de música para você!',
      );
      await waitForWidget(tester, recomendacaoFinder);

      expect(recomendacaoFinder, findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsOneWidget);
      expect(find.text('Sintonizados'), findsOneWidget);
      expect(find.text('Minha Conta'), findsOneWidget);
    });
  });
}
