Abaixo está um teste de integração focado no fluxo completo, usando firebase_auth_mocks e fake_cloud_firestore. Há dois cenários: sucesso ao salvar os gêneros e tentativa de confirmar sem selecionar nenhum gênero.

Escrita
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

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
        // Usuário que será criado pelo mock.
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

        // Preenche o formulário de cadastro.
        final campos = find.byType(TextFormField);

        await tester.enterText(campos.at(0), 'João da Silva');
        await tester.enterText(campos.at(1), email);
        await tester.enterText(campos.at(2), senha);
        await tester.enterText(campos.at(3), senha);

        // Cria a conta.
        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        // O cadastro deve criar o documento do usuário e navegar
        // para a tela de seleção de gêneros.
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);

        // O MockFirebaseAuth deve ter um usuário autenticado.
        final usuario = mockAuth.currentUser;
        expect(usuario, isNotNull);

        // O documento criado durante o cadastro deve existir.
        final usuarioDoc = await fakeFirestore
            .collection('usuarios')
            .doc(usuario!.uid)
            .get();

        expect(usuarioDoc.exists, isTrue);
        expect(usuarioDoc.data()?['nome'], 'João da Silva');
        expect(usuarioDoc.data()?['email'], email);

        // Seleciona Rock.
        final rockSwitch = find.byType(SwitchListTile).at(0);
        await tester.tap(rockSwitch);

        // Seleciona Jazz.
        final jazzSwitch = find.byType(SwitchListTile).at(2);
        await tester.tap(jazzSwitch);

        // Confirma a seleção.
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        // Depois do salvamento, deve navegar para a tela inicial.
        expect(find.byType(TelaInicialScreen), findsOneWidget);

        // Verifica diretamente no Firestore se os gêneros foram salvos.
        final documentoAtualizado = await fakeFirestore
            .collection('usuarios')
            .doc(usuario.uid)
            .get();

        expect(
          documentoAtualizado.data()?['generos_favoritos'],
          containsAll(<String>['Rock', 'Jazz']),
        );

        expect(
          (documentoAtualizado.data()?['generos_favoritos'] as List).length,
          2,
        );
      },
    );

    testWidgets(
      'não permite confirmar sem selecionar um gênero',
      (tester) async {
        // Para abrir GenerosCadastroScreen diretamente, precisamos
        // de um usuário autenticado.
        final credential = await mockAuth.createUserWithEmailAndPassword(
          email: 'user@test.com',
          password: 'senha123',
        );

        final uid = credential.user!.uid;

        // Cria o documento necessário para o update posterior.
        await fakeFirestore.collection('usuarios').doc(uid).set({
          'nome': 'João da Silva',
          'email': 'user@test.com',
        });

        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        );

        // Nenhum gênero é selecionado.
        await tester.tap(find.text('Confirmar'));
        await tester.pump();

        // Deve apresentar a mensagem de validação.
        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );

        // Continua na tela de gêneros.
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);

        // O documento não deve ter sido atualizado com generos_favoritos.
        final documento = await fakeFirestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(documento.data()?['generos_favoritos'], isNull);
      },
    );
  });
}

Observação importante

No primeiro teste, o ponto mais importante é verificar não apenas a navegação, mas também o estado final do Firestore:

CadastroScreen cria o usuário no Firebase Auth.
O documento usuarios/{uid} é criado.
A navegação chega à GenerosCadastroScreen.
Rock e Jazz são selecionados.
Confirmar executa o update.
O teste consulta o FakeFirebaseFirestore e confirma que generos_favoritos contém exatamente os gêneros selecionados.
A navegação para TelaInicialScreen também é validada.

Há ainda um detalhe no código fornecido: GenerosCadastroScreen usa widget.auth.currentUser!.uid, portanto é essencial passar a mesma instância de MockFirebaseAuth para a tela — o teste faz isso.

Se TelaInicialScreen estiver em outro arquivo, basta adicionar o respectivo import; o teste acima assume que ela está disponível pelos imports existentes do projeto.