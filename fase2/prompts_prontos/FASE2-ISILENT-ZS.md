# FASE2-ISILENT-ZS

**Bug ID:** I-SILENT | **Nível:** Integração | **Estratégia:** Zero-shot  
**Alvo:** fluxo de criação de playlist — `CriarPlaylistScreen._salvarPlaylist()`  
**Arquivo:** `lib/criar_playlist.dart`  
**Conversa nova:** sim — uma conversa por rodada, sem contexto anterior

> ⚠️ **Condição fixa de protocolo:** o cenário de teste NÃO deve interagir
> com o campo "Pesquisar Música ou Artista" (`_searchController`). Digitar
> nesse campo aciona `_filterMusicas()`, que contém um bug separado (W-CRASH).
> O teste deve preencher apenas o nome da playlist, selecionar músicas pelos
> checkboxes e tocar "Salvar Playlist".

---

## Prompt (selecionar tudo abaixo desta linha até o próximo `---` e colar no ChatGPT)

---

Gere um teste de integração em Dart usando flutter_test para o seguinte fluxo do aplicativo Flutter "Sintonize":

O usuário acessa a CriarPlaylistScreen, digita um nome para a nova playlist, seleciona músicas da lista e salva a playlist no Firestore.

Código das telas envolvidas:

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
      body: Column(
        children: [
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
          Expanded(
            child: _musicasFiltradas.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _musicasFiltradas.length,
                    itemBuilder: (context, index) {
                      var musica = _musicasFiltradas[index];
                      return ListTile(
                        title: Text('${_formatName(musica["track_name"])} - ${_formatName(musica["artist_name"] ?? "Desconhecido")}'),
                        trailing: IconButton(
                          icon: Icon(_musicasSelecionadas.contains(musica['track_name'])
                              ? Icons.check_box : Icons.check_box_outline_blank),
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

Dependências disponíveis para mocking:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito

Requisitos:
- Use testWidgets() do flutter_test
- Monte a tela dentro de um MaterialApp
- Configure mocks de Firebase Auth (usuário logado) e Firestore
- Popule o Firestore fake com documentos na coleção 'musica' para que a lista apareça
- Teste o fluxo completo: digitar nome → selecionar música → salvar → verificar o documento criado na coleção 'playlists'
- Teste o cenário de nome vazio (deve exibir SnackBar de erro)
- Os testes devem ser executáveis com `flutter test test/integration/`
- Use `import 'package:sintonize/criar_playlist.dart';`

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
