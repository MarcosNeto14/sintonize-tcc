# Fase 2 — Análise de erro por categoria (ChatGPT × Gemini)

**Data:** 2026-10-08. **Autor da classificação:** Claude Code (leitura de docs), para revisão do autor.

## 1. Método

### 1.1 Universo

60 rodadas por modelo, 120 no total: 42 alvos limpos + 18 bugs plantados (6 bugs × ZS/FS/COT). Fora da contagem principal, mencionados à parte na seção 7: as 4 rodadas `_REEXEC` de cada modelo (`WSILENT-FS_REEXEC`, `ICRASH-{ZS,FS,COT}_REEXEC`). Fora de escopo e não contados: os 2 docs `FASE2-VALIDATESENHA-ZS-*`, as tentativas em `_abortadas/` (contam apenas como evidência de categoria 5 da rodada reexecutada).

### 1.2 Fontes

| Modelo | Bloco | Docs | Saída iteração 0 |
|---|---|---|---|
| ChatGPT | 42 limpas + UCRASH ×3, USILENT ×3, WCRASH-ZS | `fase2/rodadas/{unit,widget,integration}/` | `fase2/resultados/<nível>/<estratégia>/*_iter0*.txt` |
| ChatGPT | WCRASH-FS/COT, WSILENT ×3, ICRASH ×3, ISILENT ×3 (+4 `_REEXEC`) | `fase2/_execucao-assistida/rodadas/` | `fase2/_execucao-assistida/resultados/` |
| Gemini | 42 limpas | `fase2-gemini/rodadas/` (branch `fase3-e2e`) | `fase2-gemini/resultados/*_iter0.txt` |
| Gemini | 18 bugs (+4 `_REEXEC`) | `git show fase2-gemini-piloto:fase2-gemini/rodadas/...` | `git show fase2-gemini-piloto:fase2-gemini/resultados/...` |

Campos lidos em cada doc: "Compilou?", "Testes passaram/falharam (1ª execução)", seções "Iteração N" ("Motivo da falha", "Resultado após correção"), "★ Classificação humana (auditoria)", "Tentativas de envio até obter resposta" (Gemini) e "Observações". A saída `_iter0.txt` foi usada para confirmar a primeira mensagem de erro de cada rodada. As 15 rodadas de bug do ChatGPT em `_execucao-assistida/` tiveram reparo enriquecido pelo operador; a geração e a primeira falha delas valem igual às demais, e as iterações posteriores são usadas só para a tabela (a).

### 1.3 Categorias

| # | Categoria | Critério operacional usado |
|---|---|---|
| 1 | **Erro de geração** | Impede compilar/carregar: import errado ou ausente (do alvo, de `cloud_firestore`, de `mock_exceptions`, do `.mocks.dart`), API ou assinatura inexistente na versão pinada (`AuthExceptions`, `whenCalling` sem import, `obscureText` em `TextFormField`, `anyNamed` → `Null`), erro de sintaxe/tipagem, código truncado. |
| 2 | **Erro de teste** | Compila, mas o teste está errado: asserção/presunção incorreta (`int.tryParse` com espaços, `\s` em regex), `pump`/`pumpAndSettle` insuficiente ou mal empregado, finder errado ou ambíguo (`Column` ancestral, `IconButton.first`), `tap()` fora do viewport 800×600, mock manual do mockito que devolve `Null` em runtime, dado de teste inválido. |
| 3 | **Limitação de testabilidade da aplicação** | `TelaInicialScreen` acessando `FirebaseAuth.instance`/`FirebaseFirestore.instance` no `initState` (`[core/no-app]`), ViaCEP real (`http.get` sem injeção), item "PE" do `DropdownButtonFormField` não localizável no overlay, e similares (limitação de ferramenta de mock sem alternativa no escopo). |
| 4 | **Lacuna de material do prompt** | Caminho de import não fornecido (prompts FS de widget/integração: `WCRASH-FS`, `WSILENT-FS`, `ISILENT-FS`, `INT-FS-01/02`), exemplo few-shot com API inexistente (`AuthExceptions` em `FASE2-WSILENT-FS.md`), material divergente do app real nos prompts I-CRASH (`CadastroScreen` com 4 campos e `SwitchListTile`, `build()` abreviado). |
| 5 | **Limitação do serviço** | Recusa ("Sou só um modelo de linguagem..."), erro de serviço (1096, spinner sem resposta, resposta travada e não salva), resposta truncada por limite sem código aplicável, tentativa abortada por truncamento. |
| B | **Bug real exposto (fora das 5 categorias)** | A falha da iteração 0 é a aplicação quebrando como esperado (bug plantado ou defeito pré-existente). Não é erro do teste nem do serviço; está nas tabelas só para fechar a soma. |

Regras de contagem:

- **Tabela (a):** uma rodada entra em cada categoria que a tocou em **qualquer** iteração (geração ou reparo), inclusive quando a iteração 0 passou e houve só recusa antes da resposta (categoria 5). Uma rodada pode estar em várias linhas; a coluna não soma 60.
- **Tabela (b):** só rodadas cuja **iteração 0** não ficou verde (não compilou ou teve teste falhando). Uma categoria por rodada: a que o doc da rodada aponta como causa da primeira falha (campo "Motivo da falha" da iteração 1 e "Classificação humana"), confirmada pela primeira mensagem de erro em `_iter0.txt`. Em empate, prevalece a causa listada primeiro no doc, e o caso vai para "Casos ambíguos".
- **Lista (d):** rodadas com iteração 0 compilando e 100% dos testes passando. Independe de recusas anteriores à resposta: uma rodada pode estar em (d) e na linha 5 de (a).
- Viewport 800×600 é categoria 2 por definição deste documento, mesmo onde a auditoria da rodada o reclassificou como "limitação de testabilidade".
- `pumpAndSettle` que não converge com `CircularProgressIndicator` infinito é categoria 2 (espera mal empregada), com a ressalva da seção 6.
- "Truncada e recomeçada" com versão final completa (padrão frequente no Gemini) **não** conta como categoria 5; conta só quando a resposta não trouxe código aplicável ou exigiu reenvio. Essas anomalias estão listadas na seção 5.5.

## 2. Tabela (a) — rodadas afetadas por categoria (qualquer iteração)

