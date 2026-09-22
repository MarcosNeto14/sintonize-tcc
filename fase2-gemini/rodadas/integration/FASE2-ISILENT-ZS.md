# FASE2-ISILENT-ZS — Réplica Gemini

Rodada **16/60**. Abre o bloco I-SILENT.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-ISILENT-ZS |
| **Bug ID** | I-SILENT |
| **Função/tela alvo** | `CriarPlaylistScreen._salvarPlaylist` |
| **Arquivo(s) de origem** | `lib/criar_playlist.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor do app com `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-piloto`, I-SILENT ativo |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/integration/isilent_zs_test.dart` |
| **Saídas arquivadas** | `resultados/integration/FASE2-ISILENT-ZS_iter{0,1}.txt` |
| **Modo de execução** | Manual |
| **Versão do prompt** | Original, de `prompts_prontos/FASE2-ISILENT-ZS.md`, sem alteração |

**Bug plantado:** `_salvarPlaylist` grava `'nome': 'Nova Playlist'` fixo em
vez do nome digitado (`lib/criar_playlist.dart:251`). Falha silenciosa: a
playlist é salva, a tela fecha, nenhum erro.

**Condição de protocolo (campo de pesquisa):** respeitada. Nenhum teste
digita em "Pesquisar Música ou Artista".

---

## Resposta do LLM — geração inicial

2 testes (fluxo completo e nome vazio), import correto, `setUp` com dois
documentos em `musica`. O teste de sucesso digita `'Rock Clássico'` e confere
`userId`, `musicas` e `dataCriacao` — **não confere `nome`**.

Fora do código, em "Observações sobre a execução":

> "Atenção ao código de produção: Em CriarPlaylistScreen, o método
> _salvarPlaylist grava a string fixa 'nome': 'Nova Playlist' ao invés de
> usar _playlistName / _nomeController.text. Caso altere no componente para
> salvar _playlistName, basta atualizar a asserção para
> `expect(playlistCriada['nome'], equals('Rock Clássico'));`."

**O modelo viu o bug e escreveu a asserção que o capturaria — e a deixou
fora do teste.** Apresenta o defeito como detalhe de implementação a
acompanhar, não como falha: a asserção correta fica condicionada a alguém
consertar o código primeiro.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Sim** |
| **Testes gerados** | 2 |
| **Testes passaram (1ª execução)** | 1 |
| **Iterações de reparo** | **1** |
| **Testes passaram (pós-repair)** | **2** |
| **Testes falharam (pós-repair)** | **0** |
| **Tentativas de envio até obter resposta** | 1 |
| **Bug plantado capturado por asserção?** | **Não** — nenhuma asserção sobre `nome` |
| **Bug plantado mencionado na resposta?** | **Sim, na geração inicial**, com a asserção correta no texto |

---

## Iterative Repair Loop

### Iteração 1

- **Motivo:** `Found 0 widgets with icon "IconData(U+0E157)"` — após tap em
  `find.byType(IconButton).first`, nenhum `Icons.check_box`. O primeiro
  `IconButton` da tela real é a seta de voltar do cabeçalho
  (`lib/criar_playlist.dart:101`), que o snippet do prompt não mostra.
- **★ Autoclassificação:** **(A)**, correta.
- **Diagnóstico:** vago e em parte errado — fala em ordenação do Fake
  Firestore, padding do `IconButton` e `pump()` insuficiente. Não identifica
  o botão de voltar. A correção funciona por outro motivo: passa a tocar em
  `find.byIcon(Icons.check_box_outline_blank).first`.
- **Enfraquecimento sob (A):** `contains('Bohemian Rhapsody')` →
  `isNotEmpty` em `musicas`.
- **Resultado:** **2/2.**
- Saída: `FASE2-ISILENT-ZS_iter1.txt`

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(A)** |
| **★ Classificação humana (auditoria)** | **Erro de teste** — correta, com diagnóstico impreciso |
| **★ Concordância** | **Sim** |

### Observações

1. **Primeira menção espontânea a um bug de widget/integração na geração
   inicial.** O defeito tem a forma que o achado de detecção prevê: é
   local e sintaticamente visível — o controller `_nomeController` e o
   `_playlistName` estão no código, e três linhas abaixo aparece uma string
   literal no lugar deles.
2. **Viu, mas não testou.** A suíte final passa com o bug ativo. Não chega a
   canonizar (não afirma `'Nova Playlist'`), mas omite exatamente a asserção
   que o próprio modelo redigiu.
3. **Suíte verde não é suíte correta.** Com a suíte verde, o bug escapa. Só
   quem ler a nota em prosa da resposta fica sabendo do defeito.
