# FASE3-E2E-COT-03_playlistFlow — Gemini (rodada limpa)

Rodada 33 do plano (bloco 3 — COT, Gemini). Documentada a partir de
`fase3-e2e/template_rodada.md`. **Executada em 2026-10-06 na segunda máquina
(`DESKTOP-6ETPO2H`)**, em conversa nova, com envio e cópia automatizados
(Claude in Chrome).

**Resultado em uma linha:** 4 cenários gerados; **3/4 na geração → 4/4 na
iteração 1**. Um reparo, **(A)**, com diagnóstico correto: o teste afirmava
"Minha Conta" depois do `Navigator.pop`, mas o `pop` volta à `UsuarioScreen`,
e esse texto só existe na `BottomNavigationBar` da `TelaInicialScreen`. O
reparo trocou a asserção por elementos da própria `UsuarioScreen` sem tirar a
verificação do documento no Firestore.

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-E2E-COT-03_playlistFlow (limpa) |
| **Modelo** | Gemini |
| **Fluxo alvo** | playlist — boas-vindas → `LoginScreen` → `TelaInicialScreen` → `UsuarioScreen` → `CriarPlaylistScreen` |
| **Estado do `lib/`** | limpo — `git diff ccae44a -- lib/` vazio no worktree de execução |
| **Worktree usado** | `C:\Users\Marcos\Desktop\sintonize-fase3`, `fase3-e2e` em `a0ddb46` (nenhum commit posterior a `ccae44a` tocou `lib/`) |
| **Nível da pirâmide** | E2E (integration_test no AVD, emuladores Firebase) |
| **Estratégia de prompt** | Chain-of-Thought |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/cot/FASE3-E2E-COT-03_playlistFlow.md` — sha256 `94c57906d1390802547eb6f402307a81f252df309c4fee24f782fe668218f18b`, igual ao de `_sha256.txt`; 55.879 caracteres enviados (57.525 no editor, o mesmo valor da verificação de infra de 2026-09-29 com este prompt) |
| **✦ Modelo declarado pelo LLM** | Não perguntado (regra das rodadas Gemini) |
| **✦ Verificação externa da versão** | Seletor aberto antes do envio: **3.8 Flash** marcado. Print: `evidencias/gemini/FASE3-E2E-COT-03_playlistFlow_seletor_38flash.jpg` |
| **Sessão** | Gemini logado, conta Pro, 3.8 Flash |
| **Consultou fontes externas?** | Não |
| **Data de acesso** | 2026-10-06 |
| **Conversa nova?** | Sim — `https://gemini.google.com/app/f82eb24ef7ebdcea` (geração e 1 reparo) |
| **Versão do Flutter / AVD / firebase-tools** | 3.41.6 · Dart 3.11.4 / `tcc_e2e` API 34, `emulator-5554` / 15.31.0 |

---

## Procedimento operacional (executado)

