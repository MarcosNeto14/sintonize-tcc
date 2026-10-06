# FASE3-E2E-COT-02_cadastroFlow — Gemini (rodada limpa)

Rodada 32 do plano (bloco 3 — COT, Gemini). Documentada a partir de
`fase3-e2e/template_rodada.md`. **Executada em 2026-10-06 em duas máquinas,
na mesma conversa:** geração e reparo 1 na máquina original (`DellT4i51`),
interrompida por troca de máquina (nota `_PENDENTE.md`, agora removida);
reparos 2 e 3 na segunda máquina (`DESKTOP-6ETPO2H`). Envio e cópia
automatizados (Claude in Chrome) nas quatro mensagens.

**Resultado em uma linha:** 4 cenários gerados; **0/4 → 1/4 → 1/4 → 3/4
(final)**. **(A), (A), (A)**, sempre com arquivo completo. O que sobra no fim é
o cenário do e-mail já cadastrado: o teste espera "a primeira SnackBar" e a
primeira que aparece é a do ViaCEP ("CEP não encontrado"), não a do Auth.

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-E2E-COT-02_cadastroFlow (limpa) |
| **Modelo** | Gemini |
| **Fluxo alvo** | cadastro — boas-vindas → `CadastroScreen` → `GenerosCadastroScreen` → `TelaInicialScreen` |
| **Estado do `lib/`** | limpo — `git diff ccae44a -- lib/` vazio nos dois worktrees de execução |
| **Worktree usado** | Máquina original: `C:\Users\marcos.neto\Desktop\sintonize-fase3`, detached em `dc88352` (geração, iteração 1). Segunda máquina: `C:\Users\Marcos\Desktop\sintonize-fase3`, `fase3-e2e` em `2674990` (iterações 2 e 3). `git diff --stat dc88352 2674990 -- lib/ integration_test/seed_test.dart integration_test/firebase_test_helper.dart` vazio |
| **Nível da pirâmide** | E2E (integration_test no AVD, emuladores Firebase) |
| **Estratégia de prompt** | Chain-of-Thought |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/cot/FASE3-E2E-COT-02_cadastroFlow.md` — sha256 `080dd497c83a40053c4222e2ca7e547ab4da71ce1c4575b678c445476189185a`, igual ao de `_sha256.txt`; 50.897 caracteres enviados (52.381 no editor) |
| **✦ Modelo declarado pelo LLM** | Não perguntado (regra das rodadas Gemini) |
| **✦ Verificação externa da versão** | Seletor aberto antes do envio: **3.8 Flash** marcado. Print: `evidencias/gemini/FASE3-E2E-COT-02_cadastroFlow_seletor_38flash.png`. Na segunda máquina a conversa reaberta mostrava "Flash" no seletor |
| **Sessão** | Gemini logado, conta Pro, 3.8 Flash |
| **Consultou fontes externas?** | Não |
| **Data de acesso** | 2026-10-06 |
| **Conversa nova?** | Sim — `https://gemini.google.com/app/3968b3e7d43db829` (geração e 3 reparos) |
| **Versão do Flutter / AVD / firebase-tools** | 3.41.6 · Dart 3.11.4 / `tcc_e2e` API 34, `emulator-5554` / 15.31.0 (as duas máquinas) |

---

## Procedimento operacional (executado)

