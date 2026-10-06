import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/main.dart';
import 'package:sintonize/tela-inicial.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  /// Aguarda até que o widget especificado pelo [finder] apareça na árvore de widgets.
  Future<void> esperar(WidgetTester tester, Finder finder, {int tentativas = 40}) async {
    for (var i = 0; i < tentativas; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('Elemento não encontrado a tempo: $finder');
  }

  testWidgets(
      'cadastro: cria conta no Auth/Firestore, seleciona generos e conclui cadastro',
      (tester) async {
    // 1. Inicializa o aplicativo
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 2. Navega da HomeScreen para CadastroScreen
    final btnCadastroHome = find.widgetWithText(ElevatedButton, 'Cadastro');
    expect(btnCadastroHome, findsOneWidget);
    await tester.tap(btnCadastroHome);
    await tester.pumpAndSettle();

    expect(find.byType(CadastroScreen), findsOneWidget);

    final scrollFinder = find.byType(SingleChildScrollView).first;

    // Helper robusto para preencher campos buscando pelo Label acima do TextFormField
    Future<void> preencherCampoPorLabel(String label, String valor) async {
      final labelFinder = find.text(label);
      await tester.dragUntilVisible(
        labelFinder,
        scrollFinder,
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      final campoFinder = find.descendant(
        of: find.ancestor(of: labelFinder, matching: find.byType(Column)).first,
        matching: find.byType(TextFormField),
      );

      await tester.enterText(campoFinder, valor);
      await tester.pumpAndSettle();
    }

    final String emailTeste =
        'novo_usuario_${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

    // 3. Preenche cada campo nominalmente
    await preencherCampoPorLabel('Nome', 'Carlos Silva');
    await preencherCampoPorLabel('Data de Nascimento', '15101995'); // Gera 15/10/1995 via formatter
    await preencherCampoPorLabel('E-mail', emailTeste);
    await preencherCampoPorLabel('Senha', 'senhaSegura123');
    await preencherCampoPorLabel('Confirmar Senha', 'senhaSegura123');
    await preencherCampoPorLabel('CEP', '50000000'); // Gera 50000-000 via formatter
    await preencherCampoPorLabel('Rua', 'Rua das Flores');
    await preencherCampoPorLabel('Número', '123');
    await preencherCampoPorLabel('Bairro', 'Boa Viagem');
    await preencherCampoPorLabel('Cidade', 'Recife');

    // Seleciona o Estado no DropdownButtonFormField
    final dropdownFinder = find.byType(DropdownButtonFormField<String>);
    await tester.dragUntilVisible(
      dropdownFinder,
      scrollFinder,
      const Offset(0, -50),
    );
    await tester.pumpAndSettle();

    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    // Rola a lista interna do Dropdown caso 'PE' esteja fora do viewport inicial do popup
    final itemPE = find.widgetWithText(DropdownMenuItem<String>, 'PE').last;
    final dropdownList = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      itemPE,
      100.0,
      scrollable: dropdownList,
    );
    await tester.pumpAndSettle();

    await tester.tap(itemPE, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Rola até o botão "Cadastrar" e aciona o submit
    final btnCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
    await tester.dragUntilVisible(
      btnCadastrar,
      scrollFinder,
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();

    await tester.tap(btnCadastrar);

    // 4. Aguarda criação da conta e redirecionamento para a tela de gêneros
    await esperar(tester, find.byType(GenerosCadastroScreen));
    expect(find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget);

    // 5. Seleciona os gêneros musicais (Rock e Pop)
    final rockCard = find.ancestor(
      of: find.text('Rock'),
      matching: find.byType(Card),
    );
    final popCard = find.ancestor(
      of: find.text('Pop'),
      matching: find.byType(Card),
    );

    final switchRock = find.descendant(of: rockCard, matching: find.byType(Switch));
    final switchPop = find.descendant(of: popCard, matching: find.byType(Switch));

    await tester.tap(switchRock);
    await tester.pumpAndSettle();

    await tester.tap(switchPop);
    await tester.pumpAndSettle();

    // 6. Confirma a seleção de gêneros
    final btnConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
    await tester.tap(btnConfirmar);

    // 7. Confirma a transição para a TelaInicialScreen
    await esperar(tester, find.byType(TelaInicialScreen));
    expect(find.byType(TelaInicialScreen), findsOneWidget);

    // 8. Asserções diretas no Firestore para confirmar integridade dos dados gravados
    final currentUser = FirebaseAuth.instance.currentUser;
    expect(currentUser, isNotNull);
    expect(currentUser!.email, emailTeste);

    final userDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(currentUser.uid)
        .get();

    expect(userDoc.exists, isTrue);
    final dados = userDoc.data()!;
    expect(dados['nome'], 'Carlos Silva');
    expect(dados['email'], emailTeste);
    expect(dados['data_nasc'], '15/10/1995');
    expect(dados['endereco']['cidade'], 'Recife');
    expect(dados['endereco']['estado'], 'PE');

    final List<dynamic> generosSalvos = dados['generos_favoritos'];
    expect(generosSalvos, containsAll(['Rock', 'Pop']));
  });
}

