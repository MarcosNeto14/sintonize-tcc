# FASE3-L4-ZS — ChatGPT (com bug L4)

Rodada 4 do plano (bloco 1 — ZS, ChatGPT, primeira com bug). Executada em 2026-10-04 (00:18–00:31), segunda máquina (`DESKTOP-6ETPO2H`), por automação (Claude in Chrome), enquanto o autor estava ausente.

**Resultado em uma linha:** 5 testes gerados; **4/5 em todas as 4 execuções**. Geração: falha na asserção da saudação (texto em minúsculas, que falharia até no app limpo). Reparo 1 **(A)** troca por uma espera pelos itens da barra inferior da `TelaInicialScreen` → falha com "A TelaInicialScreen não apareceu após aguardar 10 segundos" — o sintoma do L4. Reparos 2 e 3 **(B)**, sem código. **Codificação manual-first: Capturou** (definida na iteração 1). O (B) está certo quanto ao defeito estar fora do teste, mas o modelo atribui a causa ao Auth/emulador, não à navegação errada.

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-L4-ZS (com bug L4) |
| **Modelo** | ChatGPT |
| **Fluxo alvo** | login — boas-vindas → `LoginScreen` → (esperado) `TelaInicialScreen` |
| **Estado do `lib/`** | **com bug L4** — `eb14334` (`login.dart:36`, `TelaInicialScreen()` → `CadastroScreen()`); 1 arquivo, 1 linha de diferença para `ccae44a`, conferido |
| **Worktree usado** | `C:\Users\Marcos\Desktop\sintonize-fase3-L4`, detached em `eb14334` (criado em 2026-10-04; `HEAD` conferido antes de cada execução) |
| **Nível da pirâmide** | E2E (integration_test no AVD, emuladores Firebase) |
| **Estratégia de prompt** | Zero-shot |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/zero-shot/FASE3-E2E-ZS-01_loginFlow.md` — sha256 `a2b8247c6f611bdd52d0fa19e8a9449e93acdd5f2b153cc415a090670dbf8087`, igual a `_sha256.txt` |
| **✦ Modelo declarado pelo LLM** | "GPT-5.6 Luna" — perguntado em 2026-10-04, 00:17, em conversa própria e deslogada (`chatgpt.com/uc/6ac1c4c6-bca8-83ea-a37b-0fc7f4ddfeb4`); print `evidencias/chatgpt/2026-10-04_chatgpt_pergunta_versao_deslogado.jpg`. A partir daí o autor dispensou repetir o controle: "não precisa ficar sempre pedindo auto declaração e indo no help center. a versão é a mesma". |
| **✦ Verificação externa da versão** | Última consulta: OpenAI Help Center, 2026-10-03 (GPT-5.6 Luna para deslogado). A consulta de 2026-10-04 foi aberta e **interrompida pelo autor** (dispensa acima); não registrada como verificação. |
| **Sessão** | ChatGPT deslogada ("Entrar" e "Cadastre-se grátis" visíveis) |
| **Consultou fontes externas?** | Não — nenhum marcador de citação nas respostas |
| **Data de acesso** | 2026-10-04 |
| **Conversa nova?** | Sim — `https://chatgpt.com/uc/6ac1c55b-0288-83ea-af44-a80669773c8f` (1ª tentativa) |
| **Envio** | Automatizado (Claude in Chrome), autor ausente: prompt e reparos no clipboard por script, Ctrl+V no composer, texto do editor conferido por leitura do DOM (tamanho, início, fim) antes de cada envio; respostas pelo botão "Copiar resposta". |
| **Versão do Flutter** | 3.41.6 · Dart 3.11.4 |
| **AVD** | `tcc_e2e` (Pixel 6, API 34), `emulator-5554` |
| **firebase-tools** | 15.31.0 |

---

## Procedimento operacional (executado)

