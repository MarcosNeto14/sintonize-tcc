# FASE2-ICRASH-FS

**Bug ID:** I-CRASH | **Nível:** Integração | **Estratégia:** Few-shot  
**Alvo:** fluxo de cadastro — `GenerosCadastroScreen._salvarGeneros()`  
**Arquivos:** `lib/cadastro.dart` + `lib/generos-cadastro.dart`  
**Conversa nova:** sim — uma conversa por rodada, sem contexto anterior

---

## Prompt (selecionar tudo abaixo desta linha até o próximo `---` e colar no ChatGPT)

---

Gere um teste de integração em Dart usando flutter_test para o fluxo do aplicativo Flutter "Sintonize" descrito abaixo.

Antes, veja um exemplo de teste de integração que cobre um fluxo de login:

**Exemplo — teste de integração do fluxo de login:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('Fluxo de Login', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: false);
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets('fluxo completo: login bem-sucedido navega para Home', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/': (_) => LoginScreen(auth: mockAuth, firestore: fakeFirestore),
            '/home': (_) => const HomeScreen(),
          },
        ),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senha123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('credenciais inválidas exibem mensagem de erro', (tester) async {
      final authComErro = MockFirebaseAuth(
        authExceptions: AuthExceptions(
          signInWithEmailAndPassword: FirebaseAuthException(code: 'wrong-password'),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(home: LoginScreen(auth: authComErro, firestore: fakeFirestore)),
      );
      await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'errada');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      expect(find.textContaining('inválid'), findsOneWidget);
    });
  });
}
```

Agora, gere um teste de integração para o seguinte fluxo:

O usuário preenche o formulário de cadastro na CadastroScreen, cria sua conta com Firebase Auth e é redirecionado para a GenerosCadastroScreen, onde seleciona gêneros musicais e tenta salvá-los no Firestore.

Código das telas envolvidas:

```dart
// ─── lib/cadastro.dart ───────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'generos-cadastro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CadastroScreen extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  CadastroScreen({super.key, FirebaseAuth? auth, FirebaseFirestore? firestore})
      : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance;
  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _dataNascController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confSenhaController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _cepController = TextEditingController();
  String? _estadoSelecionado;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await widget.auth.createUserWithEmailAndPassword(
          email: _emailController.text, password: _senhaController.text,
        );
        String uid = userCredential.user!.uid;
        await widget.firestore.collection('usuarios').doc(uid).set({
          'nome': _nomeController.text, 'email': _emailController.text,
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) => GenerosCadastroScreen()));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao cadastrar: ${e.message}")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro desconhecido: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(key: _formKey, child: SingleChildScrollView(child: Column(children: [
        TextFormField(controller: _nomeController, validator: (v) => (v == null || v.isEmpty) ? 'O nome é obrigatório' : null),
        TextFormField(controller: _emailController, validator: (v) => (v == null || v.isEmpty) ? 'O e-mail é obrigatório' : null),
        TextFormField(controller: _senhaController, obscureText: true,
            validator: (v) => (v == null || v.length < 6) ? 'A senha deve ter pelo menos 6 caracteres' : null),
        TextFormField(controller: _confSenhaController, obscureText: true,
            validator: (v) => v != _senhaController.text ? 'As senhas não coincidem' : null),
        ElevatedButton(onPressed: _submit, child: const Text('Cadastrar')),
      ]))),
    );
  }
}

// ─── lib/generos-cadastro.dart ───────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GenerosCadastroScreen extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  GenerosCadastroScreen({super.key, FirebaseAuth? auth, FirebaseFirestore? firestore})
      : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance;
  @override
  _GenerosCadastroScreenState createState() => _GenerosCadastroScreenState();
}

class _GenerosCadastroScreenState extends State<GenerosCadastroScreen> {
  final List<String> generos = ['Rock','Pop','Jazz','Blues','Hip-Hop','Reggae','Country'];
  final Map<String, bool> selecionados = {};

  @override
  void initState() {
    super.initState();
    for (var g in generos) { selecionados[g] = false; }
  }

  Future<void> _salvarGeneros() async {
    final uid = widget.auth.currentUser!.uid;
    try {
      final selecionadosList = selecionados.entries.where((e) => e.value).map((e) => e.key).toList();
      await widget.firestore.collection('usuarios').doc(uid).update({'generos_favoritos': selecionadosList});
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TelaInicialScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar os gêneros!')));
    }
  }

  void _confirmar() {
    if (selecionados.values.contains(true)) { _salvarGeneros(); }
    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione pelo menos um gênero musical!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [
      ...generos.map((g) => SwitchListTile(
        title: Text(g), value: selecionados[g]!,
        onChanged: (v) { setState(() { selecionados[g] = v; }); },
      )),
      ElevatedButton(onPressed: _confirmar, child: const Text('Confirmar')),
    ]));
  }
}
```

Dependências disponíveis:
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
