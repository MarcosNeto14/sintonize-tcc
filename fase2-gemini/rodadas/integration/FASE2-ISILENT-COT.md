# FASE2-ISILENT-COT — Réplica Gemini

Rodada **18/60**. Fecha o bloco I-SILENT e o bloco 1 (bugs plantados).
Execução automatizada (Claude in Chrome), como a 17; respostas integrais no
Apêndice.

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE2-ISILENT-COT |
| **Bug ID** | I-SILENT |
| **Função/tela alvo** | `CriarPlaylistScreen._salvarPlaylist` |
| **Arquivo(s) de origem** | `lib/criar_playlist.dart` |
| **Nível da pirâmide** | Integração |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | Gemini |
| **Versão do modelo** | **3.8 Flash** |
| **✦ Modelo declarado pelo Gemini** | Não declara. Pergunta aposentada. |
| **✦ Verificação externa da versão** | Seletor aberto antes do envio: `3.8 Flash` marcado. |
| **Data de acesso** | 2026-09-22 |
| **Conversa nova?** | Sim — `gemini.google.com/app/8a01058cbb3e0d56` |
| **Sessão** | Com login, conta Gemini Pro |
| **Branch / estado do código** | `fase2-gemini-piloto`, I-SILENT ativo |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 (stable) · Dart 3.11.4 |
| **Arquivo de teste** | `test/fase2-gemini/integration/isilent_cot_test.dart` |
| **Saídas arquivadas** | `resultados/integration/FASE2-ISILENT-COT_iter{0,1}.txt` |
| **Modo de execução** | **Automatizado** (Claude in Chrome + clipboard) |
| **Versão do prompt** | Original, de `prompts_prontos/FASE2-ISILENT-COT.md`, sem alteração |

**Bug plantado:** `'nome': 'Nova Playlist'` fixo em `_salvarPlaylist`
(`lib/criar_playlist.dart:251`).

**Condição de protocolo (campo de pesquisa):** respeitada.

---

## Resposta do LLM — geração inicial

Seguiu os 5 passos do CoT. **A resposta veio duplicada:** uma primeira
versão completa até o passo 5, cortada no início do código, e em seguida a
resposta inteira recomeçada. Usado o bloco de código final, o único completo
(mesmo fenômeno das iterações 1 da rodada 17 e 1 desta).

4 testes: fluxo de sucesso com verificação de `Navigator.pop`, nome vazio,
usuário não autenticado e "Integridade: dados persistidos na coleção
'playlists' possuem esquema exato". Import da tela correto.

**O quarto teste canoniza o bug de forma explícita:**

```dart
await tester.enterText(nomeField, 'Trilha Sonora');
...
expect(docData['nome'], equals('Nova Playlist')); // Conforme implementado na tela
```

O teste digita um nome e exige que o gravado seja outro. Na lista de
cenários (passo 4), duas vezes:

> "Validação estrita do payload salvo no documento (campos `userId`, `nome`,
> `musicas` e `dataCriacao`), observando a implementação da tela (que grava
> fixo `'Nova Playlist'` conforme o código fornecido)."

> "*Nota técnica de implementação:* O código da tela possui o valor literal
> `'nome': 'Nova Playlist'` fixado no método `_salvarPlaylist()`. O teste
> assegura que o documento persistido reflete fielmente as chaves e valores
> gravados pela implementação atual."

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou na 1ª execução?** | **Não** — `'FirebaseAuth' isn't a type` (faltou o import de `firebase_auth`) |
| **Testes gerados** | 4 |
| **Testes passaram (1ª execução)** | 0 |
| **Iterações de reparo** | **1** |
| **Testes passaram (pós-repair)** | **4** |
| **Testes falharam (pós-repair)** | **0** |
| **Tentativas de envio até obter resposta** | 1 por mensagem |
| **Bug plantado capturado por asserção?** | **Não — canonizado.** `expect(docData['nome'], equals('Nova Playlist'))` |
| **Bug plantado mencionado na resposta?** | **Sim**, duas vezes, como "nota técnica de implementação" |

---

## Iterative Repair Loop

