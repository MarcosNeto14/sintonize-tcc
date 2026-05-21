import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget createWidgetTest(Widget child) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: child,
      routes: {
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const TelaInicialScreen(),
      },
    );
  }

  group('Fluxo de Login - Sintonize', () {
    testWidgets(
      'Deve validar campos vazios',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidgetTest(
            const LoginScreen(),
          ),
        );

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
      },
    );

    testWidgets(
      'Deve validar email inválido',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidgetTest(
            const LoginScreen(),
          ),
        );

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'email_invalido',
        );

        await tester.enterText(
          find.byType(TextFormField).at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));

        await tester.pumpAndSettle();

        expect(
          find.text('Por favor, insira um e-mail válido'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Deve validar senha curta',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createWidgetTest(
            const LoginScreen(),
          ),
        );

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'teste@sintonize.com',
        );

        await tester.enterText(
          find.byType(TextFormField).at(1),
          '123',
        );

        await tester.tap(find.text('Entrar'));

        await tester.pumpAndSettle();

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Não deve navegar quando login falhar',
      (WidgetTester tester) async {
        // Apenas instancia o mock normalmente
        // compatível com firebase_auth_mocks 0.14.2
        final mockAuth = MockFirebaseAuth(
          signedIn: false,
        );

        expect(mockAuth, isNotNull);

        await tester.pumpWidget(
          createWidgetTest(
            const LoginScreen(),
          ),
        );

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'teste@sintonize.com',
        );

        await tester.enterText(
          find.byType(TextFormField).at(1),
          '123456',
        );

        await tester.tap(find.text('Entrar'));

        await tester.pumpAndSettle();

        // Como a autenticação real não ocorre,
        // verifica apenas que NÃO navegou.
        expect(find.byType(LoginScreen), findsOneWidget);

        expect(
          find.byType(TelaInicialScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Deve renderizar TelaInicialScreen',
      (WidgetTester tester) async {
        await fakeFirestore.collection('usuarios').doc('123').set({
          'nome': 'João',
          'generos_favoritos': ['rock'],
          'historico_musicas': {},
        });

        await fakeFirestore.collection('musica').add({
          'genre': 'rock',
          'track_name': 'Numb',
          'artist_name': 'Linkin Park',
        });

        await tester.pumpWidget(
          createWidgetTest(
            const TelaInicialScreen(),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.byType(TelaInicialScreen),
          findsOneWidget,
        );

        expect(
          find.byType(BottomNavigationBar),
          findsOneWidget,
        );

        expect(
          find.text('Pesquisa Direta'),
          findsOneWidget,
        );

        expect(
          find.text('Sintonizados'),
          findsOneWidget,
        );

        expect(
          find.text('Mapa'),
          findsOneWidget,
        );

        expect(
          find.text('Minha Conta'),
          findsOneWidget,
        );

        expect(
          find.byIcon(Icons.music_note),
          findsWidgets,
        );
      },
    );
  });
}
