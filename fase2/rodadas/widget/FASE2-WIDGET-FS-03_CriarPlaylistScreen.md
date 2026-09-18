# FASE2-WIDGET-FS-03_CriarPlaylistScreen — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WIDGET-FS-03 |
| **Tela testada** | `CriarPlaylistScreen` — `lib/criar_playlist.dart` (alvo limpo; bugs W-CRASH e I-SILENT do piloto revertidos antes da rodada) |
| **Arquivo de origem** | `lib/criar_playlist.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio das demais rodadas da Fase 2) |
| **Data de acesso** | 2026-09-18 |
| **Conversa nova?** | Sim — `https://chatgpt.com/uc/6aad6fe3-8e60-83ea-94f0-c40affe3528a` |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/widget/criar_playlist_screen_fs_test.dart` |
| **Execução** | Automação de navegador (Claude in Chrome) |
| **Iterações de reparo** | 3 (o máximo permitido) |
| **Resultado final** | **11/13** — 1 falha é o achado **(B)** mantido por protocolo, 1 é erro de geração não resolvido |

### ⚠ Desvio de protocolo declarado: caminho do arquivo acrescentado ao prompt

Igual às demais rodadas deste alvo. O prompt original não informava onde o
widget está em `lib/`, e na tentativa de `FASE2-WIDGET-ZS-03` isso reproduziu
a alucinação de import que zerou `CriarPlaylistScreen` nas 3 estratégias da
Fase 1. A linha abaixo foi acrescentada **de forma idêntica aos três
prompts** do alvo (ZS-03, FS-03, COT-03):

```
O widget está em `lib/criar_playlist.dart` — use
`import 'package:sintonize/criar_playlist.dart';` para importá-lo.
```

Ver `fase2/rodadas/widget/_abortadas/FASE2-WIDGET-ZS-03_TENTATIVA-1.md` para
o registro completo da tentativa que motivou a mudança. Como a correção é
idêntica nas três estratégias, **não introduz viés entre elas**; introduz sim
uma diferença entre Fase 1 e Fase 2 neste alvo, que deve ser declarada na
análise final.

**Verificação pré-rodada:** `git diff main -- lib/criar_playlist.dart` mostra
apenas a injeção de dependência opcional de `auth`/`firestore`.

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/widget/few-shot/FASE2-WIDGET-FS-03_CriarPlaylistScreen.md`
— um exemplo de widget test bem escrito seguido do código completo de
`CriarPlaylistScreen` colado verbatim, pedindo para seguir o mesmo padrão.
Texto exato em `FASE2-WIDGET-FS-03_transcricao/prompt_fs03.txt`.

---

## Resposta do LLM

Transcrições exatas em `FASE2-WIDGET-FS-03_transcricao/`.

### Mensagem inicial (geração dos testes)

Gerou **13 testes** dentro de um `group('CriarPlaylistScreen Widget')`, com
`FakeFirebaseFirestore` e `MockFirebaseAuth` injetados em todos. Acertou o
import de primeira e respeitou o parâmetro nomeado obrigatório
(`editPlaylist: const {}`), observando espontaneamente que ele "é obrigatório,
mas não é armazenado nem utilizado pelo estado".

Suíte mais ampla que a de zero-shot no mesmo alvo (13 contra 8), incluindo
casos que a ZS não cobriu: formatação de nome, artista ausente, filtro
ignorando maiúsculas/minúsculas, salvamento **sem** usuário autenticado e
navegação de retorno.

### Iteração 1 (repair) — 2 erros de compilação

- **Motivo da falha:** (1) `Error: 'Timestamp' isn't a type` — faltou
  `import 'package:cloud_firestore/cloud_firestore.dart';` (**mesma falha da
  rodada ZS-03**, de forma independente); (2)
  `The getter 'parent' isn't defined for the type 'Finder'` — `Finder.parent`
  não existe na API do `flutter_test`.
- **Resposta do LLM:** classificou **(A)** para as duas e corrigiu: adicionou
  o import e trocou o encadeamento `find.text(...).parent!.find.byIcon(...)`
  por `find.byIcon(Icons.check_box_outline_blank)` direto.
- **Resultado após correção:** **a suíte passa a compilar — 8/13.**

### Iteração 2 (repair) — classificação dupla (A) + (B)

- **Motivo das falhas:** 5 falhas, de duas naturezas: `pumpAndSettle timed
  out` em vários testes, e o teste de artista ausente não encontrando o texto
  esperado.
- **Resposta do LLM:** **classificou as duas causas separadamente**:
  - **(A)** — `pumpAndSettle()` usado enquanto o widget mantém um
    `CircularProgressIndicator` ativo faz o teste esperar indefinidamente.
    Trocou por `pump()` com duração explícita.
  - **(B)** — o teste de artista ausente **revelou um problema real da
    aplicação**: `musica['artist_name'] ?? 'Desconhecido'` não protege contra
    campo ausente, porque `musica['artist_name']` **já lança** antes de o `??`
    ter chance de executar. Declarou: *"o teste de artista ausente é o que
    deve ser tratado como evidência de um defeito na implementação, e não como
    um teste que devemos enfraquecer."*
- **Resultado após correção:** **11/13.**

### Iteração 3 (repair, última permitida) — (A) + (B) mantido

