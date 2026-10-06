# FASE3-E2E-FS-01_loginFlow — Gemini (rodada limpa)

Rodada 19 do plano (bloco 2 — FS, Gemini). Documentada a partir de
`fase3-e2e/template_rodada.md`. **Executada em 2026-10-06 na segunda máquina
(`DESKTOP-6ETPO2H`)**, em conversa nova, com envio e cópia automatizados
(Claude in Chrome; ver README, "Estado em 2026-10-06").

**Resultado em uma linha:** 2 testes gerados; **1/2 nas 4 execuções**. As
asserções dos dois testes passam; o de sucesso é marcado como falho porque,
depois de terminar, a `TelaInicialScreen` chama `setState()` já descartada
(`tela-inicial.dart:161`, `_loadLastRecommendedMusic` sem checar `mounted`).
**(B), (B), (B)**, os três sem código, com o diagnóstico certo.

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-E2E-FS-01_loginFlow (limpa) |
| **Modelo** | Gemini |
| **Fluxo alvo** | login — boas-vindas → `LoginScreen` → `TelaInicialScreen` |
| **Estado do `lib/`** | limpo — `git diff ccae44a -- lib/` vazio no worktree de execução |
| **Worktree usado** | `C:\Users\Marcos\Desktop\sintonize-fase3`, `fase3-e2e` em `c99c3f9` |
| **Estratégia de prompt** | Few-shot |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/few-shot/FASE3-E2E-FS-01_loginFlow.md` — sha256 `926c6b8598ad69e1e10bd1f28fec0322cc3e8642770e1fc3a4a49a4ab6639df3`; 35.008 caracteres enviados |
| **✦ Modelo declarado pelo LLM** | Não perguntado (regra das rodadas Gemini) |
| **✦ Verificação externa da versão** | Seletor aberto antes do envio: **3.8 Flash** marcado. Print: `evidencias/gemini/FASE3-E2E-FS-01_loginFlow_seletor_38flash.png` |
| **Sessão** | Gemini logado, conta Pro, 3.8 Flash |
| **Consultou fontes externas?** | Não |
| **Data de acesso** | 2026-10-06 |
| **Conversa nova?** | Sim — `https://gemini.google.com/app/e3835be693713043` (geração e 3 reparos) |
| **Versão do Flutter / AVD / firebase-tools** | 3.41.6 · Dart 3.11.4 / `tcc_e2e` API 34, `emulator-5554` / 15.31.0 |

---

## Procedimento operacional (executado)

