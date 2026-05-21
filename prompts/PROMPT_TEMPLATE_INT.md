# Templates de Prompt — Integration Tests

**Projeto:** Sintonize (Flutter + Firebase)
**Nível:** Integration Tests (fluxos multi-tela)
**Total de rodadas:** 9 (3 fluxos × 3 estratégias)

**Instruções de uso:**
1. Copie o template da estratégia desejada
2. Substitua `[COLAR O CÓDIGO DAS TELAS DO FLUXO AQUI]` pelo código completo de todos os arquivos `.dart` envolvidos no fluxo
3. Abra uma **conversa nova** no ChatGPT (uma conversa por rodada)
4. Cole o prompt e copie a resposta no doc da rodada correspondente em `prompts/integration/{zero-shot,few-shot,cot}/`

---

## Fluxos-alvo

| # | Fluxo | Telas envolvidas | Arquivos |
|---|---|---|---|
| 01 | Login | LoginScreen → TelaInicial | `lib/login.dart`, `lib/tela-inicial.dart` |
| 02 | Cadastro | CadastroScreen → LoginScreen | `lib/cadastro.dart`, `lib/login.dart` |
| 03 | Adicionar música | (tela de origem) → AdicionarMusica → Playlist | `lib/adicionar-musica.dart`, `lib/criar_playlist.dart` |

---

## Estratégia 1 — ZERO-SHOT

```
Gere um teste de integração em Dart usando flutter_test para o seguinte fluxo do aplicativo Flutter "Sintonize":

[DESCREVER O FLUXO EM 1-2 FRASES — ex.: "O usuário preenche email e senha na LoginScreen e, após autenticação bem-sucedida, é redirecionado para a TelaInicial."]

Código das telas envolvidas:

```dart
[COLAR O CÓDIGO DAS TELAS DO FLUXO AQUI]
```

Dependências disponíveis para mocking:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito

Requisitos:
- Use testWidgets() do flutter_test
- Monte todas as telas do fluxo dentro de um MaterialApp com rotas configuradas
- Configure os mocks de Firebase necessários
- Teste o fluxo completo ponta a ponta: interações na primeira tela → navegação → estado da tela destino
- Teste também cenários de erro (credenciais inválidas, campos vazios, Firebase retorna erro)
- Os testes devem ser executáveis com `flutter test test/integration/`
- Use `import 'package:sintonize/...'` para os imports do projeto
```

---

## Estratégia 2 — FEW-SHOT

```
Gere um teste de integração em Dart usando flutter_test para o fluxo do aplicativo Flutter "Sintonize" descrito abaixo.

Antes, veja um exemplo de teste de integração que cobre um fluxo de login:

**Exemplo — teste de integração do fluxo de login:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  group('Fluxo de Login', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    testWidgets('fluxo completo: login bem-sucedido navega para Home', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (_) => LoginScreen(auth: mockAuth),
            '/home': (_) => const HomeScreen(),
          },
        ),
      );

      await tester.enterText(find.byKey(const Key('emailField')), 'user@test.com');
      await tester.enterText(find.byKey(const Key('senhaField')), 'senha123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('credenciais inválidas exibem mensagem de erro', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(auth: MockFirebaseAuth(authExceptions:
            AuthExceptions(signInWithEmailAndPassword: FirebaseAuthException(code: 'wrong-password')))),
        ),
      );

      await tester.enterText(find.byKey(const Key('emailField')), 'user@test.com');
      await tester.enterText(find.byKey(const Key('senhaField')), 'errada'));
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('inválid'), findsOneWidget);
    });
  });
}
```

Agora, gere um teste de integração para o seguinte fluxo:

[DESCREVER O FLUXO EM 1-2 FRASES]

Código das telas envolvidas:

```dart
[COLAR O CÓDIGO DAS TELAS DO FLUXO AQUI]
```

Dependências disponíveis:
- firebase_auth_mocks
- fake_cloud_firestore
- mockito
```

---

## Estratégia 3 — CHAIN-OF-THOUGHT (CoT)

```
Quero que você gere um teste de integração em Dart para o fluxo do aplicativo Flutter "Sintonize" descrito abaixo. Antes de escrever os testes, siga estes passos:

1. **Analise o fluxo:** Descreva em 3-5 frases o que acontece do início ao fim do fluxo, quais são os pontos de decisão (sucesso/erro) e quais telas estão envolvidas.
2. **Identifique as dependências:** Liste quais serviços (Firebase Auth, Firestore, etc.) são acionados em cada tela e como devem ser mockados.
3. **Monte a estrutura de navegação:** Descreva como configurar o MaterialApp com rotas para que a navegação entre telas funcione nos testes.
4. **Identifique os cenários de teste:** Liste todos os cenários do fluxo completo:
   - Fluxo de sucesso ponta a ponta (interação → navegação → estado final)
   - Erros de validação (campos inválidos antes de disparar Firebase)
   - Erros do Firebase (autenticação falha, Firestore indisponível)
   - Estados intermediários visíveis ao usuário (loading, mensagens de erro)
5. **Escreva os testes:** Para cada cenário, escreva um testWidgets() completo.

IMPORTANTE: Não modifique o código das telas. Apenas gere os testes.

Fluxo a testar:

[DESCREVER O FLUXO EM 1-2 FRASES]

Código das telas envolvidas:

```dart
[COLAR O CÓDIGO DAS TELAS DO FLUXO AQUI]
```

Dependências disponíveis:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito
Use `import 'package:sintonize/...'` para os imports do projeto.
```

---

## Prompt para Iterative Repair Loop

```
O teste de integração falhou com o seguinte erro:

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
| Escopo | Uma tela isolada | Fluxo completo entre 2+ telas |
| O que colar no prompt | Código de 1 widget | Código de 2+ widgets + navegação |
| Navegação | Sem rotas reais | MaterialApp com rotas configuradas |
| Assert principal | Elementos dentro da tela | Tela destino aparece após interação |
| Complexidade esperada | Alta | Muito alta |
| Iterações de repair esperadas | 2-3 | 3 |
