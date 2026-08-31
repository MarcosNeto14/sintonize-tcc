import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';

/// ---------------------------------------------------------------------------
/// MOCK LOGIN SCREEN
/// ---------------------------------------------------------------------------

class LoginScreenFake extends StatelessWidget {
  const LoginScreenFake({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('LOGIN_SCREEN'),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// MAIN
/// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget buildApp() {
    return MaterialApp(
      home: CadastroScreen(),
      routes: {
        '/generos': (_) => GenerosCadastroScreen(),
      },
    );
  }

  group('CadastroScreen Integration', () {
    testWidgets(
      'deve validar campos obrigatÃ³rios',
      (tester) async {
        await tester.pumpWidget(buildApp());

        await tester.pumpAndSettle();

        await tester.tap(find.text('Cadastrar'));

        await tester.pumpAndSettle();

        expect(
          find.text('O nome Ã© obrigatÃ³rio'),
          findsOneWidget,
        );

        expect(
          find.text('O e-mail Ã© obrigatÃ³rio'),
          findsOneWidget,
        );

        expect(
          find.text('A senha Ã© obrigatÃ³ria'),
          findsOneWidget,
        );

        expect(
          find.text('O CEP Ã© obrigatÃ³rio'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve validar email invÃ¡lido',
      (tester) async {
        await tester.pumpWidget(buildApp());

        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextFormField).at(2),
          'email-invalido',
        );

        await tester.tap(find.text('Cadastrar'));

        await tester.pumpAndSettle();

        expect(
          find.text('E-mail invÃ¡lido'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve validar senha diferente',
      (tester) async {
        await tester.pumpWidget(buildApp());

        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextFormField).at(3),
          '123456',
        );

        await tester.enterText(
          find.byType(TextFormField).at(4),
          '654321',
        );

        await tester.tap(find.text('Cadastrar'));

        await tester.pumpAndSettle();

        expect(
          find.text('As senhas nÃ£o coincidem'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve preencher formulÃ¡rio corretamente',
      (tester) async {
        await tester.pumpWidget(buildApp());

        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'JoÃ£o Silva',
        );

        await tester.enterText(
          find.byType(TextFormField).at(1),
          '01011999',
        );

        await tester.enterText(
          find.byType(TextFormField).at(2),
          'joao@email.com',
        );

        await tester.enterText(
          find.byType(TextFormField).at(3),
          '123456',
        );

        await tester.enterText(
          find.byType(TextFormField).at(4),
          '123456',
        );

        await tester.enterText(
          find.byType(TextFormField).at(5),
          '50700-000',
        );

        await tester.enterText(
          find.byType(TextFormField).at(6),
          'Rua Teste',
        );

        await tester.enterText(
          find.byType(TextFormField).at(7),
          '123',
        );

        await tester.enterText(
          find.byType(TextFormField).at(8),
          'Centro',
        );

        await tester.enterText(
          find.byType(TextFormField).at(9),
          'Recife',
        );

        /// Seleciona estado
        await tester.tap(
          find.byType(DropdownButtonFormField<String>),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('PE').last);

        await tester.pumpAndSettle();

        /// Verifica preenchimento
        expect(find.text('JoÃ£o Silva'), findsOneWidget);

        expect(find.text('joao@email.com'), findsOneWidget);

        expect(find.text('50700-000'), findsOneWidget);
      },
    );

    testWidgets(
      'deve navegar para login',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: CadastroScreen(),
            routes: {
              '/login': (_) => const LoginScreenFake(),
            },
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(
          find.text('JÃ¡ tem uma conta? FaÃ§a login'),
        );

        await tester.pumpAndSettle();

        /// Como o app usa MaterialPageRoute diretamente,
        /// verificamos se saiu da tela de cadastro
        expect(
          find.byType(CadastroScreen),
          findsNothing,
        );
      },
    );

    testWidgets(
      'GenerosCadastroScreen deve selecionar gÃªnero',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Rock'), findsOneWidget);

        /// Liga switch
        await tester.tap(find.byType(Switch).first);

        await tester.pumpAndSettle();

        final switchWidget =
            tester.widget<Switch>(find.byType(Switch).first);

        expect(switchWidget.value, true);
      },
    );

    testWidgets(
      'GenerosCadastroScreen deve exigir ao menos um gÃªnero',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: GenerosCadastroScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Confirmar'));

        await tester.pump();

        expect(
          find.text('Selecione pelo menos um gÃªnero musical!'),
          findsOneWidget,
        );
      },
    );
  });
}
