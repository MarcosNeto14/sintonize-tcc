# FASE3-E2E-ZS-01_loginFlow — Gemini (rodada limpa)

Rodada 7 do plano (bloco 1 — ZS, Gemini; primeira rodada Gemini da Fase 3).
Documentada a partir de `fase3-e2e/template_rodada.md`. **Executada em
2026-10-05 na máquina original (`DellT4i51`)**, em conversa nova. Uma tentativa
anterior no mesmo dia rodou com o seletor em Flash-Lite e foi abortada antes de
qualquer execução: `_abortadas/FASE3-E2E-ZS-01_loginFlow_TENTATIVA-1_flash-lite.md`.

**Resultado em uma linha:** 5 testes gerados; **não compila na geração**
(`Finder.matches` inexistente) → reparo 1 (A) → **2/5** (SnackBar e tela de
destino procurados antes da resposta do Auth) → reparo 2 (A), espera ativa por
`pump` com timeout → **5/5 verde**, sem enfraquecer nenhuma asserção.

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-E2E-ZS-01_loginFlow (limpa) |
| **Modelo** | Gemini |
| **Fluxo alvo** | login — tela de boas-vindas → `LoginScreen` → `TelaInicialScreen` |
| **Estado do `lib/`** | limpo — `git diff ccae44a -- lib/` vazio no worktree de execução, conferido antes da execução |
| **Worktree usado** | `C:\Users\marcos.neto\Desktop\sintonize-fase3`, detached em `06d2d59` (`lib/`, `integration_test/*.dart`, `pubspec.*` e `android/` idênticos aos da ponta `6fdb09a`). Checkout que commita: `Desktop\Repositórios\sintonize-tcc` |
| **Nível da pirâmide** | E2E (integration_test no AVD, emuladores Firebase) |
| **Estratégia de prompt** | Zero-shot |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/zero-shot/FASE3-E2E-ZS-01_loginFlow.md` — sha256 `a2b8247c6f611bdd52d0fa19e8a9449e93acdd5f2b153cc415a090670dbf8087` (conteúdo LF do repositório; o checkout desta máquina tem CRLF), igual ao de `prompts_prontos/_sha256.txt` |
| **✦ Modelo declarado pelo LLM** | Não perguntado. Segue a regra da réplica (nota de 2026-09-21 em `fase2-gemini/README.md`): o Gemini não declara versão; a resposta padrão registrada lá vale para todas as rodadas Gemini |
| **✦ Verificação externa da versão** | Não consultada em 2026-10-05. Evidência do modelo: confirmação do autor de que o seletor estava em Flash na conversa da rodada ("confirmo que ta no flash"); **sem print do seletor nesta conversa** (decisão do autor de não tirar print por rodada). O único print do dia é o da tentativa abortada, que mostra Flash-Lite |
| **Sessão** | Gemini logado, conta Pro, seletor em 3.8 Flash (declaração do autor) |
| **Consultou fontes externas?** | Não — nenhum marcador de citação nas três respostas devolvidas |
| **Data de acesso** | 2026-10-05 |
| **Conversa nova?** | Sim — `https://gemini.google.com/app/cc09df4611e95628` (geração e os 2 reparos) |
| **Versão do Flutter** | Flutter 3.41.6 · Dart 3.11.4 (stable) |
| **AVD** | `tcc_e2e` (Pixel 6, API 34, google_apis, x86_64); `emulator-5554` |
| **firebase-tools** | 15.31.0 |

---

## Procedimento operacional (executado)

Antes da conversa / da execução:

- [x] Worktree `Desktop\sintonize-fase3`, `lib/` limpo (diff vs `ccae44a` vazio). O arquivo que sobrou da tentativa ChatGPT de 2026-10-02 em `integration_test/fase3/` (byte-idêntico à cópia em `chatgpt/_abortadas/`) foi removido antes.
- [x] AVD `tcc_e2e` ligado (`-no-snapshot-load -no-boot-anim`), `sys.boot_completed = 1`.
- [x] Emuladores Firebase (`--only auth,firestore --project sintonize-fa494`) desacoplados via `Start-Process cmd /c`, a partir da raiz do worktree.

Na conversa:

- [x] Prompt carregado no clipboard por script (33.976 caracteres, início "Gere um teste end-to-end em Dart, com o pacote…", fim "…para os imports do projeto"), **colado e enviado à mão pelo autor**.
- [x] Código salvo sem editar em `integration_test/fase3/login_zs_test.dart` do worktree. O modelo nomeou o arquivo `login_test.dart` (comentário da 1ª linha); a convenção fixa `login_zs_test.dart`. Cópia arquivada em `integration_test/fase3/gemini/login_zs_test.dart` (estado final, sha256 `c34ca52801f544f6c9fe3d7cef31fbc7192d1dd2e100bbce0de2f072619fb163`).

A cada execução (3 válidas: geração + 2 iterações):

- [x] Emuladores derrubados e subidos de novo; `seed_test` rodado; conferido por REST antes de cada execução válida: 1 conta no Auth, 1 doc em `usuarios`, 5 em `musica`.
- [x] `flutter test integration_test/fase3/login_zs_test.dart -d emulator-5554`, um por comando.
- [x] Saídas íntegras em `resultados/gemini/FASE3-E2E-ZS-01_loginFlow_iter{0,1}.txt` e `_iter2_final.txt`.
- [x] Print do AVD após as execuções com falha: `evidencias/gemini/FASE3-E2E-ZS-01_loginFlow_iter{0,1}.png` (mesma limitação já registrada na rodada 1 do ChatGPT: o print sai depois do fim da suíte).
- [x] Reparos: só o template fixo com a saída literal, na mesma conversa (`..._transcricao/prompt_reparo_iter{1,2}.txt`, 7.576 e 9.250 caracteres), carregados no clipboard por script e colados pelo autor.

Depois da rodada:

- [x] Teste final arquivado em `integration_test/fase3/gemini/`; doc, resultados, evidências e transcrição commitados juntos na `fase3-e2e`.
- [ ] Codificação manual-first: não se aplica (rodada limpa).

### Ocorrências de ambiente e de método nesta rodada

1. **Ambiente da máquina original montado nesta data.** NDK 28.2.13676358 e CMake 3.22.1 instalados (`sdkmanager`; o NDK de 2026-10-02 tinha ficado só com `.installer/`). O primeiro build falhou com o JDK 21 do sistema (`jlink` / `JdkImageTransform` em `core-for-system-modules.jar`, AGP < 8.2.1); instalado o Temurin 17.0.20.1 em `%LOCALAPPDATA%\jdk17` e usado só via `JAVA_HOME` nos comandos de teste. Primeiro build: 607 s; os seguintes, 47–63 s de Gradle. O disco teve de ser liberado pelo autor (11,1 GB livres, abaixo dos 12,3 GB que o AVD exige).
2. **Uma execução da iteração 2 é inválida e não conta.** O `seed_test` falhou em 00:00 após o reinício dos emuladores (causa não registrada; a nova tentativa logo em seguida passou), o script seguiu e o teste rodou com Auth e Firestore vazios: 3/5. Saída e print preservados como `..._iter2_INVALIDA-sem-seed.{txt,png}`. Com o seed refeito e conferido (1/1/5), a iteração 2 foi executada de novo sobre o mesmo arquivo: 5/5. O script de execução passou a abortar quando a conferência do seed não dá 1/1/5.

---

## Prompt Enviado

Texto entre o segundo e o terceiro `---` de
`fase3-e2e/prompts_prontos/zero-shot/FASE3-E2E-ZS-01_loginFlow.md`, sem
alteração (33.976 caracteres). Não é repetido aqui; o arquivo e o sha256 são o
registro.

---

## Resposta do LLM

Resposta completa em `FASE3-E2E-ZS-01_loginFlow_transcricao/iter0_resposta.md`:
um parágrafo de apresentação, o arquivo inteiro (5 `testWidgets`: campos
vazios, e-mail inválido, usuário inexistente, senha errada, sucesso) e uma
seção "Detalhes da Implementação". Em português, sem Canvas aparente, sem
fontes externas. Pontos que importam para a auditoria:

- Faz `FirebaseAuth.instance.signOut()` em `setUp`.
- Nos casos de erro, aceita duas mensagens alternativas (`user-not-found` ou
  `invalid-credential`; `wrong-password` ou `invalid-credential`), justificando
  pela proteção contra enumeração de usuários do Firebase Auth atual.
