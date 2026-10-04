# FASE3-C3-FS — ChatGPT (com bug C3)

Rodada 17 do plano (bloco 2 — FS, ChatGPT, bug C3). 2026-10-04 (01:37–01:58), segunda máquina, automação, autor ausente.

**Resultado em uma linha:** 1 teste; **não compila na geração** (sem `material.dart`); reparo 1 **(A)** → 0/1 (toques fora do alvo); reparo 2 **(A)** com rolagem → 0/1; reparo 3 **(B)** sem código → **0/1 final**. O teste nunca passa do formulário: o nome é "Usuário E2E" (dígito), recusado pelo validador — a mesma causa da C3-ZS e da FS-02. **Codificação manual-first: Não viu.** O teste tinha a asserção que capturaria o C3 (`data['nome']`, linha 337), nunca alcançada.

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-C3-FS (com bug C3) |
| **Modelo** | ChatGPT |
| **Fluxo alvo** | cadastro — boas-vindas → `CadastroScreen` → `GenerosCadastroScreen` → `TelaInicialScreen` |
| **Estado do `lib/`** | **com bug C3** — `20edaaa` (`cadastro.dart:149`) |
| **Worktree usado** | `C:\Users\Marcos\Desktop\sintonize-fase3-C3`, detached em `20edaaa` |
| **Nível da pirâmide** | E2E (integration_test no AVD, emuladores Firebase) |
| **Estratégia de prompt** | Few-shot |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/few-shot/FASE3-E2E-FS-02_cadastroFlow.md` — sha256 `0a48e913d051c4d623495ed73a435ab697b31a56371caae2cb0062143ff1aac2`, igual a `_sha256.txt` |
| **✦ Modelo declarado pelo LLM** | "GPT-5.6 Luna" — 2026-10-04, 00:17. Não repetido: dispensa do autor. |
| **✦ Verificação externa da versão** | Última consulta: Help Center, 2026-10-03. Dispensada pelo autor em 2026-10-04. |
| **Sessão** | ChatGPT deslogada ("Entrar" e "Cadastre-se grátis" visíveis) |
| **Consultou fontes externas?** | Não — nenhum marcador de citação nas respostas |
| **Data de acesso** | 2026-10-04 |
| **Conversa nova?** | Sim — `https://chatgpt.com/uc/6ac1d7fc-bae4-83ea-9ad4-2250c729be6f` (1ª tentativa) |
| **Envio** | Automatizado (Claude in Chrome), autor ausente; editor conferido por DOM antes de cada envio; respostas pelo botão "Copiar resposta". |
| **Versão do Flutter** | 3.41.6 · Dart 3.11.4 |
| **AVD** | `tcc_e2e` (Pixel 6, API 34), `emulator-5554` |
| **firebase-tools** | 15.31.0 |

---

## Procedimento operacional (executado)

- [x] Worktree C3 (`20edaaa`) conferido antes de cada execução.
- [x] Prompt colado sem alteração (52.384 caracteres; o mesmo da FS-02).
- [x] **Montagem na geração:** a resposta traz dois arquivos completos; depois do primeiro o modelo diz "esta é a versão que eu recomendo efetivamente usar" e dá o segundo ("Versão recomendada"). O executado é o segundo (`teste_iter0_geracao.dart`); o primeiro está em `teste_iter0_bloco1.dart`. Reparos 1 e 2: arquivo completo, substituição integral.
- [x] Antes de cada uma das 4 execuções: emuladores reiniciados, seed, conferência por REST.
- [x] Saídas `resultados/chatgpt/FASE3-C3-FS_iter{0,1,2}.txt` e `_iter3_final.txt`; prints `evidencias/chatgpt/FASE3-C3-FS_iter{0..3}.png`.
- [x] Teste final em `integration_test/fase3/chatgpt/c3_fs_test.dart` (sha256 `7f06998d1bd0a908…`); geração (versão recomendada) sha256 `e5adb17d80e6a538…`.

---

## Prompt Enviado

Texto entre o 2º e o 3º `---` de `fase3-e2e/prompts_prontos/few-shot/FASE3-E2E-FS-02_cadastroFlow.md`, sem alteração (52.384 caracteres). Arquivo e sha256 são o registro.

---

## Resposta do LLM

`FASE3-C3-FS_transcricao/iter0_resposta.md` (13608 caracteres, botão "Copiar resposta").

