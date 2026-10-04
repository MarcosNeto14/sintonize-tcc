# FASE3-E2E-FS-02_cadastroFlow — ChatGPT (rodada limpa)

Rodada 14 do plano (bloco 2 — FS, ChatGPT). 2026-10-04 (01:23–01:41), segunda máquina, automação, autor ausente.

**Resultado em uma linha:** 1 teste (só o fluxo completo); **não compila na geração** (falta `material.dart`); reparo 1 **(A)** → 0/1 (toques no dropdown fora do alvo **e** nome "Usuário E2E" recusado pelo validador); reparo 2 **(A)** com rolagem → 0/1 (o nome continua barrando); reparo 3 **(A)** **identifica o nome com dígito** e troca por "Usuário Teste" → 0/1 final: o teste passa do formulário, chega à tela de gêneros e falha ao procurar "Reggae", fora da parte visível de um `ListView.builder` preguiçoso. Auditoria: **Erro de geração** + **Erro de teste** nas três iterações; o app está correto.

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-E2E-FS-02_cadastroFlow (rodada limpa) |
| **Modelo** | ChatGPT |
| **Fluxo alvo** | cadastro — boas-vindas → `CadastroScreen` → `GenerosCadastroScreen` → `TelaInicialScreen` |
| **Estado do `lib/`** | limpo — `git diff ccae44a -- lib/` vazio |
| **Worktree usado** | `C:\Users\Marcos\Desktop\sintonize-fase3`, `fase3-e2e` @ `11e7536` |
| **Nível da pirâmide** | E2E (integration_test no AVD, emuladores Firebase) |
| **Estratégia de prompt** | Few-shot |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/few-shot/FASE3-E2E-FS-02_cadastroFlow.md` — sha256 `0a48e913d051c4d623495ed73a435ab697b31a56371caae2cb0062143ff1aac2`, igual a `_sha256.txt` |
| **✦ Modelo declarado pelo LLM** | "GPT-5.6 Luna" — 2026-10-04, 00:17. Não repetido: dispensa do autor. |
| **✦ Verificação externa da versão** | Última consulta: Help Center, 2026-10-03. Dispensada pelo autor em 2026-10-04. |
| **Sessão** | ChatGPT deslogada ("Entrar" e "Cadastre-se grátis" visíveis) |
| **Consultou fontes externas?** | Não — nenhum marcador de citação nas respostas |
| **Data de acesso** | 2026-10-04 |
| **Conversa nova?** | Sim — `https://chatgpt.com/uc/6ac1d4a9-ca80-83ea-8e55-2007ba035285` (1ª tentativa; resposta completa na primeira) |
| **Envio** | Automatizado (Claude in Chrome), autor ausente; editor conferido por DOM antes de cada envio; respostas pelo botão "Copiar resposta". |
| **Versão do Flutter** | 3.41.6 · Dart 3.11.4 |
| **AVD** | `tcc_e2e` (Pixel 6, API 34), `emulator-5554` |
| **firebase-tools** | 15.31.0 |

---

## Procedimento operacional (executado)

- [x] Worktree limpo conferido.
- [x] Prompt colado sem alteração (52.384 caracteres).
- [x] Código salvo sem editar em `integration_test/fase3/cadastro_fs_test.dart` (único bloco; o modelo nomeou `cadastro_generos_test.dart`). Reparos 1, 2 e 3: "arquivo corrigido" / "versão revisada completa" — substituição integral nas três.
- [x] Antes de cada uma das 4 execuções: emuladores reiniciados, seed, conferência por REST (inclusive 1 conta no Auth).
- [x] Saídas `resultados/chatgpt/FASE3-E2E-FS-02_cadastroFlow_iter{0,1,2}.txt` e `_iter3_final.txt`; prints `evidencias/chatgpt/FASE3-E2E-FS-02_cadastroFlow_iter{0..3}.png`.
- [x] Teste final em `integration_test/fase3/chatgpt/cadastro_fs_test.dart` (sha256 `4d000e3d108be306…`), cópia em `teste_iter3_final.dart`; geração em `teste_iter0_geracao.dart` (sha256 `422bc43a6d6d6adf…`).

---

## Prompt Enviado

Texto entre o 2º e o 3º `---` de `fase3-e2e/prompts_prontos/few-shot/FASE3-E2E-FS-02_cadastroFlow.md`, sem alteração (52.384 caracteres). Arquivo e sha256 são o registro.

---

## Resposta do LLM

`FASE3-E2E-FS-02_cadastroFlow_transcricao/iter0_resposta.md` (7593 caracteres, botão "Copiar resposta").