- [x] Seletor conferido (3.8 Flash); prompt colado por Ctrl+V e conferido no editor (início "Quero que você gere um teste end-to-end…", fim "…para os imports do projeto."); enviado. O primeiro clique na seta não enviou; o segundo enviou (uma única mensagem na conversa).
- [x] Respostas: Markdown do botão "Copiar" logo abaixo de cada resposta, conferido no clipboard antes de gravar; salvas sem edição em `FASE3-E2E-COT-02_cadastroFlow_transcricao/iter{0..3}_resposta.md`.
- [x] Código: maior bloco ```dart, sem editar, em `integration_test/fase3/cadastro_cot_test.dart`. Os três reparos trouxeram arquivo completo (`teste_iter1.dart` 11.779, `teste_iter2.dart` 12.158, `teste_iter3.dart` 11.286 caracteres). Arquivado em `integration_test/fase3/gemini/cadastro_cot_test.dart` (sha256 `6b7dd436f6abbe01bf0540dc1273d554b69a806ead00b1986346c5edcaa20516`, igual a `teste_iter3.dart`).
- [x] 4 execuções, cada uma com emuladores Firebase subidos de novo, `seed_test` e conferência REST 1/1/5. Saídas `resultados/gemini/FASE3-E2E-COT-02_cadastroFlow_iter{0,1,2}.txt`, `_iter3_final.txt`; prints pós-suíte `evidencias/gemini/..._iter{0..3}.png`.
- [x] Reparos: template fixo + saída literal (`prompt_reparo_iter{1,2,3}.txt`; 15.286, 22.959 e 14.352 caracteres). Reparos 2 e 3 montados por `mk_repair.py` (mesmo template, mesma substituição).
- [ ] Manual-first: não se aplica (rodada limpa).

### Ocorrências de operação

1. **Troca de máquina entre as iterações 1 e 2.** A conversa é logada e foi reaberta pela URL na segunda máquina; o modelo não recebeu nada entre o reparo 1 e o reparo 2 além do que está nas transcrições. O worktree da segunda máquina está em `2674990` (ponta da branch), que difere de `dc88352` só em docs e scripts — `lib/`, seed e helper são idênticos. O `teste_iter1.dart` foi reaplicado por cópia e conferido por `cmp` antes do reparo 2.
2. **Execução de auditoria fora do protocolo**, depois da iteração 3: `flutter test … --name "Cenário 3"` com o arquivo final inalterado, só para tentar o print da tela na falha (`resultados/gemini/..._auditoria_cenario3.txt`, `evidencias/gemini/..._auditoria_cenario3.png`). Reproduziu a mesma falha (0/1, 7 s). O print pegou a tela inicial do Android — o app já tinha sido encerrado pelo `tearDownAll` — e não serve de evidência da SnackBar. **Não conta como iteração**; o modelo não viu essa saída.

---

## Resposta do LLM

`..._transcricao/iter0_resposta.md`. Passos de raciocínio (análise do fluxo,
dependências em tabela — inclusive o ViaCEP como "HTTP real" —, caminho de
navegação, cenários, decisões) e 4 `testWidgets`: fluxo completo até a
`TelaInicialScreen` (com 'Rock' marcado), validação local (nome, data, senhas),
e-mail já cadastrado (`tester@sintonize.test`, espera SnackBar com "Erro ao
cadastrar:") e gêneros sem seleção (SnackBar "Selecione pelo menos um gênero
musical!"). Localiza os campos por `find.widgetWithText(TextFormField, '').at(i)`.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim, nas quatro |
| **Testes gerados** | 4 |
| **Testes passaram (iteração 0 / final)** | 0 / 3 |
| **Testes falharam (iteração 0 / final)** | 4 / 1 — o do e-mail já cadastrado |
| **Melhor estado intermediário** | = final (3/4) |
| **Tempo por execução** | iter0: 32 s de teste (Gradle 55 s); iter1: 53 s (75 s); iter2: 26 s (27 s); iter3: 25 s (12 s) |

### Saída do terminal

Iteração 0 (cenários 1, 3 e 4; o 2 cai na mensagem de e-mail):
```
RangeError (index): Index out of range: index should be less than 5: 5
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "E-mail inválido": []>
00:32 +0 -4: Some tests failed.
```

Iteração 1 (cenários 1 e 4; o 3 na SnackBar):
```
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 0 widgets with type "GenerosCadastroScreen": []>
  Actual: _TextContainingWidgetFinder:<Found 0 widgets with text containing Erro ao cadastrar:: []>
This widget has been unmounted, so the State no longer has a context ... _CadastroScreenState._submit (package:sintonize/cadastro.dart:176:30)
00:53 +1 -3: Some tests failed.
```

Iteração 2 (cenários 1 e 4 no dropdown de estado; o 3 na SnackBar):
```
Bad state: No element
Warning: A call to tap() with finder "... DropdownMenuItem<String> ... "AC" ..." derived an Offset (Offset(209.7, 80.0)) that would not hit test on the specified widget.
  Actual: _TextContainingWidgetFinder:<Found 0 widgets with text containing Erro ao cadastrar:: []>
00:26 +1 -3: Some tests failed.
```

Iteração 3 (final — só o cenário 3):
```
Expected: exactly one matching candidate
  Actual: _TextContainingWidgetFinder:<Found 0 widgets with text containing Erro ao cadastrar:: []>
  file:///C:/Users/Marcos/Desktop/sintonize-fase3/integration_test/fase3/cadastro_cot_test.dart line 206