- [x] Worktree `sintonize-fase3-L4` criado em `eb14334`; `firebase_test_helper.dart`, `seed.dart`, `seed_test.dart` e `pubspec.lock` idênticos aos da ponta da `fase3-e2e`; primeiro build (seed) em 55 s.
- [x] Prompt colado sem alteração (33.976 caracteres; o mesmo arquivo da ZS-01, como manda o plano).
- [x] Código salvo sem editar em `integration_test/fase3/l4_zs_test.dart` **do worktree L4** (o modelo nomeou `login_test.dart`). Reparo 1: arquivo completo ("login_test.dart — corrigido"), substituição integral.
- [x] Antes de cada uma das 4 execuções: emuladores reiniciados, `seed_test` no worktree L4, conferência por REST (1 doc em `usuarios`, 5 em `musica`, 0 em `playlists`, 1 conta no Auth).
- [x] Saídas em `resultados/chatgpt/FASE3-L4-ZS_iter{0,1,2}.txt` e `_iter3_final.txt`; prints `evidencias/chatgpt/FASE3-L4-ZS_iter{0..3}.png` (o app já fechou ao fim do comando; mesma limitação das rodadas anteriores).
- [x] Reparos: só template fixo + saída literal. Nenhum pedido do modelo respondido.
- [x] Teste final arquivado em `integration_test/fase3/chatgpt/l4_zs_test.dart` (sha256 `c6a71851be73dce6…`) e removido do worktree; o da geração em `FASE3-L4-ZS_transcricao/teste_iter0_geracao.dart` (sha256 `12baa97e753bbec2…`).

---

## Prompt Enviado

Texto entre o 2º e o 3º `---` de `fase3-e2e/prompts_prontos/zero-shot/FASE3-E2E-ZS-01_loginFlow.md`, sem alteração (33.976 caracteres). Arquivo e sha256 são o registro.

---

## Resposta do LLM

`FASE3-L4-ZS_transcricao/iter0_resposta.md` (6842 caracteres, botão "Copiar resposta").

`````markdown
Abaixo está um teste único para `integration_test/fase3/login_test.dart`, cobrindo sucesso, credenciais inválidas, campos vazios e senha incorreta, sempre partindo da `HomeScreen` e usando os emuladores Firebase reais.

 integration\_test/fase3/login\_test.dart

```
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

  Future<void> abrirLogin(WidgetTester tester) async {
    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  }

  Future<void> preencherLogin(
    WidgetTester tester, {
    required String email,
    required String senha,
  }) async {
    final camposEmail = find.byType(TextFormField);

    expect(camposEmail, findsNWidgets(2));

    await tester.enterText(camposEmail.at(0), email);
    await tester.enterText(camposEmail.at(1), senha);

    await tester.pump();
  }

  group('Login - fluxo end-to-end', () {
    testWidgets(
      'autentica com sucesso e navega para a TelaInicialScreen',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'tester@sintonize.test',
          senha: 'senha123',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        // A navegação para a TelaInicialScreen substitui a LoginScreen.
        expect(find.text('tester sintonize, essa é a nossa recomendação de música para você!'),
            findsOneWidget);

        // Confirma elementos próprios da TelaInicialScreen.
        expect(find.text('Pesquisa Direta'), findsOneWidget);
        expect(find.text('Sintonizados'), findsOneWidget);
        expect(find.text('Mapa'), findsOneWidget);
        expect(find.text('Minha Conta'), findsOneWidget);

        // A recomendação pode ser a última música do histórico ou uma
        // nova música, portanto não fazemos uma asserção sobre uma música
        // específica. O importante neste teste é confirmar que a tela foi
        // carregada após a autenticação.
        expect(find.text('Entrar'), findsNothing);
      },
    );

    testWidgets(
      'exibe erro para credenciais inválidas',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'naoexiste@sintonize.test',
          senha: 'senha123',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
          ),
          findsOneWidget,
        );

        expect(
          find.text('Entrar'),
          findsOneWidget,
        );

        // Continua na LoginScreen.
        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
      },
    );

    testWidgets(
      'exibe erro de senha incorreta para usuário existente',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'tester@sintonize.test',
          senha: 'senha-errada',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
          ),
          findsOneWidget,
        );

        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
      },
    );

    testWidgets(
      'não tenta autenticar e exibe validação quando os campos estão vazios',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirLogin(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsOneWidget,
        );

        expect(
          find.text('Por favor, insira sua senha'),
          findsOneWidget,
        );

        // Continua na LoginScreen.
        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
      },
    );

    testWidgets(
      'valida formato do e-mail e tamanho mínimo da senha',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'email-invalido',
          senha: '123',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text('Por favor, insira um e-mail válido'),
          findsOneWidget,
        );

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );

        // A validação local impede a chamada ao Firebase e a navegação.
        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
      },
    );
  });
}
```

 ### Observação importante

 O teste de sucesso faz uma asserção sobre:

```
tester sintonize, essa é a nossa recomendação de música para você!
```

 porque esse texto é construído a partir do documento `usuarios/{uid}` previamente populado no Firestore. Como o `TelaInicialScreen` também carrega músicas assincronamente, o teste **não depende de qual música foi escolhida**.

 Também não é necessário chamar `Firebase.initializeApp()` diretamente no teste: o `setUpAll()` usa exatamente o `setupFirebaseEmulators()` fornecido, antes de qualquer interação.

 Para executar todos os testes da fase:

```
flutter test integration_test/fase3/ -d emulator-5554
```

 O arquivo pressupõe que `firebase_test_helper.dart` está em `integration_test/firebase_test_helper.dart`, portanto o import relativo `../firebase_test_helper.dart` está correto.
`````

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim, nas 4 execuções |
| **Testes gerados** | 5 — sucesso; credenciais inválidas; senha incorreta; campos vazios; formato de e-mail/senha curta |
| **Testes passaram (iteração 0)** | 4 |
| **Testes falharam (iteração 0)** | 1 — sucesso (asserção da saudação) |
| **Testes passaram (estado final)** | 4 |
| **Testes falharam (estado final)** | 1 — sucesso: "A TelaInicialScreen não apareceu após aguardar 10 segundos." |
| **Melhor estado intermediário** | = final |
| **Tempo por execução** | 34–41 s (Gradle 12,5–14,1 s + 13–21 s de teste) |
| **Prints tirados** | 4 (home do Android) |

