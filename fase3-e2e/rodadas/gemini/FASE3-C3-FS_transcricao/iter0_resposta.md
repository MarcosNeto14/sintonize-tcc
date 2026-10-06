<!-- Resposta do Gemini 3.8 Flash à geração (iteração 0), rodada FASE3-C3-FS, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome).
     Conversa: https://gemini.google.com/app/e87be200ec6e288c -->

Aqui está o teste end-to-end completo em Dart utilizando o pacote `integration_test`, cobrindo o fluxo desde a tela inicial, passando pelo formulário de cadastro na `CadastroScreen`, seleção de gêneros na `GenerosCadastroScreen` e validação da chegada à `TelaInicialScreen` com os dados persistidos no Firestore.

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

  /// Aguarda até que o widget especificado pelo [finder] apareça na árvore de widgets.
  Future<void> esperar(WidgetTester tester, Finder finder, {int tentativas = 40}) async {
    for (var i = 0; i < tentativas; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('Elemento não encontrado a tempo: $finder');
  }

  testWidgets(
      'cadastro: cria conta no Auth/Firestore, seleciona generos e conclui cadastro',
      (tester) async {
    // 1. Inicializa a aplicação
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 2. Navega da HomeScreen para a CadastroScreen
    final btnCadastroHome = find.widgetWithText(ElevatedButton, 'Cadastro');
    expect(btnCadastroHome, findsOneWidget);
    await tester.tap(btnCadastroHome);
    await tester.pumpAndSettle();

    expect(find.byType(CadastroScreen), findsOneWidget);

    // Gera um e-mail único para evitar conflitos no Firebase Auth
    final String emailTeste =
        'novo_usuario_${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

    // 3. Preenche os campos do formulário de cadastro
    // Campos de texto na ordem de exibição do formulário:
    // 0: Nome
    // 1: Data de Nascimento
    // 2: E-mail
    // 3: Senha
    // 4: Confirmar Senha
    // 5: CEP
    // 6: Rua
    // 7: Número
    // 8: Bairro
    // 9: Cidade
    final textFields = find.byType(TextFormField);

    await tester.enterText(textFields.at(0), 'Carlos Silva');
    await tester.enterText(textFields.at(1), '15101995'); // Formatador insere as barras -> 15/10/1995
    await tester.enterText(textFields.at(2), emailTeste);
    await tester.enterText(textFields.at(3), 'senhaSegura123');
    await tester.enterText(textFields.at(4), 'senhaSegura123');
    await tester.enterText(textFields.at(5), '50000000'); // Formatador insere o hífen -> 50000-000

    // Rola a tela para garantir que os campos inferiores e o botão estejam visíveis
    final scrollFinder = find.byType(SingleChildScrollView).first;
    await tester.drag(scrollFinder, const Offset(0, -350));
    await tester.pumpAndSettle();

    await tester.enterText(textFields.at(6), 'Rua das Flores');
    await tester.enterText(textFields.at(7), '123');
    await tester.enterText(textFields.at(8), 'Boa Viagem');
    await tester.enterText(textFields.at(9), 'Recife');

    // Seleciona o Estado no Dropdown
    final dropdownFinder = find.byType(DropdownButtonFormField<String>);
    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    final itemPE = find.widgetWithText(DropdownMenuItem<String>, 'PE').last;
    await tester.tap(itemPE);
    await tester.pumpAndSettle();

    // Rola até o botão "Cadastrar" e submete o formulário
    final btnCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
    await tester.dragUntilVisible(
      btnCadastrar,
      scrollFinder,
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();

    await tester.tap(btnCadastrar);

    // 4. Aguarda a criação da conta e redirecionamento para GenerosCadastroScreen
    await esperar(tester, find.byType(GenerosCadastroScreen));
    expect(find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget);

    // 5. Seleciona os gêneros musicais (Rock e Pop)
    // Localiza os switches correspondentes dentro dos Cards de cada gênero
    final rockCard = find.ancestor(
      of: find.text('Rock'),
      matching: find.byType(Card),
    );
    final popCard = find.ancestor(
      of: find.text('Pop'),
      matching: find.byType(Card),
    );

    final switchRock = find.descendant(of: rockCard, matching: find.byType(Switch));
    final switchPop = find.descendant(of: popCard, matching: find.byType(Switch));

    await tester.tap(switchRock);
    await tester.pumpAndSettle();

    await tester.tap(switchPop);
    await tester.pumpAndSettle();

    // 6. Confirma os gêneros selecionados
    final btnConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
    await tester.tap(btnConfirmar);

    // 7. Valida o redirecionamento para a TelaInicialScreen
    await esperar(tester, find.byType(TelaInicialScreen));
    expect(find.byType(TelaInicialScreen), findsOneWidget);

    // 8. Asserção no Firestore: confirma se os dados e gêneros foram salvos corretamente
    final currentUser = FirebaseAuth.instance.currentUser;
    expect(currentUser, isNotNull);
    expect(currentUser!.email, emailTeste);

    final userDoc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(currentUser.uid)
        .get();

    expect(userDoc.exists, isTrue);
    final dados = userDoc.data()!;
    expect(dados['nome'], 'Carlos Silva');
    expect(dados['email'], emailTeste);
    expect(dados['data_nasc'], '15/10/1995');
    expect(dados['endereco']['cidade'], 'Recife');
    expect(dados['endereco']['estado'], 'PE');

    // Valida os gêneros gravados pelo método _salvarGeneros()
    final List<dynamic> generosSalvos = dados['generos_favoritos'];
    expect(generosSalvos, containsAll(['Rock', 'Pop']));
  });
}

```

### Detalhes da implementação:

* **E-mail dinâmico:** Usa timestamp para garantir unicidade a cada execução contra o emulador de Auth.
* **Scroll e Gestos:** Utiliza `tester.drag` e `tester.dragUntilVisible` no `SingleChildScrollView` para garantir a interatividade dos campos e botões mesmo em telas com resoluções menores.
* **Formatação de inputs:** A data `15101995` e o CEP `50000000` são inseridos já considerando a máscara automática dos `TextInputFormatter` implementados nas telas.
* **Asserção em banco real:** Confirma tanto na UI (transição para `TelaInicialScreen`) quanto diretamente no emulador do Firestore a integridade do documento criado em `usuarios/{uid}` com os campos de endereço e a lista `generos_favoritos: ['Rock', 'Pop']`.