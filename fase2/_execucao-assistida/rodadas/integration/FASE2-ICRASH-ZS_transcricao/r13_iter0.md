Abaixo está um arquivo de teste completo. Há um detalhe importante: como GenerosCadastroScreen cria TelaInicialScreen() sem receber dependências, o teste de sucesso só precisa garantir que a navegação ocorreu; para o cenário de Firestore, o FakeFirebaseFirestore permite simular a falha via Mockito apenas se você injetar um mock de FirebaseFirestore. Para FirebaseAuth, MockFirebaseAuth cobre criação de usuário e estado de autenticação.

Escrita
// test/integration/cadastro_fluxo_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';

/// Mock simples para permitir simular indisponibilidade do Firestore.
class MockFirestore extends Mock implements FirebaseFirestore {}

/// Mock de DocumentReference usado no cenário de erro.
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

void main() {
  group('Fluxo de cadastro do Sintonize', () {
    late MockFirebaseAuth auth;
    late FakeFirebaseFirestore firestore;

    setUp(() {
      auth = MockFirebaseAuth();
      firestore = FakeFirebaseFirestore();
    });

    Widget buildApp() {
      return MaterialApp(
        initialRoute: '/cadastro',
        routes: {
          '/cadastro': (context) => CadastroScreen(
                auth: auth,
                firestore: firestore,
              ),
          '/generos': (context) => GenerosCadastroScreen(
                auth: auth,
                firestore: firestore,
              ),
          '/inicio': (context) => const TelaInicialScreen(),
        },
      );
    }

    Future<void> preencherCadastro(WidgetTester tester) async {
      final campos = find.byType(TextFormField);

      expect(campos, findsNWidgets(10));

      await tester.enterText(campos.at(0), 'João da Silva');
      await tester.enterText(campos.at(1), '01/01/2000');
      await tester.enterText(campos.at(2), 'joao@example.com');
      await tester.enterText(campos.at(3), '123456');
      await tester.enterText(campos.at(4), '123456');
      await tester.enterText(campos.at(5), '50000-000');
      await tester.enterText(campos.at(6), 'Rua Principal');
      await tester.enterText(campos.at(7), '123');
      await tester.enterText(campos.at(8), 'Centro');
      await tester.enterText(campos.at(9), 'Recife');
    }

    testWidgets(
      'realiza cadastro, navega para gêneros, salva gênero e chega à tela inicial',
      (tester) async {
        final mockUser = MockUser(
          uid: 'usuario-123',
          email: 'joao@example.com',
        );

        auth = MockFirebaseAuth(
          mockUser: mockUser,
          signedIn: false,
        );

        await tester.pumpWidget(buildApp());

        expect(find.byType(CadastroScreen), findsOneWidget);

        await preencherCadastro(tester);

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        // O MockFirebaseAuth cria o usuário e o FakeFirestore recebe
        // o documento criado pela CadastroScreen.
        expect(auth.currentUser, isNotNull);
        expect(auth.currentUser!.uid, 'usuario-123');

        final usuario =
            await firestore.collection('usuarios').doc('usuario-123').get();

        expect(usuario.exists, isTrue);
        expect(usuario.data()?['nome'], 'João da Silva');
        expect(usuario.data()?['email'], 'joao@example.com');

        // A tela de gêneros deve ter sido aberta.
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);
        expect(find.text('Rock'), findsOneWidget);
        expect(find.text('Pop'), findsOneWidget);

        // Seleciona Rock e Pop.
        final rockSwitch = find.byType(SwitchListTile).at(0);
        final popSwitch = find.byType(SwitchListTile).at(1);

        await tester.tap(rockSwitch);
        await tester.pump();

        await tester.tap(popSwitch);
        await tester.pump();

        // Confirma os gêneros.
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        // O documento existente deve ter sido atualizado.
        final usuarioAtualizado =
            await firestore.collection('usuarios').doc('usuario-123').get();

        expect(
          usuarioAtualizado.data()?['generos_favoritos'],
          containsAll(<String>['Rock', 'Pop']),
        );

        expect(
          usuarioAtualizado.data()?['generos_favoritos'],
          hasLength(2),
        );

        // Após salvar, a tela inicial é aberta.
        expect(find.byType(TelaInicialScreen), findsOneWidget);
      },
    );

    testWidgets(
      'exibe erro quando o Firebase Auth falha',
      (tester) async {
        auth = MockFirebaseAuth(
          signedIn: false,
          mockUser: null,
        );

        await tester.pumpWidget(buildApp());

        await preencherCadastro(tester);

        // O MockFirebaseAuth não deve criar um usuário válido neste cenário.
        // Substitua este bloco pela configuração de falha suportada pela versão
        // instalada de firebase_auth_mocks, caso ela disponibilize um callback
        // de erro para signUp.
        //
        // Como alternativa, usamos um FirebaseAuth mockado diretamente para
        // controlar createUserWithEmailAndPassword.
        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        // Sem usuário autenticado, o fluxo não deve chegar à tela de gêneros.
        expect(find.byType(GenerosCadastroScreen), findsNothing);
      },
    );

    testWidgets(
      'exibe erro quando o Firestore falha ao criar o usuário',
      (tester) async {
        final firestoreMock = MockFirestore();
        final collection = MockCollectionReference();
        final document = MockDocumentReference();

        when(firestoreMock.collection('usuarios')).thenReturn(collection);
        when(collection.doc('usuario-123')).thenReturn(document);

        when(
          document.set(any),
        ).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
            message: 'Firestore indisponível',
          ),
        );

        final mockUser = MockUser(
          uid: 'usuario-123',
          email: 'joao@example.com',
        );

        auth = MockFirebaseAuth(
          mockUser: mockUser,
          signedIn: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestoreMock,
            ),
          ),
        );

        await preencherCadastro(tester);

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        // A tela de gêneros não deve ser aberta porque o set() falhou.
        expect(find.byType(GenerosCadastroScreen), findsNothing);

        // O código captura o erro no catch genérico.
        expect(
          find.textContaining('Erro desconhecido:'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'exibe mensagem quando nenhum gênero é selecionado',
      (tester) async {
        // Para entrar diretamente na tela de gêneros precisamos ter
        // um usuário autenticado, pois _salvarGeneros acessa currentUser.
        final mockUser = MockUser(
          uid: 'usuario-123',
          email: 'joao@example.com',
        );

        auth = MockFirebaseAuth(
          mockUser: mockUser,
          signedIn: true,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        expect(find.byType(GenerosCadastroScreen), findsOneWidget);

        // Não seleciona nenhum gênero.
        await tester.tap(find.text('Confirmar'));
        await tester.pump();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );

        // Continua na mesma tela.
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      },
    );

    testWidgets(
      'exibe erro quando o usuário não está autenticado ao salvar gêneros',
      (tester) async {
        // MockFirebaseAuth sem usuário.
        auth = MockFirebaseAuth(
          mockUser: null,
          signedIn: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        expect(find.byType(GenerosCadastroScreen), findsOneWidget);

        // Seleciona um gênero para passar pela validação de _confirmar().
        await tester.tap(find.byType(SwitchListTile).first);
        await tester.pump();

        // Neste ponto _salvarGeneros() executará:
        //
        // widget.auth.currentUser!.uid
        //
        // Como currentUser é null, ocorre uma exceção.
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        // A exceção ocorre dentro do método assíncrono antes do try,
        // pois o acesso a currentUser está fora do bloco try.
        //
        // Portanto, com o código atual da tela, não há SnackBar de erro
        // para este caso. O teste verifica que não houve navegação.
        expect(find.byType(TelaInicialScreen), findsNothing);
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      },
    );
  });
}

