# FASE3-E2E-ZS-01_loginFlow — ChatGPT (rodada limpa)

Rodada 1 do plano (bloco 1 — ZS, ChatGPT). Documentada a partir de
`fase3-e2e/template_rodada.md`. **Executada por inteiro em 2026-10-03, na
segunda máquina (`DESKTOP-6ETPO2H`)**, em conversa nova. É a refeitura da
tentativa de 2026-10-02 (máquina original), que gerou o teste mas nunca o
executou e cuja conversa deslogada só existia na aba do Chrome daquela máquina;
essa tentativa está em `_abortadas/FASE3-E2E-ZS-01_loginFlow_TENTATIVA-1.md`
e não conta.

**Resultado em uma linha:** 9 testes gerados; **8/9 na geração e 8/9 no estado
final**, após 3 iterações de reparo em que o modelo classificou a falha como
**(B)** nas três e **se recusou a alterar o teste**; o arquivo final é
byte-idêntico ao gerado. A auditoria humana discorda: a asserção falha por
timing do próprio teste (o 8º teste do mesmo arquivo passa com a mesma
asserção depois de um segundo `pumpAndSettle`), e o `setState() called after
dispose()` que o modelo aponta é real e pré-existente em `lib/tela-inicial.dart`,
mas não é a causa da falha e não é um bug plantado.

---

## Metadados

| Campo | Valor |
|---|---|
| **ID da Rodada** | FASE3-E2E-ZS-01_loginFlow (limpa) |
| **Modelo** | ChatGPT |
| **Fluxo alvo** | login — tela de boas-vindas → `LoginScreen` → `TelaInicialScreen` |
| **Estado do `lib/`** | limpo (`fase3-e2e`, igual a `ccae44a`) — `git diff ccae44a -- lib/` vazio no worktree de execução, conferido antes da conversa |
| **Worktree usado** | `C:\Users\Marcos\Desktop\sintonize-fase3`, branch `fase3-e2e`, `60e070f` no momento da execução (é também o checkout que commita nesta máquina) |
| **Nível da pirâmide** | E2E (integration_test no AVD, emuladores Firebase) |
| **Estratégia de prompt** | Zero-shot |
| **Arquivo do prompt** | `fase3-e2e/prompts_prontos/zero-shot/FASE3-E2E-ZS-01_loginFlow.md` — sha256 `a2b8247c6f611bdd52d0fa19e8a9449e93acdd5f2b153cc415a090670dbf8087`, igual ao de `prompts_prontos/_sha256.txt` |
| **✦ Modelo declarado pelo LLM** | "GPT-5.6 Luna" — resposta literal a "Qual modelo você é? Responda só o nome.", em conversa própria (`chatgpt.com/uc/6ac1aeeb-89e0-83ea-8c81-3bcabe3e4478`), deslogada, antes da rodada. Print: `evidencias/chatgpt/2026-10-03_chatgpt_pergunta_versao_deslogado.jpg` |
| **✦ Verificação externa da versão** | GPT-5.6 Luna. OpenAI Help Center, "GPT-5.6 and GPT-6 Pro in ChatGPT", https://help.openai.com/en/articles/20001354-gpt-56-and-gpt-6-pro-in-chatgpt ("Updated: anteontem", isto é, 2026-10-01), consultado em 2026-10-03: "Logged-out users do not have access to GPT-5.6 Sol. Free and Go users do not have access to GPT-5.6 Sol. Their default model is GPT-5.6 Luna, which also powers Think." Print: `evidencias/chatgpt/2026-10-03_openai_helpcenter_gpt56_luna.jpg`. Autodeclaração e fonte: concordam. |
| **Sessão** | ChatGPT **deslogada**. O Chrome desta máquina estava logado numa conta Go; o autor fez logout antes da pergunta de versão e da rodada (a tela passou a mostrar "Entrar" e "Cadastre-se grátis"; visível nos prints). |
| **Consultou fontes externas?** | **Não** — nenhum marcador de citação em nenhuma das quatro respostas |
| **Data de acesso** | 2026-10-03 |
| **Conversa nova?** | Sim — `https://chatgpt.com/uc/6ac1afb0-c998-83ea-9998-23d62ad5dcda` (uma única conversa para geração e os 3 reparos) |
| **Versão do Flutter** | Flutter 3.41.6 · Dart 3.11.4 (`channel [user-branch]`) |
| **AVD** | `tcc_e2e` (Pixel 6, API 34, google_apis, x86_64), WHPX; `adb devices` → `emulator-5554 device` |
| **firebase-tools** | 15.31.0 |

---

## Procedimento operacional (executado)

Antes da conversa:

- [x] Worktree `Desktop\sintonize-fase3`, `fase3-e2e` @ `60e070f`, `lib/` limpo (diff vs `ccae44a` vazio).
- [x] AVD `tcc_e2e` ligado (`-no-snapshot-load -no-boot-anim`), `sys.boot_completed = 1`.
- [x] Emuladores Firebase (`--only auth,firestore --project sintonize-fa494`) desacoplados via `Start-Process cmd /c`, a partir da raiz do worktree; 9099 e 8080 → 200.

Na conversa:

- [x] Pergunta de versão em conversa própria; resposta literal registrada (✦).
- [x] Prompt colado exatamente como está entre o 2º e o 3º `---` do arquivo: carregado no clipboard por script (`Set-Clipboard`, 33.976 caracteres, igual ao da tentativa de 2026-10-02), colado com Ctrl+V, e o texto do editor conferido por leitura do DOM antes do envio (33.976 caracteres; início "Gere um teste end-to-end em Dart, com o pacote…", fim "…para os imports do projeto"). Envio automatizado (Claude in Chrome).
- [x] Código salvo sem editar em `integration_test/fase3/login_zs_test.dart` do worktree (único bloco Dart da resposta, linhas 6–352 do markdown copiado; 347 linhas). O modelo nomeou o arquivo `login_test.dart`; a convenção da Fase 3 fixa `login_zs_test.dart`, e o nome não afeta a execução. Cópia arquivada, idêntica (sha256 `cfef8a78ab87f9a756c618abd2d7b62ecf71af682d2248ed74cc9dbf3013c5bd`), em `integration_test/fase3/chatgpt/login_zs_test.dart`; a cópia da raiz de `integration_test/fase3/` foi removida depois do arquivamento.

A cada execução (4 no total: geração + 3 iterações):

- [x] Emuladores derrubados e subidos de novo, `seed_test` rodado; Firestore conferido por REST: 1 doc em `usuarios`, 5 em `musica`, antes de cada uma das 4 execuções.
- [x] `flutter test integration_test/fase3/login_zs_test.dart -d emulator-5554`, um por comando.
- [x] Saídas íntegras em `resultados/chatgpt/FASE3-E2E-ZS-01_loginFlow_iter{0,1,2}.txt` e `_iter3_final.txt`.
- [x] Print do AVD logo após cada `flutter test` terminar em falha: `evidencias/chatgpt/FASE3-E2E-ZS-01_loginFlow_iter{0,1,2,3}.png`. **Os quatro mostram a home do Android, não o app** — ver "Ocorrências de método" abaixo.
- [x] Reparos: só o template fixo com a saída literal, na mesma conversa (prompts em `FASE3-E2E-ZS-01_loginFlow_transcricao/prompt_reparo_iter{1,2,3}.txt`, 8.220 caracteres cada; editor conferido por leitura do DOM antes de cada envio).

Depois da rodada:

- [x] Teste final arquivado em `integration_test/fase3/chatgpt/`; doc, resultados, evidências e transcrição commitados juntos na `fase3-e2e`.
- [ ] Codificação manual-first: não se aplica (rodada limpa).

### Ocorrências de método nesta rodada

1. **O print do AVD "logo após o `flutter test` terminar em falha" não captura a falha quando o teste que falha não é o último.** O `flutter test` executa a suíte inteira (9 `testWidgets`) e encerra o app ao final; quando o comando termina, o AVD já está na home. Nos quatro prints desta rodada é isso que aparece. Para o teste que falhou (o 1º de 9), o estado da tela no momento da falha não foi registrado por este mecanismo. Os prints foram mantidos como estão (registro fiel do procedimento). Consequência para as próximas rodadas: anotada no README para decisão do autor (editar o teste gerado para tirar print está fora do protocolo; a alternativa viável é um `screencap` disparado em paralelo ao `flutter test` assim que a primeira linha de falha aparece na saída).
2. **Clipboard:** não houve sobrescrita por outro aplicativo; cada carga foi conferida por tamanho e extremidades antes do Ctrl+V, e o editor por leitura do DOM antes de cada envio.
3. **Renderer do Chrome ocupado:** durante a geração, a aba do ChatGPT ficou ~1,5 min sem responder a capturas de tela ("renderer may be frozen"). Nada foi recarregado (recarregar perde a conversa `/uc/`); a aba voltou sozinha e a conversa seguiu intacta.
4. **Build:** o Gradle já estava em cache nesta máquina (primeiro `seed_test` do dia em ~2 min, os seguintes em ~40 s). Nenhum download de NDK.

---

## Prompt Enviado

Texto entre o segundo e o terceiro `---` de
`fase3-e2e/prompts_prontos/zero-shot/FASE3-E2E-ZS-01_loginFlow.md`, sem
alteração (33.976 caracteres). Não é repetido aqui; o arquivo e o sha256 são o
registro.

---

## Resposta do LLM

Resposta completa, copiada pelo botão "Copiar resposta" do ChatGPT (Markdown,
11.155 caracteres), também em `FASE3-E2E-ZS-01_loginFlow_transcricao/iter0_resposta.md`.
O único bloco Dart é o arquivo salvo, byte a byte. Print:
`evidencias/chatgpt/2026-10-03_FASE3-E2E-ZS-01_loginFlow_resposta_iter0.jpg`.

