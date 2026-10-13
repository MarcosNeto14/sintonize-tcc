import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

void main() {
  group('Fluxo de cadastro e seleção de gêneros', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: false);
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets(
      'fluxo completo: cadastro → gêneros → salva preferências',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        );

        final campos = find.byType(TextFormField);

        // ---------------------------------------------------------------
        // Preenchimento do cadastro
        // ---------------------------------------------------------------

        await tester.enterText(
          campos.at(0),
          'Joao da Silva',
        );

        await tester.enterText(
          campos.at(1),
          '01011990',
        );

        await tester.enterText(
          campos.at(2),
          'joao@test.com',
        );

        await tester.enterText(
          campos.at(3),
          'senha123',
        );

        await tester.enterText(
          campos.at(4),
          'senha123',
        );

        // O CEP precisa estar no formato XXXXX-XXX para passar
        // pela validação de _validateCEP().
        //
        // Não esperamos que o ViaCEP seja consultado com sucesso:
        // TestWidgetsFlutterBinding bloqueia requisições HTTP reais.
        await tester.enterText(
          campos.at(5),
          '50010000',
        );

        await tester.pump();

        // ---------------------------------------------------------------
        // Endereço
        // ---------------------------------------------------------------

        final camposEndereco = find.byType(TextFormField);

        expect(
          camposEndereco,
          findsNWidgets(10),
        );

        await tester.enterText(
          camposEndereco.at(6),
          'Rua das Flores',
        );

        await tester.enterText(
          camposEndereco.at(7),
          '123',
        );

        await tester.enterText(
          camposEndereco.at(8),
          'Centro',
        );

        await tester.enterText(
          camposEndereco.at(9),
          'Recife',
        );

        // ---------------------------------------------------------------
        // Estado
        // ---------------------------------------------------------------

        final dropdown = find.byType(
          DropdownButtonFormField<String>,
        );

        expect(dropdown, findsOneWidget);

        await tester.ensureVisible(dropdown);
        await tester.pumpAndSettle();

        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        // O menu contém os estados definidos em _estados.
        //
        // Em vez de depender do texto "PE" antes do menu ser aberto,
        // procuramos o DropdownMenuItem cujo value é "PE".
        final itemPE = find.byWidgetPredicate(
          (widget) =>
              widget is DropdownMenuItem<String> &&
              widget.value == 'PE',
        );

        expect(itemPE, findsOneWidget);

        await tester.tap(itemPE);
        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // Cadastro
        // ---------------------------------------------------------------

        final cadastrar = find.text('Cadastrar');

        expect(cadastrar, findsOneWidget);

        await tester.ensureVisible(cadastrar);
        await tester.pumpAndSettle();

        await tester.tap(cadastrar);
        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // GenerosCadastroScreen
        // ---------------------------------------------------------------

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        // ---------------------------------------------------------------
        // Firebase Auth
        // ---------------------------------------------------------------

        final usuario = mockAuth.currentUser;

        expect(usuario, isNotNull);

        final uid = usuario!.uid;

        // ---------------------------------------------------------------
        // Documento criado durante o cadastro
        // ---------------------------------------------------------------

        final documentoInicial = await fakeFirestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(documentoInicial.exists, isTrue);

        final dadosIniciais = documentoInicial.data()!;

        expect(
          dadosIniciais['nome'],
          'Joao da Silva',
        );

        expect(
          dadosIniciais['data_nasc'],
          '01/01/1990',
        );

        expect(
          dadosIniciais['email'],
          'joao@test.com',
        );

        expect(
          dadosIniciais['endereco']['rua'],
          'Rua das Flores',
        );

        expect(
          dadosIniciais['endereco']['numero'],
          '123',
        );

        expect(
          dadosIniciais['endereco']['bairro'],
          'Centro',
        );

        expect(
          dadosIniciais['endereco']['cidade'],
          'Recife',
        );

        expect(
          dadosIniciais['endereco']['estado'],
          'PE',
        );

        // ---------------------------------------------------------------
        // Seleção dos gêneros
        // ---------------------------------------------------------------

        final switches = find.byType(Switch);

        expect(
          switches,
          findsNWidgets(7),
        );

        // Rock
        await tester.ensureVisible(switches.at(0));
        await tester.tap(switches.at(0));
        await tester.pump();

        // Jazz
        await tester.ensureVisible(switches.at(2));
        await tester.tap(switches.at(2));
        await tester.pump();

        // ---------------------------------------------------------------
        // Confirmar
        // ---------------------------------------------------------------

        final confirmar = find.text('Confirmar');

        expect(confirmar, findsOneWidget);

        await tester.ensureVisible(confirmar);
        await tester.pumpAndSettle();

        await tester.tap(confirmar);
        await tester.pumpAndSettle();

        // ---------------------------------------------------------------
        // Verifica gêneros no Firestore
        // ---------------------------------------------------------------

        final documentoAtualizado = await fakeFirestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(documentoAtualizado.exists, isTrue);

        final dadosAtualizados = documentoAtualizado.data()!;

        expect(
          dadosAtualizados['generos_favoritos'],
          containsAll(<String>[
            'Rock',
            'Jazz',
          ]),
        );

        expect(
          (dadosAtualizados['generos_favoritos'] as List).length,
          2,
        );
      },
    );

    testWidgets(
      'exibe mensagem quando nenhum gênero é selecionado',
      (tester) async {
        await mockAuth.createUserWithEmailAndPassword(
          email: 'generos@test.com',
          password: 'senha123',
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

        final switches = tester.widgetList<Switch>(
          find.byType(Switch),
        );

        expect(
          switches.every(
            (switchWidget) => switchWidget.value == false,
          ),
          isTrue,
        );

        final confirmar = find.text('Confirmar');

        expect(confirmar, findsOneWidget);

        await tester.ensureVisible(confirmar);
        await tester.pumpAndSettle();

        await tester.tap(confirmar);
        await tester.pump();

        expect(
          find.text(
            'Selecione pelo menos um gênero musical!',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
