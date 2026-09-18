## 1. Análise do fluxo

 Ao montar a `CriarPlaylistScreen`, o widget consulta `musica` no Firestore e exibe as músicas encontradas; enquanto a lista ainda está vazia, o `CircularProgressIndicator` fica visível. O usuário informa o nome da playlist, seleciona músicas pelos checkboxes e toca em **Salvar Playlist**. Antes da persistência, há duas decisões principais: nome vazio gera um `SnackBar` e não tenta salvar; nome válido exige um usuário autenticado, e então o documento é criado em `playlists`. Em caso de sucesso, o documento contém `userId`, `nome`, `musicas` e `dataCriacao`, e a tela é fechada; se o Firestore falhar, a tela permanece aberta e exibe um `SnackBar` de erro.

 ## 2\. Dependências e mocks

 - **Firebase Auth:** `MockFirebaseAuth`, injetado no widget por `auth:`. Para o fluxo de sucesso/erro de autenticação, basta controlar `currentUser` por meio da configuração do mock.
- **Cloud Firestore:** `FakeFirebaseFirestore`, injetado por `firestore:`. Ele permite:
  - pré-popular `musica`;
  - executar o `get()` usado por `_fetchMusicas()`;
  - verificar posteriormente o documento criado em `playlists`.
- **Mockito:** não é necessário para os cenários básicos, porque `FakeFirebaseFirestore` já permite testar a persistência sem um mockito adicional.
- **Observação importante sobre "Firestore indisponível":** com o código fornecido, `FakeFirebaseFirestore` não oferece uma maneira simples de fazer especificamente o `.add()` falhar. Portanto, para cobrir esse cenário sem modificar o widget, o teste pode usar um mockito de `FirebaseFirestore`/`CollectionReference`, configurado para lançar uma exceção no `add()`. Abaixo mostro esse cenário separadamente.

 ## 3\. Estrutura dos testes

 Antes do `pumpWidget`, o `FakeFirebaseFirestore` deve ser preenchido com documentos em `musica`, por exemplo:

 - `track_name: 'imagine'`
- `artist_name: 'john lennon'`
- `track_name: 'yellow'`
- `artist_name: 'coldplay'`

 Depois, o widget é instanciado com **os dois serviços injetados** e, obrigatoriamente, com `editPlaylist`, mesmo que a implementação atual não use esse parâmetro:

```
CriarPlaylistScreen(
  auth: mockAuth,
  firestore: fakeFirestore,
  editPlaylist: {},
)
```

 Como `_fetchMusicas()` é assíncrono, os testes devem usar `await tester.pumpAndSettle()` depois do `pumpWidget` para aguardar a consulta ao Firestore fake.

 Para validar o estado intermediário de carregamento, há uma particularidade: com o `FakeFirebaseFirestore`, a consulta pode completar rapidamente. O teste pode fazer o primeiro `pumpWidget` e verificar o indicador antes de executar o `pumpAndSettle()`.

 ## 4\. Cenários de teste

 - **Sucesso ponta a ponta:** carrega músicas → informa nome → seleciona uma ou mais músicas → salva → verifica documento em `playlists`.
- **Nome vazio:** toca em **Salvar Playlist** sem preencher o nome → aparece o `SnackBar` → nenhum documento é criado.
- **Usuário não autenticado:** nome válido e música selecionada, mas `currentUser == null` → nenhuma gravação ocorre e a tela permanece aberta.
- **Falha ao salvar:** nome válido e usuário autenticado, mas `add()` lança exceção → `SnackBar` de erro aparece e a tela não é fechada.
- **Carregamento:** imediatamente após montar a tela, o indicador de progresso deve estar visível; após a consulta terminar, as músicas devem aparecer.
- **SnackBar de validação:** confirma especificamente a mensagem `Nome da playlist é obrigatório`.

 ## 5\. Testes

 Abaixo está um arquivo completo, por exemplo `test/criar_playlist_test.dart`. O primeiro bloco cobre os cenários que podem ser exercitados diretamente com `FakeFirebaseFirestore` e `MockFirebaseAuth`; o último usa Mockito para simular a falha do Firestore.

