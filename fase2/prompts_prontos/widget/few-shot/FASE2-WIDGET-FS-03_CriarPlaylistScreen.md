# FASE2-WIDGET-FS-03_CriarPlaylistScreen

**Nível:** Widget | **Estratégia:** Few-shot
**Alvo:** `CriarPlaylistScreen` — `lib/criar_playlist.dart` (alvo limpo, sem bug plantado)
**Conversa nova:** sim — uma conversa por rodada, sem contexto anterior

> **Notas de protocolo (para o operador — NÃO fazem parte do prompt):**
>
> - **Atenção — histórico da Fase 1.** `CriarPlaylistScreen` teve **0% de
>   aprovação nas 3 estratégias da Fase 1**, por alucinação de caminho de
>   import (o modelo importava de um caminho que não existe no projeto).
>   Confirme, ao revisar o teste gerado, que ele usa
>   `import 'package:sintonize/criar_playlist.dart';` — o caminho real do
>   arquivo é `lib/criar_playlist.dart`.
> - `CriarPlaylistScreen` exige o parâmetro nomeado **obrigatório**
>   `editPlaylist` (`Map<String, dynamic>`). Como esta rodada testa o fluxo de
>   **criação** (não de edição), instancie o widget com um mapa vazio (`{}`).
> - O widget já recebe `auth` e `firestore` por injeção opcional — os mocks
>   entram por aí, sem precisar de `Firebase.initializeApp()`.
> - **Alvo verificado limpo.** Os bugs **W-CRASH** (`_filterMusicas`, acesso a
>   `artist_name` sem null-safety) e **I-SILENT** (`_salvarPlaylist`, nome
>   hardcoded `'Nova Playlist'`) estavam ativos neste mesmo arquivo e foram
>   revertidos antes desta rodada. `git diff main -- lib/criar_playlist.dart`
>   mostra apenas a injeção de dependência. Código colado verbatim, sem
>   simplificação.


---

## Prompt (selecionar tudo abaixo desta linha até o próximo `---` e colar no ChatGPT)

---

Gere widget tests em Dart usando flutter_test para o widget abaixo.

Antes, veja um exemplo de widget test bem escrito para um formulário Flutter com Firebase mockado:

**Exemplo — widget test de formulário de login:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  group('MeuFormulario Widget', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    testWidgets('deve mostrar erro quando email está vazio', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MeuFormulario()),
      );

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Campo obrigatório'), findsOneWidget);
    });

    testWidgets('deve mostrar erro para email inválido', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: MeuFormulario()),
      );

      await tester.enterText(find.byType(TextFormField).first, 'invalido');
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Email inválido'), findsOneWidget);
    });
  });
}
```

Agora, gere widget tests para este widget, seguindo o mesmo padrão do exemplo:

```dart
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

O widget faz parte do projeto Flutter "sintonize".

Dependências disponíveis para mocking:
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
