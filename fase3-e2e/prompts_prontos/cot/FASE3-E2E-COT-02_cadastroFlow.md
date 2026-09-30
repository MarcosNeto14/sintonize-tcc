# FASE3-E2E-COT-02_cadastroFlow

**Nível:** E2E (integration_test, no AVD, contra os emuladores Firebase) | **Estratégia:** Chain-of-Thought
**Alvo:** fluxo de cadastro — tela de boas-vindas → `CadastroScreen` → `GenerosCadastroScreen` → `TelaInicialScreen` (`lib/main.dart`, `lib/cadastro.dart`, `lib/generos-cadastro.dart`, `lib/tela-inicial.dart`)
**Conversa nova:** sim — uma conversa por rodada, sem contexto anterior

> **Notas de protocolo (para o operador — NÃO fazem parte do prompt):**
>
> - Este mesmo arquivo serve para a **rodada limpa** e para a **rodada com bug**
>   do fluxo (L4 / C3 / P2, ver `fase3-e2e/README.md`). O prompt é idêntico nos
>   dois casos e **nada nele menciona bug**. O que muda é só o `lib/` do
>   worktree em que o teste gerado é executado.
> - Código das telas colado **verbatim e completo** a partir do `lib/` limpo
>   (`ccae44a`), sem simplificação. Nas rodadas com bug o modelo recebe este
>   mesmo código limpo; o bug está apenas no app executado.
> - O bloco "Ambiente de execução" é byte-idêntico nos 9 prompts (sha256 em
>   `prompts_prontos/_sha256.txt`). Não adaptar para o Gemini nem para o ChatGPT.
> - Os testes de `integration_test/_referencia/` **não podem** entrar nesta
>   conversa, nem no prompt de geração, nem no de reparo.
> - Derivado de `fase2/prompts_prontos/integration/…/FASE2-INT-COT-02_cadastroFlow.md`:
>   mesma estrutura; o que era mock virou emulador + navegação real.


---

## Prompt (selecionar tudo abaixo desta linha até o próximo `---` e colar no modelo da rodada — ChatGPT ou Gemini)

---

Quero que você gere um teste end-to-end em Dart, com o pacote integration_test do Flutter, para o fluxo do aplicativo Flutter "Sintonize" descrito abaixo. Antes de escrever os testes, siga estes passos:

1. **Analise o fluxo:** Descreva em 3-5 frases o que acontece do início ao fim do fluxo, quais são os pontos de decisão (sucesso/erro) e quais telas estão envolvidas.
2. **Identifique as dependências:** Liste quais serviços (Firebase Auth, Firestore, HTTP) são acionados em cada tela, o que cada tela lê ou grava nos emuladores e quais dados já existem neles antes do teste.
3. **Monte o caminho de navegação:** Descreva, a partir da tela de boas-vindas do aplicativo real, quais toques levam à tela do fluxo e como esperar cada transição e cada resposta dos emuladores nos testes.
4. **Identifique os cenários de teste:** Liste todos os cenários do fluxo completo:
   - Fluxo de sucesso ponta a ponta (interação → navegação → estado final)
   - Erros de validação (campos inválidos antes de disparar Firebase)
   - Erros do Firebase e do fluxo (e-mail já cadastrado, nenhum gênero selecionado ao confirmar)
   - Estados intermediários visíveis ao usuário (loading, mensagens de erro)
5. **Escreva os testes:** Para cada cenário, escreva um testWidgets() completo.

IMPORTANTE: Não modifique o código das telas. Apenas gere os testes.

Fluxo a testar:

O usuário preenche o formulário de cadastro na CadastroScreen, cria sua conta com Firebase Auth e um documento em Firestore, e é redirecionado para a GenerosCadastroScreen, onde seleciona gêneros musicais e toca em "Confirmar" para salvá-los no documento do usuário no Firestore.

Código das telas envolvidas:

