# Templates de Prompt — Integration Tests

**Projeto:** Sintonize (Flutter + Firebase)
**Nível:** Integration Test (fluxos multi-tela com WidgetTester)
**Total de rodadas:** 9 (3 fluxos × 3 estratégias)

**Instruções de uso:**
1. Copie o template da estratégia desejada
2. Substitua os marcadores `[COLAR ...]` pelo código completo dos arquivos das telas envolvidas no fluxo
3. Cole no ChatGPT em uma **conversa nova**
4. Documente tudo no arquivo `INT-XX-NN` correspondente em `prompts/integration/{zero-shot,few-shot,cot}/`

**Diferença para widget tests:** os integration tests cobrem **fluxos completos de navegação** entre telas (ex: login → tela inicial), enquanto widget tests testam um único widget isolado.

---

## Fluxos e arquivos a colar

| # | Fluxo | Tela principal | Tela destino | Complexidade |
|---|---|---|---|---|
| 01 | Login | lib/login.dart (219 linhas) | lib/tela-inicial.dart | Baixa |
| 02 | Cadastro | lib/cadastro.dart (484 linhas) | lib/tela-inicial.dart | Alta |
| 03 | Criar Playlist | lib/criar_playlist.dart (254 linhas) | — (Firestore) | Média |

---

## Estratégia 1 — ZERO-SHOT

```
Gere testes de integração em Flutter para o fluxo [NOME_DO_FLUXO].

O fluxo cobre as seguintes telas:

=== TELA PRINCIPAL: [NomeDaTelaOuArquivo] ===
```dart
[COLAR O CÓDIGO COMPLETO DA TELA PRINCIPAL AQUI]
```

=== TELA DESTINO: [NomeDaTelaDestinoOuArquivo] (se aplicável) ===
```dart
[COLAR O CÓDIGO COMPLETO DA TELA DESTINO AQUI — ou remover esta seção se não houver]
```

Dependências disponíveis para mocking:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito

Requisitos:
- Usar flutter_test com testWidgets() e WidgetTester
- Envolver o widget raiz em MaterialApp para suportar navegação
- Configurar mocks de Firebase Auth e/ou Firestore conforme necessário
- Testar o fluxo completo: renderização inicial → entrada de dados → ação do usuário → navegação para tela destino
- Cobrir: caminho feliz (fluxo completo com sucesso), falhas de validação, falha de autenticação/serviço externo
- Usar pumpAndSettle() para aguardar navegação e animações
- Agrupar os testes com group('[NomeDoFluxo] Integration Tests', ...)
- Um testWidgets() por cenário
- Usar import 'package:sintonize/...' para imports do projeto
- Os testes devem ser executáveis com `flutter test test/integration/`
```

---

## Estratégia 2 — FEW-SHOT

```
Gere testes de integração em Flutter para o fluxo [NOME_DO_FLUXO].

Antes, veja dois exemplos do padrão esperado:

--- EXEMPLO 1: Fluxo de login bem-sucedido ---
```dart
testWidgets('login bem-sucedido navega para TelaInicial', (WidgetTester tester) async {
  final mockAuth = MockFirebaseAuth(signedIn: false);

  await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

  await tester.enterText(find.byType(TextFormField).first, 'usuario@email.com');
  await tester.enterText(find.byType(TextFormField).last, 'senha123');

  await tester.tap(find.text('Entrar'));
  await tester.pumpAndSettle();

  expect(find.byType(TelaInicialScreen), findsOneWidget);
});
```

--- EXEMPLO 2: Falha de validação impede navegação ---
```dart
testWidgets('campos inválidos exibem erros e não navegam', (WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

  await tester.tap(find.text('Entrar'));
  await tester.pump();

  expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
  expect(find.byType(TelaInicialScreen), findsNothing);
});
```

Agora gere testes de integração para o fluxo [NOME_DO_FLUXO], seguindo o mesmo padrão dos exemplos.

O fluxo cobre as seguintes telas:

=== TELA PRINCIPAL: [NomeDaTelaOuArquivo] ===
```dart
[COLAR O CÓDIGO COMPLETO DA TELA PRINCIPAL AQUI]
```

=== TELA DESTINO: [NomeDaTelaDestinoOuArquivo] (se aplicável) ===
```dart
[COLAR O CÓDIGO COMPLETO DA TELA DESTINO AQUI — ou remover esta seção se não houver]
```

Dependências disponíveis:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito

Use import 'package:sintonize/...' para os imports do projeto.
```

---

## Estratégia 3 — CHAIN-OF-THOUGHT (CoT)

```
Quero que você gere testes de integração em Flutter para o fluxo [NOME_DO_FLUXO]. Antes de escrever os testes, siga estes passos obrigatoriamente:

Passo 1 — Analise o fluxo:
Descreva em 2–3 frases o que o fluxo faz, quais telas são envolvidas, qual é o caminho feliz esperado e qual o estado final do app após o fluxo completo.

Passo 2 — Identifique as dependências:
Liste quais serviços externos são usados (Firebase Auth, Firestore, HTTP, etc.) e como cada um deve ser mockado usando as bibliotecas disponíveis (firebase_auth_mocks, fake_cloud_firestore, mockito).

Passo 3 — Identifique os cenários de teste:
Liste todos os cenários relevantes, incluindo:
- (a) Caminho feliz: fluxo completo com sucesso e navegação para a tela destino
- (b) Falhas de validação: campos inválidos ou vazios impedem progresso
- (c) Falha de serviço externo: Firebase Auth ou Firestore retorna erro
- (d) Casos de borda: estado parcialmente preenchido, duplo tap, etc.

Passo 4 — Escreva os testes:
Para cada cenário identificado no Passo 3, escreva um testWidgets() completo e compilável.

IMPORTANTE: Não modifique o código das telas. Apenas gere os testes.

O fluxo cobre as seguintes telas:

=== TELA PRINCIPAL: [NomeDaTelaOuArquivo] ===
```dart
[COLAR O CÓDIGO COMPLETO DA TELA PRINCIPAL AQUI]
```

=== TELA DESTINO: [NomeDaTelaDestinoOuArquivo] (se aplicável) ===
```dart
[COLAR O CÓDIGO COMPLETO DA TELA DESTINO AQUI — ou remover esta seção se não houver]
```

Dependências disponíveis para mocking:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito

Use import 'package:sintonize/...' para os imports do projeto.
Os testes devem ser executáveis com `flutter test test/integration/`.
```

---

## Prompt para Iterative Repair Loop

```
O integration test falhou com o seguinte erro:

```
[COLAR A SAÍDA DE ERRO DO TERMINAL AQUI]
```

Corrija o teste para que compile e passe corretamente. Não modifique o código das telas, apenas o código do teste.
```

**Limite:** máximo 3 iterações de reparo por rodada.

---

## Diferenças em relação aos widget tests

| Aspecto | Widget Tests | Integration Tests |
|---|---|---|
| Escopo | 1 widget isolado | Fluxo completo (1+ telas + navegação) |
| O que colar no prompt | Código de 1 tela | Código de 1–2 telas (origem + destino) |
| Tipo de assert principal | Renderização e validação | Navegação entre telas (`find.byType(TelaDestino)`) |
| pump() vs pumpAndSettle() | `pump()` suficiente na maioria | `pumpAndSettle()` obrigatório para aguardar navegação |
| Complexidade esperada | Alta | Muito alta |
| Iterações de repair esperadas | 2–3 | 2–3 |
