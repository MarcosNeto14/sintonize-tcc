Abaixo está uma proposta de teste E2E que mantém as telas intactas e usa os emuladores reais de Auth/Firestore. O `integration_test` é apropriado para executar `testWidgets()` em um Android Emulator, e `pumpAndSettle()` pode ser usado para aguardar animações/transições após interações.  Documentação Flutter+1

 ## 1\. Análise do fluxo

 O fluxo começa na `HomeScreen`, onde o usuário toca em **Cadastro** e é levado à `CadastroScreen`. Nessa tela, o formulário é validado localmente; se válido, a aplicação cria o usuário no Firebase Auth e, em seguida, grava `usuarios/{uid}` no Firestore. Após essas duas operações, navega para `GenerosCadastroScreen`, onde o usuário precisa selecionar pelo menos um gênero; ao confirmar, os gêneros são gravados no mesmo documento e a aplicação navega para `TelaInicialScreen`. Os pontos de erro são validações locais, falha no Auth/Firestore, e-mail já existente e tentativa de confirmar sem gênero; no caminho de sucesso, o estado final é a tela inicial com o documento atualizado.

 ## 2\. Dependências e estado dos emuladores

 | Tela | Serviço | Operação | Dados envolvidos |
| --- | --- | --- | --- |
| `HomeScreen` | Nenhum | Apenas navegação | Nenhum |
| `CadastroScreen` | HTTP / ViaCEP | `GET /ws/{cep}/json/` | Preenche rua, bairro, cidade e estado |
| `CadastroScreen` | Firebase Auth | `createUserWithEmailAndPassword()` | Cria o novo usuário |
| `CadastroScreen` | Firestore | `usuarios/{uid}.set()` | Nome, nascimento, e-mail e endereço |
| `GenerosCadastroScreen` | Firebase Auth | Lê `currentUser` | Obtém o UID recém-criado |
| `GenerosCadastroScreen` | Firestore | `usuarios/{uid}.update()` | Grava `generos_favoritos` |
| `TelaInicialScreen` | Auth + Firestore | Lê usuário/documento | Busca nome e recomendação |

Antes dos testes existem:

 - Auth: `tester@sintonize.test` / `senha123`.
- Firestore `usuarios/{uid-do-tester}`:
  - `nome: "tester sintonize"`
  - `generos_favoritos: ["rock", "pop"]`
- Cinco documentos em `musica`: Rock, Pop, Jazz, Blues e Reggae.

 Um ponto importante: **não há mock do ViaCEP**. Portanto, o cenário que exercita o preenchimento automático do CEP depende do serviço HTTP externo estar acessível. Firebase Auth pode ser conectado ao Authentication Emulator com `useAuthEmulator()`, e o endereço `10.0.2.2` é o endereço esperado pelo Android Emulator para acessar o host.  Firebase+1

 Também há uma característica importante do código: não existe um `CircularProgressIndicator` ou outro loading explícito durante cadastro/gêneros. O teste pode aguardar a conclusão da operação e verificar a tela seguinte, mas **não pode afirmar que uma UI de loading existe**, porque ela não existe no código fornecido.

 ## 3\. Caminho de navegação

 O caminho E2E é:

 1. `HomeScreen`
2. tocar em `Cadastro`
3. aguardar `CadastroScreen`
4. preencher os 10 campos necessários e o estado
5. tocar em `Cadastrar`
6. aguardar criação no Auth e documento no Firestore
7. aguardar `GenerosCadastroScreen`
8. tocar no `Switch` de, por exemplo, `Rock` e `Pop`
9. tocar em `Confirmar`
10. aguardar o `update()` do Firestore
11. aguardar `TelaInicialScreen`
12. verificar o nome do usuário e, opcionalmente, o documento Firestore.

 Para as transições de Flutter, `pumpAndSettle()` é adequado porque aguarda as animações/transições pendentes.  Documentação Flutter  Para as respostas dos emuladores, o teste não deve simplesmente confiar em um `pump` arbitrário: no cenário de sucesso abaixo, a própria navegação só ocorre depois dos `await` de Auth/Firestore, e o teste adicionalmente consulta o Firestore para comprovar o estado persistido.

 ## 4\. Cenários

 Os cenários que eu cobriria são:

 - **Sucesso E2E**
  - Cadastro válido.
  - Usuário criado no Auth.
  - Documento criado no Firestore.
  - Navegação para gêneros.
  - Gêneros selecionados.
  - Documento atualizado.
  - Navegação para tela inicial.
- **Validação — nome inválido**
  - Não deve disparar Firebase Auth.
