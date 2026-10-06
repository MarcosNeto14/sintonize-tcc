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

  /// Localiza o TextFormField associado ao label textual exibido logo acima dele.
  Finder campoPorLabel(String label) {
    return find.descendant(
      of: find.ancestor(
        of: find.text(label),
        matching: find.byType(Column),
      ).first,
      matching: find.byType(TextFormField),
    );
  }

  /// Garante visibilidade e preenche o campo de texto correspondente.
  Future<void> preencherCampo(
    WidgetTester tester,
    Finder scrollable,
    String label,
    String texto,
  ) async {
    final finder = campoPorLabel(label);
    await tester.scrollUntilVisible(finder, 80, scrollable: scrollable);
    await tester.enterText(finder, texto);
    await tester.pumpAndSettle();
  }

  /// Seleciona o primeiro item disponível no DropdownButtonFormField ('AC')
  /// que já fica no topo do menu suspenso sem problemas de scroll.
  Future<void> selecionarEstado(WidgetTester tester, Finder scrollable) async {
    final dropdownEstado = find.byType(DropdownButtonFormField<String>);
    await tester.scrollUntilVisible(dropdownEstado, 80, scrollable: scrollable);
    await tester.tap(dropdownEstado);
    await tester.pumpAndSettle();

    // 'AC' é o primeiro item da lista _estados
    final itemAC = find.widgetWithText(DropdownMenuItem<String>, 'AC').last;
    await tester.tap(itemAC);
    await tester.pumpAndSettle();
  }

  /// Aguarda ativamente até que um widget apareça na tela (útil para respostas assíncronas do Firebase)
  Future<void> esperarElemento(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final DateTime fim = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(fim)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (finder.evaluate().isNotEmpty) {
        await tester.pumpAndSettle();
        return;
      }
    }
    // Último pump para deixar a asserção capturar o estado real
    await tester.pumpAndSettle();
  }

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

      final scrollableForm = find.byType(Scrollable).first;
      final String uniqueEmail =
          'novo_usuario_${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      // 2. Preenchimento de todos os campos do formulário
      await preencherCampo(tester, scrollableForm, 'Nome', 'Marcos Vinicius');
      await preencherCampo(tester, scrollableForm, 'Data de Nascimento', '19032001');
      await preencherCampo(tester, scrollableForm, 'E-mail', uniqueEmail);
      await preencherCampo(tester, scrollableForm, 'Senha', 'senha123');
      await preencherCampo(tester, scrollableForm, 'Confirmar Senha', 'senha123');
      await preencherCampo(tester, scrollableForm, 'CEP', '50010000');
      await preencherCampo(tester, scrollableForm, 'Rua', 'Rua da Aurora');
      await preencherCampo(tester, scrollableForm, 'Número', '100');
      await preencherCampo(tester, scrollableForm, 'Bairro', 'Boa Vista');
      await preencherCampo(tester, scrollableForm, 'Cidade', 'Recife');

      await selecionarEstado(tester, scrollableForm);

      // 3. Submeter cadastro
      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 80, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);

      // Aguarda o processamento de rede do Auth Emulator + Firestore
      await esperarElemento(tester, find.byType(GenerosCadastroScreen));

      // 4. Verificação da tela GenerosCadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      // Ativar o switch de 'Rock'
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
        80,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(botaoConfirmar);

      // Aguarda Firestore gravar os gêneros e redirecionar para TelaInicialScreen
      await esperarElemento(tester, find.byType(TelaInicialScreen));

      // 6. Confirmação do estado final na TelaInicialScreen
      expect(find.byType(TelaInicialScreen), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsOneWidget);
    });

    testWidgets('Cenário 2: Erros de validação local no formulário', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final scrollableForm = find.byType(Scrollable).first;

      // 1. Tentar submeter tudo em branco
      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 80, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);
      await tester.pumpAndSettle();

      // Valida as mensagens de campos obrigatórios
      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);

      // 2. Preencher com dados que violam as regras de formato
      await preencherCampo(tester, scrollableForm, 'Nome', 'User123!');
      await preencherCampo(tester, scrollableForm, 'E-mail', 'email_sem_arroba');
      await preencherCampo(tester, scrollableForm, 'Senha', '123');
      await preencherCampo(tester, scrollableForm, 'Confirmar Senha', '456');

      await tester.scrollUntilVisible(botaoCadastrar, 80, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);
      await tester.pumpAndSettle();

      // Validações de formato específico
      expect(
        find.text('O nome não pode conter números ou caracteres especiais'),
        findsOneWidget,
      );
      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.text('As senhas não coincidem'), findsOneWidget);

      // Garante que não houve navegação
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 3: Erro do Firebase Auth com e-mail já existente', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final scrollableForm = find.byType(Scrollable).first;

      // Preenche os dados usando o e-mail pré-existente nos emuladores
      await preencherCampo(tester, scrollableForm, 'Nome', 'Tester Clone');
      await preencherCampo(tester, scrollableForm, 'Data de Nascimento', '01012000');
      await preencherCampo(tester, scrollableForm, 'E-mail', 'tester@sintonize.test');
      await preencherCampo(tester, scrollableForm, 'Senha', 'senha123');
      await preencherCampo(tester, scrollableForm, 'Confirmar Senha', 'senha123');
      await preencherCampo(tester, scrollableForm, 'CEP', '50000000');
      await preencherCampo(tester, scrollableForm, 'Rua', 'Rua Teste');
      await preencherCampo(tester, scrollableForm, 'Número', '10');
      await preencherCampo(tester, scrollableForm, 'Bairro', 'Centro');
      await preencherCampo(tester, scrollableForm, 'Cidade', 'Recife');

      await selecionarEstado(tester, scrollableForm);

      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 80, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);

      // Aguarda resposta assíncrona do Firebase Auth Emulator e surgimento da SnackBar
      await esperarElemento(tester, find.byType(SnackBar));

      // Valida SnackBar de erro do Firebase Auth
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Erro ao cadastrar:'), findsOneWidget);

      // Garante permanência na tela de cadastro
      expect(find.byType(CadastroScreen), findsOneWidget);
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 4: Validação de seleção obrigatória na GenerosCadastroScreen', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final scrollableForm = find.byType(Scrollable).first;
      final String randomEmail =
          'genero_test_${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      await preencherCampo(tester, scrollableForm, 'Nome', 'Usuario Genero');
      await preencherCampo(tester, scrollableForm, 'Data de Nascimento', '10101995');
      await preencherCampo(tester, scrollableForm, 'E-mail', randomEmail);
      await preencherCampo(tester, scrollableForm, 'Senha', 'senhaValida123');
      await preencherCampo(tester, scrollableForm, 'Confirmar Senha', 'senhaValida123');
      await preencherCampo(tester, scrollableForm, 'CEP', '50010000');
      await preencherCampo(tester, scrollableForm, 'Rua', 'Avenida Norte');
      await preencherCampo(tester, scrollableForm, 'Número', '500');
      await preencherCampo(tester, scrollableForm, 'Bairro', 'Encruzilhada');
      await preencherCampo(tester, scrollableForm, 'Cidade', 'Recife');

      await selecionarEstado(tester, scrollableForm);

      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 80, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);

      // Aguarda criação do usuário e navegação para GenerosCadastroScreen
      await esperarElemento(tester, find.byType(GenerosCadastroScreen));
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);

      // Tenta confirmar sem selecionar nenhum gênero musical
      final botaoConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.scrollUntilVisible(
        botaoConfirmar,
        80,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(botaoConfirmar);
      await tester.pump(); // Renderiza o frame do SnackBar síncrono

      // Validação do SnackBar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Selecione pelo menos um gênero musical!'), findsOneWidget);

      // Confirma que não avançou para TelaInicialScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });
}

