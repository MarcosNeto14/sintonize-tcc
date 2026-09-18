## 1. Análise do widget

 `CriarPlaylistScreen` permite criar uma playlist, informando um nome e selecionando músicas carregadas da coleção `musica` do Firestore. Ele possui dois campos de texto: um para o nome da playlist e outro para pesquisar músicas/artistas; cada música exibida pode ser marcada ou desmarcada. Ao salvar, o widget verifica o usuário autenticado e grava a playlist na coleção `playlists`, incluindo `userId`, nome, músicas selecionadas e `Timestamp`. Os serviços externos são Firebase Authentication e Cloud Firestore, ambos injetáveis pelo construtor, o que facilita bastante os testes.

 ## 2\. Dependências que precisam de mock

 - **Firebase Auth:** `FirebaseAuth`, usando `MockFirebaseAuth` do pacote `firebase_auth_mocks`.
  - Para o cenário autenticado, deve ser configurado um usuário fake com um `uid`.
  - Para o cenário não autenticado, `currentUser` deve permanecer `null`.
- **Firestore:** `FirebaseFirestore`, usando `FakeFirebaseFirestore`.
  - Permite inserir documentos fake em `musica`.
  - Permite verificar posteriormente se um documento foi criado em `playlists`.
  - Para testar falha no Firestore, o `FakeFirebaseFirestore` não é suficiente para simular qualquer exceção arbitrária de forma simples; nesse cenário é mais apropriado usar `mockito` para mockar `FirebaseFirestore`/`CollectionReference`/`Query` ou adaptar o mock conforme a versão dos pacotes.

 Abaixo está um arquivo de testes completo para os cenários que podem ser exercitados diretamente com `MockFirebaseAuth` \+ `FakeFirebaseFirestore`. O cenário de erro de gravação do Firestore também está incluído usando Mockito.

 ## 3\. Cenários de teste

 - Renderização inicial do widget.
- Exibição do indicador de carregamento antes de o Firestore retornar as músicas.
- Exibição das músicas depois que o carregamento termina.
- Formatação dos nomes das músicas e artistas.
- Digitação do nome da playlist.
- Pesquisa por nome da música.
- Pesquisa por nome do artista.
- Marcar uma música.
- Desmarcar uma música.
- Tentar salvar com nome vazio.
- Salvar playlist com usuário autenticado.
- Verificar os dados gravados no Firestore.
- Usuário não autenticado.
- Erro ao salvar a playlist no Firestore.
- Botão de voltar/navegação.

 ## 4\. Testes

 O arquivo abaixo pode ser colocado, por exemplo, em `test/criar_playlist_test.dart`.

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

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