- **Validação — data inválida**
  - Não deve disparar Firebase Auth.
- **Validação — e-mail inválido**
  - Não deve disparar Firebase Auth.
- **Validação — senha curta**
  - Não deve disparar Firebase Auth.
- **Validação — confirmação de senha diferente**
  - Não deve disparar Firebase Auth.
- **Validação — CEP inválido**
  - Não deve disparar Firebase Auth.
- **Validação — número inválido**
  - Não deve disparar Firebase Auth.
- **Firebase Auth — e-mail já cadastrado**
  - Deve permanecer na `CadastroScreen`.
  - Deve exibir `Erro ao cadastrar: ...`.
- **Gêneros — nenhum selecionado**
  - Não deve fazer `update()` no Firestore.
  - Deve exibir `Selecione pelo menos um gênero musical!`.
- **Estado intermediário**
  - Aguardar explicitamente as operações assíncronas em vez de introduzir sleeps arbitrários.
  - No código fornecido, não há indicador de loading para validar.

 Há uma sutileza para os testes de validação: como o Auth Emulator é consultável diretamente pelo SDK, podemos registrar o número de usuários antes e depois. Assim, o teste demonstra que a validação bloqueou o `createUserWithEmailAndPassword()`, em vez de apenas verificar uma mensagem visual.

---

 # 5\. Arquivo de testes

 Eu salvaria como:

 `integration_test/fase3/cadastro_generos_test.dart`

 O arquivo abaixo usa o aplicativo real (`MyApp`), `FirebaseAuth.instance` e `FirebaseFirestore.instance`; não injeta mocks nas telas.

