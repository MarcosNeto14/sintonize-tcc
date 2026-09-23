# FASE2-WIDGET-ZS-03_CriarPlaylistScreen — Réplica Gemini

Rodada **49/60**. Bloco 2 (alvos limpos), lote 11 (`CriarPlaylistScreen`). Execução automatizada (Claude in Chrome); respostas integrais no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WIDGET-ZS-03_CriarPlaylistScreen |
| **Função/tela alvo** | `CriarPlaylistScreen` |
| **Arquivo(s) de origem** | `lib/criar_playlist.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes de cada envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/ae1d49339d573d75` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos` (de `fase2-alvos-limpos`), sem bugs plantados |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/widget/criar_playlist_screen_zs_test.dart` |
| **Saídas arquivadas** | `resultados/widget/FASE2-WIDGET-ZS-03_iter0.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/widget/zero-shot/FASE2-WIDGET-ZS-03_CriarPlaylistScreen.md`, sem alteração |

---

## Tentativas de envio

| Tentativa | Conversa | Resultado |
|---|---|---|
| 1 | nova (sem URL própria) | **Falha do serviço:** ~3 min só com o indicador de carregamento, nenhuma linha gerada; interrompida |
| 2 | `gemini.google.com/app/ae1d49339d573d75` | Resposta completa. **Enviada manualmente pelo Marcos.** |

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 5 |
| **Testes passaram (1ª execução)** | **5/5** |
| **Iterações de reparo** | 0 |
| **Tentativas de envio até obter resposta** | **2** (1 falha de serviço) |

---

## Observações

1. **Primeira rodada de widget do bloco 2 a fechar sem reparo.** Suíte com `FakeFirebaseFirestore` + `MockFirebaseAuth` injetados, os dois pelo construtor: renderização e carregamento, filtro de busca, seleção por checkbox, SnackBar de validação sem nome e gravação.
2. O teste de gravação confere `savedData['nome'] == 'Minhas Favoritas'` — o nome digitado. Nesta branch o I-SILENT está revertido, então passa; na branch do piloto essa asserção pegaria o bug.
3. Não esquece o import de `cloud_firestore` (o erro mais reprodutível do ChatGPT neste alvo) porque não usa `isA<Timestamp>()`.
4. Mais uma confirmação da hipótese da Fase 2: o alvo que recebe `auth` e `firestore` por injeção e não navega para tela com Firebase estático é o mais fácil.
5. ChatGPT na mesma rodada: 8/8 após 1 iteração (import de `cloud_firestore`).

---

## Apêndice — respostas integrais (via "Copiar resposta")

### Resposta da geração inicial (tentativa 2, manual)

````markdown
Aqui está a suíte de testes de widget completa para o `CriarPlaylistScreen`, utilizando `fake_cloud_firestore` e `firebase_auth_mocks`.

