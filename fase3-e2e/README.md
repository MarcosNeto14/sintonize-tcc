# Fase 3 — Testes E2E

## Decisão de escopo (2026-09-29) e declaração de autoria

A Fase 3 segue a **mesma comparação das Fases 1 e 2 — ZS/FS/COT × ChatGPT/Gemini —
agora no nível E2E**, com testes `integration_test` executados no AVD contra os
emuladores Firebase. Os prompts estão em `prompts_prontos/`, o template de
rodada em `template_rodada.md`, a rubrica manual-first em `roteiro_manual.md`
e o plano de rodadas em "Plano de rodadas", abaixo.

**Os três testes em `integration_test/_referencia/` não entram na comparação.**
Eles foram produzidos com assistência de LLM (Claude Code) em regime
interativo, com acesso ao código, ao dispositivo e às saídas de cada
execução, fora do protocolo experimental. Ficam como implementação de
referência e prova de detectabilidade dos bugs L4, C3 e P2, e **não podem
aparecer em nenhum prompt, nem de geração nem de reparo**. Os tempos medidos
e a tabela SILENT × CRASH estão consolidados em
`analise/custo_e_referencia.md`.

## Base de código

A branch `fase3-e2e` foi criada em 2026-09-28 a partir de `fase2-gemini-alvos-limpos` (`27f2f69`).

**Motivo:** é o mesmo `lib/` usado nas Fases 2 dos dois modelos (ChatGPT e Gemini), com os 6 bugs plantados revertidos. Esse `lib/` difere do `main` em 6 arquivos, só pela injeção opcional de `auth`/`firestore` nos construtores (`CadastroScreen`, `LoginScreen`, `GenerosCadastroScreen`, `CriarPlaylistScreen`). Em execução real esses parâmetros ficam nulos e as telas usam `FirebaseAuth.instance` / `FirebaseFirestore.instance`, como no `main`. A injeção não altera o comportamento.

**Verificação:** `git diff fase2-gemini-piloto..fase3-e2e -- lib/` mostra exatamente a reversão dos 6 bugs da Fase 2, e nada mais:

| Bug | Arquivo | Na `fase2-gemini-piloto` | Na `fase3-e2e` |
|---|---|---|---|
| W-CRASH | `lib/criar_playlist.dart:56` | `musica['artist_name'].toLowerCase()` | `musica['artist_name']?.toLowerCase() ?? ''` |
| I-SILENT | `lib/criar_playlist.dart:251` | `'nome': 'Nova Playlist'` | `'nome': _playlistName` |
| I-CRASH | `lib/generos-cadastro.dart:44` | `_auth.currentUser!.uid` fora do `try` | `if (user != null)` em volta do bloco (o resto do diff é reindentação; `git diff -w` confirma) |
| W-SILENT | `lib/login.dart:41–44` | mensagens de `user-not-found` e `wrong-password` trocadas | mensagens corretas |
| U-SILENT | `lib/utils/validators.dart:117` | `value.length < 7` | `value.length < 6` |
| U-CRASH | `lib/utils/validators.dart:162` | sem guarda | `if (word.isEmpty) return word;` |

U-CRASH e U-SILENT não são alcançáveis em E2E: nenhuma tela importa `validators.dart`.

## Estado em 2026-09-28 (continuidade)

| Item | Estado |
|---|---|
| `firebase.json` com a seção `emulators` (auth 9099, firestore 8080, ui 4000) | feito, commitado |
| Logs dos emuladores no `.gitignore` | feito (`firebase-debug.log`, `ui-debug.log`, `firestore-debug.log`) |
| `integration_test/firebase_test_helper.dart` | feito: `setupFirebaseEmulators()`, host por `--dart-define=EMU_HOST` (padrão `10.0.2.2`), guarda estática contra dupla inicialização |
| `integration_test/seed.dart` | feito: `seedEmulators()`, com usuário `tester@sintonize.test` / `senha123`, o doc `usuarios/{uid}` no formato do cadastro (`nome` = `tester sintonize`, `generos_favoritos` = `[rock, pop]`, endereço) e 5 docs em `musica` (`track_name`, `artist_name`, `genre`), IDs fixos, idempotente. O doc de usuário foi acrescentado em 2026-09-28 porque a `TelaInicialScreen` lê `nome` e `generos_favoritos` |
| `integration_test/seed_test.dart` | só popula e confere (usuário, doc, 5 músicas); para inspecionar no Emulator UI. Os testes de fluxo chamam o seed sozinhos |
| `integration_test/smoke_test.dart` | escrito e com `flutter analyze` limpo; **executado e verde na segunda máquina em 2026-09-28** (ver "Execução da fumaça") |
| `integration_test/login_flow_test.dart` | **feito e verde (5/5) em 2026-09-28**: espelha o E2E-02 manual — E1..E4 + login válido até a `TelaInicialScreen` com saudação e recomendação (ver "Execução do fluxo de login"). Corrigido no run 3 (baseline do L4): espera pela saída da `LoginScreen`, não só pela chegada da `TelaInicialScreen` |
| `integration_test/cadastro_flow_test.dart` | **feito e verde (6/6) em 2026-09-28, no 4º run**: espelha o E2E-01 manual — E1..E5 + cadastro válido → gêneros (E6 embutido) → `TelaInicialScreen`, conferindo o doc em `usuarios/{uid}`. E-mail novo por execução (sufixo de timestamp). Ver "Execução do fluxo de cadastro" |
| `integration_test/playlist_flow_test.dart` | **feito e verde (4/4) em 2026-09-28, no 2º run**: espelha o E2E-03 manual — lista com as 5 músicas do seed, E1 (salvar sem nome), pesquisa por música/artista, criar playlist válida → volta à `UsuarioScreen` com ela listada, conferindo o doc em `playlists`. Ver "Execução do fluxo de playlist" |
| `integration_test/pump_helpers.dart` | helpers compartilhados pelos três fluxos: `pumpAte()`, `pumpAteSumir()`, `fecharTeclado()` e `tocarQuandoAlcancavel()` (os dois últimos saíram do `cadastro_flow_test.dart` após o run 4, sem mudança de comportamento; o cadastro foi reexecutado depois da mudança) |
| `android/app/src/debug/AndroidManifest.xml` | **alterado em 2026-09-28**: `<application android:usesCleartextTraffic="true"/>`, só no debug. Sem isso o Auth emulator falha com `Cleartext HTTP traffic to 10.0.2.2 not permitted` (a fumaça não pegou porque não chama o Auth) |
| Emuladores Firebase | testados na máquina original: subiram em 47 s e 9099/8080 responderam 200. Na segunda máquina, idem (200/200) |
| AVD `tcc_e2e` | criado na máquina original, **nunca subiu lá**: sem aceleração de hardware (hipervisor habilitado, mas a máquina não foi reiniciada). Na segunda máquina, WHPX usável; subiu em 132 s (boot frio) |
| `android/app/build.gradle` | **alterado pela própria ferramenta Flutter** no primeiro build: `minSdkVersion 23` → `minSdkVersion flutter.minSdkVersion`. Não foi edição manual; mantido, porque a ferramenta refaria a troca no build seguinte |
| `lib/` | limpo na ponta da branch. **Os 3 bugs (L4 em 2026-09-28; C3 e P2 em 2026-09-29) aplicados, detectados e revertidos** (ver "Aplicação dos bugs") |

### Execução da fumaça (segunda máquina, 2026-09-28)

`flutter test integration_test/smoke_test.dart -d emulator-5554`, com os emuladores Firebase já no ar e o AVD já em `device`:

| Etapa | Tempo |
|---|---|
| Subir o AVD `tcc_e2e` até `sys.boot_completed=1` (boot frio, `-no-snapshot-load`) | 132 s |
| Gradle `assembleDebug` (primeiro build; instalou sozinho NDK 28.2.13676358 e CMake 3.22.1) | 362 s |
| Instalar o APK | 0,9 s |
| Teste (`setUpAll` + `fumaça: o app abre e chega à LoginScreen` + `tearDownAll`) | 5 s |
| **Total do comando** | **390 s** |

Resultado: `00:05 +1: All tests passed!`. A fumaça não chama o Auth, então não revelou o bloqueio de cleartext (ver abaixo). O seed não é usado pela fumaça.

### Execução do fluxo de login (segunda máquina, 2026-09-28)

`flutter test integration_test/login_flow_test.dart -d emulator-5554`, AVD e emuladores já no ar.

- **Run 1: falhou no `setUpAll`**, no primeiro `createUserWithEmailAndPassword` do seed: `[firebase_auth/unknown] An internal error has occurred. [ Cleartext HTTP traffic to 10.0.2.2 not permitted`. Exatamente o item 3 da lista original. Saída em `resultados/2026-09-28_login_flow_test_run1.txt`.
- **Correção:** `<application android:usesCleartextTraffic="true"/>` em `android/app/src/debug/AndroidManifest.xml`. Nada em `lib/`, nada no manifest principal.
- **Run 2: 5/5.** Saída em `resultados/2026-09-28_login_flow_test_run2.txt`.

| Etapa | Tempo |
|---|---|
| Gradle `assembleDebug` (build incremental) | 19,6 s |
| `setUpAll` (init + seed: usuário, doc, 5 músicas) | 4 s |
| E1, E2, E3 (validação local) | 6 s, 2 s, 2 s |
| E4 (senha errada, vai ao Auth emulator) | 2 s |
| Login válido → `TelaInicialScreen` + saudação + recomendação | 4 s |
| **Total do comando** | **50 s** (21 s de teste) |

Runs posteriores do mesmo arquivo (mesma máquina, mesmo dia): **run 3, 4/5** — baseline do L4 sobre o `lib/` limpo, falhou em "login válido" porque a `TelaInicialScreen` já é encontrada durante a transição do `pushReplacement`, com a `LoginScreen` ainda saindo (a mesma armadilha do pop no fluxo de playlist; o run 2 passou por sorte de timing). Correção no teste: `pumpAteSumir(LoginScreen)` depois de `pumpAte(TelaInicialScreen)`. **Run 4, 5/5**, 27 s — é o baseline válido do L4. Saídas em `resultados/2026-09-28_login_flow_test_run3_baseline_L4_flaky.txt` e `2026-09-28_L4_antes_login_flow_test.txt`.

### Execução do fluxo de cadastro (segunda máquina, 2026-09-28)

`flutter test integration_test/cadastro_flow_test.dart -d emulator-5554`. Quatro runs; as saídas estão em `resultados/2026-09-28_cadastro_flow_test_run{1..4}.txt`.

