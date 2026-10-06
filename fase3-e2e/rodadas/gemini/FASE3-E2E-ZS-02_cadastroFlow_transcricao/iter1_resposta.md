<!-- Resposta do Gemini 3.8 Flash ao reparo 1, rodada 8, 2026-10-05,
     como devolvida pelo autor (colagem do texto da resposta), sem edição.
     Mesma conversa: https://gemini.google.com/app/07f6ac9f1e8f70f8 -->

Classificação da Causa Provável
(A) O teste presume um comportamento que não é o especificado.

Análise dos Problemas
Falha 1 (Teste do e-mail duplicado) e Falha 2 (Validação de gêneros):

Ao analisar os campos em CadastroScreen:

Índice 0: Nome (_nomeController)

Índice 1: Data de Nascimento (_dataNascController)

Índice 2: E-mail (_emailController)

Índice 3: Senha (_senhaController)

Índice 4: Confirmar Senha (_confSenhaController)

Índice 5: CEP (_cepController)

Índice 6: Rua (_ruaController)

Índice 7: Número (_numeroController)

O teste enviou CEP no índice 5 (50000000), mas o formatador _CEPInputFormatter exige e formata para máscara de 9 caracteres (XXXXX-XXX). No entanto, o teste preencheu o campo sem acionar o formatador completo ou sem preencher o hífen exigido pelo validador:

Dart
if (value.length != 9 || !RegExp(r'^\d{5}-\d{3}$').hasMatch(value)) {
  return 'CEP inválido. Formato correto: XXXXX-XXX';
}
O enterText do flutter_test atribui o texto diretamente ao controller sem disparar todas as etapas intermediárias de digitação do TextInputFormatter. Como foi passado '50000000' (8 caracteres, sem hífen), _validateCEP retornou 'CEP inválido. Formato correto: XXXXX-XXX', impedindo a submissão do formulário (_formKey.currentState!.validate() falhou).

Como o formulário não passou na validação síncrona local:

No teste de e-mail duplicado, _submit nunca chamou o Firebase Auth (logo, nenhum SnackBar de erro de autenticação foi gerado).

No teste de validação de gêneros, a tela não navegou para GenerosCadastroScreen (o texto 'SELECIONE OS GÊNEROS...' nunca apareceu).

Aviso no teste de sucesso (Dropdown de Estado):

O item 'PE' no menu suspenso do Dropdown fica fora da viewport inicial da lista flutuante (que contém 27 UFs). O tap() tentou acertar um offset fora da área visível ou sobreposta, gerando o aviso de hit test. O uso do Dropdown nem sequer é obrigatório para a validação do formulário (o estado não possui validator no código), mas caso seja selecionado, o clique deve ser feito com rolagem ou simplesmente ignorando a seleção obrigatória, já que o validador do form não o bloqueia.

Teste Corrigido
Ajustando o valor de CEP para '50000-000' para satisfazer o validador da aplicação e ajustando o preenchimento dos campos:

