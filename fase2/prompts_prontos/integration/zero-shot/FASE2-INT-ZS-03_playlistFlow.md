# FASE2-INT-ZS-03_playlistFlow

**Nível:** Integração | **Estratégia:** Zero-shot
**Alvo:** fluxo de criação de playlist — `CriarPlaylistScreen`
(`lib/criar_playlist.dart`) — alvo limpo, W-CRASH e I-SILENT revertidos
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
>   hardcoded `'Nova Playlist'`) estavam ativos neste arquivo e foram
>   revertidos antes desta rodada. `git diff main -- lib/criar_playlist.dart`
>   mostra apenas a injeção de dependência.
> - **Condição fixa de protocolo, herdada do piloto I-SILENT:** o cenário de
>   teste do fluxo de sucesso não precisa evitar o campo "Pesquisar Música ou
>   Artista" — o bug W-CRASH que isso protegia já foi revertido nesta branch.
>   Ainda assim, o fluxo descrito abaixo não exercita a busca, por não fazer
>   parte do caminho principal de criação de playlist.
> - Este alvo é uma única tela (sem navegação entre telas) — o teste é uma
>   "integração" no sentido de exercitar o fluxo completo de interação com o
>   Firestore (buscar músicas → selecionar → salvar), e não uma travessia de
>   múltiplas telas.
> - Código colado **verbatim e completo**, sem simplificação.


---

## Prompt (selecionar tudo abaixo desta linha até o próximo `---` e colar no ChatGPT)

---

Gere um teste de integração em Dart usando flutter_test para o seguinte fluxo do aplicativo Flutter "Sintonize":

O usuário acessa a CriarPlaylistScreen, que busca as músicas disponíveis no Firestore assim que é montada. O usuário digita um nome para a nova playlist, seleciona uma ou mais músicas da lista marcando os checkboxes, e toca em "Salvar Playlist" para persistir a playlist na coleção `playlists` do Firestore, associada ao usuário autenticado.

Código da tela envolvida:

```dart
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

Dependências disponíveis para mocking:
- firebase_auth_mocks (MockFirebaseAuth)
- fake_cloud_firestore (FakeFirebaseFirestore)
- mockito

Requisitos:
- Use testWidgets() do flutter_test
- Pré-popule a coleção `musica` do Firestore fake com pelo menos dois
  documentos antes do pump, para exercitar a listagem e a seleção
- Configure os mocks de Firebase Auth (usuário autenticado) e Firestore
- Teste o fluxo completo ponta a ponta: montagem → busca de músicas →
  digitar nome → selecionar músicas → salvar → verificar o documento
  persistido na coleção `playlists` (incluindo que o campo `nome` corresponde
  exatamente ao valor digitado, não um valor fixo)
- Teste também cenários de erro (nome vazio não deve chamar `_salvarPlaylist`,
  usuário não autenticado)
- Os testes devem ser executáveis com `flutter test test/integration/`
- Use `import 'package:sintonize/...'` para os imports do projeto
- O widget está em `lib/criar_playlist.dart` — use `import 'package:sintonize/criar_playlist.dart';` para importá-lo.

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