| Run | Resultado | O que mudou antes dele |
|---|---|---|
| 1 | 1/6 — E1..E5 falham, o fluxo completo **passa** | primeira versão |
| 2 | 4/6 — E1 e E3 falham | `unfocus()` + `pumpAndSettle` antes de rolar até "Cadastrar" |
| 3 | 5/6 — E5 falha | espera explícita por `viewInsets.bottom == 0` (a animação do teclado é do Android; `pumpAndSettle` não a espera) |
| 4 | **6/6**, 61 s (20 s de Gradle, 30 s de teste) | o toque só sai depois de um hit test real acertar o botão, com até 8 s de repetição e diagnóstico impresso a cada erro |
| 5 | **travou em `(setUpAll)`** por 11 min, interrompido à mão; ver a ocorrência operacional em "Execução do fluxo de playlist" | `fecharTeclado()` e `tocarQuandoAlcancavel()` movidos para `pump_helpers.dart`, sem mudança de comportamento |
| 6 | **6/6**, 43 s (11,4 s de Gradle, 25 s de teste), diagnóstico nunca impresso | nada; repetição do run 5 sozinho no comando |

Todas as falhas dos runs 1 a 3 têm a mesma assinatura: `tap()` em "Cadastrar" deriva `Offset(205.7, 748.3)` e o hit test não alcança o botão — o caminho para no `Material` do `Scaffold` sem entrar no `body`, ou seja, naquele instante o corpo estava menor do que a tela. No run 4 o hit test acertou na primeira tentativa em todos os 6 testes e o diagnóstico nunca foi impresso, então **a causa exata não ficou provada**; o que está registrado é (a) a assinatura, (b) que só o teste com uma espera fixa de 3 s antes do toque (o fluxo completo) passou em todos os runs, e (c) que a verificação por hit test estabilizou. Se voltar a falhar, a linha `Cadastrar fora do alvo (...)` traz `rect`, tamanho do `body`, `viewInsets`, `padding` e os 3 primeiros alvos do hit test.

Outros registros:
- **ViaCEP é rede externa e real**: o CEP `01310-100` preencheu `Cidade` com "São Paulo" nos 4 runs. O teste só imprime, não afirma, porque o serviço não é controlado. Se a máquina estiver sem internet, o app mostra uma SnackBar de erro e o cadastro segue (Rua/Bairro/Cidade não têm validador).
- **E6 está dentro do teste do fluxo completo** (Confirmar sem gênero → SnackBar → liga "Rock" → Confirmar), porque a tela de gêneros só existe depois de um cadastro válido.
- Estado deixado no emulador: um usuário `cadastro-<timestamp>@sintonize.test` por execução, com `generos_favoritos = ['Rock']`. O emulador não persiste entre reinícios.
- Quando o bug **C3** for aplicado (`_nomeController` → `_emailController` na gravação do `nome`), este teste deve pegá-lo em dois pontos: a saudação esperada "João Silva, ..." e a asserção `doc['nome'] == 'joão silva'`.

### Execução do fluxo de playlist (segunda máquina, 2026-09-28)

`flutter test integration_test/playlist_flow_test.dart -d emulator-5554`. Dois runs; saídas em `resultados/2026-09-28_playlist_flow_test_run{1,2}.txt`. O AVD e os emuladores tinham sido derrubados com o fim da sessão anterior e subiram de novo (AVD em 30 s desta vez, com o snapshot de sistema já aquecido).

| Run | Resultado | O que mudou antes dele |
|---|---|---|
| 1 | 2/4 — passam "lista carrega" e E1; falham "pesquisa" e "criar playlist" | primeira versão |
| 2 | **4/4**, 52 s (22,6 s de Gradle, 18 s de teste) | os dois ajustes abaixo |

As duas falhas do run 1 são **do teste, não do app**, e as duas ensinam algo sobre E2E em dispositivo:

1. **`ListView.builder` é preguiçoso.** Depois de limpar a pesquisa, o teste esperava 5 `ListTile` e achou 3: o teclado ainda estava aberto, o viewport da lista tinha encolhido e só 3 cards cabiam — os outros 2 simplesmente não existem na árvore. `findsNWidgets(5)` só vale com a lista inteira em tela. Correção: `fecharTeclado()` antes de contar.
2. **A tela de baixo já é encontrada durante o `pop`.** Depois de "Salvar Playlist", `pumpAte(UsuarioScreen)` voltou no meio da transição, com a `CriarPlaylistScreen` ainda saindo, e a asserção `findsNothing` sobre ela falhou. `pumpAndSettle` não serve porque a `UsuarioScreen` tem um `CircularProgressIndicator` enquanto carrega. Correção: `pumpAteSumir(CriarPlaylistScreen)` (novo helper).

Outros registros:
- **Passo 8 do roteiro manual diz "aparece na TelaInicialScreen"**, mas o `Navigator.pop` de `_salvarPlaylist` volta para a `UsuarioScreen` ("Minha Conta"), que é quem lista as playlists e refaz o fetch no retorno. O teste afirma o que o app faz.
- **A pesquisa filtra por `track_name` e `artist_name`, não por gênero.** O exemplo do roteiro ("rock") não encontraria nada no seed; o teste usa "queen" e "take".
- Nome de playlist único por execução (sufixo de timestamp), porque o emulador acumula uma por run e a `UsuarioScreen` lista todas as do usuário. O doc gravado tem `userId`, `nome`, `musicas = ['bohemian rhapsody']` (o `track_name` cru, sem formatação) e `dataCriacao`.
- Quando o bug **P2** for aplicado (`itemCount: _musicasFiltradas.length + 1`), o teste "lista carrega as 5 músicas do seed" deve pegá-lo: o item de índice 5 lança `RangeError` no `build`, e o framework de teste reporta a exceção como falha.

**Ocorrência operacional:** entre o run 1 do playlist e a reexecução do cadastro (encadeados no mesmo comando), o `flutter test` do cadastro **travou em `(setUpAll)` por 11 min** sem nenhuma saída. O AVD estava em `device`, os emuladores respondiam 200, a rede do AVD estava `VALIDATED`, e o logcat só mostra o app iniciando e o `FirebaseAuth` notificando sign-out — nada depois. Processos `dart` mortos à mão; a repetição (playlist run 2 e cadastro run 6) correu normal. Causa não identificada. Saída em `resultados/2026-09-28_cadastro_flow_test_run5_travado.txt`. Recomendação prática: um `flutter test` por comando, não encadear.

Registro do E4 do login: o Auth emulator devolveu `wrong-password`, e a SnackBar foi "Senha incorreta. Certifique-se de que está digitando a senha corretamente." (ramo `wrong-password` de `login.dart:43`). Em produção o Firebase atual devolve `invalid-credential` para o mesmo caso; o E2E-02 manual (Web, 2026-05-25) só registrou "SnackBar com mensagem de erro do Firebase", sem dizer qual. Quando o bug L4 for aplicado, o teste de login válido é o que deve pegá-lo (espera `TelaInicialScreen`, e L4 abre `CadastroScreen`).

### Bugs escolhidos para a Fase 3

Uma linha cada, no `lib/` desta branch. As linhas foram conferidas em 2026-09-28. Protocolo de aplicação: um bug por vez; o teste do fluxo roda **antes** (baseline, tem de estar verde com o mesmo código de teste) e **depois** (tem de ficar vermelho no ponto previsto); as duas saídas vão para `resultados/`; o bug entra num commit próprio, cujo hash é o estado reproduzível, e é revertido no commit seguinte, para a ponta da branch voltar ao `lib/` limpo.

### Aplicação dos bugs (segunda máquina, 2026-09-28 e 29)

| Bug | Baseline (antes) | Com o bug (depois) | Onde o teste pegou | Commit com o bug |
|---|---|---|---|---|
| L4 | `login_flow_test` 5/5, 27 s (`resultados/2026-09-28_L4_antes_login_flow_test.txt`) | **4/5**, 46 s — só "login válido chega à TelaInicialScreen" falha: `não apareceu em 20s: TelaInicialScreen` (`resultados/2026-09-28_L4_depois_login_flow_test.txt`) | `pumpAte(TelaInicialScreen)`, timeout de 20 s | `eb14334`. O commit `41bf190`, rotulado como reversão, **não reverteu** (`git checkout -- lib/login.dart` restaurou do índice, que já tinha o bug); a reversão real é o commit seguinte a ele |
| C3 | `cadastro_flow_test` 6/6, 78 s (`resultados/2026-09-29_C3_antes_cadastro_flow_test.txt`) | **5/6**, 65 s — só o fluxo completo falha: `não apareceu em 20s: ... João Silva, essa é a nossa recomendação de` (`resultados/2026-09-29_C3_depois_cadastro_flow_test.txt`) | `pumpAte(saudação)` na `TelaInicialScreen`, timeout de 20 s | `20edaaa` (revertido no commit seguinte, com `git diff ccae44a -- lib/` vazio conferido antes) |
| P2 | `playlist_flow_test` 4/4, 101 s (`resultados/2026-09-29_P2_antes_playlist_flow_test.txt`) | **0/4**, 64 s — os 4 testes falham com `RangeError (length): Invalid value: Not in inclusive range 0..4: 5`, stack apontando `criar_playlist.dart:167` (`resultados/2026-09-29_P2_depois_playlist_flow_test.txt`) | exceção no `build` do `ListView.builder`, reportada pelo framework em qualquer teste que abre a tela | `60cbaff` (revertido no commit seguinte, com `git diff ccae44a -- lib/` vazio conferido antes) |

Registro do L4:
- O baseline precisou de dois runs: o primeiro (run 3 do login) foi vermelho no `lib/` limpo por um defeito de timing do próprio teste, corrigido antes de aplicar o bug. O "depois" usa exatamente o código de teste do "antes".
- **O que o teste diz e o que não diz.** A falha registra que a `TelaInicialScreen` não apareceu em 20 s. Ela **não** diz que a `CadastroScreen` apareceu no lugar — o teste não afirma nada sobre para onde o app foi. Um operador lendo só a saída sabe que o login não chegou ao destino, não sabe o sintoma (abrir o Cadastro). Isso é relevante para comparar com o que um tester manual veria (coluna "O que o tester vê" da tabela).
- Os outros 4 testes (E1..E4) continuam verdes com o bug, como esperado: L4 só afeta o caminho de sucesso.
- `flutter analyze` acusa `unused_import: 'tela-inicial.dart'` em `lib/login.dart` com o bug aplicado. Ficou assim de propósito: é o rastro que um desenvolvedor real deixaria, e um aviso de lint não é o que a Fase 3 mede.
- Custo: 3 execuções do fluxo (2 de baseline + 1 com o bug), ~2 min de máquina.