`````markdown
Abaixo está um teste E2E completo para `integration_test/fase3/cadastro_generos_test.dart`. Ele usa o app real, os emuladores Firebase e verifica também diretamente no Firestore que os gêneros foram persistidos no documento criado pelo fluxo.

 integration\_test/fase3/cadastro\_generos\_test.dart

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

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu: $finder');
  }

  Future<void> preencherCadastro(WidgetTester tester) async {
    final campos = find.byType(TextFormField);

    // Os TextFormField aparecem na seguinte ordem:
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
      'e2e-${DateTime.now().millisecondsSinceEpoch}@sintonize.test',
    );

    await tester.enterText(
      campos.at(3),
      'senha123',
    );

    await tester.enterText(
      campos.at(4),
      'senha123',
    );

    // O CEP é válido no formato esperado pelo formulário.
    // O preenchimento pode disparar uma consulta ao ViaCEP, portanto
    // aguardamos a aplicação antes de preencher os campos restantes.
    await tester.enterText(
      campos.at(5),
      '01001-000',
    );

    await tester.pump(const Duration(seconds: 2));

    // Preenche manualmente os campos de endereço para que o teste
    // não dependa do serviço externo do ViaCEP.
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

    // Seleciona um estado.
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SP').last);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'cadastro: cria usuário, salva documento, seleciona gêneros e persiste no Firestore',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Confirma que estamos na tela inicial.
      expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
      expect(find.text('Cadastro'), findsOneWidget);

      // Abre o fluxo de cadastro.
      await tester.tap(find.text('Cadastro'));
      await tester.pumpAndSettle();

      // Confirma que a CadastroScreen foi aberta.
      expect(find.text('Cadastrar'), findsOneWidget);

      // Preenche todos os campos necessários.
      await preencherCadastro(tester);

      // Guarda o e-mail utilizado para localizar o usuário criado no Auth.
      final email =
          'e2e-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      // O helper acima usa um timestamp próprio para o e-mail, portanto
      // precisamos preencher novamente o campo de e-mail com o valor que
      // vamos consultar posteriormente.
      final campos = find.byType(TextFormField);

      await tester.enterText(
        campos.at(2),
        email,
      );

      // Cria a conta.
      await tester.tap(find.text('Cadastrar'));

      // O cadastro cria o usuário no Firebase Auth, cria o documento
      // usuarios/{uid} e então navega para a tela de gêneros.
      await esperar(
        tester,
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
      );

      expect(
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
        findsOneWidget,
      );
      expect(find.text('Confirmar'), findsOneWidget);

      // Localiza os switches pelos cards/textos dos gêneros.
      final rock = find.ancestor(
        of: find.text('Rock'),
        matching: find.byType(Card),
      );

      final pop = find.ancestor(
        of: find.text('Pop'),
        matching: find.byType(Card),
      );

      // Cada card possui um único Switch.
      await tester.tap(find.descendant(
        of: rock,
        matching: find.byType(Switch),
      ));

      await tester.tap(find.descendant(
        of: pop,
        matching: find.byType(Switch),
      ));

      await tester.pumpAndSettle();

      // Confirma os gêneros.
      await tester.tap(find.text('Confirmar'));

      // O fluxo deve chegar à tela inicial.
      await esperar(
        tester,
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
      );

      expect(
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // Verificação E2E adicional:
      // consulta o Auth real e o Firestore Emulator para garantir que
      // o resultado persistido corresponde ao que foi selecionado pela UI.
      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);
      expect(user!.email, email);

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(doc.exists, isTrue);

      final data = doc.data()!;

      expect(data['nome'], 'Usuário E2E');
      expect(data['email'], email);

      expect(
        data['generos_favoritos'],
        containsAll(<String>[
          'Rock',
          'Pop',
        ]),
      );

      expect(
        (data['generos_favoritos'] as List).length,
        2,
      );
    },
  );
}
```

 Há, porém, um detalhe importante no código acima: como o e-mail precisa ser reutilizado para validar o usuário criado, é melhor gerar o e-mail **uma única vez antes de preencher o formulário**. Portanto, esta é a versão que eu recomendo efetivamente salvar no projeto:

 Versão recomendada — cadastro\_generos\_test.dart

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

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu: $finder');
  }

  testWidgets(
    'cadastro: cria conta, seleciona gêneros e salva no Firestore',
    (tester) async {
      final email =
          'e2e-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);

      // ---------------------------------------------------------------
      // 1. Abre CadastroScreen
      // ---------------------------------------------------------------

      await tester.tap(find.text('Cadastro'));
      await tester.pumpAndSettle();

      expect(find.text('Cadastrar'), findsOneWidget);

      // ---------------------------------------------------------------
      // 2. Preenche o formulário de cadastro
      // ---------------------------------------------------------------

      final campos = find.byType(TextFormField);

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
        'senha123',
      );

      await tester.enterText(
        campos.at(4),
        'senha123',
      );

      // CEP válido para passar na validação.
      // O teste não depende do retorno do ViaCEP para a persistência:
      // os campos de endereço são preenchidos explicitamente.
      await tester.enterText(
        campos.at(5),
        '01001-000',
      );

      await tester.pump(const Duration(seconds: 2));

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

      // Seleciona SP no DropdownButtonFormField.
      await tester.tap(
        find.byType(DropdownButtonFormField<String>),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('SP').last);
      await tester.pumpAndSettle();

      // ---------------------------------------------------------------
      // 3. Cria a conta pelo Firebase Auth e o documento no Firestore
      // ---------------------------------------------------------------

      await tester.tap(find.text('Cadastrar'));

      // A navegação só ocorre depois que Auth + Firestore terminam.
      await esperar(
        tester,
        find.text('SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA'),
      );

      expect(find.text('Confirmar'), findsOneWidget);

      // ---------------------------------------------------------------
      // 4. Seleciona Rock e Pop
      // ---------------------------------------------------------------

      final rockCard = find.ancestor(
        of: find.text('Rock'),
        matching: find.byType(Card),
      );

      final popCard = find.ancestor(
        of: find.text('Pop'),
        matching: find.byType(Card),
      );

      await tester.tap(
        find.descendant(
          of: rockCard,
          matching: find.byType(Switch),
        ),
      );

      await tester.tap(
        find.descendant(
          of: popCard,
          matching: find.byType(Switch),
        ),
      );

      await tester.pumpAndSettle();

      // ---------------------------------------------------------------
      // 5. Confirma os gêneros
      // ---------------------------------------------------------------

      await tester.tap(find.text('Confirmar'));

      // Confirmar chama update() no documento e depois navega.
      await esperar(
        tester,
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
      );

      // ---------------------------------------------------------------
      // 6. Verifica que o fluxo chegou à TelaInicialScreen
      // ---------------------------------------------------------------

      expect(
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // ---------------------------------------------------------------
      // 7. Verifica Auth e Firestore reais
      // ---------------------------------------------------------------

      final user = FirebaseAuth.instance.currentUser;

      expect(user, isNotNull);
      expect(user!.email, email);

      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(snapshot.exists, isTrue);

      final data = snapshot.data()!;

      // Documento criado durante o cadastro.
      expect(data['nome'], 'Usuário E2E');
      expect(data['email'], email);

      // Campo atualizado pela GenerosCadastroScreen.
      expect(
        data['generos_favoritos'],
        containsAll(<String>[
          'Rock',
          'Pop',
        ]),
      );

      expect(
        (data['generos_favoritos'] as List).length,
        2,
      );
    },
  );
}
```

 ### Observação importante sobre o teste

 O teste acima valida uma propriedade importante do E2E: **não basta verificar que a tela mudou**. Depois de clicar em `Confirmar`, ele consulta o Firebase Emulator usando o `uid` do usuário realmente criado pelo formulário e confirma que `generos_favoritos` foi persistido como `['Rock', 'Pop']`.

 Há ainda um ponto específico do código fornecido: o cadastro chama o **ViaCEP real** quando o CEP chega a 9 caracteres. Isso introduz uma dependência externa no teste. A versão acima evita depender do resultado do ViaCEP para os dados necessários ao cadastro, sobrescrevendo Rua/Bairro/Cidade e selecionando Estado depois da consulta. Ainda assim, o `http.get()` é disparado. Para um E2E totalmente determinístico contra infraestrutura local, seria melhor que a aplicação permitisse injetar o serviço de CEP ou que o preenchimento automático não fosse acionado durante testes.

 Também não usei o usuário pré-populado `tester@sintonize.test`: conforme sua regra, o fluxo de cadastro precisa criar **um novo usuário pela própria interface**, então o e-mail recebe um timestamp para evitar conflito no Auth Emulator.
`````

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Não na geração; sim a partir do reparo 1 |
| **Testes gerados** | 1 — cadastro → gêneros → Firestore (afirma `data['nome']` e `generos_favoritos`) → saudação |
| **Testes passaram (iteração 0)** | 0 (não compilou) |
| **Testes falharam (iteração 0)** | — (`Undefined name` para `TextFormField`, `DropdownButtonFormField`, `Card`, `Switch`) |
| **Testes passaram (estado final)** | 0 |
| **Testes falharam (estado final)** | 1 — "Não apareceu: Found 0 widgets with text \"SELECIONE OS GÊNEROS...\"" |
| **Melhor estado intermediário** | = final |
| **Tempo por execução** | iter0 11 s; iter1–3: ~34 s (Gradle 12,3–13,0 s + 18–21 s de teste) |
| **Prints tirados** | 4 |

