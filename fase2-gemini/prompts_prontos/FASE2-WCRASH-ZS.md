# FASE2-WCRASH-ZS

**Bug ID:** W-CRASH | **Nível:** Widget | **Estratégia:** Zero-shot  
**Alvo:** `CriarPlaylistScreen` (`_filterMusicas`) — `lib/criar_playlist.dart`  
**Conversa nova:** sim — uma conversa por rodada, sem contexto anterior

---

## Prompt (selecionar tudo abaixo desta linha até o próximo `---` e colar no ChatGPT)

---

Gere widget tests em Dart usando o pacote flutter_test para o seguinte widget Flutter:

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
      QuerySnapshot snapshot =
          await widget.firestore.collection('musica').get();
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
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9E80), Color(0xFFF14621)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                      onPressed: () { Navigator.pop(context); },
                    ),
                    Expanded(
                      child: Text(
                        'Criando Playlist',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 18,
                          fontFamily: 'Poppins', fontWeight: FontWeight.bold,
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
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
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
                        String musicaNome = _formatName(musica['track_name']);
                        String artistName = _formatName(musica['artist_name'] ?? 'Desconhecido');
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            title: Text('$musicaNome - $artistName'),
                            trailing: IconButton(
                              icon: Icon(
                                _musicasSelecionadas.contains(musica['track_name'])
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: const Color(0xFFF14621),
                              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF14621),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text('Salvar Playlist', style: TextStyle(color: Colors.white, fontSize: 16)),
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

O widget faz parte de um projeto Flutter chamado "sintonize".

Dependências disponíveis para mocking:
- firebase_auth_mocks (para mockar FirebaseAuth)
- fake_cloud_firestore (para mockar Firestore)
- mockito (para mocks gerais)

Requisitos:
- Use testWidgets() do flutter_test
- Envolva o widget em MaterialApp para suportar navegação
- Configure os mocks necessários para Firebase Auth e/ou Firestore
- Teste cenários de validação de formulário (campos vazios, dados inválidos)
- Teste interações do usuário (tap em botões, entrada de texto)
- Os testes devem ser executáveis com `flutter test`
- Use `import 'package:sintonize/criar_playlist.dart';` para importar o widget

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
