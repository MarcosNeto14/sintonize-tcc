# INT-COT-03 — Fluxo Playlist — Chain-of-Thought

## Metadados

| Campo                    | Valor                                                          |
| ------------------------ | -------------------------------------------------------------- |
| **ID da Rodada**         | INT-COT-03                                                     |
| **Fluxo testado**        | Playlist (CriarPlaylistScreen + AdicionarMusicaScreen)         |
| **Arquivos envolvidos**  | lib/criar_playlist.dart, lib/adicionar-musica.dart            |
| **Nível da pirâmide**    | Integration test                                               |
| **Estratégia de prompt** | Chain-of-Thought                                               |
| **LLM utilizado**        | ChatGPT                                                        |
| **Versão do modelo**     | [preencher]                                                    |
| **Data de acesso**       | 2026-05-25                                                     |
| **Conversa nova?**       | Sim (cada rodada em conversa limpa)                            |
| **Framework de teste**   | flutter_test                                                   |
| **Versão do Flutter**    | Flutter 3.41.6 • Dart 3.11.4                                  |

---

## Prompt Enviado

```
Quero que você gere um teste de integração em Dart para o fluxo do aplicativo Flutter "Sintonize" descrito abaixo. Antes de escrever os testes, siga estes passos:

1. Analise o fluxo [...]
2. Identifique as dependências [...]
3. Monte a estrutura de navegação [...]
4. Identifique os cenários de teste [...]
5. Escreva os testes [...]

IMPORTANTE: Não modifique o código das telas. Apenas gere os testes.

Fluxo a testar: CriarPlaylistScreen (criação de playlist, snackbar para nome vazio, botão "Salvar Playlist") + AdicionarMusicaScreen (adição de músicas, campo de pesquisa, botão "Concluir").

Restrições: FirebaseFirestore.instance estático em ambas; não testar _fetchMusicas()/_salvarPlaylist(); ambas exibem CircularProgressIndicator enquanto aguardam Firebase; CriarPlaylistScreen requer editPlaylist: {}; AdicionarMusicaScreen requer playlistId e currentSongs; nunca usar pumpAndSettle; dois pumps para navegação.

[código completo de lib/criar_playlist.dart e lib/adicionar-musica.dart]

Dependências disponíveis: firebase_auth_mocks, fake_cloud_firestore, mockito.
```

---

## Resposta do LLM — Análise CoT

### 1. Análise do fluxo

O fluxo começa na CriarPlaylistScreen, onde o usuário digita o nome da playlist e pesquisa músicas. Enquanto `_fetchMusicas()` aguarda o Firestore, a tela exibe `CircularProgressIndicator`. Ao clicar em "Salvar Playlist": nome vazio → SnackBar; nome preenchido → `_salvarPlaylist()` (não testado por depender de Firestore estático). A AdicionarMusicaScreen também inicia com loading assíncrono e exibe spinner. O usuário pesquisa músicas e clica em "Concluir": sem seleção → `Navigator.pop(context)`; com seleção → atualiza Firestore antes do pop (não testado).

### 2. Dependências e estratégia

| Tela | Dependência | Estratégia |
|---|---|---|
| CriarPlaylistScreen | FirebaseFirestore (estático) | Não testar _fetchMusicas() nem _salvarPlaylist() |
| CriarPlaylistScreen | FirebaseAuth (estático) | Não testar _salvarPlaylist() |
| CriarPlaylistScreen | Navigator | Validar pop com tela fake |
| CriarPlaylistScreen | ScaffoldMessenger | Verificar texto do SnackBar |
| AdicionarMusicaScreen | FirebaseFirestore (estático) | Não testar _fetchMusicas() nem update |
| AdicionarMusicaScreen | Navigator | Validar pop com tela fake |

Estratégia de mock declarada (mas não utilizada — instâncias estáticas):
```dart
late FakeFirebaseFirestore firestore;
late MockFirebaseAuth auth;
```

### 3. Estrutura de navegação

`MaterialApp(home: child)` simples para testes de UI isolados. Para testes de navegação (back/pop), padrão `Builder + Navigator.push + dois pumps`.

### 4. Cenários identificados (11 testes)

- CriarPlaylistScreen: loading inicial, renderização de campos/botão, snackbar nome vazio, digitar nome, digitar pesquisa, voltar para tela anterior
- AdicionarMusicaScreen: loading inicial, renderização de pesquisa/botão, digitar pesquisa, voltar com back, fechar ao concluir sem músicas

---

## Resultado da Execução (Geração inicial)

| Métrica             | Valor |
| ------------------- | ----- |
| **Compilou?**       | Sim   |
| **Testes gerados**  | 11    |
| **Testes passaram** | 11    |
| **Testes falharam** | 0     |

### Saída do terminal

```
00:20 +0: CriarPlaylistScreen deve renderizar loading inicial
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:23 +1: CriarPlaylistScreen deve renderizar loading inicial
00:24 +2: CriarPlaylistScreen deve exibir campos e botão principais
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:24 +3: CriarPlaylistScreen deve mostrar snackbar ao salvar sem nome
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:24 +4: CriarPlaylistScreen deve permitir digitar nome da playlist
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:25 +5: CriarPlaylistScreen deve permitir digitar no campo de pesquisa
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:25 +6: CriarPlaylistScreen deve voltar para tela anterior ao clicar back
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:25 +7: AdicionarMusicaScreen deve renderizar loading inicial
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:25 +8: AdicionarMusicaScreen deve exibir pesquisa e botão concluir
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:25 +9: AdicionarMusicaScreen deve permitir digitar no campo de pesquisa
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:25 +10: AdicionarMusicaScreen deve voltar ao clicar no botão back
Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:25 +11: AdicionarMusicaScreen deve fechar tela ao concluir sem músicas selecionadas
00:25 +11: All tests passed!
```

**Nota:** Os "Erro ao buscar músicas: [core/no-app]" são saídas do `catch` interno de `_fetchMusicas()` em ambas as telas — comportamento esperado sem Firebase inicializado. Não afetam os testes, pois a UI permanece no estado `CircularProgressIndicator` (lista vazia).

## Iterative Repair Loop

Não necessário — 11/11 na geração inicial.

## Resultado Final

| Métrica             | Valor |
| ------------------- | ----- |
| **Compilou?**       | Sim   |
| **Testes gerados**  | 11    |
| **Testes passaram** | 11    |
| **Testes falharam** | 0     |
| **Iterações**       | 0     |