Iteração 1: toques no dropdown, em "SP" e em "Cadastrar" fora do alvo (`Offset(205.7, 801.0)`, `Offset(63.1, 617.9)`, `Offset(205.7, 686.9)`). Iterações 2 e final: sem avisos de toque; o formulário é enviado com Nome "Usuário E2E", o validador recusa (dígito) e a tela de gêneros não aparece.

### Saída do terminal (iteração 0)

`resultados/chatgpt/FASE3-C3-FS_iter0.txt`

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
00:00 +0: loading C:/Users/Marcos/Desktop/sintonize-fase3-C3/integration_test/fase3/c3_fs_test.dart
Running Gradle task 'assembleDebug'...                          
integration_test/fase3/c3_fs_test.dart:52:34: Error: Undefined name 'TextFormField'.
      final campos = find.byType(TextFormField);
                                 ^^^^^^^^^^^^^
integration_test/fase3/c3_fs_test.dart:111:21: Error: Undefined name 'DropdownButtonFormField'.
        find.byType(DropdownButtonFormField<String>),
                    ^^^^^^^^^^^^^^^^^^^^^^^
integration_test/fase3/c3_fs_test.dart:138:31: Error: Undefined name 'Card'.
        matching: find.byType(Card),
                              ^^^^
integration_test/fase3/c3_fs_test.dart:143:31: Error: Undefined name 'Card'.
        matching: find.byType(Card),
                              ^^^^
