# Reexecução — rodadas confirmadas como afetadas pelos defeitos do piloto

Este arquivo contém prompts revisados para as **4 rodadas** classificadas
como **Confirmado afetado** na investigação registrada em
`fase2/rodadas/README.md` (seção de desvio) e resumida no histórico da
sessão que gerou este arquivo. Os prompts originais do piloto
(`fase2/prompts_prontos/FASE2-WSILENT-FS.md`,
`FASE2-ICRASH-ZS.md`, `FASE2-ICRASH-FS.md`, `FASE2-ICRASH-COT.md`) **não
foram alterados** — permanecem como registro de que a primeira tentativa
existiu e do motivo pelo qual foi refeita. As rodadas já documentadas em
`fase2/rodadas/` para esses IDs (resultados do piloto) também não são
tocadas; uma nova rodada reexecutada a partir deste arquivo deve ser
documentada como uma rodada **nova** (mesmo `fase2/Template_Documentacao_Rodada_Fase2.md`,
referenciando esta reexecução).

## O que foi corrigido e por quê

| Rodada | Problema confirmado | Evidência (rodada original) |
|---|---|---|
| W-SILENT-FS | Exemplo few-shot usa `MockFirebaseAuth(authExceptions: AuthExceptions(...))`, API inexistente em `firebase_auth_mocks` 0.14.2 | Falha de compilação na iteração 0: `Error: Method not found: 'AuthExceptions'` / `No named parameter with the name 'authExceptions'` (`fase2/resultados/widget/FASE2-WSILENT-FS_iter0.txt`) |
| I-CRASH-ZS | `GenerosCadastroScreen` descrita no prompt com `SwitchListTile`; a tela real usa `Switch` dentro de `Card`/`Row` | 3 de 6 testes falharam na iteração 2 por `RangeError`/`Bad state: No element` ao procurar `SwitchListTile` inexistente (`fase2/rodadas/integration/FASE2-ICRASH-ZS.md`, achado metodológico #2) |
| I-CRASH-FS | `CadastroScreen` descrita no prompt com apenas 4 campos (`nome`, `email`, `senha`, `confSenha`); a tela real tem 10 campos + dropdown de Estado. (Exemplo few-shot também continha `AuthExceptions`, mesma API inexistente, embora não tenha sido exercitada pelo modelo nesta rodada específica.) | Falha final (iteração 3): `Expected: exactly 4 matching candidates / Actual: Found 10 widgets with type "TextFormField"` (`fase2/rodadas/integration/FASE2-ICRASH-FS.md`, achado metodológico #1) |
| I-CRASH-COT | Mesma divergência de `CadastroScreen` (4 vs. 10 campos) da rodada FS | Causa dominante de 12/13 falhas na iteração 1: `Expected: exactly 4 matching candidates / Actual: Found 10 widgets with type "TextFormField"` (`fase2/rodadas/integration/FASE2-ICRASH-COT.md`, achado metodológico #4) |

Em todos os casos: **o bug-alvo no código (I-CRASH em `generos-cadastro.dart`,
W-SILENT em `login.dart`) permanece exatamente o mesmo** — os arquivos
`lib/cadastro.dart`, `lib/generos-cadastro.dart` e `lib/login.dart` abaixo
são colados **verbatim** do código-fonte atual do projeto, sem nenhuma
alteração. Apenas o material de apoio do prompt (exemplo few-shot e/ou
descrição das telas) foi corrigido para refletir fielmente o app real.

A instrução de reparo (dois caminhos + autoclassificação) é **idêntica**,
copiada verbatim, em todas as 4 rodadas abaixo.

---

# FASE2-WSILENT-FS — REEXEC

**Bug ID:** W-SILENT | **Nível:** Widget | **Estratégia:** Few-shot
**Alvo:** `LoginScreen` (`login()` — mapeamento de erros) — `lib/login.dart`
**Conversa nova:** sim — uma conversa por rodada, sem contexto anterior
**Motivo da reexecução:** o exemplo few-shot original usava
`MockFirebaseAuth(authExceptions: AuthExceptions(...))`, que não existe em
`firebase_auth_mocks` 0.14.2 (confirmado no código-fonte do pacote:
o construtor real aceita apenas `signedIn`, `mockUser`,
`signInMethodsForEmail`, `verifyEmailAutomatically`). Isso causou falha de
compilação já na iteração 0 do piloto. Corrigido abaixo usando a API real
(`whenCalling(...).on(...).thenThrow(...)` do pacote `mock_exceptions`,
dependência transitiva já presente em `pubspec.lock`).

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
import 'package:mock_exceptions/mock_exceptions.dart';

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
      final authComErro = MockFirebaseAuth();
      whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
          .on(authComErro)
          .thenThrow(FirebaseAuthException(code: 'wrong-password'));
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
- mock_exceptions (dependência transitiva de firebase_auth_mocks/fake_cloud_firestore — já disponível em pubspec.lock, expõe `whenCalling`/`maybeThrowException`)

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

---

# FASE2-ICRASH-ZS — REEXEC

**Bug ID:** I-CRASH | **Nível:** Integração | **Estratégia:** Zero-shot
**Alvo:** fluxo de cadastro — `GenerosCadastroScreen._salvarGeneros()`
**Arquivos:** `lib/cadastro.dart` + `lib/generos-cadastro.dart`
**Conversa nova:** sim — uma conversa por rodada, sem contexto anterior
**Motivo da reexecução:** o prompt original descrevia `GenerosCadastroScreen`
com `SwitchListTile`; a tela real usa `Switch` dentro de `Card`/`Row`
(`ListView.builder` → `Card` → `Row` → `Switch`). Isso causou 3 das 6
falhas finais do piloto (`RangeError`/`Bad state: No element` ao procurar
um widget inexistente). O `build()` de `CadastroScreen` também estava
truncado no piloto (comentário `// ... (build method com formulário
completo)`); abaixo vai o código real completo das duas telas, colado
verbatim de `lib/cadastro.dart` e `lib/generos-cadastro.dart` — nenhuma
linha de comportamento foi alterada, incluindo o bug I-CRASH
(`_auth.currentUser!.uid` fora do `try` em `_salvarGeneros()`).

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
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  CadastroScreen({
    super.key,
    this.auth,
    this.firestore,
  });

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

  FirebaseAuth get _auth => widget.auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => widget.firestore ?? FirebaseFirestore.instance;

  String? _estadoSelecionado;

  final List<String> _estados = [
    "AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS", "MG",
    "PA", "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO"
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
            const SnackBar(content: Text('CEP não encontrado')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao buscar CEP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'A data de nascimento é obrigatória';
    }
    final parts = value.split('/');
    if (parts.length != 3) {
      return 'Formato inválido. Use dd/mm/aaaa';
    }
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return 'Data inválida. Certifique-se de que todos os campos são números';
    }
    if (month < 1 || month > 12) {
      return 'Mês deve ser entre 01 e 12';
    }
    final maxDay = DateTime(year, month + 1, 0).day;
    if (day < 1 || day > maxDay) {
      return 'Dia deve ser entre 01 e $maxDay';
    }
    final date = DateTime(year, month, day);
    if (date.isAfter(DateTime.now())) {
      return 'A data não pode ser no futuro';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O e-mail é obrigatório';
    }
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validateCEP(String? value) {
    if (value == null || value.isEmpty) {
      return 'O CEP é obrigatório';
    }
    if (value.length != 9 || !RegExp(r'^\d{5}-\d{3}$').hasMatch(value)) {
      return 'CEP inválido. Formato correto: XXXXX-XXX';
    }
    return null;
  }

  String? _validateNumero(String? value) {
    if (value == null || value.isEmpty) {
      return 'O número é obrigatório';
    }
    if (int.tryParse(value) == null) {
      return 'O número deve ser numérico';
    }
    return null;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _senhaController.text,
        );

        String uid = userCredential.user!.uid;

        await _firestore.collection('usuarios').doc(uid).set({
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

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GenerosCadastroScreen(
              auth: widget.auth,
              firestore: widget.firestore,
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao cadastrar: ${e.message}")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro desconhecido: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 30),
                  Image.asset(
                    'assets/logo-sintoniza.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 20),
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
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField('Nome', _nomeController,
                                    (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'O nome é obrigatório';
                                  }
                                  final hasInvalidCharacters =
                                      RegExp(r'[^a-zA-ZÀ-ÿ\s]').hasMatch(value);
                                  if (hasInvalidCharacters) {
                                    return 'O nome não pode conter números ou caracteres especiais';
                                  }
                                  return null;
                                }),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  'Data de Nascimento',
                                  _dataNascController,
                                  _validateDate,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(8),
                                    TextInputFormatter.withFunction(
                                        (oldValue, newValue) {
                                      if (newValue.text.isEmpty) {
                                        return TextEditingValue.empty;
                                      }
                                      final text =
                                          newValue.text.replaceAll('/', '');
                                      String newText = '';
                                      for (var i = 0; i < text.length; i++) {
                                        if (i == 2 || i == 4) {
                                          newText += '/';
                                        }
                                        newText += text[i];
                                      }
                                      return TextEditingValue(
                                        text: newText,
                                        selection: TextSelection.collapsed(
                                            offset: newText.length),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                              'E-mail', _emailController, _validateEmail),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                    'Senha', _senhaController, (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'A senha é obrigatória';
                                  }
                                  if (value.length < 6) {
                                    return 'A senha deve ter pelo menos 6 caracteres';
                                  }
                                  return null;
                                }, obscureText: true),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                    'Confirmar Senha', _confSenhaController,
                                    (value) {
                                  if (value != _senhaController.text) {
                                    return 'As senhas não coincidem';
                                  }
                                  return null;
                                }, obscureText: true),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildTextField('CEP', _cepController, _validateCEP,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(8),
                                _CEPInputFormatter(),
                              ], onChanged: (value) {
                            if (value.length == 9) {
                              _fetchAddressFromCEP(value.replaceAll('-', ''));
                            }
                          }),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                    'Rua', _ruaController, null),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField('Número',
                                    _numeroController, _validateNumero),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                    'Bairro', _bairroController, null),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                    'Cidade', _cidadeController, null),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildEstadoDropdown(),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Cadastrar',
                                style: TextStyle(
                                  color: Color(0xFFF14621),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen(auth: widget.auth)),
                              );
                            },
                            child: const Text(
                              'Já tem uma conta? Faça login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      String? Function(String?)? validator,
      {bool obscureText = false,
      List<TextInputFormatter>? inputFormatters,
      void Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.black, fontSize: 12),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          validator: validator,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildEstadoDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estado',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: _estadoSelecionado,
          items: _estados
              .map(
                (estado) => DropdownMenuItem<String>(
                  value: estado,
                  child: Text(estado),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _estadoSelecionado = value;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
      ],
    );
  }
}