| Categoria | ChatGPT (de 60) | Gemini (de 60) |
|---|---|---|
| 1. Erro de geração | **27** | **15** |
| 2. Erro de teste | **25** | **21** |
| 3. Limitação de testabilidade | **16** | **13** |
| 4. Lacuna de material do prompt | **6** | **8** |
| 5. Limitação do serviço | **1** | **22** |
| Rodadas com alguma falha ou anomalia (união) | **35** | **40** |
| Rodadas sem nenhuma falha nem anomalia | **25** | **20** |

Leitura rápida: o ChatGPT concentra o problema em compilação (27/60 não compilaram em alguma iteração, 25 já na geração); o Gemini compila mais vezes de primeira e falha mais por teste (finder/viewport/mock em runtime), mas 22/60 rodadas tiveram recusa ou falha de serviço antes de obter resposta, contra 1 do ChatGPT.

## 3. Tabela (b) — causa dominante da primeira falha (iteração 0)

| Causa dominante | ChatGPT | Gemini |
|---|---|---|
| 1. Erro de geração | **25** | **14** |
| 2. Erro de teste | **8** | **10** |
| 3. Limitação de testabilidade | 0 | **2** |
| 4. Lacuna de material do prompt | 0 | 0 |
| 5. Limitação do serviço | 0 | 0 |
| B. Bug real exposto | **2** | 0 |
| **Rodadas com iteração 0 não verde** | **35** | **26** |
| Iteração 0 verde (lista d) | 25 | 34 |

Observações sobre (b):

- Categoria 4 nunca é a causa *imediata* da primeira falha: o sintoma sempre aparece como erro de compilação (import inventado) ou finder sem correspondência, e a lacuna de material é a causa raiz registrada pela auditoria. Nas listas da seção 4 ela aparece como categoria concorrente de 6 (ChatGPT) e 8 (Gemini) rodadas.
- Categoria 5 nunca é a causa da primeira falha nas 60 de cada modelo, porque toda recusa foi contornada por reenvio antes de haver código. A única rodada perdida por recusa é um `_REEXEC` do Gemini (seção 7).
- Por nível (ChatGPT, 35): unitário 7 de 30 (5 cat. 2: `UNIT-ZS-01`, `ZS-03`, `ZS-06`, `COT-03`, `COT-10`; 2 B: `UNIT-COT-06`, `UCRASH-FS`); widget 14 de 15 (11 cat. 1, 3 cat. 2; só `WCRASH-ZS` verde); integração 14 de 15 (14 cat. 1; só `INT-ZS-03` verde).
- Por nível (Gemini, 26): unitário 2 de 30 (cat. 2: `UNIT-ZS-03`, `COT-03`); widget 11 de 15 (5 cat. 1, 5 cat. 2, 1 cat. 3); integração 13 de 15 (9 cat. 1, 3 cat. 2, 1 cat. 3).

## 4. Lista (c) — rodadas por categoria e modelo, com evidência

Notação: **(dom.)** = essa categoria é a causa dominante da primeira falha da rodada (entra na tabela b). Sem a marca, a categoria apareceu em iteração posterior ou é concorrente.

### 4.1 Categoria 1 — Erro de geração

**ChatGPT (27)**

| Rodada | Evidência |
|---|---|
| WIDGET-ZS-01 (dom.) | `_iter0.txt`: `Error: The getter 'obscureText' isn't defined for the type 'TextFormField'`. |
| WIDGET-ZS-02 | Iteração 1: código usou `auth.signInWithEmailAndPasswordHandler` e `MockUserCredential`, inexistentes em `firebase_auth_mocks 0.14.2` — "Erro de compilação, não executou nenhum teste". |
| WIDGET-ZS-03 (dom.) | `_iter0.txt`: `Error: 'Timestamp' isn't a type.` (faltou `import 'package:cloud_firestore/cloud_firestore.dart'`). |
| WIDGET-FS-01 (dom.) | `_iter0.txt`: `Method not found: 'AuthExceptions'` e `No named parameter with the name 'authExceptions'` (+ `obscureText`). |
| WIDGET-FS-02 | Iteração 1 "não compilou — `anyNamed('email')`/`MockUserCredential`"; iterações 2–3 `type 'Null' is not a subtype of type 'Future<UserCredential>'` (mockito sem codegen), auditoria: "Erro de geração". |
| WIDGET-FS-03 (dom.) | `_iter0.txt`: `'Timestamp' isn't a type` e `The getter 'parent' isn't defined for the type 'Finder'`. |
| WIDGET-COT-01 (dom.) | `_iter0.txt`: `Type 'FirebaseFirestore' not found` (import ausente); iteração 1 `whenCalling` sem import; iteração 3 reescrita "não compila". |
| WIDGET-COT-02 (dom.) | `_iter0.txt`: `Method not found: 'MockUserCredential'` + 18× `'Null' can't be assigned to 'String'`; iteração 2: 5× `Method not found: 'whenCalling'`. |
| WCRASH-FS (dom.) | `_iter0.txt`: `Error when reading 'lib/criar_playlist_screen.dart'` + `'Timestamp' isn't a type`. |
| WCRASH-COT (dom.) | `_iter0.txt`: `Both Iterable and Map spread elements encountered in ambiguous literal` (`Invocation.method(#add, {mapa})`); iteração 1 removeu o import de `whenCalling` e continuou a usá-lo. |
| WSILENT-ZS (dom.) | `_iter0.txt`: `The getter 'obscureText' isn't defined for the type 'TextFormField'`. |
| WSILENT-FS (dom.) | `_iter0.txt`: `Method not found: 'AuthExceptions'` / `No named parameter with the name 'authExceptions'`; iteração 3 repete `obscureText`. |
| WSILENT-COT (dom.) | `_iter0.txt`: `obscureText` em `TextFormField` + `The setter 'signInException' isn't defined for the type 'MockFirebaseAuth'`; iteração 2 nova falha de compilação (`form.key` tipado `Key?`). |
| INT-ZS-01 (dom.) | `_iter0.txt`: `No named parameter with the name 'mockSignInWithEmailAndPassword'`; iteração 1: `StateError` passado onde `Exception` é exigido. |
| INT-ZS-02 (dom.) | `_iter0.txt`: `'FakeCloudFirestore' isn't a type` (nome real: `FakeFirebaseFirestore`). |
| INT-FS-01 (dom.) | `_iter0.txt`: `No named parameter with the name 'authExceptions'` (4×); iteração 2 `Firebase.initializeApp()` em `setUpAll` regrediu para 0/6, auditoria "Erro de geração". |
| INT-FS-02 (dom.) | `_iter0.txt`: `Couldn't resolve the package 'sintoniza'` (3×) — uma letra errada no nome do pacote. |
| INT-FS-03 (dom.) | `_iter0.txt`: 2× `'Timestamp' isn't a type`. |
| INT-COT-01 (dom.) | `_iter0.txt`: 5× `Method not found: 'whenCalling'` (import de `mock_exceptions` ausente). |
| INT-COT-02 (dom.) | `_iter0.txt`: 3× `Method not found: 'whenCalling'`; iteração 2: sintaxe de Security Rules não reconhecida pela versão instalada (`Bad state: No element` em `Method.fromNameInFirebase`). |
| INT-COT-03 (dom.) | `_iter0.txt`: `'Timestamp' isn't a type`. |
| ICRASH-ZS (dom.) | `_iter0.txt`: `The argument type 'Null' can't be assigned to the parameter type 'Map<String, dynamic>'` (`document.set(any)`); iteração 2 `anyNamed()`/mocks manuais incompatíveis com null safety. |
| ICRASH-FS (dom.) | `_iter0.txt`: `Undefined name 'TelaInicialScreen'` (import ausente); iteração 2 `scrollable:` com tipo incompatível. |
| ICRASH-COT (dom.) | `_iter0.txt`: `No named parameter with the name 'shouldMockUser'`, `Undefined name 'TelaInicialScreen'`, `'Null' can't be assigned to 'Map<String, dynamic>'`. |
| ISILENT-ZS (dom.) | `_iter0.txt`: `'Timestamp' isn't a type`. |
| ISILENT-FS (dom.) | `_iter0.txt`: `Error when reading 'lib/criar_playlist_screen.dart'` + `Method not found: 'CriarPlaylistScreen'`. |
| ISILENT-COT (dom.) | `_iter0.txt`: `'FirebaseAuth' isn't a type` + `Local variable '_navigatorKey' can't be referenced before it is declared`. |

