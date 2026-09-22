# FASE2-WSILENT-FS — Réplica Gemini

Rodada **11/60**.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WSILENT-FS |
| **Bug ID** | W-SILENT |
| **Função/tela alvo** | `LoginScreen.login()` |
| **Arquivo(s) de origem** | `lib/login.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada — ver `../unit/FASE2-UCRASH-ZS.md`. |
| **✦ Verificação externa da versão** | Seletor do app com `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-piloto`, W-SILENT ativo |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/widget/wsilent_fs_test.dart` |
| **Saídas arquivadas** | `resultados/widget/FASE2-WSILENT-FS_iter{0,1,2_final}.txt` |
| **Modo de execução** | Manual (operador colou prompt e respostas) |
| **Versão do prompt** | **Original**, com o exemplo few-shot defeituoso. A versão corrigida (`FASE2--REEXEC.md`) roda como rodada separada, fora da contagem de 60. |

---

## O prompt tem duas particularidades que definem a rodada

**1. O exemplo few-shot usa uma API inexistente.**

```dart
final authComErro = MockFirebaseAuth(
  authExceptions: AuthExceptions(
    signInWithEmailAndPassword: FirebaseAuthException(code: 'wrong-password'),
  ),
);
```

`AuthExceptions` não existe em `firebase_auth_mocks` 0.14.2. Foi esse defeito
que motivou a reexecução desta rodada na Fase 2.

**2. O exemplo é um oráculo acidental do W-SILENT.**

A asserção do exemplo, para `wrong-password`, é:

```dart
expect(find.textContaining('incorreta'), findsOneWidget);
```

Ou seja: senha errada → mensagem contendo "incorreta". **É o comportamento
correto**, e contradiz o código sob teste, onde `wrong-password` devolve
"Usuário não encontrado". Pela primeira vez no bloco widget, o prompt carrega
uma fonte independente do comportamento esperado.

Não é ajuda deliberada — é acidente do material herdado da Fase 2. Mas
funciona como teste natural: se o modelo seguisse o exemplo, escreveria uma
asserção que falharia, e a falha seria o bug aparecendo.

**3. Como todo prompt FS, não traz a linha do caminho de import.**

---

## Resposta do LLM — geração inicial

9 testes. Copiou `authExceptions: AuthExceptions(...)` do exemplo nos quatro
testes de erro. **Não importou `LoginScreen` de lugar nenhum** — nem tentou um
caminho. Definiu uma `TelaInicialScreen` dummy local.

E, no ponto que importa, **ignorou o oráculo**: para `wrong-password` asseriu
`find.text('Usuário não encontrado. Verifique o e-mail e tente novamente.')`,
lido do código, em vez do `textContaining('incorreta')` do exemplo.

Seguiu o exemplo na **forma** — estrutura de `group`, helper `pumpLoginScreen`,
nomes de teste, construção dos mocks — e não na **asserção**, que era onde
estava a informação discordante.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Não** |
| **Testes gerados** | 9 |
| **Testes passaram (1ª execução)** | 0 |
| **Testes falharam (1ª execução)** | — (falha de compilação) |
| **Iterações de reparo** | 2 |
| **Testes passaram (pós-repair)** | **9** |
| **Testes falharam (pós-repair)** | 0 |
| **Tentativas de envio até obter resposta** | 1 |
| **Bug plantado capturado por asserção?** | **Não — fixado como comportamento esperado** |
| **Bug plantado mencionado na resposta?** | **Não** |
| **Testa a aplicação?** | **Não** — ver iteração 2 |

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** dois defeitos independentes.
  - `Method not found: 'LoginScreen'` / `Undefined name: 'LoginScreen'` — nenhum import.
  - `No named parameter with the name 'authExceptions'` / `Method not found: 'AuthExceptions'`, ×4 — API inexistente copiada do exemplo.
- **★ Autoclassificação do modelo:** **(A)**, com diagnóstico correto dos dois:
  reconheceu que `firebase_auth_mocks` não tem `AuthExceptions` "em sua API
  padrão (ou na versão instalada no projeto)".
- **Correção proposta:** substituiu o mock por
  `class MockFirebaseAuthWithException extends MockFirebaseAuth`, sobrescrevendo
  `signInWithEmailAndPassword` — solução correta e igual à que a rodada 10
  encontrou. Mas **deixou o import de `LoginScreen` comentado**, com mais um
  caminho inventado:
  ```dart
  // import 'package:sintonize/screens/login_screen.dart';
  ```
