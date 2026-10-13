# FASE2-WCRASH-COT — Réplica Gemini

Rodada **9/60**. Fecha o bloco W-CRASH.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WCRASH-COT |
| **Bug ID** | W-CRASH |
| **Função/tela alvo** | `CriarPlaylistScreen._filterMusicas` |
| **Arquivo(s) de origem** | `lib/criar_playlist.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada — ver `../unit/FASE2-UCRASH-ZS.md`. |
| **✦ Verificação externa da versão** | Seletor do app com `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-piloto`, W-CRASH confirmado ativo antes da execução |
| **Framework de teste** | flutter_test + mockito (mocks gerados por `build_runner`) |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/widget/wcrash_cot_test.dart` (+ `wcrash_cot_test.mocks.dart`, gerado) |
| **Saída arquivada** | `resultados/widget/FASE2-WCRASH-COT_iter0.txt` |
| **Modo de execução** | Manual (operador colou prompt e resposta) |

---

## Prompt Enviado

Verbatim, de `fase2-gemini/prompts_prontos/FASE2-WCRASH-COT.md`, do separador
`---` em diante. Pede quatro passos antes do código: analisar o widget,
identificar dependências a mockar, listar cenários — **incluindo
explicitamente "Cenários de erro (Firebase retorna erro, rede falha)"** — e
só então escrever. **Traz a linha de ajuda do caminho de import.**

---

## Resposta do LLM

Seguiu os quatro passos. Produziu análise do widget, plano de mocking,
lista de cenários em 5 grupos e 9 `testWidgets()` organizados em `group()`
espelhando esses grupos.

Usou três recursos que nenhuma rodada anterior usou:

1. **`@GenerateNiceMocks` do mockito**, para poder forçar exceção no
   Firestore — `FakeFirebaseFirestore` não permite simular falha de escrita.
2. **`Navigator` com `onPopPage`**, para verificar que a tela fecha após
   salvar.
3. **`Navigator.push` de verdade**, para testar o botão de voltar.

### Notas de execução

1. **Import do arquivo de mocks ajustado ao nome real do teste.** O modelo
   nomeou o arquivo `criar_playlist_test.dart` e importou
   `criar_playlist_test.mocks.dart`. A convenção da réplica nomeia
   `wcrash_cot_test.dart`, e o `build_runner` gera o `.mocks.dart` a partir do
   nome real do arquivo. **Única alteração feita no artefato:**
   `import 'criar_playlist_test.mocks.dart';` → `import 'wcrash_cot_test.mocks.dart';`.
   É mecânica, imposta pela convenção de nomes do operador, e o modelo não
   tinha como saber o nome usado aqui. Nenhum outro token foi tocado.
2. **`build_runner` executado**, conforme a instrução final da própria
   resposta: `dart run build_runner build --delete-conflicting-outputs`.
   Gerou `wcrash_cot_test.mocks.dart`. `mockito` e `build_runner` já estavam
   em `pubspec.yaml`; nenhuma dependência foi adicionada.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 9 |
| **Testes passaram (1ª execução)** | **9** |
| **Testes falharam (1ª execução)** | 0 |
| **Iterações de reparo** | 0 |
| **Tentativas de envio até obter resposta** | 1 |
| **Bug plantado capturado por asserção?** | **Não** |
| **Bug plantado mencionado na resposta?** | **Não** |

### Saída do terminal

```
00:00 +0: loading test/fase2-gemini/widget/wcrash_cot_test.dart
00:01 +1: 1. Renderização Básica Deve exibir CircularProgressIndicator quando a lista de músicas estiver vazia
00:02 +2: 1. Renderização Básica Deve renderizar e formatar as músicas carregadas do Firestore
00:02 +3: 2. Validação de Formulário Deve exibir SnackBar com erro ao tentar salvar sem preencher o nome
00:02 +4: 3. Interação do Usuário Deve filtrar as músicas ao digitar no campo de pesquisa
00:02 +5: 3. Interação do Usuário Deve alternar o estado de seleção da música ao clicar no checkbox
00:03 +6: 3. Interação do Usuário Deve acionar Navigator.pop ao tocar no botão de voltar
00:03 +7: 4. Cenários de Sucesso Deve salvar a playlist no Firestore com sucesso e fechar a tela
00:03 +8: 5. Cenários de Erro Deve exibir SnackBar com mensagem de erro quando falhar a gravação no Firestore
00:03 +9: All tests passed!
```

