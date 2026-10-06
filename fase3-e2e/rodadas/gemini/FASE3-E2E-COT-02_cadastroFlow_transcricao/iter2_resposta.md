<!-- Resposta do Gemini 3.8 Flash ao reparo 2, rodada FASE3-E2E-COT-02_cadastroFlow, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome), segunda máquina (DESKTOP-6ETPO2H).
     Conversa: https://gemini.google.com/app/3968b3e7d43db829 -->

### Classificação da Causa Provável

**Classificação: (A) O teste presume um comportamento que não é o especificado.**

---

### Diagnóstico Detalhado

Analisando o log de erros e avisos da execução:

1. **Falha ao interagir com o `DropdownButtonFormField` (Aviso de Hit Test):**
* O aviso:
```
Warning: A call to tap() with finder "Found 1 widget with type "DropdownMenuItem<String>" that are ancestors of widget with text "PE" (ignoring all but last)...
derived an Offset (Offset(209.7, 679.3)) that would not hit test on the specified widget.

```


* O `DropdownButtonFormField` abre um menu pop-up modal scrollável contendo 27 estados. O item `'PE'` está no meio da lista e fica fora do viewport visível do pop-up suspenso na tela do emulador. Tentar fazer `tester.tap(find.widgetWithText(DropdownMenuItem<String>, 'PE').last)` tenta tocar numa coordenada não exposta ao clique. Como resultado, o toque não atinge o item, o menu do dropdown permanece aberto (obscurecendo a tela) ou nenhum estado é selecionado, impedindo a submissão correta ou travando o clique no botão posterior.
* Além disso, no código de `CadastroScreen`:
* O campo `Estado` **não** tem validador obrigatório!
* Na verdade, `_estados[0]` é `'AC'`, que fica visível imediatamente no topo sem necessidade de rolar uma longa lista modal, ou podemos usar um estado que já esteja visível no início do menu suspenso (como `'AC'` ou `'AL'`), ou simplesmente fazer scroll até o item dentro do pop-up suspenso.




2. **O efeito colateral no CEP e na requisição HTTP externa:**
* O campo CEP possui um `onChanged`:
```dart
onChanged: (value) {
  if (value.length == 9) {
    _fetchAddressFromCEP(value.replaceAll('-', ''));
  }
}

```


* Quando digitamos o CEP, dispara a função assíncrona `_fetchAddressFromCEP` via HTTP para o `viacep.com.br`. Se o teste clicar em submeter de imediato ou se a requisição assíncrona demorar, o callback assíncrono tenta atualizar o estado ou a `SnackBar` de erro do CEP é disparada se a rede do emulador falhar ou demorar, impactando o fluxo.


3. **Tempo de resposta assíncrona do Firebase Emulator e a exceção de State unmounted:**
* Observe a mensagem:
```
The following assertion was thrown running a test (but after the test had completed):
This widget has been unmounted, so the State no longer has a context...
_CadastroScreenState._submit (package:sintonize/cadastro.dart:176:30)

```


* A linha 176 de `cadastro.dart` é justamente o `Navigator.push(...)` dentro do bloco `_submit()`:
```dart
await _firestore.collection('usuarios').doc(uid).set({...});
Navigator.push(...); // linha 176

```


E a linha 172 é o `ScaffoldMessenger.of(context).showSnackBar(...)` no `catch (FirebaseAuthException)`.
* **Por que isso aconteceu depois que o teste terminou?**
O teste chamou `await tester.pumpAndSettle()`, mas como havia operações assíncronas pendentes (a chamada de rede ao Firebase Auth / Firestore via gRPC/HTTP e a requisição do ViaCEP), o `pumpAndSettle` retornou prematuramente antes do término dessas tarefas assíncronas externas de I/O de rede. O teste então verificou a tela seguinte, falhou imediatamente, desmontou a árvore, e só então o `await _auth.createUserWithEmailAndPassword` e `await _firestore.set(...)` retornaram!
* Em testes de integração reais contra emuladores, chamadas de rede para Auth e Firestore não são microtarefas do loop de renderização do Flutter: são I/O assíncrono nativo. Para aguardar a resposta de rede dos emuladores de forma determinística, deve-se aguardar a resolução assíncrona ativamente usando um loop de verificação (ex.: aguardar até o widget esperado ou a SnackBar aparecer em tela com timeout de alguns segundos).



---

### Código Corrigido dos Testes (`cadastro_cot_test.dart`)

