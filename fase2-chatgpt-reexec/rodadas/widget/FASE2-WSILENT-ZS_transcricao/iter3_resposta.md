**Classificação: (A) — o teste está usando uma API que não existe no `LoginScreen` atualmente compilado.**

 O erro é direto:

```
No named parameter with the name 'telaInicialBuilder'
```

 O teste que forneci anteriormente pressupunha a aplicação já modificada com o parâmetro `telaInicialBuilder`, mas o seu `lib/login.dart` continua com o construtor original. Portanto, **não é uma falha de comportamento da aplicação nem devemos enfraquecer as asserções**.

 Como você quer testar o código atual, a melhor correção é **não exigir nenhuma alteração em `login.dart`**. Podemos resolver o problema do Firebase no teste inicializando o Firebase e usando a infraestrutura adequada para o `TelaInicialScreen`.

 No entanto, há um detalhe importante: o teste de login válido não precisa testar toda a implementação de `TelaInicialScreen`. O objetivo é verificar o `LoginScreen` após uma autenticação bem-sucedida. Como o código atual acopla diretamente a navegação à tela real, precisamos impedir que a construção dessa tela torne o teste dependente do Firebase global.

 A alternativa mais simples, sem modificar `login.dart`, é testar o resultado da autenticação **antes de deixar o Flutter construir a nova tela**. Em vez de `pumpAndSettle()`, podemos aguardar apenas a conclusão da operação assíncrona e verificar `mockAuth.currentUser`. Depois disso, o Navigator pode continuar seu trabalho.

 Substitua **somente o teste de login válido** por:

 Teste de login válido sem modificar login.dart

```
testWidgets(
  'deve realizar login com credenciais válidas',
  (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await preencherFormulario(tester);

    await tester.tap(find.text('Entrar'));

    // Processa o Future retornado pelo signInWithEmailAndPassword,
    // mas não usa pumpAndSettle(), pois a tela seguinte depende
    // de FirebaseAuth.instance.
    await tester.pump();

    expect(
      mockAuth.currentUser,
      isNotNull,
    );

    expect(
      mockAuth.currentUser!.email,
      'usuario@email.com',
    );
  },
);
```

 E **remova** da função `createTestWidget()` o parâmetro `telaInicialBuilder`. Ela deve voltar a ser:

 createTestWidget compatível com login.dart atual

```
Widget createTestWidget() {
  return MaterialApp(
    home: LoginScreen(
      auth: mockAuth,
    ),
  );
}
```

 ### Mas há uma questão importante

 Se, mesmo com `pump()` em vez de `pumpAndSettle()`, o Flutter construir imediatamente `TelaInicialScreen` e o erro `[core/no-app]` aparecer, então o problema não está mais na asserção do teste: o `LoginScreen` atual possui um acoplamento que impede testar o caminho de sucesso isoladamente.

 Nesse caso, a solução tecnicamente correta é a pequena alteração que mencionei anteriormente em `login.dart`:

```
final Widget Function() telaInicialBuilder;
```

 com uma implementação padrão para `TelaInicialScreen`.

 Isso permitiria ao teste fazer:

```
LoginScreen(
  auth: mockAuth,
  telaInicialBuilder: () => const Scaffold(
    body: Text('Tela inicial de teste'),
  ),
)
```

 **Mas essa alteração precisa realmente existir no `lib/login.dart`.** O erro atual confirma que ela não foi aplicada. Não é correto simplesmente colocar o parâmetro no teste e esperar que ele exista.

 ### Sobre o segundo problema, o botão de cadastro

 O erro anterior:

```
Offset(400.0, 664.0) ... outside the bounds of the root
Size(800.0, 600.0)
```

 é **A** e continua sendo resolvido no teste:

```
final cadastroButton = find.text(
  'Não tem cadastro? Cadastre-se!',
);

await tester.ensureVisible(cadastroButton);
await tester.tap(cadastroButton);
await tester.pumpAndSettle();

expect(
  find.byType(CadastroScreen),
  findsOneWidget,
);
```

 Isso não reduz a asserção. O teste continua exigindo que o `CadastroScreen` seja realmente aberto; apenas garante que o botão esteja dentro da viewport antes de clicar.

 ### Resumo

 - **Erro atual (`telaInicialBuilder`): A** — o teste foi escrito para uma versão modificada de `LoginScreen`, mas seu código ainda é o original.
- **Erro anterior de `Firebase.instance`:** decorrente do acoplamento da tela seguinte ao Firebase global; não deve ser mascarado.
- **Botão de cadastro fora da viewport: A** — use `ensureVisible()`.
- **Mensagens `user-not-found`/`wrong-password`:** continuam preservadas exatamente como estão em `login.dart`; não devemos alterar as expectativas do teste para esconder essa possível inconsistência da aplicação.