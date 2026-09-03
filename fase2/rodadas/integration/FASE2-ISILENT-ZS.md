# FASE2-ISILENT-ZS — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-ISILENT-ZS |
| **Bug ID** | I-SILENT |
| **Função/tela alvo** | Fluxo de criação de playlist — `CriarPlaylistScreen._salvarPlaylist()` |
| **Arquivo de origem** | `lib/criar_playlist.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — ver `fase2/rodadas/README.md`) |
| **Data de acesso** | 2026-09-02/03 (sessão interrompida por reset de limite de uso entre a geração inicial e o reparo; ver nota abaixo) |
| **Conversa nova?** | Sim — sessão deslogada do ChatGPT, sem histórico prévio |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable) |
| **Arquivo de teste** | `test/fase2/integration/isilent_zs_test.dart` |

### Nota operacional

A execução desta rodada foi interrompida entre a resposta inicial do
modelo e o envio do 1º prompt de reparo por um reset de limite de uso da
sessão do assistente (não do ChatGPT). A conversa do ChatGPT permaneceu
aberta e intacta durante a pausa (a aba do navegador não foi recarregada
nem navegada), portanto o reparo foi enviado normalmente na mesma
conversa, sem quebra de protocolo.

**Condição fixa de protocolo (documentada no prompt):** o cenário de
teste não deveria interagir com o campo "Pesquisar Música ou Artista"
(`_searchController`), pois isso aciona `_filterMusicas()`, que contém um
bug distinto (W-CRASH) fora do escopo desta rodada.

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/FASE2-ISILENT-ZS.md` — prompt Zero-shot
pedindo um teste de integração para o fluxo de criação de playlist
(`CriarPlaylistScreen`), com o código da tela embutido. Ao contrário dos
prompts do bloco I-CRASH, o código embutido aqui é **fiel** ao
`lib/criar_playlist.dart` real do projeto (verificado antes de enviar) —
sem a divergência sistemática observada nas rodadas anteriores.

O bug I-SILENT está em `_salvarPlaylist()`, presente no prompt verbatim:

```dart
Future<void> _salvarPlaylist() async {
  final user = widget.auth.currentUser;
  if (user != null) {
    try {
      await widget.firestore.collection('playlists').add({
        'userId': user.uid,
        'nome': 'Nova Playlist',   // <- ignora _playlistName digitado pelo usuário
        'musicas': _musicasSelecionadas,
        'dataCriacao': Timestamp.now(),
      });
      Navigator.pop(context);
    } catch (e) { ... }
  }
}
```

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Resposta completa e verbatim (extraída via "Copiar resposta"):

```
Abaixo está um arquivo de teste completo, assumindo que CriarPlaylistScreen está em
lib/criar_playlist.dart. Ele usa MockFirebaseAuth e FakeFirebaseFirestore, sem
depender de Firebase real.

[2 testWidgets(): 'deve criar playlist com nome e música selecionada' e
'deve exibir erro quando o nome da playlist estiver vazio'. Popula o Firestore fake
com 2 músicas, preenche o nome ('Minhas Favoritas'), seleciona 1 música pelo
IconButton, salva, e verifica o documento criado.]

Observação importante

Há um bug no código da tela em relação ao requisito: embora o teste digite "Minhas
Favoritas", _salvarPlaylist() grava:

'nome': 'Nova Playlist',

em vez de usar _playlistName.

Se o comportamento esperado é realmente salvar o nome digitado, altere para:

'nome': _playlistName,

e então substitua no teste:

expect(playlist.data()['nome'], equals('Nova Playlist'));

por:

expect(playlist.data()['nome'], equals('Minhas Favoritas'));

Com o código atual, o teste acima valida fielmente o comportamento existente,
inclusive esse detalhe.
```

**★ Detecção espontânea do bug-alvo:** **sim** — na resposta inicial, sem
nenhum prompt de reparo. O modelo não apenas identificou a divergência
entre o nome digitado e o valor persistido, como também **escreveu a
asserção do teste de forma fiel ao comportamento real**
(`expect(playlist.data()['nome'], equals('Nova Playlist'))`), evitando
proativamente o erro mais comum deste tipo de bug (afirmar o valor
esperado em vez do observado). Esta é a detecção espontânea mais limpa
observada até agora no experimento: o modelo diagnosticou, documentou e
escreveu o teste corretamente alinhado ao bug em um único passo.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou? (1ª tentativa)** | Não — `Timestamp` não reconhecido (faltou `import 'package:cloud_firestore/cloud_firestore.dart';`) |
| **Testes gerados** | 2 |
| **Iteração 1 (reparo)** | Compilou. **2 passaram / 2 total — 100%** |

