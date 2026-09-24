# FASE2-ICRASH-ZS_REEXEC — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-ICRASH-ZS_REEXEC |
| **Rodada original** | `FASE2-ICRASH-ZS` (piloto, `fase2/rodadas/integration/FASE2-ICRASH-ZS.md`) — reexecutada porque o `build()` de `GenerosCadastroScreen` no prompt do piloto usava `SwitchListTile`; a tela real usa `Switch`, causando 3 das 6 falhas finais do piloto |
| **Bug ID** | I-CRASH |
| **Função/tela alvo** | Fluxo de cadastro — `GenerosCadastroScreen._salvarGeneros()` |
| **Arquivo(s) de origem** | `lib/cadastro.dart` + `lib/generos-cadastro.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login) |
| **Data de acesso** | 2026-09-03 |
| **Conversa nova?** | Sim — sessão deslogada do ChatGPT, sem histórico prévio |
| **Framework de teste** | flutter_test |
| **Arquivo de teste** | `test/fase2/integration/icrash_zs_reexec_test.dart` |
| **Execução** | Conduzida por automação de navegador (Claude in Chrome), mesmo padrão das 18 rodadas do piloto — não manualmente pelo autor |

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/FASE2--REEXEC.md`, seção "FASE2-ICRASH-ZS — REEXEC": código completo e real de `lib/cadastro.dart` (10 campos + dropdown de Estado) e `lib/generos-cadastro.dart` (`Switch` real, não `SwitchListTile`), colado verbatim — bug I-CRASH intacto.

---

## Resposta do LLM

### Mensagem inicial

O modelo gerou 5 testWidgets (fluxo completo, erro de Auth, erro de Firestore no cadastro, erro de Firestore nos gêneros, usuário não autenticado), usando corretamente `Switch` (não `SwitchListTile`) e `whenCalling(...).thenThrow(...)`. Detectou espontaneamente o bug I-CRASH (`currentUser!.uid` fora do `try`) e uma condição de corrida no teste de Firestore, sem que nenhum prompt de reparo tivesse sido enviado ainda. Usou `runWithClient`/`MockClient` do pacote `http/testing.dart` para simular a resposta do ViaCEP — API que se mostrou inexistente na versão pinada do projeto (ver iteração 1).

