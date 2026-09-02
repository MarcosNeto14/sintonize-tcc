# FASE2-WCRASH-ZS — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WCRASH-ZS |
| **Bug ID** | W-CRASH |
| **Função/tela alvo** | `CriarPlaylistScreen` (`_filterMusicas`) |
| **Arquivo(s) de origem** | `lib/criar_playlist.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.6 "Luna" (autodeclarado, não verificável — ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-02 |
| **Conversa nova?** | Sim — aba anônima, sem histórico |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable) |

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/FASE2-WCRASH-ZS.md` — código completo de
`CriarPlaylistScreen` (com o bug W-CRASH: `_filterMusicas()` acessa
`musica['artist_name'].toLowerCase()` sem null-safety), requisitos de
mock com `firebase_auth_mocks`/`fake_cloud_firestore`.

---

## Resposta do LLM

Resposta completa e verbatim (única mensagem — sem prompt de reparo):

```
Abaixo está um arquivo de teste completo, usando flutter_test, firebase_auth_mocks e fake_cloud_firestore. Ele cobre renderização, validação, pesquisa, seleção de músicas, salvamento e navegação.

Sugestão: salve como test/criar_playlist_test.dart.
```

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;

  setUp(() async {
    firestore = FakeFirebaseFirestore();

    final user = MockUser(
      uid: 'user-test-123',
      email: 'teste@sintonize.com',
    );

    auth = MockFirebaseAuth(
      mockUser: user,
      signedIn: true,
    );

    // Dados usados pelos testes da lista de músicas.
    await firestore.collection('musica').add({
      'track_name': 'shape of you',
      'artist_name': 'ed sheeran',
    });

    await firestore.collection('musica').add({
      'track_name': 'blinding lights',
      'artist_name': 'the weeknd',
    });

    await firestore.collection('musica').add({
      'track_name': 'tempo perdido',
      'artist_name': 'legiao urbana',
    });
  });

  Widget createWidget() {
    return MaterialApp(
      home: CriarPlaylistScreen(
        editPlaylist: const {},
        auth: auth,
        firestore: firestore,
      ),
    );
  }

  group('CriarPlaylistScreen - renderização', () {
    testWidgets('deve renderizar os principais elementos da tela',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Criando Playlist'), findsOneWidget);
      expect(find.text('Nome da Playlist'), findsOneWidget);
      expect(find.text('Pesquisar Música ou Artista'), findsOneWidget);
      expect(find.text('Salvar Playlist'), findsOneWidget);
    });

    testWidgets('deve carregar as músicas do Firestore',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Shape Of You - Ed Sheeran'),
        findsOneWidget,
      );

      expect(
        find.text('Blinding Lights - The Weeknd'),
        findsOneWidget,
      );

      expect(
        find.text('Tempo Perdido - Legiao Urbana'),
        findsOneWidget,
      );
    });
  });

  group('CriarPlaylistScreen - validação', () {
    testWidgets(
      'deve mostrar mensagem quando tentar salvar sem nome',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
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
      'não deve salvar playlist quando o nome estiver vazio',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        final playlistsAntes =
            await firestore.collection('playlists').get();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pump();

        final playlistsDepois =
            await firestore.collection('playlists').get();

        expect(
          playlistsDepois.docs.length,
          playlistsAntes.docs.length,
        );
      },
    );

    testWidgets(
      'deve aceitar nome de playlist válido',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Nome da Playlist'),
          'Minha Playlist',
        );

        expect(find.text('Minha Playlist'), findsOneWidget);
      },
    );
  });

  group('CriarPlaylistScreen - pesquisa', () {
    testWidgets(
      'deve filtrar músicas pelo nome da música',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Pesquisar Música ou Artista',
          ),
          'shape',
        );

        await tester.pump();

        expect(
          find.text('Shape Of You - Ed Sheeran'),
          findsOneWidget,
        );

        expect(
          find.text('Blinding Lights - The Weeknd'),
          findsNothing,
        );

        expect(
          find.text('Tempo Perdido - Legiao Urbana'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve filtrar músicas pelo nome do artista',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Pesquisar Música ou Artista',
          ),
          'weeknd',
        );

        await tester.pump();

        expect(
          find.text('Blinding Lights - The Weeknd'),
          findsOneWidget,
        );

        expect(
          find.text('Shape Of You - Ed Sheeran'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'a pesquisa deve ignorar maiúsculas e minúsculas',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Pesquisar Música ou Artista',
          ),
          'ED SHEERAN',
        );

        await tester.pump();

        expect(
          find.text('Shape Of You - Ed Sheeran'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve exibir indicador de carregamento quando não houver resultados',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Pesquisar Música ou Artista',
          ),
          'musica-que-nao-existe',
        );

        await tester.pump();

        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
        );
      },
    );
  });

  group('CriarPlaylistScreen - seleção de músicas', () {
    testWidgets(
      'deve selecionar uma música ao tocar no checkbox',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        final checkbox =
            find.byIcon(Icons.check_box_outline_blank).first;

        expect(checkbox, findsOneWidget);

        await tester.tap(checkbox);
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsAtLeastNWidgets(1),
        );
      },
    );

    testWidgets(
      'deve permitir desmarcar uma música selecionada',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        final checkbox =
            find.byIcon(Icons.check_box_outline_blank).first;

        await tester.tap(checkbox);
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box),
          findsAtLeastNWidgets(1),
        );

        final selectedCheckbox = find.byIcon(Icons.check_box).first;

        await tester.tap(selectedCheckbox);
        await tester.pump();

        expect(
          find.byIcon(Icons.check_box_outline_blank),
          findsAtLeastNWidgets(1),
        );
      },
    );
  });

  group('CriarPlaylistScreen - salvar playlist', () {
    testWidgets(
      'deve salvar playlist com usuário autenticado',
      (WidgetTester tester) async {
        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextField, 'Nome da Playlist'),
          'Playlist de Teste',
        );

        await tester.tap(
          find.byIcon(Icons.check_box_outline_blank).first,
        );
        await tester.pump();

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        final snapshot =
            await firestore.collection('playlists').get();

        expect(snapshot.docs.length, 1);

        final playlist = snapshot.docs.first.data();

        expect(playlist['userId'], 'user-test-123');
        expect(playlist['nome'], 'Nova Playlist');

        final musicas = playlist['musicas'] as List<dynamic>;

        expect(musicas.length, 1);
        expect(musicas.first, 'shape of you');
      },
    );

    testWidgets(
      'deve voltar para a tela anterior após salvar',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
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
                    child: const Text('Abrir playlist'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Abrir playlist'));
        await tester.pumpAndSettle();

        expect(find.text('Criando Playlist'), findsOneWidget);

        await tester.enterText(
          find.widgetWithText(TextField, 'Nome da Playlist'),
          'Playlist de Teste',
        );

        await tester.tap(find.text('Salvar Playlist'));
        await tester.pumpAndSettle();

        expect(find.text('Abrir playlist'), findsOneWidget);
        expect(find.text('Criando Playlist'), findsNothing);
      },
    );
  });

  group('CriarPlaylistScreen - navegação', () {
    testWidgets(
      'deve voltar ao tocar no botão de voltar',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
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
                    child: const Text('Abrir playlist'),
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
      },
    );
  });
}
```

```
Observação importante