`````markdown
Abaixo está um teste E2E completo para o fluxo de cadastro → seleção de gêneros → persistência no Firestore → chegada à tela inicial. Ele usa os emuladores reais e não injeta mocks nas telas.

```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> esperar(
    WidgetTester tester,
    Finder finder, {
    int tentativas = 40,
  }) async {
    for (var i = 0; i < tentativas; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu após esperar: $finder');
  }

  Future<void> preencherCampo(
    WidgetTester tester,
    String label,
    String valor,
  ) async {
    final campo = find.widgetWithText(TextFormField, label);

    // Os TextFormField não exibem o label como texto interno. Primeiro
    // tentamos localizar pelo texto do label e, se necessário, usamos a
    // posição dos campos na tela.
    if (campo.evaluate().isNotEmpty) {
      await tester.enterText(campo, valor);
      return;
    }

    fail('Campo "$label" não encontrado.');
  }

  testWidgets(
    'cadastro completo: cria usuário, salva gêneros favoritos e abre tela inicial',
    (tester) async {
      // Gera dados únicos para que o teste possa ser executado novamente
      // sem colidir com usuários criados em execuções anteriores.
      final identificador = DateTime.now().millisecondsSinceEpoch;
      final email = 'e2e-$identificador@sintonize.test';
      const senha = 'senha123';

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tela inicial.
      expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Cadastro'), findsOneWidget);

      await tester.tap(find.text('Cadastro'));
      await tester.pumpAndSettle();

      // CadastroScreen.
      expect(find.text('Cadastrar'), findsOneWidget);

      // A tela contém 9 TextFormFields, nesta ordem:
      // 0 Nome
      // 1 Data de Nascimento
      // 2 E-mail
      // 3 Senha
      // 4 Confirmar Senha
      // 5 CEP
      // 6 Rua
      // 7 Número
      // 8 Bairro
      // 9 Cidade
      //
      // Como os TextFormFields são criados sem semanticsLabel, usamos
      // a ordem em que aparecem na tela.
      final campos = find.byType(TextFormField);

      expect(campos, findsNWidgets(10));

      await tester.enterText(
        campos.at(0),
        'Usuário E2E',
      );

      await tester.enterText(
        campos.at(1),
        '01/01/2000',
      );

      await tester.enterText(
        campos.at(2),
        email,
      );

      await tester.enterText(
        campos.at(3),
        senha,
      );

      await tester.enterText(
        campos.at(4),
        senha,
      );

      await tester.enterText(
        campos.at(5),
        '01001000',
      );

      // O CEP dispara uma chamada HTTP para o ViaCEP. O teste E2E
      // não deve depender dela para preencher os dados obrigatórios,
      // portanto garantimos os demais campos manualmente.
      await tester.enterText(
        campos.at(6),
        'Praça da Sé',
      );

      await tester.enterText(
        campos.at(7),
        '100',
      );

      await tester.enterText(
        campos.at(8),
        'Sé',
      );

      await tester.enterText(
        campos.at(9),
        'São Paulo',
      );

      // Seleciona o estado.
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SP').last);
      await tester.pumpAndSettle();

      // O botão pode estar abaixo da área atualmente visível do
      // SingleChildScrollView.
      final cadastrar = find.text('Cadastrar');

      await tester.ensureVisible(cadastrar);
      await tester.tap(cadastrar);

      // O submit cria primeiro o usuário no Firebase Auth e depois
      // cria usuarios/{uid} no Firestore.
      await esperar(
        tester,
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
      );

      // Confirma que o fluxo realmente chegou à tela de gêneros.
      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );
      expect(find.text('Rock'), findsOneWidget);
      expect(find.text('Pop'), findsOneWidget);
      expect(find.text('Jazz'), findsOneWidget);
      expect(find.text('Confirmar'), findsOneWidget);

      // Cada gênero possui um Switch. Selecionamos Rock e Pop.
      final switches = find.byType(Switch);

      expect(switches, findsNWidgets(7));

      await tester.tap(switches.at(0)); // Rock
      await tester.pump();

      await tester.tap(switches.at(1)); // Pop
      await tester.pump();

      // Confirmar salva generos_favoritos no documento do usuário.
      await tester.tap(find.text('Confirmar'));

      await esperar(
        tester,
        find.text('essa é a nossa recomendação de música para você!'),
      );

      // O fluxo terminou na TelaInicialScreen.
      expect(
        find.text('essa é a nossa recomendação de música para você!'),
        findsOneWidget,
      );

      // Validação E2E adicional diretamente no Firestore emulator.
      //
      // Não estamos mockando a tela: apenas verificamos o efeito persistido
      // pelo fluxo real executado acima.
      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);
      expect(user!.email, email);

      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(snapshot.exists, isTrue);

      final data = snapshot.data()!;

      expect(data['nome'], 'Usuário E2E');
      expect(data['email'], email);
      expect(data['generos_favoritos'], containsAll(['Rock', 'Pop']));
      expect(
        (data['generos_favoritos'] as List).length,
        2,
      );
    },
  );
}
```

 Há um detalhe importante no código acima: o teste deve ser salvo, por exemplo, como:

 `integration_test/fase3/cadastro_generos_test.dart`

 e executado com:

```
flutter test integration_test/fase3/cadastro_generos_test.dart -d emulator-5554
```

 ### Observação importante sobre o CEP

 O `CadastroScreen` chama diretamente o ViaCEP quando o campo chega a 9 caracteres. Isso introduz uma dependência externa no E2E. O teste acima preenche o CEP e depois sobrescreve Rua/Bairro/Cidade, mas **a requisição ao ViaCEP ainda acontece**.

 Para um E2E realmente determinístico contra apenas os emuladores locais, eu recomendaria alterar a tela para que a consulta de CEP seja injetável ou desabilitada durante o teste. Como você pediu explicitamente o app real sem mocks, não fiz essa alteração no teste.

 Também há uma pequena inconsistência no comentário original da tela: são **10** `TextFormField`s, não 9 — Nome, Data de Nascimento, E-mail, Senha, Confirmar Senha, CEP, Rua, Número, Bairro e Cidade.

 Por fim, a validação final no Firestore é especialmente útil aqui: ela comprova que o `Confirmar` não apenas navegou para a `TelaInicialScreen`, mas realmente gravou `generos_favoritos` no documento `usuarios/{uid}` do usuário criado pelo próprio teste.
`````

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Não na geração; sim a partir do reparo 1 |
| **Testes gerados** | 1 — cadastro completo → gêneros → Firestore → tela inicial (verifica `data['nome']` e `generos_favoritos` no documento) |
| **Testes passaram (iteração 0)** | 0 (não compilou) |
| **Testes falharam (iteração 0)** | — (`Undefined name` para `TextFormField`, `DropdownButtonFormField`, `Switch`) |
| **Testes passaram (estado final)** | 0 |
| **Testes falharam (estado final)** | 1 — `find.text('Reggae')` acha 0 widgets na `GenerosCadastroScreen` (linha 198) |
| **Melhor estado intermediário** | = final (0/1), mas o estado final é o que chega mais longe no fluxo |
| **Tempo por execução** | iter0 11 s; iter1–3: 28–36 s (Gradle 12,4–12,6 s + 10–18 s de teste) |
| **Prints tirados** | 4 |

