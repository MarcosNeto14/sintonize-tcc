# FASE2-ICRASH-ZS

**Bug ID:** I-CRASH | **Nível:** Integração | **Estratégia:** Zero-shot  
**Alvo:** fluxo de cadastro — `GenerosCadastroScreen._salvarGeneros()`  
**Arquivos:** `lib/cadastro.dart` + `lib/generos-cadastro.dart`  
**Conversa nova:** sim — uma conversa por rodada, sem contexto anterior

---

## Prompt (selecionar tudo abaixo desta linha até o próximo `---` e colar no ChatGPT)

---

Gere um teste de integração em Dart usando flutter_test para o seguinte fluxo do aplicativo Flutter "Sintonize":

O usuário preenche o formulário de cadastro na CadastroScreen, cria sua conta com Firebase Auth e é redirecionado para a GenerosCadastroScreen, onde seleciona gêneros musicais e tenta salvá-los no Firestore.

Código das telas envolvidas:

```dart
// ─── lib/cadastro.dart ───────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'generos-cadastro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroScreen extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  CadastroScreen({
    super.key,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : auth = auth ?? FirebaseAuth.instance,
       firestore = firestore ?? FirebaseFirestore.instance;

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataNascController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confSenhaController = TextEditingController();
  final TextEditingController _ruaController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();

  String? _estadoSelecionado;

  final List<String> _estados = [
    "AC","AL","AP","AM","BA","CE","DF","ES","GO","MA","MT","MS","MG",
    "PA","PB","PR","PE","PI","RJ","RN","RS","RO","RR","SC","SP","SE","TO"
  ];

  Future<void> _fetchAddressFromCEP(String cep) async {
    final url = Uri.parse('https://viacep.com.br/ws/$cep/json/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['erro'] == null) {
          setState(() {
            _ruaController.text = data['logradouro'];
            _bairroController.text = data['bairro'];
            _cidadeController.text = data['localidade'];
            _estadoSelecionado = data['uf'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('CEP não encontrado')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')));
    }
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) return 'A data de nascimento é obrigatória';
    final parts = value.split('/');
    if (parts.length != 3) return 'Formato inválido. Use dd/mm/aaaa';
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null)
      return 'Data inválida. Certifique-se de que todos os campos são números';
    if (month < 1 || month > 12) return 'Mês deve ser entre 01 e 12';
    final maxDay = DateTime(year, month + 1, 0).day;
    if (day < 1 || day > maxDay) return 'Dia deve ser entre 01 e $maxDay';
    final date = DateTime(year, month, day);
    if (date.isAfter(DateTime.now())) return 'A data não pode ser no futuro';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'O e-mail é obrigatório';
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(pattern).hasMatch(value)) return 'E-mail inválido';
    return null;
  }

  String? _validateCEP(String? value) {
    if (value == null || value.isEmpty) return 'O CEP é obrigatório';
    if (value.length != 9 || !RegExp(r'^\d{5}-\d{3}$').hasMatch(value))
      return 'CEP inválido. Formato correto: XXXXX-XXX';
    return null;
  }

  String? _validateNumero(String? value) {
    if (value == null || value.isEmpty) return 'O número é obrigatório';
    if (int.tryParse(value) == null) return 'O número deve ser numérico';
    return null;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await widget.auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _senhaController.text,
        );
        String uid = userCredential.user!.uid;
        await widget.firestore.collection('usuarios').doc(uid).set({
          'nome': _nomeController.text,
          'data_nasc': _dataNascController.text,
          'email': _emailController.text,
          'endereco': {
            'rua': _ruaController.text,
            'numero': _numeroController.text,
            'bairro': _bairroController.text,
            'cidade': _cidadeController.text,
            'estado': _estadoSelecionado,
            'cep': _cepController.text,
          },
        });
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => GenerosCadastroScreen()));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro ao cadastrar: ${e.message}")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro desconhecido: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (build method com formulário completo)
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(children: [
            TextFormField(controller: _nomeController,
                validator: (v) => (v == null || v.isEmpty) ? 'O nome é obrigatório' : null),
            TextFormField(controller: _dataNascController, validator: _validateDate),
            TextFormField(controller: _emailController, validator: _validateEmail),
            TextFormField(controller: _senhaController,
                obscureText: true,
                validator: (v) => (v == null || v.length < 6) ? 'A senha deve ter pelo menos 6 caracteres' : null),
            TextFormField(controller: _confSenhaController,
                obscureText: true,
                validator: (v) => v != _senhaController.text ? 'As senhas não coincidem' : null),
            TextFormField(controller: _cepController, validator: _validateCEP),
            TextFormField(controller: _ruaController),
            TextFormField(controller: _numeroController, validator: _validateNumero),
            TextFormField(controller: _bairroController),
            TextFormField(controller: _cidadeController),
            ElevatedButton(onPressed: _submit, child: const Text('Cadastrar')),
          ]),
        ),
      ),
    );
  }
}

// ─── lib/generos-cadastro.dart ───────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela-inicial.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GenerosCadastroScreen extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  GenerosCadastroScreen({
    super.key,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : auth = auth ?? FirebaseAuth.instance,
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
    for (var genero in generos) { selecionados[genero] = false; }
  }

  Future<void> _salvarGeneros() async {
    final uid = widget.auth.currentUser!.uid;

    try {
      final generosSelecionados = selecionados.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      await widget.firestore
          .collection('usuarios')
          .doc(uid)
          .update({'generos_favoritos': generosSelecionados});

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const TelaInicialScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar os gêneros!')));
    }
  }

  void _confirmar() {
    if (selecionados.values.contains(true)) {
      _salvarGeneros();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione pelo menos um gênero musical!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: generos.length,
            itemBuilder: (context, index) {
              final genero = generos[index];
              return SwitchListTile(
                title: Text(genero),
                value: selecionados[genero]!,
                onChanged: (v) { setState(() { selecionados[genero] = v; }); },
              );
            },
          ),
          ElevatedButton(onPressed: _confirmar, child: const Text('Confirmar')),
        ],
      ),
    );
  }
}
```

Dependências disponíveis para mocking:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito

Requisitos:
- Use testWidgets() do flutter_test
- Monte as telas do fluxo dentro de um MaterialApp com rotas configuradas
- Configure os mocks de Firebase necessários
- Teste o fluxo completo ponta a ponta: interações na CadastroScreen → navegação → interação na GenerosCadastroScreen → estado final
- Teste também cenários de erro (Firebase Auth falha, Firestore indisponível, usuário não autenticado)
- Os testes devem ser executáveis com `flutter test test/integration/`
- Use `import 'package:sintonize/cadastro.dart';` e `import 'package:sintonize/generos-cadastro.dart';`

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
