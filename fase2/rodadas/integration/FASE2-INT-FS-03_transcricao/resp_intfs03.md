Abaixo está um teste de integração focado no fluxo completo: carregar músicas do Firestore fake, preencher o nome, selecionar músicas, salvar e verificar o documento persistido na coleção `playlists`.

 Teste de integração — Criar Playlist

```
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  group('Criar Playlist', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() async {
      mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(
          uid: 'usuario-123',
          email: 'user@test.com',
        ),
      );

      fakeFirestore = FakeFirebaseFirestore();

      // Dados que a CriarPlaylistScreen deve carregar ao ser montada.
      await fakeFirestore.collection('musica').add({
        'track_name': 'Imagine',
        'artist_name': 'John Lennon',
      });

      await fakeFirestore.collection('musica').add({
        'track_name': 'Bohemian Rhapsody',
        'artist_name': 'Queen',
      });

      await fakeFirestore.collection('musica').add({
        'track_name': 'Billie Jean',
        'artist_name': 'Michael Jackson',
      });
    });

    Widget montarApp() {
      return MaterialApp(
        home: CriarPlaylistScreen(
          editPlaylist: const {},
          auth: mockAuth,
          firestore: fakeFirestore,
        ),
      );
    }

    testWidgets(
      'fluxo completo: carrega musicas, seleciona musicas e salva playlist',
      (tester) async {
        await tester.pumpWidget(montarApp());

        // Aguarda a consulta ao Firestore fake e a atualização da tela.
        await tester.pumpAndSettle();

        // Verifica que as músicas retornadas pelo Firestore estão na tela.
        expect(
          find.text('Imagine - John Lennon'),
          findsOneWidget,
        );
        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );
        expect(
          find.text('Billie Jean - Michael Jackson'),
          findsOneWidget,
        );

        // Preenche o nome da playlist.
        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Nome da Playlist',
          ),
          'Minha Playlist',
        );

        // Seleciona "Imagine".
        final imagineTile = find.ancestor(
          of: find.text('Imagine - John Lennon'),
          matching: find.byType(ListTile),
        );

        await tester.tap(
          find.descendant(
            of: imagineTile,
            matching: find.byIcon(Icons.check_box_outline_blank),
          ),
        );

        // Seleciona "Bohemian Rhapsody".
        final bohemianTile = find.ancestor(
          of: find.text('Bohemian Rhapsody - Queen'),
          matching: find.byType(ListTile),
        );

        await tester.tap(
          find.descendant(
            of: bohemianTile,
            matching: find.byIcon(Icons.check_box_outline_blank),
          ),
        );

        await tester.pump();

        // Confirma visualmente que as duas músicas foram selecionadas.
        expect(
          find.descendant(
            of: imagineTile,
            matching: find.byIcon(Icons.check_box),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: bohemianTile,
            matching: find.byIcon(Icons.check_box),
          ),
          findsOneWidget,
        );

        // Salva a playlist.
        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        // Como _salvarPlaylist faz Navigator.pop(), a tela deve ter sido
        // removida da árvore.
        expect(find.byType(CriarPlaylistScreen), findsNothing);

        // Verifica diretamente o que foi persistido no Firestore fake.
        final playlistsSnapshot =
            await fakeFirestore.collection('playlists').get();

        expect(playlistsSnapshot.docs, hasLength(1));

        final playlist = playlistsSnapshot.docs.single.data();

        expect(playlist['userId'], 'usuario-123');
        expect(playlist['nome'], 'Minha Playlist');
        expect(
          playlist['musicas'],
          containsAll(<String>[
            'Imagine',
            'Bohemian Rhapsody',
          ]),
        );
        expect(playlist['musicas'], hasLength(2));

        // O campo é criado com Timestamp.now().
        expect(playlist['dataCriacao'], isA<Timestamp>());
      },
    );

    testWidgets(
      'nome vazio exibe erro e nao cria playlist',
      (tester) async {
        await tester.pumpWidget(montarApp());
        await tester.pumpAndSettle();

        // Tenta salvar sem informar o nome.
        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        expect(
          find.text('Nome da playlist é obrigatório'),
          findsOneWidget,
        );

        // Nenhum documento deve ter sido criado.
        final playlistsSnapshot =
            await fakeFirestore.collection('playlists').get();

        expect(playlistsSnapshot.docs, isEmpty);

        // A tela continua aberta.
        expect(find.byType(CriarPlaylistScreen), findsOneWidget);
      },
    );

    testWidgets(
      'playlist pode ser salva sem selecionar musicas',
      (tester) async {
        await tester.pumpWidget(montarApp());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Nome da Playlist',
          ),
          'Playlist Vazia',
        );

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final playlistsSnapshot =
            await fakeFirestore.collection('playlists').get();

        expect(playlistsSnapshot.docs, hasLength(1));

        final playlist = playlistsSnapshot.docs.single.data();

        expect(playlist['userId'], 'usuario-123');
        expect(playlist['nome'], 'Playlist Vazia');
        expect(playlist['musicas'], isEmpty);
        expect(playlist['dataCriacao'], isA<Timestamp>());
      },
    );
  });
}
```

 ### Observação importante

 O teste injeta `MockFirebaseAuth` e `FakeFirebaseFirestore` diretamente no widget, aproveitando os parâmetros opcionais que a `CriarPlaylistScreen` já oferece. Assim, ele **não acessa Firebase real**.

 Também há uma particularidade do código da tela: quando `_musicasFiltradas` está vazia, ela mostra o `CircularProgressIndicator`; portanto, `pumpAndSettle()` é usado depois da montagem para esperar a consulta fake terminar.

 Se o objetivo for manter **um único teste de integração do fluxo principal**, o primeiro `testWidgets` é o caso essencial; os outros dois cobrem comportamentos adicionais de validação e persistência.
