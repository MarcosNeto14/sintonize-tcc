# WIDGET-COT-02

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | WIDGET-COT-02 |
| **Widget testado** | CriarPlaylistScreen |
| **Arquivo de origem** | lib/criar_playlist.dart |
| **Complexidade** | Média |
| **Nível da pirâmide** | Integração (Widget Test) |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-5.5 |
| **Data de acesso** | 2026-05-19 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.6 |

---

## Prompt Enviado

```
Quero que você gere widget tests em Dart para o widget Flutter abaixo. Antes de escrever os testes, siga estes passos:

1. **Analise o widget:** Descreva em 3-5 frases o que ele faz, quais são seus elementos interativos e quais serviços externos ele usa.
2. **Identifique as dependências que precisam de mock:** Liste quais serviços (Firebase Auth, Firestore, HTTP) são usados e como devem ser mockados.
3. **Identifique os cenários de teste:** Liste todos os cenários relevantes, incluindo:
   - Renderização básica (o widget aparece corretamente?)
   - Validação de formulário (campos vazios, dados inválidos)
   - Interação do usuário (toques, entrada de texto, scroll)
   - Cenários de sucesso (fluxo completo funciona)
   - Cenários de erro (Firebase retorna erro, rede falha)
4. **Escreva os testes:** Para cada cenário, escreva um testWidgets() completo.

IMPORTANTE: Não modifique o código do widget. Apenas gere testes.

Widget a testar:

```dart
[código completo de lib/criar_playlist.dart — 254 linhas]
```

O widget faz parte do projeto Flutter "sintonize".
Use `import 'package:sintonize/...'` para os imports.

Dependências disponíveis para mocking:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito
```

---

## Resposta do LLM

### 1. Análise do widget

CriarPlaylistScreen é uma tela Stateful que busca músicas no Firestore, permite pesquisar músicas/artistas, selecionar músicas via checkbox e salvar a playlist associada ao usuário autenticado. Elementos interativos: campo de nome, campo de busca, lista com checkboxes, botão "Salvar Playlist", botão voltar. Serviços externos: FirebaseFirestore (buscar músicas, salvar playlist), FirebaseAuth (usuário atual), Navigator.

### 2. Dependências que precisam de mock

- **FirebaseFirestore** (FakeFirebaseFirestore): `_fetchMusicas()` e `_salvarPlaylist()`
- **FirebaseAuth** (MockFirebaseAuth): `_salvarPlaylist()` — simular usuário autenticado
- **Navigator** (MockNavigatorObserver via mockito): botão voltar e após salvar

### 3. Cenários de teste

Renderização básica, carregamento de músicas, filtro por busca, seleção/desseleção de música, SnackBar sem nome, digitar nome, salvar playlist, botão voltar, loading quando lista vazia.

### 4. Código gerado (geração inicial — 9 testes)

```dart
import 'package:sintonize/screens/criar_playlist_screen.dart'; // import errado
// ...9 testWidgets com FakeFirebaseFirestore + MockFirebaseAuth
// verify(navigatorObserver.didPop(any, any)) — problema null-safety
```

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Não (iter inicial) → Não (iter 1, tipo Route) → Não (iter 2, import + setupFirebaseAuthMocks) → Não (iter 3, import reincidente + tipo Route regredido) |
| **Testes gerados** | 9 (inicial) → 5 (iter 3) |
| **Testes passaram** | 0 |
| **Testes falharam** | Não executaram — falha de compilação em todas as iterações |
| **Setup correto de mocks?** | Não — widget usa `FirebaseFirestore.instance` e `FirebaseAuth.instance` diretamente; mock local não é injetado |
| **MaterialApp wrapper?** | Sim |
| **Tratou assets?** | N/A |
| **Tipos de teste gerados** | Renderização, Interação, Validação, Loading |

### Saída do terminal (iteração 3 — resultado final)

```
test/widget/criar_playlist_cot_test.dart:6:8: Error: Error when reading 'lib/screens/criar_playlist_screen.dart': O sistema não pode encontrar o caminho especificado
import 'package:sintonize/screens/criar_playlist_screen.dart';

test/widget/criar_playlist_cot_test.dart:31:19: Error: Couldn't find constructor 'CriarPlaylistScreen'.

test/widget/criar_playlist_cot_test.dart:89:39: Error: The argument type 'Null' can't be assigned to the parameter type 'Route<dynamic>'.
      verify(navigatorObserver.didPop(any, any)).called(1);

00:00 +0 -1: Some tests failed.
```

---

## Iterative Repair Loop

### Iteração 1
- **Necessária?** Sim
- **Motivo da falha:** `verify(navigatorObserver.didPop(any, any))` — `any` do mockito é `Null` em Dart null-safe; `NavigatorObserver.didPop` exige `Route<dynamic>` não-nulável
- **Prompt de correção:** Template padrão com a saída de erro
- **Resposta do LLM:** Cast explícito: `any as Route<dynamic>` no primeiro argumento do `didPop`
- **Resultado:** Falhou em runtime (0 erros de compilação, mas `pumpAndSettle` timeout em 8/9 testes) — `_fetchMusicas()` lança `[core/no-app] No Firebase App '[DEFAULT]'` porque `FirebaseFirestore.instance` não está inicializado; apenas `mostra loading quando lista está vazia` passou (usa `pump()`)

### Iteração 2
- **Necessária?** Sim
- **Motivo da falha:** `FirebaseFirestore.instance` não inicializado; `FakeFirebaseFirestore` local não substituiu o singleton global
- **Prompt de correção:** Template padrão com a saída de erro (pumpAndSettle timeout)
- **Resposta do LLM:** Substituiu toda a abordagem: adicionou `setupFirebaseAuthMocks()` + `Firebase.initializeApp()` no `setUpAll`, usou `FirebaseFirestore.instance` real no `setUp`, removeu `FakeFirebaseFirestore` local; import corrigido para `package:sintonize/screens/criar_playlist_screen.dart` (ainda errado)
- **Resultado:** Falhou na compilação — `setupFirebaseAuthMocks` não encontrado + import inexistente

### Iteração 3
- **Necessária?** N/A — última iteração permitida
- **Motivo da falha:** Retornou ao `FakeFirebaseFirestore` local (não injetável), manteve import errado `package:sintonize/screens/criar_playlist_screen.dart` (caminho inexistente — correto seria `package:sintonize/criar_playlist.dart`) e regrediu o fix do `didPop` (removeu o cast `as Route<dynamic>`)
- **Prompt de correção:** Template padrão com a saída de erro
- **Resposta do LLM:** Sem mudança efetiva nos erros estruturais — 3 erros de compilação persistiram
- **Resultado:** Falhou na compilação — resultado final registrado
