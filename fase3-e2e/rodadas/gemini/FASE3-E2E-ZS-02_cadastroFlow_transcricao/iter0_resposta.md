<!-- Resposta do Gemini 3.8 Flash à geração (iteração 0), rodada 8, 2026-10-05,
     como devolvida pelo autor (colagem do texto da resposta), sem edição.
     Conversa: https://gemini.google.com/app/07f6ac9f1e8f70f8?hl=pt-BR -->

Aqui está o arquivo completo do teste end-to-end com integration_test para o fluxo de cadastro e seleção de gêneros musicais no aplicativo Sintonize.

O arquivo deve ser salvo como integration_test/fase3/cadastro_fluxo_test.dart.

Detalhes contemplados no teste:
Inicialização: Configuração com IntegrationTestWidgetsFlutterBinding.ensureInitialized() e chamada a setupFirebaseEmulators() no setUpAll().

Cenário de Sucesso:

Inicia em HomeScreen e navega até CadastroScreen.

Preenchimento completo do formulário (utilizando rolagem com ensureVisible para garantir interação segura em telas roláveis).

Verificação da criação da conta no Firebase Auth e documento no Firestore.

Navegação automática para GenerosCadastroScreen.

Seleção de múltiplos gêneros (ex.: Rock e Jazz).

Toque em "Confirmar" e redirecionamento para a TelaInicialScreen.

Asserção no Firestore validando se generos_favoritos foi persistido corretamente no documento do usuário recém-criado.

Cenários de Validação e Erro:

Campos em branco/inválidos: Valida mensagens de erro dos validadores do formulário.

E-mail duplicado: Tentativa de cadastro com o e-mail pré-existente (tester@sintonize.test), verificando a mensagem de erro do Firebase (FirebaseAuthException).

