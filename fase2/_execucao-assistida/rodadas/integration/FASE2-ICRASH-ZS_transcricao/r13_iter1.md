Classificação: (A) — o teste presume um comportamento que não é o especificado.

A falha ocorre na compilação do teste, não na aplicação: DocumentReference.set() exige um Map<String, dynamic> não nulo, enquanto o matcher any foi inferido de forma incompatível. Isso é um problema de tipagem do mock. A correção é usar any<Map<String, dynamic>>().

Mantendo o código da aplicação inalterado, segue o arquivo completo corrigido. Também ajustei o cenário de falha do Firebase Auth para realmente fazer createUserWithEmailAndPassword() lançar FirebaseAuthException, em vez de presumir que MockFirebaseAuth falharia sozinho.

Escrita
// test/fase2/integration/icrash_zs_test.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';

/// Mock de FirebaseAuth usado para simular falhas controladas.
class MockAuth extends Mock implements FirebaseAuth {}

/// Mock de FirebaseFirestore usado para simular indisponibilidade.
class MockFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

void main() {
  group('Integração - fluxo de cadastro do Sintonize', () {
    late MockFirebaseAuth auth;
    late FakeFirebaseFirestore firestore;

    setUp(() {
      auth = MockFirebaseAuth();
      firestore = FakeFirebaseFirestore();
    });

    Widget buildApp({
      FirebaseAuth? customAuth,
      FirebaseFirestore? customFirestore,
    }) {
      final appAuth = customAuth ?? auth;
      final appFirestore = customFirestore ?? firestore;

      return MaterialApp(
        initialRoute: '/cadastro',
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

    Future<void> preencherFormulario(WidgetTester tester) async {
      final campos = find.byType(TextFormField);

      expect(campos, findsNWidgets(10));

      await tester.enterText(
        campos.at(0),
        'João da Silva',
      );

      await tester.enterText(
        campos.at(1),
        '01/01/2000',
      );

      await tester.enterText(
        campos.at(2),
        'joao@example.com',
      );

      await tester.enterText(
        campos.at(3),
        '123456',
      );

      await tester.enterText(
        campos.at(4),
        '123456',
      );

      await tester.enterText(
        campos.at(5),
        '50000-000',
      );

      await tester.enterText(
        campos.at(6),
        'Rua Principal',
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
    }

    testWidgets(
      'fluxo completo: cadastro -> gêneros -> Firestore -> tela inicial',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
          email: 'joao@example.com',
        );

        auth = MockFirebaseAuth(
          mockUser: user,
          signedIn: false,
        );

        await tester.pumpWidget(buildApp());

        expect(find.byType(CadastroScreen), findsOneWidget);

        // ---------------------------------------------------------------
        // 1. Preenche o formulário de cadastro.
        // ---------------------------------------------------------------
        await preencherFormulario(tester);

        // ---------------------------------------------------------------
        // 2. Cria a conta.
        // ---------------------------------------------------------------
        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        expect(auth.currentUser, isNotNull);
        expect(auth.currentUser!.uid, equals('usuario-123'));

        // ---------------------------------------------------------------
        // 3. Verifica o documento criado no Firestore.
        // ---------------------------------------------------------------
        final documento = await firestore
            .collection('usuarios')
            .doc('usuario-123')
            .get();

        expect(documento.exists, isTrue);

        final dados = documento.data();

        expect(dados?['nome'], equals('João da Silva'));
        expect(dados?['data_nasc'], equals('01/01/2000'));
        expect(dados?['email'], equals('joao@example.com'));

        expect(
          dados?['endereco'],
          isA<Map<String, dynamic>>(),
        );

        final endereco =
            dados?['endereco'] as Map<String, dynamic>;

        expect(endereco['rua'], equals('Rua Principal'));
        expect(endereco['numero'], equals('123'));
        expect(endereco['bairro'], equals('Centro'));
        expect(endereco['cidade'], equals('Recife'));
        expect(endereco['cep'], equals('50000-000'));

        // ---------------------------------------------------------------
        // 4. Deve navegar para GenerosCadastroScreen.
        // ---------------------------------------------------------------
        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        expect(find.text('Rock'), findsOneWidget);
        expect(find.text('Pop'), findsOneWidget);
        expect(find.text('Jazz'), findsOneWidget);
        expect(find.text('Blues'), findsOneWidget);
        expect(find.text('Hip-Hop'), findsOneWidget);
        expect(find.text('Reggae'), findsOneWidget);
        expect(find.text('Country'), findsOneWidget);

        // ---------------------------------------------------------------
        // 5. Seleciona dois gêneros.
        // ---------------------------------------------------------------
        await tester.tap(find.byType(SwitchListTile).at(0));
        await tester.pump();

        await tester.tap(find.byType(SwitchListTile).at(1));
        await tester.pump();

        // Confirma que os switches ficaram selecionados.
        final rockSwitch =
            tester.widget<SwitchListTile>(
          find.byType(SwitchListTile).at(0),
        );

        final popSwitch =
            tester.widget<SwitchListTile>(
          find.byType(SwitchListTile).at(1),
        );

        expect(rockSwitch.value, isTrue);
        expect(popSwitch.value, isTrue);

        // ---------------------------------------------------------------
        // 6. Salva os gêneros.
        // ---------------------------------------------------------------
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // 7. Verifica o estado final no Firestore.
        // ---------------------------------------------------------------
        final documentoFinal = await firestore
            .collection('usuarios')
            .doc('usuario-123')
            .get();

        final dadosFinais = documentoFinal.data();

        expect(
          dadosFinais?['generos_favoritos'],
          equals(<String>['Rock', 'Pop']),
        );

        // ---------------------------------------------------------------
        // 8. Verifica a navegação final.
        // ---------------------------------------------------------------
        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'exibe erro quando Firebase Auth falha durante o cadastro',
      (tester) async {
        final authMock = MockAuth();

        when(
          authMock.createUserWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenThrow(
          FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'O e-mail já está em uso.',
          ),
        );

        await tester.pumpWidget(
          buildApp(customAuth: authMock),
        );

        await preencherFormulario(tester);

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        // O Navigator não deve ter saído da tela de cadastro.
        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );

        // O código de produção captura FirebaseAuthException
        // e apresenta a mensagem no SnackBar.
        expect(
          find.text(
            'Erro ao cadastrar: O e-mail já está em uso.',
          ),
          findsOneWidget,
        );

        verify(
          authMock.createUserWithEmailAndPassword(
            email: 'joao@example.com',
            password: '123456',
          ),
        ).called(1);
      },
    );

    testWidgets(
      'não navega para gêneros quando Firestore falha ao criar usuário',
      (tester) async {
        final authMock = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'usuario-123',
            email: 'joao@example.com',
          ),
          signedIn: false,
        );

        final firestoreMock = MockFirestore();
        final collectionMock = MockCollectionReference();
        final documentMock = MockDocumentReference();

        when(
          firestoreMock.collection('usuarios'),
        ).thenReturn(collectionMock);

        when(
          collectionMock.doc('usuario-123'),
        ).thenReturn(documentMock);

        // O ponto importante da correção é o tipo explícito:
        //
        // any<Map<String, dynamic>>()
        //
        // em vez de simplesmente `any`.
        when(
          documentMock.set(any<Map<String, dynamic>>()),
        ).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
            message: 'Firestore indisponível.',
          ),
        );

        await tester.pumpWidget(
          buildApp(
            customAuth: authMock,
            customFirestore: firestoreMock,
          ),
        );

        await preencherFormulario(tester);

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        // A autenticação ocorreu.
        expect(
          authMock.currentUser,
          isNotNull,
        );

        // O set() do Firestore foi tentado.
        verify(
          documentMock.set(any<Map<String, dynamic>>()),
        ).called(1);

        // Como o set() falhou, a aplicação não deve navegar
        // para GenerosCadastroScreen.
        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );

        // O catch genérico de _submit() apresenta esta mensagem.
        expect(
          find.textContaining('Erro desconhecido:'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'exibe aviso quando nenhum gênero é selecionado',
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
          buildApp(),
        );

        // A tela inicial da rota é CadastroScreen, portanto substituímos
        // o conteúdo navegando explicitamente para a rota de gêneros.
        Navigator.of(
          tester.element(find.byType(CadastroScreen)),
        ).pushReplacement(
          MaterialPageRoute(
            builder: (_) => GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        // Nenhum SwitchListTile é selecionado.
        final switches = find.byType(SwitchListTile);

        for (var i = 0; i < 7; i++) {
          final tile =
              tester.widget<SwitchListTile>(switches.at(i));
          expect(tile.value, isFalse);
        }

        // Tenta confirmar sem escolher gênero.
        await tester.tap(find.text('Confirmar'));
        await tester.pump();

        expect(
          find.text(
            'Selecione pelo menos um gênero musical!',
          ),
          findsOneWidget,
        );

        // Deve permanecer na tela de gêneros.
        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'usuário não autenticado não consegue concluir o salvamento de gêneros',
      (tester) async {
        final authMock = MockAuth();

        // currentUser permanece null.
        when(authMock.currentUser).thenReturn(null);

        await tester.pumpWidget(
          MaterialApp(
            initialRoute: '/generos',
            routes: {
              '/generos': (_) => GenerosCadastroScreen(
                    auth: authMock,
                    firestore: firestore,
                  ),
              '/inicio': (_) => const TelaInicialScreen(),
            },
          ),
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        // Seleciona um gênero para que _confirmar() tente executar
        // _salvarGeneros().
        await tester.tap(
          find.byType(SwitchListTile).first,
        );
        await tester.pump();

        expect(
          tester
              .widget<SwitchListTile>(
                find.byType(SwitchListTile).first,
              )
              .value,
          isTrue,
        );

        await tester.tap(find.text('Confirmar'));

        // O acesso a currentUser!.uid acontece ANTES do try/catch
        // no código de produção. Por isso o erro é uma exceção não
        // tratada pelo catch de _salvarGeneros().
        await tester.pump();

        // O comportamento observado da implementação atual é:
        // - não navega para TelaInicialScreen;
        // - não apresenta o SnackBar "Erro ao salvar os gêneros!",
        //   porque a exceção acontece antes do try.
        //
        // O teste não transforma esse comportamento em sucesso.
        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );
  });
}

Observação importante sobre o último cenário

Esse caso é deliberadamente diferente dos demais. No código fornecido, currentUser!.uid está antes do try:

final uid = widget.auth.currentUser!.uid;

try {
  // ...
}


Portanto, quando currentUser == null, a exceção acontece antes de o catch poder executá-la. Isso caracteriza um comportamento potencialmente incorreto da aplicação, mas, conforme sua instrução, não alterei o código de produção nem enfraqueci o teste para mascarar o problema.

A correção da falha que você reportou especificamente é esta:

when(
  documentMock.set(any<Map<String, dynamic>>()),
).thenThrow(...);


e igualmente:

verify(
  documentMock.set(any<Map<String, dynamic>>()),
).called(1);


Assim o matcher possui exatamente o tipo exigido por DocumentReference<Map<String, dynamic>>.set().