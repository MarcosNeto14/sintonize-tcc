# Propostas de Bugs Propositais — Fase 2

**Status:** os 6 candidatos abaixo foram aprovados e já estão implementados no código (branch `fase2-prep`).  
**Decisão de implementação:** do autor do TCC e do orientador.  
**Data da proposta:** 2026-08-30

---

## Critérios de seleção

Cada candidato cobre um dos dois tipos definidos no plano:

- **Crash** — produz exceção de runtime não tratada ou comportamento que
  encerra o widget/frame de forma visível.
- **Silencioso** — retorna valor incorreto ou grava dado errado, mas sem
  lançar exceção; o app continua funcionando aparentemente.

Os candidatos foram escolhidos de modo que o bug seja detectável por
testes bem escritos (unitários, widget ou integração), sem depender
de acesso real ao Firebase.

---

## Nível Unitário — `lib/utils/validators.dart`

### Candidato U-CRASH — `capitalize` (linha 162)

| Campo | Valor |
|---|---|
| **Arquivo** | `lib/utils/validators.dart` |
| **Função** | `capitalize(String text)` |
| **Linha aprox.** | 162 — `if (word.isEmpty) return word;` |
| **Tipo** | Crash |

**Comportamento atual (correto):**
```dart
return text.split(' ').map((word) {
  if (word.isEmpty) return word;   // protege word[0] de RangeError
  return word[0].toUpperCase() + word.substring(1).toLowerCase();
}).join(' ');
```
`split(' ')` em `"hello  world"` produz `['hello', '', 'world']`. A
guarda devolve a string vazia intacta, evitando acesso ao índice 0.

**Comportamento com bug:** remover a linha 162 inteira:
```dart
return text.split(' ').map((word) {
  return word[0].toUpperCase() + word.substring(1).toLowerCase();
}).join(' ');
```
Para qualquer entrada com espaços consecutivos, inicial ou final, `word`
assume `''` em alguma iteração e `word[0]` lança
`RangeError (index): Invalid value: Valid value range is empty: 0`.

**Por que é crash:** `RangeError` não capturado; a função é pura (sem
Firebase) e não tem try/catch, então a exceção propaga diretamente ao
chamador.

**Risco de confusão:** baixo — sem dependência de Firebase; reproduzível
de forma completamente determinística por teste unitário com entrada de
espaço duplo ou espaço inicial (`capitalize('hello  world')`).

**Nota de coerência interna:** torna `capitalize` idêntica em
comportamento ao bug já existente em `formatName`, que nunca teve essa
guarda. A diferença entre as duas funções era exatamente essa linha —
dado potencialmente relevante para a análise comparativa do TCC.

---

### Candidato U-SILENT — `validateSenha` (linha 117)

| Campo | Valor |
|---|---|
| **Arquivo** | `lib/utils/validators.dart` |
| **Função** | `validateSenha(String? value)` |
| **Linha aprox.** | 117 |
| **Tipo** | Silencioso |

**Comportamento atual (correto):**
```dart
if (value.length < 6) {
  return 'A senha deve ter pelo menos 6 caracteres';
}
```
Senhas com 6 ou mais caracteres passam; senhas com 5 ou menos são
rejeitadas com a mensagem correta.

**Comportamento com bug:**
```dart
if (value.length < 7) {   // threshold alterado de 6 para 7
  return 'A senha deve ter pelo menos 6 caracteres';
}
```
A mensagem de erro continua dizendo "6 caracteres" mas o limite real
passa a ser 7. Uma senha com exatamente 6 caracteres (ex.: `"abc123"`)
é rejeitada, embora o campo declare aceitá-la.

**Por que é silencioso:** nenhuma exceção; a mensagem exibida parece
correta à primeira vista; o bug só aparece em teste de fronteira com
entrada de 6 chars exatos.

**Risco de confusão:** baixo — sem Firebase; detectável por teste
unitário simples com `validateSenha("abc123")` esperando `null`.

---

## Nível Widget — telas com Firebase injetável (pós-Tarefa 1)

