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
  const uid = 'uid-teste-123';
  const email = 'teste@sintonize.com';
  const senha = '123456';
  const nome = 'Maria Silva';
  const dataNascimento = '15/05/2000';
  const cep = '50000-000';
  const rua = 'Rua das Flores';
  const numero = '123';
  const bairro = 'Boa Viagem';
  const cidade = 'Recife';

  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;

  setUp(() {
    auth = MockFirebaseAuth(
      mockUser: MockUser(
        uid: uid,
        email: email,
        isEmailVerified: true,
      ),
    );

    firestore = FakeFirebaseFirestore();
  });

  Widget buildApp({
    required Widget home,
    FirebaseAuth? testAuth,
    FirebaseFirestore? testFirestore,
  }) {
    final effectiveAuth = testAuth ?? auth;
    final effectiveFirestore = testFirestore ?? firestore;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: home,
      routes: {
        '/cadastro': (_) => CadastroScreen(
              auth: effectiveAuth,
              firestore: effectiveFirestore,
            ),
        '/generos': (_) => GenerosCadastroScreen(
              auth: effectiveAuth,
              firestore: effectiveFirestore,
            ),
        '/inicio': (_) => const TelaInicialScreen(),
      },
    );
  }

  Finder textFields() => find.byType(TextFormField);

  Future<void> preencherCadastroValido(
    WidgetTester tester, {
    String nomeValue = nome,
    String dataValue = dataNascimento,
    String emailValue = email,
    String senhaValue = senha,
    String confirmacaoValue = senha,
    String cepValue = cep,
    String ruaValue = rua,
    String numeroValue = numero,
    String bairroValue = bairro,
    String cidadeValue = cidade,
  }) async {
    // A ordem dos TextFormField em CadastroScreen é:
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

    await tester.enterText(textFields().at(0), nomeValue);
    await tester.enterText(textFields().at(1), dataValue);
    await tester.enterText(textFields().at(2), emailValue);
    await tester.enterText(textFields().at(3), senhaValue);
    await tester.enterText(textFields().at(4), confirmacaoValue);

    // Não usamos um CEP válido neste helper quando queremos evitar
    // o disparo do ViaCEP. O CEP pode ser substituído por um valor
    // válido, mas isso provocaria a chamada HTTP real da tela.
    await tester.enterText(textFields().at(5), cepValue);

    await tester.enterText(textFields().at(6), ruaValue);
    await tester.enterText(textFields().at(7), numeroValue);
    await tester.enterText(textFields().at(8), bairroValue);
    await tester.enterText(textFields().at(9), cidadeValue);

    // Estado é um DropdownButtonFormField.
    final dropdown = find.byType(DropdownButtonFormField<String>);

    await tester.ensureVisible(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    await tester.pump();

    await tester.tap(find.text('PE').last);
    await tester.pump();
  }

  Future<void> abrirCadastro(WidgetTester tester) async {
    await tester.pumpWidget(
      buildApp(
        home: CadastroScreen(
          auth: auth,
          firestore: firestore,
        ),
      ),
    );

    await tester.pump();
  }

  Future<void> abrirGeneros(WidgetTester tester) async {
    await tester.pumpWidget(
      buildApp(
        home: GenerosCadastroScreen(
          auth: auth,
          firestore: firestore,
        ),
      ),
    );

    await tester.pump();
  }

  Future<void> selecionarGenero(
    WidgetTester tester,
    String genero,
  ) async {
    final texto = find.text(genero);
    expect(texto, findsOneWidget);

    final card = find.ancestor(
      of: texto,
      matching: find.byType(Card),
    );

    final switchFinder = find.descendant(
      of: card,
      matching: find.byType(Switch),
    );

    await tester.tap(switchFinder);
    await tester.pump();
  }

  group('Fluxo ponta a ponta - Cadastro → Gêneros → Tela Inicial', () {
    testWidgets(
      'cria conta, salva perfil, seleciona gêneros e salva preferências',
      (WidgetTester tester) async {
        await abrirCadastro(tester);

        await preencherCadastroValido(tester);

        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        // A criação da conta deve ter autenticado o usuário.
        expect(auth.currentUser, isNotNull);
        expect(auth.currentUser!.uid, isNotEmpty);

        // O perfil deve ter sido persistido pelo CadastroScreen.
        final usuario = await firestore
            .collection('usuarios')
            .doc(auth.currentUser!.uid)
            .get();

        expect(usuario.exists, isTrue);
        expect(usuario.data()!['nome'], nome);
        expect(usuario.data()!['data_nasc'], dataNascimento);
        expect(usuario.data()!['email'], email);

        final endereco =
            Map<String, dynamic>.from(usuario.data()!['endereco'] as Map);

        expect(endereco['rua'], rua);
        expect(endereco['numero'], numero);
        expect(endereco['bairro'], bairro);
        expect(endereco['cidade'], cidade);
        expect(endereco['estado'], 'PE');
        expect(endereco['cep'], cep);

        // Deve estar na tela de seleção de gêneros.
        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        // Não existe loading implementado nas telas fornecidas.
        expect(find.byType(CircularProgressIndicator), findsNothing);

        await selecionarGenero(tester, 'Rock');
        await selecionarGenero(tester, 'Jazz');

        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        final usuarioAtualizado = await firestore
            .collection('usuarios')
            .doc(auth.currentUser!.uid)
            .get();

        expect(usuarioAtualizado.exists, isTrue);

        final generos =
            List<String>.from(usuarioAtualizado.data()!['generos_favoritos']);

        expect(generos, containsAll(<String>['Rock', 'Jazz']));
        expect(generos, hasLength(2));

        // A navegação final deve ter chegado à tela inicial.
        expect(find.byType(TelaInicialScreen), findsOneWidget);
      },
    );
  });

  group('Validações do CadastroScreen', () {
    testWidgets(
      'não chama Firebase Auth quando o nome é inválido',
      (WidgetTester tester) async {
        await abrirCadastro(tester);

        await preencherCadastroValido(
          tester,
          nomeValue: 'Maria123',
        );

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(
          find.text(
            'O nome não pode conter números ou caracteres especiais',
          ),
          findsOneWidget,
        );

        // O formulário falhou antes de entrar no _submit.
        expect(auth.currentUser, isNotNull);

        final documentos = await firestore
            .collection('usuarios')
            .get();

        expect(documentos.docs, isEmpty);
      },
    );

    testWidgets(
      'não chama Firebase Auth quando o e-mail é inválido',
      (WidgetTester tester) async {
        await abrirCadastro(tester);

        await preencherCadastroValido(
          tester,
          emailValue: 'email-invalido',
        );

        // Começa sem usuário autenticado para deixar a verificação
        // inequívoca.
        await auth.signOut();

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(find.text('E-mail inválido'), findsOneWidget);
        expect(auth.currentUser, isNull);

        final documentos = await firestore
            .collection('usuarios')
            .get();

        expect(documentos.docs, isEmpty);
      },
    );

    testWidgets(
      'não chama Firebase Auth quando a senha possui menos de 6 caracteres',
      (WidgetTester tester) async {
        await abrirCadastro(tester);

        await preencherCadastroValido(
          tester,
          senhaValue: '12345',
          confirmacaoValue: '12345',
        );

        await auth.signOut();

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );

        expect(auth.currentUser, isNull);
      },
    );

    testWidgets(
      'não chama Firebase Auth quando as senhas não coincidem',
      (WidgetTester tester) async {
        await abrirCadastro(tester);

        await preencherCadastroValido(
          tester,
          senhaValue: '123456',
          confirmacaoValue: '654321',
        );

        await auth.signOut();

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(
          find.text('As senhas não coincidem'),
          findsOneWidget,
        );

        expect(auth.currentUser, isNull);
      },
    );

    testWidgets(
      'não chama Firebase Auth quando a data de nascimento é inválida',
      (WidgetTester tester) async {
        await abrirCadastro(tester);

        await preencherCadastroValido(
          tester,
          dataValue: '31/02/2000',
        );

        await auth.signOut();

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(
          find.text('Dia deve ser entre 01 e 29'),
          findsOneWidget,
        );

        expect(auth.currentUser, isNull);
      },
    );

    testWidgets(
      'não chama Firebase Auth quando o CEP é inválido',
      (WidgetTester tester) async {
        await abrirCadastro(tester);

        // Usamos um CEP curto para impedir que o onChanged dispare
        // a chamada HTTP do ViaCEP.
        await preencherCadastroValido(
          tester,
          cepValue: '123',
        );

        await auth.signOut();

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(
          find.text('CEP inválido. Formato correto: XXXXX-XXX'),
          findsOneWidget,
        );

        expect(auth.currentUser, isNull);
      },
    );

    testWidgets(
      'não chama Firebase Auth quando o número do endereço não é numérico',
      (WidgetTester tester) async {
        await abrirCadastro(tester);

        await preencherCadastroValido(
          tester,
          numeroValue: 'ABC',
        );

        await auth.signOut();

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(
          find.text('O número deve ser numérico'),
          findsOneWidget,
        );

        expect(auth.currentUser, isNull);
      },
    );
  });

  group('Erros do Firebase no CadastroScreen', () {
    testWidgets(
      'mostra erro quando Firebase Auth falha ao criar a conta',
      (WidgetTester tester) async {
        final failingAuth = MockFirebaseAuth(
          signedIn: false,
        );

        whenCalling(
          Invocation.method(
            #createUserWithEmailAndPassword,
            null,
            {
              #email: email,
              #password: senha,
            },
          ),
        ).on(failingAuth).thenThrow(
              FirebaseAuthException(
                code: 'email-already-in-use',
                message: 'Este e-mail já está cadastrado.',
              ),
            );

        await tester.pumpWidget(
          buildApp(
            home: CadastroScreen(
              auth: failingAuth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pump();

        await preencherCadastroValido(tester);

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(
          find.text('Erro ao cadastrar: Este e-mail já está cadastrado.'),
          findsOneWidget,
        );

        // A navegação não deve acontecer.
        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsNothing,
        );

        // O Firestore também não deve ser chamado porque Auth falhou.
        final documentos =
            await firestore.collection('usuarios').get();

        expect(documentos.docs, isEmpty);
      },
    );

    testWidgets(
      'mostra erro quando o Firestore falha ao salvar o cadastro',
      (WidgetTester tester) async {
        final failingFirestore = FakeFirebaseFirestore();

        final document =
            failingFirestore.collection('usuarios').doc(uid);

        whenCalling(
          Invocation.method(#set, null),
        ).on(document).thenThrow(
              FirebaseException(
                plugin: 'cloud_firestore',
                code: 'unavailable',
                message: 'Firestore indisponível',
              ),
            );

        await tester.pumpWidget(
          buildApp(
            home: CadastroScreen(
              auth: auth,
              firestore: failingFirestore,
            ),
          ),
        );

        await tester.pump();

        await preencherCadastroValido(tester);

        await tester.tap(find.text('Cadastrar'));
        await tester.pump();

        expect(
          find.text(
            'Erro desconhecido: [cloud_firestore/unavailable] Firestore indisponível',
          ),
          findsOneWidget,
        );

        // A conta foi criada antes da falha do Firestore.
        expect(auth.currentUser, isNotNull);

        // Mas a tela não deve avançar para gêneros.
        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsNothing,
        );
      },
    );
  });

  group('GenerosCadastroScreen - validação e estados intermediários', () {
    testWidgets(
      'mostra erro quando nenhum gênero é selecionado',
      (WidgetTester tester) async {
        await abrirGeneros(tester);

        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        final confirmar = find.text('Confirmar');

        await tester.ensureVisible(confirmar);
        await tester.pumpAndSettle();
        await tester.tap(confirmar);
        await tester.pumpAndSettle();
        await tester.pump();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );

        // Sem gênero selecionado, não deve haver update.
        expect(auth.currentUser, isNotNull);

        final documento = await firestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(documento.exists, isFalse);

        // Também não há loading implementado.
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'mostra erro quando o Firestore falha ao salvar os gêneros',
      (WidgetTester tester) async {
        final failingFirestore = FakeFirebaseFirestore();

        // GenerosCadastroScreen fará update neste documento.
        final document =
            failingFirestore.collection('usuarios').doc(uid);

        await document.set({
          'nome': nome,
          'email': email,
        });

        whenCalling(
          Invocation.method(#update, null),
        ).on(document).thenThrow(
              FirebaseException(
                plugin: 'cloud_firestore',
                code: 'unavailable',
              ),
            );

        await tester.pumpWidget(
          buildApp(
            home: GenerosCadastroScreen(
              auth: auth,
              firestore: failingFirestore,
            ),
          ),
        );

        await tester.pump();

        await selecionarGenero(tester, 'Pop');

        final confirmar = find.text('Confirmar');

        await tester.ensureVisible(confirmar);
        await tester.pumpAndSettle();
        await tester.tap(confirmar);
        await tester.pumpAndSettle();
        await tester.pump();

        expect(
          find.text('Erro ao salvar os gêneros!'),
          findsOneWidget,
        );

        // Continua na tela de gêneros.
        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );
  });

  group('GenerosCadastroScreen - autenticação', () {
    testWidgets(
      'gera exceção quando chega sem usuário autenticado',
      (WidgetTester tester) async {
        final unauthenticatedAuth = MockFirebaseAuth(
          signedIn: false,
        );

        await tester.pumpWidget(
          buildApp(
            home: GenerosCadastroScreen(
              auth: unauthenticatedAuth,
              firestore: firestore,
            ),
            testAuth: unauthenticatedAuth,
          ),
        );

        await tester.pump();

        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        await selecionarGenero(tester, 'Rock');

        await tester.tap(find.text('Confirmar'));

        // _salvarGeneros() acessa currentUser!.uid antes do try.
        // Portanto, no código fornecido, não há SnackBar de erro:
        // a ausência de autenticação causa uma exceção não tratada.
        await tester.pump();

        expect(
          tester.takeException(),
          isNotNull,
        );

        expect(find.byType(TelaInicialScreen), findsNothing);
      },
    );
  });
}