- **Resultado:** **Falhou** — `LoginScreen` segue indefinido.
- Saída: `FASE2-WSILENT-FS_iter1.txt`

### Iteração 2

- **Motivo da falha:** `LoginScreen` indefinido.
- **★ Autoclassificação do modelo:** **(A)**.
- **Correção proposta:** **colou a declaração completa de `LoginScreen` dentro
  do arquivo de teste**, com a justificativa:

  > "a solução auto-contida para garantir compilação imediata sem depender do
  > caminho relativo de importação é incluir a declaração de `LoginScreen` e da
  > tela de destino `TelaInicialScreen` diretamente no arquivo de teste"

- **Resultado:** **compilou, 9/9 passaram.** A rodada encerra aqui; a
  iteração 3 não foi usada.
- Saída: `FASE2-WSILENT-FS_iter2_final.txt`

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(A)** nas duas iterações, declarada e correta quanto à natureza da falha. |
| **★ Classificação humana (auditoria)** | **Erro de geração.** As causas foram bem diagnosticadas; a correção da iteração 2 descaracteriza o teste. |
| **★ Concordância** | **Parcial.** Concordância no diagnóstico, discordância na correção. |
| **★ Observações** | Ver abaixo. |

### Segunda ocorrência de "trocar o sujeito do teste"

Idêntico ao que ocorreu na rodada 8 (`FASE2-WCRASH-FS`), e pela mesma causa
imediata — caminho de import que o modelo não sabe e o prompt FS não informa.

`wsilent_fs_test.dart` **não importa nada de `package:sintonize`**. Declara sua
própria `LoginScreen`, sua própria `TelaInicialScreen`, e testa a cópia. Os
9 testes passam sobre um widget que existe só dentro do arquivo de teste.

Duas ocorrências em duas rodadas FS de widget deixam de ser acidente e viram
**padrão de resposta ao ciclo de reparo**: diante da pressão de fazer compilar,
e sem o caminho real, o modelo prefere **eliminar a dependência externa** a
continuar tentando resolvê-la. O prompt de reparo proíbe enfraquecer a
asserção; não proíbe trocar o objeto testado.

A cópia da iteração 2 traz ainda uma modificação do widget que não existe no
original: um `errorBuilder` no `Image.asset`, para tolerar a ausência do asset
em teste. Pequena, mas ilustra o ponto — a cópia já divergiu da aplicação na
primeira oportunidade.

### O oráculo acidental foi descartado

Este é o achado próprio da rodada. O exemplo few-shot dizia, para
`wrong-password`, esperar texto contendo "incorreta". O modelo escreveu
"Usuário não encontrado", copiado do código.

Confrontado com **duas fontes discordantes** — o exemplo e o código —, o
modelo seguiu o código sem registrar a discordância. Não é que tenha deixado
de ver o exemplo: copiou dele a estrutura inteira, inclusive a API inexistente
que quebrou a compilação. Copiou até o que estava errado, e descartou
justamente o que estava certo.

Isso **inverte a hipótese das rodadas 2 e 5**. Lá, a suspeita era que os
exemplos few-shot ancoram o repertório de asserção e impedem o modelo de
expressar o bug. Aqui o exemplo **oferecia** a asserção que exporia o bug, e
foi descartada. A ancoragem, quando existe, é sobre **forma**; sobre
**valores esperados**, o código vence.

Isso é consistente com todo o bloco unitário, onde o modelo declarou
explicitamente a política de "testar o comportamento atual do código" — só que
lá ele *avisava* da divergência, e aqui não avisou.

### Observações

1. **O bug foi fixado como especificação, como na rodada 10** — e agora sobre
   uma cópia, o que o torna duplamente inócuo: nem testa a aplicação, nem
   sinalizaria uma correção.
2. **A API inexistente do exemplo foi copiada verbatim**, reproduzindo o defeito
   que motivou a reexecução na Fase 2. A comparação com o `_REEXEC`
   correspondente vai medir exatamente o custo desse material de apoio ruim.
3. **Terceira rodada FS de widget seguida com problema de import.** ZS e COT
   trazem a linha; FS não traz, em nenhum dos dois bugs. A assimetria é
   herdada da Fase 2 e precisa ser declarada na análise — a comparação entre
   estratégias no nível widget está contaminada por ela.
4. **Sem recusa, sem anomalia de streaming.**
