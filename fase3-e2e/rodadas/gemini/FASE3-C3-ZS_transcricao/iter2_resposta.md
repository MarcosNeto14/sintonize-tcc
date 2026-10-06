<!-- Resposta do Gemini 3.8 Flash ao reparo 2, rodada FASE3-C3-ZS, 2026-10-05,
     como devolvida pelo autor (colagem do texto da resposta), sem edição.
     Conversa: https://gemini.google.com/app/55a6da8c2e072fc4 -->

Classificação da Causa da Falha
(A) O teste presume um comportamento que não é o especificado (interação incorreta com a rota de popup do DropdownButton do Flutter).

Diagnóstico do Problema
Como o DropdownButtonFormField funciona internamente no Flutter:

Ao chamar _buildEstadoDropdown(), o widget monta 27 DropdownMenuItem<String> dentro da árvore.

Quando o DropdownButtonFormField é tocado, o Flutter abre uma rota modal (_DropdownRoute) sobreposta à tela.

Os itens originais continuam existindo na árvore de renderização do formulário original abaixo da rota, mas ficam ocultos ou fora da área interativa da rota modal.

O finder find.widgetWithText(DropdownMenuItem<String>, 'AC').last (ou find.text('AC').last) calculou o centro do item na coordenada Offset(209.7, 80.0), onde a rota modal do dropdown estava interceptando toques na área de clipping/fade (RenderMouseRegion/RenderPointerListener).

Consequentemente, o toque não acertou o item do menu, o menu não fechou, nenhum estado foi selecionado, e a validação/submissão do formulário travou com a rota do dropdown ainda aberta por cima.

Como selecionar um item de DropdownButton confiavelmente em testes E2E:

Em vez de buscar por tipo complexo ou .last, após tester.tap(dropdown) e pumpAndSettle(), a forma canônica de tocar no item aberto dentro do menu modal é tocar no widget Text exibido pelo popup (find.text('SP').last ou rolando até o item usando tester.scrollUntilVisible(...)), garantindo que o finder selecione o elemento ativo do menu suspenso ou fornecendo warnIfMissed: false.

Melhor ainda: dentro da rota modal do DropdownButton, o Flutter encapsula os itens visíveis. Ao usar find.text('SP').hitTestable() ou garantir que o widget alvo esteja visível e seja clicável com scroll na rota modal (find.byType(Scrollable)), a seleção ocorre perfeitamente.

Validação do SnackBar e transição assíncrona:

Quando o formulário falha ou tem sucesso, a chamada para o Firebase Auth Emulator precisa que as animações de navegação ou do SnackBar completem. A rota aberta do dropdown anterior estava impedindo o botão 'Cadastrar' de sequer disparar o _submit().

Código Corrigido do Teste
Dart
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

  /// Helper para selecionar um estado no Dropdown de forma segura no Flutter E2E
  Future<void> selecionarEstado(WidgetTester tester, String uf) async {
    final dropdownFinder = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(dropdownFinder);
    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    // Localiza a lista rolável dentro da rota modal aberta pelo Dropdown
    final popupScrollable = find.descendant(
      of: find.byType(Dialog).or(find.byWidgetPredicate(
            (w) => w.runtimeType.toString() == '_DropdownRoutePage<String>' ||
                   w.runtimeType.toString().contains('Dropdown'),
          )),
      matching: find.byType(Scrollable),
    );

    final itemTexto = find.text(uf);

    // Se o item não estiver visível na janela do popup, rola até ele
    if (popupScrollable.evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(
        itemTexto,
        50.0,
        scrollable: popupScrollable.first,
      );
      await tester.pumpAndSettle();
    }

    // Toca no item dentro do menu aberto (o último na árvore de widgets)
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
