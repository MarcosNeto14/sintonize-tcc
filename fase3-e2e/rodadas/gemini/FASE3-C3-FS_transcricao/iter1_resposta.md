<!-- Resposta do Gemini 3.8 Flash ao reparo 1 (reenviado com ' .' após erro genérico), rodada FASE3-C3-FS, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome).
     Conversa: https://gemini.google.com/app/e87be200ec6e288c -->

**Classificação:** (A) o teste presume um comportamento que não é o especificado.

---

### Diagnóstico da Falha

A falha decorre de uma suposição incorreta do teste sobre a ordem dos campos retornados por `find.byType(TextFormField)`.

No código de `CadastroScreen`, a árvore de widgets organiza os campos usando `Row` e `Column`:

1. Na primeira linha (`Row`):
* Primeiro `Expanded`: `_buildTextField('Nome', _nomeController, ...)`
* Segundo `Expanded`: `_buildTextField('Data de Nascimento', _dataNascController, ...)`


2. Abaixo da linha:
* `_buildTextField('E-mail', _emailController, ...)`


3. Na linha seguinte (`Row`):
* Primeiro `Expanded`: `_buildTextField('Senha', _senhaController, ...)`
* Segundo `Expanded`: `_buildTextField('Confirmar Senha', _confSenhaController, ...)`


4. Demais campos (CEP, Rua, Número, Bairro, Cidade).

No entanto, o teste utilizou índices numéricos arbitrários com `find.byType(TextFormField).at(...)`. Como o Flutter constrói e visita a árvore de widgets, além do scroll e das divisões em `Row`/`Column`, o e-mail acabou sendo inserido no `_nomeController` (observado pelo erro: `Expected: 'Carlos Silva', Actual: 'novo_usuario_...@sintonize.test'`).

Além disso, o menu suspenso (`DropdownButtonFormField`) causou o aviso de *hit test*:

```
Warning: A call to tap() with finder ... derived an Offset (...) that would not hit test on the specified widget.

```

Isso ocorre porque a lista suspensa com 27 estados ultrapassa a área visível da tela ou exige scroll interno no menu pop-up. Uma abordagem muito mais estável e idiomática em testes do Flutter é localizar os campos de texto pelo seu label descritivo ou chave/ancestral direto, e garantir o scroll explícito até o item do dropdown ou usar um estado que já esteja visível.

---

### Teste Corrigido

Aqui está a versão corrigida do teste. Para eliminar a ambiguidade dos índices, criamos um helper `digitarNoCampo(label, texto)` que busca o `TextFormField` diretamente associado ao respectivo `Text(label)`. Além disso, o toque no item do dropdown foi ajustado para garantir visibilidade:

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
    // 1. Inicializa o aplicativo
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 2. Navega da HomeScreen para CadastroScreen
    final btnCadastroHome = find.widgetWithText(ElevatedButton, 'Cadastro');
    expect(btnCadastroHome, findsOneWidget);
    await tester.tap(btnCadastroHome);
    await tester.pumpAndSettle();

    expect(find.byType(CadastroScreen), findsOneWidget);

    final scrollFinder = find.byType(SingleChildScrollView).first;

    // Helper robusto para preencher campos buscando pelo Label acima do TextFormField
    Future<void> preencherCampoPorLabel(String label, String valor) async {
      final labelFinder = find.text(label);
      await tester.dragUntilVisible(
        labelFinder,
        scrollFinder,
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      final campoFinder = find.descendant(
        of: find.ancestor(of: labelFinder, matching: find.byType(Column)).first,
        matching: find.byType(TextFormField),
      );

      await tester.enterText(campoFinder, valor);
      await tester.pumpAndSettle();
    }

    final String emailTeste =
        'novo_usuario_${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

    // 3. Preenche cada campo nominalmente
    await preencherCampoPorLabel('Nome', 'Carlos Silva');
    await preencherCampoPorLabel('Data de Nascimento', '15101995'); // Gera 15/10/1995 via formatter
    await preencherCampoPorLabel('E-mail', emailTeste);
    await preencherCampoPorLabel('Senha', 'senhaSegura123');
    await preencherCampoPorLabel('Confirmar Senha', 'senhaSegura123');
    await preencherCampoPorLabel('CEP', '50000000'); // Gera 50000-000 via formatter
    await preencherCampoPorLabel('Rua', 'Rua das Flores');
    await preencherCampoPorLabel('Número', '123');
    await preencherCampoPorLabel('Bairro', 'Boa Viagem');
    await preencherCampoPorLabel('Cidade', 'Recife');

    // Seleciona o Estado no DropdownButtonFormField
    final dropdownFinder = find.byType(DropdownButtonFormField<String>);
    await tester.dragUntilVisible(
      dropdownFinder,
      scrollFinder,
      const Offset(0, -50),
    );
    await tester.pumpAndSettle();

    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    // Rola a lista interna do Dropdown caso 'PE' esteja fora do viewport inicial do popup
    final itemPE = find.widgetWithText(DropdownMenuItem<String>, 'PE').last;
    final dropdownList = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      itemPE,
      100.0,
      scrollable: dropdownList,
    );
    await tester.pumpAndSettle();

    await tester.tap(itemPE, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Rola até o botão "Cadastrar" e aciona o submit
    final btnCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
    await tester.dragUntilVisible(
      btnCadastrar,
      scrollFinder,
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();

    await tester.tap(btnCadastrar);

    // 4. Aguarda criação da conta e redirecionamento para a tela de gêneros
    await esperar(tester, find.byType(GenerosCadastroScreen));
    expect(find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget);

    // 5. Seleciona os gêneros musicais (Rock e Pop)
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

    // 6. Confirma a seleção de gêneros
    final btnConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
    await tester.tap(btnConfirmar);

    // 7. Confirma a transição para a TelaInicialScreen
    await esperar(tester, find.byType(TelaInicialScreen));
    expect(find.byType(TelaInicialScreen), findsOneWidget);

    // 8. Asserções diretas no Firestore para confirmar integridade dos dados gravados
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

    final List<dynamic> generosSalvos = dados['generos_favoritos'];
    expect(generosSalvos, containsAll(['Rock', 'Pop']));
  });
}

```