### Saída do terminal (iteração 0 — falha de compilação)

Ver `fase2/resultados/integration/FASE2-ISILENT-ZS_iter0.txt`

```
test/fase2/integration/isilent_zs_test.dart:121:13: Error: 'Timestamp' isn't a type.
        isA<Timestamp>(),
            ^^^^^^^^^
00:00 +0 -1: Some tests failed.
```

### Saída do terminal (iteração 1 — final, 2/2)

Ver `fase2/resultados/integration/FASE2-ISILENT-ZS_iter1.txt`

```
00:00 +0: loading C:/Users/Marcos/Desktop/Sintonize-tcc/test/fase2/integration/isilent_zs_test.dart
00:00 +0: deve criar playlist com nome e música selecionada
00:00 +1: deve exibir erro quando o nome da playlist estiver vazio
00:00 +2: All tests passed!
```

---

## ★ Achado metodológico importante

### 1. Melhor resultado do experimento até agora, e a causa é dupla

Esta é a primeira rodada do experimento a alcançar **100% de sucesso**
(2/2) com apenas 1 iteração de reparo, e a única a fazê-lo sem qualquer
falha de asserção — apenas um erro de compilação trivial (import
ausente). Duas condições provavelmente contribuíram:

1. O prompt pronto desta rodada é **fiel ao código real** do app (ao
   contrário dos 3 prompts do bloco I-CRASH, que continham versões
   simplificadas de `CadastroScreen`/`GenerosCadastroScreen`).
2. `CriarPlaylistScreen` não depende de nenhuma outra tela para o teste
   ser considerado completo — não há navegação para uma tela com o
   problema de testabilidade de `TelaInicialScreen` (acesso direto a
   `FirebaseAuth.instance`) que afetou negativamente várias rodadas
   anteriores (W-SILENT, W-CRASH, e as 3 rodadas I-CRASH).

### 2. Bug silencioso capturado sem necessidade de nenhum direcionamento

Diferente do bug I-CRASH (que quebra o app com uma exceção visível, mais
fácil de notar mesmo sem examinar a lógica de perto), o bug I-SILENT é
puramente semântico — o app continua funcionando normalmente, apenas
persiste um valor incorreto. O modelo o identificou de forma zero-shot,
sem nenhuma dica no prompt além do próprio código-fonte, reforçando que
bugs silenciosos de "valor hardcoded" são, ao menos neste caso, tão
detectáveis quanto bugs que causam crash quando o modelo lê a
implementação com atenção.

---

## Iterative Repair Loop

### Iteração 1 (única, final)

**Prompt de reparo:** o único erro de compilação (`Timestamp` não
reconhecido) + template (A)/(B). Ver `scratchpad/r16_repair1.txt`.

**Classificação declarada pelo modelo (verbatim):**

```
Classificação: (A). A falha é causada por uma dependência ausente no próprio
teste: Timestamp pertence a package:cloud_firestore/cloud_firestore.dart. Isso
não indica comportamento incorreto da aplicação. Portanto, o teste deve ser
corrigido normalmente, sem alterar lib/criar_playlist.dart.
```

**Ação:** adicionou o import ausente. Nenhuma outra alteração foi
necessária — o restante do teste, incluindo a asserção fiel ao bug
I-SILENT, permaneceu inalterado.
**Resultado final:** **2/2 — 100%**.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) — correta; o único erro foi de import, sem qualquer relação com a aplicação |
| **★ Classificação humana (auditoria)** | **Erro de geração** trivial (import ausente), corrigido em 1 iteração. Nenhuma outra categoria se aplica — o teste passou integralmente e capturou o bug I-SILENT corretamente desde a versão inicial |
| **★ Concordância** | Concorda integralmente |
| **★ Observações** | Melhor rodada do experimento em eficiência (1 única iteração de reparo, trivial) e em qualidade de detecção espontânea (identificou o bug, explicou a causa, e já escreveu a asserção correta alinhada ao comportamento real, sem que isso precisasse ser corrigido depois). Fator de maior impacto provável: o prompt desta rodada não contém a divergência sistemática entre código-fonte do prompt e app real que prejudicou as 3 rodadas do bloco I-CRASH, e a tela sob teste não depende de nenhuma tela com limitação de testabilidade conhecida (diferente de `TelaInicialScreen`). Isso sugere que a fidelidade do material de entrada da rodada ao código real é um fator determinante na taxa de sucesso, possivelmente mais decisivo que a escolha da estratégia de prompting (ZS/FS/COT) em si. |

### Categorias de classificação humana

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
