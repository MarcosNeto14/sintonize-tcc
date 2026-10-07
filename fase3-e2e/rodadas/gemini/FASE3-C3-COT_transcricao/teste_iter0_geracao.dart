// ===== integration_test/fase3/cadastro_generos_flow_test.dart =====
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
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

  /// Helper para navegar da HomeScreen até a CadastroScreen
  Future<void> navigateToCadastro(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final cadastroBtn = find.widgetWithText(ElevatedButton, 'Cadastro');
    expect(cadastroBtn, findsOneWidget);

    await tester.tap(cadastroBtn);
    await tester.pumpAndSettle();

    expect(find.byType(CadastroScreen), findsOneWidget);
  }

  group('Fluxo E2E: Cadastro de Usuário e Seleção de Gêneros', () {
    testWidgets('Cenário 1: Sucesso de ponta a ponta (Cadastro -> Gêneros -> Tela Inicial)',
        (WidgetTester tester) async {
      await navigateToCadastro(tester);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueEmail = 'novo_usuario_$timestamp@sintonize.test';

      // Localizadores dos campos de texto (pelo label textual)
      final nomeField = find.widgetWithText(TextFormField, '').first; 
      // Busca específica baseada nos ancestrais ou campos sequenciais
      final textFields = find.byType(TextFormField);

      // Preenchimento dos dados pessoais
      await tester.enterText(textFields.at(0), 'Usuario Teste'); // Nome
      await tester.enterText(textFields.at(1), '15101998');     // Data de Nascimento (com formatador)
      await tester.enterText(textFields.at(2), uniqueEmail);     // E-mail
      await tester.enterText(textFields.at(3), 'senhaSegura123'); // Senha
      await tester.enterText(textFields.at(4), 'senhaSegura123'); // Confirmar Senha

      // Scroll para campos de endereço
      await tester.ensureVisible(textFields.at(5));
      await tester.enterText(textFields.at(5), '50000000'); // CEP (com formatador vira 50000-000)
      
      await tester.ensureVisible(textFields.at(6));
      await tester.enterText(textFields.at(6), 'Rua das Flores'); // Rua

      await tester.ensureVisible(textFields.at(7));
      await tester.enterText(textFields.at(7), '123'); // Número

      await tester.ensureVisible(textFields.at(8));
      await tester.enterText(textFields.at(8), 'Boa Viagem'); // Bairro

      await tester.ensureVisible(textFields.at(9));
      await tester.enterText(textFields.at(9), 'Recife'); // Cidade

      // Seleção do Estado no Dropdown
      final estadoDropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(estadoDropdown);
      await tester.tap(estadoDropdown);
      await tester.pumpAndSettle();

      final peOption = find.widgetWithText(DropdownMenuItem<String>, 'PE').last;
      await tester.tap(peOption);
      await tester.pumpAndSettle();

      // Botão Cadastrar
      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);

      // Aguarda comunicação assíncrona com Auth, Firestore e navegação
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verifica se alcançou a tela de seleção de gêneros
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      // Seleciona gêneros (Rock e Pop)
      final switches = find.byType(Switch);
      expect(switches, findsWidgets);

      // Marca o primeiro (Rock) e o segundo (Pop)
      await tester.tap(switches.at(0));
      await tester.pumpAndSettle();
      await tester.tap(switches.at(1));
      await tester.pumpAndSettle();

      // Confirmação
      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarBtn);
      await tester.tap(confirmarBtn);

      // Aguarda persistência e navegação para TelaInicialScreen
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(TelaInicialScreen), findsOneWidget);
      expect(
        find.textContaining('essa é a nossa recomendação de música para você!'),
        findsOneWidget,
      );
    });

    testWidgets('Cenário 2: Erros de validação síncrona com campos obrigatórios vazios',
        (WidgetTester tester) async {
      await navigateToCadastro(tester);

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      // Validações disparadas pelo _formKey.currentState!.validate()
      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);

      // Garante que não transitou de tela
      expect(find.byType(CadastroScreen), findsOneWidget);
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 3: Validação de regras de formato e divergência de senha',
        (WidgetTester tester) async {
      await navigateToCadastro(tester);

      final textFields = find.byType(TextFormField);

      // Preenche dados violando as regras
      await tester.enterText(textFields.at(0), 'Marcos 123'); // Nome inválido com dígitos
      await tester.enterText(textFields.at(1), '32132026'); // Data inválida
      await tester.enterText(textFields.at(2), 'email-invalido'); // Formato de e-mail inválido
      await tester.enterText(textFields.at(3), '123'); // Senha menor que 6 caracteres
      await tester.enterText(textFields.at(4), '999'); // Senhas incompatíveis

      await tester.ensureVisible(textFields.at(5));
      await tester.enterText(textFields.at(5), '1234'); // CEP incompleto

      await tester.ensureVisible(textFields.at(7));
      await tester.enterText(textFields.at(7), 'abc'); // Número não-numérico

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      // Verificação das mensagens
      expect(find.text('O nome não pode conter números ou caracteres especiais'), findsOneWidget);
      expect(find.text('Mês deve ser entre 01 e 12'), findsOneWidget);
      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.text('CEP inválido. Formato correto: XXXXX-XXX'), findsOneWidget);
      expect(find.text('O número deve ser numérico'), findsOneWidget);

      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 4: Erro do Firebase Auth (E-mail já cadastrado)',
        (WidgetTester tester) async {
      await navigateToCadastro(tester);

      final textFields = find.byType(TextFormField);

      // Preenche com o e-mail pré-existente no emulador Auth
      await tester.enterText(textFields.at(0), 'Tester Conflito');
      await tester.enterText(textFields.at(1), '10101995');
      await tester.enterText(textFields.at(2), 'tester@sintonize.test');
      await tester.enterText(textFields.at(3), 'senha123');
      await tester.enterText(textFields.at(4), 'senha123');

      await tester.ensureVisible(textFields.at(5));
      await tester.enterText(textFields.at(5), '50000000');

      await tester.ensureVisible(textFields.at(6));
      await tester.enterText(textFields.at(6), 'Rua Principal');

      await tester.ensureVisible(textFields.at(7));
      await tester.enterText(textFields.at(7), '100');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);

      // Aguarda resposta do emulador Auth
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Deve exibir SnackBar com a mensagem de erro do Firebase Auth
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Erro ao cadastrar:'), findsOneWidget);

      // Garante que o usuário permaneceu na tela de cadastro
      expect(find.byType(CadastroScreen), findsOneWidget);
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 5: Erro de fluxo na seleção de gêneros (nenhum selecionado)',
        (WidgetTester tester) async {
      await navigateToCadastro(tester);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueEmail = 'genero_test_$timestamp@sintonize.test';
      final textFields = find.byType(TextFormField);

      // Cadastro com dados válidos
      await tester.enterText(textFields.at(0), 'Ana Santos');
      await tester.enterText(textFields.at(1), '20052000');
      await tester.enterText(textFields.at(2), uniqueEmail);
      await tester.enterText(textFields.at(3), 'senha123');
      await tester.enterText(textFields.at(4), 'senha123');

      await tester.ensureVisible(textFields.at(5));
      await tester.enterText(textFields.at(5), '50000000');

      await tester.ensureVisible(textFields.at(7));
      await tester.enterText(textFields.at(7), '42');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(GenerosCadastroScreen), findsOneWidget);

      // Sem alternar nenhum switch, tenta confirmar
      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarBtn);
      await tester.tap(confirmarBtn);
      await tester.pump(); // Renderiza o SnackBar

      // Validação do SnackBar de alerta
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Selecione pelo menos um gênero musical!'),
        findsOneWidget,
      );

      // Não deve navegar para a TelaInicialScreen
      expect(find.byType(TelaInicialScreen), findsNothing);
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
    });
  });
}