`````markdown
Abaixo está um teste E2E completo para salvar em `integration_test/fase3/login_test.dart`. Ele usa o `MyApp` real, o Firebase Emulator Suite e cobre sucesso, credenciais inexistentes, campos vazios e senha incorreta.

 integration\_test/fase3/login\_test.dart

```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintonize/main.dart';
import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> abrirLogin(WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

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
    final camposTexto = find.byType(TextFormField);

    expect(camposTexto, findsNWidgets(2));

    await tester.enterText(camposTexto.at(0), email);
    await tester.enterText(camposTexto.at(1), senha);
  }

  testWidgets(
    'login com credenciais válidas navega para a TelaInicialScreen',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: 'senha123',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // A TelaInicialScreen depende de dados do Firestore para carregar
      // nome e recomendação. Primeiro verificamos elementos que só existem
      // nessa tela.
      expect(find.text('Pesquisa Direta'), findsOneWidget);
      expect(find.text('Sintonizados'), findsOneWidget);
      expect(find.text('Mapa'), findsOneWidget);
      expect(find.text('Minha Conta'), findsOneWidget);

      // O usuário previamente populado pelo ambiente deve ser carregado.
      expect(
        find.text(
          'Tester Sintonize, essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // Garante que o usuário realmente está autenticado no Emulator.
      expect(
        FirebaseAuth.instance.currentUser?.email,
        equals('tester@sintonize.test'),
      );
    },
  );

  testWidgets(
    'login com usuário inexistente exibe SnackBar vermelho',
    (tester) async {
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

      final snackBar = tester.widget<SnackBar>(
        find.ancestor(
          of: find.text(
            'Usuário não encontrado. Verifique o e-mail e tente novamente.',
          ),
          matching: find.byType(SnackBar),
        ),
      );

      expect(snackBar.backgroundColor, equals(Colors.red));

      // O login falhou, portanto continuamos na LoginScreen.
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
    },
  );

  testWidgets(
    'login com senha incorreta para usuário existente exibe SnackBar vermelho',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: 'senha-incorreta',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      final mensagem = find.text(
        'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
      );

      expect(mensagem, findsOneWidget);

      final snackBar = tester.widget<SnackBar>(
        find.ancestor(
          of: mensagem,
          matching: find.byType(SnackBar),
        ),
      );

      expect(snackBar.backgroundColor, equals(Colors.red));

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('E-mail'), findsOneWidget);
    },
  );

  testWidgets(
    'campos vazios exibem mensagens de validação e não tentam autenticar',
    (tester) async {
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

      // A validação do Form acontece antes da chamada ao Firebase.
      // Portanto, a LoginScreen continua aberta e nenhum SnackBar
      // de autenticação deve aparecer.
      expect(find.text('Entrar'), findsOneWidget);
      expect(
        find.text(
          'Usuário não encontrado. Verifique o e-mail e tente novamente.',
        ),
        findsNothing,
      );
      expect(
        find.text(
          'Senha incorreta. Certifique-se de que está digitando a senha corretamente.',
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'senha vazia exibe validação sem navegar',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: '',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Por favor, insira sua senha'),
        findsOneWidget,
      );

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsNothing);
    },
  );

  testWidgets(
    'senha com menos de seis caracteres exibe validação sem autenticar',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: '12345',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('A senha deve ter pelo menos 6 caracteres'),
        findsOneWidget,
      );

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsNothing);
    },
  );

  testWidgets(
    'e-mail inválido exibe validação sem autenticar',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'email-invalido',
        senha: 'senha123',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Por favor, insira um e-mail válido'),
        findsOneWidget,
      );

      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('Pesquisa Direta'), findsNothing);
    },
  );

  testWidgets(
    'login válido carrega os dados do usuário na TelaInicialScreen',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: 'senha123',
      );

      await tester.tap(find.text('Entrar'));

      // Dá tempo para a navegação acontecer.
      await tester.pumpAndSettle();

      // A TelaInicialScreen chama FirebaseFirestore para buscar
      // o nome e a recomendação do usuário.
      expect(find.text('Pesquisa Direta'), findsOneWidget);
      expect(find.text('Sintonizados'), findsOneWidget);
      expect(find.text('Mapa'), findsOneWidget);
      expect(find.text('Minha Conta'), findsOneWidget);

      // Aguarda os FutureBuilders da TelaInicialScreen.
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Tester Sintonize, essa é a nossa recomendação de música para você!',
        ),
        findsOneWidget,
      );

      // Como os gêneros do usuário são rock/pop, a recomendação só pode
      // ser uma das duas músicas correspondentes aos dados previamente
      // carregados no Emulator Suite.
      final recomendacoesValidas = <String>{
        'Bohemian Rhapsody',
        'Billie Jean',
      };

      final recomendacaoEncontrada = recomendacoesValidas
          .where((nome) => find.text(nome).evaluate().isNotEmpty)
          .toList();

      expect(
        recomendacaoEncontrada,
        isNotEmpty,
        reason:
            'A TelaInicialScreen deveria recomendar uma música de rock ou pop.',
      );
    },
  );

  testWidgets(
    'usuário autenticado permanece na TelaInicialScreen após o login',
    (tester) async {
      await abrirLogin(tester);

      await preencherLogin(
        tester,
        email: 'tester@sintonize.test',
        senha: 'senha123',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(
        FirebaseAuth.instance.currentUser,
        isNotNull,
      );

      expect(
        FirebaseAuth.instance.currentUser!.email,
        equals('tester@sintonize.test'),
      );

      expect(find.text('Minha Conta'), findsOneWidget);
      expect(find.text('Entrar'), findsNothing);
      expect(find.text('E-mail'), findsNothing);
    },
  );
}
```

 ### Observação importante sobre o teste

 Há um detalhe do código fornecido que merece atenção: `TelaInicialScreen` usa `FirebaseAuth.instance` e `FirebaseFirestore.instance` diretamente, enquanto o `LoginScreen` também usa essas instâncias quando `auth == null`. Isso está **correto para o E2E solicitado**, porque o teste não injeta `auth` nem usa mocks.

 Também deixei a configuração do Emulator Suite exclusivamente no `setUpAll()`:

```
setUpAll(() async {
  await setupFirebaseEmulators();
});
```

 Assim, o teste não cria nem popula usuários/dados — ele utiliza exatamente o usuário e os documentos que o ambiente prepara antes da execução, conforme especificado.

 ### Executar

 Como o arquivo está em `integration_test/fase3/`, você pode executar todos os testes da fase com:

```
flutter test integration_test/fase3/ -d emulator-5554
```

 Ou somente este arquivo:

```
flutter test integration_test/fase3/login_test.dart -d emulator-5554
```

 **Nota:** o teste de login bem-sucedido depende de o documento `usuarios/{uid}` realmente existir para o UID criado no Auth Emulator. O próprio teste não deve criar esse documento, pois você especificou que os dados iniciais são responsabilidade da preparação do ambiente.
`````

