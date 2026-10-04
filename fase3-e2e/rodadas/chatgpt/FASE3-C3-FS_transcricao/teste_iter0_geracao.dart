import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  testWidgets(
    'cadastro: cria conta, seleciona gêneros e salva no Firestore',
    (tester) async {
      final email =
          'e2e-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);

      // ---------------------------------------------------------------
      // 1. Abre CadastroScreen
      // ---------------------------------------------------------------

      await tester.tap(find.text('Cadastro'));
      await tester.pumpAndSettle();

      expect(find.text('Cadastrar'), findsOneWidget);

      // ---------------------------------------------------------------
      // 2. Preenche o formulário de cadastro
      // ---------------------------------------------------------------

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

      // CEP válido para passar na validação.
      // O teste não depende do retorno do ViaCEP para a persistência:
      // os campos de endereço são preenchidos explicitamente.
      await tester.enterText(
        campos.at(5),
        '01001-000',
      );

      await tester.pump(const Duration(seconds: 2));

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

      // Seleciona SP no DropdownButtonFormField.
      await tester.tap(
        find.byType(DropdownButtonFormField<String>),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('SP').last);
      await tester.pumpAndSettle();

      // ---------------------------------------------------------------
      // 3. Cria a conta pelo Firebase Auth e o documento no Firestore
      // ---------------------------------------------------------------

      await tester.tap(find.text('Cadastrar'));

      // A navegação só ocorre depois que Auth + Firestore terminam.
      await esperar(
        tester,
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
      );

      expect(find.text('Confirmar'), findsOneWidget);

      // ---------------------------------------------------------------
      // 4. Seleciona Rock e Pop
      // ---------------------------------------------------------------

      final rockCard = find.ancestor(
        of: find.text('Rock'),
        matching: find.byType(Card),
      );

      final popCard = find.ancestor(
        of: find.text('Pop'),
        matching: find.byType(Card),
      );

      await tester.tap(
        find.descendant(
          of: rockCard,
          matching: find.byType(Switch),
        ),
      );

      await tester.tap(
        find.descendant(
          of: popCard,
          matching: find.byType(Switch),
        ),
      );

      await tester.pumpAndSettle();

      // ---------------------------------------------------------------
      // 5. Confirma os gêneros
      // ---------------------------------------------------------------

      await tester.tap(find.text('Confirmar'));

      // Confirmar chama update() no documento e depois navega.
      await esperar(
        tester,
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
      );

      // ---------------------------------------------------------------
      // 6. Verifica que o fluxo chegou à TelaInicialScreen
      // ---------------------------------------------------------------

      expect(
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // ---------------------------------------------------------------
      // 7. Verifica Auth e Firestore reais
      // ---------------------------------------------------------------

      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);
      expect(user!.email, email);

      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(snapshot.exists, isTrue);

      final data = snapshot.data()!;

      // Documento criado durante o cadastro.
      expect(data['nome'], 'Usuário E2E');
      expect(data['email'], email);

      // Campo atualizado pela GenerosCadastroScreen.
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
      );
    },
  );
}
