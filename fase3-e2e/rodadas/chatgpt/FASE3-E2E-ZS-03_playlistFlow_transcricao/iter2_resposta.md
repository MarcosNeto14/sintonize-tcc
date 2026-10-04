## Classificação

 Há **duas causas distintas** no log:

 1. **Falha que derrubou o primeiro teste: (A) — o teste presume um comportamento que não é especificado.**
    O teste exigiu que, após o login, existisse um texto contendo `"essa é a nossa recomendação"`. Porém, o requisito especifica que um login válido **leva à `TelaInicialScreen`**; ele não especifica que esse texto necessariamente estará presente naquele momento.
    A própria `TelaInicialScreen` possui carregamentos assíncronos e pode exibir diferentes estados para a recomendação. Portanto, essa asserção foi excessivamente específica.
2. **`setState() called after dispose()`: (B) — comportamento potencialmente incorreto da aplicação.**
    Esse segundo erro é diferente e **não deve ser mascarado pelo teste**. O stack trace aponta diretamente para:

   ```
   _TelaInicialScreenState._loadLastRecommendedMusic
   lib/tela-inicial.dart:161
   ```
    O método `_loadLastRecommendedMusic()` faz uma operação assíncrona e depois chama `setState()` sem verificar `mounted`. Se a `TelaInicialScreen` for removida enquanto a operação ainda está pendente, ocorre exatamente o erro observado.
    O comportamento esperado é que uma operação assíncrona não chame `setState()` depois que seu `State` foi descartado.

 ### Correção do teste

 Para o problema **(A)**, a verificação após o login deve usar algo que o fluxo realmente especifica e que identifica a `TelaInicialScreen`. A barra inferior contém `Minha Conta`, então ela é uma boa âncora.

 Não vou alterar o teste para esconder o `setState() after dispose`: esse problema pertence à aplicação e deve ser corrigido nela.

 Segue o teste revisado:

 integration\_test/fase3/playlist\_zs\_test.dart

