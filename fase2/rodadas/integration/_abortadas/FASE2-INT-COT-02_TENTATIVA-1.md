# FASE2-INT-COT-02_cadastroFlow — TENTATIVA 1 (ABORTADA)

> **Abortada na 1ª de 3 iterações de reparo, por limite de tamanho de
> resposta da sessão — não conta para as 42 rodadas.** Os artefatos estão
> preservados aqui porque o protocolo proíbe reescrever histórico.

## Metadados

| Campo | Valor |
|---|---|
| **ID pretendido** | FASE2-INT-COT-02 |
| **Fluxo** | Cadastro — `CadastroScreen` → `GenerosCadastroScreen` |
| **Estratégia** | Chain-of-Thought |
| **LLM** | ChatGPT (sessão sem login) |
| **Data** | 2026-09-18 |
| **Conversa** | `https://chatgpt.com/uc/6aad7d8a-2570-83ea-ae7e-cee935101301` |
| **Status** | **Abortada** na iteração 1 de reparo |
| **Resultado** | **0 testes executados** — a suíte nunca compilou |

## Motivo do aborto

A resposta que deveria entregar o arquivo corrigido **truncou por limite de
tamanho**, de forma reprodutível. A rodada nunca chegou a produzir uma suíte
executável.

Sequência observada:

| Etapa | Resultado |
|---|---|
| Geração inicial | **922 linhas** — a maior resposta de toda a Fase 2. Usa `@GenerateMocks` + arquivo `.mocks.dart` gerado por `build_runner` |
| `build_runner` | Executado com sucesso (`wrote 1 output`), gerou `cadastro_flow_cot_test.mocks.dart` |
| Iteração 0 (`flutter test`) | **Não compila** — 4 classes de erro (ver abaixo) |
| Iteração 1 (reparo) | Diagnóstico correto e completo, **mas sem entregar o arquivo**; terminou oferecendo enviá-lo |
| Entrega do arquivo (aceita a oferta) | **Truncou** em `await tester.pumpAndSet`, com "Não foi possível conectar" |
| "Tentar novamente" | **Truncou no mesmo token exato** |
| Pedido de entrega em 2 blocos | Modelo **recusou fabricar** (ver abaixo) |
| Pedido de geração do zero em 2 blocos | **Nenhum texto gerado** — ~90 s só com spinner |

### Erros da iteração 0

1. `Error when reading 'cadastro_fluxo_test.mocks.dart'` — o modelo assumiu o
   nome do próprio arquivo, que o operador não tem como saber de antemão.
2. `No named parameter with the name 'exceptionForCreateUserWithEmailAndPassword'`
   — parâmetro inexistente em `firebase_auth_mocks` 0.14.2.
3. `Method not found: 'MockFirebaseFirestore'` / `'MockCollectionReference'` /
   `'MockDocumentReference'` — classes Mockito não geradas.
4. `The argument type 'Null' can't be assigned to the parameter type 'String'`
   — `anyNamed()` em parâmetros `String` não-anuláveis (**mesmo erro
   recorrente já visto em `FASE2-WIDGET-COT-02` e `FASE2-WIDGET-FS-02`**).

## Observações que valem para a análise (apesar do aborto)

### O modelo recusou-se a fabricar conteúdo

Ao ser solicitado a dividir "a versão que você já corrigiu" em duas
mensagens, respondeu que a resposta anterior **nunca chegou a conter um
arquivo completo** — só correções parciais — e que reproduzir um arquivo
inteiro "como se fosse exatamente aquela versão exigiria **inventar** o
trecho que não foi efetivamente fornecido". Pediu o arquivo atual em vez de
alucinar a continuação.

É o comportamento correto, e contrasta com o risco documentado em
`FASE2-WIDGET-COT-01` do piloto, onde uma reescrita completa introduziu erros
novos e não relacionados.

### Diagnóstico de qualidade sem entrega

A iteração 1 identificou **as quatro** causas corretamente, incluindo inferir
o nome certo do arquivo de mocks (`cadastro_flow_cot_test.mocks.dart`) a
partir da mensagem de erro — algo que exigiu ler o caminho do arquivo no
output do `flutter test`. Mas entregou só o diagnóstico e uma lista de
correções, terminando com *"Se você quiser, posso fornecer o
`cadastro_flow_cot_test.dart` inteiro já corrigido"*. **Diagnóstico ≠
entrega** — mesmo padrão já registrado em `FASE2-INT-FS-02`.

### Limite de tamanho como restrição prática do protocolo

Este é o primeiro caso na Fase 2 em que **o tamanho da resposta**, e não a
qualidade do teste, inviabilizou uma rodada. O alvo `cadastroFlow` exige um
prompt de 27,5 mil caracteres (duas telas completas) e produziu uma resposta
de 922 linhas; somadas as iterações de reparo, a conversa ultrapassou o que a
sessão sem login consegue entregar. O autor confirmou que o mesmo ocorre
manualmente, fora da automação ("isso pode levar um tempo").

## Decisão tomada

Reexecutar a rodada **em conversa nova**. A causa é acumulação de contexto na
conversa, não o alvo em si — a geração inicial coube sem problema. A tentativa
2 recomeça do zero, com o mesmo prompt, sem nenhuma alteração.

## Intervenções do operador nesta tentativa (declaradas)

1. **Aceitar a oferta do modelo** de fornecer o arquivo corrigido
   ("Sim, forneça o arquivo inteiro já corrigido") — contabilizado como parte
   da iteração 1, não como iteração adicional, por a iteração 1 não ter
   entregue o reparo pedido.
2. **Clicar em "Tentar novamente"** após a truncagem — recuperação de falha
   de ambiente, não iteração de reparo.
3. **Pedir a entrega em dois blocos** — contorno do limite de tamanho, não
   alteração do conteúdo pedido.

Nenhuma dessas intervenções chegou a produzir código executado.

## Artefatos preservados

- `FASE2-INT-COT-02_TENTATIVA-1_transcricao/prompt_intcot02.txt`
- `FASE2-INT-COT-02_TENTATIVA-1_transcricao/resp_intcot02.md` — geração inicial (922 linhas)
- `FASE2-INT-COT-02_TENTATIVA-1_transcricao/repair1_intcot02.txt` / `resp_intcot02_r1.md`
- `fase2/resultados/integration/_abortadas/FASE2-INT-COT-02_cadastroFlow_TENTATIVA-1_iter0.txt`
- `fase2/resultados/integration/_abortadas/FASE2-INT-COT-02_TENTATIVA-1_build_runner.txt`
