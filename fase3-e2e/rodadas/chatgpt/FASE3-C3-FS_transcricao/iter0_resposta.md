Abaixo está um teste E2E completo para `integration_test/fase3/cadastro_generos_test.dart`. Ele usa o app real, os emuladores Firebase e verifica também diretamente no Firestore que os gêneros foram persistidos no documento criado pelo fluxo.

 integration\_test/fase3/cadastro\_generos\_test.dart

```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu: $finder');
  }

  Future<void> preencherCadastro(WidgetTester tester) async {
    final campos = find.byType(TextFormField);

    // Os TextFormField aparecem na seguinte ordem:
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

    await tester.enterText(
      campos.at(0),
      'Usuário E2E',
    );

    await tester.enterText(
      campos.at(1),
      '01/01/2000',
    );

    await tester.enterText(
      campos.at(2),
      'e2e-${DateTime.now().millisecondsSinceEpoch}@sintonize.test',
    );

    await tester.enterText(
      campos.at(3),
      'senha123',
    );

    await tester.enterText(
      campos.at(4),
      'senha123',
    );

    // O CEP é válido no formato esperado pelo formulário.
    // O preenchimento pode disparar uma consulta ao ViaCEP, portanto
    // aguardamos a aplicação antes de preencher os campos restantes.
    await tester.enterText(
      campos.at(5),
      '01001-000',
    );

    await tester.pump(const Duration(seconds: 2));

    // Preenche manualmente os campos de endereço para que o teste
    // não dependa do serviço externo do ViaCEP.
    await tester.enterText(
      campos.at(6),
      'Praça da Sé',
    );

    await tester.enterText(
      campos.at(7),
      '100',
    );

    await tester.enterText(
      campos.at(8),
      'Sé',
    );

    await tester.enterText(
      campos.at(9),
      'São Paulo',
    );

    // Seleciona um estado.
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SP').last);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'cadastro: cria usuário, salva documento, seleciona gêneros e persiste no Firestore',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Confirma que estamos na tela inicial.
      expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
      expect(find.text('Cadastro'), findsOneWidget);

      // Abre o fluxo de cadastro.
      await tester.tap(find.text('Cadastro'));
      await tester.pumpAndSettle();

      // Confirma que a CadastroScreen foi aberta.
      expect(find.text('Cadastrar'), findsOneWidget);

      // Preenche todos os campos necessários.
      await preencherCadastro(tester);

      // Guarda o e-mail utilizado para localizar o usuário criado no Auth.
      final email =
          'e2e-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      // O helper acima usa um timestamp próprio para o e-mail, portanto
      // precisamos preencher novamente o campo de e-mail com o valor que
      // vamos consultar posteriormente.
      final campos = find.byType(TextFormField);

      await tester.enterText(
        campos.at(2),
        email,
      );

      // Cria a conta.
      await tester.tap(find.text('Cadastrar'));

      // O cadastro cria o usuário no Firebase Auth, cria o documento
      // usuarios/{uid} e então navega para a tela de gêneros.
      await esperar(
        tester,
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
      );

      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );
      expect(find.text('Confirmar'), findsOneWidget);

      // Localiza os switches pelos cards/textos dos gêneros.
      final rock = find.ancestor(
        of: find.text('Rock'),
        matching: find.byType(Card),
      );

      final pop = find.ancestor(
        of: find.text('Pop'),
        matching: find.byType(Card),
      );

      // Cada card possui um único Switch.
      await tester.tap(find.descendant(
        of: rock,
        matching: find.byType(Switch),
      ));

      await tester.tap(find.descendant(
        of: pop,
        matching: find.byType(Switch),
      ));

      await tester.pumpAndSettle();

      // Confirma os gêneros.
      await tester.tap(find.text('Confirmar'));

      // O fluxo deve chegar à tela inicial.
      await esperar(
        tester,
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
      );

      expect(
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // Verificação E2E adicional:
      // consulta o Auth real e o Firestore Emulator para garantir que
      // o resultado persistido corresponde ao que foi selecionado pela UI.
      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);
      expect(user!.email, email);

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(doc.exists, isTrue);

      final data = doc.data()!;

      expect(data['nome'], 'Usuário E2E');
      expect(data['email'], email);

      expect(
        data['generos_favoritos'],
        containsAll(<String>[
          'Rock',
          'Pop',
        ]),
      );

      expect(
        (data['generos_favoritos'] as List).length,
        2,
      );
    },
  );
}
```

 Há, porém, um detalhe importante no código acima: como o e-mail precisa ser reutilizado para validar o usuário criado, é melhor gerar o e-mail **uma única vez antes de preencher o formulário**. Portanto, esta é a versão que eu recomendo efetivamente salvar no projeto:

 Versão recomendada — cadastro\_generos\_test.dart

