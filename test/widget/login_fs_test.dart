import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/login_screen.dart'; // <- CORREÇÃO AQUI

void main() {
  group('LoginScreen Widget Tests', () {
    Future<void> pumpLoginScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
    }

    testWidgets('deve mostrar erro quando email está vazio', (tester) async {
      await pumpLoginScreen(tester);

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Por favor, insira seu e-mail'), findsOneWidget);
    });

    testWidgets('deve mostrar erro quando email é inválido', (tester) async {
      await pumpLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'emailinvalido');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
    });

    testWidgets('deve mostrar erro quando senha está vazia', (tester) async {
      await pumpLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'teste@email.com');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Por favor, insira sua senha'), findsOneWidget);
    });

    testWidgets('deve mostrar erro quando senha < 6 caracteres', (tester) async {
      await pumpLoginScreen(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'teste@email.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123');

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
    });

    testWidgets('deve renderizar elementos principais', (tester) async {
      await pumpLoginScreen(tester);

      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
