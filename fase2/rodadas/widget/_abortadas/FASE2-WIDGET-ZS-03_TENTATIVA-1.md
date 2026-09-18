# FASE2-WIDGET-ZS-03_CriarPlaylistScreen — TENTATIVA 1 (ABORTADA)

> **Esta rodada foi abortada na 2ª de 3 iterações de reparo e não conta
> para as 42 rodadas da Fase 2.** Os artefatos estão preservados aqui
> porque o protocolo proíbe reescrever histórico — a tentativa aconteceu e
> seu resultado é, ele próprio, um dado relevante para a análise.

## Metadados

| Campo | Valor |
|---|---|
| **ID pretendido** | FASE2-WIDGET-ZS-03 |
| **Tela** | `CriarPlaylistScreen` — `lib/criar_playlist.dart` (alvo limpo) |
| **Estratégia** | Zero-shot |
| **LLM** | ChatGPT (sessão sem login) |
| **Data** | 2026-09-18 |
| **Conversa** | `https://chatgpt.com/uc/6aad55cb-cb64-83ea-9f76-680c0b05f432` |
| **Status** | **Abortada** após 2 iterações de reparo |
| **Resultado em todas as iterações** | **0 testes executados — a suíte nunca compilou** |

## Motivo do aborto

A rodada replicou, de forma exata, a falha que zerou `CriarPlaylistScreen`
nas **3 estratégias da Fase 1**: alucinação do caminho de import do widget
sob teste. O modelo nunca chegou a executar um único teste.

Sequência observada:

| Iteração | Import emitido | Resultado |
|---|---|---|
| 0 (geração) | `package:sintonize/.../criar_playlist_screen.dart` | Não compila — `...` é literal, não é caminho válido |
| 1 (reparo) | `package:sintonize/screens/criar_playlist_screen.dart` | Não compila — diretório `lib/screens/` não existe |
| 2 (reparo) | `package:sintonize/CAMINHO_REAL_DO_ARQUIVO.dart` | Placeholder explícito — o modelo desistiu de adivinhar |

Observações sobre o comportamento do modelo:

- Nas 3 iterações classificou corretamente como **(A)** e **nunca
  enfraqueceu as asserções** para contornar o erro. Na iteração 2 chegou a
  escrever explicitamente: *"Não altere as asserções nem o fluxo dos testes
  por causa desse erro. Ele é exclusivamente um problema de resolução do
  arquivo de produção."*
- O modelo também errou o **nome do arquivo**, não só o diretório: assumiu
  `criar_playlist_screen.dart` quando o real é `criar_playlist.dart`.
  Acertou o nome da *classe* (`CriarPlaylistScreen`) em todas as iterações.
- Na iteração 2 o modelo pediu explicitamente a árvore de `lib/` para
  fornecer o import exato — informação que o prompt original não continha.

## Decisão tomada

Em vez de fornecer o caminho apenas na última iteração de reparo (o que
criaria uma assimetria entre esta rodada e as de few-shot e
chain-of-thought), optou-se por **eliminar a variável na origem**: o
caminho real do arquivo foi acrescentado aos **três** prompts originais do
alvo, de forma idêntica —

```
O widget está em `lib/criar_playlist.dart` — use
`import 'package:sintonize/criar_playlist.dart';` para importá-lo.
```

— e as três rodadas de `CriarPlaylistScreen` (ZS-03, FS-03, COT-03) são
executadas do zero, em conversas novas, com o prompt corrigido.

**Justificativa:** a alucinação de caminho de import é um artefato do
prompt (que não informava onde o arquivo está), não uma medida da
capacidade de gerar bons widget tests, que é o objeto do experimento. Mantê-la
faria as 3 rodadas deste alvo medirem apenas a mesma falha já documentada na
Fase 1, desperdiçando o alvo. A correção é idêntica nas 3 estratégias,
então não introduz viés entre elas.

**Impacto na comparação Fase 1 × Fase 2 para este alvo:** passa a existir
uma diferença de prompt entre as fases neste alvo específico, que **deve
ser declarada** na análise final. A tentativa registrada aqui é a evidência
de que, sem essa correção, a Fase 2 reproduziria o mesmo 0% da Fase 1 —
resultado que pode ser citado diretamente.

## Artefatos preservados

- `FASE2-WIDGET-ZS-03_TENTATIVA-1_transcricao/prompt_zs03.txt` — prompt original enviado
- `FASE2-WIDGET-ZS-03_TENTATIVA-1_transcricao/resp_zs03.md` — resposta inicial
- `FASE2-WIDGET-ZS-03_TENTATIVA-1_transcricao/repair1_zs03.txt` / `resp_zs03_r1.md` — iteração 1
- `FASE2-WIDGET-ZS-03_TENTATIVA-1_transcricao/repair2_zs03.txt` / `resp_zs03_r2.md` — iteração 2
- `fase2/resultados/widget/_abortadas/FASE2-WIDGET-ZS-03_CriarPlaylistScreen_iter{0,1}.txt` — saídas do `flutter test`