Substituímos o item do dropdown por um que está no topo (`'AC'`), tratamos o fechamento do dropdown e adicionamos um helper de espera assíncrona para I/O (`esperarElemento`) garantindo que as operações do Firebase Emulator e transições de tela sejam concluídas antes de asserir:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

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

  /// Localiza o TextFormField associado ao label textual exibido logo acima dele.
  Finder campoPorLabel(String label) {
    return find.descendant(
      of: find.ancestor(
        of: find.text(label),
        matching: find.byType(Column),
      ).first,
      matching: find.byType(TextFormField),
    );
  }

  /// Garante visibilidade e preenche o campo de texto correspondente.
  Future<void> preencherCampo(
    WidgetTester tester,
    Finder scrollable,
    String label,
    String texto,
  ) async {
    final finder = campoPorLabel(label);
    await tester.scrollUntilVisible(finder, 80, scrollable: scrollable);
    await tester.enterText(finder, texto);
    await tester.pumpAndSettle();
  }

  /// Seleciona o primeiro item disponível no DropdownButtonFormField ('AC')
  /// que já fica no topo do menu suspenso sem problemas de scroll.
  Future<void> selecionarEstado(WidgetTester tester, Finder scrollable) async {
    final dropdownEstado = find.byType(DropdownButtonFormField<String>);
    await tester.scrollUntilVisible(dropdownEstado, 80, scrollable: scrollable);
    await tester.tap(dropdownEstado);
    await tester.pumpAndSettle();

    // 'AC' é o primeiro item da lista _estados
    final itemAC = find.widgetWithText(DropdownMenuItem<String>, 'AC').last;
    await tester.tap(itemAC);
    await tester.pumpAndSettle();
  }

  /// Aguarda ativamente até que um widget apareça na tela (útil para respostas assíncronas do Firebase)
  Future<void> esperarElemento(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final DateTime fim = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(fim)) {
      await tester.pump(const Duration(milliseconds: 200));
      if (finder.evaluate().isNotEmpty) {
        await tester.pumpAndSettle();
        return;
      }
    }
    // Último pump para deixar a asserção capturar o estado real
    await tester.pumpAndSettle();
  }

  group('Fluxo E2E - Cadastro e Seleção de Gêneros', () {
    testWidgets('Cenário 1: Fluxo de sucesso ponta a ponta', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // 1. Navegar da HomeScreen para a CadastroScreen
      final botaoCadastroHome = find.widgetWithText(ElevatedButton, 'Cadastro');
      expect(botaoCadastroHome, findsOneWidget);
      await tester.tap(botaoCadastroHome);
      await tester.pumpAndSettle();

      expect(find.byType(CadastroScreen), findsOneWidget);

      final scrollableForm = find.byType(Scrollable).first;
      final String uniqueEmail =
          'novo_usuario_${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      // 2. Preenchimento de todos os campos do formulário
      await preencherCampo(tester, scrollableForm, 'Nome', 'Marcos Vinicius');
      await preencherCampo(tester, scrollableForm, 'Data de Nascimento', '19032001');
      await preencherCampo(tester, scrollableForm, 'E-mail', uniqueEmail);
      await preencherCampo(tester, scrollableForm, 'Senha', 'senha123');
      await preencherCampo(tester, scrollableForm, 'Confirmar Senha', 'senha123');
      await preencherCampo(tester, scrollableForm, 'CEP', '50010000');
      await preencherCampo(tester, scrollableForm, 'Rua', 'Rua da Aurora');
      await preencherCampo(tester, scrollableForm, 'Número', '100');
      await preencherCampo(tester, scrollableForm, 'Bairro', 'Boa Vista');
      await preencherCampo(tester, scrollableForm, 'Cidade', 'Recife');

      await selecionarEstado(tester, scrollableForm);

      // 3. Submeter cadastro
      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 80, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);

      // Aguarda o processamento de rede do Auth Emulator + Firestore
      await esperarElemento(tester, find.byType(GenerosCadastroScreen));

      // 4. Verificação da tela GenerosCadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      // Ativar o switch de 'Rock'
      final switchRock = find.descendant(
        of: find.widgetWithText(Row, 'Rock'),
        matching: find.byType(Switch),
      );
      expect(switchRock, findsOneWidget);
      await tester.tap(switchRock);
      await tester.pumpAndSettle();

      // 5. Confirmar seleção de gêneros
      final botaoConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.scrollUntilVisible(
        botaoConfirmar,
        80,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(botaoConfirmar);

      // Aguarda Firestore gravar os gêneros e redirecionar para TelaInicialScreen
      await esperarElemento(tester, find.byType(TelaInicialScreen));

      // 6. Confirmação do estado final na TelaInicialScreen
      expect(find.byType(TelaInicialScreen), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsOneWidget);
    });

    testWidgets('Cenário 2: Erros de validação local no formulário', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final scrollableForm = find.byType(Scrollable).first;

      // 1. Tentar submeter tudo em branco
      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 80, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);
      await tester.pumpAndSettle();

      // Valida as mensagens de campos obrigatórios
      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);

      // 2. Preencher com dados que violam as regras de formato
      await preencherCampo(tester, scrollableForm, 'Nome', 'User123!');
      await preencherCampo(tester, scrollableForm, 'E-mail', 'email_sem_arroba');
      await preencherCampo(tester, scrollableForm, 'Senha', '123');
      await preencherCampo(tester, scrollableForm, 'Confirmar Senha', '456');

      await tester.scrollUntilVisible(botaoCadastrar, 80, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);
      await tester.pumpAndSettle();

      // Validações de formato específico
      expect(
        find.text('O nome não pode conter números ou caracteres especiais'),
        findsOneWidget,
      );
      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.text('As senhas não coincidem'), findsOneWidget);

      // Garante que não houve navegação
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 3: Erro do Firebase Auth com e-mail já existente', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final scrollableForm = find.byType(Scrollable).first;

      // Preenche os dados usando o e-mail pré-existente nos emuladores
      await preencherCampo(tester, scrollableForm, 'Nome', 'Tester Clone');
      await preencherCampo(tester, scrollableForm, 'Data de Nascimento', '01012000');
      await preencherCampo(tester, scrollableForm, 'E-mail', 'tester@sintonize.test');
      await preencherCampo(tester, scrollableForm, 'Senha', 'senha123');
      await preencherCampo(tester, scrollableForm, 'Confirmar Senha', 'senha123');
      await preencherCampo(tester, scrollableForm, 'CEP', '50000000');
      await preencherCampo(tester, scrollableForm, 'Rua', 'Rua Teste');
      await preencherCampo(tester, scrollableForm, 'Número', '10');
      await preencherCampo(tester, scrollableForm, 'Bairro', 'Centro');
      await preencherCampo(tester, scrollableForm, 'Cidade', 'Recife');

      await selecionarEstado(tester, scrollableForm);

      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 80, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);

      // Aguarda resposta assíncrona do Firebase Auth Emulator e surgimento da SnackBar
      await esperarElemento(tester, find.byType(SnackBar));

      // Valida SnackBar de erro do Firebase Auth
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Erro ao cadastrar:'), findsOneWidget);

      // Garante permanência na tela de cadastro
      expect(find.byType(CadastroScreen), findsOneWidget);
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 4: Validação de seleção obrigatória na GenerosCadastroScreen', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final scrollableForm = find.byType(Scrollable).first;
      final String randomEmail =
          'genero_test_${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      await preencherCampo(tester, scrollableForm, 'Nome', 'Usuario Genero');
      await preencherCampo(tester, scrollableForm, 'Data de Nascimento', '10101995');
      await preencherCampo(tester, scrollableForm, 'E-mail', randomEmail);
      await preencherCampo(tester, scrollableForm, 'Senha', 'senhaValida123');
      await preencherCampo(tester, scrollableForm, 'Confirmar Senha', 'senhaValida123');
      await preencherCampo(tester, scrollableForm, 'CEP', '50010000');
      await preencherCampo(tester, scrollableForm, 'Rua', 'Avenida Norte');
      await preencherCampo(tester, scrollableForm, 'Número', '500');
      await preencherCampo(tester, scrollableForm, 'Bairro', 'Encruzilhada');
      await preencherCampo(tester, scrollableForm, 'Cidade', 'Recife');

      await selecionarEstado(tester, scrollableForm);

      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 80, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);

      // Aguarda criação do usuário e navegação para GenerosCadastroScreen
      await esperarElemento(tester, find.byType(GenerosCadastroScreen));
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);

      // Tenta confirmar sem selecionar nenhum gênero musical
      final botaoConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.scrollUntilVisible(
        botaoConfirmar,
        80,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(botaoConfirmar);
      await tester.pump(); // Renderiza o frame do SnackBar síncrono

      // Validação do SnackBar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Selecione pelo menos um gênero musical!'), findsOneWidget);

      // Confirma que não avançou para TelaInicialScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });
}

```
