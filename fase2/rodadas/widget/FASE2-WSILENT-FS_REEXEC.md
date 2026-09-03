# FASE2-WSILENT-FS_REEXEC — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WSILENT-FS_REEXEC |
| **Rodada original** | `FASE2-WSILENT-FS` (piloto, `fase2/rodadas/widget/FASE2-WSILENT-FS.md`) — reexecutada porque o exemplo few-shot do piloto usava `MockFirebaseAuth(authExceptions: AuthExceptions(...))`, API inexistente em `firebase_auth_mocks` 0.14.2, confirmada como causa de falha de compilação já na iteração 0 do piloto |
| **Bug ID** | W-SILENT |
| **Função/tela alvo** | `LoginScreen` (`login()` — mapeamento de erros) |
| **Arquivo(s) de origem** | `lib/login.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Few-shot (corrigido — ver `fase2/prompts_prontos/FASE2--REEXEC.md`) |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-03 |
| **Conversa nova?** | Sim — sessão deslogada do ChatGPT, sem histórico prévio |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable) |
| **Arquivo de teste** | `test/fase2/widget/wsilent_fs_reexec_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome) interagindo com o ChatGPT, no mesmo padrão adotado nas 18 rodadas do piloto da Fase 2 — não pelo autor manualmente no teclado |

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/FASE2--REEXEC.md`, seção "FASE2-WSILENT-FS — REEXEC": mesmo `LoginScreen` do piloto (bug W-SILENT intacto — mensagens de `user-not-found`/`wrong-password` trocadas), mas com o exemplo few-shot corrigido para usar `whenCalling(Invocation.method(#signInWithEmailAndPassword, null)).on(authComErro).thenThrow(FirebaseAuthException(code: 'wrong-password'))` do pacote `mock_exceptions`, em vez de `MockFirebaseAuth(authExceptions: AuthExceptions(...))`.

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

O modelo gerou 10 testWidgets cobrindo validação de e-mail/senha, os 4 códigos de erro do Firebase (`user-not-found`, `wrong-password`, `invalid-credential`, código desconhecido), campo de senha oculto e navegação após login bem-sucedido — usando corretamente `whenCalling(...).on(...).thenThrow(...)` em todos os cenários de erro, sem nenhuma tentativa de usar `AuthExceptions`.

**★ Detecção espontânea do bug-alvo:** sim, na resposta inicial — "as mensagens de `user-not-found` e `wrong-password` estão trocadas em relação aos códigos do Firebase. Os testes acima reproduzem exatamente o comportamento atual do widget, em vez de assumir qual mensagem deveria ser semanticamente correta." Mesmo padrão de detecção já visto no piloto (ZS e FS).

**★ Confirmação do achado da investigação:** o exemplo few-shot corrigido eliminou completamente o erro de compilação por `AuthExceptions` — nenhuma das 3 iterações desta rodada mencionou essa API. A causa raiz identificada e corrigida no prompt não se repetiu.

**Erro habitual reaparecendo por conta própria:** o modelo importou `package:sintonize/login_screen.dart` (nome de arquivo hipotético, sufixo `_screen.dart`) em vez do real `lib/login.dart` — o mesmo tipo de alucinação de path já documentado em `FASE2-WSILENT-ZS.md`/`FASE2-WSILENT-FS.md` (piloto) e em `WIDGET-FS-01.md` (Fase 1). Também tentou usar `TelaInicialScreen` sem importá-la e `TextFormField.obscureText` (getter inexistente nessa classe) — os mesmos dois erros recorrentes de API já registrados nas rodadas W-SILENT anteriores.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou? (1ª tentativa)** | Não — mas por motivo **diferente** do piloto: nome de arquivo hipotético (`login_screen.dart`), `TelaInicialScreen` sem import, `TextFormField.obscureText` inexistente. **Nenhum erro de `AuthExceptions`.** |
| **Testes gerados** | 10 (depois expandidos para 11 no reparo, ao desdobrar o teste de sucesso) |
| **Testes passaram (após iteração 1 — modelo pediu esclarecimento do path real)** | 0/0 (não compilou — o modelo devolveu um placeholder `SEU_CAMINHO` em vez de adivinhar) |
| **Testes passaram (após iteração 2 — path real `lib/login.dart` fornecido)** | 10/11 |
| **Testes falharam (após iteração 2)** | 1 — `FirebaseException: [core/no-app]` no teste de navegação pós-login |
| **Testes passaram (após iteração 3 — final, máximo permitido)** | 10/11 (inalterado — modelo classificou (B) e recusou-se a alterar o teste) |

### Saída do terminal (iteração 0 — falha de compilação)

```
test/fase2/widget/wsilent_fs_reexec_test.dart:8:8: Error: Error when reading 'lib/login_screen.dart': O sistema não pode encontrar o arquivo especificado
import 'package:sintonize/login_screen.dart';
       ^
test/fase2/widget/wsilent_fs_reexec_test.dart:20:15: Error: Method not found: 'LoginScreen'.
test/fase2/widget/wsilent_fs_reexec_test.dart:275:26: Error: Undefined name 'TelaInicialScreen'.
test/fase2/widget/wsilent_fs_reexec_test.dart:253:25: Error: The getter 'obscureText' isn't defined for the type 'TextFormField'.
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/widget/FASE2-WSILENT-FS_REEXEC_iter0.txt`)

### Saída do terminal (iteração 1 — o modelo devolveu um import-placeholder)

Em vez de adivinhar um segundo caminho, o modelo devolveu
`import 'package:sintonize/SEU_CAMINHO/login_screen.dart';` e pediu
explicitamente o caminho real. Rodar essa versão apenas reproduz o mesmo
tipo de erro de import, agora contra o placeholder literal:

```
test/fase2/widget/wsilent_fs_reexec_test.dart:15:8: Error: Error when reading 'lib/SEU_CAMINHO/login_screen.dart': O sistema não pode encontrar o caminho especificado
test/fase2/widget/wsilent_fs_reexec_test.dart:27:15: Error: Method not found: 'LoginScreen'.
test/fase2/widget/wsilent_fs_reexec_test.dart:360:23: Error: Undefined name 'LoginScreen'.
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/widget/FASE2-WSILENT-FS_REEXEC_iter1.txt`)

