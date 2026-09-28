import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sintonize/firebase_options.dart';

/// Host dos emuladores Firebase.
/// AVD: 10.0.2.2 (padrão). Dispositivo físico: --dart-define=EMU_HOST=localhost
/// com `adb reverse tcp:9099 tcp:9099` e `adb reverse tcp:8080 tcp:8080`.
const String emulatorHost =
    String.fromEnvironment('EMU_HOST', defaultValue: '10.0.2.2');

const int authEmulatorPort = 9099;
const int firestoreEmulatorPort = 8080;

class FirebaseTestHelper {
  static bool _initialized = false;
}

/// Inicializa o Firebase e aponta Auth e Firestore para os emuladores.
/// Chamadas repetidas no mesmo processo não fazem nada.
Future<void> setupFirebaseEmulators() async {
  if (FirebaseTestHelper._initialized) return;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.useAuthEmulator(emulatorHost, authEmulatorPort);
  FirebaseFirestore.instance
      .useFirestoreEmulator(emulatorHost, firestoreEmulatorPort);

  FirebaseTestHelper._initialized = true;
}