> ⚠️ Estes bugs pressupõem que a Tarefa 1 já foi executada (Firebase
> injetável via construtor). Sem a injeção, o widget test não consegue
> acionar os bugs de forma controlada pois o Firebase real falha antes.

### Candidato W-CRASH — `CriarPlaylistScreen._filterMusicas()` (linha 46)

| Campo | Valor |
|---|---|
| **Arquivo** | `lib/criar_playlist.dart` |
| **Função** | `_filterMusicas()` em `_CriarPlaylistScreenState` |
| **Linha aprox.** | 46 |
| **Tipo** | Crash |

**Comportamento atual (correto):**
```dart
String artistName = musica['artist_name']?.toLowerCase() ?? '';
```
Uso de null-safety (`?.` e `?? ''`): se o documento Firestore não tiver
o campo `artist_name`, o valor é tratado como string vazia.

**Comportamento com bug:**
```dart
String artistName = musica['artist_name'].toLowerCase();
```
Remove o null-safety. Se qualquer documento na coleção `musica` não
tiver o campo `artist_name`, `musica['artist_name']` retorna `null`,
e `.toLowerCase()` lança `NoSuchMethodError` no primeiro keypress da
caixa de pesquisa.

**Por que é crash:** `NoSuchMethodError` não capturado dentro de
`setState(() { ... })` encerra o frame.

**Como acionar no teste:** injetar um `FakeFirebaseFirestore` com ao
menos um documento sem `artist_name` e digitar qualquer caractere na
caixa de pesquisa.

**Risco de confusão:** baixo após Tarefa 1 (Firestore injetável). Sem
injeção, a tela falha em `_fetchMusicas()` antes de chegar ao filtro.

---

### Candidato W-SILENT — `LoginScreen.login()` — mensagens de erro trocadas (linhas 40–43)

| Campo | Valor |
|---|---|
| **Arquivo** | `lib/login.dart` |
| **Função** | função local `login()` dentro de `LoginScreen.build()` |
| **Linhas aprox.** | 40–43 (ramos `user-not-found` e `wrong-password`) |
| **Tipo** | Silencioso |

**Comportamento atual (correto):**
```dart
if (e.code == 'user-not-found') {
  errorMessage = 'Usuário não encontrado. Verifique o e-mail e tente novamente.';
} else if (e.code == 'wrong-password') {
  errorMessage = 'Senha incorreta. Certifique-se de que está digitando a senha corretamente.';
}
```
Cada código de erro do Firebase é mapeado para a mensagem semanticamente
correta.

**Comportamento com bug:** trocar as strings dos dois primeiros ramos:
```dart
if (e.code == 'user-not-found') {
  errorMessage = 'Senha incorreta. Certifique-se de que está digitando a senha corretamente.';
} else if (e.code == 'wrong-password') {
  errorMessage = 'Usuário não encontrado. Verifique o e-mail e tente novamente.';
}
```
O usuário que errou a senha vê "Usuário não encontrado", e vice-versa.
O SnackBar vermelho aparece normalmente — a UX parece funcionar.

**Por que é silencioso:** nenhuma exceção; o fluxo de erro continua
completo (catch → snackbar); a mensagem exibida é plausível para um
erro de login, mas semanticamente errada.

**Como acionar no teste:** injetar `MockFirebaseAuth` configurado para
lançar `FirebaseAuthException(code: 'wrong-password')`, tocar o botão
"Entrar" com campos preenchidos, e verificar que o SnackBar exibe
exatamente `'Senha incorreta...'`. Com o bug, o texto encontrado é
`'Usuário não encontrado...'` — o assert falha.

**Risco de confusão:** baixo. Após Tarefa 1, o `auth` é injetável e o
mock controla o `code` lançado de forma determinística. O teste não
navega de tela nem persiste dado — basta inspecionar o texto do SnackBar.

---

## Nível Integração — fluxos completos

### Candidato I-CRASH — `generos-cadastro.dart._salvarGeneros()` — null assertion em `currentUser!.uid` fora do bloco try (linha 33)