Progressão: iteração 1 — toques no dropdown (`Offset(205.7, 801.0)`) e em "SP" (`Offset(63.1, 617.9)`) fora do alvo, e a tela de gêneros não aparece; iteração 2 — rolagem corrige os toques, mas a tela de gêneros ainda não aparece porque o nome "Usuário E2E" tem dígito e o validador de `cadastro.dart` recusa o formulário (mesma causa da C3-ZS); iteração 3 — nome trocado, o fluxo chega à `GenerosCadastroScreen` e o teste afirma `find.text('Reggae'), findsOneWidget` antes de rolar; a lista de gêneros é um `ListView.builder` com altura de meia tela (`generos-cadastro.dart:137–141`) e "Reggae" (6º de 7) ainda não foi construído.

### Saída do terminal (iteração 0)

`resultados/chatgpt/FASE3-E2E-FS-02_cadastroFlow_iter0.txt`

```
Resolving dependencies...
Downloading packages...
  _fe_analyzer_shared 93.0.0 (108.0.0 available)
  _flutterfire_internals 1.3.52 (1.3.77 available)
  analyzer 10.0.1 (14.4.0 available)
  async 2.11.0 (2.13.1 available)
  boolean_selector 2.1.1 (2.1.2 available)
  build 4.0.5 (4.0.11 available)
  build_config 1.3.0 (1.3.3 available)
  build_daemon 4.1.1 (4.1.6 available)
  build_runner 2.13.1 (2.16.1 available)
  built_collection 5.1.1 (5.1.2 available)
  built_value 8.12.5 (8.13.0 available)
  cel 0.5.4+1 (0.6.0 available)
  clock 1.1.2 (1.1.3 available)
  cloud_firestore 5.6.4 (6.10.0 available)
  cloud_firestore_platform_interface 6.6.4 (8.0.7 available)
  cloud_firestore_web 4.4.4 (5.7.3 available)
  code_builder 4.11.1 (4.12.0 available)
  crypto 3.0.6 (3.0.7 available)
  dart_style 3.1.7 (3.1.13 available)
  equatable 2.0.8 (3.0.0 available)
  fake_cloud_firestore 3.1.0 (4.3.0 available)
  fake_firebase_security_rules 0.5.4 (0.6.0 available)
  firebase_auth 5.5.0 (6.7.0 available)
  firebase_auth_mocks 0.14.2 (0.15.2 available)
  firebase_auth_platform_interface 7.6.0 (9.1.0 available)
  firebase_auth_web 5.14.0 (6.3.0 available)
  firebase_core 3.12.0 (4.15.0 available)
  firebase_core_platform_interface 5.4.0 (8.1.1 available)
  firebase_core_web 2.21.0 (3.12.0 available)
  flutter_lints 5.0.0 (6.0.0 available)
  flutter_plugin_android_lifecycle 2.0.24 (2.0.35 available)
  geolocator 13.0.2 (14.1.1 available)
  geolocator_android 4.6.1 (5.1.1+1 available)
  geolocator_apple 2.3.9 (2.3.14 available)
  geolocator_platform_interface 4.2.4 (4.4.0 available)
  geolocator_web 4.1.1 (4.1.4 available)
  geolocator_windows 0.2.3 (0.2.5 available)
  glob 2.1.3 (2.2.0 available)
  google_maps 8.1.1 (8.3.0 available)
  google_maps_flutter 2.10.0 (2.18.2 available)
  google_maps_flutter_android 2.14.12 (2.21.0 available)
  google_maps_flutter_ios 2.13.2 (2.18.6 available)
  google_maps_flutter_platform_interface 2.11.0 (2.17.0 available)
  google_maps_flutter_web 0.5.10 (0.6.4+1 available)
  html 0.15.5 (0.15.7 available)
  http 0.13.6 (1.6.0 available)
  io 1.0.5 (1.1.0 available)
  json_annotation 4.9.0 (4.12.0 available)
  lints 5.1.1 (6.1.0 available)
  logger 2.7.0 (2.8.0 available)
  matcher 0.12.19 (0.12.20 available)
  material_color_utilities 0.13.0 (0.13.1 available)
  meta 1.17.0 (1.19.0 available)
  mime 2.0.0 (2.1.0 available)
  mockito 5.6.4 (5.8.1 available)
  package_config 2.2.0 (3.0.0 available)
  platform 3.1.6 (3.2.0 available)
  pool 1.5.2 (1.5.3 available)
  process 5.0.5 (5.0.6 available)
  pub_semver 2.2.0 (2.2.1 available)
  pubspec_parse 1.5.0 (1.6.0 available)
  rx 0.4.0 (0.5.0 available)
  sanitize_html 2.1.0 (2.2.0 available)
  source_gen 4.2.2 (4.3.0 available)
  source_span 1.10.0 (1.10.2 available)
  stack_trace 1.12.1 (1.12.2 available)
  stream_transform 2.1.1 (2.1.2 available)
  string_scanner 1.3.0 (1.4.1 available)
  term_glyph 1.2.1 (1.2.2 available)
  test_api 0.7.10 (0.7.14 available)
  uuid 4.5.1 (4.6.0 available)
  vector_math 2.2.0 (2.4.3 available)
  vm_service 14.3.0 (15.3.0 available)
  web 1.1.0 (1.1.1 available)
  webdriver 3.1.0 (3.2.0 available)
  yaml 3.1.3 (3.1.4 available)
Got dependencies!
76 packages have newer versions incompatible with dependency constraints.
Try `flutter pub outdated` for more information.
00:00 +0: loading C:/Users/Marcos/Desktop/sintonize-fase3/integration_test/fase3/cadastro_fs_test.dart
Running Gradle task 'assembleDebug'...                          
integration_test/fase3/cadastro_fs_test.dart:37:39: Error: Undefined name 'TextFormField'.
    final campo = find.widgetWithText(TextFormField, label);
                                      ^^^^^^^^^^^^^
integration_test/fase3/cadastro_fs_test.dart:87:34: Error: Undefined name 'TextFormField'.
      final campos = find.byType(TextFormField);
                                 ^^^^^^^^^^^^^
integration_test/fase3/cadastro_fs_test.dart:145:36: Error: Undefined name 'DropdownButtonFormField'.
      await tester.tap(find.byType(DropdownButtonFormField<String>));
                                   ^^^^^^^^^^^^^^^^^^^^^^^
integration_test/fase3/cadastro_fs_test.dart:176:36: Error: Undefined name 'Switch'.
      final switches = find.byType(Switch);
                                   ^^^^^^
Target kernel_snapshot_program failed: Exception


FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildDebug'.
> Process 'command 'C:\src\flutter\bin\flutter.bat'' finished with non-zero exit value 1

* Try:
> Run with --stacktrace option to get the stack trace.
> Run with --info or --debug option to get more log output.
> Run with --scan to get full insights.
> Get more help at https://help.gradle.org.

BUILD FAILED in 7s
Running Gradle task 'assembleDebug'...                              8,7s
00:00 +0 -1: loading C:/Users/Marcos/Desktop/sintonize-fase3/integration_test/fase3/cadastro_fs_test.dart [E]
  Failed to load "C:/Users/Marcos/Desktop/sintonize-fase3/integration_test/fase3/cadastro_fs_test.dart": Gradle task assembleDebug failed with exit code 1
  package:flutter_tools/src/base/common.dart 34:3                    throwToolExit
  package:flutter_tools/src/android/gradle.dart 592:7                AndroidGradleBuilder.buildGradleApp
  ===== asynchronous gap ===========================
  package:flutter_tools/src/android/gradle.dart 234:5                AndroidGradleBuilder.buildApk
  ===== asynchronous gap ===========================
  package:flutter_tools/src/android/android_device.dart 568:7        AndroidDevice.startApp
  ===== asynchronous gap ===========================
  package:flutter_tools/src/test/integration_test_device.dart 57:39  IntegrationTestTestDevice.start
  ===== asynchronous gap ===========================
  package:flutter_tools/src/test/flutter_platform.dart 680:51        FlutterPlatform._startTest.<fn>
  ===== asynchronous gap ===========================
  package:flutter_tools/src/base/async_guard.dart 108:24             asyncGuard.<fn>
  
00:00 +0 -1: Some tests failed.
```

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** não compila.
- **Prompt de reparo enviado:** template fixo + saída literal da iteração anterior (6.646 caracteres) — `FASE3-E2E-FS-02_cadastroFlow_transcricao/prompt_reparo_iter1.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `iter1_resposta.md` (9097 caracteres).

`````markdown
**Classificação: (A) — o teste presume um comportamento que não é o especificado.**

 A falha acontece **antes de o teste ser executado**, durante a compilação. O arquivo usa `TextFormField`, `DropdownButtonFormField` e `Switch`, mas não importou `package:flutter/material.dart`. Portanto, não há evidência de comportamento incorreto da aplicação.

 Além disso, o helper `preencherCampo()` que eu havia incluído era desnecessário e não funcionaria como pretendido: `widgetWithText(TextFormField, label)` procura um `TextFormField` que tenha o texto do label como descendente, mas nessa tela os labels são `Text` separados.

 Eu corrigiria o teste removendo esse helper e adicionando o import de Material. Também há um ponto importante no preenchimento do CEP: como o `onChanged` dispara uma chamada real ao ViaCEP, é melhor **não depender do resultado dessa chamada** e preencher os campos de endereço depois dela.

 Segue o arquivo corrigido:

 cadastro\_fs\_test.dart