Dart
// ===== integration_test/fase3/cadastro_fluxo_test.dart =====
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintonize/main.dart';
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

  group('E2E - Fluxo de Cadastro e Seleção de Gêneros Musicais', () {
    testWidgets('Validações de campos obrigatórios e formato inválido na tela de cadastro',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final cadastroButtonHome = find.widgetWithText(ElevatedButton, 'Cadastro');
      expect(cadastroButtonHome, findsOneWidget);
      await tester.tap(cadastroButtonHome);
      await tester.pumpAndSettle();

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);

      final nomeField = find.descendant(
        of: find.byType(Form),
        matching: find.byType(TextFormField),
      ).first;
      await tester.enterText(nomeField, 'Maria123');

      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      expect(
        find.text('O nome não pode conter números ou caracteres especiais'),
        findsOneWidget,
      );
    });

    testWidgets('Erro ao tentar cadastrar e-mail já existente no Firebase Auth',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);

      // 0: Nome
      await tester.enterText(textFields.at(0), 'Usuario Duplicado');
      // 1: Data de Nascimento (formato dd/mm/aaaa)
      await tester.enterText(textFields.at(1), '15/10/1995');
      // 2: E-mail existente
      await tester.enterText(textFields.at(2), 'tester@sintonize.test');
      // 3 e 4: Senha e confirmação
      await tester.enterText(textFields.at(3), 'senha123');
      await tester.enterText(textFields.at(4), 'senha123');
      // 5: CEP com máscara válida (XXXXX-XXX)
      await tester.enterText(textFields.at(5), '50000-000');
      // 6: Rua
      await tester.enterText(textFields.at(6), 'Rua Principal');
      // 7: Número
      await tester.enterText(textFields.at(7), '100');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      // Aguarda e valida a exibição do SnackBar com o erro do Firebase Auth
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Erro ao cadastrar:'), findsOneWidget);
    });

    testWidgets('Validação de seleção obrigatória de gêneros na GenerosCadastroScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);
      final uniqueEmail = 'semgenero_${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      await tester.enterText(textFields.at(0), 'Usuario Sem Genero');
      await tester.enterText(textFields.at(1), '10/10/1998');
      await tester.enterText(textFields.at(2), uniqueEmail);
      await tester.enterText(textFields.at(3), 'senha123');
      await tester.enterText(textFields.at(4), 'senha123');
      await tester.enterText(textFields.at(5), '50000-000');
      await tester.enterText(textFields.at(6), 'Rua dos Testes');
      await tester.enterText(textFields.at(7), '42');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      // Checa a chegada à GenerosCadastroScreen
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      // Clica em "Confirmar" sem selecionar nenhum switch
      final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarButton);
      await tester.tap(confirmarButton);
      await tester.pumpAndSettle();

      // Valida o alerta de obrigatoriedade de seleção
      expect(find.text('Selecione pelo menos um gênero musical!'), findsOneWidget);
    });

    testWidgets('Fluxo completo com sucesso: Cadastro -> GenerosCadastro -> TelaInicial e persistência no Firestore',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 1. HomeScreen
      expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      // 2. Preenchimento de CadastroScreen
      final textFields = find.byType(TextFormField);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueEmail = 'novo_usuario_$timestamp@sintonize.test';
      const nomeUsuario = 'Novo Membro Sintonize';

      await tester.enterText(textFields.at(0), nomeUsuario);
      await tester.enterText(textFields.at(1), '20/05/2000');
      await tester.enterText(textFields.at(2), uniqueEmail);
      await tester.enterText(textFields.at(3), 'segredo123');
      await tester.enterText(textFields.at(4), 'segredo123');
      await tester.enterText(textFields.at(5), '50000-000');
      await tester.enterText(textFields.at(6), 'Rua das Flores');
      await tester.enterText(textFields.at(7), '777');
      await tester.enterText(textFields.at(8), 'Boa Viagem');
      await tester.enterText(textFields.at(9), 'Recife');

      // Submeter cadastro
      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      // 3. Verificação no Auth e Firestore
      final currentUser = FirebaseAuth.instance.currentUser;
      expect(currentUser, isNotNull);
      expect(currentUser!.email, uniqueEmail);

      final userDocRef = FirebaseFirestore.instance.collection('usuarios').doc(currentUser.uid);
      final docAntesGeneros = await userDocRef.get();
      expect(docAntesGeneros.exists, isTrue);
      expect(docAntesGeneros.data()?['nome'], nomeUsuario);
      expect(docAntesGeneros.data()?['endereco']['cidade'], 'Recife');

      // 4. GenerosCadastroScreen
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      // Alterna os Switches de Rock e Pop
      final switchRock = find.descendant(
        of: find.ancestor(of: find.text('Rock'), matching: find.byType(Row)),
        matching: find.byType(Switch),
      );
      await tester.tap(switchRock);
      await tester.pumpAndSettle();

      final switchPop = find.descendant(
        of: find.ancestor(of: find.text('Pop'), matching: find.byType(Row)),
        matching: find.byType(Switch),
      );
      await tester.tap(switchPop);
      await tester.pumpAndSettle();

      final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarButton);
      await tester.tap(confirmarButton);
      await tester.pumpAndSettle();

      // 5. TelaInicialScreen
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsOneWidget);
      expect(find.text('Minha Conta'), findsOneWidget);
      expect(find.textContaining('essa é a nossa recomendação de música para você!'), findsOneWidget);

      // 6. Confirmação dos gêneros salvos no Firestore
      final docAposGeneros = await userDocRef.get();
      final List<dynamic> generosSalvos = docAposGeneros.data()?['generos_favoritos'] ?? [];
      expect(generosSalvos, containsAll(['Rock', 'Pop']));
      expect(generosSalvos.length, 2);
    });
  });
}