Crie o arquivo em `test/criar_playlist_test.dart`:

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockUser = MockUser(
      uid: 'user_test_123',
      email: 'teste@sintonize.com',
      displayName: 'Usuário Teste',
    );
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    // Pré-popula a coleção 'musica' com faixas de teste
    await fakeFirestore.collection('musica').add({
      'track_name': 'bohemian rhapsody',
      'artist_name': 'queen',
    });
    await fakeFirestore.collection('musica').add({
      'track_name': 'imagine',
      'artist_name': 'john lennon',
    });
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: CriarPlaylistScreen(
        editPlaylist: const {},
        auth: mockAuth,
        firestore: fakeFirestore,
      ),
    );
  }

  testWidgets('Deve renderizar os campos e carregar a lista de músicas',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Valida elementos estáticos do layout
    expect(find.text('Criando Playlist'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Nome da Playlist'), findsOneWidget);
    expect(
        find.widgetWithText(TextField, 'Pesquisar Música ou Artista'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Salvar Playlist'), findsOneWidget);

    // Valida as músicas formatadas pelo método _formatName
    expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
    expect(find.text('Imagine - John Lennon'), findsOneWidget);
  });

  testWidgets('Deve filtrar músicas pelo campo de busca',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final searchField =
        find.widgetWithText(TextField, 'Pesquisar Música ou Artista');

    // Filtra pelo nome da faixa
    await tester.enterText(searchField, 'bohemian');
    await tester.pumpAndSettle();

    expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
    expect(find.text('Imagine - John Lennon'), findsNothing);

    // Filtra pelo nome do artista
    await tester.enterText(searchField, 'lennon');
    await tester.pumpAndSettle();

    expect(find.text('Bohemian Rhapsody - Queen'), findsNothing);
    expect(find.text('Imagine - John Lennon'), findsOneWidget);
  });

  testWidgets('Deve alternar a seleção de uma música ao tocar no checkbox',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Inicialmente todos os checkboxes estão desmarcados
    expect(find.byIcon(Icons.check_box_outline_blank), findsNWidgets(2));
    expect(find.byIcon(Icons.check_box), findsNothing);

    // Seleciona a primeira música
    final firstCheckbox = find.byType(IconButton).at(1); // 0 é o back button
    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_box), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);

    // Desmarca a música
    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_box), findsNothing);
    expect(find.byIcon(Icons.check_box_outline_blank), findsNWidgets(2));
  });

  testWidgets('Deve exibir SnackBar de validação se tentar salvar sem nome',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    final saveButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

    // Garante que nada foi gravado no Firestore
    final playlistsSnapshot = await fakeFirestore.collection('playlists').get();
    expect(playlistsSnapshot.docs, isEmpty);
  });

  testWidgets('Deve salvar a playlist no Firestore com as músicas selecionadas',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CriarPlaylistScreen(
                      editPlaylist: const {},
                      auth: mockAuth,
                      firestore: fakeFirestore,
                    ),
                  ),
                );
              },
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

    // Navega para a tela
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    // Digita o nome da playlist
    final nameField = find.widgetWithText(TextField, 'Nome da Playlist');
    await tester.enterText(nameField, 'Minhas Favoritas');
    await tester.pumpAndSettle();

    // Marca a primeira música ('bohemian rhapsody')
    final firstCheckbox = find.byType(IconButton).at(1);
    await tester.tap(firstCheckbox);
    await tester.pumpAndSettle();

    // Clica em Salvar
    final saveButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verifica se a tela fez pop após salvar com sucesso
    expect(find.text('Criando Playlist'), findsNothing);
    expect(find.text('Abrir'), findsOneWidget);

    // Valida o documento gravado no Firestore
    final playlists = await fakeFirestore.collection('playlists').get();
    expect(playlists.docs.length, 1);

    final savedData = playlists.docs.first.data();
    expect(savedData['userId'], mockUser.uid);
    expect(savedData['nome'], 'Minhas Favoritas');
    expect(savedData['musicas'], contains('bohemian rhapsody'));
    expect(savedData['dataCriacao'], isNotNull);
  });
}

```

### O que esses testes cobrem:

1. **Renderização e Ciclo Inicial:** Garante que a requisição de `_fetchMusicas()` funciona, respeita o `_formatName()` e renderiza os campos e botões.
2. **Filtro em Tempo Real:** Testa a reação do listener `_searchController` tanto para nome de música quanto para artista.
3. **Seleção de Faixas:** Testa a inclusão e remoção da lista `_musicasSelecionadas` alternando os ícones `check_box` e `check_box_outline_blank`.
4. **Validação de Formulário:** Verifica se a `SnackBar` é disparada caso o usuário tente salvar com o nome em branco.
5. **Persistência e Navegação:** Preenche os dados, seleciona músicas, clica em salvar, verifica se a chamada `Navigator.pop()` fecha a tela e se o documento foi inserido no Firestore com o `uid` e campos corretos.
````

