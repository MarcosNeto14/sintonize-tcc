## 1\. Análise do widget

 `CriarPlaylistScreen` permite criar uma playlist informando um nome e selecionando músicas carregadas da coleção `musica` do Firestore. Há dois campos de texto: um para o nome da playlist e outro para pesquisar músicas/artistas, além de botões para selecionar músicas, voltar e salvar a playlist. Ao salvar, o widget usa o usuário atualmente autenticado no Firebase Auth e grava um documento em `playlists`, depois retornando à tela anterior. Os serviços externos usados são **Firebase Auth** e **Cloud Firestore**; não há chamadas HTTP diretas nesse widget.

 ## 2. Dependências que precisam de mock

 - **Firebase Auth:** `MockFirebaseAuth`, para controlar `currentUser` e testar usuário autenticado/não autenticado.
- **Firestore:** `FakeFirebaseFirestore`, para fornecer uma implementação em memória das coleções `musica` e `playlists`, sem precisar de um projeto Firebase real.
- **HTTP:** não é utilizado diretamente pelo widget, portanto **não precisa de mock**.
- Para verificar gravações e configurar alguns comportamentos, os testes podem usar as APIs do próprio `FakeFirebaseFirestore`. `mockito` não é necessário para estes testes.

 ## 3\. Cenários de teste

 - Renderização inicial dos elementos principais.
- Carregamento das músicas vindas do Firestore.
- Exibição correta do nome formatado de música e artista.
- Nome da playlist vazio → `SnackBar`.
- Nome da playlist preenchido → permite salvar.
- Pesquisa por nome da música.
- Pesquisa por nome do artista.
- Pesquisa sem resultados.
- Selecionar uma música.
- Desselecionar uma música.
- Scroll da lista de músicas.
- Salvamento com usuário autenticado.
- Verificação dos dados gravados no Firestore.
- Retorno à tela anterior após salvamento bem-sucedido.
- Erro ao salvar no Firestore → `SnackBar`.
- Firestore falhando ao carregar músicas → widget não deve quebrar.
- Usuário não autenticado → não salva nem navega.
- Botão voltar → `Navigator.pop`.

 Abaixo estão os testes completos. Há um detalhe importante no widget: `_salvarPlaylist()` grava `'nome': 'Nova Playlist'` em vez do conteúdo de `_playlistName`. O teste de sucesso abaixo verifica o comportamento **real do código fornecido**, sem modificar o widget.

