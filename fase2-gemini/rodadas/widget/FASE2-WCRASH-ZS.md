# FASE2-WCRASH-ZS — Réplica Gemini

Rodada **7/60**. Abre o bloco W-CRASH e o nível widget.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WCRASH-ZS |
| **Bug ID** | W-CRASH |
| **Função/tela alvo** | `CriarPlaylistScreen._filterMusicas` |
| **Arquivo(s) de origem** | `lib/criar_playlist.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada — ver `../unit/FASE2-UCRASH-ZS.md`. |
| **✦ Verificação externa da versão** | Seletor do app com `3.8 Flash` marcado, verificado na sessão. |
| **Data de acesso** | 2026-09-21 |
| **Conversa nova?** | Sim — três, ver "Tentativas" abaixo |
| **URL da conversa válida** | `https://gemini.google.com/app/f49ee5b35010bfcb` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-piloto`. W-CRASH confirmado: `lib/criar_playlist.dart:56` → `String artistName = musica['artist_name'].toLowerCase();` |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/widget/wcrash_zs_test.dart` |
| **Saída arquivada** | `fase2-gemini/resultados/widget/FASE2-WCRASH-ZS_iter0.txt` |
| **Modo de execução** | Automatizado via Claude in Chrome |

**O bug.** `_filterMusicas` faz `musica['artist_name'].toLowerCase()` sem
null-safety. Se algum documento da coleção `musica` não tiver `artist_name`,
o filtro lança ao digitar na busca. Note o contraste dentro do mesmo arquivo:
o `itemBuilder` da lista usa `musica['artist_name'] ?? 'Desconhecido'` — o
código *já sabe* que o campo pode faltar, e o filtro não.

---

## ⚠ Tentativas — 2 recusas antes da resposta

| # | Resultado | Conversa |
|---|---|---|
| 1 | Recusa: *"I'm having a hard time fulfilling your request. Can I help you with something else instead?"* (em inglês, apesar do prompt em português) | `7f14bdc9a7e6a6eb` |
| 2 | Resposta completa | `f49ee5b35010bfcb` |

Somando a recusa da rodada 6, são **3 recusas em 2 rodadas automatizadas**,
com três textos diferentes e em dois idiomas. O prompt foi conferido
programaticamente contra o arquivo de origem antes de cada envio (243 linhas,
idênticas nas duas tentativas). Ver o procedimento no README.

---

## Prompt Enviado

Verbatim, de `fase2-gemini/prompts_prontos/FASE2-WCRASH-ZS.md`, do separador
`---` em diante: o código completo de `CriarPlaylistScreen`, as dependências
de mock disponíveis e os requisitos. Inclui a linha de ajuda com o caminho de
import, desvio preservado da Fase 2.

---

## Resposta do LLM

**Anomalia de streaming — a resposta foi gerada duas vezes.** O modelo
produziu uma primeira suíte completa, cortou no meio da seção final
("*O que foi coberto: Estado assíncrono inicial: Ex*") e **recomeçou do
zero** com "*Aqui está a suíte de testes de widget completa...*", gerando uma
segunda suíte. A página final exibe os dois blocos de código.

Mesmo fenômeno observado na rodada 6, onde a prosa reiniciou no meio de uma
frase ("*...ou menor### 1. Análise da Função*"). Parece ser característica do
3.8 Flash em respostas longas.

**Artefato adotado: o segundo bloco**, que é o entregável final da resposta.
O primeiro fica registrado abaixo como parte da resposta, mas não foi
executado.

### Diferenças entre os dois blocos

| | Bloco 1 (abandonado) | Bloco 2 (adotado) |
|---|---|---|
| Testes | 6 | 5 |
| Dados de `musica` | criados por teste | criados no `setUp` |
| Teste de `CircularProgressIndicator` | sim | não |
| `uid` do mock | `user_123` | `test_user_123` |
| Verifica `dataCriacao` | sim | não |

Nenhum dos dois cobre o W-CRASH.

### Bloco 2 — adotado

O código integral está em `test/fase2-gemini/widget/wcrash_zs_test.dart`.

### Notas de execução

1. **Prompt conferido antes de cada envio**, linha a linha, contra o arquivo
   de origem. Igualdade exata nas duas tentativas.
