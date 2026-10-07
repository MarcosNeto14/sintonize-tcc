# FASE3-C3-COT — Gemini (rodada com bug C3)

Rodada 35 do plano (bloco 3 — COT, Gemini). Documentada a partir de
`fase3-e2e/template_rodada.md`. **Executada em 2026-10-06 na segunda máquina
(`DESKTOP-6ETPO2H`)**, em conversa nova, com envio e cópia automatizados
(Claude in Chrome). O prompt é o de `FASE3-E2E-COT-02_cadastroFlow` (o mesmo da
rodada limpa, sem menção a bug); o teste roda no worktree com o C3 ativo.

**Resultado em uma linha:** 5 cenários gerados; **2/5 na geração → 5/5 na
iteração 1**, com o C3 ativo. Um reparo, **(A)**: finder do dropdown de estado,
espera pelo `FutureBuilder` da saudação, ViaCEP e SnackBars assíncronas. O
fluxo completo chega à `TelaInicialScreen` e afirma só o trecho genérico da
saudação ("essa é a nossa recomendação de música para você!"), nunca o nome —
e o documento gravado tem `nome` = e-mail. **Manual-first: Viu sem asserção.**

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-C3-COT (bug C3) |
| **Modelo** | Gemini |
| **Fluxo alvo** | cadastro — boas-vindas → `CadastroScreen` → `GenerosCadastroScreen` → `TelaInicialScreen` |
| **Bug ativo** | C3 — `lib/cadastro.dart:149`, `'nome': _nomeController.text` → `_emailController.text` |
| **Estado do `lib/`** | worktree em `20edaaa`; `git diff --stat 20edaaa -- lib/` vazio; `git diff ccae44a -- lib/` só em `lib/cadastro.dart` (1 linha), conferido antes da geração |
| **Worktree usado** | `C:\Users\Marcos\Desktop\sintonize-fase3-C3`, detached em `20edaaa`. `firebase_test_helper.dart` idêntico ao da ponta da `fase3-e2e` (`cmp`); `seed.dart` e `seed_test.dart` iguais a menos de CRLF |
| **Nível da pirâmide** | E2E (integration_test no AVD, emuladores Firebase) |
| **Estratégia de prompt** | Chain-of-Thought |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/cot/FASE3-E2E-COT-02_cadastroFlow.md` — sha256 `080dd497c83a40053c4222e2ca7e547ab4da71ce1c4575b678c445476189185a`, igual ao de `_sha256.txt`; 50.897 caracteres enviados (52.381 no editor, os mesmos valores da COT-02 limpa) |
| **✦ Modelo declarado pelo LLM** | Não perguntado (regra das rodadas Gemini) |
| **✦ Verificação externa da versão** | Seletor aberto antes do envio: **3.8 Flash** marcado. Print: `evidencias/gemini/FASE3-C3-COT_seletor_38flash.jpg` |
| **Sessão** | Gemini logado, conta Pro, 3.8 Flash |
| **Consultou fontes externas?** | Não |
| **Data de acesso** | 2026-10-06 |
| **Conversa nova?** | Sim — `https://gemini.google.com/app/ac10df8022157b89` (geração e 1 reparo) |
| **Versão do Flutter / AVD / firebase-tools** | 3.41.6 · Dart 3.11.4 / `tcc_e2e` API 34, `emulator-5554` / 15.31.0 |

---

## Procedimento operacional (executado)