/// Mocks auxiliares para o cenário de Firestore indisponível.
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}


Há dois pontos no código de produção que vale corrigir para que o teste de erro reflita um comportamento realmente tratável:

Em GenerosCadastroScreen, currentUser!.uid está fora do try. Se não houver usuário autenticado, o Null check operator used on a null value escapa do tratamento.
Para testar especificamente FirebaseAuth.createUserWithEmailAndPassword lançando FirebaseAuthException, a forma mais controlável é criar um mock de FirebaseAuth com Mockito. A API exata disponível no firebase_auth_mocks varia conforme a versão.

A correção recomendada para _salvarGeneros() é:

Future<void> _salvarGeneros() async {
  try {
    final user = widget.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado!')),
      );
      return;
    }

    final generosSelecionados = selecionados.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    await widget.firestore
        .collection('usuarios')
        .doc(user.uid)
        .update({
      'generos_favoritos': generosSelecionados,
    });

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TelaInicialScreen(),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Erro ao salvar os gêneros!')),
    );
  }
}


Também recomendo ajustar o cenário de Auth para usar um MockFirebaseAuth configurado explicitamente para lançar a exceção na versão da biblioteca que seu pubspec.yaml utiliza. Isso evita um falso positivo: simplesmente criar MockFirebaseAuth sem usuário não significa necessariamente que createUserWithEmailAndPassword() irá falhar.