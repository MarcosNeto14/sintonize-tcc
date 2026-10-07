<!-- Resposta do Gemini 3.8 Flash à geração (iteração 0), rodada FASE3-C3-COT, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome), segunda máquina (DESKTOP-6ETPO2H).
     Conversa: https://gemini.google.com/app/ac10df8022157b89 -->

Aqui está o planejamento completo da análise e os testes end-to-end com `integration_test` para o fluxo de cadastro e seleção de gêneros musicais no aplicativo Sintonize.

---

### 1. Análise do Fluxo

O fluxo se inicia na tela inicial de boas-vindas (`HomeScreen`), de onde o usuário navega para a tela de registro (`CadastroScreen`) e preenche seus dados pessoais e de endereço. Ao acionar o botão "Cadastrar", os campos passam pela validação síncrona do formulário (`FormState.validate()`); caso válidos, o app cria a credencial no Firebase Auth e persiste o documento do usuário no Firestore, redirecionando-o para a seleção de preferências (`GenerosCadastroScreen`). Nessa tela, o usuário seleciona um ou mais interruptores (`Switch`) correspondentes aos seus gêneros musicais prediletos e clica em "Confirmar". Havendo ao menos um gênero selecionado, o app atualiza o documento correspondente no Firestore (`generos_favoritos`) e redireciona o usuário logado para a `TelaInicialScreen`, que exibe recomendações personalizadas baseadas nos gêneros escolhidos; caso contrário, exibe aviso via SnackBar.

---

### 2. Identificação das Dependências

* **Serviços Acionados por Tela:**
* **`HomeScreen`**: Nenhum serviço externo.
* **`CadastroScreen`**:
* **HTTP (`viacep.com.br`)**: Consulta de CEP caso o campo seja preenchido com 9 dígitos/formatado.
* **Firebase Auth**: `createUserWithEmailAndPassword(email, password)`.
* **Cloud Firestore**: `collection('usuarios').doc(uid).set(...)`.


* **`GenerosCadastroScreen`**:
* **Firebase Auth**: Leitura de `currentUser.uid`.
* **Cloud Firestore**: `collection('usuarios').doc(uid).update({'generos_favoritos': [...]})`.


* **`TelaInicialScreen`**:
* **Firebase Auth**: Leitura de `currentUser.uid`.
* **Cloud Firestore**: Leitura de `usuarios/{uid}` para obter o nome e gêneros, leitura da coleção `musica` e atualização de `historico_musicas`/`musica_recomendada`.




* **Leituras e Gravações nos Emuladores:**
* **Leitura**: Leitura de usuário autenticado no Auth; leitura das músicas na coleção `musica` (`TelaInicialScreen`).
* **Gravação**: Criação de usuário no Auth (`CadastroScreen`); criação do documento em `usuarios/{uid}` (`CadastroScreen`); atualização do array `generos_favoritos` em `usuarios/{uid}` (`GenerosCadastroScreen`).


* **Dados Pré-existentes:**
* Usuário no Auth: `tester@sintonize.test` (senha `senha123`).
* Documento `usuarios/{uid}` pré-existente com `nome: 'tester sintonize'` e `generos_favoritos: ['rock', 'pop']`.
* Coleção `musica`: 5 documentos (`bohemian rhapsody`, `billie jean`, `take five`, `the thrill is gone`, `one love`).



---

### 3. Caminho de Navegação e Sincronização

1. **Boas-vindas (`HomeScreen`)**:
* O app inicia com animação de fade-in no logo (duração de 2s após delay de 500ms).
* Localiza-se o botão `find.widgetWithText(ElevatedButton, 'Cadastro')`.
* Dispara-se `tester.tap(...)` e aguarda-se a transição de rota (`PageRouteBuilder` com SlideTransition) via `tester.pumpAndSettle()`.


