Abaixo está a análise e, em seguida, o arquivo de integração completo. O teste usa o aplicativo real, o Auth/Firestore Emulator e `testWidgets()`, sem mocks e sem alterar nenhuma tela. A abordagem segue o modelo oficial de testes de integração do Flutter e o uso do Auth Emulator via `useAuthEmulator()`.  Documentação Flutter+1

 ## 1\. Análise do fluxo

 O fluxo começa na `HomeScreen`, onde o usuário toca em **Login** e é levado à `LoginScreen` por uma transição de navegação. Na `LoginScreen`, os campos de e-mail e senha são validados localmente; somente se forem válidos é feita a chamada `signInWithEmailAndPassword()` ao Firebase Authentication. Em caso de sucesso, o aplicativo substitui a `LoginScreen` pela `TelaInicialScreen`, que imediatamente consulta o Firestore para obter o nome do usuário e seu histórico/gêneros e pode gerar uma nova recomendação musical. Em caso de erro do Firebase, permanece na `LoginScreen` e exibe um `SnackBar` vermelho com a mensagem correspondente ao código recebido.

 ## 2\. Dependências e dados dos emuladores

 ### `HomeScreen`

 - **Firebase Auth:** não utiliza.
- **Firestore:** não utiliza.
- Apenas navega para `LoginScreen`.

 ### `LoginScreen`

 - **Firebase Auth:** utiliza `FirebaseAuth.instance.signInWithEmailAndPassword()`.
- **Firestore:** não utiliza.
- Antes do teste, existe no Auth:
  - e-mail: `tester@sintonize.test`
  - senha: `senha123`
- Para erros:
  - `user-not-found` pode ser provocado usando um e-mail inexistente.
  - `wrong-password` pode ser provocado usando o usuário existente com senha incorreta.
  - `invalid-credential` é tratado pela tela, mas não há uma forma confiável de forçar especificamente esse código através desse formulário e do Auth Emulator sem alterar o código da aplicação. Portanto, não é correto inventar um teste determinístico para esse código.

 ### `TelaInicialScreen`

 Após autenticação bem-sucedida, usa tanto Auth quanto Firestore:

 - **Firebase Auth**
  - lê `FirebaseAuth.instance.currentUser`.
  - utiliza o UID do usuário autenticado.
- **Firestore**
  - lê `usuarios/{uid}` para obter `nome`.
  - lê `historico_musicas`.
  - lê `generos_favoritos`.
  - lê toda a coleção `musica`.
  - caso não haja histórico, seleciona uma música compatível.
  - grava `historico_musicas` e `musica_recomendada`.

 Dados existentes antes do teste:

```
usuarios/{uid}:
  nome: "tester sintonize"
  generos_favoritos: ["rock", "pop"]

musica:
  bohemian rhapsody / queen / rock
  billie jean / michael jackson / pop
  take five / dave brubeck / jazz
  the thrill is gone / b.b. king / blues
  one love / bob marley / reggae
```

 Como o documento inicial não informa `historico_musicas`, no primeiro login bem-sucedido a `TelaInicialScreen` deve procurar uma música de `rock` ou `pop` e gravar a recomendação.

 ## 3\. Caminho de navegação

 O caminho real é:

```
HomeScreen
   │
   │ toque em "Login"
   ▼
LoginScreen
   │
   │ preencher E-mail + Senha
   │
   │ toque em "Entrar"
   ▼
Firebase Auth Emulator
   │
   ├── sucesso ───────────────► TelaInicialScreen
   │                              │
   │                              ├─ lê usuarios/{uid}
   │                              ├─ lê musica
   │                              └─ atualiza histórico/recomendação
   │
   └── erro ──────────────────► LoginScreen
                                  │
                                  └─ SnackBar vermelho
```

 No teste, a espera deve acontecer em duas etapas:

 1. Depois de tocar em **Login**, `pumpAndSettle()` aguarda a transição `PageRouteBuilder`.
2. Depois de tocar em **Entrar**, `pumpAndSettle()` permite que a Future do Firebase termine e que a navegação ou o `SnackBar` sejam renderizados.
3. No caminho de sucesso, uma nova espera permite que as Futures do Firestore da `TelaInicialScreen` terminem.
4. No caminho de erro, o teste verifica o `SnackBar` e confirma que a `LoginScreen` continua visível.

 Um detalhe importante: **a tela não possui um indicador visual de loading**. Portanto, não há um estado `CircularProgressIndicator`, texto `"Carregando..."` da própria `LoginScreen` ou botão desabilitado para validar durante a autenticação. O estado `"Carregando..."` existente em `TelaInicialScreen` pertence à consulta do nome do usuário, não à autenticação.

 ## 4\. Cenários de teste

 - **Sucesso ponta a ponta**
  - Home → Login.
  - Preenchimento de credenciais válidas.
  - Autenticação no Auth Emulator.
  - Navegação para `TelaInicialScreen`.
  - Leitura do usuário no Firestore.
  - Leitura das músicas.
  - Criação da recomendação e atualização do histórico.
  - Exibição do nome e de uma música `rock` ou `pop`.
