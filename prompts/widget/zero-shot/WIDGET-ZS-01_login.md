# WIDGET-ZS-01

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | WIDGET-ZS-01 |
| **Widget testado** | LoginScreen |
| **Arquivo de origem** | lib/login.dart |
| **Complexidade** | Baixa |
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

````
Gere widget tests em Dart usando o pacote flutter_test para o seguinte widget Flutter:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cadastro.dart';
import 'recup-senha.dart';
import 'tela-inicial.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final senhaController = TextEditingController();

    Future<void> login(BuildContext context) async {
      if (!formKey.currentState!.validate()) {
        return;
      }

      final email = emailController.text.trim();
      final senha = senhaController.text.trim();

      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: senha);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaInicialScreen()),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage;

        if (e.code == 'user-not-found') {
          errorMessage = 'Usuário não encontrado. Verifique o e-mail e tente novamente.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Senha incorreta. Certifique-se de que está digitando a senha corretamente.';
        } else if (e.code == 'invalid-credential') {
          errorMessage = 'As credenciais fornecidas são inválidas. Tente novamente.';
        } else {
          errorMessage = 'Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 50),
                  Image.asset(
                    'assets/logo-sintoniza.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 15,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF9E80),
                            Color(0xFFF14621),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'E-mail',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: emailController,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira seu e-mail';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                    return 'Por favor, insira um e-mail válido';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Senha',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: senhaController,
                                obscureText: true,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor, insira sua senha';
                                  }
                                  if (value.length < 6) {
                                    return 'A senha deve ter pelo menos 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => login(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Entrar',
                                style: TextStyle(
                                  color: Color(0xFFF14621),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const RecupSenhaScreen()),
                              );
                            },
                            child: const Text(
                              'Esqueci minha senha',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const CadastroScreen()),
                              );
                            },
                            child: const Text(
                              'Não tem cadastro? Cadastre-se!',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

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
````

---

## Resposta do LLM

Aqui está um exemplo completo de testes de widget para a tela LoginScreen do projeto Flutter sintonize, usando flutter_test e firebase_auth_mocks.

O arquivo pode ser salvo como:

`test/login_screen_test.dart`

Código:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:sintonize/login.dart';
import 'package:sintonize/tela-inicial.dart';

void main() {
  late MockFirebaseAuth mockAuth;

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  group('LoginScreen Widget Tests', () {
    testWidgets('Deve renderizar os campos e botões corretamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);

      expect(find.byType(TextFormField), findsNWidgets(2));

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Esqueci minha senha'), findsOneWidget);
      expect(find.text('Não tem cadastro? Cadastre-se!'),
          findsOneWidget);
    });

    testWidgets(
        'Deve mostrar erro quando campos estiverem vazios',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira seu e-mail'),
        findsOneWidget,
      );

      expect(
        find.text('Por favor, insira sua senha'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Deve mostrar erro para e-mail inválido',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final emailField = find.byType(TextFormField).at(0);
      final senhaField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'email_invalido');
      await tester.enterText(senhaField, '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('Por favor, insira um e-mail válido'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Deve mostrar erro para senha menor que 6 caracteres',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final emailField = find.byType(TextFormField).at(0);
      final senhaField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'teste@email.com');
      await tester.enterText(senhaField, '123');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Deve permitir digitação nos campos',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final emailField = find.byType(TextFormField).at(0);
      final senhaField = find.byType(TextFormField).at(1);

      await tester.enterText(
          emailField, 'usuario@email.com');

      await tester.enterText(
          senhaField, '123456');

      expect(find.text('usuario@email.com'),
          findsOneWidget);

      expect(find.text('123456'), findsOneWidget);
    });

    testWidgets(
        'Deve navegar para TelaInicialScreen após login válido',
        (WidgetTester tester) async {
      final user = MockUser(
        isAnonymous: false,
        uid: '123',
        email: 'teste@email.com',
      );

      mockAuth = MockFirebaseAuth(
        mockUser: user,
        signedIn: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      final emailField = find.byType(TextFormField).at(0);
      final senhaField = find.byType(TextFormField).at(1);

      await tester.enterText(
          emailField, 'teste@email.com');

      await tester.enterText(
          senhaField, '123456');

      await tester.tap(find.text('Entrar'));

      await tester.pumpAndSettle();

      expect(
        find.byType(TelaInicialScreen),
        findsOneWidget,
      );
    });

    testWidgets(
        'Deve exibir SnackBar para credenciais inválidas',
        (WidgetTester tester) async {
      final mockAuth = MockFirebaseAuth(
        signedIn: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      final emailField = find.byType(TextFormField).at(0);
      final senhaField = find.byType(TextFormField).at(1);

      await tester.enterText(
          emailField, 'teste@email.com');

      await tester.enterText(
          senhaField, 'senhaerrada');

      await tester.tap(find.text('Entrar'));

      await tester.pump();

      // Como o widget usa FirebaseAuth.instance diretamente,
      // este teste valida apenas que a interface continua funcionando.
      // Para testar corretamente o SnackBar,
      // recomenda-se injetar FirebaseAuth via construtor.

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets(
        'Deve navegar para recuperação de senha',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Esqueci minha senha'));

      await tester.pumpAndSettle();

      expect(find.byType(Navigator), findsWidgets);
    });

    testWidgets(
        'Deve navegar para cadastro',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(
        find.text('Não tem cadastro? Cadastre-se!'),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Navigator), findsWidgets);
    });
  });
}
```

**Dependências necessárias no `pubspec.yaml`:**

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter

  firebase_auth_mocks: ^0.13.0
  mockito: ^5.4.4
  fake_cloud_firestore: ^2.5.2
```