```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> esperar(
    WidgetTester tester,
    Finder finder, {
    int tentativas = 40,
  }) async {
    for (var i = 0; i < tentativas; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu após esperar: $finder');
  }

  testWidgets(
    'cadastro completo: cria usuário, salva gêneros favoritos e abre tela inicial',
    (tester) async {
      // Usuário único para evitar conflito com execuções anteriores.
      final identificador = DateTime.now().millisecondsSinceEpoch;
      final email = 'e2e-$identificador@sintonize.test';
      const senha = 'senha123';

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // ==============================================================
      // Tela inicial
      // ==============================================================

      expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Cadastro'), findsOneWidget);

      await tester.tap(find.text('Cadastro'));
      await tester.pumpAndSettle();

      // ==============================================================
      // CadastroScreen
      // ==============================================================

      expect(find.text('Cadastrar'), findsOneWidget);

      final campos = find.byType(TextFormField);

      // CadastroScreen possui exatamente estes 10 TextFormFields:
      //
      // 0 - Nome
      // 1 - Data de Nascimento
      // 2 - E-mail
      // 3 - Senha
      // 4 - Confirmar Senha
      // 5 - CEP
      // 6 - Rua
      // 7 - Número
      // 8 - Bairro
      // 9 - Cidade
      expect(campos, findsNWidgets(10));

      await tester.enterText(
        campos.at(0),
        'Usuário E2E',
      );

      await tester.enterText(
        campos.at(1),
        '01/01/2000',
      );

      await tester.enterText(
        campos.at(2),
        email,
      );

      await tester.enterText(
        campos.at(3),
        senha,
      );

      await tester.enterText(
        campos.at(4),
        senha,
      );

      // O formatter transforma 01001000 em 01001-000.
      await tester.enterText(
        campos.at(5),
        '01001000',
      );

      // O preenchimento do CEP dispara uma requisição ao ViaCEP.
      // Não dependemos do resultado dela para o teste.
      await tester.pump(const Duration(seconds: 1));

      // Garantimos explicitamente os dados que serão persistidos.
      await tester.enterText(
        campos.at(6),
        'Praça da Sé',
      );

      await tester.enterText(
        campos.at(7),
        '100',
      );

      await tester.enterText(
        campos.at(8),
        'Sé',
      );

      await tester.enterText(
        campos.at(9),
        'São Paulo',
      );

      // Estado.
      await tester.tap(
        find.byType(DropdownButtonFormField<String>),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('SP').last);
      await tester.pumpAndSettle();

      // O botão pode estar fora da área atualmente visível.
      await tester.ensureVisible(find.text('Cadastrar'));
      await tester.tap(find.text('Cadastrar'));

      // ==============================================================
      // GenerosCadastroScreen
      // ==============================================================

      await esperar(
        tester,
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
      );

      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );

      expect(find.text('Rock'), findsOneWidget);
      expect(find.text('Pop'), findsOneWidget);
      expect(find.text('Jazz'), findsOneWidget);
      expect(find.text('Blues'), findsOneWidget);
      expect(find.text('Hip-Hop'), findsOneWidget);
      expect(find.text('Reggae'), findsOneWidget);
      expect(find.text('Country'), findsOneWidget);
      expect(find.text('Confirmar'), findsOneWidget);

      // Existem sete Switches, um para cada gênero.
      final switches = find.byType(Switch);

      expect(switches, findsNWidgets(7));

      // Rock.
      await tester.tap(switches.at(0));
      await tester.pump();

      // Pop.
      await tester.tap(switches.at(1));
      await tester.pump();

      // Confirmar deve salvar os gêneros e navegar para a TelaInicialScreen.
      await tester.tap(find.text('Confirmar'));

      // ==============================================================
      // TelaInicialScreen
      // ==============================================================

      await esperar(
        tester,
        find.text('essa é a nossa recomendação de música para você!'),
      );

      expect(
        find.text('essa é a nossa recomendação de música para você!'),
        findsOneWidget,
      );

      // ==============================================================
      // Verificação no Firestore Emulator
      // ==============================================================

      // A conta foi criada pelo fluxo real da aplicação.
      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);
      expect(user!.email, email);

      // O documento também deve ter sido criado e atualizado pelo fluxo.
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(snapshot.exists, isTrue);

      final data = snapshot.data()!;

      // Dados criados durante o cadastro.
      expect(data['nome'], 'Usuário E2E');
      expect(data['data_nasc'], '01/01/2000');
      expect(data['email'], email);

      final endereco = data['endereco'] as Map<String, dynamic>;

      expect(endereco['rua'], 'Praça da Sé');
      expect(endereco['numero'], '100');
      expect(endereco['bairro'], 'Sé');
      expect(endereco['cidade'], 'São Paulo');
      expect(endereco['estado'], 'SP');
      expect(endereco['cep'], '01001-000');

      // Dados adicionados pela GenerosCadastroScreen.
      expect(data['generos_favoritos'], isA<List>());

      final generosFavoritos =
          List<String>.from(data['generos_favoritos'] as List);

      expect(
        generosFavoritos,
        containsAll(<String>['Rock', 'Pop']),
      );

      expect(generosFavoritos, hasLength(2));
    },
  );
}
```

 ### O que foi corrigido

 - Adicionado `import 'package:flutter/material.dart';`, que resolve os quatro símbolos desconhecidos (`TextFormField`, `DropdownButtonFormField` e `Switch`).
