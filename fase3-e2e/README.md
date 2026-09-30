# Fase 3 — Testes E2E

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