**★ Confirmação do achado da investigação:** nenhuma das 4 iterações desta rodada apresentou o erro `SwitchListTile`/`Switch` que dominou 3 das 6 falhas do piloto. O defeito confirmado do prompt foi eliminado.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou? (1ª tentativa)** | Não — `runWithClient` não existe na versão 0.13.6 de `package:http` pinada no projeto (API adicionada só em versões 1.x) |
| **Testes gerados** | 6 (5 iniciais, desdobrados) |
| **Iteração 1** | Compilou. **0/6** — `Bad state: No element` ao interagir com o dropdown de Estado fora do viewport 800×600, mais 2 testes presumindo estar em `GenerosCadastroScreen` sem navegar até lá |
| **Iteração 2** | **0/6** — dropdown ainda fora do viewport (causa raiz não era só offset, mas o próprio finder falhando); os 2 testes de gêneros isolados corrigidos estruturalmente, mas com o mesmo problema de viewport no botão "Confirmar" |
| **Iteração 3 (final, máximo permitido)** | **1/6** — `find.byWidgetPredicate` + `setSurfaceSize(800,1400)` resolveram o problema do dropdown e do viewport; 1 teste passou; 4 falharam por inconsistências residuais não relacionadas ao defeito confirmado; 1 falhou porque o bug I-CRASH foi exposto (ver achado #2) |

### Saída do terminal (iteração 0 — falha de compilação)

```
test/fase2/integration/icrash_zs_reexec_test.dart:151:11: Error: Method not found: 'runWithClient'.
test/fase2/integration/icrash_zs_reexec_test.dart:309:13: Error: Method not found: 'runWithClient'.
test/fase2/integration/icrash_zs_reexec_test.dart:363:13: Error: Method not found: 'runWithClient'.
00:00 +0 -1: Some tests failed.
```

(saída completa em `fase2/resultados/integration/FASE2-ICRASH-ZS_REEXEC_iter0.txt`)

### Saída do terminal (iteração 1 — 0/6)

Compilou após remover `runWithClient`/`MockClient` (API inexistente na versão pinada). Todos os 6 testes falharam com `Bad state: No element` — o tap no `DropdownButtonFormField` de Estado derivava um offset fora do viewport padrão de 800×600, e os 2 testes que assumiam estar em `GenerosCadastroScreen` na verdade abriam `CadastroScreen` (rota inicial de `appWith()`).
(saída completa em `fase2/resultados/integration/FASE2-ICRASH-ZS_REEXEC_iter1.txt`)

### Saída do terminal (iteração 2 — 0/6)

`ensureVisible()` sozinho não resolveu — o dropdown continuou retornando "Bad state: No element" dentro do próprio `tester.tap()`. Os 2 testes de gêneros isolados (montando `GenerosCadastroScreen` diretamente) corrigiram a navegação, mas o botão "Confirmar" também ficou fora do viewport 800×600 num deles.
(saída completa em `fase2/resultados/integration/FASE2-ICRASH-ZS_REEXEC_iter2.txt`)

### Saída do terminal (iteração 3 — final, 1/6, máximo de reparos atingido)

```
00:00 +0: fluxo completo: cadastro -> gêneros -> Firestore -> tela inicial [E]
  Expected: 'Praça da Sé' / Actual: '' (endereco['rua'])
00:03 +0 -1: exibe erro quando Firebase Auth falha durante o cadastro [E]
  Expected: exactly one matching candidate
  Actual: Found 0 widgets with text "Erro ao cadastrar: O e-mail já está sendo usado por outra conta."
00:04 +0 -2: exibe erro quando Firestore falha ao salvar o cadastro inicial [E]
  Actual: Found 0 widgets with text "Erro desconhecido:"
00:05 +0 -3: exibe erro quando Firestore falha ao salvar os gêneros [E]
  Actual: Found 0 widgets with text "Erro ao salvar os gêneros!"
00:06 +0 -4: usuário não autenticado deve ser tratado ao confirmar gênero [E]
  The following _TypeError was thrown running a test:
  Null check operator used on a null value
  #0 _GenerosCadastroScreenState._salvarGeneros (package:sintonize/generos-cadastro.dart:44:34)
00:06 +1 -5: não permite confirmar sem selecionar gênero -- PASSOU
00:07 +1 -5: Some tests failed.
```

(saída completa em `fase2/resultados/integration/FASE2-ICRASH-ZS_REEXEC_iter3_final.txt`)

---

## ⚠️ Achado metodológico importante

### 1. O defeito confirmado (`SwitchListTile` vs. `Switch`) foi eliminado

Em nenhuma das 4 iterações desta rodada o modelo usou ou precisou corrigir
`SwitchListTile` — todos os `Switch` foram usados corretamente desde a
resposta inicial. A causa raiz identificada na investigação (descrição
resumida/divergente da tela no prompt do piloto) foi corrigida com sucesso.

### 2. O bug I-CRASH foi exposto novamente

O teste `usuário não autenticado deve ser tratado ao confirmar gênero`
falhou com `_TypeError: Null check operator used on a null value`
apontando diretamente para `generos-cadastro.dart:44:34`
(`_auth.currentUser!.uid`, fora do `try`) — o mesmo bug-alvo, capturado
com sucesso. Como na rodada piloto, essa "falha" é o resultado positivo
da rodada: o `flutter_test` conta qualquer exceção não tratada durante um
`tap()` como falha do teste, independentemente da asserção declarada no
corpo do teste (`tester.takeException()` nem chegou a ser avaliado, pois
a exceção escapou durante o próprio `tester.tap()`).

### 3. Um novo defeito de material de entrada apareceu: `runWithClient` inexistente

O modelo tentou usar `http.runWithClient()`/`MockClient` do pacote
`http/testing.dart` para simular a resposta do ViaCEP — API que só existe
em `package:http` 1.x; o projeto está pinado na 0.13.6. Isso não é o
mesmo defeito investigado (não estava presente no prompt do piloto, pois
o piloto nunca chegou a compilar por causa do `SwitchListTile`) — é um
defeito novo, de geração do modelo, revelado apenas porque a correção do
defeito original permitiu que a rodada avançasse further o suficiente
para expor esta segunda limitação de API. Corrigido na iteração 1
removendo a dependência de `http`/mock de rede (o CEP não é necessário
para validar o fluxo Auth → Firestore).

### 4. Divergência residual não corrigida dentro do limite de iterações

Ao remover o preenchimento de Rua/Bairro/Cidade (campos sem `validator`,
dispensáveis para o fluxo), o modelo não atualizou a asserção
`endereco['rua'] == 'Praça da Sé'` no primeiro teste — resultando em uma
falha (`Expected: 'Praça da Sé' / Actual: ''`) que não foi detectada nem
corrigida porque as 3 iterações permitidas foram consumidas por outros
problemas (API inexistente, viewport, navegação). As falhas dos testes 2
e 4 (SnackBar não encontrado) provavelmente têm causa semelhante — uma
combinação de sincronismo (`pump()` único após operações assíncronas de
Firebase) não investigada a fundo por falta de iterações restantes.

### 5. Comparação com o piloto

| | Piloto | Reexecução |
|---|---|---|
| Causa dominante das falhas | `SwitchListTile` inexistente (3/6) | Resolvida — 0 ocorrências |
| Resultado final | 1/6 | 1/6 (mesma taxa, mas o teste que passou é diferente e o bug-alvo permanece exposto de forma equivalente) |
| Bug I-CRASH exposto | Sim (classificado B, recusa de enfraquecer asserção) | Sim (mesma linha exata, mesmo padrão de exceção não capturada) |
| Detecção espontânea do bug | Sim, já na resposta inicial | Sim, já na resposta inicial |

A taxa de sucesso bruta não melhorou (1/6 em ambas), mas a **causa** do
resultado mudou completamente: no piloto, a maior parte das falhas era
atribuível ao defeito confirmado do material de entrada; na reexecução,
esse defeito específico não ocorreu nenhuma vez, e as falhas restantes
são de naturezas variadas (uma API de mock inexistente em outra
biblioteca, uma inconsistência residual do próprio processo de reparo, e
a exposição bem-sucedida do bug-alvo).

---

## Iterative Repair Loop

### Iteração 1
- **Motivo da falha:** `runWithClient` inexistente em `http` 0.13.6.
- **Prompt de reparo:** erro colado + informação da versão pinada + lembrete de não adicionar dependências.
- **Resposta do LLM:** classificou (A); removeu `MockClient`/`runWithClient`, reescreveu `preencherCadastro()`/`cadastrarComSucesso()` sem simular o ViaCEP (campos Rua/Bairro/Cidade sem validator, dispensáveis).
- **Resultado:** compilou; 0/6 — `Bad state: No element` no dropdown de Estado (fora do viewport) + 2 testes assumindo `GenerosCadastroScreen` sem navegar até lá.

### Iteração 2
- **Motivo da falha:** mesmo padrão de erro no dropdown; 2 testes ainda presos à rota errada.
- **Prompt de reparo:** erro colado + explicação técnica (viewport 800×600; `appWith()` sempre inicia em `/cadastro`) + sugestões de técnica (`ensureVisible()`/`setSurfaceSize()`).
- **Resposta do LLM:** classificou (A) para as 3 causas; criou `generoApp()` para montar `GenerosCadastroScreen` diretamente nos 2 testes isolados; usou `ensureVisible()` no dropdown.
- **Resultado:** 0/6 — dropdown ainda falhava (causa mais profunda que apenas offset); botão "Confirmar" também fora do viewport num dos 2 testes de gêneros isolados.

### Iteração 3 (final — máximo permitido)
- **Motivo da falha:** dropdown e botão "Confirmar" ainda fora do viewport padrão.
- **Prompt de reparo:** erro colado com detalhe de que a falha ocorre dentro do próprio `tester.tap()` sobre o finder do dropdown, mais os 2 testes de gêneros isolados também afetados + aviso de última iteração.
- **Resposta do LLM:** classificação individual — (A) para os 4 primeiros testes (finder do dropdown deveria usar `find.byWidgetPredicate` em vez de `find.byType` genérico; viewport insuficiente), (A) para o teste de "não permite confirmar" (mesmo motivo de viewport), (B) para "usuário não autenticado" (bug real da aplicação, mantido sem enfraquecer a asserção, apenas renomeado para refletir que é o comportamento documentado). Aplicou `tester.binding.setSurfaceSize(const Size(800, 1400))` com `addTearDown` em todos os 6 testes.
- **Resultado final:** 1/6 passou (`não permite confirmar sem selecionar gênero`). Máximo de iterações atingido — documentado como está, por protocolo. As 5 falhas remanescentes se dividem em: 1 inconsistência residual do teste (endereço), 2 SnackBars não encontrados (causa não investigada — sem iterações restantes), 1 bug-alvo exposto com sucesso (resultado positivo).

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) nas iterações 1 e 2; classificação individual detalhada na iteração 3 — (A) para as causas de viewport/finder, (B) para o cenário de usuário não autenticado |
| **★ Classificação humana (auditoria)** | Iteração 1: **Erro de geração** (`runWithClient` inexistente). Iterações 2-3: **Erro de teste** (viewport/finder do dropdown, corrigido progressivamente). Resultado final — falha 1: **Erro de teste** (asserção de endereço não atualizada); falhas 2 e 4: **Ambíguo** (causa não investigada dentro do limite de iterações); falha 5 (usuário não autenticado): **Bug real exposto**; teste que passou: correto |
| **★ Concordância** | Concorda com a classificação do modelo em todos os pontos que ele chegou a analisar; a auditoria humana identifica como "Ambíguo" duas falhas que o modelo não teve oportunidade de diagnosticar por falta de iterações |
| **★ Observações** | O defeito confirmado pela investigação (`SwitchListTile`) foi eliminado com sucesso — nenhuma das 4 iterações desta rodada o reproduziu. Em compensação, a correção revelou uma segunda camada de problemas (API de mock de rede inexistente, viewport, uma inconsistência residual do próprio processo de reparo) que consumiram as 3 iterações disponíveis antes de esgotarem as causas mais superficiais. O bug-alvo I-CRASH continua sendo exposto de forma consistente e correta em todas as tentativas (piloto e reexecução), reforçando que esse achado é robusto à qualidade do material de entrada. |

**Referência de categorias (classificação humana — mesmas da Fase 1):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
