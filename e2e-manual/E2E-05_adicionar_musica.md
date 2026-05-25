# E2E-05 — Adicionar Música a Playlist Existente

## Metadados

| Campo | Valor |
|---|---|
| **ID** | E2E-05 |
| **Fluxo** | Adicionar músicas a uma playlist já criada |
| **Telas envolvidas** | TelaInicialScreen → AdicionarMusicaScreen → TelaInicialScreen |
| **Tipo** | Manual |
| **Data de execução** | [preencher] |
| **Dispositivo/Emulador** | [preencher] |
| **Versão do app** | Flutter 3.41.6 |

---

## Pré-condições

- Usuário autenticado (executar E2E-02 antes)
- Ao menos uma playlist existente (executar E2E-04 antes)
- Conexão com internet ativa

---

## Passos e Resultados

| # | Passo | Resultado Esperado | Resultado Real | Status |
|---|---|---|---|---|
| 1 | Na TelaInicialScreen, localizar uma playlist existente | Playlist criada no E2E-04 listada | [preencher] | ⬜ |
| 2 | Acessar opção de adicionar músicas à playlist | AdicionarMusicaScreen exibida com campo de pesquisa e lista de músicas não presentes na playlist | [preencher] | ⬜ |
| 3 | Aguardar carregamento da lista | Lista de músicas disponíveis exibida | [preencher] | ⬜ |
| 4 | Digitar termo no campo de pesquisa | Lista filtra corretamente | [preencher] | ⬜ |
| 5 | Selecionar ao menos 1 música tocando no checkbox | Ícone muda para check_box | [preencher] | ⬜ |
| 6 | Tocar em "Concluir" | App atualiza a playlist no Firestore e retorna para tela anterior | [preencher] | ⬜ |
| 7 | Verificar que a música adicionada aparece na playlist | Música listada na playlist | [preencher] | ⬜ |

---

## Cenários de Erro

| # | Passo | Resultado Esperado | Resultado Real | Status |
|---|---|---|---|---|
| E1 | Tocar "Concluir" sem selecionar nenhuma música | App retorna para tela anterior sem salvar (Navigator.pop sem Firestore update) | [preencher] | ⬜ |

---

## Resultado Geral

| Métrica | Valor |
|---|---|
| **Passos executados** | [preencher] / 7 |
| **Passos aprovados** | [preencher] |
| **Passos reprovados** | [preencher] |
| **Erros validados** | [preencher] / 1 |
| **Status geral** | ⬜ Aprovado / ⬜ Reprovado / ⬜ Aprovado com ressalvas |

---

## Observações

[preencher]
