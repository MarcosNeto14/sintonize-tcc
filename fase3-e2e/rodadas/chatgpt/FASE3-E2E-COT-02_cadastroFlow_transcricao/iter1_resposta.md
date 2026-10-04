## Classificação: **(A)**

 A causa é **(A) o teste presume/implementa incorretamente alguns detalhes do código**, e não um comportamento incorreto da aplicação.

 O erro acontece **antes de qualquer teste ser executado**, durante a compilação do arquivo Dart. Os problemas principais são:

 - `_waitUntil` e `_textControllerFor` foram declaradas como funções locais **depois** de outras funções locais que tentam referenciá-las. Em Dart, nesse contexto, elas não podem ser usadas antes da inicialização da variável-função.
- `TelaInicialScreen` não é exportada por `main.dart`; portanto `app.TelaInicialScreen` é inválido. Ela precisa ser importada diretamente de `package:sintonize/tela-inicial.dart`.
- O restante dos erros é consequência desses dois problemas de compilação.

 Isso **não é evidência de problema nas telas**. Portanto, devemos corrigir o teste normalmente, sem reduzir as asserções.

 ## Arquivo corrigido

 Substitua o conteúdo de `integration_test/fase3/cadastro_cot_test.dart` por este:

```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart' as app;
import 'package:sintonize/tela-inicial.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> waitUntil(
    WidgetTester tester,
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 10),
    Duration step = const Duration(milliseconds: 100),
  }) async {
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(step);

      if (condition()) {
        return;
      }
    }

    throw TestFailure(
      'Condição não satisfeita dentro de ${timeout.inSeconds}s.',
    );
  }

  TextEditingController? textControllerFor(Finder finder) {
    final elements = finder.evaluate();

    if (elements.isEmpty) {
      return null;
    }

    final widget = elements.first.widget;

    if (widget is TextFormField) {
      return widget.controller;
    }

    return null;
  }

  Finder formField(int index) {
    return find.byType(TextFormField).at(index);
  }

  Future<void> startApp(WidgetTester tester) async {
    await FirebaseAuth.instance.signOut();

    await tester.pumpWidget(const app.MyApp());
    await tester.pumpAndSettle();

    expect(
      find.text('Bem-vindo ao Sintonize!'),
      findsOneWidget,
    );
  }

  Future<void> goToCadastro(WidgetTester tester) async {
    await tester.tap(find.text('Cadastro'));
    await tester.pumpAndSettle();

    expect(
      find.text('Cadastrar'),
      findsOneWidget,
    );

    expect(
      find.text('Nome'),
      findsOneWidget,
    );

    expect(
      find.text('E-mail'),
      findsOneWidget,
    );
  }

  Future<void> fillValidCadastro(
    WidgetTester tester, {
    required String email,
    String nome = 'Usuario Teste',
    String dataNascimento = '01/01/1990',
    String senha = 'senha123',
    String cep = '01001000',
    String numero = '100',
  }) async {
    /*
     * Ordem dos TextFormField em CadastroScreen:
     *
     * 0 Nome
     * 1 Data de Nascimento
     * 2 E-mail
     * 3 Senha
     * 4 Confirmar Senha
     * 5 CEP
     * 6 Rua
     * 7 Número
     * 8 Bairro
     * 9 Cidade
     */

    await tester.enterText(
      formField(0),
      nome,
    );

    await tester.enterText(
      formField(1),
      dataNascimento,
    );

    await tester.enterText(
      formField(2),
      email,
    );

    await tester.enterText(
      formField(3),
      senha,
    );

    await tester.enterText(
      formField(4),
      senha,
    );

    await tester.enterText(
      formField(5),
      cep,
    );

    /*
     * O CEP 01001000 é formatado para 01001-000.
     * Quando chega a 9 caracteres, o onChanged dispara a chamada
     * HTTP para o ViaCEP.
     */
    await waitUntil(
      tester,
      () {
        final rua = textControllerFor(formField(6));

        final bairro = textControllerFor(formField(8));

        final cidade = textControllerFor(formField(9));

        return rua?.text.isNotEmpty == true &&
            bairro?.text.isNotEmpty == true &&
            cidade?.text.isNotEmpty == true;
      },
      timeout: const Duration(seconds: 15),
    );

    await tester.enterText(
      formField(7),
      numero,
    );
  }

  Future<void> submitCadastro(WidgetTester tester) async {
    await tester.tap(find.text('Cadastrar'));

    await waitUntil(
      tester,
      () {
        return find
            .text(
              'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
            )
            .evaluate()
            .isNotEmpty;
      },
      timeout: const Duration(seconds: 20),
    );
  }

  Future<void> selectGenero(
    WidgetTester tester,
    String genero,
  ) async {
    final textFinder = find.text(genero);

    expect(
      textFinder,
      findsOneWidget,
    );

    final card = find.ancestor(
      of: textFinder,
      matching: find.byType(Card),
    );

    expect(
      card,
      findsOneWidget,
    );

    final switchFinder = find.descendant(
      of: card,
      matching: find.byType(Switch),
    );

    expect(
      switchFinder,
      findsOneWidget,
    );

    await tester.tap(switchFinder);
    await tester.pump();
  }

  Future<void> confirmGeneros(WidgetTester tester) async {
    await tester.tap(find.text('Confirmar'));

    await waitUntil(
      tester,
      () => find.byType(TelaInicialScreen).evaluate().isNotEmpty,
      timeout: const Duration(seconds: 20),
    );
  }

  Future<void> expectValidationError(
    WidgetTester tester,
    String message,
  ) async {
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    expect(
      find.text(message),
      findsOneWidget,
    );

    expect(
      find.text(
        'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
      ),
      findsNothing,
    );
  }

  group('Fase 3 - Cadastro e seleção de gêneros', () {
    testWidgets(
      'Fluxo E2E completo: cadastro -> gêneros -> tela inicial',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        final email =
            'e2e-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

        await fillValidCadastro(
          tester,
          email: email,
        );

        final rua = textControllerFor(formField(6));
        final bairro = textControllerFor(formField(8));
        final cidade = textControllerFor(formField(9));

        expect(
          rua?.text.isNotEmpty,
          isTrue,
        );

        expect(
          bairro?.text.isNotEmpty,
          isTrue,
        );

        expect(
          cidade?.text.isNotEmpty,
          isTrue,
        );

        await submitCadastro(tester);

        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        expect(
          find.text('Rock'),
          findsOneWidget,
        );

        expect(
          find.text('Pop'),
          findsOneWidget,
        );

        expect(
          find.text('Confirmar'),
          findsOneWidget,
        );

        await selectGenero(tester, 'Rock');
        await selectGenero(tester, 'Pop');

        await confirmGeneros(tester);

        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );

        await waitUntil(
          tester,
          () {
            return find
                .text(
                  'Usuario Teste, essa é a nossa recomendação de música para você!',
                )
                .evaluate()
                .isNotEmpty;
          },
          timeout: const Duration(seconds: 20),
        );

        expect(
          find.text(
            'Usuario Teste, essa é a nossa recomendação de música para você!',
          ),
          findsOneWidget,
        );

        final user = FirebaseAuth.instance.currentUser;

        expect(
          user,
          isNotNull,
        );

        final snapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .get();

        expect(
          snapshot.exists,
          isTrue,
        );

        final data = snapshot.data()!;

        expect(
          data['nome'],
          'Usuario Teste',
        );

        expect(
          data['email'],
          email,
        );

        final generos = List<String>.from(
          data['generos_favoritos'] ?? const [],
        );

        expect(
          generos,
          containsAll(<String>[
            'Rock',
            'Pop',
          ]),
        );
      },
    );

    testWidgets(
      'Validação: nome com números não dispara Firebase',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(
          formField(0),
          'Usuario123',
        );

        await expectValidationError(
          tester,
          'O nome não pode conter números ou caracteres especiais',
        );
      },
    );

    testWidgets(
      'Validação: data de nascimento inválida',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(
          formField(1),
          '31/02/1990',
        );

        await expectValidationError(
          tester,
          'Dia deve ser entre 01 e 28',
        );
      },
    );

    testWidgets(
      'Validação: e-mail inválido não dispara Firebase',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(
          formField(2),
          'email-invalido',
        );

        await expectValidationError(
          tester,
          'E-mail inválido',
        );
      },
    );

    testWidgets(
      'Validação: senha com menos de seis caracteres',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(
          formField(3),
          '12345',
        );

        await tester.enterText(
          formField(4),
          '12345',
        );

        await expectValidationError(
          tester,
          'A senha deve ter pelo menos 6 caracteres',
        );
      },
    );

    testWidgets(
      'Validação: senhas diferentes',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(
          formField(3),
          'senha123',
        );

        await tester.enterText(
          formField(4),
          'senha456',
        );

        await expectValidationError(
          tester,
          'As senhas não coincidem',
        );
      },
    );

    testWidgets(
      'Validação: CEP inválido',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(
          formField(5),
          '123',
        );

        await expectValidationError(
          tester,
          'CEP inválido. Formato correto: XXXXX-XXX',
        );
      },
    );

    testWidgets(
      'Validação: número do endereço não numérico',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(
          formField(7),
          'ABC',
        );

        await expectValidationError(
          tester,
          'O número deve ser numérico',
        );
      },
    );

    testWidgets(
      'Firebase Auth: e-mail já cadastrado',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        /*
         * Este usuário faz parte do estado inicial do Auth Emulator.
         */
        await fillValidCadastro(
          tester,
          email: 'tester@sintonize.test',
        );

        await tester.tap(find.text('Cadastrar'));

        await waitUntil(
          tester,
          () {
            return find
                .textContaining('Erro ao cadastrar:')
                .evaluate()
                .isNotEmpty;
          },
          timeout: const Duration(seconds: 20),
        );

        expect(
          find.textContaining('Erro ao cadastrar:'),
          findsOneWidget,
        );

        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsNothing,
        );

        expect(
          find.text('Cadastrar'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Fluxo de gêneros: confirmar sem selecionar nenhum',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        final email =
            'sem-genero-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

        await fillValidCadastro(
          tester,
          email: email,
        );

        await submitCadastro(tester);

        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Confirmar'));
        await tester.pump();

        expect(
          find.text(
            'Selecione pelo menos um gênero musical!',
          ),
          findsOneWidget,
        );

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );

        expect(
          find.text('Confirmar'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Estado final: TelaInicial carrega nome e recomendação',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        final email =
            'loading-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

        await fillValidCadastro(
          tester,
          email: email,
        );

        await submitCadastro(tester);

        await selectGenero(tester, 'Rock');

        await confirmGeneros(tester);

        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );

        await waitUntil(
          tester,
          () {
            return find
                .text(
                  'Usuario Teste, essa é a nossa recomendação de música para você!',
                )
                .evaluate()
                .isNotEmpty;
          },
          timeout: const Duration(seconds: 20),
        );

        expect(
          find.text(
            'Usuario Teste, essa é a nossa recomendação de música para você!',
          ),
          findsOneWidget,
        );

        expect(
          find.text('Bohemian Rhapsody'),
          findsOneWidget,
        );
      },
    );
  });
}
```

 ### O que foi corrigido

 1. **`_waitUntil` → `waitUntil`**
   - Continua sendo uma função local, mas agora é declarada antes das funções que a utilizam.
   - Também removi o `_`, porque ela não precisa ser privada dentro de `main()`.
