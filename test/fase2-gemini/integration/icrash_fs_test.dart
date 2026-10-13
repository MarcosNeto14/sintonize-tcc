import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

void main() {
  group('Fluxo de Cadastro e Seleção de Gêneros', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: false);
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets('validações de formulário na CadastroScreen impedem avanço com campos vazios', (tester) async {
      // Configura resolução suficiente para evitar corte em SingleChildScrollView
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: CadastroScreen(auth: mockAuth, firestore: fakeFirestore),
        ),
      );

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
    });

    testWidgets('cadastro com sucesso cria usuário no Auth e registro no Firestore', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: CadastroScreen(auth: mockAuth, firestore: fakeFirestore),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'Maria Silva');
      await tester.enterText(find.byType(TextFormField).at(1), 'maria@exemplo.com');
      await tester.enterText(find.byType(TextFormField).at(2), '123456');
      await tester.enterText(find.byType(TextFormField).at(3), '123456');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      expect(find.byType(GenerosCadastroScreen), findsOneWidget);

      expect(mockAuth.currentUser, isNotNull);
      final uid = mockAuth.currentUser!.uid;

      final docSnapshot = await fakeFirestore.collection('usuarios').doc(uid).get();
      expect(docSnapshot.exists, isTrue);
      expect(docSnapshot.data()?['nome'], 'Maria Silva');
      expect(docSnapshot.data()?['email'], 'maria@exemplo.com');
    });

    testWidgets('GenerosCadastroScreen impede envio se nenhum gênero for selecionado', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final user = MockUser(uid: 'user_123', email: 'teste@sintonize.com');
      final authLogado = MockFirebaseAuth(mockUser: user, signedIn: true);

      await tester.pumpWidget(
        MaterialApp(
          home: GenerosCadastroScreen(auth: authLogado, firestore: fakeFirestore),
        ),
      );

      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarBtn);
      await tester.tap(confirmarBtn);
      await tester.pumpAndSettle();

      expect(find.text('Selecione pelo menos um gênero musical!'), findsOneWidget);
    });

    testWidgets('GenerosCadastroScreen salva gêneros selecionados no Firestore do usuário', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const uid = 'user_sintonize_123';
      final user = MockUser(uid: uid, email: 'rocker@sintonize.com');
      final authLogado = MockFirebaseAuth(mockUser: user, signedIn: true);

      await fakeFirestore.collection('usuarios').doc(uid).set({
        'nome': 'Rocker',
        'email': 'rocker@sintonize.com',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: GenerosCadastroScreen(auth: authLogado, firestore: fakeFirestore),
        ),
      );

      // Toca diretamente no texto do switch tile
      await tester.tap(find.text('Rock'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Jazz'));
      await tester.pumpAndSettle();

      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarBtn);
      await tester.tap(confirmarBtn);
      await tester.pumpAndSettle();

      final docAtualizado = await fakeFirestore.collection('usuarios').doc(uid).get();
      final generosSalvos = List<String>.from(docAtualizado.data()?['generos_favoritos'] ?? []);

      expect(generosSalvos, containsAll(['Rock', 'Jazz']));
      expect(generosSalvos.length, 2);
    });
  });
}
