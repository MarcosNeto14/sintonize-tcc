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

  /// Preenche os campos da CadastroScreen pela ordem em que os
  /// TextFormField aparecem na árvore de widgets.
  ///
  /// Ordem:
  /// 0 Nome
  /// 1 Data de nascimento
  /// 2 E-mail
  /// 3 Senha
  /// 4 Confirmar senha
  /// 5 CEP
  /// 6 Rua
  /// 7 Número
  /// 8 Bairro
  /// 9 Cidade
  Future<void> preencherCadastro(
    WidgetTester tester, {
    required String nome,
    required String dataNascimento,
    required String email,
    required String senha,
    required String cep,
    required String rua,
    required String numero,
    required String bairro,
    required String cidade,
  }) async {
    final campos = find.byType(TextFormField);

    expect(campos, findsNWidgets(10));

    await tester.enterText(campos.at(0), nome);
    await tester.enterText(campos.at(1), dataNascimento);
    await tester.enterText(campos.at(2), email);
    await tester.enterText(campos.at(3), senha);
    await tester.enterText(campos.at(4), senha);
    await tester.enterText(campos.at(5), cep);
    await tester.enterText(campos.at(6), rua);
    await tester.enterText(campos.at(7), numero);
    await tester.enterText(campos.at(8), bairro);
    await tester.enterText(campos.at(9), cidade);

    // Fecha o teclado e dá tempo para a árvore estabilizar.
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  Future<void> selecionarEstado(
    WidgetTester tester,
    String estado,
  ) async {
    final dropdown = find.byType(DropdownButtonFormField<String>);

    expect(dropdown, findsOneWidget);

    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    await tester.tap(find.text(estado).last);
    await tester.pumpAndSettle();
  }

  Future<void> abrirCadastro(WidgetTester tester) async {
    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
    expect(find.text('Cadastro'), findsOneWidget);

    await tester.tap(find.text('Cadastro'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(10));
    expect(find.text('Cadastrar'), findsOneWidget);
  }

  Future<void> limparAutenticacao() async {
    await FirebaseAuth.instance.signOut();
  }

  group('Fase 3 - Cadastro e seleção de gêneros', () {
    testWidgets(
      'cadastro completo cria usuário, salva dados, seleciona gêneros e chega à TelaInicialScreen',
      (tester) async {
        await limparAutenticacao();

        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirCadastro(tester);

        final email =
            'e2e-${DateTime.now().microsecondsSinceEpoch}@sintonize.test';
        const senha = 'senha123';

        await preencherCadastro(
          tester,
          nome: 'usuario e2e',
          dataNascimento: '15/05/2000',
          email: email,
          senha: senha,
          cep: '01001-000',
          rua: 'Rua Teste',
          numero: '123',
          bairro: 'Centro',
          cidade: 'Sao Paulo',
        );

        await selecionarEstado(tester, 'SP');

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // O cadastro deve levar à tela de seleção de gêneros.
        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );
        expect(find.text('Confirmar'), findsOneWidget);

        final switches = find.byType(Switch);
        expect(switches, findsNWidgets(7));

        // Rock e Pop.
        await tester.tap(switches.at(0));
        await tester.pumpAndSettle();

        await tester.tap(switches.at(1));
        await tester.pumpAndSettle();

        // Confirma a seleção.
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Estado final da jornada.
        expect(
          find.textContaining(
            'Usuario e2e, essa é a nossa recomendação de música para você!',
          ),
          findsOneWidget,
        );

        // O usuário autenticado deve ser o usuário criado pela interface.
        final user = FirebaseAuth.instance.currentUser;

        expect(user, isNotNull);
        expect(user!.email, email);

        // Verifica o documento criado pelo fluxo de cadastro.
        final userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        expect(userDoc.exists, isTrue);

        final data = userDoc.data()!;

        expect(data['nome'], 'usuario e2e');
        expect(data['data_nasc'], '15/05/2000');
        expect(data['email'], email);

        expect(data['endereco'], isA<Map<String, dynamic>>());

        final endereco = data['endereco'] as Map<String, dynamic>;

        expect(endereco['rua'], 'Rua Teste');
        expect(endereco['numero'], '123');
        expect(endereco['bairro'], 'Centro');
        expect(endereco['cidade'], 'Sao Paulo');
        expect(endereco['estado'], 'SP');
        expect(endereco['cep'], '01001-000');

        // Verifica o update realizado pela GenerosCadastroScreen.
        expect(
          data['generos_favoritos'],
          containsAll(<String>['Rock', 'Pop']),
        );
        expect(
          (data['generos_favoritos'] as List).length,
          2,
        );
      },
    );

    testWidgets(
      'CadastroScreen mostra erros de validação quando campos obrigatórios são inválidos',
      (tester) async {
        await limparAutenticacao();

        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirCadastro(tester);

        // Tenta cadastrar sem preencher nada.
        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        expect(
          find.text('O nome é obrigatório'),
          findsOneWidget,
        );

        expect(
          find.text('A data de nascimento é obrigatória'),
          findsOneWidget,
        );

        expect(
          find.text('O e-mail é obrigatório'),
          findsOneWidget,
        );

        expect(
          find.text('A senha é obrigatória'),
          findsOneWidget,
        );

        expect(
          find.text('O CEP é obrigatório'),
          findsOneWidget,
        );

        expect(
          find.text('O número é obrigatório'),
          findsOneWidget,
        );

        // Testa especificamente e-mail, data, senha e CEP inválidos.
        final campos = find.byType(TextFormField);

        await tester.enterText(campos.at(0), 'usuario valido');
        await tester.enterText(campos.at(1), '31/02/2000');
        await tester.enterText(campos.at(2), 'email-invalido');
        await tester.enterText(campos.at(3), '123');
        await tester.enterText(campos.at(4), '456');
        await tester.enterText(campos.at(5), '123');

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        expect(
          find.text('E-mail inválido'),
          findsOneWidget,
        );

        expect(
          find.text('Dia deve ser entre 01 e 29'),
          findsOneWidget,
        );

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );

        expect(
          find.text('As senhas não coincidem'),
          findsOneWidget,
        );

        expect(
          find.text('CEP inválido. Formato correto: XXXXX-XXX'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'CadastroScreen mostra erro quando o e-mail já está cadastrado',
      (tester) async {
        await limparAutenticacao();

        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirCadastro(tester);

        await preencherCadastro(
          tester,
          nome: 'outro usuario',
          dataNascimento: '10/10/1999',
          email: 'tester@sintonize.test',
          senha: 'senha123',
          cep: '01001-000',
          rua: 'Rua Teste',
          numero: '100',
          bairro: 'Centro',
          cidade: 'Sao Paulo',
        );

        await selecionarEstado(tester, 'SP');

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // O Firebase Auth deve rejeitar o e-mail previamente populado
        // no emulador.
        expect(
          find.textContaining('Erro ao cadastrar:'),
          findsOneWidget,
        );

        // Continua na CadastroScreen.
        expect(find.text('Cadastrar'), findsOneWidget);

        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'GenerosCadastroScreen impede confirmação sem selecionar gênero',
      (tester) async {
        await limparAutenticacao();

        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirCadastro(tester);

        final email =
            'e2e-genero-${DateTime.now().microsecondsSinceEpoch}@sintonize.test';

        await preencherCadastro(
          tester,
          nome: 'teste genero',
          dataNascimento: '20/08/2001',
          email: email,
          senha: 'senha123',
          cep: '01001-000',
          rua: 'Rua Genero',
          numero: '200',
          bairro: 'Centro',
          cidade: 'Sao Paulo',
        );

        await selecionarEstado(tester, 'SP');

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        final switches = find.byType(Switch);
        expect(switches, findsNWidgets(7));

        // Nenhum switch é acionado.
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );

        // Continua na GenerosCadastroScreen.
        expect(find.text('Confirmar'), findsOneWidget);

        expect(
          find.textContaining(
            'essa é a nossa recomendação de música para você!',
          ),
          findsNothing,
        );

        // Nenhum gênero deve ter sido salvo.
        final user = FirebaseAuth.instance.currentUser;
        expect(user, isNotNull);

        final userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .get();

        expect(userDoc.exists, isTrue);
        expect(userDoc.data()!.containsKey('generos_favoritos'), isFalse);
      },
    );
  });
}
