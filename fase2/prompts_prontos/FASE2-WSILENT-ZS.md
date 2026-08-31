# FASE2-WSILENT-ZS

**Bug ID:** W-SILENT | **Nível:** Widget | **Estratégia:** Zero-shot  
**Alvo:** `LoginScreen` (`login()` — mapeamento de erros) — `lib/login.dart`  
**Conversa nova:** sim — uma conversa por rodada, sem contexto anterior

---

## Prompt (selecionar tudo abaixo desta linha até o próximo `---` e colar no ChatGPT)

---

Gere widget tests em Dart usando o pacote flutter_test para o seguinte widget Flutter:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cadastro.dart';
import 'recup-senha.dart';
import 'tela-inicial.dart';

class LoginScreen extends StatelessWidget {
  final FirebaseAuth auth;

  LoginScreen({
    super.key,
    FirebaseAuth? auth,
  }) : auth = auth ?? FirebaseAuth.instance;

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
        await auth
            .signInWithEmailAndPassword(email: email, password: senha);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TelaInicialScreen()),
        );
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
                  Image.asset('assets/logo-sintoniza.png', width: 200, height: 200),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9E80), Color(0xFFF14621)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('E-mail', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                              const Text('Senha', style: TextStyle(color: Colors.white, fontSize: 16)),
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
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text('Entrar',
                                  style: TextStyle(color: Color(0xFFF14621), fontSize: 18)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => const RecupSenhaScreen()));
                            },
                            child: const Text('Esqueci minha senha',
                                style: TextStyle(color: Colors.white, fontSize: 16)),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => CadastroScreen()));
                            },
                            child: const Text('Não tem cadastro? Cadastre-se!',
                                style: TextStyle(color: Colors.white, fontSize: 16)),
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
- Configure os mocks necessários para Firebase Auth
- Teste cenários de validação de formulário (campos vazios, dados inválidos)
- Teste interações do usuário (tap em botões, entrada de texto)
- Teste as mensagens de erro retornadas para diferentes códigos de exceção do Firebase Auth
- Os testes devem ser executáveis com `flutter test`
- Use `import 'package:sintonize/login.dart';` para importar o widget

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
