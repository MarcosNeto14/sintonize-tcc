import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';

/// FirebaseAuth usado somente para simular falha no cadastro.
class MockFirebaseAuthWithError extends Mock implements FirebaseAuth {
  @override
  User? get currentUser => null;

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw FirebaseAuthException(
      code: 'email-already-in-use',
      message: 'O e-mail já está cadastrado.',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxo de cadastro do Sintonize', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;

    setUp(() {
      firestore = FakeFirebaseFirestore();

      auth = MockFirebaseAuth(
        signedIn: false,
      );
    });

    Future<void> abrirCadastro(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (context) => CadastroScreen(
                  auth: auth,
                  firestore: firestore,
                ),
            '/generos': (context) => GenerosCadastroScreen(
                  auth: auth,
                  firestore: firestore,
                ),
            '/inicio': (context) => const TelaInicialScreen(),
          },
        ),
      );

      await tester.pumpAndSettle();
    }

    Future<void> preencherCadastro(WidgetTester tester) async {
      final campos = find.byType(TextFormField);

      expect(campos, findsNWidgets(10));

      // Nome
      await tester.enterText(
        campos.at(0),
        'Maria da Silva',
      );

      // Data de nascimento
      await tester.enterText(
        campos.at(1),
        '01011990',
      );

      // E-mail
      await tester.enterText(
        campos.at(2),
        'maria@example.com',
      );

      // Senha
      await tester.enterText(
        campos.at(3),
        '123456',
      );

      // Confirmar senha
      await tester.enterText(
        campos.at(4),
        '123456',
      );

      // CEP.
      //
      // A aplicação dispara o ViaCEP quando o valor chega a 9 caracteres.
      // O flutter_test bloqueia HTTP real, então não dependemos da resposta
      // dessa chamada.
      await tester.enterText(
        campos.at(5),
        '50000-000',
      );

      await tester.pump();

      // Preenche os campos manualmente para que o documento criado pelo
      // cadastro tenha valores determinísticos.
      await tester.enterText(
        campos.at(6),
        'Rua das Flores',
      );

      await tester.enterText(
        campos.at(7),
        '123',
      );

      await tester.enterText(
        campos.at(8),
        'Centro',
      );

      await tester.enterText(
        campos.at(9),
        'Recife',
      );

      // ---------------------------------------------------------------
      // Seleção do estado
      // ---------------------------------------------------------------

      final dropdown = find.byType(
        DropdownButtonFormField<String>,
      );

      expect(dropdown, findsOneWidget);

      // O dropdown fica abaixo da área inicialmente visível.
      await tester.scrollUntilVisible(
        dropdown,
        300,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.pumpAndSettle();

      // Abre o menu.
      await tester.tap(dropdown);

      await tester.pumpAndSettle();

      // O DropdownButton abre um menu em uma rota/overlay própria.
      //
      // Nesse momento o "PE" pode não estar entre os widgets renderizados,
      // porque o menu possui rolagem própria.
      final estadoPE = find.text('PE');

      // Localiza o Scrollable do menu aberto.
      //
      // O primeiro Scrollable continua sendo o SingleChildScrollView
      // da CadastroScreen. O último corresponde ao menu do Dropdown.
      final scrollables = find.byType(Scrollable);

      expect(
        scrollables,
        findsAtLeastNWidgets(2),
      );

      final menuScrollable = scrollables.last;

      // Rola o menu até PE ficar visível.
      await tester.scrollUntilVisible(
        estadoPE,
        100,
        scrollable: menuScrollable,
      );

      await tester.pumpAndSettle();

      expect(
        estadoPE,
        findsOneWidget,
      );

      // Seleciona Pernambuco.
      await tester.tap(estadoPE);

      await tester.pumpAndSettle();
    }

    Future<void> selecionarGenero(
      WidgetTester tester,
      String genero,
    ) async {
      final textoGenero = find.text(genero);

      expect(textoGenero, findsOneWidget);

      final card = find.ancestor(
        of: textoGenero,
        matching: find.byType(Card),
      );

      expect(card, findsOneWidget);

      final switchFinder = find.descendant(
        of: card,
        matching: find.byType(Switch),
      );

      expect(switchFinder, findsOneWidget);

      // Garante que o Switch está no viewport antes do tap.
      await tester.scrollUntilVisible(
        switchFinder,
        200,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.pumpAndSettle();

      await tester.tap(switchFinder);
      await tester.pump();
    }

    testWidgets(
      'deve completar o cadastro, selecionar gêneros e salvar no Firestore',
      (tester) async {
        // ---------------------------------------------------------------
        // 1. CadastroScreen
        // ---------------------------------------------------------------
        await abrirCadastro(tester);

        expect(
          find.text('Cadastrar'),
          findsOneWidget,
        );

        // ---------------------------------------------------------------
        // 2. Preenche formulário
        // ---------------------------------------------------------------
        await preencherCadastro(tester);

        // ---------------------------------------------------------------
        // 3. Localiza e toca em Cadastrar
        // ---------------------------------------------------------------
        final botaoCadastrar = find.text('Cadastrar');

        await tester.scrollUntilVisible(
          botaoCadastrar,
          300,
          scrollable: find.byType(Scrollable).first,
        );

        await tester.pumpAndSettle();

        await tester.tap(botaoCadastrar);
        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // 4. Firebase Auth deve ter criado o usuário
        // ---------------------------------------------------------------
        expect(
          auth.currentUser,
          isNotNull,
        );

        final uid = auth.currentUser!.uid;

        // ---------------------------------------------------------------
        // 5. Firestore deve conter o documento criado
        // ---------------------------------------------------------------
        final documentoInicial = await firestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(
          documentoInicial.exists,
          isTrue,
        );

        final dados = documentoInicial.data()!;

        expect(
          dados['nome'],
          'Maria da Silva',
        );

        expect(
          dados['data_nasc'],
          '01/01/1990',
        );

        expect(
          dados['email'],
          'maria@example.com',
        );

        expect(
          dados['generos_favoritos'],
          isNull,
        );

        final endereco =
            dados['endereco'] as Map<String, dynamic>;

        expect(
          endereco['rua'],
          'Rua das Flores',
        );

        expect(
          endereco['numero'],
          '123',
        );

        expect(
          endereco['bairro'],
          'Centro',
        );

        expect(
          endereco['cidade'],
          'Recife',
        );

        expect(
          endereco['estado'],
          'PE',
        );

        expect(
          endereco['cep'],
          '50000-000',
        );

        // ---------------------------------------------------------------
        // 6. Deve ter navegado para GenerosCadastroScreen
        // ---------------------------------------------------------------
        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        expect(
          find.text('Confirmar'),
          findsOneWidget,
        );

        // ---------------------------------------------------------------
        // 7. Seleciona Rock, Jazz e Reggae
        // ---------------------------------------------------------------
        await selecionarGenero(tester, 'Rock');
        await selecionarGenero(tester, 'Jazz');
        await selecionarGenero(tester, 'Reggae');

        // ---------------------------------------------------------------
        // 8. Coloca Confirmar no viewport
        // ---------------------------------------------------------------
        final confirmar = find.text('Confirmar');

        await tester.scrollUntilVisible(
          confirmar,
          300,
          scrollable: find.byType(Scrollable).first,
        );

        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // 9. Confirma gêneros
        // ---------------------------------------------------------------
        await tester.tap(confirmar);
        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // 10. Verifica Firestore
        // ---------------------------------------------------------------
        final documentoFinal = await firestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(
          documentoFinal.exists,
          isTrue,
        );

        final dadosFinais = documentoFinal.data()!;

        final generos =
            List<String>.from(
          dadosFinais['generos_favoritos'] as List,
        );

        expect(
          generos,
          containsAll(<String>[
            'Rock',
            'Jazz',
            'Reggae',
          ]),
        );

        expect(
          generos.length,
          3,
        );

        // ---------------------------------------------------------------
        // 11. Deve chegar à TelaInicialScreen
        // ---------------------------------------------------------------
        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir erro quando Firebase Auth falha ao cadastrar',
      (tester) async {
        final failingAuth = MockFirebaseAuthWithError();

        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: failingAuth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await preencherCadastro(tester);

        final botaoCadastrar = find.text('Cadastrar');

        await tester.scrollUntilVisible(
          botaoCadastrar,
          300,
          scrollable: find.byType(Scrollable).first,
        );

        await tester.pumpAndSettle();

        await tester.tap(botaoCadastrar);
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Erro ao cadastrar: O e-mail já está cadastrado.',
          ),
          findsOneWidget,
        );

        // Continua na tela de cadastro.
        expect(
          find.text('Cadastrar'),
          findsOneWidget,
        );

        // Não houve autenticação.
        expect(
          failingAuth.currentUser,
          isNull,
        );

        // Não houve criação de documento.
        final usuarios = await firestore
            .collection('usuarios')
            .get();

        expect(
          usuarios.docs,
          isEmpty,
        );
      },
    );

    testWidgets(
      'não deve salvar gêneros quando não existe usuário autenticado',
      (tester) async {
        final authSemUsuario = MockFirebaseAuth(
          signedIn: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: authSemUsuario,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        // ---------------------------------------------------------------
        // Seleciona Rock
        // ---------------------------------------------------------------
        await selecionarGenero(tester, 'Rock');

        // ---------------------------------------------------------------
        // Coloca Confirmar no viewport
        // ---------------------------------------------------------------
        final confirmar = find.text('Confirmar');

        await tester.scrollUntilVisible(
          confirmar,
          300,
          scrollable: find.byType(Scrollable).first,
        );

        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // Confirma
        // ---------------------------------------------------------------
        await tester.tap(confirmar);
        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // Sem usuário autenticado, a aplicação não deve navegar.
        // ---------------------------------------------------------------
        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );

        expect(
          find.text('Confirmar'),
          findsOneWidget,
        );

        // Nenhum documento deve ter sido criado.
        final usuarios = await firestore
            .collection('usuarios')
            .get();

        expect(
          usuarios.docs,
          isEmpty,
        );
      },
    );
  });
}
