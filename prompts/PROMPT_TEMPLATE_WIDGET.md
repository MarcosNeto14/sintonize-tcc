# Templates de Prompt — Widget Tests

**Projeto:** Sintonize (Flutter + Firebase)
**Nível:** Integração (Widget Tests)
**Total de rodadas:** 9 (3 widgets × 3 estratégias)

**Instruções de uso:**
1. Copie o template da estratégia desejada
2. Substitua `[COLAR O CÓDIGO COMPLETO DO WIDGET AQUI]` pelo conteúdo completo do arquivo `.dart` do widget-alvo
3. Cole no ChatGPT em uma **conversa nova**
4. Documente tudo no arquivo `WIDGET-XX-NN` correspondente em `prompts/widget/{zero-shot,few-shot,cot}/`

---

## Estratégia 1 — ZERO-SHOT

```
Gere widget tests em Dart usando o pacote flutter_test para o seguinte widget Flutter:

\```dart
[COLAR O CÓDIGO COMPLETO DO WIDGET AQUI]
\```

O widget faz parte de um projeto Flutter chamado "sintonize". 

Dependências disponíveis para mocking:
- firebase_auth_mocks (para mockar FirebaseAuth)
- fake_cloud_firestore (para mockar Firestore)
- mockito (para mocks gerais)

Requisitos:
- Use testWidgets() do flutter_test
- Envolva o widget em MaterialApp para suportar navegação
- Configure os mocks necessários para Firebase Auth e/ou Firestore
- Teste cenários de validação de formulário (campos vazios, dados inválidos)
- Teste interações do usuário (tap em botões, entrada de texto)
- Os testes devem ser executáveis com `flutter test`
- Use `import 'package:sintonize/...'` para os imports do projeto
```

---

## Estratégia 2 — FEW-SHOT

```
Gere widget tests em Dart usando flutter_test para o widget abaixo.

Antes, veja um exemplo de widget test bem escrito para um formulário Flutter com Firebase mockado:

**Exemplo — widget test de formulário de login:**
\```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  group('MeuFormulario Widget', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    testWidgets('deve mostrar erro quando email está vazio', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MeuFormulario()),
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Campo obrigatório'), findsOneWidget);
    });

    testWidgets('deve mostrar erro para email inválido', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MeuFormulario()),
      );

      await tester.enterText(find.byType(TextFormField).first, 'invalido');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Email inválido'), findsOneWidget);
    });
  });
}
\```

Agora, gere widget tests para este widget, seguindo o mesmo padrão do exemplo:

\```dart
[COLAR O CÓDIGO COMPLETO DO WIDGET AQUI]
\```

O widget faz parte do projeto Flutter "sintonize".

Dependências disponíveis para mocking:
- firebase_auth_mocks
- fake_cloud_firestore
- mockito
```

---

## Estratégia 3 — CHAIN-OF-THOUGHT (CoT)

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

\```dart
[COLAR O CÓDIGO COMPLETO DO WIDGET AQUI]
\```

O widget faz parte do projeto Flutter "sintonize".
Use `import 'package:sintonize/...'` para os imports.

Dependências disponíveis para mocking:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito
```

---

## Ordem de execução dos widgets

| # | Widget | Arquivo para colar no prompt | Complexidade |
|---|---|---|---|
| 01 | LoginScreen | lib/login.dart (219 linhas) | Baixa |
| 02 | CriarPlaylistScreen | lib/criar_playlist.dart (254 linhas) | Média |
| 03 | CadastroScreen | lib/cadastro.dart (484 linhas) | Alta |

---

## Prompt para Iterative Repair Loop

```
O widget test falhou com o seguinte erro:

\```
[COLAR A SAÍDA DE ERRO DO TERMINAL AQUI]
\```

Corrija o teste para que compile e passe corretamente. Não modifique o código do widget, apenas o código do teste.
```

**Limite:** máximo 3 iterações de reparo por rodada.

---

## Diferenças em relação aos testes unitários

| Aspecto | Testes Unitários | Widget Tests |
|---|---|---|
| O que colar no prompt | Código de 1 função (5-20 linhas) | Código do widget inteiro (219-484 linhas) |
| Setup necessário | Nenhum | MaterialApp wrapper + mocks de Firebase |
| Tipo de assert | expect(valor, matcher) | expect(find.text(...), findsOneWidget) |
| Interação | Nenhuma | tester.tap, tester.enterText, tester.pump |
| Complexidade esperada | Baixa | Alta |
| Iterações de repair esperadas | 0-1 | 2-3 |