2. **Código arquivado verbatim, com a indentação original.** A extração
   direta do bloco de código pela automação foi **bloqueada pelo guard de
   dados da extensão** (o código contém `'userId': user.uid` e e-mails de
   mock). A automação recuperou o código pela extração de texto da página,
   que descarta espaços à esquerda; essa primeira versão foi reindentada com
   `dart format`. **O operador então colou manualmente a resposta original**,
   e o arquivo foi substituído pela versão verbatim. A comparação entre as
   duas, ignorando espaço em branco, deu **identidade token a token** — ou
   seja, a reconstrução automática não havia alterado nada de substantivo —,
   mas o que está arquivado agora é o texto do modelo, sem normalização. O
   teste foi reexecutado sobre a versão verbatim: mesmo resultado, 5/5.

   Para as próximas rodadas cujo código a automação não conseguir extrair
   diretamente, o caminho é o mesmo: colagem manual do operador. Ver a nota
   de método no README.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 5 |
| **Testes passaram (1ª execução)** | 5 |
| **Testes falharam (1ª execução)** | 0 |
| **Iterações de reparo** | 0 |
| **Tentativas de envio até obter resposta** | **2** (1 recusa) |
| **Bug plantado capturado por asserção?** | **Não** |
| **Bug plantado mencionado na resposta?** | **Não** |

### Saída do terminal

```
00:00 +0: loading test/fase2-gemini/widget/wcrash_zs_test.dart
00:04 +1: Deve exibir SnackBar de erro ao tentar salvar sem preencher o nome
00:04 +2: Deve filtrar a lista de músicas ao digitar no campo de busca
00:05 +3: Deve alternar o ícone de seleção ao clicar no checkbox de uma música
00:05 +4: Deve salvar a playlist no Firestore quando o formulário for válido
00:05 +5: All tests passed!
```

Saída completa em `../../resultados/widget/FASE2-WCRASH-ZS_iter0.txt`.

---

## Iterative Repair Loop

**Não houve.** Nenhum teste falhou, ciclo não acionado.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **Não declarada.** Não houve reparo, e a geração inicial não comenta o comportamento divergente — logo **não é (C)**. |
| **★ Classificação humana (auditoria)** | **Bug não detectado.** A suíte é funcional e passa, mas passa ao largo do defeito. |
| **★ Concordância** | **N/A** — reparo não foi necessário e o bug não foi capturado. |
| **★ Observações** | Ver abaixo. |

### Por que o bug escapou

A suíte **tem** um teste de filtragem — `'Deve filtrar a lista de músicas ao
digitar no campo de busca'` — que exercita exatamente `_filterMusicas`, o
método defeituoso. Ele não quebra porque **todos os documentos de teste têm
`artist_name` preenchido**:

```dart
await firestore.collection('musica').add({
  'track_name': 'bohemian rhapsody',
  'artist_name': 'queen',
});
```

Bastava um documento sem `artist_name` para o teste lançar. O modelo nunca
considerou dados incompletos — apesar de o código que ele recebeu conter, no
`itemBuilder`, a evidência de que o campo pode faltar:

```dart
String artistName = _formatName(musica['artist_name'] ?? 'Desconhecido');
```

O `??` está lá, no mesmo arquivo, a poucas linhas do filtro que não o tem.
Essa assimetria é o rastro do bug plantado, e o modelo não a leu como pista.

### Observações

1. **Primeira rodada sem detecção, em 7.** As seis anteriores, todas
   unitárias, foram (C). A diferença plausível é o tamanho e a natureza do
   alvo: num validador de 10 linhas, a divergência entre docstring e código
   fica sob os olhos; num widget de 200 linhas, ela é uma inconsistência
   entre dois pontos distantes do mesmo arquivo.
2. **A cobertura "parece" boa.** 5 testes, renderização, filtragem, seleção,
   validação de formulário e persistência. Um relatório de aprovação diria
   100%. O defeito plantado está dentro de um método coberto por teste — o
   que falta é o *dado* que o expõe, não o caminho de execução.
3. **Comparação com a Fase 2 (ChatGPT):** ver `fase2/rodadas/widget/` e
   `fase2/resultados/widget/`, e comparar se a escolha de dados de mock
   difere.
4. **Anomalia de streaming** registrada acima — segunda ocorrência em duas
   rodadas automatizadas.