Registro do C3 (2026-09-29):
- Baseline verde de primeira (6/6). AVD e emuladores tinham morrido com a sessão e subiram de novo (AVD em 25 s); o primeiro Gradle do dia levou 39,5 s.
- Com o bug, mesmo código de teste: 5/6. E1..E5 seguem verdes (validação local, não passam pela gravação). O fluxo completo chega à `TelaInicialScreen` — o cadastro, os gêneros e a navegação funcionam — e falha na saudação: o app gravou o e-mail em `usuarios/{uid}.nome`, então a tela mostra "Cadastro-<timestamp>@sintonize.test, essa é a nossa recomendação..." no lugar de "João Silva, ...".
- **O que o teste diz e o que não diz, de novo.** A saída registra que o texto esperado não apareceu em 20 s; **não diz o que apareceu no lugar**. O `pumpAte` só sabe procurar o esperado. Um tester manual veria o e-mail na saudação de cara (coluna "O que o tester vê"); a saída automatizada exige que alguém abra o app para descobrir o sintoma.
- **O segundo ponto de detecção nunca rodou.** O teste tinha duas asserções capazes de pegar o C3 (a saudação e `doc['nome'] == 'joão silva'` no Firestore), mas um `testWidgets` para na primeira falha, então a leitura do Firestore não aconteceu. Na prática, um teste E2E longo dá **um** diagnóstico por execução.
- `flutter analyze` não acusa nada com o C3 aplicado (só os 8 `info` pré-existentes de `cadastro.dart`): ao contrário do L4, este bug não deixa rastro de lint.
- Custo: 2 execuções do fluxo (1 de baseline + 1 com o bug), ~2,5 min de máquina.

Registro do P2 (2026-09-29):
- Baseline verde de primeira (4/4, 101 s — o Gradle levou 50 s porque o `lib/` tinha acabado de voltar ao estado de `ccae44a`). Emuladores Firebase subiram desta vez por `Start-Process` desacoplado, porque a tarefa anterior tinha sido morta pelo limite de 10 min da ferramenta.
- Com o bug, mesmo código de teste: **0/4**. É o único dos três em que **todos** os testes do fluxo caem, porque o defeito está no `build` da lista: qualquer teste que chega à `CriarPlaylistScreen` com músicas tropeça nele antes de fazer o que ia fazer. L4 e C3 derrubaram 1 teste cada.
- **Aqui o teste diz exatamente o que aconteceu.** Ao contrário de L4 e C3, a saída traz a exceção com tipo, valor e arquivo:linha (`_CriarPlaylistScreenState.build.<anonymous closure> (package:sintonize/criar_playlist.dart:167:55)`). Um bug CRASH dá diagnóstico de graça; os SILENT só dizem "o esperado não veio". Isso é a diferença central entre os dois tipos para a análise.
- O valor do erro acompanha o tamanho da lista: `0..4: 5` com as 5 músicas e `Only valid value is 0: 1` com a pesquisa filtrando para 1 item. O bug estoura em qualquer lista não vazia, não só na do seed. Com a lista vazia (`_musicasFiltradas.isEmpty`) a tela mostra o `CircularProgressIndicator` e o `ListView` nem é construído — o bug fica invisível.
- O `RangeError` aparece 10 vezes na saída para 4 testes: a lista é reconstruída a cada `setState` (pesquisa, seleção) e cada rebuild lança de novo. O reporter do `flutter test` chega a reatribuir exceções tardias ao nome de um teste anterior (linhas `00:19 ... lista carrega as 5 músicas do seed` reaparecendo depois de o teste já ter fechado) — ao ler a saída, contar pelos `[E]`, não pelas exceções.
- Em debug o app mostra o bloco vermelho de erro no fim da lista (coluna "O que o tester vê"); o teste não precisou de asserção nenhuma para pegar — o framework reporta exceções não tratadas no `build` como falha do teste em curso.
- Sem rastro de lint (só os 6 `info` pré-existentes).
- Custo: 2 execuções do fluxo, ~3 min de máquina.

| ID | Fluxo | Arquivo:linha | Alteração | Tipo | O que o tester vê |
|---|---|---|---|---|---|
| L4 | login | `lib/login.dart:36` | `TelaInicialScreen()` → `CadastroScreen()` | SILENT | depois de um login correto, abre a tela de Cadastro |
| C3 | cadastro | `lib/cadastro.dart:149` | `_nomeController.text` → `_emailController.text` | SILENT | a saudação da tela inicial (`tela-inicial.dart:241`) mostra o e-mail no lugar do nome. O fluxo termina lá: Cadastrar → Gêneros → Confirmar (`generos-cadastro.dart:62`) |
| P2 | playlist | `lib/criar_playlist.dart:165` | `itemCount: _musicasFiltradas.length` → `length + 1` | CRASH | com as 5 músicas do seed, o item de índice 5 lança `RangeError`: bloco vermelho no fim da lista em debug, cinza em release |

## Verificação de infraestrutura 2026-09-29 — aceitação de tamanho (não é rodada)

Pergunta: o maior prompt (`FASE3-E2E-COT-03_playlistFlow.md`, corpo de 55.879
caracteres / 1.547 linhas entre os dois `---`) é aceito pelos dois modelos e
a resposta começa? Fora do protocolo, em conversas descartáveis, sem gerar
dado: só aceitou/recusou, mensagem de limite e print. Nenhuma resposta foi
guardada.

| Modelo | Sessão | Entrada aceita? | Mensagem de limite | Resposta começou? | Estado final | Print |
|---|---|---|---|---|---|---|
| Gemini | logada, Pro, seletor fixado em **3.8 Flash** (estava em Flash-Lite; trocado antes de colar) | **sim** — 57.525 caracteres no editor, início e fim conferidos | nenhuma | **sim** — após ~16 s: "Abaixo estão as análises detalhadas do fluxo…", "1. Análise do Fluxo", "2. Identificação das Dependências" | segundos depois a resposta foi **substituída pela recusa genérica** "Sou apenas uma IA com base em texto. Não tenho como ajudar nisso." — o padrão já registrado na réplica quando o envio parte da automação (Claude in Chrome), que some ao reenviar com um espaço no fim e **não conta como dado do modelo** | `evidencias/infra/2026-09-29_gemini_38flash_cot03_estado-final.jpg` (estado final; o estado intermediário com a resposta foi visto, não salvo) |
| ChatGPT | executada pelo autor, à mão; **sessão a confirmar pelo autor (deslogada?)** | **sim** | nenhuma | **sim** — resposta completa, com os 5 passos do CoT e um arquivo de teste | resposta completa | **pendente (autor)** |

Leituras:

- **Tamanho não é impedimento em nenhum dos dois.** O maior dos 9 prompts
  entrou inteiro e obteve resposta nos dois modelos.
- **Gemini:** a recusa genérica é artefato do envio automatizado, não do
  tamanho — a resposta real já tinha começado quando ela apareceu. Nas
  rodadas, colar à mão (ou reenviar com espaço no fim) e registrar a
  ocorrência, como na réplica. Uma repetição com o espaço no fim, salvando
  os dois prints, fica a critério do autor.
- **ChatGPT:** a resposta trouxe marcadores de citação de fontes externas
  ("Documentação Flutter", "Firebase"), ou seja, **o modelo consultou a web
  por conta própria**. Isso é uma condição de sessão a registrar por rodada
  (a Fase 2 não tinha esse comportamento observado) — o template ganha o
  campo "Consultou fontes externas?" antes da rodada 1.
- Ocorrência operacional: entre carregar a área de transferência com o prompt
  e colar no Gemini, algo (provavelmente a extensão) a sobrescreveu com
  "109411879"; o conteúdo foi recarregado e conferido por script antes da
  colagem que valeu. Conferir sempre o tamanho do texto no editor antes de
  enviar.

Duas conversas descartáveis ficaram nos históricos das contas (Gemini:
"Testes End-to-End (E2E) com Flutter I…"); nada foi apagado das contas.

## Verificação de infraestrutura 2026-10-02 — aceitação de tamanho do FS-03 (não é rodada)

Repetição da verificação com o maior dos 9 prompts de fato: a medição em
`prompts_prontos/README.md` mostrou que o maior é o **FS-03** (56.878
caracteres / 3.783 palavras / 1.598 linhas), não o COT-03 (55.879). Mesmas
regras: conversas descartáveis, só aceitou/recusou + mensagem de limite +
print; nenhuma resposta foi guardada nem usada. Antes do envio, o texto do
editor foi conferido por script (tamanho, início e fim). Prints em
`evidencias/infra/2026-10-02_*`.

| # | Modelo | Sessão | Envio | Entrada aceita? | Limite | Resposta começou? | Estado final |
|---|---|---|---|---|---|---|---|
| 1 | ChatGPT | **deslogada** (botões "Entrar"/"Cadastre-se grátis" no print) | automatizado (Claude in Chrome, Ctrl+V) | sim, 56.878 car. no editor | nenhum | sim | **resposta completa**, teste em `integration_test/fase3/criar_playlist_test.dart`; **sem** marcadores de fontes externas desta vez |
| 2 | Gemini | logada, Pro, seletor trocado de Flash-Lite para **3.8 Flash** antes de colar | automatizado | sim | nenhum | sim — a geração ocorreu (o título da conversa virou "Como gerar um teste end-to-end no Flutter… Aqui está o código completo do teste") | **substituída pela recusa genérica** "Sou apenas uma IA com base em texto. Não tenho como ajudar nisso." |
| 3 | Gemini | mesma conversa do #2 | automatizado, **com espaço no fim** (a contramedida de 2026-09-29) | sim | nenhum | sim — "Aqui está a implementação completa do teste end-to-end com integration_test…" chegou a aparecer (print) | **substituída por outra recusa genérica**, com texto diferente: "Não posso te ajudar com isso. Sou apenas um modelo de linguagem e não tenho essas informações ou habilidades necessárias." |
| 4 | Gemini | conversa nova, 3.8 Flash | **manual** (o autor colou da área de transferência carregada por script) | sim | nenhum | sim | **resposta completa**, com um `testWidgets` para o fluxo; ficou |

Leituras:

- **Tamanho não é impedimento** em nenhum dos dois modelos: o maior prompt
  entra inteiro e os dois geram resposta. Confirma 2026-09-29.
