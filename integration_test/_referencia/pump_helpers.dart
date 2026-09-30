import 'package:flutter/gestures.dart' show HitTestResult;
import 'package:flutter/material.dart';
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

/// Bombeia até o finder sumir. Serve para esperar o fim de um `pop`: durante
/// a transição a tela de baixo já é encontrada enquanto a de cima ainda
/// está saindo, e `pumpAndSettle` não serve quando a tela de baixo tem um
/// CircularProgressIndicator (animação sem fim).
Future<void> pumpAteSumir(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 20)}) async {
  final fim = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(fim)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isEmpty) return;
  }
  fail('não sumiu em ${timeout.inSeconds}s: $finder');
}

/// Fecha o teclado e espera o viewport voltar ao tamanho da tela. Com o
/// teclado aberto o viewport encolhe e um `tap` em botão no rodapé cai fora
/// da área visível. `pumpAndSettle` não espera o teclado recolher: a
/// animação é do Android, não do Flutter. Por isso a espera é por
/// `viewInsets.bottom == 0` (fluxo de cadastro, runs 1 e 2).
Future<void> fecharTeclado(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  final fim = DateTime.now().add(const Duration(seconds: 5));
  while (tester.view.viewInsets.bottom > 0 && DateTime.now().isBefore(fim)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(tester.view.viewInsets.bottom, 0, reason: 'teclado não recolheu');
  await tester.pumpAndSettle();
}

/// Rola até o finder e só toca depois de um hit test real acertar o alvo.
/// Mesmo com `viewInsets` em 0 o toque ainda falhava às vezes (fluxo de
/// cadastro, run 3: o hit test parava no Material do Scaffold sem entrar no
/// body). Repete por até 8 s e imprime a geometria a cada erro, para registro.
Future<void> tocarQuandoAlcancavel(WidgetTester tester, Finder finder) async {
  final limite = DateTime.now().add(const Duration(seconds: 8));
  var tentativa = 0;
  while (true) {
    tentativa++;
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    final centro = tester.getCenter(finder, warnIfMissed: false);
    final alvo = tester.renderObject(finder);
    final hit = HitTestResult();
    tester.binding.hitTestInView(hit, centro, tester.view.viewId);
    if (hit.path.any((e) => identical(e.target, alvo))) break;

    final mq = MediaQuery.of(tester.element(finder));
    final topo = hit.path.take(3).map((e) => e.target.runtimeType).join(' > ');
    // ignore: avoid_print
    print('$finder fora do alvo (tentativa $tentativa): centro=$centro '
        'rect=${tester.getRect(finder)} tela=${mq.size} '
        'viewInsets=${mq.viewInsets.bottom} padding=${mq.padding} '
        'hit=[$topo]');
    if (!DateTime.now().isBefore(limite)) break;
    await tester.pump(const Duration(milliseconds: 250));
  }
  await tester.tap(finder);
}
