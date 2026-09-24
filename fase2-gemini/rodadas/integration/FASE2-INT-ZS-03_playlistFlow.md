# FASE2-INT-ZS-03_playlistFlow — Réplica Gemini

Rodada **58/60**. Bloco 3 (integração), lote 14 (`playlistFlow`). Execução automatizada (Claude in Chrome); resposta integral no Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-INT-ZS-03_playlistFlow |
| **Função/tela alvo** | fluxo de criação de playlist — `CriarPlaylistScreen` |
| **Arquivo(s) de origem** | `lib/criar_playlist.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Pílula do seletor conferida antes do envio: `Flash` (não `Flash-Lite`). |
| **Data de acesso** | 2026-09-23 |
| **Conversa nova?** | Sim — `gemini.google.com/app/416b8f1b5c20bc32` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-alvos-limpos`, alvo limpo. **W-CRASH e I-SILENT verificados revertidos** antes da rodada: `lib/criar_playlist.dart:56` usa `musica['artist_name']?.toLowerCase() ?? ''` e a linha 251 grava `'nome': _playlistName` (não o literal `'Nova Playlist'`) |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 · DevTools 2.54.2 |
| **Arquivo de teste** | `test/fase2-gemini/integration/playlist_flow_zs_test.dart` |
| **Saídas arquivadas** | `resultados/integration/FASE2-INT-ZS-03_iter0.txt` (única execução) |
| **Modo de execução** | **Automatizado** (Claude in Chrome) — ver a nota de extração |
| **Versão do prompt** | Original, de `prompts_prontos/integration/zero-shot/FASE2-INT-ZS-03_playlistFlow.md`, sem alteração. Inclui a **ajuda de caminho de import** preservada da Fase 2 |

---

## Nota de extração

A linha de ações da resposta (com o botão "Copiar resposta") **não ficou acessível** nesta conversa — o rodapé da resposta ficou coberto pelo campo de digitação e a página já estava no fim do rolamento. Foram usados os dois caminhos alternativos, ambos previstos no `README.md`:

- **Código:** botão **"Copiar o código"** do próprio bloco → cópia verbatim, com indentação preservada. É o que está no arquivo de teste e no Apêndice.
- **Texto ao redor do código:** extração de texto da página. A prosa é curta (uma frase de abertura e cinco itens de "Pontos cobertos no teste") e foi remontada em volta do código verbatim.

Nenhum token do código foi alterado. A formatação de negrito/itálico da prosa é reconstrução; o código, não.

---

## Tentativas de envio

| Envio | Canal | Resultado |
|---|---|---|
| Geração | automação | Aceito no primeiro envio. |

**Tentativas de envio até obter resposta: 1. Nenhuma recusa, nenhum reparo.**

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 3 |
| **Testes passaram (iteração 0 — final)** | **3/3 — `All tests passed!`** |
| **Iterações de reparo** | **0 — nenhuma necessária** |
| **Tentativas de envio até obter resposta** | 1 (nenhuma recusa) |
| **Autoclassificação** | — (não houve reparo) |

---

## Iterative Repair Loop

Não houve. A geração compilou e passou integralmente na primeira execução.

| Iteração | Envio | Resposta | Classificação | Resultado |
|---|---|---|---|---|
| 0 (geração) | automação | 3 `testWidgets` cobrindo o fluxo completo (montagem → busca → digitar nome → selecionar faixas → salvar → verificar persistência), mais nome vazio e usuário deslogado | — | **3/3, `All tests passed!`** |

---

## Observações

