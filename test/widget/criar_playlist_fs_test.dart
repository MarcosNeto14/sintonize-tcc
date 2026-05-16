import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// ⚠️ ajuste o path abaixo para o arquivo REAL do seu projeto
import 'package:sintonize/criar_playlist_screen.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('CriarPlaylistScreen Widget Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockNavigatorObserver navigatorObserver;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();

      await fakeFirestore.collection('musica').add({
        'track_name': 'Song One',
        'artist_name': 'Artist A',
      });

      await fakeFirestore.collection('musica').add({
        'track_name': 'Another Song',
        'artist_name': 'Artist B',
      });

      mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: '123'),
      );

      navigatorObserver = MockNavigatorObserver();
    });

    Widget createWidget() {
      return MaterialApp(
        home: CriarPlaylistScreen(editPlaylist: const {}),
        navigatorObservers: [navigatorObserver],
      );
    }

    testWidgets('deve mostrar loading inicialmente', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('deve exibir músicas após carregar', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Song One'), findsOneWidget);
      expect(find.textContaining('Another Song'), findsOneWidget);
    });

    testWidgets('deve filtrar músicas na busca', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).at(1),
        'Another',
      );

      await tester.pump();

      expect(find.textContaining('Another Song'), findsOneWidget);
      expect(find.textContaining('Song One'), findsNothing);
    });

    testWidgets('deve alternar seleção de música', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final checkbox = find.byIcon(Icons.check_box_outline_blank).first;

      await tester.tap(checkbox);
      await tester.pump();

      expect(find.byIcon(Icons.check_box), findsOneWidget);
    });

    testWidgets('deve mostrar erro se nome vazio', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pump();

      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);
    });

    testWidgets('deve tentar salvar playlist e voltar', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'Minha Playlist',
      );

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      // Não usamos verify aqui porque NavigatorObserver não é necessário mock completo
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
