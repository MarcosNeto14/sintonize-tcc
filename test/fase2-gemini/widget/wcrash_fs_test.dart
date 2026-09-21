import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// Declaração do widget alvo do teste
class CriarPlaylistScreen extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  CriarPlaylistScreen({
    super.key,
    required Map<String, dynamic> editPlaylist,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : auth = auth ?? FirebaseAuth.instance,
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
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Expanded(
                      child: Text('Criando Playlist', textAlign: TextAlign.center),
                    ),
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
              decoration: InputDecoration(
                labelText: 'Nome da Playlist',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
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
                          title: Text(
                            '${_formatName(musica["track_name"])} - ${_formatName(musica["artist_name"] ?? "Desconhecido")}',
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              _musicasSelecionadas.contains(musica['track_name'])
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
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

void main() {
  group('CriarPlaylistScreen Widget Tests', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;
    final mockUser = MockUser(uid: 'user_sintonize_123', email: 'teste@sintonize.com');

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
      fakeFirestore = FakeFirebaseFirestore();
    });

    Widget createWidgetUnderTest({Map<String, dynamic>? editPlaylist}) {
      return MaterialApp(
        home: CriarPlaylistScreen(
          editPlaylist: editPlaylist ?? {},
          auth: mockAuth,
          firestore: fakeFirestore,
        ),
      );
    }

    testWidgets('deve exibir SnackBar de erro se tentar salvar sem nome preenchido', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final salvarBtn = find.text('Salvar Playlist');
      expect(salvarBtn, findsOneWidget);
      await tester.tap(salvarBtn);
      await tester.pump();

      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);
    });

    testWidgets('deve listar músicas carregadas do Firestore', (tester) async {
      await fakeFirestore.collection('musica').add({
        'track_name': 'tempo perdido',
        'artist_name': 'legiao urbana',
      });
      await fakeFirestore.collection('musica').add({
        'track_name': 'faroeste caboclo',
        'artist_name': 'legiao urbana',
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Tempo Perdido - Legiao Urbana'), findsOneWidget);
      expect(find.text('Faroeste Caboclo - Legiao Urbana'), findsOneWidget);
    });

    testWidgets('deve alternar seleção de música ao clicar no checkbox', (tester) async {
      await fakeFirestore.collection('musica').add({
        'track_name': 'bohemian rhapsody',
        'artist_name': 'queen',
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final iconeDesmarcado = find.byIcon(Icons.check_box_outline_blank);
      expect(iconeDesmarcado, findsOneWidget);

      await tester.tap(iconeDesmarcado);
      await tester.pump();
      expect(find.byIcon(Icons.check_box), findsOneWidget);

      await tester.tap(find.byIcon(Icons.check_box));
      await tester.pump();
      expect(find.byIcon(Icons.check_box_outline_blank), findsOneWidget);
    });

    testWidgets('deve filtrar a lista ao digitar no campo de pesquisa', (tester) async {
      await fakeFirestore.collection('musica').add({
        'track_name': 'yellow',
        'artist_name': 'coldplay',
      });
      await fakeFirestore.collection('musica').add({
        'track_name': 'in the end',
        'artist_name': 'linkin park',
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Yellow - Coldplay'), findsOneWidget);
      expect(find.text('In The End - Linkin Park'), findsNothing);

      final searchField = find.widgetWithText(TextField, 'Pesquisar Música ou Artista');
      await tester.enterText(searchField, 'coldplay');
      await tester.pump();

      expect(find.text('Yellow - Coldplay'), findsOneWidget);
      expect(find.text('In The End - Linkin Park'), findsNothing);
    });

    testWidgets('deve salvar a playlist no Firestore quando o nome for preenchido', (tester) async {
      await fakeFirestore.collection('musica').add({
        'track_name': 'hotel california',
        'artist_name': 'eagles',
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(TextField, 'Nome da Playlist');
      await tester.enterText(nameField, 'Minhas Favoritas');

      await tester.tap(find.byIcon(Icons.check_box_outline_blank));
      await tester.pump();

      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      final playlistsSnapshot = await fakeFirestore.collection('playlists').get();
      expect(playlistsSnapshot.docs.length, 1);

      final playlistData = playlistsSnapshot.docs.first.data();
      expect(playlistData['userId'], mockUser.uid);
      expect(playlistData['musicas'], contains('hotel california'));
    });
  });
}
