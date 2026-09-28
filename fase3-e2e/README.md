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

## Ambiente

- Android SDK em `%LOCALAPPDATA%\Android\Sdk` (cmdline-tools 22.0, emulator 37.1.11, platform-tools 37.0.1, platforms 34 e 36, build-tools 35.0.0 e 36.0.0, system image `android-34;google_apis;x86_64`); AVD `tcc_e2e` (Pixel 6).
- Node v24.21.0 em `%LOCALAPPDATA%\nodejs` e firebase-tools 15.31.0 (`npm i -g`).
- Emuladores Firebase: `firebase emulators:start --only auth,firestore --project sintonize-fa494` (auth 9099, firestore 8080, UI 4000; config em `firebase.json`).