1. **Primeira rodada da réplica Gemini a fechar com 0 iterações de reparo.** É também a primeira suíte verde já na geração — a rodada 57 chegou a 5/5, mas só na terceira iteração.
2. **A armadilha da Fase 1 não se repetiu.** `CriarPlaylistScreen` teve **0% de aprovação nas 3 estratégias da Fase 1** por alucinação de caminho de import. O prompt da Fase 2 embute a ajuda (`import 'package:sintonize/criar_playlist.dart';`) e o modelo a seguiu literalmente. **O crédito é da ajuda no prompt, não do modelo** — é um desvio preservado de propósito e precisa ser lido assim na análise.
3. **Verificou o campo `nome` dinamicamente**, como o prompt pede: `expect(dadosCriados['nome'], equals(nomeDigitado))`. Esse requisito existe por causa do bug I-SILENT do piloto (nome gravado com o literal `'Nova Playlist'`), aqui revertido. O teste detectaria a regressão se ela voltasse.
4. **Escopo enxuto mas correto:** 3 testes, os mesmos três cenários que o prompt lista. Não tentou a busca por texto — o prompt explicitamente diz que a busca não faz parte do caminho principal.
5. **Comparação com o ChatGPT na mesma rodada:** ChatGPT também fechou em **3/3 com 0 iterações**. É o primeiro empate perfeito entre os dois modelos em toda a réplica — mesmo alvo, mesmo número de testes, mesmo resultado, mesmo custo. Convém registrar que o alvo que **mais** derrubou a Fase 1 é o único em que os dois modelos acertam de primeira: a diferença está no prompt, que ganhou a ajuda de import justamente por aquele fracasso.

---

## Apêndice — resposta integral

Código verbatim (via "Copiar o código"); prosa remontada da extração de texto — ver a nota de extração.

````markdown
Aqui está o arquivo completo de testes de integração implementado com `flutter_test`, `fake_cloud_firestore` e `firebase_auth_mocks`.

Salve este arquivo em: `test/integration/criar_playlist_test.dart`

