import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  group('Fluxo de cadastro e seleção de gêneros', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth(
        signedIn: false,
      );

      fakeFirestore = FakeFirebaseFirestore();
    });

    Widget montarApp() {
      return MaterialApp(
        home: CadastroScreen(
          auth: mockAuth,
          firestore: fakeFirestore,
        ),
      );
    }

    Future<void> rolarCadastroParaBaixo(
      WidgetTester tester, {
      double distancia = 400,
    }) async {
      final scrollView = find.byType(SingleChildScrollView);

      expect(scrollView, findsOneWidget);

      await tester.drag(
        scrollView,
        Offset(0, -distancia),
      );

      await tester.pumpAndSettle();
    }

    testWidgets(
      'fluxo completo: cadastra usuário, cria documento, seleciona gêneros e salva no Firestore',
      (tester) async {
        await tester.pumpWidget(montarApp());
        await tester.pumpAndSettle();

        final campos = find.byType(TextFormField);

        expect(campos, findsNWidgets(10));

        // 0 - Nome
        await tester.enterText(
          campos.at(0),
          'João da Silva',
        );

        // 1 - Data de nascimento.
        await tester.enterText(
          campos.at(1),
          '01011990',
        );

        // 2 - E-mail.
        await tester.enterText(
          campos.at(2),
          'joao.teste@example.com',
        );

        // 3 - Senha.
        await tester.enterText(
          campos.at(3),
          'senha123',
        );

        // 4 - Confirmar senha.
        await tester.enterText(
          campos.at(4),
          'senha123',
        );

        // 5 - CEP.
        //
        // O código da aplicação dispara a consulta ao ViaCEP
        // quando o CEP fica completo. O flutter_test bloqueia
        // requisições HTTP reais, portanto não dependemos da
        // resposta dessa chamada.
        await tester.enterText(
          campos.at(5),
          '50000000',
        );

        await tester.pump();

        // Rolamos a SingleChildScrollView para acessar os
        // campos inferiores.
        await rolarCadastroParaBaixo(tester);

        // 6 - Rua.
        await tester.enterText(
          campos.at(6),
          'Rua de Teste',
        );

        // 7 - Número.
        await tester.enterText(
          campos.at(7),
          '123',
        );

        // 8 - Bairro.
        await tester.enterText(
          campos.at(8),
          'Centro',
        );

        // 9 - Cidade.
        await tester.enterText(
          campos.at(9),
          'Recife',
        );

        // Localiza o estado.
        final estadoDropdown =
            find.byType(DropdownButtonFormField<String>);

        expect(estadoDropdown, findsOneWidget);

        await tester.tap(estadoDropdown);
        await tester.pumpAndSettle();

        await tester.tap(find.text('PE').last);
        await tester.pumpAndSettle();

        // O botão Cadastrar está no final do formulário.
        await rolarCadastroParaBaixo(tester);

        final botaoCadastrar = find.widgetWithText(
          ElevatedButton,
          'Cadastrar',
        );

        expect(botaoCadastrar, findsOneWidget);

        await tester.tap(botaoCadastrar);
        await tester.pumpAndSettle();

        // Firebase Auth deve ter criado o usuário.
        final usuario = mockAuth.currentUser;

        expect(usuario, isNotNull);
        expect(
          usuario!.email,
          'joao.teste@example.com',
        );

        // O cadastro deve ter navegado para a tela de gêneros.
        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        // O documento inicial deve existir no Firestore fake.
        final documentoInicial = await fakeFirestore
            .collection('usuarios')
            .doc(usuario.uid)
            .get();

        expect(documentoInicial.exists, isTrue);

        final dadosIniciais = documentoInicial.data();

        expect(
          dadosIniciais?['nome'],
          'João da Silva',
        );

        expect(
          dadosIniciais?['email'],
          'joao.teste@example.com',
        );

        expect(
          dadosIniciais?['data_nasc'],
          '01/01/1990',
        );

        // ----------------------------------------------------------
        // SELEÇÃO DE GÊNEROS
        // ----------------------------------------------------------

        final rockText = find.text('Rock');
        expect(rockText, findsOneWidget);

        final rockCard = find.ancestor(
          of: rockText,
          matching: find.byType(Card),
        );

        expect(rockCard, findsOneWidget);

        final rockSwitch = find.descendant(
          of: rockCard,
          matching: find.byType(Switch),
        );

        expect(rockSwitch, findsOneWidget);

        await tester.tap(rockSwitch);
        await tester.pump();

        final jazzText = find.text('Jazz');
        expect(jazzText, findsOneWidget);

        final jazzCard = find.ancestor(
          of: jazzText,
          matching: find.byType(Card),
        );

        expect(jazzCard, findsOneWidget);

        final jazzSwitch = find.descendant(
          of: jazzCard,
          matching: find.byType(Switch),
        );

        expect(jazzSwitch, findsOneWidget);

        await tester.tap(jazzSwitch);
        await tester.pump();

        // A tela de gêneros também possui um SingleChildScrollView.
        final scrollViewGeneros = find.byType(SingleChildScrollView);

        expect(scrollViewGeneros, findsOneWidget);

        // O botão Confirmar fica depois da lista de gêneros.
        await tester.drag(
          scrollViewGeneros,
          const Offset(0, -500),
        );

        await tester.pumpAndSettle();

        final botaoConfirmar = find.widgetWithText(
          ElevatedButton,
          'Confirmar',
        );

        expect(botaoConfirmar, findsOneWidget);

        await tester.tap(botaoConfirmar);
        await tester.pumpAndSettle();

        // Deve navegar para a tela inicial.
        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );

        // ----------------------------------------------------------
        // VERIFICAÇÃO FINAL DO FIRESTORE
        // ----------------------------------------------------------

        final documentoAtualizado = await fakeFirestore
            .collection('usuarios')
            .doc(usuario.uid)
            .get();

        expect(documentoAtualizado.exists, isTrue);

        final dadosAtualizados = documentoAtualizado.data();

        expect(
          dadosAtualizados?['generos_favoritos'],
          isA<List>(),
        );

        final generosFavoritos =
            List<String>.from(
          dadosAtualizados?['generos_favoritos'] as List,
        );

        expect(
          generosFavoritos,
          containsAll(<String>[
            'Rock',
            'Jazz',
          ]),
        );

        expect(
          generosFavoritos.length,
          2,
        );
      },
    );

    testWidgets(
      'não permite confirmar gêneros sem selecionar pelo menos um gênero',
      (tester) async {
        mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
            uid: 'usuario-teste',
            email: 'joao.teste@example.com',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        final botaoConfirmar = find.widgetWithText(
          ElevatedButton,
          'Confirmar',
        );

        expect(botaoConfirmar, findsOneWidget);

        // Move a SingleChildScrollView para mostrar o botão.
        final scrollView = find.byType(SingleChildScrollView);

        expect(scrollView, findsOneWidget);

        await tester.drag(
          scrollView,
          const Offset(0, -500),
        );

        await tester.pumpAndSettle();

        await tester.tap(botaoConfirmar);
        await tester.pump();

        // Nenhum gênero foi selecionado.
        // A aplicação deve mostrar o SnackBar de validação.
        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );

        // Não deve navegar.
        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );
  });
}
