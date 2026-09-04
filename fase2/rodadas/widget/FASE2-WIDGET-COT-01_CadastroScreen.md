# FASE2-WIDGET-COT-01_CadastroScreen — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WIDGET-COT-01 |
| **Tela testada** | `CadastroScreen` — `lib/cadastro.dart` (alvo limpo, sem bug plantado) |
| **Arquivo de origem** | `lib/cadastro.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das demais rodadas da Fase 2, ver `fase2/rodadas/README.md`). Nesta rodada, o LLM afirmou textualmente ter consultado a documentação/pub.dev de `firebase_auth_mocks` (indicador "Fontes"/"Dart packages" na interface) para confirmar a API `whenCalling(...).on(...).thenThrow(...)` — não verificável de forma independente sem login. |
| **Data de acesso** | 2026-09-04 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/widget/cadastro_screen_cot_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT — não pelo autor manualmente no teclado |

**Verificação pré-rodada:** `lib/cadastro.dart` não tem bug plantado. Mesmo
alvo das rodadas `FASE2-WIDGET-ZS-01` e `FASE2-WIDGET-FS-01`, agora em
chain-of-thought (análise estruturada em 4 passos antes da geração dos
testes, conforme `prompts/PROMPT_TEMPLATES.md`).

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/widget/cot/FASE2-WIDGET-COT-01_CadastroScreen.md` —
pede para o modelo (1) analisar o widget, (2) identificar dependências que
precisam de mock, (3) listar cenários de teste, (4) escrever os testes —
seguido do código completo de `CadastroScreen`.

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Análise correta do widget (formulário de cadastro, CEP com busca automática
via ViaCEP, criação de usuário no Firebase Auth + gravação no Firestore).
Identificou corretamente as 3 dependências a mockar (`MockFirebaseAuth`,
`FakeFirebaseFirestore`, e — por não haver injeção de cliente HTTP no
widget — `HttpOverrides` para interceptar `http.get()` do ViaCEP, já que
`MockClient` não pode ser injetado diretamente). Gerou 24 testes cobrindo
renderização, scroll, validação de cada campo, formatação automática de
data/CEP, seleção de estado, navegação, 4 cenários de ViaCEP (sucesso, CEP
não encontrado, erro HTTP 500, falha de rede) e 3 cenários de
Firebase/Firestore (sucesso completo, `FirebaseAuthException`, erro de
Firestore usando um `Mock` do `mockito` com `when()`/`thenThrow()`).

Diferente das rodadas ZS e FS, esta gerou o mock de erro do Firestore via
`mockito` puro (`MockFirebaseFirestore extends Mock implements
FirebaseFirestore`) em vez de aceitar a limitação — mas **esqueceu de
importar `cloud_firestore`**, entre outros problemas (ver iteração 1).

### Iteração 1 (repair) — 3 erros de compilação (import ausente + APIs inexistentes)

- **Motivo da falha:** faltou `import 'package:cloud_firestore/cloud_firestore.dart';`
  (por isso `FirebaseFirestore`, `CollectionReference`, `DocumentReference` e
  `SetOptions` não foram encontrados); usou um parâmetro
  `mockCreateUserWithEmailAndPassword` inexistente no construtor de
  `MockFirebaseAuth` da versão instalada (0.14.2); usou
  `DropdownButtonFormField.value`, getter que não existe nessa versão do
  Flutter (mesmo erro já visto nas rodadas ZS/FS).
- **Prompt de reparo enviado:** saída bruta do `flutter test` (erros de
  compilação), sem dica adicional do operador.
- **Resposta do LLM:** classificou **(A)** — "o teste presume uma
  API/comportamento de mocking que não corresponde às versões reais das
  dependências instaladas". Corrigiu o import ausente, removeu o parâmetro
  inexistente substituindo por `whenCalling(...).on(...).thenThrow(...)`
  (API do pacote transitivo `mock_exceptions`, mas **sem importar o
  pacote** — novo erro introduzido, ver iteração 2), e removeu a asserção
  de `.value` no dropdown com um comentário explicando a limitação.
- **Resultado após correção:** Não compilou (nova classe de erros).

### Iteração 2 (repair) — 2 novos erros de compilação, resolvidos após diálogo adicional

