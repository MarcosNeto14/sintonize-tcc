import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Usuário fixo do seed.
const String seedEmail = 'tester@sintonize.test';
const String seedSenha = 'senha123';

/// 5 músicas da coleção `musica`, com os campos que
/// `lib/criar_playlist.dart` lê (`track_name`, `artist_name`) e o `genre`
/// usado pela recomendação de `lib/tela-inicial.dart`.
const List<Map<String, String>> seedMusicas = [
  {'track_name': 'bohemian rhapsody', 'artist_name': 'queen', 'genre': 'rock'},
  {'track_name': 'billie jean', 'artist_name': 'michael jackson', 'genre': 'pop'},
  {'track_name': 'take five', 'artist_name': 'dave brubeck', 'genre': 'jazz'},
  {'track_name': 'the thrill is gone', 'artist_name': 'b.b. king', 'genre': 'blues'},
  {'track_name': 'one love', 'artist_name': 'bob marley', 'genre': 'reggae'},
];

/// Popula os emuladores. Chamar depois de `setupFirebaseEmulators()`.
/// Idempotente: as músicas têm IDs fixos e o usuário é reaproveitado se já
/// existir. Termina com o usuário deslogado.
Future<void> seedEmulators() async {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  try {
    await auth.createUserWithEmailAndPassword(
      email: seedEmail,
      password: seedSenha,
    );
  } on FirebaseAuthException catch (e) {
    if (e.code != 'email-already-in-use') rethrow;
  }
  await auth.signOut();

  final batch = firestore.batch();
  for (var i = 0; i < seedMusicas.length; i++) {
    batch.set(
      firestore.collection('musica').doc('seed-musica-${i + 1}'),
      seedMusicas[i],
    );
  }
  await batch.commit();
}
