<!-- Resposta do Gemini 3.8 Flash ao reparo 1, rodada FASE3-C3-COT, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome), segunda máquina (DESKTOP-6ETPO2H).
     Conversa: https://gemini.google.com/app/ac10df8022157b89 -->

### Classificação da Causa Provável da Falha

**Classificação: (A) O teste presume um comportamento que não é o especificado (com nuances de sincronização e posicionamento em testes de integração de telas longas).**

---

### Diagnóstico Detalhado das Falhas

1. **Cenário 1 (Linha 75 e 114)**:
* **Hit-test no Dropdown**: A lista de estados tem 27 itens (`AC` a `TO`). O item `'PE'` está no meio/final da lista do menu suspenso aberto pelo Flutter. O finder `.last` localizou o item na árvore de elementos, mas o item estava fora da área visível do menu do dropdown (precisando de scroll dentro do menu ou tap com tolerância/visibilidade).
* **Texto na `TelaInicialScreen**`: O texto esperado no teste foi `essa é a nossa recomendação de música para você!`. Contudo, ao analisar `TelaInicialScreen`:
```dart
FutureBuilder<String>(
  future: fetchUserName(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Text('Carregando...');
    }
    if (snapshot.hasError) {
      return const Text('Erro ao carregar');
    }
    return Text('${_formatName(snapshot.data!)}, essa é a nossa recomendação de música para você!');
  }
)

```


O teste cadastrou o nome como `'Usuario Teste'`. A tela formata e exibe `Usuario Teste, essa é a nossa recomendação de música para você!`. Além disso, a `fetchUserName()` é assíncrona, e caso a sincronização com o Firestore no emulador leve frações de segundo a mais ou ocorra delay de layout, a tela ainda está no estado `'Carregando...'` quando o `pumpAndSettle` retorna, ou o widget não terminou de hidratar o `FutureBuilder`.


2. **Cenário 4 (Linha 209)**:
* No Cenário 4, o teste tentou cadastrar `tester@sintonize.test`, mas não preencheu o campo de estado (`DropdownButtonFormField`), deixando-o nulo ou incompleto, ou a validação síncrona/formatação impediu o submit.
* Mais crucial: na tela `CadastroScreen`, o campo CEP possui `onChanged`:
```dart
onChanged: (value) {
  if (value.length == 9) {
    _fetchAddressFromCEP(value.replaceAll('-', ''));
  }
}

```


Ao digitar `50000000`, a máscara formata para `50000-000` (tamanho 9) e dispara uma requisição HTTP real para `[https://viacep.com.br/ws/50000000/json/](https://viacep.com.br/ws/50000000/json/)`. Se essa chamada falha ou demora no emulador, ela abre uma SnackBar (`Erro ao buscar CEP` ou `Erro: ...`), substituindo a SnackBar do Firebase ou prendendo a fila de microtarefas.
* Ao testar erro de Firebase Auth no emulador com `tester@sintonize.test`, após tocar em Cadastrar, é necessário aguardar o `pump()` e esperar o SnackBar aparecer de forma resiliente, pois o `FirebaseAuthException` é assíncrono.


3. **Cenário 5 (Linha 254)**:
* No Cenário 5, após o cadastro, o app tenta navegar para `GenerosCadastroScreen`. O cadastro depende da resposta do emulador Auth e Firestore. Como a criação de conta no cenário 5 foi disparada sem aguardar a transição real, o teste tentou tocar em "Confirmar" antes mesmo de estar na `GenerosCadastroScreen`.
* Além disso, o botão "Confirmar" em `GenerosCadastroScreen` está abaixo de uma lista com altura de `50%` da tela (`MediaQuery.of(context).size.height * 0.5`) dentro de um `SingleChildScrollView`. O botão "Confirmar" estava fora da tela (off-screen) e não recebeu o toque, não disparando o `_confirmar()` que exibiria o `SnackBar('Selecione pelo menos um gênero musical!')`.



---

### Correção do Teste

Abaixo está o arquivo de teste corrigido, ajustando:

1. A rolagem explícita com `tester.dragUntilVisible` e `tester.ensureVisible` em todos os botões e campos dentro de `SingleChildScrollView`.
2. O preenchimento resiliente dos campos sem disparar consultas acidentais de rede ou contornando seleções longas do Dropdown (selecionando um item do topo visível, ex: `'BA'` ou `'CE'`).
3. A espera explícita pelo término dos `Futures` de rede dos emuladores e pela renderização dos componentes assíncronos.

```dart
// ===== integration_test/fase3/c3_cot_test.dart =====
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';
import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  /// Helper para aguardar a aparição de um finder com timeout
  Future<void> waitFor(WidgetTester tester, Finder finder,
      {Duration timeout = const Duration(seconds: 10)}) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    expect(finder, findsOneWidget);
  }

  /// Helper para navegar da HomeScreen até a CadastroScreen
  Future<void> navigateToCadastro(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final cadastroBtn = find.widgetWithText(ElevatedButton, 'Cadastro');
    expect(cadastroBtn, findsOneWidget);

    await tester.tap(cadastroBtn);
    await tester.pumpAndSettle();

    expect(find.byType(CadastroScreen), findsOneWidget);
  }

  group('Fluxo E2E: Cadastro de Usuário e Seleção de Gêneros', () {
    testWidgets(
        'Cenário 1: Sucesso de ponta a ponta (Cadastro -> Gêneros -> Tela Inicial)',
        (WidgetTester tester) async {
      await navigateToCadastro(tester);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueEmail = 'novo_user_$timestamp@sintonize.test';
      final textFields = find.byType(TextFormField);

      // Preenchimento dos dados pessoais
      await tester.enterText(textFields.at(0), 'Marcos Silva');
      await tester.enterText(textFields.at(1), '15101998');
      await tester.enterText(textFields.at(2), uniqueEmail);
      await tester.enterText(textFields.at(3), 'senhaSegura123');
      await tester.enterText(textFields.at(4), 'senhaSegura123');

      // Scroll gradual para os campos de endereço
      final scrollable = find.byType(SingleChildScrollView).first;

      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.enterText(textFields.at(5), '50000000');
      await tester.enterText(textFields.at(6), 'Rua das Flores');
      await tester.enterText(textFields.at(7), '123');
      await tester.enterText(textFields.at(8), 'Boa Viagem');
      await tester.enterText(textFields.at(9), 'Recife');

      // Seleciona um estado próximo do topo da lista para evitar overflow fora da tela
      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Opção 'BA' é visível de imediato no popup
      final estadoOpcao = find.widgetWithText(DropdownMenuItem<String>, 'BA').last;
      await tester.tap(estadoOpcao);
      await tester.pumpAndSettle();

      // Rola até o botão Cadastrar
      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.dragUntilVisible(
        cadastrarBtn,
        scrollable,
        const Offset(0, -50),
      );
      await tester.pumpAndSettle();

      await tester.tap(cadastrarBtn);

      // Aguarda criação do usuário no Firebase Auth + Firestore e transição de tela
      await waitFor(tester, find.byType(GenerosCadastroScreen));
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      // Marca gêneros musicais (Rock e Pop)
      final switches = find.byType(Switch);
      expect(switches, findsWidgets);

      await tester.tap(switches.at(0));
      await tester.pumpAndSettle();
      await tester.tap(switches.at(1));
      await tester.pumpAndSettle();

      // Rola a tela até o botão "Confirmar"
      final generosScrollable = find.byType(SingleChildScrollView);
      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');

      await tester.dragUntilVisible(
        confirmarBtn,
        generosScrollable,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      await tester.tap(confirmarBtn);

      // Aguarda gravação no Firestore e navegação para a TelaInicialScreen
      await waitFor(tester, find.byType(TelaInicialScreen));
      await tester.pumpAndSettle();

      // Aguarda resolução do FutureBuilder com o nome do usuário
      final recomendacaoFinder =
          find.textContaining('essa é a nossa recomendação de música para você!');
      await waitFor(tester, recomendacaoFinder);

      expect(recomendacaoFinder, findsOneWidget);
    });

    testWidgets(
        'Cenário 2: Erros de validação síncrona com campos obrigatórios vazios',
        (WidgetTester tester) async {
      await navigateToCadastro(tester);

      final scrollable = find.byType(SingleChildScrollView).first;
      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');

      await tester.dragUntilVisible(
        cadastrarBtn,
        scrollable,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      // Validações disparadas pelo _formKey
      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);

      expect(find.byType(CadastroScreen), findsOneWidget);
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets(
        'Cenário 3: Validação de regras de formato e divergência de senha',
        (WidgetTester tester) async {
      await navigateToCadastro(tester);

      final textFields = find.byType(TextFormField);
      final scrollable = find.byType(SingleChildScrollView).first;

      await tester.enterText(textFields.at(0), 'Marcos 123');
      await tester.enterText(textFields.at(1), '32132026');
      await tester.enterText(textFields.at(2), 'email-invalido');
      await tester.enterText(textFields.at(3), '123');
      await tester.enterText(textFields.at(4), '999');

      await tester.drag(scrollable, const Offset(0, -200));
      await tester.pumpAndSettle();

      await tester.enterText(textFields.at(5), '1234');
      await tester.enterText(textFields.at(7), 'abc');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.dragUntilVisible(
        cadastrarBtn,
        scrollable,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      expect(find.text('O nome não pode conter números ou caracteres especiais'),
          findsOneWidget);
      expect(find.text('Mês deve ser entre 01 e 12'), findsOneWidget);
      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget);
      expect(find.text('CEP inválido. Formato correto: XXXXX-XXX'),
          findsOneWidget);
      expect(find.text('O número deve ser numérico'), findsOneWidget);

      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 4: Erro do Firebase Auth (E-mail já cadastrado)',
        (WidgetTester tester) async {
      await navigateToCadastro(tester);

      final textFields = find.byType(TextFormField);
      final scrollable = find.byType(SingleChildScrollView).first;

      // Preenche com o e-mail pré-existente no emulador Auth
      await tester.enterText(textFields.at(0), 'Tester Conflito');
      await tester.enterText(textFields.at(1), '10101995');
      await tester.enterText(textFields.at(2), 'tester@sintonize.test');
      await tester.enterText(textFields.at(3), 'senha123');
      await tester.enterText(textFields.at(4), 'senha123');

      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.enterText(textFields.at(5), '50000000');
      await tester.enterText(textFields.at(6), 'Rua Principal');
      await tester.enterText(textFields.at(7), '100');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.dragUntilVisible(
        cadastrarBtn,
        scrollable,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      await tester.tap(cadastrarBtn);

      // Aguarda o processamento do FirebaseAuthException e exibição da SnackBar
      final snackBarFinder = find.textContaining('Erro ao cadastrar:');
      await waitFor(tester, snackBarFinder);

      expect(snackBarFinder, findsOneWidget);
      expect(find.byType(CadastroScreen), findsOneWidget);
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets(
        'Cenário 5: Erro de fluxo na seleção de gêneros (nenhum selecionado)',
        (WidgetTester tester) async {
      await navigateToCadastro(tester);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueEmail = 'sem_genero_$timestamp@sintonize.test';
      final textFields = find.byType(TextFormField);
      final scrollable = find.byType(SingleChildScrollView).first;

      await tester.enterText(textFields.at(0), 'Ana Santos');
      await tester.enterText(textFields.at(1), '20052000');
      await tester.enterText(textFields.at(2), uniqueEmail);
      await tester.enterText(textFields.at(3), 'senha123');
      await tester.enterText(textFields.at(4), 'senha123');

      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.enterText(textFields.at(5), '50000000');
      await tester.enterText(textFields.at(7), '42');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.dragUntilVisible(
        cadastrarBtn,
        scrollable,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      await tester.tap(cadastrarBtn);

      // Espera concluir a navegação até GenerosCadastroScreen
      await waitFor(tester, find.byType(GenerosCadastroScreen));
      await tester.pumpAndSettle();

      // Rola até o botão Confirmar sem selecionar nenhum switch
      final generosScrollable = find.byType(SingleChildScrollView);
      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');

      await tester.dragUntilVisible(
        confirmarBtn,
        generosScrollable,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      await tester.tap(confirmarBtn);
      await tester.pump(); // Renderiza o frame do SnackBar

      final alertaFinder = find.text('Selecione pelo menos um gênero musical!');
      await waitFor(tester, alertaFinder);

      expect(alertaFinder, findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
    });
  });
}

```