Há um detalhe no widget original que os testes acima deixam explícito: o nome digitado não é usado ao salvar. _salvarPlaylist() grava sempre:

'nome': 'Nova Playlist',

Por isso o teste de persistência verifica Nova Playlist, mesmo que o usuário tenha digitado Playlist de Teste.

Se a intenção for salvar o nome informado pelo usuário, o código de produção deveria ser:

'nome': _playlistName,

ou, de forma mais defensiva:

'nome': _playlistName!.trim(),

Também vale observar que, no estado atual, uma lista vazia é representada por CircularProgressIndicator, então uma pesquisa sem resultados aparece visualmente como se ainda estivesse carregando. Isso é um comportamento do widget, não do teste.

Para executar:

flutter test test/criar_playlist_test.dart

E confirme no pubspec.yaml que fake_cloud_firestore e firebase_auth_mocks estão em dev_dependencies.
```

---

## ⚠️ Achado metodológico importante

O modelo **não mencionou o bug W-CRASH em nenhum momento** — nem no
texto, nem nos testes. A "Observação importante" que ele escreveu
espontaneamente descreve um bug **diferente e real**
(`'nome': 'Nova Playlist'` hardcoded — que é exatamente o bug I-SILENT,
alvo de uma rodada de integração posterior, não desta rodada), mas não
o bug alvo desta rodada (null-safety ausente em `artist_name` dentro de
`_filterMusicas`).

Mais relevante ainda: **nenhum dos 3 documentos `musica` seedados no
`setUp()` omite o campo `artist_name`** — todos têm `'artist_name'`
preenchido. Como consequência, o `_filterMusicas()` nunca processa uma
palavra nula, e o bug **nunca é exercitado por nenhum dos 14 testes
gerados**. Diferente das rodadas unitárias (onde ZS/COT "adivinharam"
corretamente o comportamento buggy até sem serem avisados), aqui a
estratégia zero-shot **não elaborou nenhum cenário de dado incompleto
no Firestore** — resultado: 14/14 passam, mas isso não significa que a
aplicação esteja livre do bug; significa que o teste simplesmente não o
alcança.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 14 |
| **Testes passaram (1ª execução)** | 14 |
| **Testes falharam (1ª execução)** | 0 |
| **Testes passaram (pós-repair)** | — (não necessário) |
| **Testes falharam (pós-repair)** | — (não necessário) |

### Saída do terminal

```
00:00 +0: loading test/fase2/widget/wcrash_zs_test.dart
00:00 +0: CriarPlaylistScreen - renderização deve renderizar os principais elementos da tela
00:01 +1: CriarPlaylistScreen - renderização deve carregar as músicas do Firestore
00:01 +2: CriarPlaylistScreen - validação deve mostrar mensagem quando tentar salvar sem nome
00:02 +3: CriarPlaylistScreen - validação não deve salvar playlist quando o nome estiver vazio
00:02 +4: CriarPlaylistScreen - validação deve aceitar nome de playlist válido
00:02 +5: CriarPlaylistScreen - pesquisa deve filtrar músicas pelo nome da música
00:02 +6: CriarPlaylistScreen - pesquisa deve filtrar músicas pelo nome do artista
00:02 +7: CriarPlaylistScreen - pesquisa a pesquisa deve ignorar maiúsculas e minúsculas
00:03 +8: CriarPlaylistScreen - pesquisa deve exibir indicador de carregamento quando não houver resultados
00:03 +9: CriarPlaylistScreen - seleção de músicas deve selecionar uma música ao tocar no checkbox
00:03 +10: CriarPlaylistScreen - seleção de músicas deve permitir desmarcar uma música selecionada
00:03 +11: CriarPlaylistScreen - salvar playlist deve salvar playlist com usuário autenticado
00:04 +12: CriarPlaylistScreen - salvar playlist deve voltar para a tela anterior após salvar
00:04 +13: CriarPlaylistScreen - navegação deve voltar ao tocar no botão de voltar
00:04 +14: All tests passed!
```

(saída completa, incluindo resolução de dependências, em `fase2/resultados/widget/FASE2-WCRASH-ZS.txt`)

---

## Iterative Repair Loop

Não foi necessário — todos os testes passaram na primeira execução
(mas por não terem exercitado o bug alvo, não por o terem contornado
corretamente — ver "Achado metodológico importante" acima).

---

## ★ Análise de Autoclassificação (preencher após a rodada)

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | Não declarada quanto ao W-CRASH (o modelo declarou espontaneamente um problema não relacionado — o bug I-SILENT) |
| **★ Classificação humana (auditoria)** | Limitação de testabilidade / Ambíguo — o teste não é "errado" nem "captura o bug real": ele simplesmente nunca constrói o cenário (documento sem `artist_name`) que dispararia o W-CRASH |
| **★ Concordância** | N/A — não há autoclassificação sobre o bug alvo para comparar |
| **★ Observações** | Primeira rodada em que o LLM **não detecta o bug alvo de forma alguma**, nem por comportamento nem por inspeção do código — mesmo a linha `musica['artist_name'].toLowerCase()` sem `?.`/`??` estando explicitamente no código-fonte enviado no prompt. Isso contrasta fortemente com o nível unitário, onde a detecção foi quase universal. Pode indicar que bugs de null-safety em código de UI mais complexo (widget com múltiplas responsabilidades) são mais difíceis de identificar por inspeção estática do que bugs isolados em funções puras curtas. |

**Referência de categorias (classificação humana — mesmas da Fase 1):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
