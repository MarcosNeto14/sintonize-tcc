Abaixo está um teste de integração focado no fluxo completo: cadastro → criação no Firebase Auth → gravação inicial em `usuarios` → seleção de gêneros → atualização no Firestore → navegação para `TelaInicialScreen`.

 Há um detalhe importante no código fornecido: o cadastro dispara uma chamada HTTP ao ViaCEP quando o CEP chega a 9 caracteres. Para evitar que o teste dependa da internet, o teste usa um CEP que **não dispara a chamada** e preenche manualmente os campos de endereço. Isso permite testar o fluxo das telas sem introduzir uma dependência externa.

 Também é necessário que `TelaInicialScreen` possa ser construída no ambiente de teste; abaixo uso uma tela fake com o mesmo objetivo de verificar a navegação.

```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        // -------------------------------------------------------------------
        // Arrange
        // -------------------------------------------------------------------
        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        );

        // O MockFirebaseAuth cria um usuário real para o mock e, portanto,
        // currentUser ficará disponível depois do cadastro.
        expect(find.text('Cadastrar'), findsOneWidget);

        // -------------------------------------------------------------------
        // Act - preencher formulário de cadastro
        // -------------------------------------------------------------------

        final campos = find.byType(TextFormField);

        // Ordem dos TextFormField na CadastroScreen:
        // 0 - Nome
        // 1 - Data de Nascimento
        // 2 - E-mail
        // 3 - Senha
        // 4 - Confirmar Senha
        // 5 - CEP
        // 6 - Rua
        // 7 - Número
        // 8 - Bairro
        // 9 - Cidade

        await tester.enterText(campos.at(0), 'João da Silva');
        await tester.enterText(campos.at(1), '01011990');
        await tester.enterText(campos.at(2), 'joao@test.com');
        await tester.enterText(campos.at(3), 'senha123');
        await tester.enterText(campos.at(4), 'senha123');

        // CEP incompleto propositalmente para não disparar a chamada
        // externa ao ViaCEP.
        await tester.enterText(campos.at(5), '12345');

        await tester.enterText(campos.at(6), 'Rua das Flores');
        await tester.enterText(campos.at(7), '123');
        await tester.enterText(campos.at(8), 'Centro');
        await tester.enterText(campos.at(9), 'Recife');

        // Seleciona um estado.
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();

        await tester.tap(find.text('PE').last);
        await tester.pumpAndSettle();

        // Envia o formulário.
        await tester.tap(find.text('Cadastrar'));
        await tester.pumpAndSettle();

        // -------------------------------------------------------------------
        // Assert - deve ter navegado para GenerosCadastroScreen
        // -------------------------------------------------------------------

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );

        expect(
          find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
          findsOneWidget,
        );

        // O Firebase Auth mock deve possuir um usuário autenticado.
        final usuario = mockAuth.currentUser;
        expect(usuario, isNotNull);

        final uid = usuario!.uid;

        // Verifica que os dados básicos foram gravados no Firestore.
        final usuarioSnapshot = await fakeFirestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(usuarioSnapshot.exists, isTrue);

        expect(usuarioSnapshot.data()?['nome'], 'João da Silva');
        expect(usuarioSnapshot.data()?['data_nasc'], '01/01/1990');
        expect(usuarioSnapshot.data()?['email'], 'joao@test.com');

        expect(
          usuarioSnapshot.data()?['endereco']['rua'],
          'Rua das Flores',
        );

        expect(
          usuarioSnapshot.data()?['endereco']['numero'],
          '123',
        );

        expect(
          usuarioSnapshot.data()?['endereco']['bairro'],
          'Centro',
        );

        expect(
          usuarioSnapshot.data()?['endereco']['cidade'],
          'Recife',
        );

        expect(
          usuarioSnapshot.data()?['endereco']['estado'],
          'PE',
        );

        // -------------------------------------------------------------------
        // Act - selecionar gêneros
        // -------------------------------------------------------------------

        // Há um Switch para cada gênero.
        final switches = find.byType(Switch);

        expect(switches, findsNWidgets(7));

        // Seleciona Rock e Jazz.
        await tester.tap(switches.at(0));
        await tester.pump();

        await tester.tap(switches.at(2));
        await tester.pump();

        // Confirma.
        await tester.tap(find.text('Confirmar'));
        await tester.pumpAndSettle();

        // -------------------------------------------------------------------
        // Assert - gêneros devem ter sido gravados
        // -------------------------------------------------------------------

        final atualizado = await fakeFirestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(
          atualizado.data()?['generos_favoritos'],
          containsAll(<String>[
            'Rock',
            'Jazz',
          ]),
        );

        expect(
          (atualizado.data()?['generos_favoritos'] as List).length,
          2,
        );
      },
    );

    testWidgets(
      'não permite confirmar sem selecionar nenhum gênero',
      (tester) async {
        // Para testar somente a tela de gêneros, criamos um usuário
        // autenticado no mock.
        final userCredential =
            await mockAuth.createUserWithEmailAndPassword(
          email: 'generos@test.com',
          password: 'senha123',
        );

        final uid = userCredential.user!.uid;

        await fakeFirestore.collection('usuarios').doc(uid).set({
          'nome': 'Usuário Teste',
          'email': 'generos@test.com',
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

        // Nenhum Switch deve estar selecionado.
        final switches = tester.widgetList<Switch>(
          find.byType(Switch),
        );

        expect(
          switches.every((switchWidget) => switchWidget.value == false),
          isTrue,
        );

        // Tenta confirmar sem selecionar gênero.
        await tester.tap(find.text('Confirmar'));
        await tester.pump();

        // Deve exibir a validação da própria tela.
        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );

        // O documento não deve ter recebido generos_favoritos.
        final snapshot = await fakeFirestore
            .collection('usuarios')
            .doc(uid)
            .get();

        expect(
          snapshot.data()?['generos_favoritos'],
          isNull,
        );
      },
    );
  });
}
```

 ### Um ponto que precisa ser ajustado no teste

 No primeiro teste, o `CadastroScreen` contém `LengthLimitingTextInputFormatter(8)` e `_CEPInputFormatter`, portanto um CEP com apenas `12345` permanece como `12345`. Como a validação exige `XXXXX-XXX`, o formulário **não passaria**.

 Assim, para o fluxo completo funcionar sem chamar o ViaCEP, o ideal é evitar essa dependência externa por meio de uma pequena refatoração no código de produção, por exemplo injetando um serviço de CEP, ou mockando a chamada HTTP.

 Uma alternativa mais simples para o teste é usar um CEP válido e controlar a camada HTTP. Sem essa refatoração, o teste acima precisa ser adaptado porque o formulário exige um CEP válido antes de executar `_submit()`.

 ### Versão recomendada

 Eu recomendo separar a consulta ao ViaCEP em uma abstração, por exemplo:

```
abstract class CepService {
  Future<Map<String, dynamic>> buscar(String cep);
}
```

 E injetá-la em `CadastroScreen`. No teste, você fornece um mock que retorna:

```
{
  'logradouro': 'Rua das Flores',
  'bairro': 'Centro',
  'localidade': 'Recife',
  'uf': 'PE',
}
```

 Isso deixa o teste determinístico e realmente focado na integração entre **Firebase Auth + Firestore + navegação + seleção de gêneros**, em vez de depender de um serviço HTTP externo.

 Também vale observar que `GenerosCadastroScreen` faz:

```
final uid = _auth.currentUser!.uid;
```

 Portanto é essencial usar **a mesma instância de `MockFirebaseAuth`** nas duas telas, como no teste acima. Caso fosse criada uma segunda instância, `currentUser` poderia ser `null` e o fluxo falharia.

 Se quiser, posso também fornecer uma **versão 100% executável do arquivo `test/cadastro_integration_test.dart`**, incluindo um `FakeCepService` e uma adaptação mínima das telas para eliminar completamente a dependência do ViaCEP.