## Classificação: **(A) o teste presume um comportamento que não é o especificado**

 A falha é de **compilação do teste**, não de comportamento da aplicação. O problema está nesta linha:

```
expect(find.byType(app.TelaInicialScreen), findsOneWidget);
```

 `TelaInicialScreen` é definida em `lib/tela-inicial.dart`. O fato de `main.dart` importar essa classe **não faz com que ela seja exportada pelo namespace de `main.dart`**. Portanto, `app.TelaInicialScreen` não existe.

 O teste deve importar diretamente:

```
import 'package:sintonize/tela-inicial.dart';
```

 e usar:

```
find.byType(TelaInicialScreen)
```

 Não há nenhuma evidência aqui de problema na aplicação, então não precisamos enfraquecer nenhuma asserção.

 ## Correção

 No arquivo `integration_test/fase3/p2_cot_test.dart`, altere os imports para incluir `tela-inicial.dart`:

 Correção dos imports e da asserção

```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart' as app;
import 'package:sintonize/tela-inicial.dart';

import '../firebase_test_helper.dart';
```

 E altere somente a asserção:

```
expect(find.byType(TelaInicialScreen), findsOneWidget);
```

 Portanto, o trecho da função `fazerLogin()` fica:

 Função fazerLogin corrigida

```
Future<void> fazerLogin(WidgetTester tester) async {
  expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);

  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();

  expect(find.text('Entrar'), findsOneWidget);

  final camposTexto = find.byType(TextFormField);
  expect(camposTexto, findsNWidgets(2));

  await tester.enterText(
    camposTexto.at(0),
    'tester@sintonize.test',
  );

  await tester.enterText(
    camposTexto.at(1),
    'senha123',
  );

  await tester.tap(find.text('Entrar'));
  await tester.pumpAndSettle();

  expect(find.byType(TelaInicialScreen), findsOneWidget);
}
```

 ### Por que isso resolve

 `main.dart` contém:

```
import 'tela-inicial.dart';
```

 mas isso apenas disponibiliza `TelaInicialScreen` **dentro da biblioteca `main.dart`**. Não cria uma API pública equivalente a:

```
app.TelaInicialScreen
```

 no arquivo de teste.

 Já o import:

```
import 'package:sintonize/tela-inicial.dart';
```

 traz diretamente a classe definida naquele arquivo, permitindo:

```
find.byType(TelaInicialScreen)
```

 Os demais testes que usam `app.MyApp()` continuam corretos, porque `MyApp` é realmente declarado em `main.dart`.

 **Essa correção não reduz o escopo nem altera o comportamento esperado do teste.** Depois dela, o teste deve avançar para a execução real no emulador; eventuais erros seguintes devem ser analisados separadamente, sem mascará-los.