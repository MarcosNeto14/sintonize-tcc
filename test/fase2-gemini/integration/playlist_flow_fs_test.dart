import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:sintonize/criar_playlist.dart';

void main() {
  group('Fluxo de Criar Playlist', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() async {
      final mockUser = MockUser(
        uid: 'user_123',
        email: 'ouvinte@sintonize.com',
        displayName: 'Usuario Teste',
      );

      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      fakeFirestore = FakeFirebaseFirestore();

      // Popula o Firestore falso com músicas iniciais
      await fakeFirestore.collection('musica').add({
        'track_name': 'tempo perdido',
        'artist_name': 'legiao urbana',
      });

      await fakeFirestore.collection('musica').add({
        'track_name': 'metamorfose ambulante',
        'artist_name': 'raul seixas',
      });
    });

    Widget montarApp() {
      return MaterialApp(
        home: CriarPlaylistScreen(
          editPlaylist: const {},
          auth: mockAuth,
          firestore: fakeFirestore,
        ),
      );
    }

    testWidgets('cria e persiste uma nova playlist com sucesso no Firestore',
        (tester) async {
      await tester.pumpWidget(montarApp());

      // Aguarda a resolução da consulta assíncrona _fetchMusicas() e animações
      await tester.pumpAndSettle();

      // Valida se as músicas carregadas do Firestore são exibidas na listagem formatadas
      expect(find.text('Tempo Perdido - Legiao Urbana'), findsOneWidget);
      expect(find.text('Metamorfose Ambulante - Raul Seixas'), findsOneWidget);

      // Preenche o nome da playlist
      final campoNome = find.widgetWithText(TextField, 'Nome da Playlist');
      await tester.enterText(campoNome, 'Classicos do Rock');

      // Seleciona a primeira música clicando no ícone de checkbox correspondente
      final checkboxPrimeiraMusica = find.descendant(
        of: find.widgetWithText(Card, 'Tempo Perdido - Legiao Urbana'),
        matching: find.byType(IconButton),
      );
      await tester.tap(checkboxPrimeiraMusica);
      await tester.pump();

      // Confirma visualmente que o estado mudou para checked
      expect(find.byIcon(Icons.check_box), findsOneWidget);

      // Clica para salvar a playlist
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pumpAndSettle();

      // Verifica no Firestore se a playlist foi adicionada com os dados corretos
      final playlistsSnapshot =
          await fakeFirestore.collection('playlists').get();

      expect(playlistsSnapshot.docs.length, 1);

      final playlistCriada = playlistsSnapshot.docs.first.data();
      expect(playlistCriada['userId'], 'user_123');
      expect(playlistCriada['nome'], 'Classicos do Rock');
      expect(playlistCriada['musicas'], contains('tempo perdido'));
    });

    testWidgets('exibe mensagem de erro ao tentar salvar sem preencher o nome',
        (tester) async {
      await tester.pumpWidget(montarApp());
      await tester.pumpAndSettle();

      // Toca em salvar sem preencher o campo obrigatório
      await tester.tap(find.text('Salvar Playlist'));
      await tester.pump();

      // Valida a exibição do SnackBar
      expect(find.text('Nome da playlist é obrigatório'), findsOneWidget);

      // Confirma que nenhum documento foi criado
      final playlistsSnapshot =
          await fakeFirestore.collection('playlists').get();
      expect(playlistsSnapshot.docs, isEmpty);
    });
  });
}
