import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/login.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final manifest = await rootBundle.loadString('AssetManifest.json');
    expect(
      manifest.contains('assets/logo-sintoniza.png'),
      isTrue,
      reason:
          'O teste espera que assets/logo-sintoniza.png esteja declarado no projeto.',
    );
  });

  group('CadastroScreen - renderização', () {
    testWidgets(
      'deve renderizar todos os campos principais',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        expect(find.text('Nome'), findsOneWidget);
        expect(find.text('Data de Nascimento'), findsOneWidget);
        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
        expect(find.text('Confirmar Senha'), findsOneWidget);
        expect(find.text('CEP'), findsOneWidget);
        expect(find.text('Rua'), findsOneWidget);
        expect(find.text('Número'), findsOneWidget);
        expect(find.text('Bairro'), findsOneWidget);
        expect(find.text('Cidade'), findsOneWidget);
        expect(find.text('Estado'), findsOneWidget);
        expect(find.text('Cadastrar'), findsOneWidget);
        expect(
          find.text('Já tem uma conta? Faça login'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve permitir rolar o formulário até o botão Cadastrar',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        final scrollable = find.byType(SingleChildScrollView);
        expect(scrollable, findsOneWidget);

        final cadastrar = find.widgetWithText(
          ElevatedButton,
          'Cadastrar',
        );

        expect(cadastrar, findsOneWidget);

        expect(
          tester.getTopLeft(cadastrar).dy,
          greaterThan(600),
        );

        await tester.scrollUntilVisible(
          cadastrar,
          500,
          scrollable: scrollable,
        );

        expect(
          tester.getTopLeft(cadastrar).dy,
          lessThan(600),
        );
      },
    );
  });

  group('CadastroScreen - validação', () {
    testWidgets(
      'deve mostrar erros para campos obrigatórios vazios',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await tapCadastrar(tester);

        expect(
          find.text('O nome é obrigatório'),
          findsOneWidget,
        );

        expect(
          find.text('A data de nascimento é obrigatória'),
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

        expect(
          find.text('O número é obrigatório'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve rejeitar nome com números',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await enterField(
          tester,
          'Nome',
          'Joao123',
        );

        await tapCadastrar(tester);

        expect(
          find.text(
            'O nome não pode conter números ou caracteres especiais',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve rejeitar nome com caracteres especiais',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await enterField(
          tester,
          'Nome',
          'Joao@Silva',
        );

        await tapCadastrar(tester);

        expect(
          find.text(
            'O nome não pode conter números ou caracteres especiais',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve aceitar nome com acentos',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await enterField(
          tester,
          'Nome',
          'João da Silva',
        );

        await tapCadastrar(tester);

        expect(
          find.text('O nome é obrigatório'),
          findsNothing,
        );

        expect(
          find.text(
            'O nome não pode conter números ou caracteres especiais',
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve rejeitar data vazia',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await tapCadastrar(tester);

        expect(
          find.text('A data de nascimento é obrigatória'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve rejeitar data com formato inválido',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await enterField(
          tester,
          'Data de Nascimento',
          '010119',
        );

        await tapCadastrar(tester);

        expect(
          find.text('Formato inválido. Use dd/mm/aaaa'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve rejeitar data com mês inválido',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await enterField(
          tester,
          'Data de Nascimento',
          '01132000',
        );

        await tapCadastrar(tester);

        expect(
          find.text('Mês deve ser entre 01 e 12'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve rejeitar dia inválido',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await enterField(
          tester,
          'Data de Nascimento',
          '31022000',
        );

        await tapCadastrar(tester);

        expect(
          find.text('Dia deve ser entre 01 e 29'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve rejeitar data futura',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        final future = DateTime.now().add(const Duration(days: 1));

        final date =
            '${future.day.toString().padLeft(2, '0')}/'
            '${future.month.toString().padLeft(2, '0')}/'
            '${future.year}';

        await enterField(
          tester,
          'Data de Nascimento',
          date,
        );

        await tapCadastrar(tester);

        expect(
          find.text('A data não pode ser no futuro'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve rejeitar e-mail vazio',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await tapCadastrar(tester);

        expect(
          find.text('O e-mail é obrigatório'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve rejeitar e-mail inválido',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await enterField(
          tester,
          'E-mail',
          'email-invalido',
        );

        await tapCadastrar(tester);

        expect(
          find.text('E-mail inválido'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve aceitar e-mail válido',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await enterField(
          tester,
          'E-mail',
          'joao@example.com',
        );

        await tapCadastrar(tester);

        expect(
          find.text('O e-mail é obrigatório'),
          findsNothing,
        );

        expect(
          find.text('E-mail inválido'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve rejeitar senha vazia',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await tapCadastrar(tester);

        expect(
          find.text('A senha é obrigatória'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve rejeitar senha com menos de seis caracteres',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await enterField(
          tester,
          'Senha',
          '12345',
        );

        await tapCadastrar(tester);

        expect(
          find.text(
            'A senha deve ter pelo menos 6 caracteres',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve rejeitar senhas diferentes',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await enterField(
          tester,
          'Senha',
          '123456',
        );

        await enterField(
          tester,
          'Confirmar Senha',
          '654321',
        );

        await tapCadastrar(tester);

        expect(
          find.text('As senhas não coincidem'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve aceitar senhas iguais',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await enterField(
          tester,
          'Senha',
          '123456',
        );

        await enterField(
          tester,
          'Confirmar Senha',
          '123456',
        );

        await tapCadastrar(tester);

        expect(
          find.text('As senhas não coincidem'),
          findsNothing,
        );
      },
    );

    testWidgets(
      'deve rejeitar CEP vazio',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await tapCadastrar(tester);

        expect(
          find.text('O CEP é obrigatório'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve rejeitar CEP com formato inválido',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await enterField(
          tester,
          'CEP',
          '123',
        );

        await tapCadastrar(tester);

        expect(
          find.text(
            'CEP inválido. Formato correto: XXXXX-XXX',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'deve rejeitar número de endereço não numérico',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        await enterField(
          tester,
          'Número',
          'ABC',
        );

        await tapCadastrar(tester);

        expect(
          find.text('O número deve ser numérico'),
          findsOneWidget,
        );
      },
    );
  });

  group('CadastroScreen - formatação', () {
    testWidgets(
      'deve formatar automaticamente a data de nascimento',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        final field = findTextFormField('Data de Nascimento');

        await tester.scrollUntilVisible(
          field,
          300,
          scrollable: find.byType(SingleChildScrollView),
        );

        await tester.enterText(
          field,
          '01011990',
        );

        expect(
          tester.widget<TextFormField>(field).controller!.text,
          '01/01/1990',
        );
      },
    );

    testWidgets(
      'deve formatar automaticamente o CEP',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        final field = findTextFormField('CEP');

        await tester.scrollUntilVisible(
          field,
          300,
          scrollable: find.byType(SingleChildScrollView),
        );

        await tester.enterText(
          field,
          '01000100',
        );

        expect(
          tester.widget<TextFormField>(field).controller!.text,
          '01000-100',
        );
      },
    );

    testWidgets(
      'deve limitar data a oito dígitos',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        final field = findTextFormField('Data de Nascimento');

        await tester.scrollUntilVisible(
          field,
          300,
          scrollable: find.byType(SingleChildScrollView),
        );

        await tester.enterText(
          field,
          '010119901234',
        );

        expect(
          tester.widget<TextFormField>(field).controller!.text,
          '01/01/1990',
        );
      },
    );

    testWidgets(
      'deve limitar CEP a oito dígitos',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        final field = findTextFormField('CEP');

        await tester.scrollUntilVisible(
          field,
          300,
          scrollable: find.byType(SingleChildScrollView),
        );

        await tester.enterText(
          field,
          '010001001234',
        );

        expect(
          tester.widget<TextFormField>(field).controller!.text,
          '01000-100',
        );
      },
    );
  });

  group('CadastroScreen - interação', () {
    testWidgets(
      'deve permitir selecionar o estado PE',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        final dropdown = find.byType(
          DropdownButtonFormField<String>,
        );

        await tester.scrollUntilVisible(
          dropdown,
          300,
          scrollable: find.byType(SingleChildScrollView),
        );

        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        expect(
          find.text('PE'),
          findsWidgets,
        );

        await tester.tap(
          find.text('PE').last,
        );

        await tester.pumpAndSettle();

        expect(
          find.text('PE'),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'deve navegar para Login ao tocar no link',
      (tester) async {
        await tester.pumpWidget(
          buildTestApp(
            auth: MockFirebaseAuth(),
            firestore: FakeFirebaseFirestore(),
          ),
        );

        final loginButton = find.text(
          'Já tem uma conta? Faça login',
        );

        await tester.scrollUntilVisible(
          loginButton,
          300,
          scrollable: find.byType(SingleChildScrollView),
        );

        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        expect(
          find.byType(LoginScreen),
          findsOneWidget,
        );
      },
    );
  });

  group('CadastroScreen - sucesso', () {
    testWidgets(
      'deve criar usuário, salvar no Firestore e navegar',
      (tester) async {
        final auth = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'uid-teste-123',
            email: 'joao@example.com',
          ),
          signedIn: false,
        );

        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildTestApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await fillRequiredFields(
          tester,
          triggerCepLookup: false,
        );

        await tapCadastrar(tester);

        final snapshot = await firestore
            .collection('usuarios')
            .doc('uid-teste-123')
            .get();

        expect(
          snapshot.exists,
          isTrue,
        );

        final data = snapshot.data()!;

        expect(
          data['nome'],
          'Joao da Silva',
        );

        expect(
          data['data_nasc'],
          '01/01/1990',
        );

        expect(
          data['email'],
          'joao@example.com',
        );

        final endereco =
            data['endereco'] as Map<String, dynamic>;

        expect(
          endereco['rua'],
          'Rua Teste',
        );

        expect(
          endereco['numero'],
          '100',
        );

        expect(
          endereco['bairro'],
          'Centro',
        );

        expect(
          endereco['cidade'],
          'Recife',
        );

        expect(
          endereco['estado'],
          'PE',
        );

        expect(
          endereco['cep'],
          '01000-100',
        );

        expect(
          find.byType(GenerosCadastroScreen),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'não deve salvar no Firestore quando a validação falhar',
      (tester) async {
        final auth = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'uid-validacao',
            email: 'joao@example.com',
          ),
          signedIn: false,
        );

        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildTestApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await enterField(
          tester,
          'Nome',
          'Joao123',
        );

        await tapCadastrar(tester);

        final snapshot = await firestore
            .collection('usuarios')
            .doc('uid-validacao')
            .get();

        expect(
          snapshot.exists,
          isFalse,
        );

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );
      },
    );
  });

  group('CadastroScreen - Firebase Auth', () {
    testWidgets(
      'deve mostrar erro quando Firebase Auth retornar FirebaseAuthException',
      (tester) async {
        final auth = MockFirebaseAuth(
          signedIn: false,
        );

        whenCalling(
          Invocation.method(
            #createUserWithEmailAndPassword,
            null,
          ),
        ).on(auth).thenThrow(
          FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'Este e-mail já está cadastrado',
          ),
        );

        final firestore = FakeFirebaseFirestore();

        await tester.pumpWidget(
          buildTestApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await fillRequiredFields(
          tester,
          triggerCepLookup: false,
        );

        await tapCadastrar(tester);

        expect(
          find.text(
            'Erro ao cadastrar: Este e-mail já está cadastrado',
          ),
          findsOneWidget,
        );

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );
      },
    );
  });

  group('CadastroScreen - Firestore', () {
    testWidgets(
      'deve mostrar erro desconhecido quando o Firestore falhar',
      (tester) async {
        final auth = MockFirebaseAuth(
          mockUser: MockUser(
            uid: 'uid-firestore-error',
            email: 'joao@example.com',
          ),
          signedIn: false,
        );

        final firestore = FailingFirestore();

        await tester.pumpWidget(
          buildTestApp(
            auth: auth,
            firestore: firestore,
          ),
        );

        await fillRequiredFields(
          tester,
          triggerCepLookup: false,
        );

        await tapCadastrar(tester);

        expect(
          find.textContaining('Erro desconhecido:'),
          findsOneWidget,
        );

        expect(
          find.textContaining('Falha simulada no Firestore'),
          findsOneWidget,
        );

        expect(
          find.byType(CadastroScreen),
          findsOneWidget,
        );
      },
    );
  });

  group('CadastroScreen - ViaCEP', () {
    testWidgets(
      'deve preencher endereço quando o CEP for encontrado',
      (tester) async {
        final override = FakeViaCepHttpOverrides(
          statusCode: 200,
          body: jsonEncode({
            'cep': '01000-100',
            'logradouro': 'Rua Teste',
            'bairro': 'Centro',
            'localidade': 'Recife',
            'uf': 'PE',
            'erro': null,
          }),
        );

        await withHttpOverride(
          override,
          () async {
            await tester.pumpWidget(
              buildTestApp(
                auth: MockFirebaseAuth(),
                firestore: FakeFirebaseFirestore(),
              ),
            );

            final cep = findTextFormField('CEP');

            await tester.scrollUntilVisible(
              cep,
              300,
              scrollable: find.byType(SingleChildScrollView),
            );

            await tester.enterText(
              cep,
              '01000100',
            );

            await tester.pumpAndSettle();

            expect(
              getFieldText(tester, 'Rua'),
              'Rua Teste',
            );

            expect(
              getFieldText(tester, 'Bairro'),
              'Centro',
            );

            expect(
              getFieldText(tester, 'Cidade'),
              'Recife',
            );

            final dropdown =
                find.byType(DropdownButtonFormField<String>);

            expect(
              dropdown,
              findsOneWidget,
            );

            expect(
              tester.widget<DropdownButtonFormField<String>>(
                dropdown,
              ).initialValue,
              'PE',
            );
          },
        );
      },
    );

    testWidgets(
      'deve mostrar CEP não encontrado quando ViaCEP retornar erro',
      (tester) async {
        final override = FakeViaCepHttpOverrides(
          statusCode: 200,
          body: jsonEncode({
            'erro': true,
          }),
        );

        await withHttpOverride(
          override,
          () async {
            await tester.pumpWidget(
              buildTestApp(
                auth: MockFirebaseAuth(),
                firestore: FakeFirebaseFirestore(),
              ),
            );

            final cep = findTextFormField('CEP');

            await tester.scrollUntilVisible(
              cep,
              300,
              scrollable: find.byType(SingleChildScrollView),
            );

            await tester.enterText(
              cep,
              '01000100',
            );

            await tester.pumpAndSettle();

            expect(
              find.text('CEP não encontrado'),
              findsOneWidget,
            );
          },
        );
      },
    );

    testWidgets(
      'deve mostrar erro ao buscar CEP quando HTTP retornar status diferente de 200',
      (tester) async {
        final override = FakeViaCepHttpOverrides(
          statusCode: 500,
          body: 'Internal Server Error',
        );

        await withHttpOverride(
          override,
          () async {
            await tester.pumpWidget(
              buildTestApp(
                auth: MockFirebaseAuth(),
                firestore: FakeFirebaseFirestore(),
              ),
            );

            final cep = findTextFormField('CEP');

            await tester.scrollUntilVisible(
              cep,
              300,
              scrollable: find.byType(SingleChildScrollView),
            );

            await tester.enterText(
              cep,
              '01000100',
            );

            await tester.pumpAndSettle();

            expect(
              find.text('Erro ao buscar CEP'),
              findsOneWidget,
            );
          },
        );
      },
    );

    testWidgets(
      'deve mostrar erro quando houver falha de rede no ViaCEP',
      (tester) async {
        final override = FakeViaCepHttpOverrides(
          exception: SocketException('Falha de rede'),
        );

        await withHttpOverride(
          override,
          () async {
            await tester.pumpWidget(
              buildTestApp(
                auth: MockFirebaseAuth(),
                firestore: FakeFirebaseFirestore(),
              ),
            );

            final cep = findTextFormField('CEP');

            await tester.scrollUntilVisible(
              cep,
              300,
              scrollable: find.byType(SingleChildScrollView),
            );

            await tester.enterText(
              cep,
              '01000100',
            );

            await tester.pumpAndSettle();

            expect(
              find.textContaining('Erro:'),
              findsOneWidget,
            );

            expect(
              find.textContaining('Falha de rede'),
              findsOneWidget,
            );
          },
        );
      },
    );
  });
}

Widget buildTestApp({
  required FirebaseAuth auth,
  required FirebaseFirestore firestore,
}) {
  return MaterialApp(
    home: CadastroScreen(
      auth: auth,
      firestore: firestore,
    ),
  );
}

Finder findTextFormField(String label) {
  return find.byWidgetPredicate(
    (widget) {
      if (widget is! TextFormField) {
        return false;
      }

      final decoration = widget.decoration;
      final controller = widget.controller;

      return decoration != null &&
          (decoration.labelText == label ||
              controller != null);
    },
    description: 'TextFormField "$label"',
  );
}

TextFormField getTextFormField(
  WidgetTester tester,
  String label,
) {
  final fields = find.byType(TextFormField);

  for (final element in fields.evaluate()) {
    final widget = element.widget as TextFormField;

    if (label == 'Nome' &&
        tester.widget<TextFormField>(
              find.byType(TextFormField).at(
                fields.evaluate().toList().indexOf(element),
              ),
            ) ==
            widget) {
      // Campo identificado abaixo pela ordem.
    }
  }

  final index = <String, int>{
    'Nome': 0,
    'Data de Nascimento': 1,
    'E-mail': 2,
    'Senha': 3,
    'Confirmar Senha': 4,
    'CEP': 5,
    'Rua': 6,
    'Número': 7,
    'Bairro': 8,
    'Cidade': 9,
  }[label];

  if (index == null) {
    throw ArgumentError('Campo desconhecido: $label');
  }

  return tester.widget<TextFormField>(
    find.byType(TextFormField).at(index),
  );
}

String getFieldText(
  WidgetTester tester,
  String label,
) {
  return getTextFormField(
    tester,
    label,
  ).controller!.text;
}

Future<void> enterField(
  WidgetTester tester,
  String label,
  String value,
) async {
  final field = getTextFormField(
    tester,
    label,
  );

  final finder = find.byWidget(field);

  await tester.scrollUntilVisible(
    finder,
    300,
    scrollable: find.byType(SingleChildScrollView),
  );

  await tester.enterText(
    finder,
    value,
  );

  await tester.pump();
}

Future<void> tapCadastrar(
  WidgetTester tester,
) async {
  final cadastrar = find.widgetWithText(
    ElevatedButton,
    'Cadastrar',
  );

  expect(
    cadastrar,
    findsOneWidget,
  );

  await tester.scrollUntilVisible(
    cadastrar,
    500,
    scrollable: find.byType(SingleChildScrollView),
  );

  await tester.tap(
    cadastrar,
  );

  await tester.pumpAndSettle();
}

Future<void> fillRequiredFields(
  WidgetTester tester, {
  bool triggerCepLookup = false,
}) async {
  await enterField(
    tester,
    'Nome',
    'Joao da Silva',
  );

  await enterField(
    tester,
    'Data de Nascimento',
    '01011990',
  );

  await enterField(
    tester,
    'E-mail',
    'joao@example.com',
  );

  await enterField(
    tester,
    'Senha',
    '123456',
  );

  await enterField(
    tester,
    'Confirmar Senha',
    '123456',
  );

  if (triggerCepLookup) {
    await enterField(
      tester,
      'CEP',
      '01000100',
    );
  } else {
    await enterField(
      tester,
      'CEP',
      '01000100',
    );
  }

  await enterField(
    tester,
    'Rua',
    'Rua Teste',
  );

  await enterField(
    tester,
    'Número',
    '100',
  );

  await enterField(
    tester,
    'Bairro',
    'Centro',
  );

  await enterField(
    tester,
    'Cidade',
    'Recife',
  );

  final dropdown = find.byType(
    DropdownButtonFormField<String>,
  );

  await tester.scrollUntilVisible(
    dropdown,
    300,
    scrollable: find.byType(SingleChildScrollView),
  );

  await tester.tap(dropdown);
  await tester.pumpAndSettle();

  final pe = find.text('PE');

  expect(
    pe,
    findsWidgets,
  );

  await tester.tap(
    pe.last,
  );

  await tester.pumpAndSettle();
}

Future<void> withHttpOverride(
  HttpOverrides override,
  Future<void> Function() body,
) async {
  final previous = HttpOverrides.current;

  HttpOverrides.global = override;

  try {
    await body();
  } finally {
    HttpOverrides.global = previous;
  }
}

class FailingFirestore implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(
    String collectionPath,
  ) {
    return FailingCollectionReference();
  }

  @override
  dynamic noSuchMethod(
    Invocation invocation,
  ) {
    throw UnimplementedError(
      'Método FirebaseFirestore não implementado no teste: '
      '${invocation.memberName}',
    );
  }
}

class FailingCollectionReference
    implements CollectionReference<Map<String, dynamic>> {
  @override
  DocumentReference<Map<String, dynamic>> doc([
    String? path,
  ]) {
    return FailingDocumentReference();
  }

  @override
  dynamic noSuchMethod(
    Invocation invocation,
  ) {
    throw UnimplementedError(
      'Método CollectionReference não implementado no teste: '
      '${invocation.memberName}',
    );
  }
}

class FailingDocumentReference
    implements DocumentReference<Map<String, dynamic>> {
  @override
  Future<void> set(
    Map<String, dynamic> data, [
    SetOptions? options,
  ]) async {
    throw Exception(
      'Falha simulada no Firestore',
    );
  }

  @override
  dynamic noSuchMethod(
    Invocation invocation,
  ) {
    throw UnimplementedError(
      'Método DocumentReference não implementado no teste: '
      '${invocation.memberName}',
    );
  }
}

class FakeViaCepHttpOverrides extends HttpOverrides {
  FakeViaCepHttpOverrides({
    this.statusCode = 200,
    this.body = '{}',
    this.exception,
  });

  final int statusCode;
  final String body;
  final Object? exception;

  @override
  HttpClient createHttpClient(
    SecurityContext? context,
  ) {
    return FakeHttpClient(
      statusCode: statusCode,
      body: body,
      exception: exception,
    );
  }
}

class FakeHttpClient extends HttpClient {
  FakeHttpClient({
    required this.statusCode,
    required this.body,
    this.exception,
  });

  final int statusCode;
  final String body;
  final Object? exception;

  @override
  Future<HttpClientRequest> getUrl(
    Uri url,
  ) async {
    if (exception != null) {
      throw exception!;
    }

    return FakeHttpClientRequest(
      statusCode: statusCode,
      body: body,
    );
  }

  @override
  Future<HttpClientRequest> openUrl(
    String method,
    Uri url,
  ) async {
    return getUrl(url);
  }
}

class FakeHttpClientRequest extends HttpClientRequest {
  FakeHttpClientRequest({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final String body;

  @override
  Future<HttpClientResponse> close() async {
    return FakeHttpClientResponse(
      statusCode: statusCode,
      body: body,
    );
  }

  @override
  HttpHeaders get headers {
    return FakeHttpHeaders();
  }

  @override
  dynamic noSuchMethod(
    Invocation invocation,
  ) {
    throw UnimplementedError(
      'HttpClientRequest não implementado no teste: '
      '${invocation.memberName}',
    );
  }
}

class FakeHttpClientResponse
    extends Stream<List<int>>
    implements HttpClientResponse {
  FakeHttpClientResponse({
    required this.statusCode,
    required this.body,
  });

  @override
  final int statusCode;

  final String body;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final bytes = utf8.encode(body);

    return Stream<List<int>>.fromIterable(
      <List<int>>[bytes],
    ).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  HttpHeaders get headers {
    return FakeHttpHeaders();
  }

  @override
  dynamic noSuchMethod(
    Invocation invocation,
  ) {
    throw UnimplementedError(
      'HttpClientResponse não implementado no teste: '
      '${invocation.memberName}',
    );
  }
}

class FakeHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _values = {};

  @override
  void add(
    String name,
    Object value,
  ) {
    _values.putIfAbsent(
      name,
      () => <String>[],
    ).add(
      value.toString(),
    );
  }

  @override
  void set(
    String name,
    Object value, {
    bool preserveHeaderCase = false,
  }) {
    _values[name] = <String>[
      value.toString(),
    ];
  }

  @override
  String? value(
    String name,
  ) {
    final values = _values[name];

    if (values == null || values.isEmpty) {
      return null;
    }

    return values.join(',');
  }

  @override
  dynamic noSuchMethod(
    Invocation invocation,
  ) {
    throw UnimplementedError(
      'HttpHeaders não implementado no teste: '
      '${invocation.memberName}',
    );
  }
}
