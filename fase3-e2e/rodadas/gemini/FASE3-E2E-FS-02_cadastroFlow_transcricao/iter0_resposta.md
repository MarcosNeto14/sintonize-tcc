<!-- Resposta do Gemini 3.8 Flash à geração (iteração 0), rodada FASE3-E2E-FS-02_cadastroFlow, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta, capturado na página. Envio e cópia automatizados (Claude in Chrome).
     Conversa: https://gemini.google.com/app/cd8e8c7ebedc2dec -->

Aqui está a implementação do teste *end-to-end* com `integration_test`, cobrindo o fluxo completo de cadastro de usuário e seleção de gêneros musicais no app **Sintonize**:

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
    // Dados para o novo usuário
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final emailNovo = 'novo_usuario_$timestamp@sintonize.test';
    const senhaNova = 'senhaForte123';
    const nomeNovo = 'Carlos Silva';

    // 1. Inicia a aplicação
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 2. Na tela inicial de boas-vindas, clica no botão "Cadastro"
    final botaoIrParaCadastro = find.widgetWithText(ElevatedButton, 'Cadastro');
    expect(botaoIrParaCadastro, findsOneWidget);
    await tester.tap(botaoIrParaCadastro);
    await tester.pumpAndSettle();

    // 3. Garante que chegou na tela CadastroScreen
    expect(find.byType(CadastroScreen), findsOneWidget);

    // 4. Preenche os campos do formulário de cadastro
    // Campos: Nome, Data de Nasc, E-mail, Senha, Confirmação, CEP, Rua, Número, Bairro, Cidade
    final textFields = find.byType(TextFormField);

    await tester.enterText(textFields.at(0), nomeNovo); // Nome
    await tester.enterText(textFields.at(1), '15101995'); // Data Nascimento (com formatter dd/mm/aaaa)
    await tester.enterText(textFields.at(2), emailNovo); // E-mail
    await tester.enterText(textFields.at(3), senhaNova); // Senha
    await tester.enterText(textFields.at(4), senhaNova); // Confirmar Senha
    await tester.enterText(textFields.at(5), '50000000'); // CEP (com formatter)

    // Preenche o restante do endereço
    await tester.enterText(textFields.at(6), 'Rua das Flores'); // Rua
    await tester.enterText(textFields.at(7), '123'); // Número
    await tester.enterText(textFields.at(8), 'Centro'); // Bairro
    await tester.enterText(textFields.at(9), 'Recife'); // Cidade

    // Rola para baixo se necessário para interagir com o Dropdown e o botão
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    // Seleciona o Estado no DropdownButtonFormField
    final dropdownEstado = find.byType(DropdownButtonFormField<String>);
    await tester.tap(dropdownEstado);
    await tester.pumpAndSettle();

    // Toca na opção "PE" da lista suspensa
    final itemEstado = find.widgetWithText(DropdownMenuItem<String>, 'PE').last;
    await tester.tap(itemEstado);
    await tester.pumpAndSettle();

    // Submete o cadastro clicando em "Cadastrar"
    final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
    await tester.tap(botaoCadastrar);

    // 5. Aguarda a transição e a validação no Firebase Auth/Firestore
    await esperar(tester, find.byType(GenerosCadastroScreen));
    expect(find.byType(GenerosCadastroScreen), findsOneWidget);

    // 6. Seleciona gêneros musicais ativando os switches
    // Localiza e clica no Switch ao lado de 'Rock'
    final rockRow = find.ancestor(
      of: find.text('Rock'),
      matching: find.byType(Row),
    );
    final switchRock = find.descendant(
      of: rockRow,
      matching: find.byType(Switch),
    );
    await tester.tap(switchRock);
    await tester.pumpAndSettle();

    // Localiza e clica no Switch ao lado de 'Pop'
    final popRow = find.ancestor(
      of: find.text('Pop'),
      matching: find.byType(Row),
    );
    final switchPop = find.descendant(
      of: popRow,
      matching: find.byType(Switch),
    );
    await tester.tap(switchPop);
    await tester.pumpAndSettle();

    // 7. Confirma os gêneros selecionados
    final botaoConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
    await tester.tap(botaoConfirmar);

    // 8. Aguarda o redirecionamento para TelaInicialScreen
    await esperar(tester, find.byType(TelaInicialScreen));
    expect(find.byType(TelaInicialScreen), findsOneWidget);

    // 9. Validação de persistência real nos emuladores (Auth e Firestore)
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

### Destaques da Solução:

1. **Ambiente Real & Helper:** Conecta-se aos emuladores por meio de `setupFirebaseEmulators()` no `setUpAll()`.
2. **Formatação e Máscaras:** Campos como *Data de Nascimento* e *CEP* são alimentados com dígitos crus, permitindo que os `inputFormatters` nativos do formulário apliquem a formatação esperada sem inconsistências.
3. **Resolução de Rolagem:** Realiza *drag* na `SingleChildScrollView` para garantir a visibilidade dos elementos fora da visualização inicial (como o Dropdown de estados e o botão "Cadastrar").
4. **Targeting Preciso dos Switches:** Usa `find.ancestor` e `find.descendant` para localizar com precisão o componente `Switch` correspondente aos textos "Rock" e "Pop".
5. **Verificação de Backend:** Além de validar que o app alcançou a `TelaInicialScreen`, inspeciona diretamente o `FirebaseAuth.instance.currentUser` e o documento recém-gravado em `usuarios/{uid}` no Firestore para validar a consistência dos dados gravados.