Na iteração 0 a asserção era `find.text('tester sintonize, essa é a nossa recomendação de música para você!')`, em minúsculas. O app formata o nome (`_formatName`) e mostra "Tester Sintonize, …"; essa asserção **falharia também no app limpo**. A falha da iteração 0 ocorre no ponto do sintoma, mas não o discrimina.

### Saída do terminal (iteração 0)

`resultados/chatgpt/FASE3-L4-ZS_iter0.txt`

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
00:00 +0: loading C:/Users/Marcos/Desktop/sintonize-fase3-L4/integration_test/fase3/l4_zs_test.dart
Running Gradle task 'assembleDebug'...                             14,1s
√ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...          759ms
00:00 +0: (setUpAll)
00:00 +0: Login - fluxo end-to-end autentica com sucesso e navega para a TelaInicialScreen
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "tester sintonize, essa é a nossa
recomendação de música para você!": []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure>.<anonymous closure> (file:///C:/Users/Marcos/Desktop/sintonize-fase3-L4/integration_test/fase3/l4_zs_test.dart:61:9)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1682:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///C:/Users/Marcos/Desktop/sintonize-fase3-L4/integration_test/fase3/l4_zs_test.dart line 61
The test description was:
  autentica com sucesso e navega para a TelaInicialScreen
════════════════════════════════════════════════════════════════════════════════════════════════════
00:06 +0 -1: Login - fluxo end-to-end autentica com sucesso e navega para a TelaInicialScreen [E]
  Test failed. See exception logs above.
  The test description was: autentica com sucesso e navega para a TelaInicialScreen
  
