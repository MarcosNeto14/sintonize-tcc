<!-- Resposta do Gemini 3.8 Flash ao reparo 1, rodada FASE3-C3-ZS, 2026-10-05,
     como devolvida pelo autor (colagem do texto da resposta), sem edição.
     Conversa: https://gemini.google.com/app/55a6da8c2e072fc4 -->

Classificação da Causa da Falha
(A) O teste presume um comportamento que não é o especificado (comportamento de interação do teste incorreto).

Diagnóstico do Problema
Dois fatores específicos no código do teste causaram as falhas observadas:

A seleção do item no Dropdown falhou o Hit Test (origem de ambas as falhas):

Plaintext
Warning: A call to tap() with finder "Found 1 widget with text "PE" (ignoring all but last): [...]" derived an Offset (Offset(48.8, 848.0)) that would not hit test on the specified widget.
A lista de estados tem 27 itens (AC a TO). O item "PE" fica abaixo da área visível do menu suspenso aberto (_DropdownMenu<String>). Ao tentar dar tester.tap(find.text('PE').last) sem rolar o menu suspenso aberto, o toque atingiu um ponto fora do menu/tela. Como o item não foi de fato selecionado, o estado permaneceu null. Além disso, para evitar a necessidade de rolagem dentro do menu suspenso do Material, usar um dos primeiros itens visíveis da lista (como 'AC', 'AL' ou 'AM') seleciona o estado com garantia de hit test imediato.

A requisição assíncrona HTTP do CEP substituiu os dados digitados:
No teste, o campo CEP recebeu '50000000' e '51020010'. A implementação em CadastroScreen:

Dart
onChanged: (value) {
  if (value.length == 9) {
    _fetchAddressFromCEP(value.replaceAll('-', ''));
  }
}
Faz uma chamada HTTP real para a API do ViaCEP ([https://viacep.com.br/ws/$cep/json/](https://viacep.com.br/ws/$cep/json/)). Ao disparar essa requisição assíncrona enquanto o teste já preenchia os demais campos, quando a resposta chegou ela executou um setState() sobrescrevendo campos ou disparando erros assíncronos. Além disso, a chamada de rede real dentro de um teste de integração introduz latência e instabilidade desnecessárias para a validação do formulário.

Tempo de resposta assíncrona do Firebase e do SnackBar:
Após tocar em 'Cadastrar', a criação de conta no Auth e o salvamento no Firestore são operações de rede assíncronas. Um simples pumpAndSettle() logo após o tap pode retornar antes que o Firebase Emulator conclua a transação remota. É necessário aguardar a resposta com tester.pump(const Duration(seconds: ...)) ou esperar o surgimento do widget esperado.

Código Corrigido do Teste
Dart
// ===== integration_test/fase3/c3_zs_test.dart =====
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sintonize/main.dart';
import 'package:sintonize/cadastro.dart';
import 'package:sintonize/generos-cadastro.dart';
import 'package:sintonize/tela-inicial.dart';
import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  setUp(() async {
    await FirebaseAuth.instance.signOut();
  });

  tearDown(() async {
    await FirebaseAuth.instance.signOut();
  });

  group('E2E - Fluxo de Cadastro e Seleção de Gêneros', () {
    testWidgets(
      'Deve exibir validações de campos obrigatórios ao submeter formulário vazio',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 1. Navegar da HomeScreen para CadastroScreen
        final botaoCadastroHome = find.widgetWithText(ElevatedButton, 'Cadastro');
        expect(botaoCadastroHome, findsOneWidget);
        await tester.tap(botaoCadastroHome);
        await tester.pumpAndSettle();

        expect(find.byType(CadastroScreen), findsOneWidget);

        // 2. Tocar diretamente no botão Cadastrar sem preencher nada
        final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(botaoCadastrar);
        await tester.tap(botaoCadastrar);
        await tester.pumpAndSettle();

        // 3. Validar se as mensagens de validação síncronas do Form apareceram
        expect(find.text('O nome é obrigatório'), findsOneWidget);
        expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
        expect(find.text('O e-mail é obrigatório'), findsOneWidget);
        expect(find.text('A senha é obrigatória'), findsOneWidget);
        expect(find.text('O CEP é obrigatório'), findsOneWidget);
        expect(find.text('O número é obrigatório'), findsOneWidget);

        expect(find.byType(GenerosCadastroScreen), findsNothing);
      },
    );

    testWidgets(
      'Deve exibir erro quando o e-mail já estiver cadastrado no Firebase Auth',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Navegar para a tela de cadastro
        await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
        await tester.pumpAndSettle();

        final camposTexto = find.byType(TextFormField);

        // Preenche com o e-mail já existente nos emuladores (tester@sintonize.test)
        await tester.enterText(camposTexto.at(0), 'Usuario Existente');
        await tester.enterText(camposTexto.at(1), '15101995'); // 15/10/1995
        await tester.enterText(camposTexto.at(2), 'tester@sintonize.test');
        await tester.enterText(camposTexto.at(3), 'senha123');
        await tester.enterText(camposTexto.at(4), 'senha123');

        // CEP com formato válido (9 caracteres incluindo '-')
        await tester.ensureVisible(camposTexto.at(5));
        await tester.enterText(camposTexto.at(5), '50000000');
        await tester.enterText(camposTexto.at(6), 'Rua Principal');
        await tester.enterText(camposTexto.at(7), '100');
        await tester.enterText(camposTexto.at(8), 'Centro');
        await tester.enterText(camposTexto.at(9), 'Recife');

        // Selecionar o primeiro estado visível ('AC') para garantir hit test imediato
        final dropdown = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdown);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        final itemEstado = find.widgetWithText(DropdownMenuItem<String>, 'AC').last;
        await tester.tap(itemEstado);
        await tester.pumpAndSettle();

        // Submeter cadastro
        final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(botaoCadastrar);
        await tester.tap(botaoCadastrar);

        // Aguarda a resposta assíncrona do Firebase Auth Emulator
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Confirma exibição do SnackBar de erro do FirebaseAuth
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('Erro ao cadastrar:'), findsOneWidget);
        expect(find.byType(GenerosCadastroScreen), findsNothing);
      },
    );

    testWidgets(
      'Deve realizar fluxo completo: Cadastro -> Generos (alerta de seleção) -> Sucesso e persistência -> Tela Inicial',
      (WidgetTester tester) async {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final novoEmail = 'novo_$timestamp@sintonize.test';
        const nomeUsuario = 'Novo Usuario E2E';

        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 1. Abrir CadastroScreen
        await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
        await tester.pumpAndSettle();
        expect(find.byType(CadastroScreen), findsOneWidget);

        final camposTexto = find.byType(TextFormField);

        // 2. Preencher dados cadastrais
        await tester.enterText(camposTexto.at(0), nomeUsuario);
        await tester.enterText(camposTexto.at(1), '20052000'); // 20/05/2000
        await tester.enterText(camposTexto.at(2), novoEmail);
        await tester.enterText(camposTexto.at(3), 'senhaSegura123');
        await tester.enterText(camposTexto.at(4), 'senhaSegura123');

        await tester.ensureVisible(camposTexto.at(5));
        await tester.enterText(camposTexto.at(5), '51020010');
        await tester.enterText(camposTexto.at(6), 'Avenida Boa Viagem');
        await tester.enterText(camposTexto.at(7), '500');
        await tester.enterText(camposTexto.at(8), 'Boa Viagem');
        await tester.enterText(camposTexto.at(9), 'Recife');

        // Selecionar 'AC' (garantidamente visível no popup sem necessidade de scroll)
        final dropdown = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdown);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();

        final itemEstado = find.widgetWithText(DropdownMenuItem<String>, 'AC').last;
        await tester.tap(itemEstado);
        await tester.pumpAndSettle();

        // 3. Submeter formulário e aguardar criação no Auth + Firestore
        final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
        await tester.ensureVisible(botaoCadastrar);
        await tester.tap(botaoCadastrar);

        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // 4. Validar chegada na tela de gêneros
        expect(find.byType(GenerosCadastroScreen), findsOneWidget);

        // 5. Cenário de validação: tentar confirmar sem marcar nenhum gênero
        final botaoConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
        await tester.ensureVisible(botaoConfirmar);
        await tester.tap(botaoConfirmar);
        await tester.pumpAndSettle();

        expect(
          find.text('Selecione pelo menos um gênero musical!'),
          findsOneWidget,
        );
        expect(find.byType(TelaInicialScreen), findsNothing);

        // 6. Selecionar gêneros ('Rock' e 'Jazz')
        final switchRock = find.descendant(
          of: find.ancestor(
            of: find.text('Rock'),
            matching: find.byType(Row),
          ),
          matching: find.byType(Switch),
        );
        await tester.tap(switchRock);
        await tester.pumpAndSettle();

        final switchJazz = find.descendant(
          of: find.ancestor(
            of: find.text('Jazz'),
            matching: find.byType(Row),
          ),
          matching: find.byType(Switch),
        );
        await tester.tap(switchJazz);
        await tester.pumpAndSettle();

        // 7. Confirmar gêneros
        await tester.ensureVisible(botaoConfirmar);
        await tester.tap(botaoConfirmar);

        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // 8. Validar chegada na TelaInicialScreen
        expect(find.byType(TelaInicialScreen), findsOneWidget);

        // 9. Validar persistência dos dados no Firestore Emulator
        final currentUser = FirebaseAuth.instance.currentUser;
        expect(currentUser, isNotNull);
        expect(currentUser!.email, novoEmail);

        final userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(currentUser.uid)
            .get();

        expect(userDoc.exists, isTrue);
        final userData = userDoc.data()!;
        expect(userData['nome'], nomeUsuario);
        expect(userData['email'], novoEmail);
        expect(userData['data_nasc'], '20/05/2000');
        expect(userData['endereco']['cidade'], 'Recife');
        expect(userData['endereco']['estado'], 'AC');

        final generosFavoritos = List<String>.from(userData['generos_favoritos'] ?? []);
        expect(generosFavoritos, containsAll(['Rock', 'Jazz']));
      },
    );
  });
}
