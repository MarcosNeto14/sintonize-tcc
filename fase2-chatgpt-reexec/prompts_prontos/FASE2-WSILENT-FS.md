# FASE2-WSILENT-FS

**Bug ID:** W-SILENT | **Nível:** Widget | **Estratégia:** Few-shot  
**Alvo:** `LoginScreen` (`login()` — mapeamento de erros) — `lib/login.dart`  
**Conversa nova:** sim — uma conversa por rodada, sem contexto anterior

---

## Prompt (selecionar tudo abaixo desta linha até o próximo `---` e colar no ChatGPT)

---

Gere widget tests em Dart usando flutter_test para o widget abaixo.

Antes, veja um exemplo de widget test bem escrito para um formulário Flutter com Firebase mockado:

**Exemplo — widget test de formulário de login com mock de Auth:**
```dart
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
        MaterialApp(home: MeuFormulario(auth: mockAuth)),
      );
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      expect(find.text('Campo obrigatório'), findsOneWidget);
    });

    testWidgets('deve exibir mensagem de erro para credenciais inválidas', (tester) async {
      final authComErro = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          signInWithEmailAndPassword: FirebaseAuthException(code: 'wrong-password'),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(home: MeuFormulario(auth: authComErro)),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senhaerrada');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      expect(find.textContaining('incorreta'), findsOneWidget);
    });
  });
}
```

Agora, gere widget tests para este widget, seguindo o mesmo padrão do exemplo:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatelessWidget {
  final FirebaseAuth auth;

  LoginScreen({super.key, FirebaseAuth? auth}) : auth = auth ?? FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final senhaController = TextEditingController();

    Future<void> login(BuildContext context) async {
      if (!formKey.currentState!.validate()) return;
      final email = emailController.text.trim();
      final senha = senhaController.text.trim();
      try {
        await auth.signInWithEmailAndPassword(email: email, password: senha);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TelaInicialScreen()));
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'Senha incorreta. Certifique-se de que está digitando a senha corretamente.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Usuário não encontrado. Verifique o e-mail e tente novamente.';
        } else if (e.code == 'invalid-credential') {
          errorMessage = 'As credenciais fornecidas são inválidas. Tente novamente.';
        } else {
          errorMessage = 'Erro inesperado ao fazer login. Por favor, tente novamente mais tarde.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Image.asset('assets/logo-sintoniza.png', width: 200, height: 200),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor, insira seu e-mail';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Por favor, insira um e-mail válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: senhaController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Por favor, insira sua senha';
                      if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => login(context),
                    child: const Text('Entrar'),
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

O widget faz parte do projeto Flutter "sintonize".

Dependências disponíveis para mocking:
- firebase_auth_mocks
- fake_cloud_firestore
- mockito

---

## Prompt de reparo (usar na **mesma** conversa, se o teste falhar — máx. 3 iterações)

---

O teste falhou com o seguinte erro:

```
[COLAR A SAÍDA DE ERRO DO TERMINAL AQUI]
```

Antes de corrigir, classifique a causa provável da falha:
(A) o teste presume um comportamento que não é o especificado, ou
(B) o teste capturou um comportamento potencialmente incorreto da aplicação.
Declare essa classificação explicitamente antes de prosseguir.

Se (A): corrija o teste normalmente.

Se (B): não enfraqueça a asserção nem reduza o escopo do teste para
fazê-lo passar. Descreva o comportamento observado, o comportamento
esperado, e por que você suspeita de um problema na aplicação, em vez de
alterar o teste.

---
