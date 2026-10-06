<!-- Resposta do Gemini 3.8 Flash à geração (iteração 0), rodada FASE3-E2E-COT-02_cadastroFlow, 2026-10-06, sem edição.
     Markdown do botão "Copiar" da resposta. Envio e cópia automatizados (Claude in Chrome).
     Conversa: https://gemini.google.com/app/3968b3e7d43db829 -->

### 1. Análise do Fluxo

O fluxo se inicia na tela de boas-vindas (`HomeScreen`), onde o usuário opta por iniciar um novo registro tocando no botão "Cadastro". Na `CadastroScreen`, o usuário deve preencher seus dados pessoais (nome, data de nascimento, e-mail, senha, confirmação de senha) e endereço (CEP com autocompletar via ViaCEP, rua, número, bairro, cidade e estado).

O primeiro ponto de decisão ocorre na submissão do formulário (`_submit`): caso haja erros de validação local (ex.: e-mail malformatado, campos em branco, senhas divergentes), mensagens de validação síncronas aparecem em cada campo sem acionar a rede. Caso passe na validação, o app tenta registrar a credencial no Firebase Auth (`createUserWithEmailAndPassword`) e salvar os dados no Firestore (`usuarios/{uid}`). Se o e-mail já estiver cadastrado ou houver falha de rede/Firebase, uma `SnackBar` exibe a mensagem de erro e a tela permanece inalterada; obtendo sucesso, o usuário é redirecionado para a `GenerosCadastroScreen`.

Nesta segunda tela, o segundo ponto de decisão ocorre ao tocar em "Confirmar": se nenhum gênero for selecionado, uma `SnackBar` adverte o usuário ("Selecione pelo menos um gênero musical!"); caso ao menos um gênero esteja ativo via `Switch`, o documento no Firestore é atualizado com `generos_favoritos` e a navegação avança para a `TelaInicialScreen`, concluindo o fluxo com a recomendação musical gerada.

---

### 2. Identificação das Dependências

| Tela | Serviço | Ação / Leitura / Escrita | Dados Pré-existentes Necessários |
| --- | --- | --- | --- |
| **`HomeScreen`** | Nenhum | Apenas animação de opacidade e navegação. | Nenhum. |
| **`CadastroScreen`** | **ViaCEP (HTTP)** | `GET [https://viacep.com.br/ws/$cep/json/](https://viacep.com.br/ws/$cep/json/)`: Lê e preenche logradouro, bairro, cidade e UF quando o CEP atinge 9 caracteres (ex.: `50000-000`). | Conexão de rede ativa / emulador com saída HTTP. |
|  | **Firebase Auth** | `createUserWithEmailAndPassword()`: cria o registro do usuário com base em `_emailController` e `_senhaController`. | Para o teste de erro de e-mail duplicado: usuário inicial `tester@sintonize.test` (`senha123`). |
|  | **Firestore** | `set()` no caminho `usuarios/{uid}`: grava dados pessoais (nome, data de nascimento, e-mail) e mapa de endereço. | Nenhum (cria novo documento associado ao UID). |
| **`GenerosCadastroScreen`** | **Firebase Auth** | Lê `_auth.currentUser` para obter o `uid`. | Sessão ativa criada no passo anterior. |
|  | **Firestore** | `update()` no caminho `usuarios/{uid}` adicionando a chave `generos_favoritos` (lista de strings). | Documento `usuarios/{uid}` criado na tela anterior. |
| **`TelaInicialScreen`** | **Firestore** | Leitura de `usuarios/{uid}` (nome, gêneros favoritos e histórico) e leitura da coleção `musica` (docs com `genre`, `track_name`, `artist_name`). Atualiza `historico_musicas` e `musica_recomendada`. | Documentos da coleção `musica` (`bohemian rhapsody`, `billie jean`, `take five`, etc.). |

---

### 3. Caminho de Navegação e Sincronização

1. **Início (`MyApp`):**
* Renderiza `HomeScreen` com mensagem "Bem-vindo ao Sintonize!".
* Há um delay de 500 ms com animação de 2 segundos para o logo. No teste, usamos `await tester.pumpAndSettle();`.


2. **Navegação para `CadastroScreen`:**
* Localiza o botão pelo texto `'Cadastro'` ou ícone `Icons.app_registration` e toca: `await tester.tap(find.text('Cadastro'));`.
* Aguarda a transição de rota animada (`SlideTransition`): `await tester.pumpAndSettle();`.


3. **Preenchimento e Envio em `CadastroScreen`:**
* Preenche os campos de texto usando `tester.enterText()`.
* Para o campo de CEP, após digitar os 9 dígitos (ex.: `50010-000`), deve-se aguardar a requisição HTTP com `await tester.pump(const Duration(seconds: 2));` e em seguida `await tester.pumpAndSettle();` ou preencher os campos de endereço manualmente.
* Dá scroll para garantir visibilidade do botão 'Cadastrar': `await tester.scrollUntilVisible(find.widgetWithText(ElevatedButton, 'Cadastrar'), 100);`.
* Toca no botão 'Cadastrar' e aguarda as promises do Firebase Auth e Firestore resolverem no emulador: `await tester.pumpAndSettle();`.