- **E-mail vazio**
  - A validação deve exibir `Por favor, insira seu e-mail`.
  - O Firebase não deve ser chamado.
  - A tela continua na `LoginScreen`.
- **E-mail inválido**
  - A validação deve exibir `Por favor, insira um e-mail válido`.
  - O Firebase não deve ser chamado.
- **Senha vazia**
  - A validação deve exibir `Por favor, insira sua senha`.
  - O Firebase não deve ser chamado.
- **Senha curta**
  - A validação deve exibir `A senha deve ter pelo menos 6 caracteres`.
  - O Firebase não deve ser chamado.
- **Usuário inexistente**
  - Auth Emulator retorna `user-not-found`.
  - A tela deve exibir o `SnackBar` vermelho correspondente.
- **Senha incorreta**
  - Auth Emulator deve retornar o erro de credencial/senha aplicável.
  - A aplicação deve permanecer na LoginScreen e exibir a mensagem correspondente.
  - O código atual contempla tanto `wrong-password` quanto `invalid-credential`; a resposta efetiva depende da versão do SDK/Emulator.
- **Loading da autenticação**
  - Não existe um estado visual de loading implementado em `LoginScreen`.
  - Portanto, o teste não deve procurar um spinner ou texto de carregamento inexistente.

---

 ## 5\. Testes completos

 Há uma particularidade importante no `main.dart`: ele próprio chama `Firebase.initializeApp()`. Como o requisito determina que `setupFirebaseEmulators()` seja executado antes de qualquer interação, o teste **não chama `main()`**. Em vez disso, importa `main.dart` para reutilizar `MyApp` e executa `runApp(const MyApp())` depois que o helper já inicializou Firebase e conectou os plugins aos emuladores. Isso evita inicializar o Firebase duas vezes. A inicialização explícita do Firebase antes de `runApp` é também o padrão documentado pelo Firebase para Flutter.  Firebase

 Arquivo:

 `integration_test/fase3/login_test.dart`

