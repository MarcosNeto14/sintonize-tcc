# FASE2-WIDGET-ZS-02_LoginScreen — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WIDGET-ZS-02 |
| **Tela testada** | `LoginScreen` — `lib/login.dart` (alvo limpo, bug W-SILENT do piloto já revertido em `fase2-prep`, sem reversão adicional necessária nesta branch) |
| **Arquivo de origem** | `lib/login.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — mesmo desvio de protocolo das demais rodadas da Fase 2, ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-14 |
| **Conversa nova?** | Sim (ver nota sobre desvio de execução abaixo — a primeira tentativa de conversa foi perdida antes de qualquer resposta útil e precisou ser reiniciada) |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (channel stable), Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2/widget/login_screen_zs_test.dart` |
| **Execução** | **Desvio de protocolo em relação às rodadas anteriores da Fase 2** — ver nota abaixo |

**Nota sobre desvio de execução (importante para reprodutibilidade):**
esta rodada começou como automação de navegador (Claude in Chrome), igual
às rodadas anteriores da Fase 2. A automação enviou o prompt original com
sucesso (colagem via clipboard, verificado caractere a caractere) e a
resposta do ChatGPT chegou a ser recebida e extraída, mas a extração exigiu
contornar duas falhas de ambiente sérias: (1) a UI do ChatGPT renderizou de
forma degradada (composer com `id="mobile-composer-prompt"`, indicando
layout mobile mesmo em viewport desktop) e capturas de tela via CDP
começaram a expirar (timeout de 30s) de forma recorrente; (2) o texto da
resposta, quando lido via JavaScript, era bloqueado por um filtro de
conteúdo da ferramenta de automação sempre que continha trechos com padrão
"chave: valor" repetido (ex.: mapas de rotas do Dart), exigindo extração em
pedaços pequenos com ofuscação de caracteres — funcional, mas de custo
proibitivo por rodada. Quando o autor tentou retomar essa mesma conversa
manualmente para o ciclo de reparo, a página do ChatGPT havia perdido a
conversa inteira (sessão sem login não persiste de forma confiável entre
recarregamentos — mesmo fenômeno já documentado como risco no
`fase2/rodadas/README.md` para o desvio "sessão sem login"). A partir desse
ponto, **o restante da rodada (prompt original reenviado, geração inicial
e as duas iterações de reparo) foi conduzido manualmente pelo autor no
teclado**, com o Claude Code fornecendo o texto exato de cada prompt
(original e de reparo) e assumindo a documentação, a gravação dos arquivos
de teste, a execução do `flutter test` e o registro da rodada. Diferença
em relação ao padrão das rodadas anteriores ("Execução: Conduzida por
automação de navegador"), registrada aqui por transparência — não houve
qualquer edição do código gerado pelo modelo além da colagem exata do que
o autor reportou ter recebido do ChatGPT.

**Verificação pré-rodada:** `lib/login.dart` não tem bug plantado — única
diferença em relação a `main` é a injeção de dependência opcional de
`auth`. `TelaInicialScreen` mantém a limitação de testabilidade conhecida
(acesso direto a `FirebaseAuth.instance`/`FirebaseFirestore.instance`, sem
injeção), já documentada nas 3 rodadas de integração do fluxo de login
(`FASE2-INT-*-01_loginFlow`).

---

## Prompt Enviado

Conforme
`fase2/prompts_prontos/widget/zero-shot/FASE2-WIDGET-ZS-02_LoginScreen.md`
— código completo de `LoginScreen` colado verbatim, requisitos de mocking
(`firebase_auth_mocks`, `mockito`) e cobertura (validação de formulário,
interações do usuário, `flutter test`).

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Gerou 9 testes em 4 grupos (`validação`, `interações`, `Firebase Auth`,
`elementos da interface`), usando `firebase_auth_mocks` para mockar
`FirebaseAuth`. Cobriu validação de campos vazios/e-mail inválido/senha
curta, preenchimento de campos, navegação para recuperação de senha e
cadastro, um teste de login "bem-sucedido" com `MockUser` pré-configurado,
e renderização dos elementos principais.

### Iteração 1 (repair) — 2 falhas na execução inicial

- **Motivo da falha:** (1) `tap()` no botão "Não tem cadastro?
  Cadastre-se!" caiu fora da viewport padrão do `WidgetTester`
  (`Offset(400.0, 664.0)` fora de `Size(800.0, 600.0)`), então
  `CadastroScreen` nunca era encontrado; (2) o teste de login
  bem-sucedido navegava para `TelaInicialScreen`, que acessa
  `FirebaseAuth.instance` diretamente sem Firebase real inicializado
  (`[core/no-app] No Firebase App '[DEFAULT]'`), e a asserção seguinte
  (`'usuario@email.com'` ainda visível) não fazia mais sentido pós-navegação.
- **Resposta do LLM:** classificou a falha 1 como **(A)** — corrigiu com
  `tester.ensureVisible(...)` antes do `tap()`. Classificou a falha 2 como
  **(B)**, mas reconheceu que o teste original nem sequer configurava a
  exceção `user-not-found` que o nome do teste prometia testar, e pediu as
  versões exatas de `firebase_auth`/`firebase_auth_mocks`/`mockito` do
  projeto para reescrever o teste de forma compatível em vez de adivinhar
  a API.
- **Resultado após correção:** o código entregue usava
  `auth.signInWithEmailAndPasswordHandler` (setter) e `MockUserCredential`
  — nenhum dos dois existe em `firebase_auth_mocks: 0.14.2` (confirmado via
  `pubspec.lock`). **Erro de compilação**, não executou nenhum teste.

### Iteração 2 (repair) — erro de compilação (API inexistente)

- **Motivo da falha:** `The setter 'signInWithEmailAndPasswordHandler'
  isn't defined for the type 'MockFirebaseAuth'` (5 ocorrências) e `Method
  not found: 'MockUserCredential'` — API alucinada pelo modelo na iteração
  anterior, não existente na versão 0.14.2 do pacote.
- **Resposta do LLM:** classificou **(A)** — reconheceu ter atribuído ao
  pacote uma API de outra versão. Reescreveu os 4 testes de exceção usando
  o mecanismo real do pacote, `whenCalling(Invocation.method(...)).on(auth)
  .thenThrow(...)` (de `mock_exceptions`, dependência transitiva de
  `firebase_auth_mocks`, já resolvida em `pubspec.lock` na versão 0.8.2,
  sem necessidade de adicionar dependência nova). Reescreveu o teste de
  sucesso para não depender de `MockUserCredential`, usando
  `MockFirebaseAuth(mockUser: ...)` e verificando `auth.currentUser`
  diretamente, mantendo a ressalva explícita de que o teste poderia ainda
  assim esbarrar no acesso direto a `FirebaseAuth.instance` dentro de
  `TelaInicialScreen` — e que isso não deveria ser mascarado com
  `Firebase.initializeApp()` artificial.
- **Resultado após correção:** compilou; 11/12 passaram, 1 falhou — exatamente
  a limitação de testabilidade antecipada pelo próprio modelo (acesso
  direto a `FirebaseAuth.instance` em `TelaInicialScreen.initState()`).
  **Não foi feita uma 3ª iteração de reparo**: a falha remanescente não é
  um defeito no teste nem uma classificação em aberto — é a mesma
  limitação de testabilidade já documentada e aceita nas rodadas de
  integração do fluxo de login, e o próprio modelo já havia descartado
  explicitamente a "correção" de inicializar Firebase artificialmente por
  mascarar o problema real.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim na geração inicial; erro de compilação na iteração 1 (API inexistente); sim novamente na iteração 2 |
| **Testes gerados** | 9 (geração inicial) → 12 (após iteração 2, com os testes de exceção desmembrados e o teste de sucesso reescrito) |
| **Testes passaram (1ª execução)** | 7 |
| **Testes falharam (1ª execução)** | 2 |
| **Testes passaram (pós-repair, iteração 2/3 — final)** | 11 |
| **Testes falharam (pós-repair, iteração 2/3 — final)** | 1 |

### Saída do terminal (iteração 0 — geração inicial)

```
00:03 +7 -2: LoginScreen - interações botão de cadastro navega corretamente [E]
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 0 widgets with type "CadastroScreen": []>

00:03 +5 -2: LoginScreen - Firebase Auth mostra erro quando usuário não é encontrado [E]
[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
...
00:03 +7 -2: Some tests failed.
```

(saída completa em `fase2/resultados/widget/zero-shot/FASE2-WIDGET-ZS-02_LoginScreen_iter0.txt`)

### Saída do terminal (iteração 1 — erro de compilação)

```
test/fase2/widget/login_screen_zs_test.dart:340:18: Error: Method not found: 'MockUserCredential'.
test/fase2/widget/login_screen_zs_test.dart:172:14: Error: The setter 'signInWithEmailAndPasswordHandler' isn't defined for the type 'MockFirebaseAuth'.
(mesmo erro nas linhas 172, 211, 250, 289, 332)
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/widget/zero-shot/FASE2-WIDGET-ZS-02_LoginScreen_iter1.txt`)