integration_test/fase3/c3_fs_test.dart:149:33: Error: Undefined name 'Switch'.
          matching: find.byType(Switch),
                                ^^^^^^
integration_test/fase3/c3_fs_test.dart:156:33: Error: Undefined name 'Switch'.
          matching: find.byType(Switch),
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

BUILD FAILED in 8s
Running Gradle task 'assembleDebug'...                              8,7s
00:00 +0 -1: loading C:/Users/Marcos/Desktop/sintonize-fase3-C3/integration_test/fase3/c3_fs_test.dart [E]
  Failed to load "C:/Users/Marcos/Desktop/sintonize-fase3-C3/integration_test/fase3/c3_fs_test.dart": Gradle task assembleDebug failed with exit code 1
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
- **Prompt de reparo enviado:** template fixo + saída literal da iteração anterior (6.835 caracteres) — `FASE3-C3-FS_transcricao/prompt_reparo_iter1.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `iter1_resposta.md` (9054 caracteres).

`````markdown
**Classificação: (A) o teste presume um comportamento que não é o especificado.**

 A falha ocorre **antes de o aplicativo ser executado no emulador**. O compilador não reconhece `TextFormField`, `DropdownButtonFormField`, `Card` e `Switch` porque o arquivo de teste não importou `package:flutter/material.dart`.

 Isso é um problema do teste, não da aplicação. Esses widgets fazem parte do Material do Flutter e são usados pelos `Finder`s do teste.

 Os avisos de versões de pacotes não são a causa da falha.

 ### Teste corrigido

 A correção mínima seria adicionar:

```
import 'package:flutter/material.dart';
```

 ao início do teste. Já aproveitei para manter o teste em uma única versão consistente, sem o preenchimento duplicado do e-mail da resposta anterior.

 integration\_test/fase3/c3\_fs\_test.dart

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

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu: $finder');
  }

  testWidgets(
    'cadastro: cria conta, seleciona gêneros e salva no Firestore',
    (tester) async {
      final email =
          'e2e-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      // -----------------------------------------------------------------
      // 1. Inicia o aplicativo real
      // -----------------------------------------------------------------

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(
        find.text('Bem-vindo ao Sintonize!'),
        findsOneWidget,
      );

      // -----------------------------------------------------------------
      // 2. Abre a tela de cadastro
      // -----------------------------------------------------------------

      await tester.tap(find.text('Cadastro'));
      await tester.pumpAndSettle();

      expect(
        find.text('Cadastrar'),
        findsOneWidget,
      );

      // -----------------------------------------------------------------
      // 3. Preenche o formulário
      // -----------------------------------------------------------------

      final campos = find.byType(TextFormField);

      // Nome
      await tester.enterText(
        campos.at(0),
        'Usuário E2E',
      );

      // Data de nascimento
      await tester.enterText(
        campos.at(1),
        '01/01/2000',
      );

      // E-mail
      await tester.enterText(
        campos.at(2),
        email,
      );

      // Senha
      await tester.enterText(
        campos.at(3),
        'senha123',
      );

      // Confirmar senha
      await tester.enterText(
        campos.at(4),
        'senha123',
      );

      // CEP
      await tester.enterText(
        campos.at(5),
        '01001-000',
      );

      // O CEP dispara uma consulta ao ViaCEP na aplicação.
      // Damos tempo para essa operação terminar antes de preencher
      // explicitamente os demais campos.
      await tester.pump(const Duration(seconds: 2));

      // Rua
      await tester.enterText(
        campos.at(6),
        'Praça da Sé',
      );

      // Número
      await tester.enterText(
        campos.at(7),
        '100',
      );

      // Bairro
      await tester.enterText(
        campos.at(8),
        'Sé',
      );

      // Cidade
      await tester.enterText(
        campos.at(9),
        'São Paulo',
      );

      // Estado
      await tester.tap(
        find.byType(DropdownButtonFormField<String>),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('SP').last);
      await tester.pumpAndSettle();

      // -----------------------------------------------------------------
      // 4. Cria a conta
      // -----------------------------------------------------------------

      await tester.tap(find.text('Cadastrar'));

      // O código da aplicação só navega para GenerosCadastroScreen
      // depois de concluir:
      //   - createUserWithEmailAndPassword()
      //   - usuarios/{uid}.set(...)
      await esperar(
        tester,
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
      );

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsOneWidget,
      );

      expect(
        find.text('Confirmar'),
        findsOneWidget,
      );

      // -----------------------------------------------------------------
      // 5. Seleciona Rock
      // -----------------------------------------------------------------

      final rockCard = find.ancestor(
        of: find.text('Rock'),
        matching: find.byType(Card),
      );

      expect(rockCard, findsOneWidget);

      final rockSwitch = find.descendant(
        of: rockCard,
        matching: find.byType(Switch),
      );

      expect(rockSwitch, findsOneWidget);

      await tester.tap(rockSwitch);

      // -----------------------------------------------------------------
      // 6. Seleciona Pop
      // -----------------------------------------------------------------

      final popCard = find.ancestor(
        of: find.text('Pop'),
        matching: find.byType(Card),
      );

      expect(popCard, findsOneWidget);

      final popSwitch = find.descendant(
        of: popCard,
        matching: find.byType(Switch),
      );

      expect(popSwitch, findsOneWidget);

      await tester.tap(popSwitch);

      await tester.pumpAndSettle();

      // -----------------------------------------------------------------
      // 7. Confirma os gêneros
      // -----------------------------------------------------------------

      await tester.tap(find.text('Confirmar'));

      // _salvarGeneros() faz update() no Firestore e só então
      // navega para TelaInicialScreen.
      await esperar(
        tester,
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
      );

      expect(
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // -----------------------------------------------------------------
      // 8. Verifica o Firebase Auth real
      // -----------------------------------------------------------------

      final user = FirebaseAuth.instance.currentUser;

      expect(
        user,
        isNotNull,
        reason: 'O cadastro deveria criar um usuário no Firebase Auth.',
      );

      expect(
        user!.email,
        email,
      );

      // -----------------------------------------------------------------
      // 9. Verifica o documento real no Firestore Emulator
      // -----------------------------------------------------------------

      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(
        snapshot.exists,
        isTrue,
        reason:
            'O cadastro deveria criar usuarios/{uid} no Firestore.',
      );

      final data = snapshot.data()!;

      // Dados criados pela CadastroScreen.
      expect(
        data['nome'],
        'Usuário E2E',
      );

      expect(
        data['email'],
        email,
      );

      // Dados adicionados pela GenerosCadastroScreen.
      expect(
        data['generos_favoritos'],
        containsAll(<String>[
          'Rock',
          'Pop',
        ]),
      );

      expect(
        (data['generos_favoritos'] as List).length,
        2,
        reason:
            'O teste selecionou exatamente dois gêneros: Rock e Pop.',
      );
    },
  );
}
```

 ### Por que essa versão resolve a falha

 O erro original:

```
Undefined name 'TextFormField'
Undefined name 'DropdownButtonFormField'
Undefined name 'Card'
Undefined name 'Switch'
```

 vem exatamente da ausência de:

```
import 'package:flutter/material.dart';
```

 Agora os símbolos usados pelos `Finder`s estão disponíveis.

 A estrutura do E2E continua a mesma:

 1. inicia `MyApp`;
2. abre **Cadastro**;
3. preenche o formulário;
4. cria uma conta **nova** no Auth Emulator;
5. verifica a navegação para `GenerosCadastroScreen`;
6. seleciona **Rock** e **Pop**;
7. toca em **Confirmar**;
8. verifica a navegação para `TelaInicialScreen`;
9. consulta o **Auth Emulator**;
10. consulta o **Firestore Emulator**;
11. confirma que `usuarios/{uid}.generos_favoritos` contém exatamente os dois gêneros selecionados.

 Portanto, não há redução de escopo para contornar a falha de compilação.
`````

