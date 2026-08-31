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

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GenerosCadastroScreen(),
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
                                    builder: (context) => LoginScreen()),
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