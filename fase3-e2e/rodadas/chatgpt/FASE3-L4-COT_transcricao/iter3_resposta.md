## Classificação: **(B) — o teste capturou um comportamento potencialmente incorreto da aplicação**

 Neste ponto, **não devemos enfraquecer a asserção**.

 O requisito é explícito: com as credenciais válidas, a aplicação deve navegar de `LoginScreen` para `TelaInicialScreen`. O código da `LoginScreen` também deixa isso explícito:

```
await firebaseAuth.signInWithEmailAndPassword(
  email: email,
  password: senha,
);

Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const TelaInicialScreen(),
  ),
);
```

 Portanto, o teste:

```
expect(find.byType(TelaInicialScreen), findsOneWidget);
```

 está verificando exatamente o comportamento especificado.

 O fato de ele encontrar **zero** `TelaInicialScreen`, enquanto todos os demais testes continuam passando, é evidência de que há algum comportamento real no caminho de sucesso que precisa ser investigado.

 ### Comportamento observado

 Com:

```
tester@sintonize.test
senha123
```

 o teste não encontra `TelaInicialScreen` após:

```
await tester.pumpAndSettle();
```

 Enquanto isso:

 - validações locais passam;
- `user-not-found` passa;
- senha incorreta passa.

 Isso é particularmente importante: o fluxo de erro está funcionando, mas o fluxo de sucesso não está chegando ao estado esperado.

 ### Comportamento esperado

 O fluxo deveria ser:

```
HomeScreen
   ↓ Login
LoginScreen
   ↓ Entrar
Firebase Auth Emulator
   ↓ autenticação bem-sucedida
Navigator.pushReplacement(...)
   ↓
TelaInicialScreen
```

 Não devemos trocar a asserção por algo como `find.text(...)`, aumentar indiscriminadamente o timeout ou aceitar que a `LoginScreen` continue visível.

---

 ## O próximo passo deve ser diagnosticar o ponto exato da falha

 Há uma informação que o teste atual não captura: **qual é a tela que está realmente na árvore depois do login?**

 Precisamos distinguir pelo menos estes casos:

 1. `signInWithEmailAndPassword` não completou;
2. Auth autenticou, mas a navegação não aconteceu;
3. a navegação aconteceu, mas `TelaInicialScreen` foi removida por alguma exceção;
4. `TelaInicialScreen` foi construída, mas houve algum problema durante sua inicialização;
5. o `FirebaseAuth.instance` usado pela tela não está no mesmo estado/configuração esperado pelo teste.

 Como não devemos modificar a aplicação, podemos melhorar temporariamente o diagnóstico **no próprio teste**, sem enfraquecer a asserção.

 Por exemplo, altere o teste de sucesso para registrar o estado da árvore quando a expectativa falhar:

```
testWidgets(
  'E2E - login válido navega para TelaInicialScreen',
  (tester) async {
    await abrirLogin(tester);

    await preencherLogin(
      tester,
      email: 'tester@sintonize.test',
      senha: 'senha123',
    );

    await tocarEntrar(tester);

    await tester.pumpAndSettle();

    final telaInicial = find.byType(TelaInicialScreen);

    if (telaInicial.evaluate().isEmpty) {
      debugPrint('===== DIAGNÓSTICO DO FLUXO DE LOGIN =====');
      debugPrint(
        'LoginScreen: ${find.text('Entrar').evaluate().length}',
      );
      debugPrint(
        'HomeScreen: ${find.text('Bem-vindo ao Sintonize!').evaluate().length}',
      );
      debugPrint(
        'SnackBars: ${find.byType(SnackBar).evaluate().length}',
      );

      final snackBars = find.byType(SnackBar);
      for (final element in snackBars.evaluate()) {
        debugPrint('SnackBar encontrado: ${element.widget}');
      }

      debugPrint('=========================================');
    }

    // NÃO enfraquecer esta asserção.
    // O requisito é que o login válido navegue para TelaInicialScreen.
    expect(
      telaInicial,
      findsOneWidget,
    );
  },
);
```

 Isso ainda mantém o teste correto: se a tela não aparecer, **o teste continua falhando**. O diagnóstico apenas nos dará informação adicional sobre onde o fluxo terminou.

 ### Mas há uma investigação ainda mais importante

 Eu recomendo também verificar diretamente o estado do Auth Emulator **depois do login**, porque isso separa uma falha de autenticação de uma falha de navegação.

 Adicione ao arquivo:

```
import 'package:firebase_auth/firebase_auth.dart';
```

 e, antes da asserção:

```
final currentUser = FirebaseAuth.instance.currentUser;

debugPrint(
  'Usuário autenticado após login: ${currentUser?.email}',
);

debugPrint(
  'UID após login: ${currentUser?.uid}',
);
```

 Então teremos três informações fundamentais:

```
Usuário autenticado após login: tester@sintonize.test
UID após login: <uid>
TelaInicialScreen: 0
```

 Se aparecer esse resultado, teremos uma evidência muito forte de que **o Firebase Auth funcionou e o problema está depois da autenticação**, e não no teste de credenciais.

 Se, ao contrário, aparecer:

```
Usuário autenticado após login: null
```

 apesar de não haver `SnackBar` de erro, teremos de investigar a configuração/instância do Firebase no processo de teste.

---

 ### Um detalhe que merece atenção

 Seu `main.dart` contém:

```
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

 enquanto o teste faz:

```
await setupFirebaseEmulators();
```

 e depois:

```
tester.pumpWidget(const MyApp());
```

 Isso é correto **desde que o `Firebase.initializeApp()` do helper seja a inicialização efetivamente usada pelo aplicativo**. Como o helper faz:

```
FirebaseAuth.instance.useAuthEmulator(...)
FirebaseFirestore.instance.useFirestoreEmulator(...)
```

 antes de montar `MyApp`, essa ordem é importante.

 Portanto, neste momento eu **não alteraria o helper nem as telas**. Primeiro precisamos confirmar se o Auth está autenticado quando a asserção de navegação falha.

 O resultado de:

```
FirebaseAuth.instance.currentUser
```

 é a próxima evidência decisiva. Se houver usuário autenticado e `TelaInicialScreen` continuar ausente, aí a investigação deve se concentrar no `Navigator.pushReplacement`/construção da tela inicial, e **não no teste**.