```dart
// test/integration/criar_playlist_test.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockUser mockUser;
  late MockFirebaseAuth mockAuth;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockUser = MockUser(
      uid: 'user_123_abc',
      email: 'teste@sintonize.com',
      displayName: 'Usuário Teste',
    );
    mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

    // Pré-popula a coleção 'musica' com pelo menos dois documentos
    await fakeFirestore.collection('musica').doc('musica_1').set({
      'track_name': 'Bohemian Rhapsody',
      'artist_name': 'Queen',
    });

    await fakeFirestore.collection('musica').doc('musica_2').set({
      'track_name': 'Imagine',
      'artist_name': 'John Lennon',
    });

    await fakeFirestore.collection('musica').doc('musica_3').set({
      'track_name': 'Billie Jean',
      'artist_name': 'Michael Jackson',
    });
  });

  Widget buildTestableWidget({
    MockFirebaseAuth? auth,
    FakeFirebaseFirestore? firestore,
  }) {
    return MaterialApp(
      home: CriarPlaylistScreen(
        editPlaylist: const {},
        auth: auth ?? mockAuth,
        firestore: firestore ?? fakeFirestore,
      ),
    );
  }

  group('CriarPlaylistScreen - Fluxos de Integração', () {
    testWidgets(
      'deve carregar músicas, selecionar faixas, preencher nome e salvar no Firestore com sucesso',
      (WidgetTester tester) async {
        // 1. Renderiza a tela
        await tester.pumpWidget(buildTestableWidget());

        // Inicialmente há um CircularProgressIndicator enquanto o Future roda
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Aguarda a resolução da busca assíncrona de músicas e o setState
        await tester.pumpAndSettle();

        // 2. Valida se as músicas cadastradas aparecem na listagem formatadas
        expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);
        expect(find.text('Imagine - John Lennon'), findsOneWidget);
        expect(find.text('Billie Jean - Michael Jackson'), findsOneWidget);

        // 3. Digita o nome da playlist no campo correspondente
        const String nomeDigitado = 'Minhas Favoritas de Rock';
        final nomeFieldFinder = find.widgetWithText(TextField, 'Nome da Playlist');
        expect(nomeFieldFinder, findsOneWidget);

        await tester.enterText(nomeFieldFinder, nomeDigitado);
        await tester.pump();

        // 4. Seleciona a primeira e a terceira música marcando os checkboxes
        // Como o botão de alternância é um IconButton com ícones de checkbox:
        final iconBlankFinder = find.byIcon(Icons.check_box_outline_blank);
        expect(iconBlankFinder, findsNWidgets(3));

        // Toca na primeira música ('Bohemian Rhapsody')
        await tester.tap(iconBlankFinder.first);
        await tester.pump();

        // Agora resta 1 selecionado e 2 vazios
        expect(find.byIcon(Icons.check_box), findsNWidgets(1));

        // Toca no último item restante ('Billie Jean')
        await tester.tap(find.byIcon(Icons.check_box_outline_blank).last);
        await tester.pump();

        expect(find.byIcon(Icons.check_box), findsNWidgets(2));

        // 5. Toca no botão "Salvar Playlist"
        final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
        await tester.ensureVisible(salvarButton);
        await tester.tap(salvarButton);
        await tester.pumpAndSettle();

        // 6. Verifica a persistência no FakeFirebaseFirestore
        final playlistsSnapshot = await fakeFirestore.collection('playlists').get();
        expect(playlistsSnapshot.docs.length, 1);

        final dadosCriados = playlistsSnapshot.docs.first.data();
        expect(dadosCriados['userId'], equals('user_123_abc'));
        expect(dadosCriados['nome'], equals(nomeDigitado));
        expect(
          dadosCriados['musicas'],
          unorderedEquals(['Bohemian Rhapsody', 'Billie Jean']),
        );
        expect(dadosCriados['dataCriacao'], isA<Timestamp>());
      },
    );

    testWidgets(
      'não deve salvar a playlist quando o nome estiver vazio e deve exibir SnackBar de validação',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget());
        await tester.pumpAndSettle();

        // Toca em salvar sem preencher o nome
        final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
        await tester.ensureVisible(salvarButton);
        await tester.tap(salvarButton);
        await tester.pump();

        // Verifica exibição do feedback visual
        expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

        // Garante que nada foi salvo no Firestore
        final playlistsSnapshot = await fakeFirestore.collection('playlists').get();
        expect(playlistsSnapshot.docs, isEmpty);
      },
    );

    testWidgets(
      'não deve salvar documentos quando não houver usuário autenticado no FirebaseAuth',
      (WidgetTester tester) async {
        // Instancia MockFirebaseAuth deslogado
        final unauthenticatedAuth = MockFirebaseAuth(signedIn: false);

        await tester.pumpWidget(buildTestableWidget(auth: unauthenticatedAuth));
        await tester.pumpAndSettle();

        // Preenche o nome da playlist
        final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
        await tester.enterText(nomeField, 'Playlist Sem Usuário');
        await tester.pump();

        // Toca no botão salvar
        final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
        await tester.ensureVisible(salvarButton);
        await tester.tap(salvarButton);
        await tester.pumpAndSettle();

        // Confirma que nenhuma playlist foi salva na coleção
        final playlistsSnapshot = await fakeFirestore.collection('playlists').get();
        expect(playlistsSnapshot.docs, isEmpty);
      },
    );
  });
}
```

**Pontos cobertos no teste:**

1. **Pré-população assíncrona:** A coleção `musica` é preenchida no `setUp` com faixas de teste no `FakeFirebaseFirestore`.
2. **Ciclo de vida assíncrono (`initState`):** O `pumpAndSettle()` aguarda a busca de músicas e a substituição do `CircularProgressIndicator` pela lista de cards.
3. **Interações de UI:** Digitação via `enterText`, marcação de múltiplos checkboxes via `tap` nos ícones e scroll/clique no botão `Salvar Playlist`.
4. **Verificação de persistência real:** Faz a asserção dos campos (`userId`, `nome` coincidente com o valor dinâmico digitado, array `musicas` e `dataCriacao` do tipo `Timestamp`).
5. **Casos de borda e validações:** Garante que o SnackBar é disparado ao tentar salvar com nome vazio e valida que requisições de usuários deslogados não persistem dados.
````
