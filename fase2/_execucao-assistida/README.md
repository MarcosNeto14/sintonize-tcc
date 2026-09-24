# Execução assistida: rodadas de bug plantado com reparo enriquecido

**Estas rodadas não entram na comparação entre modelos.** A pasta guarda os
artefatos de 15 rodadas de bug plantado da Fase 2 (ChatGPT). Nelas, o prompt de
reparo recebeu informação do operador além do template fixo. Foram isoladas em
2026-09-24 e preservadas **sem nenhuma alteração** (movidas com `git mv`).

## O que está aqui

| Subpasta | Conteúdo | Origem |
|---|---|---|
| `rodadas/widget/` | 6 docs de rodada | `fase2/rodadas/widget/` |
| `rodadas/integration/` | 9 docs de rodada e 6 pastas `*_transcricao` (30 arquivos) | `fase2/rodadas/integration/` |
| `resultados/widget/` | 24 saídas de `flutter test` | `fase2/resultados/widget/` |
| `resultados/integration/` | 29 saídas de `flutter test` | `fase2/resultados/integration/` |
| `test/widget/`, `test/integration/` | 15 arquivos de teste gerados | `test/fase2/widget/`, `test/fase2/integration/` |

Os testes ficam **fora de `test/`** de propósito, para não entrarem mais em
`flutter test`. É o mesmo critério usado em `fase2-gemini/piloto-flash-lite/`.
Os caminhos citados dentro dos docs (`test/fase2/...`, `fase2/resultados/...`,
`scratchpad/r13_repair1.txt`) são os da época da execução e não foram
atualizados.

## Por que foram isoladas

O template de reparo da Fase 2 é fixo. Ele traz a saída de erro, o pedido de
classificação (A)/(B) e a instrução de não enfraquecer a asserção se (B). Nas 15
rodadas abaixo, o operador acrescentou ao template fatos verificados no
código-fonte real, a API real das dependências, diagnósticos, técnicas de
correção sugeridas e achados de rodadas anteriores. Na réplica com Gemini
(`fase2-gemini/`) o reparo foi o template fixo, sem acréscimos. Comparar as duas
execuções mediria o operador junto com o modelo.

Três exemplos literais:

- **`rodadas/integration/FASE2-ICRASH-COT_transcricao/r15_repair2.txt`**: lista os
  10 campos reais de `lib/cadastro.dart`, em ordem, com label e validador de cada um.
  Também receita `tester.binding.setSurfaceSize(const Size(800, 1600))` com
  `try/finally`.
- **`rodadas/integration/FASE2-ICRASH-FS_transcricao/r14_repair1.txt`**: cola o
  `build()` real de `GenerosCadastroScreen` (`Card > Row > Switch`, não
  `SwitchListTile`) e o caminho do import de `TelaInicialScreen`.
- **`rodadas/integration/FASE2-ICRASH-COT_transcricao/r15_repair3.txt`**: explica o
  `_CEPInputFormatter` e sugere `'123'` como CEP inválido. Declara a limitação de
  `TelaInicialScreen` como "JA CONHECIDA e documentada em rodadas anteriores",
  proíbe tentar `Firebase.initializeApp()` falso e dita a asserção
  `expect(tester.takeException(), isNotNull)`.

A reexecução limpa destas 15 rodadas, com o protocolo da réplica (template de
reparo fixo, sem acréscimos), fica em **`fase2-chatgpt-reexec/`**.

## O que o operador acrescentou, por rodada

Fontes: os `repair*.txt` das transcrições (rodadas 13 a 18) e as seções "Prompt
de reparo enviado" dos docs (widget e `_REEXEC`). "Template" significa que a
iteração usou só o template, sem acréscimo.

