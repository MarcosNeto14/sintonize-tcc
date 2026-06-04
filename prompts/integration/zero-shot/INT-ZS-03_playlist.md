# INT-ZS-03

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | INT-ZS-03 |
| **Fluxo testado** | Playlist (CriarPlaylistScreen + AdicionarMusicaScreen) |
| **Arquivos de origem** | `lib/criar_playlist.dart`, `lib/adicionar-musica.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.5 |
| **Data de acesso** | 2026-05-22 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | Flutter 3.41.6 / Dart 3.11.4 |

---

## Prompt Enviado

```
Gere um teste de integração em Dart usando flutter_test para o seguinte fluxo do aplicativo Flutter "Sintonize":

O fluxo de playlist envolve duas telas: (1) CriarPlaylistScreen, onde o usuário digita o nome de uma nova
playlist, pesquisa e seleciona músicas e toca "Salvar Playlist"; (2) AdicionarMusicaScreen, onde o usuário
pesquisa e seleciona músicas para adicionar a uma playlist existente e toca "Concluir". Ambas as telas
retornam com Navigator.pop ao concluir. As músicas são carregadas do Firestore na coleção "musica" via
initState.

[código completo de lib/criar_playlist.dart e lib/adicionar-musica.dart]

Dependências disponíveis: firebase_auth_mocks, fake_cloud_firestore, mockito
Requisitos: testWidgets, MaterialApp com rotas, mocks Firebase, fluxo ponta a ponta, cenários de erro,
executável com flutter test test/integration/, NÃO modificar código de produção
```

---

## Resposta do LLM

O LLM gerou 5 testes cobrindo: criar playlist com sucesso, nome vazio, adicionar músicas, concluir sem seleção, erro Firebase. Usou `FakeFirebaseFirestore` para seed de dados e verificação, mas sem inicializar Firebase — assumiu erroneamente que `FakeFirebaseFirestore` interceptaria `FirebaseFirestore.instance`.

> **Nota metodológica:** A geração inicial foi de 5 testes. Após o repair loop (ver seção Iterative Repair Loop), o LLM removeu a dependência Firebase, regeneou com 9 testes (Iteração 1) e depois removeu 1 teste problemático, totalizando 8 testes finais. A tabela de Resultado da Execução registra a contagem final (8), não a inicial (5).

**Arquivo gerado:** `test/integration/playlist_flow_zs_test.dart`

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 8 |
| **Testes passaram (1ª execução)** | 0 |
| **Testes falharam (1ª execução)** | 5 |
| **Testes passaram (pós-repair)** | 8 |
| **Testes falharam (pós-repair)** | 0 |

### Saída do terminal

```
00:14 +0 -1: Fluxo CriarPlaylistScreen deve criar playlist com sucesso [E]
  Erro ao buscar músicas: [core/no-app] No Firebase App '[DEFAULT]' has been created
  pumpAndSettle timed out
  (CircularProgressIndicator nunca resolve — _fetchMusicas() falha silenciosamente no catch)

00:14 +0 -2: Fluxo CriarPlaylistScreen deve mostrar erro ao salvar playlist sem nome [E]
  Erro ao buscar músicas: [core/no-app]
  pumpAndSettle timed out

00:27 +0 -3: Fluxo AdicionarMusicaScreen deve adicionar música à playlist existente [E]
  Erro ao buscar músicas: [core/no-app]
  pumpAndSettle timed out

00:32 +0 -4: Fluxo AdicionarMusicaScreen deve apenas fechar tela ao concluir sem selecionar músicas [E]
  Erro ao buscar músicas: [core/no-app]
  pumpAndSettle timed out

00:32 +0 -5: Cenários de erro Firebase deve tratar erro ao salvar playlist [E]
  Exception: Method.write on musica/... is not allowed
  (security rules bloquearam o próprio seed de dados do teste)

