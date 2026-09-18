# FASE2-WIDGET-COT-03_CriarPlaylistScreen — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WIDGET-COT-03 |
| **Tela testada** | `CriarPlaylistScreen` — `lib/criar_playlist.dart` (alvo limpo; bugs W-CRASH e I-SILENT do piloto revertidos antes da rodada) |
| **Arquivo de origem** | `lib/criar_playlist.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio das demais rodadas da Fase 2) |
| **Data de acesso** | 2026-09-18 |
| **Conversa nova?** | Sim — `https://chatgpt.com/uc/6aad72c9-d0f8-83ea-948b-abd2819e76a8` |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/widget/criar_playlist_screen_cot_test.dart` |
| **Execução** | Automação de navegador (Claude in Chrome) |
| **Iterações de reparo** | 3 (o máximo permitido) |
| **Resultado final** | **19/19 — `All tests passed!`** |

### ⚠ Desvio de protocolo declarado: caminho do arquivo acrescentado ao prompt

Idêntico ao aplicado em ZS-03 e FS-03 — ver
`fase2/rodadas/widget/_abortadas/FASE2-WIDGET-ZS-03_TENTATIVA-1.md` para a
justificativa completa. A linha acrescentada aos três prompts do alvo:

```
O widget está em `lib/criar_playlist.dart` — use
`import 'package:sintonize/criar_playlist.dart';` para importá-lo.
```

