# FASE2-WCRASH-FS — Réplica Gemini

Rodada **8/60**. Primeira rodada da réplica a esgotar as 3 iterações de
reparo e a terminar com falhas.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WCRASH-FS |
| **Bug ID** | W-CRASH |
| **Função/tela alvo** | `CriarPlaylistScreen._filterMusicas` |
| **Arquivo(s) de origem** | `lib/criar_playlist.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada — ver `../unit/FASE2-UCRASH-ZS.md`. |
| **✦ Verificação externa da versão** | Seletor do app com `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-21 |
| **Conversa nova?** | Sim |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-piloto`, 6 bugs plantados ativos |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/widget/wcrash_fs_test.dart` |
| **Saídas arquivadas** | `resultados/widget/FASE2-WCRASH-FS_iter{0,1,2,3_final}.txt` |
| **Modo de execução** | Manual (operador colou prompt e respostas) |

### Execução anterior perdida

Esta rodada foi tentada uma primeira vez em execução automatizada. Houve
**2 recusas** e depois uma resposta completa, mas a conversa foi apagada
antes de a resposta ser capturada. Como não há artefato recuperável, aquela
tentativa **não entra em nenhuma contagem** — fica só o registro de que as
2 recusas ocorreram e foram observadas. A rodada documentada aqui é uma
execução nova e completa, sem recusas.

---

## O bug plantado

`_filterMusicas` faz `musica['artist_name'].toLowerCase()` sem null-safety.
No mesmo arquivo, o `itemBuilder` usa `musica['artist_name'] ?? 'Desconhecido'`.

## A ajuda ausente — desvio preservado da Fase 2

Dos três prompts de W-CRASH, **só o FS não traz a linha informando
`import 'package:sintonize/criar_playlist.dart';`**. ZS e COT trazem. A ajuda
foi introduzida na Fase 2 porque `CriarPlaylistScreen` teve **0% de aprovação
nas 3 estratégias da Fase 1, por alucinação de caminho de import** (ver o
README da réplica, seção "Desvios preservados de propósito").

Esta rodada é o caso de controle acidental dessa ajuda: sem ela, o mesmo
defeito voltou.

---

## Prompt Enviado

Verbatim, de `fase2-gemini/prompts_prontos/FASE2-WCRASH-FS.md`, do separador
`---` em diante. Traz um exemplo few-shot de widget test com Firebase mockado
(`MeuFormulario`), o código do widget alvo e a lista de dependências de mock.
**Não traz a linha de ajuda do caminho de import.**

---

## Resposta do LLM — geração inicial

5 testes, cobrindo: SnackBar de campo obrigatório, listagem vinda do
Firestore, alternância de checkbox, filtro de busca e persistência.

A primeira linha de import do arquivo gerado:

```dart
import 'package:sintonize/screens/criar_playlist_screen.dart'; // Ajuste o caminho conforme sua estrutura de pastas
```

Caminho inexistente. O widget real está em `lib/criar_playlist.dart`.

O bug W-CRASH **não foi mencionado** e **nenhum teste o captura** — como na
rodada 7, todos os documentos de mock trazem `artist_name` preenchido.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Não** |
| **Testes gerados** | 5 |
| **Testes passaram (1ª execução)** | 0 |
| **Testes falharam (1ª execução)** | — (falha de compilação, nenhum teste chegou a rodar) |
| **Iterações de reparo** | **3 (máximo do protocolo)** |
| **Testes passaram (pós-repair)** | **3** |
| **Testes falharam (pós-repair)** | **2** |
| **Tentativas de envio até obter resposta** | 1 |
| **Bug plantado capturado por asserção?** | **Não** |
| **Bug plantado mencionado na resposta?** | **Não** |

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** `Error when reading 'lib/screens/criar_playlist_screen.dart'`
  + `Method not found: 'CriarPlaylistScreen'`.
- **★ Autoclassificação do modelo:** **(A)** — declarada explicitamente e
  **correta**: *"A falha ocorreu em tempo de compilação antes de qualquer
  execução de asserção lógica (...). O teste supôs um caminho de importação
  arbitrário."*
- **Correção proposta:** `import 'package:sintonize/criar_playlist_screen.dart';`
  — **segundo caminho inventado**. O modelo ofereceu ainda um menu de
  alternativas (`views/`, `pages/`, caminho relativo `../../lib/...`) e um
  `// TODO` pedindo ao operador que ajustasse.
- **Resultado:** **Falhou** — mesma classe de erro.
- Saída: `FASE2-WCRASH-FS_iter1.txt`

### Iteração 2

- **Motivo da falha:** `Error when reading 'lib/criar_playlist_screen.dart'`.
- **★ Autoclassificação do modelo:** **(A)**, novamente correta.
- **Correção proposta:** `import 'package:sintonize/telas/criarPlaylist.dart';`
  — **terceiro caminho inventado**, desta vez afirmado como fato:

  > "No projeto Sintonize, as telas ficam organizadas dentro de `lib/telas/`
  > (especificamente `criarPlaylist.dart`)."

  **Nada no prompt sustenta essa afirmação.** O prompt informa apenas que o
  widget "faz parte do projeto Flutter sintonize". O modelo passou de
  "suposição arbitrária" — como ele mesmo classificou na iteração 1 — para
  asserção confiante sobre uma estrutura de diretórios que não existe.
