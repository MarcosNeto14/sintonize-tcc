import 'package:flutter/material.dart';
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
  'E2E - login válido navega para TelaInicialScreen',
  (tester) async {
    await abrirLogin(tester);

    await preencherLogin(
      tester,
      email: 'tester@sintonize.test',
      senha: 'senha123',
    );

    await tocarEntrar(tester);

    // Aguarda a operação assíncrona de autenticação e a
    // transição da LoginScreen para a TelaInicialScreen.
    await tester.pumpAndSettle();

    // Este é o requisito central do fluxo:
    // autenticação bem-sucedida deve substituir a LoginScreen
    // pela TelaInicialScreen.
    expect(
      find.byType(TelaInicialScreen),
      findsOneWidget,
    );

    // A LoginScreen não deve mais estar na árvore.
    expect(
      find.text('Entrar'),
      findsNothing,
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
