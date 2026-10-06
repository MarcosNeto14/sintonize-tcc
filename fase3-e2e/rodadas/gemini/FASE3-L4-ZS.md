# FASE3-L4-ZS — Gemini (rodada com bug L4)

Rodada 10 do plano (bloco 1 — ZS, Gemini; primeira rodada Gemini com bug).
Documentada a partir de `fase3-e2e/template_rodada.md`. **Executada em
2026-10-05 na segunda máquina (`DESKTOP-6ETPO2H`)**, em conversa nova. O prompt
é o de `FASE3-E2E-ZS-01_loginFlow` (o mesmo da rodada limpa, sem menção a bug);
o teste roda no worktree com o L4 ativo.

**Resultado em uma linha:** 5 testes gerados; **4/5 nas 4 execuções**, sempre no
teste de sucesso (`Found 0 widgets with type "TelaInicialScreen"`), e com
`LoginScreen` → `findsNothing` passando logo antes. Reparos 1 e 2 **(A)**, com
diagnósticos que a saída desmente; reparo 3 **(B)** sem código, apontando para a
`LoginScreen` com uma causa errada. **Manual-first: Capturou** (já na iteração 0).

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-L4-ZS (bug L4) |
| **Modelo** | Gemini |
| **Fluxo alvo** | login — tela de boas-vindas → `LoginScreen` → `TelaInicialScreen` |
| **Bug ativo** | L4 — `lib/login.dart:36`, `MaterialPageRoute(builder: (context) => const TelaInicialScreen())` → `CadastroScreen()` |
| **Estado do `lib/`** | worktree em `eb14334`; `git diff --stat HEAD -- lib/` vazio, conferido antes de cada execução |
| **Worktree usado** | `C:\Users\Marcos\Desktop\sintonize-fase3-L4`, detached em `eb14334`. `firebase_test_helper.dart` e `seed.dart` idênticos aos da ponta da `fase3-e2e` (conferido por `cmp`) |
| **Nível da pirâmide** | E2E (integration_test no AVD, emuladores Firebase) |
| **Estratégia de prompt** | Zero-shot |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/zero-shot/FASE3-E2E-ZS-01_loginFlow.md` — sha256 `a2b8247c6f611bdd52d0fa19e8a9449e93acdd5f2b153cc415a090670dbf8087` |
| **✦ Modelo declarado pelo LLM** | Não perguntado (mesma regra das rodadas Gemini anteriores) |
| **✦ Verificação externa da versão** | Não consultada. O autor foi lembrado de conferir o seletor em 3.8 Flash e não apontou divergência. Sem print do seletor |
| **Sessão** | Gemini logado, conta Pro, seletor em 3.8 Flash (conferência do autor) |
| **Consultou fontes externas?** | Não — nenhum marcador de citação nas quatro respostas |
| **Data de acesso** | 2026-10-05 |
| **Conversa nova?** | Sim — `https://gemini.google.com/app/ce109fc0d738e577` (geração e os 3 reparos) |
| **Versão do Flutter** | Flutter 3.41.6 · Dart 3.11.4 |
| **AVD** | `tcc_e2e` (Pixel 6, API 34, google_apis, x86_64); `emulator-5554` |
| **firebase-tools** | 15.31.0 |

---

## Procedimento operacional (executado)

- [x] Prompt carregado no clipboard por script (33.976 caracteres, igual ao da rodada 7), **colado e enviado à mão pelo autor** numa conversa nova.
- [x] O autor devolveu as respostas colando o texto na conversa com o Claude; transcrições salvas sem edição em `FASE3-L4-ZS_transcricao/`.
- [x] Código salvo sem editar em `integration_test/fase3/l4_zs_test.dart` **do worktree L4**. O modelo nomeou `login_flow_test.dart` na geração e, a partir do reparo 1, `l4_zs_test.dart` (o nome que leu na saída do terminal). Reparos 1 e 2: arquivo completo, substituição integral. Reparo 3: sem código.
- [x] Antes de cada uma das 4 execuções: emuladores derrubados e subidos de novo, `seed_test` rodado **no worktree L4**, conferência por REST (1 conta no Auth, 1 doc em `usuarios`, 5 em `musica`). O script aborta se não der 1/1/5.
- [x] `flutter test integration_test/fase3/l4_zs_test.dart -d emulator-5554`, no worktree L4, um por comando. Saídas em `resultados/gemini/FASE3-L4-ZS_iter{0,1,2}.txt` e `_iter3_final.txt`.
- [x] Prints do AVD depois de cada execução: `evidencias/gemini/FASE3-L4-ZS_iter{0..3}.png`. **Nenhum mostra o sintoma** (ver ocorrência 2).
- [x] Teste final arquivado em `integration_test/fase3/gemini/l4_zs_test.dart` (sha256 `69a9153ff43f8909b6a47e54bd8ad53cffa1964eb504e2caf869fcd0a88f3516`) e removido do worktree. O da geração está em `FASE3-L4-ZS_transcricao/teste_iter0_geracao.dart`.
- [x] Reparos: só o template fixo com a saída literal (`prompt_reparo_iter{1,2,3}.txt`, 6.383 caracteres cada; o tamanho coincide, o conteúdo difere nos tempos e na linha da falha, conferido por `diff`).
- [x] Codificação manual-first feita (abaixo).