---

## Resultado da Execução

| Métrica | Valor |
|---|---|
| **Compilou?** | Sim |
| **Testes gerados** | 9 |
| **Testes passaram (iteração 0)** | 8 |
| **Testes falharam (iteração 0)** | 1 — "login com credenciais válidas navega para a TelaInicialScreen" |
| **Testes passaram (estado final arquivado)** | 8 (arquivo idêntico ao gerado) |
| **Testes falharam (estado final arquivado)** | 1 (o mesmo) |
| **Melhor estado intermediário** | = final (8/9 nas 4 execuções) |
| **Tempo por execução** | iter0: 43 s no total (Gradle 17,6 s + instalação + 17 s de teste); iter1: 39 s (Gradle 15,4 s, 16 s de teste); iter2: 40 s; iter3: 41 s (18 s de teste). Seed: ~40 s por execução. Reinício dos emuladores: ~30 s. |
| **Prints tirados** | `evidencias/chatgpt/FASE3-E2E-ZS-01_loginFlow_iter0.png` … `_iter3.png` — todos mostram a home do Android (ver "Ocorrências de método", item 1) |

A falha é sempre a mesma, nas quatro execuções (diff entre as saídas só em
tempos e ids de objeto): a asserção da linha 67 do teste,
`find.text('Tester Sintonize, essa é a nossa recomendação de música para você!')`,
encontra 0 widgets logo após o primeiro `pumpAndSettle()` que segue o toque em
"Entrar". Depois que esse teste termina, o framework registra
`setState() called after dispose(): _TelaInicialScreenState` com origem em
`_TelaInicialScreenState._loadLastRecommendedMusic` (`package:sintonize/tela-inicial.dart:161`),
anotado como "thrown running a test (but after the test had completed)".

### Saída do terminal (iteração 0)

Arquivo: `resultados/chatgpt/FASE3-E2E-ZS-01_loginFlow_iter0.txt` (148 linhas).

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
00:00 +0: loading C:/Users/Marcos/Desktop/sintonize-fase3/integration_test/fase3/login_zs_test.dart
Running Gradle task 'assembleDebug'...                             17,6s
√ Built build\app\outputs\flutter-apk\app-debug.apk
Installing build\app\outputs\flutter-apk\app-debug.apk...        1.119ms
00:00 +0: (setUpAll)
00:00 +0: login com credenciais válidas navega para a TelaInicialScreen
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Tester Sintonize, essa é a nossa
recomendação de música para você!": []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///C:/Users/Marcos/Desktop/sintonize-fase3/integration_test/fase3/login_zs_test.dart:67:7)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1682:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///C:/Users/Marcos/Desktop/sintonize-fase3/integration_test/fase3/login_zs_test.dart line 67
The test description was:
  login com credenciais válidas navega para a TelaInicialScreen
════════════════════════════════════════════════════════════════════════════════════════════════════
00:04 +0 -1: login com credenciais válidas navega para a TelaInicialScreen [E]
  Test failed. See exception logs above.
  The test description was: login com credenciais válidas navega para a TelaInicialScreen
  
00:04 +0 -1: login com usuário inexistente exibe SnackBar vermelho
00:04 +0 -1: login com credenciais válidas navega para a TelaInicialScreen
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following assertion was thrown running a test (but after the test had completed):
setState() called after dispose(): _TelaInicialScreenState#08b87(lifecycle state: defunct, not
mounted)
This error happens if you call setState() on a State object for a widget that no longer appears in
the widget tree (e.g., whose parent widget no longer includes the widget in its build). This error
can occur when code calls setState() from a timer or an animation callback.
The preferred solution is to cancel the timer or stop listening to the animation in the dispose()
callback. Another solution is to check the "mounted" property of this object before calling
setState() to ensure the object is still in the tree.
This error might indicate a memory leak if setState() is being called because another object is
retaining a reference to this State object after it has been removed from the tree. To avoid memory
leaks, consider breaking the reference to this object during dispose().

When the exception was thrown, this was the stack:
#0      State.setState.<anonymous closure> (package:flutter/src/widgets/framework.dart:1163:9)
#1      State.setState (package:flutter/src/widgets/framework.dart:1198:6)
#2      _TelaInicialScreenState._loadLastRecommendedMusic (package:sintonize/tela-inicial.dart:161:5)
<asynchronous suspension>
════════════════════════════════════════════════════════════════════════════════════════════════════
00:04 +0 -1: login com credenciais válidas navega para a TelaInicialScreen [E]
  Test failed. See exception logs above.
  The test description was: login com credenciais válidas navega para a TelaInicialScreen
  
