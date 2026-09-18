# FASE2-WIDGET-ZS-03_CriarPlaylistScreen — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WIDGET-ZS-03 |
| **Tela testada** | `CriarPlaylistScreen` — `lib/criar_playlist.dart` (alvo limpo; bugs W-CRASH e I-SILENT do piloto revertidos antes da rodada) |
| **Arquivo de origem** | `lib/criar_playlist.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio das demais rodadas da Fase 2) |
| **Data de acesso** | 2026-09-18 |
| **Conversa nova?** | Sim — `https://chatgpt.com/uc/6aad6e91-5900-83ea-b213-1e80e00fd88c` |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/widget/criar_playlist_screen_zs_test.dart` |
| **Execução** | Automação de navegador (Claude in Chrome) |
| **Iterações de reparo** | **1** |
| **Resultado final** | **8/8 — `All tests passed!`** |

### ⚠ Desvio de protocolo declarado: prompt corrigido após tentativa abortada

Esta rodada é a **segunda tentativa**. A primeira foi abortada na 2ª de 3
iterações de reparo e está integralmente arquivada em
`fase2/rodadas/widget/_abortadas/FASE2-WIDGET-ZS-03_TENTATIVA-1.md`.

Motivo: o prompt original não dizia onde o arquivo do widget está em `lib/`,
e o modelo alucinou o caminho de import em todas as iterações — **exatamente
a falha que zerou `CriarPlaylistScreen` nas 3 estratégias da Fase 1**. Chutou
`sintonize/.../criar_playlist_screen.dart`, depois `sintonize/screens/...`,
e terminou emitindo o placeholder `sintonize/CAMINHO_REAL_DO_ARQUIVO.dart`
pedindo a árvore de `lib/`. Nenhum teste chegou a ser executado.

Correção adotada: a linha abaixo foi acrescentada **de forma idêntica aos
três prompts** do alvo (ZS-03, FS-03, COT-03), e as três rodadas são
executadas do zero com o prompt corrigido:

```
O widget está em `lib/criar_playlist.dart` — use
`import 'package:sintonize/criar_playlist.dart';` para importá-lo.
```

**Consequência para a análise:** existe uma diferença de prompt entre Fase 1
e Fase 2 **neste alvo específico**, que deve ser declarada na comparação
final. A tentativa 1 arquivada é a evidência de que, sem essa correção, a
Fase 2 reproduziria o mesmo 0% da Fase 1. A correção é idêntica nas três
estratégias, então **não introduz viés entre elas**.

**Verificação pré-rodada:** `git diff main -- lib/criar_playlist.dart` mostra
apenas a injeção de dependência opcional de `auth`/`firestore` — nenhum bug
plantado ativo.

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/widget/zero-shot/FASE2-WIDGET-ZS-03_CriarPlaylistScreen.md`
(versão corrigida) — instrução direta de gerar widget tests com `flutter_test`
para o widget colado verbatim, sem exemplos e sem roteiro de raciocínio, com
a lista de restrições (envolver em `MaterialApp`, mockar Auth e Firestore,
pré-popular a coleção `musica`, exercitar as interações, caminho do import).
Texto exato em `FASE2-WIDGET-ZS-03_transcricao/prompt_zs03.txt`.

---

## Resposta do LLM

Transcrições exatas em `FASE2-WIDGET-ZS-03_transcricao/`.

### Mensagem inicial (geração dos testes)

Gerou um arquivo único com **8 testes** usando `FakeFirebaseFirestore` e
`MockFirebaseAuth`, sem `group`s. Com o caminho do import informado no
prompt, acertou `import 'package:sintonize/criar_playlist.dart';` de
primeira e instanciou `CriarPlaylistScreen(editPlaylist: const {}, ...)`
corretamente, respeitando o parâmetro nomeado obrigatório.

Demonstrou leitura correta do widget ao explicar espontaneamente que, com o
Firestore retornando zero músicas, `_musicasFiltradas` fica vazia e a tela
mostra um `CircularProgressIndicator` — por isso pré-populou a coleção
`musica` antes do `pumpWidget`.

### Iteração 1 (repair) — erro de compilação (import faltando)

- **Motivo da falha:** uma única linha — `Error: 'Timestamp' isn't a type.`
  O teste usa `isA<Timestamp>()` sem importar `cloud_firestore`.
- **Resposta do LLM:** classificou **(A)** corretamente e entregou um
  **patch cirúrgico**: apenas o bloco de imports corrigido, com uma linha a
  mais. Declarou explicitamente que **não era necessário alterar a asserção**
  — *"o widget realmente grava `Timestamp.now()` em `dataCriacao`, portanto
  verificar que o valor persistido é um `Timestamp` é compatível com o código
  da aplicação"* — recusando-se a enfraquecer o teste para contornar o erro.
- **Correção aplicada:** adição de
  `import 'package:cloud_firestore/cloud_firestore.dart';`, exatamente como
  fornecido.

---

## Resultado Final

**8/8 — `All tests passed!`** (`00:02 +8`)

| # | Teste |
|---|---|
| 1 | exibe as músicas carregadas do Firestore fake |
| 2 | permite digitar o nome da playlist |
| 3 | filtra músicas pelo nome da música |
| 4 | filtra músicas pelo nome do artista |
| 5 | permite marcar e desmarcar uma música |
| 6 | mostra erro ao tentar salvar sem informar nome da playlist |
| 7 | salva a playlist com nome e música selecionada |
| 8 | permite pesquisar, selecionar uma música e salvar somente a música filtrada |

---

## Achados

Nenhum achado (B) — o alvo está limpo e nenhum comportamento divergente da
aplicação foi capturado.

### Notas qualitativas para a análise comparativa

- **Primeira rodada de widget da Fase 2 a fechar com 100% de aprovação**, e
  a que precisou de menos reparo (1 iteração, contra 2–3 nas cinco rodadas de
  widget anteriores).
- **Nenhum dos problemas recorrentes das rodadas de widget anteriores
  apareceu aqui:** sem conflito `firebase_auth_mocks` × mockito, sem
  `mock_exceptions` faltando, sem falha de viewport 800×600, sem
  `[core/no-app]`. A explicação mais provável é o alvo: `CriarPlaylistScreen`
  recebe **tanto `auth` quanto `firestore`** por injeção e não navega para
  nenhuma tela que acesse Firebase diretamente — ao contrário de
  `LoginScreen`/`CadastroScreen`, cujo caminho de sucesso esbarra em
  `TelaInicialScreen`.
- Confirma que a **testabilidade da tela de destino**, e não a estratégia de
  prompt, é o fator dominante nos resultados de widget da Fase 2. Comparar
  ZS-01 (CadastroScreen, 21/22 com 3 iterações), ZS-02 (LoginScreen, 11/12
  com 2 iterações) e ZS-03 (CriarPlaylistScreen, 8/8 com 1 iteração): a mesma
  estratégia, no mesmo nível, com o mesmo operador, produz resultados
  claramente ordenados pela injeção de dependência disponível no alvo.
- O modelo **recusou espontaneamente** enfraquecer a asserção de `Timestamp`
  ao corrigir o erro de compilação, mesmo sem a falha exigir essa decisão —
  comportamento alinhado ao protocolo (B) sem que ele fosse acionado.