---

## Iterative Repair Loop

**Não houve.** Nenhum teste falhou, ciclo não acionado.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **Não declarada.** Não houve reparo, e a geração inicial não comenta o comportamento divergente — **não é (C)**. |
| **★ Classificação humana (auditoria)** | **Bug não detectado.** Suíte tecnicamente a melhor da réplica até aqui, e ainda assim cega ao defeito plantado. |
| **★ Concordância** | **N/A** — reparo não foi necessário e o bug não foi capturado. |
| **★ Observações** | Ver abaixo. |

### O prompt pediu "cenários de erro" — e o modelo entendeu outra coisa

Esta é a informação mais útil da rodada. O passo 3 do prompt diz, literalmente:

> "Cenários de erro (Firebase retorna erro, rede falha)"

O modelo cumpriu: criou um grupo `5. Cenários de Erro` e, para isso, montou um
`MockFirebaseFirestore` do mockito só para forçar exceção na escrita. É
trabalho real e bem-feito.

Mas **"erro" foi lido exclusivamente como falha de infraestrutura** — rede,
permissão, serviço indisponível. Não como **dado malformado**. Os três
documentos do catálogo trazem `track_name` e `artist_name` preenchidos, como
nas rodadas 7 e 8:

```dart
await fakeFirestore.collection('musica').add({
  'track_name': 'tempo perdido',
  'artist_name': 'legiao urbana',
});
```

Um único documento sem `artist_name` exporia o W-CRASH no teste de filtro —
que existe e passa. A instrução explícita de testar erro não aproximou o
modelo do bug, porque a categoria de erro que o bug habita não estava no
repertório evocado.

### Observações

1. **A ajuda do caminho de import se confirma como a variável da rodada 8.**
   ZS e COT trazem a linha e compilaram de primeira; FS não traz e queimou as
   3 iterações com três caminhos inventados. Com n=3 dentro da mesma tela e
   do mesmo modelo, a explicação está bem sustentada.
2. **CoT produziu a suíte mais sofisticada da réplica** — 9 testes, mocks
   gerados, teste de navegação real, verificação de `Navigator.pop`. E a
   sofisticação não ajudou em nada quanto ao bug.
3. **Sem anomalia de streaming** nesta rodada, ao contrário das rodadas 6 e 7.
4. **Sem recusa.** Envio único.

---

## Fechamento do bloco W-CRASH (rodadas 7–9)

| | ZS | FS | COT |
|---|---|---|---|
| Ajuda do caminho de import no prompt | **sim** | **não** | **sim** |
| Compilou de primeira | sim | **não** | sim |
| Iterações de reparo | 0 | **3 (máx.)** | 0 |
| Testes gerados | 5 | 5 | **9** |
| Resultado final | 5/5 | **3/5** | 9/9 |
| Mencionou o bug | não | não | não |
| **Asserção que captura o bug** | **não** | **não** | **não** |
| Autoclassificação | — | (A) ×3 | — |

**O W-CRASH sobreviveu às três estratégias.** Nenhuma o mencionou, nenhuma o
testou. Contraste com os blocos unitários, onde U-CRASH e U-SILENT foram
detectados em 6 de 6 rodadas, sempre na geração inicial, sempre (C).

A diferença não parece estar na estratégia de prompt — ela varia dentro de
cada bloco e o resultado não. Parece estar no **nível da pirâmide**:

- No unitário, a função tem 10 linhas e a divergência (docstring × código,
  mensagem × condição) está no campo de visão imediato.
- No widget, o defeito é uma **assimetria entre dois pontos distantes do mesmo
  arquivo** — `_filterMusicas` sem `??`, `itemBuilder` com `??` — e expô-lo
  exige escolher um **dado** que não é o dado óbvio. O modelo escreve o
  caminho de execução certo e alimenta com dados bem-formados.

É uma hipótese com 3 rodadas de widget contra 6 unitárias. Os blocos
`W-SILENT` (rodadas 10-12) e os de integração vão dizer se ela se sustenta.

**Consequência para a redação:** a taxa de aprovação não distingue as três
rodadas deste bloco de forma útil — 5/5, 3/5 e 9/9 dizem mais sobre o caminho
de import do que sobre a capacidade de encontrar o defeito. A métrica que
separa é "asserção que captura o bug", e nela o bloco inteiro é zero.
