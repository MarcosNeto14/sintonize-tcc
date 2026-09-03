// test/fase2/integration/icrash_zs_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  group('Integração - Cadastro do Sintonize', () {
    late MockFirebaseAuth auth;
    late FakeFirebaseFirestore firestore;

    setUp(() {
      auth = MockFirebaseAuth();
      firestore = FakeFirebaseFirestore();
    });

    Widget criarAplicacao({
      FirebaseAuth? authOverride,
      FirebaseFirestore? firestoreOverride,
      String initialRoute = '/cadastro',
    }) {
      final appAuth = authOverride ?? auth;
      final appFirestore = firestoreOverride ?? firestore;

      return MaterialApp(
        initialRoute: initialRoute,
        routes: {
          '/cadastro': (_) => CadastroScreen(
                auth: appAuth,
                firestore: appFirestore,
              ),
          '/generos': (_) => GenerosCadastroScreen(
                auth: appAuth,
                firestore: appFirestore,
              ),
          '/inicio': (_) => const TelaInicialScreen(),
        },
      );
    }

    /// Torna um widget visível dentro do viewport antes de interagir com ele.
    Future<void> tornarVisivel(
      WidgetTester tester,
      Finder finder,
    ) async {
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
    }

    /// Preenche os campos do formulário, levando cada campo ao viewport
    /// antes de tentar interagir com ele.
    Future<void> preencherFormulario(WidgetTester tester) async {
      final campos = find.byType(TextFormField);

      expect(
        campos,
        findsNWidgets(10),
        reason: 'O formulário deve possuir os 10 campos esperados.',
      );

      final valores = <String>[
        'João da Silva',
        '01/01/2000',
        'joao@example.com',
        '123456',
        '123456',
        '50000-000',
        'Rua Principal',
        '123',
        'Centro',
        'Recife',
      ];

      for (var i = 0; i < valores.length; i++) {
        final campo = campos.at(i);

        await tornarVisivel(tester, campo);

        await tester.enterText(
          campo,
          valores[i],
        );
      }
    }

    /// Localiza o botão Cadastrar e garante que ele esteja no viewport.
    Future<void> tocarCadastrar(WidgetTester tester) async {
      final botao = find.widgetWithText(
        ElevatedButton,
        'Cadastrar',
      );

      expect(
        botao,
        findsOneWidget,
      );

      await tornarVisivel(tester, botao);
      await tester.tap(botao);
      await tester.pumpAndSettle();
    }

    /// Retorna o Switch correspondente a um gênero pelo texto exibido.
    Finder switchDoGenero(String genero) {
      final texto = find.text(genero);

      return find.descendant(
        of: find.ancestor(
          of: texto,
          matching: find.byType(Row),
        ),
        matching: find.byType(Switch),
      );
    }

    /// Seleciona um gênero na GenerosCadastroScreen real.
    Future<void> selecionarGenero(
      WidgetTester tester,
      String genero,
    ) async {
      final texto = find.text(genero);

      expect(
        texto,
        findsOneWidget,
        reason: 'O gênero "$genero" deve existir na tela.',
      );

      final switchFinder = switchDoGenero(genero);

      expect(
        switchFinder,
        findsOneWidget,
        reason: 'O gênero "$genero" deve possuir um Switch.',
      );

      await tornarVisivel(tester, switchFinder);
      await tester.tap(switchFinder);
      await tester.pump();
    }

    // =====================================================================
    // 1. FLUXO COMPLETO
    // =====================================================================

    testWidgets(
      'realiza cadastro, navega para gêneros, salva gêneros e chega à tela inicial',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
          email: 'joao@example.com',
        );

        auth = MockFirebaseAuth(
          mockUser: user,
          signedIn: false,
        );

        await tester.pumpWidget(
          criarAplicacao(),
        );

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );

        // ---------------------------------------------------------------
        // CadastroScreen
        // ---------------------------------------------------------------

        await preencherFormulario(tester);

        await tocarCadastrar(tester);

        // ---------------------------------------------------------------
        // Firebase Auth
        // ---------------------------------------------------------------

        expect(
          auth.currentUser,
          isNotNull,
        );

        expect(
          auth.currentUser!.uid,
          equals('usuario-123'),
        );

        expect(
          auth.currentUser!.email,
          equals('joao@example.com'),
        );

        // ---------------------------------------------------------------
        // Firestore - documento criado
        // ---------------------------------------------------------------

        final documento = await firestore
            .collection('usuarios')
            .doc('usuario-123')
            .get();

        expect(
          documento.exists,
          isTrue,
        );

        final dados = documento.data();

        expect(
          dados?['nome'],
          equals('João da Silva'),
        );

        expect(
          dados?['data_nasc'],
          equals('01/01/2000'),
        );

        expect(
          dados?['email'],
          equals('joao@example.com'),
        );

        expect(
          dados?['endereco'],
          isA<Map<String, dynamic>>(),
        );

        final endereco =
            dados!['endereco'] as Map<String, dynamic>;

        expect(
          endereco['rua'],
          equals('Rua Principal'),
        );

        expect(
          endereco['numero'],
          equals('123'),
        );

        expect(
          endereco['bairro'],
          equals('Centro'),
        );

        expect(
          endereco['cidade'],
          equals('Recife'),
        );

        expect(
          endereco['cep'],
          equals('50000-000'),
        );

        // ---------------------------------------------------------------
        // GenerosCadastroScreen
        // ---------------------------------------------------------------

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        for (final genero in <String>[
          'Rock',
          'Pop',
          'Jazz',
          'Blues',
          'Hip-Hop',
          'Reggae',
          'Country',
        ]) {
          expect(
            find.text(genero),
            findsOneWidget,
          );
        }

        // A implementação real usa Switch, não SwitchListTile.
        expect(
          find.byType(Switch),
          findsNWidgets(7),
        );

        // ---------------------------------------------------------------
        // Seleção dos gêneros
        // ---------------------------------------------------------------

        await selecionarGenero(tester, 'Rock');
        await selecionarGenero(tester, 'Pop');

        final rockSwitch = switchDoGenero('Rock');
        final popSwitch = switchDoGenero('Pop');

        expect(
          tester.widget<Switch>(rockSwitch).value,
          isTrue,
        );

        expect(
          tester.widget<Switch>(popSwitch).value,
          isTrue,
        );

        // Os demais permanecem desmarcados.
        for (final genero in <String>[
          'Jazz',
          'Blues',
          'Hip-Hop',
          'Reggae',
          'Country',
        ]) {
          final switchFinder = switchDoGenero(genero);

          expect(
            tester.widget<Switch>(switchFinder).value,
            isFalse,
          );
        }

        // ---------------------------------------------------------------
        // Confirmar
        // ---------------------------------------------------------------

        final confirmar = find.widgetWithText(
          ElevatedButton,
          'Confirmar',
        );

        expect(
          confirmar,
          findsOneWidget,
        );

        await tornarVisivel(tester, confirmar);
        await tester.tap(confirmar);
        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // Estado final no Firestore
        // ---------------------------------------------------------------

        final documentoFinal = await firestore
            .collection('usuarios')
            .doc('usuario-123')
            .get();

        expect(
          documentoFinal.exists,
          isTrue,
        );

        expect(
          documentoFinal.data()?['generos_favoritos'],
          equals(<String>[
            'Rock',
            'Pop',
          ]),
        );

        // ---------------------------------------------------------------
        // Estado final da aplicação
        // ---------------------------------------------------------------

        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );
      },
    );

    // =====================================================================
    // 2. FIREBASE AUTH FALHA
    // =====================================================================

    testWidgets(
      'permanece no cadastro e mostra erro quando Firebase Auth falha',
      (tester) async {
        auth = MockFirebaseAuth(
          signedIn: false,
        );

        whenCalling(
          Invocation.method(
            #createUserWithEmailAndPassword,
            null,
          ),
        ).on(auth).thenThrow(
          FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'O e-mail já está em uso.',
          ),
        );

        await tester.pumpWidget(
          criarAplicacao(
            authOverride: auth,
          ),
        );

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );

        await preencherFormulario(tester);

        // O botão está inicialmente fora do viewport. Primeiro rolamos
        // até ele e somente então executamos tap().
        await tocarCadastrar(tester);

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );

        expect(
          find.text(
            'Erro ao cadastrar: O e-mail já está em uso.',
          ),
          findsOneWidget,
        );

        expect(
          auth.currentUser,
          isNull,
        );
      },
    );

    // =====================================================================
    // 3. FIRESTORE FALHA DURANTE O CADASTRO
    // =====================================================================

    testWidgets(
      'permanece no cadastro quando Firestore falha ao salvar o usuário',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
          email: 'joao@example.com',
        );

        auth = MockFirebaseAuth(
          mockUser: user,
          signedIn: false,
        );

        firestore = FakeFirebaseFirestore();

        final documento = firestore
            .collection('usuarios')
            .doc('usuario-123');

        whenCalling(
          Invocation.method(
            #set,
            null,
          ),
        ).on(documento).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
            message: 'Firestore indisponível.',
          ),
        );

        await tester.pumpWidget(
          criarAplicacao(
            authOverride: auth,
            firestoreOverride: firestore,
          ),
        );

        await preencherFormulario(tester);

        await tocarCadastrar(tester);

        // O Auth ocorre antes do set() do Firestore.
        expect(
          auth.currentUser,
          isNotNull,
        );

        expect(
          auth.currentUser!.uid,
          equals('usuario-123'),
        );

        // O set() falhou, portanto a navegação não acontece.
        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );

        expect(
          find.textContaining('Erro desconhecido:'),
          findsOneWidget,
        );
      },
    );

    // =====================================================================
    // 4. NENHUM GÊNERO SELECIONADO
    // =====================================================================

    testWidgets(
      'não salva e mostra aviso quando nenhum gênero é selecionado',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
          email: 'joao@example.com',
        );

        auth = MockFirebaseAuth(
          mockUser: user,
          signedIn: true,
        );

        await tester.pumpWidget(
          criarAplicacao(
            initialRoute: '/generos',
          ),
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        // A implementação real usa 7 Switch.
        final switches = find.byType(Switch);

        expect(
          switches,
          findsNWidgets(7),
        );

        for (var i = 0; i < 7; i++) {
          expect(
            tester.widget<Switch>(switches.at(i)).value,
            isFalse,
          );
        }

        final confirmar = find.widgetWithText(
          ElevatedButton,
          'Confirmar',
        );

        await tornarVisivel(tester, confirmar);
        await tester.tap(confirmar);
        await tester.pump();

        expect(
          find.text(
            'Selecione pelo menos um gênero musical!',
          ),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );

        // Nenhuma atualização ao Firestore deve ter ocorrido.
        final documentos = await firestore
            .collection('usuarios')
            .get();

        expect(
          documentos.docs,
          isEmpty,
        );
      },
    );

    // =====================================================================
    // 5. FIRESTORE FALHA AO SALVAR GÊNEROS
    // =====================================================================

    testWidgets(
      'mostra erro quando Firestore falha ao salvar os gêneros',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
          email: 'joao@example.com',
        );

        auth = MockFirebaseAuth(
          mockUser: user,
          signedIn: true,
        );

        firestore = FakeFirebaseFirestore();

        // O documento precisa existir porque a aplicação chama update().
        await firestore
            .collection('usuarios')
            .doc('usuario-123')
            .set({
          'nome': 'João da Silva',
          'email': 'joao@example.com',
        });

        final documento = firestore
            .collection('usuarios')
            .doc('usuario-123');

        whenCalling(
          Invocation.method(
            #update,
            null,
          ),
        ).on(documento).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
            message: 'Firestore indisponível.',
          ),
        );

        await tester.pumpWidget(
          criarAplicacao(
            authOverride: auth,
            firestoreOverride: firestore,
            initialRoute: '/generos',
          ),
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        await selecionarGenero(tester, 'Rock');

        expect(
          tester.widget<Switch>(
            switchDoGenero('Rock'),
          ).value,
          isTrue,
        );

        final confirmar = find.widgetWithText(
          ElevatedButton,
          'Confirmar',
        );

        await tornarVisivel(tester, confirmar);
        await tester.tap(confirmar);
        await tester.pumpAndSettle();

        // O update() ocorre dentro do try/catch de _salvarGeneros().
        expect(
          find.text('Erro ao salvar os gêneros!'),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );

        // O update() falhou, portanto não deve haver
        // generos_favoritos no documento.
        final documentoFinal = await firestore
            .collection('usuarios')
            .doc('usuario-123')
            .get();

        expect(
          documentoFinal.data()?['generos_favoritos'],
          isNull,
        );
      },
    );

    // =====================================================================
    // 6. USUÁRIO NÃO AUTENTICADO
    // =====================================================================

    testWidgets(
      'usuário não autenticado falha antes de salvar os gêneros',
      (tester) async {
        auth = MockFirebaseAuth(
          mockUser: null,
          signedIn: false,
        );

        await tester.pumpWidget(
          criarAplicacao(
            authOverride: auth,
            initialRoute: '/generos',
          ),
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        expect(
          auth.currentUser,
          isNull,
        );

        await selecionarGenero(tester, 'Rock');

        expect(
          tester.widget<Switch>(
            switchDoGenero('Rock'),
          ).value,
          isTrue,
        );

        final confirmar = find.widgetWithText(
          ElevatedButton,
          'Confirmar',
        );

        await tornarVisivel(tester, confirmar);
        await tester.tap(confirmar);

        /*
         * IMPORTANTE:
         *
         * O código real contém:
         *
         *   final uid = widget.auth.currentUser!.uid;
         *
         *   try {
         *     ...
         *   }
         *
         * O acesso a currentUser!.uid acontece ANTES do try.
         *
         * Portanto, quando currentUser == null, a aplicação lança
         * uma exceção antes de alcançar o catch:
         *
         *   catch (e) {
         *     ScaffoldMessenger.of(context).showSnackBar(...)
         *   }
         *
         * Não é correto esperar o SnackBar "Erro ao salvar os gêneros!"
         * neste teste, porque o código atual não consegue produzi-lo
         * para esse erro.
         *
         * Também não vamos esconder a exceção para transformar um
         * comportamento incorreto em sucesso.
         */

        await tester.pump();

        // O estado de navegação não deve ter chegado à tela inicial.
        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );

        // Continua na tela de gêneros.
        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        // O Firestore não recebe update porque o UID falha antes
        // da chamada ao Firestore.
        final documentos = await firestore
            .collection('usuarios')
            .get();

        expect(
          documentos.docs,
          isEmpty,
        );
      },
    );
  });
}
