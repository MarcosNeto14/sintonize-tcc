**Classificação: (A) — o teste presume um comportamento/estrutura que não foi explicitamente garantido, e a falha atual é do próprio teste.**

 O erro ocorre **antes de executar qualquer teste E2E**. `TextFormField`, `Card` e `Switch` são classes do Flutter Material, mas o arquivo de teste não importou `package:flutter/material.dart`. Portanto, não há evidência de comportamento incorreto da aplicação.

 A correção é simplesmente adicionar esse import. Aproveitando, há um segundo ponto importante no teste anterior: como o arquivo está em `integration_test/fase3/`, o helper em `integration_test/firebase_test_helper.dart` deve ser importado como `../firebase_test_helper.dart`, como você especificou — isso já estava correto.

 ## Arquivo corrigido

 Substitua o conteúdo de `integration_test/fase3/c3_zs_test.dart` por:

 c3\_zs\_test.dart corrigido

```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> abrirCadastro(WidgetTester tester) async {
    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
    expect(find.text('Cadastro'), findsOneWidget);

    await tester.tap(find.text('Cadastro'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastrar'), findsOneWidget);
  }

  Future<void> preencherCadastro(
    WidgetTester tester, {
    required String nome,
    required String email,
    String senha = 'senha123',
    String dataNascimento = '01/01/2000',
    String cep = '01001-000',
    String numero = '100',
  }) async {
    final campos = find.byType(TextFormField);

    // Ordem dos TextFormField na CadastroScreen:
    //
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

    await tester.enterText(campos.at(0), nome);
    await tester.enterText(campos.at(1), dataNascimento);
    await tester.enterText(campos.at(2), email);
    await tester.enterText(campos.at(3), senha);
    await tester.enterText(campos.at(4), senha);
    await tester.enterText(campos.at(5), cep);

    // O CEP dispara uma consulta ao ViaCEP.
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.enterText(campos.at(7), numero);
  }

  Future<void> selecionarGenero(
    WidgetTester tester,
    String genero,
  ) async {
    final textoGenero = find.text(genero);

    expect(textoGenero, findsOneWidget);

    final card = find.ancestor(
      of: textoGenero,
      matching: find.byType(Card),
    );

    expect(card, findsOneWidget);

    final switchFinder = find.descendant(
      of: card,
      matching: find.byType(Switch),
    );

    expect(switchFinder, findsOneWidget);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'fluxo E2E completo: cadastro, gêneros, Firestore e tela inicial',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await abrirCadastro(tester);

      final emailUnico =
          'e2e-${DateTime.now().microsecondsSinceEpoch}@sintonize.test';

      await preencherCadastro(
        tester,
        nome: 'Usuário E2E',
        email: emailUnico,
      );

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsOneWidget,
      );
      expect(find.text('Confirmar'), findsOneWidget);

      await selecionarGenero(tester, 'Rock');
      await selecionarGenero(tester, 'Jazz');

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(
        find.textContaining('essa é a nossa recomendação'),
        findsOneWidget,
      );

      final authUser = FirebaseAuth.instance.currentUser;

      expect(authUser, isNotNull);
      expect(authUser!.email, emailUnico);

      final documento = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(authUser.uid)
          .get();

      expect(documento.exists, isTrue);

      final dados = documento.data()!;

      expect(dados['nome'], 'Usuário E2E');
      expect(dados['email'], emailUnico);

      expect(
        dados['generos_favoritos'],
        containsAll(<String>['Rock', 'Jazz']),
      );

      expect(
        (dados['generos_favoritos'] as List).length,
        2,
      );
    },
  );

  testWidgets(
    'valida campos obrigatórios no cadastro',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await abrirCadastro(tester);

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

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

      expect(find.text('Cadastrar'), findsOneWidget);

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'rejeita e-mail já cadastrado pelo Firebase Auth',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await abrirCadastro(tester);

      await preencherCadastro(
        tester,
        nome: 'Outro Usuário',
        email: 'tester@sintonize.test',
      );

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(
        find.textContaining('Erro ao cadastrar:'),
        findsOneWidget,
      );

      expect(find.text('Cadastrar'), findsOneWidget);

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'não permite confirmar sem selecionar gênero musical',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await abrirCadastro(tester);

      final emailUnico =
          'e2e-genero-${DateTime.now().microsecondsSinceEpoch}@sintonize.test';

      await preencherCadastro(
        tester,
        nome: 'Teste Sem Gênero',
        email: emailUnico,
      );

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Selecione pelo menos um gênero musical!'),
        findsOneWidget,
      );

      expect(find.text('Confirmar'), findsOneWidget);

      expect(
        find.textContaining('essa é a nossa recomendação'),
        findsNothing,
      );

      final authUser = FirebaseAuth.instance.currentUser;

      expect(authUser, isNotNull);

      final documento = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(authUser!.uid)
          .get();

      expect(documento.exists, isTrue);
      expect(
        documento.data()!.containsKey('generos_favoritos'),
        isFalse,
      );
    },
  );
}
```

 ### O que causou exatamente o erro

 O compilador encontrou:

```
find.byType(TextFormField)
find.byType(Card)
find.byType(Switch)
```

 mas essas classes pertencem ao Material do Flutter. Sem:

```
import 'package:flutter/material.dart';
```

 o Dart não conhece esses símbolos e produz:

```
Error: Undefined name 'TextFormField'.
Error: Undefined name 'Card'.
Error: Undefined name 'Switch'.
```

 Isso aconteceu durante:

```
Target kernel_snapshot_program failed
```

 ou seja, **o aplicativo nem chegou a ser iniciado no emulador**.

 ### Próximo comando

 Depois de salvar a correção:

```
flutter test integration_test/fase3/c3_zs_test.dart -d emulator-5554
```

 Se passar da compilação e surgir uma falha de execução, aí ela será uma falha E2E real e devemos analisar o comportamento observado antes de alterar qualquer asserção.