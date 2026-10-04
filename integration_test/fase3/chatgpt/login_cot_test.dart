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
    await FirebaseAuth.instance.signOut();
  });

  Future<void> iniciarAplicacao(WidgetTester tester) async {
    runApp(const app.MyApp());

    await tester.pumpAndSettle();
  }

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

  /// Aguarda uma condição visual que depende de uma operação assíncrona
  /// externa ao mecanismo de animações do Flutter.
  ///
  /// pumpAndSettle() não é suficiente para aguardar diretamente uma Future
  /// de Firestore que ainda não tenha produzido um novo frame.
  Future<void> esperarAteEncontrar(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
    Duration intervalo = const Duration(milliseconds: 100),
  }) async {
    final limite = DateTime.now().add(timeout);

    while (finder.evaluate().isEmpty &&
        DateTime.now().isBefore(limite)) {
      await tester.pump(intervalo);
    }

    expect(
      finder,
      findsOneWidget,
      reason:
          'O estado esperado não apareceu dentro de ${timeout.inSeconds}s.',
    );
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

        // Aguarda a resposta do Firebase Auth e a navegação.
        await tester.pumpAndSettle();

        // A navegação bem-sucedida é um estado independente da carga
        // posterior dos dados do Firestore.
        expect(find.text('Minha Conta'), findsOneWidget);
        expect(find.text('Pesquisa Direta'), findsOneWidget);
        expect(find.text('Sintonizados'), findsOneWidget);
        expect(find.text('Mapa'), findsOneWidget);

        // TelaInicialScreen faz a leitura do Firestore em initState().
        // Essa operação pode terminar depois do pumpAndSettle() acima.
        final recomendacoesEsperadas = find.byWidgetPredicate(
          (widget) {
            if (widget is! Text) {
              return false;
            }

            const musicas = <String>{
              'Bohemian Rhapsody',
              'Billie Jean',
            };

            return musicas.contains(widget.data);
          },
        );

        await esperarAteEncontrar(
          tester,
          recomendacoesEsperadas,
        );

        // Confirma que o usuário autenticado é o usuário preparado
        // no Auth Emulator.
        final usuario = FirebaseAuth.instance.currentUser;

        expect(usuario, isNotNull);
        expect(usuario!.email, 'tester@sintonize.test');

        // Confirma o estado persistido no Firestore após a recomendação.
        final documento = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuario.uid)
            .get();

        expect(documento.exists, isTrue);

        final dados = documento.data()!;

        expect(dados['nome'], 'tester sintonize');
        expect(
          dados['generos_favoritos'],
          containsAll(<String>[
            'rock',
            'pop',
          ]),
        );

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

        await tester.pumpAndSettle();

        expect(
          find.text(
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
          ),
          findsOneWidget,
        );

        expect(find.byType(SnackBar), findsOneWidget);
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

        await tester.pumpAndSettle();

        final mensagemSenhaIncorreta = find.text(
          'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
        );

        final mensagemCredencialInvalida = find.text(
          'As credenciais fornecidas são inválidas. Tente novamente.',
        );

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

        await tester.pump();

        // A LoginScreen não implementa um indicador visual de loading.
        // Portanto, durante a operação a tela continua presente.
        expect(find.text('Entrar'), findsOneWidget);

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
