Abaixo está o desenho do fluxo e, em seguida, um arquivo completo `integration_test/fase3/cadastro_generos_test.dart`. O teste usa `integration_test` \+ `testWidgets`, sem mocks, e interage com o `FirebaseAuth`/`Firestore` Emulator Suite. Essa abordagem é compatível com o modelo oficial de testes de integração do Flutter, em que o teste pode usar as APIs do `flutter_test` em um dispositivo/emulador real.  Documentação Flutter+1

 ## 1\. Análise do fluxo

 O fluxo começa na `HomeScreen`, onde o usuário toca em **Cadastro** e chega à `CadastroScreen`. Nessa tela ele preenche dados pessoais, data, e-mail, senha e endereço; o CEP dispara uma chamada HTTP ao ViaCEP, e, se a validação local passar, o app cria o usuário no Firebase Auth e grava `usuarios/{uid}` no Firestore. Em caso de sucesso, a navegação segue para `GenerosCadastroScreen`, onde o usuário seleciona um ou mais gêneros e toca em **Confirmar**, provocando um `update` do documento Firestore e a navegação para `TelaInicialScreen`. Os principais pontos de decisão são: validação local antes de Firebase, falha de criação no Auth, ausência de gênero selecionado e falha ao atualizar o Firestore. Não existe indicador de loading explícito em `CadastroScreen` ou `GenerosCadastroScreen`; o estado de carregamento explicitamente visível no fluxo final aparece em `TelaInicialScreen` enquanto `fetchUserName()` ainda está pendente.

 ## 2\. Dependências e estado dos emuladores

 | Tela/ação | Serviço | Leitura/gravação | Estado inicial necessário |
| --- | --- | --- | --- |
| `HomeScreen` | Nenhum | Nenhuma | Apenas Firebase inicializado |
| `CadastroScreen` — CEP | HTTP / ViaCEP | `GET https://viacep.com.br/ws/{cep}/json/` | Internet disponível no dispositivo/emulador |
| `CadastroScreen` — Cadastrar | Firebase Auth | `createUserWithEmailAndPassword` | E-mail novo para sucesso; `tester@sintonize.test` para duplicidade |
| `CadastroScreen` — Cadastrar | Firestore | `set()` em `usuarios/{uid}` | Nenhum documento prévio para o novo UID |
| `GenerosCadastroScreen` — Confirmar | Firebase Auth | `currentUser` | Usuário criado/autenticado pela etapa anterior |
| `GenerosCadastroScreen` — Confirmar | Firestore | `update()` em `usuarios/{uid}` | Documento criado pela `CadastroScreen` |
| `TelaInicialScreen` | Firestore | Lê `usuarios/{uid}.nome`, `generos_favoritos`, histórico e coleção `musica`; pode atualizar histórico/recomendação | Documento do usuário e os cinco documentos de música |

Antes dos testes existem:

 - Auth: `tester@sintonize.test` / `senha123`.
- Firestore: `usuarios/{uid-do-tester}` com `nome: "tester sintonize"` e `generos_favoritos: ["rock", "pop"]`.
- Firestore `musica`: cinco músicas, nos gêneros rock, pop, jazz, blues e reggae.
- Nenhum usuário criado pelo fluxo de teste deve ser pressuposto previamente.

 O Auth Emulator é apropriado para esse tipo de teste de criação de contas e o Firestore Emulator usa a porta padrão `8080`, enquanto o Auth Emulator usa `9099`.  Firebase+1

 ## 3\. Caminho de navegação

 O caminho real é:

 1. `HomeScreen`
   - esperar `Bem-vindo ao Sintonize!`;
   - tocar `Cadastro`.
2. `CadastroScreen`
   - esperar o formulário;
   - preencher os dez `TextFormField`s;
   - preencher CEP e aguardar o preenchimento assíncrono de rua/bairro/cidade/estado;
   - tocar `Cadastrar`;
   - aguardar a conclusão de Auth + Firestore e o aparecimento da `GenerosCadastroScreen`.
