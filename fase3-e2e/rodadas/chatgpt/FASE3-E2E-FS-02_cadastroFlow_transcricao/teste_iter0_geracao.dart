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

  Future<void> esperar(
    WidgetTester tester,
    Finder finder, {
    int tentativas = 40,
  }) async {
    for (var i = 0; i < tentativas; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu após esperar: $finder');
  }

  Future<void> preencherCampo(
    WidgetTester tester,
    String label,
    String valor,
  ) async {
    final campo = find.widgetWithText(TextFormField, label);

    // Os TextFormField não exibem o label como texto interno. Primeiro
    // tentamos localizar pelo texto do label e, se necessário, usamos a
    // posição dos campos na tela.
    if (campo.evaluate().isNotEmpty) {
      await tester.enterText(campo, valor);
      return;
    }

    fail('Campo "$label" não encontrado.');
  }

  testWidgets(
    'cadastro completo: cria usuário, salva gêneros favoritos e abre tela inicial',
    (tester) async {
      // Gera dados únicos para que o teste possa ser executado novamente
      // sem colidir com usuários criados em execuções anteriores.
      final identificador = DateTime.now().millisecondsSinceEpoch;
      final email = 'e2e-$identificador@sintonize.test';
      const senha = 'senha123';

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tela inicial.
      expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Cadastro'), findsOneWidget);

      await tester.tap(find.text('Cadastro'));
      await tester.pumpAndSettle();

      // CadastroScreen.
      expect(find.text('Cadastrar'), findsOneWidget);

      // A tela contém 9 TextFormFields, nesta ordem:
      // 0 Nome
      // 1 Data de Nascimento
      // 2 E-mail
      // 3 Senha
      // 4 Confirmar Senha
      // 5 CEP
      // 6 Rua
      // 7 Número
      // 8 Bairro
      // 9 Cidade
      //
      // Como os TextFormFields são criados sem semanticsLabel, usamos
      // a ordem em que aparecem na tela.
      final campos = find.byType(TextFormField);

      expect(campos, findsNWidgets(10));

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
        email,
      );

      await tester.enterText(
        campos.at(3),
        senha,
      );

      await tester.enterText(
        campos.at(4),
        senha,
      );

      await tester.enterText(
        campos.at(5),
        '01001000',
      );

      // O CEP dispara uma chamada HTTP para o ViaCEP. O teste E2E
      // não deve depender dela para preencher os dados obrigatórios,
      // portanto garantimos os demais campos manualmente.
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

      // Seleciona o estado.
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SP').last);
      await tester.pumpAndSettle();

      // O botão pode estar abaixo da área atualmente visível do
      // SingleChildScrollView.
      final cadastrar = find.text('Cadastrar');

      await tester.ensureVisible(cadastrar);
      await tester.tap(cadastrar);

      // O submit cria primeiro o usuário no Firebase Auth e depois
      // cria usuarios/{uid} no Firestore.
      await esperar(
        tester,
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
      );

      // Confirma que o fluxo realmente chegou à tela de gêneros.
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );
      expect(find.text('Rock'), findsOneWidget);
      expect(find.text('Pop'), findsOneWidget);
      expect(find.text('Jazz'), findsOneWidget);
      expect(find.text('Confirmar'), findsOneWidget);

      // Cada gênero possui um Switch. Selecionamos Rock e Pop.
      final switches = find.byType(Switch);

      expect(switches, findsNWidgets(7));

      await tester.tap(switches.at(0)); // Rock
      await tester.pump();

      await tester.tap(switches.at(1)); // Pop
      await tester.pump();

      // Confirmar salva generos_favoritos no documento do usuário.
      await tester.tap(find.text('Confirmar'));

      await esperar(
        tester,
        find.text('essa é a nossa recomendação de música para você!'),
      );

      // O fluxo terminou na TelaInicialScreen.
      expect(
        find.text('essa é a nossa recomendação de música para você!'),
        findsOneWidget,
      );

      // Validação E2E adicional diretamente no Firestore emulator.
      //
      // Não estamos mockando a tela: apenas verificamos o efeito persistido
      // pelo fluxo real executado acima.
      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);
      expect(user!.email, email);

      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(snapshot.exists, isTrue);

      final data = snapshot.data()!;

      expect(data['nome'], 'Usuário E2E');
      expect(data['email'], email);
      expect(data['generos_favoritos'], containsAll(['Rock', 'Pop']));
      expect(
        (data['generos_favoritos'] as List).length,
        2,
      );
    },
  );
}