### Saída do terminal (iteração 2 — 10/11, path real fornecido)

```
00:00 +0: LoginScreen Widget deve exibir erro quando o e-mail está vazio
00:01 +1: LoginScreen Widget deve exibir erro quando o e-mail é inválido
00:01 +2: LoginScreen Widget deve exibir erro quando a senha está vazia
00:01 +3: LoginScreen Widget deve exibir erro quando a senha tem menos de 6 caracteres
00:02 +4: LoginScreen Widget não deve autenticar quando o formulário é inválido
00:02 +5: LoginScreen Widget deve exibir mensagem para user-not-found
00:02 +6: LoginScreen Widget deve exibir mensagem para wrong-password
00:02 +7: LoginScreen Widget deve exibir mensagem para invalid-credential
00:03 +8: LoginScreen Widget deve exibir mensagem genérica para erro inesperado
00:03 +9: LoginScreen Widget campo de senha deve ocultar o texto digitado
00:03 +10: LoginScreen Widget deve substituir LoginScreen após login bem-sucedido
The following FirebaseException was thrown running a test:
[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()
00:04 +10 -1: LoginScreen Widget deve substituir LoginScreen após login bem-sucedido [E]
00:04 +10 -1: Some tests failed.
```

(saída completa em `fase2/resultados/widget/FASE2-WSILENT-FS_REEXEC_iter2.txt`)

### Saída do terminal (iteração 3 — final, 10/11, máximo de reparos atingido)

Idêntica à iteração 2 — o modelo classificou a falha remanescente como
(B) e manteve o teste sem alterações (ver seção de reparo abaixo).
(saída completa em `fase2/resultados/widget/FASE2-WSILENT-FS_REEXEC_iter3_final.txt`, cópia da iteração 2 porque nenhum código foi alterado)

---

## ⚠️ Achado metodológico importante

### 1. O defeito confirmado (`AuthExceptions`) foi eliminado com a correção do prompt

Nenhuma das 3 iterações de reparo desta rodada mencionou `AuthExceptions`
ou qualquer parâmetro `authExceptions`. A causa raiz identificada na
investigação — o exemplo few-shot do piloto usar uma API inexistente —
foi confirmada como corrigida: o modelo usou `whenCalling(...).thenThrow(...)`
corretamente em todos os 4 cenários de erro do Firebase desde a resposta
inicial.

