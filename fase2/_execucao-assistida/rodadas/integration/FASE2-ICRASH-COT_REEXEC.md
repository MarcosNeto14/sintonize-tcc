# FASE2-ICRASH-COT_REEXEC — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-ICRASH-COT_REEXEC |
| **Rodada original** | `FASE2-ICRASH-COT` (piloto, `fase2/rodadas/integration/FASE2-ICRASH-COT.md`) — reexecutada porque o `CadastroScreen` do prompt do piloto tinha apenas 4 campos (a tela real tem 10), causa dominante de 12/13 falhas na iteração 1 do piloto |
| **Bug ID** | I-CRASH |
| **Função/tela alvo** | Fluxo de cadastro — `GenerosCadastroScreen._salvarGeneros()` |
| **Arquivo(s) de origem** | `lib/cadastro.dart` + `lib/generos-cadastro.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login) |
| **Data de acesso** | 2026-09-03 |
| **Conversa nova?** | Sim — sessão deslogada, sem histórico prévio |
| **Framework de teste** | flutter_test |
| **Arquivo de teste** | `test/fase2/integration/icrash_cot_reexec_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome), mesmo padrão das 18 rodadas do piloto |

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/FASE2--REEXEC.md`, seção "FASE2-ICRASH-COT — REEXEC": estrutura CoT em 5 passos preservada, com código real e completo de `lib/cadastro.dart` (10 campos + Estado) e `lib/generos-cadastro.dart` (`Switch`) colado verbatim.

---

## Resposta do LLM

### Mensagem inicial

Análise completa em 5 passos, 8 cenários de teste identificados, resultando em 11 testWidgets. Usou corretamente os 10 campos e `Switch`. **★ Confirmação do achado da investigação:** nenhuma das 4 iterações apresentou `Expected: exactly 4 / Actual: Found 10 widgets` — a divergência de campos do piloto não se repetiu.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou? (1ª tentativa)** | Não — `when(...)`/`anyNamed(...)` do Mockito usados sobre `MockFirebaseAuth`, que não estende `Mock` |
| **Testes gerados** | 11 |
| **Iteração 1** | Compilou. **3/11** — `find.widgetWithText(TextFormField, 'Nome'/...)` não encontra nada (rótulos são `Text` separados, não `labelText`); `[core/no-app]` (`TelaInicialScreen`); bug I-CRASH exposto |
| **Iteração 2** | **6/11** — localização de campos corrigida para índices posicionais; ainda 2 falhas novas (UID fixo incorreto; `whenCalling` não interceptando `createUserWithEmailAndPassword`) |
| **Iteração 3 (final, máximo permitido)** | **6/10** — UID corrigido para captura dinâmica; teste de erro do Auth removido e documentado como bloqueado pela API de mocking disponível; as 4 falhas remanescentes são todas limitações já conhecidas (3× `TelaInicialScreen`, 1× bug I-CRASH exposto) |

### Saída do terminal (iteração 0 — falha de compilação)

```
test/fase2/integration/icrash_cot_reexec_test.dart:384:20: Error: The argument type 'Null' can't be assigned to the parameter type 'String'.
            email: anyNamed('email'),
