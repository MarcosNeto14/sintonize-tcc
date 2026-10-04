**Classificação: (B) — o teste capturou um comportamento potencialmente incorreto da aplicação/ambiente.**

 Não vou alterar a asserção para fazê-la passar.

 ## Comportamento observado

 Com:

 - `tester@sintonize.test`
- `senha123`

 o teste:

 1. inicializa os emuladores no `setUpAll()`;
2. monta `MyApp`;
3. navega pela `HomeScreen` até `LoginScreen`;
4. preenche as credenciais;
5. toca em `Entrar`;
6. espera até 10 segundos;
7. **nunca encontra nenhum elemento da `TelaInicialScreen`**.

 Os quatro outros cenários passam.

 Isso é relevante porque o problema não é mais apenas uma condição de corrida com `fetchUserName()`.

 ## Comportamento esperado

 O código de `LoginScreen` especifica explicitamente:

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

 Portanto, para `tester@sintonize.test` \+ `senha123`, considerando que esse usuário realmente foi populado no Auth Emulator antes da execução, o fluxo esperado é:

```
LoginScreen
    │
    │ signInWithEmailAndPassword()
    ▼
Firebase Auth Emulator
    │
    │ sucesso
    ▼
Navigator.pushReplacement()
    │
    ▼
TelaInicialScreen
```

 A `TelaInicialScreen` constrói sua `BottomNavigationBar` imediatamente. As consultas ao Firestore acontecem posteriormente e **não são pré-requisito para a construção dessa barra**.

 Assim, o fato de nenhum destes elementos aparecer:

```
Pesquisa Direta
Sintonizados
Mapa
Minha Conta
```

 durante 10 segundos indica que o fluxo não chegou à `TelaInicialScreen`.

 ## Por que não devemos modificar o teste

 Não seria correto trocar a asserção por algo mais fraco, por exemplo:

```
expect(find.byType(Scaffold), findsOneWidget);
```

 Isso poderia fazer o teste passar enquanto ele ainda estivesse na `LoginScreen`.

 Também não devemos simplesmente aumentar:

```
10 segundos → 30 segundos → 60 segundos
```

 porque não existe no código da aplicação uma operação que justifique uma espera desse tipo antes da navegação.

 O teste está verificando exatamente o comportamento especificado: **autenticação válida → navegação para `TelaInicialScreen`**.

 ## O ponto que precisa ser investigado

 Agora precisamos descobrir o que aconteceu com esta chamada:

```
await firebaseAuth.signInWithEmailAndPassword(
  email: email,
  password: senha,
);
```

 Há duas possibilidades principais:

 ### 1\. O Firebase Auth está rejeitando as credenciais

 Nesse caso, a aplicação entra neste trecho:

```
on FirebaseAuthException catch (e) {
  ...
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.red,
    ),
  );
}
```

 O teste atual não mostra qual `e.code` foi recebido no cenário de sucesso.

 Se isso estiver acontecendo, o problema provavelmente está na **população/configuração do Auth Emulator**, por exemplo:

 - o usuário não existe no emulator usado pelo aplicativo;
- o usuário existe com outra senha;
- o aplicativo e o helper estão apontando para emuladores diferentes;
- o estado do emulator não é o esperado no momento da execução.

 ### 2\. O Firebase Auth aceita as credenciais, mas a navegação não ocorre

 Nesse caso teríamos evidência de um problema no próprio fluxo da aplicação, porque `Navigator.pushReplacement()` está imediatamente depois do `await`.

 Esse seria um problema real de comportamento da aplicação e o teste **não deveria ser enfraquecido para contorná-lo**.

 ## Como diagnosticar sem enfraquecer o teste

 A próxima execução deve registrar explicitamente o estado do Auth Emulator antes do teste de UI. Isso não substitui o teste E2E nem transforma o teste em mock; serve apenas para confirmar que o pré-requisito fornecido pelo ambiente realmente existe.

 Por exemplo, no próprio teste podemos consultar o usuário através do `FirebaseAuth.instance` **antes de montar a UI**, verificando se o ambiente contém o usuário esperado.

 Se essa verificação disser que `tester@sintonize.test` não existe, encontramos a causa: **o problema está no processo de população/reset do Auth Emulator**, não no teste.

 Se o usuário existir, o próximo diagnóstico deve capturar o resultado real da tentativa de login e determinar se o problema está entre:

```
Auth Emulator → signInWithEmailAndPassword()
```

 ou:

```
signInWithEmailAndPassword() → Navigator.pushReplacement()
```

 **Neste momento, portanto, eu não recomendo uma nova versão "corrigida" do teste.** O log já demonstra uma falha de comportamento que o teste foi justamente criado para detectar; alterar a asserção agora esconderia essa falha em vez de corrigi-la.