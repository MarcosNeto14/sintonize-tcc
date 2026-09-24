Abaixo está um arquivo de teste completo, assumindo que CriarPlaylistScreen está em lib/criar_playlist.dart. Ele usa MockFirebaseAuth e FakeFirebaseFirestore, sem depender de Firebase real.

Escrita
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late MockUser mockUser;

  setUp(() {
    mockUser = MockUser(
      isAnonymous: false,
      uid: 'usuario-teste-123',
      email: 'teste@sintonize.com',
      displayName: 'Usuário Teste',
    );

    mockAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: mockUser,
    );

    fakeFirestore = FakeFirebaseFirestore();
  });

  Future<void> popularMusicas() async {
    await fakeFirestore.collection('musica').add({
      'track_name': 'bohemian rhapsody',
      'artist_name': 'queen',
    });

    await fakeFirestore.collection('musica').add({
      'track_name': 'imagine',
      'artist_name': 'john lennon',
    });
  }

  Future<void> montarTela(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CriarPlaylistScreen(
          editPlaylist: const {},
          auth: mockAuth,
          firestore: fakeFirestore,
        ),
      ),
    );

    // _fetchMusicas() é assíncrono.
    await tester.pumpAndSettle();
  }

  testWidgets(
    'deve criar playlist com nome e música selecionada',
    (WidgetTester tester) async {
      await popularMusicas();
      await montarTela(tester);

      // Verifica que as músicas do Firestore fake apareceram.
      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
      expect(find.text('Imagine - John Lennon'), findsOneWidget);

      // 1. Digita o nome da playlist.
      final nomeField = find.byType(TextField).first;

      await tester.enterText(nomeField, 'Minhas Favoritas');
      await tester.pump();

      // 2. Seleciona uma música.
      final musicaTile = find.byType(ListTile).first;
      final checkbox = find.descendant(
        of: musicaTile,
        matching: find.byIcon(Icons.check_box_outline_blank),
      );

      expect(checkbox, findsOneWidget);

      await tester.tap(checkbox);
      await tester.pump();

      // A música agora deve estar marcada.
      expect(
        find.descendant(
          of: musicaTile,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      // 3. Salva a playlist.
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      // Navigator.pop() deve ter sido chamado.
      // Como a tela é a rota inicial, verificamos principalmente o Firestore.

      // 4. Verifica o documento criado.
      final playlists =
          await fakeFirestore.collection('playlists').get();

      expect(playlists.docs, hasLength(1));

      final playlist = playlists.docs.first;

      expect(playlist.data()['userId'], equals('usuario-teste-123'));

      // Observação: a implementação atual da tela salva sempre
      // "Nova Playlist", e não o valor digitado pelo usuário.
      expect(playlist.data()['nome'], equals('Nova Playlist'));

      expect(
        playlist.data()['musicas'],
        equals(['bohemian rhapsody']),
      );

      expect(
        playlist.data()['dataCriacao'],
        isA<Timestamp>(),
      );
    },
  );

  testWidgets(
    'deve exibir erro quando o nome da playlist estiver vazio',
    (WidgetTester tester) async {
      await popularMusicas();
      await montarTela(tester);

      // Não preenche o nome.

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pump();

      // Deve exibir o SnackBar.
      expect(
        find.text('Nome da playlist é obrigatório'),
        findsOneWidget,
      );

      // Nenhuma playlist deve ter sido criada.
      final playlists =
          await fakeFirestore.collection('playlists').get();

      expect(playlists.docs, isEmpty);
    },
  );
}

Observação importante

Há um bug no código da tela em relação ao requisito: embora o teste digite "Minhas Favoritas", _salvarPlaylist() grava:

'nome': 'Nova Playlist',


em vez de usar _playlistName.

Se o comportamento esperado é realmente salvar o nome digitado, altere para:

'nome': _playlistName,


e então substitua no teste:

expect(playlist.data()['nome'], equals('Nova Playlist'));


por:

expect(playlist.data()['nome'], equals('Minhas Favoritas'));


Com o código atual, o teste acima valida fielmente o comportamento existente, inclusive esse detalhe.