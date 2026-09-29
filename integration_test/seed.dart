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

/// Nome do usuário do seed, como `lib/cadastro.dart` gravaria em
/// `usuarios/{uid}.nome`. A `TelaInicialScreen` lê esse campo para a saudação.
const String seedNome = 'tester sintonize';

/// Gêneros favoritos do usuário do seed (`usuarios/{uid}.generos_favoritos`,
/// gravado por `lib/generos-cadastro.dart`). Cobrem 2 das 5 músicas.
const List<String> seedGeneros = ['rock', 'pop'];

/// Popula os emuladores. Chamar depois de `setupFirebaseEmulators()`.
/// Idempotente: as músicas têm IDs fixos, o usuário é reaproveitado se já
/// existir e o doc `usuarios/{uid}` é regravado por inteiro. Termina com o
/// usuário deslogado.
Future<void> seedEmulators() async {
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  UserCredential cred;
  try {
    cred = await auth.createUserWithEmailAndPassword(
      email: seedEmail,
      password: seedSenha,
    );
  } on FirebaseAuthException catch (e) {
    if (e.code != 'email-already-in-use') rethrow;
    cred = await auth.signInWithEmailAndPassword(
      email: seedEmail,
      password: seedSenha,
    );
  }
  final uid = cred.user!.uid;

  // Mesmo formato do doc criado pelo cadastro (cadastro.dart) e completado
  // pela tela de gêneros (generos-cadastro.dart).
  await firestore.collection('usuarios').doc(uid).set({
    'nome': seedNome,
    'data_nasc': '01/01/2000',
    'email': seedEmail,
    'endereco': {
      'rua': 'Rua do Seed',
      'numero': '1',
      'bairro': 'Centro',
      'cidade': 'Recife',
      'estado': 'PE',
      'cep': '50000-000',
    },
    'generos_favoritos': seedGeneros,
  });
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