**Gemini (15)**

| Rodada | Evidência |
|---|---|
| WIDGET-COT-01 (dom.) | `_iter0.txt`: `Type 'StreamTransformer' not found`, `Type 'StreamSubscription' not found` (faltam `dart:async` e `cloud_firestore`); iteração 2 "removeu `dart:typed_data` que o novo `FakeAssetBundle` usa" → não compila. |
| WIDGET-COT-02 (dom.) | `_iter0.txt`: `Error when reading 'test/fase2-gemini/widget/login_screen_test.mocks.dart'` (nome do `.mocks.dart` presumido). |
| WIDGET-COT-03 (dom.) | `_iter0.txt`: `Error when reading '.../criar_playlist_test.mocks.dart'`; iteração 1 `any` → `Null` em `Map<String, dynamic>`; iteração 2 `Method not found: 'anyThat'`. |
| WCRASH-FS (dom.) | `_iter0.txt`: `Error when reading 'lib/screens/criar_playlist_screen.dart'`; iterações 1–2: `lib/criar_playlist_screen.dart`, `lib/telas/criarPlaylist.dart` — "três caminhos inventados, nenhum acerto". |
| WSILENT-FS (dom.) | `_iter0.txt`: `Method not found: 'LoginScreen'` (sem import) + `Method not found: 'AuthExceptions'`. |
| INT-ZS-01 (dom.) | `_iter0.txt`: `Error when reading '.../login_flow_test.mocks.dart'`; iteração 1: `MockFirebaseAuth` importado de dois lugares (colisão). |
| INT-ZS-02 (dom.) | `_iter0.txt`: `The argument type 'Null' can't be assigned to the parameter type 'String'` (`anyNamed`); iteração 3 `Method not found: 'setupFirebaseCoreMocks'` → arquivo final não compila. |
| INT-FS-01 (dom.) | `_iter0.txt`: `'Null' can't be assigned to the parameter type 'String'` (linhas 181–182, `anyNamed`). |
| INT-FS-02 (dom.) | `_iter0.txt`: `Method not found: 'CadastroScreen'`, `Undefined name 'GenerosCadastroScreen'` — "o modelo deixou os imports do projeto comentados". |
| INT-COT-01 | Iteração 1: `Method not found: 'setupFirebaseCoreMocks'` (símbolo não importado); iteração 3: `Binding has not yet been initialized` — "o arquivo nem carrega". |
| INT-COT-03 (dom.) | `_iter0.txt`: `'FirebaseAuth' isn't a type` (import de `firebase_auth` ausente). |
| ICRASH-ZS (dom.) | Doc: `build_runner` abortou com `Invalid @GenerateMocks annotation: (...) appears to already be mocked inline`; `_iter0.txt`: `Error when reading '.../icrash_zs_test.mocks.dart'`; iteração 1 `The setter 'shouldThrowFirebaseAuthException' isn't defined`. |
| ICRASH-FS (dom.) | `_iter0.txt`: `Method not found: 'CadastroScreen'` / `Undefined name 'GenerosCadastroScreen'` (imports "deixados apenas como comentários ilustrativos"). |
| ISILENT-FS (dom.) | `_iter0.txt`: `Method not found: 'CriarPlaylistScreen'`; nunca compilou em 2 iterações (`lib/screens/criar_playlist_screen.dart`, `package:sintonize_tcc/...`). |
| ISILENT-COT (dom.) | `_iter0.txt`: `'FirebaseAuth' isn't a type`. |

### 4.2 Categoria 2 — Erro de teste

**ChatGPT (25)**

