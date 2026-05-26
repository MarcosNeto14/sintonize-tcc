# E2E-04 — Adicionar Música a Playlist Existente

## Metadados

| Campo | Valor |
|---|---|
| **ID** | E2E-04 |
| **Fluxo** | Adicionar músicas a uma playlist já criada |
| **Telas envolvidas** | TelaInicialScreen → AdicionarMusicaScreen → TelaInicialScreen |
| **Tipo** | Manual |
| **Data de execução** | 2026-05-25 |
| **Dispositivo/Emulador** | Web — Google Chrome (`flutter run -d chrome`) |
| **Versão do app** | Flutter 3.41.6 |

---

## Pré-condições

- Usuário autenticado (executar E2E-02 antes)
- Ao menos uma playlist existente (executar E2E-03 antes)
- Conexão com internet ativa

---

## Passos e Resultados

| # | Passo | Resultado Esperado | Resultado Real | Status |
|---|---|---|---|---|
| 1 | Na TelaInicialScreen, localizar uma playlist existente | Playlist criada no E2E-03 listada | Conforme esperado | ✅ |
| 2 | Acessar opção de adicionar músicas à playlist | AdicionarMusicaScreen exibida com campo de pesquisa e lista de músicas não presentes na playlist | Conforme esperado | ✅ |
| 3 | Aguardar carregamento da lista | Lista de músicas disponíveis exibida | Conforme esperado | ✅ |
| 4 | Digitar termo no campo de pesquisa | Lista filtra corretamente | Conforme esperado | ✅ |
| 5 | Selecionar ao menos 1 música tocando no checkbox | Ícone muda para check_box | Conforme esperado | ✅ |
| 6 | Tocar em "Concluir" | App atualiza a playlist no Firestore e retorna para tela anterior | Conforme esperado | ✅ |
| 7 | Verificar que a música adicionada aparece na playlist | Música listada na playlist | Conforme esperado | ✅ |

---

## Cenários de Erro

| # | Passo | Resultado Esperado | Resultado Real | Status |
|---|---|---|---|---|
| E1 | Tocar "Concluir" sem selecionar nenhuma música | App retorna para tela anterior sem salvar (Navigator.pop sem Firestore update) | Conforme esperado | ✅ |

---

## Resultado Geral

| Métrica | Valor |
|---|---|
| **Passos executados** | 7 / 7 |
| **Passos aprovados** | 7 |
| **Passos reprovados** | 0 |
| **Erros validados** | 1 / 1 |
| **Status geral** | ✅ Aprovado |

---

## Observações

Nenhuma. Todos os 7 passos e 1 cenário de erro executados sem desvios.