| Campo | Valor |
|---|---|
| **Arquivo** | `lib/generos-cadastro.dart` |
| **Função** | `_salvarGeneros()` em `_GenerosCadastroScreenState` |
| **Linha aprox.** | 33–34 (extração de `uid` antes do bloco `try`) |
| **Tipo** | Crash |

**Comportamento atual (correto):**
```dart
final user = widget.auth.currentUser;
if (user != null) {
  try {
    await widget.firestore.collection('usuarios')
        .doc(user.uid).update({...});
  } catch (e) { ... }
}
```
A guarda `if (user != null)` protege todos os acessos a `user`; o
`try/catch` interno absorve erros do Firestore.

**Comportamento com bug:** substituir o padrão guarda + try pela
extração com `!` antes do try:
```dart
final uid = widget.auth.currentUser!.uid;  // null assertion fora do try
try {
  await widget.firestore.collection('usuarios').doc(uid).update({...});
} catch (e) { ... }
```
Se `currentUser` for `null`, `!.uid` lança
`StateError: Null check operator used on a null value` — exceção que
ocorre **antes** do `try` e propaga sem ser capturada.

**Categoria mecânica:** idêntica à do `formatName` original — acesso a
membro (`uid` / `word[0]`) sem verificar previamente que o receptor está
em estado válido (não-null / não-vazio).

**Como acionar no teste:** injetar `MockFirebaseAuth(signedIn: false)` e
`FakeFirebaseFirestore` em `GenerosCadastroScreen`, selecionar ao menos
um gênero e tocar "Confirmar" → `_confirmar()` chama `_salvarGeneros()`
→ crash. `GenerosCadastroScreen` pode ser montada diretamente no
`pumpWidget`, sem precisar navegar de `CadastroScreen`.

**Risco de confusão:** baixo. Após Tarefa 1, `auth` é injetável e o
mock controla `currentUser` de forma determinística. Não envolve nenhuma
função já usada pelos candidatos aprovados. `generos-cadastro.dart` não
foi alvo de widget test na Fase 1, mas é etapa obrigatória do fluxo de
integração de cadastro.

---

### Candidato I-SILENT — `criar_playlist.dart._salvarPlaylist()` (linha 241)

| Campo | Valor |
|---|---|
| **Arquivo** | `lib/criar_playlist.dart` |
| **Função** | `_salvarPlaylist()` em `_CriarPlaylistScreenState` |
| **Linha aprox.** | 241 |
| **Tipo** | Silencioso |

**Comportamento atual (correto):**
```dart
await widget.firestore.collection('playlists').add({
  'userId': user.uid,
  'nome': _playlistName,          // usa o nome digitado pelo usuário
  'musicas': _musicasSelecionadas,
  'dataCriacao': Timestamp.now(),
});
```
A playlist é salva com o nome que o usuário digitou no campo.

**Comportamento com bug:**
```dart
await widget.firestore.collection('playlists').add({
  'userId': user.uid,
  'nome': 'Nova Playlist',        // hardcoded — ignora o input do usuário
  'musicas': _musicasSelecionadas,
  'dataCriacao': Timestamp.now(),
});
```
Independente do que o usuário digitou, a playlist é salva sempre com
o nome `'Nova Playlist'`. O `Navigator.pop(context)` é chamado
normalmente — nenhuma mensagem de erro, nenhuma indicação visual de
problema.

**Por que é silencioso:** nenhuma exceção; o fluxo completo (digitar
nome → salvar → voltar) aparenta funcionar corretamente.

**Como acionar no teste:** injetar `FakeFirebaseFirestore` + auth com
usuário logado, digitar um nome diferente de `'Nova Playlist'`, salvar, e
inspecionar o documento criado na coleção `playlists` do Firestore fake.

**Risco de confusão:** baixo após Tarefa 1. O `Timestamp.now()` poderia
causar inconsistências em testes determinísticos — recomenda-se verificar
apenas o campo `nome` no assert, ignorando `dataCriacao`.