- No sucesso, afirma `TelaInicialScreen`, ausência de `LoginScreen`, a saudação
  com o nome formatado do Firestore ("Tester Sintonize, essa é a nossa
  recomendação") e a barra inferior.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Não (iteração 0); sim a partir da iteração 1 |
| **Testes gerados** | 5 |
| **Testes passaram (iteração 0)** | 0 (não compila) |
| **Testes falharam (iteração 0)** | — (erro de carga) |
| **Testes passaram (estado final arquivado)** | 5 |
| **Testes falharam (estado final arquivado)** | 0 |
| **Melhor estado intermediário** | = final |
| **Tempo por execução** | iter0: 54 s (Gradle 47 s, falha de compilação); iter1: 152 s (Gradle 63 s + teste 56 s); iter2: 157 s (Gradle 51 s + teste 55 s) |
| **Prints tirados** | `evidencias/gemini/FASE3-E2E-ZS-01_loginFlow_iter0.png`, `_iter1.png` |

### Saída do terminal (iteração 0)

Íntegra em `resultados/gemini/FASE3-E2E-ZS-01_loginFlow_iter0.txt`. Núcleo:

```
integration_test/fase3/login_zs_test.dart:104:31: Error: The method 'matches' isn't defined for the type 'Finder'.
integration_test/fase3/login_zs_test.dart:105:36: Error: The method 'matches' isn't defined for the type 'Finder'.
integration_test/fase3/login_zs_test.dart:144:32: Error: The method 'matches' isn't defined for the type 'Finder'.
integration_test/fase3/login_zs_test.dart:145:36: Error: The method 'matches' isn't defined for the type 'Finder'.
```

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** não compila — `Finder.matches(widget)` não existe na API do `flutter_test`.
- **Prompt de reparo enviado:** template fixo + saída literal de `_iter0.txt` (7.576 caracteres) — `FASE3-E2E-ZS-01_loginFlow_transcricao/prompt_reparo_iter1.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `..._transcricao/iter1_resposta.md`. Troca os dois `byWidgetPredicate` por `widget is Text && (widget.data == … || widget.data == …)` e retira os comentários; nada mais muda.
- **★ Autoclassificação do modelo:** (A) — "a falha não ocorreu por divergência de comportamento da aplicação em tempo de execução (…) mas sim por um erro de compilação no próprio código do teste".
- **Resultado após correção:** **2/5** — Falhou. Passam campos vazios e e-mail inválido; falham usuário inexistente e senha errada (`Found 0 widgets with type "SnackBar"`, linhas 82 e 119) e sucesso (`Found 0 widgets with type "TelaInicialScreen"`, linha 156).
- **Print:** `evidencias/gemini/FASE3-E2E-ZS-01_loginFlow_iter1.png`

### Iteração 2

- **Motivo da falha:** as três asserções que dependem da resposta do Auth emulator rodam logo após um `pumpAndSettle()` que não espera I/O fora do framework.
- **Prompt de reparo enviado:** template fixo + saída literal de `_iter1.txt` (9.250 caracteres) — `..._transcricao/prompt_reparo_iter2.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `..._transcricao/iter2_resposta.md`. Diagnóstico: `pumpAndSettle` drena frames e animações, não a chamada `signInWithEmailAndPassword`; acrescenta que o SnackBar tem duração de 4 s e poderia sumir num `pumpAndSettle` repetido. Correção: auxiliar `waitForFinder` (laço de `pump(200 ms)` até o finder achar algo, timeout de 15 s) antes das asserções de SnackBar, `TelaInicialScreen` e saudação. Nenhuma asserção removida ou afrouxada.
- **★ Autoclassificação do modelo:** (A) — "Falha de sincronização com requisições assíncronas do Firebase nos emuladores".
- **Resultado após correção:** **5/5** — Passou (execução válida, com seed conferido; ver ocorrência 2).
- **Print:** — (sem falha)

### Iteração 3

Não necessária.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A), (A) |
| **★ Classificação humana (auditoria)** | Iteração 0: **Erro de geração** (API inexistente). Iteração 1: **Erro de teste** (espera insuficiente por estado assíncrono) |
| **★ Concordância** | Sim, nas duas |
| **★ Observações** | É a mesma falha de espera que as três rodadas ZS limpas do ChatGPT tiveram (asserção antes da resposta do Firebase). Diferença: aqui o reparo resolveu **sem reduzir o que é verificado** — a saudação com o nome vindo do Firestore continua afirmada, ao contrário da ZS-03 do ChatGPT, que chegou ao verde trocando essa asserção. O diagnóstico do reparo 2 é correto e específico; a observação sobre a duração do SnackBar é plausível, mas não foi o que derrubou a iteração 1. Os casos de erro aceitam duas mensagens alternativas por código de erro do Auth: é uma tolerância consciente e declarada, não um enfraquecimento introduzido no reparo (já estava na geração). |
