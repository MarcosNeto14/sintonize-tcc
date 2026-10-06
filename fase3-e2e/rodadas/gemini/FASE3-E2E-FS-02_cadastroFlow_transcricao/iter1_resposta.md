<!-- Resposta do Gemini 3.8 Flash ao reparo 1, rodada FASE3-E2E-FS-02_cadastroFlow, 2026-10-06, sem edição.
     Markdown do botão "Copiar", capturado na página. Envio e cópia automatizados.
     Conversa: https://gemini.google.com/app/cd8e8c7ebedc2dec -->

### Classificação da causa provável da falha

**(A) O teste presume um comportamento que não é o especificado (ou manipula a interface de maneira inadequada ao framework de testes).**

---

### Diagnóstico

Os logs revelam com clareza o motivo da falha:

1. **Falha ao interagir com o Dropdown:** A lista suspensa aberta por `DropdownButtonFormField` tem dezenas de itens (27 estados brasileiros). O item `'PE'` ficou fora da área visível do modal de opções, disparando o aviso de *hit-test missed*:
```
Warning: A call to tap() with finder "... DropdownMenuItem<String> ... 'PE'" derived an Offset ... that would not hit test on the specified widget.

```


Com isso, o menu não foi fechado com a seleção de `'PE'`.
2. **Menu sobreposto bloqueando cliques posteriores:** Como o modal do dropdown permaneceu aberto cobrindo a tela (criando barreiras modais como `RenderAbsorbPointer` e `RenderPointerListener`), a tentativa seguinte de tocar no botão `'Cadastrar'` também falhou com *hit-test missed*:
```
Warning: A call to tap() with finder "... ElevatedButton ... 'Cadastrar'" derived an Offset ... that would not hit test on the specified widget.

```


3. O formulário nunca foi de fato submetido, impedindo o app de navegar até a tela `GenerosCadastroScreen`.

Além disso, para garantir a interação correta com formulários longos no Flutter sem depender de valores mágicos de `drag`:

* Deve-se usar `tester.ensureVisible(...)` para rolar até o botão ou campo antes de tocá-lo.
* Para selecionar um estado sem estourar o limite de visualização ou exigir rolagem dentro do menu suspenso do Material Design, podemos escolher uma opção visível no topo da lista (como `'AC'`, `'AL'` ou `'AP'`), ou utilizar um item que não necessite de rolagem dentro do menu aberto.

---

### Código do Teste Corrigido

Substitua o conteúdo de `integration_test/fase3/cadastro_fs_test.dart` pelo código a seguir:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/main.dart';
import 'package:sintonize/tela-inicial.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  /// Helper para aguardar a renderização assíncrona de widgets na tela.
  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('Elemento não encontrado no tempo limite: $finder');
  }

  testWidgets(
      'Fluxo de cadastro: preenche dados, seleciona gêneros musicais e persiste no Firestore',
      (tester) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final emailNovo = 'novo_usuario_$timestamp@sintonize.test';
    const senhaNova = 'senhaForte123';
    const nomeNovo = 'Carlos Silva';

    // 1. Inicia o aplicativo
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 2. Toca no botão "Cadastro" da tela inicial
    final botaoIrParaCadastro = find.widgetWithText(ElevatedButton, 'Cadastro');
    expect(botaoIrParaCadastro, findsOneWidget);
    await tester.tap(botaoIrParaCadastro);
    await tester.pumpAndSettle();

    // 3. Garante que está na CadastroScreen
    expect(find.byType(CadastroScreen), findsOneWidget);

    // 4. Preenche os campos do formulário
    final textFields = find.byType(TextFormField);

    await tester.enterText(textFields.at(0), nomeNovo);
    await tester.enterText(textFields.at(1), '15101995'); // Data de Nascimento
    await tester.enterText(textFields.at(2), emailNovo);
    await tester.enterText(textFields.at(3), senhaNova);
    await tester.enterText(textFields.at(4), senhaNova);
    await tester.enterText(textFields.at(5), '50000000'); // CEP

    // Garante visibilidade e preenche o endereço
    await tester.ensureVisible(textFields.at(6));
    await tester.pumpAndSettle();
    await tester.enterText(textFields.at(6), 'Rua das Flores');

    await tester.enterText(textFields.at(7), '123'); // Número
    await tester.enterText(textFields.at(8), 'Centro'); // Bairro
    await tester.enterText(textFields.at(9), 'Recife'); // Cidade

    // 5. Seleciona o Estado no DropdownButtonFormField
    final dropdownEstado = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(dropdownEstado);
    await tester.pumpAndSettle();

    await tester.tap(dropdownEstado);
    await tester.pumpAndSettle();

    // Seleciona uma opção que aparece no topo da lista aberta (ex: 'AP') para evitar hit-test fora da tela
    final itemEstado = find.widgetWithText(DropdownMenuItem<String>, 'AP').last;
    await tester.tap(itemEstado);
    await tester.pumpAndSettle();

    // 6. Rola até o botão "Cadastrar" e submete
    final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
    await tester.ensureVisible(botaoCadastrar);
    await tester.pumpAndSettle();

    await tester.tap(botaoCadastrar);

    // 7. Aguarda transição para a GenerosCadastroScreen
    await esperar(tester, find.byType(GenerosCadastroScreen));
    expect(find.byType(GenerosCadastroScreen), findsOneWidget);

    // 8. Seleciona os gêneros musicais nos Switches
    final switchRock = find.descendant(
      of: find.ancestor(
        of: find.text('Rock'),
        matching: find.byType(Row),
      ),
      matching: find.byType(Switch),
    );
    await tester.tap(switchRock);
    await tester.pumpAndSettle();

    final switchPop = find.descendant(
      of: find.ancestor(
        of: find.text('Pop'),
        matching: find.byType(Row),
      ),
      matching: find.byType(Switch),
    );
    await tester.tap(switchPop);
    await tester.pumpAndSettle();

    // 9. Toca em "Confirmar"
    final botaoConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
    await tester.ensureVisible(botaoConfirmar);
    await tester.pumpAndSettle();
    await tester.tap(botaoConfirmar);

    // 10. Aguarda transição para TelaInicialScreen
    await esperar(tester, find.byType(TelaInicialScreen));
    expect(find.byType(TelaInicialScreen), findsOneWidget);

    // 11. Valida a persistência no Auth e no Firestore
    final currentUser = FirebaseAuth.instance.currentUser;
    expect(currentUser, isNotNull);
    expect(currentUser!.email, emailNovo);

    final userDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(currentUser.uid)
        .get();

    expect(userDoc.exists, isTrue);
    final userData = userDoc.data()!;
    expect(userData['nome'], nomeNovo);
    expect(userData['email'], emailNovo);
    expect(userData['generos_favoritos'], containsAll(['Rock', 'Pop']));
  });
}

```
