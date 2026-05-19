import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sintonize/screens/criar_playlist_screen.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late FakeFirebaseFirestore firestore;
  late MockNavigatorObserver navigatorObserver;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    navigatorObserver = MockNavigatorObserver();

    await firestore.collection('musica').add({
      'track_name': 'Shape of You',
      'artist_name': 'Ed Sheeran',
    });

    await firestore.collection('musica').add({
      'track_name': 'Believer',
      'artist_name': 'Imagine Dragons',
    });
  });

  Widget createWidget() {
    return MaterialApp(
      home: const CriarPlaylistScreen(
        editPlaylist: {},
      ),
      navigatorObservers: [navigatorObserver],
    );
  }

  group('CriarPlaylistScreen', () {
    testWidgets('renderiza elementos básicos da tela',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Criando Playlist'), findsOneWidget);
      expect(find.text('Salvar Playlist'), findsOneWidget);
    });

    testWidgets('carrega músicas (estado inicial loading)',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('exibe snackbar ao salvar sem nome',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pump();

      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);
    });

    testWidgets('digita nome da playlist corretamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'Minha Playlist',
      );

      expect(find.text('Minha Playlist'), findsOneWidget);
    });

    testWidgets('botão voltar realiza pop',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      verify(navigatorObserver.didPop(any, any)).called(1);
    });
  });
}