> **⚠️ Condição fixa de protocolo (I-SILENT):** o cenário de teste deste
> bug **não deve interagir com o campo de pesquisa de músicas**
> (`_searchController`). Digitar nesse campo aciona `_filterMusicas()`,
> onde o bug W-CRASH está injetado — o crash dispararia antes de
> `_salvarPlaylist()` ser alcançado, invalidando o cenário. O teste deve
> preencher apenas o campo de nome da playlist, selecionar músicas pelos
> checkboxes e tocar "Salvar Playlist" sem tocar no campo de busca.

---

## Resumo

| ID | Arquivo | Função | Tipo | Detectável por |
|---|---|---|---|---|
| U-CRASH | `validators.dart` | `capitalize` — remove guarda `if (word.isEmpty)` | Crash | Teste unitário (`capitalize('hello  world')` → `RangeError`) |
| U-SILENT | `validators.dart` | `validateSenha` | Silencioso | Teste unitário (fronteira) |
| W-CRASH | `criar_playlist.dart` | `_filterMusicas` | Crash | Widget test + mock Firestore |
| W-SILENT | `login.dart` | `login()` local — mapeamento de erros | Silencioso | Widget test + mock Auth (código `wrong-password`) |
| I-CRASH | `generos-cadastro.dart` | `_salvarGeneros()` — `currentUser!.uid` fora do try | Crash | Integration test + `MockFirebaseAuth(signedIn: false)` |
| I-SILENT | `criar_playlist.dart` | `_salvarPlaylist` | Silencioso | Integration test + mock Firestore |

---

## Nota de metodologia — U-CRASH como controle esperado

O bug U-CRASH (`capitalize` — remoção da guarda `if (word.isEmpty)`)
**replica deliberadamente o mesmo mecanismo** do bug real identificado
na Fase A em `formatName`:

- `formatName`: nunca teve a guarda `if (word.isEmpty)` — `word[0]`
  em string vazia lança `RangeError` com entradas de espaço múltiplo.
- `capitalize` (Fase A): tinha a guarda e passava em todos os testes.
- `capitalize` (Fase 2, com bug): guarda removida — comportamento agora
  idêntico ao bug já conhecido de `formatName`.

Isso significa que, na análise comparativa, **U-CRASH serve como controle
esperado**, não como achado independente. O modelo que detectar esse bug
estará reconhecendo um padrão que já existia na base de código; o que
é relevante medir é se ele detecta o padrão com a *mesma* eficácia em
`capitalize` versus em `formatName`, e se identifica a assimetria entre
as duas funções.

---

## Nota de metodologia — tratamento dos comentários originais em U-CRASH e U-SILENT

Os comentários originais de documentação em UCRASH e USILENT foram
tratados de forma diferente nos prompts preparados: o comentário de
UCRASH foi removido por revelar a autoria e o propósito do estudo
comparativo (nota de pesquisa vazada para o arquivo de produção); o de
USILENT foi mantido verbatim por representar uma discrepância
doc-vs-código plausível em contexto real, cuja detecção (ou não) pelo
modelo é parte do que está sendo observado. Em nenhum dos dois casos o
arquivo real (validators.dart) foi alterado.

---

## Nota de incidente — bugs U-SILENT/U-CRASH ainda ativos no início das rodadas de controle limpo (2026-09-03)

**O que aconteceu.** As 18 rodadas do piloto (bugs plantados) foram
executadas contra `lib/utils/validators.dart` **com os bugs injetados**, o
que é o esperado. Encerrado o piloto, iniciaram-se as 30 rodadas de
**controle limpo** (10 funções × 3 estratégias) — mas os bugs U-SILENT e
U-CRASH **nunca haviam sido revertidos** no arquivo. A rodada
`FASE2-UNIT-ZS-01_validateNome` não foi afetada (`validateNome` não é alvo
de nenhum bug plantado), porém a rodada seguinte, de `validateSenha`, foi
executada contra o código ainda contendo o U-SILENT (`value.length < 7`).

**Como foi detectado.** Ao consultar
`fase2/Template_Documentacao_Rodada_Fase2.md` para preencher a
documentação, notou-se que a tabela de convenção de IDs lista
`validateSenha` como alvo do U-SILENT — o que levou à conferência do
código-fonte e à confirmação de que o bug seguia ativo, junto com o
U-CRASH em `capitalize`.

