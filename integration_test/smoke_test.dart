import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/login.dart';
import 'package:sintonize/main.dart';

import 'firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  testWidgets('fumaça: o app abre e chega à LoginScreen', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // A home é a HomeScreen (boas-vindas); a LoginScreen abre pelo botão.
    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