- Removido o `preencherCampo()`, que não correspondia à estrutura real do `CadastroScreen`.
- Mantida a validação dos **10 `TextFormField`s** na ordem em que a tela os cria.
- Mantida a seleção de `SP`.
- Mantida a criação de um usuário novo via **Firebase Auth real**.
- Mantida a verificação do documento real no **Firestore Emulator**.
- Mantida a asserção de que `generos_favoritos` contém exatamente `Rock` e `Pop`.
- Mantida a verificação de que o fluxo termina na `TelaInicialScreen`.

 Há ainda uma questão que pode aparecer **depois dessa correção**, em tempo de execução: `CadastroScreen` e `GenerosCadastroScreen` recebem `auth`/`firestore` opcionais, mas, quando o fluxo parte de `MyApp`, eles usam as instâncias singleton. Isso é exatamente o que queremos neste E2E, pois o `setupFirebaseEmulators()` configura essas instâncias para os emuladores.

 Se o próximo erro ocorrer durante a execução, ele será mais informativo, porque esta falha atual é exclusivamente de compilação do teste.
`````

- **★ Autoclassificação do modelo:** **(A)** — falta `material.dart`; também descarta o helper `preencherCampo()` ("não funcionaria como pretendido").
- **Opção aplicada:** arquivo completo ("Segue o arquivo corrigido"), substituição integral.
- **Resultado após correção:** **0/1 — Falhou**: "Não apareceu após esperar: ... SELECIONE OS GÊNEROS..."; toques no dropdown e em "SP" fora do alvo.

### Iteração 2

- **Motivo da falha:** 0/1; tela de gêneros não aparece; toques fora do alvo.
- **Prompt de reparo enviado:** template fixo + saída literal da iteração anterior (11.108 caracteres) — `FASE3-E2E-FS-02_cadastroFlow_transcricao/prompt_reparo_iter2.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `iter2_resposta.md` (10199 caracteres).

