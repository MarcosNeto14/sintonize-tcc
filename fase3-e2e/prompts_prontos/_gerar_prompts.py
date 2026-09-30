# -*- coding: utf-8 -*-
"""Gera os 9 prompts da Fase 3 (E2E) a partir dos prompts de integração da
Fase 2. Rodar na raiz do repo com o lib/ limpo (git diff ccae44a -- lib/ vazio):

    PYTHONIOENCODING=utf-8 python fase3-e2e/prompts_prontos/_gerar_prompts.py

O código das telas e o helper são lidos do disco, verbatim. O bloco de
material fixo ("Ambiente de execução") é uma única string, idêntica nos 9
arquivos; o sha256 dele e o de cada arquivo vão para _sha256.txt.
"""
import io, re, hashlib, os

def read(p):
    return io.open(p, encoding='utf-8').read()

def descricao_fase2(n, flow):
    s = read(f'fase2/prompts_prontos/integration/zero-shot/FASE2-INT-ZS-{n}_{flow}.md')
    body = s.split('## Prompt (selecionar', 1)[1]
    m = re.search(r'para o seguinte fluxo do aplicativo Flutter "Sintonize":\n\n(.+?)\n\n', body, re.S)
    return m.group(1).strip()

FLUXOS = [
    dict(n='01', flow='loginFlow',
         alvo='fluxo de login — tela de boas-vindas → `LoginScreen` → `TelaInicialScreen`',
         arquivos=['lib/main.dart', 'lib/login.dart', 'lib/tela-inicial.dart'],
         zs_fim=['Teste o fluxo completo ponta a ponta: interações na LoginScreen → navegação → estado da TelaInicialScreen',
                 'Teste também cenários de erro (credenciais inválidas, campos vazios, senha incorreta para um usuário existente)'],
         cot_dep='Firebase Auth, Firestore',
         cot_cen=['Fluxo de sucesso ponta a ponta (interação → navegação → estado final)',
                  'Erros de validação (campos inválidos antes de disparar Firebase)',
                  'Erros do Firebase (credenciais incorretas, usuário inexistente)',
                  'Estados intermediários visíveis ao usuário (loading, mensagens de erro)'],
         fs_titulo='fluxo de logout', fs_exemplo='EXEMPLO_LOGOUT'),
    dict(n='02', flow='cadastroFlow',
         alvo='fluxo de cadastro — tela de boas-vindas → `CadastroScreen` → `GenerosCadastroScreen` → `TelaInicialScreen`',
         arquivos=['lib/main.dart', 'lib/cadastro.dart', 'lib/generos-cadastro.dart', 'lib/tela-inicial.dart'],
         zs_fim=['Teste o fluxo completo ponta a ponta: interações na CadastroScreen → navegação → interação na GenerosCadastroScreen → estado final na TelaInicialScreen',
                 'Teste também cenários de erro (validação dos campos, e-mail já cadastrado, nenhum gênero selecionado ao confirmar)'],
         cot_dep='Firebase Auth, Firestore, HTTP',
         cot_cen=['Fluxo de sucesso ponta a ponta (interação → navegação → estado final)',
                  'Erros de validação (campos inválidos antes de disparar Firebase)',
                  'Erros do Firebase e do fluxo (e-mail já cadastrado, nenhum gênero selecionado ao confirmar)',
                  'Estados intermediários visíveis ao usuário (loading, mensagens de erro)'],
         fs_titulo='fluxo de edição de perfil', fs_exemplo='EXEMPLO_PERFIL'),
    dict(n='03', flow='playlistFlow',
         alvo='fluxo de criar playlist — tela de boas-vindas → `LoginScreen` → `TelaInicialScreen` → `UsuarioScreen` → `CriarPlaylistScreen`',
         arquivos=['lib/main.dart', 'lib/login.dart', 'lib/tela-inicial.dart', 'lib/usuario.dart', 'lib/criar_playlist.dart'],
         zs_fim=['Faça login pela interface com o usuário já existente nos emuladores antes de chegar à CriarPlaylistScreen; a coleção `musica` já está populada',
                 'Teste o fluxo completo ponta a ponta: navegação até a tela → busca de músicas → digitar nome → selecionar músicas → salvar → verificar o documento persistido na coleção `playlists` (incluindo que o campo `nome` corresponde exatamente ao valor digitado, não um valor fixo)',
                 'Teste também cenários de erro (nome vazio não deve salvar a playlist)'],
         cot_dep='Firebase Auth, Firestore',
         cot_cen=['Fluxo de sucesso ponta a ponta (navegação até a tela → busca de músicas → seleção → salvar → documento persistido corretamente)',
                  'Validação antes de salvar (nome vazio não deve salvar a playlist)',
                  'Pesquisa e filtragem da lista de músicas',
                  'Estados intermediários visíveis ao usuário (carregando músicas, SnackBars)'],
         fs_titulo='fluxo de recuperação de senha', fs_exemplo='EXEMPLO_SENHA'),
]