| Rodada | Evidência |
|---|---|
| UNIT-ZS-01 (dom.) | `_iter0.txt`: `deve rejeitar nome contendo tabulação [E] Expected: 'O nome não pode conter...' Actual: <null>` — `\s` inclui `\t`/`\n`. |
| UNIT-ZS-03 (dom.) | `_iter0.txt`: `deve retornar erro para valor contendo espaços [E] ... Actual: <null>` — `int.tryParse` tolera espaços. |
| UNIT-ZS-06 (dom.) | 4 falhas "em duas direções opostas" sobre `[^@]+` e ausência de `$`; auditoria "Erro de teste". |
| UNIT-COT-03 (dom.) | `_iter0.txt`: `espaços ao redor do número [E] Expected: 'O número deve ser numérico' Actual: <null>`. |
| UNIT-COT-10 (dom.) | `_iter0.txt`: `validateDate(' 15/05/1990 ')` retornou `null`; "mesma presunção incorreta sobre `int.tryParse`". |
| WIDGET-ZS-01 | Iteração 2: 15 testes `tap()` fora do viewport de 600px; iteração 3: asserção `'As senhas não coincidem'` com ambos os campos vazios ("presunção incorreta do teste"). |
| WIDGET-ZS-02 (dom.) | `_iter0.txt`: `Found 0 widgets with type "CadastroScreen"` — `tap()` em `Offset(400.0, 664.0)` fora de `800×600`. |
| WIDGET-FS-01 | Iteração 2: 19 falhas por viewport; iteração 3: SnackBar não encontrado após `pump()` único. |
| WIDGET-FS-02 (dom.) | Iteração 0: "`user-not-found` sem exceção configurada" e "`tap()` fora da viewport" (2 das 3 falhas). |
| WIDGET-FS-03 | Iteração 2: `pumpAndSettle timed out` com `CircularProgressIndicator` ativo; iteração 3: navegação `Found 0 widgets with text "Criando Playlist"` não resolvida. |
| WIDGET-COT-01 | Iteração 3: "22 falhas de hit-test por elementos abaixo da viewport". |
| WIDGET-COT-02 | Iteração 3: "`tap()` em `Offset(400, 664)`, fora de `800×600`". |
| WIDGET-COT-03 (dom.) | `_iter0.txt`: `pumpAndSettle timed out` (7 testes); iteração 2 `Found 0 widgets with text "Criando Playlist"`. |
| WCRASH-FS | Iterações 2–3: `pumpAndSettle()` nunca estabiliza em testes que não popularam `musica`. |
| WCRASH-COT | Iteração 3: "asserção de scroll frágil e regra de segurança bloqueando o setup do próprio teste"; final 17/18 (`scrollUntilVisible` com finder incompatível). |
| WSILENT-ZS | Iteração 2: "asserção equivocada (1x), e `tap()` fora da área visível (1x)". |
| WSILENT-FS | Iterações 2–3: "asserção equivocada sobre `obscureText`/`find.text`". |
| WSILENT-COT | Iteração 3: "erro de tipagem no cast de `form.key`" (auditoria: Erro de teste). |
| INT-ZS-02 | Iteração 2: `Bad state: No element` em `_LastFinderMixin.filter`; final: `tap()` em "Confirmar" fora do viewport → `generos_favoritos` `null`. |
| INT-FS-02 | Iterações 2–3: `Bad state: No element` em `showKeyboard` / `Too many elements` em `scrollUntilVisible`; SnackBar não encontrado. |
| INT-COT-01 | Iteração 3: timing (`pump()` único vs `pumpAndSettle()`), auditoria "reclassifico como Erro de teste". |
| INT-COT-02 | Iteração 2: 10 testes com botões "Cadastrar"/"Confirmar" fora do viewport de 600px. |
| ICRASH-ZS | Iteração 3: "SnackBar não localizado" e "`ListView.builder` lazy renderiza 4 de 7 `Switch`". |
| ICRASH-FS | Iteração 2: "suposição não verificada de que o botão já seria visível" (viewport). |
| ICRASH-COT | Iteração 3: "falha do CEP: Erro de teste, corrigido corretamente". |

**Gemini (21)**

| Rodada | Evidência |
|---|---|
| UNIT-ZS-03 (dom.) | `_iter0.txt`: `espaços no início, meio ou fim [E] Expected: 'O número deve ser numérico' Actual: <null>`. |
| UNIT-COT-03 (dom.) | `_iter0.txt`: `espaços ao redor do número [E] ... Actual: <null>` — "mesma premissa falsa da rodada 22". |
| WIDGET-ZS-01 (dom.) | `_iter0.txt`: `Bad state: Too many elements` (3×) — `find.ancestor(... matching: find.byType(Column))` casa várias `Column`; iteração 2 viewport (`Offset would not hit test`). |
| WIDGET-ZS-02 (dom.) | Iteração 0: "SnackBar de erro não aparece; toque em 'Cadastre-se' fora do viewport" (2 das 3 falhas); iteração 2 `type 'Null' is not a subtype of type 'Future<UserCredential>'`. |
| WIDGET-FS-01 (dom.) | `_iter0.txt`: 5× `Bad state: Too many elements` no helper `findFieldByLabel`. |
| WIDGET-FS-02 (dom.) | Iteração 0: "`Null` não é `Future<UserCredential>` e `Cannot call when within a stub response` (mockito sem codegen); toque em 'Cadastre-se' fora do viewport". |
| WIDGET-COT-01 | Iteração 1: 12× `FormatException` ao resolver a imagem (mock de `flutter/assets` corrompe o `AssetManifest`) + 5× `Too many elements`; iteração 3: 14× `UnimplementedError: loadStructuredBinaryData`. |
| WIDGET-COT-02 | Iteração 1: "toque em 'Cadastre-se' fora do viewport". |
| WIDGET-COT-03 | Iteração 3: 3× `pumpAndSettle timed out`, `type 'Null' is not a subtype of type 'CollectionReference<...>'`, `Bad state: Cannot call 'when' within a stub response`. |
| WCRASH-FS | Iteração 3: `pumpAndSettle timed out` (coleção `musica` vazia) e asserção invertida pelo próprio reparo (`findsOneWidget` → `findsNothing`). |
| WSILENT-ZS (dom.) | Iteração 0: 6 falhas, "todas de infraestrutura de mock": `type 'Null' is not a subtype of type 'Future<UserCredential>'`, `Cannot call 'when' within a stub response`, botão fora do viewport. |
| INT-ZS-01 | Iteração 2: `RangeError (index)` no `enterText`, finder `.at(1)` sobre `widgetWithText(TextFormField, '')`. |
| INT-ZS-02 | Iterações 1–2: `Found 0 widgets with text "Erro ao cadastrar: O e-mail já está cadastrado."`. |
| INT-FS-01 | Iteração 1: 0/4 com mock manual `Mock implements FirebaseAuth` devolvendo `null` em `Future<UserCredential>` — (A) deixado sem correção. |
| INT-FS-02 | Iteração 1: `Bad state: No element` em `enterText`, finder `widgetWithText(TextFormField, 'Nome')` não encontra nada. |
| INT-COT-01 (dom.) | `_iter0.txt`: `type 'Null' is not a subtype of type 'Future<UserCredential>'`, `Bad state: Cannot call 'when' within a stub response` (4 das 5 falhas). |
| INT-COT-02 | Iteração 1: `Binding has not yet been initialized` — `setupFirebaseCoreMocks()` chamado antes de `TestWidgetsFlutterBinding.ensureInitialized()`. |
| INT-COT-03 | Iteração 1: asserção invertida pelo próprio reparo (`findsOneWidget` → `findsNothing`) e mock mockito devolvendo `null`. |
| ICRASH-FS | Iteração 2: viewport (`tester.view.physicalSize = Size(1080, 1920)`) e `pump()` em vez de `pumpAndSettle()` para o SnackBar. |
| ICRASH-COT (dom.) | Iteração 0: "Botões `Cadastrar` (y=870) e `Confirmar` (y=618) fora da viewport 800×600" (ver seção 6). |
| ISILENT-ZS (dom.) | `_iter0.txt`: `Found 0 widgets with icon "IconData(U+0E157)"` — `find.byType(IconButton).first` é a seta de voltar, não o checkbox. |

