import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;

  setUp(() {
    firestore = FakeFirebaseFirestore();

    auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(
        uid: 'usuario-teste-123',
        email: 'teste@sintonize.com',
      ),
    );
  });

  Future<void> inserirMusicasDeTeste() async {
    await firestore.collection('musica').add({
      'track_name': 'bohemian rhapsody',
      'artist_name': 'queen',
    });

    await firestore.collection('musica').add({
      'track_name': 'imagine',
      'artist_name': 'john lennon',
    });

    await firestore.collection('musica').add({
      'track_name': 'hotel california',
      'artist_name': 'eagles',
    });
  }

  // ---------------------------------------------------------------------------
  // 1. Fluxo de sucesso ponta a ponta
  // ---------------------------------------------------------------------------
  testWidgets(
    'deve criar playlist, salvar músicas no Firestore e voltar para a tela anterior',
    (WidgetTester tester) async {
      await inserirMusicasDeTeste();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                child: const Text('Abrir Criar Playlist'),
                onPressed: () {
                  Navigator.push(
                    tester.element(find.byType(ElevatedButton)),
                    MaterialPageRoute(
                      builder: (_) => CriarPlaylistScreen(
                        editPlaylist: const {},
                        auth: auth,
                        firestore: firestore,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Abrir Criar Playlist'), findsOneWidget);

      // Abre a tela de criação.
      await tester.tap(find.text('Abrir Criar Playlist'));
      await tester.pumpAndSettle();

      expect(find.text('Nome da Playlist'), findsOneWidget);
      expect(
        find.text('Pesquisar Música ou Artista'),
        findsOneWidget,
      );

      // Aguarda o carregamento das músicas.
      await tester.pumpAndSettle();

      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsOneWidget,
      );
      expect(
        find.text('Imagine - John Lennon'),
        findsOneWidget,
      );
      expect(
        find.text('Hotel California - Eagles'),
        findsOneWidget,
      );

      // O primeiro TextField é o nome da playlist.
      final camposTexto = find.byType(TextField);

      expect(camposTexto, findsNWidgets(2));

      await tester.enterText(
        camposTexto.at(0),
        'Minha Playlist',
      );

      // Seleciona "Bohemian Rhapsody".
      final bohemianTile = find.ancestor(
        of: find.text('Bohemian Rhapsody - Queen'),
        matching: find.byType(ListTile),
      );

      expect(bohemianTile, findsOneWidget);

      await tester.tap(
        find.descendant(
          of: bohemianTile,
          matching: find.byType(IconButton),
        ),
      );

      // Seleciona "Imagine".
      final imagineTile = find.ancestor(
        of: find.text('Imagine - John Lennon'),
        matching: find.byType(ListTile),
      );

      expect(imagineTile, findsOneWidget);

      await tester.tap(
        find.descendant(
          of: imagineTile,
          matching: find.byType(IconButton),
        ),
      );

      await tester.pump();

      // Verifica que as duas músicas foram marcadas.
      expect(
        find.descendant(
          of: bohemianTile,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      expect(
        find.descendant(
          of: imagineTile,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      // Salva a playlist.
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      // _salvarPlaylist() chama Navigator.pop() após o sucesso.
      expect(
        find.text('Abrir Criar Playlist'),
        findsOneWidget,
      );

      expect(
        find.text('Nome da Playlist'),
        findsNothing,
      );

      // Verifica o documento salvo.
      final playlists = await firestore
          .collection('playlists')
          .get();

      expect(playlists.docs, hasLength(1));

      final data = playlists.docs.first.data();

      expect(
        data['userId'],
        equals('usuario-teste-123'),
      );

      // O código da aplicação atualmente grava um nome fixo.
      expect(
        data['nome'],
        equals('Nova Playlist'),
      );

      expect(
        data['musicas'],
        containsAll([
          'bohemian rhapsody',
          'imagine',
        ]),
      );

      expect(
        data['musicas'],
        hasLength(2),
      );

      expect(
        data['dataCriacao'],
        isA<Timestamp>(),
      );
    },
  );

  // ---------------------------------------------------------------------------
  // 2. Nome da playlist vazio
  // ---------------------------------------------------------------------------
  testWidgets(
    'não deve salvar quando o nome da playlist estiver vazio e deve exibir SnackBar',
    (WidgetTester tester) async {
      await inserirMusicasDeTeste();

      await tester.pumpWidget(
        MaterialApp(
          home: CriarPlaylistScreen(
            editPlaylist: const {},
            auth: auth,
            firestore: firestore,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Não informa o nome e tenta salvar.
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pump();

      expect(
        find.text('Nome da playlist é obrigatório'),
        findsOneWidget,
      );

      // Nenhum documento deve ter sido criado.
      final playlists = await firestore
          .collection('playlists')
          .get();

      expect(
        playlists.docs,
        isEmpty,
      );

      // A tela deve continuar aberta.
      expect(
        find.text('Nome da Playlist'),
        findsOneWidget,
      );
    },
  );

  // ---------------------------------------------------------------------------
  // 3. Usuário não autenticado
  // ---------------------------------------------------------------------------
  testWidgets(
    'não deve salvar nem fechar a tela quando o usuário não estiver autenticado',
    (WidgetTester tester) async {
      await inserirMusicasDeTeste();

      final unauthenticatedAuth = MockFirebaseAuth(
        signedIn: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CriarPlaylistScreen(
            editPlaylist: const {},
            auth: unauthenticatedAuth,
            firestore: firestore,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final camposTexto = find.byType(TextField);

      expect(camposTexto, findsNWidgets(2));

      await tester.enterText(
        camposTexto.at(0),
        'Playlist sem usuário',
      );

      // Seleciona uma música.
      final musicTile = find.ancestor(
        of: find.text('Bohemian Rhapsody - Queen'),
        matching: find.byType(ListTile),
      );

      expect(musicTile, findsOneWidget);

      await tester.tap(
        find.descendant(
          of: musicTile,
          matching: find.byType(IconButton),
        ),
      );

      // Tenta salvar.
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      // Sem usuário autenticado, o código da aplicação não chama
      // Firestore e também não exibe uma mensagem de erro.
      final playlists = await firestore
          .collection('playlists')
          .get();

      expect(
        playlists.docs,
        isEmpty,
      );

      // Como Navigator.pop() não é chamado, a tela permanece aberta.
      expect(
        find.text('Nome da Playlist'),
        findsOneWidget,
      );

      expect(
        find.text('Salvar Playlist'),
        findsOneWidget,
      );
    },
  );

  // ---------------------------------------------------------------------------
  // 4. Verificação exata dos dados persistidos
  // ---------------------------------------------------------------------------
  testWidgets(
    'deve persistir exatamente userId, nome, musicas e dataCriacao em playlists',
    (WidgetTester tester) async {
      await inserirMusicasDeTeste();

      await tester.pumpWidget(
        MaterialApp(
          home: CriarPlaylistScreen(
            editPlaylist: const {},
            auth: auth,
            firestore: firestore,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final camposTexto = find.byType(TextField);

      expect(camposTexto, findsNWidgets(2));

      // Digita um nome diferente de "Nova Playlist" para verificar
      // exatamente o que a aplicação persiste.
      await tester.enterText(
        camposTexto.at(0),
        'Rock Favorito',
      );

      // Seleciona "Hotel California".
      final hotelTile = find.ancestor(
        of: find.text('Hotel California - Eagles'),
        matching: find.byType(ListTile),
      );

      expect(hotelTile, findsOneWidget);

      await tester.tap(
        find.descendant(
          of: hotelTile,
          matching: find.byType(IconButton),
        ),
      );

      // Salva.
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      final snapshot = await firestore
          .collection('playlists')
          .get();

      expect(
        snapshot.docs,
        hasLength(1),
      );

      final document = snapshot.docs.single;
      final data = document.data();

      // Verifica exatamente os campos persistidos.
      expect(
        data.keys.toSet(),
        equals({
          'userId',
          'nome',
          'musicas',
          'dataCriacao',
        }),
      );

      expect(
        data['userId'],
        equals('usuario-teste-123'),
      );

      // IMPORTANTE:
      // Apesar de o usuário ter digitado "Rock Favorito",
      // a implementação atual usa o valor fixo "Nova Playlist".
      expect(
        data['nome'],
        equals('Nova Playlist'),
      );

      expect(
        data['musicas'],
        equals([
          'hotel california',
        ]),
      );

      expect(
        data['dataCriacao'],
        isA<Timestamp>(),
      );

      expect(
        data.length,
        equals(4),
      );
    },
  );
}
