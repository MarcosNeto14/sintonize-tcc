# Fase 3 — custo do ambiente E2E e implementação de referência

Números medidos na segunda máquina em 2026-09-28 e 29, com o AVD `tcc_e2e`
(Pixel 6, API 34, x86_64, WHPX) e os emuladores Firebase Auth/Firestore.
As saídas brutas estão em `fase3-e2e/resultados/`. Este documento é a
consolidação; o histórico run a run está em `fase3-e2e/README.md`.

## Autoria dos testes de referência

Os três testes em `integration_test/_referencia/` (`login_flow_test.dart`,
`cadastro_flow_test.dart`, `playlist_flow_test.dart`, mais
`pump_helpers.dart`) foram **produzidos com assistência de LLM (Claude Code)
em regime interativo, com acesso ao código, ao dispositivo e às saídas de
cada execução, fora do protocolo experimental**. Não são rodadas: não
passaram por prompt fixo, conversa nova, limite de 3 iterações nem
autoclassificação. Seu papel na Fase 3 é (a) implementação de referência,
mostrando que os três fluxos são automatizáveis neste ambiente, e (b) prova
de detectabilidade dos três bugs plantados. **Não entram na comparação
ZS/FS/COT e não podem aparecer em nenhum prompt, nem de geração nem de
reparo.**

## Custo fixo do ambiente

| Etapa | Medido | Quando |
|---|---|---|
| Boot do AVD, frio (`-no-snapshot-load`), até `sys.boot_completed=1` | 132 s | 2026-09-28, primeira subida |
| Boot do AVD nas subidas seguintes (imagem de sistema já aquecida) | 30 s, 25 s | 2026-09-28 e 29 |
| Emuladores Firebase (`firebase emulators:start --only auth,firestore`) | ~10–12 s; a primeira vez baixou o jar do Firestore e a UI | 2026-09-28 e 29 |
| Primeiro `flutter test` (Gradle `assembleDebug` do zero; puxou NDK 28.2 e CMake 3.22.1) | 362 s | fumaça, 2026-09-28 |
| Gradle após restaurar `lib/` de outro commit | 39,5 s, 50,1 s | baselines de C3 e P2 |
| Gradle incremental (só o teste mudou) | 10,9–22,6 s | todos os demais runs |
| Instalar o APK | ~0,7–0,9 s | — |

## Custo por execução de fluxo (teste + `setUpAll` com seed)

| Fluxo | Testes | Tempo de teste (verde) | Comando inteiro (com Gradle incremental) |
|---|---|---|---|
| fumaça | 1 | 5 s | 390 s (primeiro build) |
| login | 5 | 10–21 s | 27–50 s |
| cadastro | 6 | 25–30 s | 43–78 s |
| playlist | 4 | 18–30 s | 52–101 s |

## Custo por bug (protocolo: baseline verde → bug → run vermelho)

| Bug | Execuções | Tempo de máquina | Observação |
|---|---|---|---|
| L4 | 3 (2 de baseline + 1 com bug) | ~2 min | a 1ª baseline foi vermelha por timing do próprio teste, corrigido antes de aplicar o bug |
| C3 | 2 | ~2,5 min | — |
| P2 | 2 | ~3 min | Gradle de 50 s na baseline por causa da restauração do `lib/` |

Runs de escrita dos testes (fora do protocolo, contam como custo de
desenvolvimento da referência): login 4 runs (2 até verde + 2 depois), cadastro
6 runs (4 até verde + 2 depois), playlist 2 runs. Um run encadeado travou por
11 min em `setUpAll` sem causa identificada — um `flutter test` por comando.

## Detectabilidade: SILENT × CRASH

| Bug | Tipo | Fluxo | Antes → depois | O que a saída do teste entrega | O que um tester manual vê |
|---|---|---|---|---|---|
| L4 (`login.dart:36`, `TelaInicialScreen` → `CadastroScreen`) | SILENT | login | 5/5 → **4/5** | `não apareceu em 20s: TelaInicialScreen` — não diz para onde o app foi | depois do login correto, abre a tela de Cadastro |
| C3 (`cadastro.dart:149`, `nome` ← `_emailController`) | SILENT | cadastro | 6/6 → **5/6** | `não apareceu em 20s: ... João Silva, essa é a nossa recomendação` — não diz o que apareceu; o 2º ponto de detecção (`doc['nome']`) nunca rodou | a saudação da tela inicial mostra o e-mail no lugar do nome |
| P2 (`criar_playlist.dart:165`, `itemCount + 1`) | CRASH | playlist | 4/4 → **0/4** | `RangeError (length): Invalid value: Not in inclusive range 0..4: 5` com stack em `criar_playlist.dart:167` | bloco vermelho de erro no fim da lista de músicas (debug) |

Leituras que a tabela sustenta:

1. **O CRASH entrega o diagnóstico; o SILENT só diz que o esperado não veio.**
   Em L4 e C3 a saída exige que alguém abra o app para descobrir o sintoma; em
   P2 a exceção traz tipo, valor e arquivo:linha sem asserção nenhuma.
2. **O CRASH derruba o fluxo inteiro; o SILENT derruba um teste.** P2 estoura no
   `build` da lista, então todo teste que chega à tela cai antes de fazer o
   que ia fazer. L4 e C3 só afetam o caminho de sucesso.
3. **Um `testWidgets` longo dá um diagnóstico por execução.** C3 tinha dois
   pontos de detecção; o teste parou no primeiro.
4. **Rastro de lint:** só L4 deixa um (`unused_import`); C3 e P2 não.

Hashes com cada bug ativo em `lib/`: L4 `eb14334`, C3 `20edaaa`, P2 `60cbaff`.
A ponta da branch `fase3-e2e` carrega o `lib/` limpo (igual a `ccae44a`).

## Armadilhas de E2E em dispositivo, encontradas ao escrever a referência

Registradas porque as rodadas geradas vão esbarrar nelas; a rubrica de
codificação precisa distinguir "falhou por causa do bug" de "falhou por uma
destas".

- **Cleartext:** o Auth emulator fala HTTP com `10.0.2.2` e o Android 9+ bloqueia;
  resolvido uma vez no manifest de debug (`usesCleartextTraffic`). Não afeta as
  rodadas.
- **Teclado aberto encolhe o viewport:** um `tap` em botão no rodapé cai fora da
  área visível; `pumpAndSettle` não espera o teclado recolher (animação do
  Android). E `ListView.builder` só constrói o que cabe — com o teclado aberto,
  3 dos 5 cards existem.
- **Transições de rota:** a tela de destino é encontrada antes de a de origem
  sair (`pushReplacement` e `pop`); `pumpAndSettle` não serve quando a tela
  tem `CircularProgressIndicator`.
- **Rede externa real:** o cadastro chama o ViaCEP; funcionou nos runs, mas não é
  controlado.
- **Estado acumulado no emulador:** cada run de cadastro cria um usuário e cada
  run de playlist cria uma playlist; por isso o seed limpo antes de cada
  execução no protocolo das rodadas.
