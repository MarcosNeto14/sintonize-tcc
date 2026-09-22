# FASE2-WSILENT-COT — Réplica Gemini

Rodada **12/60**. Fecha o bloco W-SILENT e o nível widget do piloto.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WSILENT-COT |
| **Bug ID** | W-SILENT |
| **Função/tela alvo** | `LoginScreen.login()` |
| **Arquivo(s) de origem** | `lib/login.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada — ver `../unit/FASE2-UCRASH-ZS.md`. |
| **✦ Verificação externa da versão** | Seletor do app com `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-piloto`, W-SILENT ativo |
| **Framework de teste** | flutter_test + mockito (mocks gerados por `build_runner`) |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/widget/wsilent_cot_test.dart` (+ `.mocks.dart`, gerado) |
| **Saídas arquivadas** | `resultados/widget/FASE2-WSILENT-COT_iter{0,1_final}.txt` |
| **Modo de execução** | Manual (operador colou prompt e respostas) |

---

## O prompt mais favorável de todo o experimento

Além dos quatro passos obrigatórios e da linha de ajuda do caminho de import,
o passo 3 traz uma instrução que existe só nesta rodada:

> "Cenários de erro (Firebase retorna erro, rede falha) — **inclua
> especificamente os diferentes códigos de erro do Firebase Auth e as
> mensagens exibidas para cada um**"

O modelo é obrigado a (a) analisar o widget antes de escrever, e (b) enumerar
cada código **junto com sua mensagem**. O bug é exatamente uma troca entre
duas dessas mensagens. Não há condição mais favorável possível dentro do
desenho do experimento.

---

## Resposta do LLM — geração inicial

Cumpriu os quatro passos. 10 testes, mocks via `@GenerateNiceMocks`, uso de
`verifyNever` para provar que o Firebase não é chamado quando a validação
falha, verificação do `trim()` nos parâmetros e do `obscureText` no campo de
senha. Tecnicamente, a suíte mais criteriosa do bloco.

**E o passo 3 enunciou o par invertido, literalmente:**

> `user-not-found`: Exibe SnackBar com a mensagem "Senha incorreta.
> Certifique-se de que está digitando a senha corretamente."
>
> `wrong-password`: Exibe SnackBar com a mensagem "Usuário não encontrado.
> Verifique o e-mail e tente novamente."

Escreveu as duas linhas, uma embaixo da outra, e seguiu adiante. Nomeou os
testes correspondentes:

```dart
testWidgets('deve exibir mensagem correta para código "user-not-found"', ...
testWidgets('deve exibir mensagem correta para código "wrong-password"', ...
```

**Chamou de "correta".** Nenhuma observação, nenhuma ressalva.

### Nota de execução

Import do arquivo de mocks ajustado ao nome real do teste
(`login_test.mocks.dart` → `wsilent_cot_test.mocks.dart`), imposto pela
convenção de nomes da réplica. Mesma adaptação mecânica da rodada 9; nenhum
outro token alterado. `build_runner` executado conforme a instrução da própria
resposta.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 10 |
| **Testes passaram (1ª execução)** | 9 |
| **Testes falharam (1ª execução)** | 1 |
| **Iterações de reparo** | 1 |
| **Testes passaram (pós-repair)** | 9 (sem código novo) |
| **Testes falharam (pós-repair)** | 1 |
| **Tentativas de envio até obter resposta** | 1 |
| **Bug plantado capturado por asserção?** | **Não — fixado como comportamento esperado** |
| **Bug plantado mencionado na resposta?** | **Não** |

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** `[core/no-app] No Firebase App '[DEFAULT]'` no teste de
  fluxo de sucesso. `pushReplacement` monta `TelaInicialScreen`, cujo
  `initState` chama `FirebaseAuth.instance` estático.
- **★ Autoclassificação do modelo:** **(B)** — bug real exposto.
- **Resposta:** coerente com o caminho (B), **não devolveu código**. Concluiu:

  > "Alterar o teste para inicializar mocks do Core do Firebase ou remover a
  > validação de que a tela inicial foi de fato aberta apenas contornaria um
  > defeito arquitetural."

- **Resultado:** sem correção. A rodada encerra em 9/10; iterações 2 e 3 não
  foram usadas.
- Saída final: `FASE2-WSILENT-COT_iter1_final.txt` (idêntica à da geração
  inicial).

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(B)** na iteração 1, declarada e bem fundamentada. |
| **★ Classificação humana (auditoria)** | **Limitação de testabilidade** — defeito real de desenho da aplicação, corretamente identificado. Não é o bug plantado. |
| **★ Concordância** | **Sim**, com a mesma ressalva de vocabulário da rodada 10. |
| **★ Observações** | Ver abaixo. |

