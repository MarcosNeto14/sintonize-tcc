# FASE2-ISILENT-FS

**Bug ID:** I-SILENT | **Nível:** Integração | **Estratégia:** Few-shot  
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

Gere um teste de integração em Dart usando flutter_test para o fluxo do aplicativo Flutter "Sintonize" descrito abaixo.

Antes, veja um exemplo de teste de integração que verifica dados gravados no Firestore:

**Exemplo — teste de integração: verifica documento salvo no Firestore:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('Fluxo de Criação', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() async {
      mockAuth = MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'user123'));
      fakeFirestore = FakeFirebaseFirestore();
    });

    testWidgets('salva documento com nome correto', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: MinhaTela(auth: mockAuth, firestore: fakeFirestore)),
      );
      await tester.enterText(find.byType(TextField).first, 'Meu Nome');
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      final docs = await fakeFirestore.collection('dados').get();
      expect(docs.docs.length, 1);
      expect(docs.docs.first['nome'], 'Meu Nome');
    });

    testWidgets('exibe erro quando nome está vazio', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: MinhaTela(auth: mockAuth, firestore: fakeFirestore)),
      );
      await tester.tap(find.text('Salvar'));
      await tester.pump();
      expect(find.textContaining('obrigatório'), findsOneWidget);
    });
  });
}
```

Agora, gere um teste de integração para o seguinte fluxo:

O usuário acessa a CriarPlaylistScreen, digita um nome para a nova playlist, seleciona músicas da lista e salva a playlist no Firestore.

Código das telas envolvidas:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CriarPlaylistScreen extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  CriarPlaylistScreen({super.key, required Map<String, dynamic> editPlaylist,
      FirebaseAuth? auth, FirebaseFirestore? firestore})
      : auth = auth ?? FirebaseAuth.instance,
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
      setState(() { _musicasDataset = snapshot.docs; _musicasFiltradas = _musicasDataset; });
    } catch (e) { print("Erro: $e"); }
  }

  void _filterMusicas() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _musicasFiltradas = _musicasDataset.where((m) {
        return m['track_name'].toLowerCase().contains(query) ||
               m['artist_name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: [
      TextField(controller: _nomeController,
          decoration: const InputDecoration(labelText: 'Nome da Playlist'),
          onChanged: (v) { setState(() { _playlistName = v; }); }),
      TextField(controller: _searchController,
          decoration: const InputDecoration(labelText: 'Pesquisar Música ou Artista')),
      Expanded(child: _musicasFiltradas.isEmpty
          ? const CircularProgressIndicator()
          : ListView.builder(
              itemCount: _musicasFiltradas.length,
              itemBuilder: (ctx, i) {
                var m = _musicasFiltradas[i];
                return ListTile(
                  title: Text('${m["track_name"]} - ${m["artist_name"] ?? "Desconhecido"}'),
                  trailing: IconButton(
                    icon: Icon(_musicasSelecionadas.contains(m['track_name']) ? Icons.check_box : Icons.check_box_outline_blank),
                    onPressed: () { setState(() {
                      if (_musicasSelecionadas.contains(m['track_name'])) { _musicasSelecionadas.remove(m['track_name']); }
                      else { _musicasSelecionadas.add(m['track_name']); }
                    }); },
                  ),
                );
              })),
      ElevatedButton(
        onPressed: () {
          if (_playlistName != null && _playlistName!.isNotEmpty) { _salvarPlaylist(); }
          else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nome da playlist é obrigatório'))); }
        },
        child: const Text('Salvar Playlist'),
      ),
    ]));
  }

  Future<void> _salvarPlaylist() async {
    final user = widget.auth.currentUser;
    if (user != null) {
      try {
        await widget.firestore.collection('playlists').add({
          'userId': user.uid, 'nome': 'Nova Playlist',
          'musicas': _musicasSelecionadas, 'dataCriacao': Timestamp.now(),
        });
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar a playlist: $e')));
      }
    }
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