```
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  group('CriarPlaylistScreen', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;

    Future<void> seedMusicas() async {
      await fakeFirestore.collection('musica').add({
        'track_name': 'imagine',
        'artist_name': 'john lennon',
      });

      await fakeFirestore.collection('musica').add({
        'track_name': 'yellow',
        'artist_name': 'coldplay',
      });
    }

    Widget buildScreen() {
      return MaterialApp(
        home: CriarPlaylistScreen(
          auth: mockAuth,
          firestore: fakeFirestore,
          editPlaylist: {},
        ),
      );
    }

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
    });

    testWidgets(
      'fluxo de sucesso: busca músicas, seleciona músicas, salva e persiste corretamente',
      (WidgetTester tester) async {
        await seedMusicas();

        final user = MockUser(
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
          signedIn: true,
        );

        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        expect(find.text('Imagine - John Lennon'), findsOneWidget);
        expect(find.text('Yellow - Coldplay'), findsOneWidget);

        final nomePlaylist =
            find.widgetWithText(TextField, 'Nome da Playlist');

        expect(nomePlaylist, findsOneWidget);

        await tester.enterText(nomePlaylist, 'Minhas Favoritas');

        expect(find.text('Minhas Favoritas'), findsOneWidget);

        final imagineTile = find.ancestor(
          of: find.text('Imagine - John Lennon'),
          matching: find.byType(ListTile),
        );

        expect(imagineTile, findsOneWidget);

        final imagineCheckbox = find.descendant(
          of: imagineTile,
          matching: find.byIcon(Icons.check_box_outline_blank),
        );

        expect(imagineCheckbox, findsOneWidget);

        await tester.tap(imagineCheckbox);
        await tester.pump();

        expect(
          find.descendant(
            of: imagineTile,
            matching: find.byIcon(Icons.check_box),
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final playlists =
            await fakeFirestore.collection('playlists').get();

        expect(playlists.docs, hasLength(1));

        final playlist = playlists.docs.single.data();

        expect(playlist['userId'], 'usuario-123');
        expect(playlist['nome'], 'Minhas Favoritas');
        expect(playlist['musicas'], ['imagine']);
        expect(playlist['dataCriacao'], isA<Timestamp>());

        expect(find.text('Criando Playlist'), findsNothing);
      },
    );

    testWidgets(
      'mostra indicador de carregamento antes de as músicas serem carregadas',
      (WidgetTester tester) async {
        await seedMusicas();

        await tester.pumpWidget(buildScreen());

        // O initState iniciou _fetchMusicas(), mas ainda não aguardamos
        // a conclusão da operação assíncrona.
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        expect(find.text('Imagine - John Lennon'), findsOneWidget);
        expect(find.text('Yellow - Coldplay'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'nome vazio mostra SnackBar e não cria playlist',
      (WidgetTester tester) async {
        await seedMusicas();

        final user = MockUser(
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
          signedIn: true,
        );

        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        expect(
          find.text('Nome da playlist é obrigatório'),
          findsOneWidget,
        );

        final playlists =
            await fakeFirestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);
      },
    );

    testWidgets(
      'usuário não autenticado não cria playlist',
      (WidgetTester tester) async {
        await seedMusicas();

        mockAuth = MockFirebaseAuth(
          signedIn: false,
        );

        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Nome da Playlist'),
          'Playlist Sem Login',
        );

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

        await tester.pump();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final playlists =
            await fakeFirestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);

        // Como _salvarPlaylist() simplesmente retorna quando currentUser
        // é null, a tela continua montada.
        expect(find.text('Criando Playlist'), findsOneWidget);
      },
    );

    testWidgets(
      'seleciona e desseleciona uma música corretamente',
      (WidgetTester tester) async {
        await seedMusicas();

        final user = MockUser(
          uid: 'usuario-123',
          email: 'usuario@example.com',
        );

        mockAuth = MockFirebaseAuth(
          mockUser: user,
          signedIn: true,
        );

        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        final imagineTile = find.ancestor(
          of: find.text('Imagine - John Lennon'),
          matching: find.byType(ListTile),
        );

        final checkbox = find.descendant(
          of: imagineTile,
          matching: find.byIcon(Icons.check_box_outline_blank),
        );

        await tester.tap(checkbox);
        await tester.pump();

        expect(
          find.descendant(
            of: imagineTile,
            matching: find.byIcon(Icons.check_box),
          ),
          findsOneWidget,
        );

        await tester.tap(
          find.descendant(
            of: imagineTile,
            matching: find.byIcon(Icons.check_box),
          ),
        );
        await tester.pump();

        expect(
          find.descendant(
            of: imagineTile,
            matching: find.byIcon(Icons.check_box_outline_blank),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
```

 ### Cenário de falha do Firestore

 Para o cenário de indisponibilidade do Firestore, há uma limitação importante na API usada pelo widget: ele recebe concretamente um `FirebaseFirestore`, enquanto `FakeFirebaseFirestore` não permite configurar diretamente `collection(...).add(...)` para lançar uma exceção.

 Uma forma apropriada de testar esse caminho é criar mocks Mockito para `FirebaseFirestore`, `CollectionReference` e `DocumentReference`. Como as APIs do Firebase são genéricas, o código de Mockito pode variar conforme as versões de `cloud_firestore`, `mockito` e `build_runner` usadas pelo projeto. Com geração de mocks, o teste fica conceitualmente assim:

```
testWidgets(
  'mostra SnackBar quando ocorre erro ao salvar no Firestore',
  (WidgetTester tester) async {
    // MockFirebaseAuth com usuário autenticado.
    final auth = MockFirebaseAuth(
      mockUser: MockUser(
        uid: 'usuario-123',
        email: 'usuario@example.com',
      ),
      signedIn: true,
    );

    // Mock do FirebaseFirestore configurado para:
    // 1. retornar músicas para collection('musica').get()
    // 2. lançar uma exceção em collection('playlists').add(...)

    // Exemplo conceitual:
    //
    // when(mockFirestore.collection('playlists'))
    //     .thenReturn(mockPlaylistsCollection);
    //
    // when(mockPlaylistsCollection.add(any))
    //     .thenThrow(Exception('Firestore indisponível'));

    await tester.pumpWidget(
      MaterialApp(
        home: CriarPlaylistScreen(
          auth: auth,
          firestore: mockFirestore,
          editPlaylist: {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nome da Playlist'),
      'Playlist Com Erro',
    );

    await tester.tap(find.text('Salvar Playlist'));
    await tester.pump();

    expect(
      find.textContaining('Erro ao salvar a playlist:'),
      findsOneWidget,
    );

    // A tela não deve ser fechada quando add() falha.
    expect(find.text('Criando Playlist'), findsOneWidget);
  },
);
```

 Esse último teste precisa dos mocks gerados pelo Mockito para compilar; não é seguro inventar as assinaturas genéricas exatas sem considerar a versão de `cloud_firestore` do projeto. Os quatro primeiros cenários, por outro lado, podem ser executados diretamente com as dependências que você informou.
