Abaixo está um teste de integração/widget que cobre o fluxo completo, usando `MockFirebaseAuth` para autenticação e `FakeFirebaseFirestore` para persistência. Para evitar a chamada HTTP real ao ViaCEP, o teste usa um CEP válido e preenche os campos de endereço diretamente.

```
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintoniza/cadastro.dart';
import 'package:sintoniza/generos-cadastro.dart';
import 'package:sintoniza/tela-inicial.dart';

void main() {
  group('Fluxo de cadastro e seleção de gêneros', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth(
        signedIn: false,
      );

      fakeFirestore = FakeFirebaseFirestore();
    });

    Widget montarApp() {
      return MaterialApp(
        home: CadastroScreen(
          auth: mockAuth,
          firestore: fakeFirestore,
        ),
      );
    }

    testWidgets(
      'fluxo completo: cadastra usuário, cria documento, seleciona gêneros e salva no Firestore',
      (tester) async {
        await tester.pumpWidget(montarApp());
        await tester.pumpAndSettle();

        // Preenche os campos do cadastro.
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome'),
          'João da Silva',
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Data de Nascimento'),
          '01011990',
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'E-mail'),
          'joao.teste@example.com',
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Senha'),
          'senha123',
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirmar Senha'),
          'senha123',
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'CEP'),
          '50000000',
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Rua'),
          'Rua de Teste',
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Número'),
          '123',
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Bairro'),
          'Centro',
        );

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Cidade'),
          'Recife',
        );

        // Seleciona o estado.
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();

        await tester.tap(find.text('PE').last);
        await tester.pumpAndSettle();

        // Cadastra o usuário.
        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        // O Firebase Auth mock deve ter criado e autenticado o usuário.
        final usuario = mockAuth.currentUser;

        expect(usuario, isNotNull);
        expect(usuario!.email, 'joao.teste@example.com');

        // Deve ter navegado para a tela de seleção de gêneros.
        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        // Verifica se o documento inicial foi criado no Firestore.
        final documentoInicial = await fakeFirestore
            .collection('usuarios')
            .doc(usuario.uid)
            .get();

        expect(documentoInicial.exists, isTrue);

        expect(documentoInicial.data(), containsPair(
          'nome',
          'João da Silva',
        ));

        expect(documentoInicial.data(), containsPair(
          'email',
          'joao.teste@example.com',
        ));

        // Seleciona Rock.
        final rockSwitch = find.ancestor(
          of: find.text('Rock'),
          matching: find.byType(Card),
        ).first;

        await tester.tap(
          find.descendant(
            of: rockSwitch,
            matching: find.byType(Switch),
          ),
        );

        // Seleciona Jazz.
        final jazzSwitch = find.ancestor(
          of: find.text('Jazz'),
          matching: find.byType(Card),
        ).first;

        await tester.tap(
          find.descendant(
            of: jazzSwitch,
            matching: find.byType(Switch),
          ),
        );

        await tester.pump();

        // Confirma os gêneros.
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        // Após salvar, deve navegar para a tela inicial.
        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );

        // Confirma que os gêneros foram persistidos no documento
        // do usuário correto.
        final documentoAtualizado = await fakeFirestore
            .collection('usuarios')
            .doc(usuario.uid)
            .get();

        expect(documentoAtualizado.exists, isTrue);

        final dados = documentoAtualizado.data();

        expect(
          dados?['generos_favoritos'],
          containsAll(<String>[
            'Rock',
            'Jazz',
          ]),
        );

        expect(
          (dados?['generos_favoritos'] as List).length,
          2,
        );
      },
    );

    testWidgets(
      'não permite confirmar gêneros sem selecionar pelo menos um gênero',
      (tester) async {
        // Coloca o usuário mockado como autenticado, pois a tela
        // GenerosCadastroScreen depende de currentUser.
        mockAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: MockUser(
            uid: 'usuario-teste',
            email: 'joao.teste@example.com',
          ),
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

        await tester.tap(find.text('Confirmar'));
        await tester.pump();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
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
```

 ### Observação importante

 Há um detalhe no código de produção que o teste revela: `CadastroScreen` cria o usuário e o documento usando os objetos injetados, e depois passa esses mesmos objetos para `GenerosCadastroScreen`. Isso é ideal para esse tipo de teste, pois permite usar `MockFirebaseAuth` e `FakeFirebaseFirestore` sem acessar os serviços reais.

 Também vale observar que o teste usa:

```
MockUser(
  uid: 'usuario-teste',
  email: 'joao.teste@example.com',
)
```

 no segundo caso porque `GenerosCadastroScreen` acessa diretamente `auth.currentUser`.

 Se quiser testar **exatamente o fluxo de produção**, inclusive a chamada ao ViaCEP, seria melhor extrair `_fetchAddressFromCEP` para um serviço injetável. Assim o teste poderia mockar o serviço HTTP em vez de depender da internet.
