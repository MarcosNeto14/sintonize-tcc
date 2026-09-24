# FASE2-WCRASH-COT — Documentação da Rodada

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-WCRASH-COT |
| **Bug ID** | W-CRASH |
| **Função/tela alvo** | `CriarPlaylistScreen` (`_filterMusicas`) |
| **Arquivo(s) de origem** | `lib/criar_playlist.dart` |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | Não verificável (sessão sem login — ver `fase2/rodadas/README.md`); modelo não se autodeclarou nesta rodada |
| **Data de acesso** | 2026-09-02 |
| **Conversa nova?** | Sim — sessão deslogada do ChatGPT, sem histórico prévio (rodada reiniciada do zero após interrupção de sessão anterior por limite de uso, em outra máquina, antes da execução do teste) |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 (channel stable) |

---

## Prompt Enviado

Conforme `fase2/prompts_prontos/FASE2-WCRASH-COT.md` — prompt Chain-of-Thought
pedindo análise do widget em 4 passos (análise, dependências a mockar,
cenários de teste, testes completos) seguido do código completo de
`CriarPlaylistScreen` (com o bug W-CRASH: `_filterMusicas()` acessa
`musica['artist_name'].toLowerCase()` sem null-safety).

---

## Resposta do LLM

### Mensagem inicial (geração dos testes)

Resposta completa e verbatim (extraída via "Copiar resposta" do ChatGPT):

```
Abaixo está uma suíte de widget tests sem alterar o widget de produção. Como o widget não usa HTTP, não há mock de HTTP a configurar. Para o Firestore, FakeFirebaseFirestore é suficiente para os fluxos normais e também permite simular exceções em Query.get/DocumentReference.set; para Auth, MockFirebaseAuth permite controlar currentUser.

1. Análise do widget

CriarPlaylistScreen permite criar uma playlist informando seu nome e selecionando músicas carregadas da coleção musica do Firestore. Há dois campos de texto, uma lista de músicas com botões de seleção, um botão para voltar e o botão Salvar Playlist. A pesquisa filtra as músicas pelo track_name ou artist_name, enquanto a seleção/desseleção é mantida em memória. Ao salvar, o widget obtém o usuário atual do Firebase Auth e grava um documento na coleção playlists; em caso de sucesso, volta para a tela anterior.

2. Dependências que precisam de mock
Firebase Auth: MockFirebaseAuth, com MockUser, para controlar currentUser e seu uid.
Cloud Firestore: FakeFirebaseFirestore, para criar documentos de teste em musica, verificar documentos gravados em playlists e simular falhas de leitura/escrita.
HTTP: não é usado pelo widget, portanto nenhum mock HTTP é necessário.
Mockito: não é necessário para esta implementação, pois firebase_auth_mocks + fake_cloud_firestore cobrem os comportamentos usados. O FakeFirebaseFirestore suporta inclusive exceções artificiais para operações como Query.get e DocumentReference.set.

3. Cenários de teste
Renderização inicial com músicas carregadas.
Renderização com Firestore vazio — o widget permanece exibindo o CircularProgressIndicator, devido à implementação atual.
Nome da playlist vazio → exibe SnackBar.
Nome da playlist preenchido → permite iniciar o salvamento.
Pesquisa por nome da música.
Pesquisa por nome do artista.
Pesquisa sem resultados.
Seleção de uma música.
Desseleção de uma música.
Seleção de várias músicas.
Salvamento completo com usuário autenticado.
Salvamento sem usuário autenticado.
Erro durante o salvamento no Firestore → exibe SnackBar.
Erro ao carregar músicas → o erro é capturado internamente e a UI permanece no estado de carregamento.
Botão voltar → executa Navigator.pop.

4. Testes completos

O arquivo abaixo pode, por exemplo, ser salvo como test/criar_playlist_test.dart.
```

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;

  const editPlaylist = <String, dynamic>{};

  Future<void> seedMusicas(FakeFirebaseFirestore firestore) async {
    await firestore.collection('musica').add({
      'track_name': 'Bohemian Rhapsody',
      'artist_name': 'Queen',
    });
    await firestore.collection('musica').add({
      'track_name': 'Imagine',
      'artist_name': 'John Lennon',
    });
    await firestore.collection('musica').add({
      'track_name': 'Billie Jean',
      'artist_name': 'Michael Jackson',
    });
  }

  Future<void> pumpScreen(
    WidgetTester tester, {
    FakeFirebaseFirestore? customFirestore,
    MockFirebaseAuth? customAuth,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CriarPlaylistScreen(
          editPlaylist: editPlaylist,
          auth: customAuth ?? auth,
          firestore: customFirestore ?? firestore,
        ),
      ),
    );
    // Permite que _fetchMusicas termine e o setState seja processado.
    await tester.pump();
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    final user = MockUser(
      uid: 'user-test-123',
      email: 'teste@sintonize.com',
      displayName: 'Usuário Teste',
    );
    auth = MockFirebaseAuth(signedIn: true, mockUser: user);
  });

  // (11 grupos de testWidgets cobrindo os 15 cenários listados acima:
  //  renderização, validação, pesquisa, seleção de músicas, scroll,
  //  salvamento e erros do Firestore — ver arquivo de teste final em
  //  test/fase2/widget/wcrash_cot_test.dart para o texto corrigido,
  //  e diffs abaixo no repair loop para as versões originais/corrigidas
  //  dos dois testes que precisaram de reparo)
}
```

```
Observação importante sobre o teste de erro do add

