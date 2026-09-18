Abaixo está um arquivo de teste completo, por exemplo em `test/criar_playlist_screen_test.dart`. Ele usa `FakeFirebaseFirestore` para os dados e `MockFirebaseAuth` para o usuário autenticado.

 Testes de CriarPlaylistScreen

```
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/.../criar_playlist_screen.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;

  setUp(() async {
    firestore = FakeFirebaseFirestore();

    auth = MockFirebaseAuth(
      mockUser: MockUser(
        uid: 'usuario-teste-123',
        email: 'teste@sintonize.com',
        displayName: 'Usuário Teste',
      ),
    );

    await firestore.collection('musica').add({
      'track_name': 'shape of you',
      'artist_name': 'ed sheeran',
    });

    await firestore.collection('musica').add({
      'track_name': 'bohemian rhapsody',
      'artist_name': 'queen',
    });
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: CriarPlaylistScreen(
        editPlaylist: const {},
        auth: auth,
        firestore: firestore,
      ),
    );
  }

  testWidgets(
    'exibe as músicas carregadas do Firestore fake',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Aguarda o Future de _fetchMusicas().
      await tester.pumpAndSettle();

      expect(find.text('Shape Of You - Ed Sheeran'), findsOneWidget);
      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
    },
  );

  testWidgets(
    'permite digitar o nome da playlist',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final nomeField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Nome da Playlist',
      );

      expect(nomeField, findsOneWidget);

      await tester.enterText(nomeField, 'Minha Playlist');

      expect(find.text('Minha Playlist'), findsOneWidget);
    },
  );

  testWidgets(
    'filtra músicas pelo nome da música',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final searchField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Pesquisar Música ou Artista',
      );

      await tester.enterText(searchField, 'bohemian');
      await tester.pump();

      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
      expect(find.text('Shape Of You - Ed Sheeran'), findsNothing);
    },
  );

  testWidgets(
    'filtra músicas pelo nome do artista',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final searchField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Pesquisar Música ou Artista',
      );

      await tester.enterText(searchField, 'queen');
      await tester.pump();

      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
      expect(find.text('Shape Of You - Ed Sheeran'), findsNothing);
    },
  );

  testWidgets(
    'permite marcar e desmarcar uma música',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final musica = find.text('Shape Of You - Ed Sheeran');
      expect(musica, findsOneWidget);

      // Encontra o ListTile correspondente e seu IconButton.
      final listTile = find.ancestor(
        of: musica,
        matching: find.byType(ListTile),
      );

      final botaoSelecao = find.descendant(
        of: listTile,
        matching: find.byType(IconButton),
      );

      expect(botaoSelecao, findsOneWidget);

      // Inicialmente não selecionada.
      expect(find.byIcon(Icons.check_box_outline_blank), findsNWidgets(2));

      await tester.tap(botaoSelecao);
      await tester.pump();

      expect(find.byIcon(Icons.check_box), findsOneWidget);

      // Toca novamente para desmarcar.
      await tester.tap(botaoSelecao);
      await tester.pump();

      expect(find.byIcon(Icons.check_box), findsNothing);
      expect(find.byIcon(Icons.check_box_outline_blank), findsNWidgets(2));
    },
  );

  testWidgets(
    'exibe SnackBar quando tenta salvar sem informar nome',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pump();

      expect(
        find.text('Nome da playlist é obrigatório'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'salva a playlist com usuário e músicas selecionadas',
    (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Digita o nome da playlist.
      final nomeField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Nome da Playlist',
      );

      await tester.enterText(nomeField, 'Playlist Favorita');

      // Seleciona Shape Of You.
      final musica = find.text('Shape Of You - Ed Sheeran');

      final listTile = find.ancestor(
        of: musica,
        matching: find.byType(ListTile),
      );

      final botaoSelecao = find.descendant(
        of: listTile,
        matching: find.byType(IconButton),
      );

      await tester.tap(botaoSelecao);
      await tester.pump();

      // Coloca uma página anterior na pilha para que o Navigator.pop()
      // executado depois do salvamento possa ser observado.
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      // Volta para a tela e recria o estado para realizar o fluxo completo.
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(nomeField, 'Playlist Favorita');

      final musicaNovamente = find.text('Shape Of You - Ed Sheeran');
      final listTileNovamente = find.ancestor(
        of: musicaNovamente,
        matching: find.byType(ListTile),
      );

      final botaoNovamente = find.descendant(
        of: listTileNovamente,
        matching: find.byType(IconButton),
      );

      await tester.tap(botaoNovamente);
      await tester.pump();

      await tester.tap(find.text('Salvar Playlist'));

      // _salvarPlaylist() é assíncrono.
      await tester.pumpAndSettle();

      final playlists = await firestore.collection('playlists').get();

      expect(playlists.docs, hasLength(1));

      final playlist = playlists.docs.first.data();

      expect(playlist['userId'], 'usuario-teste-123');
      expect(playlist['nome'], 'Playlist Favorita');
      expect(
        playlist['musicas'],
        contains('shape of you'),
      );
      expect(playlist['dataCriacao'], isA<Timestamp>());
    },
  );
}
```

 Há um detalhe importante no import: substitua

