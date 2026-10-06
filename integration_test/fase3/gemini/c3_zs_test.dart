// ===== integration_test/fase3/c3_zs_test.dart =====
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sintonize/main.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
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

  /// Helper seguro para abrir o dropdown e selecionar o estado desejado
  Future<void> selecionarEstado(WidgetTester tester, String uf) async {
    final dropdownFinder = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(dropdownFinder);
    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    final itemTexto = find.text(uf);

    // O menu do DropdownButton cria um novo Scrollable para exibir os itens.
    // O último Scrollable da árvore é o menu suspenso aberto.
    final scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().length > 1) {
      await tester.scrollUntilVisible(
        itemTexto.last,
        50.0,
        scrollable: scrollables.last,
      );
      await tester.pumpAndSettle();
    }

    await tester.tap(itemTexto.last, warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  group('E2E - Fluxo de Cadastro e Seleção de Gêneros', () {
    testWidgets(
      'Deve exibir validações de campos obrigatórios ao submeter formulário vazio',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 1. Navegar da HomeScreen para CadastroScreen
        final botaoCadastroHome = find.widgetWithText(ElevatedButton, 'Cadastro');
        expect(botaoCadastroHome, findsOneWidget);
        await tester.tap(botaoCadastroHome);
        await tester.pumpAndSettle();

        expect(find.byType(CadastroScreen), findsOneWidget);

        // 2. Tocar no botão Cadastrar sem preencher nada
        final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(botaoCadastrar);
        await tester.tap(botaoCadastrar);
        await tester.pumpAndSettle();

        // 3. Validar se as mensagens de validação síncronas do Form apareceram
        expect(find.text('O nome é obrigatório'), findsOneWidget);
        expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
        expect(find.text('O e-mail é obrigatório'), findsOneWidget);
        expect(find.text('A senha é obrigatória'), findsOneWidget);
        expect(find.text('O CEP é obrigatório'), findsOneWidget);
        expect(find.text('O número é obrigatório'), findsOneWidget);

        expect(find.byType(GenerosCadastroScreen), findsNothing);
      },
    );

    testWidgets(
      'Deve exibir erro quando o e-mail já estiver cadastrado no Firebase Auth',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Navegar para a tela de cadastro
        await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
        await tester.pumpAndSettle();

        final camposTexto = find.byType(TextFormField);

        // Preenche com o e-mail já existente nos emuladores (tester@sintonize.test)
        await tester.enterText(camposTexto.at(0), 'Usuario Existente');
        await tester.enterText(camposTexto.at(1), '15101995'); // 15/10/1995
        await tester.enterText(camposTexto.at(2), 'tester@sintonize.test');
        await tester.enterText(camposTexto.at(3), 'senha123');
        await tester.enterText(camposTexto.at(4), 'senha123');

        await tester.ensureVisible(camposTexto.at(5));
        await tester.enterText(camposTexto.at(5), '50000000');
        await tester.enterText(camposTexto.at(6), 'Rua Principal');
        await tester.enterText(camposTexto.at(7), '100');
        await tester.enterText(camposTexto.at(8), 'Centro');
        await tester.enterText(camposTexto.at(9), 'Recife');

        // Selecionar estado via helper seguro
        await selecionarEstado(tester, 'PE');

        // Submeter cadastro
        final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(botaoCadastrar);
        await tester.tap(botaoCadastrar);

        // Aguarda a resposta assíncrona do Firebase Auth Emulator
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Confirma exibição do SnackBar de erro retornado pelo Firebase Auth
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('Erro ao cadastrar:'), findsOneWidget);
        expect(find.byType(GenerosCadastroScreen), findsNothing);
      },
    );

    testWidgets(
      'Deve realizar fluxo completo: Cadastro -> Generos (alerta de seleção) -> Sucesso e persistência -> Tela Inicial',
      (WidgetTester tester) async {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final novoEmail = 'novo_$timestamp@sintonize.test';
        const nomeUsuario = 'Novo Usuario E2E';

        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 1. Abrir CadastroScreen
        await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
        await tester.pumpAndSettle();
        expect(find.byType(CadastroScreen), findsOneWidget);

        final camposTexto = find.byType(TextFormField);

        // 2. Preencher formulário completo
        await tester.enterText(camposTexto.at(0), nomeUsuario);
        await tester.enterText(camposTexto.at(1), '20052000'); // 20/05/2000
        await tester.enterText(camposTexto.at(2), novoEmail);
        await tester.enterText(camposTexto.at(3), 'senhaSegura123');
        await tester.enterText(camposTexto.at(4), 'senhaSegura123');

        await tester.ensureVisible(camposTexto.at(5));
        await tester.enterText(camposTexto.at(5), '51020010');
        await tester.enterText(camposTexto.at(6), 'Avenida Boa Viagem');
        await tester.enterText(camposTexto.at(7), '500');
        await tester.enterText(camposTexto.at(8), 'Boa Viagem');
        await tester.enterText(camposTexto.at(9), 'Recife');

        // Selecionar estado via helper seguro
        await selecionarEstado(tester, 'PE');

        // 3. Submeter formulário
        final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(botaoCadastrar);
        await tester.tap(botaoCadastrar);

        // Aguarda criação no Auth e documento no Firestore
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // 4. Validar chegada na tela de gêneros
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);

        // 5. Cenário de validação: tentar confirmar sem marcar nenhum gênero
        final botaoConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(botaoConfirmar);
        await tester.tap(botaoConfirmar);
        await tester.pumpAndSettle();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );
        expect(find.byType(TelaInicialScreen), findsNothing);

        // 6. Selecionar gêneros ('Rock' e 'Jazz')
        final switchRock = find.descendant(
          of: find.ancestor(
            of: find.text('Rock'),
            matching: find.byType(Row),
          ),
          matching: find.byType(Switch),
        );
        await tester.tap(switchRock);
        await tester.pumpAndSettle();

        final switchJazz = find.descendant(
          of: find.ancestor(
            of: find.text('Jazz'),
            matching: find.byType(Row),
          ),
          matching: find.byType(Switch),
        );
        await tester.tap(switchJazz);
        await tester.pumpAndSettle();

        // 7. Confirmar gêneros
        await tester.ensureVisible(botaoConfirmar);
        await tester.tap(botaoConfirmar);

        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // 8. Validar chegada na TelaInicialScreen
        expect(find.byType(TelaInicialScreen), findsOneWidget);

        // 9. Validar persistência dos dados no Firestore Emulator
        final currentUser = FirebaseAuth.instance.currentUser;
        expect(currentUser, isNotNull);
        expect(currentUser!.email, novoEmail);

        final userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(currentUser.uid)
            .get();

        expect(userDoc.exists, isTrue);
        final userData = userDoc.data()!;
        expect(userData['nome'], nomeUsuario);
        expect(userData['email'], novoEmail);
        expect(userData['data_nasc'], '20/05/2000');
        expect(userData['endereco']['cidade'], 'Recife');
        expect(userData['endereco']['estado'], 'PE');

        final generosFavoritos = List<String>.from(userData['generos_favoritos'] ?? []);
        expect(generosFavoritos, containsAll(['Rock', 'Jazz']));
      },
    );
  });
}
