# FASE2-ICRASH-COT

**Bug ID:** I-CRASH | **Nível:** Integração | **Estratégia:** Chain-of-Thought  
**Alvo:** fluxo de cadastro — `GenerosCadastroScreen._salvarGeneros()`  
**Arquivos:** `lib/cadastro.dart` + `lib/generos-cadastro.dart`  
**Conversa nova:** sim — uma conversa por rodada, sem contexto anterior

---

## Prompt (selecionar tudo abaixo desta linha até o próximo `---` e colar no ChatGPT)

---

Quero que você gere um teste de integração em Dart para o fluxo do aplicativo Flutter "Sintonize" descrito abaixo. Antes de escrever os testes, siga estes passos:

1. **Analise o fluxo:** Descreva em 3-5 frases o que acontece do início ao fim do fluxo, quais são os pontos de decisão (sucesso/erro) e quais telas estão envolvidas.
2. **Identifique as dependências:** Liste quais serviços (Firebase Auth, Firestore, etc.) são acionados em cada tela e como devem ser mockados.
3. **Monte a estrutura de navegação:** Descreva como configurar o MaterialApp com rotas para que a navegação entre telas funcione nos testes.
4. **Identifique os cenários de teste:** Liste todos os cenários do fluxo completo:
   - Fluxo de sucesso ponta a ponta (interação → navegação → estado final)
   - Erros de validação (campos inválidos antes de disparar Firebase)
   - Erros do Firebase (autenticação falha, Firestore indisponível)
   - Estados intermediários visíveis ao usuário (loading, mensagens de erro)
   - Cenário com usuário não autenticado ao chegar em GenerosCadastroScreen
5. **Escreva os testes:** Para cada cenário, escreva um testWidgets() completo.

IMPORTANTE: Não modifique o código das telas. Apenas gere os testes.

Fluxo a testar:

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
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confSenhaController = TextEditingController();

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
    return Scaffold(body: Form(key: _formKey, child: SingleChildScrollView(child: Column(children: [
      TextFormField(controller: _nomeController, validator: (v) => (v == null || v.isEmpty) ? 'O nome é obrigatório' : null),
      TextFormField(controller: _emailController, validator: (v) => (v == null || v.isEmpty) ? 'O e-mail é obrigatório' : null),
      TextFormField(controller: _senhaController, obscureText: true,
          validator: (v) => (v == null || v.length < 6) ? 'A senha deve ter pelo menos 6 caracteres' : null),
      TextFormField(controller: _confSenhaController, obscureText: true,
          validator: (v) => v != _senhaController.text ? 'As senhas não coincidem' : null),
      ElevatedButton(onPressed: _submit, child: const Text('Cadastrar')),
    ]))));
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
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito
Use `import 'package:sintonize/...'` para os imports do projeto.

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