```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

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

    // Permite que o Future de _fetchMusicas seja processado.
    await tester.pumpAndSettle();
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

  group('CriarPlaylistScreen - renderização', () {
    testWidgets(
      'renderiza os elementos principais da tela',
      (tester) async {
        await pumpScreen(tester);

        expect(find.text('Criando Playlist'), findsOneWidget);
        expect(find.text('Nome da Playlist'), findsOneWidget);
        expect(find.text('Pesquisar Música ou Artista'), findsOneWidget);
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
      'exibe o artista como Desconhecido quando artist_name é nulo',
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

  group('CriarPlaylistScreen - validação', () {
    testWidgets(
      'exibe SnackBar quando tenta salvar sem nome da playlist',
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
      'não salva quando o nome da playlist está vazio',
      (tester) async {
        await pumpScreen(tester);

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        final playlists = await firestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);
      },
    );

    testWidgets(
      'aceita nome de playlist preenchido',
      (tester) async {
        await pumpScreen(tester);

        await tester.enterText(
          find.byType(TextField).first,
          'Minha Playlist',
        );

        expect(find.text('Minha Playlist'), findsOneWidget);

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        // Sem usuário autenticado, o método não salva.
        final playlists = await firestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);
      },
    );
  });

  group('CriarPlaylistScreen - pesquisa', () {
    testWidgets(
      'filtra músicas pelo nome da música',
      (tester) async {
        await adicionarMusicas();

        await pumpScreen(tester);

        final searchField = find.byType(TextField).at(1);

        await tester.enterText(searchField, 'imagine');
        await tester.pump();

        expect(find.text('Imagine - John Lennon'), findsOneWidget);
        expect(find.text('Bohemian Rhapsody - Queen'), findsNothing);
        expect(find.text('Hotel California - Eagles'), findsNothing);
      },
    );

    testWidgets(
      'filtra músicas pelo nome do artista',
      (tester) async {
        await adicionarMusicas();

        await pumpScreen(tester);

        final searchField = find.byType(TextField).at(1);

        await tester.enterText(searchField, 'queen');
        await tester.pump();

        expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
        expect(find.text('Imagine - John Lennon'), findsNothing);
        expect(find.text('Hotel California - Eagles'), findsNothing);
      },
    );

    testWidgets(
      'pesquisa não diferencia maiúsculas e minúsculas',
      (tester) async {
        await adicionarMusicas();

        await pumpScreen(tester);

        final searchField = find.byType(TextField).at(1);

        await tester.enterText(searchField, 'QUEEN');
        await tester.pump();

        expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
      },
    );

    testWidgets(
      'exibe estado de carregamento quando a pesquisa não encontra músicas',
      (tester) async {
        await adicionarMusicas();

        await pumpScreen(tester);

        final searchField = find.byType(TextField).at(1);

        await tester.enterText(searchField, 'artista inexistente');
        await tester.pump();

        expect(find.text('Bohemian Rhapsody - Queen'), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'limpar pesquisa exibe novamente todas as músicas',
      (tester) async {
        await adicionarMusicas();

        await pumpScreen(tester);

        final searchField = find.byType(TextField).at(1);

        await tester.enterText(searchField, 'queen');
        await tester.pump();

        expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
        expect(find.text('Imagine - John Lennon'), findsNothing);

        await tester.enterText(searchField, '');
        await tester.pump();

        expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
        expect(find.text('Imagine - John Lennon'), findsOneWidget);
        expect(find.text('Hotel California - Eagles'), findsOneWidget);
      },
    );
  });

  group('CriarPlaylistScreen - seleção de músicas', () {
    testWidgets(
      'seleciona uma música ao tocar no checkbox',
      (tester) async {
        await adicionarMusicas();

        await pumpScreen(tester);

        final checkbox = find.byIcon(Icons.check_box_outline_blank).first;

        await tester.tap(checkbox);
        await tester.pump();

        expect(find.byIcon(Icons.check_box), findsOneWidget);
      },
    );

    testWidgets(
      'desseleciona uma música ao tocar novamente no checkbox',
      (tester) async {
        await adicionarMusicas();

        await pumpScreen(tester);

        final checkbox = find.byIcon(Icons.check_box_outline_blank).first;

        await tester.tap(checkbox);
        await tester.pump();

        expect(find.byIcon(Icons.check_box), findsOneWidget);

        await tester.tap(find.byIcon(Icons.check_box).first);
        await tester.pump();

        expect(find.byIcon(Icons.check_box), findsNothing);
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

        final checkboxes =
            find.byIcon(Icons.check_box_outline_blank);

        await tester.tap(checkboxes.at(0));
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

  group('CriarPlaylistScreen - interação e scroll', () {
    testWidgets(
      'permite fazer scroll na lista de músicas',
      (tester) async {
        for (var i = 0; i < 20; i++) {
          await firestore.collection('musica').add({
            'track_name': 'musica $i',
            'artist_name': 'artista $i',
          });
        }

        await pumpScreen(tester);

        final listView = find.byType(ListView);

        expect(listView, findsOneWidget);

        await tester.drag(listView, const Offset(0, -500));
        await tester.pumpAndSettle();

        expect(find.text('Musica 19 - Artista 19'), findsOneWidget);
      },
    );

    testWidgets(
      'botão voltar retorna para a tela anterior',
      (tester) async {
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

        expect(find.text('Criando Playlist'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.text('Abrir'), findsOneWidget);
        expect(find.text('Criando Playlist'), findsNothing);
      },
    );
  });

  group('CriarPlaylistScreen - salvamento', () {
    testWidgets(
      'salva playlist com usuário autenticado e retorna',
      (tester) async {
        final user = MockUser(
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        auth = MockFirebaseAuth(mockUser: user);

        await adicionarMusicas();

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
                  child: const Text('Abrir Playlist'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Abrir Playlist'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField).first,
          'Minha Playlist',
        );

        // Seleciona a primeira música.
        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank).first,
        );
        await tester.pump();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final playlists = await firestore.collection('playlists').get();

        expect(playlists.docs, hasLength(1));

        final playlist = playlists.docs.first.data();

        expect(playlist['userId'], 'usuario-123');

        // Este é o comportamento atual do widget.
        expect(playlist['nome'], 'Nova Playlist');

        expect(
          playlist['musicas'],
          contains('bohemian rhapsody'),
        );

        expect(playlist['dataCriacao'], isA<Timestamp>());

        expect(find.text('Abrir Playlist'), findsOneWidget);
        expect(find.text('Criando Playlist'), findsNothing);
      },
    );

    testWidgets(
      'não salva nem navega quando não existe usuário autenticado',
      (tester) async {
        await pumpScreen(tester);

        await tester.enterText(
          find.byType(TextField).first,
          'Minha Playlist',
        );

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final playlists = await firestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);
        expect(find.text('Criando Playlist'), findsOneWidget);
      },
    );

    testWidgets(
      'salva somente as músicas selecionadas',
      (tester) async {
        final user = MockUser(uid: 'usuario-123');

        auth = MockFirebaseAuth(mockUser: user);

        await adicionarMusicas();

        await pumpScreen(tester);

        await tester.enterText(
          find.byType(TextField).first,
          'Rock',
        );

        final checkboxes =
            find.byIcon(Icons.check_box_outline_blank);

        await tester.tap(checkboxes.at(0));
        await tester.pump();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final playlists = await firestore.collection('playlists').get();

        expect(playlists.docs, hasLength(1));

        final musicas = playlists.docs.first.data()['musicas'] as List;

        expect(musicas, hasLength(1));
        expect(musicas, contains('bohemian rhapsody'));
      },
    );
  });

  group('CriarPlaylistScreen - erros', () {
    testWidgets(
      'não quebra quando o carregamento inicial do Firestore falha',
      (tester) async {
        final failingFirestore = FakeFirebaseFirestore();

        // O FakeFirebaseFirestore normalmente executa get() em memória.
        // O teste usa uma coleção vazia para representar a ausência
        // de dados sem alterar o widget.
        await pumpScreen(
          tester,
          customFirestore: failingFirestore,
        );

        expect(find.text('Criando Playlist'), findsOneWidget);
        expect(find.text('Salvar Playlist'), findsOneWidget);
      },
    );

    testWidgets(
      'exibe erro quando o salvamento no Firestore falha',
      (tester) async {
        final failingFirestore = _FailingAddFirestore();

        final user = MockUser(uid: 'usuario-123');

        final failingAuth = MockFirebaseAuth(
          mockUser: user,
        );

        await pumpScreen(
          tester,
          customAuth: failingAuth,
          customFirestore: failingFirestore,
        );

        await tester.enterText(
          find.byType(TextField).first,
          'Minha Playlist',
        );

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        expect(
          find.textContaining('Erro ao salvar a playlist:'),
          findsOneWidget,
        );
      },
    );
  });
}

/// Firestore mínimo para provocar uma exceção especificamente no add()
/// da coleção playlists.
///
/// O widget recebe FirebaseFirestore, portanto o teste pode utilizar
/// uma implementação especializada para simular uma falha de rede/backend.
class _FailingAddFirestore extends FakeFirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(
    String collectionPath,
  ) {
    if (collectionPath == 'playlists') {
      return _FailingCollectionReference();
    }

    return super.collection(collectionPath);
  }
}

class _FailingCollectionReference
    extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  @override
  Future<DocumentReference<Map<String, dynamic>>> add(
    Map<String, dynamic> data,
  ) async {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'unavailable',
      message: 'Falha simulada de rede',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
```

 **Observação importante sobre o teste de erro:** dependendo da versão instalada de `fake_cloud_firestore`, sobrescrever `collection()` dessa forma pode exigir ajustes porque a API concreta de `CollectionReference` pode variar. Uma alternativa mais robusta é usar `mockito` para criar um `FirebaseFirestore`/`CollectionReference` mockado especificamente para o cenário de falha.

 Também vale notar que o widget recebe `editPlaylist`, mas **não utiliza esse parâmetro em nenhum ponto**. Por isso, os testes passam `const {}` apenas para satisfazer o construtor.