- **Motivo da falha:** `Method not found: 'whenCalling'` (faltou o import
  de `package:mock_exceptions/mock_exceptions.dart`); `No named parameter
  with the name 'options'` (assinatura de `DocumentReference.set()` em
  `cloud_firestore` 5.6.4 recebe `SetOptions?` como argumento posicional
  opcional, não nomeado).
- **Prompt de reparo enviado:** saída bruta do `flutter test`, sem dica
  adicional.
- **Resposta do LLM:** classificou **(A)**, mas pediu informação adicional
  antes de corrigir — solicitou a saída de
  `flutter pub deps | findstr "firebase_auth firebase_auth_mocks
  cloud_firestore fake_cloud_firestore mockito"` para confirmar as versões
  exatas instaladas. **Informação fornecida pelo operador:** a saída do
  comando solicitado (`cloud_firestore 5.6.4`, `fake_cloud_firestore
  3.1.0`, `firebase_auth 5.5.0`, `firebase_auth_mocks 0.14.2`, `mockito
  5.6.4`). Com essa informação, o modelo inicialmente propôs remover os
  dois testes que dependiam das APIs incompatíveis (Firebase Auth error e
  Firestore error) — o operador não aceitou essa proposta por reduzir a
  cobertura sem necessidade — e o próprio modelo reconsiderou
  espontaneamente na mesma resposta ("Não recomendo simplesmente apagar os
  cenários de erro... isso reduziria o escopo dos testes"), pedindo então
  a saída completa de `flutter pub deps` para os pacotes relevantes (já
  fornecida) e, em seguida, o trecho-fonte do construtor real de
  `MockFirebaseAuth` (fornecido pelo operador via inspeção direta do
  pacote no cache do pub, confirmando que `whenCalling(...).on(...)` é de
  fato a única forma de simular exceções nessa versão). Com essas duas
  informações, corrigiu o import ausente de `mock_exceptions` e reescreveu
  o mock de erro do Firestore usando uma classe `FailingFirestore`
  (`implements FirebaseFirestore` com `noSuchMethod`) em vez de `mockito`,
  corrigindo a assinatura posicional de `set()`.
- **Resultado após correção:** Compilou. **3/25 passaram, 22 falharam** —
  nova classe de falha (elementos fora da viewport padrão de teste,
  800×600 — mesmo padrão já visto e resolvido nas rodadas ZS e FS).

### Iteração 3 (repair, última permitida) — 22 falhas de hit-test fora da viewport

- **Motivo da falha:** `tester.tap(find.text('Cadastrar'))` e outras
  interações com campos na parte inferior do formulário falhavam porque o
  `SingleChildScrollView` é mais alto que a viewport padrão de teste
  (600px) — mesmo padrão estrutural das rodadas ZS/FS, mas **desta vez sem
  que o operador fornecesse a solução já validada** (`tester.view.physicalSize`),
  para observar como o modelo reagiria de forma independente.
- **Prompt de reparo enviado:** amostra representativa da saída (2
  falhas completas + resumo final `00:12 +3 -22`), sem dica do operador.
- **Resposta do LLM:** classificou **(A)** — "a falha é causada pelo modo
  como a suíte interage com um formulário maior que a viewport de teste...
  o comportamento do `CadastroScreen` está de acordo com o código". Ao
  contrário das rodadas anteriores (que usaram `tester.view.physicalSize`
  ampliado), propôs uma abordagem alternativa: `tester.scrollUntilVisible()`
  antes de qualquer `tap()`/`enterText()` em campos potencialmente fora de
  tela, encapsulada em helpers (`tapCadastrar()`, `enterField()`). Alertou
  explicitamente contra `warnIfMissed: false` como "correção" (silenciaria
  o sintoma sem garantir que `_submit()` fosse chamado). Ao pedir o arquivo
  completo, o modelo reescreveu a suíte inteira (não apenas os pontos
  identificados), incluindo uma reimplementação própria dos mocks de HTTP
  (`FakeHttpClient`, `FakeHttpClientRequest`, `FakeHttpClientResponse`,
  `FakeHttpHeaders`) e um novo helper `findTextFormField()` por
  `labelText`.
- **Resultado após aplicar a correção completa:** **Não compilou** — a
  reescrita introduziu 3 erros novos e independentes do problema de
  viewport que a correção pretendia resolver: (1) `FakeHttpClient extends
  HttpClient` sem implementar ~20 métodos abstratos obrigatórios da classe
  base (`get`, `post`, `close`, etc.) — o padrão correto usado nas
  gerações anteriores era `implements HttpClient` combinado com
  `noSuchMethod`, não `extends`; (2) `FakeHttpHeaders.add()` sobrescrito
  com uma assinatura de parâmetros nomeados incompatível com a da classe
  base (`HttpHeaders.add` exige `{bool preserveHeaderCase = false}`); (3)
  o novo helper `findTextFormField()` acessa `widget.decoration` em uma
  instância de `TextFormField`, mas esse getter **não existe** nessa
  classe (existe em `TextField`, não em `TextFormField`).
- **Resultado final (limite de reparo esgotado):** **0/24 passaram — a
  suíte não compila.** Nenhum teste foi executado na versão final aceita.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Não em nenhuma das 3 gerações (inicial, iteração 1 e iteração 3); apenas a iteração 2 compilou |
| **Testes gerados** | 24 (na geração inicial; a reescrita da iteração 3 renomeou/reorganizou para 25, incluindo 2 testes novos de truncamento de máscara que não estavam no escopo original) |
| **Testes passaram (1ª execução válida, iteração 2)** | 3 |
| **Testes falharam (1ª execução válida, iteração 2)** | 22 |
| **Testes passaram (pós-repair, iteração 3/3 — final)** | 0 (não compila) |
| **Testes falharam (pós-repair, iteração 3/3 — final)** | 25 (não compila) |

### Saída do terminal (iteração 0 — erro de compilação)

```
test/fase2/widget/cadastro_screen_cot_test.dart:107:12: Error: Type 'FirebaseFirestore' not found.
test/fase2/widget/cadastro_screen_cot_test.dart:1035:11: Error: No named parameter with the name 'mockCreateUserWithEmailAndPassword'.
test/fase2/widget/cadastro_screen_cot_test.dart:711:25: Error: The getter 'value' isn't defined for the type 'DropdownButtonFormField<String>'.
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/widget/cot/FASE2-WIDGET-COT-01_CadastroScreen_iter0.txt`)

