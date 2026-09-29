import 'package:flutter_test/flutter_test.dart';

/// Bombeia até o finder aparecer ou o tempo esgotar. `pumpAndSettle` não
/// serve depois de uma chamada de rede: há Futures e FutureBuilders em série
/// e o frame "assenta" antes de a resposta chegar.
Future<void> pumpAte(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 20)}) async {
  final fim = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(fim)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('não apareceu em ${timeout.inSeconds}s: $finder');
}