HELPER = read('integration_test/firebase_test_helper.dart').rstrip('\n')

FIXO = """Ambiente de execução (igual para todos os fluxos):

- O teste é end-to-end: roda o aplicativo real em um emulador Android (`emulator-5554`), contra os emuladores locais do Firebase (Auth em `10.0.2.2:9099` e Firestore em `10.0.2.2:8080`). Não há mocks: as telas usam `FirebaseAuth.instance` e `FirebaseFirestore.instance`, apontados para os emuladores pelo helper abaixo, que já existe no projeto.
- Chame `await setupFirebaseEmulators();` em um `setUpAll()`, antes de qualquer interação, importando-o com `import '../firebase_test_helper.dart';`.

```dart
// ===== integration_test/firebase_test_helper.dart =====
""" + HELPER + """
```

- Os emuladores são reiniciados e populados antes de cada execução com:
  - um usuário no Auth: e-mail `tester@sintonize.test`, senha `senha123`, com o documento `usuarios/{uid}` contendo `nome: 'tester sintonize'` e `generos_favoritos: ['rock', 'pop']`;
  - cinco documentos na coleção `musica` (campos `track_name`, `artist_name`, `genre`): `bohemian rhapsody` / `queen` / `rock`; `billie jean` / `michael jackson` / `pop`; `take five` / `dave brubeck` / `jazz`; `the thrill is gone` / `b.b. king` / `blues`; `one love` / `bob marley` / `reggae`.
  Qualquer outro usuário ou dado tem de ser criado pelo próprio teste, pela interface.
- Navegação no app a partir do início (`MyApp`, em `lib/main.dart`): a tela de boas-vindas mostra "Bem-vindo ao Sintonize!" e os botões "Login" e "Cadastro". "Login" abre a LoginScreen, e "Entrar" com credenciais válidas leva à TelaInicialScreen. "Cadastro" abre a CadastroScreen; "Cadastrar" leva à GenerosCadastroScreen e "Confirmar" à TelaInicialScreen. Na TelaInicialScreen, "Minha Conta" na barra inferior abre a UsuarioScreen, onde "Criar Playlist" abre a CriarPlaylistScreen.
- O arquivo será salvo em `integration_test/fase3/` e executado com `flutter test integration_test/fase3/<nome>_test.dart -d emulator-5554`."""

REQ_COMUNS_INICIO = [
    'Use `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` e `testWidgets()` do flutter_test',
    'Monte o aplicativo real com `await tester.pumpWidget(const MyApp());` e navegue pela interface a partir da tela de boas-vindas; não monte as telas isoladamente nem use mocks',
    'Chame o helper dos emuladores em `setUpAll()` (ver "Ambiente de execução")',
]
REQ_COMUNS_FIM = [
    'Os testes devem ser executáveis com `flutter test integration_test/fase3/ -d emulator-5554`',
    "Use `import 'package:sintonize/...'` para os imports do projeto",
]

ESPERAR = """  Future<void> esperar(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 250));
      if (finder.evaluate().isNotEmpty) return;
    }
    fail('não apareceu: $finder');
  }
"""

CABECA_EX = """import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meu_app/main.dart';
"""

SETUP_EX = """
import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

""" + ESPERAR

LOGIN_EX = """    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'user@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'senha123');
    await tester.tap(find.text('Acessar'));
"""