00:32 +0 -5: Some tests failed.
```

**Diagnóstico:** as telas chamam `FirebaseFirestore.instance.collection('musica').get()` em `initState`. Sem Firebase inicializado, o erro `[core/no-app]` é capturado silenciosamente pelo `catch(e)` e a lista fica vazia → `CircularProgressIndicator` permanente → `pumpAndSettle` timeout em todos os testes que usam a tela. Além disso, `FakeFirebaseFirestore` não intercepta `FirebaseFirestore.instance` — os dados semeados no fake são invisíveis para a tela.

---

## Iterative Repair Loop

### Iteração 1

**Prompt de reparo enviado:**
```
Os testes falharam com [core/no-app] e pumpAndSettle timed out. Restrições:
não modificar telas; firebase_auth_mocks 0.14.2 não tem setupFirebaseAuthMocks();
FakeFirebaseFirestore não intercepta FirebaseFirestore.instance.
Fixes: substituir pumpAndSettle() por pump(Duration fixo); remover asserções
dependentes de Firebase; focar em UI/validação/navegação básica.
```

**Resposta do LLM:**
Removeu todos os imports Firebase/fake. Gerou 9 testes de UI pura usando `pump(Duration(seconds: 1))` em vez de `pumpAndSettle`. Compilou.

**Resultado:**
```
+1: CriarPlaylistScreen deve renderizar campos e botão                    PASS
+2: CriarPlaylistScreen deve permitir digitar nome da playlist            PASS
+3: CriarPlaylistScreen deve mostrar snackbar ao salvar sem nome          PASS
-1: CriarPlaylistScreen deve tentar salvar sem crash                      FAIL
    FirebaseException: [core/no-app] — _salvarPlaylist chama
    FirebaseAuth.instance, Future não tratado vira falha de teste
-2: CriarPlaylistScreen botão voltar deve fechar a tela                   FAIL
    "Criando Playlist" não encontrado — pump(seconds:1) avança 1 frame,
    não completa animação de navegação
+4: AdicionarMusicaScreen deve renderizar tela corretamente               PASS
+5: AdicionarMusicaScreen deve permitir digitar na pesquisa               PASS
-3: AdicionarMusicaScreen botão concluir deve fechar tela                 FAIL
    "Adicionar Músicas" não encontrado — mesmo problema de animação
-4: AdicionarMusicaScreen botão voltar deve retornar navegação            FAIL
    Icons.arrow_back não encontrado — mesma causa

00:03 +5 -4: Some tests failed.
```

**Diagnóstico:**
- Tests 1-3, 6-7: passam — UI estática sem navegação push
- Test 4: `pump(seconds:1)` faz apenas 1 frame — navegação (300ms, múltiplos frames) não completa
- Test 5 ("salvar sem crash"): `FirebaseAuth.instance` lança em Future não tratado — flutter_test registra como falha de teste mesmo com `pump` (não é crash do app, é unhandled Future rejection)

---

### Iteração 2

**Prompt de reparo enviado:**
```
5/9 passaram. Duas falhas remanescentes:
1) "salvar sem crash" — FirebaseAuth.instance lança Future não tratado;
   remover esse teste completamente.
2) 3 testes de navegação — pump(seconds:1) avança 1 frame, animação não completa;
   substituir por: await tester.pump(); await tester.pump(Duration(milliseconds:500));
Manter os 5 testes que já passam exatamente como estão.
```

**Resposta do LLM:**
Removeu o teste problemático (Firebase submit). Substituiu pump(seconds:1) por dois pumps consecutivos nos 3 testes de navegação. Total: 8 testes.

**Resultado:**
```
00:01 +1: CriarPlaylistScreen deve renderizar campos e botão              PASS
00:02 +2: CriarPlaylistScreen deve permitir digitar nome da playlist      PASS
00:02 +3: CriarPlaylistScreen deve mostrar snackbar ao salvar sem nome    PASS
00:03 +4: CriarPlaylistScreen botão voltar deve fechar a tela             PASS
00:03 +5: AdicionarMusicaScreen deve renderizar tela corretamente         PASS
00:03 +6: AdicionarMusicaScreen deve permitir digitar na pesquisa         PASS
00:03 +7: AdicionarMusicaScreen botão concluir sem seleção deve fechar    PASS
00:04 +8: AdicionarMusicaScreen botão voltar deve retornar navegação      PASS
00:04 +8: All tests passed!
```

---

### Iteração 3

Não necessária.
