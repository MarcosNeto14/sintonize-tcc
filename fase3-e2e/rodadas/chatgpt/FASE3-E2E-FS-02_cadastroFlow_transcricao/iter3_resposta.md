**Classificação: (A) — o teste presume um comportamento que não é o especificado.**

 Desta vez o problema está nos **dados que o teste forneceu ao formulário**, não na navegação da aplicação.

 O `CadastroScreen` tem esta validação para o nome:

```
final hasInvalidCharacters =
    RegExp(r'[^a-zA-ZÀ-ÿ\s]').hasMatch(value);

if (hasInvalidCharacters) {
  return 'O nome não pode conter números ou caracteres especiais';
}
```

 O teste estava preenchendo:

```
Usuário E2E
```

 Esse valor contém os caracteres `2`, portanto **o formulário é inválido**. Consequentemente, `_submit()` não entra no bloco que chama `createUserWithEmailAndPassword()`, e a aplicação permanece na `CadastroScreen`. Por isso a `GenerosCadastroScreen` nunca aparece.

 Isso explica também por que não houve exceção do Firebase: **o Firebase Auth nem chegou a ser chamado**.

 A correção é usar um nome válido, por exemplo `Usuário Teste`, e ajustar a asserção correspondente no Firestore.

 cadastro\_fs\_test.dart

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

  Future<void> esperar(
    WidgetTester tester,
    Finder finder, {
    int tentativas = 40,
  }) async {
    for (var i = 0; i < tentativas; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu após esperar: $finder');
  }

  testWidgets(
    'cadastro completo: cria usuário, salva gêneros favoritos e abre tela inicial',
    (tester) async {
      final identificador = DateTime.now().millisecondsSinceEpoch;
      final email = 'e2e-$identificador@sintonize.test';
      const senha = 'senha123';
      const nome = 'Usuário Teste';

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // ==============================================================
      // Tela inicial
      // ==============================================================

      expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Cadastro'), findsOneWidget);

      await tester.tap(find.text('Cadastro'));
      await tester.pumpAndSettle();

      // ==============================================================
      // CadastroScreen
      // ==============================================================

      expect(find.text('Cadastrar'), findsOneWidget);

      final campos = find.byType(TextFormField);

      // Ordem definida pela implementação de CadastroScreen:
      //
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

      expect(campos, findsNWidgets(10));

      await tester.enterText(
        campos.at(0),
        nome,
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
        senha,
      );

      await tester.enterText(
        campos.at(4),
        senha,
      );

      // O formatter transforma 01001000 em 01001-000.
      await tester.enterText(
        campos.at(5),
        '01001000',
      );

      // O CEP dispara uma consulta ao ViaCEP. O resultado dessa
      // consulta não é usado como condição para o cadastro.
      await tester.pump(const Duration(seconds: 1));

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

      // ==============================================================
      // Estado
      // ==============================================================

      final estadoDropdown =
          find.byType(DropdownButtonFormField<String>);

      expect(estadoDropdown, findsOneWidget);

      await tester.ensureVisible(estadoDropdown);
      await tester.pumpAndSettle();

      await tester.tap(estadoDropdown);
      await tester.pumpAndSettle();

      final opcaoSP = find.text('SP');

      expect(opcaoSP, findsWidgets);

      await tester.tap(opcaoSP.last);
      await tester.pumpAndSettle();

      // ==============================================================
      // Cadastro
      // ==============================================================

      final botaoCadastrar = find.text('Cadastrar');

      expect(botaoCadastrar, findsOneWidget);

      await tester.ensureVisible(botaoCadastrar);
      await tester.pumpAndSettle();

      await tester.tap(botaoCadastrar);

      // O fluxo esperado é:
      //
      // CadastroScreen
      //   -> Firebase Auth: createUserWithEmailAndPassword
      //   -> Firestore: usuarios/{uid}.set(...)
      //   -> GenerosCadastroScreen

      await esperar(
        tester,
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
      );

      // ==============================================================
      // GenerosCadastroScreen
      // ==============================================================

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsOneWidget,
      );

      expect(find.text('Rock'), findsOneWidget);
      expect(find.text('Pop'), findsOneWidget);
      expect(find.text('Jazz'), findsOneWidget);
      expect(find.text('Blues'), findsOneWidget);
      expect(find.text('Hip-Hop'), findsOneWidget);
      expect(find.text('Reggae'), findsOneWidget);
      expect(find.text('Country'), findsOneWidget);
      expect(find.text('Confirmar'), findsOneWidget);

      final switches = find.byType(Switch);

      expect(switches, findsNWidgets(7));

      // Lista da aplicação:
      // 0 - Rock
      // 1 - Pop
      // 2 - Jazz
      // 3 - Blues
      // 4 - Hip-Hop
      // 5 - Reggae
      // 6 - Country

      await tester.tap(switches.at(0));
      await tester.pump();

      await tester.tap(switches.at(1));
      await tester.pump();

      // ==============================================================
      // Confirmar
      // ==============================================================

      final botaoConfirmar = find.text('Confirmar');

      expect(botaoConfirmar, findsOneWidget);

      await tester.ensureVisible(botaoConfirmar);
      await tester.pumpAndSettle();

      await tester.tap(botaoConfirmar);

      // Confirmar deve atualizar o documento e navegar para
      // TelaInicialScreen.
      await esperar(
        tester,
        find.text(
          'essa é a nossa recomendação de música para você!',
        ),
      );

      // ==============================================================
      // TelaInicialScreen
      // ==============================================================

      expect(
        find.text(
          'essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // ==============================================================
      // Firebase Auth Emulator
      // ==============================================================

      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);
      expect(user!.email, email);

      // ==============================================================
      // Firestore Emulator
      // ==============================================================

      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(snapshot.exists, isTrue);

      final data = snapshot.data()!;

      // Dados criados pelo CadastroScreen.
      expect(data['nome'], nome);
      expect(data['data_nasc'], '01/01/2000');
      expect(data['email'], email);

      final endereco = data['endereco'] as Map<String, dynamic>;

      expect(endereco['rua'], 'Praça da Sé');
      expect(endereco['numero'], '100');
      expect(endereco['bairro'], 'Sé');
      expect(endereco['cidade'], 'São Paulo');
      expect(endereco['estado'], 'SP');
      expect(endereco['cep'], '01001-000');

      // Dados adicionados posteriormente pela
      // GenerosCadastroScreen.
      expect(data['generos_favoritos'], isA<List>());

      final generosFavoritos =
          List<String>.from(data['generos_favoritos'] as List);

      expect(
        generosFavoritos,
        containsAll(<String>['Rock', 'Pop']),
      );

      expect(generosFavoritos, hasLength(2));
    },
  );
}
```

 ### O ponto que causou a falha

 O teste anterior tinha:

```
const nome = 'Usuário E2E';
```

 mas a própria aplicação exige que o nome contenha **somente letras e espaços**. Portanto:

```
Usuário Teste  ✅
Usuário E2E    ❌
```

 O restante do fluxo não deve ser enfraquecido: continuamos verificando tanto a navegação para gêneros quanto a persistência final no Firestore.

 Um detalhe adicional: o e-mail continua contendo números (`e2e-...`), mas isso é permitido pelo `_validateEmail`; a restrição de caracteres especiais é aplicada **somente ao campo Nome**.