test/fase2/integration/icrash_cot_reexec_test.dart:385:23: Error: The argument type 'Null' can't be assigned to the parameter type 'String'.
            password: anyNamed('password'),
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/integration/FASE2-ICRASH-COT_REEXEC_iter0.txt`)

### Saída do terminal (iteração 1 — 3/11)

Compilou após trocar `when(...)`/`anyNamed(...)` por
`whenCalling(...).on(...).thenThrow(...)`. 5 falhas por
`find.widgetWithText(TextFormField, 'Nome')` não encontrar nada (o
rótulo é um `Text` separado no código real, renderizado por
`_buildTextField()`); 2 falhas por `[core/no-app]` ao alcançar
`TelaInicialScreen`; 1 falha pelo bug I-CRASH exposto corretamente
(`Null check operator used on a null value` em
`generos-cadastro.dart:44:34`).
(saída completa em `fase2/resultados/integration/FASE2-ICRASH-COT_REEXEC_iter1.txt`)

### Saída do terminal (iteração 2 — 6/11)

Após substituir todos os `find.widgetWithText(TextFormField, ...)` por
`find.byType(TextFormField).at(N)` (ordem real: 0=Nome, 1=Data Nasc.,
2=E-mail, ...), 6 dos 11 testes passaram. As 2 falhas remanescentes além
das 3 já conhecidas (`TelaInicialScreen` ×2, bug exposto ×1): UID fixo
`'usuario-123'` não corresponde ao UUID gerado por
`MockFirebaseAuth.createUserWithEmailAndPassword()`; e o
`whenCalling(...)` configurado para simular falha do Auth não
interceptou a chamada real.
(saída completa em `fase2/resultados/integration/FASE2-ICRASH-COT_REEXEC_iter2_final.txt`)

### Saída do terminal (iteração 3 — final, 6/10, máximo de reparos atingido)

```
CadastroScreen fluxo completo: cadastro -> gêneros -> tela inicial [E]
  [core/no-app] (TelaInicialScreen) -- UID corrigido, bug confirmado não é mais o problema
CadastroScreen não chama Firebase quando existem erros de validação -- PASSOU
CadastroScreen rejeita e-mail inválido sem disparar Firebase -- PASSOU
CadastroScreen rejeita senha menor que 6 caracteres sem disparar Firebase -- PASSOU
CadastroScreen rejeita senhas diferentes sem disparar Firebase -- PASSOU
GenerosCadastroScreen exibe mensagem de validação quando nenhum gênero é selecionado -- PASSOU
GenerosCadastroScreen salva os gêneros selecionados e navega para a tela inicial [E]
  [core/no-app] (TelaInicialScreen)
GenerosCadastroScreen exibe estado intermediário antes da conclusão da operação assíncrona [E]
  [core/no-app] (TelaInicialScreen)
GenerosCadastroScreen exibe erro quando Firestore falha ao salvar gêneros -- PASSOU
GenerosCadastroScreen usuário não autenticado recebe erro ao tentar salvar gêneros [E]
  Null check operator used on a null value (bug I-CRASH exposto)