- **Gemini rejeita o envio automatizado, e o espaço no fim não resolve.**
  Nas duas tentativas automatizadas a resposta começou e foi descartada;
  na manual, ficou. Decisão: **nas 18 rodadas Gemini da Fase 3 a colagem é
  manual pelo autor**, a partir da área de transferência carregada e
  conferida por script; isso entra como condição de sessão no doc de cada
  rodada. No ChatGPT o envio automatizado continua válido (foi assim na
  reexecução e passou aqui).
- **ChatGPT não consultou a web** desta vez. O campo "Consultou fontes
  externas?" do template continua, porque em 2026-09-29 consultou; é uma
  variável por rodada, não uma constante.
- Ocorrência operacional, repetida: a área de transferência foi
  sobrescrita por texto de outro aplicativo entre o carregamento e a
  primeira colagem no ChatGPT (um aviso de sistema sem relação); a primeira
  colagem foi descartada, o conteúdo recarregado e conferido no editor
  antes do envio que valeu. Conferir o editor por script antes de cada
  envio é regra, não precaução.

Três conversas descartáveis ficaram nos históricos (ChatGPT deslogado não
guarda); nada foi apagado.

## Plano de rodadas (opção B) — 18 por modelo, 36 no total

Mesmos 9 prompts (`prompts_prontos/`) para as duas condições e os dois
modelos. O que muda por rodada é o modelo, a estratégia e o `lib/` do
worktree onde o teste gerado roda.

| Bloco | Ordem | Rodadas | Worktree / `lib/` |
|---|---|---|---|
| 1 — ZS | 1–6 ChatGPT, 7–12 Gemini | por modelo: 01_loginFlow, 02_cadastroFlow, 03_playlistFlow limpas; depois L4-ZS, C3-ZS, P2-ZS | limpas em `sintonize-fase3` (`fase3-e2e`); L4 em `eb14334`, C3 em `20edaaa`, P2 em `60cbaff` |
| 2 — FS | 13–18 ChatGPT, 19–24 Gemini | idem com FS | idem |
| 3 — COT | 25–30 ChatGPT, 31–36 Gemini | idem com COT | idem |

Por que ZS nos dois modelos primeiro: se a ZS já mostrar o padrão, os blocos
seguintes confirmam ou refutam com o mesmo par de modelos; e o bloco 1 revela
cedo qualquer problema de infraestrutura (worktrees dos bugs, seed, prints)
antes de gastar as rodadas FS/COT.

Contagem: 9 limpas + 9 com bug por modelo = 18; 36 no total. As 9 limpas são
o grupo de controle (o teste gerado também precisa funcionar sem bug); as 9
com bug são as que recebem a codificação manual-first de `roteiro_manual.md`.
Não há `_REEXEC` previsto: se um prompt precisar de correção, a rodada é
refeita como rodada nova com sufixo, como na Fase 2, e a original fica.

### Estimativa de tempo por rodada (a partir dos números medidos)

Medidas em `analise/custo_e_referencia.md`. Por **execução** do teste gerado:
reiniciar emuladores (~12 s) + seed (`seed_test`, ~25–30 s com Gradle
incremental) + `flutter test` do arquivo (Gradle incremental 11–23 s + teste
20–45 s + instalação 1 s) ≈ **1,5–2 min de máquina**, mais o print quando há
falha. Por **iteração de conversa** (colar, esperar a resposta, extrair o
código, salvar): ~4–6 min de operação, pelo que a Fase 2 levou.

| Cenário | Iterações (geração + reparos) | Tempo estimado |
|---|---|---|
| Verde de primeira | 1 | ~7–9 min |
| 1 reparo | 2 | ~13–16 min |
| 3 reparos (teto) | 4 | ~25–32 min |

Com a média da Fase 2 (perto de 1,5 reparo por rodada), **~15 min por rodada
→ ~9 h para as 36**, entre ~4,5 h (tudo verde de primeira) e ~19 h (tudo no
teto). Custos fixos fora disso: AVD 25–132 s por sessão; emuladores 12 s;
**primeiro Gradle em cada worktree novo ≈ 6 min** (3 worktrees de bug → ~18
min uma vez), e ≈ 40–50 s sempre que o `lib/` de um worktree muda.

Regras operacionais que saíram das medições: um `flutter test` por comando;
emuladores desacoplados do terminal da sessão; seed limpo antes de **cada**
execução (o emulador acumula usuários e playlists); print da tela na falha
antes de tocar em qualquer coisa.

## Montar o ambiente numa máquina nova (Windows)

Nada de SDK, Node ou emulador vai no repositório. Numa máquina nova, reinstalar nesta ordem:

1. **Flutter 3.41.6 stable e Java 17+.** A máquina original usou Java 21.
2. **Android SDK sem Android Studio**, em `%LOCALAPPDATA%\Android\Sdk`:
   - Use o **cmdline-tools 22.0** (`commandlinetools-win-15859902_latest.zip`) em `cmdline-tools\latest`. **Não use o 23.0:** nele, `sdkmanager --licenses` só responde "no longer needed" e o `flutter doctor` fica em "Android license status unknown".
   - Defina `ANDROID_HOME` (variável de usuário) e rode `flutter config --android-sdk <caminho>`.
   - Pacotes: `platform-tools`, `emulator`, `platforms;android-34`, `platforms;android-36`, `build-tools;35.0.0`, `build-tools;36.0.0` e `system-images;android-34;google_apis;x86_64`. O `flutter doctor` exige o SDK 36 e o build-tools.
   - **Pegadinha:** chamado pelo Git Bash, o `sdkmanager.bat` quebra os nomes no `;`. Ponha os nomes num arquivo e use `sdkmanager --package_file=<arquivo>`, ou chame pelo PowerShell/cmd.
   - Licenças: `yes | sdkmanager --licenses` e `flutter doctor --android-licenses`.
3. **AVD:** `avdmanager create avd -n tcc_e2e -k "system-images;android-34;google_apis;x86_64" -d pixel_6`.
4. **Aceleração de hardware (exige admin):** ative "Plataforma do Hipervisor do Windows" em Recursos do Windows **e reinicie**. A outra opção é instalar o driver AEHD. Confira com `%ANDROID_HOME%\emulator\emulator.exe -accel-check`, que tem de dizer que a aceleração está disponível.
5. **Node LTS e Firebase CLI:** a máquina original usou Node v24.21.0 (zip oficial em `%LOCALAPPDATA%\nodejs`, no PATH do usuário) e `npm i -g firebase-tools` (15.31.0).
   - **Não use o binário standalone** (`firebase-tools-instant-win.exe`): na 15.31.0, ele entra no modo "welcome" e quebra, e mesmo contornado falha com `ERR_REQUIRE_ESM` em qualquer comando além de `--version`.
   - O aviso do npm sobre install scripts de `re2`/`protobufjs` não impediu os emuladores de subir.
6. **Confira:** `flutter doctor -v` (Android toolchain ✓, "All Android licenses accepted"), `flutter emulators` (lista `tcc_e2e`) e `firebase --version`.

## Estado em 2026-10-02 (fim do dia) — rodada 1 iniciada, não concluída (histórico)

> Superado em 2026-10-03: a tentativa descrita aqui foi movida para `_abortadas/`
> e a rodada 1 foi refeita na segunda máquina — ver "Estado em 2026-10-03".
> O texto abaixo é mantido como registro.

Onde parou, para retomar (na máquina original, `DellT4i51`, ou em outra):

- **Rodada 1 (`FASE3-E2E-ZS-01_loginFlow`, ChatGPT, limpa): geração feita,
  execução pendente.** Doc em `rodadas/chatgpt/FASE3-E2E-ZS-01_loginFlow.md`
  (metadados, controles de versão, resposta completa); teste gerado, sem
  edição, em `integration_test/fase3/chatgpt/login_zs_test.dart`; prints em
  `evidencias/chatgpt/`. O que falta: seed, `flutter test`, saída em
  `resultados/chatgpt/`, reparo se houver. **A conversa é deslogada e vive só
  na aba do Chrome da máquina original.** Para continuar nela: não fechar o
  Chrome; terminar o download do NDK 28.2 (`sdkmanager "ndk;28.2.13676358"`,
  estava em andamento); seed; `flutter test integration_test/fase3/login_zs_test.dart -d emulator-5554`
  no worktree `Desktop\sintonize-fase3`. Para continuar **em outra máquina**:
  mover o doc e o teste desta tentativa para `rodadas/chatgpt/_abortadas/`
  (e `integration_test/fase3/chatgpt/_abortadas/`), e refazer a rodada 1 em
  conversa nova, com os controles (a), (b) e (c).
- **Máquina original, estado do ambiente:** AVD sobe (WHPX usável após
  reiniciar o Windows; o AVD exige 12.288 MB livres em disco); emuladores
  Firebase sobem; **o Gradle recusa caminhos com acento** — a execução é nos
  worktrees ASCII `Desktop\sintonize-fase3` (detached no commit da ponta de
  `fase3-e2e`, `lib/` limpo) e `Desktop\sintonize-fase3-{L4,C3,P2}` (nos
  hashes dos bugs). O checkout que commita continua
  `Desktop\Repositórios\sintonize-tcc`. **O NDK 28.2 não estava instalado**
  (`ndkVersion = flutter.ndkVersion`) e a rede desta máquina baixou ~190 MB
  em 30 min; o primeiro build só termina depois dele.
- **Controles do dia (válidos para qualquer rodada ChatGPT de 2026-10-02):**
  autodeclaração "GPT-5.6 Luna" (2 perguntas, prints em `evidencias/chatgpt/`);
  Help Center, "GPT-5.6 and GPT-6 Pro in ChatGPT", consultado em 2026-10-02:
  deslogado e Free/Go recebem GPT-5.6 Luna (print salvo). Nenhuma consulta a
  fontes externas na resposta da rodada 1.
- **Ocorrências de serviço/ambiente registradas:** uma tentativa de envio do
  ZS-01 devolveu "O ChatGPT está com problemas temporários", sem resposta nem
  ID de conversa (print; não é rodada); a área de transferência foi
  sobrescrita por outro aplicativo duas vezes no dia (sempre conferir o editor
  por script antes de enviar); 11 min 33 s de build perdidos no checkout com
  acento no caminho.
- **Template:** corrigido o caminho de execução (`integration_test/fase3/`,
  onde o import `'../firebase_test_helper.dart'` do prompt resolve); a cópia
  arquivada vai para `integration_test/fase3/<modelo>/`.
- **Pendente do autor:** print da conversa manual do Gemini com o FS-03
  (verificação de infraestrutura de 2026-10-02, linha 4), em
  `evidencias/infra/2026-10-02_gemini_38flash_fs03_manual_resposta-completa.jpg`.

