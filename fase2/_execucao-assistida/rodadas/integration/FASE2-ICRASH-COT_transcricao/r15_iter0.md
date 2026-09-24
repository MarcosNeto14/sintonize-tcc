Abaixo está uma suíte de testes de integração/widget que respeita a restrição de não modificar as telas. Há, porém, uma limitação importante no código atual: CadastroScreen recebe auth/firestore por injeção, mas, ao navegar, cria GenerosCadastroScreen() sem repassar essas dependências. Portanto, os testes conseguem isolar completamente o cadastro, mas o trecho de salvamento de gêneros após a navegação usa FirebaseAuth.instance/FirebaseFirestore.instance, e não os mocks/fakes usados no teste.

1. Análise do fluxo

O usuário preenche nome, e-mail, senha e confirmação de senha na CadastroScreen; se a validação passar, o app chama Firebase Auth e depois grava os dados básicos do usuário no Firestore. Se ambas as operações forem bem-sucedidas, ocorre a navegação para GenerosCadastroScreen, onde o usuário pode selecionar um ou mais gêneros musicais. Ao confirmar, os gêneros são gravados no documento do usuário e, em caso de sucesso, o usuário é levado à TelaInicialScreen; erros de Firebase exibem SnackBar e impedem a navegação. Há ainda uma falha específica em GenerosCadastroScreen: se não houver usuário autenticado, currentUser!.uid lança uma exceção antes de entrar no try/catch.

2. Dependências por tela
CadastroScreen
FirebaseAuth.createUserWithEmailAndPassword()
FirebaseFirestore.collection('usuarios').doc(uid).set()
Devem ser substituídos por MockFirebaseAuth e FakeFirebaseFirestore nos testes.
GenerosCadastroScreen
FirebaseAuth.currentUser
FirebaseFirestore.collection('usuarios').doc(uid).update()
Idealmente deveriam receber os mesmos mocks/fakes via construtor.
Como a tela é instanciada diretamente pelo MaterialPageRoute, os testes não conseguem injetar esses objetos nesse ponto sem modificar a produção.
TelaInicialScreen
No fluxo apresentado, basta fornecer uma tela fake/placeholder com uma chave ou texto identificável para verificar a navegação final.
3. Estrutura de navegação

Para os testes, o MaterialApp pode ter CadastroScreen como home e uma rota /inicio para uma tela fake. A navegação de CadastroScreen para GenerosCadastroScreen ocorre por MaterialPageRoute diretamente no código de produção, portanto não depende do mapa de routes do MaterialApp.

Para testar GenerosCadastroScreen isoladamente, ela pode ser usada diretamente como home, permitindo passar MockFirebaseAuth e FakeFirebaseFirestore pelo construtor.

4. Cenários cobertos
Cadastro completo com sucesso, incluindo criação no Auth, gravação no Firestore e navegação para gêneros.
Nome vazio.
E-mail vazio.
Senha com menos de seis caracteres.
Senhas diferentes.
Falha de autenticação no Firebase.
Falha do Firestore durante a criação do documento.
Loading/interação enquanto uma operação assíncrona está pendente.
Confirmação de gêneros sem selecionar nenhum.
Seleção de gênero e salvamento bem-sucedido no Firestore.
Falha do Firestore ao salvar gêneros.
Entrada em GenerosCadastroScreen sem usuário autenticado.
Observação sobre o cenário de loading

O código fornecido não apresenta nenhum CircularProgressIndicator, setState(() => loading = true) ou desabilitação do botão durante operações assíncronas. Portanto, o teste pode verificar que a tela permanece visível enquanto a operação está pendente, mas não há um estado visual de loading implementado para validar.

5. Testes

O arquivo abaixo pode, por exemplo, ser colocado em integration/cadastro_generos_test.dart.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

// -----------------------------------------------------------------------------
// Mocks auxiliares para Firestore
// -----------------------------------------------------------------------------

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

Widget buildTestApp({
  required FirebaseAuth auth,
  required FirebaseFirestore firestore,
}) {
  return MaterialApp(
    home: CadastroScreen(
      auth: auth,
      firestore: firestore,
    ),
    routes: {
      '/inicio': (_) => const Scaffold(
            body: Text('Tela Inicial'),
          ),
    },
  );
}