2. **Formulário de Cadastro (`CadastroScreen`)**:
* O formulário reside dentro de um `SingleChildScrollView`. Para campos inferiores (como CEP, Rua, Número, Bairro, Cidade, Estado e o botão "Cadastrar"), utiliza-se `tester.ensureVisible(finder)` antes da interação.
* Dispara-se `tester.enterText(finder, text)`.
* Toca-se no botão `find.widgetWithText(ElevatedButton, 'Cadastrar')`.
* Como há chamadas assíncronas de rede para os emuladores (Auth e Firestore), utiliza-se `tester.pump()` seguido de `tester.pumpAndSettle(const Duration(milliseconds: 500))` para aguardar a resolução dos `Futures` e a navegação (`MaterialPageRoute`).


3. **Seleção de Gêneros (`GenerosCadastroScreen`)**:
* Verifica-se a presença do texto `'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'`.
* Alterna-se o estado de switches desejados via `tester.tap(find.byType(Switch).first)`.
* Rola-se a tela até o botão "Confirmar" se necessário e toca-se nele: `tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar'))`.
* Aguarda-se `tester.pumpAndSettle()` para que a atualização do Firestore conclua e a rota da `TelaInicialScreen` termine de subir.


4. **Tela Inicial (`TelaInicialScreen`)**:
* Confirma-se a transição checando a presença do texto de recomendação musical (`find.textContaining('essa é a nossa recomendação de música para você!')` ou `find.byType(TelaInicialScreen)`).



---

### 4. Cenários de Teste

1. **Cenário 1: Sucesso Ponta a Ponta (Cadastro Completo → Gêneros → Tela Inicial)**
* Inicia na `HomeScreen`, navega para `CadastroScreen`.
* Preenche todos os campos com dados válidos e únicos.
* Toca em "Cadastrar" e aguarda transição para `GenerosCadastroScreen`.
* Ativa os gêneros "Rock" e "Pop".
* Toca em "Confirmar" e valida a transição bem-sucedida para a `TelaInicialScreen`.


2. **Cenário 2: Erros de Validação Síncrona do Formulário**
* Navega até a `CadastroScreen`.
* Toca diretamente em "Cadastrar" com todos os campos vazios.
* Valida a renderização das mensagens de validação síncronas na UI (`O nome é obrigatório`, `A data de nascimento é obrigatória`, `O e-mail é obrigatório`, `A senha é obrigatória`, `O CEP é obrigatório`, `O número é obrigatório`).
* Não ocorre navegação.


3. **Cenário 3: Validação de Regras de Formato e Incompatibilidade**
* Preenche nome com dígitos (`Marcos 123`), data inválida (`32/13/2026`), e-mail malformado (`invalido@com`), senha curta (`12345`) e confirmação divergente (`54321`).
* Toca em "Cadastrar".
* Valida as mensagens de erro específicas correspondentes a cada regra.


4. **Cenário 4: Erro do Firebase Auth (E-mail já cadastrado)**
* Preenche o formulário com dados válidos, porém utilizando o e-mail pré-existente no emulador (`tester@sintonize.test`).
* Toca em "Cadastrar".
* Aguarda a resposta do Firebase Auth e valida a exibição do SnackBar contendo `Erro ao cadastrar:`.
* Garante que o usuário permaneceu na `CadastroScreen`.


5. **Cenário 5: Erro de Fluxo na Seleção de Gêneros (Nenhum Selecionado)**
* Cadastra um novo usuário com sucesso e chega à `GenerosCadastroScreen`.
* Sem acionar nenhum switch (todos iniciam desmarcados), toca diretamente em "Confirmar".
* Valida a exibição do SnackBar com o texto `'Selecione pelo menos um gênero musical!'`.
* Garante que o usuário permaneceu na `GenerosCadastroScreen`.



---

### 5. Código dos Testes End-to-End