```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu: $finder');
  }

  testWidgets(
    'cadastro: cria conta, seleciona gêneros e salva no Firestore',
    (tester) async {
      final email =
          'e2e-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);

      // ---------------------------------------------------------------
      // 1. Abre CadastroScreen
      // ---------------------------------------------------------------

      await tester.tap(find.text('Cadastro'));
      await tester.pumpAndSettle();

      expect(find.text('Cadastrar'), findsOneWidget);

      // ---------------------------------------------------------------
      // 2. Preenche o formulário de cadastro
      // ---------------------------------------------------------------

      final campos = find.byType(TextFormField);

      await tester.enterText(
        campos.at(0),
        'Usuário E2E',
      );

      await tester.enterText(
        campos.at(1),
        '01/01/2000',
      );

      await tester.enterText(
        campos.at(2),
        email,
      );

      await tester.enterText(
        campos.at(3),
        'senha123',
      );

      await tester.enterText(
        campos.at(4),
        'senha123',
      );

      // CEP válido para passar na validação.
      // O teste não depende do retorno do ViaCEP para a persistência:
      // os campos de endereço são preenchidos explicitamente.
      await tester.enterText(
        campos.at(5),
        '01001-000',
      );

      await tester.pump(const Duration(seconds: 2));

      await tester.enterText(
        campos.at(6),
        'Praça da Sé',
      );

      await tester.enterText(
        campos.at(7),
        '100',
      );

      await tester.enterText(
        campos.at(8),
        'Sé',
      );

      await tester.enterText(
        campos.at(9),
        'São Paulo',
      );

      // Seleciona SP no DropdownButtonFormField.
      await tester.tap(
        find.byType(DropdownButtonFormField<String>),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('SP').last);
      await tester.pumpAndSettle();

      // ---------------------------------------------------------------
      // 3. Cria a conta pelo Firebase Auth e o documento no Firestore
      // ---------------------------------------------------------------

      await tester.tap(find.text('Cadastrar'));

      // A navegação só ocorre depois que Auth + Firestore terminam.
      await esperar(
        tester,
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
      );

      expect(find.text('Confirmar'), findsOneWidget);

      // ---------------------------------------------------------------
      // 4. Seleciona Rock e Pop
      // ---------------------------------------------------------------

      final rockCard = find.ancestor(
        of: find.text('Rock'),
        matching: find.byType(Card),
      );

      final popCard = find.ancestor(
        of: find.text('Pop'),
        matching: find.byType(Card),
      );

      await tester.tap(
        find.descendant(
          of: rockCard,
          matching: find.byType(Switch),
        ),
      );

      await tester.tap(
        find.descendant(
          of: popCard,
          matching: find.byType(Switch),
        ),
      );

      await tester.pumpAndSettle();

      // ---------------------------------------------------------------
      // 5. Confirma os gêneros
      // ---------------------------------------------------------------

      await tester.tap(find.text('Confirmar'));

      // Confirmar chama update() no documento e depois navega.
      await esperar(
        tester,
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
      );

      // ---------------------------------------------------------------
      // 6. Verifica que o fluxo chegou à TelaInicialScreen
      // ---------------------------------------------------------------

      expect(
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // ---------------------------------------------------------------
      // 7. Verifica Auth e Firestore reais
      // ---------------------------------------------------------------

      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);
      expect(user!.email, email);

      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(snapshot.exists, isTrue);

      final data = snapshot.data()!;

      // Documento criado durante o cadastro.
      expect(data['nome'], 'Usuário E2E');
      expect(data['email'], email);

      // Campo atualizado pela GenerosCadastroScreen.
      expect(
        data['generos_favoritos'],
        containsAll(<String>[
          'Rock',
          'Pop',
        ]),
      );

      expect(
        (data['generos_favoritos'] as List).length,
        2,
      );
    },
  );
}
```

 ### Observação importante sobre o teste

 O teste acima valida uma propriedade importante do E2E: **não basta verificar que a tela mudou**. Depois de clicar em `Confirmar`, ele consulta o Firebase Emulator usando o `uid` do usuário realmente criado pelo formulário e confirma que `generos_favoritos` foi persistido como `['Rock', 'Pop']`.

 Há ainda um ponto específico do código fornecido: o cadastro chama o **ViaCEP real** quando o CEP chega a 9 caracteres. Isso introduz uma dependência externa no teste. A versão acima evita depender do resultado do ViaCEP para os dados necessários ao cadastro, sobrescrevendo Rua/Bairro/Cidade e selecionando Estado depois da consulta. Ainda assim, o `http.get()` é disparado. Para um E2E totalmente determinístico contra infraestrutura local, seria melhor que a aplicação permitisse injetar o serviço de CEP ou que o preenchimento automático não fosse acionado durante testes.

 Também não usei o usuário pré-populado `tester@sintonize.test`: conforme sua regra, o fluxo de cadastro precisa criar **um novo usuário pela própria interface**, então o e-mail recebe um timestamp para evitar conflito no Auth Emulator.