- **★ Autoclassificação do modelo:** **(A)** — falta `material.dart`.
- **Opção aplicada:** arquivo completo, substituição integral.
- **Resultado após correção:** **0/1 — Falhou**: tela de gêneros não aparece; toques fora do alvo.

### Iteração 2

- **Motivo da falha:** 0/1; toques fora do alvo.
- **Prompt de reparo enviado:** template fixo + saída literal da iteração anterior (13.703 caracteres) — `FASE3-C3-FS_transcricao/prompt_reparo_iter2.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `iter2_resposta.md` (10358 caracteres).

`````markdown
**Classificação: (A) o teste presume um comportamento que não é o especificado.**

 O aplicativo chegou a ser compilado e instalado, portanto o problema anterior foi resolvido. A falha atual acontece porque o formulário da `CadastroScreen` está dentro de um `SingleChildScrollView`.

 O teste faz:

```
await tester.tap(find.byType(DropdownButtonFormField<String>));
```

 mas o dropdown está fora da área visível do emulador. O próprio Flutter informa:

 > `Maybe the widget is actually off-screen`

 O mesmo acontece depois com `SP` e `Cadastrar`. O `tap()` do `WidgetTester` **não deve ser tratado como um scroll automático até o widget**. O teste precisa tornar explicitamente o elemento visível antes de interagir com ele.

 Isso não indica um comportamento incorreto da aplicação: em um dispositivo real, o usuário pode rolar o formulário normalmente. Portanto, devemos corrigir o teste, sem enfraquecer nenhuma asserção.

 Há também uma melhoria importante: depois de selecionar o estado, devemos garantir que o botão `Cadastrar` esteja visível antes de tocá-lo.

 ### Versão corrigida

 integration\_test/fase3/c3\_fs\_test.dart

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

  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));

      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }

    fail('Não apareceu: $finder');
  }

  Future<void> tornarVisivel(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'cadastro: cria conta, seleciona gêneros e salva no Firestore',
    (tester) async {
      final email =
          'e2e-${DateTime.now().millisecondsSinceEpoch}@sintonize.test';

      // -----------------------------------------------------------------
      // 1. Inicia o aplicativo real
      // -----------------------------------------------------------------

      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(
        find.text('Bem-vindo ao Sintonize!'),
        findsOneWidget,
      );

      // -----------------------------------------------------------------
      // 2. Abre a tela de cadastro
      // -----------------------------------------------------------------

      await tester.tap(find.text('Cadastro'));
      await tester.pumpAndSettle();

      expect(
        find.text('Cadastrar'),
        findsOneWidget,
      );

      // -----------------------------------------------------------------
      // 3. Preenche o formulário
      // -----------------------------------------------------------------

      final campos = find.byType(TextFormField);

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
        'senha123',
      );

      await tester.enterText(
        campos.at(4),
        'senha123',
      );

      // CEP.
      await tester.enterText(
        campos.at(5),
        '01001-000',
      );

      // O CEP dispara uma consulta ao ViaCEP na implementação atual.
      // Damos tempo para ela terminar antes de preencher os campos
      // que podem ter sido preenchidos automaticamente.
      await tester.pump(const Duration(seconds: 2));

      // Sobrescreve os campos de endereço explicitamente para que os
      // dados persistidos pelo cadastro sejam determinados pelo teste.
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

      // -----------------------------------------------------------------
      // 4. Seleciona o estado
      // -----------------------------------------------------------------

      final estadoDropdown =
          find.byType(DropdownButtonFormField<String>);

      expect(
        estadoDropdown,
        findsOneWidget,
      );

      // O Dropdown está mais abaixo no SingleChildScrollView.
      await tornarVisivel(
        tester,
        estadoDropdown,
      );

      await tester.tap(estadoDropdown);
      await tester.pumpAndSettle();

      // A lista do Dropdown foi aberta. Selecionamos SP.
      final opcaoSp = find.text('SP').last;

      expect(
        opcaoSp,
        findsOneWidget,
      );

      await tester.tap(opcaoSp);
      await tester.pumpAndSettle();

      // -----------------------------------------------------------------
      // 5. Torna o botão Cadastrar visível e cria a conta
      // -----------------------------------------------------------------

      final botaoCadastrar = find.text('Cadastrar');

      expect(
        botaoCadastrar,
        findsOneWidget,
      );

      await tornarVisivel(
        tester,
        botaoCadastrar,
      );

      await tester.tap(botaoCadastrar);

      // A aplicação só navega depois de:
      //   1. createUserWithEmailAndPassword()
      //   2. usuarios/{uid}.set(...)
      await esperar(
        tester,
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
      );

      expect(
        find.text(
          'SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA',
        ),
        findsOneWidget,
      );

      expect(
        find.text('Confirmar'),
        findsOneWidget,
      );

      // -----------------------------------------------------------------
      // 6. Seleciona Rock
      // -----------------------------------------------------------------

      final rockCard = find.ancestor(
        of: find.text('Rock'),
        matching: find.byType(Card),
      );

      expect(
        rockCard,
        findsOneWidget,
      );

      final rockSwitch = find.descendant(
        of: rockCard,
        matching: find.byType(Switch),
      );

      expect(
        rockSwitch,
        findsOneWidget,
      );

      await tornarVisivel(
        tester,
        rockSwitch,
      );

      await tester.tap(rockSwitch);
      await tester.pumpAndSettle();

      // -----------------------------------------------------------------
      // 7. Seleciona Pop
      // -----------------------------------------------------------------

      final popCard = find.ancestor(
        of: find.text('Pop'),
        matching: find.byType(Card),
      );

      expect(
        popCard,
        findsOneWidget,
      );

      final popSwitch = find.descendant(
        of: popCard,
        matching: find.byType(Switch),
      );

      expect(
        popSwitch,
        findsOneWidget,
      );

      await tornarVisivel(
        tester,
        popSwitch,
      );

      await tester.tap(popSwitch);
      await tester.pumpAndSettle();

      // -----------------------------------------------------------------
      // 8. Confirma os gêneros
      // -----------------------------------------------------------------

      final botaoConfirmar = find.text('Confirmar');

      await tornarVisivel(
        tester,
        botaoConfirmar,
      );

      await tester.tap(botaoConfirmar);

      // _salvarGeneros() faz o update no Firestore antes de navegar.
      await esperar(
        tester,
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
      );

      // -----------------------------------------------------------------
      // 9. Verifica a navegação para TelaInicialScreen
      // -----------------------------------------------------------------

      expect(
        find.textContaining(
          'essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // -----------------------------------------------------------------
      // 10. Verifica o usuário real no Firebase Auth Emulator
      // -----------------------------------------------------------------

      final user = FirebaseAuth.instance.currentUser;

      expect(
        user,
        isNotNull,
        reason:
            'O cadastro deveria criar um usuário no Firebase Auth.',
      );

      expect(
        user!.email,
        email,
      );

      // -----------------------------------------------------------------
      // 11. Verifica o documento real no Firestore Emulator
      // -----------------------------------------------------------------

      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      expect(
        snapshot.exists,
        isTrue,
        reason:
            'O cadastro deveria criar usuarios/{uid} no Firestore.',
      );

      final data = snapshot.data()!;

      // Dados criados pela CadastroScreen.
      expect(
        data['nome'],
        'Usuário E2E',
      );

      expect(
        data['email'],
        email,
      );

      // Dados adicionados pela GenerosCadastroScreen.
      expect(
        data['generos_favoritos'],
        containsAll(<String>[
          'Rock',
          'Pop',
        ]),
      );

      expect(
        (data['generos_favoritos'] as List).length,
        2,
        reason:
            'O teste selecionou exatamente Rock e Pop.',
      );
    },
  );
}
```

 A alteração essencial é a introdução de:

```
await tester.ensureVisible(finder);
```

 antes das interações com elementos que podem estar fora da viewport.

 Assim, o teste continua verificando **o mesmo fluxo e as mesmas condições de persistência**; apenas passa a reproduzir corretamente a ação que um usuário faria ao rolar a tela até o campo/botão.
`````

