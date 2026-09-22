import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// Ajuste os imports para os caminhos do seu projeto
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setupFirebaseCoreMocks();
}

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('Fluxo de Cadastro e Seleção de Gêneros Musicais', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: false);
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets(
      'deve cadastrar usuário, redirecionar para tela de gêneros e salvar gêneros com sucesso no Firestore',
      (tester) async {
        // Define um tamanho de tela adequado para evitar estouros de layout durante os testes
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        // 1. Renderiza o widget inicial passando os mocks por injeção de dependência
        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        );

        // 2. Preenche os campos do formulário de cadastro
        // Os campos estão na ordem em que aparecem na árvore de widgets:
        // 0: Nome, 1: Data Nasc, 2: Email, 3: Senha, 4: Confirmar Senha, 
        // 5: CEP, 6: Rua, 7: Número, 8: Bairro, 9: Cidade
        await tester.enterText(find.byType(TextFormField).at(0), 'Maria Silva');
        await tester.enterText(find.byType(TextFormField).at(1), '15/05/1995');
        await tester.enterText(find.byType(TextFormField).at(2), 'maria@exemplo.com');
        await tester.enterText(find.byType(TextFormField).at(3), 'senha123');
        await tester.enterText(find.byType(TextFormField).at(4), 'senha123');
        await tester.enterText(find.byType(TextFormField).at(5), '50000-000');
        await tester.enterText(find.byType(TextFormField).at(6), 'Rua das Flores');
        await tester.enterText(find.byType(TextFormField).at(7), '123');
        await tester.enterText(find.byType(TextFormField).at(8), 'Boa Viagem');
        await tester.enterText(find.byType(TextFormField).at(9), 'Recife');

        // Seleciona o estado no DropdownButtonFormField
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('PE').last);
        await tester.pumpAndSettle();

        // 3. Rola até o botão "Cadastrar" e submete o formulário
        final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(botaoCadastrar);
        await tester.tap(botaoCadastrar);
        await tester.pumpAndSettle();

        // 4. Valida se autenticou e se gravou os dados cadastrais no Firestore
        expect(mockAuth.currentUser, isNotNull);
        final String uid = mockAuth.currentUser!.uid;

        final docUsuario = await fakeFirestore.collection('usuarios').doc(uid).get();
        expect(docUsuario.exists, isTrue);
        expect(docUsuario.data()?['nome'], equals('Maria Silva'));
        expect(docUsuario.data()?['email'], equals('maria@exemplo.com'));
        expect(docUsuario.data()?['endereco']['cidade'], equals('Recife'));
        expect(docUsuario.data()?['endereco']['estado'], equals('PE'));

        // 5. Verifica se navegou para GenerosCadastroScreen
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);

        // 6. Seleciona os gêneros musicais ativando os Switches
        // Localiza e clica no Switch do 'Rock'
        final switchRock = find.descendant(
          of: find.ancestor(
            of: find.text('Rock'),
            matching: find.byType(Row),
          ),
          matching: find.byType(Switch),
        );
        await tester.tap(switchRock);
        await tester.pumpAndSettle();

        // Localiza e clica no Switch do 'Pop'
        final switchPop = find.descendant(
          of: find.ancestor(
            of: find.text('Pop'),
            matching: find.byType(Row),
          ),
          matching: find.byType(Switch),
        );
        await tester.tap(switchPop);
        await tester.pumpAndSettle();

        // 7. Clica no botão "Confirmar"
        final botaoConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(botaoConfirmar);
        await tester.tap(botaoConfirmar);
        await tester.pumpAndSettle();

        // 8. Verifica se os gêneros foram atualizados no Firestore
        final docAtualizado = await fakeFirestore.collection('usuarios').doc(uid).get();
        final List<dynamic> generosSalvos = docAtualizado.data()?['generos_favoritos'];
        expect(generosSalvos, containsAll(['Rock', 'Pop']));
        expect(generosSalvos.length, equals(2));

        // 9. Valida que navegou para TelaInicialScreen
        expect(find.byType(TelaInicialScreen), findsOneWidget);
      },
    );

    testWidgets(
      'deve exibir snackbar ao tentar confirmar sem selecionar nenhum gênero',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        // Cria o usuário autenticado previamente para simular entrada direta ou via fluxo
        final user = await mockAuth.createUserWithEmailAndPassword(
          email: 'teste@sintonize.com',
          password: 'password123',
        );
        await fakeFirestore.collection('usuarios').doc(user.user!.uid).set({
          'nome': 'Usuário Teste',
          'email': 'teste@sintonize.com',
        });

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        );

        // Tenta confirmar sem marcar nada
        final botaoConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(botaoConfirmar);
        await tester.tap(botaoConfirmar);
        await tester.pump();

        // Verifica se a mensagem de validação foi disparada
        expect(find.text('Selecione pelo menos um gênero musical!'), findsOneWidget);
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );
  });
}

