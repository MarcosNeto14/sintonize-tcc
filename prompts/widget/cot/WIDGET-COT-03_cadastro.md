# WIDGET-COT-03

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | WIDGET-COT-03 |
| **Widget testado** | CadastroScreen |
| **Arquivo de origem** | lib/cadastro.dart |
| **Complexidade** | Alta |
| **Nível da pirâmide** | Widget |
| **Estratégia de prompt** | Chain-of-Thought |
| **LLM utilizado** | ChatGPT |
| **Versão do modelo** | GPT-4o (2026-05-20) |
| **Data de acesso** | 2026-05-20 |
| **Conversa nova?** | Sim |
| **Framework de teste** | flutter_test |
| **Versão do Flutter** | 3.41.7 |

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

[código completo de lib/cadastro.dart — 485 linhas]

O widget faz parte do projeto Flutter "sintonize".
Use `import 'package:sintonize/...'` para os imports.

Dependências disponíveis para mocking:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito
```

---

## Resposta do LLM

O modelo executou as 4 etapas do CoT antes de gerar o código:

**Etapa 1 — Análise do widget:** Identificou CadastroScreen como tela de cadastro com TextFormField (10 campos), DropdownButtonFormField, ElevatedButton e TextButton. Apontou Firebase Auth, Firestore e HTTP (ViaCEP) como serviços externos.

**Etapa 2 — Dependências:** Mapeou FirebaseAuth.instance → MockFirebaseAuth; FirebaseFirestore.instance → FakeFirebaseFirestore; http.get() → Mockito. Observou que o acoplamento estático (`instance`) dificulta mocking completo sem injeção de dependência.

**Etapa 3 — Cenários:** Listou 5 categorias: renderização (1), validação por campo (8 sub-cenários), interação (4), sucesso (1), erros (4).

**Etapa 4 — Código gerado:** 13 testes em 5 grupos. Os mocks `mockAuth` e `fakeFirestore` são declarados mas não injetados no widget (devido ao acoplamento estático). O fluxo de sucesso tenta navegar para `GenerosCadastroScreen`.

Arquivo gerado: `test/widget/cadastro_cot_test.dart`

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 13 |
| **Testes passaram (1ª execução)** | 3 |
| **Testes falharam (1ª execução)** | 10 |
| **Testes passaram (pós-repair)** | 3 |
| **Testes falharam (pós-repair)** | 10 |
| **Setup correto de mocks?** | Parcial |
| **MaterialApp wrapper?** | Sim |
| **Tratou assets?** | Não |

### Saída do terminal

```
00:00 +0: loading test/widget/cadastro_cot_test.dart
00:00 +0: Renderização deve renderizar os principais componentes
00:01 +1: Validações deve validar nome vazio

Warning: A call to tap() with finder "Cadastrar" derived an Offset (Offset(400.0, 870.0))
that would not hit test on the specified widget.
Indeed, Offset(400.0, 870.0) is outside the bounds of the root of the render tree, Size(800.0, 600.0).

Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "O nome é obrigatório": []>
   Which: means none were found but one was expected

[...falhas similares para os demais testes de validação — botão "Cadastrar" abaixo do viewport...]

00:06 +2 -7: Interações deve selecionar estado [E]
Bad state: No element
(dropdown também fora do viewport — find.text('PE').last lança exceção)

00:06 +3 -7: Fluxo de sucesso deve cadastrar usuário e navegar para próxima tela
[falha — DropdownButtonFormField fora da área visível]