## Estado em 2026-10-03 — rodada 1 concluída na segunda máquina (1/36)

Decisão do autor em 2026-10-03: **o trabalho segue na segunda máquina
(`DESKTOP-6ETPO2H`)**. Consequências, aplicadas nesta data:

- **A tentativa de 2026-10-02 virou `_abortadas/`.** Doc em
  `rodadas/chatgpt/_abortadas/FASE3-E2E-ZS-01_loginFlow_TENTATIVA-1.md`, teste
  em `integration_test/fase3/chatgpt/_abortadas/login_zs_test.dart`. Geração
  válida, execução nunca feita, conversa perdida com a aba da máquina original.
  Não conta. Os prints de 2026-10-02 ficam em `evidencias/chatgpt/` como estão.
- **Rodada 1 (`FASE3-E2E-ZS-01_loginFlow`, ChatGPT, limpa) refeita por inteiro
  em conversa nova:** 9 testes gerados, **8/9 na geração e 8/9 no final**;
  3 iterações de reparo, **(B) nas três, sem nenhuma alteração do teste**
  pelo modelo (arquivo final byte-idêntico ao gerado). Auditoria: **Erro de
  teste** (timing — o 8º teste do mesmo arquivo passa com a mesma asserção
  após um segundo `pumpAndSettle`); o `setState() called after dispose()` que
  o modelo aponta é real e pré-existente em `lib/tela-inicial.dart:161`
  (idêntico ao `main`), mas não causa a falha e não é bug plantado. Doc:
  `rodadas/chatgpt/FASE3-E2E-ZS-01_loginFlow.md`; transcrição literal em
  `..._transcricao/`; saídas em `resultados/chatgpt/`; teste em
  `integration_test/fase3/chatgpt/login_zs_test.dart`.
- **Controles do dia (ChatGPT, 2026-10-03):** autodeclaração "GPT-5.6 Luna"
  (print `evidencias/chatgpt/2026-10-03_chatgpt_pergunta_versao_deslogado.jpg`);
  Help Center "GPT-5.6 and GPT-6 Pro in ChatGPT", atualizado em 2026-10-01,
  consultado em 2026-10-03: deslogado e Free/Go recebem GPT-5.6 Luna (print
  `2026-10-03_openai_helpcenter_gpt56_luna.jpg`). Concordam. Nenhuma consulta
  a fontes externas nas 4 respostas.
- **Sessão:** o Chrome desta máquina estava **logado** no ChatGPT (conta Go).
  O autor fez logout antes dos controles e da rodada; a condição deslogada foi
  mantida. Conferir isso antes de cada sessão nesta máquina.
- **Precedente aplicado — (B) sem patch:** quando o modelo declara (B) e não
  entrega teste, o arquivo fica inalterado e é **reexecutado** com seed limpo;
  o resultado vale como o da iteração (como em `FASE2-ICRASH-ZS`, reexecução
  ChatGPT, iteração 3). As três iterações desta rodada seguiram isso.
- **Achado de método — print do AVD na falha:** o `screencap` "logo após o
  `flutter test` terminar em falha" só captura a tela da falha se o teste que
  falha for o último da suíte. Quando falha o 1º de 9, o app já fechou e o
  print mostra a home do Android (os 4 prints desta rodada). Mantidos como
  registro fiel. **Pendente de decisão do autor:** disparar o `screencap` em
  paralelo ao `flutter test`, na primeira linha de falha da saída, ou aceitar
  que o print só vale para falha no último teste. Editar o teste gerado para
  tirar print está fora do protocolo.
- **Tempos nesta máquina (Gradle em cache):** seed ~40 s; execução do teste
  gerado 39–43 s (Gradle 15–18 s + 16–18 s de teste); reinício dos emuladores
  ~30 s. Rodada inteira (controles, geração, 3 reparos, 4 execuções, doc):
  ~45 min, dos quais ~10 min de máquina.
- **Progresso: 1/36.** Próxima: rodada 2, `FASE3-E2E-ZS-02_cadastroFlow`,
  ChatGPT, limpa, mesmo worktree.
- **Rodada 2 (`FASE3-E2E-ZS-02_cadastroFlow`, ChatGPT, limpa), mesma noite:**
  1/4 na geração; reparo 1 (A) com arquivo novo → 2/5; reparo 2 (A) só com
  trecho "conceitual" e pedido do arquivo (não respondido) → inalterado, 2/5;
  reparo 3 (B) sem código → **2/5 final**. Auditoria: **erro de teste**
  (asserção da tela de gêneros antes da navegação que segue as chamadas ao
  Firebase, a mesma falha de espera da rodada 1) e um caso de **ambiente**
  (toque em "Cadastrar" com o teclado aberto, assinatura `Offset(205.7, 748.3)`
  igual à da referência em 2026-09-28). O (B) final está errado.
- **Duas tentativas da ZS-02 interrompidas pelo serviço** antes da conversa
  válida: o ChatGPT devolveu só um parágrafo de preâmbulo e a página marcou
  "Chat interrompido inesperadamente" (região aria-live). Uma por automação,
  uma à mão. Não contam; ver
  `rodadas/chatgpt/_abortadas/FASE3-E2E-ZS-02_cadastroFlow_tentativas-interrompidas.md`.
  **Regra adotada:** se a mesma rodada for interrompida 3 vezes, parar e o
  autor decide (esperar, ou condição logada pelo critério de saída), para não
  repetir até dar certo.
- **Envio manual a partir da rodada 2:** o Ctrl+V da automação parou de colar
  no composer. Prompt e reparos vão para o clipboard por script; o autor cola
  e envia; a resposta é obtida pelo botão "Copiar resposta" (a cópia por
  seleção perde o Markdown; o código das duas é comparado).
- **Seed também confere o Auth:** os testes de cadastro criam contas; antes
  de cada execução, além de 1 doc em `usuarios` e 5 em `musica`, conferir 1
  conta no Auth emulator (`accounts:query`).
- **Rodada 3 (`FASE3-E2E-ZS-03_playlistFlow`, ChatGPT, limpa), 2026-10-03/04:**
  não compila na geração (falta `material.dart`) → reparo 1 (A) → 1/2 →
  reparo 2 (A)+(B) → **2/2, primeiro verde da Fase 3**. O verde veio trocando
  a asserção da saudação pós-login (falha de espera, a mesma da rodada 1) por
  `find.text('Minha Conta')`; registrado como redução do que o login verifica.
  O reparo 2 caiu em 2026-10-04 na conversa aberta em 2026-10-03; o autor
  afirmou "a versão é a mesma"; o Help Center não foi consultado em 10-04.
- **ChatGPT, bloco ZS limpo concluído (3/3):** ZS-01 8/9, ZS-02 2/5, ZS-03 2/2.
  Padrão: em E2E, o ZS do ChatGPT erra a espera por estado assíncrono
  (Firestore) nas três; só na ZS-03 o reparo chegou ao verde, e mudando a
  asserção.
- **Progresso: 3/36.** Próximas do bloco 1 (ChatGPT): L4-ZS, C3-ZS, P2-ZS, nos
  worktrees dos hashes dos bugs (`git worktree add ../sintonize-fase3-L4 eb14334`,
  idem `-C3 20edaaa`, `-P2 60cbaff`; ainda não criados nesta máquina).

## Estado em 2026-10-04 — rodadas com bug do bloco ZS (ChatGPT), autor ausente

- **Worktrees dos bugs criados nesta máquina** (detached): `Desktop\sintonize-fase3-L4`
  (`eb14334`), `-C3` (`20edaaa`), `-P2` (`60cbaff`). Helpers e `pubspec.lock`
  idênticos aos da ponta; primeiro build em 40–55 s cada (Gradle em cache).
- **Controles de versão:** autodeclaração de 2026-10-04 feita ("GPT-5.6 Luna",
  print). Em seguida o autor dispensou repetir o controle e o Help Center:
  "não precisa ficar sempre pedindo auto declaração e indo no help center. a
  versão é a mesma". Isso **diverge** da regra (b) do `CLAUDE.md` (fonte
  externa a cada dia); a divergência fica registrada aqui, não resolvida.
- **Envio voltou a ser automatizado** (Claude in Chrome) com o autor ausente:
  o Ctrl+V da automação voltou a funcionar; editor conferido por DOM antes de
  cada envio.