### Saída do terminal (iteração 2 — final, 11/12)

```
00:06 +10 -1: LoginScreen - Firebase Auth realiza login com credenciais válidas [E]
The following FirebaseException was thrown running a test:
[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
#3      _TelaInicialScreenState.fetchLastRecommendedMusic (package:sintonize/tela-inicial.dart:43:31)
00:06 +11 -1: Some tests failed.
```

(saída completa em `fase2/resultados/widget/zero-shot/FASE2-WIDGET-ZS-02_LoginScreen_iter2_final.txt`)

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** (1) `tap()` fora da viewport de teste no botão de
  cadastro; (2) teste de `user-not-found` não configurava a exceção e
  ainda fazia uma asserção sem sentido pós-navegação, expondo a
  dependência direta de `TelaInicialScreen` em `FirebaseAuth.instance`.
- **Prompt de reparo enviado:** os dois erros de execução completos, pedindo classificação separada para cada um.
- **Resposta do LLM:** (1) **(A)** — corrigiu com `ensureVisible`. (2)
  **(B)**, mas pediu as versões exatas das dependências antes de
  reescrever, em vez de adivinhar a API — recebeu essas versões
  (`firebase_auth: 5.5.0`, `firebase_auth_mocks: 0.14.2`, `mockito:
  5.6.4`, todas de `pubspec.lock`) na mesma troca.
