# INT-COT-01 — Fluxo Login — Chain-of-Thought

## Metadados

| Campo                    | Valor                                                          |
| ------------------------ | -------------------------------------------------------------- |
| **ID da Rodada**         | INT-COT-01                                                     |
| **Fluxo testado**        | Login (LoginScreen → RecupSenhaScreen / CadastroScreen)        |
| **Arquivos envolvidos**  | lib/login.dart, lib/recup-senha.dart                          |
| **Nível da pirâmide**    | Integration test                                               |
| **Estratégia de prompt** | Chain-of-Thought                                               |
| **LLM utilizado**        | ChatGPT                                                        |
| **Versão do modelo**     | GPT-5.5                                                        |
| **Data de acesso**       | 2026-05-25                                                     |
| **Conversa nova?**       | Sim (cada rodada em conversa limpa)                            |
| **Framework de teste**   | flutter_test                                                   |
| **Versão do Flutter**    | Flutter 3.41.6 • Dart 3.11.4                                  |

---

## Prompt Enviado

```
Quero que você gere um teste de integração em Dart para o fluxo do aplicativo Flutter "Sintonize" descrito abaixo. Antes de escrever os testes, siga estes passos:

1. Analise o fluxo: Descreva em 3-5 frases o que acontece do início ao fim do fluxo, quais são os pontos de decisão (sucesso/erro) e quais telas estão envolvidas.
2. Identifique as dependências: Liste quais serviços (Firebase Auth, Firestore, etc.) são acionados em cada tela e como devem ser mockados.
3. Monte a estrutura de navegação: Descreva como configurar o MaterialApp com rotas para que a navegação entre telas funcione nos testes.
4. Identifique os cenários de teste: Liste todos os cenários do fluxo completo.
5. Escreva os testes: Para cada cenário, escreva um testWidgets() completo.

IMPORTANTE: Não modifique o código das telas. Apenas gere os testes.

Fluxo a testar: O usuário preenche email e senha na LoginScreen e tenta autenticar. Em caso de sucesso, é redirecionado para TelaInicialScreen. Em caso de erro de validação local, mensagens aparecem nos campos. Em caso de erro do Firebase, um SnackBar é exibido. A tela também possui dois links de navegação: "Esqueci minha senha" (→ RecupSenhaScreen) e "Não tem cadastro? Cadastre-se!" (→ CadastroScreen).

Restrição crítica: A LoginScreen chama FirebaseAuth.instance.signInWithEmailAndPassword() de forma estática. Não teste o fluxo de login bem-sucedido. Teste apenas: validações de formulário, links de navegação e renderização da tela.

Use await tester.pump(const Duration(seconds: 1)) após pumpWidget. Nunca use pumpAndSettle. Para navegação use o padrão Builder + Navigator.push + dois pumps.

[código completo de lib/login.dart e lib/recup-senha.dart]

Dependências disponíveis: firebase_auth_mocks, fake_cloud_firestore, mockito.
Use import 'package:sintonize/...' para os imports do projeto.
```

---

## Resposta do LLM (raciocínio CoT + código)

### 1. Análise do fluxo

O fluxo começa na LoginScreen, onde o usuário informa e-mail e senha e pode tentar autenticar ao tocar em "Entrar". Antes de chamar o Firebase, o formulário executa validações locais: e-mail obrigatório/formato válido e senha obrigatória/com mínimo de 6 caracteres. Caso a autenticação fosse bem-sucedida, o usuário seria redirecionado para TelaInicialScreen; porém, devido à restrição da chamada estática de FirebaseAuth.instance, esse fluxo não deve ser testado. Em caso de falha no Firebase, a tela exibe um SnackBar com mensagem de erro. A tela também possui navegação secundária para RecupSenhaScreen ("Esqueci minha senha") e CadastroScreen ("Não tem cadastro? Cadastre-se!").

### 2. Dependências envolvidas

| Tela | Dependência | Uso | Estratégia no teste |
|---|---|---|---|
| LoginScreen | FirebaseAuth | signInWithEmailAndPassword() | Não mockar para sucesso. Apenas evitar fluxo válido. |
| LoginScreen | Navigator | Navegação para recuperação/cadastro/home | Usar MaterialApp com rotas/fakes |
| LoginScreen | ScaffoldMessenger | Exibição de SnackBar | Validar presença do texto |
| RecupSenhaScreen | ScaffoldMessenger | Snackbar de recuperação | Validar mensagem |
| RecupSenhaScreen | Navigator | Voltar para login | Validar navegação |

### 3. Estrutura de navegação

MaterialApp com `home: LoginScreen()` e rotas auxiliares para `/cadastro` e `/home`. Como as telas usam MaterialPageRoute diretamente, o padrão de dois pumps é necessário após cada tap de navegação.

### 4. Cenários identificados

- Renderização: logo, campos, botão, links
- Validação: e-mail vazio, e-mail inválido, senha vazia, senha curta
- Navegação: "Esqueci minha senha" → RecupSenhaScreen; "Não tem cadastro?" → CadastroScreen
- RecupSenhaScreen: renderização, validação e-mail vazio, snackbar de recuperação, "Voltar para Login"
- NÃO testado: login com sucesso, navegação para TelaInicialScreen, mock completo de FirebaseAuth estático

