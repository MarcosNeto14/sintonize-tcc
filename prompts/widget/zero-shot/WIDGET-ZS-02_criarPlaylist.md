# WIDGET-ZS-02

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | WIDGET-ZS-02 |
| **Widget testado** | CriarPlaylistScreen |
| **Arquivo de origem** | lib/criar_playlist.dart |
| **Complexidade** | Média |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Zero-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.5 |
| **Data de acesso** | 2026-05-15 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 |

---

## Prompt Enviado

Mesmo template zero-shot do PROMPT_TEMPLATE_WIDGET.md, com o código completo de `lib/criar_playlist.dart` (253 linhas) embutido no marcador `[COLAR O CÓDIGO COMPLETO DO WIDGET AQUI]`. Estrutura do prompt:

1. Instrução "Gere widget tests em Dart usando o pacote flutter_test para o seguinte widget Flutter:"
2. Código completo de `lib/criar_playlist.dart` em bloco ```dart```
3. Parágrafo "O widget faz parte de um projeto Flutter chamado 'sintonize'."
4. Lista de dependências de mocking (firebase_auth_mocks, fake_cloud_firestore, mockito)
5. Lista de 7 requisitos (testWidgets, MaterialApp wrapper, mocks, validação, interação, executável com `flutter test`, imports `package:sintonize/...`)

---

## Resposta do LLM

```dart
// File: test/widgets/criar_playlist_screen_test.dart

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sintonize/screens/criar_playlist_screen.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp();
  });

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();

    final mockUser = MockUser(
      uid: 'user_123',
      email: 'teste@sintonize.com',
    );

    mockAuth = MockFirebaseAuth(
      mockUser: mockUser,
      signedIn: true,
    );

    // Inserindo músicas fake no Firestore
    await fakeFirestore.collection('musica').add({
      'track_name': 'Shape of You',
      'artist_name': 'Ed Sheeran',
    });

    await fakeFirestore.collection('musica').add({
      'track_name': 'Blinding Lights',
      'artist_name': 'The Weeknd',
    });
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: const CriarPlaylistScreen(
        editPlaylist: {},
      ),
    );
  }

  group('CriarPlaylistScreen Widget Tests', () {
    // 7 testWidgets: renderização, snackbar (nome vazio), digitar nome, pesquisar música,
    // selecionar/desselecionar música, navegação back, preencher nome + pesquisa simultâneos
    // (código completo dos testes no arquivo test/widget/criar_playlist_zs_test.dart)
  });
}
```

**Observações importantes do LLM:**

> Como o widget utiliza diretamente:
> 
> ```
> FirebaseFirestore.instance
> FirebaseAuth.instance
> ```
> 
> os testes acima assumem que o projeto já possui inicialização Firebase mockada globalmente.
> 
> Para tornar os testes realmente isolados e funcionarem corretamente com fake_cloud_firestore e firebase_auth_mocks, o ideal é refatorar o widget para receber as dependências via construtor:
> 
> ```dart
> final FirebaseFirestore firestore;
> final FirebaseAuth auth;
> ```

(Código completo dos 7 testWidgets salvo em `test/widget/criar_playlist_zs_test.dart`. Resposta integral preservada — fidelidade ao output do LLM.)

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Não |
| **Testes gerados** | 7 |
| **Testes passaram (1ª execução)** | 0 |
| **Testes falharam (1ª execução)** | 7 |
| **Testes passaram (pós-repair)** | 0 |
| **Testes falharam (pós-repair)** | 7 |
| **Setup correto de mocks?** | Parcial |
| **MaterialApp wrapper?** | Sim |
| **Tratou assets?** | N.A. |

### Saída do terminal

Saída completa salva em [`results/widget/zero-shot/WIDGET-ZS-02.txt`](../../../results/widget/zero-shot/WIDGET-ZS-02.txt).

Erro principal (falha de compilação):

```
test/widget/criar_playlist_zs_test.dart:9:8: Error: Error when reading 'lib/screens/criar_playlist_screen.dart': O sistema não pode encontrar o caminho especificado
import 'package:sintonize/screens/criar_playlist_screen.dart';
       ^
test/widget/criar_playlist_zs_test.dart:48:19: Error: Couldn't find constructor 'CriarPlaylistScreen'.
      home: const CriarPlaylistScreen(
                  ^^^^^^^^^^^^^^^^^^^
test/widget/criar_playlist_zs_test.dart:149:47: Error: Couldn't find constructor 'CriarPlaylistScreen'.
                        builder: (_) => const CriarPlaylistScreen(
                                              ^^^^^^^^^^^^^^^^^^^
00:00 +0 -1: Some tests failed.
```

**Achado experimental:** o LLM **alucinou o path do arquivo** — assumiu a convenção comum `lib/screens/<feature>_screen.dart` (típica em projetos Flutter organizados por feature), quando o projeto real usa `lib/<feature>.dart` na raiz de `lib/`. Esse tipo de alucinação é específica de zero-shot: sem exemplos (FS) ou raciocínio explícito (CoT), o LLM preenche lacunas com convenções estatisticamente prováveis.

---

## Iterative Repair Loop

### Iteração 1
- **Necessária?** Sim
- **Motivo da falha:** Falha de compilação por path errado no import (`sintonize/screens/criar_playlist_screen.dart` em vez de `sintonize/criar_playlist.dart`) — cascateia em 2 erros de "constructor not found" porque o tipo `CriarPlaylistScreen` não foi resolvido.
- **Prompt de correção:**

````
O widget test falhou com o seguinte erro:

```
test/widget/criar_playlist_zs_test.dart:9:8: Error: Error when reading 'lib/screens/criar_playlist_screen.dart': O sistema não pode encontrar o caminho especificado
import 'package:sintonize/screens/criar_playlist_screen.dart';
       ^
[+ 2 erros derivados de "Couldn't find constructor 'CriarPlaylistScreen'"]

Resultado: falha de compilação (0 testes executados).
```

Corrija o teste para que compile e passe corretamente. Não modifique o código do widget, apenas o código do teste.
````

- **Resposta do LLM:** Mudou o path de `sintonize/screens/criar_playlist_screen.dart` para `sintonize/view/criar_playlist_screen.dart` (continua errado — o path real é `sintonize/criar_playlist.dart`). Também removeu o import e o setup de `firebase_auth_mocks` argumentando que "o teste atual não executa `_salvarPlaylist()`". Adicionou comentário no código sugerindo que o usuário ajuste manualmente o path.
- **Resultado:** Falhou — mesmo erro de compilação, agora apontando para `lib/view/criar_playlist_screen.dart` (também inexistente).

**Achado:** o LLM entrou em **loop de adivinhação** — sem informação sobre a estrutura real do projeto, ele apenas alterna entre convenções estatisticamente comuns (`screens/`, `view/`, `pages/`). O prompt de reparo "padrão" (apenas o erro) não contém a informação que o LLM precisaria para resolver.

### Iteração 2
- **Necessária?** Não — loop encerrado na Iteração 1 por decisão metodológica (ver discussão abaixo)

### Iteração 3
- **Necessária?** Não — loop encerrado na Iteração 1

---

## Discussão metodológica — limite do repair loop em zero-shot

Limite estrutural do zero-shot + repair loop: quando a causa raiz é falta de informação sobre o projeto (estrutura de pastas), repetir o erro não ajuda — o LLM apenas alterna entre convenções plausíveis (`screens/`, `view/`, `pages/`) sem convergir. Rodada encerrada após Iteração 1 por decisão metodológica.