```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  setUp(() async {
    // Garante que um usuário autenticado de um teste anterior não
    // interfira na navegação inicial de outro teste.
    await FirebaseAuth.instance.signOut();
  });

  String uniqueEmail() {
    return 'e2e-${DateTime.now().microsecondsSinceEpoch}@sintonize.test';
  }

  Future<void> openCadastro(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // A HomeScreen contém uma animação de logo de 2 segundos.
    // Não precisamos esperar a animação inteira para encontrar o botão,
    // mas aguardamos a árvore inicial ficar estável.
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
    expect(find.text('Cadastro'), findsOneWidget);

    await tester.tap(find.text('Cadastro'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastrar'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(10));
  }

  Finder field(int index) {
    return find.byType(TextFormField).at(index);
  }

  Future<void> fillValidRegistration(
    WidgetTester tester, {
    required String email,
    String nome = 'Usuário E2E',
    String dataNascimento = '01/01/1990',
    String senha = 'senha123',
    String cep = '01001-000',
    String rua = 'Praça da Sé',
    String numero = '100',
    String bairro = 'Sé',
    String cidade = 'São Paulo',
  }) async {
    // Ordem dos TextFormField na CadastroScreen:
    // 0 Nome
    // 1 Data de Nascimento
    // 2 E-mail
    // 3 Senha
    // 4 Confirmar Senha
    // 5 CEP
    // 6 Rua
    // 7 Número
    // 8 Bairro
    // 9 Cidade

    await tester.enterText(field(0), nome);
    await tester.enterText(field(1), dataNascimento);
    await tester.enterText(field(2), email);
    await tester.enterText(field(3), senha);
    await tester.enterText(field(4), senha);

    await tester.enterText(field(5), cep);

    // A busca de CEP é disparada automaticamente quando o campo chega
    // a 9 caracteres no formato XXXXX-XXX.
    //
    // Se o serviço ViaCEP estiver disponível, os campos Rua/Bairro/Cidade
    // e Estado serão preenchidos automaticamente. Para manter o teste
    // determinístico mesmo que o retorno HTTP demore, aguardamos alguns
    // frames e completamos os campos manualmente se necessário.
    await tester.pumpAndSettle();

    if ((tester.widget<TextFormField>(field(6)).controller?.text ?? '').isEmpty) {
      await tester.enterText(field(6), rua);
    }

    await tester.enterText(field(7), numero);

    if ((tester.widget<TextFormField>(field(8)).controller?.text ?? '').isEmpty) {
      await tester.enterText(field(8), bairro);
    }

    if ((tester.widget<TextFormField>(field(9)).controller?.text ?? '').isEmpty) {
      await tester.enterText(field(9), cidade);
    }

    // Dropdown de Estado.
    final dropdown = find.byType(DropdownButtonFormField<String>);
    expect(dropdown, findsOneWidget);

    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    expect(find.text('SP'), findsWidgets);

    // Quando o Dropdown abre, há um item "SP" na lista.
    await tester.tap(find.text('SP').last);
    await tester.pumpAndSettle();
  }

  Future<void> submitRegistration(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Cadastrar'));
    await tester.tap(find.text('Cadastrar'));

    // _submit() contém operações assíncronas no Auth e Firestore.
    // pumpAndSettle aguarda a navegação posterior.
    await tester.pumpAndSettle();
  }

  Future<void> selectGenre(
    WidgetTester tester,
    String genre,
  ) async {
    final textFinder = find.text(genre);
    expect(textFinder, findsOneWidget);

    await tester.ensureVisible(textFinder);

    // O Switch é irmão do Text dentro do Card/Row.
    // Procuramos o Card que contém o texto e depois o Switch daquele Card.
    final card = find.ancestor(
      of: textFinder,
      matching: find.byType(Card),
    );

    expect(card, findsOneWidget);

    final switchFinder = find.descendant(
      of: card,
      matching: find.byType(Switch),
    );

    expect(switchFinder, findsOneWidget);

    await tester.tap(switchFinder);
    await tester.pump();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> currentUserDocument() async {
    final user = FirebaseAuth.instance.currentUser;
    expect(user, isNotNull);

    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .get();
  }

  testWidgets(
    'E2E completo: cadastro -> gêneros -> tela inicial -> dados persistidos',
    (tester) async {
      final email = uniqueEmail();

      await openCadastro(tester);

      await fillValidRegistration(
        tester,
        email: email,
      );

      // Verifica que ainda estamos no formulário antes do submit.
      expect(find.text('Cadastrar'), findsOneWidget);

      await submitRegistration(tester);

      // A navegação só ocorre depois de Auth + Firestore.
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      final user = FirebaseAuth.instance.currentUser;
      expect(user, isNotNull);
      expect(user!.email, email);

      // Comprova que o documento criado pelo próprio fluxo existe.
      var document = await currentUserDocument();

      expect(document.exists, isTrue);

      final registrationData = document.data()!;

      expect(registrationData['nome'], 'Usuário E2E');
      expect(registrationData['data_nasc'], '01/01/1990');
      expect(registrationData['email'], email);
      expect(registrationData['endereco'], isA<Map<String, dynamic>>());

      // Nenhum gênero foi selecionado ainda.
      expect(registrationData.containsKey('generos_favoritos'), isFalse);

      // Seleciona dois gêneros.
      await selectGenre(tester, 'Rock');
      await selectGenre(tester, 'Pop');

      expect(find.text('Confirmar'), findsOneWidget);

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      // A navegação para TelaInicialScreen acontece somente depois
      // do update() no Firestore.
      expect(
        find.textContaining(
          'Usuário E2E, essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      document = await currentUserDocument();

      expect(document.exists, isTrue);

      final data = document.data()!;

      expect(
        data['generos_favoritos'],
        containsAll(<String>['Rock', 'Pop']),
      );
      expect((data['generos_favoritos'] as List).length, 2);
    },
  );

  testWidgets(
    'Validação: nome com caracteres inválidos não cria usuário no Auth',
    (tester) async {
      await openCadastro(tester);

      final email = uniqueEmail();

      final auth = FirebaseAuth.instance;
      final before = await auth.fetchSignInMethodsForEmail(email);

      expect(before, isEmpty);

      await tester.enterText(field(0), 'Usuário123');
      await tester.enterText(field(1), '01/01/1990');
      await tester.enterText(field(2), email);
      await tester.enterText(field(3), 'senha123');
      await tester.enterText(field(4), 'senha123');
      await tester.enterText(field(5), '01001-000');
      await tester.enterText(field(6), 'Rua Teste');
      await tester.enterText(field(7), '100');
      await tester.enterText(field(8), 'Centro');
      await tester.enterText(field(9), 'São Paulo');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'O nome não pode conter números ou caracteres especiais',
        ),
        findsOneWidget,
      );

      // A validação deve impedir createUserWithEmailAndPassword().
      final after = await auth.fetchSignInMethodsForEmail(email);
      expect(after, isEmpty);

      expect(find.text('Cadastrar'), findsOneWidget);
    },
  );

  testWidgets(
    'Validação: data de nascimento inválida não cria usuário no Auth',
    (tester) async {
      await openCadastro(tester);

      final email = uniqueEmail();

      await tester.enterText(field(0), 'Usuário E2E');
      await tester.enterText(field(1), '31/02/1990');
      await tester.enterText(field(2), email);
      await tester.enterText(field(3), 'senha123');
      await tester.enterText(field(4), 'senha123');
      await tester.enterText(field(5), '01001-000');
      await tester.enterText(field(6), 'Rua Teste');
      await tester.enterText(field(7), '100');
      await tester.enterText(field(8), 'Centro');
      await tester.enterText(field(9), 'São Paulo');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Dia deve ser entre 01 e'),
        findsOneWidget,
      );

      expect(
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email),
        isEmpty,
      );
    },
  );

  testWidgets(
    'Validação: e-mail inválido não cria usuário no Auth',
    (tester) async {
      await openCadastro(tester);

      const email = 'email-invalido';

      await tester.enterText(field(0), 'Usuário E2E');
      await tester.enterText(field(1), '01/01/1990');
      await tester.enterText(field(2), email);
      await tester.enterText(field(3), 'senha123');
      await tester.enterText(field(4), 'senha123');
      await tester.enterText(field(5), '01001-000');
      await tester.enterText(field(6), 'Rua Teste');
      await tester.enterText(field(7), '100');
      await tester.enterText(field(8), 'Centro');
      await tester.enterText(field(9), 'São Paulo');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(find.text('E-mail inválido'), findsOneWidget);

      expect(
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email),
        isEmpty,
      );
    },
  );

  testWidgets(
    'Validação: senha com menos de 6 caracteres não cria usuário',
    (tester) async {
      await openCadastro(tester);

      final email = uniqueEmail();

      await tester.enterText(field(0), 'Usuário E2E');
      await tester.enterText(field(1), '01/01/1990');
      await tester.enterText(field(2), email);
      await tester.enterText(field(3), '123');
      await tester.enterText(field(4), '123');
      await tester.enterText(field(5), '01001-000');
      await tester.enterText(field(6), 'Rua Teste');
      await tester.enterText(field(7), '100');
      await tester.enterText(field(8), 'Centro');
      await tester.enterText(field(9), 'São Paulo');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );

      expect(
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email),
        isEmpty,
      );
    },
  );

  testWidgets(
    'Validação: confirmação de senha diferente não cria usuário',
    (tester) async {
      await openCadastro(tester);

      final email = uniqueEmail();

      await tester.enterText(field(0), 'Usuário E2E');
      await tester.enterText(field(1), '01/01/1990');
      await tester.enterText(field(2), email);
      await tester.enterText(field(3), 'senha123');
      await tester.enterText(field(4), 'senha456');
      await tester.enterText(field(5), '01001-000');
      await tester.enterText(field(6), 'Rua Teste');
      await tester.enterText(field(7), '100');
      await tester.enterText(field(8), 'Centro');
      await tester.enterText(field(9), 'São Paulo');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('As senhas não coincidem'),
        findsOneWidget,
      );

      expect(
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email),
        isEmpty,
      );
    },
  );

  testWidgets(
    'Validação: CEP inválido não cria usuário',
    (tester) async {
      await openCadastro(tester);

      final email = uniqueEmail();

      await tester.enterText(field(0), 'Usuário E2E');
      await tester.enterText(field(1), '01/01/1990');
      await tester.enterText(field(2), email);
      await tester.enterText(field(3), 'senha123');
      await tester.enterText(field(4), 'senha123');
      await tester.enterText(field(5), '123');
      await tester.enterText(field(6), 'Rua Teste');
      await tester.enterText(field(7), '100');
      await tester.enterText(field(8), 'Centro');
      await tester.enterText(field(9), 'São Paulo');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('CEP inválido. Formato correto: XXXXX-XXX'),
        findsOneWidget,
      );

      expect(
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email),
        isEmpty,
      );
    },
  );

  testWidgets(
    'Validação: número não numérico não cria usuário',
    (tester) async {
      await openCadastro(tester);

      final email = uniqueEmail();

      await tester.enterText(field(0), 'Usuário E2E');
      await tester.enterText(field(1), '01/01/1990');
      await tester.enterText(field(2), email);
      await tester.enterText(field(3), 'senha123');
      await tester.enterText(field(4), 'senha123');
      await tester.enterText(field(5), '01001-000');
      await tester.enterText(field(6), 'Rua Teste');
      await tester.enterText(field(7), 'ABC');
      await tester.enterText(field(8), 'Centro');
      await tester.enterText(field(9), 'São Paulo');

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('O número deve ser numérico'),
        findsOneWidget,
      );

      expect(
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email),
        isEmpty,
      );
    },
  );

  testWidgets(
    'Firebase Auth: e-mail já cadastrado exibe mensagem de erro',
    (tester) async {
      await openCadastro(tester);

      // Esse usuário é criado pelo seed dos emuladores.
      const existingEmail = 'tester@sintonize.test';

      await tester.enterText(field(0), 'Outro Usuário');
      await tester.enterText(field(1), '01/01/1990');
      await tester.enterText(field(2), existingEmail);
      await tester.enterText(field(3), 'senha123');
      await tester.enterText(field(4), 'senha123');
      await tester.enterText(field(5), '01001-000');
      await tester.enterText(field(6), 'Praça da Sé');
      await tester.enterText(field(7), '100');
      await tester.enterText(field(8), 'Sé');
      await tester.enterText(field(9), 'São Paulo');

      final beforeUser = FirebaseAuth.instance.currentUser;

      await tester.tap(find.text('Cadastrar'));
      await tester.pumpAndSettle();

      // O cadastro deve falhar no Auth e permanecer na tela.
      expect(find.text('Cadastrar'), findsOneWidget);

      expect(
        find.textContaining('Erro ao cadastrar:'),
        findsOneWidget,
      );

      // Como o teste não fez login, o usuário atual deve continuar nulo.
      expect(FirebaseAuth.instance.currentUser, same(beforeUser));
    },
  );

  testWidgets(
    'Gêneros: confirmar sem seleção mostra erro e não atualiza Firestore',
    (tester) async {
      final email = uniqueEmail();

      await openCadastro(tester);

      await fillValidRegistration(
        tester,
        email: email,
      );

      await submitRegistration(tester);

      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      final documentBefore = await currentUserDocument();

      expect(documentBefore.exists, isTrue);
      expect(
        documentBefore.data()!.containsKey('generos_favoritos'),
        isFalse,
      );

      // Nenhum Switch é acionado.
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Selecione pelo menos um gênero musical!'),
        findsOneWidget,
      );

      // Continua na tela de gêneros.
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      final documentAfter = await currentUserDocument();

      expect(documentAfter.exists, isTrue);
      expect(
        documentAfter.data()!.containsKey('generos_favoritos'),
        isFalse,
      );
    },
  );

  testWidgets(
    'Estado intermediário: cadastro válido permanece na tela de gêneros até confirmar',
    (tester) async {
      final email = uniqueEmail();

      await openCadastro(tester);

      await fillValidRegistration(
        tester,
        email: email,
      );

      await tester.tap(find.text('Cadastrar'));

      // O código da tela não possui indicador visual de loading.
      // Portanto, não testamos um CircularProgressIndicator inexistente.
      //
      // Esperamos explicitamente a conclusão das operações assíncronas
      // que precedem a navegação.
      await tester.pumpAndSettle();

      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      expect(find.text('Confirmar'), findsOneWidget);

      // O usuário ainda não pode chegar à TelaInicialScreen sem
      // confirmar pelo menos um gênero.
      expect(
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
        findsNothing,
      );
    },
  );
}
```

 ### Observações importantes sobre esse teste

 Há duas decisões deliberadas no código.

 **1\. O teste não limpa os emuladores.**\
 Isso respeita sua condição de que os emuladores são reiniciados/populados antes da execução. Cada cenário de cadastro bem-sucedido usa um e-mail único, evitando colisões entre testes. O usuário `tester@sintonize.test` permanece reservado para o cenário de e-mail já cadastrado.

 **2\. O cenário de CEP não transforma o ViaCEP em mock.**\
 O código continua disparando o `http.get()` real. No helper de preenchimento, se o retorno HTTP preencher os campos, os valores são aproveitados; caso contrário, os campos de endereço são completados pela interface. Isso deixa o E2E focado no contrato principal — Auth → Firestore → gêneros — sem fazer o resultado do cadastro depender exclusivamente de uma API externa.

 Um detalhe do código fornecido merece atenção: **não existe loading visual nas telas de cadastro/gêneros**. Portanto, não seria correto escrever uma asserção como `expect(find.byType(CircularProgressIndicator), findsOneWidget)`. O estado intermediário assíncrono é coberto aguardando a operação real e verificando que a navegação só acontece após sua conclusão.

 Para executar o arquivo:

```
flutter test integration_test/fase3/cadastro_generos_test.dart -d emulator-5554
```

 O `integration_test` oficialmente permite usar as APIs de `flutter_test`, incluindo `testWidgets`, `Finder`, `expect` e interações com widgets em um dispositivo/emulador.  Documentação Flutter+1

 **Possível fragilidade:** o código de produção não atribui `Key`s aos campos. Por isso os testes precisam identificar os `TextFormField`s pela ordem em que aparecem na árvore. Para um conjunto E2E mais resistente a mudanças visuais, o ideal seria adicionar `Key`s às telas — mas isso seria uma alteração de produção, e você pediu explicitamente que não modificássemos as telas, então não fiz isso.