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
