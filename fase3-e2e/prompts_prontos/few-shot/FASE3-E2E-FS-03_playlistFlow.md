# FASE3-E2E-FS-03_playlistFlow

**Nível:** E2E (integration_test, no AVD, contra os emuladores Firebase) | **Estratégia:** Few-shot
**Alvo:** fluxo de criar playlist — tela de boas-vindas → `LoginScreen` → `TelaInicialScreen` → `UsuarioScreen` → `CriarPlaylistScreen` (`lib/main.dart`, `lib/login.dart`, `lib/tela-inicial.dart`, `lib/usuario.dart`, `lib/criar_playlist.dart`)
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
> - Derivado de `fase2/prompts_prontos/integration/…/FASE2-INT-FS-03_playlistFlow.md`:
>   mesma estrutura; o que era mock virou emulador + navegação real.


---

## Prompt (selecionar tudo abaixo desta linha até o próximo `---` e colar no modelo da rodada — ChatGPT ou Gemini)

---

Gere um teste end-to-end em Dart, com o pacote integration_test do Flutter, para o fluxo do aplicativo Flutter "Sintonize" descrito abaixo.

Antes, veja um exemplo de teste end-to-end de outro aplicativo, que roda o app real em um emulador contra os emuladores do Firebase e cobre um fluxo de recuperação de senha:

**Exemplo — teste end-to-end de um fluxo de recuperação de senha:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meu_app/main.dart';
import 'package:meu_app/recuperar_senha_screen.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('não apareceu: $finder');
  }

  testWidgets('recuperar senha: e-mail cadastrado recebe confirmação',
      (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Esqueci minha senha'));
    await esperar(tester, find.byType(RecuperarSenhaScreen));

    await tester.enterText(find.byType(TextFormField).first, 'user@test.com');
    await tester.tap(find.text('Enviar'));
    await esperar(tester, find.text('E-mail de recuperação enviado'));

    expect(find.byType(RecuperarSenhaScreen), findsOneWidget);
  });

  testWidgets('recuperar senha: e-mail inválido mostra erro de validação',
      (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Esqueci minha senha'));
    await esperar(tester, find.byType(RecuperarSenhaScreen));

    await tester.enterText(find.byType(TextFormField).first, 'nao-e-um-email');
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe um e-mail válido'), findsOneWidget);
  });
}
```

Agora, gere um teste end-to-end para o seguinte fluxo:

O usuário acessa a CriarPlaylistScreen, que busca as músicas disponíveis no Firestore assim que é montada. O usuário digita um nome para a nova playlist, seleciona uma ou mais músicas da lista marcando os checkboxes, e toca em "Salvar Playlist" para persistir a playlist na coleção `playlists` do Firestore, associada ao usuário autenticado.

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

// ===== lib/usuario.dart =====
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintonize/detalhesplaylist.dart';
import 'tela-inicial.dart';
import 'main.dart';
import 'excluir-conta.dart';
import 'alterar-dados.dart';
import 'criar_playlist.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({super.key});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  int _selectedIndex = 0;
  String userName = 'Carregando...';
  final User? user = FirebaseAuth.instance.currentUser;
  List<DocumentSnapshot> playlists = [];
  List<DocumentSnapshot> availableSongs = [];
  bool isLoadingPlaylists = true;
  bool isLoadingSongs = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchPlaylists();
    _fetchAvailableSongs();
  }

  Future<void> _fetchUserName() async {
    if (user != null) {
      try {
        final DocumentSnapshot<Map<String, dynamic>> userDoc =
            await FirebaseFirestore.instance
                .collection('usuarios')
                .doc(user!.uid)
                .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null && userData.containsKey('nome')) {
            setState(() {
              userName = userData['nome'];
            });
          } else {
            setState(() {
              userName = 'Usuário';
            });
          }
        } else {
          setState(() {
            userName = 'Usuário não encontrado';
          });
        }
      } catch (e) {
        setState(() {
          userName = 'Erro ao carregar usuário';
        });
        print("Erro ao carregar nome do usuário: $e");
      }
    } else {
      setState(() {
        userName = 'Usuário não autenticado';
      });
    }
  }

  Future<void> _fetchPlaylists() async {
    if (user != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('playlists')
            .where('userId', isEqualTo: user!.uid)
            .get();

        setState(() {
          playlists = snapshot.docs;
          isLoadingPlaylists = false;
        });
      } catch (e) {
        setState(() {
          isLoadingPlaylists = false;
        });
        print("Erro ao carregar playlists: $e");
      }
    }
  }

  Future<void> _fetchAvailableSongs() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('musica').get();

      setState(() {
        availableSongs = snapshot.docs;
        isLoadingSongs = false;
      });
    } catch (e) {
      setState(() {
        isLoadingSongs = false;
      });
      print("Erro ao carregar músicas disponíveis: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 30),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TelaInicialScreen(),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Bem-vindo(a), $userName!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.person, color: Colors.white, size: 50),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: [
                  _buildMenuItem('Criar Playlist', Icons.add, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CriarPlaylistScreen(editPlaylist: {})),
                    ).then((_) => _fetchPlaylists());
                  }),
                  const SizedBox(height: 20),
                  if (isLoadingPlaylists)
                    const Center(child: CircularProgressIndicator())
                  else if (playlists.isNotEmpty)
                    ...playlists.map((playlist) {
                      final playlistData =
                          playlist.data() as Map<String, dynamic>;
                      final name = playlistData['nome'] ?? 'Sem nome';
                      final musicas = playlistData['musicas'] ?? [];
                      final musicCount = musicas.length;

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontFamily: 'Piazzolla',
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            '$musicCount músicas',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontFamily: 'Piazzolla',
                              fontSize: 14,
                            ),
                          ),
                          tileColor: Colors.white,
                          onTap: () {
                            _showPlaylistDetails(
                                context, playlist.id, playlistData, musicas);
                          },
                        ),
                      );
                    }).toList()
                  else
                    const Center(
                      child: Text(
                        'Você ainda não criou nenhuma playlist.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontFamily: 'Piazzolla',
                          fontSize: 18,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
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
              icon: Icon(Icons.edit),
              label: 'Alterar Dados',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.exit_to_app),
              label: 'Sair da Conta',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delete),
              label: 'Excluir Conta',
            ),
          ],
          onTap: (index) async {
            setState(() {
              _selectedIndex = index;
            });

            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            } else if (index == 0) {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AlterarDadosScreen()),
              );
              if (result == true) {
                _fetchUserName();
              }
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ExcluirContaScreen()),
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

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: const Color(0xFFF14621)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'Piazzolla',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaylistDetails(BuildContext context, String playlistId,
      Map<String, dynamic> playlistData, List<dynamic> musicas) async {
    final List<String> musicasList = List<String>.from(musicas);
    final playlistAlterada = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesPlaylistScreen(
          playlistId: playlistId,
          playlistData: playlistData,
          musicas: musicasList,
        ),
      ),
    );
    if (playlistAlterada == true) {
      _fetchPlaylists();
    }
  }
}

// ===== lib/criar_playlist.dart =====
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CriarPlaylistScreen extends StatefulWidget {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;

  CriarPlaylistScreen({
    super.key,
    required Map<String, dynamic> editPlaylist,
    this.auth,
    this.firestore,
  });

  @override
  _CriarPlaylistScreenState createState() => _CriarPlaylistScreenState();
}

class _CriarPlaylistScreenState extends State<CriarPlaylistScreen> {
  FirebaseAuth get _auth => widget.auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => widget.firestore ?? FirebaseFirestore.instance;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<String> _musicasSelecionadas = [];
  List<DocumentSnapshot> _musicasDataset = [];
  List<DocumentSnapshot> _musicasFiltradas = [];
  String? _playlistName;

  @override
  void initState() {
    super.initState();
    _fetchMusicas();
    _searchController.addListener(_filterMusicas);
  }

  Future<void> _fetchMusicas() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('musica').get();
      setState(() {
        _musicasDataset = snapshot.docs;
        _musicasFiltradas = _musicasDataset;
      });
    } catch (e) {
      print("Erro ao buscar músicas: $e");
    }
  }

  void _filterMusicas() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _musicasFiltradas = _musicasDataset.where((musica) {
        String musicaNome = musica['track_name'].toLowerCase();
        String artistName = musica['artist_name']?.toLowerCase() ?? '';
        return musicaNome.contains(query) || artistName.contains(query);
      }).toList();
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 30),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Criando Playlist',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.person, color: Colors.white, size: 50),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome da Playlist',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _playlistName = value;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar Música ou Artista',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _musicasFiltradas.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _musicasFiltradas.length,
                      itemBuilder: (context, index) {
                        var musica = _musicasFiltradas[index];
                        String musicaNome = _formatName(musica['track_name']);
                        String artistName = _formatName(
                            musica['artist_name'] ?? 'Desconhecido');

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            title: Text('$musicaNome - $artistName'),
                            trailing: IconButton(
                              icon: Icon(
                                _musicasSelecionadas
                                        .contains(musica['track_name'])
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: const Color(0xFFF14621),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_musicasSelecionadas
                                      .contains(musica['track_name'])) {
                                    _musicasSelecionadas
                                        .remove(musica['track_name']);
                                  } else {
                                    _musicasSelecionadas
                                        .add(musica['track_name']);
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                if (_playlistName != null && _playlistName!.isNotEmpty) {
                  _salvarPlaylist();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Nome da playlist é obrigatório')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF14621),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Salvar Playlist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _salvarPlaylist() async {
    final user = _auth.currentUser;

    if (user != null) {
      try {
        await _firestore.collection('playlists').add({
          'userId': user.uid,
          'nome': _playlistName,
          'musicas': _musicasSelecionadas,
          'dataCriacao': Timestamp.now(),
        });

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar a playlist: $e')),
        );
      }
    }
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