### 4.3 Categoria 3 — Limitação de testabilidade da aplicação

**ChatGPT (16)**

| Rodada | Evidência |
|---|---|
| WIDGET-ZS-01 | Iteração 3: "o item 'PE' do menu simplesmente não era encontrado após o tap no controle (`Bad state: No element`)". |
| WIDGET-ZS-02 | Falha final 1/12: `TelaInicialScreen` acessa `FirebaseAuth.instance` sem injeção (`[core/no-app]`). |
| WIDGET-FS-01 | Iteração 3: "dropdown com 'PE' duplicado (`findsOneWidget` encontrou 2)". |
| WIDGET-FS-02 | `_iter0.txt`: `[core/no-app] No Firebase App '[DEFAULT]'` em "deve realizar login e navegar para tela inicial". |
| WIDGET-COT-02 | 3 falhas finais `[core/no-app]` em `_TelaInicialScreenState.fetchLastRecommendedMusic (lib/tela-inicial.dart:43)`. |
| WSILENT-ZS | Iteração 2: "`FirebaseException` (2x, tela de destino não isolada)". |
| WSILENT-FS | Final 9/10: "`FirebaseException` de `TelaInicialScreen`" no teste de navegação. |
| WSILENT-COT | Iteração 2: 4 falhas "todas `FirebaseException` de `TelaInicialScreen`". |
| INT-ZS-01 | Iteração 3 (B): "`TelaInicialScreen.initState()` chama `FirebaseAuth.instance`" — auditoria "Limitação de testabilidade". |
| INT-ZS-02 | Iteração 3: `Found 0 widgets with text "PE"` dentro do helper `preencherCadastro`. |
| INT-FS-01 | Iteração 2: `[core/no-app]` — "mesma limitação de `TelaInicialScreen` da rodada ZS"; final 5/6. |
| INT-COT-01 | Iteração 2: `[core/no-app]`, "ambiente de teste sem platform channel nativo", contornado com `setupFirebaseCoreMocks()`. |
| INT-COT-02 | Iteração 3: `Bad state: No element` em `ensureVisible` ao localizar `find.text('PE').last` (menu em `Overlay` próprio). |
| ICRASH-ZS | Iteração 3: "`createUserWithEmailAndPassword` gera UUID aleatório, ignorando o `mockUser`" (falha de ambiente/ferramenta de mock). |
| ICRASH-FS | Iteração 3: "limitação de `setSurfaceSize` com `MediaQuery`-driven sizing" (auditoria: Limitação de testabilidade / falha de ambiente). |
| ICRASH-COT | Iteração 3: "Falha do `TelaInicialScreen`: Limitação de testabilidade"; `mock_exceptions` com parâmetros nomeados não resolvido. |

**Gemini (13)**

| Rodada | Evidência |
|---|---|
| WIDGET-ZS-01 | Iteração 1: `Bad state: No element` no item `'PE'` do dropdown. |
| WIDGET-ZS-02 | `_iter0.txt`: `[core/no-app]` em "Deve autenticar com sucesso e navegar para TelaInicialScreen"; (B) na iteração 1, teste removido. |
| WIDGET-FS-01 | Iteração 1: `Bad state: No element` em `find.text('PE').last` (item fora do menu renderizado), contornado trocando o dado para `'AC'`. |
| WIDGET-FS-02 | `_iter0.txt`: `[core/no-app]` na navegação; (B) correto, contornado com `_MockFirebasePlatform`. |
| WIDGET-COT-02 | Iterações 1–3: `[core/no-app]` no login com sucesso; (B) mantido, final 10/11. |
| WSILENT-ZS | Iteração 2 (B): "`MaterialPageRoute(builder: (context) => const TelaInicialScreen())`" quebra a injeção; final 10/11. |
| WSILENT-COT (dom.) | `_iter0.txt`: `[core/no-app] No Firebase App '[DEFAULT]'` no fluxo de sucesso — única falha da rodada (9/10). |
| INT-ZS-01 | Final 6/7: `[core/no-app]` em `_TelaInicialScreenState.fetchLastRecommendedMusic (tela-inicial.dart:43:31)`. |
| INT-ZS-02 | Iterações 1–2: `[core/no-app]` em "deve completar o fluxo de cadastro e salvar gêneros favoritos". |
| INT-FS-01 | Iterações 2–3 (B): "acoplamento de `TelaInicialScreen` aos singletons do Firebase"; final 0/4. |
| INT-COT-01 | Iteração 0: `[core/no-app]` na navegação; o reparo perseguiu o mock da plataforma até o arquivo não carregar. |
| INT-COT-02 (dom.) | `_iter0.txt`: `[core/no-app]`; iteração 3: "o `onChanged` do campo CEP dispara `_fetchAddressFromCEP` e o `ScaffoldMessenger` exibe a SnackBar do ViaCEP no lugar da esperada". |
| ICRASH-COT | Iteração 2: teste de sucesso "quebra ao montar a `TelaInicialScreen` real (`[core/no-app]` em `tela-inicial.dart:43`)". |

### 4.4 Categoria 4 — Lacuna de material do prompt

**ChatGPT (6)**

