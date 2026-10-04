import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu: $finder');
  }

  Future<void> tornarVisivel(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'cadastro: cria conta, seleciona gêneros e salva no Firestore',
    (tester) async {
      final email =
          'e2e-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      // -----------------------------------------------------------------
      // 1. Inicia o aplicativo real
      // -----------------------------------------------------------------

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(
        find.text('Bem-vindo ao Sintonize!'),
        findsOneWidget,
      );

      // -----------------------------------------------------------------
      // 2. Abre a tela de cadastro
      // -----------------------------------------------------------------

      await tester.tap(find.text('Cadastro'));
      await tester.pumpAndSettle();

      expect(
        find.text('Cadastrar'),
        findsOneWidget,
      );

      // -----------------------------------------------------------------
      // 3. Preenche o formulário
      // -----------------------------------------------------------------

      final campos = find.byType(TextFormField);

      await tester.enterText(
        campos.at(0),
        'Usuário E2E',
      );

      await tester.enterText(
        campos.at(1),
        '01/01/2000',
      );

      await tester.enterText(
        campos.at(2),
        email,
      );

      await tester.enterText(
        campos.at(3),
        'senha123',
      );

      await tester.enterText(
        campos.at(4),
        'senha123',
      );

      // CEP.
      await tester.enterText(
        campos.at(5),
        '01001-000',
      );

      // O CEP dispara uma consulta ao ViaCEP na implementação atual.
      // Damos tempo para ela terminar antes de preencher os campos
      // que podem ter sido preenchidos automaticamente.
      await tester.pump(const Duration(seconds: 2));

      // Sobrescreve os campos de endereço explicitamente para que os
      // dados persistidos pelo cadastro sejam determinados pelo teste.
      await tester.enterText(
        campos.at(6),
        'Praça da Sé',
      );

      await tester.enterText(
        campos.at(7),
        '100',
      );

      await tester.enterText(
        campos.at(8),
        'Sé',
      );

      await tester.enterText(
        campos.at(9),
        'São Paulo',
      );

      // -----------------------------------------------------------------
      // 4. Seleciona o estado
      // -----------------------------------------------------------------

      final estadoDropdown =
          find.byType(DropdownButtonFormField<String>);

      expect(
        estadoDropdown,
        findsOneWidget,
      );

      // O Dropdown está mais abaixo no SingleChildScrollView.
      await tornarVisivel(
        tester,
        estadoDropdown,
      );

      await tester.tap(estadoDropdown);
      await tester.pumpAndSettle();

      // A lista do Dropdown foi aberta. Selecionamos SP.
      final opcaoSp = find.text('SP').last;

      expect(
        opcaoSp,
        findsOneWidget,
      );

      await tester.tap(opcaoSp);
      await tester.pumpAndSettle();

      // -----------------------------------------------------------------
      // 5. Torna o botão Cadastrar visível e cria a conta
      // -----------------------------------------------------------------

      final botaoCadastrar = find.text('Cadastrar');

      expect(
        botaoCadastrar,
        findsOneWidget,
      );

      await tornarVisivel(
        tester,
        botaoCadastrar,
      );

      await tester.tap(botaoCadastrar);

      // A aplicação só navega depois de:
      //   1. createUserWithEmailAndPassword()
      //   2. usuarios/{uid}.set(...)
      await esperar(
        tester,
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
      );

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsOneWidget,
      );

      expect(
        find.text('Confirmar'),
        findsOneWidget,
      );

      // -----------------------------------------------------------------
      // 6. Seleciona Rock
      // -----------------------------------------------------------------

      final rockCard = find.ancestor(
        of: find.text('Rock'),
        matching: find.byType(Card),
      );

      expect(
        rockCard,
        findsOneWidget,
      );

      final rockSwitch = find.descendant(
        of: rockCard,
        matching: find.byType(Switch),
      );

      expect(
        rockSwitch,
        findsOneWidget,
      );

      await tornarVisivel(
        tester,
        rockSwitch,
      );

      await tester.tap(rockSwitch);
      await tester.pumpAndSettle();

      // -----------------------------------------------------------------
      // 7. Seleciona Pop
      // -----------------------------------------------------------------

      final popCard = find.ancestor(
        of: find.text('Pop'),
        matching: find.byType(Card),
      );

      expect(
        popCard,
        findsOneWidget,
      );

      final popSwitch = find.descendant(
        of: popCard,
        matching: find.byType(Switch),
      );

      expect(
        popSwitch,
        findsOneWidget,
      );

      await tornarVisivel(
        tester,
        popSwitch,
      );

      await tester.tap(popSwitch);
      await tester.pumpAndSettle();

      // -----------------------------------------------------------------
      // 8. Confirma os gêneros
      // -----------------------------------------------------------------

      final botaoConfirmar = find.text('Confirmar');

      await tornarVisivel(
        tester,
        botaoConfirmar,
      );

      await tester.tap(botaoConfirmar);

      // _salvarGeneros() faz o update no Firestore antes de navegar.
      await esperar(
        tester,
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
      );

      // -----------------------------------------------------------------
      // 9. Verifica a navegação para TelaInicialScreen
      // -----------------------------------------------------------------

      expect(
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // -----------------------------------------------------------------
      // 10. Verifica o usuário real no Firebase Auth Emulator
      // -----------------------------------------------------------------

      final user = FirebaseAuth.instance.currentUser;

      expect(
        user,
        isNotNull,
        reason:
            'O cadastro deveria criar um usuário no Firebase Auth.',
      );

      expect(
        user!.email,
        email,
      );

      // -----------------------------------------------------------------
      // 11. Verifica o documento real no Firestore Emulator
      // -----------------------------------------------------------------

      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(
        snapshot.exists,
        isTrue,
        reason:
            'O cadastro deveria criar usuarios/{uid} no Firestore.',
      );

      final data = snapshot.data()!;

      // Dados criados pela CadastroScreen.
      expect(
        data['nome'],
        'Usuário E2E',
      );

      expect(
        data['email'],
        email,
      );

      // Dados adicionados pela GenerosCadastroScreen.
      expect(
        data['generos_favoritos'],
        containsAll(<String>[
          'Rock',
          'Pop',
        ]),
      );

      expect(
        (data['generos_favoritos'] as List).length,
        2,
        reason:
            'O teste selecionou exatamente Rock e Pop.',
      );
    },
  );
}