class _CEPInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 8) {
      return oldValue;
    }

    final text = newValue.text.replaceAll('-', '');
    String newText = '';

    for (var i = 0; i < text.length; i++) {
      if (i == 5) {
        newText += '-';
      }
      newText += text[i];
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

// ─── lib/generos-cadastro.dart ───────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela-inicial.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GenerosCadastroScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  GenerosCadastroScreen({
    super.key,
    this.auth,
    this.firestore,
  });

  @override
  _GenerosCadastroScreenState createState() => _GenerosCadastroScreenState();
}

class _GenerosCadastroScreenState extends State<GenerosCadastroScreen> {
  FirebaseAuth get _auth => widget.auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => widget.firestore ?? FirebaseFirestore.instance;

  final List<String> generos = [
    'Rock',
    'Pop',
    'Jazz',
    'Blues',
    'Hip-Hop',
    'Reggae',
    'Country',
  ];
  final Map<String, bool> selecionados = {};

  @override
  void initState() {
    super.initState();
    for (var genero in generos) {
      selecionados[genero] = false;
    }
  }

  Future<void> _salvarGeneros() async {
    final uid = _auth.currentUser!.uid;

    try {
      final generosSelecionados = selecionados.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      await _firestore
          .collection('usuarios')
          .doc(uid)
          .update({
        'generos_favoritos': generosSelecionados,
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TelaInicialScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar os gêneros!')),
      );
    }
  }

  void _confirmar() {
    if (selecionados.values.contains(true)) {
      _salvarGeneros();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecione pelo menos um gênero musical!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/logo-sintoniza.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 20),
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
                  child: const Center(
                    child: Text(
                      'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  itemCount: generos.length,
                  itemBuilder: (context, index) {
                    final genero = generos[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                genero,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontFamily: 'Piazzolla',
                                ),
                              ),
                              Switch(
                                value: selecionados[genero]!,
                                activeColor: const Color(0xFFF14621),
                                inactiveThumbColor: Colors.grey[400],
                                onChanged: (bool isSelected) {
                                  setState(() {
                                    selecionados[genero] = isSelected;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF14621),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Piazzolla',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Dependências disponíveis para mocking:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito
- mock_exceptions (dependência transitiva já presente em pubspec.lock, expõe `whenCalling`/`maybeThrowException` — prefira essa API a mocks manuais para simular exceções do Firebase Auth/Firestore)

Requisitos:
- Use testWidgets() do flutter_test
- Monte as telas do fluxo dentro de um MaterialApp com rotas configuradas
- Configure os mocks de Firebase necessários
- Teste o fluxo completo ponta a ponta: interações na CadastroScreen → navegação → interação na GenerosCadastroScreen → estado final
- Teste também cenários de erro (Firebase Auth falha, Firestore indisponível, usuário não autenticado)
- Os testes devem ser executáveis com `flutter test test/integration/`
- Use `import 'package:sintonize/cadastro.dart';` e `import 'package:sintonize/generos-cadastro.dart';`
- O código acima é colado verbatim de `lib/cadastro.dart` e `lib/generos-cadastro.dart` — os seletores de widget (`Switch`, `DropdownButtonFormField`, `TextFormField`) devem corresponder exatamente ao que está escrito acima, não a uma versão resumida

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

---

# FASE2-ICRASH-FS — REEXEC

**Bug ID:** I-CRASH | **Nível:** Integração | **Estratégia:** Few-shot
**Alvo:** fluxo de cadastro — `GenerosCadastroScreen._salvarGeneros()`
**Arquivos:** `lib/cadastro.dart` + `lib/generos-cadastro.dart`
**Conversa nova:** sim — uma conversa por rodada, sem contexto anterior
**Motivo da reexecução:** dois problemas confirmados no piloto — (1) o
`CadastroScreen` embutido tinha apenas 4 campos, a tela real tem 10 (causa
confirmada da falha final `Expected: exactly 4 / Actual: Found 10 widgets
with type "TextFormField"`); (2) o exemplo few-shot usava
`MockFirebaseAuth(authExceptions: AuthExceptions(...))`, API inexistente
(não chegou a ser exercitada pelo modelo nesta rodada específica, mas é
um defeito real do material de entrada e poderia ser reproduzido em uma
nova tentativa). Ambos corrigidos abaixo; o código das telas é colado
verbatim de `lib/cadastro.dart` e `lib/generos-cadastro.dart`, incluindo o
bug I-CRASH inalterado.

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
import 'package:mock_exceptions/mock_exceptions.dart';

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
      final authComErro = MockFirebaseAuth();
      whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
          .on(authComErro)
          .thenThrow(FirebaseAuthException(code: 'wrong-password'));
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
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'generos-cadastro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  CadastroScreen({
    super.key,
    this.auth,
    this.firestore,
  });

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

  FirebaseAuth get _auth => widget.auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => widget.firestore ?? FirebaseFirestore.instance;

  String? _estadoSelecionado;

  final List<String> _estados = [
    "AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS", "MG",
    "PA", "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO"
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
            const SnackBar(content: Text('CEP não encontrado')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao buscar CEP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'A data de nascimento é obrigatória';
    }
    final parts = value.split('/');
    if (parts.length != 3) {
      return 'Formato inválido. Use dd/mm/aaaa';
    }
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return 'Data inválida. Certifique-se de que todos os campos são números';
    }
    if (month < 1 || month > 12) {
      return 'Mês deve ser entre 01 e 12';
    }
    final maxDay = DateTime(year, month + 1, 0).day;
    if (day < 1 || day > maxDay) {
      return 'Dia deve ser entre 01 e $maxDay';
    }
    final date = DateTime(year, month, day);
    if (date.isAfter(DateTime.now())) {
      return 'A data não pode ser no futuro';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O e-mail é obrigatório';
    }
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validateCEP(String? value) {
    if (value == null || value.isEmpty) {
      return 'O CEP é obrigatório';
    }
    if (value.length != 9 || !RegExp(r'^\d{5}-\d{3}$').hasMatch(value)) {
      return 'CEP inválido. Formato correto: XXXXX-XXX';
    }
    return null;
  }

  String? _validateNumero(String? value) {
    if (value == null || value.isEmpty) {
      return 'O número é obrigatório';
    }
    if (int.tryParse(value) == null) {
      return 'O número deve ser numérico';
    }
    return null;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _senhaController.text,
        );

        String uid = userCredential.user!.uid;

        await _firestore.collection('usuarios').doc(uid).set({
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

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GenerosCadastroScreen(
              auth: widget.auth,
              firestore: widget.firestore,
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao cadastrar: ${e.message}")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro desconhecido: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 30),
                  Image.asset(
                    'assets/logo-sintoniza.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 20),
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
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField('Nome', _nomeController,
                                    (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'O nome é obrigatório';
                                  }
                                  final hasInvalidCharacters =
                                      RegExp(r'[^a-zA-ZÀ-ÿ\s]').hasMatch(value);
                                  if (hasInvalidCharacters) {
                                    return 'O nome não pode conter números ou caracteres especiais';
                                  }
                                  return null;
                                }),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  'Data de Nascimento',
                                  _dataNascController,
                                  _validateDate,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(8),
                                    TextInputFormatter.withFunction(
                                        (oldValue, newValue) {
                                      if (newValue.text.isEmpty) {
                                        return TextEditingValue.empty;
                                      }
                                      final text =
                                          newValue.text.replaceAll('/', '');
                                      String newText = '';
                                      for (var i = 0; i < text.length; i++) {
                                        if (i == 2 || i == 4) {
                                          newText += '/';
                                        }
                                        newText += text[i];
                                      }
                                      return TextEditingValue(
                                        text: newText,
                                        selection: TextSelection.collapsed(
                                            offset: newText.length),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                              'E-mail', _emailController, _validateEmail),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                    'Senha', _senhaController, (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'A senha é obrigatória';
                                  }
                                  if (value.length < 6) {
                                    return 'A senha deve ter pelo menos 6 caracteres';
                                  }
                                  return null;
                                }, obscureText: true),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                    'Confirmar Senha', _confSenhaController,
                                    (value) {
                                  if (value != _senhaController.text) {
                                    return 'As senhas não coincidem';
                                  }
                                  return null;
                                }, obscureText: true),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildTextField('CEP', _cepController, _validateCEP,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(8),
                                _CEPInputFormatter(),
                              ], onChanged: (value) {
                            if (value.length == 9) {
                              _fetchAddressFromCEP(value.replaceAll('-', ''));
                            }
                          }),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                    'Rua', _ruaController, null),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField('Número',
                                    _numeroController, _validateNumero),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                    'Bairro', _bairroController, null),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                    'Cidade', _cidadeController, null),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildEstadoDropdown(),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Cadastrar',
                                style: TextStyle(
                                  color: Color(0xFFF14621),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen(auth: widget.auth)),
                              );
                            },
                            child: const Text(
                              'Já tem uma conta? Faça login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      String? Function(String?)? validator,
      {bool obscureText = false,
      List<TextInputFormatter>? inputFormatters,
      void Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.black, fontSize: 12),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          validator: validator,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildEstadoDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estado',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: _estadoSelecionado,
          items: _estados
              .map(
                (estado) => DropdownMenuItem<String>(
                  value: estado,
                  child: Text(estado),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _estadoSelecionado = value;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
      ],
    );
  }
}

class _CEPInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 8) {
      return oldValue;
    }

    final text = newValue.text.replaceAll('-', '');
    String newText = '';

    for (var i = 0; i < text.length; i++) {
      if (i == 5) {
        newText += '-';
      }
      newText += text[i];
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

// ─── lib/generos-cadastro.dart ───────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela-inicial.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GenerosCadastroScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  GenerosCadastroScreen({
    super.key,
    this.auth,
    this.firestore,
  });

  @override
  _GenerosCadastroScreenState createState() => _GenerosCadastroScreenState();
}

