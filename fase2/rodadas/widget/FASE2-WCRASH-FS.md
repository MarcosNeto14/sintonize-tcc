# FASE2-WCRASH-FS — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WCRASH-FS |
| **Bug ID** | W-CRASH |
| **Função/tela alvo** | `CriarPlaylistScreen` (`_filterMusicas`) |
| **Arquivo(s) de origem** | `lib/criar_playlist.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.6 "Luna" (autodeclarado, não verificável — ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-02 |
| **Conversa nova?** | Sim — aba anônima, sem histórico |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable) |

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/FASE2-WCRASH-FS.md` — um exemplo few-shot
de widget test com Firebase mockado, seguido do código completo de
`CriarPlaylistScreen` (com o bug W-CRASH: `_filterMusicas()` acessa
`musica['artist_name'].toLowerCase()` sem null-safety).

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Resposta completa e verbatim:

```
Abaixo está uma suíte de widget tests seguindo o padrão do exemplo, usando MockFirebaseAuth e FakeFirebaseFirestore. Ela cobre carregamento das músicas, busca, seleção/desseleção, validação do nome, salvamento e navegação.
```

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Ajuste o caminho conforme a estrutura do projeto sintonize.
import 'package:sintonize/criar_playlist_screen.dart';

void main() {
  group('CriarPlaylistScreen Widget', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user123'),
      );

      fakeFirestore = FakeFirebaseFirestore();
    });

    Future<void> inserirMusicas() async {
      await fakeFirestore.collection('musica').add({
        'track_name': 'imagine',
        'artist_name': 'john lennon',
      });

      await fakeFirestore.collection('musica').add({
        'track_name': 'bohemian rhapsody',
        'artist_name': 'queen',
      });

      await fakeFirestore.collection('musica').add({
        'track_name': 'hotel california',
        'artist_name': 'eagles',
      });
    }

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CriarPlaylistScreen(
            editPlaylist: const {},
            auth: mockAuth,
            firestore: fakeFirestore,
          ),
        ),
      );

      // Aguarda o Future de _fetchMusicas().
      await tester.pumpAndSettle();
    }

    testWidgets('deve mostrar o título da tela', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Criando Playlist'), findsOneWidget);
      expect(find.text('Nome da Playlist'), findsOneWidget);
      expect(find.text('Pesquisar Música ou Artista'), findsOneWidget);
      expect(find.text('Salvar Playlist'), findsOneWidget);
    });

    testWidgets('deve carregar as músicas do Firestore', (tester) async {
      await inserirMusicas();

      await pumpScreen(tester);

      expect(
        find.text('Imagine - John Lennon'),
        findsOneWidget,
      );

      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsOneWidget,
      );

      expect(
        find.text('Hotel California - Eagles'),
        findsOneWidget,
      );
    });

    testWidgets('deve formatar nomes das músicas e artistas', (tester) async {
      await fakeFirestore.collection('musica').add({
        'track_name': 'stairway to heaven',
        'artist_name': 'led zeppelin',
      });

      await pumpScreen(tester);

      expect(
        find.text('Stairway To Heaven - Led Zeppelin'),
        findsOneWidget,
      );
    });

    testWidgets('deve filtrar músicas pelo nome da música', (tester) async {
      await inserirMusicas();

      await pumpScreen(tester);

      final searchField = find.byType(TextField).at(1);

      await tester.enterText(searchField, 'bohemian');
      await tester.pump();

      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsOneWidget,
      );

      expect(
        find.text('Imagine - John Lennon'),
        findsNothing,
      );

      expect(
        find.text('Hotel California - Eagles'),
        findsNothing,
      );
    });

    testWidgets('deve filtrar músicas pelo nome do artista', (tester) async {
      await inserirMusicas();

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

      expect(
        find.text('Hotel California - Eagles'),
        findsNothing,
      );
    });

    testWidgets('deve realizar busca ignorando maiúsculas e minúsculas',
        (tester) async {
      await inserirMusicas();

      await pumpScreen(tester);

      final searchField = find.byType(TextField).at(1);

      await tester.enterText(searchField, 'QUEEN');
      await tester.pump();

      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsOneWidget,
      );
    });

    testWidgets('deve mostrar todas as músicas quando a busca está vazia',
        (tester) async {
      await inserirMusicas();

      await pumpScreen(tester);

      final searchField = find.byType(TextField).at(1);

      await tester.enterText(searchField, 'queen');
      await tester.pump();

      expect(find.text('Imagine - John Lennon'), findsNothing);
      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);

      await tester.enterText(searchField, '');
      await tester.pump();

      expect(find.text('Imagine - John Lennon'), findsOneWidget);
      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
      expect(find.text('Hotel California - Eagles'), findsOneWidget);
    });

    testWidgets('deve mostrar mensagem quando nenhuma música for encontrada',
        (tester) async {
      await inserirMusicas();

      await pumpScreen(tester);

      final searchField = find.byType(TextField).at(1);

      await tester.enterText(searchField, 'musica inexistente');
      await tester.pump();

      // O widget utiliza CircularProgressIndicator quando a lista filtrada
      // fica vazia.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('deve selecionar uma música', (tester) async {
      await inserirMusicas();

      await pumpScreen(tester);

      final listTile = find.widgetWithText(
        ListTile,
        'Imagine - John Lennon',
      );

      final iconButton = find.descendant(
        of: listTile,
        matching: find.byType(IconButton),
      );

      await tester.tap(iconButton);
      await tester.pump();

      expect(
        find.descendant(
          of: listTile,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );
    });

    testWidgets('deve desselecionar uma música previamente selecionada',
        (tester) async {
      await inserirMusicas();

      await pumpScreen(tester);

      final listTile = find.widgetWithText(
        ListTile,
        'Imagine - John Lennon',
      );

      final iconButton = find.descendant(
        of: listTile,
        matching: find.byType(IconButton),
      );

      await tester.tap(iconButton);
      await tester.pump();

      expect(
        find.descendant(
          of: listTile,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      await tester.tap(iconButton);
      await tester.pump();

      expect(
        find.descendant(
          of: listTile,
          matching: find.byIcon(Icons.check_box_outline_blank),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'deve mostrar erro quando tentar salvar sem informar o nome da playlist',
        (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pump();

      expect(
        find.text('Nome da playlist é obrigatório'),
        findsOneWidget,
      );
    });

    testWidgets('deve permitir informar o nome da playlist', (tester) async {
      await pumpScreen(tester);

      final nomeField = find.byType(TextField).first;

      await tester.enterText(nomeField, 'Minha Playlist');
      await tester.pump();

      expect(
        find.text('Minha Playlist'),
        findsOneWidget,
      );
    });

    testWidgets('deve salvar a playlist com o usuário e músicas selecionadas',
        (tester) async {
      await inserirMusicas();

      // Inserimos uma rota anterior para que Navigator.pop() tenha
      // um destino válido.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CriarPlaylistScreen(
              editPlaylist: const {},
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final nomeField = find.byType(TextField).first;

      await tester.enterText(nomeField, 'Minha Playlist');

      final imagineTile = find.widgetWithText(
        ListTile,
        'Imagine - John Lennon',
      );

      final imagineButton = find.descendant(
        of: imagineTile,
        matching: find.byType(IconButton),
      );

      await tester.tap(imagineButton);
      await tester.pump();

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      final docs = await fakeFirestore.collection('playlists').get();

      expect(docs.docs.length, 1);

      final playlist = docs.docs.first.data();

      expect(playlist['userId'], 'user123');

      // O código atual salva "Nova Playlist", independentemente
      // do texto digitado no campo.
      expect(playlist['nome'], 'Nova Playlist');

      expect(
        List<String>.from(playlist['musicas']),
        contains('imagine'),
      );

      expect(playlist['dataCriacao'], isA<Timestamp>());

      // Após salvar, a tela deve ter sido removida da navegação.
      expect(find.text('Criando Playlist'), findsNothing);
    });

    testWidgets('deve salvar várias músicas selecionadas', (tester) async {
      await inserirMusicas();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CriarPlaylistScreen(
              editPlaylist: const {},
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'Playlist Favorita',
      );

      final imagineTile = find.widgetWithText(
        ListTile,
        'Imagine - John Lennon',
      );

      final queenTile = find.widgetWithText(
        ListTile,
        'Bohemian Rhapsody - Queen',
      );

      await tester.tap(
        find.descendant(
          of: imagineTile,
          matching: find.byType(IconButton),
        ),
      );

      await tester.tap(
        find.descendant(
          of: queenTile,
          matching: find.byType(IconButton),
        ),
      );

      await tester.pump();

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      final docs = await fakeFirestore.collection('playlists').get();

      expect(docs.docs.length, 1);

      final musicas = List<String>.from(docs.docs.first.data()['musicas']);

      expect(musicas, contains('imagine'));
      expect(musicas, contains('bohemian rhapsody'));
      expect(musicas.length, 2);
    });

    testWidgets('deve voltar ao tocar no botão de voltar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  child: const Text('Abrir playlist'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CriarPlaylistScreen(
                          editPlaylist: const {},
                          auth: mockAuth,
                          firestore: fakeFirestore,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir playlist'));
      await tester.pumpAndSettle();

      expect(find.text('Criando Playlist'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Abrir playlist'), findsOneWidget);
      expect(find.text('Criando Playlist'), findsNothing);
    });
  });
}
```

```
Observação importante sobre o widget

Há um detalhe no código de produção que o teste acima evidencia:

await widget.firestore.collection('playlists').add({
  'userId': user.uid,
  'nome': 'Nova Playlist',
  'musicas': _musicasSelecionadas,
  'dataCriacao': Timestamp.now(),
});

Apesar de o usuário preencher Nome da Playlist, o valor salvo é sempre "Nova Playlist". Se a intenção for salvar o nome informado, o código deveria usar _playlistName:

'nome': _playlistName,

Nesse caso, o teste pode ser alterado de:

expect(playlist['nome'], 'Nova Playlist');

para:

expect(playlist['nome'], 'Minha Playlist');

Também vale notar que editPlaylist é obrigatório no construtor, mas atualmente não é utilizado pelo widget. Os testes passam const {} apenas para satisfazer essa exigência.

Por fim, o teste de busca sem resultados espera um CircularProgressIndicator porque essa é a implementação atual: _musicasFiltradas.isEmpty é interpretado como carregamento. Se isso não for intencional, seria melhor diferenciar "carregando" de "nenhuma música encontrada" no widget.
```

Ver as três respostas de reparo completas na seção "Iterative Repair Loop" abaixo.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou? (1ª tentativa)** | Não — import inexistente (`criar_playlist_screen.dart`) e `Timestamp` sem import |
| **Testes gerados** | 15 |
| **Testes passaram (após iteração 1 — import corrigido)** | 11 |
| **Testes falharam (após iteração 1)** | 4 (todos `pumpAndSettle timed out`) |
| **Testes passaram (após iteração 2)** | 14 |
| **Testes falharam (após iteração 2)** | 1 (`pumpAndSettle timed out`) |
| **Testes passaram (após iteração 3 — final)** | 15 |
| **Testes falharam (após iteração 3 — final)** | 0 |

### Saída do terminal (iteração 0 — falha de compilação)

```
test/fase2/widget/wcrash_fs_test.dart:7:8: Error: Error when reading 'lib/criar_playlist_screen.dart': O sistema não pode encontrar o arquivo especificado
import 'package:sintonize/criar_playlist_screen.dart';
       ^
test/fase2/widget/wcrash_fs_test.dart:43:17: Error: Method not found: 'CriarPlaylistScreen'.
test/fase2/widget/wcrash_fs_test.dart:357:43: Error: 'Timestamp' isn't a type.
00:00 +0 -1: loading wcrash_fs_test.dart [E]
  Failed to load: Compilation failed.
```

(saída completa em `fase2/resultados/widget/FASE2-WCRASH-FS_iter0.txt`)

### Saída do terminal (iteração 1 — 11/15)

4 testes falharam com `pumpAndSettle timed out`: "deve mostrar o título
da tela", "deve mostrar erro quando tentar salvar sem informar o nome da
playlist", "deve permitir informar o nome da playlist", "deve voltar ao
tocar no botão de voltar" (saída completa em
`fase2/resultados/widget/FASE2-WCRASH-FS_iter1.txt`).

### Saída do terminal (iteração 2 — 14/15)

Apenas "deve voltar ao tocar no botão de voltar" continuou falhando com
o mesmo tipo de timeout (saída completa em
`fase2/resultados/widget/FASE2-WCRASH-FS_iter2.txt`).

### Saída do terminal (iteração 3 — final, 15/15)

```
00:00 +0: CriarPlaylistScreen Widget deve mostrar o título da tela
00:01 +1: CriarPlaylistScreen Widget deve carregar as músicas do Firestore
00:01 +2: CriarPlaylistScreen Widget deve formatar nomes das músicas e artistas
00:01 +3: CriarPlaylistScreen Widget deve filtrar músicas pelo nome da música
00:01 +4: CriarPlaylistScreen Widget deve filtrar músicas pelo nome do artista
00:01 +5: CriarPlaylistScreen Widget deve realizar busca ignorando maiúsculas e minúsculas
00:02 +6: CriarPlaylistScreen Widget deve mostrar todas as músicas quando a busca está vazia
00:02 +7: CriarPlaylistScreen Widget deve mostrar mensagem quando nenhuma música for encontrada
00:02 +8: CriarPlaylistScreen Widget deve selecionar uma música
00:02 +9: CriarPlaylistScreen Widget deve desselecionar uma música previamente selecionada
00:02 +10: CriarPlaylistScreen Widget deve mostrar erro quando tentar salvar sem informar o nome da playlist
00:02 +11: CriarPlaylistScreen Widget deve permitir informar o nome da playlist
00:03 +12: CriarPlaylistScreen Widget deve salvar a playlist com o usuário e músicas selecionadas
00:03 +13: CriarPlaylistScreen Widget deve salvar várias músicas selecionadas
00:03 +14: CriarPlaylistScreen Widget deve voltar ao tocar no botão de voltar
00:03 +15: All tests passed!
```

(saída completa em `fase2/resultados/widget/FASE2-WCRASH-FS_iter3_final.txt`)

---

## ⚠️ Achado metodológico importante

Assim como em **FASE2-WCRASH-ZS**, o bug W-CRASH (`_filterMusicas()`
acessando `musica['artist_name'].toLowerCase()` sem null-safety) **não
foi detectado nem exercitado** nesta rodada. Todas as músicas seedadas
pelo modelo (`imagine`/`john lennon`, `bohemian rhapsody`/`queen`,
`hotel california`/`eagles`, `stairway to heaven`/`led zeppelin`) têm
`artist_name` preenchido — nenhum teste gerado cobre um documento sem
esse campo. O modelo, no entanto, voltou a identificar espontaneamente o
bug adjacente do nome hardcoded (`'nome': 'Nova Playlist'`, alvo real de
uma rodada de I-SILENT futura), mantendo a asserção fiel ao
comportamento atual da aplicação conforme instruído pelo protocolo de
reparo.

Esta é a segunda rodada Widget seguida (de duas realizadas até agora)
em que o LLM não detecta o bug-alvo por nenhum meio — reforçando o
padrão observado no nível Widget, em contraste com a detecção quase
universal no nível Unitário.

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** compilação — `import 'package:sintonize/criar_playlist_screen.dart';` (arquivo inexistente; o real é `criar_playlist.dart`) e uso de `Timestamp` sem importar `cloud_firestore.dart`.
- **Prompt de reparo enviado:** erro de compilação colado, com nota indicando o nome real do arquivo e a origem de `Timestamp`.
- **Resposta do LLM (completa e verbatim):**

```
Classificação: (A) — a falha é causada por uma suposição incorreta do teste sobre o caminho/nome do arquivo e pela ausência de um import necessário. Isso não indica, por si só, um comportamento incorreto da aplicação.

As correções são:

trocar criar_playlist_screen.dart por criar_playlist.dart;
importar cloud_firestore.dart para que Timestamp seja reconhecido.

Segue o teste corrigido, sem alterar o escopo das asserções:
```

(código completo reenviado com `import 'package:cloud_firestore/cloud_firestore.dart';` adicionado e `import 'package:sintonize/criar_playlist.dart';` corrigido — demais 15 testes idênticos ao original, incluindo a manutenção de `expect(playlist['nome'], 'Nova Playlist')`)

```
Há ainda um ponto que não foi alterado para fazer o teste passar: o widget recebe "Minha Playlist", mas _salvarPlaylist() grava 'Nova Playlist'. Isso é um comportamento potencialmente incorreto da aplicação, não uma falha do teste. Portanto, mantive a asserção sobre 'Nova Playlist' para refletir exatamente o código atual. Se o requisito funcional for que o nome digitado seja persistido, o correto é corrigir a aplicação para usar _playlistName, e então atualizar a asserção para 'Minha Playlist'.
```

- **Resultado:** compilou; 11/15 passaram, 4 falharam por `pumpAndSettle timed out`.

### Iteração 2

- **Motivo da falha:** `pumpAndSettle()` nunca estabiliza em 4 testes que chamam `pumpScreen()` sem antes popular músicas — sem músicas, `_musicasFiltradas` fica vazia e o widget renderiza `CircularProgressIndicator` (animação infinita), o que impede `pumpAndSettle()` de convergir.
- **Prompt de reparo enviado:** saída do terminal com o stack trace do timeout, apontando o padrão comum aos 4 testes falhos.
- **Resposta do LLM (completa e verbatim):**

```
Classificação: (A) — a falha está no teste, especificamente no uso de pumpAndSettle() enquanto o widget contém um CircularProgressIndicator com animação infinita. Não é necessário alterar a aplicação para esses testes.

A correção mais apropriada é fazer pumpScreen() aguardar apenas o carregamento assíncrono do Firestore, sem usar pumpAndSettle(). Como FakeFirebaseFirestore resolve o get() rapidamente, podemos usar pump() algumas vezes para processar o Future e o setState.

Também é importante não inserir músicas artificialmente nesses quatro testes só para evitar o timeout: eles podem e devem testar o estado sem músicas.

Correção

Substitua a função auxiliar pumpScreen() para usar dois pump() em vez de pumpAndSettle():

Future<void> pumpScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CriarPlaylistScreen(
        editPlaylist: const {},
        auth: mockAuth,
        firestore: fakeFirestore,
      ),
    ),
  );

  // Processa o Future de _fetchMusicas() e o setState subsequente,
  // mas não usa pumpAndSettle(), pois CircularProgressIndicator
  // possui uma animação contínua quando não há músicas.
  await tester.pump();
  await tester.pump();
}

Com isso, os quatro testes problemáticos continuam testando exatamente o que deveriam. Nos testes que inserem músicas, pumpAndSettle() também pode funcionar porque, depois do _fetchMusicas(), a tela deixa de exibir o CircularProgressIndicator e passa a exibir o ListView. Portanto, não é necessário modificar esses testes.

Assim, a alteração mínima necessária é apenas substituir o pumpAndSettle() dentro de pumpScreen() por dois pump().
```

- **Resultado:** 14/15 passaram; "deve voltar ao tocar no botão de voltar" continuou falhando (não usa `pumpScreen()`, monta a árvore manualmente).

### Iteração 3 (final — máximo permitido)

- **Motivo da falha:** o único teste restante monta `CriarPlaylistScreen` manualmente (fora de `pumpScreen()`) e chama `pumpAndSettle()` diretamente após navegar — mesmo problema do `CircularProgressIndicator` infinito, sem músicas seedadas.
- **Prompt de reparo enviado:** novo stack trace apontando a linha exata, com nota de que esta é a 3ª e última iteração permitida.
- **Resposta do LLM (completa e verbatim):**

```
Classificação: (A) — novamente, a falha está no teste. O teste monta CriarPlaylistScreen sem músicas e chama pumpAndSettle() após a navegação. Como o widget exibe um CircularProgressIndicator com animação contínua nesse estado, pumpAndSettle() nunca encontra uma árvore estabilizada.

Não há motivo para alterar a aplicação nem para enfraquecer a asserção de navegação. Basta corrigir esse teste específico para usar pump() em vez de pumpAndSettle() após o Navigator.push().

Substitua somente o último teste: trocar o pumpAndSettle() logo após tocar em "Abrir playlist" por dois pump() (mantendo pumpAndSettle() após o tap no botão de voltar, pois nesse momento o CircularProgressIndicator já não pertence mais à árvore relevante).

Aqui o pumpAndSettle() depois do Navigator.pop() pode permanecer, porque o CircularProgressIndicator pertence à tela que está sendo removida. Após o pop, ele deixa de fazer parte da árvore relevante; portanto, não há a mesma animação infinita impedindo a estabilização.

A mudança essencial é esta:

await tester.pump();
await tester.pump();

no lugar de:

await tester.pumpAndSettle();

antes da asserção de que Criando Playlist apareceu. Isso preserva integralmente o objetivo do teste: abrir a tela, verificar que ela abriu e verificar que o botão de voltar retorna à tela anterior.
```

- **Resultado:** 15/15 passaram. Repair loop encerrado com sucesso, dentro do limite de 3 iterações.

---

## ★ Análise de Autoclassificação (preencher após a rodada)

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) em todas as 3 iterações — falhas de teste (import incorreto; uso indevido de `pumpAndSettle()` contra um `CircularProgressIndicator` de animação infinita), não bugs de aplicação |
| **★ Classificação humana (auditoria)** | Erro de geração (iteração 1 — import incorreto) / Erro de teste (iterações 2 e 3 — `pumpAndSettle()` mal empregado) |
| **★ Concordância** | Concorda — as 3 classificações (A) do modelo são coerentes com a causa raiz observada |
| **★ Observações** | Rodada exigiu as 3 iterações de reparo permitidas, todas por falhas do teste em si (nunca do widget). O padrão do `CircularProgressIndicator` com animação infinita bloqueando `pumpAndSettle()` é um erro sistemático de geração que se repetiu em 2 pontos distintos do arquivo (helper `pumpScreen()` e um teste que monta a árvore manualmente fora do helper) — sugerindo que o modelo não generaliza a lição entre iterações sem que o ponto específico seja apontado. Assim como em WCRASH-ZS, o bug-alvo W-CRASH não foi detectado nem exercitado; o modelo voltou a identificar espontaneamente o bug do nome hardcoded, mantendo a asserção fiel ao código atual sem enfraquecê-la. |

**Referência de categorias (classificação humana — mesmas da Fase 1):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