### Iteração 1

- **Motivo:** `'FirebaseAuth' isn't a type` na assinatura de
  `buildTestableWidget`.
- **★ Autoclassificação:** **(A)**, correta.
- **Resposta anômala, de novo:** reescreve o arquivo inteiro com o import
  adicionado, **corta no meio** (`snapshot.docs.first.data`) e recomeça só
  com instruções — adicionar o import, conferir `pubspec.yaml`, rodar
  `flutter pub get`.
- **Aplicado:** a única mudança concreta, o import
  `package:firebase_auth/firebase_auth.dart`, no arquivo da iteração 0
  (regra definida com o Marcos na rodada 17).
- **Resultado:** **4/4.**
- Saída: `FASE2-ISILENT-COT_iter1.txt`

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(A)** |
| **★ Classificação humana (auditoria)** | **Erro de teste** — correta |
| **★ Concordância** | **Sim** |

### Observações

1. **A canonização mais explícita da réplica.** Nas rodadas 16 e 17 o
   modelo viu o bug e deixou a asserção de fora. Aqui, com o CoT pedindo
   "cenários" e "validação estrita", ele escreveu a asserção — no sentido
   errado. Consertar `_salvarPlaylist` para gravar o nome digitado quebra o
   teste "Integridade". A suíte verde protege o defeito.
2. **O I-SILENT foi o bug mais visto e o menos pego.** Mencionado nas três
   estratégias; capturado em nenhuma. ZS e FS omitiram a asserção, COT a
   inverteu. É a confirmação mais direta do achado de que o modelo trata o
   código recebido como especificação: visibilidade do defeito não basta
   quando nada no material diz qual é o comportamento pretendido — nem o
   nome do campo, nem o `enterText` do próprio teste.
3. **Resposta duplicada/truncada virou padrão desta sessão** (17-iter1,
   18-iter0, 18-iter1): o Gemini começa a resposta, corta e recomeça. O
   texto copiado traz as duas partes; o doc registra ambas.

---

## Apêndice — respostas integrais (via "Copiar resposta")


### Resposta da geração inicial

````markdown
Aqui está a análise completa do fluxo seguida pelos testes de integração para o aplicativo Flutter **Sintonize**.

---

### 1. Análise do Fluxo

O fluxo inicia com a renderização da tela `CriarPlaylistScreen`, que carrega no `initState` as faixas disponíveis a partir da coleção `musica` no Firestore e exibe uma lista pesquisável. O usuário interage definindo um nome no campo de texto e marcando/desmarcando faixas via botão com ícone de caixa de seleção. O ponto de decisão principal ocorre ao acionar o botão "Salvar Playlist": se o campo do nome estiver nulo ou vazio, um `SnackBar` com mensagem de erro é exibido e a ação é interrompida. Havendo nome preenchido, o método verifica se existe um usuário autenticado (`currentUser != null`): caso exista, persiste o documento na coleção `playlists` e fecha a tela atual através de `Navigator.pop(context)`; se não houver usuário autenticado, a execução silenciosamente não salva nem navega.

---

### 2. Identificação das Dependências

* **Cloud Firestore (`FirebaseFirestore`):** Acionado para carregar faixas (`collection('musica').get()`) e persistir novas playlists (`collection('playlists').add(...)`). É instanciado via `FakeFirebaseFirestore` do pacote `fake_cloud_firestore`, o qual simula o banco de dados NoSQL em memória de forma declarativa.
* **Firebase Auth (`FirebaseAuth`):** Acionado na consulta da propriedade `widget.auth.currentUser` para obter o `uid`. É mockado via `MockFirebaseAuth(signedIn: true/false, mockUser: MockUser(...))` do pacote `firebase_auth_mocks`.
* **Navegação (`Navigator`):** O método `Navigator.pop(context)` é chamado após o salvamento bem-sucedido. Pode ser verificado observando a pilha do `Navigator` ou utilizando um `NavigatorObserver` mockado com `mockito`.

---

### 3. Estrutura de Navegação

Para que os testes funcionem isoladamente e permitam a verificação de `Navigator.pop()`, encapsula-se a tela em um `MaterialApp` configurado com rotas ou com uma rota base:

```dart
await tester.pumpWidget(
  MaterialApp(
    home: Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CriarPlaylistScreen(
              editPlaylist: const {},
              auth: mockAuth,
              firestore: fakeFirestore,
            ),
          ),
        ),
        child: const Text('Abrir'),
      ),
    ),
  ),
);

```

Ao disparar o push e abrir a `CriarPlaylistScreen`, o posterior chamado de `Navigator.pop(context)` retorna à tela anterior, facilitando verificar se a tela foi devidamente fechada (`find.byType(CriarPlaylistScreen)` passa a encontrar 0 widgets).

---

### 4. Cenários de Teste

1. **Fluxo de Sucesso Ponta a Ponta:** Usuário logado preenche o nome da playlist, seleciona uma música, clica em salvar, a playlist é gravada no Firestore e a tela é fechada (`Navigator.pop`).
2. **Nome de Playlist Vazio:** Usuário clica em "Salvar Playlist" com o campo em branco. O sistema exibe o `SnackBar` com o texto `'Nome da playlist é obrigatório'` e nenhum documento é salvo.
3. **Usuário Não Autenticado:** Usuário sem sessão ativa (`currentUser == null`) preenche o nome e clica em salvar. O sistema não persiste nenhum registro no Firestore e não realiza o `pop` da tela.
4. **Verificação dos Dados Persistidos na Coleção `'playlists'`:** Validação estrita do payload salvo no documento (campos `userId`, `nome`, `musicas` e `dataCriacao`), observando a implementação da tela (que grava fixo `'Nova Playlist'` conforme o código fornecido).

---

### 5. Código dos Testes

