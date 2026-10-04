import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu: $finder');
  }

  Future<void> preencherCadastro(WidgetTester tester) async {
    final campos = find.byType(TextFormField);

    // Os TextFormField aparecem na seguinte ordem:
    // 0 - Nome
    // 1 - Data de Nascimento
    // 2 - E-mail
    // 3 - Senha
    // 4 - Confirmar Senha
    // 5 - CEP
    // 6 - Rua
    // 7 - Número
    // 8 - Bairro
    // 9 - Cidade

    await tester.enterText(
      campos.at(0),
      'Usuário E2E',
    );

    await tester.enterText(
      campos.at(1),
      '01/01/2000',
    );

    await tester.enterText(
      campos.at(2),
      'e2e-${DateTime.now().millisecondsSinceEpoch}@sintonize.test',
    );

    await tester.enterText(
      campos.at(3),
      'senha123',
    );

    await tester.enterText(
      campos.at(4),
      'senha123',
    );

    // O CEP é válido no formato esperado pelo formulário.
    // O preenchimento pode disparar uma consulta ao ViaCEP, portanto
    // aguardamos a aplicação antes de preencher os campos restantes.
    await tester.enterText(
      campos.at(5),
      '01001-000',
    );

    await tester.pump(const Duration(seconds: 2));

    // Preenche manualmente os campos de endereço para que o teste
    // não dependa do serviço externo do ViaCEP.
    await tester.enterText(
      campos.at(6),
      'Praça da Sé',
    );

    await tester.enterText(
      campos.at(7),
      '100',
    );

    await tester.enterText(
      campos.at(8),
      'Sé',
    );

    await tester.enterText(
      campos.at(9),
      'São Paulo',
    );

    // Seleciona um estado.
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SP').last);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'cadastro: cria usuário, salva documento, seleciona gêneros e persiste no Firestore',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Confirma que estamos na tela inicial.
      expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
      expect(find.text('Cadastro'), findsOneWidget);

      // Abre o fluxo de cadastro.
      await tester.tap(find.text('Cadastro'));
      await tester.pumpAndSettle();

      // Confirma que a CadastroScreen foi aberta.
      expect(find.text('Cadastrar'), findsOneWidget);

      // Preenche todos os campos necessários.
      await preencherCadastro(tester);

      // Guarda o e-mail utilizado para localizar o usuário criado no Auth.
      final email =
          'e2e-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      // O helper acima usa um timestamp próprio para o e-mail, portanto
      // precisamos preencher novamente o campo de e-mail com o valor que
      // vamos consultar posteriormente.
      final campos = find.byType(TextFormField);

      await tester.enterText(
        campos.at(2),
        email,
      );

      // Cria a conta.
      await tester.tap(find.text('Cadastrar'));

      // O cadastro cria o usuário no Firebase Auth, cria o documento
      // usuarios/{uid} e então navega para a tela de gêneros.
      await esperar(
        tester,
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
      );

      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );
      expect(find.text('Confirmar'), findsOneWidget);

      // Localiza os switches pelos cards/textos dos gêneros.
      final rock = find.ancestor(
        of: find.text('Rock'),
        matching: find.byType(Card),
      );

      final pop = find.ancestor(
        of: find.text('Pop'),
        matching: find.byType(Card),
      );

      // Cada card possui um único Switch.
      await tester.tap(find.descendant(
        of: rock,
        matching: find.byType(Switch),
      ));

      await tester.tap(find.descendant(
        of: pop,
        matching: find.byType(Switch),
      ));

      await tester.pumpAndSettle();

      // Confirma os gêneros.
      await tester.tap(find.text('Confirmar'));

      // O fluxo deve chegar à tela inicial.
      await esperar(
        tester,
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
      );

      expect(
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // Verificação E2E adicional:
      // consulta o Auth real e o Firestore Emulator para garantir que
      // o resultado persistido corresponde ao que foi selecionado pela UI.
      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);
      expect(user!.email, email);

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(doc.exists, isTrue);

      final data = doc.data()!;

      expect(data['nome'], 'Usuário E2E');
      expect(data['email'], email);

      expect(
        data['generos_favoritos'],
        containsAll(<String>[
          'Rock',
          'Pop',
        ]),
      );

      expect(
        (data['generos_favoritos'] as List).length,
        2,
      );
    },
  );
}
