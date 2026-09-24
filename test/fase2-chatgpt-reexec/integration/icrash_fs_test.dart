import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

void main() {
  group('Fluxo de Cadastro e seleção de gêneros', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: false);
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets(
      'fluxo completo: cadastro, seleção de gêneros e salvamento no Firestore',
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

        await tester.enterText(
          campos.at(0),
          'João da Silva',
        );
        await tester.enterText(
          campos.at(1),
          'joao@test.com',
        );
        await tester.enterText(
          campos.at(2),
          'senha123',
        );
        await tester.enterText(
          campos.at(3),
          'senha123',
        );

        // O botão Cadastrar está abaixo da área visível do
        // SingleChildScrollView, então primeiro o tornamos visível.
        final cadastrar = find.widgetWithText(
          ElevatedButton,
          'Cadastrar',
        );

        await tester.ensureVisible(cadastrar);
        await tester.tap(cadastrar);
await tester.pumpAndSettle();

expect(
  find.textContaining('Erro ao cadastrar'),
  findsNothing,
);

expect(
  find.textContaining('Erro desconhecido'),
  findsNothing,
);

expect(mockAuth.currentUser, isNotNull);

        // O usuário deve ter sido criado no Firebase Auth.
        final usuario = mockAuth.currentUser;

        expect(usuario, isNotNull);
        expect(usuario!.email, 'joao@test.com');

        // O documento inicial deve ter sido criado no Firestore.
        final usuarioDoc = await fakeFirestore
            .collection('usuarios')
            .doc(usuario.uid)
            .get();

        expect(usuarioDoc.exists, isTrue);
        expect(usuarioDoc.data()?['nome'], 'João da Silva');
        expect(usuarioDoc.data()?['email'], 'joao@test.com');

        // Deve ter navegado para a tela de gêneros.
        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        // Os gêneros estão em uma Column. Tornamos cada SwitchListTile
        // visível antes de tocá-lo.
        final rock = find.widgetWithText(
          SwitchListTile,
          'Rock',
        );

        await tester.ensureVisible(rock);
        await tester.tap(rock);
        await tester.pump();

        final pop = find.widgetWithText(
          SwitchListTile,
          'Pop',
        );

        await tester.ensureVisible(pop);
        await tester.tap(pop);
        await tester.pump();

        // O botão Confirmar também pode estar fora da viewport.
        final confirmar = find.widgetWithText(
          ElevatedButton,
          'Confirmar',
        );

        await tester.ensureVisible(confirmar);
        await tester.tap(confirmar);
        await tester.pumpAndSettle();

        // Verifica se os gêneros foram persistidos.
        final usuarioAtualizado = await fakeFirestore
            .collection('usuarios')
            .doc(usuario.uid)
            .get();

        final generos = usuarioAtualizado.data()?['generos_favoritos'];

        expect(generos, isA<List>());
        expect(
          generos,
          containsAll(<String>['Rock', 'Pop']),
        );
        expect(generos, hasLength(2));

        // A GenerosCadastroScreen deve ter sido substituída pela
        // próxima tela após o salvamento.
        expect(
          find.byType(GenerosCadastroScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'não permite confirmar sem selecionar um gênero',
      (tester) async {
        await mockAuth.signInWithEmailAndPassword(
          email: 'joao@test.com',
          password: 'senha123',
        );

        final uid = mockAuth.currentUser!.uid;

        await fakeFirestore
            .collection('usuarios')
            .doc(uid)
            .set({
          'nome': 'João da Silva',
          'email': 'joao@test.com',
        });

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        );

        final confirmar = find.widgetWithText(
          ElevatedButton,
          'Confirmar',
        );

        // O botão está logo após os sete SwitchListTile e pode
        // ficar parcialmente ou totalmente fora da viewport.
        await tester.ensureVisible(confirmar);
        await tester.tap(confirmar);
        await tester.pump();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );

        // Como nenhum gênero foi selecionado, não deve haver
        // atualização do documento.
        final usuario = await fakeFirestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(
          usuario.data()?['generos_favoritos'],
          isNull,
        );
      },
    );
testWidgets(
  'diagnóstico: createUserWithEmailAndPassword autentica o MockFirebaseAuth',
  (tester) async {
    final credential =
        await mockAuth.createUserWithEmailAndPassword(
      email: 'diagnostico@test.com',
      password: 'senha123',
    );

    expect(credential.user, isNotNull);
    expect(credential.user!.email, 'diagnostico@test.com');

    expect(mockAuth.currentUser, isNotNull);
    expect(
      mockAuth.currentUser!.uid,
      credential.user!.uid,
    );
  },
);
  });
}