Crie o arquivo de teste (por exemplo, `test/criar_playlist_test.dart`):

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();

    // Popula a coleção 'musica' para permitir seleção nas telas
    await fakeFirestore.collection('musica').add({
      'track_name': 'bohemian rhapsody',
      'artist_name': 'queen',
    });
    await fakeFirestore.collection('musica').add({
      'track_name': 'hotel california',
      'artist_name': 'eagles',
    });
  });

  Widget buildTestableWidget({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            key: const Key('btn_abrir_tela'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CriarPlaylistScreen(
                    editPlaylist: const {},
                    auth: auth,
                    firestore: firestore,
                  ),
                ),
              );
            },
            child: const Text('Abrir Criar Playlist'),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'Cenário 1: Fluxo de sucesso ponta a ponta - digita nome, seleciona música, salva e fecha a tela',
    (WidgetTester tester) async {
      mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user_123', email: 'user@sintonize.com'),
      );

      await tester.pumpWidget(
        buildTestableWidget(auth: mockAuth, firestore: fakeFirestore),
      );

      // Abre a tela empilhando na rota
      await tester.tap(find.byKey(const Key('btn_abrir_tela')));
      await tester.pumpAndSettle();

      expect(find.byType(CriarPlaylistScreen), findsOneWidget);
      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);

      // 1. Digita o nome da playlist
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'Minha Playlist Favorita');
      await tester.pumpAndSettle();

      // 2. Seleciona a primeira música
      final selectButtons = find.byIcon(Icons.check_box_outline_blank);
      expect(selectButtons, findsWidgets);
      await tester.tap(selectButtons.first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_box), findsOneWidget);

      // 3. Clica em "Salvar Playlist"
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar Playlist'));
      await tester.pumpAndSettle();

      // 4. Verifica se a tela foi fechada (Navigator.pop funcionou)
      expect(find.byType(CriarPlaylistScreen), findsNothing);

      // 5. Verifica se o documento foi persistido no Firestore
      final playlistsSnapshot =
          await fakeFirestore.collection('playlists').get();
      expect(playlistsSnapshot.docs.length, 1);
      expect(playlistsSnapshot.docs.first.get('userId'), 'user_123');
      expect(
        playlistsSnapshot.docs.first.get('musicas'),
        contains('bohemian rhapsody'),
      );
    },
  );

  testWidgets(
    'Cenário 2: Validação de campo obrigatório - exibe SnackBar e não salva quando o nome for vazio',
    (WidgetTester tester) async {
      mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'user_123'),
      );

      await tester.pumpWidget(
        buildTestableWidget(auth: mockAuth, firestore: fakeFirestore),
      );

      await tester.tap(find.byKey(const Key('btn_abrir_tela')));
      await tester.pumpAndSettle();

      // Tenta salvar sem preencher o nome da playlist
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar Playlist'));
      await tester.pump(); // Inicia animação do SnackBar

      // Verifica exibição da mensagem de validação
      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);

      // Garante que nenhum registro foi gravado
      final playlistsSnapshot =
          await fakeFirestore.collection('playlists').get();
      expect(playlistsSnapshot.docs.isEmpty, isTrue);

      // Garante que a tela continua aberta
      expect(find.byType(CriarPlaylistScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Cenário 3: Usuário não autenticado - não persiste dados e não navega',
    (WidgetTester tester) async {
      // Usuário deslogado (currentUser == null)
      mockAuth = MockFirebaseAuth(signedIn: false);

      await tester.pumpWidget(
        buildTestableWidget(auth: mockAuth, firestore: fakeFirestore),
      );

      await tester.tap(find.byKey(const Key('btn_abrir_tela')));
      await tester.pumpAndSettle();

      // Digita o nome da playlist
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'Playlist Anônima');
      await tester.pumpAndSettle();

      // Clica em salvar
      await tester.tap(find.widgetWithText(ElevatedButton, 'Salvar Playlist'));
      await tester.pumpAndSettle();

      // Não deve salvar no Firestore
      final playlistsSnapshot =
          await fakeFirestore.collection('playlists').get();
      expect(playlistsSnapshot.docs.isEmpty, isTrue);

      // Deve permanecer na mesma tela
      expect(find.byType(CriarPlaylistScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Cenário 4: Verificação detalhada da estrutura e conteúdo persistido na coleção "playlists"',
    (WidgetTester tester) async {
      const testUid = 'user_sintonize_99';
      mockAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: testUid),
      );

      await tester.pumpWidget(
        buildTestableWidget(auth: mockAuth, fire### 1. Análise do Fluxo

O fluxo ocorre inteiramente na tela `CriarPlaylistScreen`. Ao ser inicializada, a tela consome a coleção `musica` no Firestore e exibe os itens em uma lista rolável (ou um `CircularProgressIndicator` enquanto carrega ou se vazia). O usuário insere um nome de playlist no primeiro campo de texto e seleciona faixas clicando no botão de alternância do item. No ponto de decisão de salvamento (ao tocar em "Salvar Playlist"), se o nome estiver vazio ou nulo, o fluxo é interrompido com uma `SnackBar` de erro. Se houver nome válido e o usuário estiver autenticado, a tela persiste o documento na coleção `playlists` e aciona `Navigator.pop(context)`; se o usuário for nulo, a operação de salvamento é silenciosamente ignorada e a tela permanece aberta.

---

### 2. Identificação de Dependências e Estratégia de Mocking

* **FirebaseFirestore:** Acionado em `widget.firestore.collection('musica').get()` e `widget.firestore.collection('playlists').add(...)`. Será mockado utilizando a instância em memória fornecida por `FakeFirebaseFirestore()`. Isso permite pré-popular dados de teste em `musica` e inspecionar os documentos gerados em `playlists`.
* **FirebaseAuth:** Acionado em `widget.auth.currentUser`. Será mockado via `MockFirebaseAuth(signedIn: true/false, mockUser: MockUser(...))`, permitindo simular tanto sessões ativas com `uid` específico quanto sessões nulas (deslogadas).
* Ambas as dependências são injetadas diretamente via construtor do `CriarPlaylistScreen(auth: ..., firestore: ...)`.

---

### 3. Estrutura de Navegação para Testes

Para garantir que o `Navigator.pop(context)` e os `SnackBar`s funcionem sem falhas no ambiente de teste, o widget sob teste deve ser encapsulado em um `MaterialApp` com suporte a histórico de rotas. 

Utiliza-se a propriedade `routes` ou a navegação manual via `NavigatorObserver` mockado/espião. A estratégia mais limpa e robusta em Flutter é definir uma rota inicial simulada (ex: `/home`) contendo um botão que empurra (`Navigator.pushNamed`) a tela sob teste. Assim, quando o código invocar `Navigator.pop(context)`, a pilha desce corretamente para a tela anterior, permitindo verificar que `CriarPlaylistScreen` foi desempilhada.

---

### 4. Cenários de Teste

1. **Fluxo de sucesso ponta a ponta:** Usuário autenticado preenche o nome da playlist, seleciona uma música da lista recuperada do Firestore, clica em "Salvar Playlist", a tela é fechada (`Navigator.pop`) e o documento correspondente é inserido na coleção `playlists`.
2. **Nome de playlist vazio:** Usuário autenticado deixa o campo de nome vazio e clica em salvar. O sistema exibe o `SnackBar` com o texto `'Nome da playlist é obrigatório'`, nenhuma inserção ocorre na coleção `playlists` e a tela não é fechada.
3. **Usuário não autenticado:** Usuário não logado (`currentUser == null`) preenche o nome, clica em salvar, nenhuma gravação é feita no Firestore e a tela permanece ativa.
4. **Verificação exata dos dados persistidos:** Validação estrita do payload salvo em `playlists` (`userId`, `nome`, lista `musicas` e presença de `dataCriacao` do tipo `Timestamp`). *Nota técnica de implementação:* O código da tela possui o valor literal `'nome': 'Nova Playlist'` fixado no método `_salvarPlaylist()`. O teste assegura que o documento persistido reflete fielmente as chaves e valores gravados pela implementação atual.

---

### 5. Código dos Testes de Integração

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser testUser;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    testUser = MockUser(
      uid: 'user_123_abc',
      email: 'user@sintonize.com',
      displayName: 'Marcos Neto',
    );
    mockAuth = MockFirebaseAuth(mockUser: testUser, signedIn: true);

    // Popula o banco falso com músicas de teste
    await fakeFirestore.collection('musica').add({
      'track_name': 'Bohemian Rhapsody',
      'artist_name': 'Queen',
    });
    await fakeFirestore.collection('musica').add({
      'track_name': 'Hotel California',
      'artist_name': 'Eagles',
    });
  });

  Widget buildTestableWidget({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CriarPlaylistScreen(
                      editPlaylist: const {},
                      auth: auth,
                      firestore: firestore,
                    ),
                  ),
                );
              },
              child: const Text('Abrir Criar Playlist'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'Fluxo de sucesso: preencher nome, selecionar música, salvar e desempilhar tela',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(auth: mockAuth, firestore: fakeFirestore),
      );

      // Abre a tela via navegação
      await tester.tap(find.text('Abrir Criar Playlist'));
      await tester.pumpAndSettle();

      expect(find.byType(CriarPlaylistScreen), findsOneWidget);
      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);

      // 1. Digita o nome da playlist
      final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
      await tester.enterText(nomeField, 'Minhas Favoritas');
      await tester.pumpAndSettle();

      // 2. Seleciona a primeira música da lista
      final checkboxButtons = find.byIcon(Icons.check_box_outline_blank);
      expect(checkboxButtons, findsWidgets);
      await tester.tap(checkboxButtons.first);
      await tester.pumpAndSettle();

      // Verifica se o ícone mudou para selecionado
      expect(find.byIcon(Icons.check_box), findsOneWidget);

      // 3. Salva a playlist
      final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.tap(salvarButton);
      await tester.pumpAndSettle();

      // Verifica se a tela foi fechada (Navigator.pop)
      expect(find.byType(CriarPlaylistScreen), findsNothing);
      expect(find.text('Abrir Criar Playlist'), findsOneWidget);

      // 4. Verifica persistência no Firestore
      final snapshot = await fakeFirestore.collection('playlists').get();
      expect(snapshot.docs.length, 1);
      final data = snapshot.docs.first.data();
      expect(data['userId'], 'user_123_abc');
      expect(data['musicas'], contains('Bohemian Rhapsody'));
    },
  );

  testWidgets(
    'Validação: nome vazio exibe SnackBar de erro e não persiste dados',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(auth: mockAuth, firestore: fakeFirestore),
      );

      await tester.tap(find.text('Abrir Criar Playlist'));
      await tester.pumpAndSettle();

      // Deixa o nome da playlist em branco e aciona o salvamento
      final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.tap(salvarButton);
      await tester.pump(); // Dispara a exibição da SnackBar

      // Validações da interface
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);
      expect(find.byType(CriarPlaylistScreen), findsOneWidget);

      // Validação do banco: nenhum registro deve ser criado
      final snapshot = await fakeFirestore.collection('playlists').get();
      expect(snapshot.docs, isEmpty);
    },
  );

  testWidgets(
    'Segurança: usuário não autenticado não salva registro nem fecha tela',
    (WidgetTester tester) async {
      final unauthenticatedAuth = MockFirebaseAuth(signedIn: false);

      await tester.pumpWidget(
        buildTestableWidget(auth: unauthenticatedAuth, firestore: fakeFirestore),
      );

      await tester.tap(find.text('Abrir Criar Playlist'));
      await tester.pumpAndSettle();

      // Preenche o nome para passar pela primeira barreira de validação
      final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
      await tester.enterText(nomeField, 'Rock Clássico');
      await tester.pumpAndSettle();

      // Clica em salvar
      final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.tap(salvarButton);
      await tester.pumpAndSettle();

      // Confirma que nenhuma playlist foi gerada no Firestore
      final snapshot = await fakeFirestore.collection('playlists').get();
      expect(snapshot.docs, isEmpty);

      // Confirma que a tela continua ativa
      expect(find.byType(CriarPlaylistScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Integridade: dados persistidos na coleção "playlists" possuem esquema exato',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(auth: mockAuth, firestore: fakeFirestore),
      );

      await tester.tap(find.text('Abrir Criar Playlist'));
      await tester.pumpAndSettle();

      // Preenche nome
      final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
      await tester.enterText(nomeField, 'Trilha Sonora');
      await tester.pumpAndSettle();

      // Seleciona ambas as músicas
      final blankCheckboxes = find.byIcon(Icons.check_box_outline_blank);
      await tester.tap(blankCheckboxes.at(0));
      await tester.pumpAndSettle();
      await tester.tap(blankCheckboxes.at(0)); // Próximo item vira index 0 após rebuild
      await tester.pumpAndSettle();

      // Salva
      final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.tap(salvarButton);
      await tester.pumpAndSettle();

      // Inspeciona esquema de dados
      final snapshot = await fakeFirestore.collection('playlists').get();
      expect(snapshot.docs.length, 1);

      final Map<String, dynamic> docData = snapshot.docs.first.data();
      expect(docData.keys, containsAll(['userId', 'nome', 'musicas', 'dataCriacao']));
      expect(docData['userId'], equals(testUser.uid));
      expect(docData['nome'], equals('Nova Playlist')); // Conforme implementado na tela
      expect(docData['musicas'], isA<List>());
      expect(docData['musicas'], containsAll(['Bohemian Rhapsody', 'Hotel California']));
      expect(docData['dataCriacao'], isA<Timestamp>());
    },
  );
}