class _GenerosCadastroScreenState extends State<GenerosCadastroScreen> {
  FirebaseAuth get _auth => widget.auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => widget.firestore ?? FirebaseFirestore.instance;

  final List<String> generos = [
    'Rock',
    'Pop',
    'Jazz',
    'Blues',
    'Hip-Hop',
    'Reggae',
    'Country',
  ];
  final Map<String, bool> selecionados = {};

  @override
  void initState() {
    super.initState();
    for (var genero in generos) {
      selecionados[genero] = false;
    }
  }

  Future<void> _salvarGeneros() async {
    final uid = _auth.currentUser!.uid;

    try {
      final generosSelecionados = selecionados.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      await _firestore
          .collection('usuarios')
          .doc(uid)
          .update({
        'generos_favoritos': generosSelecionados,
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TelaInicialScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar os gêneros!')),
      );
    }
  }

  void _confirmar() {
    if (selecionados.values.contains(true)) {
      _salvarGeneros();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecione pelo menos um gênero musical!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/logo-sintoniza.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 20),
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
                  child: const Center(
                    child: Text(
                      'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  itemCount: generos.length,
                  itemBuilder: (context, index) {
                    final genero = generos[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                genero,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontFamily: 'Piazzolla',
                                ),
                              ),
                              Switch(
                                value: selecionados[genero]!,
                                activeColor: const Color(0xFFF14621),
                                inactiveThumbColor: Colors.grey[400],
                                onChanged: (bool isSelected) {
                                  setState(() {
                                    selecionados[genero] = isSelected;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF14621),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Piazzolla',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Dependências disponíveis:
- firebase_auth_mocks
- fake_cloud_firestore
- mockito
- mock_exceptions (dependência transitiva já presente em pubspec.lock)

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

---

# FASE2-ICRASH-COT — REEXEC

**Bug ID:** I-CRASH | **Nível:** Integração | **Estratégia:** Chain-of-Thought
**Alvo:** fluxo de cadastro — `GenerosCadastroScreen._salvarGeneros()`
**Arquivos:** `lib/cadastro.dart` + `lib/generos-cadastro.dart`
**Conversa nova:** sim — uma conversa por rodada, sem contexto anterior
**Motivo da reexecução:** mesma divergência de `CadastroScreen` (4 campos
no prompt vs. 10 campos reais) confirmada como causa dominante de 12/13
falhas na rodada FS/COT do piloto (`findsNWidgets(4)` encontrando 10
`TextFormField`). Corrigido abaixo com o código real e completo das duas
telas, colado verbatim; o bug I-CRASH permanece inalterado.

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
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'generos-cadastro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CadastroScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  CadastroScreen({
    super.key,
    this.auth,
    this.firestore,
  });

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

  FirebaseAuth get _auth => widget.auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => widget.firestore ?? FirebaseFirestore.instance;

  String? _estadoSelecionado;

  final List<String> _estados = [
    "AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT", "MS", "MG",
    "PA", "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SP", "SE", "TO"
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
            const SnackBar(content: Text('CEP não encontrado')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao buscar CEP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'A data de nascimento é obrigatória';
    }
    final parts = value.split('/');
    if (parts.length != 3) {
      return 'Formato inválido. Use dd/mm/aaaa';
    }
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return 'Data inválida. Certifique-se de que todos os campos são números';
    }
    if (month < 1 || month > 12) {
      return 'Mês deve ser entre 01 e 12';
    }
    final maxDay = DateTime(year, month + 1, 0).day;
    if (day < 1 || day > maxDay) {
      return 'Dia deve ser entre 01 e $maxDay';
    }
    final date = DateTime(year, month, day);
    if (date.isAfter(DateTime.now())) {
      return 'A data não pode ser no futuro';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'O e-mail é obrigatório';
    }
    const pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  String? _validateCEP(String? value) {
    if (value == null || value.isEmpty) {
      return 'O CEP é obrigatório';
    }
    if (value.length != 9 || !RegExp(r'^\d{5}-\d{3}$').hasMatch(value)) {
      return 'CEP inválido. Formato correto: XXXXX-XXX';
    }
    return null;
  }

  String? _validateNumero(String? value) {
    if (value == null || value.isEmpty) {
      return 'O número é obrigatório';
    }
    if (int.tryParse(value) == null) {
      return 'O número deve ser numérico';
    }
    return null;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _senhaController.text,
        );

        String uid = userCredential.user!.uid;

        await _firestore.collection('usuarios').doc(uid).set({
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

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GenerosCadastroScreen(
              auth: widget.auth,
              firestore: widget.firestore,
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao cadastrar: ${e.message}")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro desconhecido: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 30),
                  Image.asset(
                    'assets/logo-sintoniza.png',
                    width: 150,
                    height: 150,
                  ),
                  const SizedBox(height: 20),
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
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField('Nome', _nomeController,
                                    (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'O nome é obrigatório';
                                  }
                                  final hasInvalidCharacters =
                                      RegExp(r'[^a-zA-ZÀ-ÿ\s]').hasMatch(value);
                                  if (hasInvalidCharacters) {
                                    return 'O nome não pode conter números ou caracteres especiais';
                                  }
                                  return null;
                                }),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  'Data de Nascimento',
                                  _dataNascController,
                                  _validateDate,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(8),
                                    TextInputFormatter.withFunction(
                                        (oldValue, newValue) {
                                      if (newValue.text.isEmpty) {
                                        return TextEditingValue.empty;
                                      }
                                      final text =
                                          newValue.text.replaceAll('/', '');
                                      String newText = '';
                                      for (var i = 0; i < text.length; i++) {
                                        if (i == 2 || i == 4) {
                                          newText += '/';
                                        }
                                        newText += text[i];
                                      }
                                      return TextEditingValue(
                                        text: newText,
                                        selection: TextSelection.collapsed(
                                            offset: newText.length),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                              'E-mail', _emailController, _validateEmail),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                    'Senha', _senhaController, (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'A senha é obrigatória';
                                  }
                                  if (value.length < 6) {
                                    return 'A senha deve ter pelo menos 6 caracteres';
                                  }
                                  return null;
                                }, obscureText: true),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                    'Confirmar Senha', _confSenhaController,
                                    (value) {
                                  if (value != _senhaController.text) {
                                    return 'As senhas não coincidem';
                                  }
                                  return null;
                                }, obscureText: true),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildTextField('CEP', _cepController, _validateCEP,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(8),
                                _CEPInputFormatter(),
                              ], onChanged: (value) {
                            if (value.length == 9) {
                              _fetchAddressFromCEP(value.replaceAll('-', ''));
                            }
                          }),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                    'Rua', _ruaController, null),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField('Número',
                                    _numeroController, _validateNumero),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                    'Bairro', _bairroController, null),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                    'Cidade', _cidadeController, null),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildEstadoDropdown(),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                'Cadastrar',
                                style: TextStyle(
                                  color: Color(0xFFF14621),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen(auth: widget.auth)),
                              );
                            },
                            child: const Text(
                              'Já tem uma conta? Faça login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      String? Function(String?)? validator,
      {bool obscureText = false,
      List<TextInputFormatter>? inputFormatters,
      void Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.black, fontSize: 12),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
          validator: validator,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildEstadoDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estado',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: _estadoSelecionado,
          items: _estados
              .map(
                (estado) => DropdownMenuItem<String>(
                  value: estado,
                  child: Text(estado),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _estadoSelecionado = value;
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          ),
        ),
      ],
    );
  }
}