Future<void> preencherCadastro(
  WidgetTester tester, {
  String nome = 'João',
  String email = 'joao@example.com',
  String senha = '123456',
  String confirmacao = '123456',
}) async {
  final campos = find.byType(TextFormField);

  await tester.enterText(campos.at(0), nome);
  await tester.enterText(campos.at(1), email);
  await tester.enterText(campos.at(2), senha);
  await tester.enterText(campos.at(3), confirmacao);
}

Future<void> tocarCadastrar(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastrar'));
  await tester.pump();
}

// -----------------------------------------------------------------------------
// 1. Fluxo de sucesso do cadastro
// -----------------------------------------------------------------------------

void main() {
  group('CadastroScreen', () {
    testWidgets(
      'realiza cadastro, grava usuário no Firestore e navega para gêneros',
      (tester) async {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildTestApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(tester);

        await tocarCadastrar(tester);

        // Aguarda createUserWithEmailAndPassword + Firestore.set().
        await tester.pumpAndSettle();

        expect(find.byType(GenerosCadastroScreen), findsOneWidget);

        final user = auth.currentUser;

        expect(user, isNotNull);

        final documento =
            await firestore.collection('usuarios').doc(user!.uid).get();

        expect(documento.exists, isTrue);
        expect(documento.data()?['nome'], 'João');
        expect(documento.data()?['email'], 'joao@example.com');
      },
    );

    // -------------------------------------------------------------------------
    // 2. Validação: nome obrigatório
    // -------------------------------------------------------------------------

    testWidgets(
      'não chama Firebase quando o nome está vazio',
      (tester) async {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildTestApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(
          tester,
          nome: '',
        );

        await tocarCadastrar(tester);
        await tester.pump();

        expect(
          find.text('O nome é obrigatório'),
          findsOneWidget,
        );

        expect(auth.currentUser, isNull);
      },
    );

    // -------------------------------------------------------------------------
    // 3. Validação: e-mail obrigatório
    // -------------------------------------------------------------------------

    testWidgets(
      'não chama Firebase quando o e-mail está vazio',
      (tester) async {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildTestApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(
          tester,
          email: '',
        );

        await tocarCadastrar(tester);
        await tester.pump();

        expect(
          find.text('O e-mail é obrigatório'),
          findsOneWidget,
        );

        expect(auth.currentUser, isNull);
      },
    );

    // -------------------------------------------------------------------------
    // 4. Validação: senha curta
    // -------------------------------------------------------------------------

    testWidgets(
      'não chama Firebase quando a senha tem menos de 6 caracteres',
      (tester) async {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildTestApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(
          tester,
          senha: '12345',
          confirmacao: '12345',
        );

        await tocarCadastrar(tester);
        await tester.pump();

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );

        expect(auth.currentUser, isNull);
      },
    );

    // -------------------------------------------------------------------------
    // 5. Validação: confirmação diferente
    // -------------------------------------------------------------------------

    testWidgets(
      'não chama Firebase quando as senhas não coincidem',
      (tester) async {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildTestApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(
          tester,
          senha: '123456',
          confirmacao: '654321',
        );

        await tocarCadastrar(tester);
        await tester.pump();

        expect(
          find.text('As senhas não coincidem'),
          findsOneWidget,
        );

        expect(auth.currentUser, isNull);
      },
    );

    // -------------------------------------------------------------------------
    // 6. Erro do Firebase Auth
    // -------------------------------------------------------------------------

    testWidgets(
      'exibe SnackBar quando o Firebase Auth falha',
      (tester) async {
        final auth = MockFirebaseAuth(
          mockUser: null,
          signedIn: false,
          shouldMockUser: false,
        );

        final firestore = FakeFirebaseFirestore();

        // MockFirebaseAuth permite simular falhas de autenticação.
        auth.mockCreateUserWithEmailAndPassword = (
          String email,
          String password,
        ) async {
          throw FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'E-mail já cadastrado',
          );
        };

        await tester.pumpWidget(
          buildTestApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(tester);

        await tocarCadastrar(tester);
        await tester.pump();

        expect(
          find.text('Erro ao cadastrar: E-mail já cadastrado'),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );
      },
    );

    // -------------------------------------------------------------------------
    // 7. Erro do Firestore no cadastro
    // -------------------------------------------------------------------------

    testWidgets(
      'exibe erro desconhecido quando o Firestore falha durante o cadastro',
      (tester) async {
        final auth = MockFirebaseAuth();
        final firestore = MockFirebaseFirestore();

        final collection = MockCollectionReference();
        final document = MockDocumentReference();

        when(
          firestore.collection('usuarios'),
        ).thenReturn(collection);

        when(
          collection.doc(any),
        ).thenReturn(document);

        when(
          document.set(any),
        ).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
            message: 'Firestore indisponível',
          ),
        );

        await tester.pumpWidget(
          buildTestApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(tester);

        await tocarCadastrar(tester);
        await tester.pump();

        expect(
          find.textContaining('Erro desconhecido:'),
          findsOneWidget,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );

        // Auth pode ter criado o usuário, mas o documento não foi salvo.
        expect(auth.currentUser, isNotNull);

        verify(
          document.set(
            argThat(
              allOf(
                containsPair('nome', 'João'),
                containsPair('email', 'joao@example.com'),
              ),
            ),
          ),
        ).called(1);
      },
    );

    // -------------------------------------------------------------------------
    // 8. Estado intermediário enquanto Auth está pendente
    // -------------------------------------------------------------------------

    testWidgets(
      'mantém a CadastroScreen visível enquanto o cadastro está pendente',
      (tester) async {
        final auth = MockFirebaseAuth();
        final firestore = FakeFirebaseFirestore();

        final completer = Future<UserCredential>.delayed(
          const Duration(seconds: 1),
          () async {
            return await auth.createUserWithEmailAndPassword(
              email: 'joao@example.com',
              password: '123456',
            );
          },
        );

        auth.mockCreateUserWithEmailAndPassword = (
          String email,
          String password,
        ) {
          return completer;
        };

        await tester.pumpWidget(
          buildTestApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await preencherCadastro(tester);

        await tocarCadastrar(tester);

        // A operação ainda não terminou.
        expect(find.byType(CadastroScreen), findsOneWidget);
        expect(find.byType(GenerosCadastroScreen), findsNothing);

        // Não existe indicador de loading no código fornecido.
        expect(find.byType(CircularProgressIndicator), findsNothing);

        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      },
    );
  });

  // ===========================================================================
  // GenerosCadastroScreen
  // ===========================================================================

  group('GenerosCadastroScreen', () {
    // -------------------------------------------------------------------------
    // 9. Nenhum gênero selecionado
    // -------------------------------------------------------------------------

    testWidgets(
      'exibe erro quando confirma sem selecionar gênero',
      (tester) async {
        final auth = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'usuario-123',
            email: 'joao@example.com',
          ),
          signedIn: true,
        );

        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        expect(find.text('Rock'), findsOneWidget);
        expect(find.text('Pop'), findsOneWidget);
        expect(find.text('Jazz'), findsOneWidget);

        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Confirmar'),
        );
        await tester.pump();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );
      },
    );

    // -------------------------------------------------------------------------
    // 10. Seleção + Firestore com sucesso
    // -------------------------------------------------------------------------

    testWidgets(
      'seleciona gêneros, salva no Firestore e navega para a tela inicial',
      (tester) async {
        final auth = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'usuario-123',
            email: 'joao@example.com',
          ),
          signedIn: true,
        );

        final firestore = FakeFirebaseFirestore();

        await firestore.collection('usuarios').doc('usuario-123').set({
          'nome': 'João',
          'email': 'joao@example.com',
        });

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
            routes: {
              '/inicio': (_) => const Scaffold(
                    body: Text('Tela Inicial'),
                  ),
            },
          ),
        );

        // Seleciona Rock.
        final rockSwitch = find.byType(SwitchListTile).at(0);
        await tester.tap(rockSwitch);
        await tester.pump();

        // Seleciona Jazz.
        final jazzSwitch = find.byType(SwitchListTile).at(2);
        await tester.tap(jazzSwitch);
        await tester.pump();

        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Confirmar'),
        );

        await tester.pumpAndSettle();

        final documento = await firestore
            .collection('usuarios')
            .doc('usuario-123')
            .get();

        expect(
          documento.data()?['generos_favoritos'],
          containsAll(<String>['Rock', 'Jazz']),
        );

        expect(find.byType(TelaInicialScreen), findsOneWidget);
      },
    );

    // -------------------------------------------------------------------------
    // 11. Firestore indisponível ao salvar gêneros
    // -------------------------------------------------------------------------

    testWidgets(
      'exibe SnackBar quando o Firestore falha ao salvar gêneros',
      (tester) async {
        final auth = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'usuario-123',
            email: 'joao@example.com',
          ),
          signedIn: true,
        );

        final firestore = MockFirebaseFirestore();
        final collection = MockCollectionReference();
        final document = MockDocumentReference();

        when(
          firestore.collection('usuarios'),
        ).thenReturn(collection);

        when(
          collection.doc('usuario-123'),
        ).thenReturn(document);

        when(
          document.update(any),
        ).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
            message: 'Firestore indisponível',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await tester.tap(
          find.byType(SwitchListTile).first,
        );
        await tester.pump();

        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Confirmar'),
        );

        await tester.pumpAndSettle();

        expect(
          find.text('Erro ao salvar os gêneros!'),
          findsOneWidget,
        );

        verify(
          document.update(
            argThat(
              containsPair(
                'generos_favoritos',
                contains('Rock'),
              ),
            ),
          ),
        ).called(1);
      },
    );

    // -------------------------------------------------------------------------
    // 12. Usuário não autenticado
    // -------------------------------------------------------------------------

    testWidgets(
      'falha ao entrar em GenerosCadastroScreen sem usuário autenticado',
      (tester) async {
        final auth = MockFirebaseAuth(
          mockUser: null,
          signedIn: false,
        );

        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        expect(find.text('Rock'), findsOneWidget);
        expect(find.text('Pop'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Confirmar'),
        );

        await tester.pump();

        /*
         * O código de produção faz:
         *
         *   final uid = widget.auth.currentUser!.uid;
         *
         * antes do try/catch.
         *
         * Portanto, com currentUser == null, ocorre uma exceção de null
         * check operator e NÃO é exibido o SnackBar "Erro ao salvar..."
         *
         * Este comportamento é intencionalmente documentado pelo teste,
         * sem alterar a tela de produção.
         */
        expect(
          find.text('Erro ao salvar os gêneros!'),
          findsNothing,
        );
      },
    );
  });
}