00:25 +3 -1: Some tests failed.
```

---

## Iterative Repair Loop

| It. | Resposta | ★ Autoclassificação | Ação | Resultado |
|---|---|---|---|---|
| 1 | `iter1_resposta.md` — `widgetWithText(TextFormField, '')` não casa os campos (o rótulo é um `Text` acima); troca por `find.descendant` a partir do rótulo + `scrollUntilVisible`; "E-mail inválido" porque o nome é validado antes; arquivo completo | **(A)** | substituído | 1/4 (cenário 2 passa; 1 e 4 não chegam à `GenerosCadastroScreen`; 3 sem a SnackBar do Auth) |
| 2 | `iter2_resposta.md` — o toque em 'PE' no dropdown de estado não acerta o item (lista de 27 fora do viewport); `pumpAndSettle` volta antes do I/O de rede; cita o `onChanged` do CEP e o `_submit` após desmontar; arquivo com espera ativa (`esperarElemento`) e 'AC' no lugar de 'PE' | **(A)** | substituído | 1/4 (`Bad state: No element` ao tocar 'AC'; 3 igual) |
| 3 | `iter3_resposta.md` — `DropdownMenuItem` já existe na árvore antes de abrir o menu, daí a ambiguidade; o campo Estado não tem validador, então deixa de abrir o dropdown; para o cenário 3 diz que o `_submit` nunca disparou porque o menu cobria o botão; arquivo completo | **(A)** | substituído | **3/4 (final)** — cenário 3 continua |

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A), (A), (A) |
| **★ Classificação humana (auditoria)** | Reparo 1: **(A) correto** (finder errado para os campos). Reparo 2: **(A) correto** (toque fora do item e espera insuficiente), mas o reparo trocou um item inalcançável por outro e manteve a abertura do menu. Reparo 3: **(A) correto** para os cenários 1 e 4; para o cenário 3 a classe está certa e a causa, errada |
| **★ Concordância** | Sim na classe, nas três. No diagnóstico: sim no 1; parcial no 2 e no 3 (ver abaixo) |
| **★ Observações** | (1) **Cenário 3 — a SnackBar encontrada é a do ViaCEP, não a do Auth.** A asserção da linha 205 (`find.byType(SnackBar)`, `findsOneWidget`) passou; a da 206 (`textContaining('Erro ao cadastrar:')`) falhou — logo havia uma SnackBar na tela, com outro texto. O campo CEP termina com `_CEPInputFormatter`, que insere o hífen: `enterText('50000000')` vira `50000-000`, 9 caracteres, e o `onChanged` chama `_fetchAddressFromCEP('50000000')` (`cadastro.dart:314`). O ViaCEP responde `{"erro": "true"}` para esse CEP (conferido por `curl` em 2026-10-06), e o app mostra a SnackBar "CEP não encontrado" (`cadastro.dart:62`). O `esperarElemento` do teste pega a primeira SnackBar que aparece — essa — e a de "Erro ao cadastrar:" ainda não existe (ou fica na fila do `ScaffoldMessenger`). **É erro de teste (A)**, mas a causa que o modelo deu no reparo 3 ("o `_submit` nunca disparou") não se sustenta: na iteração 3 o cenário 1 passa pelo mesmo botão sem dropdown. A própria resposta de geração listou o ViaCEP como dependência HTTP real e o reparo 2 citou o `onChanged` do CEP, mas nenhum reparo isolou essa chamada nem escolheu um CEP existente. Isso também é a prova que faltou na ZS-02 do Gemini (observação 1 daquela rodada, "hipótese não verificada"): a consulta ao ViaCEP dispara, sim, com 8 dígitos digitados. (2) **Nenhum reparo removeu asserção de destino nem reduziu escopo:** a `TelaInicialScreen` do cenário 1 e as SnackBars dos cenários 3 e 4 continuam afirmadas no arquivo final. (3) Comparação direta: a COT-02 do ChatGPT (mesmo prompt) não compilou na geração e terminou em 4/11 (11 testes) com (A),(B),(B); aqui, 3/4 (4 testes) com (A),(A),(A). (4) Esta rodada é a primeira do Gemini cujas iterações se dividiram entre duas máquinas (confundidor registrado nas ocorrências); a falha restante é determinística (reproduzida na execução de auditoria) e não depende de tempo de resposta. |