`````markdown
**Classificação: (A) — o teste presume um comportamento que não é o especificado.**

 O erro indica que o problema está no **próprio teste ao interagir com widgets que estão fora da área visível**. O log é explícito:

 - `DropdownButtonFormField` está em `Offset(205.7, 801.0)`, fora da área útil do emulador.
- O teste chama `tap()` diretamente sem antes tornar o dropdown visível.
- Em consequência, a seleção de `SP` também não acontece.
- O `Cadastrar` portanto não consegue concluir corretamente o fluxo, e a `GenerosCadastroScreen` nunca aparece.

 Isso **não caracteriza, neste momento, um problema da aplicação**. A aplicação especifica corretamente um `SingleChildScrollView`, então o teste precisa rolar a tela antes de interagir com controles inferiores.

 Também vou corrigir a estratégia para não depender de coordenadas implícitas: antes de tocar no dropdown e no botão, o teste usa `ensureVisible()`.

 Abaixo está a versão revisada completa.

 cadastro\_fs\_test.dart

```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> esperar(
    WidgetTester tester,
    Finder finder, {
    int tentativas = 40,
  }) async {
    for (var i = 0; i < tentativas; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu após esperar: $finder');
  }

  testWidgets(
    'cadastro completo: cria usuário, salva gêneros favoritos e abre tela inicial',
    (tester) async {
      final identificador = DateTime.now().millisecondsSinceEpoch;
      final email = 'e2e-$identificador@sintonize.test';
      const senha = 'senha123';

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // ==============================================================
      // Tela inicial
      // ==============================================================

      expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Cadastro'), findsOneWidget);

      await tester.tap(find.text('Cadastro'));
      await tester.pumpAndSettle();

      // ==============================================================
      // CadastroScreen
      // ==============================================================

      expect(find.text('Cadastrar'), findsOneWidget);

      final campos = find.byType(TextFormField);

      expect(campos, findsNWidgets(10));

      // 0 - Nome
      await tester.enterText(
        campos.at(0),
        'Usuário E2E',
      );

      // 1 - Data de nascimento
      await tester.enterText(
        campos.at(1),
        '01/01/2000',
      );

      // 2 - E-mail
      await tester.enterText(
        campos.at(2),
        email,
      );

      // 3 - Senha
      await tester.enterText(
        campos.at(3),
        senha,
      );

      // 4 - Confirmar senha
      await tester.enterText(
        campos.at(4),
        senha,
      );

      // 5 - CEP
      //
      // O formatter transforma 01001000 em 01001-000.
      await tester.enterText(
        campos.at(5),
        '01001000',
      );

      // O CEP dispara uma requisição ao ViaCEP.
      // Aguardamos um pouco para permitir que ela termine, mas não
      // dependemos do resultado para o teste.
      await tester.pump(const Duration(seconds: 1));

      // 6 - Rua
      await tester.enterText(
        campos.at(6),
        'Praça da Sé',
      );

      // 7 - Número
      await tester.enterText(
        campos.at(7),
        '100',
      );

      // 8 - Bairro
      await tester.enterText(
        campos.at(8),
        'Sé',
      );

      // 9 - Cidade
      await tester.enterText(
        campos.at(9),
        'São Paulo',
      );

      // ==============================================================
      // Estado
      // ==============================================================

      final estadoDropdown =
          find.byType(DropdownButtonFormField<String>);

      expect(estadoDropdown, findsOneWidget);

      // O dropdown está inicialmente abaixo da área visível.
      // Fazemos o scroll necessário antes do tap.
      await tester.ensureVisible(estadoDropdown);
      await tester.pumpAndSettle();

      await tester.tap(
        estadoDropdown,
        warnIfMissed: true,
      );
      await tester.pumpAndSettle();

      // O menu do DropdownButton é exibido em uma rota/popup.
      // Nesse momento "SP" deve ser uma das opções.
      final opcaoSP = find.text('SP');

      expect(opcaoSP, findsWidgets);

      await tester.tap(opcaoSP.last);
      await tester.pumpAndSettle();

      // ==============================================================
      // Cadastrar
      // ==============================================================

      final botaoCadastrar = find.text('Cadastrar');

      expect(botaoCadastrar, findsOneWidget);

      // O botão está na parte inferior do SingleChildScrollView.
      await tester.ensureVisible(botaoCadastrar);
      await tester.pumpAndSettle();

      await tester.tap(botaoCadastrar);
      await tester.pump();

      // O submit é assíncrono:
      //
      // 1. createUserWithEmailAndPassword()
      // 2. usuarios/{uid}.set(...)
      // 3. navegação para GenerosCadastroScreen
      //
      // Portanto não usamos apenas pumpAndSettle() aqui como condição
      // de conclusão; esperamos explicitamente a próxima tela.
      await esperar(
        tester,
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
      );

      // ==============================================================
      // GenerosCadastroScreen
      // ==============================================================

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsOneWidget,
      );

      expect(find.text('Rock'), findsOneWidget);
      expect(find.text('Pop'), findsOneWidget);
      expect(find.text('Jazz'), findsOneWidget);
      expect(find.text('Blues'), findsOneWidget);
      expect(find.text('Hip-Hop'), findsOneWidget);
      expect(find.text('Reggae'), findsOneWidget);
      expect(find.text('Country'), findsOneWidget);
      expect(find.text('Confirmar'), findsOneWidget);

      final switches = find.byType(Switch);

      expect(switches, findsNWidgets(7));

      // Índices correspondem à lista:
      // 0 Rock
      // 1 Pop
      // 2 Jazz
      // 3 Blues
      // 4 Hip-Hop
      // 5 Reggae
      // 6 Country

      await tester.tap(switches.at(0));
      await tester.pump();

      await tester.tap(switches.at(1));
      await tester.pump();

      // ==============================================================
      // Confirmar
      // ==============================================================

      final botaoConfirmar = find.text('Confirmar');

      expect(botaoConfirmar, findsOneWidget);

      await tester.ensureVisible(botaoConfirmar);
      await tester.pumpAndSettle();

      await tester.tap(botaoConfirmar);

      // _salvarGeneros() faz:
      //
      // usuarios/{uid}.update({
      //   'generos_favoritos': ['Rock', 'Pop']
      // });
      //
      // e depois navega para TelaInicialScreen.
      await esperar(
        tester,
        find.text(
          'essa é a nossa recomendação de música para você!',
        ),
      );

      // ==============================================================
      // TelaInicialScreen
      // ==============================================================

      expect(
        find.text(
          'essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // ==============================================================
      // Verificação no Firebase Auth Emulator
      // ==============================================================

      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);
      expect(user!.email, email);

      // ==============================================================
      // Verificação no Firestore Emulator
      // ==============================================================

      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(snapshot.exists, isTrue);

      final data = snapshot.data()!;

      // Dados criados pelo CadastroScreen.
      expect(data['nome'], 'Usuário E2E');
      expect(data['data_nasc'], '01/01/2000');
      expect(data['email'], email);

      final endereco = data['endereco'] as Map<String, dynamic>;

      expect(endereco['rua'], 'Praça da Sé');
      expect(endereco['numero'], '100');
      expect(endereco['bairro'], 'Sé');
      expect(endereco['cidade'], 'São Paulo');
      expect(endereco['estado'], 'SP');
      expect(endereco['cep'], '01001-000');

      // Dados adicionados pela GenerosCadastroScreen.
      expect(data['generos_favoritos'], isA<List>());

      final generosFavoritos =
          List<String>.from(data['generos_favoritos'] as List);

      expect(
        generosFavoritos,
        containsAll(<String>['Rock', 'Pop']),
      );

      expect(generosFavoritos, hasLength(2));
    },
  );
}
```

 A diferença principal é que agora o teste **rola explicitamente até o dropdown e até o botão antes de tentar tocá-los**. Isso trata diretamente o warning que apareceu no log, em vez de silenciá-lo com `warnIfMissed: false`.

 Se a próxima execução avançar para `GenerosCadastroScreen` e falhar depois disso, aí teremos uma nova evidência sobre o comportamento real do aplicativo, especialmente na criação do documento ou na atualização de `generos_favoritos`.
`````