EXEMPLOS = {
'EXEMPLO_LOGOUT': CABECA_EX + """import 'package:meu_app/conta_screen.dart';
import 'package:meu_app/boas_vindas_screen.dart';
""" + SETUP_EX + """
  testWidgets('logout: sair da conta volta para a tela de boas-vindas',
      (tester) async {
""" + LOGIN_EX + """    await esperar(tester, find.byType(ContaScreen));

    await tester.tap(find.text('Sair'));
    await esperar(tester, find.byType(BoasVindasScreen));

    expect(find.byType(ContaScreen), findsNothing);
    expect(find.text('Entrar'), findsOneWidget);
  });
}""",
'EXEMPLO_PERFIL': CABECA_EX + """import 'package:meu_app/editar_perfil_screen.dart';
""" + SETUP_EX + """
  testWidgets('editar perfil: novo nome é salvo e aparece na tela',
      (tester) async {
""" + LOGIN_EX + """    await esperar(tester, find.text('Editar perfil'));

    await tester.tap(find.text('Editar perfil'));
    await esperar(tester, find.byType(EditarPerfilScreen));
    await tester.enterText(find.byType(TextFormField).first, 'Novo Nome');
    await tester.tap(find.text('Salvar'));
    await esperar(tester, find.text('Perfil atualizado'));

    expect(find.text('Novo Nome'), findsOneWidget);
  });

  testWidgets('editar perfil: nome vazio mostra erro e não salva',
      (tester) async {
""" + LOGIN_EX + """    await esperar(tester, find.text('Editar perfil'));

    await tester.tap(find.text('Editar perfil'));
    await esperar(tester, find.byType(EditarPerfilScreen));
    await tester.enterText(find.byType(TextFormField).first, '');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('O nome é obrigatório'), findsOneWidget);
    expect(find.byType(EditarPerfilScreen), findsOneWidget);
  });
}""",
'EXEMPLO_SENHA': CABECA_EX + """import 'package:meu_app/recuperar_senha_screen.dart';
""" + SETUP_EX + """
  testWidgets('recuperar senha: e-mail cadastrado recebe confirmação',
      (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Esqueci minha senha'));
    await esperar(tester, find.byType(RecuperarSenhaScreen));

    await tester.enterText(find.byType(TextFormField).first, 'user@test.com');
    await tester.tap(find.text('Enviar'));
    await esperar(tester, find.text('E-mail de recuperação enviado'));

    expect(find.byType(RecuperarSenhaScreen), findsOneWidget);
  });

  testWidgets('recuperar senha: e-mail inválido mostra erro de validação',
      (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Esqueci minha senha'));
    await esperar(tester, find.byType(RecuperarSenhaScreen));

    await tester.enterText(find.byType(TextFormField).first, 'nao-e-um-email');
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe um e-mail válido'), findsOneWidget);
  });
}""",
}

REPARO = """## Prompt de reparo (usar na **mesma** conversa, se o teste falhar — máx. 3 iterações)

---

O teste falhou com o seguinte erro:

```
[COLAR A SAÍDA DE ERRO DO TERMINAL AQUI]
```

Antes de corrigir, classifique a causa provável da falha:
(A) o teste presume um comportamento que não é o especificado, ou
(B) o teste capturou um comportamento potencialmente incorreto da aplicação.
Declare essa classificação explicitamente antes de prosseguir.

Se (A): corrija o teste normalmente.

Se (B): não enfraqueça a asserção nem reduza o escopo do teste para
fazê-lo passar. Descreva o comportamento observado, o comportamento
esperado, e por que você suspeita de um problema na aplicação, em vez de
alterar o teste.

---
"""

def bloco_codigo(arquivos):
    partes = [f'// ===== {a} =====\n' + read(a).rstrip('\n') for a in arquivos]
    return '```dart\n' + '\n\n'.join(partes) + '\n```'

def cabecalho(fx, sigla, nome_estr):
    arqs = ', '.join(f'`{a}`' for a in fx['arquivos'])
    return f"""# FASE3-E2E-{sigla}-{fx['n']}_{fx['flow']}

**Nível:** E2E (integration_test, no AVD, contra os emuladores Firebase) | **Estratégia:** {nome_estr}
**Alvo:** {fx['alvo']} ({arqs})
**Conversa nova:** sim — uma conversa por rodada, sem contexto anterior

> **Notas de protocolo (para o operador — NÃO fazem parte do prompt):**
>
> - Este mesmo arquivo serve para a **rodada limpa** e para a **rodada com bug**
>   do fluxo (L4 / C3 / P2, ver `fase3-e2e/README.md`). O prompt é idêntico nos
>   dois casos e **nada nele menciona bug**. O que muda é só o `lib/` do
>   worktree em que o teste gerado é executado.
> - Código das telas colado **verbatim e completo** a partir do `lib/` limpo
>   (`ccae44a`), sem simplificação. Nas rodadas com bug o modelo recebe este
>   mesmo código limpo; o bug está apenas no app executado.
> - O bloco "Ambiente de execução" é byte-idêntico nos 9 prompts (sha256 em
>   `prompts_prontos/_sha256.txt`). Não adaptar para o Gemini nem para o ChatGPT.
> - Os testes de `integration_test/_referencia/` **não podem** entrar nesta
>   conversa, nem no prompt de geração, nem no de reparo.
> - Derivado de `fase2/prompts_prontos/integration/…/FASE2-INT-{sigla}-{fx['n']}_{fx['flow']}.md`:
>   mesma estrutura; o que era mock virou emulador + navegação real.


---

## Prompt (selecionar tudo abaixo desta linha até o próximo `---` e colar no modelo da rodada — ChatGPT ou Gemini)

---

"""