```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:sintonize/main.dart' as app;

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  setUp(() async {
    // Cada cenário começa sem uma sessão autenticada.
    await FirebaseAuth.instance.signOut();
  });

  Future<void> abrirLogin(WidgetTester tester) async {
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

  Future<void> iniciarAplicacao(WidgetTester tester) async {
    runApp(const app.MyApp());

    // Aguarda a HomeScreen ficar disponível.
    await tester.pumpAndSettle();
  }

  group('Login - fluxo ponta a ponta', () {
    testWidgets(
      'login válido navega para TelaInicial e carrega recomendação',
      (tester) async {
        await iniciarAplicacao(tester);

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'tester@sintonize.test',
          senha: 'senha123',
        );

        await tester.tap(find.text('Entrar'));

        // Aguarda a resposta do Auth Emulator e a navegação.
        await tester.pumpAndSettle();

        expect(
          find.textContaining(
            'essa é a nossa recomendação de música para você!',
          ),
          findsOneWidget,
        );

        // A TelaInicial consulta o Firestore para carregar o nome.
        expect(find.textContaining('Tester Sintonize'), findsOneWidget);

        // A recomendação é criada a partir dos gêneros rock/pop.
        final textosMusica = <String>[
          'Bohemian Rhapsody',
          'Billie Jean',
        ];

        expect(
          textosMusica.any(
            (texto) => find.text(texto).evaluate().isNotEmpty,
          ),
          isTrue,
          reason:
              'A recomendação deveria ser uma das músicas dos gêneros '
              'rock ou pop.',
        );

        // Confirma que a autenticação realmente ocorreu.
        final usuario = FirebaseAuth.instance.currentUser;

        expect(usuario, isNotNull);
        expect(usuario!.email, 'tester@sintonize.test');

        // A TelaInicial também grava a recomendação/histórico.
        final documento = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuario.uid)
            .get();

        expect(documento.exists, isTrue);

        final dados = documento.data()!;

        expect(dados['nome'], 'tester sintonize');
        expect(dados['generos_favoritos'], containsAll(<String>[
          'rock',
          'pop',
        ]));

        expect(dados['historico_musicas'], isNotNull);
        expect(dados['musica_recomendada'], isNotNull);

        final musicaRecomendada =
            Map<String, dynamic>.from(dados['musica_recomendada']);

        expect(
          <String>[
            'bohemian rhapsody',
            'billie jean',
          ],
          contains(musicaRecomendada['track_name']),
        );
      },
    );
  });

  group('Login - validações locais', () {
    testWidgets(
      'e-mail vazio não dispara Firebase e mostra validação',
      (tester) async {
        await iniciarAplicacao(tester);

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: '',
          senha: 'senha123',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsOneWidget,
        );

        expect(FirebaseAuth.instance.currentUser, isNull);
        expect(find.text('Entrar'), findsOneWidget);
      },
    );

    testWidgets(
      'e-mail inválido não dispara Firebase e mostra validação',
      (tester) async {
        await iniciarAplicacao(tester);

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'email-invalido',
          senha: 'senha123',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira um e-mail válido'),
          findsOneWidget,
        );

        expect(FirebaseAuth.instance.currentUser, isNull);
        expect(find.text('Entrar'), findsOneWidget);
      },
    );

    testWidgets(
      'senha vazia não dispara Firebase e mostra validação',
      (tester) async {
        await iniciarAplicacao(tester);

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'tester@sintonize.test',
          senha: '',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('Por favor, insira sua senha'),
          findsOneWidget,
        );

        expect(FirebaseAuth.instance.currentUser, isNull);
        expect(find.text('Entrar'), findsOneWidget);
      },
    );

    testWidgets(
      'senha com menos de seis caracteres não dispara Firebase',
      (tester) async {
        await iniciarAplicacao(tester);

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'tester@sintonize.test',
          senha: '12345',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pump();

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );

        expect(FirebaseAuth.instance.currentUser, isNull);
        expect(find.text('Entrar'), findsOneWidget);
      },
    );
  });

  group('Login - erros do Firebase', () {
    testWidgets(
      'usuário inexistente exibe SnackBar de usuário não encontrado',
      (tester) async {
        await iniciarAplicacao(tester);

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'naoexiste@sintonize.test',
          senha: 'senha123',
        );

        await tester.tap(find.text('Entrar'));

        // Aguarda a resposta real do Auth Emulator.
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
          ),
          findsOneWidget,
        );

        expect(
          find.byType(SnackBar),
          findsOneWidget,
        );

        expect(find.text('Entrar'), findsOneWidget);
        expect(FirebaseAuth.instance.currentUser, isNull);
      },
    );

    testWidgets(
      'senha incorreta exibe mensagem de erro de credencial',
      (tester) async {
        await iniciarAplicacao(tester);

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'tester@sintonize.test',
          senha: 'senha-incorreta',
        );

        await tester.tap(find.text('Entrar'));

        // Aguarda a resposta real do Auth Emulator.
        await tester.pumpAndSettle();

        final mensagemSenhaIncorreta = find.text(
          'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
        );

        final mensagemCredencialInvalida = find.text(
          'As credenciais fornecidas são inválidas. Tente novamente.',
        );

        // Dependendo da versão do Firebase Auth/Emulator, uma senha
        // incorreta pode chegar como "wrong-password" ou "invalid-credential".
        expect(
          mensagemSenhaIncorreta.evaluate().isNotEmpty ||
              mensagemCredencialInvalida.evaluate().isNotEmpty,
          isTrue,
          reason:
              'O Firebase deveria retornar wrong-password ou '
              'invalid-credential para as credenciais incorretas.',
        );

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Entrar'), findsOneWidget);
        expect(FirebaseAuth.instance.currentUser, isNull);
      },
    );
  });

  group('Login - estados intermediários', () {
    testWidgets(
      'durante uma tentativa de login a LoginScreen permanece até a resposta',
      (tester) async {
        await iniciarAplicacao(tester);

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'naoexiste@sintonize.test',
          senha: 'senha123',
        );

        await tester.tap(find.text('Entrar'));

        // Apenas um frame: a chamada de autenticação já foi iniciada,
        // mas ainda não exigimos que a resposta tenha sido processada.
        await tester.pump();

        // A implementação atual não possui spinner/loading explícito
        // na LoginScreen. O estado visual continua sendo a própria tela.
        expect(find.text('Entrar'), findsOneWidget);

        // Aguarda a resposta real do Firebase para validar o estado final.
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
          ),
          findsOneWidget,
        );

        expect(find.byType(SnackBar), findsOneWidget);
      },
    );
  });
}
```

 ### Observação sobre `invalid-credential`

 Eu não criei um `testWidgets()` artificial que tentasse “forçar” `FirebaseAuthException(code: 'invalid-credential')`, porque isso exigiria mock ou alteração da implementação — justamente o que o requisito proíbe.

 O teste de senha incorreta aceita os dois códigos que a própria `LoginScreen` trata:

```
wrong-password
invalid-credential
```

 Assim, ele continua sendo um teste E2E real contra o Auth Emulator, em vez de transformar um cenário de integração em um teste unitário disfarçado.

 Também não há um teste de `Firestore` isolado porque o objetivo é o fluxo de login: a leitura/gravação do Firestore é verificada como parte do sucesso ponta a ponta da `TelaInicialScreen`. A documentação do Flutter caracteriza esse tipo de teste como execução do aplicativo completo, incluindo a interação entre as partes da aplicação.  Documentação Flutter+1

 **Execução:**

```
flutter test integration_test/fase3/login_test.dart -d emulator-5554
```

 Um ponto a conferir no projeto é que o `firebase_test_helper.dart` esteja realmente importável a partir de `integration_test/fase3/` com `../firebase_test_helper.dart`, como especificado.