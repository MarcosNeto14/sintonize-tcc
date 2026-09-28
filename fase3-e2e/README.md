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
| `integration_test/seed.dart` | feito: `seedEmulators()`, com usuário `tester@sintonize.test` / `senha123` e 5 docs em `musica` (`track_name`, `artist_name`, `genre`), IDs fixos, idempotente |
| `integration_test/smoke_test.dart` | escrito e com `flutter analyze` limpo, **nunca executado**: abre `MyApp`, toca em "Login" e verifica `LoginScreen` |
| Emuladores Firebase | testados na máquina original: subiram em 47 s e 9099/8080 responderam 200 |
| AVD `tcc_e2e` | criado na máquina original, **nunca subiu**: sem aceleração de hardware (hipervisor habilitado, mas a máquina não foi reiniciada) |
| `lib/` | intocado; nenhum bug da Fase 3 aplicado |

### Bugs escolhidos para a Fase 3 (não aplicados)

Uma linha cada, no `lib/` desta branch. As linhas foram conferidas em 2026-09-28.

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

1. **Validar a aceleração:** `emulator -accel-check`. Sem ela, o AVD x86_64 não sobe.
2. **Rodar a fumaça**, medindo o tempo de cada etapa:
   - subir o AVD: `flutter emulators --launch tcc_e2e` e esperar `adb devices` mostrar `emulator-5554` como `device`;
   - subir os emuladores Firebase: `firebase emulators:start --only auth,firestore --project sintonize-fa494`, na raiz do repo (o `--project` tem de ser o `projectId` de `lib/firebase_options.dart`);
   - seed: `seedEmulators()` ainda não é chamado por nenhum teste. Chamar no `setUpAll` do teste, depois de `setupFirebaseEmulators()`, ou criar um `integration_test/seed_test.dart` que só faça isso;
   - build e teste: `flutter test integration_test/smoke_test.dart -d emulator-5554`.
3. **Se o Auth emulator for bloqueado por HTTP em claro** (Android 9+ bloqueia cleartext), acrescentar `android:usesCleartextTraffic="true"` **só** em `android/app/src/debug/AndroidManifest.xml` e registrar aqui. Não mexer em `lib/`.
4. Commitar o `smoke_test` (e o manifest, se mudar) e anotar os tempos neste README.
5. Só depois disso partir para os fluxos reais (login, cadastro, playlist) e para a aplicação dos bugs L4, C3 e P2.

## Ambiente da máquina original (2026-09-28)

- Android SDK em `%LOCALAPPDATA%\Android\Sdk` (cmdline-tools 22.0, emulator 37.1.11, platform-tools 37.0.1, platforms 34 e 36, build-tools 35.0.0 e 36.0.0, system image `android-34;google_apis;x86_64`); AVD `tcc_e2e` (Pixel 6).
- Node v24.21.0 em `%LOCALAPPDATA%\nodejs` e firebase-tools 15.31.0 (`npm i -g`).
- Emuladores Firebase: `firebase emulators:start --only auth,firestore --project sintonize-fa494` (auth 9099, firestore 8080, UI 4000; config em `firebase.json`).