```dart
// ===== integration_test/fase3/cadastro_generos_flow_test.dart =====
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

  /// Helper para navegar da HomeScreen até a CadastroScreen
  Future<void> navigateToCadastro(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final cadastroBtn = find.widgetWithText(ElevatedButton, 'Cadastro');
    expect(cadastroBtn, findsOneWidget);

    await tester.tap(cadastroBtn);
    await tester.pumpAndSettle();

    expect(find.byType(CadastroScreen), findsOneWidget);
  }

  group('Fluxo E2E: Cadastro de Usuário e Seleção de Gêneros', () {
    testWidgets('Cenário 1: Sucesso de ponta a ponta (Cadastro -> Gêneros -> Tela Inicial)',
        (WidgetTester tester) async {
      await navigateToCadastro(tester);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueEmail = 'novo_usuario_$timestamp@sintonize.test';

      // Localizadores dos campos de texto (pelo label textual)
      final nomeField = find.widgetWithText(TextFormField, '').first; 
      // Busca específica baseada nos ancestrais ou campos sequenciais
      final textFields = find.byType(TextFormField);

      // Preenchimento dos dados pessoais
      await tester.enterText(textFields.at(0), 'Usuario Teste'); // Nome
      await tester.enterText(textFields.at(1), '15101998');     // Data de Nascimento (com formatador)
      await tester.enterText(textFields.at(2), uniqueEmail);     // E-mail
      await tester.enterText(textFields.at(3), 'senhaSegura123'); // Senha
      await tester.enterText(textFields.at(4), 'senhaSegura123'); // Confirmar Senha

      // Scroll para campos de endereço
      await tester.ensureVisible(textFields.at(5));
      await tester.enterText(textFields.at(5), '50000000'); // CEP (com formatador vira 50000-000)
      
      await tester.ensureVisible(textFields.at(6));
      await tester.enterText(textFields.at(6), 'Rua das Flores'); // Rua

      await tester.ensureVisible(textFields.at(7));
      await tester.enterText(textFields.at(7), '123'); // Número

      await tester.ensureVisible(textFields.at(8));
      await tester.enterText(textFields.at(8), 'Boa Viagem'); // Bairro

      await tester.ensureVisible(textFields.at(9));
      await tester.enterText(textFields.at(9), 'Recife'); // Cidade

      // Seleção do Estado no Dropdown
      final estadoDropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(estadoDropdown);
      await tester.tap(estadoDropdown);
      await tester.pumpAndSettle();

      final peOption = find.widgetWithText(DropdownMenuItem<String>, 'PE').last;
      await tester.tap(peOption);
      await tester.pumpAndSettle();

      // Botão Cadastrar
      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);

      // Aguarda comunicação assíncrona com Auth, Firestore e navegação
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verifica se alcançou a tela de seleção de gêneros
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      // Seleciona gêneros (Rock e Pop)
      final switches = find.byType(Switch);
      expect(switches, findsWidgets);

      // Marca o primeiro (Rock) e o segundo (Pop)
      await tester.tap(switches.at(0));
      await tester.pumpAndSettle();
      await tester.tap(switches.at(1));
      await tester.pumpAndSettle();

      // Confirmação
      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarBtn);
      await tester.tap(confirmarBtn);

      // Aguarda persistência e navegação para TelaInicialScreen
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(TelaInicialScreen), findsOneWidget);
      expect(
        find.textContaining('essa é a nossa recomendação de música para você!'),
        findsOneWidget,
      );
    });

    testWidgets('Cenário 2: Erros de validação síncrona com campos obrigatórios vazios',
        (WidgetTester tester) async {
      await navigateToCadastro(tester);

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      // Validações disparadas pelo _formKey.currentState!.validate()
      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);

      // Garante que não transitou de tela
      expect(find.byType(CadastroScreen), findsOneWidget);
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 3: Validação de regras de formato e divergência de senha',
        (WidgetTester tester) async {
      await navigateToCadastro(tester);

      final textFields = find.byType(TextFormField);

      // Preenche dados violando as regras
      await tester.enterText(textFields.at(0), 'Marcos 123'); // Nome inválido com dígitos
      await tester.enterText(textFields.at(1), '32132026'); // Data inválida
      await tester.enterText(textFields.at(2), 'email-invalido'); // Formato de e-mail inválido
      await tester.enterText(textFields.at(3), '123'); // Senha menor que 6 caracteres
      await tester.enterText(textFields.at(4), '999'); // Senhas incompatíveis

      await tester.ensureVisible(textFields.at(5));
      await tester.enterText(textFields.at(5), '1234'); // CEP incompleto

      await tester.ensureVisible(textFields.at(7));
      await tester.enterText(textFields.at(7), 'abc'); // Número não-numérico

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);
      await tester.pumpAndSettle();

      // Verificação das mensagens
      expect(find.text('O nome não pode conter números ou caracteres especiais'), findsOneWidget);
      expect(find.text('Mês deve ser entre 01 e 12'), findsOneWidget);
      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.text('CEP inválido. Formato correto: XXXXX-XXX'), findsOneWidget);
      expect(find.text('O número deve ser numérico'), findsOneWidget);

      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 4: Erro do Firebase Auth (E-mail já cadastrado)',
        (WidgetTester tester) async {
      await navigateToCadastro(tester);

      final textFields = find.byType(TextFormField);

      // Preenche com o e-mail pré-existente no emulador Auth
      await tester.enterText(textFields.at(0), 'Tester Conflito');
      await tester.enterText(textFields.at(1), '10101995');
      await tester.enterText(textFields.at(2), 'tester@sintonize.test');
      await tester.enterText(textFields.at(3), 'senha123');
      await tester.enterText(textFields.at(4), 'senha123');

      await tester.ensureVisible(textFields.at(5));
      await tester.enterText(textFields.at(5), '50000000');

      await tester.ensureVisible(textFields.at(6));
      await tester.enterText(textFields.at(6), 'Rua Principal');

      await tester.ensureVisible(textFields.at(7));
      await tester.enterText(textFields.at(7), '100');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);

      // Aguarda resposta do emulador Auth
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Deve exibir SnackBar com a mensagem de erro do Firebase Auth
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Erro ao cadastrar:'), findsOneWidget);

      // Garante que o usuário permaneceu na tela de cadastro
      expect(find.byType(CadastroScreen), findsOneWidget);
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 5: Erro de fluxo na seleção de gêneros (nenhum selecionado)',
        (WidgetTester tester) async {
      await navigateToCadastro(tester);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueEmail = 'genero_test_$timestamp@sintonize.test';
      final textFields = find.byType(TextFormField);

      // Cadastro com dados válidos
      await tester.enterText(textFields.at(0), 'Ana Santos');
      await tester.enterText(textFields.at(1), '20052000');
      await tester.enterText(textFields.at(2), uniqueEmail);
      await tester.enterText(textFields.at(3), 'senha123');
      await tester.enterText(textFields.at(4), 'senha123');

      await tester.ensureVisible(textFields.at(5));
      await tester.enterText(textFields.at(5), '50000000');

      await tester.ensureVisible(textFields.at(7));
      await tester.enterText(textFields.at(7), '42');

      final cadastrarBtn = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.ensureVisible(cadastrarBtn);
      await tester.tap(cadastrarBtn);

      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(GenerosCadastroScreen), findsOneWidget);

      // Sem alternar nenhum switch, tenta confirmar
      final confirmarBtn = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.ensureVisible(confirmarBtn);
      await tester.tap(confirmarBtn);
      await tester.pump(); // Renderiza o SnackBar

      // Validação do SnackBar de alerta
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Selecione pelo menos um gênero musical!'),
        findsOneWidget,
      );

      // Não deve navegar para a TelaInicialScreen
      expect(find.byType(TelaInicialScreen), findsNothing);
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
    });
  });
}

```
