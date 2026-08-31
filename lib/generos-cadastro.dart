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
    final uid = widget.auth.currentUser!.uid;

    try {
      final generosSelecionados = selecionados.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      await widget.firestore
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