```
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sintonize/main.dart';

import '../firebase_test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupFirebaseEmulators();
  });

  Future<void> login(
    WidgetTester tester, {
    String email = 'tester@sintonize.test',
    String senha = 'senha123',
  }) async {
    // Tela de boas-vindas.
    expect(find.text('Bem-vindo ao Sintonize!'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget);

    final campos = find.byType(TextFormField);
    expect(campos, findsNWidgets(2));

    await tester.enterText(campos.at(0), email);
    await tester.enterText(campos.at(1), senha);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    // O comportamento especificado é que um login válido leve
    // à TelaInicialScreen. "Minha Conta" faz parte da BottomNavigationBar
    // dessa tela.
    expect(find.text('Minha Conta'), findsOneWidget);
  }

  Future<void> navegarParaCriarPlaylist(WidgetTester tester) async {
    // TelaInicialScreen -> UsuarioScreen.
    await tester.tap(find.text('Minha Conta'));
    await tester.pumpAndSettle();

    expect(find.text('Criar Playlist'), findsOneWidget);

    // UsuarioScreen -> CriarPlaylistScreen.
    await tester.tap(find.text('Criar Playlist'));
    await tester.pumpAndSettle();

    expect(find.text('Criando Playlist'), findsOneWidget);
  }

  testWidgets(
    'E2E - cria playlist com músicas e persiste no Firestore',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await login(tester);
      await navegarParaCriarPlaylist(tester);

      // A CriarPlaylistScreen deve buscar as músicas no Firestore
      // durante o initState().
      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsOneWidget,
      );
      expect(
        find.text('Billie Jean - Michael Jackson'),
        findsOneWidget,
      );
      expect(
        find.text('Take Five - Dave Brubeck'),
        findsOneWidget,
      );

      const nomePlaylist = 'Playlist E2E - Rock e Pop';

      final campos = find.byType(TextField);
      expect(campos, findsNWidgets(2));

      // Primeiro TextField: Nome da Playlist.
      await tester.enterText(campos.at(0), nomePlaylist);

      // Encontra o ListTile da primeira música.
      final bohemianTile = find.ancestor(
        of: find.text('Bohemian Rhapsody - Queen'),
        matching: find.byType(ListTile),
      );

      // Encontra o ListTile da segunda música.
      final billieJeanTile = find.ancestor(
        of: find.text('Billie Jean - Michael Jackson'),
        matching: find.byType(ListTile),
      );

      expect(bohemianTile, findsOneWidget);
      expect(billieJeanTile, findsOneWidget);

      // Seleciona Bohemian Rhapsody.
      await tester.tap(
        find.descendant(
          of: bohemianTile,
          matching: find.byType(IconButton),
        ),
      );

      // Seleciona Billie Jean.
      await tester.tap(
        find.descendant(
          of: billieJeanTile,
          matching: find.byType(IconButton),
        ),
      );

      await tester.pumpAndSettle();

      // Confirma a seleção na UI.
      expect(
        find.descendant(
          of: bohemianTile,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      expect(
        find.descendant(
          of: billieJeanTile,
          matching: find.byIcon(Icons.check_box),
        ),
        findsOneWidget,
      );

      final user = FirebaseAuth.instance.currentUser;
      expect(user, isNotNull);

      final uid = user!.uid;

      // Não deve existir uma playlist com esse nome antes do save.
      final antes = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: uid)
          .where('nome', isEqualTo: nomePlaylist)
          .get();

      expect(antes.docs, isEmpty);

      // Salva pela interface.
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      // CriarPlaylistScreen chama Navigator.pop() depois do save.
      expect(find.text('Criando Playlist'), findsNothing);

      // Consulta o Firestore real/emulado.
      final resultado = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: uid)
          .where('nome', isEqualTo: nomePlaylist)
          .get();

      expect(resultado.docs, hasLength(1));

      final playlist = resultado.docs.single.data();

      // Associação com o usuário autenticado.
      expect(playlist['userId'], equals(uid));

      // O nome deve ser exatamente o valor digitado.
      expect(playlist['nome'], equals(nomePlaylist));

      // As músicas selecionadas devem ter sido persistidas.
      expect(
        playlist['musicas'],
        containsAll(<String>[
          'bohemian rhapsody',
          'billie jean',
        ]),
      );

      expect(playlist['musicas'], hasLength(2));

      // _salvarPlaylist() grava Timestamp.now().
      expect(playlist['dataCriacao'], isA<Timestamp>());
    },
  );

  testWidgets(
    'E2E - nome vazio não salva playlist',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await login(tester);
      await navegarParaCriarPlaylist(tester);

      // Confirma que a tela carregou as músicas reais do Firestore.
      expect(
        find.text('Bohemian Rhapsody - Queen'),
        findsOneWidget,
      );

      final user = FirebaseAuth.instance.currentUser;
      expect(user, isNotNull);

      final uid = user!.uid;

      // Mantém o nome vazio.
      final nomeVazio = find.byType(TextField).at(0);

      await tester.tap(nomeVazio);
      await tester.enterText(nomeVazio, '');

      // Seleciona uma música.
      final bohemianTile = find.ancestor(
        of: find.text('Bohemian Rhapsody - Queen'),
        matching: find.byType(ListTile),
      );

      await tester.tap(
        find.descendant(
          of: bohemianTile,
          matching: find.byType(IconButton),
        ),
      );

      // Tenta salvar.
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      // O nome vazio deve ser rejeitado pela aplicação.
      expect(
        find.text('Nome da playlist é obrigatório'),
        findsOneWidget,
      );

      // A tela continua aberta porque _salvarPlaylist() não deve ser chamado.
      expect(find.text('Criando Playlist'), findsOneWidget);

      // Nenhum documento deve ter sido criado.
      final resultado = await FirebaseFirestore.instance
          .collection('playlists')
          .where('userId', isEqualTo: uid)
          .where('nome', isEqualTo: '')
          .get();

      expect(resultado.docs, isEmpty);
    },
  );
}
```

 ## Problema real encontrado na aplicação

 O segundo erro deve ser tratado separadamente. Na aplicação existe:

```
void _loadLastRecommendedMusic() async {
  final lastMusic = await fetchLastRecommendedMusic();
  setState(() {
    _currentMusic = lastMusic;
  });
}
```

 O problema é que `fetchLastRecommendedMusic()` é assíncrono. Enquanto ele aguarda Firestore, o usuário/teste pode sair da `TelaInicialScreen`. Quando a operação termina, o `State` pode não estar mais montado.

 O comportamento esperado seria verificar `mounted` antes do `setState`, por exemplo:

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

 Esse é um **defeito da aplicação**, não uma condição que o teste deveria ignorar.

 Além disso, o mesmo padrão deve ser revisado em `_fetchNewMusic()` e em qualquer outro método assíncrono da aplicação que faça `setState()` depois de um `await`.

 Portanto, após corrigir a asserção de login, o teste está cobrindo o fluxo solicitado corretamente; se o `setState() called after dispose()` continuar aparecendo, ele deve ser tratado como falha da implementação do `TelaInicialScreen`, e não como motivo para enfraquecer o teste.