**Alcance.** Das 30 rodadas de controle limpo, 6 estariam contaminadas se
o problema não fosse corrigido: `validateSenha` × 3 estratégias
(U-SILENT) e `capitalize` × 3 estratégias (U-CRASH). As outras 8 funções
não são alvo de nenhum bug plantado.

**Como foi resolvido.**

1. A rodada já executada foi **preservada integralmente**, com nomes de
   arquivo que a marcam como fora da contagem oficial:
   `fase2/rodadas/unit/FASE2-VALIDATESENHA-ZS-ACHADO-EXTRA-BUG-ATIVO.md`,
   `test/fase2/unit/validate_senha_zs_ACHADO_EXTRA_BUG_ATIVO_test.dart` e
   `fase2/resultados/unit/zero-shot/FASE2-VALIDATESENHA-ZS-ACHADO-EXTRA-BUG-ATIVO_iter0_final.txt`.
   Ela **não entra na contagem de 30**. Foi mantida porque produziu um
   achado próprio: detecção espontânea do U-SILENT na geração inicial,
   categoria **(C)**, com 10/10 e zero iterações de reparo.
2. Os dois bugs foram revertidos em `lib/utils/validators.dart`:
   `validateSenha` voltou a `value.length < 6` e `capitalize` recuperou a
   guarda `if (word.isEmpty) return word;`.
3. A reversão foi verificada de duas formas:
   `git diff main -- lib/utils/validators.dart` retorna **vazio** (o
   arquivo é byte-idêntico ao estado pré-bugs usado no Estudo 1), e a
   suíte unitária da Fase 1 (`flutter test test/unit/`) passa a aprovar
   todos os testes de `validateSenha` e `capitalize`, incluindo os de
   fronteira de 6 caracteres e os de espaço múltiplo.
4. A rodada oficial `FASE2-UNIT-ZS-02_validateSenha` foi **refeita do
   zero, em conversa nova**, após a reversão.

**Consequência conhecida e aceita.** Os testes do piloto em
`test/fase2/unit/{ucrash,usilent}_*_test.dart` foram escritos contra o
código **com** os bugs e, após a reversão, deixam de passar por
construção. Isso é esperado e **não deve ser "corrigido"**: os resultados
daquelas rodadas já estão arquivados em `fase2/resultados/`, e o estado do
código no momento de cada execução está preservado no histórico do git.
O mesmo vale para o arquivo de teste do achado extra descrito acima.

**Estado dos demais bugs.** Os 4 bugs restantes — W-CRASH e I-SILENT em
`lib/criar_playlist.dart`, W-SILENT em `lib/login.dart`, I-CRASH em
`lib/generos-cadastro.dart` — **seguem ativos** e não foram revertidos,
por não afetarem nenhuma das 30 rodadas de controle limpo, que são todas
unitárias sobre `lib/utils/validators.dart`.

**Achado colateral (pré-existente, não relacionado à Fase 2).** Ao rodar
a suíte da Fase 1 para verificar a reversão, 6 testes de
`test/unit/format_name_cot_test.dart` falham. Não é efeito da reversão:
tanto esse arquivo de teste quanto `validators.dart` são byte-idênticos a
`main`, e o teste é puro (sem Firebase ou dependência externa), logo a
falha existe igualmente no estado `main`. As causas são duas
características **reais e documentadas** de `formatName` — ela preserva a
caixa do restante da palavra (`'joao silva'` → `'JOaO SIlVa'`, e o teste
espera `'Joao Silva'`, semântica de `capitalize`) e nunca teve a guarda
`if (word.isEmpty)`, lançando `RangeError` com espaços múltiplos. O
resultado arquivado em `results/unit/cot/UNIT-COT-08.txt` registra esses
mesmos 8 testes como aprovados, o que indica uma divergência entre o
artefato arquivado e o arquivo de teste hoje versionado na Fase 1. Fica
**registrado sem correção** — mexer nisso alteraria artefatos da Fase 1,
o que o protocolo proíbe.