- **Regressão introduzida no mesmo passo:** no teste de filtro, a asserção
  *anterior* à busca mudou de `findsOneWidget` para `findsNothing`:

  ```dart
  expect(find.text('In The End - Linkin Park'), findsNothing);  // antes de filtrar
  ```

  Passa a afirmar que a música não está na lista antes de qualquer filtro.
  É falso e é a causa direta de uma das duas falhas finais.
- **Resultado:** **Falhou** — mesma classe de erro.
- Saída: `FASE2-WCRASH-FS_iter2.txt`

### Iteração 3 (máximo)

- **Motivo da falha:** `Error when reading 'lib/telas/criarPlaylist.dart'`.
- **★ Autoclassificação do modelo:** **(A)**, pela terceira vez.
- **Correção proposta:** o modelo **desistiu do import e colou a declaração
  completa de `CriarPlaylistScreen` dentro do próprio arquivo de teste**:

  > "o teste pode incluir a própria declaração do widget fornecido no mesmo
  > arquivo de teste (...) garantindo que o arquivo compile e execute
  > imediatamente de forma auto-contida independente da estrutura de
  > diretórios do projeto"

- **Resultado:** **compilou**, mas **3 passaram e 2 falharam**.
- Saída: `FASE2-WCRASH-FS_iter3_final.txt`

O ciclo termina aqui pelo limite de 3 iterações.

### As duas falhas remanescentes

**1. `deve exibir SnackBar de erro se tentar salvar sem nome preenchido`** —
`pumpAndSettle timed out`.

Esse teste não popula a coleção `musica`. Com a lista vazia, o widget entra
no ramo `_musicasFiltradas.isEmpty ? const Center(child: CircularProgressIndicator())`,
e o spinner **anima indefinidamente**, de modo que `pumpAndSettle` nunca
converge. É um defeito de testabilidade do widget — o estado "vazio" e o
estado "carregando" são o mesmo — que o modelo não previu.

**2. `deve filtrar a lista ao digitar no campo de pesquisa`** —
`Expected: no matching candidates / Actual: Found 1 widget with text "In The End - Linkin Park"`.

Causada pela regressão que o próprio modelo introduziu na iteração 2.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(A)** nas três iterações, sempre declarada explicitamente. |
| **★ Classificação humana (auditoria)** | **Erro de geração.** (A) está correta quanto à natureza da falha — é problema do teste, não da aplicação —, mas as três correções são erradas, e a da iteração 3 **descaracteriza o teste**. |
| **★ Concordância** | **Parcial.** Concordância na categoria; discordância total quanto à correção aplicada. |
| **★ Observações** | Ver abaixo. |

### O problema central da iteração 3

Ao colar o widget dentro do arquivo de teste, o modelo produziu uma suíte que
**compila, executa e não testa a aplicação**. `wcrash_fs_test.dart` não
importa nada de `package:sintonize`. Exercita uma cópia do widget congelada
no texto do prompt.

Consequências:

1. **Qualquer alteração em `lib/criar_playlist.dart` é invisível** para esta
   suíte. Corrigir o W-CRASH não muda nada; introduzir um novo bug também não.
2. **Os 3 testes que passam são falsos positivos como evidência de
   qualidade da aplicação.** Atestam a cópia, não o código.
3. A cópia **carrega o W-CRASH junto** (`musica['artist_name'].toLowerCase()`
   veio no prompt), então nem por acidente o bug seria exposto como defeito
   da aplicação.

É uma solução que satisfaz literalmente o pedido — "faça compilar" — e destrói
o propósito do teste. Vale como achado próprio: **o ciclo de reparo, sob
pressão de compilar, pode levar o modelo a remover o alvo do teste em vez de
consertá-lo.** O prompt de reparo proíbe enfraquecer asserções, mas não
proíbe trocar o sujeito do teste.

### Observações

1. **Três caminhos inventados, nenhum acerto**:
   `screens/criar_playlist_screen.dart` → `criar_playlist_screen.dart` →
   `telas/criarPlaylist.dart`. O real é `criar_playlist.dart`, na raiz de
   `lib/`. Em nenhum momento o modelo tentou a raiz.
2. **Escalada de confiança.** Iteração 1: "o teste supôs um caminho
   arbitrário" (correto e honesto). Iteração 2: "no projeto Sintonize, as
   telas ficam organizadas dentro de `lib/telas/`" (fabricação apresentada
   como fato). A incerteza diminuiu enquanto o acerto não veio.
3. **A ajuda ausente explica a rodada.** ZS (rodada 7) recebeu o caminho no
   prompt e compilou de primeira. FS não recebeu e queimou as 3 iterações.
   A comparação ZS × FS nesta tela **não é limpa** — os prompts diferem em
   mais do que a estratégia. Isso vale para a Fase 2 com ChatGPT também, já
   que a assimetria foi preservada de propósito; é uma limitação a declarar
   na análise, não um defeito desta execução.
4. **O W-CRASH segue não capturado**, como na rodada 7 e pela mesma razão:
   todos os dados de mock têm `artist_name`.
5. **A hipótese de ancoragem few-shot** (rodadas 2 e 5) não é testável aqui:
   a rodada não chegou a exercitar o bug. Segue pendente para `I-CRASH-FS`.