```
import 'package:sintonize/.../criar_playlist_screen.dart';
```

 pelo caminho real do arquivo dentro de `lib/`, por exemplo:

```
import 'package:sintonize/screens/criar_playlist_screen.dart';
```

 ### Uma versão mais direta do teste de salvamento

 O teste acima pode ser simplificado. Como o `Navigator.pop()` precisa de uma rota anterior, o ideal é montar a tela dentro de uma rota de teste explícita. Assim você também testa a navegação depois do salvamento sem precisar recriar o widget.

 Teste de salvamento simplificado

```
testWidgets(
  'salva a playlist e retorna para a tela anterior',
  (WidgetTester tester) async {
    final firestore = FakeFirebaseFirestore();

    final auth = MockFirebaseAuth(
      mockUser: MockUser(
        uid: 'usuario-teste-123',
        email: 'teste@sintonize.com',
      ),
    );

    await firestore.collection('musica').add({
      'track_name': 'shape of you',
      'artist_name': 'ed sheeran',
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CriarPlaylistScreen(
                      editPlaylist: const {},
                      auth: auth,
                      firestore: firestore,
                    ),
                  ),
                );
              },
              child: const Text('Abrir'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    final nomeField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'Nome da Playlist',
    );

    await tester.enterText(nomeField, 'Playlist Favorita');

    final musica = find.text('Shape Of You - Ed Sheeran');

    final listTile = find.ancestor(
      of: musica,
      matching: find.byType(ListTile),
    );

    final botaoSelecao = find.descendant(
      of: listTile,
      matching: find.byType(IconButton),
    );

    await tester.tap(botaoSelecao);
    await tester.pump();

    await tester.tap(find.text('Salvar Playlist'));
    await tester.pumpAndSettle();

    final playlists = await firestore.collection('playlists').get();

    expect(playlists.docs, hasLength(1));
    expect(playlists.docs.first.data()['userId'], 'usuario-teste-123');
    expect(playlists.docs.first.data()['nome'], 'Playlist Favorita');
    expect(
      playlists.docs.first.data()['musicas'],
      ['shape of you'],
    );
    expect(
      playlists.docs.first.data()['dataCriacao'],
      isA<Timestamp>(),
    );

    // O _salvarPlaylist chama Navigator.pop().
    expect(find.text('Abrir'), findsOneWidget);
  },
);
```

 Esse segundo teste é o fluxo mais fiel ao comportamento real: **abrir tela → preencher nome → selecionar música → salvar → verificar Firestore → verificar `Navigator.pop()`**.

 Também vale observar que `editPlaylist` é obrigatório no construtor, mas **não é utilizado pelo widget mostrado**; por isso `const {}` é suficiente nos testes.
