# FASE2-INT-FS-03_playlistFlow — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-INT-FS-03 |
| **Fluxo testado** | Criação de playlist — `CriarPlaylistScreen` (`lib/criar_playlist.dart`) |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio das demais rodadas da Fase 2) |
| **Data de acesso** | 2026-09-18 |
| **Conversa nova?** | Sim — `https://chatgpt.com/uc/6aad89ab-b058-83ea-8782-ccc8eab93a1d` |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/integration/playlist_flow_fs_test.dart` |
| **Execução** | Automação de navegador (Claude in Chrome) |
| **Iterações de reparo** | **1** |
| **Resultado final** | **3/3 — `All tests passed!`** |

### ⚠ Desvio de protocolo declarado

Mesmo desvio da rodada `FASE2-INT-ZS-03` — caminho do arquivo acrescentado
identicamente aos três prompts do `playlistFlow` (commit `4036fed`), como
extensão do desvio já aplicado às rodadas de widget do alvo (commit
`42dcdf9`). **Deve ser declarado na comparação final Fase 1 × Fase 2.**

**Verificação pré-rodada:** W-CRASH e I-SILENT revertidos; `git diff main`
mostra apenas a injeção de dependência.

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/integration/few-shot/FASE2-INT-FS-03_playlistFlow.md`
— um exemplo de teste de integração bem escrito seguido do código da tela
colado verbatim (11.572 caracteres). Texto exato em
`FASE2-INT-FS-03_transcricao/prompt_intfs03.txt`.

---

## Resposta do LLM

Transcrições exatas em `FASE2-INT-FS-03_transcricao/`.

### Mensagem inicial (geração dos testes)

Gerou **3 testes** em um `group('Criar Playlist')`: fluxo completo, nome vazio
e — caso que a zero-shot não cobriu — **playlist salva sem nenhuma música
selecionada**. Acertou o import de primeira e respeitou o `editPlaylist`
obrigatório.

Duas observações espontâneas corretas:

- Explicou que injeta `MockFirebaseAuth` e `FakeFirebaseFirestore`
  diretamente no widget pelos parâmetros opcionais, "assim, ele **não acessa
  Firebase real**".
- Notou que, quando `_musicasFiltradas` está vazia, a tela mostra o
  `CircularProgressIndicator`, e por isso usa `pumpAndSettle()` após a
  montagem para esperar a consulta fake terminar. **Mesma característica do
  widget que a rodada `FASE2-WIDGET-COT-03` identificou** — aqui não causou
  travamento porque a coleção é pré-populada.

### Iteração 1 (repair) — erro de compilação (import faltando)

- **Motivo da falha:** 2× `Error: 'Timestamp' isn't a type.` — faltou
  `import 'package:cloud_firestore/cloud_firestore.dart';`.
- **Resposta do LLM:** classificou **(A)** e corrigiu apenas o import,
  declarando que *"a única mudança necessária para o erro apresentado é o
  primeiro import. As asserções de `Timestamp` podem permanecer, porque elas
  verificam exatamente o tipo que a implementação da tela utiliza ao persistir
  `dataCriacao`"* — recusando-se a enfraquecer a asserção.
- **Resultado após correção:** **3/3 — `All tests passed!`**

---

## Resultado Final

**3/3 — `All tests passed!`** (`00:01 +3`)

| # | Teste |
|---|---|
| 1 | fluxo completo: carrega músicas, seleciona músicas e salva playlist |
| 2 | nome vazio exibe erro e não cria playlist |
| 3 | playlist pode ser salva sem selecionar músicas |

---

## Achados

Nenhum achado **(B)** — alvo limpo.

### Notas qualitativas para a análise comparativa

- **O erro de esquecer `import 'package:cloud_firestore/cloud_firestore.dart'`
  ao usar `isA<Timestamp>()` ocorreu agora pela terceira vez neste alvo**, de
  forma independente: `FASE2-WIDGET-ZS-03`, `FASE2-WIDGET-FS-03` e esta
  rodada. É o padrão de erro mais reprodutível de toda a Fase 2 para
  `CriarPlaylistScreen`, e em todas as três vezes foi resolvido em uma única
  iteração.
- **Mesma recusa de enfraquecer asserção** já registrada em `FASE2-WIDGET-ZS-03`
  diante exatamente do mesmo erro: o modelo separou "o import está faltando"
  de "a asserção está errada", e corrigiu só o primeiro.
- Comparação no fluxo `playlistFlow` até aqui: ZS **3/3 com 0 iterações**,
  FS **3/3 com 1 iteração**. Mesmo número de testes, mas a few-shot cobriu um
  cenário que a zero-shot não cobriu (salvar playlist **sem** músicas
  selecionadas) e deixou de cobrir outro (usuário não autenticado). Cobertura
  **diferente**, não maior.
- Confirma, junto com a rodada 40, que o `playlistFlow` é o alvo de integração
  mais testável da Fase 2 — contra 1/3 e 0/2 no `cadastroFlow` e 7/8, 5/6 e
  10/10 no `loginFlow`.
