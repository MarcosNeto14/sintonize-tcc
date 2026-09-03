# FASE2-ISILENT-COT — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-ISILENT-COT |
| **Bug ID** | I-SILENT |
| **Função/tela alvo** | Fluxo de criação de playlist — `CriarPlaylistScreen._salvarPlaylist()` |
| **Arquivo de origem** | `lib/criar_playlist.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-03 |
| **Conversa nova?** | Sim — sessão deslogada do ChatGPT, sem histórico prévio |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable) |
| **Arquivo de teste** | `test/fase2/integration/isilent_cot_test.dart` |

**Condição fixa de protocolo (documentada no prompt):** o cenário de
teste não deveria interagir com o campo "Pesquisar Música ou Artista"
(`_searchController`), pois isso aciona `_filterMusicas()`, que contém um
bug distinto (W-CRASH) fora do escopo desta rodada.

**Esta é a última rodada do experimento (18/18).**

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/FASE2-ISILENT-COT.md` — prompt
Chain-of-Thought em 5 passos, com o passo 4 pedindo explicitamente 4
cenários: fluxo de sucesso, nome vazio, **usuário não autenticado**, e
verificação exata dos dados persistidos. O código embutido é fiel ao
`lib/criar_playlist.dart` real do projeto (mesma verificação feita para
ZS e FS).

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Resposta completa e verbatim (extraída via "Copiar resposta"), com a
análise em 4 passos solicitada seguida de 4 `testWidgets()`:

```
1. Análise do fluxo
[...] Um detalhe importante do código fornecido: o campo nome persistido não usa
o nome digitado pelo usuário. Ele sempre grava 'Nova Playlist'. O teste deve
verificar exatamente esse comportamento, sem alterá-lo.

2. Dependências
[MockFirebaseAuth, FakeFirebaseFirestore, MaterialApp + tela anterior]

3. Estrutura de navegação
[...]

4. Cenários de teste
Sucesso ponta a ponta: carregar músicas → digitar nome → selecionar músicas →
salvar → verificar o documento em playlists → verificar que a tela foi removida.
Nome vazio: tocar em salvar sem informar nome → verificar SnackBar → verificar
que nenhum documento foi criado.
Usuário não autenticado: informar nome e tentar salvar sem currentUser →
verificar que nenhum documento é criado e que a tela permanece aberta.
Dados persistidos: verificar explicitamente userId, nome, musicas e dataCriacao,
inclusive o fato de nome ser 'Nova Playlist' independentemente do texto digitado.

5. Testes completos
[4 testWidgets(): fluxo de sucesso com Navigator.push/pop via onGenerateRoute;
nome vazio; usuário não autenticado; verificação exata das 4 chaves persistidas]

Observação importante sobre o teste: há um pequeno ajuste necessário no exemplo
acima para evitar depender de um GlobalKey declarado dentro de main em uma
função auxiliar que não é usada. Na prática, você pode remover completamente
criarApp() e _navigatorKey e simplificar o primeiro teste usando um MaterialApp
com home e Navigator.push. Os três últimos testes já estão estruturados dessa
forma.

Também vale destacar que o cenário de usuário não autenticado não apresenta
SnackBar nem mensagem de erro no código atual: _salvarPlaylist() simplesmente
não faz nada quando currentUser == null. O teste acima registra esse
comportamento sem alterar a implementação.
```

**★ Detecção espontânea:** **dupla**, na resposta inicial. O modelo
identificou (1) o bug I-SILENT (`'nome': 'Nova Playlist'` fixo) e (2) que
o cenário de usuário não autenticado é um **no-op silencioso**
(`_salvarPlaylist()` simplesmente não faz nada quando `currentUser ==
null` — nem salva, nem mostra erro, nem navega), documentando ambos os
comportamentos sem tentar corrigi-los ou mascará-los. Também identificou,
**por conta própria e antes de qualquer execução**, um problema técnico
no próprio código gerado (`criarApp()`/`_navigatorKey` mortos e com
referência antes da declaração), com a correção exata já sugerida na
mesma resposta.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou? (1ª tentativa)** | Não — exatamente o problema que o próprio modelo já havia sinalizado (`_navigatorKey` referenciado antes de declarado dentro de `criarApp()`, função nunca usada) + import de `firebase_auth` ausente |
| **Testes gerados** | 4 |
| **Iteração 1 (reparo)** | Compilou. **4 passaram / 4 total — 100%** |

### Saída do terminal (iteração 0 — falha de compilação)

Ver `fase2/resultados/integration/FASE2-ISILENT-COT_iter0.txt`

```
test/fase2/integration/isilent_cot_test.dart:42:14: Error: 'FirebaseAuth' isn't a type.
    required FirebaseAuth auth,
             ^^^^^^^^^^^^
test/fase2/integration/isilent_cot_test.dart:53:30: Error: Local variable '_navigatorKey'
can't be referenced before it is declared.
                Navigator.of(_navigatorKey.currentContext!).context,
                             ^^^^^^^^^^^^^
00:00 +0 -1: Some tests failed.
```

### Saída do terminal (iteração 1 — final, 4/4)