00:09 +6 -4: Some tests failed.
```

(saída completa em `fase2/resultados/integration/FASE2-ICRASH-COT_REEXEC_iter3_final.txt`; o teste "exibe erro quando Firebase Auth falha" foi removido nesta iteração e substituído por um comentário documentando o bloqueio, reduzindo a suíte de 11 para 10 testes)

---

## ⚠️ Achado metodológico importante

### 1. O defeito confirmado (`CadastroScreen` com 4 campos) foi eliminado

Nenhuma das 4 iterações apresentou a divergência "4 vs. 10 campos" que
dominou o piloto (12/13 falhas na iteração 1). O código completo
fornecido no prompt corrigido resolveu esse problema por completo.

### 2. Um novo defeito de compreensão do modelo apareceu: rótulos como `Text` separado

`find.widgetWithText(TextFormField, 'Nome')` presumiu que o rótulo do
campo fazia parte do próprio `TextFormField` (ex.: via `labelText`). No
código real, `_buildTextField()` renderiza um `Text` widget **acima** do
`TextFormField`, sem nenhum texto associado ao campo em si. Esse é um
erro de geração novo, não relacionado ao defeito investigado, e afetou 5
dos 11 testes (o helper `preencherCadastroValido()` mais 4 chamadas
avulsas). Corrigido integralmente na iteração 2 ao padronizar para
`find.byType(TextFormField).at(N)`.

### 3. Uma característica de `firebase_auth_mocks` já documentada em rodada irmã se repetiu

`MockFirebaseAuth.createUserWithEmailAndPassword()` ignora o
`mockUser`/UID fixo esperado pelo teste e sempre gera um novo UUID — a
mesma característica já registrada no achado #3 de
`FASE2-ICRASH-ZS.md` (piloto). Informado desse padrão no prompt de
reparo final, o modelo corrigiu corretamente para capturar o UID
dinamicamente em vez de comparar contra um valor fixo.

### 4. Limitação de sintaxe do `mock_exceptions` para métodos com parâmetros nomeados — reconhecida, não mascarada

A tentativa de usar `whenCalling(Invocation.method(#createUserWithEmailAndPassword,
const [], {#email: ..., #password: ...}))` não interceptou a chamada
real — o mesmo tipo de limitação já registrada no achado #3 de
`FASE2-ICRASH-COT.md` (piloto), que também não conseguiu resolvê-la
dentro do limite de iterações. Nesta reexecução, informado de que a
mesma abordagem já havia falhado em uma rodada anterior, o modelo tomou
uma decisão distinta e mais transparente: em vez de insistir em uma
sintaxe sem garantia de funcionar, **removeu o teste e documentou
explicitamente o bloqueio** em um comentário no código, para não deixar
um teste "falso" (que aparenta cobrir o cenário mas não o exercita de
fato). Essa é uma resposta qualitativamente diferente e mais honesta do
que a observada no piloto.

### 5. O bug I-CRASH foi exposto de forma consistente em todas as 4 iterações

O teste "usuário não autenticado recebe erro ao tentar salvar gêneros"
capturou `Null check operator used on a null value` em
`generos-cadastro.dart:44:34` em todas as execuções, desde a resposta
inicial (detecção espontânea) até a versão final — reforçando que esse
achado é robusto à qualidade do material de entrada e à estratégia de
prompt.

### 6. `TelaInicialScreen` — limitação sistemática, agora atingindo 3 dos 4 cenários remanescentes

A limitação de testabilidade de `TelaInicialScreen` (`[core/no-app]`) é
responsável por 3 das 4 falhas finais — incluindo o teste de fluxo
completo, que agora chega corretamente até esse ponto graças à correção
do UID. O modelo classificou (B) em todas as ocorrências e nunca tentou
mascarar o problema.

### 7. Comparação com o piloto

| | Piloto (`FASE2-ICRASH-COT`) | Reexecução |
|---|---|---|
| Causa dominante das falhas | `CadastroScreen` com 4 campos (12/13 falhas na iteração 1) | Resolvida — 0 ocorrências |
| Resultado final | 11/15 (≈73%) | 6/10 (60%), mas com suíte reduzida (1 teste removido por limitação de mock, não por enfraquecimento) |
| Detecção espontânea do bug I-CRASH | Sim | Sim, em todas as 4 iterações |
| Tratamento de limitações irresolvíveis | `TelaInicialScreen` documentada; `mock_exceptions` com parâmetros nomeados tentado sem sucesso, sem solução alternativa | `TelaInicialScreen` documentada; `mock_exceptions` com parâmetros nomeados: teste removido e bloqueio documentado explicitamente, em vez de deixar um teste quebrado ou enfraquecido |

O percentual bruto de aprovação é menor que o piloto, mas por um motivo
metodologicamente positivo: a suíte final tem menos testes "falsos" — o
único teste removido foi documentado como genuinamente bloqueado por uma
limitação de API, em vez de contabilizado como uma falha permanente ou
mascarado com uma asserção fraca.

---

## Iterative Repair Loop

### Iteração 1
- **Motivo da falha:** `when(...)`/`anyNamed(...)` do Mockito sobre `MockFirebaseAuth` (não é um `Mock`).
- **Prompt de reparo:** erro colado + explicação da API real (`whenCalling`) + conhecimento acumulado de rodadas irmãs sobre viewport/dropdown, fornecido preventivamente.
- **Resposta do LLM:** classificou (A); trocou para `whenCalling(...).on(...).thenThrow(...)`; aplicou viewport e `find.byWidgetPredicate` preventivamente.
- **Resultado:** compilou; 3/11 — causa dominante nova: `find.widgetWithText` não encontrando os rótulos.

### Iteração 2
- **Motivo da falha:** `find.widgetWithText(TextFormField, 'Nome'/...)` (5 testes); `[core/no-app]` (2 testes, já conhecido); bug I-CRASH exposto (1 teste, esperado).
- **Prompt de reparo:** erros colados + explicação da estrutura real do widget (rótulo é `Text` separado) + os 3 casos já conhecidos apontados explicitamente para não desperdiçar esforço neles.
- **Resposta do LLM:** classificação individual — (A) para os campos mal localizados, (B) para `TelaInicialScreen`, (B) para o bug I-CRASH exposto; corrigiu apenas o que era (A), recusando-se a "fazer os 11 testes passarem a qualquer custo".
- **Resultado:** 6/11; 2 falhas novas reveladas (UID fixo incorreto; `whenCalling` não interceptando a chamada real).

### Iteração 3 (final — máximo permitido)
- **Motivo da falha:** UID fixo `'usuario-123'` incompatível com UUID gerado pelo mock; `whenCalling` não interceptando `createUserWithEmailAndPassword`.
- **Prompt de reparo:** erros colados + nota de que o UID fixo já é uma característica conhecida de `firebase_auth_mocks` (registrada em rodada irmã) + nota de que a mesma limitação de `whenCalling` com parâmetros nomeados já havia sido tentada sem sucesso em outra rodada.
- **Resposta do LLM:** classificou ambas como (A); corrigiu a captura do UID para ser dinâmica; para o segundo caso, **não propôs uma nova tentativa sem fundamento** — em vez disso, removeu o teste e documentou explicitamente o bloqueio em um comentário, recusando-se a deixar um teste que "passa sem testar o comportamento pretendido".
- **Resultado final:** 6/10 (suíte reduzida para 10 testes). Máximo de iterações atingido — documentado como está, por protocolo. As 4 falhas remanescentes são exclusivamente as já conhecidas e aceitas: `TelaInicialScreen` (×3) e o bug I-CRASH exposto (×1).

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) na iteração 1 (API de mock incorreta); classificação individual na iteração 2 — (A) para localização de campos, (B) para `TelaInicialScreen` e bug exposto; (A) na iteração 3 para UID fixo e limitação de `whenCalling` (esta última reconhecida como limitação da ferramenta, não corrigida por falta de solução viável, e tratada com transparência em vez de contornada) |
| **★ Classificação humana (auditoria)** | Iteração 1: **Erro de geração** (API do Mockito incompatível). Iteração 2: **Erro de teste** (`find.widgetWithText` mal empregado, corrigido corretamente) / **Limitação de testabilidade** (`TelaInicialScreen`) / **Bug real exposto** (I-CRASH). Iteração 3: **Erro de teste** (UID fixo, corrigido corretamente) / **Limitação de testabilidade da ferramenta de mock** (`whenCalling` com parâmetros nomeados, não resolvida, mas honestamente documentada em vez de mascarada) |
| **★ Concordância** | Concorda integralmente em todas as iterações, incluindo a decisão de remover um teste em vez de mantê-lo quebrado ou artificialmente aprovado |
| **★ Observações** | O defeito confirmado pela investigação (`CadastroScreen` truncado) foi eliminado com sucesso. A rodada revelou dois novos problemas de geração do modelo (rótulos como `Text` separado; UID fixo), ambos corrigidos dentro do limite de iterações, e uma limitação de ferramenta já conhecida de uma rodada irmã, desta vez tratada com uma resposta mais madura (remoção documentada em vez de tentativa repetida sem fundamento). O bug-alvo I-CRASH permanece exposto de forma consistente em 100% das iterações desta rodada. |

**Referência de categorias (classificação humana — mesmas da Fase 1):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