- **★ Autoclassificação do modelo:** **(A)** — "o problema está no próprio teste ao interagir com widgets que estão fora da área visível".
- **Opção aplicada:** arquivo completo ("versão revisada completa"), substituição integral; rolagem antes do dropdown e do botão.
- **Resultado após correção:** **0/1 — Falhou**: tela de gêneros ainda não aparece, agora sem aviso de toque.

### Iteração 3 (máximo)

- **Motivo da falha:** 0/1; tela de gêneros não aparece.
- **Prompt de reparo enviado:** template fixo + saída literal da iteração anterior (5.824 caracteres) — `FASE3-E2E-FS-02_cadastroFlow_transcricao/prompt_reparo_iter3.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `iter3_resposta.md` (9778 caracteres).

`````markdown
**Classificação: (A) — o teste presume um comportamento que não é o especificado.**

 Desta vez o problema está nos **dados que o teste forneceu ao formulário**, não na navegação da aplicação.

 O `CadastroScreen` tem esta validação para o nome:

```
final hasInvalidCharacters =
    RegExp(r'[^a-zA-ZÀ-ÿ\s]').hasMatch(value);

if (hasInvalidCharacters) {
  return 'O nome não pode conter números ou caracteres especiais';
}
```

 O teste estava preenchendo:

```
Usuário E2E
```

 Esse valor contém os caracteres `2`, portanto **o formulário é inválido**. Consequentemente, `_submit()` não entra no bloco que chama `createUserWithEmailAndPassword()`, e a aplicação permanece na `CadastroScreen`. Por isso a `GenerosCadastroScreen` nunca aparece.

 Isso explica também por que não houve exceção do Firebase: **o Firebase Auth nem chegou a ser chamado**.

 A correção é usar um nome válido, por exemplo `Usuário Teste`, e ajustar a asserção correspondente no Firestore.

 cadastro\_fs\_test.dart

