import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;

  setUp(() {
    auth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
  });

  Widget buildTestApp({
    required Widget home,
  }) {
    return MaterialApp(
      home: home,
      routes: {
        '/cadastro': (_) => CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
        '/generos': (_) => GenerosCadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
        '/inicio': (_) => const TelaInicialScreen(),
      },
    );
  }

  Future<void> tapAndSettle(
    WidgetTester tester,
    Finder finder,
  ) async {
    expect(finder, findsOneWidget);

    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();

    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> selecionarEstado(
    WidgetTester tester,
    String estado,
  ) async {
    final dropdown = find.byType(
      DropdownButtonFormField<String>,
    );

    expect(dropdown, findsOneWidget);

    await tester.ensureVisible(dropdown);
    await tester.pumpAndSettle();

    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    final item = find.text(estado);

    // O menu do DropdownButton é exibido em um Overlay. Portanto,
    // o item pode não estar na viewport inicialmente.
    //
    // Procuramos os Scrollables disponíveis depois da abertura do menu
    // e tentamos tornar o item visível em cada um deles.
    if (item.evaluate().isEmpty) {
      final scrollables = find.byType(Scrollable);

      for (final element in scrollables.evaluate()) {
        final scrollableFinder = find.byWidget(
          element.widget,
        );

        try {
          await tester.scrollUntilVisible(
            item,
            250,
            scrollable: scrollableFinder,
          );
        } catch (_) {
          // Esse Scrollable pode ser o scroll da tela principal,
          // e não o scroll interno do menu. Tentamos o próximo.
        }

        if (item.evaluate().isNotEmpty) {
          break;
        }
      }
    }

    // Algumas versões do Flutter deixam todos os itens do Dropdown
    // disponíveis na árvore mesmo quando somente parte deles está
    // visível. Nesse caso, scrollUntilVisible acima já resolveu.
    expect(
      item,
      findsAtLeastNWidgets(1),
    );

    await tester.tap(item.last);
    await tester.pumpAndSettle();
  }

  Future<void> preencherCadastroValido(
    WidgetTester tester, {
    String email = 'joao@example.com',
  }) async {
    final campos = find.byType(TextFormField);

    await tester.enterText(
      campos.at(0),
      'João da Silva',
    );

    await tester.enterText(
      campos.at(1),
      '01/01/1990',
    );

    await tester.enterText(
      campos.at(2),
      email,
    );

    await tester.enterText(
      campos.at(3),
      '123456',
    );

    await tester.enterText(
      campos.at(4),
      '123456',
    );

    // O formatter da tela transforma os oito dígitos em 50000-000.
    // Não aguardamos o ViaCEP; os dados do endereço são preenchidos
    // manualmente para manter o teste independente de rede.
    await tester.enterText(
      campos.at(5),
      '50000000',
    );

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
      'Boa Vista',
    );

    await tester.enterText(
      campos.at(9),
      'Recife',
    );

    await selecionarEstado(
      tester,
      'PE',
    );
  }

  Future<void> abrirGenerosComUsuarioAutenticado(
    WidgetTester tester,
  ) async {
    auth = MockFirebaseAuth(
      mockUser: MockUser(
        uid: 'usuario-generos',
        email: 'usuario@example.com',
      ),
    );

    await tester.pumpWidget(
      buildTestApp(
        home: GenerosCadastroScreen(
          auth: auth,
          firestore: firestore,
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

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

  Future<void> selecionarGenero(
    WidgetTester tester,
    String genero,
  ) async {
    final finder = switchDoGenero(genero);

    expect(
      finder,
      findsOneWidget,
    );

    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();

    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  group('CadastroScreen - validação local', () {
    testWidgets(
      'não chama Firebase quando campos obrigatórios estão vazios',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await tapAndSettle(
          tester,
          find.text('Cadastrar'),
        );

        expect(
          find.text('O nome é obrigatório'),
          findsOneWidget,
        );

        expect(
          find.text('A data de nascimento é obrigatória'),
          findsOneWidget,
        );

        expect(
          find.text('O e-mail é obrigatório'),
          findsOneWidget,
        );

        expect(
          find.text('A senha é obrigatória'),
          findsOneWidget,
        );

        expect(
          find.text('O CEP é obrigatório'),
          findsOneWidget,
        );

        expect(
          find.text('O número é obrigatório'),
          findsOneWidget,
        );

        expect(
          auth.currentUser,
          isNull,
        );

        final usuarios =
            await firestore.collection('usuarios').get();

        expect(
          usuarios.docs,
          isEmpty,
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'não chama Firebase quando o e-mail é inválido',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(
          campos.at(0),
          'João da Silva',
        );
        await tester.enterText(
          campos.at(1),
          '01/01/1990',
        );
        await tester.enterText(
          campos.at(2),
          'email-invalido',
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
          '50000000',
        );
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
          'Boa Vista',
        );
        await tester.enterText(
          campos.at(9),
          'Recife',
        );

        await tapAndSettle(
          tester,
          find.text('Cadastrar'),
        );

        expect(
          find.text('E-mail inválido'),
          findsOneWidget,
        );

        expect(
          auth.currentUser,
          isNull,
        );

        final usuarios =
            await firestore.collection('usuarios').get();

        expect(
          usuarios.docs,
          isEmpty,
        );
      },
    );

    testWidgets(
      'não chama Firebase quando a data de nascimento é inválida',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(
          campos.at(0),
          'João da Silva',
        );
        await tester.enterText(
          campos.at(1),
          '31/02/1990',
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
          '50000000',
        );
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
          'Boa Vista',
        );
        await tester.enterText(
          campos.at(9),
          'Recife',
        );

        await tapAndSettle(
          tester,
          find.text('Cadastrar'),
        );

        expect(
          find.text('Dia deve ser entre 01 e 28'),
          findsOneWidget,
        );

        expect(
          auth.currentUser,
          isNull,
        );

        final usuarios =
            await firestore.collection('usuarios').get();

        expect(
          usuarios.docs,
          isEmpty,
        );
      },
    );

    testWidgets(
      'não chama Firebase quando a senha tem menos de seis caracteres',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(
          campos.at(0),
          'João da Silva',
        );
        await tester.enterText(
          campos.at(1),
          '01/01/1990',
        );
        await tester.enterText(
          campos.at(2),
          'joao@example.com',
        );
        await tester.enterText(
          campos.at(3),
          '12345',
        );
        await tester.enterText(
          campos.at(4),
          '12345',
        );
        await tester.enterText(
          campos.at(5),
          '50000000',
        );
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
          'Boa Vista',
        );
        await tester.enterText(
          campos.at(9),
          'Recife',
        );

        await tapAndSettle(
          tester,
          find.text('Cadastrar'),
        );

        expect(
          find.text(
            'A senha deve ter pelo menos 6 caracteres',
          ),
          findsOneWidget,
        );

        expect(
          auth.currentUser,
          isNull,
        );

        final usuarios =
            await firestore.collection('usuarios').get();

        expect(
          usuarios.docs,
          isEmpty,
        );
      },
    );

    testWidgets(
      'não chama Firebase quando as senhas não coincidem',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(
          campos.at(0),
          'João da Silva',
        );
        await tester.enterText(
          campos.at(1),
          '01/01/1990',
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
          '654321',
        );
        await tester.enterText(
          campos.at(5),
          '50000000',
        );
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
          'Boa Vista',
        );
        await tester.enterText(
          campos.at(9),
          'Recife',
        );

        await tapAndSettle(
          tester,
          find.text('Cadastrar'),
        );

        expect(
          find.text('As senhas não coincidem'),
          findsOneWidget,
        );

        expect(
          auth.currentUser,
          isNull,
        );

        final usuarios =
            await firestore.collection('usuarios').get();

        expect(
          usuarios.docs,
          isEmpty,
        );
      },
    );

    testWidgets(
      'não chama Firebase quando o CEP é inválido',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(
          campos.at(0),
          'João da Silva',
        );
        await tester.enterText(
          campos.at(1),
          '01/01/1990',
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
          '1234567',
        );
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
          'Boa Vista',
        );
        await tester.enterText(
          campos.at(9),
          'Recife',
        );

        await tapAndSettle(
          tester,
          find.text('Cadastrar'),
        );

        expect(
          find.text(
            'CEP inválido. Formato correto: XXXXX-XXX',
          ),
          findsOneWidget,
        );

        expect(
          auth.currentUser,
          isNull,
        );

        final usuarios =
            await firestore.collection('usuarios').get();

        expect(
          usuarios.docs,
          isEmpty,
        );
      },
    );

    testWidgets(
      'não chama Firebase quando o número do endereço não é numérico',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        final campos = find.byType(TextFormField);

        await tester.enterText(
          campos.at(0),
          'João da Silva',
        );
        await tester.enterText(
          campos.at(1),
          '01/01/1990',
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
          '50000000',
        );
        await tester.enterText(
          campos.at(6),
          'Rua das Flores',
        );
        await tester.enterText(
          campos.at(7),
          'abc',
        );
        await tester.enterText(
          campos.at(8),
          'Boa Vista',
        );
        await tester.enterText(
          campos.at(9),
          'Recife',
        );

        await tapAndSettle(
          tester,
          find.text('Cadastrar'),
        );

        expect(
          find.text('O número deve ser numérico'),
          findsOneWidget,
        );

        expect(
          auth.currentUser,
          isNull,
        );

        final usuarios =
            await firestore.collection('usuarios').get();

        expect(
          usuarios.docs,
          isEmpty,
        );
      },
    );
  });

  group('Fluxo ponta a ponta', () {
    testWidgets(
      'cria conta, salva usuário, navega para gêneros, salva gêneros e vai para tela inicial',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            home: CadastroScreen(
              auth: auth,
              firestore: firestore,
            ),
          ),
        );

        await preencherCadastroValido(tester);

        await tapAndSettle(
          tester,
          find.text('Cadastrar'),
        );

        expect(
          auth.currentUser,
          isNotNull,
        );

        final uid = auth.currentUser!.uid;

        final usuarioSnapshot =
            await firestore.collection('usuarios').doc(uid).get();

        expect(
          usuarioSnapshot.exists,
          isTrue,
        );

        final dados = usuarioSnapshot.data()!;

        expect(
          dados['nome'],
          'João da Silva',
        );

        expect(
          dados['data_nasc'],
          '01/01/1990',
        );

        expect(
          dados['email'],
          'joao@example.com',
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
          'Boa Vista',
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

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        await selecionarGenero(
          tester,
          'Rock',
        );

        await selecionarGenero(
          tester,
          'Jazz',
        );

        await tapAndSettle(
          tester,
          find.text('Confirmar'),
        );

        final atualizado =
            await firestore.collection('usuarios').doc(uid).get();

        expect(
          atualizado.exists,
          isTrue,
        );

        final generos =
            atualizado.data()!['generos_favoritos']
                as List<dynamic>;

        expect(
          generos,
          containsAll(<String>[
            'Rock',
            'Jazz',
          ]),
        );

        expect(
          generos,
          hasLength(2),
        );

        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );
      },
    );
  });

  group('GenerosCadastroScreen - validação', () {
    testWidgets(
      'mostra erro ao confirmar sem selecionar nenhum gênero',
      (tester) async {
        await abrirGenerosComUsuarioAutenticado(tester);

        await tapAndSettle(
          tester,
          find.text('Confirmar'),
        );

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
      },
    );
  });

  group('GenerosCadastroScreen - autenticação', () {
    testWidgets(
      'não salva e permanece na tela quando não há usuário autenticado',
      (tester) async {
        final unauthenticatedAuth = MockFirebaseAuth();
        final firestoreForTest = FakeFirebaseFirestore();

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: unauthenticatedAuth,
              firestore: firestoreForTest,
            ),
          ),
        );

        await tester.pumpAndSettle();

        await selecionarGenero(
          tester,
          'Rock',
        );

        await tapAndSettle(
          tester,
          find.text('Confirmar'),
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );

        final usuarios =
            await firestoreForTest.collection('usuarios').get();

        expect(
          usuarios.docs,
          isEmpty,
        );

        expect(
          find.text('Erro ao salvar os gêneros!'),
          findsNothing,
        );

        expect(
          find.text(
            'Selecione pelo menos um gênero musical!',
          ),
          findsNothing,
        );
      },
    );
  });
}