4. **Interação em `GenerosCadastroScreen`:**
* Verifica presença do texto `"SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA"`.
* Localiza o `Switch` correspondente ao gênero musical desejado e toca para ativá-lo.
* Dá scroll até o botão 'Confirmar' e toca: `await tester.tap(find.widgetWithText(ElevatedButton, 'Confirmar'));`.
* Aguarda escrita no Firestore e transição para `TelaInicialScreen`: `await tester.pumpAndSettle();`.


5. **Verificação em `TelaInicialScreen`:**
* Verifica se a tela inicial foi carregada através do ícone da barra de navegação `'Pesquisa Direta'` ou pelo texto de recomendação de música.



---

### 4. Cenários de Teste

1. **Cenário 1: Sucesso Ponta a Ponta (Cadastro Completo com Seleção de Gênero):**
* Inicia no app, clica em "Cadastro", preenche todos os campos com dados válidos e não cadastrados.
* Clica em "Cadastrar", navega para `GenerosCadastroScreen`, ativa ao menos um gênero ('Rock') e clica em "Confirmar".
* Confirma redirecionamento para `TelaInicialScreen`.


2. **Cenário 2: Validação de Formulário Local (Campos Obrigatórios e Inválidos):**
* Clica em "Cadastro", deixa campos vazios ou preenche com formatos inválidos (ex.: nome com números, data no formato errado, senhas diferentes).
* Toca em "Cadastrar" e verifica se as mensagens de validação surgem em tela sem acionar o Firebase.


3. **Cenário 3: Erro do Firebase Auth (E-mail Já Cadastrado):**
* Preenche o formulário usando o e-mail pré-existente nos emuladores (`tester@sintonize.test`).
* Clica em "Cadastrar" e valida a exibição da `SnackBar` com mensagem informando o erro vindo do Firebase Auth. Permanece na `CadastroScreen`.


4. **Cenário 4: Validação de Fluxo na Tela de Gêneros (Nenhum Gênero Selecionado):**
* Realiza cadastro com usuário válido até chegar na `GenerosCadastroScreen`.
* Toca diretamente em "Confirmar" sem marcar nenhum `Switch`.
* Verifica exibição da `SnackBar` com `"Selecione pelo menos um gênero musical!"` e a permanência na mesma tela.



---

