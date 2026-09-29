import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/login.dart';
import 'package:sintonize/main.dart';
import 'package:sintonize/tela-inicial.dart';

import 'firebase_test_helper.dart';
import 'seed.dart';

/// Fluxo de login (E2E-02 do roteiro manual, `e2e-manual/E2E-02_login_completo.md`):
/// HomeScreen → LoginScreen → TelaInicialScreen, com os 4 cenários de erro.
/// Roda no AVD contra os emuladores Auth/Firestore, com o usuário do seed.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
    await seedEmulators();
  });

  // Cada teste começa deslogado; a HomeScreen não depende do estado de auth,
  // mas a TelaInicialScreen lê FirebaseAuth.instance.currentUser.
  setUp(() async {
    await FirebaseAuth.instance.signOut();
  });

  /// Abre o app e vai da HomeScreen para a LoginScreen (passo 1 do roteiro).
  Future<void> abrirLogin(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  }

  /// Os dois TextFormField da LoginScreen, na ordem em que aparecem.
  Finder campoEmail() => find.byType(TextFormField).at(0);
  Finder campoSenha() => find.byType(TextFormField).at(1);

  /// Bombeia até o finder aparecer ou o tempo esgotar. `pumpAndSettle` não
  /// serve depois do "Entrar": há chamadas de rede e FutureBuilders em série.
  Future<void> pumpAte(WidgetTester tester, Finder finder,
      {Duration timeout = const Duration(seconds: 20)}) async {
    final fim = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(fim)) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('não apareceu em ${timeout.inSeconds}s: $finder');
  }

  group('cenários de erro (validação local, sem rede)', () {
    testWidgets('E1: campos vazios', (tester) async {
      await abrirLogin(tester);
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('E2: e-mail inválido', (tester) async {
      await abrirLogin(tester);
      await tester.enterText(campoEmail(), 'nao-e-um-email');
      await tester.enterText(campoSenha(), seedSenha);
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('E3: senha com menos de 6 caracteres', (tester) async {
      await abrirLogin(tester);
      await tester.enterText(campoEmail(), seedEmail);
      await tester.enterText(campoSenha(), '12345');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  testWidgets('E4: senha incorreta mostra SnackBar de erro e não navega',
      (tester) async {
    await abrirLogin(tester);
    await tester.enterText(campoEmail(), seedEmail);
    await tester.enterText(campoSenha(), 'senha-errada');
    await tester.tap(find.text('Entrar'));

    await pumpAte(tester, find.byType(SnackBar));
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(TelaInicialScreen), findsNothing);
    expect(FirebaseAuth.instance.currentUser, isNull);

    // Registra qual dos ramos de login.dart o emulador acionou.
    final snack = tester.widget<SnackBar>(find.byType(SnackBar));
    // ignore: avoid_print
    print('E4 SnackBar: ${(snack.content as Text).data}');
  });

  testWidgets('login válido chega à TelaInicialScreen com a saudação',
      (tester) async {
    await abrirLogin(tester);
    await tester.enterText(campoEmail(), seedEmail);
    await tester.enterText(campoSenha(), seedSenha);
    await tester.tap(find.text('Entrar'));

    await pumpAte(tester, find.byType(TelaInicialScreen));
    expect(find.byType(LoginScreen), findsNothing);
    expect(FirebaseAuth.instance.currentUser?.email, seedEmail);

    // Saudação: `_formatName('tester sintonize')` → 'Tester Sintonize'.
    final saudacao = find.textContaining(
      'Tester Sintonize, essa é a nossa recomendação de música para você!',
    );
    await pumpAte(tester, saudacao);
    expect(saudacao, findsOneWidget);

    // Recomendação: com generos_favoritos = [rock, pop], sai uma das duas.
    final recomendacao = find.byWidgetPredicate((w) =>
        w is Text &&
        (w.data == 'Bohemian Rhapsody' || w.data == 'Billie Jean'));
    await pumpAte(tester, recomendacao);
    expect(recomendacao, findsOneWidget);
  });
}