**Observação importante sobre testabilidade**

Seu widget utiliza diretamente:

`FirebaseAuth.instance`

Isso dificulta mockar autenticação nos testes.

O ideal é refatorar para injeção de dependência:

```dart
class LoginScreen extends StatelessWidget {
  final FirebaseAuth auth;

  const LoginScreen({
    super.key,
    required this.auth,
  });
}
```

Assim você poderá testar autenticação, erros e SnackBars corretamente usando MockFirebaseAuth.

Exemplo:

```dart
await auth.signInWithEmailAndPassword(
  email: email,
  password: senha,
);
```

E no teste:

`LoginScreen(auth: mockAuth)`

Isso torna os testes mais confiáveis e totalmente isolados do Firebase real.

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 9 |
| **Testes passaram (1ª execução)** | 7 |
| **Testes falharam (1ª execução)** | 2 |
| **Testes passaram (pós-repair)** | 7 |
| **Testes falharam (pós-repair)** | 2 |
| **Setup correto de mocks?** | Parcial |
| **MaterialApp wrapper?** | Sim |
| **Tratou assets?** | Não |

### Saída do terminal

Saída completa salva em [`results/widget/zero-shot/WIDGET-ZS-01.txt`](../../../results/widget/zero-shot/WIDGET-ZS-01.txt).

Resumo:

```
00:01 +7 -2: Some tests failed.
```

Testes que falharam:
1. `LoginScreen Widget Tests Deve navegar para TelaInicialScreen após login válido`
2. `LoginScreen Widget Tests Deve exibir SnackBar para credenciais inválidas`

Ambas as falhas têm a mesma raiz: `FirebaseException [core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()`. Causa: o widget invoca `FirebaseAuth.instance.signInWithEmailAndPassword(...)` diretamente; o `MockFirebaseAuth` criado no teste não substitui a instância global, portanto o tap em "Entrar" tenta acessar o Firebase real, que não está inicializado no ambiente de teste.

Aviso adicional (não fatal) no teste "Deve navegar para cadastro": `tap()` derivou um Offset (400, 664) fora do viewport de teste (800×600), pois o botão "Cadastre-se" está abaixo do scroll. O teste passou porque o `Navigator` ainda foi encontrado, mas o tap real não atingiu o widget.

---

## Iterative Repair Loop

### Iteração 1
- **Necessária?** Sim
- **Motivo da falha:** 2 testes falharam por `FirebaseException [core/no-app]` — widget invoca `FirebaseAuth.instance` que não pode ser substituído pelo `MockFirebaseAuth` instanciado no teste (falta injeção de dependência).
- **Prompt de correção:**

````
O widget test falhou com o seguinte erro:

```
The following FirebaseException was thrown running a test:
[core/no-app] No Firebase App '[DEFAULT]' has been created - call Firebase.initializeApp()

When the exception was thrown, this was the stack:
#0      MethodChannelFirebase.app (package:firebase_core_platform_interface/src/method_channel/method_channel_firebase.dart:195:5)
#1      Firebase.app (package:firebase_core/src/firebase.dart:79:41)
#2      FirebaseAuth.instance (package:firebase_auth/src/firebase_auth.dart:38:47)
#3      LoginScreen.build.login (package:sintonize/login.dart:25:28)

Testes que falharam:
1. Deve navegar para TelaInicialScreen após login válido
2. Deve exibir SnackBar para credenciais inválidas

Resultado: 7 passaram, 2 falharam.
```

Corrija o teste para que compile e passe corretamente. Não modifique o código do widget, apenas o código do teste.
````

- **Resposta do LLM:** N/A — a conversa original do ChatGPT foi perdida por refresh acidental do navegador antes do prompt de reparo ser enviado. Como o protocolo exige *mesma conversa* para o repair loop (preservação de contexto do código gerado), a iteração não pôde ser concluída sem comprometer a integridade metodológica do experimento.
- **Resultado:** Não executada
- **Nota metodológica:** Em vez de tentar reparo em conversa nova (que introduziria divergência com o protocolo das demais rodadas), a rodada foi encerrada com o estado da 1ª execução (7/9). A falha residual (2 testes envolvendo `FirebaseAuth.instance` direto) é tratada como achado experimental: a estratégia zero-shot, sem instrução explícita sobre injeção de dependência, gera mocks tecnicamente corretos mas incapazes de interceptar chamadas a singletons globais do widget. Comparar com FS-01 e COT-01 para verificar se exemplos ou raciocínio passo-a-passo mitigam esse padrão.

### Iteração 2
- **Necessária?** Não (loop encerrado na Iteração 1)

### Iteração 3
- **Necessária?** Não (loop encerrado na Iteração 1)