00:06 +0 -1: Login - fluxo end-to-end exibe erro para credenciais inválidas
00:08 +1 -1: Login - fluxo end-to-end exibe erro de senha incorreta para usuário existente
00:09 +2 -1: Login - fluxo end-to-end não tenta autenticar e exibe validação quando os campos estão vazios
00:11 +3 -1: Login - fluxo end-to-end valida formato do e-mail e tamanho mínimo da senha
00:12 +4 -1: (tearDownAll)
00:13 +4 -1: Some tests failed.
```

---

## Iterative Repair Loop

### Iteração 1

- **Motivo da falha:** 4/5; saudação não encontrada após o `pumpAndSettle` do login.
- **Prompt de reparo enviado:** template fixo + saída literal da iteração anterior (6.235 caracteres) — `FASE3-L4-ZS_transcricao/prompt_reparo_iter1.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `iter1_resposta.md` (7976 caracteres).

`````markdown
**Classificação: (A) — o teste presume um comportamento que não é necessariamente garantido pelo código especificado.**

 O problema está na asserção do texto completo. Embora a `TelaInicialScreen` seja a tela esperada após o login, o `FutureBuilder` inicialmente renderiza **`Carregando...`** e só depois monta a saudação. Além disso, `pumpAndSettle()` não é uma garantia adequada para esperar operações assíncronas externas do Firebase/Firestore.

 Portanto, o teste deve verificar de forma robusta que a navegação chegou à `TelaInicialScreen`, e aguardar explicitamente o elemento característico dessa tela aparecer, sem depender do timing da consulta ao Firestore.

 Vou manter a cobertura ponta a ponta e não alterar a aplicação.

 integration\_test/fase3/login\_test.dart — corrigido

```
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

  Future<void> abrirLogin(WidgetTester tester) async {
    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  }

  Future<void> preencherLogin(
    WidgetTester tester, {
    required String email,
    required String senha,
  }) async {
    final campos = find.byType(TextFormField);

    expect(campos, findsNWidgets(2));

    await tester.enterText(campos.at(0), email);
    await tester.enterText(campos.at(1), senha);
    await tester.pump();
  }

  /// Aguarda a TelaInicialScreen aparecer.
  ///
  /// O carregamento do Firestore ocorre depois da navegação, portanto não
  /// devemos depender de um único pumpAndSettle() para esperar essa consulta.
  Future<void> aguardarTelaInicial(WidgetTester tester) async {
    final indicadoresDaTelaInicial = [
      find.text('Pesquisa Direta'),
      find.text('Sintonizados'),
      find.text('Mapa'),
      find.text('Minha Conta'),
    ];

    for (var i = 0; i < 50; i++) {
      if (indicadoresDaTelaInicial.any(
        (finder) => finder.evaluate().isNotEmpty,
      )) {
        return;
      }

      await tester.pump(const Duration(milliseconds: 200));
    }

    fail(
      'A TelaInicialScreen não apareceu após aguardar 10 segundos.',
    );
  }

  group('Login - fluxo end-to-end', () {
    testWidgets(
      'autentica com sucesso e navega para a TelaInicialScreen',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'tester@sintonize.test',
          senha: 'senha123',
        );

        await tester.tap(find.text('Entrar'));

        // Não dependemos do pumpAndSettle() para esperar as operações
        // externas de Auth/Firestore.
        await aguardarTelaInicial(tester);

        // A barra inferior é criada exclusivamente pela TelaInicialScreen.
        expect(find.text('Pesquisa Direta'), findsOneWidget);
        expect(find.text('Sintonizados'), findsOneWidget);
        expect(find.text('Mapa'), findsOneWidget);
        expect(find.text('Minha Conta'), findsOneWidget);

        // A LoginScreen não deve mais estar na árvore após
        // pushReplacement().
        expect(find.text('Entrar'), findsNothing);
        expect(find.text('Esqueci minha senha'), findsNothing);
      },
    );

    testWidgets(
      'exibe erro para credenciais inválidas',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'naoexiste@sintonize.test',
          senha: 'senha123',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
          ),
          findsOneWidget,
        );

        // O login falhou, portanto continua na LoginScreen.
        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
      },
    );

    testWidgets(
      'exibe erro de senha incorreta para usuário existente',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'tester@sintonize.test',
          senha: 'senha-errada',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
          ),
          findsOneWidget,
        );

        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
      },
    );

    testWidgets(
      'exibe validação quando os campos estão vazios',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirLogin(tester);

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text('Por favor, insira seu e-mail'),
          findsOneWidget,
        );

        expect(
          find.text('Por favor, insira sua senha'),
          findsOneWidget,
        );

        // A validação local impede a tentativa de autenticação.
        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
      },
    );

    testWidgets(
      'valida formato do e-mail e tamanho mínimo da senha',
      (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await abrirLogin(tester);

        await preencherLogin(
          tester,
          email: 'email-invalido',
          senha: '123',
        );

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(
          find.text('Por favor, insira um e-mail válido'),
          findsOneWidget,
        );

        expect(
          find.text('A senha deve ter pelo menos 6 caracteres'),
          findsOneWidget,
        );

        expect(find.text('Entrar'), findsOneWidget);
        expect(find.text('E-mail'), findsOneWidget);
        expect(find.text('Senha'), findsOneWidget);
      },
    );
  });
}
```

 ### O que mudou

 A asserção problemática era:

```
expect(
  find.text(
    'tester sintonize, essa é a nossa recomendação de música para você!',
  ),
  findsOneWidget,
);
```

 Ela dependia de duas coisas assíncronas:

 1. autenticação no Firebase Auth;
2. leitura de `usuarios/{uid}` no Firestore feita por `fetchUserName()`.

 O erro ocorreu especificamente porque, no momento da asserção, esse `Text` ainda não estava presente.

 Agora o teste espera a própria estrutura característica da `TelaInicialScreen`, especialmente os quatro itens da `BottomNavigationBar`. Isso continua sendo uma verificação real de **navegação após autenticação**, sem montar a tela isoladamente ou mockar Firebase.

 Um detalhe importante: os outros quatro testes passaram no seu resultado (`+4 -1`), então **não há evidência de problema na aplicação nos cenários de erro/validação**. O único problema demonstrado pelo log é a sincronização da asserção do teste de sucesso.
`````