### 5. Código dos Testes (`integration_test/fase3/cadastro_fluxo_test.dart`)

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

      // Gera um email único para evitar colisões no Auth Emulator
      final String uniqueEmail = 'novo_usuario_${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      // 2. Preenchimento dos campos do formulário
      final scrollableForm = find.byType(Scrollable).first;

      // Nome
      final campoNome = find.widgetWithText(TextFormField, '').at(0);
      await tester.enterText(campoNome, 'Marcos Vinicius');
      await tester.pumpAndSettle();

      // Data de Nascimento
      final campoData = find.widgetWithText(TextFormField, '').at(1);
      await tester.enterText(campoData, '19032001'); // Passa pelo formatter virando 19/03/2001
      await tester.pumpAndSettle();

      // E-mail
      final campoEmail = find.widgetWithText(TextFormField, '').at(2);
      await tester.enterText(campoEmail, uniqueEmail);
      await tester.pumpAndSettle();

      // Senha e Confirmar Senha
      final campoSenha = find.widgetWithText(TextFormField, '').at(3);
      await tester.enterText(campoSenha, 'senha123');
      await tester.pumpAndSettle();

      final campoConfSenha = find.widgetWithText(TextFormField, '').at(4);
      await tester.enterText(campoConfSenha, 'senha123');
      await tester.pumpAndSettle();

      // CEP
      final campoCep = find.widgetWithText(TextFormField, '').at(5);
      await tester.enterText(campoCep, '50010000'); // Formata para 50010-000
      await tester.pumpAndSettle();

      // Scroll para campos inferiores
      await tester.drag(scrollableForm, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Rua
      final campoRua = find.widgetWithText(TextFormField, '').at(6);
      await tester.enterText(campoRua, 'Rua da Aurora');
      await tester.pumpAndSettle();

      // Número
      final campoNumero = find.widgetWithText(TextFormField, '').at(7);
      await tester.enterText(campoNumero, '100');
      await tester.pumpAndSettle();

      // Bairro
      final campoBairro = find.widgetWithText(TextFormField, '').at(8);
      await tester.enterText(campoBairro, 'Boa Vista');
      await tester.pumpAndSettle();

      // Cidade
      final campoCidade = find.widgetWithText(TextFormField, '').at(9);
      await tester.enterText(campoCidade, 'Recife');
      await tester.pumpAndSettle();

      // Dropdown Estado
      final dropdownEstado = find.byType(DropdownButtonFormField<String>);
      await tester.tap(dropdownEstado);
      await tester.pumpAndSettle();

      final itemPE = find.widgetWithText(DropdownMenuItem<String>, 'PE').last;
      await tester.tap(itemPE);
      await tester.pumpAndSettle();

      // 3. Submeter formulário de cadastro
      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 100, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);

      // Aguarda processamento de Firebase Auth + Firestore e transição de tela
      await tester.pumpAndSettle();

      // 4. Verificação e interação na GenerosCadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      // Ativa o gênero 'Rock'
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
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(botaoConfirmar);

      // Aguarda salvamento no Firestore e navegação para a tela principal
      await tester.pumpAndSettle();

      // 6. Confirmação do estado final na TelaInicialScreen
      expect(find.byType(TelaInicialScreen), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsOneWidget);
    });

    testWidgets('Cenário 2: Erros de validação local no formulário', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Ir para CadastroScreen
      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final scrollableForm = find.byType(Scrollable).first;

      // 1. Tentar submeter formulário em branco
      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 100, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);
      await tester.pumpAndSettle();

      // Verifica mensagens de campos obrigatórios
      expect(find.text('O nome é obrigatório'), findsOneWidget);
      expect(find.text('A data de nascimento é obrigatória'), findsOneWidget);
      expect(find.text('O e-mail é obrigatório'), findsOneWidget);
      expect(find.text('A senha é obrigatória'), findsOneWidget);
      expect(find.text('O CEP é obrigatório'), findsOneWidget);
      expect(find.text('O número é obrigatório'), findsOneWidget);

      // 2. Preencher com dados fora da regra
      await tester.drag(scrollableForm, const Offset(0, 500));
      await tester.pumpAndSettle();

      final campoNome = find.widgetWithText(TextFormField, '').at(0);
      await tester.enterText(campoNome, 'User123!');

      final campoEmail = find.widgetWithText(TextFormField, '').at(2);
      await tester.enterText(campoEmail, 'email_invalido_sem_arroba');

      final campoSenha = find.widgetWithText(TextFormField, '').at(3);
      await tester.enterText(campoSenha, '123'); // menor que 6 caracteres

      final campoConfSenha = find.widgetWithText(TextFormField, '').at(4);
      await tester.enterText(campoConfSenha, '456'); // senhas diferentes

      await tester.scrollUntilVisible(botaoCadastrar, 100, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);
      await tester.pumpAndSettle();

      expect(find.text('O nome não pode conter números ou caracteres especiais'), findsOneWidget);
      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      expect(find.text('As senhas não coincidem'), findsOneWidget);

      // Garante que permaneceu na CadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsNothing);
    });

    testWidgets('Cenário 3: Erro do Firebase Auth com e-mail já existente', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Cadastro'));
      await tester.pumpAndSettle();

      final scrollableForm = find.byType(Scrollable).first;

      // Preenche os dados usando o e-mail pré-existente nos emuladores
      await tester.enterText(find.widgetWithText(TextFormField, '').at(0), 'Tester Clone');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(1), '01012000');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(2), 'tester@sintonize.test');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(3), 'senha123');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(4), 'senha123');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(5), '50000000');

      await tester.drag(scrollableForm, const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, '').at(6), 'Rua Teste');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(7), '10');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(8), 'Centro');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(9), 'Recife');

      final dropdownEstado = find.byType(DropdownButtonFormField<String>);
      await tester.tap(dropdownEstado);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(DropdownMenuItem<String>, 'PE').last);
      await tester.pumpAndSettle();

      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 100, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);

      // Aguarda resposta do Firebase Auth Emulator
      await tester.pumpAndSettle();

      // Verifica exibição da SnackBar com erro
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
      final String randomEmail = 'genero_test_${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      await tester.enterText(find.widgetWithText(TextFormField, '').at(0), 'Usuario Genero');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(1), '10101995');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(2), randomEmail);
      await tester.enterText(find.widgetWithText(TextFormField, '').at(3), 'senhaValida123');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(4), 'senhaValida123');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(5), '50010000');

      await tester.drag(scrollableForm, const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, '').at(6), 'Avenida Norte');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(7), '500');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(8), 'Encruzilhada');
      await tester.enterText(find.widgetWithText(TextFormField, '').at(9), 'Recife');

      final dropdownEstado = find.byType(DropdownButtonFormField<String>);
      await tester.tap(dropdownEstado);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(DropdownMenuItem<String>, 'PE').last);
      await tester.pumpAndSettle();

      final botaoCadastrar = find.widgetWithText(ElevatedButton, 'Cadastrar');
      await tester.scrollUntilVisible(botaoCadastrar, 100, scrollable: scrollableForm);
      await tester.tap(botaoCadastrar);
      await tester.pumpAndSettle();

      // Chega à GenerosCadastroScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);

      // Tenta confirmar diretamente sem acionar nenhum Switch
      final botaoConfirmar = find.widgetWithText(ElevatedButton, 'Confirmar');
      await tester.scrollUntilVisible(
        botaoConfirmar,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(botaoConfirmar);
      await tester.pump(); // Renderiza o frame com o SnackBar

      // Valida SnackBar de advertência
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Selecione pelo menos um gênero musical!'), findsOneWidget);

      // Permanece na GenerosCadastroScreen sem avançar para a TelaInicialScreen
      expect(find.byType(GenerosCadastroScreen), findsOneWidget);
      expect(find.byType(TelaInicialScreen), findsNothing);
    });
  });
}

```