| Rodada | It. | O que o operador acrescentou ao template |
|---|---|---|
| WCRASH-FS | 1 | nome real do arquivo e origem de `Timestamp` |
| | 2 | aponta o padrão comum aos 4 testes que falharam (timeout) |
| | 3 | aponta a linha exata do stack trace; aviso de última iteração |
| WCRASH-COT | 1 | template |
| | 2 | nota apontando a contradição na resposta anterior |
| | 3 | pede classificação individual; aviso de última iteração |
| WSILENT-ZS | 1 | template |
| | 2 | pede classificação individual das 4 falhas |
| | 3 | pergunta se há correção viável sem alterar `lib/tela-inicial.dart`; aviso de limite |
| WSILENT-FS | 1 | assinatura real do construtor `MockFirebaseAuth` da versão instalada; sugere `mock_exceptions`/`whenCalling` |
| | 2 | achado de rodada anterior: `Firebase.initializeApp()` falso não resolve `TelaInicialScreen` |
| | 3 | aponta que é o mesmo engano de antes e dita a correção (`find.descendant(..., matching: find.byType(EditableText))`) |
| WSILENT-COT | 1 | assinatura real das classes; sugere `mock_exceptions`/`whenCalling` e `find.descendant(...EditableText)` |
| | 2 | limitação já conhecida, incluindo que `initializeApp()` falso não resolve; restringe o escopo das correções |
| | 3 | dita a correção esperada (cast explícito) |
| WSILENT-FS_REEXEC | 1 | template |
| | 2 | caminho real `lib/login.dart` |
| | 3 | causa raiz de rodadas anteriores; `initializeApp()` falso já tentado; aviso de última iteração |
| ICRASH-ZS (r13) | 1 | restrição de não alterar `lib/cadastro.dart` e `lib/generos-cadastro.dart` |
| | 2 | `dev_dependencies` reais (`mockito`, `build_runner`, `fake_cloud_firestore`, `firebase_auth_mocks` com versões) |
| | 3 | "dois fatos verificados no código-fonte real": `build()` do prompt era simplificado (`Switch` em `Card`/`Row`); viewport 800×600 |
| ICRASH-FS (r14) | 1 | import de `TelaInicialScreen`; `build()` real de `GenerosCadastroScreen`; viewport e `ensureVisible`/`scrollUntilVisible` |
| | 2 | hipóteses de causa (`Scrollable` ambíguo; `ListView.builder` lazy); sugere `setSurfaceSize` |
| | 3 | as 2 causas exatas (tap fora do viewport; tipo de `scrollable:`); receita `setSurfaceSize(Size(800, 1400))` |
| ICRASH-COT (r15) | 1 | API real de `firebase_auth_mocks ^0.14.1`; `mock_exceptions` com código pronto; `any` do mockito; import de `TelaInicialScreen`; `build()` real com `Switch` |
| | 2 | os 10 campos reais do cadastro com ordem, labels e validadores; `setSurfaceSize(Size(800, 1600))` |
| | 3 | `_CEPInputFormatter`; sintaxe de `Invocation.method` com nomeados; limitação conhecida de `TelaInicialScreen`; asserção com `takeException()` ditada |
| ICRASH-ZS_REEXEC | 1 | versão pinada da dependência; lembrete de não adicionar dependências |
| | 2 | viewport 800×600; `appWith()` sempre inicia em `/cadastro`; sugere `ensureVisible()`/`setSurfaceSize()` |
| | 3 | detalha que a falha ocorre dentro do `tap()` no dropdown; aviso de última iteração |
| ICRASH-FS_REEXEC | 1 | técnica `setSurfaceSize`/`find.byWidgetPredicate` vinda de `ICRASH-ZS_REEXEC`, fornecida preventivamente |
| | 2 | causa raiz já documentada em rodadas anteriores; `initializeApp()` falso já tentado |
| ICRASH-COT_REEXEC | 1 | API real (`whenCalling`); achados de rodadas irmãs sobre viewport e dropdown, fornecidos preventivamente |
| | 2 | estrutura real do widget (rótulo é `Text` separado); aponta os 3 casos já conhecidos |
| | 3 | UID fixo de `firebase_auth_mocks` (rodada irmã); limitação de `whenCalling` com nomeados já tentada |
| ISILENT-ZS (r16) | 1 | diagnóstico ("Falta o import de `package:cloud_firestore`…"); restrição sobre `lib/criar_playlist.dart` |
| ISILENT-FS (r17) | 1 | nome real do arquivo (`lib/criar_playlist.dart`) e import corrigido pronto |
| ISILENT-COT (r18) | 1 | confirma o ajuste que o modelo apontou e dita as remoções; import de `firebase_auth` |

## As 7 rodadas de bug plantado que NÃO foram movidas

Estas rodadas ficam em `fase2/` e **entram na comparação**. Elas não tiveram
reparo enriquecido, então são válidas sob o protocolo da réplica.

| Rodada | Iterações de reparo | Motivo |
|---|---|---|
| UCRASH-ZS | 0 | sem reparo |
| UCRASH-COT | 0 | sem reparo |
| USILENT-ZS | 0 | sem reparo |
| USILENT-FS | 0 | sem reparo |
| USILENT-COT | 0 | sem reparo |
| WCRASH-ZS | 0 | sem reparo |
| UCRASH-FS | 1 | **template puro segundo o doc, sem transcrição literal para conferir** (`fase2/rodadas/unit/FASE2-UCRASH-FS.md`, Iteração 1). É dado válido com essa ressalva. |

## Outros itens que ficaram de fora

- **`fase2/rodadas.rar`**: não foi aberto nem movido. Provavelmente contém cópias
  antigas dos docs de rodada, incluindo os destas 15.
- **Prompts** em `fase2/prompts_prontos/`: continuam onde estavam. O prompt inicial
  não é o problema. As cópias byte-idênticas estão em `fase2-gemini/prompts_prontos/`.
- **`FASE2-VALIDATESENHA-ZS-*`**: rodadas extras de controle limpo, sem reparo. Não
  são de bug plantado.