- **★ Autoclassificação do modelo:** **(A)** — "o `FutureBuilder` inicialmente renderiza `Carregando...`"; `pumpAndSettle` não espera o Firestore.
- **Opção aplicada:** arquivo completo, substituição integral. Mudança: helper `aguardarTelaInicial` (até 10 s, 50 × 200 ms) que espera qualquer um dos 4 itens da barra inferior; a saudação deixa de ser afirmada.
- **Resultado após correção:** **4/5 — Falhou**: "A TelaInicialScreen não apareceu após aguardar 10 segundos." (`l4_zs_test.dart:63`).

### Iteração 2

- **Motivo da falha:** 4/5; a `TelaInicialScreen` não aparece em 10 s.
- **Prompt de reparo enviado:** template fixo + saída literal da iteração anterior (6.103 caracteres) — `FASE3-L4-ZS_transcricao/prompt_reparo_iter2.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `iter2_resposta.md` (3997 caracteres).

`````markdown
**Classificação: (B) — o teste capturou um comportamento potencialmente incorreto da aplicação/ambiente.**

 Desta vez, **não devemos enfraquecer a asserção nem aumentar simplesmente o timeout**.

 ### Comportamento observado

 O fluxo foi:

 1. O teste abriu a `LoginScreen`.
2. Preencheu `tester@sintonize.test` / `senha123`.
3. Tocou em `Entrar`.
4. Aguardou até 10 segundos.
5. A `TelaInicialScreen` **não apareceu**.

 Isso é diferente da falha anterior. Antes, a `TelaInicialScreen` provavelmente já havia sido alcançada, mas o texto da saudação ainda não estava disponível. Agora, **nenhum dos elementos estruturais da `TelaInicialScreen` apareceu durante 10 segundos**.

 ### Comportamento esperado

 Com as credenciais fornecidas, o código da `LoginScreen` executa:

```
await firebaseAuth.signInWithEmailAndPassword(
  email: email,
  password: senha,
);

Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const TelaInicialScreen(),
  ),
);
```

 Portanto, se o `signInWithEmailAndPassword()` for bem-sucedido, a navegação para `TelaInicialScreen` deve acontecer **independentemente do Firestore**.

 A leitura do Firestore dentro de `TelaInicialScreen` só ocorre depois que essa tela é construída. Ela pode afetar o conteúdo de recomendação/nome, mas **não deveria impedir a existência da `BottomNavigationBar`**.

 ### Por que isso sugere um problema

 O ponto importante é que a própria navegação ocorre **antes** de `TelaInicialScreen` fazer suas consultas ao Firestore:

```
signInWithEmailAndPassword()
        ↓
Navigator.pushReplacement(...)
        ↓
TelaInicialScreen
        ↓
fetchUserName()
fetchLastRecommendedMusic()
        ↓
Firestore
```

 Assim, uma falha de `fetchUserName()` ou `fetchLastRecommendedMusic()` não explica, por si só, a ausência da `TelaInicialScreen` inteira.

 Há duas hipóteses principais:

 - **O login aparentemente não foi autenticado com sucesso**, apesar de o ambiente declarar que o usuário existe no Auth Emulator.
- **Existe algum problema de inicialização/configuração do Firebase Auth no teste de sucesso**, fazendo com que a chamada não complete como esperado.

 E há um detalhe particularmente relevante no seu cenário: o teste monta `MyApp` diretamente:

```
await tester.pumpWidget(const MyApp());
```

 Logo, o `main()` de `lib/main.dart` **não é executado**. Isso é intencional e está de acordo com o requisito do teste, mas significa que a inicialização do Firebase precisa ser totalmente providenciada pelo `setupFirebaseEmulators()`.

 O helper faz isso, então a configuração parece correta à primeira vista.

 ### O que eu não faria

 Não substituiria a asserção por algo como:

```
expect(find.byType(Scaffold), findsOneWidget);
```

 nem aumentaria o timeout para 30 ou 60 segundos. Isso poderia mascarar justamente o problema que o teste está revelando.

 Também não removeria a verificação de navegação.

 ### Próximo diagnóstico recomendado

 O próximo passo é descobrir **qual dos dois caminhos está acontecendo**:

```
Entrar
  │
  ├── Firebase Auth aceita credenciais
  │       ↓
  │   Navigator.pushReplacement
  │       ↓
  │   TelaInicialScreen
  │
  └── Firebase Auth rejeita credenciais
          ↓
      SnackBar de erro
```

 Como o teste atual não registra qual caminho ocorreu, o diagnóstico fica incompleto.

 Podemos fazer isso **sem enfraquecer o teste**: alterar temporariamente o teste para, após o toque em `Entrar`, verificar explicitamente o resultado esperado da autenticação — `TelaInicialScreen` **ou** o `SnackBar` inesperado — e produzir uma mensagem diagnóstica contendo o erro real retornado pelo fluxo.

 Se aparecer um `SnackBar` de erro para `tester@sintonize.test`/`senha123`, então o problema está na **configuração/população do Firebase Auth Emulator**, não na asserção da tela.

 Se não aparecer erro e mesmo assim a navegação não ocorrer, aí teremos evidência muito mais forte de um problema na própria aplicação ou na inicialização do Firebase no teste.
`````

- **★ Autoclassificação do modelo:** **(B)** — "nenhum dos elementos estruturais da `TelaInicialScreen` apareceu"; hipóteses: Auth rejeitando as credenciais ou inicialização do Firebase. Oferece um diagnóstico ("podemos fazer isso") sem código.
- **Opção aplicada:** nenhuma; sem código; arquivo inalterado e reexecutado.
- **Resultado após correção:** **4/5 — Falhou**, idêntico.

### Iteração 3 (máximo)

- **Motivo da falha:** o mesmo.
- **Prompt de reparo enviado:** template fixo + saída literal da iteração anterior (6.103 caracteres) — `FASE3-L4-ZS_transcricao/prompt_reparo_iter3.txt`. [x] sem acréscimo.
- **Resposta do LLM:** `iter3_resposta.md` (4702 caracteres).

`````markdown
**Classificação: (B) — o teste capturou um comportamento potencialmente incorreto da aplicação/ambiente.**

 Não vou alterar a asserção para fazê-la passar.

 ## Comportamento observado

 Com:

 - `tester@sintonize.test`