### Saída do terminal (iteração 1 — 2 erros de compilação)

```
test/fase2/widget/cadastro_screen_cot_test.dart:995:9: Error: Method not found: 'whenCalling'.
test/fase2/widget/cadastro_screen_cot_test.dart:1066:13: Error: No named parameter with the name 'options'.
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/widget/cot/FASE2-WIDGET-COT-01_CadastroScreen_iter1.txt`)

### Saída do terminal (iteração 2 — 3/25 passaram, 22 falharam)

```
00:12 +3 -22: Some tests failed.
```

(saída completa em `fase2/resultados/widget/cot/FASE2-WIDGET-COT-01_CadastroScreen_iter2.txt`)

### Saída do terminal (iteração 3 — final, não compila)

```
test/fase2/widget/cadastro_screen_cot_test.dart:1586:7: Error: The non-abstract class 'FakeHttpClient' is missing implementations for these members: ...
test/fase2/widget/cadastro_screen_cot_test.dart:1705:8: Error: The method 'FakeHttpHeaders.add' has fewer named arguments than those of overridden method 'HttpHeaders.add'.
test/fase2/widget/cadastro_screen_cot_test.dart:1272:33: Error: The getter 'decoration' isn't defined for the type 'TextFormField'.
test/fase2/widget/cadastro_screen_cot_test.dart:1587:3: Error: The superclass, 'HttpClient', has no unnamed constructor that takes no arguments.
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/widget/cot/FASE2-WIDGET-COT-01_CadastroScreen_iter3_final.txt`)

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** import ausente (`cloud_firestore`) + parâmetro
  inexistente em `MockFirebaseAuth` + getter inexistente em
  `DropdownButtonFormField`.
- **Resposta do LLM:** classificação **(A)**; corrigiu o import e o
  dropdown, mas trocou o parâmetro inexistente por uma API que também
  precisava de um import não declarado (`mock_exceptions`).
- **Resultado após correção:** Não compilou (nova classe de erro).

### Iteração 2

- **Motivo da falha:** `whenCalling` não encontrado (import ausente);
  `set()` do Firestore chamado com argumento nomeado em vez de posicional.
