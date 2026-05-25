# INT-FS-02 — Fluxo Cadastro — Few-shot

## Metadados

| Campo                    | Valor                                                          |
| ------------------------ | -------------------------------------------------------------- |
| **ID da Rodada**         | INT-FS-02                                                      |
| **Fluxo testado**        | Cadastro (CadastroScreen → GenerosCadastroScreen)              |
| **Arquivos envolvidos**  | lib/cadastro.dart, lib/generos-cadastro.dart                  |
| **Nível da pirâmide**    | Integration test                                               |
| **Estratégia de prompt** | Few-shot                                                       |
| **LLM utilizado**        | ChatGPT                                                        |
| **Versão do modelo**     | [preencher]                                                    |
| **Data de acesso**       | 2026-05-25                                                     |
| **Conversa nova?**       | Sim (cada rodada em conversa limpa)                            |
| **Framework de teste**   | flutter_test                                                   |
| **Versão do Flutter**    | Flutter 3.41.6 • Dart 3.11.4                                  |

---

## Prompt Enviado

```
Gere um teste de integração em Dart usando flutter_test para o fluxo do aplicativo Flutter "Sintonize" descrito abaixo.

Antes, veja um exemplo de teste de integração que funcionou para o fluxo de login (8/8 testes passando):

**Exemplo — teste de integração do fluxo de login (login_flow_fs_test.dart):**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/recup-senha.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('deve renderizar campos, botões e links', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Esqueci minha senha'), findsOneWidget);
      expect(find.text('Não tem cadastro? Cadastre-se!'), findsOneWidget);
    });

    testWidgets('deve mostrar validação ao tentar login sem email', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.pump();
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
    });

    testWidgets('deve mostrar validação para email inválido', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextFormField).at(0), 'email-invalido');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.pump();
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
    });

    testWidgets('deve mostrar validação para senha curta', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextFormField).at(0), 'teste@email.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.pump();
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
    });

    testWidgets('deve permitir digitar email e senha', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextFormField).at(0), 'usuario@email.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.pump();
      expect(find.text('usuario@email.com'), findsOneWidget);
      expect(find.text('123456'), findsOneWidget);
    });

    testWidgets('link "Não tem cadastro? Cadastre-se!" deve navegar para CadastroScreen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Abrir'),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(LoginScreen), findsOneWidget);
      await tester.ensureVisible(find.text('Não tem cadastro? Cadastre-se!'));
      await tester.pump();
      await tester.tap(find.text('Não tem cadastro? Cadastre-se!'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(CadastroScreen), findsOneWidget);
    });

    testWidgets('link "Esqueci minha senha" deve navegar para RecupSenhaScreen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Abrir'),
                ),
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(LoginScreen), findsOneWidget);
      await tester.tap(find.text('Esqueci minha senha'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(RecupSenhaScreen), findsOneWidget);
    });

    testWidgets('não deve tentar autenticar quando formulário for inválido', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextFormField).at(0), '');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.pump();
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
    });
  });
}
```

---

Agora, gere um teste de integração para o seguinte fluxo:

**Fluxo:** O usuário preenche o formulário de cadastro na CadastroScreen (nome, data de nascimento, email, senha, confirmação de senha e endereço) e, após cadastro bem-sucedido via Firebase, é redirecionado para a GenerosCadastroScreen. A tela também possui o link "Já tem uma conta? Faça login" que navega para a LoginScreen.

**Atenção:**
- O formulário está dentro de um `SingleChildScrollView` — muitos campos ficam fora do viewport. Use `ensureVisible` antes de interagir com campos que possam estar off-screen, especialmente o botão "Cadastrar" e o link "Já tem uma conta? Faça login".
- NÃO teste o submit com campos válidos: a CadastroScreen usa `FirebaseAuth.instance` e `FirebaseFirestore.instance` estáticos (sem injeção de dependência), então o cadastro bem-sucedido não é testável sem inicializar o Firebase real.
- A GenerosCadastroScreen renderiza os gêneros (Rock, Pop, Jazz, Blues, Hip-Hop, Reggae, Country) no `initState` sem chamar Firebase — pode ser testada diretamente com `const MaterialApp(home: GenerosCadastroScreen())`.
- Use `await tester.pump(const Duration(milliseconds: 500))` (nunca `pumpAndSettle`) para evitar timeout por animações Firebase.