| Rodada | Evidência |
|---|---|
| WCRASH-FS | Prompt FS sem caminho de import (`FASE2-WCRASH-FS.md` não contém `package:sintonize/`); modelo importou `criar_playlist_screen.dart` inexistente. |
| WSILENT-FS | Auditoria: "API inexistente, induzida pelo exemplo few-shot desatualizado" — `FASE2-WSILENT-FS.md:42` traz `authExceptions: AuthExceptions(`. |
| ISILENT-FS | Prompt FS sem caminho; iteração 0 `Error when reading 'lib/criar_playlist_screen.dart'` — "nome de arquivo incorreto; o real é `criar_playlist.dart`". |
| ICRASH-ZS | Observações: "o prompt continha um `build()` simplificado divergente da tela real". |
| ICRASH-FS | Iteração 3: "a divergência de 10 vs. 4 campos é falha do material do prompt, não do teste ou da aplicação" (`findsNWidgets(4)` encontrou 10). |
| ICRASH-COT | Seção "Confirmação da divergência de campos entre prompt e app real (mesma da rodada FS)". |

**Gemini (8)**

| Rodada | Evidência |
|---|---|
| WCRASH-FS | "A ajuda ausente explica a rodada. ZS recebeu o caminho no prompt e compilou de primeira. FS não recebeu e queimou as 3 iterações." |
| WSILENT-FS | "A API inexistente do exemplo foi copiada verbatim" (`AuthExceptions`) + import de `LoginScreen` sem caminho. |
| INT-FS-02 | Iteração 0 com imports comentados e nota "Importe as telas do seu projeto conforme a estrutura de diretórios"; prompt `FASE2-INT-FS-02_cadastroFlow.md` não contém `package:sintonize/`. |
| ICRASH-ZS | Iteração 3: "as 4 falhas são de divergência do material: a `CadastroScreen` real tem mais de um `Scrollable`... a tela real não usa `SwitchListTile`". |
| ICRASH-FS | Iteração 2: "4 × 'Found 0 widgets' — nenhum elemento descrito pelo prompt existe na tela real"; (B) da iteração 3 "errado nos três pontos". |
| ICRASH-COT | (B) item 3 errado: "a causa é a tela real ter 10 campos, com outra ordem e outros validadores". |
| ISILENT-FS | "Import sem caminho: quarta rodada FS travada nisso (8, 11, 14, 17)". |
| ISILENT-ZS | Iteração 1: "o primeiro `IconButton` da tela real é a seta de voltar do cabeçalho (`lib/criar_playlist.dart:101`), que o snippet do prompt não mostra". |

### 4.5 Categoria 5 — Limitação do serviço

**ChatGPT (1)**

| Rodada | Evidência |
|---|---|
| INT-COT-02 | Tentativa 1 (`_abortadas/FASE2-INT-COT-02_TENTATIVA-1.md`): entrega do arquivo "truncou em `await tester.pumpAndSet`, com 'Não foi possível conectar'", repetido no mesmo token; pedido de geração em 2 blocos "nenhum texto gerado — ~90 s só com spinner". A rodada contada é a reexecução; nela a iteração 1 ainda teve "diagnóstico sem entrega". |

**Gemini (22)**

| Rodada | Evidência |
|---|---|
| UNIT-ZS-01 | Tentativa 1: recusa "Sou apenas um modelo de linguagem. Não posso ajudar com isso." |
| UNIT-ZS-05 | Tentativa 1: recusa "Não fui programado para fazer essas coisas." |
| UNIT-ZS-08 | 2 recusas; resposta só na 3ª tentativa, enviada manualmente. |
| UNIT-ZS-10 | 2 recusas; resposta só na 3ª tentativa, enviada manualmente. |
| UNIT-FS-01 | Tentativa 1: recusa "Não consigo te ajudar com isso. Sou só um modelo de linguagem..." |
| UNIT-FS-07 | Tentativa 1: recusa "Não fui programado para fazer isso. Só consigo gerar texto." |
| UNIT-COT-01 | Tentativa 1: recusa (mesmo texto da FS-01). |
| UNIT-COT-04 | Tentativa 1: "Erro do serviço: aviso 'Algo deu errado (1096)'; nenhuma resposta gerada". |
| UNIT-COT-05 | Tentativa 1: recusa "Sou apenas uma IA com base em texto. Não tenho como ajudar nisso." |
| UNIT-COT-10 | 2 recusas "Não fui programado para fazer isso. Só consigo gerar texto."; 3ª tentativa manual. |
| USILENT-COT | "⚠ Tentativa 1 — recusa em conversa nova" (Gemini intitulou a conversa "Recusa de Testes em Dart"). |
| WCRASH-ZS | "⚠ Tentativas — 2 recusas antes da resposta", uma em inglês: "I'm having a hard time fulfilling your request." |
| WCRASH-FS | Execução anterior: "2 recusas e depois uma resposta completa, mas a conversa foi apagada"; a rodada documentada é uma execução nova. |
| WIDGET-ZS-03 | Tentativa 1: "Falha do serviço: ~3 min só com o indicador de carregamento, nenhuma linha gerada". |
| WIDGET-FS-01 | Tentativa 1: recusa "Sou um modelo de linguagem e não consigo ajudar com isso." |
| WIDGET-FS-02 | Tentativa 1: recusa "Não posso te ajudar com isso. Sou apenas um modelo de linguagem..." |
| WIDGET-FS-03 | Tentativa 1: recusa "Não fui programado para fazer essas coisas." |
| WIDGET-COT-02 | Tentativa 1: recusa; iteração 3: "a primeira resposta travou no meio da geração e não foi salva pelo serviço". |
| WIDGET-COT-03 | 2 recusas (geração e reparo 1): "Tentativas de envio até obter resposta: 4". |
| INT-FS-01 | Geração, tentativa 1: recusa em envio automatizado; reenvio em conversa nova. |
| INT-FS-02 | Iteração 2: "resposta truncada e reiniciada... termina perguntando 'Quer compartilhar as linhas 45 a 65?'" — sem código aplicável; iteração 3 "só orientação genérica, sem arquivo". |
| ISILENT-FS | Iteração 1: "corta no meio (`late FakeFirebase`) e recomeça do zero, agora sem código aplicável". |

### 4.6 Fora das categorias — bug real exposto na iteração 0

| Modelo | Rodada | Evidência |
|---|---|---|
| ChatGPT | UCRASH-FS | `_iter0.txt`: `RangeError (index): Invalid value: Valid value range is empty: 0` em `'maria  silva'` — bug plantado U-CRASH; teste mantido (B). |
| ChatGPT | UNIT-COT-06 | 17/18: `validateEmailLogin('usuario@exam ple.com')` aceito; auditoria "Bug real exposto — `[^@]+` não exclui espaço e falta `$`". |

