<!-- Resposta do Gemini 3.8 Flash ao reparo 3, rodada FASE3-C3-FS, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome).
     Conversa: https://gemini.google.com/app/e87be200ec6e288c -->

**Classificação:** (A) o teste presume um comportamento que não é o especificado.

---

### Causa Exata da Falha

O erro ocorre por conta da lógica do finder no helper `preencherCampoPorLabel`:

```dart
final campoFinder = find.descendant(
  of: find.ancestor(of: labelFinder, matching: find.byType(Column)).first,
  matching: find.byType(TextFormField),
);

```

Na árvore de widgets do Flutter, `find.ancestor(..., matching: find.byType(Column))` encontra todos os nós ancestrais do tipo `Column` a partir do `Text(label)` em direção à raiz da árvore.

O método `.first` do `Finder` retorna o primeiro elemento retornado pela busca estrutural. Em árvores de layout com containers pais (como a `Column` principal do formulário dentro do `Card`), o ancestral `Column` retornado pelo `.first` ou a resolução de descendentes de `Column` acaba englobando múltiplos `TextFormField`.

Quando `find.descendant(of: ..., matching: find.byType(TextFormField))` é resolvido com múltiplos campos descendentes, o método `tester.enterText(campoFinder, ...)` seleciona o **primeiro** `TextFormField` daquele subconjunto. Como resultado, em várias chamadas subsequentes (inclusive a de E-mail), o texto digitado acabou substituindo o valor do primeiro campo do formulário (`_nomeController`).

### Solução

Para garantir que o texto seja digitado estritamente no campo correspondente a cada label, sem depender de índices globais e sem colidir com `Column` ancestrais de níveis superiores:

1. Localizamos o `Text(label)`.
2. Buscamos o nó do tipo `TextFormField` que é irmão imediato (ou que compartilha exatamente o container pai `Column` com 2 filhos: o rótulo e o campo), ou usamos uma abordagem direta baseada na ordem de foco/tabulação sequencial dos campos do formulário.

Abaixo está o teste corrigido.

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

    /// Localiza e preenche o TextFormField correspondente ao rótulo exato.
    /// Em `_buildTextField`, o TextFormField é sempre o campo subsequente
    /// ao rótulo dentro do mesmo Column de 2 filhos.
    Future<void> preencherCampo(String label, String valor) async {
      final labelFinder = find.text(label);
      await tester.dragUntilVisible(
        labelFinder,
        scrollFinder,
        const Offset(0, -60),
      );
      await tester.pumpAndSettle();

      // Encontra a Column imediata que encapsula o label e o TextFormField
      final columnFinder = find.ancestor(
        of: labelFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is Column && widget.children.length == 3,
        ),
      );

      final campoFinder = find.descendant(
        of: columnFinder.first,
        matching: find.byType(TextFormField),
      );

      await tester.enterText(campoFinder, valor);
      await tester.pumpAndSettle();
    }

    final String emailTeste =
        'novo_usuario_${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

    // 3. Preenche cada campo nominalmente
    await preencherCampo('Nome', 'Carlos Silva');
    await preencherCampo('Data de Nascimento', '15101995'); // Formata para 15/10/1995
    await preencherCampo('E-mail', emailTeste);
    await preencherCampo('Senha', 'senhaSegura123');
    await preencherCampo('Confirmar Senha', 'senhaSegura123');
    await preencherCampo('CEP', '50000000'); // Formata para 50000-000
    await preencherCampo('Rua', 'Rua das Flores');
    await preencherCampo('Número', '123');
    await preencherCampo('Bairro', 'Boa Viagem');
    await preencherCampo('Cidade', 'Recife');

    // 4. Seleciona o Estado no DropdownButtonFormField
    final dropdownFinder = find.byType(DropdownButtonFormField<String>);
    await tester.dragUntilVisible(
      dropdownFinder,
      scrollFinder,
      const Offset(0, -60),
    );
    await tester.pumpAndSettle();

    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    final itemPE = find.widgetWithText(DropdownMenuItem<String>, 'PE').last;
    final dropdownScrollable = find.byType(Scrollable).last;
    await tester.scrollUntilVisible(
      itemPE,
      100.0,
      scrollable: dropdownScrollable,
    );
    await tester.pumpAndSettle();

    await tester.tap(itemPE, warnIfMissed: false);
    await tester.pumpAndSettle();

    // 5. Rola até o botão "Cadastrar" e aciona o submit
    final btnCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
    await tester.dragUntilVisible(
      btnCadastrar,
      scrollFinder,
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();

    await tester.tap(btnCadastrar);

    // 6. Aguarda a criação da conta e o redirecionamento para GenerosCadastroScreen
    await esperar(tester, find.byType(GenerosCadastroScreen));
    expect(find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget);

    // 7. Seleciona os gêneros musicais (Rock e Pop)
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

    // 8. Confirma a seleção dos gêneros
    final btnConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
    await tester.tap(btnConfirmar);

    // 9. Valida o redirecionamento para a TelaInicialScreen
    await esperar(tester, find.byType(TelaInicialScreen));
    expect(find.byType(TelaInicialScreen), findsOneWidget);

    // 10. Asserções diretas no Firestore para confirmar os dados salvos
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
    expect(dados['endereco']['rua'], 'Rua das Flores');
    expect(dados['endereco']['numero'], '123');
    expect(dados['endereco']['bairro'], 'Boa Viagem');
    expect(dados['endereco']['cidade'], 'Recife');
    expect(dados['endereco']['estado'], 'PE');

    final List<dynamic> generosSalvos = dados['generos_favoritos'];
    expect(generosSalvos, containsAll(['Rock', 'Pop']));
  });
}

```