- [x] Seletor conferido (3.8 Flash); prompt carregado no clipboard por script, colado por Ctrl+V e conferido no editor por JavaScript (52.381 caracteres; início "Quero que você gere um teste end-to-end…", fim "…para os imports do projeto."); enviado com um clique (a leitura por JavaScript logo depois ainda mostrava o editor cheio; a captura de tela mostrava a mensagem enviada — não houve reenvio).
- [x] Respostas: Markdown do botão "Copiar" logo abaixo de cada resposta, conferido no clipboard antes de gravar; salvas sem edição em `FASE3-C3-COT_transcricao/iter{0,1}_resposta.md`.
- [x] Código: maior bloco ```dart, sem editar, em `integration_test/fase3/c3_cot_test.dart` **do worktree C3** (o modelo nomeou `cadastro_generos_flow_test.dart` na geração e `c3_cot_test.dart` no reparo). `teste_iter0_geracao.dart` (10.916 caracteres, sha256 `a8071f63…1b3e`); `teste_iter1.dart` (11.530, sha256 `98e9329c…a32b`). Arquivado em `integration_test/fase3/gemini/c3_cot_test.dart` (= `teste_iter1.dart`).
- [x] 2 execuções, cada uma com emuladores Firebase derrubados e subidos de novo, `seed_test` **no worktree C3** e conferência REST 1/1/5. Saídas `resultados/gemini/FASE3-C3-COT_iter0.txt`, `_iter1_final.txt`; prints pós-suíte `evidencias/gemini/FASE3-C3-COT_iter{0,1}.png` (tela inicial do Android; o app já foi encerrado pelo `tearDownAll`).
- [x] Reparo: template fixo + saída literal (`prompt_reparo_iter1.txt`, 12.212 caracteres).
- [x] Codificação manual-first feita (abaixo).

### Ocorrências de operação

1. **Colisão de nome no worktree C3.** O worktree tinha `integration_test/fase3/c3_cot_test.dart` da rodada C3-COT do ChatGPT (pendente, decisão do autor). O arquivo é byte-idêntico à cópia arquivada em `integration_test/fase3/chatgpt/c3_cot_test.dart` e a `FASE3-C3-COT_transcricao/teste_iter0_geracao.dart` do ChatGPT (sha256 `62a99852…3e3d`); foi renomeado para `c3_cot_test.dart.chatgpt-pendente` durante esta rodada e devolvido ao nome original ao fim, sem alteração (sha conferido).
2. **Conferência do bug nos dados**, fora do protocolo e sem efeito na rodada: depois de cada execução, os documentos `usuarios/*` criados pelo teste têm `nome` igual ao e-mail (`novo_usuario_…@sintonize.test` na iteração 0; `novo_user_…@sintonize.test` e `sem_genero_…@sintonize.test` na iteração 1), lidos por REST no emulador. O modelo não viu nada disso.

---

## Resposta do LLM

`..._transcricao/iter0_resposta.md`. Passos de raciocínio (análise do fluxo,
dependências — ViaCEP, Auth, Firestore, seed —, caminho de navegação, cenários)
e 5 `testWidgets`: fluxo completo com nome "Usuario Teste" (afirma
`GenerosCadastroScreen`, o título da tela de gêneros, `TelaInicialScreen` e o
trecho "essa é a nossa recomendação de música para você!"), campos vazios,
regras de formato e senhas divergentes, e-mail já cadastrado (SnackBar "Erro ao
cadastrar:") e gêneros sem seleção. Campos localizados por `find.byType(TextFormField).at(i)`.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim, nas duas |
| **Testes gerados** | 5 |
| **Testes passaram (iteração 0 / final)** | 2 / 5 |
| **Testes falharam (iteração 0 / final)** | 3 / 0 |
| **Melhor estado intermediário** | = final |
| **Tempo por execução** | iter0: 42 s de teste (Gradle 13 s); iter1: 27 s (11 s) |

### Saída do terminal (iteração 0)

```
Expected: exactly one matching candidate
  Actual: _TextContainingWidgetFinder:<Found 0 widgets with text containing essa é a nossa
recomendação de música para você!: []>
  ... c3_cot_test.dart:114:7   (cenário 1)
  Actual: _TextContainingWidgetFinder:<Found 0 widgets with text containing Erro ao cadastrar:: []>
  ... c3_cot_test.dart:209:7   (cenário 4)
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Selecione pelo menos um gênero musical!": []>
  ... c3_cot_test.dart:254:7   (cenário 5)
00:42 +2 -3: Some tests failed.
```

Iteração 1: `00:27 +5: All tests passed!`

---

## Iterative Repair Loop

| It. | Resposta | ★ Autoclassificação | Ação | Resultado |
|---|---|---|---|---|
| 1 | `iter1_resposta.md` — cenário 1: 'PE' fora da área visível do menu de 27 estados e `fetchUserName()` assíncrono (cita o `FutureBuilder` com "Carregando…"); cenário 4: estado não preenchido e o `onChanged` do CEP chamando o ViaCEP; cenário 5: SnackBar assíncrona. Arquivo completo com `waitFor` (polling de 10 s), rolagem por `drag`, nome "Marcos Silva", sem abrir o dropdown | **(A)** | substituído | **5/5 (final)** |

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) |
| **★ Classificação humana (auditoria)** | **(A) correto** para as três falhas da iteração 0: na iteração 0 o cenário 1 já tinha passado por `find.byType(TelaInicialScreen)` (linha 113) e caiu só no texto da saudação, que o `FutureBuilder` ainda não tinha resolvido; os cenários 4 e 5 esperavam SnackBars sem polling. Nenhuma das três falhas é o C3 |
| **★ Concordância** | Sim, na classe e nas causas principais. A causa do cenário 4 ("não preencheu o campo de estado") não procede — o campo não tem validador —, mas o reparo acertou pelo polling |
| **★ Observações** | (1) **O verde é com o bug ativo.** A saudação na tela diz "Novo_user_…@sintonize.test, essa é a nossa recomendação de música para você!" (o e-mail no lugar do nome, com a primeira letra em maiúscula pelo `_formatName`), e `textContaining('essa é a nossa recomendação…')` casa com ela. O modelo teve o nome na mão duas vezes — "Usuario Teste" na geração, "Marcos Silva" no reparo — e o diagnóstico do reparo 1 chega a escrever o texto completo esperado ("Usuario Teste, essa é a nossa recomendação…"), mas a asserção ficou no trecho sem o nome. (2) Nenhum reparo removeu asserções; o reparo 1 trocou a abertura do dropdown por não selecionar estado (campo opcional), como na COT-02 limpa. (3) Mesmo padrão da C3-ZS do Gemini (Não viu) na direção oposta ao da C3-FS (Capturou, porque afirmava `dados['nome']`): o que decide é se o nome entra na asserção. (4) Comparação direta: a C3-COT do ChatGPT está pendente (1/11 na geração, reparo 1 sem resposta do serviço). |

---

## ★ Codificação manual-first

| Campo | Valor |
|---|---|
| **Código** | **Viu sem asserção** |
| **Iteração em que se define** | 0 (não muda na 1) |
| **Evidência** | O teste de sucesso chega ao passo 14 do roteiro (a `TelaInicialScreen`, onde o sintoma está) nas duas execuções e afirma o tipo da tela e o trecho da saudação que não contém o nome; a asserção passa com "Novo_user_…@sintonize.test, essa é a nossa recomendação…" na tela. O passo 10 (campo `nome` do documento) não é verificado. É exatamente o caso que o roteiro descreve: "chega à TelaInicialScreen e só verifica o tipo da tela" — aqui, o tipo e o sufixo fixo da frase |