Outros (B) reais que apareceram em iterações posteriores, não na primeira falha: ChatGPT `WIDGET-FS-03` (`musica['artist_name']` lança antes do `??`), `ICRASH-ZS`/`ICRASH-COT` (I-CRASH exposto); Gemini `ICRASH-COT` (`_TypeError` em `generos-cadastro.dart:44:34`, canonizado).

## 5. Lista (d) — rodadas verdes de primeira (iteração 0 compila e passa 100%)

### 5.1 ChatGPT — 25 de 60

- **Unitário limpo (18):** UNIT-ZS-04, ZS-05, ZS-07, ZS-08, ZS-10; UNIT-FS-01, FS-03, FS-04, FS-05, FS-06, FS-07, FS-08, FS-10; UNIT-COT-01, COT-04, COT-05, COT-07, COT-08.
- **Unitário bug (5):** UCRASH-ZS, UCRASH-COT, USILENT-ZS, USILENT-FS, USILENT-COT (todos com detecção espontânea do bug).
- **Widget (1):** WCRASH-ZS (14/14 — bug não detectado).
- **Integração (1):** INT-ZS-03 (3/3, "única mensagem da rodada").

Nenhuma dessas 25 teve anomalia de serviço: **25 limpas em todos os sentidos**.

### 5.2 Gemini — 34 de 60

- **Unitário limpo (22):** todas exceto UNIT-ZS-03 e UNIT-COT-03.
- **Unitário bug (6):** UCRASH ×3, USILENT ×3 (todos (C)).
- **Widget (4):** WIDGET-ZS-03, WIDGET-FS-03, WCRASH-ZS, WCRASH-COT.
- **Integração (2):** INT-ZS-03, INT-FS-03.

Dessas 34, **14 tiveram recusa ou erro de serviço antes da resposta** (UNIT-ZS-01, ZS-05, ZS-08, ZS-10, FS-01, FS-07, COT-01, COT-04, COT-05, COT-10, USILENT-COT, WCRASH-ZS, WIDGET-ZS-03, WIDGET-FS-03). **Verdes sem nenhuma anomalia: 20.**

### 5.3 Comparação

| | ChatGPT | Gemini |
|---|---|---|
| Iteração 0 verde | 25 | 34 |
| ... das quais sem recusa/erro de serviço | 25 | 20 |
| Unitário (30) | 23 | 28 |
| Widget (15) | 1 | 4 |
| Integração (15) | 1 | 2 |

### 5.4 Nota sobre `formatName`

`UNIT-{ZS,FS,COT}-08` são verdes de primeira nos dois modelos, mas o alvo carrega defeito real (`RangeError` em espaços múltiplos); ZS e COT do ChatGPT e as três do Gemini testam o `RangeError` explicitamente (`throwsRangeError`), FS do ChatGPT só o comenta. Não é falha de rodada; registrado porque "verde" aqui não significa "alvo limpo".

### 5.5 Anomalias de streaming do Gemini não contadas em (a)

Resposta "truncada e recomeçada" com versão final completa e utilizável: UNIT-ZS-06, UNIT-FS-04, UNIT-FS-06, UNIT-COT-01 (análise duplicada), UNIT-COT-08, WIDGET-ZS-01, WCRASH-ZS (resposta gerada duas vezes), INT-FS-03 (markdown malformado no início do bloco), INT-COT-03 (análise reiniciada), ISILENT-COT (iteração 1), ICRASH-COT_REEXEC, ICRASH-FS_REEXEC, WSILENT-FS_REEXEC. Nenhuma no ChatGPT.

## 6. Casos ambíguos — 9 rodadas

| # | Rodada | Por que é ambíguo |
|---|---|---|
| 1 | ChatGPT WIDGET-ZS-02 | Iteração 0 tem 2 falhas de causas distintas (viewport = cat. 2; `TelaInicialScreen` = cat. 3). Empate; atribuída a cat. 2 por ser a listada primeiro no doc. Se o critério fosse "falha não corrigível no escopo", seria cat. 3. |
| 2 | Gemini ICRASH-COT | Iteração 0 (0/6) mistura viewport (cat. 2), `find.widgetWithText(SwitchListTile, ...)` (cat. 4 — a tela real não tem `SwitchListTile`) e mensagens de validação ausentes (cat. 4, segundo o próprio doc na iteração 3). Atribuída a cat. 2 porque a auditoria da iteração 1 diz "Erro de teste, correta"; uma leitura pela causa raiz daria cat. 4 dominante. |
| 3 | Gemini WIDGET-COT-02, WIDGET-COT-03, INT-ZS-01 (e ICRASH-ZS em parte) | Primeira falha é `Error when reading '...mocks.dart'` — nome do `.mocks.dart` presumido pelo modelo. Classificado cat. 1, mas o doc da INT-ZS-01 argumenta que "é um custo fixo do protocolo: o nome do arquivo de teste é decidido pelo operador depois da geração" — o que o aproximaria da cat. 4 (lacuna do procedimento, não do prompt). Contado como cat. 1 nas duas tabelas. |
| 4 | `pumpAndSettle timed out` com `CircularProgressIndicator` infinito (ChatGPT WIDGET-COT-03 dom., WIDGET-FS-03, WCRASH-FS; Gemini WIDGET-COT-03, WCRASH-FS) | Contado como cat. 2 (espera mal empregada), seguindo a classificação (A) das rodadas do ChatGPT. Os docs do Gemini chamam o mesmo fenômeno de "defeito de testabilidade do widget — o estado 'vazio' e o estado 'carregando' são o mesmo" e "candidato a (B)", o que seria cat. 3. |
| 5 | ChatGPT WIDGET-ZS-01 e WIDGET-FS-01 (falha final) | `document.exists` retorna `false` após o fluxo completo de cadastro; o doc levanta hipótese de incompatibilidade `firebase_auth_mocks 0.14.2` × `createUserWithEmailAndPassword`, não confirmada. Pode ser cat. 2 (espera insuficiente), cat. 3 (ferramenta de mock) ou outro. Não atribuída a nenhuma categoria; as rodadas já estão em 1, 2 e 3 por outras falhas. Na FS-01, a correção da iteração 3 travou o processo (`taskkill`), também sem causa fechada. |
| 6 | ChatGPT INT-COT-02 (cat. 5) | A rodada contada não teve falha de serviço própria — a tentativa 1 abortada por truncamento está em `_abortadas/`. Contada em cat. 5 porque a rodada só existe por causa dela, e porque a iteração 1 da reexecução repetiu "diagnóstico sem entrega" (prosa sem arquivo, corrigido a pedido). Se o critério for estrito à conversa contada, ChatGPT cai para 0 em cat. 5. O doc cita o mesmo padrão em `INT-FS-02`, mas o doc dessa rodada não o registra; não contado. |
| 7 | Gemini WCRASH-FS (cat. 5) | As 2 recusas pertencem a uma execução anterior cuja conversa foi apagada; a rodada documentada "é uma execução nova e completa, sem recusas". Contada em cat. 5 pela mesma regra do item 6. Sem ela, Gemini cai para 21. |
| 8 | Gemini INT-FS-01 / WIDGET-COT-02 / WSILENT-COT / WSILENT-ZS — respostas (B) "só diagnóstico, sem código" | Não contadas em cat. 5: são respostas completas que seguem o caminho (B) do prompt de reparo. Só INT-FS-02 (iterações 2–3, sob (A), sem arquivo) e ISILENT-FS (iteração 1, "sem código aplicável") entraram em cat. 5, porque ali o modelo deveria ter entregue código e não entregou. A fronteira entre "não entregou por protocolo" e "não entregou por limitação" é interpretativa. |
| 9 | Gemini UNIT-ZS-03 e UNIT-COT-03; ChatGPT UNIT-ZS-03, COT-03, COT-10 | Classificadas cat. 2 (premissa falsa sobre `int.tryParse`). A `validateNumero`/`validateDate` do app não faz `trim()` e aceita `' 10 '` como válido; um leitor pode considerar isso defeito de validação (B) e não erro de teste. Seguida a auditoria dos docs ("Erro de teste — confirmado: comportamento documentado da biblioteca padrão"). |