- **★ Autoclassificação do modelo:** **(A)** — "o dropdown está fora da área visível do emulador"; o teste precisa rolar.
- **Opção aplicada:** arquivo completo ("Versão corrigida"), substituição integral.
- **Resultado após correção:** **0/1 — Falhou**: tela de gêneros não aparece, sem aviso de toque.

### Iteração 3 (máximo)

- **Motivo da falha:** 0/1; tela de gêneros não aparece.
- **Prompt de reparo enviado:** template fixo + saída literal da iteração anterior (5.738 caracteres) — `FASE3-C3-FS_transcricao/prompt_reparo_iter3.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `iter3_resposta.md` (2575 caracteres).

`````markdown
## Classificação: **(B)**

 O teste está capturando um comportamento potencialmente incorreto da aplicação.

 O erro relevante agora é:

```
Found 0 widgets with text "SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA"
```

 Diferentemente do primeiro erro, o teste **já compila, instala o APK e começa a executar**. Portanto, não há mais um problema de importação ou de dependências impedindo a execução.

 ### Comportamento observado

 Durante o fluxo:

 > `cadastro: cria conta, seleciona gêneros e salva no Firestore`

 o teste chega ao ponto em que espera a tela/seção de seleção de gêneros musicais, mas a aplicação **não apresenta nenhum widget contendo o texto**:

```
SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA
```

 O teste falha exatamente nessa verificação, na linha 184:

```
c3_fs_test.dart:184
```

 ### Comportamento esperado

 Pelo próprio fluxo que o teste está validando, após o cadastro deve existir uma etapa de seleção de gêneros musicais. Nessa etapa, o texto esperado deveria estar presente e os gêneros deveriam poder ser selecionados antes da conclusão do cadastro.

 Portanto, **não é apropriado simplesmente trocar o texto procurado, remover a asserção ou pular essa etapa** apenas para fazer o teste passar.

 ### Por que classifico como B

 A falha anterior envolvendo `TextFormField`, `DropdownButtonFormField`, `Card` e `Switch` era claramente um problema do próprio arquivo de teste: faltavam símbolos/imports necessários.

 Essa parte já foi corrigida, e o teste agora consegue executar a aplicação. A falha mudou para uma evidência funcional:

```
Found 0 widgets with text
"SELECIONE OS GÊNEROS MUSICAIS QUE VOCÊ MAIS GOSTA"
```

 Isso indica que **a aplicação em execução não está apresentando a etapa que o teste espera encontrar**.

 Há duas possibilidades dentro de B que precisam ser investigadas antes de alterar qualquer coisa:

 - a aplicação realmente não está navegando para a tela de seleção de gêneros;
- a aplicação chega a uma tela equivalente, mas implementada com conteúdo diferente do especificado.

 Em ambos os casos, alterar a asserção do teste sem verificar a especificação poderia mascarar um defeito da aplicação.

 **Assim, não recomendo modificar o teste neste momento.** O próximo passo correto é verificar o fluxo de cadastro da aplicação — especialmente a navegação após o cadastro e a implementação da tela de gêneros — e comparar isso com a especificação da fase C3. Se você me fornecer o `c3_fs_test.dart` atual e o código da tela/fluxo de cadastro, consigo apontar exatamente onde está a divergência.
`````

- **★ Autoclassificação do modelo:** **(B)** — "a aplicação não apresenta nenhum widget contendo o texto" da tela de gêneros.
- **Opção aplicada:** nenhuma; sem código; arquivo inalterado.
- **Resultado após correção:** **0/1 — Falhou**, idêntico. `FASE3-C3-FS_iter3_final.txt`.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A), (A), (B). |
| **★ Classificação humana (auditoria)** | **Erro de geração** (import) e **Erro de teste** (toques fora da área visível; nome com dígito recusado pelo validador). Nenhum defeito do app no caminho exercitado. |
| **★ Concordância** | (A) nas iterações 1 e 2: sim. (B) na 3: **não** — mesma situação da FS-02 iteração 2, em que o modelo, na outra conversa, achou a causa no próprio teste; aqui não achou. |
| **★ Observações** | 1) Terceira vez na noite que o ChatGPT escolhe "Usuário E2E" como nome de teste (C3-ZS, FS-02, C3-FS). 2) O teste é bem desenhado para o C3 (afirma `data['nome']`), mas nunca chega lá. 3) Sem fontes externas. |

---

## Codificação manual-first (rubrica em `roteiro_manual.md`)

| Campo | Valor |
|---|---|
| **Bug da rodada** | C3 |
| **Sintoma manual de referência** | Passo 14: saudação com o e-mail no lugar do nome; fora da tela, `nome` do documento = e-mail (passo 10). |
| **O teste chegou ao ponto do sintoma?** | **Não** — para no passo 10: formulário recusado pelo validador do nome. |
| **Código** | **Não viu** (motivo: erro do teste antes do sintoma) |
| **Evidência** | `FASE3-C3-FS_iter3_final.txt`: tela de gêneros ausente; `expect(data['nome'], ...)` (linha 337) não é alcançada; o (B) final não descreve o sintoma do C3. |
| **Iteração em que o código se define** | 0 (nome com dígito desde a geração) |