- **Correção:** a mensagem "Chat interrompido inesperadamente" (região
  aria-live) aparece também em respostas completas; não prova interrupção.
  A nota das tentativas da ZS-02 foi corrigida (motivo passa a "resposta sem
  código, causa não determinada").
- **Rodada 4 (`FASE3-L4-ZS`):** 4/5 em todas as execuções; (A), (B), (B);
  **Capturou** (a `TelaInicialScreen` não aparece em 10 s).
- **Rodada 5 (`FASE3-C3-ZS`):** não compila (sem `material.dart`) → 1/4 → 3/4
  → 3/4; (A), (A), (B); **Não viu** — o fluxo completo usa o nome "Usuário
  E2E", recusado pelo validador (dígito), e nunca chega à asserção
  `dados['nome']` que capturaria o C3. A resposta de geração citou
  "Documentação Flutter" (fontes externas).
- **Rodada 6 (`FASE3-P2-ZS`): PENDENTE, decisão do autor.** Três tentativas
  seguidas (00:48–00:52) com resposta só de preâmbulo, sem código; nenhuma
  execução. Regra da 3ª tentativa aplicada. Ver
  `rodadas/chatgpt/_abortadas/FASE3-P2-ZS_tentativas-sem-codigo.md`, que traz
  também o padrão da noite por tamanho de prompt.
- **Ordem do plano alterada (autor ausente):** o bloco ZS do Gemini (rodadas
  7–12) exige colagem manual pelo autor (decisão de 2026-10-02); para não parar,
  a execução automatizada seguiu para o bloco FS do ChatGPT (rodadas 13–18).
  Nenhuma rodada depende da ordem; a mudança só antecipa as do ChatGPT.
- **Rodada 13 (`FASE3-E2E-FS-01_loginFlow`):** 1/2 nas 4 execuções; (B) ×3
  sem arquivo. Erro de teste (afirma a ausência da `LoginScreen` durante a
  transição) e, numa execução, o `setState` após `dispose` pré-existente.
- **Rodada 16 (`FASE3-L4-FS`):** 1/2 nas 4 execuções; (B) ×3; **Capturou na
  geração** (a `TelaInicialScreen` não aparece). O reparo 3 trocou o teste de
  sucesso por uma versão diagnóstica (aplicada por script): autenticado, sem a
  tela de destino.
- **Rodada 14 (`FASE3-E2E-FS-02_cadastroFlow`):** não compila → 0/1 → 0/1 →
  0/1; (A) ×3. O reparo 3 achou o nome com dígito ("Usuário E2E", o mesmo da
  C3-ZS); o teste final chega à tela de gêneros e falha num item fora da
  parte visível da lista preguiçosa ("Reggae").
- **Rodada 17 (`FASE3-C3-FS`):** não compila → 0/1 ×3; (A), (A), (B);
  **Não viu** — de novo o nome "Usuário E2E" recusado pelo validador.
- **Rodada 15 (`FASE3-E2E-FS-03_playlistFlow`):** não compila → **1/1 verde**
  no reparo 1 (A), só com o import. Segundo verde da Fase 3.
- **Rodada 18 (`FASE3-P2-FS`):** não compila ×2 → 0/1 ×2; (A), (A), (B);
  **Capturou** — `RangeError` do P2 com `criar_playlist.dart:167`; (B) com
  diagnóstico correto. **Bloco FS do ChatGPT concluído (6/6).**
- **Rodada 25 (`FASE3-E2E-COT-01_loginFlow`):** 7/8 → **8/8 verde** no reparo 1
  (A), com o diagnóstico certo (`pumpAndSettle` não espera o Firestore). O
  verde espera a música recomendada e deixa de afirmar a saudação. Fontes
  externas na geração.
- **Rodada 28 (`FASE3-L4-COT`):** 6/7 nas 4 execuções; (A), (A), (B);
  **Capturou** — a asserção ficou cada vez mais direta até
  `find.byType(TelaInicialScreen)`, e o modelo passou a (B) como havia anunciado.
- **Rodada 26 (`FASE3-E2E-COT-02_cadastroFlow`):** não compila → 6/11 (A) →
  6/11 (B) → **4/11** (B), com o mesmo arquivo nas três últimas execuções. O
  toque em "Cadastrar" com o teclado aberto cai fora do alvo; o modelo atribuiu
  isso ao app (falso positivo). Fontes externas na geração.
- **Rodada 27 (`FASE3-E2E-COT-03_playlistFlow`):** não compila ×2 → 0/4 ×2;
  (A), (A), (B). Os 4 testes afirmam o título da tela um quadro após o toque; o
  (B) culpa o `setState()` após `dispose()`, que é efeito da falha (falso
  positivo). Fontes externas na geração. **Bloco COT limpo do ChatGPT concluído.**
- **Rodada 29 (`FASE3-C3-COT`): PENDENTE.** Iteração 0 com 1/11 (toques fora
  do alvo); o reparo 1 (57.926 caracteres) recebeu resposta vazia três vezes.
  Decisão do autor; ver `rodadas/chatgpt/FASE3-C3-COT_PENDENTE.md`.
- **Rodada 30 (`FASE3-P2-COT`):** não compila → 0/4 → não compila ×2; (A),
  (A), (A); **Não viu** — o teste parou no spinner antes da lista e o reparo 2
  quebrou a compilação. **Bloco COT do ChatGPT executado (5 de 6; C3-COT
  pendente).**
- **Pendências do ChatGPT ficam com o autor, em execução manual posterior:**
  P2-ZS e C3-COT. Ordem combinada: repetir uma vez em outro horário; se a
  C3-COT falhar de novo, filtro documentado da saída do terminal só acima de
  um limite de tamanho; se a P2-ZS falhar de novo, sessão logada ou "geração
  sem código". O prompt de geração não será reduzido. Detalhes no fim de
  `rodadas/chatgpt/FASE3-C3-COT_PENDENTE.md` e da nota da P2-ZS.
- **Próximo bloco: Gemini (rodadas 7–12, 19–24, 31–36), 0/18**, com colagem
  manual pelo autor.

## Estado em 2026-10-05 — bloco Gemini iniciado, máquina original

- **Ambiente da máquina original (`DellT4i51`) montado:** NDK 28.2 e CMake
  3.22.1 instalados; **o build exige JDK 17** (com o JDK 21 do sistema falha em
  `JdkImageTransform`/`jlink`) — Temurin 17 em `%LOCALAPPDATA%\jdk17`, usado só
  via `JAVA_HOME` nos comandos de teste; primeiro build 607 s, depois ~50 s.
  Disco: o AVD exige 12,3 GB livres; o autor liberou espaço.
- **Rodada 7 (`FASE3-E2E-ZS-01_loginFlow`, Gemini, limpa):** não compila → 2/5
  (A) → **5/5 verde** (A), com espera ativa por `pump` e sem reduzir asserções.
  Doc em `rodadas/gemini/`.
- **Tentativa 1 da rodada 7 abortada:** seletor em **Flash-Lite**, não 3.8
  Flash (print em `evidencias/gemini/`); nunca executada. Conferir o seletor
  antes de cada envio. O autor decidiu não tirar print do seletor por rodada; a
  confirmação dele fica registrada no doc.
- **Seed:** uma execução rodou sem seed (o `seed_test` falhou e o script seguiu)
  e foi descartada como `_INVALIDA-sem-seed`; a conferência 1/1/5 passou a
  bloquear a execução.
- **Progresso: Gemini 1/18.** Próxima: rodada 8, `FASE3-E2E-ZS-02_cadastroFlow`.

## Estado em 2026-10-05 (noite) — rodada 8, segunda máquina

- **Rodada 8 (`FASE3-E2E-ZS-02_cadastroFlow`, Gemini, limpa)**, executada na
  `DESKTOP-6ETPO2H` depois de puxar a rodada 7: 2/4 → 1/4 (A) → **4/4 verde**
  (A). O verde final **removeu a asserção da saudação** na `TelaInicialScreen`.
  O diagnóstico do reparo 1 (CEP sem hífen) contradiz o código: o campo tem
  `digitsOnly`, e as duas entradas dão o mesmo texto. Doc em `rodadas/gemini/`.
- O autor devolveu as respostas colando o texto na conversa com o Claude, não
  pelo clipboard. Mesmo formato de transcrição da rodada 7.
- **Rodada 9 (`FASE3-E2E-ZS-03_playlistFlow`, Gemini, limpa): 2/2 verde na
  geração, sem reparo.** É o primeiro verde de primeira da Fase 3 nos dois
  modelos. Usa só `pumpAndSettle()` depois do Firebase, a mesma espera que
  falhou nas rodadas 7 e 8; uma execução não prova estabilidade.
- **Bloco ZS limpo do Gemini completo.** **Progresso: Gemini 3/18.** Próximas:
  L4-ZS, C3-ZS, P2-ZS (Gemini), nos worktrees `sintonize-fase3-{L4,C3,P2}`.
- **Rodada 10 (`FASE3-L4-ZS`, Gemini, bug L4): 4/5 nas 4 execuções; (A),(A),(B)
  sem código; manual-first Capturou (iteração 0).** Os dois (A) são desmentidos
  pela própria saída (`LoginScreen` ausente antes da falha). O (B) acerta a
  classe e erra a causa (culpa os controllers no `build()`).
- **Ambiente:** o AVD estava com o diálogo "System UI isn't responding" aberto
  desde pelo menos a rodada 8 (aparece nos prints, que saem depois da suíte).
  Fechado com "Wait"; sem indício de efeito nos resultados. Conferir o AVD antes
  de cada rodada.
- **Rodada 11 (`FASE3-C3-ZS`, Gemini, bug C3): 1/3 → 1/3 → não compila →
  1/3; (A),(A),(A); manual-first Não viu.** O fluxo completo nunca passa do
  formulário: o nome "Novo Usuario E2E" tem dígito e o validador recusa. É o
  mesmo achado da C3-ZS do ChatGPT ("Usuário E2E"). Os reparos culpam o
  Dropdown, o ViaCEP e a espera.
- **Ocorrências:** o autor reenviou sem querer o reparo 3 (resposta guardada
  como `FORA_DO_PROTOCOLO_…`, não conta). Duas tentativas da iteração 3
  abortaram no seed por falha do AVD (ANR; depois "No tests were found"), com
  carga 11,5 após 2h18 ligado; o AVD foi reiniciado a frio. O script agora
  limita o seed a 5 min. **Reiniciar o AVD a cada ~2 h de uso.**
- **Progresso: Gemini 5/18.** Próxima: P2-ZS (prompt `FASE3-E2E-ZS-03`), no
  worktree `sintonize-fase3-P2`.

## Estado em 2026-10-06 — envio automatizado ao Gemini

- **Mudança de método, pedida pelo autor em 2026-10-06:** a partir da P2-ZS, o
  envio ao Gemini e a cópia das respostas passam a ser automatizados (Claude in
  Chrome), revendo a decisão de 2026-10-02 de colar à mão. O conteúdo enviado
  não muda. Controles por rodada: seletor aberto e conferido (print
  `evidencias/gemini/<ID>_seletor_38flash.png`), texto no editor conferido
  (tamanho, início e fim) antes de enviar, resposta conferida contra os textos
  de recusa genérica. Recusa genérica, se aparecer, é registrada e não conta
  como dado do modelo; o autor indicou editar a mensagem acrescentando um
  espaço ou ponto. As transcrições passam a ser o Markdown do botão "Copiar".
- **Rodada 12 (`FASE3-P2-ZS`, Gemini, bug P2): 0/2 nas 4 execuções, `RangeError`
  em `criar_playlist.dart:167`; (B),(B),(B) sem código; manual-first Capturou
  (iteração 0).** Primeira rodada da Fase 3 sem nenhum (A). O reparo 3 aponta o
  `itemCount` maior que a lista, a causa real, sem ter visto o bug. Nenhuma
  recusa genérica com a automação.
- **Bloco ZS do Gemini completo (6/6).** **Progresso: Gemini 6/18.** Próximo:
  bloco FS (rodadas 19–24): FS-01, FS-02, FS-03 limpas, depois L4-FS, C3-FS,
  P2-FS.
- **Rodada 19 (`FASE3-E2E-FS-01_loginFlow`, Gemini, limpa): 1/2 nas 4
  execuções; (B),(B),(B) corretos.** As asserções passam; o teste de sucesso cai
  depois de terminar pelo `setState()` após `dispose` pré-existente em
  `tela-inicial.dart:161` (o mesmo defeito da FS-01 do ChatGPT).
- **Rodada 20 (`FASE3-E2E-FS-02_cadastroFlow`) interrompida** antes da captura
  da resposta ao reparo 3 e da iteração 3 (a máquina descarregou; o autor
  decidiu parar). Estado e passos para retomar em
  `rodadas/gemini/FASE3-E2E-FS-02_PENDENTE.md`.
- **Automação, lições (2026-10-06):** com a janela do Chrome em segundo plano a
  página do Gemini para de atualizar e os timers são estrangulados; esperar a
  geração e recarregar a conversa antes de copiar; o clipboard do sistema só
  recebeu o texto por um botão injetado e clicado de verdade, logo depois de um
  screenshot; abas podem travar e precisar ser trocadas por uma nova. A
  instabilidade cresceu ao longo da sessão.
- **Progresso: Gemini 7/18 fechadas + FS-02 pendente.**
- **Rodada 20 retomada e fechada (mesmo dia, máquina original `DellT4i51`):
  0/1 → 0/1 → 0/1 → 1/1; (A),(B),(B) — ver doc.** Reparo 1 (A) corrige os
  toques fora do alvo; iterações 1 e 2 caem pelo `setState()` após `dispose` de
  `tela-inicial.dart:161` (reparos 2 e 3, (B), corretos); a iteração 3, com o
  mesmo arquivo, passou 1/1. Verde não conquistado por reparo: o defeito é
  intermitente e a iteração 3 rodou em outra máquina (confundidor registrado).
- **Máquina original, operação:** o build exige o worktree
  `Desktop\sintonize-fase3` (o caminho `Repositórios` tem caractere não-ASCII e
  o AGP recusa); `firebase` só sobe pelo PowerShell (no Git Bash o shim resolve
  caminho errado). Na cópia, o "Copiar" certo é o logo abaixo da última
  resposta — conferir início e fim do clipboard antes de gravar.
- **Progresso: Gemini 8/18.** Próximo: rodada 21, FS-03 playlistFlow.
- **Rodada 21 (`FASE3-E2E-FS-03_playlistFlow`, Gemini, limpa): 1/1 verde na
  geração, sem reparo** (máquina original, envio e cópia automatizados).
- **Bloco FS limpo do Gemini completo (3/3). Progresso: Gemini 9/18.** Próximo:
  L4-FS, C3-FS, P2-FS nos worktrees `Desktop\sintonize-fase3-{L4,C3,P2}`.
- **Rodada 22 (`FASE3-L4-FS`, Gemini, bug L4): 1/2 nas 4 execuções; (A),(A),(B)
  com causa errada; manual-first Capturou (iteração 0).** O primeiro envio do
  reparo 1 não chegou à conversa e foi refeito (o modelo o recebeu uma vez).
  **Progresso: Gemini 10/18.** Próximo: C3-FS.
- **Rodada 23 (`FASE3-C3-FS`, Gemini, bug C3): 0/1 nas 4 execuções, sempre em
  `nome` = e-mail; (A),(B),(A); manual-first Capturou (iteração 0).** O reparo
  1 voltou com o erro genérico do Gemini e foi reenviado com " ." (orientação
  do autor); não conta como iteração. **Progresso: Gemini 11/18.** Próximo:
  P2-FS.
- **Rodada 24 (`FASE3-P2-FS`, Gemini, bug P2): não compila → 0/1 ×3 com
  `RangeError` em `criar_playlist.dart:167`; (A),(A),(A); manual-first Capturou
  (iteração 1).** A geração teve recusa genérica (reenviada com " .") e depois
  veio com o código cortado e recomeçado dentro do mesmo bloco — usado como
  veio, não compilou.
- **Bloco FS do Gemini completo (6/6). Progresso: Gemini 12/18.** Próximo:
  bloco COT (rodadas 31–36): COT-01, COT-02, COT-03 limpas, depois L4-COT,
  C3-COT, P2-COT.
- **Rodada 31 (`FASE3-E2E-COT-01_loginFlow`) interrompida** antes da iteração
  2 (4/5 → 4/5; reparos (B) com código e (A)): a execução travou no seed por
  falta de memória na máquina original e o autor decidiu parar. Estado e passos
  em `rodadas/gemini/FASE3-E2E-COT-01_PENDENTE.md`. **Progresso: Gemini 12/18 +
  COT-01 pendente.**
- **Rodada 31 retomada e fechada: 4/5 nas 4 execuções; (B),(A),(B).** Iterações
  2 e 3 caem pelo `setState()` após `dispose` de `tela-inicial.dart:161`
  (reparo 3 correto, sem código). Nota `_PENDENTE` removida. **Progresso:
  Gemini 13/18.** Próximo: COT-02 cadastroFlow.
- **Rodada 32 (`FASE3-E2E-COT-02_cadastroFlow`) interrompida** depois da
  iteração 1 (0/4 → 1/4; reparo 1 (A)), por troca de máquina. Estado e passos
  em `rodadas/gemini/FASE3-E2E-COT-02_PENDENTE.md`.
- **Para continuar em outra máquina:** os scripts de automação usados nas
  rodadas 20–32 estão em `scripts_automacao/` (com README). Faltam no Gemini:
  COT-02 (pendente), COT-03, L4-COT, C3-COT, P2-COT; no ChatGPT, P2-ZS e
  C3-COT (execução manual do autor). Na máquina original: build só no
  worktree `Desktop\sintonize-fase3` (caminho com acento quebra o AGP),
  `firebase` só via PowerShell, 7,8 GB de RAM (encerrar daemons do Gradle e
  apps pesados; o seed já travou por falta de memória).
- **Progresso: Gemini 13/18 + COT-02 pendente.**

## Estado em 2026-10-06 (noite) — retomada na segunda máquina

- **Rodada 32 (`FASE3-E2E-COT-02_cadastroFlow`, Gemini, limpa) retomada e
  fechada na segunda máquina (`DESKTOP-6ETPO2H`), na mesma conversa:
  0/4 → 1/4 → 1/4 → 3/4; (A),(A),(A), sempre com arquivo completo.** A falha
  que sobra (e-mail já cadastrado) é determinística: o `_CEPInputFormatter`
  põe o hífen, o `onChanged` do CEP consulta o ViaCEP, que devolve `erro` para
  `50000000`, e a SnackBar "CEP não encontrado" aparece antes da do Auth; o
  teste pega a primeira. Isso prova a hipótese que ficou aberta na ZS-02 do
  Gemini. O reparo 3 dá a classe certa com a causa errada. Nota `_PENDENTE`
  removida. Uma execução de auditoria (`--name "Cenário 3"`, arquivo
  inalterado) fica registrada fora do protocolo; o print pós-suíte não captura
  a SnackBar porque o app já foi encerrado.
- **Operação nesta máquina:** scripts no scratchpad da sessão (equivalentes
  aos de `scripts_automacao/`: `clip.sh`, `mk_repair.py`, `save_resp.py`,
  `run_iter.sh`); envio e cópia pelo Claude in Chrome sem recusa genérica
  nesta rodada; `run_iter.sh` reinicia os emuladores Firebase e confere 1/1/5
  antes de cada execução.
- **Progresso: Gemini 14/18.** Próximo: COT-03 playlistFlow, depois L4-COT,
  C3-COT, P2-COT.
- **Rodada 33 (`FASE3-E2E-COT-03_playlistFlow`, Gemini, limpa): 3/4 na
  geração → 4/4 na iteração 1; (A) correto** ("Minha Conta" só existe na
  `TelaInicialScreen`; o `pop` volta à `UsuarioScreen`). O reparo trocou a
  asserção de retorno e manteve a verificação do documento no Firestore.
  **Bloco COT limpo do Gemini completo (3/3). Progresso: Gemini 15/18.**
  Próximo: L4-COT, C3-COT, P2-COT nos worktrees `Desktop\sintonize-fase3-{L4,C3,P2}`.
- **Rodada 34 (`FASE3-L4-COT`, Gemini, bug L4): 5/6 nas 4 execuções; (A),(B),(B);
  manual-first Capturou (iteração 0).** O reparo 1 acrescenta polling e mantém a
  asserção; os reparos 2 e 3 dizem que ela "deve ser mantida" e procuram a causa
  em exceções e no `initState` da `TelaInicialScreen` — nunca na rota trocada.
  **Progresso: Gemini 16/18.** Próximo: C3-COT.
- **Rodada 35 (`FASE3-C3-COT`, Gemini, bug C3): 2/5 → 5/5 na iteração 1, (A)
  correto; manual-first Viu sem asserção.** O verde é com o bug ativo: a
  saudação mostra o e-mail no lugar do nome e o teste afirma só "essa é a nossa
  recomendação…". Os docs criados têm `nome` = e-mail (REST). **Progresso:
  Gemini 17/18.** Próximo: P2-COT.
- **Rodada 36 (`FASE3-P2-COT`, Gemini, bug P2): 0/4 nas 4 execuções
  (`RangeError` em `criar_playlist.dart:167`, 11 por execução); (B),(B),(B)
  sem código, com arquivo e linha certos e a causa atribuída a corrida de
  rebuild, não ao `itemCount + 1`; manual-first Capturou (iteração 0).** Os
  prompts de reparo têm 140.876 caracteres (saída literal com os 11 stacks) e
  o editor do Gemini aceitou. A partir da cópia do reparo 2 o autor assumiu à
  mão (colou as respostas no chat; enviou o reparo 3) — registrado no doc.
- **Bloco COT do Gemini completo (6/6). GEMINI 18/18 — réplica Gemini da
  Fase 3 CONCLUÍDA.** Faltam no ChatGPT: P2-ZS e C3-COT (pendentes de decisão
  do autor; execução manual). **Progresso: 34/36.**

## Limitações e desvios (registro de 2026-10-06, decisão do autor)

Registrado antes do fechamento das duas rodadas pendentes do ChatGPT, por
decisão do autor, para valer independentemente do resultado delas.

### (a) Nome com dígito e o validador de `cadastro.dart`

Em cinco rodadas o teste do fluxo completo de cadastro nunca passou do
formulário porque o nome preenchido tinha um dígito ("Usuário E2E" no ChatGPT,
"Novo Usuario E2E" no Gemini) e o validador do campo Nome o recusou:

| Rodada | Modelo | Efeito |
|---|---|---|
| FASE3-E2E-FS-02_cadastroFlow | ChatGPT | rodada limpa; 0/1 nas iterações 1 e 2; o reparo 3 identificou o dígito e trocou por "Usuário Teste" |
| FASE3-C3-ZS | ChatGPT | bug C3; fluxo completo barrado nas 4 execuções → **Não viu** |
| FASE3-C3-FS | ChatGPT | bug C3; 0/1 ×4; tinha a asserção `data['nome']` que capturaria o C3, nunca alcançada → **Não viu** |
| FASE3-C3-COT (iteração 0, pendente) | ChatGPT | bug C3; 1/11 → Não viu provisório |
| FASE3-C3-ZS | Gemini | bug C3; 1/3 ×3 → **Não viu** |

**Onde está a regra.** `lib/utils/validators.dart` (as 10 funções da Fase 1)
não faz parte do material de nenhum prompt da Fase 3 (conferido: nenhum
arquivo de `prompts_prontos/` o cita). Mas o validador que recusou os nomes
**não é o de `validators.dart`**: é o `validator` inline do campo Nome em
`lib/cadastro.dart:235–237` (`RegExp(r'[^a-zA-ZÀ-ÿ\s]')` → "O nome não pode
conter números ou caracteres especiais"); `cadastro.dart` não importa
`validators.dart`. E `cadastro.dart` inteiro está nos três prompts de cadastro
(ZS-02, FS-02, COT-02 — a mensagem de erro aparece nos três). Portanto **não
é lacuna de material do desenho**: a regra foi entregue aos dois modelos, nas
três estratégias, e foi ignorada ao escolher o dado de teste. É erro do
modelo, igual para os dois, e assim é codificado nas auditorias (erro de
teste antes do sintoma → Não viu). A analogia com o caminho de import da
Fase 2 vale só no efeito (uma causa única derruba várias rodadas antes do
alvo), não na origem. O prompt não foi corrigido nem reexecutado, para
preservar a comparabilidade entre rodadas e entre modelos; a ChatGPT FS-02 é
a prova de que a regra era legível no material: o reparo 3 cita a regex do
`cadastro.dart` para explicar a falha do próprio teste.

### (b) Regra de não determinismo

O resultado de uma rodada é a **execução única registrada no doc** (geração
e cada iteração, uma execução cada, com seed reconferido). Quando a mesma
suíte, sem alteração, deu resultados diferentes, as duas saídas ficam
registradas e a rodada é marcada **instável**:

| Rodada | Observado |
|---|---|
| FASE3-E2E-COT-02_cadastroFlow (ChatGPT) | mesmo arquivo da iteração 1: **6/11** na iteração 1 e **4/11** na execução final — o número de testes derrubados pelo toque em "Cadastrar" com o teclado aberto varia entre execuções |
| FASE3-E2E-FS-02_cadastroFlow (Gemini) | mesmo arquivo nas iterações 1, 2 e 3: **0/1, 0/1, 1/1** — o `setState()` após `dispose` pré-existente dispara ou não; a iteração 3 rodou em **outra máquina** (confundidor registrado no doc) |
| FASE3-E2E-FS-01_loginFlow (ChatGPT) | 1/2 nas 4 execuções, mas por duas causas distintas (transição da `LoginScreen` nas iterações 0, 1 e 3; `setState` após `dispose` na 2) — resultado estável, causa instável |

Nenhuma rodada foi reexecutada para "escolher" um resultado; onde há duas
execuções do mesmo arquivo, foi porque o reparo veio sem código (regra:
reexecutar inalterado) ou porque o protocolo pedia a execução final.

### (c) Defeitos reais, não plantados, expostos pela Fase 3 (para o relatório de bugs)

1. **`setState()` após `dispose()` em `lib/tela-inicial.dart:161`**
   (`_TelaInicialScreenState._loadLastRecommendedMusic`, sem checar `mounted`).
   Aparece quando o teste termina logo depois que a `TelaInicialScreen` surge
   e o framework desmonta a tela antes de o Firestore responder. Presente no
   `lib/` limpo (`ccae44a`) e no `main`. Diagnosticado corretamente como
   defeito da aplicação por: **Gemini FS-01** (reparos 1–3, com arquivo, linha
   e correção), **Gemini FS-02** (reparos 2–3), **Gemini COT-01** (reparo 3),
   **ChatGPT ZS-03** (reparo 2, separou do erro de teste), **ChatGPT FS-01**
   (iteração 2). Apontado mas tomado pela causa errada (era efeito, não causa,
   da falha de timing): **ChatGPT ZS-01** (reparos 1–3), **ChatGPT COT-01**
   (geração). Derrubou o teste de sucesso do login em Gemini FS-01 (4×),
   FS-02 (2×) e COT-01 (2×).
2. **`setState()` após `dispose()` em `lib/criar_playlist.dart:41`**
   (`_fetchMusicas`, sem checar `mounted`). Mesmo padrão, na tela de playlist.
   Apontado por **ChatGPT COT-03** (reparo 3, tomado pela causa — falso (B)) e
   **ChatGPT P2-COT** (reparo 2, corretamente como efeito da falha).
3. Fora do escopo de bug mas registrado: a consulta real ao **ViaCEP** no
   `onChanged` do CEP (`cadastro.dart:314`) com a SnackBar "CEP não encontrado"
   — não é defeito, é dependência externa não isolada que derrubou o cenário
   de e-mail duplicado na Gemini COT-02 (provado por `curl`).

### (d) Rodadas pendentes do ChatGPT — decisão

**P2-ZS** (3 gerações só com preâmbulo) e **C3-COT** (reparo 1 de 57.926
caracteres sem resposta ×3): **Opção 1, e se falhar, Opção 4** — sem sessão
logada e sem filtro da saída. Procedimento: uma tentativa manual cada, em
horário de baixa carga, prompt byte-idêntico, deslogado, print do estado do
seletor. P2-ZS: conversa nova, tentativa 4 da geração. C3-COT: conversa nova
= tentativa 2 da rodada; a iteração 0 anterior fica como tentativa 1 nos
docs. Com código, protocolo normal; sem código (vazio/preâmbulo), fechar com
a Opção 4 e marcar a célula como **"sem dado por limitação do serviço"**, com
a nota já escrita em `_PENDENTE`. Razões: logar ou filtrar introduziria uma
variável nova dentro do ChatGPT, onde a comparação entre estratégias é a
primária; o Gemini aceitou reparos de 140.876 caracteres (P2-COT) no mesmo
dia, o que situa o limite no serviço, não no desenho.

## Próximos passos

Os passos 1 a 4 da lista original (validar aceleração, rodar a fumaça, cleartext, commitar e anotar tempos) foram cumpridos na segunda máquina em 2026-09-28; ver "Execução da fumaça". Receita que funcionou:

- subir o AVD: `emulator -avd tcc_e2e -no-snapshot-load -no-boot-anim` e esperar `adb -s emulator-5554 shell getprop sys.boot_completed` devolver `1`;
- subir os emuladores Firebase: `firebase emulators:start --only auth,firestore --project sintonize-fa494`, na raiz do repo (o `--project` tem de ser o `projectId` de `lib/firebase_options.dart`);
- build e teste: `flutter test integration_test/smoke_test.dart -d emulator-5554`.

Seed e os três fluxos (login, cadastro, playlist) estão feitos e verdes (2026-09-28, mesma máquina). `lib/` continua intocado. O que falta:

1. **Os 3 bugs estão aplicados, detectados e revertidos** (ver "Aplicação dos bugs"). Resumo: L4 → login 5/5 → 4/5; C3 → cadastro 6/6 → 5/6; P2 → playlist 4/4 → 0/4. Os hashes com cada bug ativo estão na tabela.
2. Decidir e registrar o que a Fase 3 mede a partir daí (os testes E2E são escritos à mão, não por LLM — isso precisa estar claro na redação). Material já levantado para essa decisão: (a) SILENT × CRASH — o CRASH entrega arquivo:linha na saída, o SILENT só diz que o esperado não apareceu; (b) um `testWidgets` longo dá um diagnóstico por execução (C3 tinha dois pontos de detecção, só o primeiro rodou); (c) o custo por bug foi de 2 a 3 execuções e 2–3 min de máquina, contra 132 s de boot do AVD e 362 s do primeiro build.

Operacional: um `flutter test` por comando (ver a ocorrência do travamento em "Execução do fluxo de playlist"); AVD e emuladores Firebase morrem com a sessão e precisam subir de novo (30 s e ~10 s, respectivamente, com tudo em cache).

## Ambiente da máquina original (2026-09-28)

- Android SDK em `%LOCALAPPDATA%\Android\Sdk` (cmdline-tools 22.0, emulator 37.1.11, platform-tools 37.0.1, platforms 34 e 36, build-tools 35.0.0 e 36.0.0, system image `android-34;google_apis;x86_64`); AVD `tcc_e2e` (Pixel 6).
- Node v24.21.0 em `%LOCALAPPDATA%\nodejs` e firebase-tools 15.31.0 (`npm i -g`).
- Emuladores Firebase: `firebase emulators:start --only auth,firestore --project sintonize-fa494` (auth 9099, firestore 8080, UI 4000; config em `firebase.json`).

## Ambiente da segunda máquina (2026-09-28) — onde a fumaça passou

Worktree `Desktop/sintonize-fase3` na branch `fase3-e2e`. Diferenças em relação à máquina original que valem registro:

- Android SDK em `%LOCALAPPDATA%\Android\Sdk` já existia (de uma instalação antiga): cmdline-tools **16.0**, emulator 35.2.10, platform-tools 35.0.2. `ANDROID_HOME` **não** está definido; o Flutter achou o SDK sozinho. Instalados nesta data via `sdkmanager --package_file`: `platforms;android-36`, `build-tools;36.0.0`, `system-images;android-34;google_apis;x86_64`. Licenças aceitas com `yes | sdkmanager --licenses` e `flutter doctor --android-licenses` (Git Bash). O primeiro build do app puxou sozinho NDK 28.2.13676358 e CMake 3.22.1.
- AVD `tcc_e2e` criado com `avdmanager create avd -n tcc_e2e -k "system-images;android-34;google_apis;x86_64" -d pixel_6`. `emulator -accel-check` diz `WHPX(10.0.26200) is installed and usable`.
- Java: `JAVA_HOME` aponta para **jdk-17**; o `java` do PATH é o 25, mas o Gradle 8.3 usa o `JAVA_HOME`. Não trocar para o 25.
- Node **v22.16.0** (instalação em `Program Files`) e firebase-tools **15.31.0**. Estava em 13.31.1, que falhava com `Error: No emulators to start, run firebase init emulators to get started.` mesmo com a seção `emulators` em `firebase.json`; `npm i -g firebase-tools@15.31.0` resolveu. O primeiro `emulators:start` baixou `cloud-firestore-emulator-v1.22.0.jar` e `ui-v1.15.0.zip`.
- Flutter 3.41.6 (checkout da tag, `channel [user-branch]`), Dart 3.11.4, o mesmo da Fase 2.
