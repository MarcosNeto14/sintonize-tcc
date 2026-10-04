## 1\. Análise do fluxo

 O aplicativo inicia na `HomeScreen`, onde o usuário toca em **Login** para chegar à `LoginScreen`. Nessa tela, o formulário valida e-mail e senha localmente; somente se a validação passar é feita a chamada `FirebaseAuth.signInWithEmailAndPassword`. Em caso de autenticação bem-sucedida, a `LoginScreen` é substituída pela `TelaInicialScreen`, que imediatamente consulta dados do usuário e músicas no Firestore; em caso de falha do Firebase, a própria `LoginScreen` permanece visível e apresenta um `SnackBar` vermelho com a mensagem correspondente ao código retornado. Não existe indicador de loading explícito na `LoginScreen`, portanto o teste não deve esperar por um widget de loading que não existe.

 ## 2\. Dependências e estado inicial

 ### `HomeScreen`

 - **Firebase Auth:** não utiliza.
- **Firestore:** não utiliza.
- **Dados prévios:** nenhum.
- **Dependência adicional:** asset `assets/logo-sintoniza.png`.
- **Ação:** toque em `Login` navega para `LoginScreen`.

 ### `LoginScreen`

 - **Firebase Auth:** usa `FirebaseAuth.instance.signInWithEmailAndPassword`.
- **Firestore:** não acessa.
- **Dados prévios necessários no Auth:**
  - e-mail: `tester@sintonize.test`
  - senha: `senha123`
- **Validação local antes do Firebase:**
  - e-mail vazio → `Por favor, insira seu e-mail`
  - e-mail inválido → `Por favor, insira um e-mail válido`
  - senha vazia → `Por favor, insira sua senha`
  - senha com menos de 6 caracteres → `A senha deve ter pelo menos 6 caracteres`
- **Erros tratados do Firebase:**
  - `user-not-found`
  - `wrong-password`
  - `invalid-credential`
  - qualquer outro código → mensagem genérica.

 ### `TelaInicialScreen`

 Após login bem-sucedido, a tela usa:

 - **Firebase Auth**
  - `FirebaseAuth.instance.currentUser` para obter o UID.
- **Firestore**
  - lê `usuarios/{uid}` para obter `nome`;
  - lê novamente `usuarios/{uid}` para verificar `historico_musicas` e gêneros favoritos;
  - se não houver histórico, lê `musica`;
  - filtra as músicas pelos gêneros `rock` e `pop`;
  - grava `historico_musicas` e `musica_recomendada` em `usuarios/{uid}`.

 Estado inicial fornecido para o teste:

```
Auth:
tester@sintonize.test / senha123

usuarios/{uid}:
nome: tester sintonize
generos_favoritos: ['rock', 'pop']

musica:
bohemian rhapsody / queen / rock
billie jean / michael jackson / pop
take five / dave brubeck / jazz
the thrill is gone / b.b. king / blues
one love / bob marley / reggae
```

 Como `historico_musicas` não é informado no estado inicial, a primeira entrada na `TelaInicialScreen` deverá buscar uma música `rock` ou `pop` e gravar o resultado no documento do usuário.

 ## 3\. Caminho de navegação e sincronização

 O caminho principal é:

```
HomeScreen
   ↓ toca "Login"
LoginScreen
   ↓ preenche e-mail + senha
   ↓ toca "Entrar"
Firebase Auth
   ↓ sucesso
TelaInicialScreen
   ↓ inicialização
Firestore
   ├─ lê usuarios/{uid}
   ├─ lê musica
   └─ atualiza usuarios/{uid}
```

 Nos testes, a sequência recomendada é:

 1. Inicializar `IntegrationTestWidgetsFlutterBinding`.
2. Executar `setupFirebaseEmulators()` no `setUpAll()`.
3. Executar `runApp(const MyApp())`.
4. Esperar a `HomeScreen` através do texto `Bem-vindo ao Sintonize!`.
5. Tocar em `Login`.
6. Usar `pumpAndSettle()` para aguardar a transição da rota.
7. Localizar os `TextFormField` da tela de login.
8. Preencher os dados.
9. Tocar em `Entrar`.
10. Em sucesso, aguardar `TelaInicialScreen` indiretamente por um texto produzido por ela, como `tester sintonize, essa é a nossa recomendação de música para você!`, ou aguardar um dos textos de música.
11. Em erro do Firebase, aguardar o `SnackBar` e verificar sua mensagem.
12. Nos casos de validação, verificar as mensagens dos validadores e confirmar que a tela não saiu da `LoginScreen`.

 Há uma particularidade importante: **não é necessário e nem desejável chamar `main()` no teste**. O `main()` da aplicação faz `Firebase.initializeApp()` antes do helper poder apontar os serviços para os emuladores. O teste deve chamar `setupFirebaseEmulators()` primeiro e depois montar `MyApp()` diretamente.

 ## 4. Cenários de teste

 ### Sucesso ponta a ponta

 - Abrir `HomeScreen`.