### Ocorrências de operação e de ambiente

1. **Colagem errada do autor, sem efeito sobre o modelo.** O primeiro texto devolvido era a resposta da rodada 9 (teste da playlist), não uma resposta a este prompt. Foi recusado antes de salvar qualquer arquivo, e o autor devolveu em seguida a resposta certa (teste de login). O modelo não recebeu nada fora do protocolo.
2. **Diálogo "System UI isn't responding" no AVD.** Aparece em todos os prints desta rodada e já estava aberto no print da iteração 1 da rodada 8. Os prints são tirados depois do fim da suíte, quando o app já fechou, por isso mostram o launcher com o diálogo e não o sintoma. O diálogo foi fechado ("Wait") depois desta rodada. Não há indício de efeito nos resultados: os toques do `flutter_test` são sintéticos, injetados no framework e não na UI do sistema; as rodadas 8 e 9 ficaram verdes com o diálogo aberto; e aqui as 4 execuções deram a mesma falha, no mesmo ponto.

---

## Prompt Enviado

Texto entre o segundo e o terceiro `---` de
`fase3-e2e/prompts_prontos/zero-shot/FASE3-E2E-ZS-01_loginFlow.md`, sem
alteração (33.976 caracteres). Não é repetido aqui.

---

## Resposta do LLM

Resposta completa em `FASE3-L4-ZS_transcricao/iter0_resposta.md`. São 5
`testWidgets` com um auxiliar `navigateToLoginScreen`: campos vazios, formato
inválido, usuário inexistente, senha errada (SnackBar vermelho; duas mensagens
aceitas por código do Auth) e sucesso. No sucesso: `pumpAndSettle(3 s)` e
asserções `LoginScreen` → `findsNothing`, **`TelaInicialScreen` →
`findsOneWidget`**, a saudação "Tester Sintonize, essa é a nossa recomendação…"
e os 3 itens da barra inferior. Estrutura muito próxima da rodada 7 (mesmo
prompt, conversa diferente).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim, nas quatro |
| **Testes gerados** | 5 |
| **Testes passaram (iteração 0)** | 4 (os 4 de erro/validação) |
| **Testes falharam (iteração 0)** | 1 — sucesso: `Found 0 widgets with type "TelaInicialScreen"` (linha 178) |
| **Testes passaram (estado final arquivado)** | 4 |
| **Testes falharam (estado final arquivado)** | 1 — o mesmo, linha 215 |
| **Melhor estado intermediário** | 4/5 em todas |
| **Tempo por execução** | iter0 35 s (Gradle 16 s); iter1 39 s (21 s); iter2 57 s (16 s); iter3 46 s (18 s) |
| **Prints tirados** | `evidencias/gemini/FASE3-L4-ZS_iter{0,1,2,3}.png` (só o diálogo do sistema; ocorrência 2) |

### Saída do terminal (iteração 0)

Íntegra em `resultados/gemini/FASE3-L4-ZS_iter0.txt`. Núcleo:

```
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 0 widgets with type "TelaInicialScreen": []>
   Which: means none were found but one was expected
#4      main.<anonymous closure>.<anonymous closure> (file:///C:/Users/Marcos/Desktop/sintonize-fase3-L4/integration_test/fase3/l4_zs_test.dart:178:7)
00:35 +4 -1: Some tests failed.
```

A linha 177, `expect(find.byType(LoginScreen), findsNothing)`, passou: o app
saiu da `LoginScreen` e não chegou à `TelaInicialScreen`.

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** o sintoma do L4 — depois do login válido, a tela de destino não é a `TelaInicialScreen`.
- **Prompt de reparo enviado:** template fixo + saída literal de `_iter0.txt` — `FASE3-L4-ZS_transcricao/prompt_reparo_iter1.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `..._transcricao/iter1_resposta.md`. Diagnóstico em quatro hipóteses (SnackBar de 4 s do teste anterior, `pumpAndSettle(Duration)` como "pulso" e não timeout, teclado/foco ativos, estado residual entre testes). Correção: auxiliar `waitForWidget` (laço de `pump(200 ms)`, 10 s), `unfocus()` antes do "Entrar" e espera ativa pela `TelaInicialScreen` e pela saudação. A resposta promete "limpar qualquer SnackBar ativo no setUp e tearDown via ScaffoldMessenger", **o que não está no código entregue**.
- **★ Autoclassificação do modelo:** (A) — "O teste presume um comportamento que não é o especificado."
- **Resultado após correção:** **4/5** — Falhou. O mesmo teste, linha 192, depois de esperar 10 s.
- **Print:** `evidencias/gemini/FASE3-L4-ZS_iter1.png`

### Iteração 2

- **Motivo da falha:** o mesmo; a espera ativa não muda nada.
- **Prompt de reparo enviado:** template fixo + saída literal de `_iter1.txt` — `..._transcricao/prompt_reparo_iter2.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `..._transcricao/iter2_resposta.md`. Diagnóstico: o botão "Entrar" estaria fora da viewport do `SingleChildScrollView`, e o toque "é ignorado pelo framework, fazendo com que o callback onPressed nunca seja disparado". Correção: `ensureVisible` (e `unfocus()`) antes de cada toque em "Entrar", nos 5 testes.
- **★ Autoclassificação do modelo:** (A) — "O teste presume um comportamento que não é o especificado."
- **Resultado após correção:** **4/5** — Falhou. O mesmo teste, linha 215.
- **Print:** `evidencias/gemini/FASE3-L4-ZS_iter2.png`