### O (B) é consistente e é o mesmo da rodada 10

ZS e COT, em conversas independentes, chegaram ao mesmo diagnóstico e à mesma
conclusão: `LoginScreen` externaliza `auth` por injeção, instancia
`TelaInicialScreen()` sem repassar nada, e essa tela acopla o singleton
estático no `initState`. Ambas recusaram enfraquecer o teste.

Consistência entre estratégias em cima de um achado que **não estava
plantado** é um dado positivo sobre o caminho (B) do prompt de reparo: quando
há um defeito real e visível no caminho de execução, o modelo o encontra e se
recusa a mascará-lo.

Isso torna o silêncio sobre o W-SILENT mais informativo, não menos: o modelo é
capaz de reconhecer e defender um problema da aplicação. O W-SILENT não foi
ignorado por falta de disposição — foi ignorado por não ter sido **percebido**.

### O enunciado do bug não produziu a percepção do bug

Este é o resultado central da rodada, e o mais forte do bloco.

O modelo **escreveu o bug com todas as letras** no passo de planejamento:
associou `user-not-found` a "Senha incorreta" e `wrong-password` a "Usuário
não encontrado", em linhas consecutivas. Depois chamou ambos de "correta" nos
nomes dos testes.

Ter enunciado o par não gerou a comparação entre o significado do código de
erro e o conteúdo da mensagem. O passo de análise produziu **transcrição
estruturada**, não **avaliação**. A cadeia de raciocínio organizou a
informação sem interrogá-la.

Comparar com a rodada 3 (`UCRASH-COT`), onde o mesmo passo 1 produziu:

> "apesar do comentário indicar que 'trata palavras vazias internas', a
> implementação atual não trata esse caso"

Lá a análise confrontou duas fontes; aqui apenas copiou uma. A diferença entre
os dois casos não é o passo de análise — é se havia, no material, **duas
afirmações em conflito sintático** para confrontar.

---

## Fechamento do bloco W-SILENT (rodadas 10–12)

| | ZS | FS | COT |
|---|---|---|---|
| Ajuda do caminho de import | sim | **não** | sim |
| Compilou de primeira | sim | **não** | sim |
| Iterações de reparo | 2 | 2 | 1 |
| Testes gerados | 11 | 9 | 10 |
| Resultado final | 10/11 | 9/9 | 9/10 |
| **Testa a aplicação?** | sim | **não** (widget colado no teste) | sim |
| Mencionou o bug | não | não | não |
| **Asserção que captura o bug** | **não** | **não** | **não** |
| **Bug fixado como esperado?** | **sim** | **sim** | **sim** |
| Autoclassificação | (A), (B) | (A), (A) | (B) |

**As três estratégias escreveram um teste por código de erro, e as três
fixaram o par invertido como comportamento esperado.** Corrigir o W-SILENT
quebraria testes em todas as três suítes.

---

## Fechamento do nível widget do piloto (rodadas 7–12)

| Bloco | Detecção | Bug fixado como esperado |
|---|---|---|
| W-CRASH (7-9) | 0/3 | não (ignorado) |
| W-SILENT (10-12) | 0/3 | **3/3** |
| **Total widget** | **0/6** | |

Contra **6/6 de detecção no nível unitário** (rodadas 1-6), todas em (C), todas
na geração inicial.

### A hipótese, na forma em que o bloco a deixa

Não é o nível da pirâmide em si. É se o defeito produz, **no material que o
modelo recebe, uma incoerência local e sintaticamente visível**:

| Bug | Incoerência disponível | Detectado |
|---|---|---|
| U-CRASH | docstring diz "trata palavras vazias", código não trata | **sim, 3/3** |
| U-SILENT | docstring "mínimo 6", mensagem "pelo menos 6", condição `< 7` | **sim, 3/3** |
| W-CRASH | `??` presente no `itemBuilder`, ausente no filtro — 100 linhas de distância | não, 0/3 |
| W-SILENT | nenhuma. Exige saber o que `user-not-found` significa e ler uma frase em português | não, 0/3 |

Nos dois casos detectados havia **texto afirmando X ao lado de código fazendo
não-X**. Nos dois não detectados, ou a contradição está distante no arquivo,
ou é puramente semântica e não tem contraparte textual no material.

Os blocos de integração (rodadas 13-18) testam se isso se mantém quando o
alvo cresce mais uma ordem de grandeza.
