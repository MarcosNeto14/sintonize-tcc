import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/main.dart';
import 'package:sintonize/tela-inicial.dart';

import '../firebase_test_helper.dart';
import 'pump_helpers.dart';
import '../seed.dart';

/// Fluxo de cadastro (E2E-01 do roteiro manual,
/// `e2e-manual/E2E-01_cadastro_completo.md`):
/// HomeScreen → CadastroScreen → GenerosCadastroScreen → TelaInicialScreen,
/// com os cenários de erro E1..E5 (validação local) e E6 (gêneros).
///
/// Cada execução cadastra um e-mail novo (sufixo de timestamp), porque o
/// cadastro cria o usuário no Auth emulator e a segunda tentativa com o mesmo
/// e-mail cairia em `email-already-in-use`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final emailNovo =
      'cadastro-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';
  const nome = 'joão silva';
  const senha = 'senha123';

  setUpAll(() async {
    await setupFirebaseEmulators();
    await seedEmulators();
  });

  setUp(() async {
    await FirebaseAuth.instance.signOut();
  });

  /// Abre o app e vai da HomeScreen para a CadastroScreen (passos 1 e 2).
  Future<void> abrirCadastro(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cadastro'));
    await tester.pumpAndSettle();
    expect(find.byType(CadastroScreen), findsOneWidget);
  }

  /// Os TextFormField da CadastroScreen, na ordem em que `build()` os cria.
  /// Rua (6), Bairro (8) e Cidade (9) não têm validador e são preenchidos
  /// pelo ViaCEP; o teste não escreve neles.
  Finder campo(int i) => find.byType(TextFormField).at(i);
  const iNome = 0, iDataNasc = 1, iEmail = 2, iSenha = 3, iConfSenha = 4;
  const iCep = 5, iNumero = 7;

  /// Preenche o formulário inteiro com valores válidos (passos 3 a 9).
  /// Data e CEP recebem só dígitos: os `inputFormatters` da tela põem as
  /// barras e o hífen, como no teclado.
  Future<void> preencherValido(WidgetTester tester,
      {String email = '', String nomeUsado = nome}) async {
    await tester.enterText(campo(iNome), nomeUsado);
    await tester.enterText(campo(iDataNasc), '01012000');
    await tester.enterText(campo(iEmail), email.isEmpty ? emailNovo : email);
    await tester.enterText(campo(iSenha), senha);
    await tester.enterText(campo(iConfSenha), senha);
    await tester.enterText(campo(iCep), '01310100');
    await tester.enterText(campo(iNumero), '100');
    await tester.pump();
  }

  /// Runs 1 a 3 falharam no toque em "Cadastrar" (Offset y=748 fora do alvo);
  /// a história e o porquê de cada passo estão em `pump_helpers.dart`.
  Future<void> tocarCadastrar(WidgetTester tester) async {
    await fecharTeclado(tester);
    await tocarQuandoAlcancavel(tester, find.text('Cadastrar'));
  }

  group('cenários de erro (validação local, sem rede)', () {
    testWidgets('E1: nome com números', (tester) async {
      await abrirCadastro(tester);
      await preencherValido(tester, nomeUsado: 'joão123');
      await tocarCadastrar(tester);
      await tester.pumpAndSettle();
      expect(
        find.text('O nome não pode conter números ou caracteres especiais'),
        findsOneWidget,
      );
      expect(find.byType(CadastroScreen), findsOneWidget);
    });

    testWidgets('E2: e-mail inválido', (tester) async {
      await abrirCadastro(tester);
      await preencherValido(tester, email: 'teste');
      await tocarCadastrar(tester);
      await tester.pumpAndSettle();
      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.byType(CadastroScreen), findsOneWidget);
    });

    testWidgets('E3: senha com menos de 6 caracteres', (tester) async {
      await abrirCadastro(tester);
      await preencherValido(tester);
      await tester.enterText(campo(iSenha), '12345');
      await tester.enterText(campo(iConfSenha), '12345');
      await tocarCadastrar(tester);
      await tester.pumpAndSettle();
      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
      expect(find.byType(CadastroScreen), findsOneWidget);
    });

    testWidgets('E4: senhas diferentes', (tester) async {
      await abrirCadastro(tester);
      await preencherValido(tester);
      await tester.enterText(campo(iConfSenha), 'outra-senha');
      await tocarCadastrar(tester);
      await tester.pumpAndSettle();
      expect(find.text('As senhas não coincidem'), findsOneWidget);
      expect(find.byType(CadastroScreen), findsOneWidget);
    });

    testWidgets('E5: CEP inválido', (tester) async {
      await abrirCadastro(tester);
      await preencherValido(tester);
      await tester.enterText(campo(iCep), '123');
      await tocarCadastrar(tester);
      await tester.pumpAndSettle();
      expect(
        find.text('CEP inválido. Formato correto: XXXXX-XXX'),
        findsOneWidget,
      );
      expect(find.byType(CadastroScreen), findsOneWidget);
    });
  });

  testWidgets(
      'cadastro válido → gêneros (E6 sem seleção, depois Rock) → TelaInicialScreen',
      (tester) async {
    await abrirCadastro(tester);
    await preencherValido(tester);

    // Registra se o ViaCEP respondeu (rede externa; não é asserção).
    await tester.pump(const Duration(seconds: 3));
    final cidade = tester.widget<TextFormField>(campo(9)).controller?.text;
    // ignore: avoid_print
    print('ViaCEP: cidade preenchida = "${cidade ?? ''}"');

    // Passo 10: Cadastrar → cria usuário no Auth + doc em usuarios/{uid}.
    await tocarCadastrar(tester);
    await pumpAte(tester, find.byType(GenerosCadastroScreen));
    final user = FirebaseAuth.instance.currentUser;
    expect(user?.email, emailNovo);

    // E6: Confirmar sem gênero → SnackBar, continua na tela de gêneros.
    await tester.ensureVisible(find.text('Confirmar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await pumpAte(
      tester,
      find.text('Selecione pelo menos um gênero musical!'),
    );
    expect(find.byType(GenerosCadastroScreen), findsOneWidget);

    // Passos 11 a 13: liga "Rock" e confirma.
    await tester.ensureVisible(find.byType(Switch).first);
    await tester.tap(find.byType(Switch).first); // Rock é o 1º da lista
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Confirmar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));

    // Passo 14: TelaInicialScreen com a saudação pelo nome cadastrado.
    await pumpAte(tester, find.byType(TelaInicialScreen));
    final saudacao = find.textContaining(
      'João Silva, essa é a nossa recomendação de música para você!',
    );
    await pumpAte(tester, saudacao);

    // O que ficou no Firestore: doc do cadastro + gêneros da 2ª tela.
    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .get();
    expect(doc.data()?['nome'], nome);
    expect(doc.data()?['email'], emailNovo);
    expect(doc.data()?['generos_favoritos'], ['Rock']);
    expect(doc.data()?['endereco']?['cep'], '01310-100');
  });
}
