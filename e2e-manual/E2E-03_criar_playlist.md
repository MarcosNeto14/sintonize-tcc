# E2E-03 — Criar Playlist

## Metadados

| Campo | Valor |
|---|---|
| **ID** | E2E-03 |
| **Fluxo** | Criação de nova playlist com músicas |
| **Telas envolvidas** | TelaInicialScreen → CriarPlaylistScreen → TelaInicialScreen |
| **Tipo** | Manual |
| **Data de execução** | 2026-05-25 |
| **Dispositivo/Emulador** | Web — Google Chrome (`flutter run -d chrome`) |
| **Versão do app** | Flutter 3.41.6 |

---

## Pré-condições

- Usuário autenticado (executar E2E-02 antes)
- Conexão com internet ativa (Firebase + coleção "musica" populada)

---

## Passos e Resultados

| # | Passo | Resultado Esperado | Resultado Real | Status |
|---|---|---|---|---|
| 1 | Na TelaInicialScreen, navegar até a opção de criar playlist | Botão/ícone de criação de playlist visível | Conforme esperado | ✅ |
| 2 | Tocar na opção de criar playlist | CriarPlaylistScreen exibida com campo "Nome da Playlist", campo de pesquisa e lista de músicas | Conforme esperado | ✅ |
| 3 | Aguardar carregamento da lista de músicas | Lista de músicas exibida (substituindo CircularProgressIndicator) | Conforme esperado | ✅ |
| 4 | Preencher "Nome da Playlist" com valor válido (ex: "Minha Playlist") | Campo aceita o texto | Conforme esperado | ✅ |
| 5 | Digitar termo no campo de pesquisa (ex: "rock") | Lista filtra músicas contendo o termo pesquisado | Conforme esperado | ✅ |
| 6 | Limpar pesquisa e selecionar ao menos 1 música tocando no ícone de checkbox | Ícone muda para check_box (selecionado) | Conforme esperado | ✅ |
| 7 | Tocar em "Salvar Playlist" | App salva a playlist no Firestore e retorna para tela anterior | Conforme esperado | ✅ |
| 8 | Verificar que a playlist criada aparece na TelaInicialScreen | Nova playlist listada | Conforme esperado | ✅ |

---

## Cenários de Erro

| # | Passo | Resultado Esperado | Resultado Real | Status |
|---|---|---|---|---|
| E1 | Tocar "Salvar Playlist" sem preencher o nome | SnackBar "Nome da playlist é obrigatório" | Conforme esperado | ✅ |

---

## Resultado Geral

| Métrica | Valor |
|---|---|
| **Passos executados** | 8 / 8 |
| **Passos aprovados** | 8 |
| **Passos reprovados** | 0 |
| **Erros validados** | 1 / 1 |
| **Status geral** | ✅ Aprovado |

---

## Observações

Nenhuma. Todos os 8 passos e 1 cenário de erro executados sem desvios.
