## Classificação: **(A) — o teste presume comportamentos/condições que não estavam corretamente configurados**

 Os erros apresentados são, em sua maioria, causados pelo próprio teste:

 - **`pumpAndSettle timed out`**: quando `musica` está vazia, o widget mostra permanentemente um `CircularProgressIndicator`. Portanto, `pumpAndSettle()` nunca encontra um estado sem animações. O helper do teste não poderia usar `pumpAndSettle()` indiscriminadamente.
- **Teste de scroll**: a asserção exigia que a música 19 estivesse necessariamente visível após um único `drag` de 500 px. Isso é uma suposição frágil sobre a geometria/viewport do teste.
- **Salvamento com usuário autenticado**: `MockFirebaseAuth(mockUser: user)` não significa necessariamente que o mock esteja no estado autenticado. A API de `firebase_auth_mocks` possui explicitamente o parâmetro `signedIn`; o teste deve usar `MockFirebaseAuth(signedIn: true, mockUser: user)`.  Dart packages+1
- **Falha simulada do Firestore**: a implementação anterior de `_FailingCollectionReference` era desnecessariamente frágil. `fake_cloud_firestore` suporta `add()` normalmente, mas para simular uma exceção especificamente no `add()` é mais apropriado usar Mockito.  Dart packages

 Há, porém, **um comportamento potencialmente incorreto na aplicação que o teste deve preservar e evidenciar**: `_salvarPlaylist()` ignora `_playlistName` e grava sempre `'nome': 'Nova Playlist'`. Isso não deve ser "corrigido" no teste. O teste deve registrar o comportamento atual. Se o requisito da aplicação for salvar o nome digitado pelo usuário, isso é um problema no widget, não no teste.

 ### Correção principal

 Substitua o arquivo de testes anterior por esta versão. Ela evita `pumpAndSettle()` durante a inicialização, autentica corretamente o `MockFirebaseAuth` e torna o teste de erro do Firestore determinístico.

