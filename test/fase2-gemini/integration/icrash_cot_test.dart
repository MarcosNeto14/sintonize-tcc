import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

// Mock de FirebaseAuth que dispara FirebaseAuthException customizada
class FailingAuthMock extends MockFirebaseAuth {
  final FirebaseAuthException exceptionToThrow;

  FailingAuthMock({required this.exceptionToThrow});

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw exceptionToThrow;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void setMobileViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2220);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('CadastroScreen - Testes de Validação e Erros', () {
    testWidgets('Deve exibir erros de validação quando os campos forem inválidos', (tester) async {
      setMobileViewport(tester);

      final mockAuth = MockFirebaseAuth();
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(MaterialApp(
        home: CadastroScreen(auth: mockAuth, firestore: fakeFirestore),
      ));

      final btnCadastrar = find.text('Cadastrar');

      // 1. Enviar formulário vazio
      await tester.ensureVisible(btnCadastrar);
      await tester.tap(btnCadastrar);
      await tester.pumpAndSettle();

      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);

      // 2. Preencher nome e e-mail válidos, mas senha com menos de 6 caracteres
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Nome Teste');
      await tester.enterText(textFields.at(1), 'teste@sintonize.com');
      await tester.enterText(textFields.at(2), '123');
      await tester.enterText(textFields.at(3), '123');

      await tester.ensureVisible(btnCadastrar);
      await tester.tap(btnCadastrar);
      await tester.pumpAndSettle();

      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);

      // 3. Preencher senha válida mas confirmação divergente
      await tester.enterText(textFields.at(2), '123456');
      await tester.enterText(textFields.at(3), '654321');

      await tester.ensureVisible(btnCadastrar);
      await tester.tap(btnCadastrar);
      await tester.pumpAndSettle();

      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });

    testWidgets('Deve exibir SnackBar de erro quando o Firebase Auth falhar', (tester) async {
      setMobileViewport(tester);

      final failingAuth = FailingAuthMock(
        exceptionToThrow: FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'O e-mail informado já está cadastrado.',
        ),
      );
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(MaterialApp(
        home: CadastroScreen(auth: failingAuth, firestore: fakeFirestore),
      ));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Nome Teste');
      await tester.enterText(textFields.at(1), 'existente@sintonize.com');
      await tester.enterText(textFields.at(2), '123456');
      await tester.enterText(textFields.at(3), '123456');

      final btnCadastrar = find.text('Cadastrar');
      await tester.ensureVisible(btnCadastrar);
      await tester.tap(btnCadastrar);
      await tester.pump(); // Inicia o processamento do callback
      await tester.pump(const Duration(milliseconds: 500)); // Aguarda renderização da SnackBar

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.textContaining('O e-mail informado já está cadastrado.'),
        findsOneWidget,
      );
    });
  });

  group('GenerosCadastroScreen - Regras de Negócio e Persistência', () {
    testWidgets('Deve exibir SnackBar de aviso se nenhum gênero for selecionado ao confirmar', (tester) async {
      setMobileViewport(tester);

      final mockUser = MockUser(uid: 'user_123', email: 'user@sintonize.com');
      final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(MaterialApp(
        home: GenerosCadastroScreen(auth: mockAuth, firestore: fakeFirestore),
      ));

      final btnConfirmar = find.text('Confirmar');
      await tester.ensureVisible(btnConfirmar);
      await tester.tap(btnConfirmar);
      await tester.pumpAndSettle();

      expect(find.text('Selecione pelo menos um gênero musical!'), findsOneWidget);
    });

    testWidgets('Deve salvar os gêneros selecionados no Firestore e tentar navegar para a tela inicial', (tester) async {
      setMobileViewport(tester);

      final mockUser = MockUser(uid: 'user_123', email: 'user@sintonize.com');
      final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      final fakeFirestore = FakeFirebaseFirestore();

      await fakeFirestore.collection('usuarios').doc('user_123').set({
        'nome': 'João Silva',
        'email': 'joao@sintonize.com',
      });

      await tester.pumpWidget(MaterialApp(
        home: GenerosCadastroScreen(auth: mockAuth, firestore: fakeFirestore),
      ));

      // Seleciona 'Rock' (índice 0) e 'Jazz' (índice 2)
      final switches = find.byType(Switch);
      await tester.tap(switches.at(0));
      await tester.pumpAndSettle();

      await tester.tap(switches.at(2));
      await tester.pumpAndSettle();

      final btnConfirmar = find.text('Confirmar');
      await tester.ensureVisible(btnConfirmar);
      await tester.tap(btnConfirmar);

      // Dá um pump breve para salvar no Firestore antes da navegação instanciar o Firebase não mockado
      await tester.pump();

      // Valida que os dados foram gravados com sucesso no Firestore
      final snapshot = await fakeFirestore.collection('usuarios').doc('user_123').get();
      expect(snapshot.exists, isTrue);
      final List<dynamic>? generos = snapshot.data()?['generos_favoritos'] as List<dynamic>?;
      expect(generos, isNotNull);
      expect(generos, containsAll(['Rock', 'Jazz']));
      expect(generos, isNot(contains('Pop')));

      // Trata a exceção gerada pela TelaInicialScreen real que invoca Firebase.app() nativo
      await tester.pump();
      final exception = tester.takeException();
      if (exception != null) {
        expect(exception, isA<FirebaseException>());
      }
    });

    testWidgets('Deve exibir SnackBar de erro ao falhar atualização no Firestore (ex: doc inexistente)', (tester) async {
      setMobileViewport(tester);

      final mockUser = MockUser(uid: 'uid_sem_documento', email: 'semdoc@sintonize.com');
      final mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(MaterialApp(
        home: GenerosCadastroScreen(auth: mockAuth, firestore: fakeFirestore),
      ));

      final switches = find.byType(Switch);
      await tester.tap(switches.at(3)); // Blues
      await tester.pumpAndSettle();

      final btnConfirmar = find.text('Confirmar');
      await tester.ensureVisible(btnConfirmar);
      await tester.tap(btnConfirmar);
      await tester.pumpAndSettle();

      expect(find.text('Erro ao salvar os gêneros!'), findsOneWidget);
    });

    testWidgets('Deve falhar ao tentar salvar gêneros quando currentUser for nulo', (tester) async {
      setMobileViewport(tester);

      final mockAuth = MockFirebaseAuth(signedIn: false);
      final fakeFirestore = FakeFirebaseFirestore();

      await tester.pumpWidget(MaterialApp(
        home: GenerosCadastroScreen(auth: mockAuth, firestore: fakeFirestore),
      ));

      final switches = find.byType(Switch);
      await tester.tap(switches.at(0));
      await tester.pumpAndSettle();

      final btnConfirmar = find.text('Confirmar');
      await tester.ensureVisible(btnConfirmar);

      // Ao dar o tap, capturamos a exceção síncrona do operador bang (!)
      FlutterErrorDetails? errorCaptured;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        errorCaptured = details;
      };

      try {
        await tester.tap(btnConfirmar);
        await tester.pump();
      } finally {
        FlutterError.onError = originalOnError;
      }

      // Confirma que a exceção disparada pela aplicação é TypeError (Null check operator used on a null value)
      expect(errorCaptured, isNotNull);
      expect(errorCaptured!.exception, isA<TypeError>());
    });
  });
}
