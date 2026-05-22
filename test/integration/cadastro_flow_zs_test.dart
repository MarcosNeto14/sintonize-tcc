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
      home: const CadastroScreen(),
      routes: {
        '/generos': (_) => const GenerosCadastroScreen(),
      },
    );
  }

  group('CadastroScreen Integration', () {
    testWidgets(
      'deve validar campos obrigatórios',
      (tester) async {
        await tester.pumpWidget(buildApp());

        await tester.pumpAndSettle();

        await tester.tap(find.text('Cadastrar'));

        await tester.pumpAndSettle();

        expect(
          find.text('O nome é obrigatório'),
          findsOneWidget,
        );

        expect(
          find.text('O e-mail é obrigatório'),
          findsOneWidget,
        );

        expect(
          find.text('A senha é obrigatória'),
          findsOneWidget,
        );

        expect(
          find.text('O CEP é obrigatório'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve validar email inválido',
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
          find.text('E-mail inválido'),
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
          find.text('As senhas não coincidem'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve preencher formulário corretamente',
      (tester) async {
        await tester.pumpWidget(buildApp());

        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'João Silva',
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
        expect(find.text('João Silva'), findsOneWidget);

        expect(find.text('joao@email.com'), findsOneWidget);

        expect(find.text('50700-000'), findsOneWidget);
      },
    );

    testWidgets(
      'deve navegar para login',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const CadastroScreen(),
            routes: {
              '/login': (_) => const LoginScreenFake(),
            },
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(
          find.text('Já tem uma conta? Faça login'),
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
      'GenerosCadastroScreen deve selecionar gênero',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const GenerosCadastroScreen(),
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
      'GenerosCadastroScreen deve exigir ao menos um gênero',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: const GenerosCadastroScreen(),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Confirmar'));

        await tester.pump();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );
      },
    );
  });
}
