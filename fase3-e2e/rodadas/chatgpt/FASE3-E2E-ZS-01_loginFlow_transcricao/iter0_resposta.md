Abaixo está um teste E2E completo para salvar em `integration_test/fase3/login_test.dart`. Ele usa o `MyApp` real, o Firebase Emulator Suite e cobre sucesso, credenciais inexistentes, campos vazios e senha incorreta.

 integration\_test/fase3/login\_test.dart

```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintonize/main.dart';
import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> abrirLogin(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

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
    final camposTexto = find.byType(TextFormField);

    expect(camposTexto, findsNWidgets(2));

    await tester.enterText(camposTexto.at(0), email);
    await tester.enterText(camposTexto.at(1), senha);
  }

  testWidgets(
    'login com credenciais válidas navega para a TelaInicialScreen',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: 'senha123',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // A TelaInicialScreen depende de dados do Firestore para carregar
      // nome e recomendação. Primeiro verificamos elementos que só existem
      // nessa tela.
      expect(find.text('Pesquisa Direta'), findsOneWidget);
      expect(find.text('Sintonizados'), findsOneWidget);
      expect(find.text('Mapa'), findsOneWidget);
      expect(find.text('Minha Conta'), findsOneWidget);

      // O usuário previamente populado pelo ambiente deve ser carregado.
      expect(
        find.text(
          'Tester Sintonize, essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // Garante que o usuário realmente está autenticado no Emulator.
      expect(
        FirebaseAuth.instance.currentUser?.email,
        equals('tester@sintonize.test'),
      );
    },
  );

  testWidgets(
    'login com usuário inexistente exibe SnackBar vermelho',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'naoexiste@sintonize.test',
        senha: 'senha123',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Usuário não encontrado. Verifique o e-mail e tente novamente.',
        ),
        findsOneWidget,
      );

      final snackBar = tester.widget<SnackBar>(
        find.ancestor(
          of: find.text(
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
          ),
          matching: find.byType(SnackBar),
        ),
      );

      expect(snackBar.backgroundColor, equals(Colors.red));

      // O login falhou, portanto continuamos na LoginScreen.
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
    },
  );

  testWidgets(
    'login com senha incorreta para usuário existente exibe SnackBar vermelho',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: 'senha-incorreta',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      final mensagem = find.text(
        'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
      );

      expect(mensagem, findsOneWidget);

      final snackBar = tester.widget<SnackBar>(
        find.ancestor(
          of: mensagem,
          matching: find.byType(SnackBar),
        ),
      );

      expect(snackBar.backgroundColor, equals(Colors.red));

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
    },
  );

  testWidgets(
    'campos vazios exibem mensagens de validação e não tentam autenticar',
    (tester) async {
      await abrirLogin(tester);

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Por favor, insira seu e-mail'),
        findsOneWidget,
      );

      expect(
        find.text('Por favor, insira sua senha'),
        findsOneWidget,
      );

      // A validação do Form acontece antes da chamada ao Firebase.
      // Portanto, a LoginScreen continua aberta e nenhum SnackBar
      // de autenticação deve aparecer.
      expect(find.text('Entrar'), findsOneWidget);
      expect(
        find.text(
          'Usuário não encontrado. Verifique o e-mail e tente novamente.',
        ),
        findsNothing,
      );
      expect(
        find.text(
          'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'senha vazia exibe validação sem navegar',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: '',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Por favor, insira sua senha'),
        findsOneWidget,
      );

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsNothing);
    },
  );

  testWidgets(
    'senha com menos de seis caracteres exibe validação sem autenticar',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: '12345',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsNothing);
    },
  );

  testWidgets(
    'e-mail inválido exibe validação sem autenticar',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'email-invalido',
        senha: 'senha123',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Por favor, insira um e-mail válido'),
        findsOneWidget,
      );

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsNothing);
    },
  );

  testWidgets(
    'login válido carrega os dados do usuário na TelaInicialScreen',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: 'senha123',
      );

      await tester.tap(find.text('Entrar'));

      // Dá tempo para a navegação acontecer.
      await tester.pumpAndSettle();

      // A TelaInicialScreen chama FirebaseFirestore para buscar
      // o nome e a recomendação do usuário.
      expect(find.text('Pesquisa Direta'), findsOneWidget);
      expect(find.text('Sintonizados'), findsOneWidget);
      expect(find.text('Mapa'), findsOneWidget);
      expect(find.text('Minha Conta'), findsOneWidget);

      // Aguarda os FutureBuilders da TelaInicialScreen.
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Tester Sintonize, essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // Como os gêneros do usuário são rock/pop, a recomendação só pode
      // ser uma das duas músicas correspondentes aos dados previamente
      // carregados no Emulator Suite.
      final recomendacoesValidas = <String>{
        'Bohemian Rhapsody',
        'Billie Jean',
      };

      final recomendacaoEncontrada = recomendacoesValidas
          .where((nome) => find.text(nome).evaluate().isNotEmpty)
          .toList();

      expect(
        recomendacaoEncontrada,
        isNotEmpty,
        reason:
            'A TelaInicialScreen deveria recomendar uma música de rock ou pop.',
      );
    },
  );

  testWidgets(
    'usuário autenticado permanece na TelaInicialScreen após o login',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: 'senha123',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(
        FirebaseAuth.instance.currentUser,
        isNotNull,
      );

      expect(
        FirebaseAuth.instance.currentUser!.email,
        equals('tester@sintonize.test'),
      );

      expect(find.text('Minha Conta'), findsOneWidget);
      expect(find.text('Entrar'), findsNothing);
      expect(find.text('E-mail'), findsNothing);
    },
  );
}
```

 ### Observação importante sobre o teste

 Há um detalhe do código fornecido que merece atenção: `TelaInicialScreen` usa `FirebaseAuth.instance` e `FirebaseFirestore.instance` diretamente, enquanto o `LoginScreen` também usa essas instâncias quando `auth == null`. Isso está **correto para o E2E solicitado**, porque o teste não injeta `auth` nem usa mocks.

 Também deixei a configuração do Emulator Suite exclusivamente no `setUpAll()`:

```
setUpAll(() async {
  await setupFirebaseEmulators();
});
```

 Assim, o teste não cria nem popula usuários/dados — ele utiliza exatamente o usuário e os documentos que o ambiente prepara antes da execução, conforme especificado.

 ### Executar

 Como o arquivo está em `integration_test/fase3/`, você pode executar todos os testes da fase com:

```
flutter test integration_test/fase3/ -d emulator-5554
```

 Ou somente este arquivo:

```
flutter test integration_test/fase3/login_test.dart -d emulator-5554
```

 **Nota:** o teste de login bem-sucedido depende de o documento `usuarios/{uid}` realmente existir para o UID criado no Auth Emulator. O próprio teste não deve criar esse documento, pois você especificou que os dados iniciais são responsabilidade da preparação do ambiente.