**Verificação pré-rodada:** `git diff main -- lib/criar_playlist.dart` mostra
apenas a injeção de dependência opcional de `auth`/`firestore`.

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/widget/cot/FASE2-WIDGET-COT-03_CriarPlaylistScreen.md`
— roteiro em 4 passos (analisar o widget → identificar dependências a mockar
→ enumerar cenários → escrever os testes) seguido do código completo de
`CriarPlaylistScreen` colado verbatim. Texto exato em
`FASE2-WIDGET-COT-03_transcricao/prompt_cot03.txt`.

---

## Resposta do LLM

Transcrições exatas em `FASE2-WIDGET-COT-03_transcricao/`.

### Mensagem inicial (geração dos testes)

Seguiu a estrutura CoT pedida, com as seções numeradas explícitas. Gerou
**19 testes** — a maior suíte de qualquer rodada de widget da Fase 2 (contra
8 em ZS-03 e 13 em FS-03) — todos dentro de
`group('CriarPlaylistScreen')`, com um helper `pumpScreen(tester)`
compartilhado.

Acertou o import de primeira e respeitou o parâmetro nomeado obrigatório.
**A suíte compilou na primeira execução**, o que não havia acontecido em
nenhuma das outras cinco rodadas de widget da Fase 2.

Na análise em prosa, registrou espontaneamente duas observações corretas
sobre o widget, ambas depois confirmadas pelos testes:

- `_fetchMusicas()` captura qualquer exceção e apenas faz `print`, sem
  `SnackBar` — logo não há indicador de erro observável para testar.
- O código usa `_musicasFiltradas.isEmpty` tanto para "carregando" quanto
  para "nenhuma música", então uma coleção vazia mantém o
  `CircularProgressIndicator` indefinidamente. **Escreveu o teste para
  registrar o comportamento real em vez de mascará-lo**, e declarou que, se
  o requisito fosse exibir "Nenhuma música encontrada", isso seria uma
  questão a corrigir no widget.

### Iteração 1 (repair) — 7 falhas, todas `pumpAndSettle timed out`

- **Motivo da falha:** `pumpAndSettle()` nunca estabiliza enquanto o
  `CircularProgressIndicator` está ativo — a mesma causa da iteração 2 de
  `FASE2-WIDGET-FS-03`, identificada aqui de forma independente.
- **Resposta do LLM:** classificou **(A)** e entregou **7 patches
  cirúrgicos**, um por teste ("Você pode manter a maior parte do arquivo
  anterior e alterar estes testes"), trocando `pumpAndSettle()` por `pump()`
  com duração explícita. Dois testes foram **renomeados** para refletir o
  comportamento real em vez do presumido:
  `'não salva playlist quando o nome contém apenas espaços?'` →
  `'aceita nome contendo apenas espaços conforme a validação atual'` (a
  validação usa `isNotEmpty`, então `"   "` é aceito), e
  `'exibe lista vazia/indicador quando a coleção de músicas está vazia'` →
  `'exibe indicador quando a coleção de músicas está vazia'`.
- **Resultado após correção:** **18/19.**

### Iteração 2 (repair) — 1 falha (navegação)

- **Motivo da falha:** `Found 0 widgets with text "Criando Playlist"` — após
  o `push`, a transição de rota não concluiu.
- **Resposta do LLM:** classificou **(A)** e propôs
  `pump(const Duration(milliseconds: 500))` para avançar a animação da
  `MaterialPageRoute`. **Exatamente a mesma correção que a rodada FS-03
  tentou e que lá também não funcionou.**
- **Resultado após correção:** **18/19 — sem mudança.**

### Iteração 3 (repair, última permitida) — 1 falha (navegação)

- **Resposta do LLM:** classificou **(A)** e, em vez de insistir no ajuste de
  tempo, **mudou de abordagem**: substituiu a `MaterialPageRoute` por uma
  `PageRouteBuilder` com duração de transição zero, tornando a navegação
  determinística e removendo a animação da equação. Justificou explicitamente
  que isso **não reduz a asserção**: *"estamos removendo apenas uma variável
  irrelevante — a animação da rota — para testar diretamente o comportamento
  que interessa"*, e manteve as três verificações originais (entrar na tela,
  voltar, e a tela anterior reaparecer).
- **Resultado após correção:** **19/19 — `All tests passed!`**

---

## Resultado Final

**19/19 — `All tests passed!`** (`00:11 +19`)

| # | Teste |
|---|---|
| 1 | renderiza os elementos básicos da tela |
| 2 | exibe indicador de carregamento antes das músicas serem carregadas |
| 3 | exibe as músicas depois que o Firestore termina de carregar |
| 4 | formata corretamente nomes de músicas e artistas |
| 5 | permite digitar o nome da playlist |
| 6 | filtra músicas pelo nome da música |
| 7 | filtra músicas pelo nome do artista |
| 8 | a pesquisa não diferencia maiúsculas de minúsculas |
| 9 | marca uma música quando o usuário toca no checkbox |
| 10 | desmarca uma música previamente selecionada |
| 11 | exibe erro quando tenta salvar sem informar nome da playlist |
| 12 | salva playlist com usuário autenticado e músicas selecionadas |
| 13 | não salva playlist quando não existe usuário autenticado |
| 14 | não salva playlist quando o nome é uma string vazia |
| 15 | aceita nome contendo apenas espaços conforme a validação atual |
| 16 | volta para a tela anterior ao tocar no botão de voltar |
| 17 | exibe indicador quando a coleção de músicas está vazia |
| 18 | permite selecionar várias músicas |
| 19 | pesquisa sem resultados não exibe nenhuma música |

---

## Achados

Nenhum achado **(B)** formal — o modelo não classificou nenhuma falha como
defeito da aplicação nesta rodada. Mas registrou **dois comportamentos
questionáveis do widget em prosa**, sem que nenhuma falha o obrigasse a isso:

1. **`isEmpty` ambíguo:** o código não diferencia "estou carregando músicas"
   de "terminei de carregar e não existem músicas", então uma coleção `musica`
   vazia deixa o `CircularProgressIndicator` girando para sempre. O modelo
   escreveu o teste nº 17 para **registrar** esse comportamento, declarando
   que se o requisito fosse outro, o widget é que deveria mudar.
2. **Validação por `isNotEmpty`:** o nome `"   "` (só espaços) é aceito como
   válido. O modelo renomeou o teste para declarar isso explicitamente em vez
   de esperar um erro que a aplicação não produz.

**Notar:** a rodada FS-03, no mesmo alvo, encontrou um **terceiro** problema
(`artist_name ?? 'Desconhecido'` como código morto — ver
`fase2/propostas_bugs_fase2.md`) que **esta rodada não encontrou**, apesar da
suíte maior: a COT gerou o teste "formata corretamente nomes de músicas e
artistas" com o campo sempre presente, nunca ausente.

### Notas qualitativas para a análise comparativa

- **Única rodada de widget da Fase 2 cuja suíte compilou na primeira
  execução** — todas as outras cinco precisaram de pelo menos uma iteração só
  para compilar.
- **Segunda rodada da Fase 2 a fechar com 100% de aprovação**, e com a maior
  suíte (19 testes).
- **Nenhuma regressão entre iterações:** 12 → 18 → 18 → 19, monotônico. As
  três rodadas 33–36 usaram patch cirúrgico em vez de reescrita completa e
  nenhuma regrediu, confirmando a lição registrada após
  `FASE2-WIDGET-COT-01` (onde uma reescrita completa na última iteração
  trocou "compila com 22 falhas" por "não compila").
- **Comportamento notável na iteração 3:** ao ver que a correção da iteração 2
  não funcionou, o modelo **trocou de estratégia** em vez de insistir no mesmo
  ajuste. É o contraste direto com a rodada FS-03, que ficou presa no mesmo
  teste de navegação e o entregou falhando. Mesmo alvo, mesmo sintoma, mesma
  primeira correção — a diferença esteve em reconhecer que a abordagem não
  servia e mudar de tática dentro do orçamento de reparo.
- **Comparação completa no alvo `CriarPlaylistScreen`:**

  | Estratégia | Testes | Resultado | Iterações | Compilou de primeira? | Achou o bug de `artist_name`? |
  |---|---|---|---|---|---|
  | Zero-shot | 8 | 8/8 (100%) | 1 | não | não |
  | Few-shot | 13 | 11/13 (85%) | 3 | não | **sim** |
  | Chain-of-Thought | 19 | **19/19 (100%)** | 3 | **sim** | não |

  A CoT domina em tamanho de suíte e taxa de aprovação simultaneamente, mas a
  few-shot foi a única a exercitar o caminho que revelou o defeito real da
  aplicação. Reforça que **cobertura e taxa de aprovação medem coisas
  diferentes** e devem ser reportadas juntas.
