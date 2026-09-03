import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  group('Fluxo de Cadastro e Seleção de Gêneros', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: false);
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets(
      'fluxo completo: cadastro cria usuário, salva dados e permite salvar gêneros',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));

        addTearDown(() async {
          await tester.binding.setSurfaceSize(const Size(800, 600));
        });

        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        );

        // Nome
        await tester.enterText(
          find.byType(TextFormField).at(0),
          'João Silva',
        );

        // Data de nascimento
        await tester.enterText(
          find.byType(TextFormField).at(1),
          '01/01/1990',
        );

        // E-mail
        await tester.enterText(
          find.byType(TextFormField).at(2),
          'joao@test.com',
        );

        // Senha
        await tester.enterText(
          find.byType(TextFormField).at(3),
          'senha123',
        );

        // Confirmar senha
        await tester.enterText(
          find.byType(TextFormField).at(4),
          'senha123',
        );

        // CEP.
        //
        // O CadastroScreen chama o ViaCEP quando o CEP fica completo.
        // Os demais campos são preenchidos explicitamente abaixo para que
        // o teste não dependa dos dados retornados pela API.
        await tester.enterText(
          find.byType(TextFormField).at(5),
          '50000-000',
        );

        // Rua
        await tester.enterText(
          find.byType(TextFormField).at(6),
          'Rua Teste',
        );

        // Número
        await tester.enterText(
          find.byType(TextFormField).at(7),
          '123',
        );

        // Bairro
        await tester.enterText(
          find.byType(TextFormField).at(8),
          'Centro',
        );

        // Cidade
        await tester.enterText(
          find.byType(TextFormField).at(9),
          'Recife',
        );

        // Localiza o DropdownButtonFormField sem depender do argumento
        // genérico do tipo.
        final estadoDropdown = find.byWidgetPredicate(
          (widget) => widget is DropdownButtonFormField,
        );

        expect(estadoDropdown, findsOneWidget);

        await tester.tap(estadoDropdown);
        await tester.pumpAndSettle();

        // Depois que o menu abre, "PE" aparece como uma das opções.
        expect(find.text('PE'), findsWidgets);

        // A opção do menu é a última ocorrência de "PE":
        // a primeira pode estar em algum elemento do dropdown original.
        await tester.tap(find.text('PE').last);
        await tester.pump();

        // Submete o cadastro.
        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        // O Firebase Auth mock deve ter criado/autenticado o usuário.
        expect(mockAuth.currentUser, isNotNull);

        final uid = mockAuth.currentUser!.uid;

        // Verifica que o documento inicial do usuário foi criado.
        final usuario =
            await fakeFirestore.collection('usuarios').doc(uid).get();

        expect(usuario.exists, isTrue);
        expect(usuario.data()?['nome'], 'João Silva');
        expect(usuario.data()?['email'], 'joao@test.com');
        expect(usuario.data()?['data_nasc'], '01/01/1990');

        final endereco =
            usuario.data()?['endereco'] as Map<String, dynamic>;

        expect(endereco['rua'], 'Rua Teste');
        expect(endereco['numero'], '123');
        expect(endereco['bairro'], 'Centro');
        expect(endereco['cidade'], 'Recife');
        expect(endereco['estado'], 'PE');
        expect(endereco['cep'], '50000-000');

        // Deve ter navegado para a tela de seleção de gêneros.
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);

        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsOneWidget,
        );

        // Seleciona Rock.
        final rockSwitch = find.descendant(
          of: find.ancestor(
            of: find.text('Rock'),
            matching: find.byType(Card),
          ).first,
          matching: find.byType(Switch),
        );

        expect(rockSwitch, findsOneWidget);

        await tester.tap(rockSwitch);
        await tester.pump();

        // Seleciona Pop.
        final popSwitch = find.descendant(
          of: find.ancestor(
            of: find.text('Pop'),
            matching: find.byType(Card),
          ).first,
          matching: find.byType(Switch),
        );

        expect(popSwitch, findsOneWidget);

        await tester.tap(popSwitch);
        await tester.pump();

        // Confirma.
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        // Verifica que os gêneros foram adicionados ao mesmo documento.
        final usuarioAtualizado =
            await fakeFirestore.collection('usuarios').doc(uid).get();

        expect(usuarioAtualizado.exists, isTrue);

        expect(
          usuarioAtualizado.data()?['generos_favoritos'],
          containsAll(<String>['Rock', 'Pop']),
        );

        // O fluxo completo termina na tela inicial.
        expect(find.byType(TelaInicialScreen), findsOneWidget);
      },
    );

    testWidgets(
      'falha ao salvar gêneros exibe mensagem de erro',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));

        addTearDown(() async {
          await tester.binding.setSurfaceSize(const Size(800, 600));
        });

        // Usuário autenticado, mas sem documento correspondente no Firestore.
        //
        // Isso é intencional: GenerosCadastroScreen chama update() e o
        // documento inexistente faz o FakeFirebaseFirestore lançar uma
        // exceção. Assim testamos o catch real da aplicação sem precisar
        // interceptar DocumentReference.update().
        mockAuth = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'usuario-teste',
            email: 'user@test.com',
          ),
          signedIn: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        );

        expect(find.byType(GenerosCadastroScreen), findsOneWidget);

        // Seleciona Rock para que _confirmar() chame _salvarGeneros().
        final rockSwitch = find.descendant(
          of: find.ancestor(
            of: find.text('Rock'),
            matching: find.byType(Card),
          ).first,
          matching: find.byType(Switch),
        );

        expect(rockSwitch, findsOneWidget);

        await tester.tap(rockSwitch);
        await tester.pump();

        await tester.tap(find.text('Confirmar'));

        // Dá tempo para o Future de _salvarGeneros() completar e para
        // a SnackBar ser inserida na árvore.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          find.text('Erro ao salvar os gêneros!'),
          findsOneWidget,
        );

        // Como o update falhou, não deve haver navegação.
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );

    testWidgets(
      'não permite confirmar sem selecionar nenhum gênero',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1400));

        addTearDown(() async {
          await tester.binding.setSurfaceSize(const Size(800, 600));
        });

        mockAuth = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'usuario-teste',
            email: 'user@test.com',
          ),
          signedIn: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        );

        expect(find.text('Confirmar'), findsOneWidget);

        await tester.tap(find.text('Confirmar'));
        await tester.pump();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );

        // Não deve navegar porque nenhum gênero foi selecionado.
        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );
  });
}
