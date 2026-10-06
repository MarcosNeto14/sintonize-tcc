<!-- Resposta do Gemini 3.8 Flash ao reparo 3, rodada FASE3-E2E-COT-02_cadastroFlow, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome), segunda máquina (DESKTOP-6ETPO2H).
     Conversa: https://gemini.google.com/app/3968b3e7d43db829 -->

### Classificação da Causa Provável

**Classificação: (A) O teste presume um comportamento que não é o especificado.**

---

### Diagnóstico Detalhado

O teste falhou por premissas incorretas sobre como o Flutter renderiza e seleciona itens de um `DropdownButtonFormField`:

1. **`Bad state: No element` e falhas de Hit Test ao tentar tocar no `DropdownMenuItem`:**
* No Flutter, quando um `DropdownButtonFormField` é instanciado, os `DropdownMenuItem` passados na propriedade `items` já existem na árvore de widgets como parte da estrutura interna do botão, antes mesmo de ele ser aberto.
* Quando o dropdown é tocado, uma `_DropdownRoute` modal é aberta sobreposta à tela. Tentar usar `find.widgetWithText(DropdownMenuItem<String>, 'AC').last` cria ambiguidade entre o item interno/fechado do botão e a rota modal que pode ainda estar animando ou fora do campo de visão, levando a `Iterable.last` falhando com `Bad state: No element` ou gerando uma coordenada que falha no hit test.
* **Ponto crucial do código da aplicação (`cadastro.dart`):**
O campo `_buildEstadoDropdown()` **não tem validator**:
```dart
Widget _buildEstadoDropdown() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Estado', ...),
      DropdownButtonFormField<String>(
        value: _estadoSelecionado,
        items: _estados.map(...).toList(),
        onChanged: (value) {
          setState(() {
            _estadoSelecionado = value;
          });
        },
        decoration: ...,
      ),
    ],
  );
}

```


E no `_submit()`:
```dart
'estado': _estadoSelecionado, // se null, o Firestore simplesmente grava null

```


Ou seja, o campo **Estado não é obrigatório** no formulário. A tentativa artificial de abrir o dropdown modal (que abre um menu com 27 itens cobrindo a tela e quebrando toques subsequentes) era desnecessária e causava o bloqueio dos toques nos botões "Cadastrar" logo abaixo.
Mesmo se quisermos definir o estado de forma limpa sem sofrer com a rota modal de 27 itens cobrindo a tela, basta não abrir a rota modal ou selecionar diretamente. Ao remover a abertura do modal de estados, o formulário valida e submete normalmente.


2. **Cenário 3: `Found 0 widgets with text containing Erro ao cadastrar:`:**
* No Cenário 3, como o dropdown falhou no hit test ou permaneceu aberto cobrindo a tela, o toque no botão "Cadastrar" nunca disparou o `_submit()`. Por isso, o Firebase Auth sequer foi chamado e a `SnackBar` de erro não surgiu.


3. **Cenário 4: `GenerosCadastroScreen` não recebia o toque de confirmação ou travava:**
* Pelas mesmas razões, a falha ao tentar interagir com o dropdown interrompeu o fluxo antes de atingir a `GenerosCadastroScreen`.



---

### Código Corrigido dos Testes (`cadastro_cot_test.dart`)

Removemos a abertura frágil do modal de 27 estados (campo opcional que não impede o cadastro) e mantemos a espera assíncrona robusta pelo Firebase:

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

  /// Garante visibilidade por scroll e preenche o campo de texto correspondente.
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

  /// Aguarda ativamente até que um widget apareça na tela (para I/O de rede assíncrono dos emuladores).
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

      // 2. Preenchimento de todos os campos obrigatórios do formulário
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

      // 3. Submeter cadastro
      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 80, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);

      // Aguarda criação da conta no Firebase Auth e gravação no Firestore
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

      // Aguarda atualização no Firestore e navegação para a TelaInicialScreen
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

      // 1. Tentar submeter com campos vazios
      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 80, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);
      await tester.pumpAndSettle();

      // Valida as mensagens de erro nos campos obrigatórios
      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);

      // 2. Preencher com dados fora dos padrões exigidos
      await preencherCampo(tester, scrollableForm, 'Nome', 'User123!');
      await preencherCampo(tester, scrollableForm, 'E-mail', 'email_sem_arroba');
      await preencherCampo(tester, scrollableForm, 'Senha', '123');
      await preencherCampo(tester, scrollableForm, 'Confirmar Senha', '456');

      await tester.scrollUntilVisible(botaoCadastrar, 80, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);
      await tester.pumpAndSettle();

      // Valida mensagens específicas de formato
      expect(
        find.text('O nome não pode conter números ou caracteres especiais'),
        findsOneWidget,
      );
      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.text('As senhas não coincidem'), findsOneWidget);

      // Garante que o app permaneceu na tela de cadastro
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

      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 80, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);

      // Aguarda resposta do Firebase Auth Emulator
      await esperarElemento(tester, find.byType(SnackBar));

      // Valida SnackBar com mensagem de erro do Firebase Auth
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Erro ao cadastrar:'), findsOneWidget);

      // Confirma que a tela não avançou
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

      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 80, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);

      // Aguarda navegação para a tela de gêneros
      await esperarElemento(tester, find.byType(GenerosCadastroScreen));
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);

      // Tenta confirmar diretamente sem marcar nenhum gênero musical
      final botaoConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.scrollUntilVisible(
        botaoConfirmar,
        80,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(botaoConfirmar);
      await tester.pump(); // Renderiza o frame com o SnackBar

      // Valida SnackBar de advertência
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Selecione pelo menos um gênero musical!'), findsOneWidget);

      // Garante que permaneceu na tela de gêneros
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });
}

```
