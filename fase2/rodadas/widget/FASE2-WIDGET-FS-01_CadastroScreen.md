# FASE2-WIDGET-FS-01_CadastroScreen — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WIDGET-FS-01 |
| **Tela testada** | `CadastroScreen` — `lib/cadastro.dart` (alvo limpo, sem bug plantado) |
| **Arquivo de origem** | `lib/cadastro.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das demais rodadas da Fase 2, ver `fase2/rodadas/README.md`). Nesta rodada, a resposta da 3ª iteração de reparo incluiu uma busca na web (indicador "Fontes"/"Dart packages" na interface) para verificar a API do `firebase_auth_mocks` — não verificável de forma independente sem login. |
| **Data de acesso** | 2026-09-04 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/widget/cadastro_screen_fs_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `lib/cadastro.dart` não tem bug plantado. Mesmo
alvo da rodada `FASE2-WIDGET-ZS-01`, agora em few-shot com um exemplo de
widget test de formulário com Firebase mockado fornecido no prompt.

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/widget/few-shot/FASE2-WIDGET-FS-01_CadastroScreen.md`
— um exemplo de widget test de formulário de login com `MockFirebaseAuth`,
seguido do código completo de `CadastroScreen` e das mesmas instruções de
mocking da rodada zero-shot.

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Gerou 24 testes cobrindo renderização, validação de cada campo
individualmente (abordagem mais granular que a rodada ZS, que agrupava
várias validações em um único teste de formulário vazio), máscaras,
dropdown, navegação, cadastro completo e uma exceção de `FirebaseAuthException`.
Identificou de forma correta e proativa duas armadilhas antes de qualquer
execução: (1) usou `AuthExceptions` — uma API que **não existe** na versão
instalada de `firebase_auth_mocks` — mas avisou textualmente que "se a
versão específica... tiver uma API diferente, pode ser necessário
ajustar"; (2) evitou testar `_fetchAddressFromCEP` diretamente, pelo mesmo
motivo já identificado na rodada ZS (chamada HTTP real).

### Iteração 1 (repair) — 2 erros de compilação

- **Motivo da falha:** `AuthExceptions` não existe no construtor de
  `MockFirebaseAuth` na versão instalada (0.14.2); `TextFormField` não
  expõe `obscureText` publicamente (mesmo erro já visto em
  `FASE2-WIDGET-ZS-01`).
- **Informação fornecida ao modelo pelo operador:** a assinatura real do
  construtor `MockFirebaseAuth` na versão 0.14.2 (verificada diretamente
  no código-fonte do pacote no cache do pub) e a API real para simular
  exceções nessa versão via o pacote `mock_exceptions`
  (`whenCalling(...).on(...).thenThrow(...)`).
- **Resposta do LLM:** classificou **(A)** e aplicou corretamente a API
  real fornecida, mais `find.descendant` para o `obscureText`.
- **Resultado após correção:** Compilou; 5/24 passaram, 19 falharam (nova
  classe de erro).

### Iteração 2 (repair) — 19 falhas por elementos fora da viewport

- **Motivo da falha:** mesmo padrão da rodada ZS — formulário mais alto
  que a viewport padrão de 600px, `tester.tap(find.text('Cadastrar'))`
  não conseguia acionar o botão.
- **Informação fornecida ao modelo pelo operador:** a solução que
  funcionou na rodada `FASE2-WIDGET-ZS-01` (aumentar `tester.view.physicalSize`
  em vez de `ensureVisible`).
- **Resposta do LLM:** classificou **(A)** e aplicou a mesma técnica de
  viewport ampliada em `pumpCadastroScreen` e nos dois `pumpWidget`
  manuais do arquivo.
- **Resultado após correção:** 20/24 passaram (na prática 21, ver nota),
  3 falharam.

### Iteração 3 (repair, última permitida) — 3 falhas residuais

- **Motivo da falha:** (1) dropdown com "PE" duplicado (`findsOneWidget`
  encontrou 2) após `tester.pump()` único pós-seleção; (2) SnackBar de erro
  do Firebase Auth não encontrado após `tester.pump()` único; (3)
  `document.exists` retornando `false` no teste de cadastro completo,
  mesma classe de falha não resolvida na rodada ZS.