### 2. A rodada ainda precisou de reparo — mas por causas não relacionadas, já documentadas em rodadas anteriores

A falha de compilação inicial teve **três causas independentes da
correção aplicada**: (a) alucinação do nome do arquivo
(`login_screen.dart` em vez de `login.dart`, o mesmo padrão de
`FASE2-WSILENT-ZS`, `FASE2-WSILENT-FS` piloto e `WIDGET-FS-01` da Fase 1),
(b) referência a `TelaInicialScreen` sem import, e (c) uso do getter
inexistente `TextFormField.obscureText`. Nenhuma dessas três é o defeito
que esta reexecução pretendia eliminar — são erros de geração já
documentados como recorrentes do modelo neste projeto, independentes da
estratégia de prompt.

### 3. O modelo preferiu pedir esclarecimento a adivinhar novamente

Na iteração 1, em vez de tentar um segundo nome de arquivo hipotético
(como aconteceu na Fase 1, `WIDGET-FS-01`), o modelo devolveu um
placeholder explícito (`SEU_CAMINHO`) e pediu o caminho real — um
comportamento mais conservador do que o observado em rodadas anteriores
com o mesmo tipo de erro.

### 4. Limitação de testabilidade de `TelaInicialScreen` confirmada uma vez mais

O único teste que não passou (`deve substituir LoginScreen após login
bem-sucedido`) falha pelo mesmo motivo sistemático já documentado em
`FASE2-WSILENT-ZS`, `FASE2-WSILENT-FS` (piloto) e `FASE2-ICRASH-COT`:
`TelaInicialScreen` acessa `FirebaseAuth.instance`/`FirebaseFirestore.instance`
diretamente, sem receber essas dependências por injeção. Informado dessa
limitação já conhecida no prompt de reparo final, o modelo classificou
corretamente como (B) e recusou-se a mascará-la com
`Firebase.initializeApp()` falso ou a enfraquecer a asserção.

### 5. Comparação com o piloto

| | Piloto (`FASE2-WSILENT-FS`) | Reexecução (`FASE2-WSILENT-FS_REEXEC`) |
|---|---|---|
| Causa da falha de compilação inicial | `AuthExceptions` inexistente + (nas iterações seguintes) `obscureText`/`TelaInicialScreen` | `login_screen.dart` hipotético + `TelaInicialScreen` sem import + `obscureText` — **sem `AuthExceptions`** |
| Iterações usadas | 3 (máximo) | 3 (máximo) |
| Resultado final | 9/10 (90%) | 10/11 (91%) |
| Detecção espontânea do bug W-SILENT | Sim | Sim |
| Falha remanescente final | `TelaInicialScreen` (`core/no-app`) | `TelaInicialScreen` (`core/no-app`) — mesma limitação |

A taxa de sucesso final é equivalente à do piloto, mas por um caminho
diferente: o defeito confirmado do prompt (API inexistente) deixou de
ocorrer; o resultado final continua imperfeito por causas já registradas
e independentes (alucinação de nome de arquivo; limitação de
testabilidade de `TelaInicialScreen`).

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** compilação — import hipotético `login_screen.dart`, `TelaInicialScreen` sem import, `TextFormField.obscureText` inexistente.
- **Prompt de reparo enviado:** saída de erro colada, seguindo o template padrão de reparo (verbatim).
- **Resposta do LLM:** classificou (A); removeu a dependência de `TelaInicialScreen` (passou a verificar apenas que `LoginScreen` deixa de estar presente após o `pushReplacement`); corrigiu `obscureText` para inspecionar o `TextField` descendente; mas, sem saber o caminho real do arquivo, devolveu um import-placeholder (`SEU_CAMINHO`) e pediu explicitamente essa informação em vez de adivinhar.
- **Resultado:** ainda não compila (o placeholder não é um caminho válido).

### Iteração 2