## 7. Rodadas `_REEXEC` (fora da contagem principal; 4 por modelo)

| Rodada | ChatGPT | Gemini |
|---|---|---|
| WSILENT-FS_REEXEC | Cat. 1 dom. (`Error when reading 'lib/login_screen.dart'`, `obscureText`), cat. 4 (FS sem caminho — modelo devolveu placeholder `SEU_CAMINHO` e o operador forneceu `lib/login.dart`), cat. 3 (`[core/no-app]` final). 10/11. | Cat. 1 dom. (`Method not found: 'LoginScreen'`), cat. 4 (três caminhos inventados, "nunca chegou a `package:sintonize/login.dart`"), cat. 5 (1 recusa + truncada). **Nunca compilou, 0/9.** |
| ICRASH-ZS_REEXEC | Cat. 1 dom. (`Method not found: 'runWithClient'` — `http 0.13.6`), cat. 2 (viewport/finder do dropdown), (B) bug exposto. | **Cat. 5 — não executada:** 2 recusas ao mesmo prompt (27 mil caracteres), parada pelo protocolo. 0 testes gerados. |
| ICRASH-FS_REEXEC | Compilou; iteração 0: viewport do dropdown/"Confirmar" e mock manual de `update()` (cat. 2); cat. 3 (`TelaInicialScreen`). 2/3. | Cat. 1 dom. (`Required named parameter 'items' must be provided` — `find.byType(DropdownButtonFormField<String>())`), cat. 3 (`[core/no-app]`), cat. 1 (`setupFirebaseCoreMocks` sem import → final não compila), cat. 5 (1 recusa + truncada). |
| ICRASH-COT_REEXEC | Cat. 1 dom. (`when`/`anyNamed` do mockito sobre `MockFirebaseAuth`: `'Null' can't be assigned to 'String'`), cat. 2 (`find.widgetWithText`, UID fixo), cat. 3 (`TelaInicialScreen`, `whenCalling` com parâmetros nomeados), (B). 11/15. | Cat. 1 dom. (`'MockFirebaseAuth' is imported from both ...`), cat. 3 (dropdown "PE" não seleciona; `[core/no-app]`), cat. 2 (`generos_favoritos` nulo), cat. 5 (1 recusa + truncada), (B) canonizado. 4/8. |

Nos `_REEXEC`, o material corrigido eliminou o defeito específico investigado (`AuthExceptions`; `CadastroScreen` truncado), sem mudar o resultado quanto ao bug: W-SILENT seguiu canonizado nos dois modelos e I-CRASH seguiu exposto só quando o cenário "usuário não autenticado" foi escrito (ZS e COT).

## 8. Síntese

1. **Compilação é a barreira do ChatGPT**: 25 das 35 primeiras falhas (71%) são erro de geração, quase todas em widget e integração (de 30 rodadas desses níveis, 28 não compilaram na iteração 0 ou falharam). Os erros se repetem entre conversas independentes: `Timestamp` sem import (6 rodadas), `obscureText` em `TextFormField` (5), `whenCalling` sem import (5), `AuthExceptions`/`authExceptions` (3), API do mockito sem codegen (4).
2. **Gemini compila mais e erra mais o teste**: 14 erros de geração contra 10 de teste na primeira falha; o padrão repetido é o finder `find.ancestor(... Column)` (3 rodadas no `CadastroScreen`), o mock manual do mockito devolvendo `Null` em runtime (7) e o nome presumido do `.mocks.dart` (4).
3. **A limitação de testabilidade é a mesma nos dois modelos** — `TelaInicialScreen` com `FirebaseAuth.instance` no `initState` aparece em 10 rodadas do ChatGPT e 11 do Gemini (item "PE" do dropdown em 4 e 2). Nenhum modelo a contorna sem alterar a aplicação, exceto Gemini `WIDGET-FS-02` e `INT-COT-02` (plataforma Firebase falsa / `setupFirebaseCoreMocks()`).
4. **A lacuna de material penaliza o Gemini mais que o ChatGPT** (8 vs 6 rodadas), e nos dois casos concentra-se nos prompts FS sem caminho de import e nos três prompts I-CRASH com `CadastroScreen` divergente. É a assimetria entre estratégias herdada do desenho dos prompts, a declarar na análise ZS × FS.
5. **Limitação do serviço é quase exclusiva do Gemini**: 22 rodadas com recusa, erro 1096, travamento ou resposta sem código, contra 1 do ChatGPT (truncamento por limite). Nenhuma recusa custou uma rodada das 60; custou uma `_REEXEC` (`ICRASH-ZS_REEXEC`).
