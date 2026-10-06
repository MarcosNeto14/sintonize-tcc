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

  group('Fluxo E2E - Cadastro e Seleção de Gêneros', () {
    testWidgets('Cenário 1: Fluxo de sucesso ponta a ponta', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 1. Navegar da HomeScreen para a CadastroScreen
      final botaoCadastroHome = find.widgetWithText(ElevatedButton, 'Cadastro');
      expect(botaoCadastroHome, findsOneWidget);
      await tester.tap(botaoCadastroHome);
      await tester.pumpAndSettle();

      expect(find.byType(CadastroScreen), findsOneWidget);

      // Gera um email único para evitar colisões no Auth Emulator
      final String uniqueEmail = 'novo_usuario_${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      // 2. Preenchimento dos campos do formulário
      final scrollableForm = find.byType(Scrollable).first;

      // Nome
      final campoNome = find.widgetWithText(TextFormField, '').at(0);
      await tester.enterText(campoNome, 'Marcos Vinicius');
      await tester.pumpAndSettle();

      // Data de Nascimento
      final campoData = find.widgetWithText(TextFormField, '').at(1);
      await tester.enterText(campoData, '19032001'); // Passa pelo formatter virando 19/03/2001
      await tester.pumpAndSettle();

      // E-mail
      final campoEmail = find.widgetWithText(TextFormField, '').at(2);
      await tester.enterText(campoEmail, uniqueEmail);
      await tester.pumpAndSettle();

      // Senha e Confirmar Senha
      final campoSenha = find.widgetWithText(TextFormField, '').at(3);
      await tester.enterText(campoSenha, 'senha123');
      await tester.pumpAndSettle();

      final campoConfSenha = find.widgetWithText(TextFormField, '').at(4);
      await tester.enterText(campoConfSenha, 'senha123');
      await tester.pumpAndSettle();

      // CEP
      final campoCep = find.widgetWithText(TextFormField, '').at(5);
      await tester.enterText(campoCep, '50010000'); // Formata para 50010-000
      await tester.pumpAndSettle();

      // Scroll para campos inferiores
      await tester.drag(scrollableForm, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Rua
      final campoRua = find.widgetWithText(TextFormField, '').at(6);
      await tester.enterText(campoRua, 'Rua da Aurora');
      await tester.pumpAndSettle();

      // Número
      final campoNumero = find.widgetWithText(TextFormField, '').at(7);
      await tester.enterText(campoNumero, '100');
      await tester.pumpAndSettle();

      // Bairro
      final campoBairro = find.widgetWithText(TextFormField, '').at(8);
      await tester.enterText(campoBairro, 'Boa Vista');
      await tester.pumpAndSettle();

      // Cidade
      final campoCidade = find.widgetWithText(TextFormField, '').at(9);
      await tester.enterText(campoCidade, 'Recife');
      await tester.pumpAndSettle();

      // Dropdown Estado
      final dropdownEstado = find.byType(DropdownButtonFormField<String>);
      await tester.tap(dropdownEstado);
      await tester.pumpAndSettle();

      final itemPE = find.widgetWithText(DropdownMenuItem<String>, 'PE').last;
      await tester.tap(itemPE);
      await tester.pumpAndSettle();

      // 3. Submeter formulário de cadastro
      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 100, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);

      // Aguarda processamento de Firebase Auth + Firestore e transição de tela
      await tester.pumpAndSettle();

      // 4. Verificação e interação na GenerosCadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      // Ativa o gênero 'Rock'
      final switchRock = find.descendant(
        of: find.widgetWithText(Row, 'Rock'),
        matching: find.byType(Switch),
      );
      expect(switchRock, findsOneWidget);
      await tester.tap(switchRock);
      await tester.pumpAndSettle();

      // 5. Confirmar seleção de gêneros
      final botaoConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.scrollUntilVisible(
        botaoConfirmar,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(botaoConfirmar);

      // Aguarda salvamento no Firestore e navegação para a tela principal
      await tester.pumpAndSettle();

      // 6. Confirmação do estado final na TelaInicialScreen
      expect(find.byType(TelaInicialScreen), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsOneWidget);
    });

    testWidgets('Cenário 2: Erros de validação local no formulário', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Ir para CadastroScreen
      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final scrollableForm = find.byType(Scrollable).first;

      // 1. Tentar submeter formulário em branco
      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 100, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);
      await tester.pumpAndSettle();

      // Verifica mensagens de campos obrigatórios
      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);

      // 2. Preencher com dados fora da regra
      await tester.drag(scrollableForm, const Offset(0, 500));
      await tester.pumpAndSettle();

      final campoNome = find.widgetWithText(TextFormField, '').at(0);
      await tester.enterText(campoNome, 'User123!');

      final campoEmail = find.widgetWithText(TextFormField, '').at(2);
      await tester.enterText(campoEmail, 'email_invalido_sem_arroba');

      final campoSenha = find.widgetWithText(TextFormField, '').at(3);
      await tester.enterText(campoSenha, '123'); // menor que 6 caracteres

      final campoConfSenha = find.widgetWithText(TextFormField, '').at(4);
      await tester.enterText(campoConfSenha, '456'); // senhas diferentes

      await tester.scrollUntilVisible(botaoCadastrar, 100, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);
      await tester.pumpAndSettle();

      expect(find.text('O nome não pode conter números ou caracteres especiais'), findsOneWidget);
      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.text('As senhas não coincidem'), findsOneWidget);

      // Garante que permaneceu na CadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 3: Erro do Firebase Auth com e-mail já existente', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final scrollableForm = find.byType(Scrollable).first;

      // Preenche os dados usando o e-mail pré-existente nos emuladores
      await tester.enterText(find.widgetWithText(TextFormField, '').at(0), 'Tester Clone');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(1), '01012000');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(2), 'tester@sintonize.test');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(3), 'senha123');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(4), 'senha123');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(5), '50000000');

      await tester.drag(scrollableForm, const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, '').at(6), 'Rua Teste');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(7), '10');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(8), 'Centro');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(9), 'Recife');

      final dropdownEstado = find.byType(DropdownButtonFormField<String>);
      await tester.tap(dropdownEstado);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(DropdownMenuItem<String>, 'PE').last);
      await tester.pumpAndSettle();

      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 100, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);

      // Aguarda resposta do Firebase Auth Emulator
      await tester.pumpAndSettle();

      // Verifica exibição da SnackBar com erro
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Erro ao cadastrar:'), findsOneWidget);

      // Confirma que a tela não avançou
      expect(find.byType(CadastroScreen), findsOneWidget);
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 4: Validação de seleção obrigatória na GenerosCadastroScreen', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final scrollableForm = find.byType(Scrollable).first;
      final String randomEmail = 'genero_test_${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      await tester.enterText(find.widgetWithText(TextFormField, '').at(0), 'Usuario Genero');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(1), '10101995');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(2), randomEmail);
      await tester.enterText(find.widgetWithText(TextFormField, '').at(3), 'senhaValida123');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(4), 'senhaValida123');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(5), '50010000');

      await tester.drag(scrollableForm, const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, '').at(6), 'Avenida Norte');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(7), '500');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(8), 'Encruzilhada');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(9), 'Recife');

      final dropdownEstado = find.byType(DropdownButtonFormField<String>);
      await tester.tap(dropdownEstado);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(DropdownMenuItem<String>, 'PE').last);
      await tester.pumpAndSettle();

      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 100, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);
      await tester.pumpAndSettle();

      // Chega à GenerosCadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);

      // Tenta confirmar diretamente sem acionar nenhum Switch
      final botaoConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.scrollUntilVisible(
        botaoConfirmar,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(botaoConfirmar);
      await tester.pump(); // Renderiza o frame com o SnackBar

      // Valida SnackBar de advertência
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Selecione pelo menos um gênero musical!'), findsOneWidget);

      // Permanece na GenerosCadastroScreen sem avançar para a TelaInicialScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });
}