- Tocar em `Login`.
- Preencher `tester@sintonize.test` / `senha123`.
- Tocar em `Entrar`.
- Auth deve autenticar.
- `LoginScreen` deve ser removida da pilha.
- `TelaInicialScreen` deve aparecer.
- Firestore deve ser consultado.
- Como não há histórico inicialmente, uma música `rock` ou `pop` deve ser apresentada.
- O documento `usuarios/{uid}` deve receber `historico_musicas` e `musica_recomendada`.

 ### Validação: e-mail vazio

 - Não deve chamar Firebase.
- Deve mostrar `Por favor, insira seu e-mail`.
- Deve continuar na `LoginScreen`.

 ### Validação: e-mail inválido

 - Não deve chamar Firebase.
- Deve mostrar `Por favor, insira um e-mail válido`.
- Deve continuar na `LoginScreen`.

 ### Validação: senha vazia

 - Não deve chamar Firebase.
- Deve mostrar `Por favor, insira sua senha`.
- Deve continuar na `LoginScreen`.

 ### Validação: senha curta

 - Não deve chamar Firebase.
- Deve mostrar `A senha deve ter pelo menos 6 caracteres`.
- Deve continuar na `LoginScreen`.

 ### Firebase: usuário inexistente

 - E-mail válido, mas não cadastrado.
- Firebase deve retornar `user-not-found`.
- Deve permanecer na `LoginScreen`.
- Deve mostrar o `SnackBar` vermelho com a mensagem correspondente.

 ### Firebase: senha incorreta

 - Usar o usuário existente.
- Informar senha incorreta com pelo menos seis caracteres.
- Esperar `wrong-password` no Firebase Emulator.
- Deve permanecer na `LoginScreen`.
- Deve mostrar a mensagem correspondente.

 ### Firebase: `invalid-credential`

 Existe código na tela para esse caso, mas **o fluxo fornecido não possui uma operação de UI que permita determinar de maneira confiável um `FirebaseAuthException` com código `invalid-credential`**. Dependendo da versão do Firebase Auth/SDK, uma credencial inválida pode ser reportada como `wrong-password` ou `invalid-credential`. Como você pediu um E2E sem mocks e sem modificar as telas, não é correto fabricar esse código no teste.

 Da mesma forma, não há um caminho determinístico, somente pela interface apresentada, para provocar cada possível código arbitrário que cairia no `else` genérico.

 ### Loading

 A `LoginScreen` não possui estado visual de loading. Portanto, não há um cenário de teste que possa validar um spinner, texto `Carregando...` ou botão desabilitado durante `signInWithEmailAndPassword`. O `Carregando...` existente pertence à `FutureBuilder` da `TelaInicialScreen` e diz respeito à leitura do nome no Firestore, não à autenticação.

---

 ## 5\. Testes E2E

 Abaixo está o arquivo completo sugerido:

 `integration_test/fase3/login_e2e_test.dart`