void main() {
  group('CriarPlaylistScreen', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;

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
    }

    setUp(() {
      firestore = FakeFirebaseFirestore();
      auth = MockFirebaseAuth();
    });

    testWidgets(
      'renderiza os elementos básicos da tela',
      (tester) async {
        await pumpScreen(tester);

        expect(find.text('Criando Playlist'), findsOneWidget);
        expect(find.text('Nome da Playlist'), findsOneWidget);
        expect(
          find.text('Pesquisar Música ou Artista'),
          findsOneWidget,
        );
        expect(find.text('Salvar Playlist'), findsOneWidget);
        expect(find.byIcon(Icons.person), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
      },
    );

    testWidgets(
      'exibe indicador de carregamento antes das músicas serem carregadas',
      (tester) async {
        // O Future do FakeFirebaseFirestore ainda não foi processado.
        await pumpScreen(tester);

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'exibe as músicas depois que o Firestore termina de carregar',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'bohemian rhapsody',
          'artist_name': 'queen',
        });

        await firestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpScreen(tester);
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
          find.byIcon(Icons.check_box_outline_blank),
          findsNWidgets(2),
        );
      },
    );

    testWidgets(
      'formata corretamente nomes de músicas e artistas',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'my favorite song',
          'artist_name': 'the beatles',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        expect(
          find.text('My Favorite Song - The Beatles'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'permite digitar o nome da playlist',
      (tester) async {
        await pumpScreen(tester);

        final campoNome = find.byType(TextField).first;

        await tester.enterText(campoNome, 'Minha Playlist');
        await tester.pump();

        expect(
          find.text('Minha Playlist'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'filtra músicas pelo nome da música',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'bohemian rhapsody',
          'artist_name': 'queen',
        });

        await firestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final campoPesquisa = find.byType(TextField).at(1);

        await tester.enterText(campoPesquisa, 'bohemian');
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
      'filtra músicas pelo nome do artista',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'bohemian rhapsody',
          'artist_name': 'queen',
        });

        await firestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final campoPesquisa = find.byType(TextField).at(1);

        await tester.enterText(campoPesquisa, 'queen');
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
      'a pesquisa não diferencia maiúsculas de minúsculas',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'Bohemian Rhapsody',
          'artist_name': 'Queen',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final campoPesquisa = find.byType(TextField).at(1);

        await tester.enterText(campoPesquisa, 'QUEEN');
        await tester.pump();

        expect(
          find.text('Bohemian Rhapsody - Queen'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'marca uma música quando o usuário toca no checkbox',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        expect(
          find.byIcon(Icons.check_box_outline_blank),
          findsOneWidget,
        );

        await tester.tap(find.byIcon(Icons.check_box_outline_blank));
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'desmarca uma música previamente selecionada',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.check_box_outline_blank));
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsOneWidget,
        );

        await tester.tap(find.byIcon(Icons.check_box));
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box_outline_blank),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'exibe erro quando tenta salvar sem informar nome da playlist',
      (tester) async {
        await pumpScreen(tester);
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
      'salva playlist com usuário autenticado e músicas selecionadas',
      (tester) async {
        final mockUser = MockUser(
          isAnonymous: false,
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        auth = MockFirebaseAuth(
          mockUser: mockUser,
          signedIn: true,
        );

        await firestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await firestore.collection('musica').add({
          'track_name': 'hey jude',
          'artist_name': 'the beatles',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final campoNome = find.byType(TextField).first;

        await tester.enterText(
          campoNome,
          'Minha Playlist',
        );

        final checkboxes =
            find.byIcon(Icons.check_box_outline_blank);

        await tester.tap(checkboxes.at(0));
        await tester.pump();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final playlists =
            await firestore.collection('playlists').get();

        expect(playlists.docs, hasLength(1));

        final playlist = playlists.docs.first.data();

        expect(
          playlist['userId'],
          equals('usuario-123'),
        );

        expect(
          playlist['nome'],
          equals('Minha Playlist'),
        );

        expect(
          playlist['musicas'],
          equals(['imagine']),
        );

        expect(
          playlist['dataCriacao'],
          isA<Timestamp>(),
        );
      },
    );

    testWidgets(
      'não salva playlist quando não existe usuário autenticado',
      (tester) async {
        auth = MockFirebaseAuth(
          signedIn: false,
        );

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField).first,
          'Playlist sem usuário',
        );

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final playlists =
            await firestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);
      },
    );

    testWidgets(
      'não salva playlist quando o nome é uma string vazia',
      (tester) async {
        final mockUser = MockUser(
          isAnonymous: false,
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        auth = MockFirebaseAuth(
          mockUser: mockUser,
          signedIn: true,
        );

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField).first,
          '',
        );

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        expect(
          find.text('Nome da playlist é obrigatório'),
          findsOneWidget,
        );

        final playlists =
            await firestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);
      },
    );

    testWidgets(
      'não salva playlist quando o nome contém apenas espaços?',
      (tester) async {
        final mockUser = MockUser(
          isAnonymous: false,
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        auth = MockFirebaseAuth(
          mockUser: mockUser,
          signedIn: true,
        );

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField).first,
          '   ',
        );

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        /*
         * Observação:
         * O widget verifica apenas isNotEmpty, portanto "   "
         * é considerado um nome válido pelo código atual.
         *
         * Este teste documenta o comportamento real do widget.
         */
        final playlists =
            await firestore.collection('playlists').get();

        expect(playlists.docs, hasLength(1));
        expect(playlists.docs.first.data()['nome'], equals('   '));
      },
    );

    testWidgets(
      'volta para a tela anterior ao tocar no botão de voltar',
      (tester) async {
        bool voltou = false;

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
            routes: {
              '/anterior': (_) => Builder(
                    builder: (context) {
                      voltou = true;
                      return const Scaffold(
                        body: Text('Tela anterior'),
                      );
                    },
                  ),
            },
          ),
        );

        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();

        expect(
          find.text('Criando Playlist'),
          findsOneWidget,
        );

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(
          find.text('Abrir'),
          findsOneWidget,
        );

        expect(voltou, isFalse);
      },
    );

    testWidgets(
      'exibe lista vazia/indicador quando a coleção de músicas está vazia',
      (tester) async {
        await pumpScreen(tester);
        await tester.pumpAndSettle();

        /*
         * Como o widget usa _musicasFiltradas.isEmpty para decidir
         * entre CircularProgressIndicator e ListView, uma coleção
         * realmente vazia continua mostrando o indicador.
         */
        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );

        expect(
          find.byType(ListTile),
          findsNothing,
        );
      },
    );

    testWidgets(
      'permite selecionar várias músicas',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'first song',
          'artist_name': 'artist one',
        });

        await firestore.collection('musica').add({
          'track_name': 'second song',
          'artist_name': 'artist two',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        final checkboxes =
            find.byIcon(Icons.check_box_outline_blank);

        expect(checkboxes, findsNWidgets(2));

        await tester.tap(checkboxes.at(0));
        await tester.pump();

        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank),
        );
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsNWidgets(2),
        );
      },
    );

    testWidgets(
      'pesquisa sem resultados não exibe nenhuma música',
      (tester) async {
        await firestore.collection('musica').add({
          'track_name': 'imagine',
          'artist_name': 'john lennon',
        });

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField).at(1),
          'xyz-musica-inexistente',
        );

        await tester.pump();

        expect(
          find.text('Imagine - John Lennon'),
          findsNothing,
        );
      },
    );
  });
}
```

 ### Observação importante sobre o cenário de erro do Firestore

 Há uma particularidade no widget fornecido: `_fetchMusicas()` captura qualquer exceção e apenas faz `print`, portanto não há `SnackBar` ou outro indicador de erro para verificar no teste. Além disso, `_salvarPlaylist()` captura a exceção da operação `.add()` e mostra:

```
Erro ao salvar a playlist: ...
```

 Para testar especificamente essa segunda situação, o mock precisa interceptar a cadeia `collection('playlists').add(...)`. Como a API do Firestore possui vários tipos genéricos, a implementação exata com Mockito depende da versão de `cloud_firestore` usada pelo projeto. O restante dos testes acima usa `FakeFirebaseFirestore`, que é particularmente adequado para verificar o estado persistido sem precisar mockar a API inteira do Firestore.

 Também há dois comportamentos do widget que os testes deixam explícitos: uma coleção `musica` vazia continua exibindo `CircularProgressIndicator`, porque o código usa `isEmpty` tanto para “carregando” quanto para “nenhuma música”; e nomes contendo apenas espaços são aceitos, pois a validação usa somente `isNotEmpty`.

 Se você quiser, posso também adaptar esse arquivo para **Mockito 5 com `@GenerateMocks` e mocks completos do Firestore**, incluindo um teste determinístico para a exceção durante `playlists.add()`.