Ver `fase2/resultados/integration/FASE2-ISILENT-COT_iter1.txt`

```
00:00 +0: loading C:/Users/Marcos/Desktop/Sintonize-tcc/test/fase2/integration/isilent_cot_test.dart
00:00 +0: deve criar playlist, salvar músicas no Firestore e voltar para a tela anterior
00:00 +1: não deve salvar quando o nome da playlist estiver vazio e deve exibir SnackBar
00:00 +2: não deve salvar nem fechar a tela quando o usuário não estiver autenticado
00:01 +3: deve persistir exatamente userId, nome, musicas e dataCriacao em playlists
00:01 +4: All tests passed!
```

---

## ★ Achado metodológico importante

### 1. Terceira rodada consecutiva com 100% no bloco I-SILENT

O bloco I-SILENT fechou com **3/3 rodadas em 100%** (ZS: 2/2, FS: 2/2,
COT: 4/4), todas resolvidas em apenas 1 iteração de reparo trivial
(imports/nomes). É o único bloco do experimento com sucesso perfeito nas
3 estratégias, reforçando fortemente a hipótese levantada nas rodadas
anteriores: quando (a) o prompt é fiel ao código real da tela e (b) a
tela sob teste não depende de outra tela com limitação de testabilidade
conhecida (como `TelaInicialScreen`), o resultado é consistentemente
excelente — a estratégia de prompting (ZS/FS/COT) parece ter influência
secundária diante dessas duas condições.

### 2. Autocorreção prospectiva de um erro ainda não executado

Esta rodada apresenta um caso raro: o modelo **detectou seu próprio erro
de geração antes de qualquer execução de teste**, avisando explicitamente
na resposta inicial que `criarApp()`/`_navigatorKey` deveriam ser
removidos. Ainda assim, a resposta inicial entregue continha o código com
o problema (não a versão já corrigida) — o aviso foi driblado até a
iteração de reparo. Isso sugere uma limitação de auto-revisão: o modelo
consegue diagnosticar corretamente um problema em texto explicativo, mas
nem sempre aplica esse diagnóstico ao código que ele mesmo acabou de
gerar na mesma resposta.

### 3. Cobertura mais completa do bloco: dois comportamentos capturados numa só rodada

Diferente de ZS e FS (que cobriram apenas o cenário de sucesso e o nome
vazio), esta rodada, seguindo o passo 4 do CoT que pedia explicitamente o
cenário de usuário não autenticado, também documentou o comportamento de
no-op silencioso do `_salvarPlaylist()` nesse caso — um segundo
comportamento observável relevante para a tese, que as rodadas ZS/FS não
tiveram a oportunidade de cobrir.

---

## Iterative Repair Loop

### Iteração 1 (única, final)

**Prompt de reparo:** os erros de compilação exatos, confirmando que
correspondiam ao ajuste que o próprio modelo já havia apontado + template
(A)/(B). Ver `scratchpad/r18_repair1.txt`.

**Classificação declarada pelo modelo (verbatim):**

```
Classificação: (A) — a falha está no teste, não na aplicação. O teste anterior
continha referências inválidas (_navigatorKey declarado depois do uso e uma
função auxiliar desnecessária) e também faltava o import de FirebaseAuth. Como
criarApp() não é necessário, a correção mais simples é removê-la completamente e
fazer o primeiro cenário navegar por um botão da tela inicial.
```

**Ação:** removeu `criarApp()` e `_navigatorKey`, reestruturou o primeiro
teste para navegar via botão na tela inicial (`onGenerateRoute` mantido).
Todas as asserções relativas aos bugs I-SILENT permaneceram inalteradas.
**Resultado final:** **4/4 — 100%**.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) — correta; erro de código morto/ordem de declaração no próprio teste, sem relação com a aplicação |
| **★ Classificação humana (auditoria)** | **Erro de geração** (código morto com referência antes da declaração — o próprio modelo já havia identificado esse problema na resposta inicial, mas não o corrigiu proativamente no código entregue), corrigido em 1 iteração. As 4 asserções relacionadas aos bugs I-SILENT e ao no-op de usuário não autenticado são **Bug real exposto** — capturados corretamente desde a versão inicial |
| **★ Concordância** | Concorda integralmente quanto à causa do erro de compilação. Quanto ao restante, o teste captura fielmente dois comportamentos reais da aplicação (o hardcode do nome e o no-op silencioso de autenticação), sem necessidade de nenhum ajuste |
| **★ Observações** | Fecha o bloco I-SILENT com 3/3 rodadas em 100%, o único bloco do experimento com esse resultado. Reforça que a fidelidade do prompt ao código real e a independência de telas com limitações de testabilidade conhecidas são fatores mais determinantes que a estratégia de prompting escolhida. Interessante notar a "autocorreção anunciada mas não aplicada": o modelo sinalizou textualmente o próprio erro antes de qualquer execução, mas entregou o código com o defeito mesmo assim — sugerindo que o texto explicativo de uma resposta e o código gerado na mesma resposta nem sempre estão perfeitamente sincronizados. **Esta é a rodada final do experimento (18/18).** |

### Categorias de classificação humana

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
