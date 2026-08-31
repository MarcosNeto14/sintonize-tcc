# FASE2-WCRASH-COT

**Bug ID:** W-CRASH | **Nível:** Widget | **Estratégia:** Chain-of-Thought  
**Alvo:** `CriarPlaylistScreen` (`_filterMusicas`) — `lib/criar_playlist.dart`  
**Conversa nova:** sim — uma conversa por rodada, sem contexto anterior

---

## Prompt (selecionar tudo abaixo desta linha até o próximo `---` e colar no ChatGPT)

---

Quero que você gere widget tests em Dart para o widget Flutter abaixo. Antes de escrever os testes, siga estes passos:

1. **Analise o widget:** Descreva em 3-5 frases o que ele faz, quais são seus elementos interativos e quais serviços externos ele usa.
2. **Identifique as dependências que precisam de mock:** Liste quais serviços (Firebase Auth, Firestore, HTTP) são usados e como devem ser mockados.
3. **Identifique os cenários de teste:** Liste todos os cenários relevantes, incluindo:
   - Renderização básica (o widget aparece corretamente?)
   - Validação de formulário (campos vazios, dados inválidos)
   - Interação do usuário (toques, entrada de texto, scroll)
   - Cenários de sucesso (fluxo completo funciona)
   - Cenários de erro (Firebase retorna erro, rede falha)
4. **Escreva os testes:** Para cada cenário, escreva um testWidgets() completo.

IMPORTANTE: Não modifique o código do widget. Apenas gere testes.

Widget a testar:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CriarPlaylistScreen extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  CriarPlaylistScreen({
    super.key,
    required Map<String, dynamic> editPlaylist,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : auth = auth ?? FirebaseAuth.instance,
       firestore = firestore ?? FirebaseFirestore.instance;

  @override
  _CriarPlaylistScreenState createState() => _CriarPlaylistScreenState();
}

class _CriarPlaylistScreenState extends State<CriarPlaylistScreen> {
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
      QuerySnapshot snapshot = await widget.firestore.collection('musica').get();
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
        String artistName = musica['artist_name'].toLowerCase();
        return musicaNome.contains(query) || artistName.contains(query);
      }).toList();
    });
  }

  String _formatName(String name) {
    if (name.isEmpty) return name;
    return name.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
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
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back), onPressed: () { Navigator.pop(context); }),
                    Expanded(child: Text('Criando Playlist', textAlign: TextAlign.center)),
                    const Icon(Icons.person, size: 50),
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
              decoration: InputDecoration(labelText: 'Nome da Playlist',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              onChanged: (value) { setState(() { _playlistName = value; }); },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar Música ou Artista',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
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
                        return ListTile(
                          title: Text('${_formatName(musica["track_name"])} - ${_formatName(musica["artist_name"] ?? "Desconhecido")}'),
                          trailing: IconButton(
                            icon: Icon(_musicasSelecionadas.contains(musica['track_name']) ? Icons.check_box : Icons.check_box_outline_blank),
                            onPressed: () {
                              setState(() {
                                if (_musicasSelecionadas.contains(musica['track_name'])) {
                                  _musicasSelecionadas.remove(musica['track_name']);
                                } else {
                                  _musicasSelecionadas.add(musica['track_name']);
                                }
                              });
                            },
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
                    const SnackBar(content: Text('Nome da playlist é obrigatório')),
                  );
                }
              },
              child: const Text('Salvar Playlist'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _salvarPlaylist() async {
    final user = widget.auth.currentUser;
    if (user != null) {
      try {
        await widget.firestore.collection('playlists').add({
          'userId': user.uid,
          'nome': 'Nova Playlist',
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
Use `import 'package:sintonize/criar_playlist.dart';` para os imports.

Dependências disponíveis para mocking:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
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