```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> abrirLogin(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  }

  Future<void> preencherLogin(
    WidgetTester tester, {
    required String email,
    required String senha,
  }) async {
    final campos = find.byType(TextFormField);

    expect(campos, findsNWidgets(2));

    await tester.enterText(campos.at(0), email);
    await tester.enterText(campos.at(1), senha);
  }

  Future<void> tocarEntrar(WidgetTester tester) async {
    await tester.tap(find.text('Entrar'));
  }

  testWidgets(
    'E2E - login válido navega para TelaInicial e carrega recomendação',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: 'senha123',
      );

      await tocarEntrar(tester);

      // Aguarda a autenticação e a navegação para a tela inicial.
      await tester.pumpAndSettle();

      // A TelaInicialScreen faz uma leitura assíncrona do nome do usuário.
      expect(
        find.text(
          'Tester Sintonize, essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // Como o estado inicial não possui historico_musicas, a tela
      // deve encontrar uma música pertencente aos gêneros rock ou pop.
      final musicasEsperadas = <String>[
        'Bohemian Rhapsody',
        'Billie Jean',
      ];

      final encontrouMusica = musicasEsperadas.any(
        (musica) => find.text(musica).evaluate().isNotEmpty,
      );

      expect(
        encontrouMusica,
        isTrue,
        reason:
            'A TelaInicialScreen deveria apresentar uma música de rock ou pop.',
      );
    },
  );

  testWidgets(
    'E2E - e-mail vazio mostra erro de validação sem acessar Firebase',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: '',
        senha: 'senha123',
      );

      await tocarEntrar(tester);
      await tester.pump();

      expect(
        find.text('Por favor, insira seu e-mail'),
        findsOneWidget,
      );

      // Continua na LoginScreen.
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Esqueci minha senha'), findsOneWidget);
    },
  );

  testWidgets(
    'E2E - e-mail inválido mostra erro de validação sem acessar Firebase',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'email-invalido',
        senha: 'senha123',
      );

      await tocarEntrar(tester);
      await tester.pump();

      expect(
        find.text('Por favor, insira um e-mail válido'),
        findsOneWidget,
      );

      expect(find.text('Entrar'), findsOneWidget);
    },
  );

  testWidgets(
    'E2E - senha vazia mostra erro de validação sem acessar Firebase',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: '',
      );

      await tocarEntrar(tester);
      await tester.pump();

      expect(
        find.text('Por favor, insira sua senha'),
        findsOneWidget,
      );

      expect(find.text('Entrar'), findsOneWidget);
    },
  );

  testWidgets(
    'E2E - senha com menos de seis caracteres mostra erro de validação',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: '12345',
      );

      await tocarEntrar(tester);
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );

      expect(find.text('Entrar'), findsOneWidget);
    },
  );

  testWidgets(
    'E2E - usuário inexistente mostra SnackBar de user-not-found',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'usuario-inexistente@sintonize.test',
        senha: 'senha123',
      );

      await tocarEntrar(tester);

      // signInWithEmailAndPassword é assíncrono.
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Usuário não encontrado. Verifique o e-mail e tente novamente.',
        ),
        findsOneWidget,
      );

      // A navegação não deve ocorrer em caso de erro.
      expect(find.text('Entrar'), findsOneWidget);
    },
  );

  testWidgets(
    'E2E - senha incorreta mostra SnackBar de wrong-password',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: 'senha-incorreta',
      );

      await tocarEntrar(tester);

      await tester.pumpAndSettle();

      expect(
        find.text(
          'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
        ),
        findsOneWidget,
      );

      // O usuário continua na LoginScreen.
      expect(find.text('Entrar'), findsOneWidget);
    },
  );
}
```

 ### Observação importante sobre isolamento dos testes

 Há um detalhe relevante para esse arquivo ser realmente **E2E contra os emuladores**, e não um teste com estado compartilhado acidentalmente.

 Os testes de validação são independentes do estado do Firebase. Já os testes de autenticação dependem do usuário pré-populado. O teste de sucesso, por sua vez, **modifica o Firestore**, adicionando `historico_musicas` e `musica_recomendada`.

 Portanto, se todos os testes forem executados no mesmo processo contra o mesmo estado dos emuladores, a premissa de que `historico_musicas` está vazio pode deixar de ser verdadeira depois do primeiro teste de sucesso. Isso não impede o login, mas muda o comportamento da recomendação.

 Como o ambiente informado reinicia/popula os emuladores **antes de cada execução do arquivo**, e não necessariamente antes de cada `testWidgets`, a versão acima não deve depender de `historico_musicas` vazio para validar a autenticação. Para tornar o teste de sucesso ainda mais robusto, a asserção principal deve ser a presença da `TelaInicialScreen`; a música pode ser verificada como pertencente ao conjunto permitido, sem exigir que o documento ainda esteja no estado inicial.

 Também vale notar que o teste de `wrong-password` pressupõe que a versão do Firebase Auth Emulator utilizada pelo projeto devolve exatamente esse código. Se a versão instalada devolver `invalid-credential` para senha incorreta, o comportamento observado estará de acordo com o `catch` da aplicação, mas a asserção específica deverá ser ajustada para esse código — **não seria correto adicionar um mock apenas para forçar `wrong-password`**, pois isso violaria a exigência de E2E real.