```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sintonize/criar_playlist.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    FirebaseAuth? customAuth,
    FirebaseFirestore? customFirestore,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CriarPlaylistScreen(
          editPlaylist: const {},
          auth: customAuth ?? auth,
          firestore: customFirestore ?? firestore,
        ),
      ),
    );

    // NÃO usar pumpAndSettle aqui.
    //
    // O widget exibe CircularProgressIndicator quando
    // _musicasFiltradas está vazio. Nesse estado existe uma
    // animação contínua e pumpAndSettle nunca termina.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> adicionarMusicas() async {
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

  group('Renderização', () {
    testWidgets(
      'renderiza os elementos principais da tela',
      (tester) async {
        await pumpScreen(tester);

        expect(find.text('Criando Playlist'), findsOneWidget);
        expect(find.text('Nome da Playlist'), findsOneWidget);
        expect(
          find.text('Pesquisar Música ou Artista'),
          findsOneWidget,
        );
        expect(find.text('Salvar Playlist'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      },
    );

    testWidgets(
      'exibe as músicas carregadas do Firestore',
      (tester) async {
        await adicionarMusicas();

        await pumpScreen(tester);

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
      },
    );

    testWidgets(
      'formata corretamente nome da música e artista',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'sweet child o mine',
          'artist_name': 'guns n roses',
        });

        await pumpScreen(tester);

        expect(
          find.text('Sweet Child O Mine - Guns N Roses'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'usa Desconhecido quando artist_name é nulo',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'minha musica',
          'artist_name': null,
        });

        await pumpScreen(tester);

        expect(
          find.text('Minha Musica - Desconhecido'),
          findsOneWidget,
        );
      },
    );
  });

  group('Validação', () {
    testWidgets(
      'exibe SnackBar quando tenta salvar sem nome',
      (tester) async {
        await pumpScreen(tester);

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        expect(
          find.text('Nome da playlist é obrigatório'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'não salva quando o nome está vazio',
      (tester) async {
        await pumpScreen(tester);

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        final playlists =
            await firestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);
      },
    );

    testWidgets(
      'atualiza o nome da playlist ao digitar',
      (tester) async {
        await pumpScreen(tester);

        final nomeField = find.byType(TextField).first;

        await tester.enterText(
          nomeField,
          'Minha Playlist',
        );

        await tester.pump();

        expect(
          find.text('Minha Playlist'),
          findsOneWidget,
        );
      },
    );
  });

  group('Pesquisa', () {
    testWidgets(
      'filtra pelo nome da música',
      (tester) async {
        await adicionarMusicas();

        await pumpScreen(tester);

        final searchField = find.byType(TextField).at(1);

        await tester.enterText(
          searchField,
          'imagine',
        );
        await tester.pump();

        expect(
          find.text('Imagine - John Lennon'),
          findsOneWidget,
        );

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsNothing,
        );

        expect(
          find.text('Hotel California - Eagles'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'filtra pelo nome do artista',
      (tester) async {
        await adicionarMusicas();

        await pumpScreen(tester);

        final searchField = find.byType(TextField).at(1);

        await tester.enterText(
          searchField,
          'queen',
        );
        await tester.pump();

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );

        expect(
          find.text('Imagine - John Lennon'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'pesquisa não diferencia maiúsculas de minúsculas',
      (tester) async {
        await adicionarMusicas();

        await pumpScreen(tester);

        final searchField = find.byType(TextField).at(1);

        await tester.enterText(
          searchField,
          'QUEEN',
        );
        await tester.pump();

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'pesquisa sem resultado não exibe músicas',
      (tester) async {
        await adicionarMusicas();

        await pumpScreen(tester);

        final searchField = find.byType(TextField).at(1);

        await tester.enterText(
          searchField,
          'nao existe',
        );
        await tester.pump();

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsNothing,
        );

        expect(
          find.text('Imagine - John Lennon'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'limpar pesquisa restaura todas as músicas',
      (tester) async {
        await adicionarMusicas();

        await pumpScreen(tester);

        final searchField = find.byType(TextField).at(1);

        await tester.enterText(searchField, 'queen');
        await tester.pump();

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );

        expect(
          find.text('Imagine - John Lennon'),
          findsNothing,
        );

        await tester.enterText(searchField, '');
        await tester.pump();

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
      },
    );
  });

  group('Seleção de músicas', () {
    testWidgets(
      'seleciona uma música',
      (tester) async {
        await adicionarMusicas();

        await pumpScreen(tester);

        expect(
          find.byIcon(Icons.check_box_outline_blank),
          findsNWidgets(3),
        );

        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank).first,
        );
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'desseleciona uma música previamente selecionada',
      (tester) async {
        await adicionarMusicas();

        await pumpScreen(tester);

        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank).first,
        );
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsOneWidget,
        );

        await tester.tap(
          find.byIcon(Icons.check_box).first,
        );
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsNothing,
        );

        expect(
          find.byIcon(Icons.check_box_outline_blank),
          findsNWidgets(3),
        );
      },
    );

    testWidgets(
      'permite selecionar várias músicas',
      (tester) async {
        await adicionarMusicas();

        await pumpScreen(tester);

        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank).at(0),
        );
        await tester.pump();

        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank).at(0),
        );
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsNWidgets(2),
        );
      },
    );
  });

  group('Scroll', () {
    testWidgets(
      'permite rolar a lista de músicas',
      (tester) async {
        for (var i = 0; i < 50; i++) {
          await firestore.collection('musica').add({
            'track_name': 'musica $i',
            'artist_name': 'artista $i',
          });
        }

        await pumpScreen(tester);

        final listView = find.byType(ListView);

        expect(listView, findsOneWidget);

        // O primeiro item deve estar inicialmente visível.
        expect(
          find.text('Musica 0 - Artista 0'),
          findsOneWidget,
        );

        await tester.drag(
          listView,
          const Offset(0, -1000),
        );

        await tester.pump();

        // Não dependemos de uma música específica estar
        // exatamente na posição final. Verificamos que o
        // primeiro item saiu da viewport após o scroll.
        expect(
          find.text('Musica 0 - Artista 0'),
          findsNothing,
        );
      },
    );
  });

  group('Navegação', () {
    testWidgets(
      'botão voltar retorna para a tela anterior',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: ElevatedButton(
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
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Abrir'));

        // Aqui não usamos pumpAndSettle porque a tela pode
        // permanecer com CircularProgressIndicator quando
        // a coleção estiver vazia.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.text('Criando Playlist'),
          findsOneWidget,
        );

        await tester.tap(
          find.byIcon(Icons.arrow_back),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Abrir'),
          findsOneWidget,
        );

        expect(
          find.text('Criando Playlist'),
          findsNothing,
        );
      },
    );
  });

  group('Salvamento', () {
    testWidgets(
      'salva playlist quando existe usuário autenticado',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        // IMPORTANTE:
        // mockUser sozinho não deve ser usado como garantia de
        // autenticação. Explicitamente configuramos signedIn: true.
        final authenticatedAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: user,
        );

        await adicionarMusicas();

        await tester.pumpWidget(
          MaterialApp(
            home: CriarPlaylistScreen(
              editPlaylist: const {},
              auth: authenticatedAuth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        await tester.enterText(
          find.byType(TextField).first,
          'Minha Playlist',
        );

        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank).first,
        );
        await tester.pump();

        await tester.tap(
          find.text('Salvar Playlist'),
        );

        // Espera o Future de _salvarPlaylist.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final playlists =
            await firestore.collection('playlists').get();

        expect(
          playlists.docs,
          hasLength(1),
        );

        final data = playlists.docs.first.data();

        expect(
          data['userId'],
          'usuario-123',
        );

        // Este teste documenta o comportamento ATUAL do widget.
        // O widget usa literalmente 'Nova Playlist', ignorando
        // _playlistName.
        expect(
          data['nome'],
          'Nova Playlist',
        );

        expect(
          data['musicas'],
          contains('bohemian rhapsody'),
        );

        expect(
          data['dataCriacao'],
          isA<Timestamp>(),
        );
      },
    );

    testWidgets(
      'não salva quando não existe usuário autenticado',
      (tester) async {
        await pumpScreen(tester);

        await tester.enterText(
          find.byType(TextField).first,
          'Minha Playlist',
        );

        await tester.tap(
          find.text('Salvar Playlist'),
        );

        await tester.pump();

        final playlists =
            await firestore.collection('playlists').get();

        expect(
          playlists.docs,
          isEmpty,
        );

        expect(
          find.text('Criando Playlist'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'salva somente as músicas selecionadas',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
        );

        final authenticatedAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: user,
        );

        await adicionarMusicas();

        await tester.pumpWidget(
          MaterialApp(
            home: CriarPlaylistScreen(
              editPlaylist: const {},
              auth: authenticatedAuth,
              firestore: firestore,
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Seleciona somente a primeira música.
        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank).first,
        );
        await tester.pump();

        await tester.enterText(
          find.byType(TextField).first,
          'Rock',
        );

        await tester.tap(
          find.text('Salvar Playlist'),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final playlists =
            await firestore.collection('playlists').get();

        expect(
          playlists.docs,
          hasLength(1),
        );

        final musicas =
            playlists.docs.first.data()['musicas'] as List;

        expect(
          musicas,
          hasLength(1),
        );

        expect(
          musicas,
          contains('bohemian rhapsody'),
        );
      },
    );
  });

  group('Erro no Firestore', () {
    testWidgets(
      'exibe SnackBar quando o salvamento falha',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
        );

        final authenticatedAuth = MockFirebaseAuth(
          signedIn: true,
          mockUser: user,
        );

        final mockFirestore = MockFirebaseFirestore();
        final musicaCollection = firestore.collection('musica');
        final playlistsCollection = MockCollectionReference();

        when(
          mockFirestore.collection('musica'),
        ).thenReturn(musicaCollection);

        when(
          mockFirestore.collection('playlists'),
        ).thenReturn(playlistsCollection);

        when(
          playlistsCollection.add(any),
        ).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'unavailable',
            message: 'Falha simulada de rede',
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: CriarPlaylistScreen(
              editPlaylist: const {},
              auth: authenticatedAuth,
              firestore: mockFirestore,
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        await tester.enterText(
          find.byType(TextField).first,
          'Minha Playlist',
        );

        await tester.tap(
          find.text('Salvar Playlist'),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.textContaining(
            'Erro ao salvar a playlist:',
          ),
          findsOneWidget,
        );

        expect(
          find.textContaining(
            'Falha simulada de rede',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
```

 ### Um ponto que permanece como possível problema da aplicação

 O teste de sucesso agora deve chegar à gravação porque o mock está explicitamente autenticado:

```
final authenticatedAuth = MockFirebaseAuth(
  signedIn: true,
  mockUser: user,
);
```

 Isso corresponde à API do `firebase_auth_mocks`, que diferencia explicitamente o estado `signedIn` do objeto `mockUser`.  Dart packages+1

 Já este trecho do widget continua sendo problemático **se o requisito for salvar o nome digitado**:

```
await widget.firestore.collection('playlists').add({
  'userId': user.uid,
  'nome': 'Nova Playlist',
  'musicas': _musicasSelecionadas,
  'dataCriacao': Timestamp.now(),
});
```

 O usuário pode digitar `"Minha Playlist"`, mas o documento será gravado com `"Nova Playlist"`. **Não alterei o teste para esconder isso**; a asserção continua verificando o comportamento efetivamente implementado.

 Outro detalhe: o estado vazio é usado simultaneamente para representar **"ainda carregando"** e **"nenhuma música encontrada"**:

```
_musicasFiltradas.isEmpty
    ? const Center(child: CircularProgressIndicator())
    : ListView.builder(...)
```

 Por isso o `pumpAndSettle()` não deve ser utilizado na inicialização de uma tela sem músicas. O `fake_cloud_firestore` oferece `collection.add()` e `query.get()` normalmente, então não há necessidade de alterar o widget para os testes com dados reais em memória.  Dart packages

 **Se o novo teste de salvamento ainda resultar em `playlists.docs == []`, isso muda a classificação desse caso para (B)**: nesse ponto o teste estará configurado com `signedIn: true`, e uma ausência de gravação indicaria que o comportamento da aplicação/mock merece investigação, não que a asserção deva ser enfraquecida.