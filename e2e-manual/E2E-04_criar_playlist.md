# E2E-04 — Criar Playlist

## Metadados

| Campo | Valor |
|---|---|
| **ID** | E2E-04 |
| **Fluxo** | Criação de nova playlist com músicas |
| **Telas envolvidas** | TelaInicialScreen → CriarPlaylistScreen → TelaInicialScreen |
| **Tipo** | Manual |
| **Data de execução** | [preencher] |
| **Dispositivo/Emulador** | [preencher] |
| **Versão do app** | Flutter 3.41.6 |

---

## Pré-condições

- Usuário autenticado (executar E2E-02 antes)
- Conexão com internet ativa (Firebase + coleção "musica" populada)

---

## Passos e Resultados

| # | Passo | Resultado Esperado | Resultado Real | Status |
|---|---|---|---|---|
| 1 | Na TelaInicialScreen, navegar até a opção de criar playlist | Botão/ícone de criação de playlist visível | [preencher] | ⬜ |
| 2 | Tocar na opção de criar playlist | CriarPlaylistScreen exibida com campo "Nome da Playlist", campo de pesquisa e lista de músicas | [preencher] | ⬜ |
| 3 | Aguardar carregamento da lista de músicas | Lista de músicas exibida (substituindo CircularProgressIndicator) | [preencher] | ⬜ |
| 4 | Preencher "Nome da Playlist" com valor válido (ex: "Minha Playlist") | Campo aceita o texto | [preencher] | ⬜ |
| 5 | Digitar termo no campo de pesquisa (ex: "rock") | Lista filtra músicas contendo o termo pesquisado | [preencher] | ⬜ |
| 6 | Limpar pesquisa e selecionar ao menos 1 música tocando no ícone de checkbox | Ícone muda para check_box (selecionado) | [preencher] | ⬜ |
| 7 | Tocar em "Salvar Playlist" | App salva a playlist no Firestore e retorna para tela anterior | [preencher] | ⬜ |
| 8 | Verificar que a playlist criada aparece na TelaInicialScreen | Nova playlist listada | [preencher] | ⬜ |

---

## Cenários de Erro

| # | Passo | Resultado Esperado | Resultado Real | Status |
|---|---|---|---|---|
| E1 | Tocar "Salvar Playlist" sem preencher o nome | SnackBar "Nome da playlist é obrigatório" | [preencher] | ⬜ |

---

## Resultado Geral

| Métrica | Valor |
|---|---|
| **Passos executados** | [preencher] / 8 |
| **Passos aprovados** | [preencher] |
| **Passos reprovados** | [preencher] |
| **Erros validados** | [preencher] / 1 |
| **Status geral** | ⬜ Aprovado / ⬜ Reprovado / ⬜ Aprovado com ressalvas |

---

## Observações

[preencher]