- `senha123`

 o teste:

 1. inicializa os emuladores no `setUpAll()`;
2. monta `MyApp`;
3. navega pela `HomeScreen` até `LoginScreen`;
4. preenche as credenciais;
5. toca em `Entrar`;
6. espera até 10 segundos;
7. **nunca encontra nenhum elemento da `TelaInicialScreen`**.

 Os quatro outros cenários passam.

 Isso é relevante porque o problema não é mais apenas uma condição de corrida com `fetchUserName()`.

 ## Comportamento esperado

 O código de `LoginScreen` especifica explicitamente:

```
await firebaseAuth.signInWithEmailAndPassword(
  email: email,
  password: senha,
);

Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) => const TelaInicialScreen(),
  ),
);
```

 Portanto, para `tester@sintonize.test` \+ `senha123`, considerando que esse usuário realmente foi populado no Auth Emulator antes da execução, o fluxo esperado é:

```
LoginScreen
    │
    │ signInWithEmailAndPassword()
    ▼
Firebase Auth Emulator
    │
    │ sucesso
    ▼
Navigator.pushReplacement()
    │
    ▼
TelaInicialScreen
```

 A `TelaInicialScreen` constrói sua `BottomNavigationBar` imediatamente. As consultas ao Firestore acontecem posteriormente e **não são pré-requisito para a construção dessa barra**.

 Assim, o fato de nenhum destes elementos aparecer:

```
Pesquisa Direta
Sintonizados
Mapa
Minha Conta
```

 durante 10 segundos indica que o fluxo não chegou à `TelaInicialScreen`.

 ## Por que não devemos modificar o teste

 Não seria correto trocar a asserção por algo mais fraco, por exemplo:

```
expect(find.byType(Scaffold), findsOneWidget);
```

 Isso poderia fazer o teste passar enquanto ele ainda estivesse na `LoginScreen`.

 Também não devemos simplesmente aumentar:

```
10 segundos → 30 segundos → 60 segundos
```

 porque não existe no código da aplicação uma operação que justifique uma espera desse tipo antes da navegação.

 O teste está verificando exatamente o comportamento especificado: **autenticação válida → navegação para `TelaInicialScreen`**.

 ## O ponto que precisa ser investigado

 Agora precisamos descobrir o que aconteceu com esta chamada:

```
await firebaseAuth.signInWithEmailAndPassword(
  email: email,
  password: senha,
);
```

 Há duas possibilidades principais:

 ### 1\. O Firebase Auth está rejeitando as credenciais

 Nesse caso, a aplicação entra neste trecho:

```
on FirebaseAuthException catch (e) {
  ...
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.red,
    ),
  );
}
```

 O teste atual não mostra qual `e.code` foi recebido no cenário de sucesso.

 Se isso estiver acontecendo, o problema provavelmente está na **população/configuração do Auth Emulator**, por exemplo:

 - o usuário não existe no emulator usado pelo aplicativo;
- o usuário existe com outra senha;
- o aplicativo e o helper estão apontando para emuladores diferentes;
- o estado do emulator não é o esperado no momento da execução.

 ### 2\. O Firebase Auth aceita as credenciais, mas a navegação não ocorre

 Nesse caso teríamos evidência de um problema no próprio fluxo da aplicação, porque `Navigator.pushReplacement()` está imediatamente depois do `await`.

 Esse seria um problema real de comportamento da aplicação e o teste **não deveria ser enfraquecido para contorná-lo**.

 ## Como diagnosticar sem enfraquecer o teste

 A próxima execução deve registrar explicitamente o estado do Auth Emulator antes do teste de UI. Isso não substitui o teste E2E nem transforma o teste em mock; serve apenas para confirmar que o pré-requisito fornecido pelo ambiente realmente existe.

 Por exemplo, no próprio teste podemos consultar o usuário através do `FirebaseAuth.instance` **antes de montar a UI**, verificando se o ambiente contém o usuário esperado.

 Se essa verificação disser que `tester@sintonize.test` não existe, encontramos a causa: **o problema está no processo de população/reset do Auth Emulator**, não no teste.

 Se o usuário existir, o próximo diagnóstico deve capturar o resultado real da tentativa de login e determinar se o problema está entre:

```
Auth Emulator → signInWithEmailAndPassword()
```

 ou:

```
signInWithEmailAndPassword() → Navigator.pushReplacement()
```

 **Neste momento, portanto, eu não recomendo uma nova versão "corrigida" do teste.** O log já demonstra uma falha de comportamento que o teste foi justamente criado para detectar; alterar a asserção agora esconderia essa falha em vez de corrigi-la.
`````

- **★ Autoclassificação do modelo:** **(B)** — "o log já demonstra uma falha de comportamento que o teste foi justamente criado para detectar"; duas hipóteses: Auth rejeitando (emulador mal populado) ou Auth aceitando e a navegação não ocorrendo ("problema real de comportamento da aplicação").
- **Opção aplicada:** nenhuma; sem código; arquivo inalterado.
- **Resultado após correção:** **4/5 — Falhou**, idêntico. `FASE3-L4-ZS_iter3_final.txt`.

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | (A) na iteração 1; (B) nas iterações 2 e 3. |
| **★ Classificação humana (auditoria)** | Iteração 0: **Erro de teste** (texto da saudação sem a formatação que o app aplica; e espera insuficiente). Iterações 1–3: **Bug real exposto** — com o L4, o login autentica e o app abre a `CadastroScreen`; nenhum item da barra inferior aparece, e o teste falha exatamente aí. |
| **★ Concordância** | (A) da iteração 1: sim (o teste estava errado). (B) das iterações 2–3: **sim quanto à classificação**; a explicação, porém, não acerta a causa: o modelo nunca considera que a navegação vá para outra tela, e prioriza a hipótese de Auth/emulador, que a própria saída refuta (os testes de senha incorreta e credenciais inválidas passam, então o Auth emulator responde). |
| **★ Observações** | 1) Primeira rodada com bug. 2) O teste de sucesso não afirma o tipo da tela de destino nem a ausência da `CadastroScreen`; detecta o L4 indiretamente, pela ausência da barra inferior. 3) A resposta 3 contém o diagnóstico certo como uma das duas hipóteses ("Auth aceita as credenciais, mas a navegação não ocorre"), sem escolher entre elas. 4) Os testes de erro (E1–E4) passam, como previsto em `roteiro_manual.md` (idênticos com e sem L4). 5) A referência (`_referencia/login_flow_test.dart`) não entrou em nenhum prompt. |

---

## Codificação manual-first (rubrica em `roteiro_manual.md`)

| Campo | Valor |
|---|---|
| **Bug da rodada** | L4 |
| **Sintoma manual de referência** | Passo 5: "**CadastroScreen**: formulário de cadastro vazio (Nome, Data de Nascimento, E-mail, Senha…), botão "Cadastrar", link "Já tem uma conta? Faça login". Nenhuma mensagem de erro. O usuário **está** autenticado no Auth." |
| **O teste chegou ao ponto do sintoma?** | Sim — toca em "Entrar" com as credenciais do seed e espera a tela de destino |
| **Código** | **Capturou** |
| **Evidência** | `FASE3-L4-ZS_iter3_final.txt`: "A TelaInicialScreen não apareceu após aguardar 10 segundos." no teste de sucesso, os outros 4 verdes; mesma assinatura da referência ("não apareceu em 20s: TelaInicialScreen"). (B) nas iterações 2–3, coerente com o sintoma. |
| **Iteração em que o código se define** | 1 (na iteração 0 a falha já ocorre no passo 5, mas por uma asserção que falharia também no app limpo) |