```
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> esperar(
    WidgetTester tester,
    Finder finder, {
    int tentativas = 40,
  }) async {
    for (var i = 0; i < tentativas; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu após esperar: $finder');
  }

  testWidgets(
    'cadastro completo: cria usuário, salva gêneros favoritos e abre tela inicial',
    (tester) async {
      final identificador = DateTime.now().millisecondsSinceEpoch;
      final email = 'e2e-$identificador@sintonize.test';
      const senha = 'senha123';
      const nome = 'Usuário Teste';

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // ==============================================================
      // Tela inicial
      // ==============================================================

      expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Cadastro'), findsOneWidget);

      await tester.tap(find.text('Cadastro'));
      await tester.pumpAndSettle();

      // ==============================================================
      // CadastroScreen
      // ==============================================================

      expect(find.text('Cadastrar'), findsOneWidget);

      final campos = find.byType(TextFormField);

      // Ordem definida pela implementação de CadastroScreen:
      //
      // 0 - Nome
      // 1 - Data de Nascimento
      // 2 - E-mail
      // 3 - Senha
      // 4 - Confirmar Senha
      // 5 - CEP
      // 6 - Rua
      // 7 - Número
      // 8 - Bairro
      // 9 - Cidade

      expect(campos, findsNWidgets(10));

      await tester.enterText(
        campos.at(0),
        nome,
      );

      await tester.enterText(
        campos.at(1),
        '01/01/2000',
      );

      await tester.enterText(
        campos.at(2),
        email,
      );

      await tester.enterText(
        campos.at(3),
        senha,
      );

      await tester.enterText(
        campos.at(4),
        senha,
      );

      // O formatter transforma 01001000 em 01001-000.
      await tester.enterText(
        campos.at(5),
        '01001000',
      );

      // O CEP dispara uma consulta ao ViaCEP. O resultado dessa
      // consulta não é usado como condição para o cadastro.
      await tester.pump(const Duration(seconds: 1));

      await tester.enterText(
        campos.at(6),
        'Praça da Sé',
      );

      await tester.enterText(
        campos.at(7),
        '100',
      );

      await tester.enterText(
        campos.at(8),
        'Sé',
      );

      await tester.enterText(
        campos.at(9),
        'São Paulo',
      );

      // ==============================================================
      // Estado
      // ==============================================================

      final estadoDropdown =
          find.byType(DropdownButtonFormField<String>);

      expect(estadoDropdown, findsOneWidget);

      await tester.ensureVisible(estadoDropdown);
      await tester.pumpAndSettle();

      await tester.tap(estadoDropdown);
      await tester.pumpAndSettle();

      final opcaoSP = find.text('SP');

      expect(opcaoSP, findsWidgets);

      await tester.tap(opcaoSP.last);
      await tester.pumpAndSettle();

      // ==============================================================
      // Cadastro
      // ==============================================================

      final botaoCadastrar = find.text('Cadastrar');

      expect(botaoCadastrar, findsOneWidget);

      await tester.ensureVisible(botaoCadastrar);
      await tester.pumpAndSettle();

      await tester.tap(botaoCadastrar);

      // O fluxo esperado é:
      //
      // CadastroScreen
      //   -> Firebase Auth: createUserWithEmailAndPassword
      //   -> Firestore: usuarios/{uid}.set(...)
      //   -> GenerosCadastroScreen

      await esperar(
        tester,
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
      );

      // ==============================================================
      // GenerosCadastroScreen
      // ==============================================================

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsOneWidget,
      );

      expect(find.text('Rock'), findsOneWidget);
      expect(find.text('Pop'), findsOneWidget);
      expect(find.text('Jazz'), findsOneWidget);
      expect(find.text('Blues'), findsOneWidget);
      expect(find.text('Hip-Hop'), findsOneWidget);
      expect(find.text('Reggae'), findsOneWidget);
      expect(find.text('Country'), findsOneWidget);
      expect(find.text('Confirmar'), findsOneWidget);

      final switches = find.byType(Switch);

      expect(switches, findsNWidgets(7));

      // Lista da aplicação:
      // 0 - Rock
      // 1 - Pop
      // 2 - Jazz
      // 3 - Blues
      // 4 - Hip-Hop
      // 5 - Reggae
      // 6 - Country

      await tester.tap(switches.at(0));
      await tester.pump();

      await tester.tap(switches.at(1));
      await tester.pump();

      // ==============================================================
      // Confirmar
      // ==============================================================

      final botaoConfirmar = find.text('Confirmar');

      expect(botaoConfirmar, findsOneWidget);

      await tester.ensureVisible(botaoConfirmar);
      await tester.pumpAndSettle();

      await tester.tap(botaoConfirmar);

      // Confirmar deve atualizar o documento e navegar para
      // TelaInicialScreen.
      await esperar(
        tester,
        find.text(
          'essa é a nossa recomendação de música para você!',
        ),
      );

      // ==============================================================
      // TelaInicialScreen
      // ==============================================================

      expect(
        find.text(
          'essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // ==============================================================
      // Firebase Auth Emulator
      // ==============================================================

      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);
      expect(user!.email, email);

      // ==============================================================
      // Firestore Emulator
      // ==============================================================

      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(snapshot.exists, isTrue);

      final data = snapshot.data()!;

      // Dados criados pelo CadastroScreen.
      expect(data['nome'], nome);
      expect(data['data_nasc'], '01/01/2000');
      expect(data['email'], email);

      final endereco = data['endereco'] as Map<String, dynamic>;

      expect(endereco['rua'], 'Praça da Sé');
      expect(endereco['numero'], '100');
      expect(endereco['bairro'], 'Sé');
      expect(endereco['cidade'], 'São Paulo');
      expect(endereco['estado'], 'SP');
      expect(endereco['cep'], '01001-000');

      // Dados adicionados posteriormente pela
      // GenerosCadastroScreen.
      expect(data['generos_favoritos'], isA<List>());

      final generosFavoritos =
          List<String>.from(data['generos_favoritos'] as List);

      expect(
        generosFavoritos,
        containsAll(<String>['Rock', 'Pop']),
      );

      expect(generosFavoritos, hasLength(2));
    },
  );
}
```

 ### O ponto que causou a falha

 O teste anterior tinha:

```
const nome = 'Usuário E2E';
```

 mas a própria aplicação exige que o nome contenha **somente letras e espaços**. Portanto:

```
Usuário Teste  ✅
Usuário E2E    ❌
```

 O restante do fluxo não deve ser enfraquecido: continuamos verificando tanto a navegação para gêneros quanto a persistência final no Firestore.

 Um detalhe adicional: o e-mail continua contendo números (`e2e-...`), mas isso é permitido pelo `_validateEmail`; a restrição de caracteres especiais é aplicada **somente ao campo Nome**.
`````

- **★ Autoclassificação do modelo:** **(A)** — "Desta vez o problema está nos **dados que o teste forneceu ao formulário**": cita a regex do validador de nome e "Usuário E2E" contém `2`; "o Firebase Auth nem chegou a ser chamado".
- **Opção aplicada:** arquivo completo, substituição integral; nome `'Usuário Teste'` e asserção `data['nome'] == nome`.
- **Resultado após correção:** **0/1 — Falhou**: `Found 0 widgets with text "Reggae"` na tela de gêneros. `FASE3-E2E-FS-02_cadastroFlow_iter3_final.txt`.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A), (A), (A). |
| **★ Classificação humana (auditoria)** | **Erro de geração** (import) e **Erro de teste** nas três iterações (toques fora da área visível; nome inválido; item de lista preguiçosa ainda não construído). Nenhum defeito do app. |
| **★ Concordância** | **Sim** nas três. O diagnóstico da iteração 3 é exato (validador, regex, dígito): o modelo usou o código do app fornecido no prompt para explicar uma falha do próprio teste. |
| **★ Observações** | 1) Mesmo nome com dígito ("Usuário E2E") da C3-ZS, escolhido de forma independente em outra conversa e outra estratégia. 2) O reparo 3 não pôde ser testado além da tela de gêneros: a correção nova expôs o próximo erro (lista preguiçosa). 3) Sem fontes externas nas respostas. |

---

## Codificação manual-first

Não se aplica — rodada limpa.
