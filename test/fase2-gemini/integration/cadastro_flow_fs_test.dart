import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// Importações relativas dos arquivos da aplicação em lib/
import '../../../lib/cadastro.dart';
import '../../../lib/generos-cadastro.dart';
import '../../../lib/tela-inicial.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de Cadastro e Seleção de Gêneros - App Sintonize', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: false);
      fakeFirestore = FakeFirebaseFirestore();
    });

    Widget buildTestableWidget() {
      return MaterialApp(
        home: CadastroScreen(
          auth: mockAuth,
          firestore: fakeFirestore,
        ),
      );
    }

    testWidgets(
      'deve completar com sucesso o cadastro, salvar dados no Firestore, '
      'navegar para seleção de gêneros e atualizar preferências no Firestore',
      (WidgetTester tester) async {
        // Define resolução física para garantir que os formulários caibam na viewport de teste
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(buildTestableWidget());

        // Localizadores por campo de texto
        final nomeField = find.widgetWithText(TextFormField, 'Nome');
        final dataNascField = find.widgetWithText(TextFormField, 'Data de Nascimento');
        final emailField = find.widgetWithText(TextFormField, 'E-mail');
        final senhaField = find.widgetWithText(TextFormField, 'Senha');
        final confSenhaField = find.widgetWithText(TextFormField, 'Confirmar Senha');
        final cepField = find.widgetWithText(TextFormField, 'CEP');
        final numeroField = find.widgetWithText(TextFormField, 'Número');
        final ruaField = find.widgetWithText(TextFormField, 'Rua');
        final bairroField = find.widgetWithText(TextFormField, 'Bairro');
        final cidadeField = find.widgetWithText(TextFormField, 'Cidade');
        final estadoDropdown = find.byType(DropdownButtonFormField<String>);

        // 1. Preenchimento do formulário de cadastro
        await tester.enterText(nomeField, 'Marcos Neto');
        await tester.enterText(dataNascField, '15101998');
        await tester.enterText(emailField, 'marcos.neto@teste.com');
        await tester.enterText(senhaField, 'senhaSegura123');
        await tester.enterText(confSenhaField, 'senhaSegura123');
        await tester.enterText(cepField, '50000000');
        await tester.enterText(numeroField, '100');

        // Preenche campos de endereço diretamente para dispensar a chamada externa de API
        await tester.enterText(ruaField, 'Rua Principal');
        await tester.enterText(bairroField, 'Boa Viagem');
        await tester.enterText(cidadeField, 'Recife');

        // Seleção do Estado no Dropdown
        await tester.ensureVisible(estadoDropdown);
        await tester.tap(estadoDropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('PE').last);
        await tester.pumpAndSettle();

        // 2. Submissão do Cadastro
        final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(cadastrarButton);
        await tester.tap(cadastrarButton);
        await tester.pumpAndSettle();

        // Valida que a transição para GenerosCadastroScreen ocorreu
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);

        // Valida o registro no Firebase Auth
        final currentUser = mockAuth.currentUser;
        expect(currentUser, isNotNull);
        expect(currentUser!.email, equals('marcos.neto@teste.com'));

        // Valida se o documento do usuário foi criado com os dados iniciais
        final userDoc = await fakeFirestore
            .collection('usuarios')
            .doc(currentUser.uid)
            .get();

        expect(userDoc.exists, isTrue);
        expect(userDoc.get('nome'), equals('Marcos Neto'));
        expect(userDoc.get('email'), equals('marcos.neto@teste.com'));
        expect(userDoc.get('endereco.estado'), equals('PE'));
        expect(userDoc.get('endereco.numero'), equals('100'));

        // 3. Seleção de Gêneros Musicais
        final rockSwitch = find.descendant(
          of: find.ancestor(
            of: find.text('Rock'),
            matching: find.byType(Card),
          ),
          matching: find.byType(Switch),
        );

        final jazzSwitch = find.descendant(
          of: find.ancestor(
            of: find.text('Jazz'),
            matching: find.byType(Card),
          ),
          matching: find.byType(Switch),
        );

        await tester.ensureVisible(rockSwitch);
        await tester.tap(rockSwitch);
        await tester.pumpAndSettle();

        await tester.ensureVisible(jazzSwitch);
        await tester.tap(jazzSwitch);
        await tester.pumpAndSettle();

        // 4. Confirmação e Salvamento dos Gêneros
        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);
        await tester.pumpAndSettle();

        // Validação da navegação final
        expect(find.byType(TelaInicialScreen), findsOneWidget);

        // Validação da atualização dos dados no Firestore
        final userDocAtualizado = await fakeFirestore
            .collection('usuarios')
            .doc(currentUser.uid)
            .get();

        final generosFavoritos = List<String>.from(
          userDocAtualizado.get('generos_favoritos'),
        );

        expect(generosFavoritos, containsAll(['Rock', 'Jazz']));
        expect(generosFavoritos, isNot(contains('Pop')));
      },
    );

    testWidgets(
      'não deve prosseguir em GenerosCadastroScreen se nenhum gênero for selecionado',
      (WidgetTester tester) async {
        // Pré-autentica o usuário para simular chegada direta na tela
        await mockAuth.createUserWithEmailAndPassword(
          email: 'teste@exemplo.com',
          password: 'senha123456',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        );

        final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(confirmarButton);
        await tester.tap(confirmarButton);
        await tester.pump();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );
  });
}