### Iteração 3

- **Motivo da falha:** o mesmo.
- **Prompt de reparo enviado:** template fixo + saída literal de `_iter2.txt` — `..._transcricao/prompt_reparo_iter3.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `..._transcricao/iter3_resposta.md`. **Sem código.** Descreve o esperado (`pushReplacement` para a `TelaInicialScreen`, como no código limpo que recebeu) e o observado (nenhuma `TelaInicialScreen` na árvore, mesmo com o toque garantido). Atribui a causa à `LoginScreen` ser `StatelessWidget` com `GlobalKey` e controllers criados no `build()`: um rebuild no toque perderia o texto digitado ou o `BuildContext`, e pede a refatoração para `StatefulWidget`.
- **★ Autoclassificação do modelo:** (B) — "O teste capturou um comportamento potencialmente incorreto da aplicação."
- **Resultado:** (B) sem patch → arquivo **reexecutado inalterado**, com seed limpo (precedente FASE2-ICRASH-ZS it.3 e L4-ZS do ChatGPT): **4/5**, a mesma falha na linha 215.
- **Print:** `evidencias/gemini/FASE3-L4-ZS_iter3.png`

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A), (A), (B) |
| **★ Classificação humana (auditoria)** | As 4 falhas são o **sintoma do bug L4** (defeito da aplicação, plantado). Nenhuma é erro de teste |
| **★ Concordância** | Não nas iterações 1 e 2; sim na 3 quanto à classe, não quanto à causa |
| **★ Observações** | (1) **A própria saída desmente os dois diagnósticos (A).** Em todas as execuções a asserção `LoginScreen` → `findsNothing`, logo antes da falha, passou. Então o toque chegou ao botão, o login aconteceu e houve navegação, para uma tela que não é a `TelaInicialScreen`. Espera (reparo 1) e viewport (reparo 2) não explicam isso, e o reparo 2 afirma explicitamente que o `onPressed` "nunca" dispara. (2) **O (B) acerta a classe e erra a causa.** O modelo só tinha o código limpo, em que a rota é a `TelaInicialScreen`, e por isso não podia ver a troca para `CadastroScreen`. Inventou uma causa plausível (controllers no `build()` de um `StatelessWidget`), mas ela também não bate com a saída: se o texto digitado se perdesse, a validação barraria e a `LoginScreen` continuaria na árvore. (3) **O teste é bom detector:** afirma o tipo da tela de destino desde a geração, com a mesma assinatura da referência (`não apareceu em 20s: TelaInicialScreen`). Nenhum reparo enfraqueceu essa asserção. (4) Os 4 testes de erro passaram nas 4 execuções, como previsto em `roteiro_manual.md` (idênticos com e sem L4). (5) Comparação com a L4-ZS do ChatGPT: também 4/5 em todas as execuções, (A),(B),(B), Capturou. A diferença é que lá a asserção da geração falhava por outro motivo e o código se definiu na iteração 1; aqui a geração já afirma o tipo da tela e captura na iteração 0. (6) A referência (`_referencia/`) não entrou em nenhum prompt. |

---

## Codificação manual-first (rubrica em `roteiro_manual.md`)

| Campo | Valor |
|---|---|
| **Bug da rodada** | L4 |
| **Sintoma manual de referência** | Passo 5: depois do login válido, o app abre a **CadastroScreen** (formulário vazio, botão "Cadastrar"), sem mensagem de erro; o usuário está autenticado no Auth |
| **O teste chegou ao ponto do sintoma?** | Sim — toca em "Entrar" com as credenciais do seed e afirma a tela de destino |
| **Código** | **Capturou** |
| **Evidência** | `FASE3-L4-ZS_iter3_final.txt` (e as 3 execuções anteriores): `Found 0 widgets with type "TelaInicialScreen"` no teste de sucesso, com `LoginScreen` ausente e os outros 4 verdes; mesma assinatura da referência. O (B) da iteração 3 é coerente com o sintoma, embora a causa apontada esteja errada |
| **Iteração em que o código se define** | 0 |
