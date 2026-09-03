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
      'fluxo completo: cadastro, seleção de gêneros e salvamento no Firestore',
      (tester) async {
        // O viewport padrão do flutter_test é 800x600.
        // As telas do fluxo são maiores que isso, portanto usamos um
        // viewport maior para que todos os elementos necessários estejam
        // acessíveis sem rolagem.
        await tester.binding.setSurfaceSize(
          const Size(800, 1400),
        );

        try {
          const nome = 'João da Silva';
          const email = 'user@test.com';
          const senha = 'senha123';

          await tester.pumpWidget(
            MaterialApp(
              home: CadastroScreen(
                auth: mockAuth,
                firestore: fakeFirestore,
              ),
            ),
          );

          await tester.pumpAndSettle();

          final campos = find.byType(TextFormField);

          expect(campos, findsNWidgets(4));

          // Preenche o formulário de cadastro.
          await tester.enterText(campos.at(0), nome);
          await tester.enterText(campos.at(1), email);
          await tester.enterText(campos.at(2), senha);
          await tester.enterText(campos.at(3), senha);

          // O botão agora está dentro do viewport ampliado.
          final botaoCadastrar = find.widgetWithText(
            ElevatedButton,
            'Cadastrar',
          );

          expect(botaoCadastrar, findsOneWidget);
          expect(
            tester.getCenter(botaoCadastrar).dy,
            lessThan(1400),
          );

          await tester.tap(botaoCadastrar);
          await tester.pumpAndSettle();

          // O cadastro deve navegar para a tela de gêneros.
          expect(
            find.byType(GenerosCadastroScreen),
            findsOneWidget,
          );

          // O usuário deve ter sido criado e autenticado.
          final usuario = mockAuth.currentUser;
          expect(usuario, isNotNull);

          final uid = usuario!.uid;

          // Verifica o documento criado pela CadastroScreen.
          final usuarioDoc = await fakeFirestore
              .collection('usuarios')
              .doc(uid)
              .get();

          expect(usuarioDoc.exists, isTrue);
          expect(usuarioDoc.data()?['nome'], nome);
          expect(usuarioDoc.data()?['email'], email);

          // Com o viewport ampliado, os sete itens do ListView.builder
          // ficam visíveis e são materializados.
          final switches = find.byType(Switch);

          expect(switches, findsNWidgets(7));

          // A ordem dos gêneros é:
          // 0 Rock
          // 1 Pop
          // 2 Jazz
          // 3 Blues
          // 4 Hip-Hop
          // 5 Reggae
          // 6 Country

          // Seleciona Rock.
          await tester.tap(switches.at(0));
          await tester.pump();

          // Seleciona Jazz.
          await tester.tap(switches.at(2));
          await tester.pump();

          // Confirma os gêneros.
          final botaoConfirmar = find.widgetWithText(
            ElevatedButton,
            'Confirmar',
          );

          expect(botaoConfirmar, findsOneWidget);

          await tester.tap(botaoConfirmar);
          await tester.pumpAndSettle();

          // O salvamento deve navegar para a tela inicial.
          expect(
            find.byType(TelaInicialScreen),
            findsOneWidget,
          );

          // Verifica diretamente o resultado persistido no Firestore.
          final documentoAtualizado = await fakeFirestore
              .collection('usuarios')
              .doc(uid)
              .get();

          expect(documentoAtualizado.exists, isTrue);

          final generosFavoritos =
              documentoAtualizado.data()?['generos_favoritos'];

          expect(generosFavoritos, isA<List>());

          expect(
            generosFavoritos,
            containsAll(<String>[
              'Rock',
              'Jazz',
            ]),
          );

          // Somente os dois gêneros selecionados devem ter sido salvos.
          expect(generosFavoritos, hasLength(2));

          expect(
            generosFavoritos,
            equals(<String>[
              'Rock',
              'Jazz',
            ]),
          );
        } finally {
          // Restaura o tamanho padrão do ambiente de teste.
          await tester.binding.setSurfaceSize(null);
        }
      },
    );

    testWidgets(
      'não permite confirmar sem selecionar um gênero',
      (tester) async {
        await tester.binding.setSurfaceSize(
          const Size(800, 1400),
        );

        try {
          const email = 'user@test.com';
          const senha = 'senha123';

          // Cria um usuário autenticado para que
          // GenerosCadastroScreen possa acessar currentUser!.uid.
          final credential =
              await mockAuth.createUserWithEmailAndPassword(
            email: email,
            password: senha,
          );

          final uid = credential.user!.uid;

          // Cria o documento que seria atualizado por
          // _salvarGeneros().
          await fakeFirestore
              .collection('usuarios')
              .doc(uid)
              .set({
            'nome': 'João da Silva',
            'email': email,
          });

          await tester.pumpWidget(
            MaterialApp(
              home: GenerosCadastroScreen(
                auth: mockAuth,
                firestore: fakeFirestore,
              ),
            ),
          );

          await tester.pumpAndSettle();

          // O viewport ampliado permite que o ListView.builder
          // materialize todos os sete gêneros.
          expect(
            find.byType(Switch),
            findsNWidgets(7),
          );

          // Confirma que os sete gêneros esperados estão presentes.
          for (final genero in <String>[
            'Rock',
            'Pop',
            'Jazz',
            'Blues',
            'Hip-Hop',
            'Reggae',
            'Country',
          ]) {
            expect(find.text(genero), findsOneWidget);
          }

          // Nenhum gênero foi selecionado.
          final botaoConfirmar = find.widgetWithText(
            ElevatedButton,
            'Confirmar',
          );

          expect(botaoConfirmar, findsOneWidget);

          await tester.tap(botaoConfirmar);
          await tester.pump();

          // A aplicação deve impedir o salvamento e mostrar a mensagem.
          expect(
            find.text('Selecione pelo menos um gênero musical!'),
            findsOneWidget,
          );

          // Deve continuar na tela de seleção de gêneros.
          expect(
            find.byType(GenerosCadastroScreen),
            findsOneWidget,
          );

          // Não deve navegar para a tela inicial.
          expect(
            find.byType(TelaInicialScreen),
            findsNothing,
          );

          // O campo generos_favoritos não deve ser criado, pois
          // _salvarGeneros() não deve ser chamado sem seleção.
          final documento = await fakeFirestore
              .collection('usuarios')
              .doc(uid)
              .get();

          expect(
            documento.data()?['generos_favoritos'],
            isNull,
          );
        } finally {
          await tester.binding.setSurfaceSize(null);
        }
      },
    );
  });
}