- [x] Seletor conferido (3.8 Flash), prompt colado por automação e conferido no editor (início "Gere um teste end-to-end…", fim "…para os imports do projeto."), enviado.
- [x] Resposta: Markdown do botão "Copiar" da resposta, capturado na página e levado ao clipboard por um botão injetado e clicado (ver "Ocorrências"); salvo sem edição em `FASE3-E2E-FS-01_loginFlow_transcricao/iter0_resposta.md`.
- [x] Código: maior bloco ```dart, sem editar, em `integration_test/fase3/login_fs_test.dart`; o modelo sugeriu `login_test.dart`. Arquivado em `integration_test/fase3/gemini/login_fs_test.dart` (sha256 `90becfc65c27728ff51962990d2c551f7cbf378ab6d2ca12f7b64c86defffaf0`); o arquivo não mudou na rodada (`teste_iter0_geracao.dart` idêntico).
- [x] 4 execuções, cada uma com emuladores reiniciados, `seed_test` e conferência REST 1/1/5. Saídas `resultados/gemini/FASE3-E2E-FS-01_loginFlow_iter{0,1,2}.txt`, `_iter3_final.txt`; prints pós-suíte `evidencias/gemini/..._iter{0..3}.png`.
- [x] Reparos: template fixo + saída literal (`prompt_reparo_iter{1,2,3}.txt`, 6.760 caracteres cada).
- [ ] Manual-first: não se aplica (rodada limpa).

### Ocorrências de operação (automação)

1. O primeiro clique na seta de envio, por JavaScript, não enviou na tela de conversa nova; o envio foi feito com clique real.
2. A página do Gemini deixa de atualizar o texto e o rodapé da resposta quando a janela do Chrome está em segundo plano. Procedimento adotado: esperar a geração e recarregar a URL da conversa (logada; nada se perde) antes de copiar.
3. O clique no botão "Copiar" do Gemini deixou de gravar no clipboard do sistema depois do recarregamento, e um Ctrl+C sintético também falhou. O que funcionou: interceptar o texto que o botão "Copiar" da resposta entrega a `navigator.clipboard`, e copiá-lo com um botão injetado na página, clicado de verdade logo depois de um screenshot. Na geração, uma primeira gravação saiu com o conteúdo errado (o prompt ainda no clipboard) e foi **apagada antes de qualquer uso**; o `save_resp.py` passou a recusar gravar quando o clipboard começa com o texto de um prompt. Uma leitura de diagnóstico por `get_page_text` confirmou o conteúdo do reparo 1 contra a página.

---

## Resposta do LLM

`..._transcricao/iter0_resposta.md`. Dois `testWidgets` com um auxiliar
`esperar` (laço de `pump(250 ms)`, como no exemplo do prompt) e
`abrirTelaLogin`:

1. **sucesso:** login com o usuário do seed, espera a `TelaInicialScreen`, afirma `LoginScreen` ausente, `TelaInicialScreen` presente e "Minha Conta";
2. **falha:** credenciais inexistentes, espera o SnackBar, confere fundo vermelho e uma de duas mensagens ("Usuário não encontrado" / "As credenciais fornecidas são inválidas"), e que continua na `LoginScreen`.

Não afirma a saudação.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim, nas quatro |
| **Testes gerados** | 2 |
| **Testes passaram (iteração 0 / final)** | 1 / 1 (o de falha) |
| **Testes falharam (iteração 0 / final)** | 1 / 1 — o de sucesso, por exceção depois do fim do teste |
| **Melhor estado intermediário** | 1/2 em todas |
| **Tempo por execução** | 10–11 s de teste (Gradle ~22 s) |

### Saída do terminal (iteração 0)

```
The following assertion was thrown running a test (but after the test had completed):
setState() called after dispose(): _TelaInicialScreenState#5b8ab(lifecycle state: defunct, not mounted)
#2      _TelaInicialScreenState._loadLastRecommendedMusic (package:sintonize/tela-inicial.dart:161:5)
00:11 +1 -1: Some tests failed.
```

---

## Iterative Repair Loop

| It. | Resposta | ★ Autoclassificação | Ação | Resultado |
|---|---|---|---|---|
| 1 | `iter1_resposta.md` — sem patch no teste. Aponta `_loadLastRecommendedMusic` chamado no `initState` e o `setState` incondicional depois do `await` do Firestore; propõe `if (!mounted) return;` no app e nota o mesmo risco em `_fetchNewMusic` | **(B)** | arquivo reexecutado inalterado | 1/2 |
| 2 | `iter2_resposta.md` — sem patch. Mesmo diagnóstico, mais curto | **(B)** | reexecutado inalterado | 1/2 |
| 3 | `iter3_resposta.md` — sem patch. Mesmo diagnóstico | **(B)** | reexecutado inalterado | **1/2 (final)** |

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (B), (B), (B) |
| **★ Classificação humana (auditoria)** | **Defeito pré-existente da aplicação** (real, não plantado): `setState` sem `mounted` em `tela-inicial.dart:159–163`, conferido no `lib/` limpo. Ele aparece porque o teste de sucesso termina logo que a `TelaInicialScreen` surge, antes do fim do carregamento do Firestore; o framework desmonta a tela e a resposta chega depois |
| **★ Concordância** | **Sim**, nas três: classe e causa corretas, com arquivo, linha e correção |
| **★ Observações** | (1) **É o mesmo defeito que a FS-01 do ChatGPT encontrou**, lá só na iteração 2 (nas outras, a causa dominante era uma asserção de transição). Aqui ele derruba as 4 execuções, porque a asserção de transição do Gemini espera certo. (2) O teste da geração é bom: espera ativa como no exemplo, sem asserções frágeis; a única "correção" possível no teste seria esperar o carregamento terminar (por exemplo, a saudação), o que o modelo, com razão, não fez para não esconder o defeito. (3) Comparação com a ZS-01 do Gemini (5/5): lá o teste esperava a saudação, e o carregamento terminava antes do fim do teste. |
