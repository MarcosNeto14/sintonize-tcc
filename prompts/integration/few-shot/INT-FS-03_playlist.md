# INT-FS-03 — Fluxo Playlist — Few-shot

## Metadados

| Campo                    | Valor                                                                      |
| ------------------------ | -------------------------------------------------------------------------- |
| **ID da Rodada**         | INT-FS-03                                                                  |
| **Fluxo testado**        | Playlist (CriarPlaylistScreen + AdicionarMusicaScreen)                     |
| **Arquivos envolvidos**  | lib/criar_playlist.dart, lib/adicionar-musica.dart                        |
| **Nível da pirâmide**    | Integration test                                                           |
| **Estratégia de prompt** | Few-shot                                                                   |
| **LLM utilizado**        | ChatGPT                                                                    |
| **Versão do modelo**     | GPT-4.5                                                                |
| **Data de acesso**       | 2026-05-25                                                                 |
| **Conversa nova?**       | Sim (cada rodada em conversa limpa)                                        |
| **Framework de teste**   | flutter_test                                                               |
| **Versão do Flutter**    | Flutter 3.41.6 • Dart 3.11.4                                              |

---

## Prompt Enviado

```
Gere um teste de integração em Dart usando flutter_test para o fluxo do aplicativo Flutter "Sintonize" descrito abaixo.

Antes, veja um exemplo de teste de integração que funcionou para o fluxo de login (8/8 testes passando):

[exemplo login_flow_fs_test.dart — omitido por brevidade; mesmo exemplo usado em INT-FS-01 e INT-FS-02]

---

Agora, gere um teste de integração para o seguinte fluxo:

**Fluxo:** O usuário cria uma playlist na CriarPlaylistScreen (define nome e opcionalmente pesquisa músicas) e depois adiciona músicas na AdicionarMusicaScreen (pesquisa e seleciona, depois conclui voltando à tela anterior).

**Atenção:**
- Ambas as telas chamam FirebaseFirestore.instance.collection('musica').get() no initState() via _fetchMusicas(). Esse fetch vai falhar silenciosamente (sem Firebase inicializado), e enquanto _musicasFiltradas estiver vazia a tela exibe CircularProgressIndicator. Não tente testar músicas listadas — elas nunca aparecerão.
- Construa CriarPlaylistScreen com CriarPlaylistScreen(editPlaylist: {}).
- Construa AdicionarMusicaScreen com AdicionarMusicaScreen(playlistId: 'playlist_1', currentSongs: []).
- Use await tester.pump(const Duration(seconds: 1)) após pumpWidget para aguardar a tentativa de fetch do Firebase sem travar.
- Para testar navegação, use o padrão Builder + Navigator.push + dois pumps.
- CriarPlaylistScreen usa FirebaseAuth.instance.currentUser em _salvarPlaylist() (não no initState) — não teste o botão "Salvar Playlist" com nome preenchido.
- AdicionarMusicaScreen com lista vazia exibe spinner — o botão "Concluir" sem seleção chama Navigator.pop(context) diretamente. Esse cenário pode ser testado.
- Nunca use pumpAndSettle.

Código das telas envolvidas: [lib/criar_playlist.dart e lib/adicionar-musica.dart — omitidos por brevidade]

Dependências disponíveis:
- firebase_auth_mocks
- fake_cloud_firestore
- mockito
```

---

## Resposta do LLM

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/criar_playlist.dart';
import 'package:sintonize/adicionar-musica.dart';

void main() {
  group('Fluxo de Playlist', () {
    testWidgets('deve renderizar CriarPlaylistScreen com campos e spinner', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CriarPlaylistScreen(editPlaylist: {})));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Criando Playlist'), findsOneWidget);
      expect(find.text('Nome da Playlist'), findsOneWidget);
      expect(find.text('Pesquisar Música ou Artista'), findsOneWidget);
      expect(find.text('Salvar Playlist'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('deve permitir digitar nome da playlist e pesquisa', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CriarPlaylistScreen(editPlaylist: {})));
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextField).at(0), 'Minha Playlist');
      await tester.enterText(find.byType(TextField).at(1), 'Rock');
      await tester.pump();
      expect(find.text('Minha Playlist'), findsOneWidget);
      expect(find.text('Rock'), findsOneWidget);
    });

    testWidgets('deve mostrar SnackBar ao tentar salvar playlist sem nome', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CriarPlaylistScreen(editPlaylist: {})));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pump();
      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);
    });

    testWidgets('botão voltar deve fechar CriarPlaylistScreen', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CriarPlaylistScreen(editPlaylist: {}))),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Abrir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CriarPlaylistScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CriarPlaylistScreen), findsNothing);
      expect(find.text('Abrir'), findsOneWidget);
    });

    testWidgets('deve renderizar AdicionarMusicaScreen com spinner', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AdicionarMusicaScreen(playlistId: 'playlist_1', currentSongs: [])));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Adicionar Músicas'), findsOneWidget);
      expect(find.text('Pesquisar Música ou Artista'), findsOneWidget);
      expect(find.text('Concluir'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('deve permitir pesquisar música em AdicionarMusicaScreen', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AdicionarMusicaScreen(playlistId: 'playlist_1', currentSongs: [])));
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextField), 'Metallica');
      await tester.pump();
      expect(find.text('Metallica'), findsOneWidget);
    });

    testWidgets('botão concluir sem músicas selecionadas deve voltar para tela anterior', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdicionarMusicaScreen(playlistId: 'playlist_1', currentSongs: []))),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Abrir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(AdicionarMusicaScreen), findsOneWidget);
      await tester.tap(find.text('Concluir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(AdicionarMusicaScreen), findsNothing);
      expect(find.text('Abrir'), findsOneWidget);
    });

    testWidgets('botão voltar deve fechar AdicionarMusicaScreen', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdicionarMusicaScreen(playlistId: 'playlist_1', currentSongs: []))),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('Abrir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(AdicionarMusicaScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(AdicionarMusicaScreen), findsNothing);
      expect(find.text('Abrir'), findsOneWidget);
    });
  });
}
```

---

## Resultado da Execução

| Métrica             | Valor |
| ------------------- | ----- |
| **Compilou?**       | Sim   |
| **Testes gerados**  | 8     |
| **Testes passaram** | 8     |
| **Testes falharam** | 0     |
| **Iterações**       | 0     |

### Saída do terminal

```
00:00 +0: Fluxo de Playlist deve renderizar CriarPlaylistScreen com campos e spinner
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:01 +1: Fluxo de Playlist deve permitir digitar nome da playlist e pesquisa
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:01 +2: Fluxo de Playlist deve mostrar SnackBar ao tentar salvar playlist sem nome
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:01 +3: Fluxo de Playlist botão voltar deve fechar CriarPlaylistScreen
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:02 +4: Fluxo de Playlist deve renderizar AdicionarMusicaScreen com spinner
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:02 +5: Fluxo de Playlist deve permitir pesquisar música em AdicionarMusicaScreen
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:02 +6: Fluxo de Playlist botão concluir sem músicas selecionadas deve voltar para tela anterior
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:02 +7: Fluxo de Playlist botão voltar deve fechar AdicionarMusicaScreen
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:02 +8: All tests passed!
```

**Nota:** As linhas `Erro ao buscar músicas: [core/no-app]...` são saídas de `print()` das próprias telas (não falhas de teste) — comportamento esperado e previsto no prompt.

---

## Iterative Repair Loop

Não necessário — 8/8 na geração inicial.