2. **`_textControllerFor` → `textControllerFor`**
   - Mesmo motivo: agora está definida antes de `fillValidCadastro()`.
3. **`TelaInicialScreen`**

   ```
   import 'package:sintonize/tela-inicial.dart';
   ```

   ```
   app.TelaInicialScreen
   ```
    para:

   ```
   TelaInicialScreen
   ```
   - Acrescentei:
   - E as referências passaram de:
4. **Removi o `firstOrNull`**
   - Não é necessário aqui. `evaluate()` é verificado explicitamente antes de acessar `.first`, deixando o helper mais compatível com a versão do SDK usada pelo projeto.
5. **Mantive o escopo E2E**
   - Não foram adicionados mocks.
   - Auth e Firestore continuam sendo os emuladores reais.
   - O cadastro continua sendo feito pela UI.
   - A atualização dos gêneros continua sendo feita pela UI.
   - A consulta direta ao Firestore continua sendo apenas uma **asserção do resultado produzido pela interface**.

 O erro apresentado, portanto, deve desaparecer na fase de compilação. Depois disso, qualquer novo erro será significativo: se o próximo erro ocorrer durante a execução do teste, aí devemos analisar se ele revela outro problema no **teste (A)** ou um comportamento efetivamente incorreto da **aplicação (B)**.