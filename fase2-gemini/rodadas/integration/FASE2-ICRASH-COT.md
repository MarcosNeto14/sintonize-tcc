# FASE2-ICRASH-COT — Réplica Gemini

Rodada **15/60**. Fecha o bloco I-CRASH.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-ICRASH-COT |
| **Bug ID** | I-CRASH |
| **Função/tela alvo** | `GenerosCadastroScreen._salvarGeneros` |
| **Arquivo(s) de origem** | `lib/generos-cadastro.dart`, `lib/cadastro.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor do app com `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-piloto`, I-CRASH ativo |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/integration/icrash_cot_test.dart` |
| **Saídas arquivadas** | `resultados/integration/FASE2-ICRASH-COT_iter{0,1,2,3_final}.txt` |
| **Modo de execução** | Manual |
| **Versão do prompt** | **Original, defeituoso** — o mesmo de `prompts_prontos/FASE2-ICRASH-COT.md`, sem correção, para manter a comparação com 13 e 14. |

---

## ⚠ Material do prompt × app real

Mesmos defeitos das rodadas 13 e 14, menos o exemplo few-shot:

1. **`SwitchListTile` que a tela real não usa** — a real usa `Switch`
   (`lib/generos-cadastro.dart:162`).
2. **`CadastroScreen` com 4 campos quando a real tem 10.** Com isso, os
   validadores e a ordem dos `TextFormField` do prompt não correspondem aos da
   tela: com senha vazia a real devolve `'A senha é obrigatória'`
   (`lib/cadastro.dart:286`), não a mensagem de 6 caracteres.
3. **`Navigator.push` sem repassar `auth`/`firestore`** no snippet; o código
   real repassa (`lib/cadastro.dart:162-170`).

Diferente da 14, **este prompt pede explicitamente o cenário "usuário não
autenticado ao chegar em GenerosCadastroScreen"** (passo 4).

---

## Resposta do LLM — geração inicial

Seguiu os 5 passos do CoT. 6 testes, imports `package:sintonize/...`
corretos de primeira, stub local de `TelaInicialScreen`, `MockFailingAuth`
com `extends Mock implements FirebaseAuth`.

**Primeira rodada do bloco a transformar o requisito "não autenticado" em
teste.** Mas o teste é escrito como *expectativa* do crash:

```dart
// A chamada `widget.auth.currentUser!.uid` causará TypeError em runtime
await tester.tap(find.text('Confirmar'));
await tester.pump();

expect(tester.takeException(), isA<TypeError>());
```

No passo 4 descreve o cenário como "disparando erro de null check operator
tratado/esperado". O modelo leu o `!` fora do `try`, previu o `TypeError`
corretamente e **o fixou como comportamento esperado**. Nenhuma palavra sobre
isso ser um defeito.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 6 |
| **Testes passaram (1ª execução)** | 0 |
| **Iterações de reparo** | **3 (máximo)** |
| **Testes passaram (pós-repair)** | **2** |
| **Testes falharam (pós-repair)** | **4** |
| **Tentativas de envio até obter resposta** | 1 |
| **Bug plantado exercitado?** | **Sim** — a partir da iteração 2, `generos-cadastro.dart:44:34` lança `Null check operator used on a null value` |
| **Bug plantado capturado por asserção?** | **Não — canonizado.** A asserção espera o `TypeError` |
| **Bug plantado mencionado na resposta?** | **Sim, na iteração 3**, como (B) correto |

---

## Iterative Repair Loop

### Iteração 1

- **Motivo:** 0/6. Botões `Cadastrar` (y=870) e `Confirmar` (y=618) fora da
  viewport 800×600; `find.widgetWithText(SwitchListTile, ...)` sem
  correspondência.
- **★ Autoclassificação:** **(A)**. Viewport e seleção de widget.
- **Correção:** viewport 540×1110 lógico, `ensureVisible()` antes de cada tap,
  tap em `find.text('Rock')` no lugar do `SwitchListTile`.
- **Resultado:** **1/6** (aviso "Selecione pelo menos um gênero" passa). Tap
  no texto não alterna o `Switch`, então o fluxo continua sem chegar a
  `_salvarGeneros`.
- Saída: `FASE2-ICRASH-COT_iter1.txt`

### Iteração 2

- **Motivo:** 5 falhas — mensagens de validação ausentes, `SnackBar` de auth
  ausente, `generos_favoritos` `null`, `SnackBar` de erro do Firestore
  ausente, `takeException()` `null`.
- **★ Autoclassificação:** **(A)**. Diagnóstico da Falha 5 correto: "como o
  switch 'Rock' não foi ativado [...] `_salvarGeneros()` nunca chegou a ser
  chamada".
- **Correção:** `find.byType(Switch).at(i)` — por acaso coincide com a tela
  real, que usa `Switch`. `MockFailingAuth` trocado por subclasse de
  `MockFirebaseAuth`. **Asserção do crash enfraquecida:**
  `isA<TypeError>()` → `isNotNull`, sob classificação (A).
