# Propostas de Bugs Propositais — Fase 2

**Status:** proposta para revisão humana — nenhum bug foi implementado.  
**Decisão de implementação:** do autor do TCC e do orientador, não automática.  
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

### Candidato U-CRASH — `validateNumero` (linha 76)

| Campo | Valor |
|---|---|
| **Arquivo** | `lib/utils/validators.dart` |
| **Função** | `validateNumero(String? value)` |
| **Linha aprox.** | 76 |
| **Tipo** | Crash |

**Comportamento atual (correto):**
```dart
if (int.tryParse(value) == null) {
  return 'O número deve ser numérico';
}
```
`int.tryParse` retorna `null` em vez de lançar exceção quando o valor não
é um inteiro. A função nunca crasha.

**Comportamento com bug:**
```dart
int.parse(value);  // substitui tryParse por parse
```
`int.parse` lança `FormatException` para entradas não numéricas (ex.:
`"abc"`, `"12.5"`, `""`). A exceção não é capturada — propaga para cima
e mata o frame de renderização.

**Por que é crash:** `FormatException` é exceção de runtime não tratada;
o validador é chamado dentro de um `TextFormField.validator`, que não tem
try/catch por padrão.

**Risco de confusão:** baixo — sem dependência de Firebase; o crash é
reproduzível de forma totalmente determinística por um teste unitário.

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

---

## Resumo

| ID | Arquivo | Função | Tipo | Detectável por |
|---|---|---|---|---|
| U-CRASH | `validators.dart` | `validateNumero` | Crash | Teste unitário |
| U-SILENT | `validators.dart` | `validateSenha` | Silencioso | Teste unitário (fronteira) |
| W-CRASH | `criar_playlist.dart` | `_filterMusicas` | Crash | Widget test + mock Firestore |
| W-SILENT | `login.dart` | `login()` local — mapeamento de erros | Silencioso | Widget test + mock Auth (código `wrong-password`) |
| I-CRASH | `generos-cadastro.dart` | `_salvarGeneros()` — `currentUser!.uid` fora do try | Crash | Integration test + `MockFirebaseAuth(signedIn: false)` |
| I-SILENT | `criar_playlist.dart` | `_salvarPlaylist` | Silencioso | Integration test + mock Firestore |

**Próximo passo:** o autor do TCC e o orientador selecionam quais bugs
entram na Fase 2 (plano prevê ~1/3 dos alvos). Após aprovação, a
implementação pode ser feita em commits atômicos e revertidos facilmente.