```dart
// ===== lib/main.dart =====
import 'package:flutter/material.dart';
import 'cadastro.dart';
import 'login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Piazzolla',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLogoVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isLogoVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedOpacity(
              opacity: _isLogoVisible ? 1.0 : 0.0,
              duration: const Duration(seconds: 2),
              child: Image.asset(
                'assets/logo-sintoniza.png',
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Bem-vindo ao Sintonize!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF14621),
                fontFamily: 'Piazzolla',
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          LoginScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFF14621),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(
                      color: Color(0xFFF14621),
                    ),
                  ),
                  elevation: 5,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login),
                    SizedBox(width: 10),
                    Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          CadastroScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFF14621),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(
                      color: Color(0xFFF14621),
                    ),
                  ),
                  elevation: 5,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.app_registration),
                    SizedBox(width: 10),
                    Text(
                      'Cadastro',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ===== lib/cadastro.dart =====
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

// ===== lib/generos-cadastro.dart =====
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
    final user = _auth.currentUser;

    if (user != null) {
      try {
        final generosSelecionados = selecionados.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

        await _firestore
            .collection('usuarios')
            .doc(user.uid)
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

// ===== lib/tela-inicial.dart =====
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'usuario.dart';
import 'pesquisa-direta.dart';
import 'sintonizados.dart';
import 'dart:math';
import 'mapa.dart';

class TelaInicialScreen extends StatefulWidget {
  const TelaInicialScreen({super.key});

  @override
  _TelaInicialScreenState createState() => _TelaInicialScreenState();
}

class _TelaInicialScreenState extends State<TelaInicialScreen> {
  int _selectedIndex = 0;
  Map<String, String>? _currentMusic;

  // Função para normalizar gêneros
  String _normalizeGenre(String genre) {
    return genre.toLowerCase().replaceAll('-', '').replaceAll(' ', '');
  }

  Future<String> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data()?['nome'] ?? 'Usuário';
      }
    }
    return 'Usuário';
  }

  Future<Map<String, String>> fetchLastRecommendedMusic() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'track_name': 'Erro', 'artist_name': 'Usuário não autenticado'};
    }

    try {
      final userRef =
          FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
      final userDoc = await userRef.get();
      final Map<String, dynamic> historicoMusicasRaw =
          userDoc.data()?['historico_musicas'] ?? {};
      if (historicoMusicasRaw.isNotEmpty) {
        final lastKey = historicoMusicasRaw.keys.last;
        final lastMusic = historicoMusicasRaw[lastKey];
        return {
          'track_name': lastMusic['track_name'] as String? ?? 'Sem título',
          'artist_name': lastMusic['artist_name'] as String? ?? 'Desconhecido'
        };
      }
      return await fetchNewMusic();
    } catch (e) {
      return {'track_name': 'Erro ao carregar música', 'artist_name': 'Erro'};
    }
  }

  Future<Map<String, String>> fetchNewMusic() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {'track_name': 'Erro', 'artist_name': 'Usuário não autenticado'};
    }
    try {
      final userRef =
          FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
      final userDoc = await userRef.get();
      final List<dynamic> generosFavoritosRaw =
          userDoc.data()?['generos_favoritos'] ?? [];
      final List<String> generosFavoritos = generosFavoritosRaw
          .map((g) => _normalizeGenre(g.toString()))
          .toList();

      if (generosFavoritos.isEmpty) {
        return {
          'track_name': 'Nenhum gênero favorito',
          'artist_name': 'Selecione gêneros'
        };
      }

      final Map<String, dynamic> historicoMusicasRaw =
          userDoc.data()?['historico_musicas'] ?? {};
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('musica').get();
      final availableMusics = querySnapshot.docs.where((doc) {
        final String genre = _normalizeGenre(doc['genre'].toString());
        return generosFavoritos.contains(genre);
      }).toList();

      if (availableMusics.isEmpty) {
        return {'track_name': 'Nenhuma música disponível', 'artist_name': ''};
      }

      final random = Random();
      final filteredMusics = availableMusics
          .where((doc) => !historicoMusicasRaw.values.any((music) =>
              music['track_name'] == doc['track_name'] &&
              music['artist_name'] == doc['artist_name']))
          .toList();

      if (filteredMusics.isEmpty) {
        return {
          'track_name': 'Todas músicas já foram sugeridas',
          'artist_name': ''
        };
      }

      final randomMusic = filteredMusics[random.nextInt(filteredMusics.length)];
      final musicData = {
        'track_name': randomMusic['track_name'] as String? ?? 'Sem título',
        'artist_name': randomMusic['artist_name'] as String? ?? 'Desconhecido'
      };

      final DateTime now = DateTime.now();
      final String todayKey = "${now.year}-${now.month}-${now.day}";
      historicoMusicasRaw[todayKey] = musicData;

      await userRef.update({
        'historico_musicas': historicoMusicasRaw,
        'musica_recomendada': musicData,
      });

      return musicData;
    } catch (e) {
      return {'track_name': 'Erro ao carregar música', 'artist_name': 'Erro'};
    }
  }

  void _fetchNewMusic() async {
    final newMusic = await fetchNewMusic();
    setState(() {
      _currentMusic = newMusic;
    });
  }

  String _formatName(String name) {
    if (name.isEmpty) return name;
    return name
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    _loadLastRecommendedMusic();
  }

  void _loadLastRecommendedMusic() async {
    final lastMusic = await fetchLastRecommendedMusic();
    setState(() {
      _currentMusic = lastMusic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.music_note,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FutureBuilder<String>(
                          future: fetchUserName(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text(
                                'Carregando...',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Text(
                                'Erro ao carregar',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }

                            return Text(
                              '${_formatName(snapshot.data!)}, essa é a nossa recomendação de música para você!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/logo-sintoniza.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            if (_currentMusic != null)
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
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
                      Text(
                        _formatName(_currentMusic!['track_name']!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Piazzolla',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatName(_currentMusic!['artist_name']!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Piazzolla',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _fetchNewMusic,
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF9E80),
              Color(0xFFF14621),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          currentIndex: _selectedIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Pesquisa Direta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.music_note),
              label: 'Sintonizados',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map), // Botão do mapa na barra inferior
              label: 'Mapa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Minha Conta',
            ),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });

            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SintonizadosScreen()),
              );
            } else if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PesquisaDiretaScreen()),
              );
            } else if (index == 2) {
              // Navega para a tela do mapa
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapaScreen()),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UsuarioScreen()),
              );
            }
          },
          iconSize: 30,
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
```