- **Resultado após correção:** não compilou — o código usou uma API
  (`signInWithEmailAndPasswordHandler`, `MockUserCredential`) que não
  existe na versão informada do pacote, apesar de ter recebido as versões
  corretas.

### Iteração 2

- **Motivo da falha:** erro de compilação — API alucinada
  (`signInWithEmailAndPasswordHandler`, `MockUserCredential`) não existe
  em `firebase_auth_mocks: 0.14.2`.
- **Prompt de reparo enviado:** erro de compilação completo, com nota
  explícita informando que essas APIs não existem na versão instalada e
  pedindo para não inventar API caso houvesse incerteza.
- **Resposta do LLM:** classificação **(A)** — reconheceu o erro anterior,
  citou a documentação do pacote (`whenCalling(...).on(...).thenThrow(...)`
  de `mock_exceptions`) e reescreveu os testes de exceção com esse
  mecanismo real, além de reescrever o teste de sucesso sem
  `MockUserCredential`.
- **Resultado após correção:** compilou; 11/12 passaram, 1 falhou (limitação
  de testabilidade conhecida de `TelaInicialScreen`) — **repair
  interrompido aqui por decisão humana, sem consumir a 3ª iteração**: a
  falha remanescente não é um erro de teste corrigível nem uma
  ambiguidade — é a mesma limitação de testabilidade documentada nas
  rodadas de integração do fluxo de login, e o próprio modelo já havia
  descartado a única "correção" possível (inicializar Firebase
  artificialmente) por mascarar o problema real em vez de resolvê-lo.

**Nota sobre (C):** não aplicável — a rodada teve falhas reais com ciclo
de reparo em ambas as iterações, não um bug identificado espontaneamente
na geração inicial sem falha.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | Iteração 1: (A) para o botão fora da viewport, (B) para o teste de Firebase (com pedido de mais contexto antes de corrigir). Iteração 2: (A) — reconheceu a API alucinada da resposta anterior. |
| **★ Classificação humana (auditoria)** | Iteração 1, falha 1: concordo — **Erro de teste** genuíno (falta de `ensureVisible`). Iteração 1, falha 2 (resultado da correção): **Erro de geração** — o modelo alucinou uma API (`signInWithEmailAndPasswordHandler`, `MockUserCredential`) que não existe na versão do pacote que ele mesmo havia acabado de receber, apesar de ter pedido essa informação especificamente para evitar esse erro. Falha final (1/12, iteração 2): concordo com a classificação implícita do modelo — **Limitação de testabilidade** (`TelaInicialScreen` acessa `FirebaseAuth.instance`/`FirebaseFirestore.instance` sem injeção de dependência), não um bug do `LoginScreen` nem erro de teste. |
| **★ Concordância** | Parcial — o modelo classificou corretamente a causa raiz de cada falha quando teve informação suficiente, mas produziu um **erro de geração não solicitado** ao tentar corrigir a falha 2 da iteração 1 (alucinação de API), mesmo após pedir e receber as versões exatas das dependências. Isso consumiu uma iteração inteira de reparo (de 3 permitidas) sem progresso real no teste de Firebase Auth. |
| **★ Observações** | Padrão notável: a estratégia zero-shot pediu proativamente informação de ambiente (versões de pacote) antes de tentar uma correção incerta — comportamento desejável — mas, mesmo de posse dessa informação, ainda produziu código incompatível com a versão informada na resposta seguinte. Isso sugere que o conhecimento do modelo sobre a API específica de versões menos populares de pacotes (`firebase_auth_mocks`) pode estar desatualizado ou impreciso mesmo quando a versão é fornecida explicitamente, exigindo um segundo ciclo de reparo para chegar à API real (`whenCalling`/`mock_exceptions`). A falha final (limitação de testabilidade de `TelaInicialScreen`) é consistente com as 3 rodadas de integração do fluxo de login e com a rodada `FASE2-WIDGET-ZS-01_CadastroScreen` (mesma classe de problema: tela de destino sem injeção de dependência do Firebase). **Desvio de execução:** ver nota detalhada nos Metadados — rodada iniciada por automação de navegador, mas geração inicial e ambas as iterações de reparo conduzidas manualmente pelo autor após perda da conversa do ChatGPT em sessão sem login. |

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
