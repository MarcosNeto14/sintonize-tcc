# FASE2-INT-COT-03_playlistFlow — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-INT-COT-03 |
| **Fluxo testado** | Criação de playlist — `CriarPlaylistScreen` (`lib/criar_playlist.dart`) |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio das demais rodadas da Fase 2) |
| **Data de acesso** | 2026-09-18 |
| **Conversa nova?** | Sim — `https://chatgpt.com/uc/6aad8b1e-d8bc-83ea-b5ef-69884f62d551` |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/integration/playlist_flow_cot_test.dart` |
| **Execução** | Automação de navegador (Claude in Chrome) |
| **Iterações de reparo** | **1** |
| **Resultado final** | **5/5 — `All tests passed!`** |

### ⚠ Desvio de protocolo declarado

Mesmo desvio das rodadas 40 e 41 — caminho do arquivo acrescentado
identicamente aos três prompts do `playlistFlow` (commit `4036fed`).
**Deve ser declarado na comparação final Fase 1 × Fase 2.**

**Verificação pré-rodada:** W-CRASH e I-SILENT revertidos.

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/integration/cot/FASE2-INT-COT-03_playlistFlow.md`
— roteiro em 5 passos (analisar o fluxo → identificar dependências → montar
a estrutura de navegação → enumerar cenários → escrever os testes) seguido
do código da tela colado verbatim (11.244 caracteres). Texto exato em
`FASE2-INT-COT-03_transcricao/prompt_intcot03.txt`.

---

## Resposta do LLM

Transcrições exatas em `FASE2-INT-COT-03_transcricao/`.

### Mensagem inicial (geração dos testes)

Seguiu a estrutura CoT pedida. Gerou **5 testes executáveis** — a maior suíte
do fluxo `playlistFlow`, contra 3 em ZS e 3 em FS: fluxo de sucesso,
indicador de carregamento, nome vazio, usuário não autenticado, e
seleção/desseleção de música.

**Comportamento notável: recusou-se a entregar um teste que não poderia
garantir que compila.** Para o cenário de indisponibilidade do Firestore,
explicou que `FakeFirebaseFirestore` não permite configurar
`collection(...).add(...)` para lançar, que a alternativa correta seria gerar
mocks Mockito, e que — como as APIs do Firebase são genéricas e variam por
versão — *"não é seguro inventar as assinaturas genéricas exatas sem
considerar a versão de `cloud_firestore` do projeto"*. Apresentou esse sexto
cenário explicitamente como ilustrativo (*"o teste fica conceitualmente
assim"*), **fora** do arquivo entregue, e declarou que *"os quatro primeiros
cenários podem ser executados diretamente com as dependências que você
informou"*.

O arquivo entregue foi tratado como a resposta da rodada; o bloco ilustrativo
não foi incluído no teste executado.

### Iteração 1 (repair) — erro de compilação (import faltando)

- **Motivo da falha:** `Error: 'Timestamp' isn't a type.` — faltou
  `import 'package:cloud_firestore/cloud_firestore.dart';`.
- **Resposta do LLM:** classificou **(A)** e entregou um patch cirúrgico
  apenas do bloco de imports. Declarou: *"Não é necessário enfraquecer a
  asserção para, por exemplo, `isNotNull`: o próprio código da aplicação
  especifica `Timestamp.now()`, então verificar o tipo concreto é uma
  validação pertinente do contrato de persistência."*
- **Resultado após correção:** **5/5 — `All tests passed!`**

---

## Resultado Final

**5/5 — `All tests passed!`** (`00:03 +5`)

| # | Teste |
|---|---|
| 1 | fluxo de sucesso: busca músicas, seleciona músicas, salva e persiste corretamente |
| 2 | mostra indicador de carregamento antes de as músicas serem carregadas |
| 3 | nome vazio mostra SnackBar e não cria playlist |
| 4 | usuário não autenticado não cria playlist |
| 5 | seleciona e desseleciona uma música corretamente |

---

## Achados

Nenhum achado **(B)** — alvo limpo.

### Notas qualitativas para a análise comparativa

- **Quarta ocorrência independente, neste mesmo alvo, do erro de esquecer
  `import 'package:cloud_firestore/cloud_firestore.dart'` ao usar
  `isA<Timestamp>()`** — depois de `WIDGET-ZS-03`, `WIDGET-FS-03` e
  `INT-FS-03`. É o padrão de erro mais reprodutível de toda a Fase 2:
  ocorreu em **4 de 6 rodadas** do alvo `CriarPlaylistScreen`, nas três
  estratégias e nos dois níveis, e em todas as vezes foi resolvido em **uma
  única iteração**.
- **Terceira rodada consecutiva neste alvo em que o modelo recusa enfraquecer
  a asserção de `Timestamp`** diante exatamente do mesmo erro
  (`WIDGET-ZS-03`, `INT-FS-03`, esta) — sempre separando "falta o import" de
  "a asserção está errada". Comportamento consistente e correto.
- **Recusa de entregar código que não pode garantir que compila.** O modelo
  deixou o cenário de erro do Firestore explicitamente fora do arquivo, em
  vez de inventar assinaturas genéricas de Mockito. Contrasta diretamente com
  a tentativa 1 de `FASE2-INT-COT-02`, onde o uso de `@GenerateMocks` com
  assinaturas presumidas foi justamente o que impediu a suíte de compilar.
  **A mesma cautela, aplicada antes de gerar, evitou o problema aqui.**
- **Comparação completa do fluxo `playlistFlow`:**

  | Estratégia | Testes | Resultado | Iterações |
  |---|---|---|---|
  | Zero-shot | 3 | 3/3 (100%) | **0** |
  | Few-shot | 3 | 3/3 (100%) | 1 |
  | **Chain-of-Thought** | **5** | **5/5 (100%)** | 1 |

  As três fecharam em 100%. A CoT gerou a maior suíte (67% maior que as
  outras duas) mantendo a aprovação total — o mesmo padrão observado no nível
  widget deste alvo (COT 19/19 contra ZS 8/8 e FS 11/13).
- **Comparação dos três fluxos de integração da Fase 2:**

  | Fluxo | ZS | FS | COT |
  |---|---|---|---|
  | login | 7/8 (3 iter) | 5/6 (3 iter) | 10/10 (3 iter) |
  | cadastro | 1/3 (3 iter) | 0/2 (3 iter) | *não executada* |
  | **playlist** | **3/3 (0 iter)** | **3/3 (1 iter)** | **5/5 (1 iter)** |

  O `playlistFlow` é, com folga, o alvo de integração mais testável — única
  tela do experimento que recebe **`auth` e `firestore` ambos por injeção** e
  não navega para nenhuma tela que acesse Firebase diretamente.
