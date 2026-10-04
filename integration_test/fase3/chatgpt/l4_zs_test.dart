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
    final campos = find.byType(TextFormField);

    expect(campos, findsNWidgets(2));

    await tester.enterText(campos.at(0), email);
    await tester.enterText(campos.at(1), senha);
    await tester.pump();
  }

  /// Aguarda a TelaInicialScreen aparecer.
  ///
  /// O carregamento do Firestore ocorre depois da navegação, portanto não
  /// devemos depender de um único pumpAndSettle() para esperar essa consulta.
  Future<void> aguardarTelaInicial(WidgetTester tester) async {
    final indicadoresDaTelaInicial = [
      find.text('Pesquisa Direta'),
      find.text('Sintonizados'),
      find.text('Mapa'),
      find.text('Minha Conta'),
    ];

    for (var i = 0; i < 50; i++) {
      if (indicadoresDaTelaInicial.any(
        (finder) => finder.evaluate().isNotEmpty,
      )) {
        return;
      }

      await tester.pump(const Duration(milliseconds: 200));
    }

    fail(
      'A TelaInicialScreen não apareceu após aguardar 10 segundos.',
    );
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

        // Não dependemos do pumpAndSettle() para esperar as operações
        // externas de Auth/Firestore.
        await aguardarTelaInicial(tester);

        // A barra inferior é criada exclusivamente pela TelaInicialScreen.
        expect(find.text('Pesquisa Direta'), findsOneWidget);
        expect(find.text('Sintonizados'), findsOneWidget);
        expect(find.text('Mapa'), findsOneWidget);
        expect(find.text('Minha Conta'), findsOneWidget);

        // A LoginScreen não deve mais estar na árvore após
        // pushReplacement().
        expect(find.text('Entrar'), findsNothing);
        expect(find.text('Esqueci minha senha'), findsNothing);
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

        // O login falhou, portanto continua na LoginScreen.
        expect(find.text('Entrar'), findsOneWidget);
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
      'exibe validação quando os campos estão vazios',
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

        // A validação local impede a tentativa de autenticação.
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

        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
      },
    );
  });
}