### 5. Código gerado

```dart
// test/integration/login_flow_cot_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/recup-senha.dart';

void main() {
  Widget createApp(Widget child) {
    return MaterialApp(home: child);
  }

  group('LoginScreen - Renderização', () {
    testWidgets('deve renderizar elementos principais da tela', (tester) async {
      await tester.pumpWidget(createApp(const LoginScreen()));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Esqueci minha senha'), findsOneWidget);
      expect(find.text('Não tem cadastro? Cadastre-se!'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });

  group('LoginScreen - Validações', () {
    testWidgets('deve validar e-mail vazio', (tester) async {
      await tester.pumpWidget(createApp(const LoginScreen()));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
    });

    testWidgets('deve validar e-mail inválido', (tester) async {
      await tester.pumpWidget(createApp(const LoginScreen()));
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextFormField).at(0), 'email-invalido');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
    });

    testWidgets('deve validar senha vazia', (tester) async {
      await tester.pumpWidget(createApp(const LoginScreen()));
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextFormField).at(0), 'teste@email.com');
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
    });

    testWidgets('deve validar senha curta', (tester) async {
      await tester.pumpWidget(createApp(const LoginScreen()));
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextFormField).at(0), 'teste@email.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
    });
  });

  group('LoginScreen - Navegação', () {
    testWidgets('deve navegar para RecupSenhaScreen ao tocar em "Esqueci minha senha"', (tester) async {
      await tester.pumpWidget(createApp(const LoginScreen()));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Esqueci minha senha'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(RecupSenhaScreen), findsOneWidget);
    });

    testWidgets('deve navegar para tela de cadastro ao tocar em cadastro', (tester) async {
      await tester.pumpWidget(createApp(Builder(builder: (context) => const LoginScreen())));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Não tem cadastro? Cadastre-se!'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('RecupSenhaScreen', () {
    testWidgets('deve renderizar elementos da tela', (tester) async {
      await tester.pumpWidget(createApp(const RecupSenhaScreen()));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Digite seu e-mail'), findsOneWidget);
      expect(find.text('Recuperar Senha'), findsOneWidget);
      expect(find.text('Voltar para Login'), findsOneWidget);
    });

    testWidgets('deve validar email vazio', (tester) async {
      await tester.pumpWidget(createApp(const RecupSenhaScreen()));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Recuperar Senha'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
    });

    testWidgets('deve mostrar snackbar ao enviar recuperação com email válido', (tester) async {
      await tester.pumpWidget(createApp(const RecupSenhaScreen()));
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextFormField), 'teste@email.com');
      await tester.tap(find.text('Recuperar Senha'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Link de recuperação enviado!'), findsOneWidget);
    });

    testWidgets('deve voltar para LoginScreen ao tocar em voltar', (tester) async {
      await tester.pumpWidget(createApp(const RecupSenhaScreen()));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Voltar para Login'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
```

---

## Resultado da Execução

| Métrica             | Valor |
| ------------------- | ----- |
| **Compilou?**       | Sim   |
| **Testes gerados**  | 11    |
| **Testes passaram** | 11    |
| **Testes falharam** | 0     |
| **Iterações**       | 0     |

### Saída do terminal

```
00:00 +0: LoginScreen - Renderização deve renderizar elementos principais da tela
00:01 +1: LoginScreen - Validações deve validar e-mail vazio
00:01 +2: LoginScreen - Validações deve validar e-mail inválido
00:01 +3: LoginScreen - Validações deve validar senha vazia
00:01 +4: LoginScreen - Validações deve validar senha curta
00:01 +5: LoginScreen - Navegação deve navegar para RecupSenhaScreen ao tocar em "Esqueci minha senha"
00:02 +6: LoginScreen - Navegação deve navegar para tela de cadastro ao tocar em cadastro

Warning: A call to tap() with finder "Found 1 widget with text "Não tem cadastro? Cadastre-se!"..." derived an Offset (Offset(400.0, 664.0)) that would not hit test on the specified widget. The widget is off-screen (root size 800x600).

00:02 +7: RecupSenhaScreen deve renderizar elementos da tela
00:02 +8: RecupSenhaScreen deve validar email vazio
00:02 +9: RecupSenhaScreen deve mostrar snackbar ao enviar recuperação com email válido
00:02 +10: RecupSenhaScreen deve voltar para LoginScreen ao tocar em voltar
00:02 +11: All tests passed!
```

**Nota:** O warning no teste 7 indica que "Não tem cadastro? Cadastre-se!" está fora do viewport (offset Y=664 > altura 600). O tap ocorreu mesmo assim e a navegação aconteceu; o expect usa `find.byType(Scaffold), findsWidgets` — asserção fraca que não verifica se CadastroScreen foi carregada. Comportamento esperado dado o formulário dentro de SingleChildScrollView sem ensureVisible.

---

## Iterative Repair Loop

Não necessário — 11/11 na geração inicial.
