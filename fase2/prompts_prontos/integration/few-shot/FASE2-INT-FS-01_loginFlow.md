# FASE2-INT-FS-01_loginFlow

**Nível:** Integração | **Estratégia:** Few-shot
**Alvo:** fluxo de login — `LoginScreen` → `TelaInicialScreen`
(`lib/login.dart`, `lib/tela-inicial.dart`) — alvo limpo, W-SILENT revertido
**Conversa nova:** sim — uma conversa por rodada, sem contexto anterior

> **Notas de protocolo (para o operador — NÃO fazem parte do prompt):**
>
> - **Alvo limpo verificado.** O bug **W-SILENT** (mensagens de `user-not-found`
>   e `wrong-password` trocadas) estava ativo em `lib/login.dart` e foi
>   **revertido** antes desta rodada, a pedido do autor.
>   `git diff main -- lib/login.dart` agora mostra apenas a injeção de
>   dependência de `auth`; `lib/tela-inicial.dart` é idêntico a `main`.
>   Nenhum bug plantado no fluxo.
> - **Limitação de testabilidade conhecida e sistemática:** `TelaInicialScreen`
>   acessa `FirebaseAuth.instance` e `FirebaseFirestore.instance` **diretamente,
>   sem injeção**, ao contrário de `LoginScreen`. Isso tornou o teste do fluxo
>   de sucesso impossível de isolar nas 3 rodadas W-SILENT do piloto.
>   `Firebase.initializeApp()` com opções falsas **não resolve**
>   (`PlatformException: channel-error`). Esperar que o modelo esbarre nisso.
> - **Não reaproveitar o exemplo few-shot do
>   `prompts/PROMPT_TEMPLATE_INTEGRATION.md`:** ele usa
>   `MockFirebaseAuth(authExceptions: AuthExceptions(...))`, API que não existe
>   no `firebase_auth_mocks` e que induziu erro repetido nas rodadas W-SILENT —
>   além de conter um erro de sintaxe (parêntese extra). O exemplo deste prompt
>   foi reescrito, é sintaticamente válido e não usa essa API.
> - Código das duas telas colado **verbatim e completo**, sem simplificação.


---

## Prompt (selecionar tudo abaixo desta linha até o próximo `---` e colar no ChatGPT)

---

Gere um teste de integração em Dart usando flutter_test para o fluxo do aplicativo Flutter "Sintonize" descrito abaixo.

Antes, veja um exemplo de teste de integração que cobre um fluxo de formulário com autenticação mockada:

**Exemplo — teste de integração de um fluxo de formulário:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  group('Fluxo de Autenticacao', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: false);
    });

    Widget montarApp() {
      return MaterialApp(
        routes: {
          '/': (_) => FormularioScreen(auth: mockAuth),
          '/destino': (_) => const DestinoScreen(),
        },
      );
    }

    testWidgets('fluxo completo: submissao valida navega para a tela destino',
        (tester) async {
      await tester.pumpWidget(montarApp());

      await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'senha123');
      await tester.tap(find.text('Enviar'));
      await tester.pumpAndSettle();

      expect(find.byType(DestinoScreen), findsOneWidget);
    });

    testWidgets('campos vazios exibem erro de validacao e nao navegam',
        (tester) async {
      await tester.pumpWidget(montarApp());

      await tester.tap(find.text('Enviar'));
      await tester.pump();

      expect(find.text('Campo obrigatorio'), findsWidgets);
      expect(find.byType(DestinoScreen), findsNothing);
    });
  });
}
```

Agora, gere um teste de integração para o seguinte fluxo:

O usuario preenche e-mail e senha na LoginScreen e toca em "Entrar". Se a autenticacao no Firebase for bem-sucedida, o app navega para a TelaInicialScreen; se falhar, a LoginScreen exibe um SnackBar vermelho com a mensagem de erro correspondente ao codigo retornado pelo Firebase.

Código das telas envolvidas:

```dart
// ===== lib/login.dart =====
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cadastro.dart';
import 'recup-senha.dart';
import 'tela-inicial.dart';

class LoginScreen extends StatelessWidget {
  final FirebaseAuth? auth;

  LoginScreen({
    super.key,
    this.auth,
  });

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
        final firebaseAuth = auth ?? FirebaseAuth.instance;
        await firebaseAuth
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
                                    builder: (context) => CadastroScreen(auth: auth)),
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