- **Resposta do LLM:** classificação **(A)**; pediu e recebeu do operador
  (a) a saída de `flutter pub deps` com as versões exatas e (b) o
  código-fonte real do construtor de `MockFirebaseAuth`; propôs
  inicialmente remover os testes afetados, mas reconsiderou
  espontaneamente e produziu uma correção completa preservando os 2
  cenários (import correto + `FailingFirestore` sem `mockito`).
- **Resultado após correção:** Compilou; 3/25 passaram, 22 falharam
  (elementos fora da viewport de teste).

### Iteração 3 (máximo)

- **Motivo da falha:** 22 falhas de hit-test por elementos abaixo da
  viewport padrão de 600px.
- **Resposta do LLM:** classificação **(A)**; propôs `scrollUntilVisible()`
  sistemático (alternativa válida a `tester.view.physicalSize`, usada nas
  rodadas ZS/FS) e, a pedido do operador, reescreveu a suíte inteira —
  incluindo uma nova implementação de mocks HTTP que introduziu 3 erros de
  compilação novos e não relacionados ao problema de viewport original.
- **Resultado após aplicar integralmente:** **não compila** — limite de
  reparo esgotado sem uma versão executável da suíte.
- **Resultado final:** 0/25 passaram (0/24 na contagem original) —
  **rodada encerrada com falha total, documentada sem correção adicional**
  (protocolo não permite uma 4ª iteração).

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) em todas as 3 iterações |
| **★ Classificação humana (auditoria)** | Iterações 1 e 2: concordo — causas raiz corretamente diagnosticadas (imports ausentes, assinaturas de API divergentes da versão instalada), e a resolução da iteração 2 foi exemplar: o modelo pediu evidência concreta (versões via `pub deps`, código-fonte do construtor) em vez de adivinhar, e reverteu por conta própria uma proposta que reduziria a cobertura de testes assim que percebeu a implicação — sem que o operador precisasse intervir. Iteração 3: **reclassifico como Erro de geração**. O diagnóstico da causa (viewport) estava correto e a estratégia proposta (`scrollUntilVisible` sistemático) era estruturalmente sólida e equivalente à solução já validada nas rodadas ZS/FS — mas, ao materializar essa estratégia em uma reescrita completa da suíte (escopo que o operador pediu, mas que o modelo executou com baixa atenção a detalhes básicos de tipagem: uma classe `extends` uma superclasse abstrata sem implementar ~20 membros obrigatórios, um override com assinatura de parâmetros incompatível, e um getter chamado em um tipo que não o possui), o modelo trocou uma suíte que **compilava e falhava de forma diagnosticável** (iteração 2, 3/25) por uma que **não compila de forma alguma** (iteração 3, 0/25) — um retrocesso líquido, não um progresso parcial. |
| **★ Concordância** | Parcial — concordo com o diagnóstico de causa em todas as iterações, mas diverjo quanto ao resultado prático da correção da iteração 3, que piorou o estado executável da suíte em vez de melhorá-lo |
| **★ Observações** | Segunda rodada consecutiva (após `FASE2-WIDGET-FS-01`) em que uma correção proposta pelo modelo, aplicada integralmente conforme instruído, **piora objetivamente o resultado** em vez de o melhorar — na rodada FS foi um travamento do processo; nesta, uma regressão de "compila com 22 falhas diagnosticáveis" para "não compila". Padrão que reforça a mesma lição operacional: nunca aceitar uma correção de reparo sem executá-la e auditar o resultado, mesmo quando a explicação textual do modelo é coerente e a classificação (A)/(B) parece bem fundamentada — a qualidade do diagnóstico não garante a qualidade da implementação, especialmente quando o escopo da correção se expande (de "ajustar alguns pontos" para "reescrever o arquivo inteiro"). Também digno de nota: nesta rodada o modelo foi a única, entre as 3 estratégias aplicadas ao `CadastroScreen` (ZS, FS, COT), a pedir e obter informação de diagnóstico do operador de forma proativa e bem direcionada (comando `pub deps` específico) antes de tentar uma correção às cegas — comportamento desejável que não foi suficiente, na iteração seguinte, para evitar um erro de execução básico. Por fim, esta rodada não conseguiu produzir uma suíte executável dentro do limite de 3 iterações de reparo — resultado qualitativamente pior que ZS (21/22) e FS (22/24) para o mesmo alvo, isolando a variável de estratégia de prompt (chain-of-thought) como o fator mais provável, já que a versão do ambiente, o alvo e o protocolo de reparo foram idênticos nas 3 rodadas. |

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
