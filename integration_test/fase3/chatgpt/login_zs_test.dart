import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';
import 'package:sintonize/tela-inicial.dart';

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
    final campos = find.byType(TextFormField);

    expect(campos, findsNWidgets(2));

    await tester.enterText(campos.at(0), email);
    await tester.enterText(campos.at(1), senha);
  }

  group('Login - fluxo end-to-end', () {
    testWidgets(
      'login válido navega para a TelaInicialScreen',
      (tester) async {
        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'tester@sintonize.test',
          senha: 'senha123',
        );

        await tester.tap(find.text('Entrar'));

        // Aguarda a autenticação Firebase e a navegação.
        await tester.pumpAndSettle();

        expect(find.byType(TelaInicialScreen), findsOneWidget);

        // Elementos característicos da tela inicial.
        expect(find.text('Pesquisa Direta'), findsOneWidget);
        expect(find.text('Sintonizados'), findsOneWidget);
        expect(find.text('Mapa'), findsOneWidget);
        expect(find.text('Minha Conta'), findsOneWidget);

        // O nome é carregado do Firestore.
        expect(
          find.text(
            'Tester Sintonize, essa é a nossa recomendação de música para você!',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'credenciais inválidas exibem SnackBar de credenciais inválidas',
      (tester) async {
        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'usuario-inexistente@sintonize.test',
          senha: 'senha123',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(find.byType(TelaInicialScreen), findsNothing);

        expect(
          find.text(
            'As credenciais fornecidas são inválidas. Tente novamente.',
          ),
          findsOneWidget,
        );

        expect(
          find.byType(SnackBar),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'senha incorreta para usuário existente exibe SnackBar de senha incorreta',
      (tester) async {
        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'tester@sintonize.test',
          senha: 'senha-incorreta',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(find.byType(TelaInicialScreen), findsNothing);

        expect(
          find.text(
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
          ),
          findsOneWidget,
        );

        expect(find.byType(SnackBar), findsOneWidget);
      },
    );

    testWidgets(
      'campos vazios exibem erros de validação sem chamar autenticação',
      (tester) async {
        await abrirLogin(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(find.byType(TelaInicialScreen), findsNothing);

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsOneWidget,
        );

        expect(
          find.text('Por favor, insira sua senha'),
          findsOneWidget,
        );

        // Não deve haver SnackBar: a validação do formulário interrompe
        // o fluxo antes de chamar FirebaseAuth.
        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets(
      'e-mail inválido e senha curta exibem erros de validação',
      (tester) async {
        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'email-invalido',
          senha: '123',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(find.byType(TelaInicialScreen), findsNothing);

        expect(
          find.text('Por favor, insira um e-mail válido'),
          findsOneWidget,
        );

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );

        expect(find.byType(SnackBar), findsNothing);
      },
    );
  });
}