def zs(fx, desc):
    req = REQ_COMUNS_INICIO + fx['zs_fim'] + REQ_COMUNS_FIM
    return (cabecalho(fx, 'ZS', 'Zero-shot')
        + 'Gere um teste end-to-end em Dart, com o pacote integration_test do Flutter, para o seguinte fluxo do aplicativo Flutter "Sintonize":\n\n'
        + desc + '\n\nCódigo das telas envolvidas:\n\n' + bloco_codigo(fx['arquivos']) + '\n\n' + FIXO
        + '\n\nRequisitos:\n' + '\n'.join(f'- {r}' for r in req) + '\n\n---\n\n' + REPARO)

def fs(fx, desc):
    ex = EXEMPLOS[fx['fs_exemplo']]
    return (cabecalho(fx, 'FS', 'Few-shot')
        + 'Gere um teste end-to-end em Dart, com o pacote integration_test do Flutter, para o fluxo do aplicativo Flutter "Sintonize" descrito abaixo.\n\n'
        + f'Antes, veja um exemplo de teste end-to-end de outro aplicativo, que roda o app real em um emulador contra os emuladores do Firebase e cobre um {fx["fs_titulo"]}:\n\n'
        + f'**Exemplo — teste end-to-end de um {fx["fs_titulo"]}:**\n```dart\n{ex}\n```\n\n'
        + 'Agora, gere um teste end-to-end para o seguinte fluxo:\n\n' + desc
        + '\n\nCódigo das telas envolvidas:\n\n' + bloco_codigo(fx['arquivos']) + '\n\n' + FIXO
        + "\n\nUse `import 'package:sintonize/...'` para os imports do projeto.\n\n---\n\n" + REPARO)

def cot(fx, desc):
    cen = '\n'.join(f'   - {c}' for c in fx['cot_cen'])
    return (cabecalho(fx, 'COT', 'Chain-of-Thought')
        + 'Quero que você gere um teste end-to-end em Dart, com o pacote integration_test do Flutter, para o fluxo do aplicativo Flutter "Sintonize" descrito abaixo. Antes de escrever os testes, siga estes passos:\n\n'
        + '1. **Analise o fluxo:** Descreva em 3-5 frases o que acontece do início ao fim do fluxo, quais são os pontos de decisão (sucesso/erro) e quais telas estão envolvidas.\n'
        + f'2. **Identifique as dependências:** Liste quais serviços ({fx["cot_dep"]}) são acionados em cada tela, o que cada tela lê ou grava nos emuladores e quais dados já existem neles antes do teste.\n'
        + '3. **Monte o caminho de navegação:** Descreva, a partir da tela de boas-vindas do aplicativo real, quais toques levam à tela do fluxo e como esperar cada transição e cada resposta dos emuladores nos testes.\n'
        + f'4. **Identifique os cenários de teste:** Liste todos os cenários do fluxo completo:\n{cen}\n'
        + '5. **Escreva os testes:** Para cada cenário, escreva um testWidgets() completo.\n\n'
        + 'IMPORTANTE: Não modifique o código das telas. Apenas gere os testes.\n\n'
        + 'Fluxo a testar:\n\n' + desc
        + '\n\nCódigo das telas envolvidas:\n\n' + bloco_codigo(fx['arquivos']) + '\n\n' + FIXO
        + "\n\nUse `import 'package:sintonize/...'` para os imports do projeto.\n\n---\n\n" + REPARO)

def sha(s):
    return hashlib.sha256(s.encode('utf-8')).hexdigest()

if __name__ == '__main__':
    linhas = []
    for fx in FLUXOS:
        desc = descricao_fase2(fx['n'], fx['flow'])
        for pasta, sigla, fn in [('zero-shot', 'ZS', zs), ('few-shot', 'FS', fs), ('cot', 'COT', cot)]:
            texto = fn(fx, desc)
            corpo = texto.split('## Prompt (selecionar')[1]
            assert texto.count(FIXO) == 1
            # 'debugShowCheckedModeBanner' (lib/main.dart) contém 'bug'; o que se proíbe é a palavra.
            assert not re.search(r'(?<![a-z])bug', corpo, re.I), 'prompt menciona bug'
            assert '_referencia' not in corpo
            os.makedirs(f'fase3-e2e/prompts_prontos/{pasta}', exist_ok=True)
            p = f'fase3-e2e/prompts_prontos/{pasta}/FASE3-E2E-{sigla}-{fx["n"]}_{fx["flow"]}.md'
            io.open(p, 'w', encoding='utf-8', newline='\n').write(texto)
            linhas.append((p, sha(texto)))
            print(p, len(texto.splitlines()), 'linhas')
    print('sha256 do bloco fixo:', sha(FIXO))
    io.open('fase3-e2e/prompts_prontos/_sha256.txt', 'w', encoding='utf-8', newline='\n').write(
        f'# sha256 do bloco "Ambiente de execução" (idêntico nos 9): {sha(FIXO)}\n'
        + ''.join(f'{h}  {os.path.basename(p)}\n' for p, h in linhas))