Ambiente de execução (igual para todos os fluxos):

- O teste é end-to-end: roda o aplicativo real em um emulador Android (`emulator-5554`), contra os emuladores locais do Firebase (Auth em `10.0.2.2:9099` e Firestore em `10.0.2.2:8080`). Não há mocks: as telas usam `FirebaseAuth.instance` e `FirebaseFirestore.instance`, apontados para os emuladores pelo helper abaixo, que já existe no projeto.
- Chame `await setupFirebaseEmulators();` em um `setUpAll()`, antes de qualquer interação, importando-o com `import '../firebase_test_helper.dart';`.

```dart
// ===== integration_test/firebase_test_helper.dart =====
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sintonize/firebase_options.dart';

/// Host dos emuladores Firebase.
/// AVD: 10.0.2.2 (padrão). Dispositivo físico: --dart-define=EMU_HOST=localhost
/// com `adb reverse tcp:9099 tcp:9099` e `adb reverse tcp:8080 tcp:8080`.
const String emulatorHost =
    String.fromEnvironment('EMU_HOST', defaultValue: '10.0.2.2');

const int authEmulatorPort = 9099;
const int firestoreEmulatorPort = 8080;

class FirebaseTestHelper {
  static bool _initialized = false;
}

/// Inicializa o Firebase e aponta Auth e Firestore para os emuladores.
/// Chamadas repetidas no mesmo processo não fazem nada.
Future<void> setupFirebaseEmulators() async {
  if (FirebaseTestHelper._initialized) return;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.useAuthEmulator(emulatorHost, authEmulatorPort);
  FirebaseFirestore.instance
      .useFirestoreEmulator(emulatorHost, firestoreEmulatorPort);

  FirebaseTestHelper._initialized = true;
}
```

- Os emuladores são reiniciados e populados antes de cada execução com:
  - um usuário no Auth: e-mail `tester@sintonize.test`, senha `senha123`, com o documento `usuarios/{uid}` contendo `nome: 'tester sintonize'` e `generos_favoritos: ['rock', 'pop']`;
  - cinco documentos na coleção `musica` (campos `track_name`, `artist_name`, `genre`): `bohemian rhapsody` / `queen` / `rock`; `billie jean` / `michael jackson` / `pop`; `take five` / `dave brubeck` / `jazz`; `the thrill is gone` / `b.b. king` / `blues`; `one love` / `bob marley` / `reggae`.
  Qualquer outro usuário ou dado tem de ser criado pelo próprio teste, pela interface.
- Navegação no app a partir do início (`MyApp`, em `lib/main.dart`): a tela de boas-vindas mostra "Bem-vindo ao Sintonize!" e os botões "Login" e "Cadastro". "Login" abre a LoginScreen, e "Entrar" com credenciais válidas leva à TelaInicialScreen. "Cadastro" abre a CadastroScreen; "Cadastrar" leva à GenerosCadastroScreen e "Confirmar" à TelaInicialScreen. Na TelaInicialScreen, "Minha Conta" na barra inferior abre a UsuarioScreen, onde "Criar Playlist" abre a CriarPlaylistScreen.
- O arquivo será salvo em `integration_test/fase3/` e executado com `flutter test integration_test/fase3/<nome>_test.dart -d emulator-5554`.

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
