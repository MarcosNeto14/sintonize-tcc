# FASE2-INT-ZS-03_playlistFlow — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-INT-ZS-03 |
| **Fluxo testado** | Criação de playlist — `CriarPlaylistScreen` (`lib/criar_playlist.dart`) |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio das demais rodadas da Fase 2) |
| **Data de acesso** | 2026-09-18 |
| **Conversa nova?** | Sim — `https://chatgpt.com/uc/6aad8877-56fc-83ea-9b03-d2f0b922ace7` |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/integration/playlist_flow_zs_test.dart` |
| **Execução** | Automação de navegador (Claude in Chrome) |
| **Iterações de reparo** | **0 — nenhuma necessária** |
| **Resultado final** | **3/3 — `All tests passed!`** |

### ⚠ Desvio de protocolo declarado: caminho do arquivo acrescentado ao prompt

Extensão do desvio já aplicado às rodadas de widget do mesmo alvo (commit
`42dcdf9`), estendida aos três prompts de integração do `playlistFlow` no
commit `4036fed`, a pedido do autor. A linha acrescentada, idêntica nos três:

```
O widget está em `lib/criar_playlist.dart` — use
`import 'package:sintonize/criar_playlist.dart';` para importá-lo.
```

Motivo: `CriarPlaylistScreen` teve **0% de aprovação nas 3 estratégias da
Fase 1** por alucinação do caminho de import, e isso se repetiu na 1ª
tentativa de `FASE2-WIDGET-ZS-03` (ver
`fase2/rodadas/widget/_abortadas/FASE2-WIDGET-ZS-03_TENTATIVA-1.md`).
**Deve ser declarado na comparação final Fase 1 × Fase 2 para este alvo.**

**Verificação pré-rodada:** os bugs W-CRASH e I-SILENT foram revertidos;
`git diff main -- lib/criar_playlist.dart` mostra apenas a injeção de
dependência de `auth`/`firestore`.

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/integration/zero-shot/FASE2-INT-ZS-03_playlistFlow.md`
— instrução direta de gerar um teste de integração para o fluxo, com o código
da tela colado verbatim (10.827 caracteres). Texto exato em
`FASE2-INT-ZS-03_transcricao/prompt_intzs03.txt`.

---

## Resposta do LLM

Transcrição exata em `FASE2-INT-ZS-03_transcricao/resp_intzs03.md`.

### Mensagem inicial (geração dos testes) — única mensagem da rodada

Gerou **3 testes** em um `group('CriarPlaylistScreen - integração')`:
fluxo completo, nome vazio e usuário não autenticado. Acertou o import de
primeira e respeitou o parâmetro nomeado obrigatório `editPlaylist`.

**A suíte compilou e passou inteira na primeira execução.** Não houve
ciclo de reparo.

Duas observações espontâneas corretas na resposta:

- Explicou que o `FakeFirebaseFirestore` usado na asserção é **o mesmo objeto
  injetado no widget**, então a verificação final confirma de fato o documento
  criado por `_firestore.collection('playlists').add(...)` — e não um estado
  paralelo do teste.
- Notou que não é necessário inicializar o Firebase real, porque `auth` e
  `firestore` chegam ao `CriarPlaylistScreen` por injeção.

Também escreveu explicitamente uma asserção sobre o campo `nome` corresponder
**"exatamente ao valor digitado, não um valor fixo"** — o que exercita
diretamente o caminho do bug **I-SILENT** do piloto (nome hardcoded
`'Nova Playlist'`), que está revertido nesta branch. O teste passa, como
esperado num alvo limpo.

---

## Resultado Final

**3/3 — `All tests passed!`** (`00:02 +3`)

| # | Teste |
|---|---|
| 1 | executa o fluxo completo de criar playlist e persiste no Firestore |
| 2 | não salva quando o nome da playlist está vazio |
| 3 | não salva quando o usuário não está autenticado |

---

## Achados

Nenhum achado **(B)** — alvo limpo, nenhum comportamento divergente capturado.

### Notas qualitativas para a análise comparativa

- **Primeira rodada de toda a Fase 2 a fechar com 0 iterações de reparo.**
  Todas as 39 rodadas anteriores precisaram de pelo menos uma.
- **Contraste extremo dentro do mesmo nível e da mesma estratégia:** no nível
  integração, zero-shot, o fluxo de **cadastro** fechou em 1/3 com 3 iterações
  e o de **playlist** em 3/3 com 0 iterações. A diferença não está na
  estratégia de prompt — está no alvo:

  | Fluxo | Telas | Dependências externas | Resultado ZS | Iterações |
  |---|---|---|---|---|
  | login | 1 | `FirebaseAuth` injetado; destino sem injeção | 7/8 | 3 |
  | cadastro | 2 | Auth + Firestore + **HTTP real (ViaCEP) sem injeção** + dropdown de 27 itens | 1/3 | 3 |
  | **playlist** | **1** | **Auth e Firestore, ambos injetados** | **3/3** | **0** |

  Reforça a hipótese central já registrada no nível widget: **a testabilidade
  do alvo domina os resultados, não a estratégia de prompt.**
- A suíte é pequena (3 testes) — comparar com FS-03 e COT-03 do mesmo fluxo
  antes de concluir qualquer coisa sobre cobertura. Como visto no nível widget
  neste mesmo alvo, a zero-shot tende a gerar a suíte mais enxuta.
- O prompt corrigido (com o caminho do import) foi suficiente para eliminar por
  completo o modo de falha que zerou este alvo na Fase 1.
