import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'firebase_test_helper.dart';
import 'seed.dart';

/// Só popula os emuladores e confere que o que foi gravado está lá.
/// Serve para checar o seed isolado, no Emulator UI (http://127.0.0.1:4000).
/// Os testes de fluxo chamam `seedEmulators()` por conta própria.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  testWidgets('seed: usuário e 5 músicas nos emuladores', (tester) async {
    await seedEmulators();

    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    expect(auth.currentUser, isNull, reason: 'o seed termina deslogado');

    final cred = await auth.signInWithEmailAndPassword(
      email: seedEmail,
      password: seedSenha,
    );
    final userDoc =
        await firestore.collection('usuarios').doc(cred.user!.uid).get();
    expect(userDoc.exists, isTrue);
    expect(userDoc.data()?['nome'], seedNome);
    expect(userDoc.data()?['generos_favoritos'], seedGeneros);
    await auth.signOut();

    final musicas = await firestore.collection('musica').get();
    expect(musicas.docs.length, seedMusicas.length);
    expect(
      musicas.docs.map((d) => d.id).toSet(),
      {for (var i = 1; i <= seedMusicas.length; i++) 'seed-musica-$i'},
    );
  });
}