00:06 +1 -1: login com senha incorreta para usuário existente exibe SnackBar vermelho
00:07 +2 -1: campos vazios exibem mensagens de validação e não tentam autenticar
00:09 +3 -1: senha vazia exibe validação sem navegar
00:10 +4 -1: senha com menos de seis caracteres exibe validação sem autenticar
00:12 +5 -1: e-mail inválido exibe validação sem autenticar
00:13 +6 -1: login válido carrega os dados do usuário na TelaInicialScreen
00:15 +7 -1: usuário autenticado permanece na TelaInicialScreen após o login
00:16 +8 -1: (tearDownAll)
00:17 +8 -1: Some tests failed.
```

---

## Iterative Repair Loop

Nas três iterações o modelo declarou **(B)** e **não entregou nenhuma versão
alterada do teste** ("não vou fornecer uma versão 'corrigida' do teste que
simplesmente aumente esperas ou remova a asserção"). Seguindo o precedente da
reexecução ChatGPT da Fase 2 (`FASE2-ICRASH-ZS`, iteração 3: "Opção aplicada:
nenhuma; arquivo inalterado"), o arquivo foi mantido e **reexecutado** a cada
iteração, com seed limpo, e o resultado registrado como o da iteração. Os
trechos de código que aparecem nas respostas são todos **da aplicação**
(`tela-inicial.dart`: `if (!mounted) return;` antes dos `setState`) ou
exemplos do que o modelo diz que **não** faria no teste; nenhum foi aplicado.

### Iteração 1

- **Motivo da falha:** 8/9; o 1º teste não encontra o texto de saudação com o nome após o `pumpAndSettle()` pós-login; `setState() after dispose` registrado depois do fim do teste.
- **Prompt de reparo enviado:** template fixo + saída literal de `_iter0.txt` (8.220 caracteres) — `FASE3-E2E-ZS-01_loginFlow_transcricao/prompt_reparo_iter1.txt`. [x] sem acréscimo.
- **Resposta do LLM:** completa, 4.993 caracteres — `…_transcricao/iter1_resposta.md`; print `evidencias/chatgpt/2026-10-03_FASE3-E2E-ZS-01_loginFlow_resposta_iter1.jpg`.

`````markdown
## Classificação: **(B) o teste capturou um comportamento potencialmente incorreto da aplicação**

 A falha não deve ser corrigida simplesmente removendo a asserção sobre o nome ou reduzindo o teste a verificar apenas a barra inferior.

 ### O que foi observado

 Após o login válido:

 1. A autenticação foi bem-sucedida.
2. A aplicação navegou para `TelaInicialScreen`.
3. Os elementos da barra inferior apareceram corretamente.
4. Porém, o texto esperado:
    `Tester Sintonize, essa é a nossa recomendação de música para você!`
    ainda não estava presente quando a asserção foi executada.
5. Depois que o primeiro teste terminou e a próxima execução começou, apareceu:

```
setState() called after dispose(): _TelaInicialScreenState
```

 A origem indicada pelo stack trace é exatamente:

```
_TelaInicialScreenState._loadLastRecommendedMusic
```

 na linha:

```
setState(() {
  _currentMusic = lastMusic;
});
```

 ## Por que isso aponta para um problema na aplicação

 O `initState()` da `TelaInicialScreen` dispara uma operação assíncrona:

```
@override
void initState() {
  super.initState();
  _loadLastRecommendedMusic();
}
```

 que posteriormente executa:

```
void _loadLastRecommendedMusic() async {
  final lastMusic = await fetchLastRecommendedMusic();
  setState(() {
    _currentMusic = lastMusic;
  });
}
```

 Não há verificação de `mounted`.

 Se a `TelaInicialScreen` for removida da árvore antes de `fetchLastRecommendedMusic()` terminar, o `setState()` continua sendo executado sobre um `State` já descartado. É exatamente o que o log reportou:

```
setState() called after dispose()
```

 Portanto, há um problema real de ciclo de vida assíncrono na aplicação.

 ### Há ainda um segundo ponto importante

 O `FutureBuilder` que carrega o nome do usuário também depende de uma operação assíncrona:

```
FutureBuilder<String>(
  future: fetchUserName(),
  ...
)
```

 Logo, entrar na `TelaInicialScreen` não significa que o nome do usuário estará disponível no mesmo instante em que a navegação termina.

 O comportamento esperado, considerando os dados fornecidos pelo ambiente, é:

 - autenticar `tester@sintonize.test`;
- navegar para `TelaInicialScreen`;
- buscar `usuarios/{uid}`;
- obter `nome: 'tester sintonize'`;
- formatar para `Tester Sintonize`;
- exibir:

```
Tester Sintonize, essa é a nossa recomendação de música para você!
```

 O teste está correto ao querer verificar esse estado final.

 ## O que **não** devemos fazer

 Não considero correto transformar:

```
expect(
  find.text(
    'Tester Sintonize, essa é a nossa recomendação de música para você!',
  ),
  findsOneWidget,
);
```

 em algo como:

```
expect(find.text('Pesquisa Direta'), findsOneWidget);
```

 e declarar o teste aprovado.

 Isso verificaria somente a navegação, não o **estado da `TelaInicialScreen` após o login**, que faz parte do fluxo solicitado.

 Também não devemos simplesmente remover o teste porque o `setState() after dispose` é um sinal importante de que a aplicação tem uma operação assíncrona cujo ciclo de vida não está protegido.

 ## Correção esperada na aplicação

 A implementação deveria proteger o `setState()`:

```
void _loadLastRecommendedMusic() async {
  final lastMusic = await fetchLastRecommendedMusic();

  if (!mounted) {
    return;
  }

  setState(() {
    _currentMusic = lastMusic;
  });
}
```

 E o mesmo princípio deveria ser aplicado a `_fetchNewMusic()`:

```
void _fetchNewMusic() async {
  final newMusic = await fetchNewMusic();

  if (!mounted) {
    return;
  }

  setState(() {
    _currentMusic = newMusic;
  });
}
```

 Isso corrige especificamente o erro:

```
setState() called after dispose()
```

 ### Entretanto, há uma questão separada no teste

 O fato de a primeira asserção ocorrer antes de o nome aparecer indica também que o teste precisa aguardar **explicitamente o estado assíncrono esperado**, em vez de depender apenas de `pumpAndSettle()` após a navegação.

 Mas, como você determinou que, no caso **B**, não devo alterar o teste para mascarar o problema, **não vou fornecer uma versão "corrigida" do teste que simplesmente aumente esperas ou remova a asserção**.

 O diagnóstico é:

 | Observação | Classificação |
| --- | --- |
| Login válido navega para `TelaInicialScreen` | Comportamento correto |
| Nome do usuário ainda não disponível imediatamente | Operação assíncrona esperada |
| `setState()` ocorre depois de `dispose()` | **Problema potencial na aplicação** |
| Remover a asserção do nome para fazer passar | **Não recomendado** |
| Corrigir `mounted` na `TelaInicialScreen` | **Correção apropriada na aplicação** |

**Conclusão:** a falha deve ser tratada como **(B)**. O teste revelou uma condição de corrida/ciclo de vida assíncrono em `TelaInicialScreen`; não é apropriado enfraquecê-lo para obter um resultado verde.
`````

- **★ Autoclassificação do modelo:** **(B)** — "o teste capturou um comportamento potencialmente incorreto da aplicação".
- **Opção aplicada:** nenhuma; arquivo inalterado (o modelo não entregou teste).
- **Resultado após correção:** **8/9 — Falhou**, idêntico à iteração 0. `resultados/chatgpt/FASE3-E2E-ZS-01_loginFlow_iter1.txt`.
- **Print:** `evidencias/chatgpt/FASE3-E2E-ZS-01_loginFlow_iter1.png` (home do Android).

### Iteração 2

- **Motivo da falha:** o mesmo.
- **Prompt de reparo enviado:** template fixo + saída literal de `_iter1.txt` (8.220 caracteres) — `…_transcricao/prompt_reparo_iter2.txt`. [x] sem acréscimo.
- **Resposta do LLM:** completa, 4.226 caracteres — `…_transcricao/iter2_resposta.md`; print `…_resposta_iter2.jpg`.

`````markdown
## Classificação: **(B) o teste capturou um comportamento potencialmente incorreto da aplicação**

 O novo log confirma o diagnóstico anterior; portanto, **não devemos enfraquecer nem remover a asserção** sobre o estado da `TelaInicialScreen`.

 ### Comportamento observado

 O login válido aparentemente funciona:

 - `tester@sintonize.test` é autenticado.
- A navegação para `TelaInicialScreen` ocorre.
- Os elementos da `BottomNavigationBar` aparecem.
- Porém, a busca assíncrona dos dados da tela não termina de forma consistente antes de o widget ser descartado.

 O erro mais importante continua sendo:

```
setState() called after dispose(): _TelaInicialScreenState
```

 com origem em:

```
_TelaInicialScreenState._loadLastRecommendedMusic
```

 especificamente no `setState()` depois do `await fetchLastRecommendedMusic()`.

 ### Comportamento esperado

 Com os dados fornecidos pelo ambiente, depois de um login válido a `TelaInicialScreen` deveria conseguir consultar:

```
usuarios/{uid}
```

 e obter:

```
nome: "tester sintonize"
generos_favoritos: ["rock", "pop"]
```

 Consequentemente, o estado da tela deveria eventualmente conter o nome formatado:

```
Tester Sintonize, essa é a nossa recomendação de música para você!
```

 O teste está correto em verificar esse estado. A especificação não diz apenas que a navegação deve ocorrer; ela diz explicitamente:

 > credenciais válidas levam à `TelaInicialScreen`

 e o fluxo E2E deve testar a navegação **e o estado da tela inicial**.

 ### O problema na aplicação

 Há uma operação assíncrona iniciada no `initState()`:

```
@override
void initState() {
  super.initState();
  _loadLastRecommendedMusic();
}
```

 que posteriormente faz:

```
void _loadLastRecommendedMusic() async {
  final lastMusic = await fetchLastRecommendedMusic();

  setState(() {
    _currentMusic = lastMusic;
  });
}
```

 Se a tela for descartada enquanto `fetchLastRecommendedMusic()` aguarda Firebase, esse `setState()` passa a operar sobre um `State` que já não está montado.

 O próprio Flutter identifica isso no log:

```
setState() called after dispose()
```

 Portanto, não é um falso positivo produzido pela asserção do teste.

 ### Por que `pumpAndSettle()` não resolve isso

 `pumpAndSettle()` aguarda frames pendentes de animação/renderização, mas não deve ser tratado como uma garantia de que todas as operações assíncronas externas — neste caso, leituras do Firestore — terminaram.

 Além disso, o problema de `setState()` após `dispose()` é independente da duração da espera: **o código da aplicação não verifica se o `State` continua montado depois do `await`.**

 ### Correção apropriada na aplicação

 O código deveria, no mínimo, fazer:

```
void _loadLastRecommendedMusic() async {
  final lastMusic = await fetchLastRecommendedMusic();

  if (!mounted) {
    return;
  }

  setState(() {
    _currentMusic = lastMusic;
  });
}
```

 E o mesmo cuidado é necessário em:

```
void _fetchNewMusic() async {
  final newMusic = await fetchNewMusic();

  if (!mounted) {
    return;
  }

  setState(() {
    _currentMusic = newMusic;
  });
}
```

 Isso trata o erro de ciclo de vida que o teste revelou.

 ## Um detalhe adicional que merece investigação

 Existe ainda uma possibilidade independente: o documento do usuário pode não estar sendo encontrado pelo Firestore Emulator.

 Nesse caso, `fetchUserName()` retorna:

```
return 'Usuário';
```

 em vez de `tester sintonize`.

 E `fetchLastRecommendedMusic()` pode produzir uma recomendação diferente dependendo do conteúdo retornado.

 Isso pode ser diagnosticado sem alterar a asserção. O teste deve continuar exigindo o comportamento especificado; se o documento preparado pelo ambiente não estiver acessível, isso é outro problema de configuração/inicialização do E2E, não motivo para aceitar qualquer texto.

 **Conclusão: B.** O teste não deve ser alterado para aceitar a ausência do nome. O log mostra uma falha real de ciclo de vida assíncrono em `TelaInicialScreen`, e a correção deve ser feita na aplicação antes de considerar esse cenário E2E aprovado.
`````

- **★ Autoclassificação do modelo:** **(B)**. Acrescenta uma segunda hipótese, "o documento `usuarios/{uid}` pode não estar sendo encontrado", e mesmo assim não altera o teste.
- **Opção aplicada:** nenhuma; arquivo inalterado.
- **Resultado após correção:** **8/9 — Falhou**, idêntico. `…_iter2.txt`.
- **Print:** `…_iter2.png` (home do Android).

### Iteração 3 (máximo)

- **Motivo da falha:** o mesmo.
- **Prompt de reparo enviado:** template fixo + saída literal de `_iter2.txt` (8.220 caracteres) — `…_transcricao/prompt_reparo_iter3.txt`. [x] sem acréscimo.
- **Resposta do LLM:** completa, 3.819 caracteres — `…_transcricao/iter3_resposta.md`; print `…_resposta_iter3.jpg`.

`````markdown
## Classificação: **(B) o teste capturou um comportamento potencialmente incorreto da aplicação**

 O novo resultado é essencialmente idêntico ao anterior e reforça a mesma conclusão. **Não vou alterar a asserção para fazê-la passar.**

 ### Comportamento observado

 O fluxo chega à `TelaInicialScreen`, mas a aplicação não apresenta o estado esperado:

```
Tester Sintonize, essa é a nossa recomendação de música para você!
```

 A asserção falha com:

```
Found 0 widgets with text "Tester Sintonize, essa é a nossa
recomendação de música para você!"
```

 Mais importante, posteriormente o Flutter registra:

```
setState() called after dispose(): _TelaInicialScreenState
```

 com origem em:

```
_TelaInicialScreenState._loadLastRecommendedMusic
```

 na linha 161.

 ### Comportamento esperado

 Depois de:

```
tester@sintonize.test
senha123
```

 o fluxo esperado é:

```
HomeScreen
   ↓
LoginScreen
   ↓
Firebase Auth Emulator
   ↓
TelaInicialScreen
   ↓
Firestore Emulator
   ↓
usuarios/{uid}
   ↓
nome = "tester sintonize"
   ↓
"Tester Sintonize, essa é a nossa recomendação de música para você!"
```

 Portanto, verificar esse texto **não é uma suposição indevida do teste**. É uma verificação legítima do estado da tela depois do login, especialmente porque o código fornecido explicitamente busca o nome do usuário no Firestore.

 ### O problema concreto na aplicação

 O código atual possui:

```
void _loadLastRecommendedMusic() async {
  final lastMusic = await fetchLastRecommendedMusic();

  setState(() {
    _currentMusic = lastMusic;
  });
}
```

 Depois de um `await`, o widget pode ter sido desmontado. O código deveria verificar `mounted` antes do `setState`:

```
void _loadLastRecommendedMusic() async {
  final lastMusic = await fetchLastRecommendedMusic();

  if (!mounted) {
    return;
  }

  setState(() {
    _currentMusic = lastMusic;
  });
}
```

 Há o mesmo risco em:

```
void _fetchNewMusic() async {
  final newMusic = await fetchNewMusic();

  if (!mounted) {
    return;
  }

  setState(() {
    _currentMusic = newMusic;
  });
}
```

 ### Um ponto que eu investigaria antes de qualquer mudança no teste

 O log não mostra **por que** o texto não apareceu. Há duas possibilidades dentro da aplicação:

 1. A consulta ao Firestore está demorando e o teste chega à asserção antes do `FutureBuilder` receber o nome.
2. O documento `usuarios/{uid}` não está sendo encontrado pelo app, fazendo `fetchUserName()` retornar `"Usuário"`.

 A segunda possibilidade é especialmente importante porque o helper chama:

```
await Firebase.initializeApp(...);
await FirebaseAuth.instance.useAuthEmulator(...);
FirebaseFirestore.instance.useFirestoreEmulator(...);
```

 enquanto o `main()` do aplicativo também executa:

```
await Firebase.initializeApp(...);
```

 No E2E real, precisamos garantir que **a mesma instância/configuração do Firebase usada pelo app esteja efetivamente apontando para os emuladores**.

 Mas isso deve ser diagnosticado, não mascarado no teste.

 ### Portanto

 Não recomendo nenhuma destas alterações:

```
expect(find.text('Pesquisa Direta'), findsOneWidget);
```

 no lugar da asserção atual;

 ou:

```
expect(find.byType(TelaInicialScreen), findsOneWidget);
```

 como substituição;

 ou aceitar `"Usuário"` como resultado válido.

 Todas elas reduziriam o escopo e poderiam transformar um defeito da aplicação/configuração em um falso positivo.

 **Classificação final: B.** O teste está revelando um problema potencial na aplicação — confirmado pelo `setState() called after dispose()` — e a ausência do estado esperado da \`TelaInicialScreen ainda precisa ser investigada, não escondida pelo teste.
`````

- **★ Autoclassificação do modelo:** **(B)** ("Classificação final: B"). Levanta ainda a hipótese de o app e o helper não compartilharem a configuração dos emuladores, e diz que isso "deve ser diagnosticado, não mascarado no teste".
- **Opção aplicada:** nenhuma; arquivo inalterado.
- **Resultado após correção:** **8/9 — Falhou**, idêntico. `resultados/chatgpt/FASE3-E2E-ZS-01_loginFlow_iter3_final.txt`.
- **Print:** `…_iter3.png` (home do Android).

---

## ★ Análise de Autoclassificação

| Campo | Valor |
|---|---|
| **★ Autoclassificação do modelo** | **(B)** nas três iterações, sem alteração do teste em nenhuma. |
| **★ Classificação humana (auditoria)** | **Erro de teste** (timing): a asserção do nome é executada logo após o primeiro `pumpAndSettle()`, que assenta antes de o `FutureBuilder<String>(future: fetchUserName())` da `TelaInicialScreen` receber o Firestore. A prova está no próprio arquivo: o 8º teste ("login válido carrega os dados do usuário na TelaInicialScreen") faz um **segundo** `pumpAndSettle()` e então afirma **exatamente o mesmo texto** — e passa nas quatro execuções. O documento `usuarios/{uid}` existe e o nome chega; a hipótese do modelo de "documento não encontrado" é refutada pelo mesmo teste. |
| **★ Concordância** | **Não.** |
| **★ Observações** | 1) **O `setState() called after dispose()` é real**, está em `lib/tela-inicial.dart:161` (`_loadLastRecommendedMusic` sem checar `mounted`; `_fetchNewMusic`, linha 140, idem) e o arquivo é idêntico ao de `main` — é defeito pré-existente da aplicação, **não** um dos bugs da Fase 3 (L4/C3/P2) e não está plantado nesta rodada. Mas ele é registrado "after the test had completed", quando a tela já foi descartada pelo teste seguinte; **não causa** a asserção falhar. O modelo acertou um diagnóstico de código e errou a causa da falha. 2) **Diz e não faz, invertido em relação à Fase 2:** aqui o modelo cumpre à risca a regra do (B) — não toca no teste — e com isso perde as três iterações sem corrigir um problema de espera que ele mesmo descreve ("o teste precisa aguardar explicitamente o estado assíncrono esperado", iteração 1) e que ele mesmo resolveu, por acaso, no 8º teste. 3) O modelo nunca olhou o resto da própria saída: 8 testes passando, incluindo o 8º, estavam nas três saídas que recebeu. 4) Não propôs mudanças fora do teste além do `mounted` em `tela-inicial.dart`; nada fora do teste foi aplicado. 5) Mesma armadilha de timing que a referência (`_referencia/login_flow_test.dart`) enfrentou no run 3 de 2026-09-28 e resolveu com `pumpAte()`/`pumpAteSumir()`; a referência não entrou na conversa. |

**Nota de fronteira com "Falha de ambiente":** o template lista como ambiente
o `pumpAndSettle` que *nunca assenta*. Aqui é o oposto: assenta cedo demais,
porque leituras do Firestore não são frames pendentes. É uma propriedade do
teste gerado (asserção sem espera pelo estado assíncrono), não do dispositivo
nem dos emuladores; por isso, **Erro de teste**. O caso fica registrado como
limítrofe para a análise agregada.

---

## Codificação manual-first

Não se aplica — rodada limpa, sem bug plantado.