00:12 +3 -10: Some tests failed.
```

**Causa raiz dominante:** O formulário de CadastroScreen tem ~870px de altura. O viewport de teste é 800×600px. O botão "Cadastrar" e o DropdownButtonFormField ficam abaixo de y=600, tornando-os inalcançáveis por `tap()` sem scroll prévio. Todos os testes que dependem de tap nesses elementos falham.

---

## Iterative Repair Loop

### Iteração 1
- **Necessária?** Sim
- **Motivo da falha:** Botão "Cadastrar" e DropdownButtonFormField estão abaixo do viewport de teste (800×600px). O formulário tem ~870px de altura. `tap()` emite `Warning: offset would not hit test on the specified widget` e a validação do formulário não dispara, causando `findsOneWidget` → found 0. O dropdown também fica fora da tela, lançando `Bad state: No element` em `find.text('PE').last`.
- **Prompt de correção:** Adicionar `await tester.ensureVisible(finder)` antes de qualquer `tap()` em elemento potencialmente fora do viewport (botão "Cadastrar", DropdownButtonFormField, opção 'PE').
- **Resposta do LLM:** Forneceu correções pontuais: inserir `ensureVisible` antes de cada `tap(find.text('Cadastrar'))`, antes de `tap(find.byType(DropdownButtonFormField<String>))` e antes de `tap(find.text('PE').last)`.
- **Resultado:** Falhou — 11/13 passaram. `ensureVisible(find.text('PE').last)` lança `Bad state: No element` porque os itens do overlay do dropdown não são encontráveis via `find.text()` após `pumpAndSettle()`.

### Iteração 2
- **Necessária?** Sim
- **Motivo da falha:** Após abrir o dropdown com `tap()` + `pumpAndSettle()`, `find.text('PE').last` retorna 0 elementos. O overlay abre mas os itens (DropdownMenuItem) podem não estar acessíveis via `find.text()`, ou 'PE' não está visível na lista sem scroll do overlay.
- **Prompt de correção:** Substituir `.last` por `.first`, adicionar `expect(find.byType(DropdownMenuItem<String>), findsWidgets)` para confirmar que o menu abriu antes de tentar selecionar o item.
- **Resposta do LLM:** Forneceu reescrita dos dois testes afetados usando `.first`, `find.byWidgetPredicate` para confirmar que o menu está aberto, e `ensureVisible` no item 'PE'.
- **Resultado:** Falhou — 11/13 (mesmos 2 testes). `expect(find.byType(DropdownMenuItem<String>), findsWidgets)` passa (itens estão na árvore, provavelmente renderizados offstage para cálculo de tamanho do botão), mas `find.text('PE').first` continua retornando `Bad state: No element`. O tap no dropdown possivelmente não abre o overlay ou os itens do overlay não são encontráveis via `find.text()` com `skipOffstage: true` (padrão).

### Iteração 3
- **Necessária?** Sim
- **Motivo da falha:** `find.text('PE').first` retorna 0 elementos mesmo após `pumpAndSettle()`. O `DropdownButtonFormField` renderiza itens offstage para cálculo de tamanho; `find.text()` usa `skipOffstage: true` por padrão e não os encontra. O overlay com itens interativos pode não estar abrindo corretamente via `tap()` no ambiente de teste.
- **Prompt de correção:** Sugeriu 3 opções: (A) `find.text('PE', skipOffstage: false)`, (B) simplificar o teste para verificar apenas que o dropdown renderiza sem tentar selecionar um item, (C) `find.byWidgetPredicate` por valor. LLM escolheu a Opção B como a mais estável.
- **Resposta do LLM:** (1) Substituir "deve selecionar estado" por "deve renderizar dropdown de estados" — apenas verifica `findsOneWidget` do `DropdownButtonFormField`. (2) No teste de fluxo, remover todo o bloco de interação com o dropdown; como `estado` não tem validator obrigatório, o submit pode ser chamado sem seleção.
- **Resultado:** Falhou — 12/13. O teste "deve renderizar dropdown de estados" passou. O teste de fluxo ("deve cadastrar usuário e navegar para próxima tela") ainda falha: `FirebaseAuth.instance` real é chamado em `_submit()` mas Firebase não está inicializado no ambiente de teste; `mockAuth` é declarado mas nunca injetado no widget (acoplamento estático). A navegação para `GenerosCadastroScreen` nunca ocorre. Limite de 3 iterações atingido — falha registrada.
