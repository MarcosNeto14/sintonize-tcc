## Classificação: **(A)**

 A falha continua sendo causada por uma **suposição incorreta do teste**, não por um comportamento incorreto da aplicação.

 O `DropdownButtonFormField` contém os 27 estados. Ao abrir o dropdown, porém, o menu tem altura limitada pelo viewport. O item `PE` não necessariamente está entre os itens atualmente renderizados/visíveis do menu. Por isso:

```
find.text('PE')
```

 retorna zero naquele momento.

 O teste anterior assumiu que **todos os `DropdownMenuItem`s estariam simultaneamente disponíveis para o finder**, o que não é garantido para um menu rolável.

 A correção é: abrir o dropdown e **rolar o `Scrollable` do próprio menu até `PE` ficar visível**, em vez de simplesmente procurar `PE` imediatamente.

 Há ainda uma melhoria importante: não precisamos procurar `PE` antes de verificar se o menu abriu. Podemos localizar o `DropdownButtonFormField`, tocá-lo, identificar o `Scrollable` adicional criado pelo menu e então fazer a rolagem.

 Substitua a função `preencherCadastro` pela versão abaixo:

 Correção da seleção do estado no teste

```
Future<void> preencherCadastro(WidgetTester tester) async {
  final campos = find.byType(TextFormField);

  expect(campos, findsNWidgets(10));

  // Nome
  await tester.enterText(
    campos.at(0),
    'Maria da Silva',
  );

  // Data de nascimento
  await tester.enterText(
    campos.at(1),
    '01011990',
  );

  // E-mail
  await tester.enterText(
    campos.at(2),
    'maria@example.com',
  );

  // Senha
  await tester.enterText(
    campos.at(3),
    '123456',
  );

  // Confirmar senha
  await tester.enterText(
    campos.at(4),
    '123456',
  );

  // CEP.
  //
  // A aplicação dispara o ViaCEP quando o valor chega a 9 caracteres.
  // O flutter_test bloqueia HTTP real, então não dependemos da resposta
  // dessa chamada.
  await tester.enterText(
    campos.at(5),
    '50000-000',
  );

  await tester.pump();

  // Preenche os campos manualmente para que o documento criado pelo
  // cadastro tenha valores determinísticos.
  await tester.enterText(
    campos.at(6),
    'Rua das Flores',
  );

  await tester.enterText(
    campos.at(7),
    '123',
  );

  await tester.enterText(
    campos.at(8),
    'Centro',
  );

  await tester.enterText(
    campos.at(9),
    'Recife',
  );

  // ---------------------------------------------------------------
  // Seleção do estado
  // ---------------------------------------------------------------

  final dropdown = find.byType(
    DropdownButtonFormField<String>,
  );

  expect(dropdown, findsOneWidget);

  // O dropdown fica abaixo da área inicialmente visível.
  await tester.scrollUntilVisible(
    dropdown,
    300,
    scrollable: find.byType(Scrollable).first,
  );

  await tester.pumpAndSettle();

  // Abre o menu.
  await tester.tap(dropdown);

  await tester.pumpAndSettle();

  // O DropdownButton abre um menu em uma rota/overlay própria.
  //
  // Nesse momento o "PE" pode não estar entre os widgets renderizados,
  // porque o menu possui rolagem própria.
  final estadoPE = find.text('PE');

  // Localiza o Scrollable do menu aberto.
  //
  // O primeiro Scrollable continua sendo o SingleChildScrollView
  // da CadastroScreen. O último corresponde ao menu do Dropdown.
  final scrollables = find.byType(Scrollable);

  expect(
    scrollables,
    findsAtLeastNWidgets(2),
  );

  final menuScrollable = scrollables.last;

  // Rola o menu até PE ficar visível.
  await tester.scrollUntilVisible(
    estadoPE,
    100,
    scrollable: menuScrollable,
  );

  await tester.pumpAndSettle();

  expect(
    estadoPE,
    findsOneWidget,
  );

  // Seleciona Pernambuco.
  await tester.tap(estadoPE);

  await tester.pumpAndSettle();
}
```

 ### Por que essa versão resolve o erro

 A sequência agora é:

```
CadastroScreen
    ↓
rolar SingleChildScrollView
    ↓
DropdownButtonFormField fica visível
    ↓
abrir dropdown
    ↓
menu cria seu próprio Scrollable
    ↓
rolar o menu
    ↓
PE fica visível
    ↓
tocar PE
```

 O ponto fundamental é que existem **dois contextos de rolagem diferentes**:

```
find.byType(Scrollable).first
```

 é o `SingleChildScrollView` da tela de cadastro.

 Depois de abrir o dropdown, o:

```
find.byType(Scrollable).last
```

 é usado para o menu do dropdown.

 ### Sobre o warning do ViaCEP

 O warning de HTTP é esperado com a implementação atual de `CadastroScreen`, porque ela faz uma requisição real dentro de `_fetchAddressFromCEP()`:

```
final response = await http.get(url);
```

 O `flutter_test` não permite que essa chamada saia para a internet. Isso **não é a causa da falha atual** — o teste está falhando antes, na seleção de `PE`.

 Também não recomendo simplesmente colocar `warnIfMissed: false` nos `tap()`. Isso esconderia uma interação que realmente não aconteceu. O objetivo do teste é garantir que o fluxo possa ser executado de fato.

 Com essa alteração, os dois testes que estavam falhando em `preencherCadastro()` — o fluxo feliz e o cenário de erro do Firebase Auth — passam a usar a mesma estratégia correta para selecionar `PE`.