- **Resposta do LLM:** classificou **(A) para os 3 padrões**. Para 1 e 2,
  trocou `pump()` por `pumpAndSettle()`. Para o Padrão 3, pesquisou na web
  (uso de fontes/citações visível na interface) para confirmar que
  `createUserWithEmailAndPassword` é suportado pela versão instalada, e
  propôs aguardar explicitamente com `tester.pump()` +
  `await Future<void>.delayed(Duration.zero)` + `pumpAndSettle()` antes de
  consultar o Firestore, argumentando que isso tornaria o teste
  determinístico sem enfraquecer a asserção `expect(snapshot.exists, isTrue)`.
- **Resultado após aplicar a correção completa:** **o teste de cadastro
  completo travou indefinidamente** (processo `flutter test` não retornou
  em mais de 4 minutos, muito acima do padrão de poucos segundos por
  suíte) e precisou ser encerrado manualmente (`taskkill` nos processos
  `dart.exe`/`flutter_tester.exe`). A causa mais provável é a combinação
  de `pumpAndSettle()` (que já teria avançado o relógio de teste o
  suficiente) com o `await Future<void>.delayed(Duration.zero)` sobre um
  `Future` real (não simulado) interagindo mal com o mecanismo de
  finalização do binding de teste.
- **Ação do operador:** revertida **apenas** a parte da correção que
  causou o travamento (a sequência extra de `pump`/`Future.delayed` no
  teste de cadastro completo), mantendo as duas correções de
  `pumpAndSettle()` para dropdown e SnackBar, que não travaram. O teste de
  cadastro completo voltou à forma simples (`tap` + `pumpAndSettle()`
  único), consistente com o padrão que já havia falhado de forma limpa
  (sem travar) na iteração 2.
- **Resultado final (limite de reparo esgotado):** 22/24 passaram, 2
  falharam — o teste de cadastro completo (`document.exists` = `false`,
  inalterado) e, inesperadamente, o teste de SnackBar (que a correção da
  iteração 3 pretendia resolver, mas não resolveu — ver observações).

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Não na geração inicial (2 erros); sim após iteração 1 |
| **Testes gerados** | 24 |
| **Testes passaram (1ª execução válida, pós-compilação)** | 5 |
| **Testes falharam (1ª execução válida)** | 19 |
| **Testes passaram (pós-repair, iteração 3/3 — final)** | 22 |
| **Testes falharam (pós-repair, iteração 3/3 — final)** | 2 |

### Saída do terminal (iteração 0 — erro de compilação)

```
test/fase2/widget/cadastro_screen_fs_test.dart:482:25: Error: Method not found: 'AuthExceptions'.
...
test/fase2/widget/cadastro_screen_fs_test.dart:530:20: Error: The getter 'obscureText' isn't defined for the type 'TextFormField'.
...
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/widget/few-shot/FASE2-WIDGET-FS-01_CadastroScreen_iter0.txt`)

### Saída do terminal (iteração 1 — 19 falhas)

```
00:14 +5 -19: Some tests failed.
```

(saída completa em `fase2/resultados/widget/few-shot/FASE2-WIDGET-FS-01_CadastroScreen_iter1.txt`)

### Saída do terminal (iteração 2 — 3 falhas)

```
00:21 +21 -3: Some tests failed.
```

(saída completa em `fase2/resultados/widget/few-shot/FASE2-WIDGET-FS-01_CadastroScreen_iter2.txt`)

### Saída do terminal (iteração 3 — final, 22/24, após reversão parcial da correção que travou)

```
00:08 +22 -2: Some tests failed.
```

(saída completa em `fase2/resultados/widget/few-shot/FASE2-WIDGET-FS-01_CadastroScreen_iter3_final.txt`)

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** `AuthExceptions` inexistente na versão instalada; `obscureText` não público em `TextFormField`.
- **Resposta do LLM:** classificação **(A)**; corrigido com a API real de `mock_exceptions` (informada pelo operador) e `find.descendant`.
- **Resultado após correção:** Compilou; 5/24 passaram.

