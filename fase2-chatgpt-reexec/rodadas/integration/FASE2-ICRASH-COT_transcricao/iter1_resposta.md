## Classificação: **(A) o teste presume um comportamento que não é o especificado**

 A falha é causada pelo próprio teste: `whenCalling()` **não pertence ao Mockito**. Ele é fornecido pelo pacote `mock_exceptions`, que é usado internamente por `firebase_auth_mocks` e `fake_cloud_firestore` para configurar exceções em fakes. A documentação das versões usadas confirma que `whenCalling(...).on(...).thenThrow(...)` é a API prevista para isso.  Dart packages+1

 Portanto, **não há evidência aqui de um problema na aplicação** e não devemos remover os cenários de erro. A correção é importar explicitamente `mock_exceptions`.

 ### Correção

 Adicione este import ao teste:

```
import 'package:mock_exceptions/mock_exceptions.dart';
```

 Embora `mock_exceptions` esteja vindo como dependência transitiva das bibliotecas Firebase, o ideal é declará-lo explicitamente em `dev_dependencies`, já que o código do teste o importa diretamente:

```
dev_dependencies:
  mock_exceptions: ^0.8.2
```

 A versão exata pode ser ajustada ao `pubspec.lock` do projeto.

 A documentação do `firebase_auth_mocks` mostra exatamente esse padrão para fazer `createUserWithEmailAndPassword` lançar uma `FirebaseAuthException`.  Dart packages  O `fake_cloud_firestore` também documenta o mesmo mecanismo para `DocumentReference.set()` e `update()`.  Dart packages

 ## Substituições no teste

 Não é necessário alterar os cenários nem enfraquecer as asserções. Basta corrigir a configuração das exceções.

 ### 1\. Firebase Auth

 O trecho que estava assim:

```
whenCalling(
  Invocation.method(
    #createUserWithEmailAndPassword,
    null,
  ),
).on(auth).thenThrow(
  FirebaseAuthException(
    code: 'email-already-in-use',
    message: 'O e-mail já está em uso',
  ),
);
```

 pode permanecer **exatamente assim** depois do import de `mock_exceptions`.

 A API documentada suporta esse formato para configurar uma exceção independentemente dos parâmetros nomeados.  Dart packages

 ### 2\. Firestore `set`

 Este trecho também permanece:

```
final doc = firestore
    .collection('usuarios')
    .doc('usuario-erro');

whenCalling(
  Invocation.method(#set, null),
).on(doc).thenThrow(
  Exception('Firestore indisponível'),
);
```

 `FakeFirebaseFirestore` documenta explicitamente o uso de `whenCalling(...).on(doc).thenThrow(...)` para `set`.  Dart packages

 ### 3\. Firestore `update`

 E este:

```
final doc = firestore
    .collection('usuarios')
    .doc(user.uid);

whenCalling(
  Invocation.method(#update, null),
).on(doc).thenThrow(
  FirebaseException(
    plugin: 'cloud_firestore',
    code: 'unavailable',
    message: 'Firestore indisponível',
  ),
);
```

 também está de acordo com a API do `fake_cloud_firestore`, que suporta exceções simuladas em `update`.  Dart packages

 ## Importações finais

 No começo de `icrash_cot_test.dart`, deixe os imports relacionados assim:

```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';
```

 O `package:mockito/mockito.dart` **não é necessário para esses três `whenCalling()`**. `whenCalling` vem de `mock_exceptions`, não de Mockito.  Dart packages+1

 ### Depois disso

 Execute:

```
flutter pub get
flutter test test/fase2-chatgpt-reexec/integration/icrash_cot_test.dart
```

 Os três erros de compilação `Method not found: 'whenCalling'` devem desaparecer. Se surgir então uma falha de **execução** em algum dos testes, ela será uma questão diferente — especialmente nos cenários de Firestore e no E2E, onde podemos analisar o comportamento efetivo sem reduzir as asserções.