3. `GenerosCadastroScreen`
   - tocar o `Switch` correspondente ao gênero;
   - tocar `Confirmar`;
   - aguardar o `update()` do Firestore e a navegação.
4. `TelaInicialScreen`
   - aguardar o carregamento assíncrono do nome/recomendação;
   - validar o estado final.

 Como não há widgets de loading no cadastro, o teste não deve esperar uma mensagem de `"Carregando..."` nessa tela. Em vez disso, ele espera diretamente pela alteração observável da UI após a operação assíncrona. A documentação do Flutter recomenda usar `pumpAndSettle()` após interações e verificar explicitamente a presença/ausência dos widgets esperados.  Documentação Flutter

 ## 4\. Cenários

 - **Sucesso ponta a ponta:** boas-vindas → cadastro válido → ViaCEP → Auth → Firestore → gêneros → Firestore → tela inicial.
- **Nome inválido:** números/caracteres especiais; não deve disparar Auth.
- **Data inválida:** formato/valor inválido; não deve disparar Auth.
- **E-mail inválido:** validação local; não deve disparar Auth.
- **Senha curta:** validação local; não deve disparar Auth.
- **Senhas diferentes:** validação local; não deve disparar Auth.
- **CEP inválido:** validação local; não deve disparar Auth.
- **Número inválido:** validação local; não deve disparar Auth.
- **E-mail já cadastrado:** usar o usuário pré-populado `tester@sintonize.test`; Auth deve rejeitar a criação e a tela deve mostrar `Erro ao cadastrar: ...`. O Firebase documenta `email-already-in-use`/`EmailAlreadyInUse` como o erro correspondente a uma tentativa de criação com e-mail existente.  Firebase+1
- **Confirmar sem gênero:** deve mostrar `Selecione pelo menos um gênero musical!` e não navegar.
- **Estado intermediário:** `TelaInicialScreen` pode exibir `Carregando...` enquanto busca o nome; o código não fornece um loading explícito para Auth/Firestore durante cadastro.
- **Erro de atualização do Firestore:** com as restrições dadas, não há uma forma legítima e determinística de produzir esse erro somente pela UI. Para forçá-lo seria necessário alterar/remover o documento externamente ou manipular regras, o que deixaria de ser o fluxo E2E solicitado. Portanto, não incluí um falso teste que dependeria de uma condição que o aplicativo não consegue produzir sozinho.

 ## 5\. Testes

 Um detalhe importante: o helper já chama `Firebase.initializeApp()`. Por isso, o teste **não chama `main()` do aplicativo**, evitando uma segunda inicialização do Firebase. Em vez disso, ele monta `MyApp`, que é o mesmo widget raiz usado pelo `main.dart`.

 O arquivo completo é:

 integration\_test/fase3/cadastro\_generos\_test.dart

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

  Future<void> startApp(WidgetTester tester) async {
    await FirebaseAuth.instance.signOut();

    await tester.pumpWidget(const app.MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
  }

  Future<void> goToCadastro(WidgetTester tester) async {
    await tester.tap(find.text('Cadastro'));
    await tester.pumpAndSettle();

    expect(find.text('Cadastrar'), findsOneWidget);
    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
  }

  Finder formField(int index) {
    return find.byType(TextFormField).at(index);
  }

  Future<void> fillValidCadastro(
    WidgetTester tester, {
    required String email,
    String nome = 'Usuario Teste',
    String dataNascimento = '01/01/1990',
    String senha = 'senha123',
    String cep = '01001000',
    String numero = '100',
  }) async {
    /*
     * Ordem dos TextFormField em CadastroScreen:
     *
     * 0 Nome
     * 1 Data de Nascimento
     * 2 E-mail
     * 3 Senha
     * 4 Confirmar Senha
     * 5 CEP
     * 6 Rua
     * 7 Número
     * 8 Bairro
     * 9 Cidade
     */

    await tester.enterText(formField(0), nome);
    await tester.enterText(formField(1), dataNascimento);
    await tester.enterText(formField(2), email);
    await tester.enterText(formField(3), senha);
    await tester.enterText(formField(4), senha);

    await tester.enterText(formField(5), cep);

    /*
     * Ao completar 8 dígitos, o formatter transforma:
     * 01001000 -> 01001-000
     *
     * e o onChanged dispara a chamada HTTP ao ViaCEP.
     */
    await _waitUntil(
      tester,
      () =>
          find.text('Rua').evaluate().isNotEmpty &&
          formField(6).evaluate().isNotEmpty,
    );

    /*
     * Aguarda o preenchimento assíncrono do ViaCEP.
     * Para 01001000 esperamos o endereço oficial correspondente.
     */
    await _waitUntil(
      tester,
      () {
        final ruaController = _textControllerFor(formField(6));
        final bairroController = _textControllerFor(formField(8));
        final cidadeController = _textControllerFor(formField(9));

        return ruaController?.text.isNotEmpty == true &&
            bairroController?.text.isNotEmpty == true &&
            cidadeController?.text.isNotEmpty == true;
      },
    );

    await tester.enterText(formField(7), numero);
  }

  Future<void> submitCadastro(WidgetTester tester) async {
    await tester.tap(find.text('Cadastrar'));

    await _waitUntil(
      tester,
      () => find.text(
        'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
      ).evaluate().isNotEmpty,
      timeout: const Duration(seconds: 20),
    );
  }

  Future<void> selectGenero(
    WidgetTester tester,
    String genero,
  ) async {
    final textFinder = find.text(genero);
    expect(textFinder, findsOneWidget);

    /*
     * O texto e o Switch estão no mesmo Row/Card.
     * Encontramos o Switch mais próximo do Card que contém o gênero.
     */
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

  Future<void> confirmGeneros(
    WidgetTester tester,
  ) async {
    await tester.tap(find.text('Confirmar'));

    await _waitUntil(
      tester,
      () => find.byType(app.TelaInicialScreen).evaluate().isNotEmpty,
      timeout: const Duration(seconds: 20),
    );
  }

  Future<void> _waitUntil(
    WidgetTester tester,
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 10),
    Duration step = const Duration(milliseconds: 100),
  }) async {
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(step);

      if (condition()) {
        return;
      }
    }

    throw TestFailure(
      'Condição não satisfeita dentro de ${timeout.inSeconds}s.',
    );
  }

  TextEditingController? _textControllerFor(Finder finder) {
    final element = finder.evaluate().firstOrNull;

    if (element == null) {
      return null;
    }

    final widget = element.widget;

    if (widget is TextFormField) {
      return widget.controller;
    }

    return null;
  }

  Future<void> expectValidationError(
    WidgetTester tester,
    String message,
  ) async {
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    expect(find.text(message), findsOneWidget);

    /*
     * A tela de cadastro continua aberta, portanto nenhuma navegação
     * para GenerosCadastroScreen ocorreu.
     */
    expect(
      find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
      findsNothing,
    );
  }

  group('Fase 3 - Cadastro e seleção de gêneros', () {
    testWidgets(
      'Fluxo E2E completo: cadastro -> gêneros -> tela inicial',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        final email =
            'e2e-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

        await fillValidCadastro(
          tester,
          email: email,
        );

        /*
         * Verifica que os dados retornados pelo ViaCEP foram usados
         * antes de disparar o cadastro.
         */
        final rua = _textControllerFor(formField(6));
        final bairro = _textControllerFor(formField(8));
        final cidade = _textControllerFor(formField(9));

        expect(rua?.text.isNotEmpty, isTrue);
        expect(bairro?.text.isNotEmpty, isTrue);
        expect(cidade?.text.isNotEmpty, isTrue);

        await submitCadastro(tester);

        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        expect(find.text('Rock'), findsOneWidget);
        expect(find.text('Pop'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await selectGenero(tester, 'Rock');
        await selectGenero(tester, 'Pop');

        await confirmGeneros(tester);

        expect(find.byType(app.TelaInicialScreen), findsOneWidget);

        /*
         * TelaInicialScreen consulta o documento do usuário e exibe
         * o nome formatado. Como o nome cadastrado foi "Usuario Teste",
         * a mensagem esperada é esta.
         */
        await _waitUntil(
          tester,
          () => find
              .text(
                'Usuario Teste, essa é a nossa recomendação de música para você!',
              )
              .evaluate()
              .isNotEmpty,
          timeout: const Duration(seconds: 20),
        );

        expect(
          find.text(
            'Usuario Teste, essa é a nossa recomendação de música para você!',
          ),
          findsOneWidget,
        );

        /*
         * Como Rock e Pop estão entre os gêneros selecionados e existem
         * músicas desses gêneros no Firestore, a recomendação deve ser
         * uma das duas músicas compatíveis.
         */
        final recomendacoes = <String>[
          'Bohemian Rhapsody',
          'Billie Jean',
        ];

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Text && recomendacoes.contains(widget.data),
          ),
          findsOneWidget,
        );

        /*
         * Confirma diretamente no Firestore o estado final produzido
         * pela interface. A leitura é apenas uma verificação do teste;
         * nenhum dado do fluxo é criado/modificado por fora da UI.
         */
        final user = FirebaseAuth.instance.currentUser;
        expect(user, isNotNull);

        final snapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user!.uid)
            .get();

        expect(snapshot.exists, isTrue);

        final data = snapshot.data()!;

        expect(data['nome'], 'Usuario Teste');
        expect(data['email'], email);

        final generos = List<String>.from(
          data['generos_favoritos'] ?? const [],
        );

        expect(generos, containsAll(<String>['Rock', 'Pop']));
      },
    );

    testWidgets(
      'Validação: nome com números não dispara Firebase',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(formField(0), 'Usuario123');

        await expectValidationError(
          tester,
          'O nome não pode conter números ou caracteres especiais',
        );

        expect(
          find.text('Cadastrar'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Validação: data de nascimento inválida',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(formField(1), '31/02/1990');

        await expectValidationError(
          tester,
          'Dia deve ser entre 01 e 28',
        );
      },
    );

    testWidgets(
      'Validação: e-mail inválido não dispara Firebase',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(
          formField(2),
          'email-invalido',
        );

        await expectValidationError(
          tester,
          'E-mail inválido',
        );
      },
    );

    testWidgets(
      'Validação: senha com menos de seis caracteres',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(
          formField(3),
          '12345',
        );
        await tester.enterText(
          formField(4),
          '12345',
        );

        await expectValidationError(
          tester,
          'A senha deve ter pelo menos 6 caracteres',
        );
      },
    );

    testWidgets(
      'Validação: senhas diferentes',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(
          formField(3),
          'senha123',
        );
        await tester.enterText(
          formField(4),
          'senha456',
        );

        await expectValidationError(
          tester,
          'As senhas não coincidem',
        );
      },
    );

    testWidgets(
      'Validação: CEP inválido',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        /*
         * O formatter não deixa chegar a um CEP válido, portanto
         * nenhuma chamada ao ViaCEP é necessária neste cenário.
         */
        await tester.enterText(
          formField(5),
          '123',
        );

        await expectValidationError(
          tester,
          'CEP inválido. Formato correto: XXXXX-XXX',
        );
      },
    );

    testWidgets(
      'Validação: número do endereço não numérico',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        await tester.enterText(
          formField(7),
          'ABC',
        );

        await expectValidationError(
          tester,
          'O número deve ser numérico',
        );
      },
    );

    testWidgets(
      'Firebase Auth: e-mail já cadastrado',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        /*
         * Este usuário existe no estado inicial do Auth Emulator.
         */
        await fillValidCadastro(
          tester,
          email: 'tester@sintonize.test',
        );

        await tester.tap(find.text('Cadastrar'));

        /*
         * O Auth Emulator deve rejeitar createUserWithEmailAndPassword.
         * O app captura FirebaseAuthException e mostra SnackBar.
         */
        await _waitUntil(
          tester,
          () => find
              .textContaining('Erro ao cadastrar:')
              .evaluate()
              .isNotEmpty,
          timeout: const Duration(seconds: 20),
        );

        expect(
          find.textContaining('Erro ao cadastrar:'),
          findsOneWidget,
        );

        /*
         * O fluxo não pode avançar para gêneros.
         */
        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsNothing,
        );

        expect(find.text('Cadastrar'), findsOneWidget);
      },
    );

    testWidgets(
      'Fluxo de gêneros: confirmar sem selecionar nenhum',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        final email =
            'sem-genero-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

        await fillValidCadastro(
          tester,
          email: email,
        );

        await submitCadastro(tester);

        expect(
          find.text(
            'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
          ),
          findsOneWidget,
        );

        /*
         * Nenhum Switch é alterado.
         */
        await tester.tap(find.text('Confirmar'));
        await tester.pump();

        expect(
          find.text(
            'Selecione pelo menos um gênero musical!',
          ),
          findsOneWidget,
        );

        /*
         * O Firestore não deve ser atualizado e a navegação não ocorre.
         */
        expect(
          find.byType(app.TelaInicialScreen),
          findsNothing,
        );

        expect(
          find.text('Confirmar'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Estado intermediário/final: TelaInicial carrega nome e recomendação',
      (tester) async {
        await startApp(tester);
        await goToCadastro(tester);

        final email =
            'loading-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

        await fillValidCadastro(
          tester,
          email: email,
        );

        await submitCadastro(tester);

        await selectGenero(tester, 'Rock');
        await confirmGeneros(tester);

        expect(find.byType(app.TelaInicialScreen), findsOneWidget);

        /*
         * O código de TelaInicialScreen usa FutureBuilder para o nome.
         * O estado "Carregando..." é legítimo enquanto a leitura do
         * Firestore ainda está pendente, mas em um teste E2E real não
         * devemos exigir que a janela de timing seja capturada.
         *
         * Portanto, validamos o estado final observável depois que as
         * respostas dos emuladores chegaram.
         */
        await _waitUntil(
          tester,
          () => find
              .text(
                'Usuario Teste, essa é a nossa recomendação de música para você!',
              )
              .evaluate()
              .isNotEmpty,
          timeout: const Duration(seconds: 20),
        );

        expect(
          find.text(
            'Usuario Teste, essa é a nossa recomendação de música para você!',
          ),
          findsOneWidget,
        );

        expect(find.text('Bohemian Rhapsody'), findsOneWidget);
      },
    );
  });
}
```

 ### Observações importantes sobre esse arquivo

 Há três pontos que eu manteria como estão:

 - **Não uso mocks nem injeção de `FirebaseAuth`/`FirebaseFirestore`**. As telas recebem os singletons reais, exatamente como no aplicativo, e o helper aponta esses singletons para os emuladores.
- **Não crio o usuário por SDK dentro do teste**. Os usuários novos são sempre criados pelo botão `Cadastrar`; a única conta usada diretamente como pré-condição é `tester@sintonize.test`, que já faz parte do seed informado.
- **A verificação final consulta o Firestore somente para validar o efeito da UI**. Ela não cria nem altera o documento.

 Há ainda uma limitação real do código fornecido: **não é possível produzir de forma determinística o cenário “erro do Firestore ao salvar gêneros” exclusivamente através da interface**. O `update()` só falharia se o documento não existisse, as regras rejeitassem a operação ou houvesse uma falha de infraestrutura. Com o Emulator Suite aberto e o documento criado imediatamente antes pelo próprio cadastro, não há uma ação da UI capaz de provocar essa condição. Testá-la exigiria uma intervenção externa no estado do emulador, o que contrariaria a condição de E2E sem manipulação externa.

 Também vale notar que o ViaCEP é uma dependência HTTP real, diferente do Auth/Firestore: o teste usa `01001000` justamente para exercitar o caminho de preenchimento automático do endereço, e portanto precisa ter conectividade HTTP disponível no ambiente do teste.

 Para executar:

```
flutter test integration_test/fase3/cadastro_generos_test.dart -d emulator-5554
```

 O `integration_test` é o pacote oficial do Flutter para esse tipo de teste em dispositivo/emulador.  Documentação Flutter