Código das telas envolvidas:

[código completo de lib/cadastro.dart e lib/generos-cadastro.dart — omitido aqui por brevidade]

Dependências disponíveis:
- firebase_auth_mocks
- fake_cloud_firestore
- mockito
```

---

## Resposta do LLM (Geração inicial)

```dart
// test/integration/cadastro_flow_test.dart
// (import original: package:seu_app/ — corrigido para package:sintonize/ antes de executar)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seu_app/cadastro.dart';
import 'package:seu_app/generos-cadastro.dart';
import 'package:seu_app/login.dart';

void main() {
  group('CadastroScreen Integration Tests', () {
    testWidgets('deve exibir erros de validação ao tentar cadastrar com formulário vazio', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CadastroScreen()));
      await tester.pump(const Duration(milliseconds: 500));
      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);
    });

    testWidgets('deve validar email inválido', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CadastroScreen()));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.enterText(find.byType(TextFormField).at(0), 'João da Silva');
      await tester.enterText(find.byType(TextFormField).at(1), '01011990');
      await tester.enterText(find.byType(TextFormField).at(2), 'email-invalido');
      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('deve validar senhas diferentes', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: CadastroScreen()));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.enterText(find.byType(TextFormField).at(3), '123456');
      await tester.enterText(find.byType(TextFormField).at(4), '654321');
      final cadastrarButton = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarButton);
      await tester.tap(cadastrarButton);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });

    testWidgets('deve navegar para LoginScreen ao clicar em "Faça login"', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: const CadastroScreen(),
        routes: {'/login': (_) => const LoginScreen()},
      ));
      await tester.pump(const Duration(milliseconds: 500));
      final loginText = find.text('Já tem uma conta? Faça login');
      await tester.ensureVisible(loginText);
      await tester.tap(loginText);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  group('GenerosCadastroScreen Integration Tests', () {
    testWidgets('deve renderizar todos os gêneros musicais', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GenerosCadastroScreen()));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Rock'), findsOneWidget);
      expect(find.text('Pop'), findsOneWidget);
      expect(find.text('Jazz'), findsOneWidget);
      expect(find.text('Blues'), findsOneWidget);
      expect(find.text('Hip-Hop'), findsOneWidget);
      expect(find.text('Reggae'), findsOneWidget);
      expect(find.text('Country'), findsOneWidget);
    });

    testWidgets('deve permitir selecionar um gênero', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GenerosCadastroScreen()));
      await tester.pump(const Duration(milliseconds: 500));
      final rockSwitch = find.descendant(
        of: find.ancestor(of: find.text('Rock'), matching: find.byType(Card)),
        matching: find.byType(Switch),
      );
      expect(tester.widget<Switch>(rockSwitch).value, false);
      await tester.tap(rockSwitch);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.widget<Switch>(rockSwitch).value, true);
    });

    testWidgets('deve exibir snackbar ao confirmar sem selecionar gênero', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: GenerosCadastroScreen()));
      await tester.pump(const Duration(milliseconds: 500));
      final confirmarButton = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarButton);
      await tester.tap(confirmarButton);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Selecione pelo menos um gênero musical!'), findsOneWidget);
    });
  });
}
```

---

## Resultado da Execução (Geração inicial)

| Métrica             | Valor |
| ------------------- | ----- |
| **Compilou?**       | Sim   |
| **Testes gerados**  | 7     |
| **Testes passaram** | 5     |
| **Testes falharam** | 2     |

### Saída do terminal

```
00:00 +0: CadastroScreen Integration Tests deve exibir erros de validação ao tentar cadastrar com formulário vazio
00:01 +1: CadastroScreen Integration Tests deve validar email inválido
00:02 +2: CadastroScreen Integration Tests deve validar senhas diferentes
00:02 +3 -1: CadastroScreen Integration Tests deve navegar para LoginScreen ao clicar em "Faça login" [E]
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 0 widgets with type "LoginScreen": []>
00:03 +3 -2: GenerosCadastroScreen Integration Tests deve renderizar todos os gêneros musicais [E]
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Hip-Hop": []>
00:03 +4: GenerosCadastroScreen Integration Tests deve permitir selecionar um gênero
00:04 +5: GenerosCadastroScreen Integration Tests deve exibir snackbar ao confirmar sem selecionar gênero
00:04 +5 -2: Some tests failed.
```

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:**
  1. Teste de navegação para LoginScreen: `find.byType(LoginScreen)` encontrou 0 widgets — `Navigator.push` com `MaterialPageRoute` não usa rotas nomeadas, um único pump de 500ms foi insuficiente para a transição.
  2. `deve renderizar todos os gêneros musicais`: `find.text('Hip-Hop')` encontrou 0 widgets — `ListView.builder` dentro de `Container(height: MediaQuery.of(context).size.height * 0.5)` não renderiza itens fora da viewport (lazy); `ensureVisible` falha quando o widget ainda não existe na árvore.

- **Prompt de correção enviado:**
```
O teste de integração falhou com o seguinte erro:

00:02 +3 -1: CadastroScreen Integration Tests deve navegar para LoginScreen ao clicar em "Faça login" [E]
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 0 widgets with type "LoginScreen": []>

00:03 +3 -2: GenerosCadastroScreen Integration Tests deve renderizar todos os gêneros musicais [E]
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Hip-Hop": []>

00:04 +5 -2: Some tests failed.

Corrija o teste para que compile e passe corretamente. Não modifique o código das telas, apenas o código do teste.
```

- **Resposta do LLM:** Enfraqueceu a asserção de navegação (usa `find.byType(Scaffold), findsWidgets` em vez de `find.byType(LoginScreen)`); tentou `ensureVisible` em loop para cada gênero — mas `ensureVisible` também falha para itens não construídos pelo `ListView.builder`.

- **Resultado após correção:** 6/7 — navegação passou (asserção fraca); gêneros ainda falharam (`Bad state: No element` no `ensureVisible`).

### Iteração 2

- **Motivo da falha:** `ensureVisible` requer que o widget já esteja na árvore de widgets; itens lazy do `ListView.builder` não existem até serem rolados para a viewport.

- **Prompt de correção enviado:**
```
O teste de integração falhou com o seguinte erro:

00:05 +4 -1: GenerosCadastroScreen Integration Tests deve renderizar todos os gêneros musicais [E]
The following StateError was thrown running a test:
Bad state: No element

#0      Iterable.single (dart:core/iterable.dart:694:25)
#1      WidgetController.element (package:flutter_test/src/controller.dart:883:30)
#2      WidgetController.ensureVisible (package:flutter_test/src/controller.dart:2382:32)
#3      main.<anonymous closure>.<anonymous closure> (cadastro_flow_fs_test.dart:181:24)

00:06 +6 -1: Some tests failed.

Corrija o teste para que compile e passe corretamente. Não modifique o código das telas, apenas o código do teste.
```

- **Resposta do LLM:** Substituiu `ensureVisible` por `scrollUntilVisible` (com `scrollable: find.byType(Scrollable).last`) para todos os itens do ListView — força a rolagem que materializa os itens lazy antes do `expect`.

- **Resultado após correção:** 7/7 — todos os testes passaram.

### Saída final do terminal

```
00:00 +0: CadastroScreen Integration Tests deve exibir erros de validação ao tentar cadastrar com formulário vazio
00:01 +1: CadastroScreen Integration Tests deve validar email inválido
00:02 +2: CadastroScreen Integration Tests deve validar senhas diferentes
00:02 +3: CadastroScreen Integration Tests deve navegar ao clicar em "Faça login"
00:02 +4: GenerosCadastroScreen Integration Tests deve renderizar todos os gêneros musicais
00:03 +5: GenerosCadastroScreen Integration Tests deve permitir selecionar um gênero
00:03 +6: GenerosCadastroScreen Integration Tests deve exibir snackbar ao confirmar sem selecionar gênero
00:03 +7: All tests passed!
```

## Resultado Final

| Métrica             | Valor |
| ------------------- | ----- |
| **Compilou?**       | Sim   |
| **Testes gerados**  | 7     |
| **Testes passaram** | 7     |
| **Testes falharam** | 0     |
| **Iterações**       | 2     |