### Iteração 2

- **Motivo da falha:** 19 testes falhando por elementos fora da viewport de 600px.
- **Resposta do LLM:** classificação **(A)**; aplicou `tester.view.physicalSize` ampliado (técnica já validada na rodada ZS).
- **Resultado após correção:** 21/24 passaram, 3 falharam.

### Iteração 3 (máximo)

- **Motivo da falha:** dropdown duplicado, SnackBar não encontrado, Firestore não persistido.
- **Resposta do LLM:** classificação **(A) para os 3**; `pumpAndSettle()` para os dois primeiros, `pump()` + `Future.delayed` + `pumpAndSettle()` extra para o terceiro.
- **Resultado após aplicar integralmente:** **travamento** no teste de cadastro completo — correção revertida parcialmente pelo operador (mantidas as duas correções que não travaram).
- **Resultado final:** 22/24 passaram, 2 falharam — **limite de reparo esgotado, falhas finais documentadas sem correção adicional**.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) em todas as 3 iterações |
| **★ Classificação humana (auditoria)** | Iteração 1: concordo (erro de teste/API incorreta). Iteração 2: concordo com a causa, mas reclassifico como **Limitação de testabilidade** (viewport fixa do `WidgetTester`, não presunção de lógica de negócio) — mesma nota da rodada ZS. Iteração 3, Padrão 3 (Firestore): a correção proposta pelo modelo **piorou o resultado** (de uma falha limpa e determinística para um travamento indefinido) — classifico como **Erro de geração**, já que o código sugerido, embora sintaticamente válido, introduziu um problema de execução mais grave do que o que pretendia resolver. Padrão 2 (SnackBar): a correção proposta (`pumpAndSettle()`) **não resolveu** o problema original — o teste continua falhando da mesma forma após a correção — classifico como **Ambíguo**, pois não há evidência suficiente, sem uma 4ª iteração (fora do limite do protocolo), para determinar se a causa é a duração de exibição do `SnackBar` sendo consumida integralmente por `pumpAndSettle()` (hipótese do auditor: `pumpAndSettle()` avança o tempo simulado até não haver mais frames agendados, o que inclui o timer de auto-dismissal do `SnackBar` — de 4 segundos por padrão — potencialmente fazendo o widget aparecer e desaparecer antes da asserção rodar) ou se o mock de exceção nunca dispara de fato. |
| **★ Concordância** | Parcial — concordo com a classificação (A) quanto à causa raiz identificada em cada padrão, mas diverjo quanto à eficácia e ao risco das correções propostas na iteração 3 |
| **★ Observações** | Rodada com o achado mais significativo desta bateria: **uma correção sugerida pelo LLM, aplicada integralmente, causou um travamento do processo de teste** (não apenas uma falha) — a primeira ocorrência desse tipo em toda a Fase 2 até aqui. Isso reforça a importância do protocolo de rodar cada correção sugerida e auditar o resultado antes de aceitá-la, em vez de confiar cegamente na garantia textual do modelo de que "a asserção permanece intacta". A causa mais provável do travamento (`Future.delayed` real combinado com `pumpAndSettle()` já esgotado) é um padrão de erro específico de testes assíncronos em Flutter, não uma falha genérica de lógica. Este é também o segundo widget test consecutivo (após `FASE2-WIDGET-ZS-01`) a não conseguir validar de ponta a ponta a persistência no Firestore usando `firebase_auth_mocks` 0.14.2 — reforça a hipótese, já levantada na rodada ZS, de uma incompatibilidade sistemática entre essa versão do mock e o fluxo `createUserWithEmailAndPassword` seguido de leitura imediata do usuário criado, independentemente da estratégia de prompt usada. |

---

**Referência de categorias (classificação humana — mesmas da Fase 1, + (C) da Fase 2):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
| Bug capturado sem necessidade de reparo (C) | O modelo já identificou e se ajustou ao bug real na geração inicial, sem falha nem ciclo de reparo |