- [x] Seletor conferido (3.8 Flash); prompt carregado no clipboard por script, colado por Ctrl+V e conferido no editor por JavaScript (57.525 caracteres; início "Quero que você gere um teste end-to-end…", fim "…para os imports do projeto."); enviado. O primeiro clique na seta não enviou; o segundo enviou — uma única mensagem na conversa (conferido: 1 `user-query`).
- [x] Respostas: Markdown do botão "Copiar" logo abaixo de cada resposta, conferido no clipboard antes de gravar; salvas sem edição em `FASE3-E2E-COT-03_playlistFlow_transcricao/iter{0,1}_resposta.md`.
- [x] Código: único bloco ```dart grande, sem editar, em `integration_test/fase3/playlist_cot_test.dart` (`teste_iter0_geracao.dart` 9.640 caracteres, sha256 `91dc34b6…2976`; `teste_iter1.dart` 8.584, sha256 `98cc3d07…2c2d`). Arquivado em `integration_test/fase3/gemini/playlist_cot_test.dart` (= `teste_iter1.dart`).
- [x] 2 execuções, cada uma com emuladores Firebase subidos de novo, `seed_test` e conferência REST 1/1/5. Saídas `resultados/gemini/FASE3-E2E-COT-03_playlistFlow_iter0.txt`, `_iter1_final.txt`; prints pós-suíte `evidencias/gemini/..._iter{0,1}.png` (nesta máquina o print pós-suíte mostra a tela inicial do Android — o app já foi encerrado pelo `tearDownAll` — e não serve de evidência da falha).
- [x] Reparo: template fixo + saída literal (`prompt_reparo_iter1.txt`, 6.124 caracteres).
- [ ] Manual-first: não se aplica (rodada limpa).

---

## Resposta do LLM

`..._transcricao/iter0_resposta.md`. Passos de raciocínio (análise do fluxo,
dependências, caminho de navegação, cenários) e 4 `testWidgets`, com um helper
de navegação até a `CriarPlaylistScreen` e um `setUp` que desloga e apaga as
playlists do usuário do seed: (1) estados intermediários — indicador de
carregamento e listagem; (2) salvar sem nome → SnackBar "Nome da playlist é
obrigatório" e nenhum documento criado; (3) pesquisa por título e por artista;
(4) fluxo completo — seleção de duas músicas, "Salvar Playlist", retorno à tela
anterior e consulta direta à coleção `playlists` (`userId`, `nome`, `musicas`).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim, nas duas |
| **Testes gerados** | 4 |
| **Testes passaram (iteração 0 / final)** | 3 / 4 |
| **Testes falharam (iteração 0 / final)** | 1 / 0 |
| **Melhor estado intermediário** | = final |
| **Tempo por execução** | iter0: 21 s de teste (Gradle 11 s); iter1: 20 s (11 s) |

### Saída do terminal (iteração 0)

```
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Minha Conta": []>
  file:///C:/Users/Marcos/Desktop/sintonize-fase3/integration_test/fase3/playlist_cot_test.dart:232:7
00:21 +3 -1: Some tests failed.
```

Iteração 1: `00:20 +4: All tests passed!`

---

## Iterative Repair Loop

| It. | Resposta | ★ Autoclassificação | Ação | Resultado |
|---|---|---|---|---|
| 1 | `iter1_resposta.md` — "Minha Conta" pertence só ao `BottomNavigationBarItem` da `TelaInicialScreen`; a `UsuarioScreen` tem outra barra ('Alterar Dados', 'Sair da Conta', 'Excluir Conta'), o texto "Bem-vindo(a), <nome>!" e o item "Criar Playlist"; o `pop` volta a ela. Arquivo completo com as asserções `find.text('Criar Playlist')` e `find.textContaining('Bem-vindo(a)')` no lugar | **(A)** | substituído | **4/4 (final)** |

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) |
| **★ Classificação humana (auditoria)** | **(A) correto.** Depois da iteração 0 a coleção `playlists` do emulador tinha 1 documento (conferido por REST): o `_salvarPlaylist` e o `pop` ocorreram; o que faltava era o texto errado. `grep` em `lib/`: "Minha Conta" só em `tela-inicial.dart:365` |
| **★ Concordância** | Sim, na classe e na causa |
| **★ Observações** | (1) O reparo manteve a verificação do documento no Firestore (`userId`, `nome`, lista de `musicas`) e trocou só a asserção de retorno — não reduziu escopo. As demais diferenças entre `teste_iter0_geracao.dart` e `teste_iter1.dart` são remoção de comentários. (2) O `setUp` apaga as playlists do usuário antes de cada cenário, o que torna a asserção "nenhum documento criado" do cenário 2 independente da ordem. (3) Comparação direta: a COT-03 do ChatGPT (mesmo prompt) não compilou na geração e terminou em 0/4 com (A),(A),(B); aqui, 3/4 → 4/4 com (A). A FS-03 do Gemini tinha dado 1/1 na geração com um único teste; a COT-03 gera 4 cenários e cobre estados intermediários, validação e pesquisa. |
