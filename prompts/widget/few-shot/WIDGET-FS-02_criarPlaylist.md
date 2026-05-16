# WIDGET-FS-02

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | WIDGET-FS-02 |
| **Widget testado** | CriarPlaylistScreen |
| **Arquivo de origem** | lib/criar_playlist.dart |
| **Complexidade** | Média |
| **Nível da pirâmide** | Integração (Widget Test) |
| **Estratégia de prompt** | Few-shot |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.5 |
| **Data de acesso** | 2026-05-15 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 |

---

## Prompt Enviado

Template few-shot do `PROMPT_TEMPLATE_WIDGET.md` (igual ao FS-01: exemplo de `MeuFormulario` com `MockFirebaseAuth` + instrução "siga o mesmo padrão") seguido do código completo de `lib/criar_playlist.dart` (253 linhas) e lista de dependências de mock.

---

## Resposta do LLM

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/criar_playlist_screen.dart';   // ← path alucinado (correto: sintonize/criar_playlist.dart)

class MockNavigatorObserver extends Mock implements NavigatorObserver {}  // ← Mock sem import de mockito

void main() {
  group('CriarPlaylistScreen Widget Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late NavigatorObserver navigatorObserver;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      await fakeFirestore.collection('musica').add({'track_name': 'Song One', 'artist_name': 'Artist A'});
      await fakeFirestore.collection('musica').add({'track_name': 'Another Song', 'artist_name': 'Artist B'});
      mockAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: '123'));
      navigatorObserver = MockNavigatorObserver();
    });

    // 6 testWidgets: loading inicial, exibir músicas, filtrar, selecionar/desselecionar,
    // erro nome vazio, salvar e voltar (usando verify(...).called(1) sem importar mockito)
    // (código completo em test/widget/criar_playlist_fs_test.dart)
  });
}
```

**Observação importante do LLM:** Reconheceu novamente a limitação de DI (`FirebaseFirestore.instance` direto) e ofereceu refatorar o widget. Não aplicada.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | **Não** |
| **Testes gerados** | 6 |
| **Testes passaram (1ª execução)** | 0 |
| **Testes falharam (1ª execução)** | 6 (todos por falha de compilação) |
| **Testes passaram (pós-repair)** | 0 (loop encerrado na Iteração 1 — LLM admitiu não saber o path correto) |
| **Testes falharam (pós-repair)** | 6 (continuam por falha de compilação no import) |
| **Setup correto de mocks?** | Não — múltiplas falhas: (1) `Mock` usado sem `import 'package:mockito/mockito.dart'`; (2) `verify`/`any` usados sem import do mockito; (3) `MockNavigatorObserver extends Mock implements NavigatorObserver` falha porque `NavigatorObserver` tem métodos que precisariam ser stubados. Mesmo que o path estivesse correto, ainda não compilaria. |
| **MaterialApp wrapper?** | Sim — `MaterialApp(home: CriarPlaylistScreen(editPlaylist: const {}), navigatorObservers: [navigatorObserver])`. |
| **Tratou assets?** | N/A — falha de compilação; widget não tem `Image.asset`. |
| **Tipos de teste gerados** | Loading state (1), Carregamento async/Firestore (1), Filtro/busca (1), Toggle UI (1), Validação form (1), Persistência + Navegação (1) |
| **Nota metodológica** | Os campos "1ª execução" refletem a saída do `flutter test` antes de qualquer iteração de repair. Os campos "pós-repair" refletem o estado final após todas as iterações. |

### Saída do terminal

Saída completa salva em [`results/widget/few-shot/WIDGET-FS-02.txt`](../../../results/widget/few-shot/WIDGET-FS-02.txt).

Erros principais:

```
test/widget/criar_playlist_fs_test.dart:7:8: Error: Error when reading 'lib/criar_playlist_screen.dart': O sistema não pode encontrar o arquivo especificado
import 'package:sintonize/criar_playlist_screen.dart';
       ^
test/widget/criar_playlist_fs_test.dart:9:34: Error: 'Mock' isn't a type.
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
                                 ^^^^
test/widget/criar_playlist_fs_test.dart:40:15: Error: Method not found: 'CriarPlaylistScreen'.
        home: CriarPlaylistScreen(editPlaylist: const {}),
              ^^^^^^^^^^^^^^^^^^^
test/widget/criar_playlist_fs_test.dart:110:39: Error: Undefined name 'any'.
      verify(navigatorObserver.didPop(any, any)).called(1);
                                      ^^^