Gêneros vazios: Tentativa de confirmar na GenerosCadastroScreen sem selecionar nenhum gênero musical, checando o SnackBar de aviso.

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
    // Garante que não haja sessão residual antes de cada caso de teste
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

      // Navega para a tela de Cadastro a partir da HomeScreen
      final cadastroButtonHome = find.widgetWithText(ElevatedButton, 'Cadastro');
      expect(cadastroButtonHome, findsOneWidget);
      await tester.tap(cadastroButtonHome);
      await tester.pumpAndSettle();

      // Rola até o botão "Cadastrar" e tenta submeter o formulário vazio
      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      // Verifica mensagens de validação padrão
      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);

      // Preenche nome com caracteres inválidos (números) para testar regex
      final nomeField = find.descendant(
        of: find.byType(Form),
        matching: find.byType(TextFormField),
      ).first;
      await tester.enterText(nomeField, 'Maria123');

      // Tenta submeter novamente
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

      // Acessa Cadastro
      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextFormField);

      // Nome
      await tester.enterText(textFields.at(0), 'Usuario Duplicado');
      // Data de Nascimento
      await tester.enterText(textFields.at(1), '15101995'); // Formatador insere as barras
      // E-mail já semeado no Auth emulator
      await tester.enterText(textFields.at(2), 'tester@sintonize.test');
      // Senha e confirmação
      await tester.enterText(textFields.at(3), 'senha123');
      await tester.enterText(textFields.at(4), 'senha123');
      // CEP e Número
      await tester.enterText(textFields.at(5), '50000000');
      await tester.enterText(textFields.at(7), '100');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      // Deve exibir o SnackBar de erro com a mensagem do FirebaseAuthException
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
      await tester.enterText(textFields.at(1), '10101998');
      await tester.enterText(textFields.at(2), uniqueEmail);
      await tester.enterText(textFields.at(3), 'senha123');
      await tester.enterText(textFields.at(4), 'senha123');
      await tester.enterText(textFields.at(5), '50000000');
      await tester.enterText(textFields.at(7), '42');

      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      // Deve estar na tela de seleção de gêneros musicais
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      // Tenta clicar em "Confirmar" sem ligar nenhum Switch
      final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarButton);
      await tester.tap(confirmarButton);
      await tester.pumpAndSettle();

      // Valida o alerta exigindo a seleção
      expect(find.text('Selecione pelo menos um gênero musical!'), findsOneWidget);
    });

    testWidgets('Fluxo completo com sucesso: Cadastro -> GenerosCadastro -> TelaInicial e persistência no Firestore',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 1. Tela de Boas-vindas (HomeScreen)
      expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
      final botaoCadastro = find.widgetWithText(ElevatedButton, 'Cadastro');
      await tester.tap(botaoCadastro);
      await tester.pumpAndSettle();

      // 2. Preenchimento do formulário na CadastroScreen
      final textFields = find.byType(TextFormField);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueEmail = 'novo_usuario_$timestamp@sintonize.test';
      const nomeUsuario = 'Novo Membro Sintonize';

      // 0: Nome, 1: Data Nasc, 2: Email, 3: Senha, 4: Conf Senha, 5: CEP, 6: Rua, 7: Número, 8: Bairro, 9: Cidade
      await tester.enterText(textFields.at(0), nomeUsuario);
      await tester.enterText(textFields.at(1), '20052000');
      await tester.enterText(textFields.at(2), uniqueEmail);
      await tester.enterText(textFields.at(3), 'segredo123');
      await tester.enterText(textFields.at(4), 'segredo123');
      await tester.enterText(textFields.at(5), '50000000');
      await tester.enterText(textFields.at(6), 'Rua das Flores');
      await tester.enterText(textFields.at(7), '777');
      await tester.enterText(textFields.at(8), 'Boa Viagem');
      await tester.enterText(textFields.at(9), 'Recife');

      // Seleção do Estado no Dropdown
      final dropdownEstado = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdownEstado);
      await tester.tap(dropdownEstado);
      await tester.pumpAndSettle();

      final estadoPE = find.widgetWithText(DropdownMenuItem<String>, 'PE').last;
      await tester.tap(estadoPE);
      await tester.pumpAndSettle();

      // Submeter formulário
      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pumpAndSettle();

      // 3. Verificação intermediária: Checa se o usuário foi autenticado e criado no Firestore
      final currentUser = FirebaseAuth.instance.currentUser;
      expect(currentUser, isNotNull);
      expect(currentUser!.email, uniqueEmail);

      final userDocRef = FirebaseFirestore.instance.collection('usuarios').doc(currentUser.uid);
      final docAntesGeneros = await userDocRef.get();
      expect(docAntesGeneros.exists, isTrue);
      expect(docAntesGeneros.data()?['nome'], nomeUsuario);
      expect(docAntesGeneros.data()?['endereco']['cidade'], 'Recife');

      // 4. Tela de Seleção de Gêneros (GenerosCadastroScreen)
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      // Liga os switches para "Rock" e "Jazz"
      final switchRock = find.descendant(
        of: find.ancestor(of: find.text('Rock'), matching: find.byType(Row)),
        matching: find.byType(Switch),
      );
      await tester.tap(switchRock);
      await tester.pumpAndSettle();

      final switchJazz = find.descendant(
        of: find.ancestor(of: find.text('Jazz'), matching: find.byType(Row)),
        matching: find.byType(Switch),
      );
      await tester.tap(switchJazz);
      await tester.pumpAndSettle();

      // Clica em Confirmar
      final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarButton);
      await tester.tap(confirmarButton);
      await tester.pumpAndSettle();

      // 5. Verificação da Tela Inicial (TelaInicialScreen)
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsOneWidget);
      expect(find.text('Minha Conta'), findsOneWidget);
      expect(find.textContaining('essa é a nossa recomendação de música para você!'), findsOneWidget);

      // 6. Verificação final no Firestore: confirma persistência dos gêneros favoritos
      final docAposGeneros = await userDocRef.get();
      final List<dynamic> generosSalvos = docAposGeneros.data()?['generos_favoritos'] ?? [];
      expect(generosSalvos, containsAll(['Rock', 'Jazz']));
      expect(generosSalvos.length, 2);
    });
  });
}
Como executar o teste:
Inicie seus emuladores do Firebase e rode no emulador Android conectado:

Bash
flutter test integration_test/fase3/cadastro_fluxo_test.dart -d emulator-5554