- **Resposta do LLM:** manteve a classificação **(B)** para `artist_name` e
  reafirmou que o teste deve continuar falhando até a aplicação ser
  corrigida. Para a falha restante de navegação, classificou **(A)** e
  entregou um **patch cirúrgico** ("Substitua apenas o teste de navegação por
  este"), trocando os `pump()` simples por
  `pump(const Duration(milliseconds: 500))` para avançar a animação de
  transição de rota.
- **Correção aplicada:** apenas o patch do teste de navegação. O teste de
  `artist_name` foi mantido **exatamente como estava**, conforme o protocolo.
- **Resultado após correção:** **11/13 — sem mudança.** A correção proposta
  para a navegação **não resolveu**: o teste continua falhando com
  `Found 0 widgets with text "Criando Playlist"`, agora por não encontrar o
  título após o `push`, não mais por timeout.

---

## Resultado Final

**11/13** (`00:03 +11 -2`)

| # | Teste | Resultado |
|---|---|---|
| 1 | deve mostrar os campos e botão da tela | ✅ |
| 2 | deve mostrar mensagem de erro quando nome da playlist está vazio | ✅ |
| 3 | deve carregar músicas do Firestore | ✅ |
| 4 | deve formatar nome da música e artista | ✅ |
| 5 | **deve usar Desconhecido quando artista não existir** | ❌ **achado (B)** |
| 6 | deve filtrar músicas pelo nome da música | ✅ |
| 7 | deve filtrar músicas pelo nome do artista | ✅ |
| 8 | deve filtrar ignorando maiúsculas e minúsculas | ✅ |
| 9 | deve selecionar uma música | ✅ |
| 10 | deve desmarcar uma música previamente selecionada | ✅ |
| 11 | deve salvar playlist para usuário autenticado | ✅ |
| 12 | não deve salvar playlist quando não existe usuário autenticado | ✅ |
| 13 | **deve voltar ao tocar no botão de voltar** | ❌ erro de geração não resolvido |

---

## Achados

### (B) — `artist_name` ausente derruba a renderização da lista

**Confirmado no código da aplicação.** `lib/criar_playlist.dart:168-170`:

```dart
var musica = _musicasFiltradas[index];
String musicaNome = _formatName(musica['track_name']);
String artistName = _formatName(
    musica['artist_name'] ?? 'Desconhecido');
```

O `?? 'Desconhecido'` **é código morto** quando o campo não existe: o operador
`[]` de um `DocumentSnapshot` lança antes de o `??` ser avaliado. A pilha de
execução do teste confirma:

```
Bad state: Cannot get field that does not exist
#0  MockDocumentSnapshot.get (package:fake_cloud_firestore/...:36:7)
#1  MockDocumentSnapshot.[] (package:fake_cloud_firestore/...:93:33)
#3  _CriarPlaylistScreenState.build.<anonymous closure>
    (package:sintonize/criar_playlist.dart:170:35)
```

A consequência prática é que **um único documento da coleção `musica` sem o
campo `artist_name` quebra a renderização de toda a lista**, não apenas
daquele item. O `?? 'Desconhecido'` mostra que a intenção do autor era
justamente tolerar o campo ausente — a implementação não cumpre essa
intenção.

**Não corrigido**, conforme o protocolo (não se altera a aplicação sob teste
durante uma rodada). Registrar em `fase2/propostas_bugs_fase2.md` como
candidato a correção fora do fluxo de rodada. Este é um **bug não plantado**,
descoberto espontaneamente pelo teste gerado.

### Erro de geração não resolvido — teste de navegação

O teste `deve voltar ao tocar no botão de voltar` não foi resolvido nas 3
iterações. Evoluiu de `pumpAndSettle timed out` (iterações 0–2) para
`Found 0 widgets with text "Criando Playlist"` (iteração 3), ou seja, a causa
mudou mas o teste continuou falhando. O título `'Criando Playlist'` **existe**
em `lib/criar_playlist.dart:109-110`, então o diagnóstico do modelo sobre a
animação estava incompleto — 500 ms não bastaram para a transição de rota
concluir, ou o `CircularProgressIndicator` ainda impede a renderização do
título nesse instante.

### Notas qualitativas para a análise comparativa

- **Primeira rodada da Fase 2 a produzir um achado (B) confirmado no código da
  aplicação a partir de um bug não plantado**, em qualquer nível. Os achados
  (B) anteriores eram limitações de testabilidade (`TelaInicialScreen` sem
  injeção), não defeitos de lógica.
- **Segunda rodada consecutiva com classificação dupla (A)+(B)** na mesma
  iteração (a primeira foi `FASE2-WIDGET-COT-02`), e a única até aqui a
  **sustentar** a classificação (B) por duas iterações seguidas, recusando-se
  a enfraquecer o teste nas duas.
- Comparação no mesmo alvo: ZS-03 **8/8 com 1 iteração**, FS-03 **11/13 com 3
  iterações**. A few-shot gerou uma suíte **63% maior** e foi a que encontrou
  o bug de `artist_name` — que a zero-shot simplesmente não cobriu. Um
  resultado numérico pior aqui corresponde a **maior cobertura**, não a pior
  qualidade: comparar apenas a razão de aprovação entre estratégias seria
  enganoso neste par.
- O erro de esquecer `import 'package:cloud_firestore/cloud_firestore.dart'`
  ao usar `isA<Timestamp>()` ocorreu **de forma independente em ZS-03 e
  FS-03** — padrão recorrente do modelo neste alvo, análogo ao
  `mock_exceptions` faltando nas rodadas de `LoginScreen`.