```
````

### Resposta ao reparo 1

````markdown
**Classificação da causa provável da falha:**

**(A) o teste presume um comportamento que não é o especificado**

---

### Justificativa

O erro ocorrido não é uma falha de asserção em tempo de execução nem decorre de divergência de lógica de negócio da aplicação. Trata-se de um erro de **compilação** no arquivo de teste (`'FirebaseAuth' isn't a type`).

No código do teste gerado, o pacote `package:firebase_auth/firebase_auth.dart` não foi importado no arquivo de teste. Embora `package:firebase_auth_mocks/firebase_auth_mocks.dart` tenha sido incluído, ele não exporta diretamente o tipo base `FirebaseAuth` no namespace do arquivo de teste, tornando o tipo desconhecido para o compilador do Dart na assinatura da função auxiliar `buildTestableWidget`.

---

### Código do Teste Corrigido

Adicionou-se o import `import 'package:firebase_auth/firebase_auth.dart';`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser testUser;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    testUser = MockUser(
      uid: 'user_123_abc',
      email: 'user@sintonize.com',
      displayName: 'Marcos Neto',
    );
    mockAuth = MockFirebaseAuth(mockUser: testUser, signedIn: true);

    // Popula o banco falso com músicas de teste
    await fakeFirestore.collection('musica').add({
      'track_name': 'Bohemian Rhapsody',
      'artist_name': 'Queen',
    });
    await fakeFirestore.collection('musica').add({
      'track_name': 'Hotel California',
      'artist_name': 'Eagles',
    });
  });

  Widget buildTestableWidget({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CriarPlaylistScreen(
                      editPlaylist: const {},
                      auth: auth,
                      firestore: firestore,
                    ),
                  ),
                );
              },
              child: const Text('Abrir Criar Playlist'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets(
    'Fluxo de sucesso: preencher nome, selecionar música, salvar e desempilhar tela',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestableWidget(auth: mockAuth, firestore: fakeFirestore),
      );

      // Abre a tela via navegação
      await tester.tap(find.text('Abrir Criar Playlist'));
      await tester.pumpAndSettle();

      expect(find.byType(CriarPlaylistScreen), findsOneWidget);
      expect(find.text('Bohemian Rhapsody - Queen'), findsOneWidget);

      // 1. Digita o nome da playlist
      final nomeField = find.widgetWithText(TextField, 'Nome da Playlist');
      await tester.enterText(nomeField, 'Minhas Favoritas');
      await tester.pumpAndSettle();

      // 2. Seleciona a primeira música da lista
      final checkboxButtons = find.byIcon(Icons.check_box_outline_blank);
      expect(checkboxButtons, findsWidgets);
      await tester.tap(checkboxButtons.first);
      await tester.pumpAndSettle();

      // Verifica se o ícone mudou para selecionado
      expect(find.byIcon(Icons.check_box), findsOneWidget);

      // 3. Salva a playlist
      final salvarButton = find.widgetWithText(ElevatedButton, 'Salvar Playlist');
      await tester.tap(salvarButton);
      await tester.pumpAndSettle();

      // Verifica se a tela foi fechada (Navigator.pop)
      expect(find.byType(CriarPlaylistScreen), findsNothing);
      expect(find.text('Abrir Criar Playlist'), findsOneWidget);

      // 4. Verifica persistência no Firestore
      final snapshot = await fakeFirestore.collection('playlists').get();
      expect(snapshot.docs.length, 1);
      final data = snapshot.docs.first.data**Classificação:** **(A) o teste presume um comportamento que não é o especificado** (trata-se de uma falha de compilação do próprio arquivo de teste por dependência/tipo não importado no escopo do teste, e não de uma falha de asserção de lógica da aplicação em tempo de execução).

---

### Causa do Problema

O compilador do Dart não encontrou a definição do tipo `FirebaseAuth` dentro do arquivo `test/fase2-gemini/integration/isilent_cot_test.dart` na linha 34. Isso ocorre normalmente por duas razões:
1. O arquivo de teste não importou o pacote `firebase_auth`.
2. O pacote `firebase_auth` não foi adicionado às dependências (`pubspec.yaml`).

---

### Correção

#### 1. Importar o pacote no arquivo de teste
Adicione o import do Firebase Auth no topo de `test/fase2-gemini/integration/isilent_cot_test.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';

```

Se o teste estiver usando mocks (como `firebase_auth_mocks` ou `mockito`), certifique-se de importar o tipo correto ou a classe base:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart'; // se aplicável

```

#### 2. Verificar o `pubspec.yaml`

Caso o import gere o erro de que o pacote não foi encontrado, certifique-se de que a dependência está presente no `pubspec.yaml`:

```yaml
dependencies:
  firebase_auth: ^5.0.0 # ou a versão compatível do seu projeto

```

Em seguida, execute no terminal para atualizar os pacotes:

```bash
flutter pub get

```
````