class _CEPInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 8) {
      return oldValue;
    }

    final text = newValue.text.replaceAll('-', '');
    String newText = '';

    for (var i = 0; i < text.length; i++) {
      if (i == 5) {
        newText += '-';
      }
      newText += text[i];
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

// ─── lib/generos-cadastro.dart ───────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela-inicial.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GenerosCadastroScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  GenerosCadastroScreen({
    super.key,
    this.auth,
    this.firestore,
  });

  @override
  _GenerosCadastroScreenState createState() => _GenerosCadastroScreenState();
}

class _GenerosCadastroScreenState extends State<GenerosCadastroScreen> {
  FirebaseAuth get _auth => widget.auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => widget.firestore ?? FirebaseFirestore.instance;

  final List<String> generos = [
    'Rock',
    'Pop',
    'Jazz',
    'Blues',
    'Hip-Hop',
    'Reggae',
    'Country',
  ];
  final Map<String, bool> selecionados = {};

  @override
  void initState() {
    super.initState();
    for (var genero in generos) {
      selecionados[genero] = false;
    }
  }

  Future<void> _salvarGeneros() async {
    final uid = _auth.currentUser!.uid;

    try {
      final generosSelecionados = selecionados.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      await _firestore
          .collection('usuarios')
          .doc(uid)
          .update({
        'generos_favoritos': generosSelecionados,
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TelaInicialScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar os gêneros!')),
      );
    }
  }

  void _confirmar() {
    if (selecionados.values.contains(true)) {
      _salvarGeneros();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecione pelo menos um gênero musical!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/logo-sintoniza.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 20),
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
                  child: const Center(
                    child: Text(
                      'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  itemCount: generos.length,
                  itemBuilder: (context, index) {
                    final genero = generos[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                genero,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontFamily: 'Piazzolla',
                                ),
                              ),
                              Switch(
                                value: selecionados[genero]!,
                                activeColor: const Color(0xFFF14621),
                                inactiveThumbColor: Colors.grey[400],
                                onChanged: (bool isSelected) {
                                  setState(() {
                                    selecionados[genero] = isSelected;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF14621),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Piazzolla',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Dependências disponíveis:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito
- mock_exceptions (dependência transitiva já presente em pubspec.lock)
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