- **Motivo da falha:** o mesmo tipo de erro de import, agora contra o placeholder literal.
- **Prompt de reparo enviado:** erro colado + informação do caminho real (`lib/login.dart`) fornecida explicitamente pelo experimentador, seguindo o mesmo padrão de outras rodadas do experimento em que essa informação foi necessária.
- **Resposta do LLM:** classificou (A); trocou o import por `package:sintonize/login.dart`; manteve a estratégia de não depender de `TelaInicialScreen`; identificou e corrigiu, no próprio texto da resposta, um erro de digitação que havia introduzido no bloco de código (parêntese ausente em uma chamada `enterText`).
- **Resultado:** compilou; 10/11 passaram. 1 falha: `FirebaseException: [core/no-app]` no teste de navegação pós-login.

### Iteração 3 (final — máximo permitido)

- **Motivo da falha:** limitação de testabilidade já conhecida de `TelaInicialScreen` (ver achado metodológico #4).
- **Prompt de reparo enviado:** erro colado + nota de protocolo informando que essa mesma falha já apareceu em rodadas anteriores, qual a causa raiz identificada, e que `Firebase.initializeApp()` falso já foi tentado sem sucesso — mais aviso de última iteração.
- **Resposta do LLM (resumo):** classificou **(B)** — "o teste capturou um comportamento potencialmente incorreto da aplicação"; descreveu o comportamento observado (`TelaInicialScreen` acessa o Firebase real após a navegação) e o esperado (a navegação pós-login deveria funcionar independente das instâncias globais do Firebase, via injeção de dependência também em `TelaInicialScreen`); manteve o teste de navegação exatamente como estava, sem enfraquecer a asserção nem mascarar o problema.
- **Resultado final:** 10/11 (91%). Repair loop encerrado no limite de 3 iterações, sem 100% dos testes passando — resultado final documentado como está, por protocolo.

---

## ★ Análise de Autoclassificação

### Quanto ao bug-alvo W-SILENT (mensagens `user-not-found`/`wrong-password` trocadas)

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(C)** — bug identificado espontaneamente na geração inicial, sem falha nem reparo. Evidência: resposta inicial do modelo (ver "Resposta do LLM" acima) — "as mensagens de `user-not-found` e `wrong-password` estão trocadas em relação aos códigos do Firebase. Os testes acima reproduzem exatamente o comportamento atual do widget, em vez de assumir qual mensagem deveria ser semanticamente correta." Os testes `deve exibir mensagem para user-not-found` e `deve exibir mensagem para wrong-password` já nasceram calibrados ao comportamento buggy e passaram em todas as execuções — o bug nunca desencadeou uma falha nem entrou no ciclo de reparo, portanto não há (A)/(B) aplicável a ele. |
| **★ Classificação humana (auditoria)** | Bug capturado sem necessidade de reparo (C) |
| **★ Concordância** | Sim |
| **★ Observações** | Este é o único bug-alvo, entre os 4 confirmados na investigação, capturado antes de qualquer execução — diferente de I-CRASH-ZS/COT, onde a exposição do bug só ocorre via falha em tempo de execução (exceção não tratada) e é classificada (B) durante o reparo. |

### Quanto às demais falhas da rodada (não relacionadas ao bug-alvo)

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) nas iterações 1 e 2 (corretas — erros de geração do próprio teste); (B) na iteração 3 (correta — limitação de testabilidade real da aplicação) |
| **★ Classificação humana (auditoria)** | Erro de geração (iteração 1 — nome de arquivo hipotético, uso indevido de `TextFormField.obscureText`) / Erro de geração (iteração 1→2, resolvido — import corrigido após informação do caminho real) / Limitação de testabilidade (iteração 3 — `TelaInicialScreen` não injetável, mesma causa raiz de `FASE2-WSILENT-ZS`/`FASE2-WSILENT-FS` piloto) |
| **★ Concordância** | Concorda integralmente em todas as 3 iterações |
| **★ Observações** | Rodada confirma que a correção aplicada ao prompt (few-shot sem `AuthExceptions`) eliminou o defeito específico identificado na investigação — nenhuma menção a essa API em nenhuma das 3 iterações. O resultado final (10/11) segue limitado pelos dois problemas já documentados e independentes da correção: alucinação de nome de arquivo (padrão recorrente do modelo neste projeto) e a limitação de testabilidade sistemática de `TelaInicialScreen`. |

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