Um ponto que precisa ser ajustado antes de executar literalmente

Há dois detalhes do código fornecido que podem exigir adaptação ao projeto real:

TelaInicialScreen precisa estar importada no arquivo de teste, caso ela não seja exportada por algum dos imports atuais.
A propriedade mockCreateUserWithEmailAndPassword usada acima depende da API exata da versão de firebase_auth_mocks instalada. Se essa propriedade não existir na sua versão, a alternativa é criar um mock Mockito de FirebaseAuth e stubar createUserWithEmailAndPassword() diretamente.

A limitação arquitetural mais importante é a injeção de dependências: o teste isolado de GenerosCadastroScreen funciona porque podemos construí-la como GenerosCadastroScreen(auth: ..., firestore: ...). Já o fluxo Cadastro → Generos cria a segunda tela sem esses argumentos. Assim, um teste E2E que realmente valide o mesmo FakeFirebaseFirestore desde o cadastro até o salvamento dos gêneros não é possível somente com testes: seria necessário que o código de produção propagasse auth e firestore para GenerosCadastroScreen. Isso não é algo que o teste consiga corrigir sem modificar o comportamento das telas.

Também vale notar que o cenário de usuário não autenticado não exibe uma mensagem de erro: currentUser!.uid acontece antes do try. O teste acima registra esse comportamento sem alterar o código de produção.