- **Resultado:** **2/6.** Pela primeira vez no bloco, **o bug plantado é
  exercitado**: `_TypeError` em `generos-cadastro.dart:44:34`, via
  `_confirmar` (`:72`). O teste falha porque a exceção sobe no tap e
  `takeException()` retorna `null`. O teste de sucesso grava no Firestore e
  quebra ao montar a `TelaInicialScreen` **real** (`[core/no-app]` em
  `tela-inicial.dart:43`) — o stub do arquivo de teste nunca é usado.
- Saída: `FASE2-ICRASH-COT_iter2.txt`

### Iteração 3 (máximo)

- **★ Autoclassificação:** **(B)**, com três itens. Devolveu código mesmo
  assim.
- **Correção:** remove o stub, troca `pumpAndSettle` por `pump` no teste de
  sucesso e aceita `FirebaseException` condicionalmente
  (`if (exception != null) expect(exception, isA<FirebaseException>())`);
  intercepta `FlutterError.onError` para capturar o `TypeError`.
- **Resultado:** **2/6**. O teste do crash falha com
  `'_pendingExceptionDetails != null'` — o override de `FlutterError.onError`
  conflita com o binding. O de sucesso ainda falha com `[core/no-app]`.
- Saída final: `FASE2-ICRASH-COT_iter3_final.txt`

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(A)**, **(A)**, **(B)**. |
| **★ Classificação humana (auditoria)** | Iterações 1 e 2: **Erro de teste**, corretas. Iteração 3: **(B) correto em 2 de 3 itens.** Ver abaixo. |
| **★ Concordância** | **Parcial**, na iteração 3. |

### O (B) da iteração 3, ponto a ponto

**Item 2 — o bug plantado, diagnosticado com precisão.**

> "A linha 44 de GenerosCadastroScreen assume cegamente que há um usuário
> logado usando bang operator: `final uid = widget.auth.currentUser!.uid;`
> [...] Deveria haver tratamento defensivo (por exemplo,
> `if (widget.auth.currentUser == null)` redirecionando para login ou
> exibindo uma mensagem amigável via SnackBar)."

Arquivo, linha, causa e correção corretos. **É o primeiro (B) da réplica que
nomeia um bug plantado.**

**Mas o código entregue na mesma resposta continua exigindo o crash:**

```dart
// Confirma que a exceção disparada pela aplicação é TypeError
expect(errorCaptured!.exception, isA<TypeError>());
```

O texto classifica como defeito; o teste fixa o defeito como especificação.
Aplicada a correção que o próprio modelo propõe, este teste quebra.

**Item 1 — correto.** `TelaInicialScreen` acopla `FirebaseAuth.instance` no
`initState` (`tela-inicial.dart:43`). Mesmo diagnóstico das rodadas 10 e 12,
e de novo porque o material aqui corresponde ao app: o stack trace aponta o
arquivo real.

**Item 3 — errado.** Atribui a ausência das mensagens a "divergência na
string de validação" ou ao `ScaffoldMessenger`. A causa é a tela real ter
10 campos, com outra ordem e outros validadores.

### O padrão do (B), agora com cinco casos

| Rodada | (B) declarado | Defeito diagnosticado | Existe no app? |
|---|---|---|---|
| 10 (WSILENT-ZS) | sim | `TelaInicialScreen` acopla `FirebaseAuth.instance` | **sim** |
| 12 (WSILENT-COT) | sim | idem | **sim** |
| 13 (ICRASH-ZS) | sim | `ListView` sem altura em `Column` | **não** |
| 14 (ICRASH-FS) | sim | `Navigator.push` sem injeção + 2 outros | **não** |
| 15 (ICRASH-COT) | sim | `currentUser!` fora do `try` + `TelaInicialScreen` + validação | **sim, sim, não** |

Confirma o divisor: cada item do (B) acerta quando a evidência que o modelo
tem vem do app real (stack trace apontando `generos-cadastro.dart:44` e
`tela-inicial.dart:43`) e erra quando vem só do snippet do prompt (os
validadores do cadastro).

### Observações

1. **Canonizar, agora na integração.** Mesmo padrão do bloco W-SILENT: o
   modelo vê o comportamento defeituoso e escreve um teste que o exige. Aqui
   é mais explícito, porque na iteração 3 o próprio modelo chama de defeito o
   que o teste afirma.
2. **O requisito explícito fez diferença.** ZS também pedia "usuário não
   autenticado" e não gerou o teste; FS não pedia. O COT, com a lista de
   cenários como passo obrigatório, foi o único a exercitar o bug.
3. **Enfraquecimento sob (A).** Na iteração 2, `isA<TypeError>()` virou
   `isNotNull` sem classificação (B). O prompt de reparo só proíbe
   enfraquecer sob (B).
4. **Rodada a separar na análise**, junto com 13 e 14 (prompt defeituoso).
