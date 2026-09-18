Abaixo está um arquivo de teste completo para `test/integration/criar_playlist_test.dart`. Ele usa `FakeFirebaseFirestore` para persistência, `MockFirebaseAuth` para autenticação e exercita o fluxo real do widget.

```
// test/integration/criar_playlist_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  group('CriarPlaylistScreen - integração', () {
    late FakeFirebaseFirestore firestore;
    late MockFirebaseAuth auth;

    setUp(() async {
      firestore = FakeFirebaseFirestore();

      // Pré-popula o Firestore antes do widget ser montado.
      await firestore.collection('musica').add({
        'track_name': 'primeira musica',
        'artist_name': 'primeiro artista',
      });

      await firestore.collection('musica').add({
        'track_name': 'segunda musica',
        'artist_name': 'segundo artista',
      });

      final user = MockUser(
        isAnonymous: false,
        uid: 'usuario-teste-123',
        email: 'teste@sintonize.com',
      );

      auth = MockFirebaseAuth(
        mockUser: user,
        signedIn: true,
      );
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CriarPlaylistScreen(
            editPlaylist: const {},
            auth: auth,
            firestore: firestore,
          ),
        ),
      );

      // Aguarda o _fetchMusicas() terminar e o setState() reconstruir a tela.
      await tester.pumpAndSettle();
    }

    testWidgets(
      'executa o fluxo completo de criar playlist e persiste no Firestore',
      (tester) async {
        await pumpScreen(tester);

        // A lista de músicas foi carregada.
        expect(find.text('Primeira Musica - Primeiro Artista'), findsOneWidget);
        expect(find.text('Segunda Musica - Segundo Artista'), findsOneWidget);

        // Digita o nome da playlist.
        final nomeField = find.byType(TextField).first;

        await tester.enterText(
          nomeField,
          'Minha Playlist de Teste',
        );

        // Seleciona a primeira música.
        final primeiraMusica = find.text(
          'Primeira Musica - Primeiro Artista',
        );

        final primeiraCard = find.ancestor(
          of: primeiraMusica,
          matching: find.byType(ListTile),
        );

        await tester.tap(
          find.descendant(
            of: primeiraCard,
            matching: find.byIcon(Icons.check_box_outline_blank),
          ),
        );

        // Seleciona a segunda música.
        final segundaMusica = find.text(
          'Segunda Musica - Segundo Artista',
        );

        final segundaCard = find.ancestor(
          of: segundaMusica,
          matching: find.byType(ListTile),
        );

        await tester.tap(
          find.descendant(
            of: segundaCard,
            matching: find.byIcon(Icons.check_box_outline_blank),
          ),
        );

        await tester.pump();

        // Ambas devem estar selecionadas.
        expect(
          find.descendant(
            of: primeiraCard,
            matching: find.byIcon(Icons.check_box),
          ),
          findsOneWidget,
        );

        expect(
          find.descendant(
            of: segundaCard,
            matching: find.byIcon(Icons.check_box),
          ),
          findsOneWidget,
        );

        // Salva a playlist.
        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        // O documento deve ter sido criado na coleção playlists.
        final playlists =
            await firestore.collection('playlists').get();

        expect(playlists.docs, hasLength(1));

        final playlist = playlists.docs.single;

        // Valida explicitamente o valor digitado, e não um valor fixo
        // diferente do conteúdo do campo.
        expect(
          playlist.data()['nome'],
          equals('Minha Playlist de Teste'),
        );

        expect(
          playlist.data()['userId'],
          equals('usuario-teste-123'),
        );

        expect(
          playlist.data()['musicas'],
          containsAll([
            'primeira musica',
            'segunda musica',
          ]),
        );

        expect(
          (playlist.data()['musicas'] as List).length,
          equals(2),
        );

        expect(
          playlist.data()['dataCriacao'],
          isA<Object>(),
        );

        // Depois do Navigator.pop(), a tela deve ter sido removida.
        expect(find.byType(CriarPlaylistScreen), findsNothing);
      },
    );

    testWidgets(
      'não salva quando o nome da playlist está vazio',
      (tester) async {
        await pumpScreen(tester);

        // Não informa nome e tenta salvar.
        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        // Deve apresentar a mensagem de validação.
        expect(
          find.text('Nome da playlist é obrigatório'),
          findsOneWidget,
        );

        // Nenhum documento deve ser criado.
        final playlists =
            await firestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);
      },
    );

    testWidgets(
      'não salva quando o usuário não está autenticado',
      (tester) async {
        // Cria uma instância sem usuário autenticado.
        auth = MockFirebaseAuth(
          mockUser: null,
          signedIn: false,
        );

        await pumpScreen(tester);

        // Informa um nome válido.
        final nomeField = find.byType(TextField).first;

        await tester.enterText(
          nomeField,
          'Playlist sem usuário',
        );

        // Seleciona uma música para garantir que o fluxo de criação
        // está sendo exercitado até a etapa de autenticação.
        final primeiraMusica = find.text(
          'Primeira Musica - Primeiro Artista',
        );

        final primeiraCard = find.ancestor(
          of: primeiraMusica,
          matching: find.byType(ListTile),
        );

        await tester.tap(
          find.descendant(
            of: primeiraCard,
            matching: find.byIcon(Icons.check_box_outline_blank),
          ),
        );

        await tester.pump();

        // Tenta salvar.
        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        // Como currentUser == null, _salvarPlaylist() não adiciona
        // nenhum documento.
        final playlists =
            await firestore.collection('playlists').get();

        expect(playlists.docs, isEmpty);

        // A tela permanece aberta porque Navigator.pop() só acontece
        // depois de uma gravação bem-sucedida.
        expect(find.byType(CriarPlaylistScreen), findsOneWidget);
      },
    );
  });
}
```

 ### Estrutura esperada

```
test/
└── integration/
    └── criar_playlist_test.dart
```

 E no `pubspec.yaml`, as dependências de teste precisam estar disponíveis, por exemplo:

```
dev_dependencies:
  flutter_test:
    sdk: flutter
  fake_cloud_firestore: ^3.0.0
  firebase_auth_mocks: ^0.14.0
  mockito: ^5.4.0
```

 Um detalhe importante do teste: o `FakeFirebaseFirestore` é **o mesmo objeto injetado no widget e posteriormente consultado pelo teste**. Assim, a verificação final realmente confirma o documento criado pela chamada:

```
await _firestore.collection('playlists').add(...)
```

 Também não é necessário inicializar o Firebase real, porque tanto Auth quanto Firestore são fornecidos ao `CriarPlaylistScreen` por meio das propriedades `auth` e `firestore`.