test/widget/criar_playlist_fs_test.dart:110:7: Error: Method not found: 'verify'.
      verify(navigatorObserver.didPop(any, any)).called(1);
      ^^^^^^
```

**Achados experimentais:**

1. **Path alucinado mais uma vez** — agora `sintonize/criar_playlist_screen.dart`. Padrão consistente: FS adiciona sufixo `_screen` em todos os widgets (FS-01: `login_screen`, FS-02: `criar_playlist_screen`). O sufixo é coerente com a "convenção" implícita do exemplo de `MeuFormulario`, reforçando a hipótese de viés introduzido pelo few-shot.
2. **Uso de mockito sem import** — o LLM declarou `class MockNavigatorObserver extends Mock implements NavigatorObserver` e chamou `verify(...)`, `any` sem importar `package:mockito/mockito.dart`. O exemplo do few-shot **não usa mockito** (só `firebase_auth_mocks`), então o LLM trouxe convenções de fora do prompt e esqueceu o import.
3. **Boa cobertura conceitual mesmo que não compile** — diferente do FS-01 (só validação de form), o LLM aqui foi mais ambicioso: cobriu loading inicial, async de Firestore, filtro, toggle, validação e navegação. A intenção dos testes é mais rica que ZS-02 (que tinha 7 tests mas estrutura mais simples). Trade-off interessante: FS ambiciona mais e por isso falha em mais lugares.

---

## Iterative Repair Loop

### Iteração 1
- **Necessária?** Sim
- **Motivo da falha:** Compilação falhou com 4 categorias heterogêneas — path alucinado, `Mock` sem import de mockito, `verify`/`any` undefined, `Method not found: 'CriarPlaylistScreen'`.
- **Prompt de correção:** Erro completo de compilação enviado ao LLM (5 mensagens de erro do flutter test).
- **Resposta do LLM:** Corrigiu 3 dos 4 problemas:
  - Adicionou `import 'package:mockito/mockito.dart';`
  - Removeu `verify(navigatorObserver.didPop(any, any)).called(1);` (substituiu por `expect(find.byType(CircularProgressIndicator), findsNothing);`)
  - `MockNavigatorObserver extends Mock implements NavigatorObserver` agora compila
  - **Não corrigiu o path** — manteve `package:sintonize/criar_playlist_screen.dart` (continua `_screen` no nome) e adicionou comentário `// ⚠️ ajuste o path abaixo para o arquivo REAL do seu projeto`, devolvendo o problema ao usuário.
- **Resultado:** Falhou — 0/6 ainda. Restam 2 erros (path errado + cascata `Method not found: 'CriarPlaylistScreen'`). O LLM **explicitamente reconheceu** que não sabe o path correto e pediu ajuste manual.

### Iteração 2
- **Necessária?** Não — loop encerrado na Iteração 1 (LLM explicitamente declarou desconhecer o path)

### Iteração 3
- **Necessária?** Não — loop encerrado na Iteração 1

---

## Achados consolidados — WIDGET-FS-02

1. **Repair loop parcialmente eficaz em erros heterogêneos** — diferente de FS-01 (loop puro de adivinhação), aqui o LLM **resolveu 3 dos 4 problemas** na Iteração 1 (import de mockito, remoção de `verify`/`any` problemáticos, classe Mock funcional). O repair tem rendimento quando o erro descreve um problema diagnosticável (falta de import, símbolo undefined).
2. **Path continua sendo o limite intransponível** — repair loop não tem como resolver alucinação de path sem informação adicional. Confirma o padrão observado em ZS-02, FS-01 e agora FS-02.
3. **LLM evoluiu de "chutar" para "admitir"** — em FS-02 a Iteração 1 incluiu o comentário `// ⚠️ ajuste o path abaixo para o arquivo REAL do seu projeto`, devolvendo explicitamente a responsabilidade ao usuário. Trade-off interessante: o LLM **sabe que não sabe** o path, mas não tem mecanismo (no protocolo zero/few-shot) para descobrir.
4. **Sufixo `_screen.dart` é viés do few-shot** — terceira ocorrência do mesmo viés (FS-01: `login_screen`, FS-02: `criar_playlist_screen`, e provavelmente FS-03 vai produzir `cadastro_screen`). Forte evidência de que o exemplo `MeuFormulario` no prompt induz uma convenção `<Feature>Screen` em `<feature>_screen.dart` que o LLM aplica acriticamente ao widget-alvo.
