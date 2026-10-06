// ===== integration_test/fase3/cadastro_fluxo_test.dart =====
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
    // Garante que nenhum usuário permaneça autenticado entre os testes
    await FirebaseAuth.instance.signOut();
  });

  tearDown(() async {
    await FirebaseAuth.instance.signOut();
  });

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

        // 2. Tocar diretamente no botão Cadastrar sem preencher nada
        final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(botaoCadastrar);
        await tester.tap(botaoCadastrar);
        await tester.pumpAndSettle();

        // 3. Validar se as mensagens de erro síncronas do Form apareceram
        expect(find.text('O nome é obrigatório'), findsOneWidget);
        expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
        expect(find.text('O e-mail é obrigatório'), findsOneWidget);
        expect(find.text('A senha é obrigatória'), findsOneWidget);
        expect(find.text('O CEP é obrigatório'), findsOneWidget);
        expect(find.text('O número é obrigatório'), findsOneWidget);

        // Garante que não transitou de tela
        expect(find.byType(GenerosCadastroScreen), findsNothing);
      },
    );

    testWidgets(
      'Deve exibir erro quando o e-mail já estiver cadastrado no Firebase Auth',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Navegar para o cadastro
        await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
        await tester.pumpAndSettle();

        // Preenche com o e-mail que já existe nos emuladores (tester@sintonize.test)
        final camposTexto = find.byType(TextFormField);

        // Preenchimento dos campos:
        // Ordem na tela: Nome, DataNasc, Email, Senha, ConfSenha, CEP, Rua, Numero, Bairro, Cidade
        await tester.enterText(camposTexto.at(0), 'Usuario Teste');
        await tester.enterText(camposTexto.at(1), '15101995'); // Data formatada: 15/10/1995
        await tester.enterText(camposTexto.at(2), 'tester@sintonize.test');
        await tester.enterText(camposTexto.at(3), 'senha123');
        await tester.enterText(camposTexto.at(4), 'senha123');

        await tester.ensureVisible(camposTexto.at(5));
        await tester.enterText(camposTexto.at(5), '50000000'); // CEP
        await tester.enterText(camposTexto.at(6), 'Rua Principal');
        await tester.enterText(camposTexto.at(7), '100');
        await tester.enterText(camposTexto.at(8), 'Centro');
        await tester.enterText(camposTexto.at(9), 'Recife');

        // Selecionar Estado no Dropdown
        final dropdown = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdown);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        final itemPE = find.text('PE').last;
        await tester.tap(itemPE);
        await tester.pumpAndSettle();

        // Submeter cadastro
        final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(botaoCadastrar);
        await tester.tap(botaoCadastrar);
        await tester.pumpAndSettle();

        // O Firebase Auth retorna erro de email já em uso exibido no SnackBar
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('Erro ao cadastrar:'), findsOneWidget);

        // Certifica-se de que a tela não avançou
        expect(find.byType(GenerosCadastroScreen), findsNothing);
      },
    );

    testWidgets(
      'Deve realizar fluxo completo: Cadastro -> Generos (alerta de seleção) -> Sucesso e persistência -> Tela Inicial',
      (WidgetTester tester) async {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final novoEmail = 'novo_usuario_$timestamp@sintonize.test';
        const nomeUsuario = 'Novo Usuario E2E';

        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 1. Ir da HomeScreen para CadastroScreen
        await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
        await tester.pumpAndSettle();
        expect(find.byType(CadastroScreen), findsOneWidget);

        final camposTexto = find.byType(TextFormField);

        // 2. Preencher formulário de cadastro com dados válidos
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

        final dropdown = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdown);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        await tester.tap(find.text('PE').last);
        await tester.pumpAndSettle();

        // 3. Submeter formulário
        final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(botaoCadastrar);
        await tester.tap(botaoCadastrar);
        await tester.pumpAndSettle();

        // 4. Valida redirecionamento para GenerosCadastroScreen
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);

        // 5. Cenário de validação: tentar confirmar sem selecionar nenhum gênero
        final botaoConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(botaoConfirmar);
        await tester.tap(botaoConfirmar);
        await tester.pumpAndSettle();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );
        expect(find.byType(TelaInicialScreen), findsNothing);

        // 6. Selecionar gêneros musicais ('Rock' e 'Jazz')
        // Encontrar os Switches correspondentes aos gêneros
        final switchRock = find.descendant(
          of: find.ancestor(
            of: find.text('Rock'),
            matching: find.byType(Row),
          ),
          matching: find.byType(Switch),
        );
        expect(switchRock, findsOneWidget);
        await tester.tap(switchRock);
        await tester.pumpAndSettle();

        final switchJazz = find.descendant(
          of: find.ancestor(
            of: find.text('Jazz'),
            matching: find.byType(Row),
          ),
          matching: find.byType(Switch),
        );
        expect(switchJazz, findsOneWidget);
        await tester.tap(switchJazz);
        await tester.pumpAndSettle();

        // 7. Confirmar seleção
        await tester.tap(botaoConfirmar);
        await tester.pumpAndSettle();

        // 8. Validar chegada à TelaInicialScreen
        expect(find.byType(TelaInicialScreen), findsOneWidget);

        // Aguarda eventuais chamadas assíncronas de carregamento da tela inicial
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        // 9. Verificar consistência dos dados gravados diretamente no Firestore
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
