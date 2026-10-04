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
    final camposEmail = find.byType(TextFormField);

    expect(camposEmail, findsNWidgets(2));

    await tester.enterText(camposEmail.at(0), email);
    await tester.enterText(camposEmail.at(1), senha);

    await tester.pump();
  }

  group('Login - fluxo end-to-end', () {
    testWidgets(
      'autentica com sucesso e navega para a TelaInicialScreen',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'tester@sintonize.test',
          senha: 'senha123',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        // A navegação para a TelaInicialScreen substitui a LoginScreen.
        expect(find.text('tester sintonize, essa é a nossa recomendação de música para você!'),
            findsOneWidget);

        // Confirma elementos próprios da TelaInicialScreen.
        expect(find.text('Pesquisa Direta'), findsOneWidget);
        expect(find.text('Sintonizados'), findsOneWidget);
        expect(find.text('Mapa'), findsOneWidget);
        expect(find.text('Minha Conta'), findsOneWidget);

        // A recomendação pode ser a última música do histórico ou uma
        // nova música, portanto não fazemos uma asserção sobre uma música
        // específica. O importante neste teste é confirmar que a tela foi
        // carregada após a autenticação.
        expect(find.text('Entrar'), findsNothing);
      },
    );

    testWidgets(
      'exibe erro para credenciais inválidas',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

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

        expect(
          find.text('Entrar'),
          findsOneWidget,
        );

        // Continua na LoginScreen.
        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
      },
    );

    testWidgets(
      'exibe erro de senha incorreta para usuário existente',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'tester@sintonize.test',
          senha: 'senha-errada',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
          ),
          findsOneWidget,
        );

        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
      },
    );

    testWidgets(
      'não tenta autenticar e exibe validação quando os campos estão vazios',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

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

        // Continua na LoginScreen.
        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
      },
    );

    testWidgets(
      'valida formato do e-mail e tamanho mínimo da senha',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'email-invalido',
          senha: '123',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text('Por favor, insira um e-mail válido'),
          findsOneWidget,
        );

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );

        // A validação local impede a chamada ao Firebase e a navegação.
        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
      },
    );
  });
}