Dependendo da versão exata do fake_cloud_firestore instalada no pubspec.yaml, o matcher do Invocation para CollectionReference.add() pode precisar ser ajustado. A própria documentação do pacote confirma que operações do Firestore podem ter exceções simuladas e que o mecanismo usa whenCalling(...).on(...).thenThrow(...).

Também há dois comportamentos do widget que os testes deixam explícitos, em vez de mascará-los:

_playlistName é preenchido pelo campo, mas _salvarPlaylist() grava 'Nova Playlist' fixamente. Portanto, o teste de sucesso verifica 'Nova Playlist', não 'Minha Playlist'.
Uma pesquisa sem resultados produz CircularProgressIndicator, porque build() usa _musicasFiltradas.isEmpty para representar carregamento. Isso significa que "sem resultados" e "carregando" são visualmente indistinguíveis na implementação atual.

Por fim, embora você tenha disponibilizado mockito, ele não é necessário nesta suíte. MockFirebaseAuth fornece o usuário autenticado e FakeFirebaseFirestore é especificamente destinado a testes de UI com Firestore em memória.

Se o projeto estiver usando versões específicas de cloud_firestore/fake_cloud_firestore, vale alinhar as versões compatíveis; por exemplo, a documentação atual do fake_cloud_firestore lista explicitamente a compatibilidade entre suas versões e cloud_firestore.
```

Ver as três respostas de reparo completas na seção "Iterative Repair Loop" abaixo.

**Nota de fidelidade:** o texto acima foi extraído com o botão "Copiar
resposta" do próprio ChatGPT (cópia em Markdown), não por
transcrição manual. O bloco de código Dart completo (814 linhas na
primeira versão) foi condensado nesta seção para legibilidade do
documento — o texto integral de cada teste está no arquivo de teste e
nos diffs da seção de reparo.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou? (1ª tentativa)** | Não — `Invocation.method(#add, {mapa})` é ambíguo (`List` esperado, `Map` literal fornecido) |
| **Testes gerados** | 18 |
| **Testes passaram (após iteração 1 — trocada a técnica de mock)** | 0 (nova falha de compilação) |
| **Testes falharam (após iteração 1)** | 18 (compilação: `whenCalling` não encontrado, import removido por engano) |
| **Testes passaram (após iteração 2 — import restaurado)** | 16 |
| **Testes falharam (após iteração 2)** | 2 (`scroll` frágil; `securityRules` bloqueava o próprio seed) |
| **Testes passaram (após iteração 3 — final, máximo permitido)** | 17 |
| **Testes falharam (após iteração 3 — final)** | 1 (`scrollUntilVisible` com finder incompatível) |

### Saída do terminal (iteração 0 — falha de compilação)

```
test/fase2/widget/wcrash_cot_test.dart:645:13: Error: Both Iterable and Map spread elements encountered in ambiguous literal.
            {
            ^
Compilation failed for testPath=test/fase2/widget/wcrash_cot_test.dart
```

(saída completa em `fase2/resultados/widget/FASE2-WCRASH-COT_iter0.txt`)

### Saída do terminal (iteração 1 — nova falha de compilação)

```
test/fase2/widget/wcrash_cot_test.dart:695:9: Error: Method not found: 'whenCalling'.
        whenCalling(
        ^^^^^^^^^^^
Compilation failed for testPath=test/fase2/widget/wcrash_cot_test.dart
```

(saída completa em `fase2/resultados/widget/FASE2-WCRASH-COT_iter1.txt`)

### Saída do terminal (iteração 2 — 16/18)

```
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Musica 15 - Artista 15": []>
   Which: means none were found but one was expected
...
Exception: Method.write on databases/fake-database/documents/musica/JeGvRUEqAK5xQ8uqIhZm with
context {request: {auth: {uid: user-test-123, ...}}} is not allowed.
```

(saída completa em `fase2/resultados/widget/FASE2-WCRASH-COT_iter2.txt`)

### Saída do terminal (iteração 3 — final, 17/18, máximo de reparos atingido)

```
00:03 +13 -1: CriarPlaylistScreen - scroll deve permitir rolar a lista de músicas [E]
The following _TypeError was thrown running a test:
type 'ListView' is not a subtype of type 'Scrollable' in type cast
...
00:03 +13 -1: CriarPlaylistScreen - salvamento deve salvar a playlist com usuário, nome e músicas selecionadas
00:03 +14 -1: CriarPlaylistScreen - salvamento não deve salvar quando não existe usuário autenticado
00:03 +15 -1: CriarPlaylistScreen - salvamento deve exibir SnackBar quando o Firestore falhar ao salvar
00:03 +16 -1: CriarPlaylistScreen - erros do Firestore deve capturar erro ao buscar músicas sem quebrar a tela
00:03 +17 -1: Some tests failed.
```

(saída completa em `fase2/resultados/widget/FASE2-WCRASH-COT_iter3_final.txt`)

---

## ⚠️ Achado metodológico importante

Assim como em **FASE2-WCRASH-ZS** e **FASE2-WCRASH-FS**, o bug-alvo
W-CRASH (`_filterMusicas()` acessando `musica['artist_name'].toLowerCase()`
sem null-safety) **não foi detectado nem exercitado** nesta rodada. Todas
as músicas seedadas pelo modelo têm `artist_name` preenchido. O modelo
voltou a identificar espontaneamente o bug adjacente do nome hardcoded
(`'nome': 'Nova Playlist'`, alvo de uma rodada futura de I-SILENT),
mantendo a asserção fiel ao comportamento atual sem enfraquecê-la — o
mesmo padrão das duas rodadas W-CRASH anteriores. É a **terceira e
última** rodada W-CRASH, fechando o bloco com 0/3 detecções do bug-alvo
no nível Widget, em forte contraste com a detecção quase universal no
nível Unitário.

Diferente das outras duas rodadas W-CRASH, esta é a **primeira em que o
repair loop se esgota (3 iterações) sem alcançar 100% dos testes
passando**: o teste de scroll permanece falho ao final, por um erro
próprio do modelo (uso de `scrollUntilVisible(..., scrollable: find.byType(ListView))`,
quando a API espera um finder que resolva a um widget `Scrollable`, não
a `ListView` diretamente). Por protocolo (`prompts/PROMPT_TEMPLATES.md`
e `CLAUDE.md`), o teste não foi corrigido manualmente além do limite de
3 iterações — o resultado é registrado como está: **17/18**.

Também vale registrar um segundo desvio de protocolo específico desta
rodada: a rodada original (executada em outra máquina) foi interrompida
pelo limite de uso da sessão logo após a geração do teste, antes de
qualquer execução. Por decisão do autor, a rodada foi **reiniciada do
zero em uma nova conversa** (não uma continuação), já que a conversa
original não era acessível a partir desta máquina — daí a resposta do
LLM aqui documentada ser distinta de qualquer artefato porventura salvo
localmente na máquina de origem.

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** compilação — `Invocation.method(#add, {'userId': ..., 'nome': ..., ...})` passa um `Map` como segundo argumento posicional, que a assinatura de `Invocation.method` espera como `List<dynamic>?`; o compilador relata literal ambíguo entre `Set`/`Map` spread.
- **Prompt de reparo enviado:** erro de compilação colado, conforme template de reparo.
- **Resposta do LLM (completa e verbatim):**

```
Classificação: (A)

A falha é de compilação do teste, não uma evidência de comportamento incorreto da aplicação. O problema está no teste que eu forneci: a tentativa de configurar a exceção do add() usando Invocation.method e um mapa de argumentos tornou o literal ambíguo para o compilador Dart. Além disso, a API documentada do fake_cloud_firestore para exceções cobre DocumentReference.set, update, delete e Query.get, não CollectionReference.add.

Portanto, não devemos enfraquecer nenhum teste funcional da aplicação; devemos corrigir a forma de simular o erro.

Correção

Remova este import:

import 'package:mock_exceptions/mock_exceptions.dart';

E substitua o teste de erro de salvamento que eu havia fornecido por uma abordagem que usa um FakeFirebaseFirestore com regras de segurança para fazer o add() falhar. O pacote documenta que as regras de segurança são aplicadas às operações de escrita e que ele pode ser combinado com MockFirebaseAuth.

Use este teste:

testWidgets(
  'deve exibir SnackBar quando o Firestore falhar ao salvar',
  (tester) async {
    final failingFirestore = FakeFirebaseFirestore(
      securityRules: '''
      service cloud.firestore {
        match /databases/{database}/documents {
          match /musica/{document} {
            allow read: if true;
          }
          match /playlists/{document} {
            allow read: if true;
            allow write: if false;
          }
        }
      }
      ''',
      authObject: auth.authForFakeFirestore,
    );

    await failingFirestore.collection('musica').add({
      'track_name': 'Bohemian Rhapsody',
      'artist_name': 'Queen',
    });

    await pumpScreen(tester, customFirestore: failingFirestore);

    await tester.enterText(
      find.widgetWithText(TextField, 'Nome da Playlist'),
      'Playlist com erro',
    );

    await tester.tap(find.text('Salvar Playlist'));
    await tester.pump();

    expect(find.textContaining('Erro ao salvar a playlist'), findsOneWidget);

    final snapshot = await failingFirestore.collection('playlists').get();
    expect(snapshot.docs, isEmpty);
  },
);

Esse teste continua verificando exatamente o comportamento importante: com usuário autenticado e nome válido, uma falha do Firestore durante o salvamento deve produzir o SnackBar de erro e não criar a playlist.

Há ainda uma segunda correção importante na suíte original: o teste de erro ao carregar músicas usando whenCalling(...).on(query).thenThrow(...) é suportado, porque Query.get está explicitamente entre as operações para as quais fake_cloud_firestore permite mock de exceções. Portanto, esse teste pode permanecer como estava.

Em resumo: a classificação é A, e o comportamento da aplicação coberto pelo teste de erro de salvamento permanece sendo testado; apenas a técnica inválida de mocking foi substituída.
```

- **Resultado:** nova falha de compilação — o modelo instruiu remover o import de `mock_exceptions`, mas o próprio parágrafo final da mesma resposta afirma que o *outro* teste (erro ao buscar músicas) que também usa `whenCalling` "pode permanecer como estava" — uma contradição interna. Sem o import, esse segundo uso deixou de compilar.

### Iteração 2

- **Motivo da falha:** `Method not found: 'whenCalling'` — consequência direta da contradição da iteração 1 (import removido, mas ainda referenciado).
- **Prompt de reparo enviado:** novo erro de compilação colado, com nota explícita apontando a contradição na resposta anterior.
- **Resposta do LLM (completa e verbatim):**

```
Classificação: (A)

A falha é causada pela alteração do próprio teste: whenCalling pertence ao pacote mock_exceptions, cujo import foi removido. Isso não indica comportamento incorreto do CriarPlaylistScreen.

Minha orientação anterior foi incorreta ao dizer para remover o import globalmente. O import deve permanecer, porque o teste de falha do Query.get() ainda utiliza whenCalling.

Correção

Restaure:

import 'package:mock_exceptions/mock_exceptions.dart';

O teste de carregamento pode permanecer assim:

testWidgets(
  'deve capturar erro ao buscar músicas sem quebrar a tela',
  (tester) async {
    final musicaQuery = firestore.collection('musica');

    whenCalling(
      Invocation.method(#get, null),
    ).on(musicaQuery).thenThrow(
      FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'Falha de rede',
      ),
    );

    await pumpScreen(tester);

    expect(find.text('Criando Playlist'), findsOneWidget);
    expect(find.text('Nome da Playlist'), findsOneWidget);
    expect(find.text('Salvar Playlist'), findsOneWidget);

    // O widget captura a exceção em _fetchMusicas().
    // Como a lista permanece vazia, a implementação atual
    // exibe o CircularProgressIndicator.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  },
);

Não é necessário alterar a asserção desse teste. Ele está verificando um comportamento real do código: _fetchMusicas() captura a exceção e não apresenta nenhum SnackBar ou outro estado de erro; a lista permanece vazia e, pela condição existente em build(), isso resulta no CircularProgressIndicator.

A distinção importante é que o teste de Query.get() usa mock_exceptions, enquanto a abordagem que eu sugeri posteriormente para provocar falha no add() não deve depender daquele whenCalling com o literal ambíguo.
```

- **Resultado:** compilou; 16/18 passaram. 2 falharam:
  1. `deve permitir rolar a lista de músicas` — `drag(listView, Offset(0,-500))` seguido de busca por `'Musica 15 - Artista 15'` não encontrou o widget (asserção frágil, dependente da geometria exata do scroll).
  2. `deve exibir SnackBar quando o Firestore falhar ao salvar` — a própria chamada de seed (`failingFirestore.collection('musica').add(...)`) foi bloqueada pelas `securityRules`, que só permitiam `read` em `musica` (sem `write`), lançando exceção antes mesmo do cenário de falha em `playlists` ser exercitado.

### Iteração 3 (final — máximo permitido)

- **Motivo da falha:** dois testes com problemas distintos, ambos no próprio teste (não na aplicação): asserção de scroll frágil e regra de segurança bloqueando o setup do próprio teste.
- **Prompt de reparo enviado:** as duas falhas coladas juntas, pedindo classificação individual para cada uma, com nota de que esta era a última iteração permitida.
- **Resposta do LLM (completa e verbatim):**

```
Classificação

Teste "deve permitir rolar a lista de músicas" — (A)
O teste presume que um drag de exatamente -500 pixels fará o item 15 ficar visível. Isso não é garantido: a posição final depende da altura real dos ListTiles, viewport e física de scroll. O comportamento esperado da aplicação — permitir rolagem — está correto; a asserção específica sobre o item 15 é que é frágil.

Teste "deve exibir SnackBar quando o Firestore falhar ao salvar" — (A)
O problema está no próprio teste: configuramos regras que bloqueiam todas as escritas em musica, mas depois tentamos inserir os dados de preparação justamente nessa coleção. O cenário pretendido é bloquear a escrita em playlists, permitindo normalmente a preparação dos dados em musica. Não há evidência de problema na aplicação.

Correções
1. Teste de scroll

Em vez de assumir que -500 coloca especificamente o item 15 na viewport, podemos verificar o efeito que realmente interessa: depois de rolar, um item que inicialmente está fora da viewport torna-se visível.

Uma maneira mais determinística é rolar para o final usando scrollUntilVisible:

testWidgets(
  'deve permitir rolar a lista de músicas',
  (tester) async {
    for (var i = 0; i < 30; i++) {
      await firestore.collection('musica').add({
        'track_name': 'Musica $i',
        'artist_name': 'Artista $i',
      });
    }

    await pumpScreen(tester);

    final listView = find.byType(ListView);
    expect(listView, findsOneWidget);

    // O item 29 começa fora da viewport.
    expect(find.text('Musica 29 - Artista 29'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Musica 29 - Artista 29'),
      300,
      scrollable: listView,
    );

    await tester.pump();

    expect(find.text('Musica 29 - Artista 29'), findsOneWidget);
  },
);

Isso testa diretamente a capacidade de scroll da lista, sem depender de uma distância arbitrária de 500 pixels.

2. Teste de falha ao salvar

Aqui precisamos deixar musica gravável durante o setup e bloquear somente playlists.

Substitua o teste anterior inteiro por:

testWidgets(
  'deve exibir SnackBar quando o Firestore falhar ao salvar',
  (tester) async {
    final failingFirestore = FakeFirebaseFirestore(
      securityRules: '''
      service cloud.firestore {
        match /databases/{database}/documents {
          match /musica/{document} {
            allow read, write: if true;
          }
          match /playlists/{document} {
            allow read: if true;
            allow write: if false;
          }
        }
      }
      ''',
      authObject: auth.authForFakeFirestore,
    );

    // Setup: a coleção de músicas precisa aceitar escrita.
    await failingFirestore.collection('musica').add({
      'track_name': 'Bohemian Rhapsody',
      'artist_name': 'Queen',
    });

    await pumpScreen(tester, customFirestore: failingFirestore);

    await tester.enterText(
      find.widgetWithText(TextField, 'Nome da Playlist'),
      'Playlist com erro',
    );

    await tester.tap(find.text('Salvar Playlist'));
    await tester.pump();

    // O add() em playlists deve falhar e _salvarPlaylist()
    // deve exibir o SnackBar correspondente.
    expect(find.textContaining('Erro ao salvar a playlist'), findsOneWidget);

    // Confirma que nenhuma playlist foi criada.
    final snapshot = await failingFirestore.collection('playlists').get();
    expect(snapshot.docs, isEmpty);
  },
);

Resultado esperado

Com essas duas alterações: o teste de scroll deixa de depender da geometria específica dos ListTile; o teste de erro consegue preparar os dados normalmente em musica; somente a operação que queremos fazer falhar — playlists.add() — é bloqueada; nenhuma asserção sobre o comportamento da aplicação foi enfraquecida.

Assim, esses dois testes continuam cobrindo integralmente os cenários originais, mas deixam de depender de premissas frágeis do ambiente de teste.
```

- **Resultado:** 17/18. O teste de `SnackBar` do Firestore foi corrigido com sucesso pela mudança da regra de segurança. O teste de scroll, porém, **continuou falhando** — desta vez com um erro diferente e não previsto pelo modelo: `type 'ListView' is not a subtype of type 'Scrollable' in type cast`, porque `scrollUntilVisible` espera que o parâmetro `scrollable` resolva a um widget `Scrollable`, e `find.byType(ListView)` resolve ao `ListView` em si, não ao `Scrollable` que ele constrói internamente. **Esta era a 3ª e última iteração permitida — o resultado final desta rodada é 17/18, com o teste de scroll registrado como falho, sem correção adicional.**

---

## ★ Análise de Autoclassificação (preencher após a rodada)

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) em todas as 3 iterações — falhas de teste/geração (literal ambíguo; import removido por engano/contradição interna; asserção de scroll frágil e regra de segurança mal desenhada), nunca bugs de aplicação |
| **★ Classificação humana (auditoria)** | Erro de geração (iterações 1 e 2 — uso indevido de `Invocation.method`, e uma contradição interna do próprio modelo sobre remover ou não um import) / Erro de teste (iteração 3 — asserção de scroll frágil e regra de segurança incompleta) |
| **★ Concordância** | Concorda quanto à causa raiz de cada falha, mas o modelo **não previu corretamente sua própria correção** duas vezes seguidas: (a) na iteração 1, instruiu remover um import que sua própria resposta reconhecia ser necessário em outro teste; (b) na iteração 3, propôs `scrollUntilVisible(scrollable: find.byType(ListView))`, que não compila/executa como esperado (`ListView` não é `Scrollable`) |
| **★ Observações** | Rodada esgotou as 3 iterações de reparo permitidas **sem atingir 100%** — resultado final documentado como 17/18, conforme protocolo (não há correção manual além do limite). Assim como em WCRASH-ZS e WCRASH-FS, o bug-alvo W-CRASH não foi detectado nem exercitado; o modelo voltou a identificar espontaneamente o bug do nome hardcoded, mantendo a asserção fiel ao código atual. Diferente das rodadas anteriores da família W-CRASH, aqui o próprio processo de reparo introduziu uma contradição interna (iteração 1) e uma correção comprovadamente incorreta (iteração 3), sugerindo que o modelo tem dificuldade em rastrear o estado completo do arquivo de teste ao longo de múltiplas iterações de reparo — um achado metodológico relevante para a comparação entre estratégias de prompt na Fase 2. |

**Referência de categorias (classificação humana — mesmas da Fase 1):**

| Categoria | Definição |
|---|---|
| Erro de teste | O teste está errado — asserção incorreta, setup inadequado, expectativa inválida |
| Bug real exposto | O teste capturou corretamente um comportamento incorreto da aplicação |
| Erro de geração | O LLM gerou código que não compila ou que testa algo diferente do pedido |
| Limitação de testabilidade | O comportamento não é testável da forma solicitada (ex.: dependência não mockável) |
| Ambíguo | Não é possível determinar com certeza qual das categorias acima se aplica |
| Falha de ambiente | Problema de configuração, versão de dependência, ou ambiente de execução |
